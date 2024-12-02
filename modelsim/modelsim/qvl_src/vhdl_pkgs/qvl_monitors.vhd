--              Copyright 2006-2009 Mentor Graphics Corporation
--                           All Rights Reserved.
--
--              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
--            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
--           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
--                                  TERMS.
--
--                   Questa Verification Library (QVL)
--

library ieee;
use ieee.std_logic_1164.all;

PACKAGE qvl_monitors IS

--------------------------------------------------------------------------------

COMPONENT qvl_ahb_master_monitor

  GENERIC (
     Constraints_Mode : integer := 0;
     DATA_BUS_WIDTH : integer := 32;
     CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE : integer := 0;
     Over_Constraints_Mode : integer := 0;
     DISABLE_CHKS_ON_IDLE : integer := 0
  );

  PORT (
    hgrantx : in std_logic;
    hready : in std_logic;
    hresp : in std_logic_vector(1 downto 0);
    hresetn : in std_logic;
    hclk : in std_logic;
    hrdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    htrans : in std_logic_vector(1 downto 0);
    haddr : in std_logic_vector(31 downto 0);
    hwrite : in std_logic;
    hsize : in std_logic_vector(2 downto 0);
    hburst : in std_logic_vector(2 downto 0);
    hprot : in std_logic_vector(3 downto 0);
    hwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
  );

END COMPONENT; -- qvl_ahb_master_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_ahb_master_target_monitor

  GENERIC (

     Constraints_Mode : integer := 0;
     DATA_BUS_WIDTH : integer := 32;
     NUMBER_OF_MASTERS : integer := 16;
     CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE : integer := 0;
     Over_Constraints_Mode : integer := 0;
     DISABLE_CHKS_ON_IDLE : integer := 0

  );

  PORT (

    hclk : in std_logic;
    hresetn : in std_logic;
    hgrantx : in std_logic;
    ahb_hready : in std_logic;
    ahb_hresp : in std_logic_vector(1 downto 0);
    ahb_hrdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    mas_htrans : in std_logic_vector(1 downto 0);
    mas_haddr : in std_logic_vector(31 downto 0);
    mas_hwrite : in std_logic;
    mas_hsize : in std_logic_vector(2 downto 0);
    mas_hburst : in std_logic_vector(2 downto 0);
    mas_hprot : in std_logic_vector(3 downto 0);
    mas_hwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    hselx : in std_logic;
    ahb_htrans : in std_logic_vector(1 downto 0);
    ahb_haddr : in std_logic_vector(31 downto 0);
    ahb_hwrite : in std_logic;
    ahb_hsize : in std_logic_vector(2 downto 0);
    ahb_hburst : in std_logic_vector(2 downto 0);
    ahb_hwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    ahb_hmaster : in std_logic_vector(3 downto 0);
    ahb_hmastlock : in std_logic;
    ahb_hready_in : in std_logic;
    tar_hready_out : in std_logic;
    tar_hresp : in std_logic_vector(1 downto 0);
    tar_hrdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    tar_hsplitx : in std_logic_vector(NUMBER_OF_MASTERS-1 downto 0)
  );

END COMPONENT; -- qvl_ahb_master_target_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_ahb_target_monitor

  GENERIC (

     Constraints_Mode : integer := 0;
     DATA_BUS_WIDTH : integer := 32;
     NUMBER_OF_MASTERS : integer := 16;
     CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE : integer := 0;
     Over_Constraints_Mode : integer := 0;
     DISABLE_CHKS_ON_IDLE : integer := 0

  );

  PORT (

    hselx : in std_logic;
    haddr : in std_logic_vector(31 downto 0);
    hwrite : in std_logic;
    htrans : in std_logic_vector(1 downto 0);
    hsize : in std_logic_vector(2 downto 0);
    hburst : in std_logic_vector(2 downto 0);
    hwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    hresetn : in std_logic;
    hclk : in std_logic;
    hmaster : in std_logic_vector(3 downto 0);
    hmastlock : in std_logic;
    hready_in : in std_logic;
    hready_out : in std_logic;
    hresp : in std_logic_vector(1 downto 0);
    hrdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    hsplitx : in std_logic_vector(NUMBER_OF_MASTERS-1 downto 0)
  );

END COMPONENT; -- qvl_ahb_target_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_apb_monitor

  GENERIC (

     Constraints_Mode : integer := 0;
     ADD_BUS_WIDTH  : integer := 32;
     DATA_BUS_WIDTH : integer := 32

  );

  PORT (

    pclk : in std_logic;
    presetn : in std_logic;
    paddr : in std_logic_vector(ADD_BUS_WIDTH-1 downto 0);
    pselx : in std_logic;
    penable : in std_logic;
    pwrite : in std_logic;
    pwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    prdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
  );

END COMPONENT; -- qvl_apb_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_amba3_apb_monitor

  GENERIC (

     Constraints_Mode : integer := 0;
     ADD_BUS_WIDTH  : integer := 32;
     DATA_BUS_WIDTH : integer := 32

  );

  PORT (

    pclk : in std_logic;
    presetn : in std_logic;
    paddr : in std_logic_vector(ADD_BUS_WIDTH-1 downto 0);
    pselx : in std_logic;
    penable : in std_logic;
    pwrite : in std_logic;
    pwdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    prdata : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    pready : in std_logic;
    pslverr : in std_logic
  );

END COMPONENT; -- qvl_amba3_apb_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_amba_axi_monitor

  GENERIC (

    Constraints_Mode : integer := 0;
    INTERFACE_TYPE : integer := 0;
    WRITE_DATA_BUS_WIDTH : integer := 32;
    READ_DATA_BUS_WIDTH : integer := 32;
    TRAN_ID_WIDTH : integer := 4;
    READ_REORDER_DEPTH : integer := 8;
    READ_INTERLEAVING_DEPTH : integer := 8;
    WRITE_INTERLEAVING_DEPTH : integer := 8;
    EXCLUSIVE_ACCESS_ENABLE : integer := 1;
    LPI_ENABLE : integer := 0;
    MAX_OUTSTANDING_READ_ADDR : integer := 16;
    MAX_OUTSTANDING_WRITE_ADDR : integer := 16;
    CHECK_WRITE_DATA_FOLLOWS_ADDR_ENABLE : integer := 0;
    ENABLE_RESERVED_VALUE_CHECKING : integer := 1;
    ENABLE_RECOMMENDATION_CHECKING : integer := 0;
    LENGTH_WIDTH : integer := 4;
    ADDR_WIDTH : integer := 32;
    MAX_UNIQUE_EXCLUSIVE_ACCESSES : integer := 16;
    EXCLUSIVE_READ_RESPONSE_CHECKING_ENABLE : integer := 1

  );

  PORT (

  -- Global clock and reset signals
    aclk : in std_logic;
    areset_n : in std_logic;
    reset_n : in std_logic;

  -- Write address channel signals
    awvalid : in std_logic;
    awaddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    awlen : in std_logic_vector(LENGTH_WIDTH-1 downto 0);
    awsize : in std_logic_vector(2 downto 0);
    awburst : in std_logic_vector(1 downto 0);
    awlock : in std_logic_vector(1 downto 0);
    awcache : in std_logic_vector(3 downto 0);
    awprot : in std_logic_vector(2 downto 0);
    awid : in std_logic_vector(TRAN_ID_WIDTH-1 downto 0);
    awready : in std_logic;

  -- Read address channel signals
    arvalid : in std_logic;
    araddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    arlen : in std_logic_vector(LENGTH_WIDTH-1 downto 0);
    arsize : in std_logic_vector(2 downto 0);
    arburst : in std_logic_vector(1 downto 0);
    arlock : in std_logic_vector(1 downto 0);
    arcache : in std_logic_vector(3 downto 0);
    arprot : in std_logic_vector(2 downto 0);
    arid : in std_logic_vector(TRAN_ID_WIDTH-1 downto 0);
    arready : in std_logic;

  -- Write channel signals
    wvalid : in std_logic;
    wlast : in std_logic;
    wdata : in std_logic_vector(WRITE_DATA_BUS_WIDTH-1 downto 0);
    wstrb : in std_logic_vector((WRITE_DATA_BUS_WIDTH / 8)-1 downto 0);
    wid : in std_logic_vector(TRAN_ID_WIDTH-1 downto 0);
    wready : in std_logic;

  -- Read channel signals
    rvalid : in std_logic;
    rlast : in std_logic;
    rdata : in std_logic_vector(READ_DATA_BUS_WIDTH-1 downto 0);
    rresp : in std_logic_vector(1 downto 0);
    rid : in std_logic_vector(TRAN_ID_WIDTH-1 downto 0);
    rready : in std_logic;

  -- Write response channel signals
    bvalid : in std_logic;
    bresp : in std_logic_vector(1 downto 0);
    bid : in std_logic_vector(TRAN_ID_WIDTH-1 downto 0);
    bready : in std_logic;

  -- Low power interface signals
    cactive : in std_logic;
    csysreq : in std_logic;
    csysack : in std_logic

  );

END COMPONENT; -- qvl_amba_axi_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_ddr_sdram_monitor

  GENERIC (
    Constraints_Mode : integer := 0;
    CONTROLLER_SIDE : integer := 1;
    CS_CKE_WIDTH : integer := 1;
    ADDR_WIDTH : integer := 12;
    DM_WIDTH : integer := 1;
    DATA_WIDTH : integer := 8;
    DLL_TRACKING_ENABLE : integer := 1;
    TRC_OVERRIDE : integer := 0;
    TRAS_OVERRIDE : integer := 0;
    TRP_OVERRIDE : integer := 0;
    TRCD_OVERRIDE : integer := 0;
    TRRD_OVERRIDE : integer := 0;
    TMRD_OVERRIDE : integer := 0;
    TRFC_OVERRIDE : integer := 0;
    TXSNR_OVERRIDE : integer := 0;
    TXSRD_OVERRIDE : integer :=0;
    TWR_OVERRIDE : integer := 0;
    TWTR_OVERRIDE : integer := 0;
    AUTOPRECHARGE_ENABLE_ADDRESS_BIT : integer := 10;
    COL_ADDRESS_WIDTH : integer := 8;
    READ_BEFORE_WRITE_CHECK_ENABLE : integer := 1;
    CON_AUTO_PRECHARGE : integer := 8;
    ENABLE_WHY_PRECHARGE_AN_IDLE_BANK : integer := 0;
    BYPASS_INIT : integer := 0;
    NON_JEDEC : integer := 0
  );

  PORT (

  -- Global clock and reset signals
    clock : in std_logic;
    clock_n : in std_logic;
    areset : in std_logic;
    reset : in std_logic;

  -- Control Signals
    CKE : in std_logic_vector(CS_CKE_WIDTH-1 downto 0);
    CS_n : in std_logic_vector(CS_CKE_WIDTH-1 downto 0);
    RAS_n : in std_logic;
    CAS_n : in std_logic;
    WE_n : in std_logic;
    DM : in std_logic_vector(DM_WIDTH-1 downto 0);
    BA : in std_logic_vector(1 downto 0);
    A : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    DQ : in std_logic_vector(DATA_WIDTH-1 downto 0);
    DQS : in std_logic;
    mode_register : in std_logic_vector(ADDR_WIDTH+1 downto 0);
    extended_mode_register : in std_logic_vector(ADDR_WIDTH+1 downto 0)
  );

