----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2025 15:35:31
-- Design Name: 
-- Module Name: Counter - Behavioral
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

use IEEE.NUMERIC_STD.ALL;



entity Counter is

  Port (

    clk50   : in  std_logic;

    nRST    : in  std_logic;       -- Reset activo alto

    enCnt   : in  std_logic;       -- Habilitación desde DetFlanco

    addr_rd : out std_logic_vector(13 downto 0)  

  );

end Counter;



architecture Behavioral of Counter is

  signal count : unsigned (13 downto 0) := (others => '0');

begin



  process(clk50, nRST)

  begin

    if nRST = '0' then

      count <= (others => '0');

    elsif rising_edge(clk50) then

      if enCnt = '1' then

        count <= count + 1;

      end if;

    end if;

  end process;



  addr_rd <= std_logic_vector(count);



end Behavioral;
