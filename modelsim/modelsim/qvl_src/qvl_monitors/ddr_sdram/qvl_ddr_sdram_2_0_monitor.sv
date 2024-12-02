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
 * REFERENCE    JEDEC Standard, Double Data Rate SDRAM Specification, JESD79C
 *              JEDEC Solid State Technology Association, March 2003
 *
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
 *              LDQS         - Data Strobe for port "LDQ".
 *              LDM          - Data Mask for port "LDQ".
 *              UDQS         - Data Strobe for port "UDQ".
 *              UDM          - Data Mask for port "UDQ".
 *
 *
 * PARAMETERS Constraints_Mode - Set this parameter to 0 if the checks in the  
 *                               monitor are to be used as targets for formal
 *                               analysis. The default value is 1.
 *             CONTROLLER_SIDE - Set this parameter to 0, if the monitor is
 *                               instantiated on the DDR SDRAM memory side.
 *                               The default value is 1.
 *             ADDR_WIDTH    - width of address bus signals
 *             DATA_WIDTH    - width of data bus signals
 *             TRC_OVERRIDE  - RAS# cycle time.
 *                             Minimum time interval between successive ACTIVE
 *                             commands to the same bank.
 *                             JEDEC Spec. compliant value is 5.
 *             TRAS_OVERRIDE - RAS# active time.
 *                             Minimum time to precharge a bank after it was
 *                             previously issued an ACTIVE command without
 *                             losing read/write data.
 *                             JEDEC Spec. compliant value is 4.
 *             TRP_OVERRIDE  - RAS# precharge time.
 *                             Minimum time to precharge a bank.
 *                             JEDEC Spec. compliant value is 2.
 *             TRCD_OVERRIDE - RAS# to CAS# delay.
 *                             Minimum time to legally issue
 *                             a READ or WRITE command to a row after opening
 *                             it by issuing an ACTIVE command.
 *                             JEDEC Spec. compliant value is 2
 *             TRRD_OVERRIDE - RAS# to RAS# bank activate delay.
 *                             Minimum time interval between successive ACTIVE
 *                             commands to different banks.
 *                             JEDEC Spec. compliant value is 1.
 *             TMRD_OVERRIDE - MODE REGISTER SET command cycle time.
 *                             Minimum time interval for any new command-issue
 *                             after the MODE REGISTER SET command was
 *                             previously issued.
 *                             JEDEC Spec. compliant value is 2.
 *             TRFC_OVERRIDE - AUTO REFRESH to ACTIVE command time. Minimum
 *                             time between AUTO REFRESH command and an
 *                             ACTIVE command to any bank.
 *                             JEDEC Spec. compliant value is 6.
 *            TXSNR_OVERRIDE - SELF REFRESH to non-READ command time. Minimum
 *                             time interval between SELF REFRESH command to
 *                             any non-READ command to any bank.
 *                             JEDEC Spec. compliant value is 6.
 *            TXSRD_OVERRIDE - SELF REFRESH to READ command time. Minimum
 *                             time interval between SELF REFRESH command to
 *                             a READ command to any bank.
 *                             JEDEC Spec. compliant value is 200.
 *              TWR_OVERRIDE - Write recovery time. Minimum time interval
 *                             between last write data pair that was written
 *                             into memory and the PRECHARGE command.
 *                             JEDEC Spec. compliant value is 1.
 *             TWTR_OVERRIDE - Write to Read delay timing value.
 *                             Spec. compliant value is 1.
 //BIPS
 *             TCLK_OVERRIDE - Minimum number of clock cycles to be lapsed
 *                             after CKE goes LOW before input clock frequency
 *                             can change
 //BIPS
 *             AUTOPRECHARGE_ENABLE_ADDRESS_BIT -
 *                             Address bit number that is used to enable/
 *                             disbale the Autoprecharge function.
 *         COL_ADDRESS_WIDTH - Full Page Mode busrt address width.
 *         READ_BEFORE_WRITE_CHECK_ENABLE -
 *                             This parameter enables or disables read
 *                             before write check.
 *        CON_AUTO_PRECHARGE - Determines whether the device supports
 *                             concurrent Auto Precharge feature.
 *         ENABLE_WHY_PRECHARGE_AN_IDLE_BANK -
 *                             This parameter enables or disables the
 *                             "why_precharge_an_idle_bank" check.
 *              BYPASS_INIT  - Indicates initialization sequence bypass.
 *               NON_JEDEC   - This parameter is used to enable support of 
 *                             non JEDEC values for Cas latency, burst length 
 *                             and timing parameters. 
 *    USE_PORTS_TO_CONFIGURE - This parameter enables or disables the timing
 *                             parameters to be used from the inputports 
 //BIPS
 *    CLOCK_CHANGE_TRACKING_ENABLE -
 *                             This parameter is used to enable support of
 *                             change of input clock frequency on the fly
 *                             as per JESD78E May 2005 spec update
 *         TCLK_CHECK_ENABLE - This parameter enabled or disables the
 *                             check for minimum clock cycles to be lapsed
 *                             before clock frequency can change after
 *                             CKE is sampled LOW 
 *    CLOCK_FREQUENCY_RANGE_CHECK_ENABLE -
 *                             This parameter is to enable checking the
 *                             clock frquency if it is within allowed ranges
 *                             which is specified by another set of parameters
 *                             CLOCK_FREQUENCY_MIN and CLOCK_FREQUENCY_MAX.
 *                             This parameter is effective only when the
 *                             parameter CLOCK_CHANGE_TRACKING_ENABLE is set.
 *    NO_SET_CAS_LATENCY_CHECK_ENABLE -
 *                             This parameter is to enable the checking of
 *                             setting of CAS latency new after precharge power
 *                             down mode exit followed by a clock frequency change
 *                             This parameter is effective only when the
 *                             parameter CLOCK_CHANGE_TRACKING_ENABLE is set.
 //BIPS

 * Last modified date: 05 August 2008
 *
 **************************************************************************/


