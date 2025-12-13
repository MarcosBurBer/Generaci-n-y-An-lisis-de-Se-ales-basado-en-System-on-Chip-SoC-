----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.12.2025 12:58:43
-- Design Name: 
-- Module Name: ADC_Controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_Controller is
    Generic (
        SYS_CLK_FREQ : integer := 100_000_000; -- Reloj del sistema (100 MHz)
        -- Nyquist, duplicamos la velocidad del DAC (6.25 MHz)
        SCLK_FREQ    : integer := 12_500_000  -- Frecuencia deseada para SPI
         
    );
    Port (
        clk      : in  STD_LOGIC;
        reset_n  : in  STD_LOGIC;
        start    : in  STD_LOGIC; -- Señal para iniciar conversión
        
        -- Interfaz SPI (Pmod AD1)
        sdata    : in  STD_LOGIC; -- MISO
        sclk     : out STD_LOGIC; -- Reloj SPI
        cs       : out STD_LOGIC; -- Chip Select
        
        -- Interfaz Interna / AXI
        data_out : out STD_LOGIC_VECTOR (11 downto 0); -- 12 bits de datos puros
        drdy     : out STD_LOGIC -- Data Ready
    );
end ADC_Controller;

architecture Behavioral of ADC_Controller is

    -- Definición de Estados según tu diagrama
    type state_type is (HOLD, FPORCH, SHIFTING, BPORCH);
    signal current_state : state_type;

    -- Cálculos para el Prescaler (Generación de SCLK)
    constant CLK_DIV : integer := SYS_CLK_FREQ / (2 * SCLK_FREQ); 
    signal sclk_cnt  : integer range 0 to CLK_DIV := 0;
    signal sclk_int  : std_logic := '1'; -- Reloj interno SPI (empieza alto CPOL=1 o bajo CPOL=0)
    signal sclk_en   : std_logic := '0'; -- Habilitador de flancos

    -- Contadores de la FSM
    signal wait_cnt  : integer range 0 to 10 := 0; -- Para los Porches
    signal bit_cnt   : integer range 0 to 16 := 0; -- Para contar los 16 bits
    
    -- Registro de desplazamiento
    signal shift_reg : std_logic_vector(15 downto 0) := (others => '0');

begin

    -- Generación de SCLK (Prescaler)
    -- Genera un pulso 'sclk_en' cada vez que hay que cambiar el nivel de SCLK
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            sclk_cnt <= 0;
            sclk_int <= '1'; -- Pmod AD1 suele tener CPOL=1 (Idle High)
        elsif rising_edge(clk) then
            if current_state = SHIFTING then
                if sclk_cnt = CLK_DIV - 1 then
                    sclk_cnt <= 0;
                    sclk_int <= not sclk_int; -- Conmutar reloj
                else
                    sclk_cnt <= sclk_cnt + 1;
                end if;
            else
                sclk_cnt <= 0;
                sclk_int <= '1'; -- En reposo, SCLK alto
            end if;
        end if;
    end process;
    
    sclk <= sclk_int;

    -- Máquina de Estados Finita (FSM)
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            current_state <= HOLD;
            cs <= '1';
            drdy <= '0';
            bit_cnt <= 0;
            wait_cnt <= 0;
            data_out <= (others => '0');
            shift_reg <= (others => '0');
        elsif rising_edge(clk) then
            
            case current_state is
            
                when HOLD =>
                    cs <= '1';
                    drdy <= '0';
                    bit_cnt <= 0;
                    if start = '1' then
                        current_state <= FPORCH;
                        wait_cnt <= 0;
                    end if;

                when FPORCH =>
                    cs <= '0'; -- Bajamos CS
                    -- Según diagrama: cnt < 3 T_100MHz
                    if wait_cnt = 3 then 
                        current_state <= SHIFTING;
                        wait_cnt <= 0;
                    else
                        wait_cnt <= wait_cnt + 1;
                    end if;

                when SHIFTING =>
                    cs <= '0';
                    -- Lógica de muestreo en flanco de subida del SCLK (Rising Edge)
                    -- Pmod AD1: Los datos cambian en flanco de bajada, leemos en subida.
                    if sclk_cnt = CLK_DIV - 1 and sclk_int = '0' then -- Justo antes de ponerse a '1'
                        shift_reg <= shift_reg(14 downto 0) & sdata; -- Desplazamiento
                        bit_cnt <= bit_cnt + 1;
                    end if;

                    -- Condición de salida: 16 bits leídos
                    if bit_cnt = 16 then
                        current_state <= BPORCH;
                        wait_cnt <= 0;
                    end if;

                when BPORCH =>
                    cs <= '0';
                    -- Según tu diagrama: cnt < 1 T_100MHz
                    if wait_cnt = 1 then
                        drdy <= '1'; -- Dato válido
                        -- El Pmod AD1 envía 4 ceros + 12 datos. 
                        -- Tomamos los 12 bits menos significativos.
                        data_out <= shift_reg(11 downto 0); 
                        current_state <= HOLD;
                    else
                        wait_cnt <= wait_cnt + 1;
                    end if;
                    
            end case;
        end if;
    end process;

end Behavioral;
