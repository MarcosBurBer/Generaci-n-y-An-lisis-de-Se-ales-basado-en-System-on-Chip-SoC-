----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 15:37:25
-- Design Name: 
-- Module Name: FSM_tb - Behavioral
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

entity FSM_tb is
--  Port ( );
end FSM_tb;

architecture Behavioral of FSM_tb is

component FSM is
  generic ( SHIFT_ANCHO : integer ); -- ancho del ShiftCounter

     Port ( -- ENTRADAS
            clk   : in STD_LOGIC;  --CAMBIAR POR clkDiv
            START : in STD_LOGIC;
            rst   : in STD_LOGIC;
            Sft_Counter : in std_logic_vector((SHIFT_ANCHO - 1) downto 0);
           
            -- SALIDAS
            en_Sft   : out STD_LOGIC;
            DONE     : out STD_LOGIC;
            nSYNC    : out STD_LOGIC;
            LoadData : out STD_LOGIC );
end component;

constant SHIFT_ANCHO : integer := 4;
signal clk, START, rst, en_Sft, DONE, nSYNC, LoadData : STD_LOGIC;
signal Sft_Counter : std_logic_vector((SHIFT_ANCHO - 1) downto 0);

begin
    UUT: FSM
        generic map ( SHIFT_ANCHO => SHIFT_ANCHO)
        
           port map ( clk => clk,
                      START => START,
                      rst => rst,
                      Sft_Counter => Sft_Counter,
                      en_Sft => en_Sft,
                      DONE => DONE,
                      nSYNC => nSYNC,
                      LoadData => LoadData);
                      
    GEN_CLK: process
    begin
        clk <= '1';
        wait for 5 ns; -- Ton
        clk <= '0';
        wait for 5 ns; -- Toff
    end process;
                      
    rst <= '0', '1' after 160 ns;
    START <= '1', '0' after 40 ns, '1' after 100 ns;
    Sft_Counter <= "0000", "1111" after 36 ns, "0000" after 90 ns, "1111" after 136 ns;
    

end Behavioral;
