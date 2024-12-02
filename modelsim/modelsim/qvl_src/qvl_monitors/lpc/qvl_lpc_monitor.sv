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
 * PURPOSE      This file is part of Questa Verification Library (QVL).
 *
 * DESCRIPTION  The LPC monitor checks if the Low Pin Count (LPC)
 *              interface functions properly.
 *
 * REFERENCE    Low Pin Count (LPC) Interface Specification,
 *              Rev. 1.0, Sept 29, 1997
 *
 * USAGE
 * 
 *                    ISA                        PCI/Host Bus
 *               <--------+->                  <-+------------>
 *                        |   +--------------+   |
 *                        |   |              |   |
 *                        +---|     Host     |---+
 *                            |              |
 *                            | +----------+ |
 *                            | |  LPC mon | |
 *                            | +----------+ |
 *                            +--------------+
 *                                   |
 *                                   |
 *                                   |                 LPC
 *               <============================================>
 *                                   |
 *                                   |
 *                                   |
 *                            +--------------+
 *                            | +----------+ |
 *                            | |  LPC mon | |
 *                            | +----------+ |
 *                            |              |
 *                            |   SuperIO    |
 *                            |              |
 *                            +--------------+
 *
 * Last Modified : 17-August-2006 
 ***********************************************************************/
`include "std_qvl_defines.h"

`qvlmodule qvl_lpc_monitor(lclk, lreset_n, 
			 lframe_n, 
			 lad,
			 ldrq_n,
			 serirq,
			 clkrun_n,
			 pme_n,
			 lpcpd_n,
			 lsmi_n);

   parameter Constraints_Mode = 0;
   wire [31:0] pw_Constraints_Mode = Constraints_Mode;

   parameter LDRQ_WIDTH = 2;
   wire [31:0] pw_LDRQ_WIDTH = LDRQ_WIDTH;
   parameter RETAIN_DMA_ON_ABORT = 1;
   wire [31:0] pw_RETAIN_DMA_ON_ABORT = RETAIN_DMA_ON_ABORT;
   parameter CHECK_RESERVED_VALUE = 0;
   wire [31:0] pw_CHECK_RESERVED_VALUE = CHECK_RESERVED_VALUE;
   parameter ALLOW_LARGE_DMA_TRANSFERS = 1;
   wire [31:0] pw_ALLOW_LARGE_DMA_TRANSFERS = 
                 ALLOW_LARGE_DMA_TRANSFERS;
   parameter ALLOW_DMA_AFTER_DEACTIVATION = 1;
   wire [31:0] pw_ALLOW_DMA_AFTER_DEACTIVATION = 
                 ALLOW_DMA_AFTER_DEACTIVATION;

 // These parameters can be used to disable/enable the checks LPC_30 and LPC_31

   parameter ZI_CHANNEL_CHECK_ENABLE = 1;
   parameter ZI_BM_CHECK_ENABLE = 1;

   input       lclk;
   input       lreset_n;
   input       lframe_n;
   input [3:0] lad;
   input [LDRQ_WIDTH-1:0] ldrq_n;
   input       serirq;
   input       clkrun_n;
   input       pme_n;
   input       lpcpd_n;
   input       lsmi_n;             

   wire        lreset_n_sampled;               
   wire        lframe_n_sampled;
   wire  [3:0] lad_sampled;
   wire  [LDRQ_WIDTH-1:0] ldrq_n_sampled;
   wire        serirq_sampled;
   wire        clkrun_n_sampled;
   wire        pme_n_sampled;
   wire        lpcpd_n_sampled;
   wire        lsmi_n_sampled;

   assign `QVL_DUT2CHX_DELAY lreset_n_sampled  = lreset_n;                      
   assign `QVL_DUT2CHX_DELAY lframe_n_sampled  = lframe_n;
   assign `QVL_DUT2CHX_DELAY lad_sampled       = lad;
   assign `QVL_DUT2CHX_DELAY ldrq_n_sampled    = ldrq_n;
   assign `QVL_DUT2CHX_DELAY serirq_sampled    = serirq;
   assign `QVL_DUT2CHX_DELAY clkrun_n_sampled  = clkrun_n;
   assign `QVL_DUT2CHX_DELAY pme_n_sampled     = pme_n;
   assign `QVL_DUT2CHX_DELAY lpcpd_n_sampled   = lpcpd_n;
   assign `QVL_DUT2CHX_DELAY lsmi_n_sampled    = lsmi_n;     

  qvl_lpc_logic
    #(.Constraints_Mode (Constraints_Mode),
      .LDRQ_WIDTH       (LDRQ_WIDTH),
      .RETAIN_DMA_ON_ABORT (RETAIN_DMA_ON_ABORT),
      .CHECK_RESERVED_VALUE (CHECK_RESERVED_VALUE),
      .ALLOW_LARGE_DMA_TRANSFERS (ALLOW_LARGE_DMA_TRANSFERS),
      .ALLOW_DMA_AFTER_DEACTIVATION (ALLOW_DMA_AFTER_DEACTIVATION),
      .ZI_CHANNEL_CHECK_ENABLE (ZI_CHANNEL_CHECK_ENABLE),
      .ZI_BM_CHECK_ENABLE (ZI_BM_CHECK_ENABLE)
     )
       qvl_logic (.lclk                (lclk),
		 .lreset_n (lreset_n_sampled),
                 .lframe_n (lframe_n_sampled),
		 .lad           (lad_sampled),
 		 .ldrq_n     (ldrq_n_sampled),
                 .serirq     (serirq_sampled),
                 .clkrun_n (clkrun_n_sampled),
                 .pme_n       (pme_n_sampled),
                 .lpcpd_n   (lpcpd_n_sampled),
                 .lsmi_n     (lsmi_n_sampled)
                 );       
`qvlendmodule
 
