library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_TOP_tb is
--  Port ( );
end ADC_TOP_tb;

architecture Behavioral of ADC_TOP_tb is

component ADC_TOP is
    port( 
          i_D1     : in STD_LOGIC; -- dato serial
          start, nrst, i_clk     : in STD_LOGIC;
         
          o_D1  : out STD_LOGIC_VECTOR (11 downto 0); -- bus 12 bits
          drdy, cs, o_clk     : out STD_LOGIC);
end component ADC_TOP;

signal D1_in_tb , START_tb , clk_in_tb, DRDY_tb, clk_out_tb, CS_tb, nrst_tb, bit_out_tb : STD_LOGIC;
signal D1_out_tb : STD_LOGIC_VECTOR (11 downto 0);

begin
    UUT: ADC_TOP port map ( i_D1 => D1_in_tb,
                                   START => START_tb,
                                   nrst => nrst_tb,
                                   i_clk => clk_in_tb,
                                   DRDY => DRDY_tb,
                                   o_D1 => D1_out_tb,
                                   o_clk => clk_out_tb,
                                   CS => CS_tb); 
                                           
    GEN_CLK: process
    begin
        clk_in_tb <= '1';
        wait for 2.5 ns; -- Ton
        clk_in_tb <= '0';
        wait for 2.5 ns; -- Toff
    end process;            
    

   STIM: process
    begin
        -- 1. Reset inicial
        nrst_tb <= '0'; 
        wait for 20 ns;
        nrst_tb <= '1'; 
        wait for 20 ns;

        -- 2. Iniciar
        START_tb <= '1';
        wait for 10 ns;
        START_tb <= '0';
        wait for 160 ns;
       
        -- 3. Inyectar bits manualmente (ejemplo: 1010...)
        -- Ajustamos al tiempo del clk_out (50 ns por bit)
        D1_in_tb <= '1'; wait for 50 ns; --[11]
        D1_in_tb <= '0'; wait for 50 ns; --[10]
        D1_in_tb <= '1'; wait for 50 ns; --[9]
        D1_in_tb <= '0'; wait for 50 ns; --[8]
        D1_in_tb <= '0'; wait for 50 ns; --[7]
        D1_in_tb <= '1'; wait for 50 ns; --[6]
        D1_in_tb <= '0'; wait for 50 ns; --[5]
        D1_in_tb <= '1'; wait for 50 ns; --[4]
        D1_in_tb <= '0'; wait for 50 ns; --[3]
        D1_in_tb <= '1'; wait for 50 ns; --[2]
        D1_in_tb <= '0'; wait for 50 ns; --[1]
        D1_in_tb <= '0'; wait for 50 ns; --[0]
                
        wait; 
    end process;
                                                  
end Behavioral;

