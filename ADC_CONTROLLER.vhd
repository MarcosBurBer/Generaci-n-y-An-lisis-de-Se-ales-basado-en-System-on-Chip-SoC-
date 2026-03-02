----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2025 20:58:40
-- Design Name: 
-- Module Name: ADC_CONTROLLER - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC_CONTROLLER is
    port( -- ENTRADAS
          D1_in     : in STD_LOGIC;
          START     : in STD_LOGIC;
          rst       : in STD_LOGIC := '1';
          clk_in    : in STD_LOGIC;
          
          -- SALIDAS
          DRDY    : out STD_LOGIC;
          D1_out  : out STD_LOGIC_VECTOR (11 downto 0); 
          clk_out : out STD_LOGIC;
          CS      : out STD_LOGIC);
end ADC_CONTROLLER;

architecture Behavioral of ADC_CONTROLLER is
    
component Prescaler is
    generic ( N_BITS: integer;
              VAL_DIV : integer );
             
       Port ( rst     : in STD_LOGIC;
              clk_in  : in STD_LOGIC; -- reloj de entrada
              clk_out : out STD_LOGIC); -- reloj escalado
end component Prescaler;

component SR_ADC is           
       Port ( -- ENTRADAS
              clk    : in STD_LOGIC; -- señal de reloj (20 MHz)
              in_D1  : in STD_LOGIC; -- entrada dato 1 serie
              en_cnt : in STD_LOGIC; -- habilita el reloj
               
              -- SALIDAS
              out_D1      : out STD_LOGIC_VECTOR (11 downto 0); -- salida dato 1 en bus
              Sft_Counter : out STD_LOGIC_VECTOR (3 downto 0)); -- contador de cambio
end component SR_ADC;

component FSM_ADC is
  Port (
        clk_100   : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        START     : in  STD_LOGIC;
        cntData   : in  STD_LOGIC_VECTOR (3 downto 0);

        DRDY      : out STD_LOGIC;
        CS        : out STD_LOGIC;
        en_cnt    : out STD_LOGIC
       );
end component FSM_ADC;

    signal clk_20, clk_100, en_CONECT : STD_LOGIC;
    signal cnt_CONECT : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    PSC_20MHz: Prescaler 
        generic map ( N_BITS => 3,
                      VAL_DIV => 10) -- (200 MHz)/10 = 20 MHz
           port map ( rst => rst,
                      clk_in => clk_in,
                      clk_out => clk_20);
                      
    PSC_100MHz: Prescaler 
        generic map ( N_BITS => 2,
                      VAL_DIV => 2) -- (200 MHz)/2 = 100 MHz
           port map ( rst => rst,
                      clk_in => clk_in,
                      clk_out => clk_100);
                                          
    ShiftR_ADC: SR_ADC port map ( clk => clk_20,    
                                  in_D1 => D1_in, 
                                  en_cnt => en_CONECT,     
                                  out_D1 => D1_out,
                                  Sft_Counter => cnt_CONECT);
                                
   FSMach_ADC: FSM_ADC port map ( clk_100 => clk_100,    
                                  rst => rst,   
                                  START => START, 
                                  cntData => cnt_CONECT,    
                                  DRDY => DRDY,     
                                  CS => CS,       
                                  en_cnt => en_CONECT);    

    clk_out <= clk_20; -- salida de 20 MHz para el ADC
    
end Behavioral;
