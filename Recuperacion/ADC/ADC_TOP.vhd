library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_TOP is
    port( 
          i_D1     : in STD_LOGIC; -- dato serial
          start, nrst, i_clk     : in STD_LOGIC;
         
          o_D1  : out STD_LOGIC_VECTOR (11 downto 0); -- bus 12 bits
          drdy, cs, o_clk     : out STD_LOGIC);
end ADC_TOP;

architecture Behavioral of ADC_TOP is
    
component FSM_ADC is
  Port (
        clk_100   : in  STD_LOGIC;
        nrst       : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        cntData   : in  STD_LOGIC_VECTOR (3 downto 0);

        DRDY      : out STD_LOGIC;
        CS        : out STD_LOGIC;
        enable    : out STD_LOGIC
       );
end component FSM_ADC;

component ShiftReg_ADC is           
       Port ( 
              clk    : in STD_LOGIC; -- señal de reloj (20 MHz)
              in_D1  : in STD_LOGIC; -- entrada dato 
              enable : in STD_LOGIC; -- habilita el reloj
               
              
              out_D1      : out STD_LOGIC_VECTOR (11 downto 0); -- salida dato 1 
              Shift_Cnt : out STD_LOGIC_VECTOR (3 downto 0)); -- contador de cambio
end component ShiftReg_ADC;

component Prescaler is
    generic ( N_BITS: integer;
              DIV : integer );
             
       Port ( nrst     : in STD_LOGIC;
              clk_in  : in STD_LOGIC; -- reloj de entrada
              clk_out : out STD_LOGIC); -- reloj escalado
end component Prescaler;

    signal s_clk_20, s_clk_100, s_en: STD_LOGIC;
    signal s_cnt : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    PSC_20MHz: Prescaler 
        generic map ( N_BITS => 3,
                      DIV => 10) -- (200 MHz)/10 = 20 MHz
           port map ( nrst => nrst,
                      clk_in => i_clk,
                      clk_out => s_clk_20);
                      
    PSC_100MHz: Prescaler 
        generic map ( N_BITS => 2,
                      DIV => 2) -- (200 MHz)/2 = 100 MHz
           port map ( nrst => nrst,
                      clk_in => i_clk,
                      clk_out => s_clk_100);
                                          
    ShiftRegister: ShiftReg_ADC port map ( clk => s_clk_20,    
                                  in_D1 => i_D1, 
                                  enable => s_en,     
                                  out_D1 => o_D1,
                                  Shift_Cnt => s_cnt);
                                
   FSM: FSM_ADC port map ( clk_100 => s_clk_100,    
                                  nrst => nrst,   
                                  start => start, 
                                  cntData => s_cnt,    
                                  DRDY => drdy,     
                                  CS => cs,       
                                  enable => s_en);    
   

    o_clk <= s_clk_20; -- 20 MHz al ADC

end Behavioral;
