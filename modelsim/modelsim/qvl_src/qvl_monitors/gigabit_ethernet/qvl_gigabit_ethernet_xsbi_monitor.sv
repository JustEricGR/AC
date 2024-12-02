//              Copyright 2006-2007 Mentor Graphics Corporation      
//                           All Rights Reserved.                           
//                                                                          
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY             
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS          
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE         
//                                  TERMS.                                  
//                                                                          
/***********************************************************************
 * PURPOSE       This file is part of the 0-In CheckerWare.
 *               It describes the Gigabit Ethernet XSBI Monitor.
 *
 * DESCRIPTION   This monitor checks the Gigabit Etherent frames for
 *               violations and malformed frames by observing the XSBI
 *               interface of the 10GBase-R family of physical layers.
 *
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002
 *               802.3ae Amendment: Media Access Control (MAC) Parameters,
 *               Physical Layers, and Management Parameters for 10 Gb/s
 *               Operation, 2002.
 *
 * INPUTS        areset            - asynchronous reset (active high)
 *               reset             - synchronous reset (active high)
 *               tx_clk            - transmit interface clock
 *               rx_clk            - receive interface clock
 *               txd               - transmit data (16-bit)
 *               rxd               - receive data (16-bit)
 *               bypass_descramble - descrambler bypass signal
 *
 * MONITOR INSTANTIATION
 *
 *                1. Applicable only in case of 10GBASE-R PHYs
 *                --------------------------------------------
 *
 *                                + +
 *                                | |
 *                                | |
 *                +---------------+-+----------------+
 *                |    LLC - Logical Link Control    |
 *                +----------------------------------+
 *                |      MAC Control (optional)      |  L
 *                +----------------------------------+  I
 *                |    MAC - Media Access Control    |  N
 *                +----------------------------------+  K
 *                |   RS - Reconciliation Sublayer   |
 *                +---------------+-+----------------+
 *                                | |
 *                                | | XGMII
 *                                | |
 *               +---------------+-+------------------+
 *               | 10GBASE-R Physical Coding Sublayer |
 *               |                                    |  
 *               |         +--------------+           |  
 *               |         | XSBI MONITOR |           |  
 *               |         +------+-+-----+           |  
 *               |                | |                 |  
 *               +----------------+-+-----------------+
 *                                | |
 *                                | |
 *                                | | XSBI
 *                                | |
 *                                | |
 *                +---------------+-+----------------+
 *                |        Serial PMA / WIS          |  P
 *                +----------------------------------+  H
 *                | PMD - Physical Medium Dependent  |  Y
 *                +---------------+-+----------------+
 *                                | |
 *                                | |
 *                                + +
 *
 *
 * LAST MODIFIED 07 December 2004
 *
 *********************************************************************/
`include "std_qvl_defines.h"

`qvlmodule qvl_gigabit_ethernet_xsbi_monitor (areset,
                                            reset,
                                            tx_clk,
                                            rx_clk,
                                            txd,
                                            rxd,
                                            bypass_descramble
                                           );

  // Parameter Constraints_Mode = 0, will configure some checks in this
  // monitor as constraints during formal analysis. 
 
  parameter Constraints_Mode = 0; 
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  // Parameter MAC_SIDE = 1, will indicate that the monitor is instantiated
  // on the XSBI interface either on PCS (MAC_SIDE = 1) or closer on the 
  // the PMA (closer to PHY). This parameter is used in constraining the 
  // correct side in case of the formal analysis.
 
  parameter MAC_SIDE = 1;
  wire [31:0] pw_MAC_SIDE = MAC_SIDE;
 
  // Jumbo frame size is fixed for a given simulation run. Set this parameter 
  // to the desired length of Jumbo frames. The default length of Jumbo frames 
  // is taken to be 9K bytes (9126 bytes). Note that the upper limit for Jumbo 
  // frame size is 12K bytes since this is the maximum possible payload for 
  // 32-bit CRC.

  parameter JUMBO_FRAME_DATA_LENGTH = 9126;
  wire [31:0] pw_JUMBO_FRAME_DATA_LENGTH = JUMBO_FRAME_DATA_LENGTH;

  // Set this parameter to 0 to disable checking for usage of reserved
  // values in fields. By default, these checks will be performed.

  parameter RESERVED_VALUE_CHECK_ENABLE = 1;                       
  wire [31:0] pw_RESERVED_VALUE_CHECK_ENABLE = RESERVED_VALUE_CHECK_ENABLE;

  // Parameter BYPASS_BLOCK_SYNC = 1 will bypass the block synchronization 
  // process and assume that the blocks are coming in aligned from first data.
  // To enable block synchronization set this parameter to 0.

  parameter BYPASS_BLOCK_SYNC = 1;
  wire [31:0] pw_BYPASS_BLOCK_SYNC = BYPASS_BLOCK_SYNC;

  parameter DIC_SUPPORTED = 0;
  wire [31:0] pw_DIC_SUPPORTED = DIC_SUPPORTED;

  parameter MAC_MIN_TAGGED_FRAME_SIZE_68 = 0;
  wire [31:0] pw_MAC_MIN_TAGGED_FRAME_SIZE_68 = MAC_MIN_TAGGED_FRAME_SIZE_68;

  parameter RESERVED_CONTROL_FRAME_SUPPORTED = 0;
  wire [31:0] pw_RESERVED_CONTROL_FRAME_SUPPORTED = RESERVED_CONTROL_FRAME_SUPPORTED;
  
  input areset;
  input reset;
  input tx_clk;
  input rx_clk;
  input [15:0] txd;
  input [15:0] rxd;
  input bypass_descramble;

  wire areset_sampled;
  wire reset_sampled;
  wire [15:0] txd_sampled;
  wire [15:0] rxd_sampled;
  wire bypass_descramble_sampled;
  
  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY reset_sampled = reset;
  assign `QVL_DUT2CHX_DELAY txd_sampled = txd;
  assign `QVL_DUT2CHX_DELAY rxd_sampled = rxd;
  assign `QVL_DUT2CHX_DELAY bypass_descramble_sampled = bypass_descramble;

  qvl_gigabit_ethernet_xsbi_logic
    #(.Constraints_Mode(Constraints_Mode),
      .MAC_SIDE(MAC_SIDE),
      .JUMBO_FRAME_DATA_LENGTH(JUMBO_FRAME_DATA_LENGTH),
      .RESERVED_VALUE_CHECK_ENABLE(RESERVED_VALUE_CHECK_ENABLE),
      .BYPASS_BLOCK_SYNC(BYPASS_BLOCK_SYNC),
      .DIC_SUPPORTED(DIC_SUPPORTED),
      .MAC_MIN_TAGGED_FRAME_SIZE_68(MAC_MIN_TAGGED_FRAME_SIZE_68),
      .RESERVED_CONTROL_FRAME_SUPPORTED(RESERVED_CONTROL_FRAME_SUPPORTED)
     )
  qvl_gigabit_ethernet_xsbi(.tx_clk(tx_clk),
                            .rx_clk(rx_clk),
                            .areset(areset_sampled),
                            .reset(reset_sampled),
                            .txd(txd_sampled),
                            .rxd(rxd_sampled),
                            .bypass_descramble(bypass_descramble_sampled)
                           );

`qvlendmodule // zi_cw_gigabit_ethernet_xsbi_monitor
