----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 20:41:45
-- Design Name: 
-- Module Name: AddCtrl - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AddrCtrl is
  generic (
    ADDR_WIDTH : integer  -- ancho del contador de direcciones
  );
  port (
    clk  : in  std_logic;
    rst   : in  std_logic;
    DONE   : in  std_logic;
    addr_rd : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
    START  : out std_logic
  );
end entity;

architecture rtl of AddrCtrl is

  signal done_ff1, done_ff2, done_ff3, done_ff4 : std_logic;  -- registros para detectar flanco
  signal start_reg           : std_logic;
  signal addr_counter        : unsigned((ADDR_WIDTH - 1) downto 0) := (others => '0');

begin

  -- Detector de flanco: flanco ascendente de DONE
  proc_flanco : process(clk, rst)
  begin
    if rst = '0' then
      done_ff1 <= '0';
      done_ff2 <= '0';
    elsif rising_edge(clk) then
      done_ff1 <= DONE;
      done_ff2 <= done_ff1;
    end if;
  end process;

  -- Generar se al START cuando haya flanco de DONE
  start_reg <= '1' when (done_ff1 = '1' and done_ff2 = '0') else '0';
  
  -- Contador de direcciones
  proc_counter : process(clk, rst)
  begin
    if rst = '0' then
      addr_counter <= (others => '0');
    elsif rising_edge(clk) then
      if start_reg = '1' then
        addr_counter <= addr_counter + 1;
      end if;
    end if;
  end process;
  
  signal_delay : process(clk, rst) -- detector de flanco para retrasar un ciclo de reloj el START
  begin
    if rst = '0' then
      done_ff3 <= '0';
      done_ff4 <= '0';
    elsif rising_edge(clk) then
      done_ff3 <= start_reg;
      done_ff4 <= done_ff3;
    end if;
  end process;
  
  START <= done_ff4;
  addr_rd <= std_logic_vector(addr_counter);
  
end architecture;