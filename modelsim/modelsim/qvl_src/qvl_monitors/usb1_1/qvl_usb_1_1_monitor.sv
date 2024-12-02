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
* DESCRIPTION This monitor checks the USB 1.1 interface for compliance with
*             USB 1.1 specification and protocol.  
* 
* REFERENCES  Universal Serial Bus Specification, Revision 1.1, September 23
*             1998.  
* 
* INPUTS      clock                   - Clock. 
*             reset                   - Synchronous reset, active high.
*             areset                  - Asynchronous reset, active high.
*             dp                      - Data plus input/output. 
*             dm                      - Data minus input/output. 
*             oe_n                    - Output enable, active low.
*             speed                   - Speed input.
*             address                 - Device address.
*             end_point_config        - End point configuration input. 
*
* NOTES   
*
*             1. Monitor should be instantiated in the interface between 
*                USB transceiver and USB controller. This controller can
*                be a host controller, HUB controller or a device 
*                controller.
* 
*             2. Input dp is an input to the USB transceiver when oe_n is 
*                asserted, and output from the transceiver when oe_n is 
*                deasserted.
*
*             3. Input dm is an input to the USB transceiver when oe_n is 
*                asserted, and output from the transceiver when oe_n is 
*                deasserted.
*
*             4. Clk frequency should be same as the data rate of the USB
*                interface. For a full speed interface connect 12Mhz clock
*                to this input. For a low speed interface connect 1.5Mhz
*                clock to this input. This clock will be used to sample 
*                data on the USB bus.
* 
* MONITOR INSTANTIATION 
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
*       |  HOST          |    Full speed            |     FUNCTION    |
*       |                |                          |                 |  
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
*       |                |      Full speed          |                 |  
*       |  HOST          |                          |    FUNCTION     |
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
*        |  HUB           |   Full or Low speed      |   FUNCTION      |
*        |                |                          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        +----------------+                          +-----------------+
* 
* 
**************************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_usb_1_1_monitor (
                              clock,
                              reset,
                              areset,
                              dp,
                              dm,
                              oe_n,
			      speed,
                              address,
			      end_point_config
                              );
                         
  // Parameter Constraints_Mode = 0 will configure some checks in this
  // monitor as constraints during 0-In Search.

  parameter Constraints_Mode = 0; 
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter PORT_TYPE configures the port type which will be tracked by  
  // the monitor. PORT_TYPE = 0 configures the monitor to track the 
  // transactions of the downstream port of the Host. PORT_TYPE = 1 
  // configures the monitor to track the transactions of the upstream port
  // of Hub. PORT_TYPE = 2 configures the monitor to track the transactions 
  // of the downstream port of Hub. PORT_TYPE = 3 configures the monitor to
  // track transactions of upstream port of a function. This information, 
  // along with the value of parameter Constraints_Mode will decide the checks
  // to be turned into constraints during 0-In Search.
     
  parameter PORT_TYPE = 0;
  wire [31:0] pw_PORT_TYPE = PORT_TYPE;

  // Parameter NUMBER_OF_ENDPOINTS configures the number of end points 
  // to be tracked by the monitor. By default, monitor is configured
  // to track only one end point.

  parameter NUMBER_OF_ENDPOINTS = 1;
  wire [31:0] pw_NUMBER_OF_ENDPOINTS = NUMBER_OF_ENDPOINTS;

  // Parameter FRAME_INTERVAL_COUNT indicates the number of clock cycles
  // between two successive SOF packets (USB specification specifies
  // an interval of 1ms between frames. This time duration needs to be mapped
  // into number of clock cycles). Typicaly 12000 clock cycles occur in a 
  // full speed interface. 

  parameter FRAME_INTERVAL_COUNT = 12000;
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

  // Parameter HUB_SETUP_INTERVAL configures the Hub setup time. this
  // time is required to enable the low speed ports connected to
  // low speed ports of the hub. This time is specified interms of
  // full speed bit times. This parameter is valid only when the monitor
  // is instantiated on ports other than upstream port of the function.

  parameter HUB_SETUP_INTERVAL = 4;
  wire [31:0] pw_HUB_SETUP_INTERVAL = HUB_SETUP_INTERVAL;

  // Parameter DISCONNECT_COUNT configures the number of cycles
  // se0 should be asserted by the device to indicate disconnect.

  parameter DISCONNECT_COUNT = 20;
  wire [31:0] pw_DISCONNECT_COUNT = DISCONNECT_COUNT;

  // Parameter CONTROL_XFR_MAX_PKT_SIZE configures the maximum packet size
  // supported for Control transfers. Allowed values are 8,16,32 or 64. For
  // low speed devices maximum packet size for control transfer is 8.

  parameter CONTROL_XFR_MAX_PKT_SIZE = 8;
  wire [31:0] pw_CONTROL_XFR_MAX_PKT_SIZE = CONTROL_XFR_MAX_PKT_SIZE;

  // Parameter ISO_XFR_MAX_PKT_SIZE configures the maximum packet size
  // supported for Isochronous transfers. Low speed devices should not
  // support Isochronous type end points.

  parameter ISO_XFR_MAX_PKT_SIZE = 1023;
  wire [31:0] pw_ISO_XFR_MAX_PKT_SIZE = ISO_XFR_MAX_PKT_SIZE;

  // Parameter INTERRUPT_XFR_MAX_PKT_SIZE configures the maximum packet size  
  // supported for Interrupt transfers. For low speed devices maximum packet   
  // size for interrupt transfers is 8. 
 
  parameter INTERRUPT_XFR_MAX_PKT_SIZE = 64; 
  wire [31:0] pw_INTERRUPT_XFR_MAX_PKT_SIZE = INTERRUPT_XFR_MAX_PKT_SIZE;

  // Parameter INTERRUPT_XFR_LS_MAX_PKT_SIZE configures the maximum packet 
  // size supported for low speed interrupt end points.

  parameter INTERRUPT_XFR_LS_MAX_PKT_SIZE = 8;
  wire [31:0] pw_INTERRUPT_XFR_LS_MAX_PKT_SIZE = INTERRUPT_XFR_LS_MAX_PKT_SIZE;
 
  // Parameter BULK_XFR_MAX_PKT_SIZE configures the maximum packet size
  // supported for Bulk transfers. Allowed values are 8,16,32 or 64. Low
  // speed devices should not support bulk transfer type end point.

  parameter BULK_XFR_MAX_PKT_SIZE = 8;
  wire [31:0] pw_BULK_XFR_MAX_PKT_SIZE = BULK_XFR_MAX_PKT_SIZE; 

  // Input declarations

  input clock;
  input reset;
  input areset;
  input dp;
  input dm;
  input oe_n;
  input speed;
  input [6:0] address;

  // Input end_point_config specifies the configuration details
  // for each the end point. This port contains all the information
  // regarding all the end points that needs to tracked by the monitor.
  // Fallowing encoding scheme should be utilized to specify the 
  // end point configuration.
  // End point encoding scheme used for each end point is as follows.
  // A3 A2 A1 A0 D T2 T1 T0 S9 to S0 is the bit fields of a 18 bit register.
  // A3 bit is the MSB and S0 bit is the LSB of the 18 bit register.
  // A3 A2 A1 A0 bits specifies the address of the end point.
  // T1 T0 bit indicates whether type of the end point. D bit gives the
  // direction of the end point. D = '0' indicates OUT direction.
  // D = '1' indicates IN direction.
  // T2 T1 T0 decoding is as follows.
  // 0  0  0  ---> Undefined
  // 0  0  1  ---> Control Transfer
  // 0  1  0  ---> Interrupt Transfer
  // 0  1  1  ---> Bulk Transfer
  // 1  0  0  ---> ISO Transfer.
  // S9 to S0 specifies the wMaxpacketsize. The maximum packet size
  // supported by this end point.

  input [NUMBER_OF_ENDPOINTS * 18 - 1 :0] end_point_config; 


  wire reset_sampled;
  wire areset_sampled;
  wire dp_sampled;
  wire dm_sampled;
  wire oe_n_sampled;
  wire speed_sampled;
  wire [6:0] address_sampled;
  wire [NUMBER_OF_ENDPOINTS * 18 - 1 :0] end_point_config_sampled;


  assign `QVL_DUT2CHX_DELAY reset_sampled            = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled           = areset;
  assign `QVL_DUT2CHX_DELAY dp_sampled               = dp;
  assign `QVL_DUT2CHX_DELAY dm_sampled               = dm;
  assign `QVL_DUT2CHX_DELAY oe_n_sampled             = oe_n;
  assign `QVL_DUT2CHX_DELAY speed_sampled            = speed;
  assign `QVL_DUT2CHX_DELAY address_sampled          = address;
  assign `QVL_DUT2CHX_DELAY end_point_config_sampled = end_point_config;

  qvl_usb_1_1_logic        #(
                             .Constraints_Mode (Constraints_Mode),
                             .PORT_TYPE        (PORT_TYPE),
                             .NUMBER_OF_ENDPOINTS (NUMBER_OF_ENDPOINTS),
                             .FRAME_INTERVAL_COUNT (FRAME_INTERVAL_COUNT),
                             .SEQUENCE_BIT_TRACKING_ENABLE (SEQUENCE_BIT_TRACKING_ENABLE),
                             .PACKET_ISSUE_CHECK_ENABLE (PACKET_ISSUE_CHECK_ENABLE),
                             .HUB_SETUP_INTERVAL (HUB_SETUP_INTERVAL),
                             .DISCONNECT_COUNT (DISCONNECT_COUNT),
                             .CONTROL_XFR_MAX_PKT_SIZE (CONTROL_XFR_MAX_PKT_SIZE),
                             .ISO_XFR_MAX_PKT_SIZE (ISO_XFR_MAX_PKT_SIZE),
                             .INTERRUPT_XFR_MAX_PKT_SIZE (INTERRUPT_XFR_MAX_PKT_SIZE),
                             .INTERRUPT_XFR_LS_MAX_PKT_SIZE (INTERRUPT_XFR_LS_MAX_PKT_SIZE),
                             .BULK_XFR_MAX_PKT_SIZE (BULK_XFR_MAX_PKT_SIZE)
                             )
  qvl_usb_1_1 (
              .clock (clock),
              .reset (reset_sampled),
              .areset (areset_sampled),
              .dp (dp_sampled),
              .dm (dm_sampled),
              .oe_n (oe_n_sampled),
              .speed (speed_sampled),
              .address (address_sampled),
              .end_point_config (end_point_config_sampled)
              );

`qvlendmodule 

    
  


































