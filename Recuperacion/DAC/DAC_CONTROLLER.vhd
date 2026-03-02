----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2025 10:08:49
-- Design Name: 
-- Module Name: DAC_CONTROLLER - Behavioral
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

entity DAC_CONTROLLER is
  port ( -- ENTRADAS
         START   : in STD_LOGIC;
         START2  : in STD_LOGIC;
         in_D1  : in STD_LOGIC_VECTOR ( 11 downto 0 );
         rst    : in STD_LOGIC;
         clk_in : in STD_LOGIC;
        
         -- SALIDAS
         DONE    : out STD_LOGIC;
         clk_out : out STD_LOGIC;
         nSYNC   : out STD_LOGIC;
         out_D1  : out STD_LOGIC);
end DAC_CONTROLLER;

architecture Behavioral of DAC_CONTROLLER is

component Prescaler is
    generic ( N_BITS : integer;
              VAL_DIV : integer );
             
       Port ( rst     : in STD_LOGIC;
              clk_in  : in STD_LOGIC; -- reloj de entrada
              clk_out : out STD_LOGIC); -- reloj escalado
end component;

component Shift_Register is
    Generic ( SHIFT_ANCHO : integer; -- n  de bits para el n  de shifts
              N_Bits_D    : integer; -- n  de bits para el dato a convertir
              N_BITS_SPI  : integer ); -- n  de bits para SPI
              
       Port ( -- ENTRADAS
              clk    : in STD_LOGIC; -- se al de reloj (25 MHz)
              in_D1  : in STD_LOGIC_VECTOR ((N_Bits_D - 1) downto 0); -- entrada dato 1
              LoadData : in STD_LOGIC; -- registro de carga
              en_Sft : in STD_LOGIC; -- registro de cambio
               
              -- SALIDAS
              out_D1      : out STD_LOGIC; -- salida dato 1
              Sft_Counter : out STD_LOGIC_VECTOR ((SHIFT_ANCHO - 1) downto 0)); -- contador de cambio
end component;

component FSM is
  generic ( SHIFT_ANCHO : integer ); -- ancho del ShiftCounter

     Port ( -- ENTRADAS
            clk    : in STD_LOGIC;  --CAMBIAR POR clkDiv
            START  : in STD_LOGIC;
            START2 : in STD_LOGIC;
            rst   : in STD_LOGIC;
            Sft_Counter : in std_logic_vector((SHIFT_ANCHO - 1) downto 0);
           
            -- SALIDAS
            en_Sft   : out STD_LOGIC;
            DONE     : out STD_LOGIC;
            nSYNC    : out STD_LOGIC;
            LoadData : out STD_LOGIC );
end component;
    
    constant SHIFT_ANCHO : integer := 4;
    constant N_Bits_D : integer := 12;
    constant N_BITS_SPI : integer := 16;
    
--    signal LoadData : STD_LOGIC;
--    signal Sft_Counter : STD_LOGIC;
--    signal en_Sft : STD_LOGIC;
    
    signal Sft_Counter_CONECTION : STD_LOGIC_VECTOR ((SHIFT_ANCHO - 1) downto 0);
    signal en_Sft_CONECTION : STD_LOGIC;
    signal LoadData_CONECTION : STD_LOGIC;
    signal clk_25 : STD_LOGIC;
    
begin
    PS: Prescaler 
        generic map ( N_BITS => 4,
                      VAL_DIV => 8) -- (200 MHz)/8 = 25 MHz
           port map ( rst => rst,
                      clk_in => clk_in,
                      clk_out => clk_25);
                       
    Maq_estados: FSM
        generic map ( SHIFT_ANCHO => SHIFT_ANCHO)
           port map ( clk => clk_25,
                      START => START,
                      START2 => START2,
                      rst => rst,
                      Sft_Counter => Sft_Counter_CONECTION,
                      en_Sft => en_Sft_CONECTION,
                      DONE => DONE,
                      nSYNC => nSYNC,
                      LoadData => LoadData_CONECTION);
                      
    reg_Despl : Shift_Register
        generic map ( SHIFT_ANCHO => SHIFT_ANCHO,
                      N_Bits_D => N_Bits_D,
                      N_BITS_SPI => N_BITS_SPI)
           port map ( clk => clk_25,
                      in_D1 => in_D1,
                      LoadData => LoadData_CONECTION,
                      en_Sft => en_Sft_CONECTION,
                      out_D1 => out_D1,
                      Sft_Counter => Sft_Counter_CONECTION);
                      
    clk_out <= clk_25;
             

end Behavioral;