END COMPONENT; -- qvl_ddr_sdram_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_ddr_sdram_2_0_monitor

  GENERIC (

    Constraints_Mode : integer := 0;
    CONTROLLER_SIDE : integer := 1;
    ADDR_WIDTH : integer := 12;
    DATA_WIDTH : integer := 8;
    DLL_TRACKING_ENABLE : integer := 1;
    TRC_OVERRIDE : integer := 0;
    TRAS_OVERRIDE : integer := 0;
    TRP_OVERRIDE : integer := 0;
    TRCD_OVERRIDE : integer := 0;
    TRRD_OVERRIDE : integer := 0;
    TMRD_OVERRIDE : integer := 0;
    TRFC_OVERRIDE : integer := 0;
    TXSNR_OVERRIDE : integer := 0;
    TXSRD_OVERRIDE : integer := 0;
    TWR_OVERRIDE : integer := 0;
    TWTR_OVERRIDE : integer := 0;
    AUTOPRECHARGE_ENABLE_ADDRESS_BIT : integer := 10;
    COL_ADDRESS_WIDTH : integer := 8;
    READ_BEFORE_WRITE_CHECK_ENABLE : integer := 1;
    CON_AUTO_PRECHARGE : integer := 0;
    ENABLE_WHY_PRECHARGE_AN_IDLE_BANK : integer := 0;
    BYPASS_INIT : integer := 0;
    NON_JEDEC : integer :=0;
    USE_PORTS_TO_CONFIGURE : integer := 0;
    DM_WIDTH : integer := 1
  );

  PORT (

  -- Global clock and reset signals
    clock : in std_logic;
    clock_n : in std_logic;
    areset : in std_logic;
    reset : in std_logic;

  -- Control Signals
    CKE : in std_logic;
    CS_n : in std_logic;
    RAS_n : in std_logic;
    CAS_n : in std_logic;
    WE_n : in std_logic;
    DM : in std_logic_vector(DM_WIDTH-1 downto 0);
    BA : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    A : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    DQ : in std_logic_vector(DATA_WIDTH-1 downto 0);
    DQS : in std_logic;
    LDQS : in std_logic;
    LDM : in std_logic;
    UDQS : in std_logic;
    UDM : in std_logic;
    mode_register : in std_logic_vector(ADDR_WIDTH+1 downto 0);
    extended_mode_register : in std_logic_vector(ADDR_WIDTH+1 downto 0);
    TRC : in std_logic_vector(31 downto 0);
    TRAS : in std_logic_vector(31 downto 0);
    TRP : in std_logic_vector(31 downto 0);
    TRCD : in std_logic_vector(31 downto 0);
    TRRD : in std_logic_vector(31 downto 0);
    TWR : in std_logic_vector(31 downto 0);
    TWTR : in std_logic_vector(31 downto 0);
    TMRD : in std_logic_vector(31 downto 0);
    TRFC : in std_logic_vector(31 downto 0);
    TXSNR : in std_logic_vector(31 downto 0);
    TXSRD : in std_logic_vector(31 downto 0)
  );

END COMPONENT; -- qvl_ddr_sdram_2_0_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_ddr2_sdram_monitor

  GENERIC (
    Constraints_Mode : integer := 0;
    CONTROLLER_SIDE : integer := 1;
    ROW_ADDR_WIDTH : integer := 13;
    DATA_BUS_WIDTH : integer := 8;
    DM_WIDTH : integer := 1; 
    DLL_TRACKING_ENABLE : integer := 1;
    TRAS : integer := 6;
    TRCD : integer := 3;
    TRP : integer := 3;
    TRRD : integer := 2;
    TCCD : integer := 2;
    TRTW : integer := 4;
    TWTR : integer := 2;
    TWR : integer := 3;
    TRFC : integer := 10;
    TXSNR : integer := 10;
    TXSRD : integer := 200;
    TMRD : integer := 2;
    AUTOPRECHARGE_ENABLE_ADDRESS_BIT : integer := 10;
    READ_BEFORE_WRITE_CHECK_ENABLE : integer := 1
  );
    
  PORT (
    
  -- Global clock and reset signals
    ck : in std_logic;
    ck_n : in std_logic;
    areset : in std_logic;
    reset : in std_logic;

  -- Control Signals
    cke : in std_logic;
    cs_n : in std_logic;
    ras_n : in std_logic;
    cas_n : in std_logic;
    we_n : in std_logic;
    dm : in std_logic_vector(DM_WIDTH-1 downto 0);
    ba : in std_logic_vector(1 downto 0);
    a : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
    dq : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    dqs : in std_logic
  );
    
END COMPONENT; -- qvl_ddr2_sdram_monitor
    
--------------------------------------------------------------------------------

COMPONENT qvl_ddr2_sdram_2_0_monitor

  GENERIC (
    
    Constraints_Mode : integer := 0;
    CONTROLLER_SIDE : integer := 1;
    ROW_ADDR_WIDTH : integer := 13;
    DATA_BUS_WIDTH : integer := 8;
    DLL_TRACKING_ENABLE : integer := 1;
    TRAS : integer := 6;
    TRCD : integer := 3;
    TRP : integer := 3;
    TRRD : integer := 2;
    TCCD : integer := 2;
    TRTW : integer := 4;
    TWTR : integer := 2;
    TWR : integer := 3;
    TRFC : integer := 10;
    TXSNR : integer := 10;
    TXSRD : integer := 200;
    TMRD : integer := 2;
    AUTOPRECHARGE_ENABLE_ADDRESS_BIT : integer := 10;
    READ_BEFORE_WRITE_CHECK_ENABLE : integer := 1;
    TXP : integer := 2;
    TXARD : integer := 2;
    BANK_ADDR_WIDTH : integer := 3;
    ENABLE_PRECHARGE_TO_IDLE_BANK : integer := 0;
    BYPASS_INIT : integer := 0;
    ZI_DM_WIDTH  : integer := 1
  );
  
  PORT (
    
  -- Global clock and reset signals
    ck : in std_logic;
    ck_n : in std_logic;
    areset : in std_logic;
    reset : in std_logic;
    
  -- Control Signals
    cke : in std_logic;
    cs_n : in std_logic;
    ras_n : in std_logic;
    cas_n : in std_logic;
    we_n : in std_logic;
    dm_rdqs : in std_logic_vector(ZI_DM_WIDTH-1 downto 0);
    ba : in std_logic_vector(BANK_ADDR_WIDTH-1 downto 0);
    a : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
    dq : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    dqs : in std_logic;
    ldqs : in std_logic;
    ldm : in std_logic;
    udqs : in std_logic;
    udm : in std_logic;
    mode_register_in : in std_logic_vector(ROW_ADDR_WIDTH+BANK_ADDR_WIDTH-1 downto 0);
    ex_mode_register_in : in std_logic_vector(ROW_ADDR_WIDTH+BANK_ADDR_WIDTH-1 downto 0)
  );

END COMPONENT; -- qvl_ddr2_sdram_2_0_monitor

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

COMPONENT qvl_gigabit_ethernet_xgmii_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    MAC_SIDE                        : integer := 1;
    JUMBO_FRAME_DATA_LENGTH         : integer := 9126;
    RESERVED_VALUE_CHECK_ENABLE     : integer := 1;
    DDR                             : integer := 1

          );

  PORT (

    areset          : in std_logic;
    reset           : in std_logic;
    tx_clk          : in std_logic;
    txd             : in std_logic_vector((64 - (32*DDR))-1 downto 0);
    txc             : in std_logic_vector((8 - (4*DDR))-1 downto 0);
    rx_clk          : in std_logic;
    rxd             : in std_logic_vector((64 - (32*DDR))-1 downto 0);
    rxc             : in std_logic_vector((8 - (4*DDR))-1 downto 0)

      );

END COMPONENT; -- qvl_gigabit_ethernet_xgmii_monitor

COMPONENT qvl_gigabit_ethernet_mii_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    MAC_SIDE                        : integer := 1;
    JUMBO_FRAME_DATA_LENGTH         : integer := 9126;
    RESERVED_VALUE_CHECK_ENABLE     : integer := 1;
    HALF_DUPLEX                     : integer := 0

          );

  PORT (

    areset          : in std_logic;
    reset           : in std_logic;
    tx_clk          : in std_logic;
    txd             : in std_logic_vector(3 downto 0);
    tx_en           : in std_logic;
    tx_er           : in std_logic;
    rx_clk          : in std_logic;
    rxd             : in std_logic_vector(3 downto 0);
    rx_dv           : in std_logic;
    rx_er           : in std_logic;
    col             : in std_logic;
    crs             : in std_logic

      );

END COMPONENT; --qvl_gigabit_ethernet_mii_monitor
 
COMPONENT qvl_gigabit_ethernet_xsbi_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    MAC_SIDE                        : integer := 1;
    JUMBO_FRAME_DATA_LENGTH         : integer := 9126;
    RESERVED_VALUE_CHECK_ENABLE     : integer := 1;
    BYPASS_BLOCK_SYNC               : integer := 1

          );

  PORT (

    areset             : in std_logic;
    reset              : in std_logic;
    tx_clk             : in std_logic;
    rx_clk             : in std_logic;
    txd                : in std_logic_vector(15 downto 0);
    rxd                : in std_logic_vector(15 downto 0);
    bypass_descramble  : in std_logic

      );

END COMPONENT; --qvl_gigabit_ethernet_xsbi_monitor

COMPONENT qvl_gigabit_ethernet_gmii_monitor

  GENERIC (

    Constraints_Mode            : integer := 0;
    MAC_SIDE                    : integer := 1;
    JUMBO_FRAME_DATA_LENGTH     : integer := 9126;
    RESERVED_VALUE_CHECK_ENABLE : integer := 1;
    HALF_DUPLEX                 : integer := 0

          );

  PORT (

    areset      : in std_logic;
    reset       : in std_logic;
    tx_clk      : in std_logic;
    txd         : in std_logic_vector ( 7 downto 0); 
    tx_en       : in std_logic;
    tx_er       : in std_logic;
    rx_clk      : in std_logic;
    rxd         : in std_logic_vector ( 7 downto 0);
    rx_dv       : in std_logic;
    rx_er       : in std_logic;
    col         : in std_logic;
    crs         : in std_logic

       );

END COMPONENT; --qvl_gigabit_ethernet_gmii_monitor

COMPONENT qvl_gigabit_ethernet_xaui_monitor

  GENERIC (

    Constraints_Mode            : integer := 0;
    MAC_SIDE                    : integer := 1;
    JUMBO_FRAME_DATA_LENGTH     : integer := 9126;
    RESERVED_VALUE_CHECK_ENABLE : integer := 1;
    SYMBOL_MODE                 : integer := 0;
    BYPASS_DESKEW               : integer := 0

          );

  PORT (

    areset  : in std_logic;
    reset   : in std_logic;
    dl_clk  : in std_logic;
    sl_clk  : in std_logic;
    sl0_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    sl1_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    sl2_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    sl3_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    dl0_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    dl1_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    dl2_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0);
    dl3_p   : in std_logic_vector (((1+(SYMBOL_MODE*9))-1) downto 0)

       );

