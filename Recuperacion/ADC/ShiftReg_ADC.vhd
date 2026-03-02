----------------------------------------------------------------------------------
-- DESCRIPCIÓN DEL MÓDULO DAC PMOD DA2
-- EL DISPOSITIVO CUENTA CON 6 TERMINALES:
--    - nSync: Selección de chip (nivel bajo activo). Cuando está en '0', permite la recepción de datos;
--      en '1', ignora la información entrante.
--    - DIN_A: Línea de datos serie para el canal A (12 bits de resolución).
--    - DIN_B: Línea de datos serie para el canal B (12 bits de resolución).
--    - SCLK: Reloj de comunicación compatible con SPI. Frecuencia máxima de 30 MHz.
--      Requiere 16 ciclos por transferencia: el bit más significativo del dato
--      debe transmitirse durante los últimos 12 pulsos.
--    - GND: Referencia a masa (0 V).
--    - VCC: Alimentación positiva (+3,3 V).
--    - OutA: Tensión analógica de salida (rango de 0 a 3,3 V).
--      Resolución: 0,8 mV por escalón.
----------------------------------------------------------------------------------
--------------------------------------------------------------------
-- Registro de Desplazamiento para ADC
-- Versión: 1.0
-- Descripción: Convierte datos serie a paralelo para ADC
--------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ShiftReg_ADC is           
       Port ( 
              clk    : in STD_LOGIC; -- 20 MHz
              in_D1  : in STD_LOGIC; -- dato serie
              enable : in STD_LOGIC; -- habilita clk
                            
              out_D1      : out STD_LOGIC_VECTOR (11 downto 0); -- dato bus
              Shift_Cnt : out STD_LOGIC_VECTOR (3 downto 0)); -- contador de desplazamiento
end ShiftReg_ADC;

architecture Behavioral of ShiftReg_ADC is

    signal s_SPI : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- señal de 4 bits protocolo SPI
    signal s_counter : unsigned(3  downto 0) := (others => '0'); -- contador de desplazamiento de registro

begin

    IDLE: process (clk, enable)
    begin
        if rising_edge(clk) then 
            if enable = '1' then -- habilita el registro de desplazamiento
                s_SPI(15 downto 1) <= s_SPI(14 downto 0);
                s_SPI(0) <= in_D1;

                
                if s_counter = "1111" then -- termina de enviar el dato
                    out_D1 <= s_SPI(11 downto 0); -- 12 MSB de SPI -> dato digital
                end if;
                s_counter <= s_counter + 1;
            else         
                s_counter <= "0000";
            end if;
        end if;
    end process;

    Shift_Cnt <= STD_LOGIC_VECTOR(s_counter);
    
end Behavioral;
