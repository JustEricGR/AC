//              Copyright 2006-2007 Mentor Graphics Corporation           
//                           All Rights Reserved.                           
//                                                                          
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY             
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS          
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE         
//                                  TERMS.                                  
//                                                                          
//
/***********************************************************************
 * PURPOSE       This file is part of the 0-In CheckerWare.
 *               It describes the Gigabit Ethernet XGMII Monitor.
 *
 * DESCRIPTION   This monitor checks the 10 Gigabit Etherent frames for
 *               alignment related violations and malformed packets by 
 *               observing the XGMII (10 Gigabit Media Independent I/F).
 *               This module internally instantiates two link monitors,
 *               one each for the Tx link and the Rx link respectively. 
 *               
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002
 *               802.3ae Amendment: Media Access Control (MAC) Parameters, 
 *               Physical Layers, and Management Parameters for 10 Gb/s 
 *               Operation, 2002.
 *
 * INPUTS        areset - asynchronous reset (active high)
 *               reset  - synchronous reset (active high)
 *               tx_clk - transmit interface clock
 *               txd    - transmit data (32-bit DDR or 64-bit SDR)
 *               txc    - transmit control (4-bit DDR or 8-bit SDR)
 *               rx_clk - receive interface clock
 *               rxd    - receive data (32-bit DDR or 64-bit SDR)
 *               rxc    - receive control (4-bit DDR or 8-bit SDR)
 *
 *
 * MONITOR INSTANTIATION
 * 
 *                  1. Without XGXS implemented
 *                  ---------------------------
 *                          
 *                                  + +
 *                                  | |
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |    LLC - Logical Link Control    |
 *                  +----------------------------------+
 *                  |      MAC Control (optional)      |  L
 *                  +----------------------------------+  I
 *                  |    MAC - Media Access Control    |  N
 *                  +----------------------------------+  K
 *                  |   RS - Reconciliation Sublayer   |
 *                  |                                  |  L
 *                  |        +---------------+         |  A
 *                  |        | XGMII MONITOR |         |  Y
 *                  |        +------+-+------+         |  E
 *                  |               | |                |  R
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | XGMII
 *                                  | |
 *                  +---------------+-+----------------+  P
 *                  |               | |                |  H
 *                  |        +------+-+------+         |  Y
 *                  |        | XGMII MONITOR |         | 
 *                  |        +---------------+         |  L
 *                  |                                  |  A
 *                  |  PCS - Physical Coding Sublayer  |  Y
 *                  +----------------------------------+  E
 *                  | PMA - Physical Medium Attachment |  R
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | |
 *                                  + +
 *
 *
 *                  2. With XGXS implemented
 *                  ------------------------
 *
 *                                  + +
 *                                  | |
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |    LLC - Logical Link Control    |
 *                  +----------------------------------+
 *                  |      MAC Control (optional)      |  L
 *                  +----------------------------------+  I
 *                  |    MAC - Media Access Control    |  N
 *                  +----------------------------------+  K
 *                  |   RS - Reconciliation Sublayer   |
 *                  |                                  |  L
 *                  |        +---------------+         |  A
 *                  |        | XGMII MONITOR |         |  Y
 *                  |        +------+-+------+         |  E
 *                  |               | |                |  R
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | XGMII
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |               | |                | 
 *                  |        +------+-+------+         | 
 *                  |        | XGMII MONITOR |         | 
 *                  |        +---------------+         | 
 *                  |                                  | 
 *                  |  XGXS - Optional XGMII Extender  |
 *                  +----------------------------------+
 *                                  | |
 *                                  | |
 *                                  | |
 *                                  | | XAUI
 *                                  | |
 *                                  | |
 *                                  | |
 *                  +----------------------------------+
 *                  |  XGXS - Optional XGMII Extender  |
 *                  |                                  | 
 *                  |        +---------------+         | 
 *                  |        | XGMII MONITOR |         | 
 *                  |        +------+-+------+         | 
 *                  |               | |                | 
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | XGMII
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |               | |                |  P
 *                  |        +------+-+------+         |  H
 *                  |        | XGMII MONITOR |         |  Y
 *                  |        +---------------+         | 
 *                  |                                  |  L
 *                  |  PCS - Physical Coding Sublayer  |  A
 *                  +----------------------------------+  Y
 *                  | PMA - Physical Medium Attachment |  E
 *                  +---------------+-+----------------+  R
 *                                  | |
 *                                  | |
 *                                  + +
 *
 *
 * LAST MODIFIED 07 December 2004
 *
 *********************************************************************/
