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
 * PURPOSE      This file is part of 0-In CheckerWare.
 *              It describes the DDR2 SDRAM monitor.
 *
 * REFERENCE    JEDEC DDR-II SDRAM Data Sheet, JC 42.3, December 2000
 *
 * DESCRIPTION  This monitor checks if the DDR2 SDRAM memory interface 
 *              functions properly.
 *
 * INPUTS       areset       - Asynchronous reset.
 *              reset        - Synchronous reset.
 *              ck           - Input differential clock.
 *              ck_n         - Input differential clock.
 *              cke          - Clock Enable. 
 *              cs_n         - Chip Select. 
 *              ras_n        - Row Address Strobe.   
 *              cas_n        - Column Address Strobe. 
 *              we_n         - Write Enable. 
 *              dm           - Data Mask.    
 *              ba           - Bank Address.
 *              a            - Address bus. 
 *              dq           - Data bus.
 *              dqs          - Data Strobe. 
 * 
 * USAGE        The monitor should be instantiated as shown below:
 *
 *
 *            +---------------+                 +---------------+
 *            |               |--- ck        -->|               | 
 *            | +-----------+ |--- ck_n      -->|               | 
 *            | |DDR2 SDRAM | |--- cke       -->|  DDR2 SDRAM   | 
 *            | |Monitor    | |--- cs_n      -->|               | 
 *            | +-----------+ |--- ras_n     -->|               | 
 *            |               |--- cas_n     -->|               | 
 *            |               |--- we_n      -->|               | 
 *            | DDR2 SDRAM    |--- dm        -->|               | 
 *            | Controller    |--- ba        -->|               | 
 *            |               |--- a         -->|               | 
 *            |               |<-- dq        -->|               | 
 *            |               |<-- dqs       -->|               | 
 *            |               |                 |               | 
 *            +---------------+                 +---------------+
 *
 *                                 (OR)
 *
 *            +---------------+                 +---------------+
 *            |               |--- ck        -->|               | 
 *            |               |--- ck_n      -->|               | 
 *            |               |--- cke       -->|  DDR2 SDRAM   | 
 *            |               |--- cs_n      -->|               | 
 *            | DDR2 SDRAM    |--- ras_n     -->|               | 
 *            | Controller    |--- cas_n     -->|               | 
 *            |               |--- we_n      -->|               | 
 *            |               |--- dm        -->| +-----------+ |
 *            |               |--- ba        -->| |DDR2 SDRAM | | 
 *            |               |--- a         -->| |Monitor    | |
 *            |               |<-- dq        -->| +-----------+ |
 *            |               |<-- dqs       -->|               | 
 *            |               |                 |               | 
 *            +---------------+                 +---------------+
 *
 * LAST MODIFIED : 06 April 2006
 *
 **************************************************************************/