END COMPONENT; --qvl_gigabit_ethernet_xaui_monitor

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_i2c_master_monitor

  GENERIC (

  -- Parameters

    Constraints_Mode : integer := 0;
    MAX_TXN_LENGTH : integer := 0;
    CLOCK_PRESCALE_EN :  integer := 0;
    OUTPUT_ENABLES_ON :  integer := 0;
    ZI_ADDR_WIDTH : integer := 10
  );

  PORT (

  -- Global clock and reset signals

    clock : in std_logic;
    reset : in std_logic;
    areset : in std_logic;
    sda_out : in std_logic;
    sda_in : in std_logic;
    sda_out_en_n : in std_logic;
    scl_out : in std_logic;
    scl_in : in std_logic;
    scl_out_en_n : in std_logic;
    clock_prescale_count : in std_logic_vector(15 downto 0)
  );

END COMPONENT; -- qvl_i2c_master_monitor

----------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_i2c_master_slave_monitor

  GENERIC (

  -- Parameters

    Constraints_Mode : integer := 0;
    MAX_TXN_LENGTH : integer := 0;
    CLOCK_PRESCALE_EN :  integer := 0;
    OUTPUT_ENABLES_ON :  integer := 0;
    ZI_ADDR_WIDTH : integer := 10
  );

  PORT (

  -- Global clock and reset signals

    clock : in std_logic;
    reset : in std_logic;
    areset : in std_logic;
    sda_out : in std_logic;
    sda_in : in std_logic;
    sda_out_en_n : in std_logic;
    scl_out : in std_logic;
    scl_in : in std_logic;
    scl_out_en_n : in std_logic;
    slave_addr : in std_logic_vector(ZI_ADDR_WIDTH-1 downto 0);
    clock_prescale_count : in std_logic_vector(15 downto 0)
  );

END COMPONENT; -- qvl_i2c_master_slave_monitor

----------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_i2c_slave_monitor 

  GENERIC (

  -- Parameters

    Constraints_Mode : integer := 0;
    MAX_TXN_LENGTH : integer := 0;
    CLOCK_PRESCALE_EN :  integer := 0;
    OUTPUT_ENABLES_ON :  integer := 0;
    ZI_ADDR_WIDTH : integer := 10
  );

  PORT ( 

  -- Global clock and reset signals

    clock : in std_logic;
    reset : in std_logic;
    areset : in std_logic;
    sda_out : in std_logic;
    sda_in : in std_logic;
    sda_out_en_n : in std_logic;
    scl_out : in std_logic;
    scl_in : in std_logic;
    scl_out_en_n : in std_logic;
    slave_addr : in std_logic_vector(ZI_ADDR_WIDTH-1 downto 0);
    clock_prescale_count : in std_logic_vector(15 downto 0)
  );

END COMPONENT; -- qvl_i2c_slave_monitor

----------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_lpc_monitor

  GENERIC (

    Constraints_Mode : integer := 0;
    LDRQ_WIDTH : integer := 2;
    RETAIN_DMA_ON_ABORT : integer := 1;
    CHECK_RESERVED_VALUE : integer := 0;
    ALLOW_LARGE_DMA_TRANSFERS : integer := 1;
    ALLOW_DMA_AFTER_DEACTIVATION : integer := 1

  );

  PORT (

   lclk : in std_logic;
   lreset_n : in std_logic;
   lframe_n : in std_logic;
   lad : in std_logic_vector(3 downto 0);
   ldrq_n : in std_logic_vector(LDRQ_WIDTH-1 downto 0);
   serirq : in std_logic;
   clkrun_n : in std_logic;
   pme_n : in std_logic;
   lpcpd_n : in std_logic;
   lsmi_n : in std_logic

  );

END COMPONENT; -- qvl_lpc_monitor

------------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_ocp_monitor

  GENERIC (

   Constraints_Mode : integer := 0;
   INTERFACE_TYPE : integer := 0;
   ADDR_WDTH : integer := 32;
   DATA_WDTH : integer := 32;
   BURSTLENGTH_WDTH : integer := 4;
   ATOMICLENGTH_WDTH : integer := 2;
   THREADS : integer := 1;
   THREADID_WDTH : integer := 1;
   CONNID_WDTH : integer := 1;
   ADDRSPACE_WDTH : integer := 4;
   MDATAINFO_WDTH : integer := 4;
   MDATAINFOBYTE_WDTH : integer := 1;
   REQINFO_WDTH : integer := 4;
   RESPINFO_WDTH : integer := 4;
   SDATAINFO_WDTH : integer := 4;
   SDATAINFOBYTE_WDTH : integer := 1;
   CONTROL_WDTH : integer := 4;
   STATUS_WDTH : integer := 4;
   TAGS : integer := 1;
   TAGID_WDTH : integer := 1;
   TAG_INTERLEAVE_SIZE: integer := 1;
   ENABLE_INTER_PHASE_TRANFER_CHECKS : integer := 0;
   MAX_OUTSTANDING_REQ : integer := 16
  );

   PORT (

  -- Monitor connections
    clk : in std_logic;
    areset_n : in std_logic;
    maddr : in std_logic_vector(ADDR_WDTH-1 downto 0);
    mcmd : in std_logic_vector(2 downto 0);
    mdata : in std_logic_vector(DATA_WDTH-1 downto 0);
    mdatavalid : in std_logic;
    mrespaccept : in std_logic;
    scmdaccept : in std_logic;
    sdata : in std_logic_vector(DATA_WDTH-1 downto 0);
    sdataaccept : in std_logic;
    sresp : in std_logic_vector(1 downto 0);

  -- Simple Extensions
    maddrspace : in std_logic_vector(ADDRSPACE_WDTH-1 downto 0);
    mbyteen : in std_logic_vector(1 + ((DATA_WDTH-1)/8)-1 downto 0);
    mdatabyteen : in std_logic_vector(1 + ((DATA_WDTH-1)/8)-1 downto 0);
    mdatainfo : in std_logic_vector(MDATAINFO_WDTH-1 downto 0);
    mreqinfo : in std_logic_vector(REQINFO_WDTH-1 downto 0);
    sdatainfo : in std_logic_vector(SDATAINFO_WDTH-1 downto 0);
    srespinfo : in std_logic_vector(RESPINFO_WDTH-1 downto 0);

  -- Burst Extensions
    matomiclength : in std_logic_vector(ATOMICLENGTH_WDTH-1 downto 0);
    mburstlength : in std_logic_vector(BURSTLENGTH_WDTH-1 downto 0);
    mburstprecise : in std_logic;
    mburstseq : in std_logic_vector(2 downto 0);
    mburstsinglereq : in std_logic;
    mdatalast : in std_logic;
    mreqlast : in std_logic;
    sresplast : in std_logic;

  -- Tag Extensions
    mdatatagid : in std_logic_vector(TAGID_WDTH-1 downto 0);
    mtagid : in std_logic_vector(TAGID_WDTH-1 downto 0);
    mtaginorder: in std_logic;
    stagid : in std_logic_vector(TAGID_WDTH-1 downto 0);
    staginorder : in std_logic;

  -- Thread Extensions
    mconnid : in std_logic_vector(CONNID_WDTH-1 downto 0);
    mdatathreadid : in std_logic_vector(THREADID_WDTH-1 downto 0);
    mthreadbusy : in std_logic_vector(THREADS-1 downto 0);
    mthreadid : in std_logic_vector(THREADID_WDTH-1 downto 0);
    sdatathreadbusy : in std_logic_vector(THREADS-1 downto 0);
    sthreadbusy : in std_logic_vector(THREADS-1 downto 0);
    sthreadid : in std_logic_vector(THREADID_WDTH-1 downto 0);

  -- Sideband Signals
    mreset_n : in std_logic;
    sreset_n : in std_logic;
    control : in std_logic_vector(CONTROL_WDTH-1 downto 0);
    controlbusy : in std_logic;
    controlwr : in std_logic;
    status : in std_logic_vector(STATUS_WDTH-1 downto 0);
    statusbusy : in std_logic;
    statusrd : in std_logic;

  -- base addr for XOR burst
    base : in std_logic_vector(ADDR_WDTH-1 downto 0);

  -- Parameter configuration ports
    phase_options_group : in std_logic_vector(2 downto 0);
    basic_group : in std_logic_vector(6 downto 0);
    simple_ext_group : in std_logic_vector(6 downto 0);
    burst_ext_group : in std_logic_vector(16 downto 0);
    tag_ext_group : in std_logic;
    thread_ext_group : in std_logic_vector(6 downto 0);
    sideband_sig_group : in std_logic_vector(5 downto 0);
    cmd_enable_group : in std_logic_vector(5 downto 0)
  );

END COMPONENT; -- qvl_ocp_monitor

------------------------------------------------------------------------------

COMPONENT qvl_pci_monitor

  GENERIC (

   Bit64Mode : integer := 0;
   Constraints_Mode : integer := 0;
   ParityErrorResponse : integer := 1;
   SELF_CONFIG : integer := 0;
   SystemErrorResponse : integer := 1

  );

  PORT (

    pci_ad_en_n : in std_logic;
    pci_cbe_en_n : in std_logic;
    pci_frame_en_n : in std_logic;
    pci_irdy_en_n : in std_logic;
    pci_trdy_en_n : in std_logic;
    pci_devsel_en_n : in std_logic;
    pci_stop_en_n : in std_logic;
    pci_perr_en_n : in std_logic;
    pci_par_en_n : in std_logic;
    pci_par64_en_n : in std_logic;
    pci_req64_en_n : in std_logic;
    pci_ack64_en_n : in std_logic;

    pci_req_out_n : in std_logic;
    pci_ad_out : in std_logic_vector(32*(1+Bit64Mode)-1 downto 0);
    pci_cbe_out_n : in std_logic_vector(4*(1+Bit64Mode)-1 downto 0);
    pci_frame_out_n : in std_logic;
    pci_irdy_out_n : in std_logic;
    pci_trdy_out_n : in std_logic;
    pci_devsel_out_n : in std_logic;
    pci_stop_out_n : in std_logic;
    pci_perr_out_n : in std_logic;
    pci_serr_out_n : in std_logic;
    pci_par_out : in std_logic;
    pci_par64_out : in std_logic;
    pci_req64_out_n : in std_logic;
    pci_ack64_out_n : in std_logic;

    pci_rst_in_n : in std_logic;
    pci_clk_in : in std_logic;
    pci_gnt_in_n : in std_logic;
    pci_idsel_in : in std_logic;
    pci_ad_in : in std_logic_vector(32*(1+Bit64Mode)-1 downto 0);
    pci_cbe_in_n : in std_logic_vector(4*(1+Bit64Mode)-1 downto 0);
    pci_frame_in_n : in std_logic;
    pci_irdy_in_n : in std_logic;
    pci_trdy_in_n : in std_logic;
    pci_devsel_in_n : in std_logic;
    pci_stop_in_n : in std_logic;
    pci_lock_in_n : in std_logic;
    pci_perr_in_n : in std_logic;
    pci_par_in : in std_logic;
    pci_par64_in : in std_logic;
    pci_req64_in_n : in std_logic;
    pci_ack64_in_n : in std_logic

  );

