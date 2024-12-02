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
 * PURPOSE	This file is part of the 0-In CheckerWare.
 *		It describes the AHB target monitor for the AMBA AHB bus.
 *
 * DESCRIPTION	This monitor checks the AMBA AHB target protocol.
 *
 * REFERENCE	AMBA Specification (Rev 2.0 13th May 1999, Issue A)
 *              ARM FAQ 23rd January 2001
 *
 * USAGE

Block Diagram of a typical AHB-based system :
---------------------------------------------
 
                +------------------+            +------------------+    +---+
                |    AHB Master    |            |    AHB Target    |    | A |
                +------------------+            +------------------+    | P |
                         |                               |              | B |
                         |                               |              |   |
+------------------+     |           AHB Bus             |              | B |
|    AHB Target    |----------------------------------------------------| r |
+------------------+                    |                               | i |
                                        |                               | d |
                                +------------------+                    | g |
                                |    AHB Master    |                    | e |
                                +------------------+                    +---+
 
Examples of AHB master are : High-performance ARM processor, DMA bus master,
                             etc.
 
Examples of AHB target are : High-bandwidth Memory Interface, High-bandwidth
                             on-chip RAM, etc.  Note that the APB bridge is also
                             a target on the AHB bus.
 
Where is the monitor to be placed ?
-----------------------------------
 
The AHB TARGET monitor can be placed inside the AHB target device(s) for use as
checks with 0-In Check.  It can also be used as search goals and as constraints
with 0-In Search on the AHB target.
 
***********************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_ahb_target_monitor (
                     		 hselx,

                     		 haddr,
                     		 hwrite,
                     		 htrans,
                     		 hsize,
                     		 hburst,

                     		 hwdata,

                     		 hresetn,
				 hclk,
                     
                     		 hmaster,
                     		 hmastlock,

                     		 hready_in,
                     		 hready_out,

                     		 hresp,
                     		 hrdata,

                     		 hsplitx
			       );


  parameter Constraints_Mode = 0; 
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter DATA_BUS_WIDTH = 32; 
  wire [31:0] pw_DATA_BUS_WIDTH = DATA_BUS_WIDTH;

  parameter NUMBER_OF_MASTERS = 16; 
  wire [31:0] pw_NUMBER_OF_MASTERS = NUMBER_OF_MASTERS;

  parameter CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE = 0;
  wire [31:0] pw_CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE =
                                    CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE;

  parameter Over_Constraints_Mode = 0;
  wire [31:0] pw_Over_Constraints_Mode = Over_Constraints_Mode;

  parameter DISABLE_CHKS_ON_IDLE = 0;
  wire [31:0] pw_DISABLE_CHKS_ON_IDLE = DISABLE_CHKS_ON_IDLE;

  input					hselx; 

  input [31:0]				haddr; 

  input					hwrite; 

  input [1:0]				htrans; 

  input [2:0]				hsize; 

  input [2:0]				hburst; 

  input [DATA_BUS_WIDTH-1:0]		hwdata;

  input					hresetn;
  input					hclk;

  input [3:0]				hmaster; 

  input					hmastlock; 

  input					hready_in; 

  input					hready_out; 

  input [1:0]				hresp; 

  input [DATA_BUS_WIDTH-1:0]		hrdata;

  input [NUMBER_OF_MASTERS-1:0]		hsplitx; 


  wire				hselx_sampled; 
  wire [31:0]			haddr_sampled; 
  wire				hwrite_sampled;
  wire [1:0]			htrans_sampled;
  wire [2:0]			hsize_sampled; 
  wire [2:0]			hburst_sampled;
  wire [DATA_BUS_WIDTH-1:0]	hwdata_sampled;
  wire				hresetn_sampled;
  wire [3:0]			hmaster_sampled; 
  wire				hmastlock_sampled; 
  wire				hready_in_sampled; 
  wire				hready_out_sampled;
  wire [1:0]			hresp_sampled; 
  wire [DATA_BUS_WIDTH-1:0]	hrdata_sampled;
  wire [NUMBER_OF_MASTERS-1:0]	hsplitx_sampled; 

  assign `QVL_DUT2CHX_DELAY hselx_sampled      = hselx;
  assign `QVL_DUT2CHX_DELAY haddr_sampled      = haddr;
  assign `QVL_DUT2CHX_DELAY hwrite_sampled     = hwrite;
  assign `QVL_DUT2CHX_DELAY htrans_sampled     = htrans;
  assign `QVL_DUT2CHX_DELAY hsize_sampled      = hsize;
  assign `QVL_DUT2CHX_DELAY hburst_sampled     = hburst;
  assign `QVL_DUT2CHX_DELAY hwdata_sampled     = hwdata;
  assign `QVL_DUT2CHX_DELAY hresetn_sampled    = hresetn;
  assign `QVL_DUT2CHX_DELAY hmaster_sampled    = hmaster;
  assign `QVL_DUT2CHX_DELAY hmastlock_sampled  = hmastlock;
  assign `QVL_DUT2CHX_DELAY hready_in_sampled  = hready_in;
  assign `QVL_DUT2CHX_DELAY hready_out_sampled = hready_out;
  assign `QVL_DUT2CHX_DELAY hresp_sampled      = hresp;
  assign `QVL_DUT2CHX_DELAY hrdata_sampled     = hrdata;
  assign `QVL_DUT2CHX_DELAY hsplitx_sampled    = hsplitx;

  qvl_ahb_target_logic #(
                        .Constraints_Mode (Constraints_Mode),
                        .DATA_BUS_WIDTH (DATA_BUS_WIDTH),
                        .NUMBER_OF_MASTERS (NUMBER_OF_MASTERS),
                        .CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE (CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE),
                        .Over_Constraints_Mode (Over_Constraints_Mode),
                        .DISABLE_CHKS_ON_IDLE (DISABLE_CHKS_ON_IDLE)
                        )
  qvl_ahb_target (
                 .hselx      (hselx_sampled),
                 .haddr      (haddr_sampled),
                 .hwrite     (hwrite_sampled),
                 .htrans     (htrans_sampled),
                 .hsize      (hsize_sampled),
                 .hburst     (hburst_sampled),
                 .hwdata     (hwdata_sampled),
                 .hresetn    (hresetn_sampled),
		 .hclk       (hclk),
                 .hmaster    (hmaster_sampled),
                 .hmastlock  (hmastlock_sampled),
                 .hready_in  (hready_in_sampled),
                 .hready_out (hready_out_sampled),
                 .hresp      (hresp_sampled),
                 .hrdata     (hrdata_sampled),
                 .hsplitx    (hsplitx_sampled)
		 );

`qvlendmodule
                







































