`include "std_qvl_defines.h"


`qvlmodule qvl_ddr2_sdram_monitor (ck, 
				 ck_n,
				 areset,
				 reset,
				 cke,
				 cs_n,
				 ras_n, 
				 cas_n,
				 we_n,
				 dm,
				 ba,
				 a,
				 dq,
				 dqs
                                );

  parameter Constraints_Mode = 0; // 0in constraint
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter CONTROLLER_SIDE = 1; // 1 implies monitor is instantiated on the
                                 // controller side. else memory side  
  wire [31:0] pw_CONTROLLER_SIDE = CONTROLLER_SIDE;

  parameter ROW_ADDR_WIDTH = 13; // Size of address bus equals row_addr_width
  wire [31:0] pw_ROW_ADDR_WIDTH = ROW_ADDR_WIDTH;

  parameter DATA_BUS_WIDTH = 8; // Width of the Data Bus
  wire [31:0] pw_DATA_BUS_WIDTH = DATA_BUS_WIDTH;

  parameter DM_WIDTH = 1; // Width of the Data Mask
  wire [31:0] pw_DM_WIDTH = DM_WIDTH;

  parameter DLL_TRACKING_ENABLE = 1;
  wire [31:0] pw_DLL_TRACKING_ENABLE = DLL_TRACKING_ENABLE;

  parameter TRAS = 6; // Active to precharge command
  wire [31:0] pw_TRAS = TRAS;

  parameter TRCD = 3; // Active to read/write delay
  wire [31:0] pw_TRCD = TRCD;

  parameter TRP = 3; // Precharge command period
  wire [31:0] pw_TRP = TRP;

  parameter TRRD = 2; // Bank A activate to bank B activate
  wire [31:0] pw_TRRD = TRRD;

  parameter TCCD = 2; // CAS A to CAS B delay
  wire [31:0] pw_TCCD = TCCD;

  parameter TRTW = 4; // Read to write turnaround time
  wire [31:0] pw_TRTW = TRTW;

  parameter TWTR = 2; // Write to read turnaround time
  wire [31:0] pw_TWTR = TWTR;

  parameter TWR = 3; // Write recovery time
  wire [31:0] pw_TWR = TWR;

  parameter TRFC = 10; // Auto-refresh to auto-refresh or activation period
  wire [31:0] pw_TRFC = TRFC;

  parameter TXSNR = 10; // Exit self-refresh to a non-read command delay
  wire [31:0] pw_TXSNR = TXSNR;

  parameter TXSRD = 200; // Exit self-refresh to a read command delay
  wire [31:0] pw_TXSRD = TXSRD;

  parameter TMRD = 2; // Mode register set command cycle time
  wire [31:0] pw_TMRD = TMRD;

  parameter  AUTOPRECHARGE_ENABLE_ADDRESS_BIT = 10;
  wire [31:0] pw_AUTOPRECHARGE_ENABLE_ADDRESS_BIT =
              AUTOPRECHARGE_ENABLE_ADDRESS_BIT;

  //The following parameter is used to enable/disable the
  //read before write checker.

  parameter  READ_BEFORE_WRITE_CHECK_ENABLE = 1;
  wire [31:0] pw_READ_BEFORE_WRITE_CHECK_ENABLE =
              READ_BEFORE_WRITE_CHECK_ENABLE;

  //The following parameter is used to enable/disable the
  //data checker.
  parameter  DATA_CHECK_ENABLE = 1;
  wire [31:0] pw_DATA_CHECK_ENABLE = DATA_CHECK_ENABLE;

  input ck;
  input ck_n;
  input areset; 
  input reset;
  input cke;
  input cs_n;
  input ras_n; 
  input cas_n; 
  input we_n;
  input [DM_WIDTH-1:0] dm;
  input [1:0] ba;  // This version supports only 4 banks
  input [ROW_ADDR_WIDTH-1:0] a;
  input [DATA_BUS_WIDTH-1:0] dq;
  input dqs;

  wire [ROW_ADDR_WIDTH+3-1:0] mode_reg = 0;
  wire [ROW_ADDR_WIDTH+3-1:0] ex_mode_reg = 0;


qvl_ddr2_sdram_2_0_monitor #(Constraints_Mode,
                           CONTROLLER_SIDE,
                           ROW_ADDR_WIDTH,
                           DATA_BUS_WIDTH,
                           DLL_TRACKING_ENABLE,
                           TRAS,
                           TRCD,
                           TRP,
                           TRRD,
                           TCCD,
                           TRTW,
                           TWTR,
                           TWR,
                           TRFC,
                           TXSNR,
                           TXSRD,
                           TMRD,
                           AUTOPRECHARGE_ENABLE_ADDRESS_BIT,
                           READ_BEFORE_WRITE_CHECK_ENABLE,
                           2, // default value of TXP
                           2, // default value of TXARD
                           3, // BANK_ADDR_WIDTH for 4 banks + 1 bit always 0
                           0, // defaut value of ENABLE_PRECHARGE_TO_IDLE_BANK
                           0, // No BYPASS_INIT supported for this version
                           DATA_CHECK_ENABLE,
                           0,  // Previous version of monitor ZI_DDR2_SDRAM_2_0
                           DM_WIDTH 
                           )
                   MONITOR0 (
                   .ck (ck),
                   .ck_n(ck_n),
                   .reset (reset),
                   .areset (areset),
                   .cke (cke),
                   .cs_n (cs_n),
                   .ras_n (ras_n),
                   .cas_n (cas_n),
                   .we_n (we_n),
                   .dm_rdqs (dm),
                   .ba ({1'b0,ba}),
                   .a (a), 
                   .dq (dq),
                   .dqs (dqs),
                   .ldqs(1'b0),
                   .ldm(1'b1),
                   .udqs(1'b0),
                   .udm(1'b1),
                   .mode_register_in(mode_reg),
                   .ex_mode_register_in(ex_mode_reg) 
                   );


`ifdef ZI_INLINED_PSL
`include "0in_ac_inline_for_mod_zi_cw_ddr2_sdram_monitor.inc"
`endif
`ifdef ZI_INLINED_CHX
`include "zi_cw_ddr2_sdram_monitor.zi_chx.inc"
`else
`ifdef ZI_INLINED_CHX_zi_cw_ddr2_sdram_monitor
`include "zi_cw_ddr2_sdram_monitor.zi_chx.inc"
`endif
`endif

`qvlendmodule // qvl_ddr2_sdram_monitor