`include "std_qvl_defines.h"


`qvlmodule qvl_ddr_sdram_2_0_monitor(clock,
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
			       extended_mode_register,
                               LDQS,
                               LDM,
                               UDQS,
                               UDM,
                               TRC,
                               TRAS,
                               TRP,
                               TRCD,
                               TRRD,
                               TWR,
                               TWTR, 
                               TMRD,
                               TRFC,
                               TXSNR,
                               TXSRD,
//BIPS
                               TCLK
//BIPS 
                               );

  parameter  Constraints_Mode = 0; // 0in constraint
                            // Used to make a checker to be a constraint
                            // or a search-goal during 0in-Search.
 
  parameter  CONTROLLER_SIDE = 1;
                            // To know if the monitor is instantiated on
                            // the Controller side or Memory side.

  parameter  ADDR_WIDTH = 12;
  parameter  DATA_WIDTH = 8;
  parameter  DLL_TRACKING_ENABLE = 1; 

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
//BIPS
  parameter TCLK_OVERRIDE = 0;
  wire pw_TCLK_OVERRIDE = TCLK_OVERRIDE;
//BIPS
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

  // The following parameter is to be used to enable the usage of non JEDEC 
  // values for the burst_length, cas_latency and timing parameters.
  parameter NON_JEDEC = 0;
  wire[31:0] pw_NON_JEDEC = NON_JEDEC;
 
  // The following parameter is used to enable the monitor to infer the timing
  // parameters from the input ports. 
  parameter USE_PORTS_TO_CONFIGURE = 0;
  wire[31:0] pw_USE_PORTS_TO_CONFIGURE = USE_PORTS_TO_CONFIGURE;

  parameter  DATA_CHECK_ENABLE = 1;
  wire[31:0] pw_DATA_CHECK_ENABLE = DATA_CHECK_ENABLE;
  
  // Use the following parameter to configure the monitor to support the new
  // DDR SDRAM specification of May 2005 --BIPS
  parameter ZI_DDR_SDRAM_2_0 = 1;
  wire [31:0] pw_DDR_SDRAM_2_0 = ZI_DDR_SDRAM_2_0;

  parameter  DM_WIDTH = 1;
  wire [31:0] pw_DM_WIDTH = DM_WIDTH;
 
