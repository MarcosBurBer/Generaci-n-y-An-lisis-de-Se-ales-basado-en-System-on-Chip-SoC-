----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2025 18:30:53
-- Design Name: 
-- Module Name: Shift_Register_tb - Behavioral
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

entity Shift_Register_tb is
--  Port ( );
end Shift_Register_tb;

architecture Behavioral of Shift_Register_tb is

component Shift_Register is
    Generic ( SHIFT_ANCHO : integer; -- nº de bits para el nº de shifts
              N_Bits_D    : integer; -- nº de bits para el dato a convertir
              N_BITS_SPI  : integer ); -- nº de bits para SPI
              
       Port ( -- ENTRADAS
              clk    : in STD_LOGIC; -- señal de reloj (25 MHz)
              in_D1  : in STD_LOGIC_VECTOR ((N_Bits_D - 1) downto 0); -- entrada dato 1
              in_D2  : in STD_LOGIC_VECTOR ((N_Bits_D - 1) downto 0); -- entrada dato 2
              LoadData : in STD_LOGIC; -- registro de carga
              en_Sft : in STD_LOGIC; -- registro de cambio
               
              -- SALIDAS
              out_D1      : out STD_LOGIC; -- salida dato 1
              out_D2      : out STD_LOGIC; -- salida dato 2
              Sft_Counter : out STD_LOGIC_VECTOR ((SHIFT_ANCHO - 1) downto 0)); -- contador de cambio
end component;
    
    -- DECLARACIÓN DE ESTÍMULOS
    signal clk, LoadData, en_Sft, out_D1, out_D2 : STD_LOGIC;
    signal in_D1, in_D2 : STD_LOGIC_VECTOR (11 downto 0);
    signal Sft_Counter  : STD_LOGIC_VECTOR (3 downto 0);
    
    constant SHIFT_ANCHO : integer := 4;
    constant N_Bits_D : integer := 12;
    constant N_BITS_SPI : integer := 16;

begin
    UUT: Shift_Register 
            generic map ( SHIFT_ANCHO => SHIFT_ANCHO,
                          N_Bits_D    => N_Bits_D,
                          N_BITS_SPI  => N_BITS_SPI )
                          
               port map ( clk => clk, 
                          in_D1  => in_D1,
                          in_D2  => in_D2,
                          LoadData => LoadData,
                          en_Sft => en_Sft,
                          out_D1 => out_D1,
                          out_D2 => out_D2,
                          Sft_Counter => Sft_Counter );
                                 
    CLK_gen: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    in_D1 <= "111111110000"; -- "1111 1111 0000"
    in_D2 <= "000000001111"; -- "0000 0000 1111"
    LoadData <= '0', '1' after 13 ns, '0' after 25 ns, '1' after 200 ns, '0' after 220 ns; 
    en_Sft <= '0', '1' after 40 ns, '0' after 200 ns, '1' after 230 ns;
    
end Behavioral;
