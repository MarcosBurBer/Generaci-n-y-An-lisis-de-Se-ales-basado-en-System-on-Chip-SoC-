----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 15:36:53
-- Design Name: 
-- Module Name: DAC_Controller - Behavioral
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

entity DAC_Controller is
    Port ( DATA1 : in std_logic_vector(12-1 downto 0);
           START : in STD_LOGIC;
           DONE : out STD_LOGIC;
           nRST : in STD_LOGIC;
           CLK50 : in STD_LOGIC;
           D1 : out STD_LOGIC;
           nSYNC : out STD_LOGIC;
           CLK_OUT : out STD_LOGIC);
end DAC_Controller;

architecture Behavioral of DAC_Controller is
    signal CLK, RST, clkDIV, OK, GO, enSift, LoadData, D, SYNC, REG_0 : std_logic;
    signal ShiftCounter : std_logic_vector(3 downto 0); 
    signal DATA: std_logic_vector(12-1 downto 0);
    
  component Prescaler
      Port (
          CLK50   : in  STD_LOGIC;
          nRST   : in  STD_LOGIC;
          clkDIV   : out STD_LOGIC
      );
      end component;
  
  component FSM
      Port (
          START   : in  STD_LOGIC;
          ShiftCounter   : in  std_logic_vector(3 downto 0); 
          nRST : in STD_LOGIC;
          clkDIV : in STD_LOGIC;
          DONE   : out STD_LOGIC;
          LoadData   : out STD_LOGIC;
          enShift   : out STD_LOGIC;
          nSYNC   : out STD_LOGIC
      );
      end component;
          
  component SiftRegister
      Port (
             DATA1 : in  std_logic_vector(12-1 downto 0);
             LoadData : in STD_LOGIC;
             enShift : in STD_LOGIC;
             clkDiv : in STD_LOGIC;
             ShiftCounter : out std_logic_vector(3 downto 0);
             D1 : out STD_LOGIC);
      end component;
         
  
begin

  --Prescaler
    U1: Prescaler
    port map(
         CLK50   => CLK,
         nRST    => RST,--nRST    => '1',
         clkDiv  => clkDIV
         );
         
         --FSM
    U2: FSM
    port map(
         START   => GO,
         ShiftCounter => ShiftCounter,
         nRST  => RST,
         clkDiv  => clkDIV,
         LoadData => LoadData,
         enShift => enSift,
         DONE    => OK,
         nSYNC => SYNC
         );
         
    U3: SiftRegister
     port map (
             DATA1 => DATA,
             LoadData => LoadData,
             enShift => enSift,
             clkDiv => clkDIV, 
             ShiftCounter => ShiftCounter,
             D1 => D
             );
     
      
    --Entradas
    CLK <= CLK50;  -- Reloj
    RST <= nRST;   -- Reset
    GO <= START;   -- Inicio AddrCtrl
    DATA <= DATA1;
    
    --Salidas
    DONE <= OK;
    CLK_OUT <= ClkDiv;
    D1 <= D;  
    nSYNC <= SYNC;
           
end Behavioral;