//BIPS

  // Use the following parameter to configure the monitor to support the new
  // DDR SDRAM specification of May 2005 i.e. JESD79E

  parameter CLOCK_CHANGE_TRACKING_ENABLE = 1;
  wire [31:0] pw_CLOCK_CHANGE_TRACKING_ENABLE = CLOCK_CHANGE_TRACKING_ENABLE;

  parameter TCLK_CHECK_ENABLE = 1;
  wire [31:0] pw_TCLK_CHECK_ENABLE = TCLK_CHECK_ENABLE;

  parameter CLOCK_FREQUENCY_RANGE_CHECK_ENABLE = 0;
  wire [31:0] pw_CLOCK_FREQUENCY_RANGE_CHECK_ENABLE = CLOCK_FREQUENCY_RANGE_CHECK_ENABLE;

  parameter CLOCK_FREQUENCY_MIN = 100;
  wire [31:0] pw_CLOCK_FREQUENCY_MIN = CLOCK_FREQUENCY_MIN;
  // Default minimum supported clock is 100 Mhz which allows 100 million transfers
  // per data pin per second. This is the lowest speed grade for DDR SDRAM spec
  // JESD79E-May2005..

  parameter CLOCK_FREQUENCY_MAX = 200;
  wire [31:0] pw_CLOCK_FREQUENCY_MAX = CLOCK_FREQUENCY_MAX;
  // Deafult maximum supported clock is 200 Mhz which allows 200 million transfers
  // per data pin per second. This is the highest speed grade for DDR SDRAM spec
  // JESD79E-May2005.

  parameter NO_SET_CAS_LATENCY_CHECK_ENABLE = 0;
   wire [31:0] pw_NO_SET_CAS_LATENCY_CHECK_ENABLE = NO_SET_CAS_LATENCY_CHECK_ENABLE;

//BIPS
 

  parameter  ZI_DM_RDQS_WIDTH = (ZI_DDR_SDRAM_2_0 === 1) ? 1 : DM_WIDTH;

  input clock;	
  input clock_n;
  input reset;	
  input areset;	 
  input CKE;
  input CS_n;	 
  input RAS_n;	 
  input CAS_n;	 
  input WE_n;	 
  input [1:0] BA;	 
  input [ADDR_WIDTH-1:0] A; 
  input [ZI_DM_RDQS_WIDTH-1:0] DM;	 
  input [DATA_WIDTH-1:0] DQ;
  input DQS;
  input [ADDR_WIDTH+1:0] mode_register; // width of mode registers equal the
  input [ADDR_WIDTH+1:0] extended_mode_register; // address bus + bank address
  input LDQS;
  input LDM;
  input UDQS;
  input UDM;

  input[31:0] TRC;
  input[31:0] TRAS;
  input[31:0] TRP;
  input[31:0] TRCD;
  input[31:0] TRRD;
  input[31:0] TWR;
  input[31:0] TWTR; 
  input[31:0] TMRD;
  input[31:0] TRFC;
  input[31:0] TXSNR;
  input[31:0] TXSRD;
//BIPS
  input[31:0] TCLK;
//BIPS

  wire reset_sampled;	
  wire areset_sampled;	 
  wire CKE_sampled;
  wire CS_n_sampled;	 
  wire RAS_n_sampled;	 
  wire CAS_n_sampled;	 
  wire WE_n_sampled;	 
  wire [1:0] BA_sampled;	 
  wire [ADDR_WIDTH-1:0] A_sampled; 
  wire [ZI_DM_RDQS_WIDTH-1:0] DM_sampled;	 
  wire [DATA_WIDTH-1:0] DQ_sampled;
  wire DQS_sampled;
  wire [ADDR_WIDTH+1:0] mode_register_sampled; // width of mode registers equal the
  wire [ADDR_WIDTH+1:0] extended_mode_register_sampled; // address bus + bank address
  wire LDQS_sampled;
  wire LDM_sampled;
  wire UDQS_sampled;
  wire UDM_sampled;

  wire[31:0] TRC_sampled;
  wire[31:0] TRAS_sampled;
  wire[31:0] TRP_sampled;
  wire[31:0] TRCD_sampled;
  wire[31:0] TRRD_sampled;
  wire[31:0] TWR_sampled;
  wire[31:0] TWTR_sampled; 
  wire[31:0] TMRD_sampled;
  wire[31:0] TRFC_sampled;
  wire[31:0] TXSNR_sampled;
  wire[31:0] TXSRD_sampled;
  wire[31:0] TCLK_sampled;

  assign `QVL_DUT2CHX_DELAY reset_sampled = reset;
  assign `QVL_DUT2CHX_DELAY areset_sampled = areset;
  assign `QVL_DUT2CHX_DELAY CKE_sampled = CKE;
  assign `QVL_DUT2CHX_DELAY CS_n_sampled = CS_n;
  assign `QVL_DUT2CHX_DELAY RAS_n_sampled = RAS_n;
  assign `QVL_DUT2CHX_DELAY CAS_n_sampled = CAS_n;
  assign `QVL_DUT2CHX_DELAY WE_n_sampled = WE_n;
  assign `QVL_DUT2CHX_DELAY BA_sampled = BA;
  assign `QVL_DUT2CHX_DELAY A_sampled = A;
  assign `QVL_DUT2CHX_DELAY DM_sampled = DM;
  assign `QVL_DUT2CHX_DELAY DQ_sampled = DQ;
  assign `QVL_DUT2CHX_DELAY DQS_sampled = DQS;
  assign `QVL_DUT2CHX_DELAY mode_register_sampled = mode_register;
  assign `QVL_DUT2CHX_DELAY extended_mode_register_sampled = extended_mode_register;
  assign `QVL_DUT2CHX_DELAY LDQS_sampled = LDQS;
  assign `QVL_DUT2CHX_DELAY LDM_sampled = LDM;
  assign `QVL_DUT2CHX_DELAY UDQS_sampled = UDQS;
  assign `QVL_DUT2CHX_DELAY UDM_sampled = UDM;
  assign `QVL_DUT2CHX_DELAY TRC_sampled = TRC;
  assign `QVL_DUT2CHX_DELAY TRAS_sampled = TRAS;
  assign `QVL_DUT2CHX_DELAY TRP_sampled = TRP;
  assign `QVL_DUT2CHX_DELAY TRCD_sampled = TRCD;
  assign `QVL_DUT2CHX_DELAY TRRD_sampled = TRRD;
  assign `QVL_DUT2CHX_DELAY TWR_sampled = TWR;
  assign `QVL_DUT2CHX_DELAY TWTR_sampled = TWTR;
  assign `QVL_DUT2CHX_DELAY TMRD_sampled = TMRD;
  assign `QVL_DUT2CHX_DELAY TRFC_sampled = TRFC;
  assign `QVL_DUT2CHX_DELAY TXSNR_sampled = TXSNR;
  assign `QVL_DUT2CHX_DELAY TXSRD_sampled = TXSRD;
  assign `QVL_DUT2CHX_DELAY TCLK_sampled = TCLK;



