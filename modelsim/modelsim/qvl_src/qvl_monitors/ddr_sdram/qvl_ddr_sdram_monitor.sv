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
 *              It describes the DDR SDRAM monitor 
 *
 * DESCRIPTION  This monitor checks the JEDEC compliant DDR SDRAM interface.
 *
 * INPUTS       clock         - Clock signal
 *              clock_n       - Complementary clock signal
 *              reset         - Reset signal
 *              areset        - Asynchonous Reset signal
 *              CKE	      - DDR SDRAM clock enable signal(s)
 *              CS_n	      - DDR SDRAM chip select active low signal(s)
 *              RAS_n	      - DDR SDRAM row address strobe active low signal
 *              CAS_n	      - DDR SDRAM column address strobe active low 
 *				signal
 *              WE_n	      - DDR SDRAM write enable active low signal
 *              BA	      - DDR SDRAM bank address signals
 *              A	      - DDR SDRAM address signals
 *              DM	      - DDR SDRAM data mask signal(s)
 *		DQ	      - DDR SDRAM data signals
 *		DQS	      - DDR SDRAM data strobe signal
 *              mode_register - DDR SDRAM mode register input
 *              extended_mode_register - DDR SDRAM extended mode register input
 *
 * PARAMETERS   Constraints_Mode - Used to make the checker to be a
 *                constraint or a search-goal during 0in-Search.  The legal
 *                values are 0 and 1 (default value is 1).
 *
 *              CONTROLLER_SIDE  - To know if the monitor is instantiated on
 *                the Controller side or Memory side.  The value is 1, if the
 *                monitor is instantiated on Controller side.  The value is 0,
 *                if the monitor is instantiated on Memory side.
 *                The default value is 1.
 *
 *              ADDR_WIDTH    - width of address bus signals
 *              DM_WIDTH      - width of data mask signal(s)
 *              DATA_WIDTH    - width of data bus signals
 *              TRC_OVERRIDE  - RAS# cycle time.
 *                              Minimum time interval between successive ACTIVE
 *                              commands to the same bank.
 *                              JEDEC Spec. compliant value is 9.
 *              TRAS_OVERRIDE - RAS# active time.
 *                              Minimum time to precharge a bank after it was
 *                              previously issued an ACTIVE command without
 *                              losing read/write data.
 *                              JEDEC Spec. compliant value is 6.
 *              TRP_OVERRIDE  - RAS# precharge time.
 *                              Minimum time to precharge a bank.
 *                              JEDEC Spec. compliant value is 3.
 *              TRCD_OVERRIDE - RAS# to CAS# delay.
 *                              Minimum time to legally issue
 *                              a READ or WRITE command to a row after opening
 *                              it by issuing an ACTIVE command.
 *                              JEDEC Spec. compliant value is 3
 *              TRRD_OVERRIDE - RAS# to RAS# bank activate delay.
 *                              Minimum time interval between successive ACTIVE
 *                              commands to different banks.
 *                              JEDEC Spec. compliant value is 2.
 *              TMRD_OVERRIDE - MODE REGISTER SET command cycle time.
 *                              Minimum time interval for any new command-issue
 *                              after the MODE REGISTER SET command was
 *                              previously issued.
 *                              JEDEC Spec. compliant value is 3.
 *              TRFC_OVERRIDE - AUTO REFRESH to ACTIVE command time. Minimum
 *                              time between AUTO REFRESH command and an
 *                              ACTIVE command to any bank.
 *                              JEDEC Spec. compliant value is 10.
 *             TXSNR_OVERRIDE - SELF REFRESH to non-READ command time. Minimum
 *                              time interval between SELF REFRESH command to
 *                              any non-READ command to any bank.
 *                              JEDEC Spec. compliant value is 10.
 *             TXSRD_OVERRIDE - SELF REFRESH to READ command time. Minimum
 *                              time interval between SELF REFRESH command to
 *                              a READ command to any bank.
 *                              JEDEC Spec. compliant value is 200.
 *             TWR_OVERRIDE   - Write recovery time. Minimum time interval
 *                              between last write data pair that was written
 *                              into memory and the PRECHARGE command.
 *                              JEDEC Spec. compliant value is 2.
 *            TWTR_OVERRIDE   - Write to Read delay timing value.
 *                              Spec. compliant value is 1.
 * AUTOPRECHARGE_ENABLE_ADDRESS_BIT - Address bit number that is used to
 *                                    enable/disbale the Autoprecharge
 *                                    function.
 *       COL_ADDRESS_WIDTH - Full Page Mode busrt address width.
 *
 *       READ_BEFORE_WRITE_CHECK_ENABLE - This parameter enables or disables
 *                                        read before write check.
 *       CON_AUTO_PRECHARGE - Determines whether the device supports
 *                            concurrent Auto Precharge feature.
 *       ENABLE_WHY_PRECHARGE_AN_IDLE_BANK - This parameter enables or
 *                                           disables the
 *                                           "why_precharge_an_idle_bank"
 *                                           check.
 *             BYPASS_INIT   - Indicates initialization sequence bypass.
 *               NON_JEDEC   - This parameter is used to enable support of
 *                             non JEDEC values for CAS latency, burst length
 *                             and timing parameters.
 *
 *
 * Last modified date: 06 April 2006
 *
 **************************************************************************/

