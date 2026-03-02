----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 19:13:46
-- Design Name: 
-- Module Name: Memoria_RAM - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memoria_RAM is
    Generic ( d_width    : integer; -- ancho de palabra
              addr_width : integer); -- tamaño de la memoria
              
       Port ( clk     : in STD_LOGIC;
              wr_en   : in STD_LOGIC; -- enable escritura
              addr_rd : in STD_LOGIC_VECTOR ((addr_width - 1) downto 0); -- dirección a leer
              addr_wr : in STD_LOGIC_VECTOR ((addr_width - 1) downto 0); -- dirección a escribir
              data_in : in STD_LOGIC_VECTOR ((d_width - 1) downto 0); -- dato de entrada a escribir
              data_out : out STD_LOGIC_VECTOR ((d_width - 1) downto 0)); -- dato de salida a leer
end Memoria_RAM;

architecture Behavioral of Memoria_RAM is

type memory is array(((2**addr_width) - 1) downto 0) of STD_LOGIC_VECTOR((d_width - 1) downto 0);
signal ram: memory;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                ram(TO_INTEGER(UNSIGNED(addr_wr))) <= data_in;
            end if;
            data_out <= ram(TO_INTEGER(UNSIGNED(addr_rd)));
        end if;
     end process;

end Behavioral;