qvl_ddr_sdram_2_0_logic #(Constraints_Mode,
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
                          TCLK_OVERRIDE,
                          AUTOPRECHARGE_ENABLE_ADDRESS_BIT,
                          COL_ADDRESS_WIDTH,
                          READ_BEFORE_WRITE_CHECK_ENABLE,
                          CON_AUTO_PRECHARGE,
                          ENABLE_WHY_PRECHARGE_AN_IDLE_BANK,
                          BYPASS_INIT,
                          NON_JEDEC,
                          USE_PORTS_TO_CONFIGURE,
                          ZI_DDR_SDRAM_2_0,  // Previous version of  DDR monitor
                          DM_WIDTH,
                          DATA_CHECK_ENABLE,
                          CLOCK_CHANGE_TRACKING_ENABLE,
                          TCLK_CHECK_ENABLE,
                          CLOCK_FREQUENCY_RANGE_CHECK_ENABLE,
                          CLOCK_FREQUENCY_MIN,
                          CLOCK_FREQUENCY_MAX,
                          NO_SET_CAS_LATENCY_CHECK_ENABLE
                              )
                   MONITOR0 (
                   .clock (clock),
                   .clock_n (clock_n),
                   .reset (reset_sampled),
                   .areset (areset_sampled),
                   .CKE (&CKE_sampled),
                   .CS_n (|CS_n_sampled),
                   .RAS_n (RAS_n_sampled),
                   .CAS_n (CAS_n_sampled),
                   .WE_n (WE_n_sampled),
                   .BA (BA_sampled),
                   .A (A_sampled),
                   .DM (DM_sampled),
                   .DQ (DQ_sampled),
                   .DQS (DQS_sampled),
                   .mode_register(mode_register_sampled),
                   .extended_mode_register(extended_mode_register_sampled),
                   .LDQS (LDQS_sampled),
                   .LDM (LDM_sampled),
                   .UDQS (UDQS_sampled),
                   .UDM (UDM_sampled),
                   .TRC (TRC_sampled),
                   .TRAS (TRAS_sampled),
                   .TRP (TRP_sampled),
                   .TRCD (TRCD_sampled),
                   .TRRD (TRRD_sampled),
                   .TWR (TWR_sampled),
                   .TWTR (TWTR_sampled),
                   .TMRD (TMRD_sampled),
                   .TRFC (TRFC_sampled),
                   .TXSNR (TXSNR_sampled),
                   .TXSRD (TXSRD_sampled),
//BIPS
                   .TCLK (TCLK_sampled) 
//BIPS
                   );


`qvlendmodule // qvl_ddr_sdram_bank_monitor



