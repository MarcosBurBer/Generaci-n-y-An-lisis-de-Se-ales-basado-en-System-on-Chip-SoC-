----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2025 15:47:30
-- Design Name: 
-- Module Name: Registro - Behavioral
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



entity Registro is

  Port (

    clk50  : in  std_logic;

    nRST   : in  std_logic;  -- Reset activo alto

    enCnt  : in  std_logic;  -- Entrada desde DetFlanco

    START  : out std_logic

  );

end Registro;



architecture Behavioral of Registro is

  signal start_reg : std_logic;

begin



  process(clk50, nRST)

  begin

    if nRST = '0' then

      start_reg <= '0';

    elsif rising_edge(clk50) then

      start_reg <= enCnt;  -- Registrar el pulso

    end if;

  end process;



  START <= start_reg;



end Behavioral;
