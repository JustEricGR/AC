//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.
//
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                  TERMS.
//
//                   Questa Verification Library (QVL)
//

/*************************************************************************
*
* PURPOSE     This file is part of Questa Verification Library (QVL).
*
* DESCRIPTION This monitor checks the PCI Express PIPE interface for 
*             compliance with PCI Express Base specification. 
*
* REFERENCES  PCI Express Base Specification, Revision 1.0a, July 22, 2002.
*             PCI Express Base Specification, Revision 1.1, March 28, 2005.
*             PHY Interface for the PCI Express architecture, Version 1.00,
*             June 19, 2003.
*
* INPUTS
*             areset_n                    - Asynchronous reset, active low 
*             reset_n                     - Synchronous reset, active low 
*
*             pclk                        - Parallel interface clock.
*             tx_data                     - Parallel PCI Express data input 
*                                           to the PHY Device.
*             tx_data_k                   - Data/Control signal for symbols 
*                                           on 'tx_data'. 
*             tx_detect_rx_loopback       - Signal which indicates when to
*                                           start receiver detection and 
*                                           loopback.
*             tx_elecidle                 - Signal which indicates when to
*                                           drive electrical idle.
*             tx_compliance               - Signal which indicates when to 
*                                           set the running disparity to 
*                                           -ve, while transmitting the
*                                           compliance pattern.
*             rx_polarity                 - Signal which indicates when to
*                                           perform polarity inversion on 
*                                           the received data.
*             power_down                  - Command which transits the power
*                                           states of the PHY.
*             rx_data                     - Parallel PCI Express data output 
*                                           from the PHY Device.
*             rx_data_k                   - Data/Control signal for symbols 
*                                           on 'rx_data'.
*             rx_valid                    - Signal which indicates that 
*                                           valid data is available on the
*                                           'rx_data'.
*             rx_elecidle                 - Signal which indicates that 
*                                           electrical idle is detected.
*             rx_status                   - Signal that encodes the receiver
*                                           status.
*             phystatus                   - Signal which indicates the
*                                           succesful poer state transitions.
*             disable_descrambler         - When set, disables the
*                                           descrambling.
*             skip_link_training          - When set, the monitor
*                                           does not track the link 
*                                           training sequence. The
*                                           LTSSM state machine is inactive 
*                                           and default link width is maximum
*                                           link width specified by the user.
*                                           Monitor tracks all the training 
*                                           ordered sets as well as  
*                                           other ordered sets. 
*             extended_sync_enable        - Extended Synch bit of the Link
*                                           control register(offset 10h).
*             L0s_entry_supported         - Signal which indicates whether 
*                                           transition to L0s ASPM state is 
*                                           supported. 
*             device_control_register     - Device control register.
*                                           (Off set 08h)
*
*             device_capabilities_register - Device capabilities register.
*                                           (Off set 04h)
*
*             phy_layer_checks_disable    - Disables all the physical layer
*                                           checks.
*
*             link_layer_checks_disable   - Disables all the link layer checks.
*
*             transaction_layer_checks_disable 
*
*                                         - Disables all the transaction layer
*                                           checks.
*             enable_vc_id                - A logic high in a bit enables
*                                           corresponding VC ID
*             tc_mapped_to_vc_id_0        - TC's mapped to VC ID 0
*             tc_mapped_to_vc_id_1        - TC's mapped to VC ID 1
*             tc_mapped_to_vc_id_2        - TC's mapped to VC ID 2
*             tc_mapped_to_vc_id_3        - TC's mapped to VC ID 3
*             tc_mapped_to_vc_id_4        - TC's mapped to VC ID 4
*             tc_mapped_to_vc_id_5        - TC's mapped to VC ID 5
*             tc_mapped_to_vc_id_6        - TC's mapped to VC ID 6
*             tc_mapped_to_vc_id_7        - TC's mapped to VC ID 7
*
* MONITOR INSTANTIATION
*
*       1. In a MAC Layer device : 
*       --------------------------
*
*       +---------------+                 +-----------------+
*       | MAC Layer     |  Transmit       |                 |
*       |       +---+   |  Interface      |                 |
*       |       | M |<--|---------------->|   PHY Layer     |
*       |       | O |   |                 |                 |
*       |       | N |   |                 |                 |
*       |       | I |   |                 |                 |
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 |
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*       2. In an PHY Layer device :
*       ---------------------------
*
*       +---------------+                 +-----------------+
*       |  MAC Layer    |  Transmit       | PHY Layer       |
*       |               |  Interface      |  +---+          |
*       |               |---------------->|->| M |          |
*       |               |                 |  | O |          |
*       |               |                 |  | N |          |
*       |               |                 |  | I |          |
*       |               |  Receive        |  | T |          |
*       |               |  Interface      |  | O |          |
*       |               |<----------------|->| R |          |
*       |               |                 |  +---+          |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*     Last Modified Data : Sep 30, 2005 
*
**************************************************************************/
`include "std_qvl_defines.h"

`qvlmodule qvl_pci_express_pipe_monitor (
                                 reset_n,
                                 areset_n,
                                 pclk,

                                 // MAC Layer to PHY Layer signals
                                 tx_data,
                                 tx_data_k,
                                 tx_detect_rx_loopback,
                                 tx_elecidle,
                                 tx_compliance,
                                 rx_polarity,
                                 power_down,

                                 // PHY Layer to MAC Layer signals

                                 rx_data,
                                 rx_data_k,
                                 rx_valid,
                                 rx_elecidle,
                                 rx_status,
                                 phystatus,

                                 // Monitor configuration inputs
         
                                 disable_descrambler,
                                 skip_link_training,
                                 extended_sync_enable,
                                 device_control_register,
                                 device_capabilities_register,
                                 L0s_entry_supported,
                                 phy_layer_checks_disable,
                                 link_layer_checks_disable,
                                 transaction_layer_checks_disable,

                                 // VC Configuration

                                 enable_vc_id,
                                 tc_mapped_to_vc_id_0,
                                 tc_mapped_to_vc_id_1,
                                 tc_mapped_to_vc_id_2,
                                 tc_mapped_to_vc_id_3,
                                 tc_mapped_to_vc_id_4,
                                 tc_mapped_to_vc_id_5,
                                 tc_mapped_to_vc_id_6,
                                 tc_mapped_to_vc_id_7
                                 );

  // Parameter Constraints_Mode = 1, will configure some checks in this
  // monitor as constraints during 0-In Search.
 
  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter PCI_EXPRESS_DEVICE_TYPE specifies the device type where the 
  // monitor is instantiated. This parameter has to be set based on the 
  // PCI Express device in which monitor is instantiated.
  // 
  // Parameter value         Device
  //     0                   PCI Express end point.
  //     1                   Legacy PCI Express end point.
  //     4                   PCI Express Root Complex.
  //     5                   PCI Express switch, upstream port.
  //     6                   PCI Express switch, downstream port.
  //     7                   PCI Express to PCI/PCI-X bridge.
  //
  // By default, monitor is instantiated on the PCI Express end point
  // This information along with the Constraints_Mode will decide which checks
  // are to be turned into constraints during 0-In Search.
 
  parameter PCI_EXPRESS_DEVICE_TYPE = 0;
  wire [31:0] pw_PCI_EXPRESS_DEVICE_TYPE = PCI_EXPRESS_DEVICE_TYPE;

  // Parameter MAC_LAYER_SIDE configures the device where the monitor is 
  // instantiated. Set this parameter to 1 if the monitor is instantiated 
  // on the MAC_LAYER. By default, monitor is instantiated on the PHY_LAYER.

  parameter MAC_LAYER_SIDE = 1;
  wire [31:0] pw_MAC_LAYER_SIDE = MAC_LAYER_SIDE;

  // Parameter INTERFACE_TYPE specifies whether the PIPE interface is 16 bits
  // or 8 bits. Set this to 1 if the PIPE interface is 16 bits. By default 
  // the monitor is configured for 8 bit PIPE interface.

  parameter INTERFACE_TYPE = 0; 
  wire [31:0] pw_INTERFACE_TYPE = INTERFACE_TYPE;

  // Parameter MAX_LINK_WIDTH specifies the maximum width supported by the
  // PCI Express link. The link widths supported are 1,2,4,8,12,16 and 32.

  parameter MAX_LINK_WIDTH = 1;                                            
  wire [31:0] pw_MAX_LINK_WIDTH = MAX_LINK_WIDTH;

  // Parameter MAX_REQUESTS_ADDR_WIDTH specifies the number of address bits
  // required to address the outstanding requests. This parameter in turn
  // configures the maximum number of outstanding requests. By default, the
  // maximum number of outstanding requests can be 32.
 
  parameter MAX_REQUESTS_ADDR_WIDTH = 5;
  wire [31:0] pw_MAX_REQUESTS_ADDR_WIDTH = MAX_REQUESTS_ADDR_WIDTH;

  // Parameter RESERVED_FIELD_CHECK_ENABLE configures the monitor to track the
  // reserved field of the transaction layer packets (TLPs), Data link layer
  // packets and other reserved fields. Set this parameter to 1 if the monitor
  // has to track for any non zero value in the reserved fields. By default,
  // the monitor does not tracks for existence of non zero value in the reserved
  // field.

  parameter RESERVED_FIELD_CHECK_ENABLE = 1;
  wire [31:0] pw_RESERVED_FIELD_CHECK_ENABLE = RESERVED_FIELD_CHECK_ENABLE;

  // Parameter VENDOR_SPECIFIC_ENCODING_ENABLE = 0 configures the monitor to
  // allow the usage of vendor specific encodings in the DLL packet type as
  // well as the vendor specific message codes.

  parameter VENDOR_SPECIFIC_ENCODING_ENABLE = 0;
  wire [31:0] pw_VENDOR_SPECIFIC_ENCODING_ENABLE = 
                                             VENDOR_SPECIFIC_ENCODING_ENABLE;

  parameter OVERRIDE_TIMER_VALUE = 0;
  wire [31:0] pw_OVERRIDE_TIMER_VALUE = OVERRIDE_TIMER_VALUE;

  parameter REPLAY_TIMER_VALUE = 711;
  wire [31:0] pw_REPLAY_TIMER_VALUE = REPLAY_TIMER_VALUE;

  parameter ACKNAK_TIMER_VALUE = 237;
  wire [31:0] pw_ACKNAK_TIMER_VALUE = ACKNAK_TIMER_VALUE;

  // Parameter MIN_TS1_COUNT configures the minimum number of TS1 ordered sets
  // that must be transmitted before transitioning into Polling.Configuration
  // state from Polling.active state.

  parameter MIN_TS1_COUNT = 1024;
  wire [31:0] pw_MIN_TS1_COUNT = MIN_TS1_COUNT;

  // Parameter DESKEW_SUPPORT configures the monitor to support multi lane
  // deskew on the receive side. By default, multi lane deskew is not 
  // supported.

  parameter DESKEW_SUPPORT = 0;
  wire [31:0] pw_DESKEW_SUPPORT = DESKEW_SUPPORT;

  // Parameter VC_SUPPORT configures the TC/VC mapping.
  // By default, only VC0 is supported and all the TC's are mapped to VC0.
  // Set this parameter to 1, to support all the VC's and one to one
  // mapping between TC and VC. I,e TC0/VC0, TC1/VC1, TC2/VC2 ....
  // Set this parameter to 2, to enable required VC's and to specify the TC/VC
  // mapping through ports.

  parameter VC_SUPPORT = 0;
  wire [31:0] pw_VC_SUPPORT = VC_SUPPORT;

  // Parameter HOT_PLUG_MESSAGE_ENABLE allows hot plug signaling messages.
  // By default, monitor does not allow the transmission of hot plug
  // signaling messages as per PCIE 1.1 specification.

  parameter HOT_PLUG_MESSAGE_ENABLE = 0;

  // Parameter TX_SKEW_SUPPORT configures the monitor to support skew on
  // transmit lanes. By default, skew on transmit lanes is not supported.

  parameter TX_SKEW_SUPPORT = 0;

  // Additional gen1 code start
  // Parameter CPL_TIMEOUT_CLK configures the completion timeout value of monitor.
  parameter CPL_TIMEOUT_CLK = 30000;
  wire [31:0] pw_CPL_TIMEOUT_CLK = CPL_TIMEOUT_CLK;
  // 30us update fc timer is 30us/4ns = 7500 clk for 8-bit PIPE and 3750 clk for 16-bit PIPE
  parameter UPDATE_FC_30US_TIMER_CLK = (INTERFACE_TYPE == 0) ? 7500 : 3750;
  wire [31:0] pw_UPDATE_FC_30US_TIMER_CLK = UPDATE_FC_30US_TIMER_CLK;
  // Additional gen1 code end

  //----------------------------------------------------------------
  // Internal parameters for PIPE
  //----------------------------------------------------------------

  // All the modules operate in DDR mode when the PIPE interface is
  // 16 bits wide. In 8 bit mode of operation the PIPE interface is
  // always uses rising edge.

  parameter ZI_DOUBLE_DATA_RATE  = (INTERFACE_TYPE == 1) ? 1 : 0;
  wire [31:0] pw_DOUBLE_DATA_RATE = ZI_DOUBLE_DATA_RATE;

  parameter ZI_PORT_WIDTH = (INTERFACE_TYPE == 1) ?
                    (2 * 8 * MAX_LINK_WIDTH) : (8 * MAX_LINK_WIDTH);
  parameter ZI_D_OR_K_PORT_WIDTH = (INTERFACE_TYPE == 1) ?
                    (2 * MAX_LINK_WIDTH) : MAX_LINK_WIDTH;

  parameter ZI_ELECTRICAL_IDLE_VAL = 0;

  parameter PHY_LAYER_CONSTRAINT =
                   (Constraints_Mode == 1 && MAC_LAYER_SIDE == 0);
  parameter MAC_LAYER_CONSTRAINT =
                   (Constraints_Mode == 1 && MAC_LAYER_SIDE == 1);

  
  //----------------------------------------------------------------

  // Input declarations 

  input reset_n; // Global synchronous reset signal
  input areset_n; // Global asynchronous reset signal
  input pclk; // Parallel interface lock

  // MAC Layer to PHY layer signals

  input [ZI_PORT_WIDTH - 1 :0] tx_data;
  input [ZI_D_OR_K_PORT_WIDTH - 1:0] tx_data_k;
  input tx_detect_rx_loopback;
  input [MAX_LINK_WIDTH - 1:0] tx_elecidle;
  input [MAX_LINK_WIDTH - 1:0] tx_compliance;
  input [MAX_LINK_WIDTH - 1:0] rx_polarity; 
  input [1:0] power_down;

  // PHY Layer to MAC layer signals

  input [ZI_PORT_WIDTH - 1 :0] rx_data;
  input [ZI_D_OR_K_PORT_WIDTH - 1 :0] rx_data_k;
  input [MAX_LINK_WIDTH - 1:0] rx_valid;
  input [MAX_LINK_WIDTH - 1:0] rx_elecidle;
  input [(3*MAX_LINK_WIDTH) - 1 :0] rx_status;
  input phystatus;
  input disable_descrambler;
  input skip_link_training;
  input extended_sync_enable;
  input L0s_entry_supported;
  input [15:0] device_control_register;
  input [31:0] device_capabilities_register;
  input phy_layer_checks_disable;
  input link_layer_checks_disable;
  input transaction_layer_checks_disable;

  // VC Configuration

  input [7:0] enable_vc_id;
  input [7:0] tc_mapped_to_vc_id_0;
  input [7:0] tc_mapped_to_vc_id_1;
  input [7:0] tc_mapped_to_vc_id_2;
  input [7:0] tc_mapped_to_vc_id_3;
  input [7:0] tc_mapped_to_vc_id_4;
  input [7:0] tc_mapped_to_vc_id_5;
  input [7:0] tc_mapped_to_vc_id_6;
  input [7:0] tc_mapped_to_vc_id_7;

  wire  reset_n_sampled;
  wire  areset_n_sampled; 
  wire  [ZI_PORT_WIDTH - 1 :0] tx_data_sampled;
  wire  [ZI_D_OR_K_PORT_WIDTH - 1:0] tx_data_k_sampled;
  wire  tx_detect_rx_loopback_sampled;
  wire  [MAX_LINK_WIDTH - 1:0] tx_elecidle_sampled;
  wire  [MAX_LINK_WIDTH - 1:0] tx_compliance_sampled;
  wire  [MAX_LINK_WIDTH - 1:0] rx_polarity_sampled; 
  wire  [1:0] power_down_sampled;
  wire  [ZI_PORT_WIDTH - 1 :0] rx_data_sampled;
  wire  [ZI_D_OR_K_PORT_WIDTH - 1 :0] rx_data_k_sampled;
  wire  [MAX_LINK_WIDTH - 1:0] rx_valid_sampled;
  wire  [MAX_LINK_WIDTH - 1:0] rx_elecidle_sampled;
  wire  [(3*MAX_LINK_WIDTH) - 1 :0] rx_status_sampled;
  wire  phystatus_sampled;
  wire  disable_descrambler_sampled;
  wire  skip_link_training_sampled;
  wire  extended_sync_enable_sampled;
  wire  L0s_entry_supported_sampled;
  wire  [15:0] device_control_register_sampled;
  wire  [31:0] device_capabilities_register_sampled;
  wire  phy_layer_checks_disable_sampled;
  wire  link_layer_checks_disable_sampled;
  wire  transaction_layer_checks_disable_sampled;
  wire  [7:0] enable_vc_id_sampled;
  wire  [7:0] tc_mapped_to_vc_id_0_sampled;
  wire  [7:0] tc_mapped_to_vc_id_1_sampled;
  wire  [7:0] tc_mapped_to_vc_id_2_sampled;
  wire  [7:0] tc_mapped_to_vc_id_3_sampled;
  wire  [7:0] tc_mapped_to_vc_id_4_sampled;
  wire  [7:0] tc_mapped_to_vc_id_5_sampled;
  wire  [7:0] tc_mapped_to_vc_id_6_sampled;
  wire  [7:0] tc_mapped_to_vc_id_7_sampled;

  assign `QVL_DUT2CHX_DELAY  reset_n_sampled       = reset_n;
  assign `QVL_DUT2CHX_DELAY  areset_n_sampled      = areset_n; 
  assign `QVL_DUT2CHX_DELAY  tx_data_sampled       = tx_data;
  assign `QVL_DUT2CHX_DELAY  tx_data_k_sampled     = tx_data_k;
  assign `QVL_DUT2CHX_DELAY  tx_detect_rx_loopback_sampled = tx_detect_rx_loopback;
  assign `QVL_DUT2CHX_DELAY  tx_elecidle_sampled   = tx_elecidle;
  assign `QVL_DUT2CHX_DELAY  tx_compliance_sampled = tx_compliance;
  assign `QVL_DUT2CHX_DELAY  rx_polarity_sampled   = rx_polarity; 
  assign `QVL_DUT2CHX_DELAY  power_down_sampled    = power_down;
  assign `QVL_DUT2CHX_DELAY  rx_data_sampled       = rx_data;
  assign `QVL_DUT2CHX_DELAY  rx_data_k_sampled     = rx_data_k;
  assign `QVL_DUT2CHX_DELAY  rx_valid_sampled      = rx_valid;
  assign `QVL_DUT2CHX_DELAY  rx_elecidle_sampled   = rx_elecidle;
  assign `QVL_DUT2CHX_DELAY  rx_status_sampled     = rx_status;
  assign `QVL_DUT2CHX_DELAY  phystatus_sampled     = phystatus;

  assign `QVL_DUT2CHX_DELAY  disable_descrambler_sampled       = disable_descrambler;
  assign `QVL_DUT2CHX_DELAY  skip_link_training_sampled        = skip_link_training;
  assign `QVL_DUT2CHX_DELAY  extended_sync_enable_sampled      = extended_sync_enable;
  assign `QVL_DUT2CHX_DELAY  L0s_entry_supported_sampled       = L0s_entry_supported;
  assign `QVL_DUT2CHX_DELAY  device_control_register_sampled   = device_control_register;
  assign `QVL_DUT2CHX_DELAY  device_capabilities_register_sampled = device_capabilities_register;
  assign `QVL_DUT2CHX_DELAY  phy_layer_checks_disable_sampled  = phy_layer_checks_disable;
  assign `QVL_DUT2CHX_DELAY  link_layer_checks_disable_sampled = link_layer_checks_disable;
  assign `QVL_DUT2CHX_DELAY  transaction_layer_checks_disable_sampled = transaction_layer_checks_disable;
  assign `QVL_DUT2CHX_DELAY  enable_vc_id_sampled         = enable_vc_id;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_0_sampled = tc_mapped_to_vc_id_0;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_1_sampled = tc_mapped_to_vc_id_1;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_2_sampled = tc_mapped_to_vc_id_2;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_3_sampled = tc_mapped_to_vc_id_3;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_4_sampled = tc_mapped_to_vc_id_4;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_5_sampled = tc_mapped_to_vc_id_5;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_6_sampled = tc_mapped_to_vc_id_6;
  assign `QVL_DUT2CHX_DELAY  tc_mapped_to_vc_id_7_sampled = tc_mapped_to_vc_id_7;
