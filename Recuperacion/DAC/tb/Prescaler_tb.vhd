----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2025 20:12:42
-- Design Name: 
-- Module Name: Prescaler_tb - Behavioral
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

entity Prescaler_tb is
--  Port ( );
end Prescaler_tb;

architecture Behavioral of Prescaler_tb is

component Prescaler is
    generic ( N_BITS      : integer;
              VAL_FCUENTA : integer );
             
       Port ( rst     : in STD_LOGIC;
              clk_in  : in STD_LOGIC; -- reloj de entrada
              clk_out : out STD_LOGIC); -- reloj escalado
end component;

    constant N_BITS : integer := 2; -- 2 bits
    constant VAL_FCUENTA : integer := 4; -- contará hasta 3 en binario
    
    signal rst, clk_in, clk_out : STD_LOGIC;
    
begin
    UUT: Prescaler generic map ( N_BITS => N_BITS,
                                 VAL_FCUENTA => VAL_FCUENTA)
                                 
                       port map( rst => rst,
                                 clk_in  => clk_in,
                                 clk_out => clk_out);
                                 
    GEN_CLK: process
    begin
        clk_in <= '1';
        wait for 5 ns; -- Ton
        clk_in <= '0';
        wait for 5 ns; -- Toff
    end process;
    
    rst <= '0', '1' after 24 ns, '0' after 70 ns, '0' after 200 ns, '1' after 300 ns;
    
end Behavioral;
