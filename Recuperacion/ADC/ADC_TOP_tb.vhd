library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_CONTROLLER_tb is
--  Port ( );
end ADC_CONTROLLER_tb;

architecture Behavioral of ADC_CONTROLLER_tb is

component ADC_CONTROLLER is
    port( 
          D1_in     : in STD_LOGIC;
          START     : in STD_LOGIC;
          rst       : in STD_LOGIC;
          clk_in    : in STD_LOGIC;
          
          
          DRDY    : out STD_LOGIC;
          D1_out  : out STD_LOGIC_VECTOR (11 downto 0); 
          clk_out : out STD_LOGIC;
          CS      : out STD_LOGIC);
end component ADC_CONTROLLER;

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
       
    process
    begin
        -- 1. Reset inicial
        rst <= '0'; 
        wait for 20 ns;
        rst <= '1'; 
        wait for 20 ns;

        -- 2. Iniciar
        START <= '1';
        wait for 10 ns;
        START <= '0';
        wait for 160 ns;
        -- 3. Inyectar bits manualmente (ejemplo: 1010...)
        -- Ajustamos al tiempo del clk_out (50 ns por bit)
        D1_in <= '1'; wait for 50 ns; --[11]
        D1_in <= '0'; wait for 50 ns; --[10]
        D1_in <= '1'; wait for 50 ns; --[9]
        D1_in <= '0'; wait for 50 ns; --[8]
        D1_in <= '0'; wait for 50 ns; --[7]
        D1_in <= '1'; wait for 50 ns; --[6]
        D1_in <= '0'; wait for 50 ns; --[5]
        D1_in <= '1'; wait for 50 ns; --[4]
        D1_in <= '0'; wait for 50 ns; --[3]
        D1_in <= '1'; wait for 50 ns; --[2]
        D1_in <= '0'; wait for 50 ns; --[1]
        D1_in <= '0'; wait for 50 ns; --[0]
                
        wait; -- Fin de la simulación
    end process;
                                                       
end Behavioral;

