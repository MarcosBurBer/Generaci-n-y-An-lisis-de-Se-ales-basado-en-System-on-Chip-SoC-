----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2025 12:57:46
-- Design Name: 
-- Module Name: DAC_CONTROLLER_tb - Behavioral
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

entity DAC_CONTROLLER_tb is
--  Port ( );
end DAC_CONTROLLER_tb;

architecture Behavioral of DAC_CONTROLLER_tb is
component DAC_CONTROLLER is
    port ( -- ENTRADAS
           START  : in STD_LOGIC;
           in_D1  : in STD_LOGIC_VECTOR ( 11 downto 0 );
           rst    : in STD_LOGIC;
           clk_in : in STD_LOGIC;
        
           -- SALIDAS
           DONE    : out STD_LOGIC;
           clk_out : out STD_LOGIC;
           nSYNC   : out STD_LOGIC;
           out_D1  : out STD_LOGIC);
end component;

    signal DONE, START, clk_in, clk_out, nSYNC, out_D1, rst : STD_LOGIC;
    signal in_D1 : STD_LOGIC_VECTOR ( 11 downto 0 );
begin

    UUT: DAC_CONTROLLER
         port map (
          DONE    => DONE,
          START   => START,
          clk_in  => clk_in,
          clk_out => clk_out,
          in_D1(11 downto 0) => in_D1(11 downto 0),
          nSYNC  => nSYNC,
          out_D1 => out_D1,
          rst => rst
        );
    
    GEN_CLK: process
    begin
        clk_in <= '1';
        wait for 5 ns; -- Ton
        clk_in <= '0';
        wait for 5 ns; -- Toff
    end process;
    
    in_D1 <= "111111110000"; -- "1111 1111 0000"
    
    rst <= '0', '1' after 10 ns;
    START <= '0', '1' after 20 ns, '0' after 372 ns; --, '1' after 100 ns;
end Behavioral;