END COMPONENT; -- qvl_pci_monitor

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

COMPONENT qvl_pci_express_gen2_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    PCI_EXPRESS_DEVICE_TYPE         : integer := 0;
    INTERFACE_TYPE                  : integer := 0;
    MAX_LINK_WIDTH                  : integer := 2;
    DOUBLE_DATA_RATE                : integer := 0;
    MAX_REQUESTS_ADDR_WIDTH         : integer := 5;
    ELECTRICAL_IDLE_VAL             : integer := 0;
    RESERVED_FIELD_CHECK_ENABLE     : integer := 1;
    VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0;
    OVERRIDE_TIMER_VALUE            : integer := 0;
    REPLAY_TIMER_VALUE              : integer := 711;
    ACKNAK_TIMER_VALUE              : integer := 237;
    MIN_TS1_COUNT                   : integer := 1024;
    DESKEW_SUPPORT                  : integer := 0;
    VC_SUPPORT                      : integer := 0;
    HOT_PLUG_MESSAGE_ENABLE         : integer := 0;
    TX_SKEW_SUPPORT                 : integer := 0;
    ENABLE_DATA_PLUS_MINUS_CHECK    : integer := 0;
    CPL_TIMEOUT_CLK                 : integer := 30000;
    UPDATE_FC_30US_TIMER_CLK        : integer := 7500

  );

  PORT (

  -- Global clock and reset signals
    reset           : in std_logic;
    areset          : in std_logic;
    tx_clk          : in std_logic;
    tx_symbols_plus  : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    tx_symbols_minus : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    rx_clk          : in std_logic;
    rx_symbols_plus  : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    rx_symbols_minus : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);

  -- Monitor configuration inputs

    skip_link_training               : in std_logic;
    device_control_register          : in std_logic_vector(15 downto 0);
    device_capabilities_register     : in std_logic_vector(31 downto 0);
    extended_sync_enable             : in std_logic;
    L0s_entry_supported              : in std_logic;
    phy_layer_checks_disable         : in std_logic;
    link_layer_checks_disable        : in std_logic;
    transaction_layer_checks_disable : in std_logic;

  -- VC Configuration

    enable_vc_id : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_0 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_1 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_2 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_3 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_4 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_5 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_6 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_7 : in std_logic_vector(7 downto 0);

        disable_cpl_timeout : in std_logic;
        acs_translation_blocking_enable : in std_logic 

  );

END COMPONENT; -- qvl_pci_express_gen2_monitor

COMPONENT qvl_pci_express_gen2_pipe_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    PCI_EXPRESS_DEVICE_TYPE         : integer := 0;
    MAC_LAYER_SIDE                  : integer := 1;
    INTERFACE_TYPE                  : integer := 0;
    MAX_LINK_WIDTH                  : integer := 2;
    MAX_REQUESTS_ADDR_WIDTH         : integer := 5;
    RESERVED_FIELD_CHECK_ENABLE     : integer := 1;
    VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0;
    OVERRIDE_TIMER_VALUE            : integer := 0;
    REPLAY_TIMER_VALUE              : integer := 711;
    ACKNAK_TIMER_VALUE              : integer := 237;
    MIN_TS1_COUNT                   : integer := 1024;
    DESKEW_SUPPORT                  : integer := 0;
    VC_SUPPORT                      : integer := 0;
    HOT_PLUG_MESSAGE_ENABLE         : integer := 0;
    TX_SKEW_SUPPORT                 : integer := 0;
    CPL_TIMEOUT_CLK                 : integer := 30000;
    UPDATE_FC_30US_TIMER_CLK        : integer := 7500

  );

  PORT (

  -- Global clock and reset signals
    reset_n  : in std_logic;
    areset_n : in std_logic;
    pclk     : in std_logic;

  -- MAC Layer to PHY Layer signals

    tx_data               : in std_logic_vector((((1+INTERFACE_TYPE)*8*MAX_LINK_WIDTH)-1) downto 0);
    tx_data_k             : in std_logic_vector((((1+INTERFACE_TYPE)*MAX_LINK_WIDTH)-1) downto 0);
    tx_detect_rx_loopback : in std_logic;
    tx_elecidle           : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    tx_compliance         : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_polarity           : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    power_down            : in std_logic_vector(1 downto 0);

  -- PHY Layer to MAC Layer signals

    rx_data     : in std_logic_vector((((1+INTERFACE_TYPE)*8*MAX_LINK_WIDTH)-1) downto 0);
    rx_data_k   : in std_logic_vector((((1+INTERFACE_TYPE)*MAX_LINK_WIDTH)-1) downto 0);
    rx_valid    : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_elecidle : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_status   : in std_logic_vector((3*MAX_LINK_WIDTH-1) downto 0);
    phystatus   : in std_logic;

  -- Monitor configuration inputs

    disable_descrambler              : in std_logic;
    skip_link_training               : in std_logic;
    extended_sync_enable             : in std_logic;
    device_control_register          : in std_logic_vector(15 downto 0);
    device_capabilities_register     : in std_logic_vector(31 downto 0);
    L0s_entry_supported              : in std_logic;
    phy_layer_checks_disable         : in std_logic;
    link_layer_checks_disable        : in std_logic;
    transaction_layer_checks_disable : in std_logic;

  -- VC Configuration

    enable_vc_id : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_0 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_1 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_2 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_3 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_4 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_5 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_6 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_7 : in std_logic_vector(7 downto 0);

    acs_translation_blocking_enable : in std_logic;
    disable_cpl_timeout : in std_logic;
    rate : in std_logic;
    tx_margin : in std_logic_vector (2 downto 0);
    tx_deemph : in std_logic;
    tx_swing : in std_logic

  );

END COMPONENT; -- qvl_pci_express_gen2_pipe_monitor

--------------------------------------------------------------------------------

COMPONENT qvl_pci_express_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    PCI_EXPRESS_DEVICE_TYPE         : integer := 0;
    INTERFACE_TYPE                  : integer := 0;
    MAX_LINK_WIDTH                  : integer := 1;
    DOUBLE_DATA_RATE                : integer := 0;
    MAX_REQUESTS_ADDR_WIDTH         : integer := 5;
    ELECTRICAL_IDLE_VAL             : integer := 0;
    RESERVED_FIELD_CHECK_ENABLE     : integer := 1;
    VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0;
    OVERRIDE_TIMER_VALUE            : integer := 0;
    REPLAY_TIMER_VALUE              : integer := 711;
    ACKNAK_TIMER_VALUE              : integer := 237;
    MIN_TS1_COUNT                   : integer := 1024;
    DESKEW_SUPPORT                  : integer := 0;
    VC_SUPPORT                      : integer := 0;
    HOT_PLUG_MESSAGE_ENABLE         : integer := 0;
    TX_SKEW_SUPPORT                 : integer := 0;
    ENABLE_DATA_PLUS_MINUS_CHECK    : integer := 0

  );

  PORT (

  -- Global clock and reset signals
    reset           : in std_logic;
    areset          : in std_logic;
    tx_clk          : in std_logic;
    tx_symbols_plus  : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    tx_symbols_minus : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    rx_clk          : in std_logic;
    rx_symbols_plus  : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);
    rx_symbols_minus : in std_logic_vector((((1+(INTERFACE_TYPE*9))*MAX_LINK_WIDTH)-1) downto 0);

  -- Monitor configuration inputs

    skip_link_training               : in std_logic;
    device_control_register          : in std_logic_vector(15 downto 0);
    device_capabilities_register     : in std_logic_vector(31 downto 0);
    extended_sync_enable             : in std_logic;
    L0s_entry_supported              : in std_logic;
    phy_layer_checks_disable         : in std_logic;
    link_layer_checks_disable        : in std_logic;
    transaction_layer_checks_disable : in std_logic;

  -- VC Configuration

    enable_vc_id : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_0 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_1 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_2 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_3 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_4 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_5 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_6 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_7 : in std_logic_vector(7 downto 0)
  );

END COMPONENT; -- qvl_pci_express_monitor

COMPONENT qvl_pci_express_pipe_monitor

  GENERIC (

    Constraints_Mode                : integer := 0;
    PCI_EXPRESS_DEVICE_TYPE         : integer := 0;
    MAC_LAYER_SIDE                  : integer := 1;
    INTERFACE_TYPE                  : integer := 0;
    MAX_LINK_WIDTH                  : integer := 1;
    MAX_REQUESTS_ADDR_WIDTH         : integer := 5;
    RESERVED_FIELD_CHECK_ENABLE     : integer := 1;
    VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0;
    OVERRIDE_TIMER_VALUE            : integer := 0;
    REPLAY_TIMER_VALUE              : integer := 711;
    ACKNAK_TIMER_VALUE              : integer := 237;
    MIN_TS1_COUNT                   : integer := 1024;
    DESKEW_SUPPORT                  : integer := 0;
    VC_SUPPORT                      : integer := 0;
    HOT_PLUG_MESSAGE_ENABLE         : integer := 0;
    TX_SKEW_SUPPORT                 : integer := 0

  );

  PORT (

  -- Global clock and reset signals
    reset_n  : in std_logic;
    areset_n : in std_logic;
    pclk     : in std_logic;

  -- MAC Layer to PHY Layer signals

    tx_data               : in std_logic_vector((((1+INTERFACE_TYPE)*8*MAX_LINK_WIDTH)-1) downto 0);
    tx_data_k             : in std_logic_vector((((1+INTERFACE_TYPE)*MAX_LINK_WIDTH)-1) downto 0);
    tx_detect_rx_loopback : in std_logic;
    tx_elecidle           : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    tx_compliance         : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_polarity           : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    power_down            : in std_logic_vector(1 downto 0);

  -- PHY Layer to MAC Layer signals

    rx_data     : in std_logic_vector((((1+INTERFACE_TYPE)*8*MAX_LINK_WIDTH)-1) downto 0);
    rx_data_k   : in std_logic_vector((((1+INTERFACE_TYPE)*MAX_LINK_WIDTH)-1) downto 0);
    rx_valid    : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_elecidle : in std_logic_vector((MAX_LINK_WIDTH-1) downto 0);
    rx_status   : in std_logic_vector((3*MAX_LINK_WIDTH-1) downto 0);
    phystatus   : in std_logic;

  -- Monitor configuration inputs

    disable_descrambler              : in std_logic;
    skip_link_training               : in std_logic;
    extended_sync_enable             : in std_logic;
    device_control_register          : in std_logic_vector(15 downto 0);
    device_capabilities_register     : in std_logic_vector(31 downto 0);
    L0s_entry_supported              : in std_logic;
    phy_layer_checks_disable         : in std_logic;
    link_layer_checks_disable        : in std_logic;
    transaction_layer_checks_disable : in std_logic;

  -- VC Configuration

    enable_vc_id : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_0 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_1 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_2 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_3 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_4 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_5 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_6 : in std_logic_vector(7 downto 0);
    tc_mapped_to_vc_id_7 : in std_logic_vector(7 downto 0)
  );

