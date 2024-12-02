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
* PURPOSE     This file is part of 0-In CheckerWare.
*
* DESCRIPTION This monitor tracks the SAS interface for compliance with
*             Serial Attached SCSI specification and protocol.
*             
* REFERENCES   Serial Attached SCSI, Revision 1.1, Revision 04, Mar 13, 2004.
*
* INPUTS      
*             areset                    - Asynchronous reset, active high
*             reset                     - Synchronous reset, active high
*
*             tx_clk                    - Transmit clock. 
*             tx_data_plus              - Transmit data plus
*             tx_data_minus             - Transmit data minus
*             tx_idle_signal            - Transmit Electrical Idle signal 
*
*             rx_clk                    - Receive clock.
*             rx_data_plus              - Receive data plus
*             rx_data_minus             - Receive data minus
*             rx_idle_signal            - Receive Electrical Idle signal
*             bypass_reset_sequence     - Bypassing the reset sequence
*             start_speed_negotiation   - Starting point of RCD phase
*
*             tx_cominit_idle_time      - Transmitter COMINIT IDLE time period
*             tx_comsas_idle_time       - Transmitter COMSAS IDLE time period
*             tx_cominit_neg_time       - Tx COMINIT NEGATION time period
*             tx_comsas_neg_time        - Tx COMSAS NEGATION time period
*             rate_change_delay         - RATE CHANGE DELAY period
*             spd_neg_lock_time         - SPEED NEG LOCK time period
*             spd_neg_transmit_time     - SPEED NEG TRANSMIT time period
*             hotplug_timeout           - HOTPLUG timeout period
*             comsas_timeout            - COMSAS timeout period
*             hard_reset_timeout        - HARD RESET timeout period
*             ident_frame_timeout       - IDENTIFICATION FRAME timeout period
*             break_timeout             - BREAK timeout period
*             open_addr_res_timeout     - OPEN ADDRESS RESPONSE timeout period
*             credit_timeout            - CREDIT timeout period
*             ack_nak_timeout           - ACK/NAK timeout period
*             close_timeout             - CLOSE timeout period
*             done_timeout              - DONE timeout period
*             rx_cominit_idle_time_min  - Rcvr COMINIT minimum idle time
*             rx_cominit_idle_time_max  - Rcvr COMINIT maximum idle time
*             rx_comsas_idle_time_min   - Rcvr COMSAS minimum idle time
*             rx_comsas_idle_time_max   - Rcvr COMSAS maximum idle time
*             rx_cominit_neg_time       - Rx COMINIT NEGATION time period
*             rx_comsas_neg_time        - Rx COMSAS NEGATION time period
*
* MONITOR INSTANTIATION 
*
*     1. In a Initiator Device
*        ---------------------
*
*       +---------------+                 +-----------------+
*       |   INITIATOR   |  Transmit       |                 |
*       |       +---+   |  Interface      |                 |
*       |       | M |<--|---------------->|       TARGET    |
*       |       | O |   |                 |       DEVICE    |
*       |       | N |   |                 |                 |
*       |       | I |   |                 |                 |
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 |
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*     2. In an Expander device
*        ---------------------
*      
*       Note : Monitor is instantiated in the Expander device.
*
*       +---------------+                 +-----------------+
*       |   EXPANDER    |  Transmit       |                 |
*       |       +---+   |  Interface      |                 |
*       |       | M |<--|---------------->|       TARGET    |
*       |       | O |   |                 |       DEVICE    |
*       |       | N |   |                 |                 |
*       |       | I |   |                 |                 |
*       |       | T |   |  Receive        |                 |
*       |       | O |   |  Interface      |                 |
*       |       | R |<--|<----------------|                 |
*       |       +---+   |                 |                 |
*       |               |                 |                 |
*       +---------------+                 +-----------------+
*
*     3. In a Target device
*        ------------------ 
* 
*       Note : Monitor is instantiated in the Target device.
*
*       +---------------+                 +-----------------+
*       |   INITIATOR   |  Receive        |     TARGET      |
*       |    DEVICE     |  Interface      |    +---+        |
*       |               |---------------->|--->|   |        |
*       |               |                 |    | M |        |
*       |               |                 |    | O |        |
*       |               |                 |    | N |        |
*       |               |  Transmit       |    | I |        |
*       |               |  Interface      |    | T |        |
*       |               |<----------------|--->| O |        |
*       |               |                 |    | R |        |
*       |               |                 |    +---+        |
*       +---------------+                 +-----------------+
*
*
* LAST MODIFIED DATE : 01st July 2004
*
*****************************************************************************/
`qvlmodule qvl_sas_dynamic_timer_values_monitor(
                         reset,
                         areset,
                          
                         tx_clk,
                         tx_data_plus,
                         tx_data_minus,
			 tx_idle_signal,

                         rx_clk,
                         rx_data_plus,
                         rx_data_minus,
			 rx_idle_signal,
                         bypass_reset_sequence,
                         start_speed_negotiation,

			 tx_cominit_idle_time,
			 tx_comsas_idle_time,
			 tx_cominit_neg_time,
			 tx_comsas_neg_time,
			 rate_change_delay,
			 spd_neg_lock_time,
			 spd_neg_transmit_time,
			 hotplug_timeout,
			 comsas_timeout,
			 hard_reset_timeout,
			 ident_frame_timeout,
			 break_timeout,
			 open_addr_res_timeout,
			 credit_timeout,
			 ack_nak_timeout,
			 close_timeout,
			 done_timeout,
                         rx_cominit_idle_time_min,
                         rx_cominit_idle_time_max,
                         rx_comsas_idle_time_min,
                         rx_comsas_idle_time_max,
                         rx_cominit_neg_time,
                         rx_comsas_neg_time  
                        );

  // Set this parameter to 1 if the checks in the monitor are to be used 
  // as constraints for 0-In Search. 


  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Configures the monitor to track a initiator/target device or an 
  // expander/fanout expander device.  Set this parameter to 1 to track an 
  // expander/fanout expander device.  By default the monitor tracks 
  // initator/target device.

  parameter SAS_DEVICE_TYPE = 0;
  wire [31:0] pw_SAS_DEVICE_TYPE = SAS_DEVICE_TYPE;

  // This parameter configures the monitor to either serial or parallel mode. 
  // Set this parameter to 1 if the monitor is instantiated on a 10-bit parallel 
  // interface. Set this parameter to 2, if the monitor is instantiated on a
  // 20-bit parallel interface. By default the monitor is instantiated on a 
  // serial interface.

  parameter INTERFACE_TYPE = 0;
  wire [31:0] pw_INTERFACE_TYPE = INTERFACE_TYPE;

  // Configures the active edge of the tx_clk/rx_clk clocks. Set this 
  // parameter to 1 if both edges of tx_clk/rx_clk clocks are active. Set 
  // this parameter to 0 if tx_clk/rx_clk is active on only rising edge. 
  // By default, tx_clk/rx_clk is active on only rising edge.

  parameter DOUBLE_DATA_RATE = 0;
  wire [31:0] pw_DOUBLE_DATA_RATE = DOUBLE_DATA_RATE;

  // Configures the rate at which ALIGNs are transmitted after powerup.Set 
  // this parameter to 1 if ALIGNs are transmitted at G2(3.0Gbps) rate. 
  // By default, ALIGNs are transmitted at G1 (1.5Gbps) rate.

  parameter TX_DEVICE_SPEED_RATE = 0;
  wire [31:0] pw_TX_DEVICE_SPEED_RATE = TX_DEVICE_SPEED_RATE;

  // Configures the rate at which ALIGNs are received after powerup.Set 
  // this parameter to 1 if ALIGNs are received at G2(3.0Gbps) rate. 
  // By default, ALIGNs are received at G1 (1.5Gbps) rate.

  parameter RX_DEVICE_SPEED_RATE = 0;
  wire [31:0] pw_RX_DEVICE_SPEED_RATE = RX_DEVICE_SPEED_RATE;

  // Specifies the value of the encoded 10B data during electrical idle 
  // conditions. This parameter is applicable only when INTERFACE_TYPE is set 
  // to 1 (parallel mode of operation). The default value of the  parameter is 
  // the value equivalent to 3FFh, the assumed 10-bit encoded value for 
  // electrical idle.  In serial mode of operation, the monitor detects 
  // electrical idle when both D+ and D- inputs are driven to same level.

  parameter ELECTRICAL_IDLE_TIME_BIT_PATTERN = 10'h3ff;
  wire [31:0] pw_ELECTRICAL_IDLE_TIME_BIT_PATTERN =
                                           ELECTRICAL_IDLE_TIME_BIT_PATTERN;

  // This parameter will determine the maximum rate supported by the device.
  // If this is set to 1, maximum supported rate is G2.  If this is set to 0,
  // Maximum supported rate is G1.   Bydefault this is set to 0.
  // by the TX device. 

  parameter TX_MAX_SUPPORTED_RATE = 0;
  wire [31:0] pw_TX_MAX_SUPPORTED_RATE = TX_MAX_SUPPORTED_RATE;

  // This parameter will determine the maximun rate supported by the device.
  // If this is set to 1, maximum supported rate is G2.  If this is set to 0,
  // Maximum supported rate is G1.   Bydefault this is set to 0.
  // by the RX device.

  parameter RX_MAX_SUPPORTED_RATE = 0;
  wire [31:0] pw_RX_MAX_SUPPORTED_RATE = RX_MAX_SUPPORTED_RATE; 

  // Configures the monitor to track repeatitive primitive sequences.
  // Set this parameter to 0 to disable the tracking of repeated primitive 
  // sequences.By default , monitor tracks repetitive primitive sequences.

  parameter REPEATED_PRIMITIVE_SEQ = 1;
  wire [31:0] pw_REPEATED_PRIMITIVE_SEQ = REPEATED_PRIMITIVE_SEQ;

  // Configures the monitor to perform the transaction layer checks. Set this
  // parameter to 0 to configure the monitor to disable transport layer
  // checks.  By default, the transport layer checks are turned on.

  parameter TRANSPORT_LAYER_CHECKS_ENABLE = 1;
  wire [31:0] pw_TRANSPORT_LAYER_CHECKS_ENABLE = 
                                           TRANSPORT_LAYER_CHECKS_ENABLE;

  //Configures the monitor to perform scrambling. Set this parameter to 1 to
  //configure the monitor to disable scrambling of 8bit data.  By default
  //monitor performs scrambling of 8bit data.

  parameter DISABLE_DESCRAMBLER = 0;
  wire [31:0] pw_DISABLE_DESCRAMBLER = DISABLE_DESCRAMBLER;

  // Configures the monitor to perform the checks during reset sequence.
  // Set the parameter to 1 to configure the monitor to perform the 
  // reset sequence checks.  By default, reset sequence checks are 
  // turned off.

  parameter PHY_RESET_SEQ_CHECK_ENABLE = 0;
  wire [31:0] pw_PHY_RESET_SEQ_CHECK_ENABLE = PHY_RESET_SEQ_CHECK_ENABLE;

  // Configures the monitor to perform the check for the reserved values.
  // Set the parameter to 1 to configure the monitor to perform the check.
  // By default, checks are performed for the reserved values.

  parameter RESERVED_FIELD_CHECK_ENABLE = 1;
  wire [31:0] pw_RESERVED_FIELD_CHECK_ENABLE = RESERVED_FIELD_CHECK_ENABLE;

  // Parameter VENDOR_SPECIFIC_ENCODING_ENABLE = 0 configures the monitor to
  // allow the usage of vendor specific encodings in the SSP and SMP frames.

  parameter VENDOR_SPECIFIC_ENCODING_ENABLE = 0;
  wire [31:0] pw_VENDOR_SPECIFIC_ENCODING_ENABLE =
                                             VENDOR_SPECIFIC_ENCODING_ENABLE;

  // ---------------------------------
  // Internal Parameter declarations
  // ---------------------------------

  parameter ZI_PORT_WIDTH = (INTERFACE_TYPE === 0 ? 1 : 
			     (INTERFACE_TYPE === 1 ? 10 :
			     (INTERFACE_TYPE === 2 ? 20 : 20)));

  parameter ZI_LINK_PORT_WIDTH = (INTERFACE_TYPE !== 0) ? 10 : 1;

  // This parameter will determine where the first transmitted 10-bit
  // will sit in the parallel 20-bit data.

  parameter ZI_BIT_POSITION = 0;

  // This parameter will determine the DOUBLE_DATA_RATE depending on
  // the INTERFACE_TYPE

  parameter ZI_FINAL_DDR = INTERFACE_TYPE === 2 ? 1 : DOUBLE_DATA_RATE;
  wire [31:0] pw_ZI_FINAL_DDR = ZI_FINAL_DDR;
			     
  // Input declarations

  input reset;
  input areset;
  input tx_clk;
  input [ZI_PORT_WIDTH - 1:0] tx_data_plus;
  input [ZI_PORT_WIDTH - 1:0] tx_data_minus;
  input tx_idle_signal;
  input rx_clk;
  input [ZI_PORT_WIDTH - 1:0] rx_data_plus;
  input [ZI_PORT_WIDTH - 1:0] rx_data_minus;
  input rx_idle_signal;
  input start_speed_negotiation;

  input [31:0] tx_cominit_idle_time;
  input [31:0] tx_comsas_idle_time;
  input [31:0] rx_cominit_idle_time_min;
  input [31:0] rx_cominit_idle_time_max; 
  input [31:0] rx_comsas_idle_time_min;
  input [31:0] rx_comsas_idle_time_max;
  input [31:0] tx_cominit_neg_time;
  input [31:0] tx_comsas_neg_time;
  input [31:0] rx_cominit_neg_time;
  input [31:0] rx_comsas_neg_time;
  input [31:0] rate_change_delay;
  input [31:0] spd_neg_lock_time;
  input [31:0] spd_neg_transmit_time;
  input [31:0] hotplug_timeout;
  input [31:0] comsas_timeout;
  input [31:0] hard_reset_timeout;
  input [31:0] ident_frame_timeout;
  input [31:0] break_timeout;
  input [31:0] open_addr_res_timeout;
  input [31:0] credit_timeout;
  input [31:0] ack_nak_timeout;
  input [31:0] close_timeout;
  input [31:0] done_timeout;

  // Configure this port to 1'b1 to track phy reset sequence, when 
  // configured as 1'b0 the monitor assumes the link is in idle condition.

  input bypass_reset_sequence;

  wire reset_sampled;
  wire areset_sampled;
  wire [ZI_PORT_WIDTH - 1:0] tx_data_plus_sampled;
  wire [ZI_PORT_WIDTH - 1:0] tx_data_minus_sampled;
  wire tx_idle_signal_sampled;
  wire [ZI_PORT_WIDTH - 1:0] rx_data_plus_sampled;
  wire [ZI_PORT_WIDTH - 1:0] rx_data_minus_sampled;
  wire rx_idle_signal_sampled;
  wire start_speed_negotiation_sampled;
  wire [31:0] tx_cominit_idle_time_sampled;
  wire [31:0] tx_comsas_idle_time_sampled;
  wire [31:0] rx_cominit_idle_time_min_sampled;
  wire [31:0] rx_cominit_idle_time_max_sampled; 
  wire [31:0] rx_comsas_idle_time_min_sampled;
  wire [31:0] rx_comsas_idle_time_max_sampled;
  wire [31:0] tx_cominit_neg_time_sampled;
  wire [31:0] tx_comsas_neg_time_sampled;
  wire [31:0] rx_cominit_neg_time_sampled;
  wire [31:0] rx_comsas_neg_time_sampled;
  wire [31:0] rate_change_delay_sampled;
  wire [31:0] spd_neg_lock_time_sampled;
  wire [31:0] spd_neg_transmit_time_sampled;
  wire [31:0] hotplug_timeout_sampled;
  wire [31:0] comsas_timeout_sampled;
  wire [31:0] hard_reset_timeout_sampled;
  wire [31:0] ident_frame_timeout_sampled;
  wire [31:0] break_timeout_sampled;
  wire [31:0] open_addr_res_timeout_sampled;
  wire [31:0] credit_timeout_sampled;
  wire [31:0] ack_nak_timeout_sampled;
  wire [31:0] close_timeout_sampled;
  wire [31:0] done_timeout_sampled;
  wire bypass_reset_sequence_sampled;

  assign `QVL_DUT2CHX_DELAY reset_sampled = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY tx_data_plus_sampled = tx_data_plus;
  assign `QVL_DUT2CHX_DELAY tx_data_minus_sampled = tx_data_minus;
  assign `QVL_DUT2CHX_DELAY tx_idle_signal_sampled = tx_idle_signal;
  assign `QVL_DUT2CHX_DELAY rx_data_plus_sampled = rx_data_plus;
  assign `QVL_DUT2CHX_DELAY rx_data_minus_sampled = rx_data_minus;
  assign `QVL_DUT2CHX_DELAY rx_idle_signal_sampled = rx_idle_signal;
  assign `QVL_DUT2CHX_DELAY start_speed_negotiation_sampled = start_speed_negotiation;

  assign `QVL_DUT2CHX_DELAY tx_cominit_idle_time_sampled = tx_cominit_idle_time;
  assign `QVL_DUT2CHX_DELAY tx_comsas_idle_time_sampled = tx_comsas_idle_time;
  assign `QVL_DUT2CHX_DELAY rx_cominit_idle_time_min_sampled = rx_cominit_idle_time_min;
  assign `QVL_DUT2CHX_DELAY rx_cominit_idle_time_max_sampled = rx_cominit_idle_time_max; 
  assign `QVL_DUT2CHX_DELAY rx_comsas_idle_time_min_sampled = rx_comsas_idle_time_min;
  assign `QVL_DUT2CHX_DELAY rx_comsas_idle_time_max_sampled = rx_comsas_idle_time_max;
  assign `QVL_DUT2CHX_DELAY tx_cominit_neg_time_sampled = tx_cominit_neg_time;
  assign `QVL_DUT2CHX_DELAY tx_comsas_neg_time_sampled = tx_comsas_neg_time;
  assign `QVL_DUT2CHX_DELAY rx_cominit_neg_time_sampled = rx_cominit_neg_time;
  assign `QVL_DUT2CHX_DELAY rx_comsas_neg_time_sampled = rx_comsas_neg_time;
  assign `QVL_DUT2CHX_DELAY rate_change_delay_sampled = rate_change_delay;
  assign `QVL_DUT2CHX_DELAY spd_neg_lock_time_sampled = spd_neg_lock_time;
  assign `QVL_DUT2CHX_DELAY spd_neg_transmit_time_sampled = spd_neg_transmit_time;
  assign `QVL_DUT2CHX_DELAY hotplug_timeout_sampled = hotplug_timeout;
  assign `QVL_DUT2CHX_DELAY comsas_timeout_sampled = comsas_timeout;
  assign `QVL_DUT2CHX_DELAY hard_reset_timeout_sampled = hard_reset_timeout;
  assign `QVL_DUT2CHX_DELAY ident_frame_timeout_sampled = ident_frame_timeout;
  assign `QVL_DUT2CHX_DELAY break_timeout_sampled = break_timeout;
  assign `QVL_DUT2CHX_DELAY open_addr_res_timeout_sampled = open_addr_res_timeout;
  assign `QVL_DUT2CHX_DELAY credit_timeout_sampled = credit_timeout;
  assign `QVL_DUT2CHX_DELAY ack_nak_timeout_sampled = ack_nak_timeout;
  assign `QVL_DUT2CHX_DELAY close_timeout_sampled = close_timeout;
  assign `QVL_DUT2CHX_DELAY done_timeout_sampled = done_timeout;
  assign `QVL_DUT2CHX_DELAY bypass_reset_sequence_sampled = bypass_reset_sequence;

  // ----------------------------------------------------
  // Instantiation of the new version of the SAS monitor
  // ----------------------------------------------------

  qvl_sas_dynamic_timer_values_logic
                        #(Constraints_Mode,
                          SAS_DEVICE_TYPE,
                          INTERFACE_TYPE,
                          DOUBLE_DATA_RATE,
                          TX_DEVICE_SPEED_RATE,
                          RX_DEVICE_SPEED_RATE,
                          ELECTRICAL_IDLE_TIME_BIT_PATTERN,
                          TX_MAX_SUPPORTED_RATE,
                          RX_MAX_SUPPORTED_RATE,
                          REPEATED_PRIMITIVE_SEQ,
                          TRANSPORT_LAYER_CHECKS_ENABLE,
                          DISABLE_DESCRAMBLER,
                          PHY_RESET_SEQ_CHECK_ENABLE,
                          RESERVED_FIELD_CHECK_ENABLE,
                          VENDOR_SPECIFIC_ENCODING_ENABLE   
			 ) 
        SAS_PORTS_VERSION (.areset(areset_sampled),
			   .reset(reset_sampled),

			   .tx_clk(tx_clk),
			   .tx_data_plus(tx_data_plus_sampled),
			   .tx_data_minus(tx_data_minus_sampled),
			   .tx_idle_signal(tx_idle_signal_sampled),

                           .rx_clk(rx_clk),
                           .rx_data_plus(rx_data_plus_sampled),
                           .rx_data_minus(rx_data_minus_sampled),
                           .rx_idle_signal(rx_idle_signal_sampled),

                           .bypass_reset_sequence(bypass_reset_sequence_sampled),
                           .start_speed_negotiation(start_speed_negotiation_sampled),

                           .tx_cominit_idle_time(tx_cominit_idle_time_sampled),
                           .tx_comsas_idle_time(tx_comsas_idle_time_sampled),
                           .rx_cominit_idle_time_min
                                         (rx_cominit_idle_time_min_sampled),
                           .rx_cominit_idle_time_max
                                         (rx_cominit_idle_time_max_sampled),
                           .rx_comsas_idle_time_min
                                         (rx_comsas_idle_time_min_sampled),
                           .rx_comsas_idle_time_max
                                         (rx_comsas_idle_time_max_sampled),
                           .tx_cominit_neg_time(tx_cominit_neg_time_sampled),
                           .tx_comsas_neg_time(tx_comsas_neg_time_sampled),
                           .rx_cominit_neg_time(rx_cominit_neg_time_sampled),
                           .rx_comsas_neg_time(rx_comsas_neg_time_sampled),
                           .rate_change_delay(rate_change_delay_sampled),
                           .spd_neg_lock_time(spd_neg_lock_time_sampled),
                           .spd_neg_transmit_time
				     (spd_neg_transmit_time_sampled),
                           .hotplug_timeout(hotplug_timeout_sampled),
                           .comsas_timeout(comsas_timeout_sampled),
                           .hard_reset_timeout(hard_reset_timeout_sampled),
                           .ident_frame_timeout(ident_frame_timeout_sampled),
                           .break_timeout(break_timeout_sampled),
                           .open_addr_res_timeout(open_addr_res_timeout_sampled),
                           .credit_timeout(credit_timeout_sampled),
                           .ack_nak_timeout(ack_nak_timeout_sampled),
                           .close_timeout(close_timeout_sampled),
                           .done_timeout(done_timeout_sampled) 
                          );


`qvlendmodule