`include "std_qvl_defines.h"
`qvlmodule qvl_gigabit_ethernet_xgmii_monitor (areset,
                                             reset,
                                             tx_clk,
                                             txd,
                                             txc,
                                             rx_clk,
                                             rxd,
                                             rxc
                                            );

  // Parameter Constraints_Mode = 0, will configure some checks in this
  // monitor as constraints during formal analysis.

  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter MAC_SIDE = 1, will indicate that the monitor is instantiated
  // on the XGMII interface either at the RS or on the second XGXS (if the 
  // XAUI is implemented) after converting from XAUI to XGMII. A value of 
  // 0 on this parameter will indicate that the monitor is instantiated on 
  // an XGMII interface on that side of the link that is closer to the PHY.
  // This parameter is used in constraining the correct side in case of the
  // formal analysis.

  parameter MAC_SIDE = 1;
  wire [31:0] pw_MAC_SIDE = MAC_SIDE;
  
  // Set this parameter to the desired length of Jumbo frames. The default
  // length of Jumbo frames is taken to be 9K bytes (9126 bytes).

  parameter JUMBO_FRAME_DATA_LENGTH = 9126;
  wire [31:0] pw_JUMBO_FRAME_DATA_LENGTH = JUMBO_FRAME_DATA_LENGTH;

  // Set this parameter to 0 to disable checking for usage of reserved 
  // values in fields. By default, these checks will be performed.

  parameter RESERVED_VALUE_CHECK_ENABLE = 1;
  wire [31:0] pw_RESERVED_VALUE_CHECK_ENABLE = RESERVED_VALUE_CHECK_ENABLE;

  // This parameter indicates whether the XGMII interface is a standard 
  // dual-edge 32-bit interface (4 lanes) or the alternative single-edge
  // 64-bit (8 lanes corresponding to 2 columns of data in one period of
  // the standard dual-edge XGMII. By default, a dual-edge XGMII will be
  // assumed. Set this to 0 to indicate a single-edge XGMII. 

  parameter DDR = 1;
  wire [31:0] pw_DDR = DDR;

  parameter DIC_SUPPORTED = 0;
  wire [31:0] pw_DIC_SUPPORTED = DIC_SUPPORTED;

  parameter MAC_MIN_TAGGED_FRAME_SIZE_68 = 0;
  wire [31:0] pw_MAC_MIN_TAGGED_FRAME_SIZE_68 = MAC_MIN_TAGGED_FRAME_SIZE_68;

  parameter RESERVED_CONTROL_FRAME_SUPPORTED = 0;
  wire [31:0] pw_RESERVED_CONTROL_FRAME_SUPPORTED = RESERVED_CONTROL_FRAME_SUPPORTED;

  // These are internal parameters used to derive the data and control
  // width depending on whether the interface is dual/single rate.

  parameter ZI_DATA_WIDTH = (DDR === 1) ? 32 : 64;
  wire [31:0] pw_DATA_WIDTH = ZI_DATA_WIDTH;

  parameter ZI_CTRL_WIDTH = (DDR === 1) ? 4 : 8;
  wire [31:0] pw_CTRL_WIDTH = ZI_CTRL_WIDTH;


  input areset;
  input reset;
  input tx_clk;
  input [ZI_DATA_WIDTH-1:0] txd;
  input [ZI_CTRL_WIDTH-1:0] txc;
  input rx_clk;
  input [ZI_DATA_WIDTH-1:0] rxd;
  input [ZI_CTRL_WIDTH-1:0] rxc;

  wire areset_sampled;
  wire reset_sampled;
  wire [ZI_DATA_WIDTH-1:0] txd_sampled;
  wire [ZI_CTRL_WIDTH-1:0] txc_sampled;
  wire [ZI_DATA_WIDTH-1:0] rxd_sampled;
  wire [ZI_CTRL_WIDTH-1:0] rxc_sampled;

 assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
 assign `QVL_DUT2CHX_DELAY reset_sampled = reset;
 assign `QVL_DUT2CHX_DELAY txd_sampled = txd;
 assign `QVL_DUT2CHX_DELAY txc_sampled = txc;
 assign `QVL_DUT2CHX_DELAY rxd_sampled = rxd;
 assign `QVL_DUT2CHX_DELAY rxc_sampled = rxc;
 
  qvl_gigabit_ethernet_xgmii_logic
    #(.Constraints_Mode(Constraints_Mode),
      .MAC_SIDE(MAC_SIDE),
      .JUMBO_FRAME_DATA_LENGTH(JUMBO_FRAME_DATA_LENGTH),
      .RESERVED_VALUE_CHECK_ENABLE(RESERVED_VALUE_CHECK_ENABLE),
      .DDR(DDR),
      .ZI_DATA_WIDTH(ZI_DATA_WIDTH),
      .ZI_CTRL_WIDTH(ZI_CTRL_WIDTH),
      .DIC_SUPPORTED(DIC_SUPPORTED),
      .MAC_MIN_TAGGED_FRAME_SIZE_68(MAC_MIN_TAGGED_FRAME_SIZE_68),
      .RESERVED_CONTROL_FRAME_SUPPORTED(RESERVED_CONTROL_FRAME_SUPPORTED)         
     )
  qvl_gigabit_ethernet_xgmii(.tx_clk(tx_clk),
                             .rx_clk(rx_clk),
                             .areset(areset_sampled),
                             .reset(reset_sampled),
                             .txd(txd_sampled),
                             .txc(txc_sampled),
                             .rxd(rxd_sampled),
                             .rxc(rxc_sampled)
                            );

`qvlendmodule // qvl_gigabit_ethernet_xgmii_monitor
