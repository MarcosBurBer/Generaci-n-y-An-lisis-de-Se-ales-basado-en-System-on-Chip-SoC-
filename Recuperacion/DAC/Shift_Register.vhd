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

entity Shift_Register is
    Generic ( SHIFT_ANCHO : integer; -- nº de bits para el nº de shifts
              N_Bits_D    : integer; -- nº de bits para el dato a convertir
              N_BITS_SPI  : integer ); -- nº de bits para SPI
              
       Port ( -- ENTRADAS
              clk    : in STD_LOGIC; -- señal de reloj (25 MHz)
              in_D1  : in STD_LOGIC_VECTOR ((N_Bits_D - 1) downto 0); -- entrada dato 1
              LoadData : in STD_LOGIC; -- registro de carga
              en_Sft : in STD_LOGIC; -- registro de cambio
               
              -- SALIDAS
              out_D1      : out STD_LOGIC; -- salida dato 1
              Sft_Counter : out STD_LOGIC_VECTOR ((SHIFT_ANCHO - 1) downto 0)); -- contador de cambio
end Shift_Register;

architecture Behavioral of Shift_Register is

    -- DECLARACIÓN DE SEÑALES
    signal SPI_out1 : STD_LOGIC_VECTOR((N_BITS_SPI - 1) downto 0); -- señal de 16 bits para mandar por protocolo SPI
    signal counter : unsigned((SHIFT_ANCHO - 1)  downto 0) := (others => '0'); -- contador del número de veces que se desplaza un registro
    
    signal i : integer := 0;

begin

    IDLE: process (clk)
    begin
        if rising_edge(clk) then 
            if LoadData = '1' then -- carga el dato de entrada como protocolo SPI de 16 bits
                SPI_out1((N_BITS_SPI - 1) downto N_Bits_D) <= (others => '0'); -- necesario para el protocolo SPI
                SPI_out1((N_Bits_D - 1) downto 0) <= in_D1; -- SPI_out(11 downto 0) contiene el valor digital
                
                counter <= "0000";
            elsif en_Sft = '1' then       
               
                    SPI_out1((N_BITS_SPI - 1) downto 1) <= SPI_out1((N_BITS_SPI - 2) downto 0); -- desplazando el LSB de SPI_out1
                    SPI_out1(0) <= SPI_out1(N_BITS_SPI - 1);   
                    
                    counter <= counter + 1;
            end if;
        end if;
    end process;
    
    -- ASIGNACIÓN DE SALIDAS
    out_D1 <= SPI_out1(N_BITS_SPI - 1); -- LSB como salida
    
    Sft_Counter <= STD_LOGIC_VECTOR(counter);
    
end Behavioral;
