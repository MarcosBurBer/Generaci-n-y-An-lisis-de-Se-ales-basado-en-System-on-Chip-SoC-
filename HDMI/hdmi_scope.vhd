library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Librería para primitivas de Xilinx (Relojes)
library UNISIM;
use UNISIM.VComponents.all;

entity hdmi_scope is
    Port (
        -- SOLO UN RELOJ DE ENTRADA (100 MHz)
        clk_100     : in STD_LOGIC; 
        reset       : in STD_LOGIC; -- Reset Activo Alto
        
        -- Datos ADC
        adc_data    : in STD_LOGIC_VECTOR(11 downto 0);
        adc_valid   : in STD_LOGIC;
        
        -- Salida HDMI
        hdmi_clk_p, hdmi_clk_n : out STD_LOGIC;
        hdmi_d_p,   hdmi_d_n   : out STD_LOGIC_VECTOR(2 downto 0)
    );
end hdmi_scope;

architecture Behavioral of hdmi_scope is

    -- Señales de Reloj Generadas Internamente
    signal clk_pixel   : std_logic; -- 25 MHz
    signal clk_serial  : std_logic; -- 125 MHz
    signal clk_feedback: std_logic; -- Lazo de control
    signal locked      : std_logic; -- Indica reloj estable
    signal sys_rst     : std_logic; -- Reset interno combinado

    -- Señales VGA
    signal x_cnt, y_cnt : std_logic_vector(9 downto 0);
    signal video_active, hsync, vsync : std_logic;
    signal rgb_data : std_logic_vector(23 downto 0);
    
    -- Memoria RAM
    type ram_type is array (0 to 639) of std_logic_vector(11 downto 0);
    shared variable waveform_ram : ram_type := (others => (others => '0'));
    signal write_ptr : integer range 0 to 639 := 0;
    signal read_val  : std_logic_vector(11 downto 0);

    -- Señales TMDS
    signal tmds_r, tmds_g, tmds_b : std_logic_vector(9 downto 0);

begin

    -- ========================================================================
    -- 1. GESTIÓN DE RELOJES (INTERNAL MMCM)
    -- ========================================================================
    -- Convertimos 100 MHz -> 125 MHz (Serial) y 25 MHz (Pixel)
    -- Matemáticas: 
    -- VCO = 100 MHz * 10 = 1000 MHz
    -- Serial = 1000 / 8  = 125 MHz
    -- Pixel  = 1000 / 40 = 25 MHz
    
    inst_mmcm : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",
        CLKFBOUT_MULT_F => 10.0,      -- VCO Multiplier (100*10 = 1000MHz)
        CLKIN1_PERIOD => 10.0,        -- Input period (10ns = 100MHz)
        
        CLKOUT0_DIVIDE_F => 8.0,      -- Divide VCO by 8 = 125 MHz (Serial)
        CLKOUT1_DIVIDE => 40,         -- Divide VCO by 40 = 25 MHz (Pixel)
        DIVCLK_DIVIDE => 1            -- No input division
    )
    port map (
        CLKIN1   => clk_100,
        CLKFBIN  => clk_feedback,     -- Feedback loop
        CLKFBOUT => clk_feedback,     -- Feedback loop
        
        CLKOUT0  => clk_serial,       -- Salida 125 MHz
        CLKOUT1  => clk_pixel,        -- Salida 25 MHz
        
        LOCKED   => locked,
        RST      => reset,            -- Reset del PLL
        PWRDWN   => '0'
    );

    -- El sistema se mantiene en reset hasta que los relojes son estables
    sys_rst <= reset or (not locked);

    -- ========================================================================
    -- 2. ESCRITURA EN MEMORIA (Dominio 100 MHz - Asíncrono al video)
    -- ========================================================================
    process(clk_100)
    begin
        if rising_edge(clk_100) then
            if adc_valid = '1' then
                waveform_ram(write_ptr) := adc_data;
                if write_ptr = 639 then write_ptr <= 0;
                else write_ptr <= write_ptr + 1; end if;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 3. GENERADOR VGA (Dominio 25 MHz Interno)
    -- ========================================================================
    inst_sync_vga: entity work.sync_vga
    port map (
        clk_25   => clk_pixel, -- Usamos el reloj generado internamente
        rst      => sys_rst,   -- Reset seguro
        cols     => x_cnt,
        fils     => y_cnt,
        Visible  => video_active,
        Hsync    => hsync,
        Vsync    => vsync
    );

    -- ========================================================================
    -- 4. DIBUJADO
    -- ========================================================================
    process(clk_pixel)
        variable x_int, y_int, wave_y : integer;
    begin
        if rising_edge(clk_pixel) then
            x_int := to_integer(unsigned(x_cnt));
            y_int := to_integer(unsigned(y_cnt));
            
            if x_int < 640 then read_val <= waveform_ram(x_int);
            else read_val <= (others => '0'); end if;

            if video_active = '1' then
                wave_y := 480 - (to_integer(unsigned(read_val)) / 8); 
                
                if y_int = 240 or x_int = 320 then rgb_data <= x"404040"; -- Retícula
                elsif (y_int >= wave_y - 1) and (y_int <= wave_y + 1) then rgb_data <= x"00FF00"; -- Traza
                else rgb_data <= x"101020"; -- Fondo
                end if;
            else
                rgb_data <= (others => '0');
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 5. SALIDA HDMI (Usando relojes internos)
    -- ========================================================================
    inst_hdmi_tx: entity work.hdmi_rgb2tmds
    generic map ( SERIES6 => FALSE )
    port map (
        rst         => sys_rst,
        pixelclock  => clk_pixel,  -- 25 MHz interno
        serialclock => clk_serial, -- 125 MHz interno
        
        video_data  => rgb_data,
        video_active=> video_active,
        hsync       => hsync, vsync => vsync,
        
        clk_p       => hdmi_clk_p, clk_n => hdmi_clk_n,
        data_p      => hdmi_d_p,   data_n => hdmi_d_n
    );

end Behavioral;