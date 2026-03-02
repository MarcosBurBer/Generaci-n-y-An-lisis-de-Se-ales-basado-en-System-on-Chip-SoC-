library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Prescaler is
    generic ( 
        N_BITS  : integer := 4;  -- Bits necesarios para representar VAL_DIV
        DIV : integer := 10  -- Factor de división (Reloj_In / Reloj_Out)
    );
    Port ( 
        nrst     : in  STD_LOGIC;
        clk_in  : in  STD_LOGIC; -- Reloj de entrada (ej. 200 MHz)
        clk_out : out STD_LOGIC  -- Reloj escalado
    );
end Prescaler;

architecture Behavioral of Prescaler is
    -- El contador llega hasta (VAL_DIV/2 - 1) para generar un ciclo de trabajo del 50%
    signal s_counter : unsigned(N_BITS-1 downto 0) := (others => '0');
    signal s_clk_reg : STD_LOGIC := '0';
begin

    process(clk_in, nrst)
    begin
        if nrst = '0' then
            s_counter <= (others => '0');
            s_clk_reg <= '0';
        elsif rising_edge(clk_in) then
            -- Si el divisor es 1, la salida es igual a la entrada (evita división por cero)
            if DIV <= 1 then
                s_clk_reg <= clk_in;
            else
                -- Comparamos con la mitad del valor para alternar el estado del reloj
                if s_counter >= (DIV/2 - 1) then
                    s_clk_reg <= not s_clk_reg;
                    s_counter <= (others => '0');
                else
                    s_counter <= s_counter + 1;
                end if;
            end if;
        end if;
    end process;

    clk_out <= s_clk_reg;

end Behavioral;