END COMPONENT; -- qvl_pci_express_pipe_monitor

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  
  COMPONENT qvl_sas_monitor
  
    GENERIC (
  
      -- Set this generic to 1 if the checks in the monitor are to be used 
      -- as constraints for 0-In Search. 
  
      Constraints_Mode : integer := 0;
  
  
  
      -- Configures the monitor to track a initiator/target device or an 
      -- expander/fanout expander device.  Set this generic to 1 to track an 
      -- expander/fanout expander device.  By default the monitor tracks 
      -- initator/target device.
  
      SAS_DEVICE_TYPE : integer := 0;
  
  
  
      -- This generic configures the monitor to either serial or parallel mode. 
      -- Set this generic to 1 if the monitor is instantiated on a 10-bit parallel 
      -- interface. Set this generic to 2, if the monitor is instantiated on a
      -- 20-bit parallel interface. By default the monitor is instantiated on a 
      -- serial interface.
  
      INTERFACE_TYPE : integer := 0;
  
  
  
      -- Configures the active edge of the tx_clk/rx_clk clocks. Set this 
      -- generic to 1 if both edges of tx_clk/rx_clk clocks are active. Set 
      -- this generic to 0 if tx_clk/rx_clk is active on only rising edge. 
      -- By default, tx_clk/rx_clk is active on only rising edge.
  
      DOUBLE_DATA_RATE : integer := 0;
  
  
      -- Configures the rate at which ALIGNs are transmitted after powerup.Set 
      -- this generic to 1 if ALIGNs are transmitted at G2(3.0Gbps) rate. 
      -- By default, ALIGNs are transmitted at G1 (1.5Gbps) rate.
  
      TX_DEVICE_SPEED_RATE : integer := 0;
  
  
  
      -- Configures the rate at which ALIGNs are received after powerup.Set 
      -- this generic to 1 if ALIGNs are received at G2(3.0Gbps) rate. 
      -- By default, ALIGNs are received at G1 (1.5Gbps) rate.
  
      RX_DEVICE_SPEED_RATE : integer := 0;
  
  
  
      -- Configures the idle time period between ALIGN bursts in a COMINIT sequence
      -- The idle time period must be specified in UIs. By default, the idle time 
      -- period is set to 480UIs.
  
      TX_COMINIT_IDLE_TIME : integer := 480;
  
  
  
      -- Configures the idle time period between ALIGN bursts in a COMSAS sequence
      -- The idle time period must be specified in UIs. By default, the idle time 
      -- period is set to 1440UIs.
  
      TX_COMSAS_IDLE_TIME : integer := 1440;
  
  
  
      -- Configures the negation time after a COMINIT sequence. By default the 
      -- negation time is set to 800UIs.
  
      TX_COMINIT_NEGATION_TIME_PERIOD : integer := 800;
  
  
  
      -- Configures the negation time after COMSAS sequence. By default, the 
      -- negation time after COMSAS sequence is set to 2400UIs.
  
      TX_COMSAS_NEGATION_TIME_PERIOD : integer := 2400; 
  
  
  
      -- Specifies the value of the encoded 10B data during electrical idle 
      -- conditions. This generic is applicable only when INTERFACE_TYPE is set 
      -- to 1 (parallel mode of operation). The default value of the  generic is 
      -- the value equivalent to 3FFh, the assumed 10-bit encoded value for 
      -- electrical idle.  In serial mode of operation, the monitor detects 
      -- electrical idle when both D+ and D- inputs are driven to same level.
  
      ELECTRICAL_IDLE_TIME_BIT_PATTERN : integer := 1023;
                       --std_logic_vector(9 downto 0) := 1023; 
                                         --"1111111111";
  
  
  
      -- Specifies the time the transmitter shall transmit D.C. idle between
      -- rates during speed negotiation.  By default, the RATE_CHANGE_DELAY 
      -- value is set to 750000 UIs.
  
      RATE_CHANGE_DELAY : integer := 750000;
  
  
  
      -- Specifies the maximum time during the speed negotiation window for
      -- a transmitter to reply with ALIGN (1).  By default, the 
      -- SPEED_NEGOTIATION_LOCK_TIME value is set to 153600 UIs.
  
      SPEED_NEGOTIATION_LOCK_TIME : integer := 153600;
  
  
  
      -- Specifies time during which ALIGN (0) or ALIGN (1) is transmitted at
      -- each physical link rate during the speed negotiation sequecnce.
      -- By default, the SPEED_NEGOTIATION_TRANSMIT_TIME value is set to
      -- 163840 UIs.
  
      SPEED_NEGOTIATION_TRANSMIT_TIME : integer := 163840;
  
  
  
      -- This generic will determine the maximum rate supported by the device.
      -- If this is set to 1, maximum supported rate is G2.  If this is set to 0,
      -- Maximum supported rate is G1.   Bydefault this is set to 0.
      -- by the TX device. 
  
      TX_MAX_SUPPORTED_RATE : integer := 0;
  
  
  
      -- This generic will determine the maximun rate supported by the device.
      -- If this is set to 1, maximum supported rate is G2.  If this is set to 0,
      -- Maximum supported rate is G1.   Bydefault this is set to 0.
      -- by the RX device.
  
      RX_MAX_SUPPORTED_RATE : integer := 0;
  
  
      -- Configures the monitor to track repeatitive primitive sequences.
      -- Set this generic to 0 to disable the tracking of repeated primitive 
      -- sequences.By default , monitor tracks repetitive primitive sequences.
  
      REPEATED_PRIMITIVE_SEQ : integer := 1;
  
  
  
      -- Configures the monitor to perform the transaction layer checks. Set
      -- this generic to 0 to configure the monitor to disable transport layer
      -- checks.  By default, the transport layer checks are turned on.
  
      TRANSPORT_LAYER_CHECKS_ENABLE : integer := 1;
  
  
  
      -- Configures the time period within which COMINIT sequence must be 
      -- received after transmitting COMINIT sequence.By default, the hot plug 
      -- timeout period is set to 1 milli secs.The values are mentioned in UIs.
  
      HOTPLUG_TIMEOUT_PERIOD : integer := 1499250;
  
  
  
      -- Configures the time period within which COMSAS sequence must be
      -- received after transmitting COMSAS sequence.By default, the comsas
      -- timeout period is set to 13.65 micro secs.The values are mentioned
      -- in UIs.
  
      COMSAS_TIMEOUT_PERIOD : integer := 20480;
  
  
  
      -- Configures the hard reset period. After a  port detects hard 
      -- reset, it should not send any valid primitives within one milli
      -- second. Values are mentioned in UIs.
  
      HARD_RESET_PERIOD : integer := 1499250;
  
  
  
      -- Configures the monitor to perform scrambling. Set this generic to 1 to
      -- configure the monitor to disable scrambling of 8bit data.  By default
      -- monitor performs scrambling of 8bit data.
  
      DISABLE_DESCRAMBLER : integer := 0;
  
  
  
      -- Configures the identification address frame timeout period.  If the 
      -- port transmits identification address frame, it should receive the
      -- same from the other side within one milli second.  Values are
      -- mentioned in UIs.
  
      IDENT_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the break timeout period.  If the port sends break, it
      -- should receive break within one 1 milli second.  Values are mentioned
      -- in UIs.
  
      BREAK_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the open address response timeout period.  After a port
      -- sends an open address frame should receive a response within one
      -- milli second. Values are mentioned in UIs.
  
      OPEN_ADDR_RES_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the credit timeout period.  Port which accepts an open
      -- address frame, should send credit within 1 milli second. Values are
      -- mentioned in UIs.
  
      CREDIT_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the ACK/NAK timeout period. If the port sends an SSP frame, 
      -- it should be acknowledged within one milli second.  Values are
      -- mentioned in UIs.
  
      ACK_NAK_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the Close timeout period.  If the port send close, it
      -- should receive close within one 1 milli second.  Values are mentioned
      -- in UIs.
  
      CLOSE_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the Done timeout period.  If the port send done, it should
      -- receive done within one 1 milli second.  Values are mentioned in UIs.
  
      DONE_TIMEOUT : integer := 1499250;
  
  
  
      -- Configures the monitor to perform the checks during reset sequence.
      -- Set the generic to 1 to configure the monitor to perform the 
      -- reset sequence checks.  By default, reset sequence checks are 
      -- turned off.
  
      PHY_RESET_SEQ_CHECK_ENABLE : integer := 0;
  
  
  
      -- Configures the monitor to perform the check for the reserved values.
      -- Set the generic to 1 to configure the monitor to perform the check.
      -- By default, checks are performed for the reserved values.
  
      RESERVED_FIELD_CHECK_ENABLE : integer := 1;
  
  
  
      -- Generic VENDOR_SPECIFIC_ENCODING_ENABLE = 0 configures the monitor to
      -- allow the usage of vendor specific encodings in the SSP and SMP frames.
  
      VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0;
  
  
  
      -- Configures the receiver's minimum idle time period between ALIGN
      -- bursts in a COMINIT sequence. The idle time period must be specified
      -- in UIs. By default, the idle time period is set to 260UIs.
  
      RX_COMINIT_IDLE_TIME_MIN : integer := 260;
  
  
  
      -- Configures the receiver's maximum idle time period between ALIGN
      -- bursts in a COMINIT sequence. The idle time period must be specified
      -- in UIs. By default, the idle time period is set to 780UIs.
  
      RX_COMINIT_IDLE_TIME_MAX : integer := 780;
  
  
  
      -- Configures the receiver's minimum idle time period between ALIGN
      -- bursts in a COMSAS sequence. The idle time period must be specified
      -- in UIs. By default, the idle time period is set to 780UIs.
  
      RX_COMSAS_IDLE_TIME_MIN : integer := 780;
  
  
  
      -- Configures the receiver's maximum idle time period between ALIGN
      -- bursts in a COMSAS sequence. The idle time period must be specified
      -- in UIs. By default, the idle time period is set to 2360UIs.
  
      RX_COMSAS_IDLE_TIME_MAX : integer := 2360;
  
  
  
      -- Configures the receive negation time after a COMINIT sequence.
      -- By default the negation time is set to 780UIs.
  
      RX_COMINIT_NEGATION_TIME_PERIOD : integer := 780;
  
  
  
      -- Configures the receive negation time after COMSAS sequence. By
      -- default, the negation time after COMSAS sequence is set to 200UIs.
  
      RX_COMSAS_NEGATION_TIME_PERIOD : integer := 2360
  
    );
  
    PORT (
    
      -- Monitor connections
  
      reset : in std_logic;                      
      areset : in std_logic;                      
      tx_clk : in std_logic;                      
      tx_data_plus : in std_logic_vector((10*INTERFACE_TYPE + (INTERFACE_TYPE-1)* (INTERFACE_TYPE-2)/2) - 1 downto 0);
      tx_data_minus : in std_logic_vector((10*INTERFACE_TYPE + (INTERFACE_TYPE-1)* (INTERFACE_TYPE-2)/2) - 1 downto 0);
      tx_idle_signal : in std_logic;                      
      rx_clk : in std_logic;                      
      rx_data_plus : in std_logic_vector((10*INTERFACE_TYPE + (INTERFACE_TYPE-1)* (INTERFACE_TYPE-2)/2) - 1 downto 0);
      rx_data_minus : in std_logic_vector((10*INTERFACE_TYPE + (INTERFACE_TYPE-1)* (INTERFACE_TYPE-2)/2) - 1 downto 0);
      rx_idle_signal : in std_logic;                      
      bypass_reset_sequence : in std_logic;
      start_speed_negotiation : in std_logic                      
  
    );
  
  END COMPONENT; -- qvl_sas_monitor