`include "std_qvl_defines.h"


`qvlmodule qvl_ddr_sdram_monitor(clock,
			       clock_n,
			       reset,
			       areset,
	                       CKE,
			       CS_n,
			       RAS_n,
			       CAS_n,
			       WE_n,
			       BA,
			       A,
			       DM,
			       DQ,
			       DQS,
			       mode_register,
			       extended_mode_register);
  
  parameter  Constraints_Mode = 0; // 0in constraint
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;
  parameter  CONTROLLER_SIDE = 1; // Indicates location of monitor instance
  wire [31:0] pw_CONTROLLER_SIDE = CONTROLLER_SIDE;
  parameter  CS_CKE_WIDTH = 1;   
  wire [31:0] pw_CS_CKE_WIDTH = CS_CKE_WIDTH;
  parameter  ADDR_WIDTH = 12;
  wire [31:0] pw_ADDR_WIDTH = ADDR_WIDTH;
  parameter  DM_WIDTH = 1;
  wire [31:0] pw_DM_WIDTH = DM_WIDTH;
  parameter  DATA_WIDTH = 8;
  wire [31:0] pw_DATA_WIDTH = DATA_WIDTH;
  parameter  DLL_TRACKING_ENABLE = 1; 
  wire [31:0] pw_DLL_TRACKING_ENABLE = DLL_TRACKING_ENABLE;
  parameter  TRC_OVERRIDE = 0;
  wire [31:0] pw_TRC_OVERRIDE = TRC_OVERRIDE;
  parameter  TRAS_OVERRIDE = 0;
  wire [31:0] pw_TRAS_OVERRIDE = TRAS_OVERRIDE;
  parameter  TRP_OVERRIDE = 0;
  wire [31:0] pw_TRP_OVERRIDE = TRP_OVERRIDE;
  parameter  TRCD_OVERRIDE = 0;
  wire [31:0] pw_TRCD_OVERRIDE = TRCD_OVERRIDE;
  parameter  TRRD_OVERRIDE = 0;
  wire [31:0] pw_TRRD_OVERRIDE = TRRD_OVERRIDE;
  parameter  TMRD_OVERRIDE = 0;
  wire [31:0] pw_TMRD_OVERRIDE = TMRD_OVERRIDE;
  parameter  TRFC_OVERRIDE = 0;
  wire [31:0] pw_TRFC_OVERRIDE = TRFC_OVERRIDE;
  parameter  TXSNR_OVERRIDE = 0;
  wire [31:0] pw_TXSNR_OVERRIDE = TXSNR_OVERRIDE;
  parameter  TXSRD_OVERRIDE = 0;
  wire [31:0] pw_TXSRD_OVERRIDE = TXSRD_OVERRIDE;
  parameter  TWR_OVERRIDE = 0;
  wire [31:0] pw_TWR_OVERRIDE = TWR_OVERRIDE;
  parameter  TWTR_OVERRIDE = 0;
  wire [31:0] pw_TWTR_OVERRIDE = TWTR_OVERRIDE;
  parameter  AUTOPRECHARGE_ENABLE_ADDRESS_BIT = 10;
  wire [31:0] pw_AUTOPRECHARGE_ENABLE_ADDRESS_BIT = 
	      AUTOPRECHARGE_ENABLE_ADDRESS_BIT;
  parameter  COL_ADDRESS_WIDTH = 8;  
  wire [31:0] pw_COL_ADDRESS_WIDTH = COL_ADDRESS_WIDTH;
	       //Full Page Mode burst address width. Ex: For 256 length 
	       //FPM burst, this value should be set to 8.

  //The following parameter is used to enable/disable the
  //read before write checker.

  parameter  READ_BEFORE_WRITE_CHECK_ENABLE = 1;
  wire [31:0] pw_READ_BEFORE_WRITE_CHECK_ENABLE = 
              READ_BEFORE_WRITE_CHECK_ENABLE;

  parameter  CON_AUTO_PRECHARGE = 0;
  wire [31:0] pw_CON_AUTO_PRECHARGE = 
              CON_AUTO_PRECHARGE;

  // Following parameter is added to give the use control to enable
  // the "why_precharge_an_idle_bank" check.

  parameter  ENABLE_WHY_PRECHARGE_AN_IDLE_BANK = 0;
  wire [31:0] pw_ENABLE_WHY_PRECHARGE_AN_IDLE_BANK = 
	      ENABLE_WHY_PRECHARGE_AN_IDLE_BANK;

  // The following parameter is to be used to enable initialization bypass
  parameter  BYPASS_INIT = 0;
  wire [31:0] pw_BYPASS_INIT = BYPASS_INIT;

  parameter NON_JEDEC = 0;
  wire[31:0] pw_NON_JEDEC = NON_JEDEC;
  
  parameter DATA_CHECK_ENABLE = 1;
  wire[31:0] pw_DATA_CHECK_ENABLE = DATA_CHECK_ENABLE;

  input clock;	
  input clock_n;
  input reset;	 
  input areset;	 
  input [CS_CKE_WIDTH-1:0] CKE;
  input [CS_CKE_WIDTH-1:0] CS_n;	 
  input RAS_n;	 
  input CAS_n;	 
  input WE_n;	 
  input [1:0] BA;	 
  input [ADDR_WIDTH-1:0] A; 
  input [DM_WIDTH-1:0] DM;	 
  input [DATA_WIDTH-1:0] DQ;
  input DQS;
  input [ADDR_WIDTH+1:0] mode_register; // width of mode registers equal the
  input [ADDR_WIDTH+1:0] extended_mode_register; // address bus + bank address

  // wire [ADDR_WIDTH+1:0] mode_reg = 0;
  // wire [ADDR_WIDTH+1:0] ex_mode_reg = 0;

  

