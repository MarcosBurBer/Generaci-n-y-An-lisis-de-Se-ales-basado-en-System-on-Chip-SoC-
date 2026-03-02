----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2025 19:58:19
-- Design Name: 
-- Module Name: Prescaler - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Prescaler is
    generic ( N_BITS : integer;
              VAL_DIV : integer );
             
       Port ( rst     : in STD_LOGIC;
              clk_in  : in STD_LOGIC; -- reloj de entrada
              clk_out : out STD_LOGIC); -- reloj escalado
end Prescaler;

architecture Behavioral of Prescaler is

    signal cuenta_actual       : unsigned ((N_BITS - 1) downto 0) := (others => '0'); -- señal que lleva la cuenta
    signal fin_cuenta, clk_div : std_logic := '1';
    signal test_1   : std_logic_vector ((N_BITS - 1) downto 0); -- para simular
    constant val_fc : integer := VAL_DIV / 2; -- valor de fin de cueta
    
begin
    P_conta: process (clk_in, rst)
    begin
        if rst = '0' then
            cuenta_actual <= (others => '0');
        elsif rising_edge(clk_in) then
           if fin_cuenta = '1' then
                cuenta_actual <= (others => '0'); -- others cambia todos los elementos de cuenta_actual a 0
                clk_div <= not clk_div; -- toggle en final de cuenta
            else 
                cuenta_actual <= cuenta_actual + 1; -- aumenta la cuenta en 1
           end if;
        end if;
    end process;
    
    fin_cuenta <= '1' when cuenta_actual = (val_fc - 1) else '0'; 
    
    test_1  <= std_logic_vector(cuenta_actual);
    clk_out <= clk_div;
end Behavioral;