--------------------------------------------------------------------------------

  COMPONENT qvl_sas_dynamic_timer_values_monitor

    GENERIC (

      -- Set this generic to 1 if the checks in the monitor are to be used
      -- as constraints for 0-In Search.

      Constraints_Mode : integer := 0;



      -- Configures the monitor to track a initiator/target device or an 
      -- expander/fanout expander device.  Set this generic to 1 to track an 
      -- expander/fanout expander device.  By default the monitor tracks 
      -- initator/target device.

      SAS_DEVICE_TYPE : integer := 0;



      -- This generic configures the monitor to either serial or parallel mode. 
      -- Set this generic to 1 if the monitor is instantiated on a 10-bit
      -- parallel interface. Set this generic to 2, if the monitor is
      -- instantiated on a 20-bit parallel interface. By default the monitor
      -- is instantiated on a serial interface.

      INTERFACE_TYPE : integer := 0;



      -- Configures the active edge of the tx_clk/rx_clk clocks. Set this 
      -- generic to 1 if both edges of tx_clk/rx_clk clocks are active. Set 
      -- this generic to 0 if tx_clk/rx_clk is active on only rising edge. 
      -- By default, tx_clk/rx_clk is active on only rising edge.

      DOUBLE_DATA_RATE : integer := 0;



      -- Configures the rate at which ALIGNs are transmitted after powerup.Set 
      -- this generic to 1 if ALIGNs are transmitted at G2(3.0Gbps) rate. 
      -- By default, ALIGNs are transmitted at G1 (1.5Gbps) rate.

      TX_DEVICE_SPEED_RATE : integer := 0;



      -- Configures the rate at which ALIGNs are received after powerup.Set 
      -- this generic to 1 if ALIGNs are received at G2(3.0Gbps) rate. 
      -- By default, ALIGNs are received at G1 (1.5Gbps) rate.

      RX_DEVICE_SPEED_RATE : integer := 0;



      -- Specifies the value of the encoded 10B data during electrical idle 
      -- conditions. This generic is applicable only when INTERFACE_TYPE is set 
      -- to 1 (parallel mode of operation). The default value of the  generic is 
      -- the value equivalent to 3FFh, the assumed 10-bit encoded value for 
      -- electrical idle.  In serial mode of operation, the monitor detects 
      -- electrical idle when both D+ and D- inputs are driven to same level.

      ELECTRICAL_IDLE_TIME_BIT_PATTERN : integer := 1023;



      -- This generic will determine the maximum rate supported by the device.
      -- If this is set to 1, maximum supported rate is G2. If this is set to
      -- 0,Maximum supported rate is G1.   Bydefault this is set to 0.
      -- by the TX device. 

      TX_MAX_SUPPORTED_RATE : integer := 0;



      -- This generic will determine the maximun rate supported by the device.
      -- If this is set to 1, maximum supported rate is G2. If this is set to
      -- 0, Maximum supported rate is G1.   Bydefault this is set to 0.
      -- by the RX device.

      RX_MAX_SUPPORTED_RATE : integer := 0;



      -- Configures the monitor to track repeatitive primitive sequences.
      -- Set this generic to 0 to disable the tracking of repeated primitive 
      -- sequences.By default , monitor tracks repetitive primitive sequences.

      REPEATED_PRIMITIVE_SEQ : integer := 1;



      -- Configures the monitor to perform the transaction layer checks. Set
      -- this generic to 0 to configure the monitor to disable transport layer
      -- checks.  By default, the transport layer checks are turned on.

      TRANSPORT_LAYER_CHECKS_ENABLE : integer := 1;



      -- Configures the monitor to perform scrambling. Set this generic to 1 to
      -- configure the monitor to disable scrambling of 8bit data.  By default
      -- monitor performs scrambling of 8bit data.

      DISABLE_DESCRAMBLER : integer := 0;



      -- Configures the monitor to perform the checks during reset sequence.
      -- Set the generic to 1 to configure the monitor to perform the 
      -- reset sequence checks.  By default, reset sequence checks are 
      -- turned off.

      PHY_RESET_SEQ_CHECK_ENABLE : integer := 0;



      -- Configures the monitor to perform the check for the reserved values.
      -- Set the generic to 1 to configure the monitor to perform the check.
      -- By default, checks are performed for the reserved values.

      RESERVED_FIELD_CHECK_ENABLE : integer := 1;



      -- generic VENDOR_SPECIFIC_ENCODING_ENABLE = 0 configures the monitor to
      -- allow the usage of vendor specific encodings in the SSP and SMP frames.

      VENDOR_SPECIFIC_ENCODING_ENABLE : integer := 0
    );

    PORT (

      -- Monitor connections

      reset : in std_logic;
      areset : in std_logic;
      tx_clk : in std_logic;
      tx_data_plus : in std_logic_vector((10*INTERFACE_TYPE +
                                          (INTERFACE_TYPE-1)*
                                          (INTERFACE_TYPE-2)/2) - 1 downto 0);
      tx_data_minus : in std_logic_vector((10*INTERFACE_TYPE +
                                           (INTERFACE_TYPE-1)*
                                           (INTERFACE_TYPE-2)/2) - 1 downto 0);
      tx_idle_signal : in std_logic;
      rx_clk : in std_logic;
      rx_data_plus : in std_logic_vector((10*INTERFACE_TYPE +
                                          (INTERFACE_TYPE-1)*
                                          (INTERFACE_TYPE-2)/2) - 1 downto 0);
      rx_data_minus : in std_logic_vector((10*INTERFACE_TYPE +
                                           (INTERFACE_TYPE-1)*
                                           (INTERFACE_TYPE-2)/2) - 1 downto 0);
      rx_idle_signal : in std_logic;
      bypass_reset_sequence : in std_logic;
      start_speed_negotiation : in std_logic;
      tx_cominit_idle_time : in std_logic_vector(31 downto 0);
      tx_comsas_idle_time : in std_logic_vector(31 downto 0);
      tx_cominit_neg_time : in std_logic_vector(31 downto 0);
      tx_comsas_neg_time : in std_logic_vector(31 downto 0);
      rate_change_delay : in std_logic_vector(31 downto 0);
      spd_neg_lock_time : in std_logic_vector(31 downto 0);
      spd_neg_transmit_time : in std_logic_vector(31 downto 0);
      hotplug_timeout : in std_logic_vector(31 downto 0);
      comsas_timeout : in std_logic_vector(31 downto 0);
      hard_reset_timeout : in std_logic_vector(31 downto 0);
      ident_frame_timeout : in std_logic_vector(31 downto 0);
      break_timeout : in std_logic_vector(31 downto 0);
      open_addr_res_timeout : in std_logic_vector(31 downto 0);
      credit_timeout : in std_logic_vector(31 downto 0);
      ack_nak_timeout : in std_logic_vector(31 downto 0);
      close_timeout : in std_logic_vector(31 downto 0);
      done_timeout : in std_logic_vector(31 downto 0);
      rx_cominit_idle_time_min : in std_logic_vector(31 downto 0);
      rx_cominit_idle_time_max : in std_logic_vector(31 downto 0); 
      rx_comsas_idle_time_min : in std_logic_vector(31 downto 0);
      rx_comsas_idle_time_max : in std_logic_vector(31 downto 0);
      rx_cominit_neg_time : in std_logic_vector(31 downto 0);
      rx_comsas_neg_time : in std_logic_vector(31 downto 0)
   );
  END COMPONENT; -- qvl_sas_dynamic_timer_values_monitor

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

  COMPONENT qvl_sata_monitor

    GENERIC (

      -- This generic configures the checks in the monitor as constraints
      -- during formal analysis

       Constraints_Mode : integer := 0; 

      -- Interface type (Location of monitor instance)
      -- 0 => Serial interface
      -- 1 => 10B interface

      INTERFACE_TYPE : integer := 0;

      -- This generic configures the type of the DUT the monitor is hooked to
      -- 0 => Host
      -- 1 => Device

      DEVICE_TYPE : integer := 0;

      -- This generic defines the width of the parallel interface
      -- 10 - 10Bits
      -- 20 - 20Bits
      -- 40 - 40Bits

      PARALLEL_DATA_WIDTH : integer := 10;

      -- This generic configures whether data is available on both clock 
      -- edges or on single edge of the clock.
      -- 0 => Single data rate
      -- 1 => Double data rate

      DOUBLE_DATA_RATE : integer := 0;

      -- This generic defines the maximum speed supported by the SATA device
      -- on which the monitor is instantiated.
      -- 0 => GEN1 speed
      -- 1 => GEN2 speed

      MAX_DEV_SPEED : integer := 0;

      -- This generic when set enables Native queued commands

      NCQ_COMMAND_ENABLE : integer := 0;

      -- This generic when set enables legacy queued commands

      LEGACY_QUEUED_COMMAND_ENABLE : integer := 0;

      -- When set this generic indicates that the monitor sits on the host or
      -- device side of the port selector or on the host or device interface
      -- connected to the port selector

      PORT_SELECTOR_ENABLE : integer := 0;

      -- When set this generic indicates that the monitor sits on the host or
      -- device side of the port multiplier or on the host or device interface
      -- connected to the port multiplier

      PORT_MULTIPLIER_ENABLE : integer := 0;

      -- This generic when set enables packet command protocol.

      PACKET_COMMAND_ENABLE : integer := 0;

      -- This generic when set enables the reserved field checking when set 
      -- to "1"

      RESERVED_VALUE_CHECKING_ENABLE : integer := 1;

      -- This generic when set enables power management.
      -- 0 - Power management mode disabled
      -- 1 - Power management mode enabled

      POWER_MGMT_ENABLE : integer := 1;

      -- This generic defines the maximum queue depth for ncq commands.

      MAX_QUEUE_DEPTH : integer := 32;

      -- This generic when set enables Asynchronous signal recovery support.

      ASYNC_SIGNAL_RECOVERY : integer := 0;

      -- This generic configures the retry interval time.
      -- minimum time is 10ms (i.e. 10ms/0.6667ns = 14999250GEN1 clocks)

      RETRY_INTERVAL : integer := 14999250;


      -- This generic when set enables the reserved fis type checking

      RESERVED_FIS_TYPE_ENABLE : integer := 0;

      -- This generic when set enables the Vendor specific fis type checking

      VENDOR_FIS_TYPE_ENABLE : integer := 0;

      -- This generic defines the pattern that indicates electrical IDLE 
      -- condition in case of 10B interface

      ELECTRICAL_IDLE_PATTERN : integer := 0
      );

    PORT (
   
  -- Monitor connections

      areset : in std_logic;
      reset : in std_logic;
      tx_clk : in std_logic;
      tx_data_plus : in std_logic_vector(((PARALLEL_DATA_WIDTH-1)*
                                            INTERFACE_TYPE) downto 0);
      tx_data_minus : in std_logic_vector(((PARALLEL_DATA_WIDTH-1)*
                                            INTERFACE_TYPE) downto 0);
      rx_clk : in std_logic;
      rx_data_plus : in std_logic_vector(((PARALLEL_DATA_WIDTH-1)*
                                            INTERFACE_TYPE) downto 0);
      rx_data_minus : in std_logic_vector(((PARALLEL_DATA_WIDTH-1)*
                                          INTERFACE_TYPE) downto 0);
      scrambling_off : in std_logic;
      bypass_power_on_seq : in std_logic
      );
    
  END COMPONENT; -- qvl_sata_monitor

