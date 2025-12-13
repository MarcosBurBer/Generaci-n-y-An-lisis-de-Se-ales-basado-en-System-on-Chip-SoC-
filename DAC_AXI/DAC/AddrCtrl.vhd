----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2025 15:49:19
-- Design Name: 
-- Module Name: AddrCtrl - Behavioral
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

entity AddrCtrl is
    Port ( clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           DONE : in STD_LOGIC;
           addr_rd : out std_logic_vector(14-1 downto 0);
           START : out STD_LOGIC);
end AddrCtrl;

architecture Behavioral of AddrCtrl is

signal CLK, RST, OK, En_cnt, GO: std_logic;
signal addrrd: std_logic_vector(14-1 downto 0);
signal done_sync0, done_sync1 : std_logic := '0';

    component DetFlanco
      Port (
          clk50   : in  STD_LOGIC;
          nRST   : in  STD_LOGIC;
          DONE   : in STD_LOGIC;
          enCnt : out STD_LOGIC
      );
      end component;
      
      component Counter
      Port (
           clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           enCnt : in STD_LOGIC;
           addr_rd : out std_logic_vector(14-1 downto 0)
      );
      end component;
      
      component Registro
      Port (
           clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           enCnt : in STD_LOGIC;
           START : out STD_LOGIC
      );
      end component;

begin


    --DetFlanco
    U1: DetFlanco
    port map(
         clk50   => CLK,
         nRST    => RST,
         DONE  => done_sync1,
         enCnt => en_cnt
         );
    
    --Counter
    U2: Counter
    port map(
         clk50   => CLK,
         nRST    => RST,
         addr_rd  => addrrd,
         enCnt => en_cnt
         );
         
    --Register
    U3: Registro
    port map(
         clk50   => CLK,
         nRST    => RST,
         START  => GO,
         enCnt => en_cnt
         );
         
    --Entradas
    CLK <= clk50;  -- Reloj
    RST <= nRST;   -- Reset
    OK <= DONE;

    --Salidas
     START <= GO ;
    addr_rd <= addrrd;

     -- Sincronizador de la señal DONE que viene desde el dominio clkDiv
     process(clk50, nRST)
     begin
          if nRST = '0' then
               done_sync0 <= '0';
               done_sync1 <= '0';
          elsif rising_edge(clk50) then
               done_sync0 <= DONE;
               done_sync1 <= done_sync0;
          end if;
     end process;

end Behavioral;
