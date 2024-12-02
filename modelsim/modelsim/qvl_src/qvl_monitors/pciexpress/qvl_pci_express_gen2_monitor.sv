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
* DESCRIPTION This monitor checks the PCI Express interface for compliance
*             with PCI Express Base specification. 
*
* REFERENCES  PCI Express Base Specification, Revision 1.0, July 22, 2002.
*             PCI Express Base Specification, Revision 1.0a, April 15,2003.
*             PCI Express Base Specification, Revision 1.1, March 28, 2005.
*
* INPUTS
*             areset                      - Asynchronous reset, active high
*             reset                       - Synchronous reset, active high
*
*             tx_clk                      - Transmit clock.
*             tx_symbols_plus             - Transmit symbols, D+ input.
*             tx_symbols_minus            - Transmit symbols, D- input.
*                                           This input is applicable only
*                                           in serial mode of operation.
*
*             rx_clk                      - Receive clock.
*             rx_symbols_plus             - Receive symbols, D+ input.
*             rx_symbols_minus            - Receive symbols, D- input. 
*                                           This input is applicable only 
*                                           in serial mode of operation.
*       
*             skip_link_training          - When set, the monitor
*                                           does not track the link 
*                                           training sequence. The
*                                           LTSSM state machine is inactive 
*                                           and default link width is maximum
*                                           link width specified by the user.
*                                           Monitor tracks all the training 
*                                           ordered sets as well as  
*                                           other ordered sets. 
*
*             extended_sync_enable       - Extended Synch bit of the Link
*                                           control register(offset 10h).
*
*             L0s_entry_supported        - Signal which indicates whether
*                                          transition to L0s ASPM state is
*                                          supported. 
*         
*             device_control_register    - Device control register.
*                                          (Off set 08h)
*
*             device_capabilities_register - Device capabilities register.
*                                          (Off set 04h)
*
*             phy_layer_checks_disable   - Disables all the physical layer
*                                          checks.
*
*             link_layer_checks_disable  - Disables all the link layer checks.
*
*             transaction_layer_checks_disable 
*
*                                        - Disables all the transaction layer
*                                          checks.
*
*             enable_vc_id                - A logic high in a bit enables
*                                           corresponding VC ID
*
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
*       1. In a Root complex 
*       --------------------
*
*       +---------------+                 +-----------------+
*       | ROOT COMPLEX  |  Transmit       |                 |
*       |       +---+   |  Interface      |                 |
*       |       | M |<--|---------------->|   END POINT,    |
*       |       | O |   |                 |   SWITCH,       |
*       |       | N |   |                 |      OR         |
*       |       | I |   |                 |   BRIDGE        |
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 |
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*       2. In an End Point :
*       --------------------
*
*       Note : The end point can be a PCI Express end point or legacy end
*              point or a PCI Express/PCI X bridge.
*
*       +---------------+                 +-----------------+
*       |  END POINT    |  Transmit       |                 |
*       |       +---+   |  Interface      |                 |
*       |       | M |<--|---------------->|   ROOT COMPLEX  |
*       |       | O |   |                 |      OR         |
*       |       | N |   |                 |    SWITCH       |
*       |       | I |   |                 |                 |
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 |
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*       3. In a Switch :  
*       ----------------
*
*       Monitor instantiated in the downstream port of the switch.
*
*       +---------------+                 +-----------------+ 
*       | SWICTH        |  Transmit       |                 |
*       |       +---+   |  Interface      |                 | 
*       |       | M |<--|---------------->|   END POINT     |
*       |       | O |   |                 |     OR          | 
*       |       | N |   |                 |   BRIDGE        |
*       |       | I |   |                 |                 | 
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 | 
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 | 
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*       Monitor instantiated in the upstream port of the switch.
*
*       +---------------+                 +-----------------+  
*       | SWICTH        |  Transmit       |                 | 
*       |       +---+   |  Interface      |                 |  
*       |       | M |<--|---------------->|   ROOT COMPLEX  |
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
* LAST MODIFIED DATE : Sep 30, 2005 
*
**************************************************************************/
`include "std_qvl_defines.h"

`qvlmodule qvl_pci_express_gen2_monitor (
				 reset,
				 areset,
				 tx_clk,
				 tx_symbols_plus,
                                 tx_symbols_minus,
				 rx_clk,
				 rx_symbols_plus,
                                 rx_symbols_minus,
                                 skip_link_training,
				 extended_sync_enable,
				 device_control_register,
				 device_capabilities_register,
				 L0s_entry_supported,
				 acs_translation_blocking_enable, // Gen2 pin
				 disable_cpl_timeout,	 
				 phy_layer_checks_disable,
				 link_layer_checks_disable,
				 transaction_layer_checks_disable,
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

  // Parameter INTERFACE_TYPE specifies whether the input to the PCI Express
  // device is serial 10B symbols or parallel 10B symbols. 
  // Set this to 1 if the input to the PCI Express device is parallel 10B
  // symbols. By default, the input to the PCI Express device is serial 10B
  // symbols.

  parameter INTERFACE_TYPE = 0; 
  wire [31:0] pw_INTERFACE_TYPE = INTERFACE_TYPE;

  // Parameter MAX_LINK_WIDTH specifies the maximum width supported by the
  // PCI Express link. The link widths supported are 1,2,4,8,12,16 and 32.

  parameter MAX_LINK_WIDTH = 1;                                            
  wire [31:0] pw_MAX_LINK_WIDTH = MAX_LINK_WIDTH;

  // Parameter DOUBLE_DATA_RATE specifies the active edge of the tx_clk/rx_clk.
  // Set this parameter to 1 if tx_clk/rx_clk is active on both the edges.
  // Set this parameter to 0 if tx_clk/rx_clk is active on only rising edge.
  // By default, tx_clk/rx_clk is active on only one edge.

  parameter DOUBLE_DATA_RATE = 0;
  wire [31:0] pw_DOUBLE_DATA_RATE = DOUBLE_DATA_RATE;

  // Parameter MAX_REQUESTS_ADDR_WIDTH specifies the number of address bits
  // required to address the outstanding requests. This parameter in turn
  // configures the maximum number of outstanding requests. By default, the
  // maximum number of outstanding requests can be 32.
 
  parameter MAX_REQUESTS_ADDR_WIDTH = 5;
  wire [31:0] pw_MAX_REQUESTS_ADDR_WIDTH = MAX_REQUESTS_ADDR_WIDTH;

  // Parameter ELECTRICAL_IDLE_VAL specifies the 10 bit value which
  // indicates the electrical idle condition of the bus. This 10 bit
  // value specifies that the PCI Express bus is in electrical idle.
  // By default, a bit pattern of '0000000000' is considered to be electrical
  // idle condition.  
 
  parameter ELECTRICAL_IDLE_VAL = 0;
  wire [31:0] pw_ELECTRICAL_IDLE_VAL = ELECTRICAL_IDLE_VAL;
  
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

  // Parameter ENABLE_DATA_PLUS_MINUS_CHECK configures the monitor to
  // check whether the symbol_data_plus and symbol_data_minus signals
  // are properly hooked up or not. By default, this check is not done.
  // When properly hooked up, the symbol_data_plus will be either 
  // equal to symbol_data_minus or complementary of symbol_data_minus.

  parameter ENABLE_DATA_PLUS_MINUS_CHECK = 0;

  // Additional gen1 code start
  // Parameter CPL_TIMEOUT_CLK configures the completion timeout value of monitor.
  parameter CPL_TIMEOUT_CLK = 30000;
  wire [31:0] pw_CPL_TIMEOUT_CLK = CPL_TIMEOUT_CLK;
  // 30us update fc timer is 30us/.4ns = 75000 clk for 1 bit serial and 7500 clk for 10 bit parallel interface
  parameter UPDATE_FC_30US_TIMER_CLK = (INTERFACE_TYPE == 0) ? 75000 : 7500;
  wire [31:0] pw_UPDATE_FC_30US_TIMER_CLK = UPDATE_FC_30US_TIMER_CLK;
  // Additional gen1 code end

  parameter ZI_PORT_WIDTH = (INTERFACE_TYPE == 0) ? MAX_LINK_WIDTH :
			    10 * MAX_LINK_WIDTH;

  // Input declarations 

  input reset; // Global synchronous reset signal
  input areset; // Global asynchronous reset signal
  input tx_clk; // Transmit interface clock
  input [ZI_PORT_WIDTH - 1 :0] tx_symbols_plus;
  input [ZI_PORT_WIDTH - 1 :0] tx_symbols_minus;  
  input rx_clk; // Receive clock
  input [ZI_PORT_WIDTH - 1 :0] rx_symbols_plus;
  input [ZI_PORT_WIDTH - 1 :0] rx_symbols_minus;

  input skip_link_training;
  input [15:0] device_control_register;
  input [31:0] device_capabilities_register;
  input extended_sync_enable;
  input L0s_entry_supported;
  input acs_translation_blocking_enable; // Gen2 pin
  input disable_cpl_timeout; // Gen2 pin
  input phy_layer_checks_disable;
  input link_layer_checks_disable;
  input transaction_layer_checks_disable;

  input [7:0] enable_vc_id;
  input [7:0] tc_mapped_to_vc_id_0;
  input [7:0] tc_mapped_to_vc_id_1;
  input [7:0] tc_mapped_to_vc_id_2;
  input [7:0] tc_mapped_to_vc_id_3;
  input [7:0] tc_mapped_to_vc_id_4;
  input [7:0] tc_mapped_to_vc_id_5;
  input [7:0] tc_mapped_to_vc_id_6;
  input [7:0] tc_mapped_to_vc_id_7;

  wire                         reset_sampled;
  wire                         areset_sampled;
  wire  [ZI_PORT_WIDTH - 1 :0] tx_symbols_plus_sampled;
  wire  [ZI_PORT_WIDTH - 1 :0] tx_symbols_minus_sampled;  
  wire  [ZI_PORT_WIDTH - 1 :0] rx_symbols_plus_sampled;
  wire  [ZI_PORT_WIDTH - 1 :0] rx_symbols_minus_sampled;

  wire                         skip_link_training_sampled;
  wire  [15:0]                 device_control_register_sampled;
  wire  [31:0]                 device_capabilities_register_sampled;
  wire                         extended_sync_enable_sampled;
  wire                         L0s_entry_supported_sampled;
  wire                         phy_layer_checks_disable_sampled;
  wire                         link_layer_checks_disable_sampled;
  wire        		       transaction_layer_checks_disable_sampled;

  wire  [7:0] 		       enable_vc_id_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_0_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_1_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_2_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_3_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_4_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_5_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_6_sampled;
  wire  [7:0] 		       tc_mapped_to_vc_id_7_sampled;
  // Gen2
  wire acs_translation_blocking_enable_sampled;
  wire disable_cpl_timeout_sampled;

  assign `QVL_DUT2CHX_DELAY reset_sampled   = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled  = areset;
  assign `QVL_DUT2CHX_DELAY tx_symbols_plus_sampled = tx_symbols_plus;
  assign `QVL_DUT2CHX_DELAY tx_symbols_minus_sampled = tx_symbols_minus;  
  assign `QVL_DUT2CHX_DELAY rx_symbols_plus_sampled = rx_symbols_plus;
  assign `QVL_DUT2CHX_DELAY rx_symbols_minus_sampled = rx_symbols_minus;

  assign `QVL_DUT2CHX_DELAY skip_link_training_sampled = skip_link_training;
  assign `QVL_DUT2CHX_DELAY device_control_register_sampled = device_control_register;
  assign `QVL_DUT2CHX_DELAY device_capabilities_register_sampled = device_capabilities_register;
  assign `QVL_DUT2CHX_DELAY extended_sync_enable_sampled = extended_sync_enable;
  assign `QVL_DUT2CHX_DELAY L0s_entry_supported_sampled = L0s_entry_supported;
  assign `QVL_DUT2CHX_DELAY phy_layer_checks_disable_sampled = phy_layer_checks_disable;
  assign `QVL_DUT2CHX_DELAY link_layer_checks_disable_sampled = link_layer_checks_disable;
  assign `QVL_DUT2CHX_DELAY transaction_layer_checks_disable_sampled = transaction_layer_checks_disable;

  assign `QVL_DUT2CHX_DELAY enable_vc_id_sampled = enable_vc_id;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_0_sampled = tc_mapped_to_vc_id_0;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_1_sampled = tc_mapped_to_vc_id_1;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_2_sampled = tc_mapped_to_vc_id_2;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_3_sampled = tc_mapped_to_vc_id_3;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_4_sampled = tc_mapped_to_vc_id_4;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_5_sampled = tc_mapped_to_vc_id_5;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_6_sampled = tc_mapped_to_vc_id_6;
  assign `QVL_DUT2CHX_DELAY tc_mapped_to_vc_id_7_sampled = tc_mapped_to_vc_id_7;
  // gen2
  assign `QVL_DUT2CHX_DELAY acs_translation_blocking_enable_sampled = acs_translation_blocking_enable;
  assign `QVL_DUT2CHX_DELAY disable_cpl_timeout_sampled = disable_cpl_timeout;  

qvl_pci_express_logic
    #(.Constraints_Mode(Constraints_Mode),
      .PCI_EXPRESS_DEVICE_TYPE(PCI_EXPRESS_DEVICE_TYPE),
      .INTERFACE_TYPE(INTERFACE_TYPE), 
      .MAX_LINK_WIDTH(MAX_LINK_WIDTH),                                            
      .DOUBLE_DATA_RATE(DOUBLE_DATA_RATE),
      .MAX_REQUESTS_ADDR_WIDTH(MAX_REQUESTS_ADDR_WIDTH),
      .ELECTRICAL_IDLE_VAL(ELECTRICAL_IDLE_VAL),
      .RESERVED_FIELD_CHECK_ENABLE(RESERVED_FIELD_CHECK_ENABLE),
      .VENDOR_SPECIFIC_ENCODING_ENABLE(VENDOR_SPECIFIC_ENCODING_ENABLE),
      .OVERRIDE_TIMER_VALUE(OVERRIDE_TIMER_VALUE),
      .REPLAY_TIMER_VALUE(REPLAY_TIMER_VALUE),
      .ACKNAK_TIMER_VALUE(ACKNAK_TIMER_VALUE),
      .MIN_TS1_COUNT(MIN_TS1_COUNT),
      .DESKEW_SUPPORT(DESKEW_SUPPORT),
      .VC_SUPPORT(VC_SUPPORT),
      .HOT_PLUG_MESSAGE_ENABLE(0), // For Gen2 it is not required
      .TX_SKEW_SUPPORT(TX_SKEW_SUPPORT),
      .ENABLE_DATA_PLUS_MINUS_CHECK(ENABLE_DATA_PLUS_MINUS_CHECK),
      .PCI_EXPRESS_GEN2(1),
      .CPL_TIMEOUT_CLK(CPL_TIMEOUT_CLK),
      .UPDATE_FC_30US_TIMER_CLK(UPDATE_FC_30US_TIMER_CLK)
     )
    qvl_pciexpress (
               .reset(reset_sampled),
               .areset(areset_sampled),
               .tx_clk(tx_clk),
               .tx_symbols_plus(tx_symbols_plus_sampled),
               .tx_symbols_minus(tx_symbols_minus_sampled),
               .rx_clk(rx_clk),
               .rx_symbols_plus(rx_symbols_plus_sampled),
               .rx_symbols_minus(rx_symbols_minus_sampled),

               .skip_link_training(skip_link_training_sampled),
               .device_control_register(device_control_register_sampled),
               .device_capabilities_register(device_capabilities_register_sampled),
               .extended_sync_enable(extended_sync_enable_sampled),
               .L0s_entry_supported(L0s_entry_supported_sampled),
	       // gen2	    
	       .acs_translation_blocking_enable(acs_translation_blocking_enable_sampled),
	       .disable_cpl_timeout(disable_cpl_timeout_sampled),  	    
		    
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

`qvlendmodule // end of qvl_pci_express_monitor