qvl_pci_express_pipe_logic
    #(.Constraints_Mode(Constraints_Mode),
      .PCI_EXPRESS_DEVICE_TYPE(PCI_EXPRESS_DEVICE_TYPE),
      .MAC_LAYER_SIDE(MAC_LAYER_SIDE),
      .INTERFACE_TYPE(INTERFACE_TYPE), 
      .MAX_LINK_WIDTH(MAX_LINK_WIDTH),                                            
      .MAX_REQUESTS_ADDR_WIDTH(MAX_REQUESTS_ADDR_WIDTH),
      .ZI_ELECTRICAL_IDLE_VAL(ZI_ELECTRICAL_IDLE_VAL),
      .RESERVED_FIELD_CHECK_ENABLE(RESERVED_FIELD_CHECK_ENABLE),
      .VENDOR_SPECIFIC_ENCODING_ENABLE(VENDOR_SPECIFIC_ENCODING_ENABLE),
      .OVERRIDE_TIMER_VALUE(OVERRIDE_TIMER_VALUE),
      .REPLAY_TIMER_VALUE(REPLAY_TIMER_VALUE),
      .ACKNAK_TIMER_VALUE(ACKNAK_TIMER_VALUE),
      .MIN_TS1_COUNT(MIN_TS1_COUNT),
      .DESKEW_SUPPORT(DESKEW_SUPPORT),
      .VC_SUPPORT(VC_SUPPORT),
      .HOT_PLUG_MESSAGE_ENABLE(HOT_PLUG_MESSAGE_ENABLE),
      .TX_SKEW_SUPPORT(TX_SKEW_SUPPORT),
      .ZI_DOUBLE_DATA_RATE(ZI_DOUBLE_DATA_RATE),
      .PCI_EXPRESS_GEN2(0), // Gen2 is disabled
      .CPL_TIMEOUT_CLK(CPL_TIMEOUT_CLK),
      .UPDATE_FC_30US_TIMER_CLK(UPDATE_FC_30US_TIMER_CLK)
     )