qvl_ddr_sdram_2_0_monitor #(Constraints_Mode,
			      CONTROLLER_SIDE,
			      ADDR_WIDTH,
			      DATA_WIDTH,
			      DLL_TRACKING_ENABLE,
                              TRC_OVERRIDE,
                              TRAS_OVERRIDE,
                              TRP_OVERRIDE,
                              TRCD_OVERRIDE,
                              TRRD_OVERRIDE,
                              TMRD_OVERRIDE,
                              TRFC_OVERRIDE,
                              TXSNR_OVERRIDE,
                              TXSRD_OVERRIDE,
                              TWR_OVERRIDE,
                              TWTR_OVERRIDE,
//BIPS
                              0, // Previous version of  DDR monitor: TCLK_OVERRIDE 
//BIPS       
			      AUTOPRECHARGE_ENABLE_ADDRESS_BIT,
			      COL_ADDRESS_WIDTH,
			      READ_BEFORE_WRITE_CHECK_ENABLE,
			      CON_AUTO_PRECHARGE,
			      ENABLE_WHY_PRECHARGE_AN_IDLE_BANK,
			      BYPASS_INIT,
			      NON_JEDEC,
                              0, // Previous version of  DDR monitor: USE_PORTS_TO_CONFIGURE
                              DATA_CHECK_ENABLE,
                              0,  // Previous version of  DDR monitor:  
			      DM_WIDTH,
                              0, // Previous version of  DDR monitor
                                 // These 6 parameters are attributed to latest version only 
                              0,
                              0,
                              0,
                              0,
                              0  
			      )
                   MONITOR0 (
                   .clock (clock),
                   .clock_n (clock_n),
                   .reset (reset),
                   .areset (areset),
                   .CKE (&CKE),
                   .CS_n (|CS_n),
                   .RAS_n (RAS_n),
                   .CAS_n (CAS_n),
                   .WE_n (WE_n),
                   .BA (BA),
                   .A (A),
                   .DM (DM),
                   .DQ (DQ),
                   .DQS (DQS),
                   .mode_register(mode_register),
                   .extended_mode_register(extended_mode_register),
                   .LDQS (1'b0),
                   .LDM (1'b0),
                   .UDQS (1'b0),
                   .UDM (1'b0),
                   .TRC (32'b0),
                   .TRAS (32'b0),
                   .TRP (32'b0),
                   .TRCD (32'b0),
                   .TRRD (32'b0),
                   .TWR (32'b0),
                   .TWTR (32'b0), 
                   .TMRD (32'b0),
                   .TRFC (32'b0),
                   .TXSNR (32'b0),
                   .TXSRD (32'b0),
//BIPS
                   .TCLK (32'b0)
//BIPS
                   );


`ifdef ZI_INLINED_PSL
`include "0in_ac_inline_for_mod_zi_cw_ddr_sdram_monitor.inc"
`endif
`ifdef ZI_INLINED_CHX
`include "zi_cw_ddr_sdram_monitor.zi_chx.inc"
`else
`ifdef ZI_INLINED_CHX_zi_cw_ddr_sdram_monitor
`include "zi_cw_ddr_sdram_monitor.zi_chx.inc"
`endif
`endif

`qvlendmodule // qvl_ddr_sdram_monitor
