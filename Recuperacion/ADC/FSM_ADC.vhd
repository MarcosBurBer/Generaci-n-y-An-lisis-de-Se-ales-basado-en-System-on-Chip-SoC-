library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_ADC is
  Port (   clk_100 : in STD_LOGIC;
           rst : in STD_LOGIC;
           START : in STD_LOGIC; 
           cntData : in STD_LOGIC_VECTOR (3 downto 0);
           DRDY: out STD_LOGIC;
           CS : out STD_LOGIC;
           en_cnt : out STD_LOGIC);
end FSM_ADC;

architecture Behavioral of FSM_ADC is
    type estados is (HOLD, FPORCH, SHIFTING, BPORCH);
    signal e_act, e_sig : estados;
    signal counter_data : std_logic_vector(3 downto 0);
    signal counter : unsigned(1 downto 0) := "00";
    signal estado : std_logic_vector(1 downto 0);
    signal en_counter : std_logic;
    signal counter_sync : unsigned(2 downto 0);
begin
   counter_data <= cntData;
   
  P_S_FSM: process (clk_100, rst)
    begin
       if rst = '0' then
            e_act <= HOLD;
        elsif rising_edge(clk_100) then
            e_act<= e_sig;
        end if;
    end process;
    
    process(e_act, START, counter_data, counter, counter_sync)
    begin
     
        CS     <= '0';
        DRDY   <= '1';
        en_cnt <= '0';
        e_sig  <= e_act;

        case e_act is
            when HOLD =>
                CS     <= '1';
                DRDY   <= '0';
                en_cnt <= '0';
                estado <= "00";
                if START = '1' then
                   e_sig <= FPORCH;
                end if;

            when FPORCH =>
                CS     <= '0';
                DRDY   <= '0';
                en_cnt <= '0';
                estado <= "01";
                if counter = "11" then
                    e_sig <= SHIFTING;
                end if;

            when SHIFTING =>
                CS     <= '0';
                DRDY   <= '0';
                en_cnt <= '1';
                estado <= "10";
                if counter_data = "1111" and counter_sync = "100" then
                    e_sig <= BPORCH;
                end if;
              
              when BPORCH =>
                CS     <= '0';
                DRDY   <= '1';
                en_cnt <= '1';
                estado <= "11";
                    if counter_sync = "110" then
                        en_cnt <= '0';
                    end if;
                    if counter = "01" then
                        e_sig <= HOLD;
                    end if;

            when others =>
               e_sig <= HOLD;
        end case;
       end process;
       
    Contadores: process(clk_100, rst)
    begin
    if rst = '0' then
        counter <= "00";
        counter_sync <= "000"; -- Reset
    elsif rising_edge(clk_100) then
        case e_act is
            when FPORCH =>
                counter <= counter + 1;
                counter_sync<="000";
            when SHIFTING =>
                if counter_data = "1111" then
                    counter_sync <=counter_sync+1;
                end if;
            when BPORCH =>
                counter <= counter + 1;
                counter_sync <= counter_sync+1;
            when others =>
                counter_sync <= "000";
                counter <= "00";
        end case;
    end if;
    end process;

end Behavioral;
