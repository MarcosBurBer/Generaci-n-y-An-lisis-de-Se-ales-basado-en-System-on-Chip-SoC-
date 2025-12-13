library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sync_vga is
 port (
        clk_25 : in std_logic;
        rst : in std_logic;
        fils : out std_logic_vector(9 downto 0);
        cols : out std_logic_vector(9 downto 0);
        Visible : out std_logic;
        Hsync: out std_logic;
        Vsync: out std_logic
 );
 
end sync_vga;

architecture Behavioral of sync_vga is

--signal
signal s_Fc_Cols : std_logic;
signal s_Fc_fils : std_logic;
signal s_ConteoCols: std_logic_vector(9 downto 0);
signal s_Conteofils: std_logic_vector(9 downto 0);

 --component
                                    
component ContadorUp_Down is
     generic(
        N_BITS : integer := 10; 
        MAX_VALOR : integer := 10 
 );
     port (
        en : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        Up_Conta: in std_logic;
        cuenta : out std_logic_vector(N_BITS-1 downto 0);
        f_cuenta : out std_logic 
 );
             
  end component; 

begin

       --instantacion
       ContCols : ContadorUp_Down  
       generic map (
          N_BITS =>  10, 
          MAX_VALOR => 800
        )
                          
        port map (               
          en    => '1',   
          clk    => clk_25,   
          rst  =>  rst,
          Up_Conta=>'1', 
          cuenta  =>  s_conteocols,
          f_cuenta     =>  s_fc_cols    
        );   
        
        Contfils : ContadorUp_Down                     
       generic map (
          N_BITS =>  10,  --podria quitarlo
          MAX_VALOR => 525 --- quizas necesito 524
        )
                                       
        port map (               
          en    => s_fc_cols,   
          clk    => clk_25,   
          rst  =>  rst,
          Up_Conta=>'1', 
          cuenta =>  s_conteofils,
          f_cuenta =>  s_fc_fils    
        );   

    cols<= s_conteocols;
    fils<=s_conteofils;

    hsync <= '1' when (to_integer(unsigned(s_conteocols)) < (640 + 16)) or 
                (to_integer(unsigned(s_conteocols)) > (640 + 16 + 96 - 1)) else '0';
                
    Vsync <= '1' when (to_integer(unsigned(s_conteofils)) < (480+10)) or 
                (to_integer(unsigned(s_conteofils)) > (480 + 10 + 2 - 1)) else '0';
                
    visible <= '1' when (to_integer(unsigned(s_conteocols)) < (640)) and 
                (to_integer(unsigned(s_conteofils)) < (480)) else '0';
    
   
end Behavioral;