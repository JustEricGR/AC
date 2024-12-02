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
* DESCRIPTION This monitor checks the USB 2.0 UTMI interface for compliance 
*             with UTMI specification and USB 2.0 specification and protocol.
*
* REFERENCES  Universal Serial Bus Specification, Revision 2.0, April 27,
*             2000.
*             Errata for USB 2.0 specification, May 28, 2002.
*             Errata for USB 2.0 specification, December 7, 2000.
*             USB 2.0 Transceiver Macrocell Interface Specification, 
*             Revision 1.05, Mar 29, 2001.
*             UTMI+ Specification, Revision 1.0, February 25th , 2004.
*
* INPUTS      clock                   - Clock.
*             reset                   - Synchronous reset, active high.
*             areset                  - Asynchronous reset, active high.
*
*             tx_valid                - Transmit data valid signal.
*             tx_valid_h              - Transmit data valid high signal.
*             tx_ready                - Transmit data ready signal.
*             data_in_low             - 8-Bit parallel USB data input.
*             data_in_high            - 8-Bit parallel USB data input. This
*                                       bus carries the high order byte
*
*             rx_valid                - Receive data valid signal.
*             rx_valid_h              - Receive data valid high signal.
*             data_out_low            - 8-Bit parallel USB data output.
*             data_out_high           - 8-Bit parallel USB data output. This
*                                       bus carries the high order byte.
*             rx_active               - Receive active signal
*             rx_error                - Receive error signal
*             
*             databus16_8             - Selects between 8 bit or 16 bit.
*             line_state              - Signal which reflects current state
*                                       of the USB bus.
*             xcvr_select             - Selects between FS/HS transceivers.
*             term_select             - Selects between FS/HS terminations.
*             op_mode                 - Selects operational mode of the Macrocell.
*             suspendm                - Places the Macrocell in a low power mode.
*             address                 - Device address.
*             end_point_config        - End point configuration input.
*             number_of_active_endpoints - Number of active endpoints.
*
*             // Signals to support Bi-Directional interfaces.
*     
*             data_low                - 8-Bit parallel USB input and output.
*             data_high               - 8-Bit parallel USB input and output.
*             valid_h                 - Valid high signal.
*
*
*             // Signals to support On-The-Go Devices
*             a_valid                 - Indicates if A-Perip session is valid
*             b_valid                 - Indicates if B-Perip session is valid
*             vbus_valid              - Indicates voltage on Vbus is valid
*             sess_end                - Vbus is below its B-Dev Session End threshold
*             drv_vbus                - Signal enables to drive 5V on Vbus
*             dischrg_vbus            - Signal enables discharging Vbus
*             chrg_vbus               - Signal enables charging of Vbus
*             host_disconnect         - Indicates weather a peripheral is connected or not
*
*             // Signals for supporting Level 1 and above 
*             id_pullup               - Enables analog Id lines 
*             id_dig                  - Selects between mini-A or mini-B.
*             dp_pulldown             - Enables the 15k Ohm pull-down resistor on the DP line
*             dm_pulldown             - Enables the 15k Ohm pull-down resistor on the DM line.
*
* NOTES
*
*        1. Bidirectional signals are required if the UTMI is bidirectional.
*
*        2. If the UTMI interface is 8 bit, then signals/ports related to 
*           16 bit interface need not be hooked up.
*
*        3. Depending on the relevent level of operation signals/ports related
*           to higher level need not be hooked up.
*
*
* MONITOR INSTANTIATION
*
*
*  Monitor is instantiated in the Host to track the transactions of the
*  downstream port of the host(Downstream port of root hub).
*
*       +----------------+                          +-----------------+
*       |                |                          |                 |  
*       | +-----------+  |                          |                 |  
*       | | Monitor   |  |                          |                 |  
*       | +-----------+  |     USB Bus              |     HUB or      |  
*       |                |<------------------------>|                 |  
*       |  HOST          |    Full speed or         |     FUNCTION    |
*       |                |    High speed            |                 |  
*       |                |                          |                 |  
*       |                |                          |                 |  
*       |                |                          |                 |  
*       +----------------+                          +-----------------+
*
*  Monitor is instantiated in the Device to track the transactions of the
*  upstream port of the Device. (Device can be Hub or Function)
*
*       +----------------+                          +-----------------+
*       |                |                          |                 |  
*       |                |                          | +-------------+ |
*       |                |                          | | Monitor     | |
*       |                |      USB Bus             | +-------------+ |
*       |                |<------------------------>|     HUB or      |  
*       |                |      Full speed or       |                 |  
*       |  HOST          |      High speed          |    FUNCTION     |  
*       |                |                          |                 |  
*       |                |                          |                 |  
*       |                |                          |                 |  
*       +----------------+                          +-----------------+
*
*  Monitor is instantiated in the Hub to track the transactions of the
*  downstream port of the Hub.
*
*        +----------------+                          +-----------------+
*        |                |                          |                 | 
*        | +-----------+  |                          |                 | 
*        | | Monitor   |  |                          |                 | 
*        | +-----------+  |     USB Bus              |     HUB or      | 
*        |                |<------------------------>|                 | 
*        |  HUB           |   Full or Low speed or   |   FUNCTION      | 
*        |                |      High speed          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        +----------------+                          +-----------------+
*
*
***************************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_usb_2_0_utmi_monitor (
                                   clock,
                                   reset,
                                   areset,
                              
                                   // Transmit Interface

                                   tx_valid,
                                   data_in_low,
                                   tx_valid_h,
                                   data_in_high,
                                   tx_ready,

                                   // Receive Interface

                                   rx_valid,
                                   data_out_low,
                                   rx_valid_h,
                                   data_out_high,
                                   rx_active,
                                   rx_error,

                                   // Control interface

                                   databus16_8,
                                   line_state, 
                                   xcvr_select,
                                   term_select,
                                   op_mode,
                                   suspendm,

                                   // Bi directional 

                                   data_low,
                                   data_high,
                                   valid_h,

                                   //OTG interface
                                   id_pullup,
                                   id_dig,
                                   a_valid,
                                   b_valid,
                                   vbus_valid,
                                   sess_end,
                                   drv_vbus,
                                   dischrg_vbus,
                                   chrg_vbus,
                                   dp_pulldown,
                                   dm_pulldown,
                                   host_disconnect,

                                   // Configuration inputs
 
                                   address,
                                   end_point_config,
                                   number_of_active_endpoints
                                   );

  // Parameter Constraints_Mode = 1 will configure some checks in this 
  // monitor as constraints during 0-In Search.

  parameter Constraints_Mode = 0; 
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Paramete UTMI_LEVEL configures the Level of the UTMI monitor.
  // UTMI_LEVEL = 0 configures the monitor to operate in UTMI+Level0 mode.
  // UTMI_LEVEL = 1 configures the monitor to operate in UTMI+Level1 mode.
  // UTMI_LEVEL = 2 configures the monitor to operate in UTMI+Level2 mode.
  // UTMI_LEVEL = 3 configures the monitor to operate in UTMI+Level3 mode.
  // This information is used to configure the width of XcvrSelect signal to
  // 2 bits for Level 2 and above

  parameter UTMI_LEVEL = 0;
  wire [31:0] pw_UTMI_LEVEL = UTMI_LEVEL;

  // Parameter PORT_TYPE configures the port type which will be tracked by
  // the monitor. PORT_TYPE = 0 configures the monitor to track the
  // transactions of the downstream port of the Host. PORT_TYPE = 1
  // configures the monitor to track the transactions of the upstream port
  // of Hub. PORT_TYPE = 2 configures the monitor to track the transactions
  // of the downstream port of Hub. PORT_TYPE = 3 configures the monitor to
  // track transactions of upstream port of a function. This information,
  // along with the value of parameter Constraints_Mode will decide the checks
  // to be turned into constraints during 0-In Search.

  parameter PORT_TYPE = 3;                             
  wire [31:0] pw_PORT_TYPE = PORT_TYPE;

  // Parameter UTMI_SIDE indicates on which side of the interface, monitor
  // is instantiated. By default monitor is assumed to be instantiated on
  // the SIE side of the interface. 

  parameter UTMI_SIDE = 0;
  wire [31:0] pw_UTMI_SIDE = UTMI_SIDE;

  // Parameter BI_DIRECTIONAL configures the monitor to track the
  // UTMI interface.

  parameter BI_DIRECTIONAL = 0;
  wire [31:0] pw_BI_DIRECTIONAL = BI_DIRECTIONAL;

  // Parameter DEVICE_SPEED configures the monitor for FS/HS, FS only, LS only
  // mode of operation. Set this parameter to 1 if the UTM is FS only, Set this
  // parameter to 2 if the UTM is LS only. By default, monitor is configured to
  // track FS/HS interface.

  parameter DEVICE_SPEED = 0;
  wire [31:0] pw_DEVICE_SPEED = DEVICE_SPEED;

  // Parameter NUMBER_OF_ENDPOINTS configures the number of end points
  // to be tracked by the monitor. By default, monitor is configured
  // to track only one end point.

  parameter NUMBER_OF_ENDPOINTS = 1;
  wire [31:0] pw_NUMBER_OF_ENDPOINTS = NUMBER_OF_ENDPOINTS;
 
  // Parameter FRAME_INTERVAL_COUNT indicates the number of clock cycles
  // between two successive SOF packets (USB specification specifies
  // an interval of 1ms between frames. This time duration needs to be mapped
  // into number of clock cycles).

  parameter FRAME_INTERVAL_COUNT = 7500;
  wire [31:0] pw_FRAME_INTERVAL_COUNT = FRAME_INTERVAL_COUNT;

  // Parameter SEQUENCE_BIT_TRACKING_ENABLE configures the monitor to
  // track data toggle synchronization.

  parameter SEQUENCE_BIT_TRACKING_ENABLE = 1;
  wire [31:0] pw_SEQUENCE_BIT_TRACKING_ENABLE = SEQUENCE_BIT_TRACKING_ENABLE;
 
  // Parameter PACKET_ISSUE_CHECK_ENABLE configures the monitor to fire
  // for illegal issue of token, requests. By default monitor fires
  // for above mentioned conditions. Example : If IN token is issued
  // to OUT only end point then monitor check fires when this parameter
  // is set to 1. Similarly if undefined requests other than standard
  // requests, device class requests are issued then monitor checks
  // fire when this parameter is set to 1.
 
  parameter PACKET_ISSUE_CHECK_ENABLE = 1;
  wire [31:0] pw_PACKET_ISSUE_CHECK_ENABLE = PACKET_ISSUE_CHECK_ENABLE;

  // parameter RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY configures the
  // delay between the deassertion of the RxActive and assertion of TxValid
  // assertion

  parameter RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN = 5;
  wire [31:0] pw_RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN = 
                       RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN;

  parameter RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX = 24;
  wire [31:0] pw_RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX = 
                       RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX;

  // parameter TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY configures the
  // delay between the deassertion of the TxValid and assertion of
  // RxActive.

  parameter TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN = 6;
  wire [31:0] pw_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN = 
                   TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN;

  parameter TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX = 37;
  wire [31:0] pw_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX = 
                   TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX;

  // Parameter TIME_OUT_COUNT configures the number of clk cycles
  // after which device or host is required to time out.

  parameter TIME_OUT_COUNT = 800;
  wire [31:0] pw_TIME_OUT_COUNT = TIME_OUT_COUNT;

  // Parameter OTG_DEVICE configures the monitor to track OTG compliant
  // USB devices. By default, non OTG compliant devices are tracked.

  parameter OTG_DEVICE = 0;
  wire [31:0] pw_OTG_DEVICE = OTG_DEVICE;

  // Parameter HUB_TURNAR_TIMEOUT_16BIT configures the monitor to track 
  // the turn around timeout period in case databus16_8 is set for 16 bit
  
  parameter HUB_TURNAR_TIMEOUT_16BIT = 45000;
  wire [12:0] pw_HUB_TURNAR_TIMEOUT_16BIT = HUB_TURNAR_TIMEOUT_16BIT; 

  // Parameter HUB_TURNAR_TIMEOUT_8BIT configures the monitor to track 
  // the turn around timeout period in case databus16_8 is set for 8 bit
  
  parameter HUB_TURNAR_TIMEOUT_8BIT = 90000;
  wire [12:0] pw_HUB_TURNAR_TIMEOUT_8BIT = HUB_TURNAR_TIMEOUT_8BIT; 

  // Parameter HUB_CHIRP_TIMEOUT_16BIT configures the monitor to track
  // the timeout period for a K or J chirp in 16 bit mode
  
  parameter HUB_CHIRP_TIMEOUT_16BIT = 1800;
  wire [11:0] pw_HUB_CHIRP_TIMEOUT_16BIT = HUB_CHIRP_TIMEOUT_16BIT;	

  // Parameter HUB_CHIRP_TIMEOUT_8BIT configures the monitor to track
  // the timeout period for a K or J chirp in 8 bit mode
  
  parameter HUB_CHIRP_TIMEOUT_8BIT = 3600;
  wire [11:0] pw_HUB_CHIRP_TIMEOUT_8BIT = HUB_CHIRP_TIMEOUT_8BIT;	
  
  // Parameter TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT configures the 
  // monitor to timeout when term_select signal does not deassert till 
  // 500 us after HS has been detected.

  parameter TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT = 30000; 
  wire [14:0] pw_TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT = 
                 TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT;	

  // Parameter TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT configures the 
  // monitor to timeout when term_select signal does not deassert till 
  // 500 us after HS has been detected.

  parameter TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT = 15000; 
  wire [14:0] pw_TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT = 
                 TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT;	

  // Parameters SE0_COUNT_MAX_FULL_SPEED_REVERSE_MAX_COUNT_8BIT configures the 
  // maximum time 3.125 ms in number of clocks for which SE0 has to be seen on 
  // the bus for reversal to full speed mode 
  parameter SE0_COUNT_MAX_FULL_SPEED_REVERSE_8BIT  = 187500;
  wire [31:0] pw_SE0_COUNT_MAX_FULL_SPEED_REVERSE_8BIT = 
                 SE0_COUNT_MAX_FULL_SPEED_REVERSE_8BIT;

  // Parameters SE0_COUNT_MAX_FULL_SPEED_REVERSE_MAX_COUNT_16BIT configures the 
  // maximum time 3.125 ms in number of clocks for which SE0 has to be seen on the 
  // bus for reversal to full speed mode 
  parameter SE0_COUNT_MAX_FULL_SPEED_REVERSE_16BIT = 93750;
  wire [31:0] pw_SE0_COUNT_MAX_FULL_SPEED_REVERSE_16BIT = 
                 SE0_COUNT_MAX_FULL_SPEED_REVERSE_16BIT;

  // Parameters SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT configures the minimum time 
  // 3 ms in number of clocks for which SE0 has to be seen on the bus for reversal 
  // to full speed mode
  parameter SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT  = 180000;
  wire [31:0] pw_SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT = 
                 SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT;

  // Parameters SE0_COUNT_MIN_FULL_SPEED_REVERSET_16BIT configures the minimum 
  // time 3 ms in number of clocks for which SE0 has to be seen on the bus for 
  // reversal to full speed mode
  parameter SE0_COUNT_MIN_FULL_SPEED_REVERSE_16BIT = 90000;
  wire[31:0] pw_SE0_COUNT_MIN_FULL_SPEED_REVERSE_16BIT = 
                SE0_COUNT_MIN_FULL_SPEED_REVERSE_16BIT;

  // Parameters FULL_SPEED_SE0_RESET_TIMEOUT_8BIT configures the time 2.5 us number 
  // of clock in full speed mode for which SE0 has to be seen on the bus for detecting 
  // reset
  parameter FULL_SPEED_SE0_RESET_TIMEOUT_8BIT = 1500;
  wire [31:0] pw_FULL_SPEED_SE0_RESET_TIMEOUT_8BIT  = FULL_SPEED_SE0_RESET_TIMEOUT_8BIT; 

  // Parameters FULL_SPEED_SE0_RESET_TIMEOUT_16BIT configures the time 2.5 us number 
  // of clock in full speed mode for which SE0 has to be seen on the bus for detecting 
  // reset
  parameter FULL_SPEED_SE0_RESET_TIMEOUT_16BIT = 750;
  wire [31:0] pw_FULL_SPEED_SE0_RESET_TIMEOUT_16BIT = FULL_SPEED_SE0_RESET_TIMEOUT_16BIT;

  // Parameters FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT configures the number of clock in
  // full speed mode for which J has to be seen on the bus for detecting suspend
  parameter FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT = 180000;
  wire [31:0] pw_FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT = FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT;
  
  // Parameters FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT configures the number of clock in
  // full speed mode for which J has to be seen on the bus for detecting suspend
  parameter FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT = 90000;
  wire [31:0] pw_FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT = FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT;

  // Parameter LINE_STATE_DEBOUNCE_TIMEOUT_8BIT configures the time in range of 100 us 
  // to 875 us to sample the line state for detection of reset/suspend after reversal 
  // to full speed mode
  parameter LINE_STATE_DEBOUNCE_TIMEOUT_8BIT = 6000;
  wire [31:0] pw_LINE_STATE_DEBOUNCE_TIMEOUT_8BIT = LINE_STATE_DEBOUNCE_TIMEOUT_8BIT;

  // Parameter LINE_STATE_DEBOUNCE_TIMEOUT_16BIT configures the time in range of 100 us 
  // to 875 us to sample the line state for detection of reset/suspend after reversal 
  // to full speed mode
  parameter LINE_STATE_DEBOUNCE_TIMEOUT_16BIT = 3000;
  wire [31:0] pw_LINE_STATE_DEBOUNCE_TIMEOUT_16BIT = LINE_STATE_DEBOUNCE_TIMEOUT_16BIT;

  // Parameter CLK_USABLE_TIMEOUT_8BIT configures the time 5.6 ms in number of clocks
  // for the clock to be usable after J-SE0 transition is seen on the bus
  parameter CLK_USABLE_TIMEOUT_8BIT = 336000;
  wire [31:0] pw_CLK_USABLE_TIMEOUT_8BIT = CLK_USABLE_TIMEOUT_8BIT;

  // Parameter CLK_USABLE_TIMEOUT_16BIT configures the time 5.6 ms in number of clocks
  // for the clock to be usable after J-SE0 transition is seen on the bus
  parameter CLK_USABLE_TIMEOUT_16BIT = 168000;
  wire [31:0] pw_CLK_USABLE_TIMEOUT_16BIT = CLK_USABLE_TIMEOUT_16BIT;

  // Parameter MIN_RESET_INTERVAL_8BIT configures the minimum reset interval of 10ms
  parameter MIN_RESET_INTERVAL_8BIT = 600000;
  wire [31:0] pw_MIN_RESET_INTERVAL_8BIT = MIN_RESET_INTERVAL_8BIT;

  // Parameter MIN_RESET_INTERVAL_16BIT configures the minimum reset interval of 10ms
  parameter MIN_RESET_INTERVAL_16BIT = 300000;
  wire [31:0] pw_MIN_RESET_INTERVAL_16BIT = MIN_RESET_INTERVAL_16BIT;

  // Parameter CHIRP_KJ_START_TIMEOUT_8BIT configures the time 100 us in number of clocks 
  // for Chirp-KJ sequence to start after device Chirp-K 
  parameter CHIRP_KJ_START_TIMEOUT_8BIT = 6000;
  wire [31:0]  pw_CHIRP_KJ_START_TIMEOUT_8BIT = CHIRP_KJ_START_TIMEOUT_8BIT;

  // Parameter CHIRP_KJ_START_TIMEOUT_16BIT configures the time 100 us in number of clocks 
  // for Chirp-KJ sequence to start after device Chirp-K 
  parameter CHIRP_KJ_START_TIMEOUT_16BIT = 3000;
  wire [31:0] pw_CHIRP_KJ_START_TIMEOUT_16BIT = CHIRP_KJ_START_TIMEOUT_16BIT;

  // Parameter DEV_CHIRP_K_TIMEOUT_8BIT configures the maximum time 5.8 ms in number clocks 
  // for assertion of device chirp after detection SE0 on the bus for reset 
  parameter DEV_CHIRP_K_TIMEOUT_8BIT = 348000;
  wire [31:0] pw_DEV_CHIRP_K_TIMEOUT_8BIT = DEV_CHIRP_K_TIMEOUT_8BIT;

  // Parameter DEV_CHIRP_K_TIMEOUT_16BIT configures the maximum time 5.8ms in number of 
  // clocks for assertion of device chirp after detection SE0 on the bus for reset 
  parameter DEV_CHIRP_K_TIMEOUT_16BIT = 174000;
  wire [31:0] pw_DEV_CHIRP_K_TIMEOUT_16BIT = DEV_CHIRP_K_TIMEOUT_16BIT;

  // Parameter  DEV_CHIRP_K_DEASS_TIMEOUT_8BIT configures the maximum clocks before 
  // which device chirp has to be deasserted after it is asserted
  parameter DEV_CHIRP_K_DEASS_TIMEOUT_8BIT = 420000;
  wire [31:0] pw_DEV_CHIRP_K_DEASS_TIMEOUT_8BIT = DEV_CHIRP_K_DEASS_TIMEOUT_8BIT;

  // Parameter  DEV_CHIRP_K_DEASS_TIMEOUT_16BIT configures the maximum clocks before which 
  // device chirp has to be deasserted after it is asserted
  parameter DEV_CHIRP_K_DEASS_TIMEOUT_16BIT = 210000;
  wire [31:0] pw_DEV_CHIRP_K_DEASS_TIMEOUT_16BIT = DEV_CHIRP_K_DEASS_TIMEOUT_16BIT;

  // Parameter DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT configures the maximum time 6ms
  // in clocks before which device chirp has to be asserted after entering
  // handshake mode
  parameter DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT   = 360000;
  wire [31:0] pw_DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT = DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT;

  // Parameter DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT configures the maximum time
  // 6ms in clocks before which device chirp has to be asserted after entering
  // handshake mode
  parameter DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT   = 180000;
  wire [31:0] pw_DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT = DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT;

  // Parameter DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT configures the minimum time 5ms in clocks 
  // before which a device capable of remote wake up must not initiate resume
  parameter DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT = 300000;
  wire [31:0] pw_DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT = DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT;

  // Parameter DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT configures the minimum clocks before
  // which a device capable of remote wake up must not initiate resume
  parameter DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT = 150000;
  wire [31:0] pw_DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT = DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT;

  // Parameter RESUME_K_MIN_ASSERT_8BIT configures the minimum clocks
  // for which resume K must be asserted 
  parameter RESUME_K_MIN_ASSERT_8BIT =  60000;
  wire [31:0] pw_RESUME_K_MIN_ASSERT_8BIT = RESUME_K_MIN_ASSERT_8BIT;

  // Parameter RESUME_K_MIN_ASSERT_16BIT configures the minimum clocks
  // for which resume K must be asserted 
  parameter RESUME_K_MIN_ASSERT_16BIT =  30000;
  wire [31:0] pw_RESUME_K_MIN_ASSERT_16BIT = RESUME_K_MIN_ASSERT_16BIT;

  // Parameter RESUME_K_MAX_ASSERT_8BIT configures the maximum clocks
  // for which resume K can be asserted 
  parameter RESUME_K_MAX_ASSERT_8BIT = 900000;
  wire [31:0] pw_RESUME_K_MAX_ASSERT_8BIT = RESUME_K_MAX_ASSERT_8BIT;

  // Parameter RESUME_K_MAX_ASSERT_16BIT configures the maximum clocks
  // for which resume K can be asserted 
  parameter RESUME_K_MAX_ASSERT_16BIT = 450000;
  wire [31:0] pw_RESUME_K_MAX_ASSERT_16BIT = RESUME_K_MAX_ASSERT_16BIT;

  // Parameter RESUME_K_DURATION_LINE_STATE_8BIT configures the minimum clocks for
  // which resume K must be found on the line_state
  parameter RESUME_K_DURATION_LINE_STATE_8BIT = 1200000;
  wire [31:0] pw_RESUME_K_DURATION_LINE_STATE_8BIT = RESUME_K_DURATION_LINE_STATE_8BIT;

  // Parameter RESUME_K_DURATION_LINE_STATE_16BIT configures the minimum clocks for
  // which resume K must be found on the line_state
  parameter RESUME_K_DURATION_LINE_STATE_16BIT = 600000;
  wire [31:0] pw_RESUME_K_DURATION_LINE_STATE_16BIT = RESUME_K_DURATION_LINE_STATE_16BIT;

  // Parameter RESUME_NORMAL_OPER_TIMEOUT_8BIT configures the maximum clock before
  // which the device should resume normal operation after coming out of
  // resume sequence  
  parameter RESUME_NORMAL_OPER_TIMEOUT_8BIT = 75;
  wire [31:0] pw_RESUME_NORMAL_OPER_TIMEOUT_8BIT = RESUME_NORMAL_OPER_TIMEOUT_8BIT;

  // Parameter RESUME_NORMAL_OPER_TIMEOUT_16BIT configures the maximum clock before
  // which the device should resume normal operation after coming out of
  // resume sequence  
  parameter RESUME_NORMAL_OPER_TIMEOUT_16BIT = 38;
  wire [31:0] pw_RESUME_NORMAL_OPER_TIMEOUT_16BIT = RESUME_NORMAL_OPER_TIMEOUT_16BIT;

  // Parameter SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT configures maximum delay for
  // assertion of FS 'K' on the bus after suspendm is asserted
  parameter SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT = 600000;
  wire [31:0]  pw_SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT = 
                  SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT;

  // Parameter SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT configures maximum delay for
  // assertion of FS 'K' on the bus after suspendm is asserted
  parameter SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT = 300000;
  wire [31:0] pw_SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT = 
                 SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT;

  // Parameter HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT configures the
  // recovery time after reversal to full speed mode before which
  // host_disconnect signal cannot be updated
  parameter HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT = 240000;
  wire [31:0] pw_HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT =
                 HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT;

  // Parameter HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT configures the
  // recovery time after reversal to full speed mode before which
  // host_disconnect signal cannot be updated
  parameter HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT = 120000;
  wire [31:0] pw_HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT = 
                 HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT;

  // Parameters related to Inter PAcket delay, Max PAcket Size.

  // Parameter which decides the width of the XcvrSelect
  parameter XCVR_WIDTH = (UTMI_LEVEL == 0 || UTMI_LEVEL == 1)?1:2;
  // Input port declarations.

  input clock; // Active on the rising edge only.
  input reset; // Active high. 
  input areset; // Active high.

  input tx_valid; // Transmit data 'data_in_low' is valid.
  input [7:0] data_in_low; 

  input tx_valid_h; // Transmit data 'data_in_high' is valid.
  input [7:0] data_in_high;
 
  input tx_ready; // Transmit ready signal

  input rx_valid; // Receive data 'data_out_low' is valid.
  input [7:0] data_out_low; 

  input rx_valid_h; // Receive data 'data_out_high' is valid.
  input [7:0] data_out_high;
  input rx_active;
  input rx_error;

  input databus16_8; // 1 - 16 bit, 0 - 8 bit interface.
  input [1:0] line_state; // Line status signal.
  input [XCVR_WIDTH-1:0] xcvr_select; // Selects between FS and HS transceiver
  input term_select; // Selects between FS and HS termination
  input [1:0] op_mode; // Selects between normal and disable NRZI and bit stuffing 
  input suspendm; // Places the Macrocell in a mode that draws minimal power from supplies

  input [7:0] data_low; // Bidirectional data
  input [7:0] data_high; // Bidirectional data
  input valid_h; // 'data_high' is valid.

  input id_pullup; // Enables analog Id lines
  input id_dig;    // Selects between mini-A or mini-B
  input a_valid;   // Indicates if A-Perip session is valid
  input b_valid;   // Indicates if B-Perip session is valid
  input vbus_valid;// Indicates voltage on Vbus is valid
  input sess_end;  // Vbus is below its B-Dev Session End threshold
  input drv_vbus;  // Signal enables to drive 5V on Vbus
  input dischrg_vbus; // Signal enables discharging Vbus
  input chrg_vbus;  // Signal enables charging of Vbus
  input dp_pulldown; // Enables the 15k Ohm pull-down resistor on the DP line
  input dm_pulldown; // Enables the 15k Ohm pull-down resistor on the DM line.
  input host_disconnect; // Indicates weather a peripheral is connected or not

  input [6:0] address; // Address of the device.
  input [NUMBER_OF_ENDPOINTS * 21 - 1:0] end_point_config; // End point info.
  input [4:0] number_of_active_endpoints;  

  parameter MAC_LAYER_CONSTRAINT = (UTMI_SIDE == 0 && Constraints_Mode);
  parameter PHY_LAYER_CONSTRAINT = (UTMI_SIDE == 1 && Constraints_Mode);

  // Input port declarations.

  wire reset_sampled; 
  wire areset_sampled; 
  wire tx_valid_sampled; 
  wire [7:0] data_in_low_sampled; 
  wire tx_valid_h_sampled;
  wire [7:0] data_in_high_sampled;
  wire tx_ready_sampled; 
  wire rx_valid_sampled;
  wire [7:0] data_out_low_sampled; 
  wire rx_valid_h_sampled;
  wire [7:0] data_out_high_sampled;
  wire rx_active_sampled;
  wire rx_error_sampled;
  wire databus16_8_sampled;
  wire [1:0] line_state_sampled;
  wire [XCVR_WIDTH-1:0]xcvr_select_sampled;
  wire term_select_sampled;
  wire [1:0] op_mode_sampled;
  wire suspendm_sampled;
  wire [7:0] data_low_sampled;
  wire [7:0] data_high_sampled;
  wire valid_h_sampled;
  wire id_pullup_sampled;
  wire id_dig_sampled;
  wire a_valid_sampled;
  wire b_valid_sampled;
  wire vbus_valid_sampled;
  wire sess_end_sampled;
  wire drv_vbus_sampled;
  wire dischrg_vbus_sampled;
  wire chrg_vbus_sampled;
  wire dp_pulldown_sampled;
  wire dm_pulldown_sampled;
  wire host_disconnect_sampled;
  wire [6:0] address_sampled;

  reg  [(NUMBER_OF_ENDPOINTS * 21) - 1 :0] end_point_config_sampled;  
  wire [(NUMBER_OF_ENDPOINTS * 21) - 1 :0] end_point_config_tmp;  

  wire [4:0] number_of_active_endpoints_sampled;  

  integer i;

  // Assignments

  assign `QVL_DUT2CHX_DELAY reset_sampled                = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled               = areset;
  assign `QVL_DUT2CHX_DELAY tx_valid_sampled             = tx_valid;
  assign `QVL_DUT2CHX_DELAY data_in_low_sampled          = data_in_low;
  assign `QVL_DUT2CHX_DELAY tx_valid_h_sampled           = tx_valid_h;
  assign `QVL_DUT2CHX_DELAY data_in_high_sampled         = data_in_high;
  assign `QVL_DUT2CHX_DELAY tx_ready_sampled             = tx_ready;
  assign `QVL_DUT2CHX_DELAY rx_valid_sampled             = rx_valid;
  assign `QVL_DUT2CHX_DELAY data_out_low_sampled         = data_out_low;
  assign `QVL_DUT2CHX_DELAY rx_valid_h_sampled           = rx_valid_h;
  assign `QVL_DUT2CHX_DELAY data_out_high_sampled        = data_out_high;
  assign `QVL_DUT2CHX_DELAY rx_active_sampled            = rx_active;
  assign `QVL_DUT2CHX_DELAY rx_error_sampled             = rx_error;
  assign `QVL_DUT2CHX_DELAY databus16_8_sampled          = databus16_8;
  assign `QVL_DUT2CHX_DELAY line_state_sampled           = line_state;
  assign `QVL_DUT2CHX_DELAY xcvr_select_sampled          = xcvr_select;
  assign `QVL_DUT2CHX_DELAY op_mode_sampled              = op_mode;
  assign `QVL_DUT2CHX_DELAY suspendm_sampled             = suspendm;
  assign `QVL_DUT2CHX_DELAY term_select_sampled          = term_select;
  assign `QVL_DUT2CHX_DELAY data_low_sampled             = data_low;
  assign `QVL_DUT2CHX_DELAY data_high_sampled            = data_high;
  assign `QVL_DUT2CHX_DELAY valid_h_sampled              = valid_h;
  assign `QVL_DUT2CHX_DELAY id_pullup_sampled            = id_pullup;    
  assign `QVL_DUT2CHX_DELAY id_dig_sampled               = id_dig;          
  assign `QVL_DUT2CHX_DELAY a_valid_sampled              = a_valid;         
  assign `QVL_DUT2CHX_DELAY b_valid_sampled              = b_valid;         
  assign `QVL_DUT2CHX_DELAY vbus_valid_sampled           = vbus_valid;      
  assign `QVL_DUT2CHX_DELAY sess_end_sampled             = sess_end;        
  assign `QVL_DUT2CHX_DELAY drv_vbus_sampled             = drv_vbus;        
  assign `QVL_DUT2CHX_DELAY dischrg_vbus_sampled         = dischrg_vbus;    
  assign `QVL_DUT2CHX_DELAY chrg_vbus_sampled            = chrg_vbus;       
  assign `QVL_DUT2CHX_DELAY dp_pulldown_sampled          = dp_pulldown;
  assign `QVL_DUT2CHX_DELAY dm_pulldown_sampled          = dm_pulldown;
  assign `QVL_DUT2CHX_DELAY host_disconnect_sampled      = host_disconnect;
  assign `QVL_DUT2CHX_DELAY address_sampled              = address;

  assign `QVL_DUT2CHX_DELAY number_of_active_endpoints_sampled = (^number_of_active_endpoints === 'bx) ? NUMBER_OF_ENDPOINTS 
                                                                                                       : number_of_active_endpoints;

  assign `QVL_DUT2CHX_DELAY end_point_config_tmp     = end_point_config;

  always @(end_point_config_tmp or number_of_active_endpoints_sampled)
  begin
    for (i = 0; i <= ((NUMBER_OF_ENDPOINTS * 21) - 1); i = i+1)
    begin
      if(i < (21*number_of_active_endpoints_sampled))
        end_point_config_sampled[i] = end_point_config_tmp[i];
      else
        end_point_config_sampled[i] = 1'b0;
    end
  end


    qvl_usb_2_0_utmi_logic #(
            .Constraints_Mode (Constraints_Mode),
            .UTMI_LEVEL(UTMI_LEVEL),
            .PORT_TYPE (PORT_TYPE),
            .UTMI_SIDE (UTMI_SIDE),
            .BI_DIRECTIONAL (BI_DIRECTIONAL),
            .DEVICE_SPEED (DEVICE_SPEED),
            .NUMBER_OF_ENDPOINTS (NUMBER_OF_ENDPOINTS),
            .FRAME_INTERVAL_COUNT (FRAME_INTERVAL_COUNT),
            .SEQUENCE_BIT_TRACKING_ENABLE (SEQUENCE_BIT_TRACKING_ENABLE),
            .PACKET_ISSUE_CHECK_ENABLE (PACKET_ISSUE_CHECK_ENABLE),
            .RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN (RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MIN),
            .RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX (RX_ACTIVE_DEASSERT_TO_TX_VALID_ASSERT_DELAY_MAX),
            .TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN (TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MIN),
            .TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX (TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_DELAY_MAX),
            .TIME_OUT_COUNT (TIME_OUT_COUNT),
            .OTG_DEVICE (OTG_DEVICE),
            .HUB_TURNAR_TIMEOUT_16BIT (HUB_TURNAR_TIMEOUT_16BIT),   
            .HUB_TURNAR_TIMEOUT_8BIT (HUB_TURNAR_TIMEOUT_8BIT),   
            .HUB_CHIRP_TIMEOUT_16BIT (HUB_CHIRP_TIMEOUT_16BIT),   
            .HUB_CHIRP_TIMEOUT_8BIT (HUB_CHIRP_TIMEOUT_8BIT),   
            .TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT (TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_8BIT),   
            .TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT (TERM_SEL_DEASS_AFTER_HS_DETECT_TIMEOUT_16BIT),   
            .SE0_COUNT_MAX_FULL_SPEED_REVERSE_8BIT (SE0_COUNT_MAX_FULL_SPEED_REVERSE_8BIT),   
            .SE0_COUNT_MAX_FULL_SPEED_REVERSE_16BIT (SE0_COUNT_MAX_FULL_SPEED_REVERSE_16BIT),   
            .SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT (SE0_COUNT_MIN_FULL_SPEED_REVERSE_8BIT),   
            .SE0_COUNT_MIN_FULL_SPEED_REVERSE_16BIT (SE0_COUNT_MIN_FULL_SPEED_REVERSE_16BIT),   
            .FULL_SPEED_SE0_RESET_TIMEOUT_8BIT (FULL_SPEED_SE0_RESET_TIMEOUT_8BIT),   
            .FULL_SPEED_SE0_RESET_TIMEOUT_16BIT (FULL_SPEED_SE0_RESET_TIMEOUT_16BIT),   
            .FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT (FULL_SPEED_J_SUSPEND_TIMEOUT_8BIT),   
            .FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT (FULL_SPEED_J_SUSPEND_TIMEOUT_16BIT),   
            .LINE_STATE_DEBOUNCE_TIMEOUT_8BIT (LINE_STATE_DEBOUNCE_TIMEOUT_8BIT),   
            .LINE_STATE_DEBOUNCE_TIMEOUT_16BIT (LINE_STATE_DEBOUNCE_TIMEOUT_16BIT),   
            .CLK_USABLE_TIMEOUT_8BIT (CLK_USABLE_TIMEOUT_8BIT),   
            .CLK_USABLE_TIMEOUT_16BIT (CLK_USABLE_TIMEOUT_16BIT),   
            .MIN_RESET_INTERVAL_8BIT (MIN_RESET_INTERVAL_8BIT),   
            .MIN_RESET_INTERVAL_16BIT (MIN_RESET_INTERVAL_16BIT),   
            .CHIRP_KJ_START_TIMEOUT_8BIT (CHIRP_KJ_START_TIMEOUT_8BIT),   
            .CHIRP_KJ_START_TIMEOUT_16BIT (CHIRP_KJ_START_TIMEOUT_16BIT),   
            .DEV_CHIRP_K_TIMEOUT_8BIT (DEV_CHIRP_K_TIMEOUT_8BIT),   
            .DEV_CHIRP_K_TIMEOUT_16BIT (DEV_CHIRP_K_TIMEOUT_16BIT),   
            .DEV_CHIRP_K_DEASS_TIMEOUT_8BIT (DEV_CHIRP_K_DEASS_TIMEOUT_8BIT),   
            .DEV_CHIRP_K_DEASS_TIMEOUT_16BIT (DEV_CHIRP_K_DEASS_TIMEOUT_16BIT),   
            .DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT (DEV_CHIRP_K_ASSERT_TIMEOUT_8BIT),   
            .DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT (DEV_CHIRP_K_ASSERT_TIMEOUT_16BIT),   
            .DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT (DEV_MIN_REMOTE_WAKE_UP_COUNT_8BIT),   
            .DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT (DEV_MIN_REMOTE_WAKE_UP_COUNT_16BIT),   
            .RESUME_K_MIN_ASSERT_8BIT (RESUME_K_MIN_ASSERT_8BIT),   
            .RESUME_K_MIN_ASSERT_16BIT (RESUME_K_MIN_ASSERT_16BIT),   
            .RESUME_K_MAX_ASSERT_8BIT (RESUME_K_MAX_ASSERT_8BIT),   
            .RESUME_K_MAX_ASSERT_16BIT (RESUME_K_MAX_ASSERT_16BIT),   
            .RESUME_K_DURATION_LINE_STATE_8BIT (RESUME_K_DURATION_LINE_STATE_8BIT),   
            .RESUME_K_DURATION_LINE_STATE_16BIT (RESUME_K_DURATION_LINE_STATE_16BIT),   
            .RESUME_NORMAL_OPER_TIMEOUT_8BIT (RESUME_NORMAL_OPER_TIMEOUT_8BIT),   
            .RESUME_NORMAL_OPER_TIMEOUT_16BIT (RESUME_NORMAL_OPER_TIMEOUT_16BIT),          
            .SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT (SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_8BIT),
            .SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT (SUSPENDM_DEASSERT_TO_RESUME_K_ASSERT_TIMEOUT_16BIT),
            .HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT (HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_8BIT),
            .HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT (HOST_DISCONNECT_UPDATE_RECOVERY_TIMEOUT_16BIT)
            )
    qvl_usb_2_0_utmi (
            .clock                (clock),
            .reset                (reset_sampled),
            .areset               (areset_sampled),
            .tx_valid             (tx_valid_sampled),
            .data_in_low          (data_in_low_sampled),
            .tx_valid_h           (tx_valid_h_sampled),
            .data_in_high         (data_in_high_sampled),
            .tx_ready             (tx_ready_sampled),
            .rx_valid             (rx_valid_sampled),
            .data_out_low         (data_out_low_sampled),
            .rx_valid_h           (rx_valid_h_sampled),
            .data_out_high        (data_out_high_sampled),
            .rx_active            (rx_active_sampled),
            .rx_error             (rx_error_sampled),
            .databus16_8          (databus16_8_sampled),
            .line_state           (line_state_sampled),
            .xcvr_select          (xcvr_select_sampled),
            .term_select          (term_select_sampled),
            .op_mode              (op_mode_sampled),
            .suspendm             (suspendm_sampled),
            .data_low             (data_low_sampled),
            .data_high            (data_high_sampled),
            .valid_h              (valid_h_sampled),
            .id_pullup            (id_pullup_sampled),
            .id_dig               (id_dig_sampled),
            .a_valid              (a_valid_sampled),
            .b_valid              (b_valid_sampled),
            .vbus_valid           (vbus_valid_sampled),
            .sess_end             (sess_end_sampled),
            .drv_vbus             (drv_vbus_sampled),
            .dischrg_vbus         (dischrg_vbus_sampled),
            .chrg_vbus            (chrg_vbus_sampled),   
            .dp_pulldown          (dp_pulldown_sampled),
            .dm_pulldown          (dm_pulldown_sampled),
            .host_disconnect      (host_disconnect_sampled), 
            .address              (address_sampled),
            .end_point_config     (end_point_config_sampled),
            .number_of_active_endpoints(number_of_active_endpoints_sampled)
    );

`qvlendmodule