------------------------------------------------------------------------------

--------------------------------------------------------------------------------

  COMPONENT qvl_sata_sapis_monitor

    GENERIC (

      -- This generic configures the checks in the monitor as constraints
      -- during formal analysis
  
       Constraints_Mode : integer := 0; 
  
      -- This generic when set indicates that the monitor is instantiated on the
      -- Link side of the sapis interface. When set to 0 indicates that the
      -- monitor is instantiated on the PHY side of the SAPIS interface.
  
      LINK_SIDE : integer := 1;
  
      -- This generic configures the type of the DUT the monitor is hooked to
      -- 0 => Host
      -- 1 => Device
  
      DEVICE_TYPE : integer := 0;
  
      -- This generic defines the width of the parallel interface
      -- 10 - 10Bits
      -- 20 - 20Bits
      -- 40 - 40Bits
  
      PARALLEL_DATA_WIDTH : integer := 10;
  
      -- This generic configures whether data is available on both clock 
      -- edges or on single edge of the clock.
      -- 0 => Single data rate
      -- 1 => Double data rate
  
      DOUBLE_DATA_RATE : integer := 1;
  
      -- This generic defines the maximum speed supported by the SATA device
      -- on which monitor is instantiated.
      -- 0 => GEN1 speed
      -- 1 => GEN2 speed
  
      MAX_DEV_SPEED : integer := 0;
  
      -- This generic when set enables Native queued commands
  
      NCQ_COMMAND_ENABLE : integer := 0;
  
      -- This generic when set enables legacy queued commands
  
      LEGACY_QUEUED_COMMAND_ENABLE : integer := 0;
  
      -- When set this generic indicates that the monitor sits on the host or
      -- device side of the port selector or on the host or device interface
      -- connected to the port selector
  
      PORT_SELECTOR_ENABLE : integer := 0;
  
      -- When set this generic indicates that the monitor sits on the host or
      -- device side of the port multiplier or on the host or device interface
      -- connected to the port multiplier
  
      PORT_MULTIPLIER_ENABLE : integer := 0;
  
      -- This generic when set enables packet command protocol.
  
      PACKET_COMMAND_ENABLE : integer := 0;
  
      -- This generic when set enables the reserved field checking when
      -- set to "1"
  
      RESERVED_VALUE_CHECKING_ENABLE : integer := 1;
  
      -- This generic when set enables power management.
      -- 0 - Power management mode disabled
      -- 1 - Power management mode enabled
  
      POWER_MGMT_ENABLE : integer := 1;
  
      -- This generic defines the maximum queue depth for ncq commands.
  
      MAX_QUEUE_DEPTH : integer := 32;
  
      -- This generic when set enables Asynchronous signal recovery support.
  
      ASYNC_SIGNAL_RECOVERY : integer := 0;
  
      -- This generic configures the retry interval time.
      -- minimum time is 10ms (i.e. 10ms/0.6667ns = 14999250GEN1 clocks)
  
      RETRY_INTERVAL : integer := 14999250;
  
  
      -- This generic when set enables the reserved fis type checking
  
      RESERVED_FIS_TYPE_ENABLE : integer := 0;
  
      -- This generic when set enables the Vendor specific fis type checking
  
      VENDOR_FIS_TYPE_ENABLE : integer := 0
  
      );
  
    PORT (
     
    -- Monitor connections
  
      areset : in std_logic;
      reset : in std_logic;
      tbc : in std_logic;
      tx_data: in std_logic_vector(PARALLEL_DATA_WIDTH-1 downto 0);
      tx_enable : in std_logic;
      rbc : in std_logic;
      rx_data: in std_logic_vector(PARALLEL_DATA_WIDTH-1 downto 0);
      rx_data_valid : in std_logic;
      k28_5_detect : in std_logic;
      rx_locked : in std_logic;
      comwake_detect : in std_logic;
      comreset_cominit_detect : in std_logic;
      partial: in std_logic;
      slumber: in std_logic;
      scrambling_off : in std_logic;
      bypass_power_on_seq : in std_logic
      );
  
  END COMPONENT; -- qvl_sata_sapis_monitor

------------------------------------------------------------------------------

------------------------------------------------------------------------------

COMPONENT qvl_usb_1_1_monitor

  GENERIC (
    
     Constraints_Mode  : integer := 0; -- 0in constraint

  -- Generic PORT_TYPE configures the port type which will be tracked by  
  -- the monitor. PORT_TYPE = 0 configures the monitor to track the 
  -- transactions of the downstream port of the Host. PORT_TYPE = 1 
  -- configures the monitor to track the transactions of the upstream port
  -- of Hub. PORT_TYPE = 2 configures the monitor to track the transactions 
  -- of the downstream port of Hub. PORT_TYPE = 3 configures the monitor to
  -- track transactions of upstream port of a function. This information, 
  -- along with the value of generic Constraints_Mode will decide the checks
  -- to be turned into constraints during 0-In Search.
     
     PORT_TYPE  : integer := 0;

  -- Generic NUMBER_OF_ENDPOINTS configures the number of end points 
  -- to be tracked by the monitor. By default, monitor is configured
  -- to track only one end point.

     NUMBER_OF_ENDPOINTS  : integer := 1;

  -- Generic FRAME_INTERVAL_COUNT indicates the number of clock cycles
  -- between two successive SOF packets (USB specification specifies
  -- an interval of 1ms between frames. This time duration needs to be mapped
  -- into number of clock cycles). Typicaly 12000 clock cycles occur in a 
  -- full speed interface. 

     FRAME_INTERVAL_COUNT  : integer := 12000;

  -- Generic SEQUENCE_BIT_TRACKING_ENABLE configures the monitor to
  -- track data toggle synchronization.

     SEQUENCE_BIT_TRACKING_ENABLE  : integer := 1;

  -- Generic PACKET_ISSUE_CHECK_ENABLE configures the monitor to fire
  -- for illegal issue of token, requests. By default monitor fires
  -- for above mentioned conditions. Example : If IN token is issued
  -- to OUT only end point then monitor check fires when this generic
  -- is set to 1. Similarly if undefined requests other than standard
  -- requests, device class requests are issued then monitor checks
  -- fire when this generic is set to 1.

     PACKET_ISSUE_CHECK_ENABLE  : integer := 1;

  -- Generic HUB_SETUP_INTERVAL configures the Hub setup time. this
  -- time is required to enable the low speed ports connected to
  -- low speed ports of the hub. This time is specified interms of
  -- full speed bit times. This generic is valid only when the monitor
  -- is instantiated on ports other than upstream port of the function.

     HUB_SETUP_INTERVAL  : integer := 4;

  -- Generic DISCONNECT_COUNT configures the number of cycles
  -- se0 should be asserted by the device to indicate disconnect.

     DISCONNECT_COUNT  : integer := 20;

  -- Generic CONTROL_XFR_MAX_PKT_SIZE configures the maximum packet size
  -- supported for Control transfers. Allowed values are 8,16,32 or 64. For
  -- low speed devices maximum packet size for control transfer is 8.

     CONTROL_XFR_MAX_PKT_SIZE  : integer := 8;

  -- Generic ISO_XFR_MAX_PKT_SIZE configures the maximum packet size
  -- supported for Isochronous transfers. Low speed devices should not
  -- support Isochronous type end points.

     ISO_XFR_MAX_PKT_SIZE  : integer := 1023;

  -- Generic INTERRUPT_XFR_MAX_PKT_SIZE configures the maximum packet size  
  -- supported for Interrupt transfers. For low speed devices maximum packet   
  -- size for interrupt transfers is 8. 
 
     INTERRUPT_XFR_MAX_PKT_SIZE  : integer := 64; 

  -- Generic INTERRUPT_XFR_LS_MAX_PKT_SIZE configures the maximum packet 
  -- size supported for low speed interrupt end points.

     INTERRUPT_XFR_LS_MAX_PKT_SIZE  : integer := 8;
 
  -- Generic BULK_XFR_MAX_PKT_SIZE configures the maximum packet size
  -- supported for Bulk transfers. Allowed values are 8,16,32 or 64. Low
  -- speed devices should not support bulk transfer type end point.

     BULK_XFR_MAX_PKT_SIZE  : integer := 8
  );

  PORT (
   clock     : in std_logic;
   reset     : in std_logic;
   areset     : in std_logic;
   dp     : in std_logic;
   dm     : in std_logic;
   oe_n     : in std_logic;
   speed     : in std_logic;
   address   : in std_logic_vector(6 downto 0); 
   end_point_config   : in std_logic_vector(NUMBER_OF_ENDPOINTS * 18 - 1  downto 0)
  -- Input end_point_config specifies the configuration details
  -- for each the end point. This port contains all the information
  -- regarding all the end points that needs to tracked by the monitor.
  -- Fallowing encoding scheme should be utilized to specify the 
  -- end point configuration.
  -- End point encoding scheme used for each end point is as follows.
  -- A3 A2 A1 A0 D T2 T1 T0 S9 to S0 is the bit fields of a 18 bit register.
  -- A3 bit is the MSB and S0 bit is the LSB of the 18 bit register.
  -- A3 A2 A1 A0 bits specifies the address of the end point.
  -- T1 T0 bit indicates whether type of the end point. D bit gives the
  -- direction of the end point. D = '0' indicates OUT direction.
  -- D = '1' indicates IN direction.
  -- T2 T1 T0 decoding is as follows.
  -- 0  0  0  ---> Undefined
  -- 0  0  1  ---> Control Transfer
  -- 0  1  0  ---> Interrupt Transfer
  -- 0  1  1  ---> Bulk Transfer
  -- 1  0  0  ---> ISO Transfer.
  -- S9 to S0 specifies the wMaxpacketsize. The maximum packet size
  -- supported by this end point.
  );

END COMPONENT; -- qvl_usb_1_1_monitor
--------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Component declaration for USB 2.0 monitor

COMPONENT qvl_usb_2_0_monitor

  GENERIC (
       Constraints_Mode : integer := 0;
       PORT_TYPE : integer := 0;
       NUMBER_OF_ENDPOINTS : integer := 1;
       FRAME_INTERVAL_COUNT : integer := 60000;
       SEQUENCE_BIT_TRACKING_ENABLE : integer := 1;
       PACKET_ISSUE_CHECK_ENABLE : integer := 1;
       OTG_DEVICE : integer := 0;
       HUB_SETUP_INTERVAL : integer := 4
       );

  PORT (
        clock : in std_logic;
        reset : in std_logic;
        areset : in std_logic;
        dp : in std_logic;
        dm : in std_logic;
        oe_n : in std_logic;
        speed : in std_logic_vector(1 downto 0);
        address : in std_logic_vector(6 downto 0);
        end_point_config : in std_logic_vector((NUMBER_OF_ENDPOINTS * 21)-1 downto 0)
       );

END COMPONENT; -- qvl_usb_2_0_monitor

------------------------------------------------------------------------------