qvl_pciexpress_pipe (
               .reset_n(reset_n_sampled),
               .areset_n(areset_n_sampled),
               .pclk(pclk),
               .tx_data(tx_data_sampled),
               .tx_data_k(tx_data_k_sampled),
               .tx_detect_rx_loopback(tx_detect_rx_loopback_sampled),
               .tx_elecidle(tx_elecidle_sampled),
               .tx_compliance(tx_compliance_sampled),
               .rx_polarity(rx_polarity_sampled), 
               .power_down(power_down_sampled),
               .rx_data(rx_data_sampled),
               .rx_data_k(rx_data_k_sampled),
               .rx_valid(rx_valid_sampled),
               .rx_elecidle(rx_elecidle_sampled),
               .rx_status(rx_status_sampled),
               .phystatus(phystatus_sampled),
               .rate(1'b0),    // gen2 signal 
               .tx_margin(3'b0), // gen2 signal 
               .tx_deemph(1'b0), // gen2 signal 
               .tx_swing(1'b0),  // gen2 signal 
               .disable_descrambler(disable_descrambler_sampled),
               .skip_link_training(skip_link_training_sampled),
               .extended_sync_enable(extended_sync_enable_sampled),
               .L0s_entry_supported(L0s_entry_supported_sampled),
               .device_control_register(device_control_register_sampled),
               .device_capabilities_register(device_capabilities_register_sampled),
               .acs_translation_blocking_enable(1'b0),    // gen2 signal
               .disable_cpl_timeout(1'b0),           
               .phy_layer_checks_disable(phy_layer_checks_disable_sampled),
               .link_layer_checks_disable(link_layer_checks_disable_sampled),
               .transaction_layer_checks_disable(transaction_layer_checks_disable_sampled),
               .enable_vc_id(enable_vc_id_sampled),

               .tc_mapped_to_vc_id_0(tc_mapped_to_vc_id_0_sampled),
               .tc_mapped_to_vc_id_1(tc_mapped_to_vc_id_1_sampled),
               .tc_mapped_to_vc_id_2(tc_mapped_to_vc_id_2_sampled),
               .tc_mapped_to_vc_id_3(tc_mapped_to_vc_id_3_sampled),
               .tc_mapped_to_vc_id_4(tc_mapped_to_vc_id_4_sampled),
               .tc_mapped_to_vc_id_5(tc_mapped_to_vc_id_5_sampled),
               .tc_mapped_to_vc_id_6(tc_mapped_to_vc_id_6_sampled),
               .tc_mapped_to_vc_id_7(tc_mapped_to_vc_id_7_sampled)
             );

`qvlendmodule // end of qvl_pci_express_pipe_monitor
