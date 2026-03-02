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
    generic ( 
        N_BITS  : integer := 4;  -- Bits necesarios para representar VAL_DIV
        VAL_DIV : integer := 10  -- Factor de división (Reloj_In / Reloj_Out)
    );
    Port ( 
        rst     : in  STD_LOGIC;
        clk_in  : in  STD_LOGIC; -- Reloj de entrada (ej. 200 MHz)
        clk_out : out STD_LOGIC  -- Reloj escalado
    );
end Prescaler;

architecture Behavioral of Prescaler is
    -- El contador llega hasta (VAL_DIV/2 - 1) para generar un ciclo de trabajo del 50%
    signal counter : unsigned(N_BITS-1 downto 0) := (others => '0');
    signal clk_reg : STD_LOGIC := '0';
begin

    process(clk_in, rst)
    begin
        if rst = '0' then
            counter <= (others => '0');
            clk_reg <= '0';
        elsif rising_edge(clk_in) then
            -- Si el divisor es 1, la salida es igual a la entrada (evita división por cero)
            if VAL_DIV <= 1 then
                clk_reg <= clk_in;
            else
                -- Comparamos con la mitad del valor para alternar el estado del reloj
                if counter >= (VAL_DIV/2 - 1) then
                    clk_reg <= not clk_reg;
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    clk_out <= clk_reg;

end Behavioral;
