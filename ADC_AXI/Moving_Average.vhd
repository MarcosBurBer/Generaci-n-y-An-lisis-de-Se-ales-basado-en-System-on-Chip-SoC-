----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2025 10:02:48
-- Design Name: 
-- Module Name: Moving_Average - Behavioral
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

entity Moving_Average is
    Generic (
        WINDOW_SIZE_LOG2 : integer := 5; -- 2^5 = 32 muestras
        DATA_WIDTH       : integer := 12
    );
    Port (
        clk         : in STD_LOGIC;
        reset_n     : in STD_LOGIC;
        data_in     : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        data_valid  : in STD_LOGIC;
        data_out    : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end Moving_Average;

architecture Behavioral of Moving_Average is
    
    constant WINDOW_SIZE : integer := 2**WINDOW_SIZE_LOG2;
    
    -- Array para el historial (FIFO)
    type sample_array is array (0 to WINDOW_SIZE-1) of unsigned(DATA_WIDTH-1 downto 0);
    signal window_fifo : sample_array := (others => (others => '0'));
    
    -- Acumulador: 12 bits + 5 bits extra = 17 bits para evitar desbordamiento
    signal accumulator : unsigned(DATA_WIDTH + WINDOW_SIZE_LOG2 - 1 downto 0) := (others => '0');
    
    signal ptr : integer range 0 to WINDOW_SIZE-1 := 0;

begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset Asíncrono
            window_fifo <= (others => (others => '0'));
            accumulator <= (others => '0');
            ptr <= 0;
            -- ¡IMPORTANTE!: NO asignamos data_out aquí para evitar driver conflict
        elsif rising_edge(clk) then
            if data_valid = '1' then
                -- Lógica de Suma Recursiva:
                -- Nuevo Acumulado = Anterior - El que sale + El que entra
                -- Usamos 'resize' para igualar los tamaños de bits (a 17 bits) antes de operar
                accumulator <= accumulator 
                             - resize(window_fifo(ptr), accumulator'length) 
                             + resize(unsigned(data_in), accumulator'length);
                             
                -- Guardar dato nuevo en el FIFO
                window_fifo(ptr) <= unsigned(data_in);
                
                -- Avanzar puntero circular
                if ptr = WINDOW_SIZE-1 then
                    ptr <= 0;
                else
                    ptr <= ptr + 1;
                end if;
            end if;
        end if;
    end process;

    -- Asignación Concurrente (Única fuente de data_out)
    -- Divide por 32 descartando los 5 bits menos significativos
    data_out <= std_logic_vector(accumulator(accumulator'high downto WINDOW_SIZE_LOG2));

end Behavioral;