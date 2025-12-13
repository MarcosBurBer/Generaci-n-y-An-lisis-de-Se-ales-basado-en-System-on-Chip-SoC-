----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2025 13:41:15
-- Design Name: 
-- Module Name: DSP_Processor - Behavioral
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

entity DSP_Processor is
    Generic (
        SYS_CLK_FREQ : integer := 100_000_000 -- Reloj del sistema
    );
    Port (
        clk        : in  STD_LOGIC;
        reset_n    : in  STD_LOGIC;
        
        -- Interfaz con el ADC (Entrada)
        data_valid : in  STD_LOGIC; -- Pulso 'drdy' del ADC
        data_in    : in  STD_LOGIC_VECTOR(11 downto 0);
        
        -- Resultados (Salida hacia registros AXI)
        mav_out    : out STD_LOGIC_VECTOR(11 downto 0); -- Valor MAV calculado
        freq_out   : out STD_LOGIC_VECTOR(31 downto 0)  -- Frecuencia en Hz
    );
end DSP_Processor;

architecture Behavioral of DSP_Processor is

    -- Constantes
    constant DC_OFFSET : integer := 2048; -- Mitad de rango (4095/2)
    constant MAV_SAMPLES_LOG2 : integer := 10; -- 2^10 = 1024 muestras
    constant MAV_SAMPLES : integer := 2**MAV_SAMPLES_LOG2;

    -- --- NUEVO: MARGEN DE HISTÉRESIS ---
    -- Un margen de 100 unidades (aprox 0.08V) elimina el ruido de rebote.
    constant HYST_MARGIN : integer := 100; 
    constant THRESH_HIGH : integer := DC_OFFSET + HYST_MARGIN;
    constant THRESH_LOW  : integer := DC_OFFSET - HYST_MARGIN;

    -- Señales para MAV
    signal abs_val       : unsigned(11 downto 0);
    signal accum_mav     : unsigned(21 downto 0) := (others => '0');
    signal sample_cnt    : integer range 0 to MAV_SAMPLES := 0;
    
    -- Señales para Frecuencímetro
    signal raw_data_int : integer range 0 to 4095;
    signal crossings    : unsigned(31 downto 0) := (others => '0');
    signal timer_1sec   : integer range 0 to SYS_CLK_FREQ := 0;
    
    -- --- NUEVO: ESTADO DEL SCHMITT TRIGGER ---
    signal signal_state : std_logic := '0'; -- '0' = Bajo, '1' = Alto

begin

    -- Convertir entrada a entero para facilitar comparaciones
    raw_data_int <= to_integer(unsigned(data_in));

    -- ==========================================
    -- 1. LÓGICA DE VALOR ABSOLUTO MEDIO (MAV)
    -- ==========================================
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            accum_mav <= (others => '0');
            sample_cnt <= 0;
            mav_out <= (others => '0');
            abs_val <= (others => '0');
        elsif rising_edge(clk) then
            if data_valid = '1' then
                -- A. Calcular Valor Absoluto (|Data - 2048|)
                if raw_data_int >= DC_OFFSET then
                    abs_val <= to_unsigned(raw_data_int - DC_OFFSET, 12);
                else
                    abs_val <= to_unsigned(DC_OFFSET - raw_data_int, 12);
                end if;

                -- B. Acumular
                if sample_cnt < MAV_SAMPLES - 1 then
                    accum_mav <= accum_mav + abs_val;
                    sample_cnt <= sample_cnt + 1;
                else
                    -- C. Fin de ventana: Calcular promedio y reiniciar
                    mav_out <= std_logic_vector(accum_mav(21 downto 10) + abs_val(11 downto 10));
                    
                    accum_mav <= (others => '0'); 
                    sample_cnt <= 0;
                end if;
            end if;
        end if;
    end process;

    -- =================================================================
    -- 2. LÓGICA DE FRECUENCÍMETRO CON HISTÉRESIS (SCHMITT TRIGGER)
    -- =================================================================
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            crossings <= (others => '0');
            timer_1sec <= 0;
            freq_out <= (others => '0');
            signal_state <= '0';
        elsif rising_edge(clk) then
            
            -- Detección de cruce con Histéresis
            if data_valid = '1' then
                
                if signal_state = '0' then
                    -- Estamos en la zona BAJA. Esperamos a cruzar el UMBRAL ALTO.
                    if raw_data_int > THRESH_HIGH then
                        crossings <= crossings + 1; -- ¡CRUCE VÁLIDO!
                        signal_state <= '1';        -- Cambiamos estado a ALTO
                    end if;
                else
                    -- Estamos en la zona ALTA. Esperamos a bajar del UMBRAL BAJO.
                    if raw_data_int < THRESH_LOW then
                        signal_state <= '0';        -- Cambiamos estado a BAJO (rearmar)
                        -- No contamos aquí, solo rearmamos el trigger
                    end if;
                end if;
                
            end if;

            -- Timer de 1 segundo (Base de tiempo)
            if timer_1sec < SYS_CLK_FREQ - 1 then
                timer_1sec <= timer_1sec + 1;
            else
                -- Ha pasado 1 segundo: Actualizar salida y resetear
                timer_1sec <= 0;
                freq_out <= std_logic_vector(crossings);
                crossings <= (others => '0');
            end if;
            
        end if;
    end process;

end Behavioral;
