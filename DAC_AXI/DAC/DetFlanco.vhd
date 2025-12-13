----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2025 15:33:24
-- Design Name: 
-- Module Name: DetFlanco - Behavioral
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



entity DetFlanco is

  Port (

    clk50 : in std_logic;

    nRST  : in std_logic;  -- activo alto

    DONE  : in std_logic;

    enCnt : out std_logic

  );

end DetFlanco;



architecture Behavioral of DetFlanco is

  signal done_d1 : std_logic; -- Copia retrasada un ciclo del valor anterior de DONE

begin



  process(clk50, nRST)

  begin

    if nRST = '0' then          --  activo alto

      done_d1 <= '0';

      enCnt <= '0';

    elsif rising_edge(clk50) then

      -- Detección de flanco ascendente de DONE

      enCnt <= DONE and not(done_d1);

      done_d1 <= DONE;

    end if;

  end process;



end Behavioral;
