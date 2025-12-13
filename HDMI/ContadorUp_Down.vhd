library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ContadorUp_Down is
generic(
        N_BITS : integer := 8; 
        MAX_VALOR : integer := 10 
 );
 port (
        en : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        Up_Conta: in std_logic;
        cuenta : out std_logic_vector(N_BITS-1downto 0);
        f_cuenta : out std_logic 
 );
end ContadorUp_Down;

architecture Behavioral of ContadorUp_Down is

signal counter_reg : unsigned(N_BITS-1 downto 0) := (others => '0');
signal ini:std_logic;   

begin
process(clk, rst)
 begin

    if rst = '1' then
        counter_reg <= (others => '0'); -- Reiniciar el contador
    elsif rising_edge(clk) then
      if en='1' then  -- el enable lo meto aqui dentro porque quiero que sea un proceso sincrono, y el reset voy a dejar que funcione siempre
        if ini= '1' then
            if Up_Conta='1' then
            counter_reg <= (others => '0'); -- Reiniciar al alcanzar el valor máximo
            else
            counter_reg <= TO_UNSIGNED(Max_valor-1,counter_reg'length);
            end if;  
        else
            if Up_Conta='1' then
            counter_reg <= counter_reg + 1; -- Incrementar el contador
            else
            counter_reg <= counter_reg - 1;
            end if;
        end if;
   end if;
 end if;
end process;
 
 cuenta <= std_logic_vector(counter_reg); -- Asignar el valor del contador a la salida
 ini <= '1' when (counter_reg = (MAX_VALOR-1) and Up_Conta='1') or (counter_reg=0 and Up_Conta='0')  else '0'; -- Señal de finalización   
 f_cuenta<=ini;

end Behavioral;
