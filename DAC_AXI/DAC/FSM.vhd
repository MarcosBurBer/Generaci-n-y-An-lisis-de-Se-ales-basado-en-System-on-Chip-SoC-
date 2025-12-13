----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 15:30:46
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
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port (
        START        : in  STD_LOGIC;
        clkDiv       : in  STD_LOGIC;
        nRST         : in  STD_LOGIC;
        ShiftCounter : in  std_logic_vector(3 downto 0);
        DONE         : out STD_LOGIC;
        LoadData     : out STD_LOGIC;
        enShift       : out STD_LOGIC;
        nSYNC        : out STD_LOGIC
    );
end FSM;

architecture Behavioral of FSM is
    type estados is (SyncData, SiftOUT, IDLE);
    signal e_act, e_sig : estados;
begin

    -- Máquina de estado secuencial
    process(clkDiv, nRST)
    begin
        if nRST = '0' then
            e_act <= IDLE;
        elsif rising_edge(clkDiv) then
            e_act <= e_sig;
        end if;
    end process;

    -- Lógica de transición
    process(e_act, START, ShiftCounter)
    begin
        e_sig <= e_act;
        case e_act is
            when SyncData =>
                if START = '0' then
                    e_sig <= IDLE;
                end if;
            when SiftOUT =>
                if ShiftCounter = "1111" then
                    e_sig <= SyncData;
                end if;
            when IDLE =>
                if START = '1' then
                    e_sig <= SiftOUT;
                end if;
            when others =>
                e_sig <= SyncData;             
        end case;
    end process;

    -- Lógica de salida
    process(e_act)
    begin
        case e_act is
            when SyncData =>
                enShift   <= '0';
                DONE     <= '0';
                nSYNC    <= '1';
                LoadData <= '0';
            when SiftOUT =>
                enShift   <= '1';
                DONE     <= '0';
                nSYNC    <= '0';
                LoadData <= '0';
            when IDLE =>
                enShift   <= '0';
                DONE     <= '1';
                nSYNC    <= '1';
                LoadData <= '1';
            when others =>
                enShift   <= '0';
                DONE     <= '0';
                nSYNC    <= '1';
                LoadData <= '0';
        end case;
    end process;

end Behavioral;
