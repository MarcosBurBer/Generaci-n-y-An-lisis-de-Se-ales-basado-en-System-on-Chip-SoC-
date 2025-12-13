----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 18:39:27
-- Design Name: 
-- Module Name: RAM - Behavioral
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


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY RAM IS
    GENERIC(
        d_width    : INTEGER := 12;  -- ancho de palabra de datos (12 bits)
        addr_width : INTEGER := 14   -- 2^14 = 16384 posiciones de memoria
    );
    PORT(
        clk50     : IN  STD_LOGIC;  -- reloj del sistema
        wr_en     : IN  STD_LOGIC;  -- habilitación de escritura
        addr_rd   : IN  STD_LOGIC_VECTOR(addr_width-1 DOWNTO 0); -- dirección de lectura
        addr_wr   : IN  STD_LOGIC_VECTOR(addr_width-1 DOWNTO 0); -- dirección de escritura
        data_in   : IN  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);    -- datos de entrada
        data_out  : OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)     -- datos de salida
    );
END RAM;

ARCHITECTURE logic OF RAM IS
    TYPE memory IS ARRAY((2**addr_width)-1 DOWNTO 0) OF STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
    SIGNAL ram : memory := (OTHERS => (OTHERS => '0'));  -- inicialización a cero
BEGIN
    PROCESS(clk50)
    BEGIN
        IF rising_edge(clk50) THEN
            -- Escritura
            IF (wr_en = '1') THEN
                ram(to_integer(unsigned(addr_wr))) <= data_in;
            END IF;
            -- Lectura síncrona
            data_out <= ram(to_integer(unsigned(addr_rd)));
        END IF;
    END PROCESS;
END logic;
