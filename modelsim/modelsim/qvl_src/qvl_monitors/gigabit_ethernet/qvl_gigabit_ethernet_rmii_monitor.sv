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
 *               It describes the Ethernet RMII Monitor.
 *
 * DESCRIPTION   This monitor checks the 100 Mbps Etherent frames for
 *               alignment related violations and malformed packets by 
 *               observing the RMII (100 Mbps Media Independent I/F).
 *               This module internally instantiates two link monitors,
 *               one each for the Tx link and the Rx link respectively. 
 *               
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002
 *
 * INPUTS        areset      - asynchronous reset (active high)
 *               reset       - synchronous reset (active high)
 *               ref_clk     - transmit and receive interface clock
 *               txd         - transmit data (2-bit SDR)
 *               tx_en       - transmit enable 
 *               rxd         - receive data (2-bit SDR)
 *               crs_dv      - receive data valid
 *               rx_er       - receive error
 *
 *
 * MONITOR INSTANTIATION
 *                  
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
 *                  +----------------------------------+ 
 *                  |           RMII Interface         |  L
 *                  |        +---------------+         |  A
 *                  |        |  RMII MONITOR |         |  Y
 *                  |        +------+-+------+         |  E
 *                  |               | |                |  R
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | RMII
 *                                  | |
 *                  +---------------+-+----------------+  P
 *                  |               | |                |  H
 *                  |        +------+-+------+         |  Y
 *                  |        |  RMII MONITOR |         | 
 *                  |        +---------------+         |  L
 *                  |           RMII Interface         |  A
 *                  +----------------------------------+  Y
 *                  |  PCS - Physical Coding Sublayer  |  E
 *                  +----------------------------------+  R
 *                  | PMA - Physical Medium Attachment |  
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | |
 *                                  + +
 *
 *
 * LAST MODIFIED 30 Jan 2009
 *
 *********************************************************************/
`include "std_qvl_defines.h"
`qvlmodule qvl_gigabit_ethernet_rmii_monitor (areset,
                                              reset,
                                              ref_clk,
                                              txd,
                                              tx_en,
                                              rxd,
                                              crs_dv,
                                              rx_er
                                             );

  // Parameter Constraints_Mode = 0, will configure some checks in this
  // monitor as constraints during formal analysis.

  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter MAC_SIDE = 1, will indicate as to which side of the  RMII link
  // the monitor is instantiated. This parameter, along with the Constraints
  // Mode parameter is used in constraining the correct side in case of the
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

  // Set this parameter to 1 if the monitor is instantiated on a Half 
  // Duplex link. The default value of 1 indicates that the monitor is 
  // instantiated on a full duplex interface.

  parameter HALF_DUPLEX = 0;
  wire [31:0] pw_HALF_DUPLEX = HALF_DUPLEX;

  parameter MAC_MIN_TAGGED_FRAME_SIZE_68 = 0;
  wire [31:0] pw_MAC_MIN_TAGGED_FRAME_SIZE_68 = MAC_MIN_TAGGED_FRAME_SIZE_68;

  parameter RESERVED_CONTROL_FRAME_SUPPORTED = 0;
  wire [31:0] pw_RESERVED_CONTROL_FRAME_SUPPORTED = RESERVED_CONTROL_FRAME_SUPPORTED;

  parameter SLOT_TIME = 64;
  wire [31:0] pw_SLOT_TIME = SLOT_TIME;

  parameter JAM_SIZE = 32;
  wire [31:0] pw_JAM_SIZE = JAM_SIZE;

  parameter ZI_CONSTRAINT_MAC_SIDE = (Constraints_Mode == 1 &&
                                      MAC_SIDE == 1);
  parameter ZI_CONSTRAINT_PHY_SIDE = (Constraints_Mode == 1 &&
                                      MAC_SIDE == 0);

  input areset;
  input reset;
  input ref_clk;
  input [1:0] txd;
  input tx_en;
  input [1:0] rxd;
  input crs_dv;
  input rx_er;

  wire areset_sampled;
  wire reset_sampled;
  wire [1:0] txd_sampled;
  wire tx_en_sampled;
  wire [1:0] rxd_sampled;
  wire crs_dv_sampled;
  wire rx_er_sampled;

  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY reset_sampled  = reset;
  assign `QVL_DUT2CHX_DELAY txd_sampled    = txd;
  assign `QVL_DUT2CHX_DELAY tx_en_sampled  = tx_en;
  assign `QVL_DUT2CHX_DELAY rxd_sampled    = rxd;
  assign `QVL_DUT2CHX_DELAY crs_dv_sampled = crs_dv;
  assign `QVL_DUT2CHX_DELAY rx_er_sampled  = rx_er;

  qvl_gigabit_ethernet_rmii_logic
    #(.Constraints_Mode(Constraints_Mode),
     .MAC_SIDE(MAC_SIDE),
     .JUMBO_FRAME_DATA_LENGTH(JUMBO_FRAME_DATA_LENGTH),
     .RESERVED_VALUE_CHECK_ENABLE(RESERVED_VALUE_CHECK_ENABLE),
     .HALF_DUPLEX(HALF_DUPLEX),
     .MAC_MIN_TAGGED_FRAME_SIZE_68(MAC_MIN_TAGGED_FRAME_SIZE_68),
     .RESERVED_CONTROL_FRAME_SUPPORTED(RESERVED_CONTROL_FRAME_SUPPORTED),
     .SLOT_TIME(SLOT_TIME),
     .JAM_SIZE(JAM_SIZE),
     .ZI_CONSTRAINT_MAC_SIDE(ZI_CONSTRAINT_MAC_SIDE),
     .ZI_CONSTRAINT_PHY_SIDE(ZI_CONSTRAINT_PHY_SIDE)
     )
  qvl_gigabit_ethernet_rmii (.ref_clk(ref_clk),
                             .areset(areset_sampled),
                             .reset(reset_sampled),
                             .txd(txd_sampled),
                             .tx_en(tx_en_sampled),
                             .rxd(rxd_sampled),
                             .crs_dv(crs_dv_sampled),
                             .rx_er(rx_er_sampled)
                            );

`qvlendmodule
