library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_adc_axi_v1_0_S00_AXI is
    generic (
        C_S_AXI_DATA_WIDTH  : integer   := 32;
        C_S_AXI_ADDR_WIDTH  : integer   := 5 -- Ancho 5 para soportar hasta 32 bytes (8 registros)
    );
    port (
        -- PUERTOS EXTERNOS PARA EL PMOD AD1
        spi_sdata : in  std_logic; -- MISO
        spi_sclk  : out std_logic; -- SCLK
        spi_cs    : out std_logic; -- CS

        -- PUERTOS DE EXPORTACIÓN (PARA HDMI / OSCILOSCOPIO)
        adc_data_export  : out std_logic_vector(11 downto 0);
        adc_valid_export : out std_logic;

        -- PUERTOS AXI ESTÁNDAR
        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN : in std_logic;
        S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in std_logic;
        S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in std_logic
    );
end my_adc_axi_v1_0_S00_AXI;

architecture arch_imp of my_adc_axi_v1_0_S00_AXI is

    -- Señales AXI
    signal axi_awaddr   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awready  : std_logic;
    signal axi_wready   : std_logic;
    signal axi_bresp    : std_logic_vector(1 downto 0);
    signal axi_bvalid   : std_logic;
    signal axi_araddr   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready  : std_logic;
    signal axi_rdata    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp    : std_logic_vector(1 downto 0);
    signal axi_rvalid   : std_logic;

    constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
    constant OPT_MEM_ADDR_BITS : integer := 2; -- 3 bits útiles para direccionar registros

    signal slv_reg0 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal slv_reg1 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal slv_reg2 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal slv_reg3 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal slv_reg4 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); -- Registro Filtro
    
    signal slv_reg_rden : std_logic;
    signal slv_reg_wren : std_logic;
    signal reg_data_out :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal byte_index : integer;
    signal aw_en : std_logic;

    -- --- SEÑALES INTERNAS (HARDWARE) ---
    signal adc_data_internal : std_logic_vector(11 downto 0);
    signal adc_drdy_internal : std_logic;
    
    -- Señales para el DSP
    signal dsp_mav_internal  : std_logic_vector(11 downto 0);
    signal dsp_freq_internal : std_logic_vector(31 downto 0);
    
    -- Señales para el Filtro
    signal adc_filtered_internal : std_logic_vector(11 downto 0);

    -- --- DECLARACIÓN DE COMPONENTES ---

    component ADC_Controller
        Generic (
            SYS_CLK_FREQ : integer := 100_000_000;
            SCLK_FREQ    : integer := 10_000_000
        );
        Port (
            clk      : in  STD_LOGIC;
            reset_n  : in  STD_LOGIC;
            start    : in  STD_LOGIC;
            sdata    : in  STD_LOGIC;
            sclk     : out STD_LOGIC;
            cs       : out STD_LOGIC;
            data_out : out STD_LOGIC_VECTOR (11 downto 0);
            drdy     : out STD_LOGIC
        );
    end component;

    component DSP_Processor
        Generic (
            SYS_CLK_FREQ : integer := 100_000_000
        );
        Port (
            clk        : in  STD_LOGIC;
            reset_n    : in  STD_LOGIC;
            data_valid : in  STD_LOGIC;
            data_in    : in  STD_LOGIC_VECTOR(11 downto 0);
            mav_out    : out STD_LOGIC_VECTOR(11 downto 0);
            freq_out   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Moving_Average is
        Generic (
            WINDOW_SIZE_LOG2 : integer := 5; 
            DATA_WIDTH       : integer := 12
        );
        Port (
            clk         : in STD_LOGIC;
            reset_n     : in STD_LOGIC;
            data_in     : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            data_valid  : in STD_LOGIC;
            data_out    : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;

begin
    S_AXI_AWREADY   <= axi_awready;
    S_AXI_WREADY    <= axi_wready;
    S_AXI_BRESP     <= axi_bresp;
    S_AXI_BVALID    <= axi_bvalid;
    S_AXI_ARREADY   <= axi_arready;
    S_AXI_RDATA     <= axi_rdata;
    S_AXI_RRESP     <= axi_rresp;
    S_AXI_RVALID    <= axi_rvalid;

    -- Implement axi_awready generation
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_awready <= '0';
          aw_en <= '1';
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            axi_awready <= '1';
            aw_en <= '0';
          elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            aw_en <= '1';
            axi_awready <= '0';
          else
            axi_awready <= '0';
          end if;
        end if;
      end if;
    end process;

    -- Implement axi_awaddr latching
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_awaddr <= (others => '0');
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            axi_awaddr <= S_AXI_AWADDR;
          end if;
        end if;
      end if;                   
    end process; 

    -- Implement axi_wready generation
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_wready <= '0';
        else
          if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
              axi_wready <= '1';
          else
            axi_wready <= '0';
          end if;
        end if;
      end if;
    end process; 

    slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

    process (S_AXI_ACLK)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          slv_reg0 <= (others => '0');
        else
          loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
          if (slv_reg_wren = '1') then
            case loc_addr is
              when b"000" => -- REG 0: CONTROL (RW)
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when others =>
                slv_reg0 <= slv_reg0;
            end case;
          end if;
        end if;
      end if;                   
    end process; 

    -- Implement write response logic generation
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_bvalid  <= '0';
          axi_bresp   <= "00"; 
        else
          if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
            axi_bvalid <= '1';
            axi_bresp  <= "00"; 
          elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            axi_bvalid <= '0'; 
          end if;
        end if;
      end if;                   
    end process; 

    -- Implement axi_arready generation
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_arready <= '0';
          axi_araddr  <= (others => '1');
        else
          if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            axi_arready <= '1';
            axi_araddr  <= S_AXI_ARADDR;             
          else
            axi_arready <= '0';
          end if;
        end if;
      end if;                   
    end process; 

    -- Implement axi_rvalid generation
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_rvalid <= '0';
          axi_rresp  <= "00";
        else
          if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
            axi_rvalid <= '1';
            axi_rresp  <= "00"; 
          elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            axi_rvalid <= '0';
          end if;            
        end if;
      end if;
    end process;

    slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

    -- =====================================================================
    -- LECTURA DE REGISTROS (ACTUALIZADO)
    -- =====================================================================
    process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        case loc_addr is
          when b"000" => reg_data_out <= slv_reg0; -- 0x00 Control
          when b"001" => reg_data_out <= slv_reg1; -- 0x04 Raw
          when b"010" => reg_data_out <= slv_reg2; -- 0x08 MAV
          when b"011" => reg_data_out <= slv_reg3; -- 0x0C Freq
          when b"100" => reg_data_out <= slv_reg4; -- 0x10 Filtered
          when others => reg_data_out <= (others => '0');
        end case;
    end process; 

    process( S_AXI_ACLK ) is
    begin
      if (rising_edge (S_AXI_ACLK)) then
        if ( S_AXI_ARESETN = '0' ) then
          axi_rdata  <= (others => '0');
        else
          if (slv_reg_rden = '1') then
              axi_rdata <= reg_data_out;      
          end if;   
        end if;
      end if;
    end process;

    -- =====================================================================
    --                        LÓGICA DE USUARIO
    -- =====================================================================

    -- 1. Instanciación del ADC Controller
    inst_adc_controller: ADC_Controller
    Generic Map (
        SYS_CLK_FREQ => 100_000_000,
        SCLK_FREQ    => 12_500_000
    )
    Port Map (
        clk      => S_AXI_ACLK,
        reset_n  => S_AXI_ARESETN,
        start    => slv_reg0(0),
        
        sdata    => spi_sdata,
        sclk     => spi_sclk,
        cs       => spi_cs,
        
        data_out => adc_data_internal, 
        drdy     => adc_drdy_internal  
    );

    -- 2. Instanciación del DSP Processor
    inst_dsp_processor: DSP_Processor
    Generic Map (
        SYS_CLK_FREQ => 100_000_000
    )
    Port Map (
        clk        => S_AXI_ACLK,
        reset_n    => S_AXI_ARESETN,
        
        data_valid => adc_drdy_internal,
        data_in    => adc_data_internal,
        
        mav_out    => dsp_mav_internal,
        freq_out   => dsp_freq_internal
    );
    
    -- 3. Instanciación del Filtro FIR
    inst_moving_average: Moving_Average
    Generic Map (
        WINDOW_SIZE_LOG2 => 5, 
        DATA_WIDTH       => 12
    )
    Port Map (
        clk        => S_AXI_ACLK,
        reset_n    => S_AXI_ARESETN,
        data_in    => adc_data_internal,
        data_valid => adc_drdy_internal, 
        data_out   => adc_filtered_internal
    );

    -- =====================================================================
    -- MAPEO DE REGISTROS AXI Y EXPORTACIÓN
    -- =====================================================================

    -- Exportación a HDMI (Usamos dato crudo para ver ruido en osciloscopio)
    --adc_data_export  <= adc_data_internal;
    adc_valid_export <= adc_drdy_internal;
    -- AHORA (Señal FILTRADA y limpia):
    adc_data_export  <= adc_filtered_internal;  -- <--- CAMBIO CLAVE

    -- REG 1: Datos Crudos ADC
    slv_reg1(11 downto 0)  <= adc_data_internal;
    slv_reg1(30 downto 12) <= (others => '0');
    slv_reg1(31)           <= adc_drdy_internal;

    -- REG 2: Valor Medio (MAV)
    slv_reg2(11 downto 0)  <= dsp_mav_internal;
    slv_reg2(31 downto 12) <= (others => '0');

    -- REG 3: Frecuencia (Hz)
    slv_reg3 <= dsp_freq_internal;
    
    -- REG 4: Dato Filtrado
    slv_reg4(11 downto 0)  <= adc_filtered_internal;
    slv_reg4(31 downto 12) <= (others => '0');

end arch_imp;


