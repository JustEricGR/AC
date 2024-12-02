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
 *               It describes the Ethernet RGMII Monitor.
 *
 * DESCRIPTION   This monitor checks the Etherent frames for alignment
 *               related violations and malformed packets by observing
 *               the RGMII (Reduced Gigabit Media Independent I/F).
 *               This module internally instantiates two link monitors,
 *               one each for the Tx link and the Rx link respectively. 
 *               
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002
 *
 * INPUTS        areset - asynchronous reset (active high)
 *               reset  - synchronous reset (active high)
 *               txc    - transmit interface clock
 *               td     - transmit data (4-bit SDR)
 *               tx_ctl - transmit control signal 
 *               rxc    - receive interface clock
 *               rd     - receive data (4-bit SDR)
 *               rx_ctl - receive control signal
 *
 *
 * MONITOR INSTANTIATION
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
 *                  |        | RGMII MONITOR |         |  Y
 *                  |        +------+-+------+         |  E
 *                  |               | |                |  R
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | RGMII
 *                                  | |
 *                  +---------------+-+----------------+  P
 *                  |               | |                |  H
 *                  |        +------+-+------+         |  Y
 *                  |        | RGMII MONITOR |         | 
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
 * LAST MODIFIED 07 December 2004
 *
 *********************************************************************/
`include "std_qvl_defines.h"
`qvlmodule qvl_gigabit_ethernet_rgmii_monitor (areset,
                                               reset,
                                               txc,
                                               td,
                                               tx_ctl,
                                               rxc,
                                               rd,
                                               rx_ctl
                                              );

  // Parameter Constraints_Mode = 0, will configure some checks in this
  // monitor as constraints during formal analysis.

  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter MAC_SIDE = 1, will indicate as to which side of the RGMII link
  // monitor is instantiated. This parameter, along with the Constraints
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

  parameter SLOT_TIME = 512;
  wire [31:0] pw_SLOT_TIME = SLOT_TIME ;

  parameter JAM_SIZE = 32;
  wire [31:0] pw_JAM_SIZE = JAM_SIZE ;

  parameter BURST_LIMIT = 65536;
  wire [31:0] pw_BURST_LIMIT = BURST_LIMIT ;

  parameter DUPLEX_MODE_INDICATION = 0;
  wire [31:0] pw_DUPLEX_MODE_INDICATION = DUPLEX_MODE_INDICATION ;

  parameter CLK_SPEED_INDICATION = 0;
  wire [31:0] pw_CLK_SPEED_INDICATION = CLK_SPEED_INDICATION ;


  parameter ZI_CONSTRAINT_MAC_SIDE = (Constraints_Mode == 1 &&
                                      MAC_SIDE == 1);
  parameter ZI_CONSTRAINT_PHY_SIDE = (Constraints_Mode == 1 &&
                                      MAC_SIDE == 0);
  
  parameter ZI_PREAMBLE_FIELD = 8'h55;
  parameter ZI_SFD_FIELD = 8'hD5;

  input areset;
  input reset;
  input txc;
  input [3:0] td;
  input tx_ctl;
  input rxc;
  input [3:0] rd;
  input rx_ctl;

  wire areset_sampled;
  wire reset_sampled;
  wire [3:0] td_sampled;
  wire tx_ctl_sampled;
  wire [3:0] rd_sampled;
  wire rx_ctl_sampled;

  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY reset_sampled  = reset;
  assign `QVL_DUT2CHX_DELAY td_sampled     = td; 
  assign `QVL_DUT2CHX_DELAY tx_ctl_sampled = tx_ctl;
  assign `QVL_DUT2CHX_DELAY rd_sampled     = rd;
  assign `QVL_DUT2CHX_DELAY rx_ctl_sampled = rx_ctl;
  
  qvl_gigabit_ethernet_rgmii_logic
    #(.Constraints_Mode(Constraints_Mode),
      .MAC_SIDE(MAC_SIDE),
      .JUMBO_FRAME_DATA_LENGTH(JUMBO_FRAME_DATA_LENGTH),
      .RESERVED_VALUE_CHECK_ENABLE(RESERVED_VALUE_CHECK_ENABLE),
      .HALF_DUPLEX(HALF_DUPLEX),
      .MAC_MIN_TAGGED_FRAME_SIZE_68(MAC_MIN_TAGGED_FRAME_SIZE_68),
      .RESERVED_CONTROL_FRAME_SUPPORTED(RESERVED_CONTROL_FRAME_SUPPORTED),
      .ZI_CONSTRAINT_MAC_SIDE(ZI_CONSTRAINT_MAC_SIDE),
      .ZI_CONSTRAINT_PHY_SIDE(ZI_CONSTRAINT_PHY_SIDE),
      .ZI_PREAMBLE_FIELD(ZI_PREAMBLE_FIELD),
      .ZI_SFD_FIELD(ZI_SFD_FIELD),
      .SLOT_TIME(SLOT_TIME),
      .JAM_SIZE(JAM_SIZE),
      .DUPLEX_MODE_INDICATION(DUPLEX_MODE_INDICATION),
      .CLK_SPEED_INDICATION(CLK_SPEED_INDICATION)
     )
  qvl_gigabit_ethernet_rgmii (.areset(areset_sampled),
                              .reset(reset_sampled),
                              .txc(txc),
                              .td(td_sampled),
                              .tx_ctl(tx_ctl_sampled),
                              .rxc(rxc),   
                              .rd(rd_sampled),
                              .rx_ctl(rx_ctl_sampled)
                             );
`qvlendmodule // qvl_gigabit_ethernet_rgmii_monitor
