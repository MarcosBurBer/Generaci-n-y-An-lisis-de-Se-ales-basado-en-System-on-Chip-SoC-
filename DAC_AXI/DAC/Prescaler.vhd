----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 15:30:46
-- Design Name: 
-- Module Name: Prescaler - Behavioral
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

entity Prescaler is
    Port ( CLK50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           clkDIV : out STD_LOGIC);
end Prescaler;

architecture Structural of Prescaler is
  

    -- Declaración del componente de contador genérico
    component ContadorGenerico is
        generic (
            N_BITS : integer := 4;  -- Número de bits del contador
            MAX_VALOR : integer := 10  -- Valor máximo del contador
        );
        port (
            clk        : in  std_logic;                           -- Reloj
            rst      : in  std_logic;                           -- Reset
          --  enable     : in  std_logic;
            cuenta     : out std_logic_vector(N_BITS-1 downto 0); -- Salida de cuenta
            f_cuenta   : out std_logic                            -- Señal de "done"
        );
    end component;

begin

    -- Contador para frecuencia de 0,5s
    DIVFREQ : ContadorGenerico
        generic map (
            N_BITS => 10,
            MAX_VALOR => 1000  -- DIV 100MHz/1000 = 100KHz
        )
        port map (
            clk => CLK50,
            rst => nRST,
           -- enable => enable,             
            f_cuenta => CLKDIV
        );

    
    
end Structural;