COMPONENT qvl_usb_2_0_utmi_monitor

  GENERIC (
        Constraints_Mode : integer := 0;
        PORT_TYPE : integer := 0;
        UTMI_SIDE : integer := 0;
        BI_DIRECTIONAL : integer := 0;
        DEVICE_SPEED : integer := 0;
        NUMBER_OF_ENDPOINTS : integer := 1;
        FRAME_INTERVAL_COUNT : integer := 7500;
        SEQUENCE_BIT_TRACKING_ENABLE : integer := 1;
        PACKET_ISSUE_CHECK_ENABLE : integer := 1;
        RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN : integer := 5;
        RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX : integer := 24;
        TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN : integer := 6;
        TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX : integer := 37;
        TIME_OUT_COUNT : integer := 800;
        OTG_DEVICE : integer := 0;
        HUB_TURNAR_TIMEOUT_16BIT : integer := 45000;
        HUB_TURNAR_TIMEOUT_8BIT : integer := 90000;
        HUB_CHIRP_TIMEOUT_16BIT : integer := 1800;
        HUB_CHIRP_TIMEOUT_8BIT : integer := 3600;
        TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT : integer := 30000;
        TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT : integer := 15000
          );

   PORT (
         clock : in std_logic;
         reset : in std_logic;
         areset : in std_logic;
         tx_valid : in std_logic;
         data_in_low : in std_logic_vector(7 downto 0);
         tx_valid_h : in std_logic;
         data_in_high : in std_logic_vector(7 downto 0);
         tx_ready : in std_logic;
         rx_valid : in std_logic;
         data_out_low : in std_logic_vector(7 downto 0);
         rx_valid_h : in std_logic;
         data_out_high : in std_logic_vector(7 downto 0);
         rx_active : in std_logic;
         rx_error : in std_logic;
         databus16_8 : in std_logic;
         line_state : in std_logic_vector(1 downto 0);
         xcvr_select : in std_logic;
         term_select : in std_logic;
         op_mode : in std_logic_vector(1 downto 0);
         data_low : in std_logic_vector(7 downto 0);
         data_high : in std_logic_vector(7 downto 0);
         valid_h : in std_logic;
         address : in std_logic_vector(6 downto 0);
         end_point_config : in std_logic_vector((NUMBER_OF_ENDPOINTS * 21 - 1) downto 0)
        );

END COMPONENT; -- qvl_usb_2_0_utmi_monitor

------------------------------------------------------------------------------

COMPONENT qvl_spi4_2_tx_monitor

  GENERIC (

   Constraints_Mode : integer := 0; 
   LINK_SIDE_P : integer := 1; 
   PORTS_COUNT_P : integer := 1; --No. of ports to be tracked.
   LVDS_IO_P : integer := 0; --To select the clocking of FIFO status pattern.
			 --If this generic value is 1, then clocking will 
			 --happen on both edges of tsclk.

   FIFO_VALID_SYNC_OR_TRAINING_DELAY_P : integer := 0;
	      --After reset, No. of clocks, after which SYNC pattern will be 
	      --transmitted on FIFO interface, if LVDS_IO mode is enabled, 
	      --and Training pattern will be transmitted on FIFO interface, 
	      --if LVTTL_IO mode is enabled.

   MAX_CALENDAR_LEN_P : integer := 256;
              --Maximum calendar length. This used to program the width of
	      --the calendar_sequence signal.

   CONTROL_WORD_EXTENSION_ENABLE_P : integer := 0;
	      --To enable/disable the Payload control word extension feature.

   BANDWIDTH_REPROVISIONING_ENABLE_P : integer := 0; 
	      --To enable/disable 'Hit less bandwidth reprovisioning' feature. 

   NARROW_BAND_INTERFACE_ENABLE_P : integer := 0; 
	      --To enable/disable Narrow band interface to support OC-48
	      --interface.

  -- Generic USE_PORTS_TO_CONFIGURE indicates that ports of the monitor
  -- are used to configure the monitor instead of generics. By default,
  -- generics are used to configure the monitor. When set, values on the
  -- ports are used to configure the monitor.

   USE_PORTS_TO_CONFIGURE_P : integer := 0;
   ZI_PORT_ADDR_WIDTH : integer := 32

  );

  PORT (
  
  -- Monitor connections

  tdclk : in std_logic;
  tsclk : in std_logic;
  areset : in std_logic;
  reset : in std_logic; 
  tdat : in std_logic_vector(16 - (12*NARROW_BAND_INTERFACE_ENABLE_P)-1 downto 0);
  tctl : in std_logic; 
  tstat : in std_logic_vector(1 downto 0);
  port_addresses : in std_logic_vector((ZI_PORT_ADDR_WIDTH*PORTS_COUNT_P)-1 downto 0);
  max_burst_1_x : in std_logic_vector(31 downto 0);
  max_burst_2_x : in std_logic_vector(31 downto 0);
  data_max_t_x : in std_logic_vector(31 downto 0);
  calendar_len_x : in std_logic_vector(31 downto 0);
  calendar_m_x : in std_logic_vector(31 downto 0);
  calendar_sequence_x : in std_logic_vector((MAX_CALENDAR_LEN_P*ZI_PORT_ADDR_WIDTH)-1 downto 0);
  l_max_x : in std_logic_vector(31 downto 0);
  data_training_sequences_cnt_x : in std_logic_vector(31 downto 0);
  fifo_max_t_x : in std_logic_vector(31 downto 0);
  max_packet_len_x : in std_logic_vector(31 downto 0);
  min_packet_len_x : in std_logic_vector(31 downto 0);
  max_burst_1_y : in std_logic_vector(31 downto 0);
  max_burst_2_y : in std_logic_vector(31 downto 0);
  data_max_t_y : in std_logic_vector(31 downto 0);
  calendar_len_y : in std_logic_vector(31 downto 0);
  calendar_m_y : in std_logic_vector(31 downto 0);
  calendar_sequence_y : in std_logic_vector((MAX_CALENDAR_LEN_P*ZI_PORT_ADDR_WIDTH)-1 downto 0);
  l_max_y : in std_logic_vector(31 downto 0);
  data_training_sequences_cnt_y : in std_logic_vector(31 downto 0);
  fifo_max_t_y : in std_logic_vector(31 downto 0);
  max_packet_len_y : in std_logic_vector(31 downto 0);
  min_packet_len_y : in std_logic_vector(31 downto 0);
  ports_count : in std_logic_vector(31 downto 0);
  lvds_io : in std_logic;
  control_word_extension_enable : in std_logic;
  bandwidth_reprovisioning_enable : in std_logic;
  fifo_valid_sync_or_training_delay : in std_logic_vector(31 downto 0)

  );

END COMPONENT; --  qvl_spi4_2_tx_monitor

------------------------------------------------------------------------------

COMPONENT qvl_spi4_2_rx_monitor

  GENERIC (
  
     Constraints_Mode : integer := 0;


     LINK_SIDE_P : integer := 1; 


     PORTS_COUNT_P : integer := 1; --No. of ports to be tracked.


     ENABLE_FIFO_STATUS_IF_P : integer := 1; --To enable/disable the FIFO status I/F.


     LVDS_IO_P : integer := 0; --To select the clocking of FIFO status pattern.
			 --If this generic value is 1, then clocking will 
			 --happen on both edges of rsclk.


     FIFO_VALID_SYNC_OR_TRAINING_DELAY_P : integer := 0;
	      --After reset, No. of clocks, after which SYNC pattern will be 
	      --transmitted on FIFO interface, if LVDS_IO mode is enabled, 
	      --and Training pattern will be transmitted on FIFO interface, 
	      --if LVTTL_IO mode is enabled.


     MAX_CALENDAR_LEN_P : integer := 256;
              --Maximum calendar length. This used to program the width of
	      --the calendar_sequence signal.



     CONTROL_WORD_EXTENSION_ENABLE_P : integer := 0;
	      --To enable/disable the Payload control word extension feature.



     BANDWIDTH_REPROVISIONING_ENABLE_P : integer := 0; 
	      --To enable/disable 'Hit less bandwidth reprovisioning' feature. 




     NARROW_BAND_INTERFACE_ENABLE_P : integer := 0; 
	      --To enable/disable Narrow band interface to support OC-48
	      --interface.



  -- Generic USE_PORTS_TO_CONFIGURE indicates that ports of the monitor
  -- are used to configure the monitor instead of generics. By default,
  -- generics are used to configure the monitor. When set, values on the
  -- ports are used to configure the monitor.

     USE_PORTS_TO_CONFIGURE_P : integer := 0;

     ZI_PORT_ADDR_WIDTH : integer := 32

  );

  PORT (
  
  -- Monitor connections

  rdclk : in std_logic;
  rsclk : in std_logic;
  areset : in std_logic;
  reset : in std_logic; 
  rdat : in std_logic_vector(16-(12*NARROW_BAND_INTERFACE_ENABLE_P)-1 downto 0);
  rctl : in std_logic;
  rstat : in std_logic_vector(1 downto 0);
  port_addresses : in std_logic_vector((ZI_PORT_ADDR_WIDTH*PORTS_COUNT_P)-1 downto 0);
  max_burst_1_x : in std_logic_vector(31 downto 0);
  max_burst_2_x : in std_logic_vector(31 downto 0);
  data_max_t_x : in std_logic_vector(31 downto 0);
  calendar_len_x : in std_logic_vector(31 downto 0);
  calendar_m_x : in std_logic_vector(31 downto 0);
  calendar_sequence_x : in std_logic_vector((MAX_CALENDAR_LEN_P*ZI_PORT_ADDR_WIDTH)-1 downto 0);
  l_max_x : in std_logic_vector(31 downto 0);
  data_training_sequences_cnt_x : in std_logic_vector(31 downto 0);
  fifo_max_t_x : in std_logic_vector(31 downto 0);
  max_packet_len_x : in std_logic_vector(31 downto 0);
  min_packet_len_x : in std_logic_vector(31 downto 0);
  max_burst_1_y : in std_logic_vector(31 downto 0);
  max_burst_2_y : in std_logic_vector(31 downto 0); 
  data_max_t_y : in std_logic_vector(31 downto 0);
  calendar_len_y : in std_logic_vector(31 downto 0);   
  calendar_m_y : in std_logic_vector(31 downto 0); 
  calendar_sequence_y : in std_logic_vector((MAX_CALENDAR_LEN_P*ZI_PORT_ADDR_WIDTH)-1 downto 0);
  l_max_y : in std_logic_vector(31 downto 0);  
  data_training_sequences_cnt_y : in std_logic_vector(31 downto 0);
  fifo_max_t_y : in std_logic_vector(31 downto 0);
  max_packet_len_y : in std_logic_vector(31 downto 0); 
  min_packet_len_y : in std_logic_vector(31 downto 0); 
  ports_count : in std_logic_vector(31 downto 0);
  lvds_io : in std_logic;
  control_word_extension_enable : in std_logic;
  bandwidth_reprovisioning_enable : in std_logic;
  fifo_valid_sync_or_training_delay : in std_logic_vector(31 downto 0);
  enable_fifo_status_if : in std_logic

  );

END COMPONENT; -- qvl_spi4_2_rx_monitor

------------------------------------------------------------------------------

END qvl_monitors;
