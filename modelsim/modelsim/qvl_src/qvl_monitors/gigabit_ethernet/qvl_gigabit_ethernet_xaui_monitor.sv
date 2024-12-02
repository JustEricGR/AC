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
/***********************************************************************
 * PURPOSE       This file is part of the 0-In CheckerWare.
 *               It describes the Gigabit Ethernet XAUI monitor.
 *
 * DESCRIPTION   This monitor checks the 10 Gigabit Etherent frames on
 *               the XAUI serial/10-bit symbol interface for violations
 *               with respect to encapsulation, alignment etc and also
 *               instantiates the MAC monitor to check for field errors.
 *
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002 
 *               802.3ae Amendment: Media Access Control (MAC) Parameters, 
 *               Physical Layers, and Management Parameters for 10 Gb/s
 *               Operation, 2002. 
 *
 * INPUTS        areset     - asynchronous reset (active high)
 *               reset      - synchronous reset (active high)
 *               dl_clk     - destination interface clock
 *               sl_clk     - source interface clock
 *               sl0_p      - source lane 0 (serial/symbol)
 *               sl1_p      - source lane 1 (serial/symbol)
 *               sl2_p      - source lane 2 (serial/symbol)
 *               sl3_p      - source lane 3 (serial/symbol)
 *               dl0_p      - destination lane 0 (serial/symbol)
 *               dl1_p      - destination lane 1 (serial/symbol)
 *               dl2_p      - destination lane 2 (serial/symbol)
 *               dl3_p      - destination lane 3 (serial/symbol)
 * 
 * MONITOR INSTANTIATION
 *
 *                  1. Applicable only when XGXS is implemented
 *                  ------------------------------------------
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
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | XGMII
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |  XGXS - Optional XGMII Extender  |
 *                  |                                  | 
 *                  |        +--------------+          | 
 *                  |        | XAUI MONITOR |          | 
 *                  |        +------+-+-----+          | 
 *                  |               | |                | 
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | |
 *                                  | |
 *                                  | | XAUI
 *                                  | |
 *                                  | |
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |               | |                | 
 *                  |        +------+-+-----+          | 
 *                  |        | XAUI MONITOR |          | 
 *                  |        +--------------+          | 
 *                  |                                  | 
 *                  |  XGXS - Optional XGMII Extender  |
 *                  +---------------+-+----------------+
 *                                  | |
 *                                  | | XGMII
 *                                  | |
 *                  +---------------+-+----------------+
 *                  |  PCS - Physical Coding Sublayer  |  P
 *                  +----------------------------------+  H
 *                  | PMA - Physical Medium Attachment |  Y
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

`qvlmodule qvl_gigabit_ethernet_xaui_monitor (areset,
                                            reset,
                                            dl_clk,
                                            sl_clk,
                                            sl0_p,
                                            sl1_p,
                                            sl2_p,
                                            sl3_p,
                                            dl0_p,
                                            dl1_p,
                                            dl2_p,
                                            dl3_p
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

  // The Jumbo frames do not carry length information with them and therefore 
  // the length is fixed for a given simulation.

  parameter JUMBO_FRAME_DATA_LENGTH = 9126;
  wire [31:0] pw_JUMBO_FRAME_DATA_LENGTH = JUMBO_FRAME_DATA_LENGTH;
 
  // Set this parameter to 0 to disable checking for usage of reserved
  // values in fields. By default, these checks will be performed.
 
  parameter RESERVED_VALUE_CHECK_ENABLE = 1;
  wire [31:0] pw_RESERVED_VALUE_CHECK_ENABLE = RESERVED_VALUE_CHECK_ENABLE;

  // Parameter SYMBOL_MODE = 1 indicates a parallel (symbol) 10-bit interface.
  // The default of 0 implies a serial interface. 

  parameter SYMBOL_MODE = 0;
  wire [31:0] pw_SYMBOL_MODE = SYMBOL_MODE;

  // Parameter BYPASS_DESKEW = 1 indicates bypass of deskew logic. The default
  // of 1 attempts to deskew the lanes before proceeding.

  parameter BYPASS_DESKEW = 0;
  wire [31:0] pw_BYPASS_DESKEW = BYPASS_DESKEW;

  parameter DIC_SUPPORTED = 0;
  wire [31:0] pw_DIC_SUPPORTED = DIC_SUPPORTED;

  parameter MAC_MIN_TAGGED_FRAME_SIZE_68 = 0;
  wire [31:0] pw_MAC_MIN_TAGGED_FRAME_SIZE_68 = MAC_MIN_TAGGED_FRAME_SIZE_68;

  parameter RESERVED_CONTROL_FRAME_SUPPORTED = 0;
  wire [31:0] pw_RESERVED_CONTROL_FRAME_SUPPORTED = RESERVED_CONTROL_FRAME_SUPPORTED;

  parameter ZI_DATA_WIDTH = (SYMBOL_MODE == 0) ? 1 : 10;
  wire [31:0] pw_DATA_WIDTH = ZI_DATA_WIDTH;

  input areset;
  input reset;
  input dl_clk;
  input sl_clk;
  input [ZI_DATA_WIDTH-1:0] sl0_p;
  input [ZI_DATA_WIDTH-1:0] sl1_p;
  input [ZI_DATA_WIDTH-1:0] sl2_p;
  input [ZI_DATA_WIDTH-1:0] sl3_p;
  input [ZI_DATA_WIDTH-1:0] dl0_p;
  input [ZI_DATA_WIDTH-1:0] dl1_p;
  input [ZI_DATA_WIDTH-1:0] dl2_p;
  input [ZI_DATA_WIDTH-1:0] dl3_p;

  wire areset_sampled;
  wire reset_sampled;
  wire [ZI_DATA_WIDTH-1:0] sl0_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] sl1_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] sl2_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] sl3_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] dl0_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] dl1_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] dl2_p_sampled;
  wire [ZI_DATA_WIDTH-1:0] dl3_p_sampled;
 
  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY reset_sampled = reset;
  assign `QVL_DUT2CHX_DELAY sl0_p_sampled = sl0_p; 
  assign `QVL_DUT2CHX_DELAY sl1_p_sampled = sl1_p;
  assign `QVL_DUT2CHX_DELAY sl2_p_sampled = sl2_p;
  assign `QVL_DUT2CHX_DELAY sl3_p_sampled = sl3_p;
  assign `QVL_DUT2CHX_DELAY dl0_p_sampled = dl0_p;
  assign `QVL_DUT2CHX_DELAY dl1_p_sampled = dl1_p; 
  assign `QVL_DUT2CHX_DELAY dl2_p_sampled = dl2_p;
  assign `QVL_DUT2CHX_DELAY dl3_p_sampled = dl3_p;
  
  qvl_gigabit_ethernet_xaui_logic
    #(.Constraints_Mode(Constraints_Mode),
      .MAC_SIDE(MAC_SIDE),
      .JUMBO_FRAME_DATA_LENGTH(JUMBO_FRAME_DATA_LENGTH),
      .RESERVED_VALUE_CHECK_ENABLE(RESERVED_VALUE_CHECK_ENABLE),
      .SYMBOL_MODE(SYMBOL_MODE),
      .BYPASS_DESKEW(BYPASS_DESKEW),
      .DIC_SUPPORTED(DIC_SUPPORTED),
      .ZI_DATA_WIDTH(ZI_DATA_WIDTH),
      .MAC_MIN_TAGGED_FRAME_SIZE_68(MAC_MIN_TAGGED_FRAME_SIZE_68),
      .RESERVED_CONTROL_FRAME_SUPPORTED(RESERVED_CONTROL_FRAME_SUPPORTED)
     )
  qvl_gigabit_ethernet_xaui (.dl_clk(dl_clk),
                             .sl_clk(sl_clk),
                             .areset(areset_sampled),
                             .reset(reset_sampled),
                             .sl0_p(sl0_p_sampled),
                             .sl1_p(sl1_p_sampled),
                             .sl2_p(sl2_p_sampled),
                             .sl3_p(sl3_p_sampled),
                             .dl0_p(dl0_p_sampled),
                             .dl1_p(dl1_p_sampled),
                             .dl2_p(dl2_p_sampled),
                             .dl3_p(dl3_p_sampled)
                           );
`qvlendmodule // qvl_gigabit_ethernet_xaui_monitor
