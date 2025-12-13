----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2025 17:11:05
-- Design Name: 
-- Module Name: ContadorGenerico - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ContadorGenerico is
    generic(
        N_BITS : integer := 4;
        MAX_VALOR : integer := 10
    );
    port (
        --Entradas
        clk        : in  std_logic;
        rst        : in  std_logic;
      --  enable     : in  std_logic;                    
        
        --Salidas
        cuenta     : out std_logic_vector(N_BITS-1 downto 0);
        f_cuenta   : out std_logic
    );
end ContadorGenerico;

architecture Behavioral of ContadorGenerico is
    signal counter_reg : unsigned(N_BITS-1 downto 0) := (others => '0');
    signal done_signal : std_logic := '0';  -- Señal interna para f_cuenta
begin
    process(clk, rst)
    begin
    if rst = '0' then
        counter_reg <= (others => '0');
        done_signal <= '0';
    elsif rising_edge(clk) then
       -- if enable = '1' then
            if counter_reg = (MAX_VALOR - 2) then
                done_signal <= '1';  -- activa antes del último valor
            else
                done_signal <= '0';
            end if;

            if counter_reg = (MAX_VALOR - 1) then
                counter_reg <= (others => '0');
            else
                counter_reg <= counter_reg + 1;
            end if;
       -- end if;
    end if;
end process;


    cuenta <= STD_LOGIC_VECTOR(counter_reg);  -- Asignar el valor del contador a la salida
    f_cuenta <= done_signal;  -- Asignar la se al interna a la salida f_cuenta
    
end Behavioral;



