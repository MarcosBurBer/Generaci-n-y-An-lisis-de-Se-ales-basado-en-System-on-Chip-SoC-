----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 17:23:23
-- Design Name: 
-- Module Name: AddCtrl_tb - Behavioral
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

entity AddCtrl_tb is
--  Port ( );
end AddCtrl_tb;

architecture Behavioral of AddCtrl_tb is

component AddrCtrl is
  generic (
    ADDR_WIDTH : integer  -- ancho del contador de direcciones
  );
  port (
    clk  : in  std_logic;
    rst   : in  std_logic;
    DONE   : in  std_logic;
    addr_rd : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
    START  : out std_logic
  );
end component;
    
    constant ADDR_WIDTH : integer := 14;
    signal clk, rst, DONE, START : std_logic;
    signal addr_rd : std_logic_vector((ADDR_WIDTH - 1) downto 0);

begin
    UUT: AddrCtrl 
        generic map ( ADDR_WIDTH => ADDR_WIDTH)
        
           port map ( clk => clk,
                      rst => rst,
                      DONE => DONE,
                      addr_rd => addr_rd,
                      START => START);
    
    
    GEN_CLK: process
    begin
        clk <= '1';
        wait for 5 ns; -- Ton
        clk <= '0';
        wait for 5 ns; -- Toff
    end process;
    
    rst <= '0', '1' after 10 ns, '0' after 140 ns;
    DONE <= '0', '1' after 22 ns, '1' after 64 ns, '0' after 80 ns, '1' after 100 ns, '0' after 112 ns;
    
end Behavioral;
