----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2025 17:05:52
-- Design Name: 
-- Module Name: AXI4Lite_DAC_Controller - Behavioral
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

entity AXI4Lite_DAC_Controller is
  Port (               
           nRST : in STD_LOGIC;
           CLK50 : in STD_LOGIC;
           REG0 : in STD_LOGIC; 
           REG1 : in std_logic_vector(12-1 downto 0);
           REG2 : in std_logic_vector(14-1 downto 0);      
           REG3 : in STD_LOGIC;     
           D1 : out STD_LOGIC;
           nSYNC : out STD_LOGIC;
           CLK_OUT : out STD_LOGIC
  );
end AXI4Lite_DAC_Controller;

architecture Behavioral of AXI4Lite_DAC_Controller is

    signal CLK, RST, clkDIV, OK, GO, enSift, LoadData, D, SYNC, REG_0, REG_3, Start_REG : std_logic;
    signal ShiftCounter : std_logic_vector(3 downto 0); 
    signal DATA, REG_1: std_logic_vector(12-1 downto 0);
    signal Addrrd, REG_2: std_logic_vector(14-1 downto 0);

      component DAC_Controller
      Port (
          DATA1 : in std_logic_vector(12-1 downto 0);
           START : in STD_LOGIC;
           DONE : out STD_LOGIC;
           nRST : in STD_LOGIC;
           CLK50 : in STD_LOGIC;
           D1 : out STD_LOGIC;
           nSYNC : out STD_LOGIC;
           CLK_OUT : out STD_LOGIC
      );
      end component;
      
      component RAM
      GENERIC(
        d_width    : INTEGER := 12;  -- ancho de palabra de datos (12 bits)
        addr_width : INTEGER := 14   -- 2^14 = 16384 posiciones de memoria
        );
      Port (
            clk50     : IN  STD_LOGIC;  -- reloj del sistema
            wr_en     : IN  STD_LOGIC;  -- habilitación de escritura
            addr_rd   : IN  STD_LOGIC_VECTOR(addr_width-1 DOWNTO 0); -- dirección de lectura
            addr_wr   : IN  STD_LOGIC_VECTOR(addr_width-1 DOWNTO 0); -- dirección de escritura
            data_in   : IN  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);    -- datos de entrada
            data_out  : OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)     -- datos de salida
            );     
      end component; 
      
      component AddrCtrl
      Port (
           clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           DONE : in STD_LOGIC;
           addr_rd : out std_logic_vector(14-1 downto 0);
           START : out STD_LOGIC
      );
      end component;
begin
    Start_REG <= REG_3 or GO ;
    
    U1: DAC_Controller
     port map(      
            DATA1 => DATA,
             START => START_REG,
             DONE => OK,
             nRST => RST,
             CLK50 => CLK,
             D1 => D,
             nSYNC => SYNC,
             CLK_OUT => clkDIV
              );
     U2: RAM  
     port map(      
            clk50   => CLK,
            wr_en   => REG_0,
            addr_rd => addrrd,
            addr_wr => REG_2,
            data_in => REG_1,
            data_out=> DATA
            );
    
    U3: AddrCtrl
     port map(      
             clk50 => CLK,
             nRST  => RST,
             DONE  => OK,
             addr_rd => addrrd,
             START => GO 
            );
            
    --Entradas
    CLK <= CLK50;  -- Reloj
    RST <= nRST;   -- Reset
    REG_0 <= REG0;
    REG_1 <= REG1;
    REG_2 <= REG2;
    REG_3 <= REG3;
    
    --Salidas
    CLK_OUT <= ClkDiv;
    D1 <= D;  
    nSYNC <= SYNC;
    
end Behavioral;
