----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 15:30:46
-- Design Name: 
-- Module Name: SiftRegister - Behavioral
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

entity SiftRegister is
    generic(
        N : integer := 12  -- Tamaño del dato (ajustable según el DAC)
    );
    port(
        clkDiv       : in  std_logic;
    --    nRST         : in  std_logic;
        LoadData     : in  std_logic;
        enShift      : in  std_logic;
        DATA1        : in  std_logic_vector(N-1 downto 0);
        D1           : out std_logic;
        ShiftCounter : out std_logic_vector(3 downto 0)  -- suficiente para 16 bits
    );
end entity SiftRegister;

architecture Behavioral of SiftRegister is
    signal shift_reg     : std_logic_vector(N-1 downto 0) := (others => '0');
    signal counter       : unsigned(3 downto 0) := (others => '0');
begin

    process(clkDiv)-- nRST)
    begin
       -- if nRST = '0' then
        --    shift_reg <= (others => '0');
         --   counter   <= (others => '0');
        if rising_edge(clkDiv) then
            if LoadData = '1' then
                -- Carga paralela del dato
                shift_reg <= DATA1;
                counter   <= (others => '0');
            elsif enShift = '1' then
                -- Desplazamiento hacia la derecha
                shift_reg <= shift_reg(N-2 downto 0) & '0';
                counter   <= counter + 1;
            end if;
        end if;
    end process;

    -- Salida del bit más significativo
    D1 <= shift_reg(N-1);
    -- Salida del contador
    ShiftCounter <= std_logic_vector(counter);

end architecture Behavioral;

