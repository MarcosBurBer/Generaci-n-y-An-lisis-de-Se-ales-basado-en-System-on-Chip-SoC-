----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2025 18:46:42
-- Design Name: 
-- Module Name: FSM - Behavioral
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

entity FSM is
  generic ( SHIFT_ANCHO : integer ); -- ancho del ShiftCounter

     Port ( -- ENTRADAS
            clk   : in STD_LOGIC;  --CAMBIAR POR clkDiv
            START : in STD_LOGIC;
            START2 : in STD_LOGIC;
            rst   : in STD_LOGIC;
            Sft_Counter : in std_logic_vector((SHIFT_ANCHO - 1) downto 0);
           
            -- SALIDAS
            en_Sft   : out STD_LOGIC;
            DONE     : out STD_LOGIC;
            nSYNC    : out STD_LOGIC;
            LoadData : out STD_LOGIC );
end FSM;

architecture Behavioral of FSM is

  type state_type is (IDLE, SIFTOUT, SYNCDATA); --ESTADOS
  signal state, next_state : state_type;
  constant FIN_CUENTA : STD_LOGIC_VECTOR((SHIFT_ANCHO - 1) downto 0) := (others => '1'); -- "1111" termin  la cuenta

begin
 -- Registro de estado 
  proc_state : process(rst, clk)
  begin
    if rst = '0' then
      state <= IDLE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process proc_state;

  -- L GICA DE TRANSICION
  proc_nextstate : process(state, START, START2, Sft_Counter)
  begin
    -- por defecto
    next_state <= state;

    case state is
      when IDLE =>
        if START = '1' or START2 = '1' then
          next_state <= SIFTOUT;
        else
          next_state <= IDLE;
        end if;

      when SIFTOUT =>
        if Sft_Counter = FIN_CUENTA then  ---cuando termino
          next_state <= SYNCDATA;
        else
          next_state <= SIFTOUT;
        end if;

      when SYNCDATA =>  --Volvemos a IDLE
        if START = '0' then
         next_state <= IDLE;
         end if;

      when others =>
        next_state <= IDLE;
    end case;
  end process proc_nextstate;

  -- SALIDAS TIPO MOORE
  proc_salidas : process(state)
  begin
    -- por defecto
--    en_Sft   <= '0';
--    DONE     <= '0';
--    nSYNC    <= '1';
--    LoadData <= '1';

    case state is
      when IDLE =>
        en_Sft   <= '0';
        DONE     <= '1';
        nSYNC    <= '1';
        LoadData <= '1';

      when SIFTOUT =>
        en_Sft   <= '1';
        DONE     <= '0';
        nSYNC    <= '0';  -- activo bajo? 
        LoadData <= '0';

      when SYNCDATA =>
        en_Sft   <= '0';
        DONE     <= '0';
        nSYNC    <= '1';
        LoadData <= '0';

      when others =>
        en_Sft   <= '0';
        DONE     <= '0';
        nSYNC    <= '1';
        LoadData <= '1';
    end case;
  end process proc_salidas;

end Behavioral;
