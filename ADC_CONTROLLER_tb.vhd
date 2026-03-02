----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 09:48:19
-- Design Name: 
-- Module Name: ADC_CONTROLLER_tb - Behavioral
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

entity ADC_CONTROLLER_tb is
--  Port ( );
end ADC_CONTROLLER_tb;

architecture Behavioral of ADC_CONTROLLER_tb is

component ADC_CONTROLLER is
    port( -- ENTRADAS
          D1_in     : in STD_LOGIC;
          START     : in STD_LOGIC;
          rst       : in STD_LOGIC;
          clk_in    : in STD_LOGIC;
          
          -- SALIDAS
          DRDY    : out STD_LOGIC;
          D1_out  : out STD_LOGIC_VECTOR (11 downto 0); 
          clk_out : out STD_LOGIC;
          CS      : out STD_LOGIC);
end component ADC_CONTROLLER;

component rampa_serial_12bit is
    port(
        clk        : in  std_logic;         -- Reloj
        rst      : in  std_logic;         -- rst síncrono
        bit_out    : out std_logic          -- Salida serie
    );
end component rampa_serial_12bit;

signal D1_in, START , clk_in, DRDY, clk_out, CS, rst, bit_out : STD_LOGIC;
signal D1_out : STD_LOGIC_VECTOR (11 downto 0);

begin
    UUT: ADC_CONTROLLER port map ( D1_in => D1_in,
                                   START => START,
                                   rst => rst,
                                   clk_in => clk_in,
                                   DRDY => DRDY,
                                   D1_out => D1_out,
                                   clk_out => clk_out,
                                   CS => CS); 
    
    GEN_CLK: process
    begin
        clk_in <= '1';
        wait for 2.5 ns; -- Ton
        clk_in <= '0';
        wait for 2.5 ns; -- Toff
    end process;            
    
    D1_in <= '1';
    START <= '0', '1' after 23 ns; 
    
                 
                                   
end Behavioral;
