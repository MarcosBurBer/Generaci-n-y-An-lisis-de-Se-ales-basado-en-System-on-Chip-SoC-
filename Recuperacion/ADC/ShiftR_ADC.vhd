----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2025 17:23:03
-- Design Name: 
-- Module Name: Shift_Register - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: IMPLEMENTACIÓN DEL DAC PMOD DA2
--   TIENE 6 PINES:
--    - nSync (cuando está en 0, se habilita a entrada de datos, cuando está a 1 se ignora la salida de datos)
--    - DIN_A (12 bits)
--    - DIN_B (12 bits)
--    - SLCK (señal de reloj de hasta 30 MHz sigue el protocolo SPI y se deben mandar 16 pulsos de reloj donde el MSB de DIN será mandado el primero de los últimos 12 pulsos)
--    - GND (0 V)
--    - Vcc (3,3 V)
--    - OutA (salida señal analógica entre 0 V y 3,3 V con una resolución de 0,8 mV por bit)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SR_ADC is           
       Port ( -- ENTRADAS
              clk    : in STD_LOGIC; -- señal de reloj (20 MHz)
              in_D1  : in STD_LOGIC; -- entrada dato 1 serie
              en_cnt : in STD_LOGIC; -- habilita el reloj
               
              -- SALIDAS
              out_D1      : out STD_LOGIC_VECTOR (11 downto 0); -- salida dato 1 en bus
              Sft_Counter : out STD_LOGIC_VECTOR (3 downto 0)); -- contador de cambio
end SR_ADC;

architecture Behavioral of SR_ADC is

    -- DECLARACIÓN DE SEÑALES
    signal SPI_in1 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- señal de 4 bits para mandar por protocolo SPI
    signal counter : unsigned(3  downto 0) := (others => '0'); -- contador del número de veces que se desplaza un registro

begin

    IDLE: process (clk, en_cnt)
    begin
        if rising_edge(clk) then 
            if en_cnt = '1' then -- habilita el registro de desplazamiento
                SPI_in1(15 downto 1) <= SPI_in1(14 downto 0);
                SPI_in1(0) <= in_D1;

                
                if counter = "1111" then -- solo cuando termina de mandar el dato
                    out_D1 <= SPI_in1(11 downto 0); -- primeros 12 bits de SPI es el dato digitalizado
                end if;
                counter <= counter + 1;
            else         
                counter <= "0000";
            end if;
        end if;
    end process;

    Sft_Counter <= STD_LOGIC_VECTOR(counter);
    
end Behavioral;
