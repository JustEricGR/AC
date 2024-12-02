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
* DESCRIPTION This monitor checks the USB 2.0 interface for compliance with
*             USB 2.0 specification and protocol.  
* 
* REFERENCES  Universal Serial Bus Specification, Revision 2.0, April 27 
*             2000.
*             Errata for USB 2.0 specification, May 28, 2002
*             Errata for USB 2.0 specification, December 7, 2002
* 
* INPUTS      clock                      - Clock. 
*             reset                      - Synchronous reset, active high.
*             areset                     - Asynchronous reset, active high.
*             dp                         - Data plus input/output. 
*             dm                         - Data minus input/output. 
*             oe_n                       - Output enable, active low.
*             speed                      - Speed input.
*             address                    - Device address.
*             end_point_config           - End point configuration input. 
*             number_of_active_endpoints - Number of active endpoints.
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
*             4. Clock frequency should be same as the data rate of the USB
*                interface. For a High speed interface connect 480Mhz clock 
*                to this input. For a full speed interface connect 12Mhz clock
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
*       |  HOST          |    High /Full speed      |     FUNCTION    |
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
*       |                |      High / Full speed   |                 |  
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
*        |  HUB           |   High,Full or Low speed |   FUNCTION      |
*        |                |                          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        |                |                          |                 | 
*        +----------------+                          +-----------------+
* 
**************************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_usb_2_0_monitor (
                              clock,
                              reset,
                              areset,
                              dp,
                              dm,
                              oe_n,
			                  speed,
                              address,
			                  end_point_config,
                              number_of_active_endpoints
                              );

  // Parameter Constraints_Mode = 1 will configure some checks in this
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

  parameter FRAME_INTERVAL_COUNT = 60000;
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

  // Parameter OTG_DEVICE configures the monitor to track OTG compliant
  // USB devices. By default, non OTG compliant devices are tracked.

  parameter OTG_DEVICE = 0;
  wire [31:0] pw_OTG_DEVICE = OTG_DEVICE;

  // Parameter HUB_SETUP_INTERVAL configures the Hub setup time. this
  // time is required to enable the low speed ports connected to
  // low speed ports of the hub. This time is specified interms of
  // full speed bit times. This parameter is valid only when the monitor
  // is instantiated on ports other than upstream port of the function
  // and in an full speed environment between Host and Hub.

  parameter HUB_SETUP_INTERVAL = 4;
  wire [31:0] pw_HUB_SETUP_INTERVAL = HUB_SETUP_INTERVAL;

  // Input declarations

  input clock;
  input reset;
  input areset;
  input dp;
  input dm;
  input oe_n;
  input [1:0] speed;
  input [6:0] address;

  // Input end_point_config specifies the configuration details
  // for each the end point. This port contains all the information
  // regarding all the end points that needs to tracked by the monitor.
  // Fallowing encoding scheme should be utilized to specify the 
  // end point configuration.
  // End point encoding scheme used for each end point is as follows.
  // A3 A2 A1 A0 D T2 T1 T0 O1 O0 S9 to S0 is the bit fields of a 21 bit reg.
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
  // S10 to S0 specifies the wMaxpacketsize. The maximum packet size
  // supported by this end point.
  // O1 O0 specify the additional transaction oppertunity per microframe
  // This field is required for high bandwidth end points.
  //
  // 0 0     None         (1 Transaction per microframe).
  // 0 1     1 Additional (2 Transactions per microframe).
  // 1 0     2 Additional (3 Transactions per micrframe).
  // 1 1     Reserved. 

  input [(NUMBER_OF_ENDPOINTS * 21) - 1 :0] end_point_config;  
  input [4:0] number_of_active_endpoints;  


  wire reset_sampled;
  wire areset_sampled;
  wire dp_sampled;
  wire dm_sampled;
  wire oe_n_sampled;
  wire [1:0] speed_sampled;
  wire [6:0] address_sampled;

  reg  [(NUMBER_OF_ENDPOINTS * 21) - 1 :0] end_point_config_sampled;  
  wire [(NUMBER_OF_ENDPOINTS * 21) - 1 :0] end_point_config_tmp;  
  wire [4:0] number_of_active_endpoints_sampled;  

  integer i;

  assign `QVL_DUT2CHX_DELAY reset_sampled                      = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled                     = areset;
  assign `QVL_DUT2CHX_DELAY dp_sampled                         = dp;
  assign `QVL_DUT2CHX_DELAY dm_sampled                         = dm;
  assign `QVL_DUT2CHX_DELAY oe_n_sampled                       = oe_n;
  assign `QVL_DUT2CHX_DELAY speed_sampled                      = speed;
  assign `QVL_DUT2CHX_DELAY address_sampled                    = address;
  assign `QVL_DUT2CHX_DELAY number_of_active_endpoints_sampled = (^number_of_active_endpoints === 'bx) ? NUMBER_OF_ENDPOINTS 
                                                                                                       : number_of_active_endpoints;

  assign `QVL_DUT2CHX_DELAY end_point_config_tmp = end_point_config;

  always @(end_point_config_tmp or number_of_active_endpoints_sampled)
  begin
    for (i = 0; i < (NUMBER_OF_ENDPOINTS * 21); i = i+1)
    begin
      if(i < (21*number_of_active_endpoints_sampled))
        end_point_config_sampled[i] = end_point_config_tmp[i];
      else
        end_point_config_sampled[i] = 1'b0;
    end
  end


  qvl_usb_2_0_logic         #(
                             .Constraints_Mode (Constraints_Mode),
                             .PORT_TYPE (PORT_TYPE),
                             .NUMBER_OF_ENDPOINTS (NUMBER_OF_ENDPOINTS),
                             .FRAME_INTERVAL_COUNT (FRAME_INTERVAL_COUNT),
                             .SEQUENCE_BIT_TRACKING_ENABLE (SEQUENCE_BIT_TRACKING_ENABLE),
                             .PACKET_ISSUE_CHECK_ENABLE (PACKET_ISSUE_CHECK_ENABLE),
                             .OTG_DEVICE (OTG_DEVICE),
                             .HUB_SETUP_INTERVAL (HUB_SETUP_INTERVAL)
                             )
  qvl_usb_2_0 (.clock           (clock),
              .reset            (reset_sampled),
              .areset           (areset_sampled),
              .dp               (dp_sampled),
              .dm               (dm_sampled),
              .oe_n             (oe_n_sampled),
	          .speed            (speed_sampled),
              .address          (address_sampled),
	          .end_point_config (end_point_config_sampled),
              .number_of_active_endpoints(number_of_active_endpoints_sampled)
              );

`qvlendmodule
   

