----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 19:41:07
-- Design Name: 
-- Module Name: Memoria_RAM_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memoria_RAM_tb is
--  Port ( );
end Memoria_RAM_tb;

architecture Behavioral of Memoria_RAM_tb is

component Memoria_RAM is
    Generic ( d_width    : integer; -- ancho de palabra
              addr_width : integer); -- tamaño de la memoria
              
       Port ( clk     : in STD_LOGIC;
              wr_en   : in STD_LOGIC; -- enable escritura
              addr_rd : in STD_LOGIC_VECTOR ((addr_width - 1) downto 0); -- dirección a leer
              addr_wr : in STD_LOGIC_VECTOR ((addr_width - 1) downto 0); -- dirección a escribir
              data_in : in STD_LOGIC_VECTOR ((d_width - 1) downto 0); -- dato de entrada a escribir
              data_out : out STD_LOGIC_VECTOR ((d_width - 1) downto 0)); -- dato de salida a leer
end component;

    -- ESTÍMULOS
    signal clk, wr_en : STD_LOGIC;
    
    constant d_width : integer := 8;
    constant addr_width : integer := 14;
    
    signal addr_rd, addr_wr : STD_LOGIC_VECTOR ((addr_width - 1) downto 0);
    signal data_in, data_out : STD_LOGIC_VECTOR ((d_width - 1) downto 0);

begin
    UUT: Memoria_RAM
            generic map ( d_width    => d_width,
                          addr_width => addr_width)
                         
               port map ( clk   => clk,
                          wr_en => wr_en,
                          addr_rd  => addr_rd,
                          addr_wr  => addr_wr,
                          data_in  => data_in,
                          data_out => data_out);
                          
    GEN_CLK: process
    begin
        clk <= '1';
        wait for 5 ns; -- Ton
        clk <= '0';
        wait for 5 ns; -- Toff
    end process;
    
    addr_rd <= "00000000000000", "00000000001111" after 36 ns;
    addr_wr <= "00000000000000", "00000000001111" after 36 ns;
    
    data_in <= "00001111", "11110000" after 36 ns;
    
    wr_en <= '0', '1' after 16 ns, '0' after 32 ns, '1' after 45 ns, '0' after 58 ns;
end Behavioral;
