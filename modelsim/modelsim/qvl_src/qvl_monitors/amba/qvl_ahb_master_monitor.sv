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
 *		It describes the AHB master monitor for the AMBA AHB bus.
 *
 * DESCRIPTION	This monitor checks the AMBA AHB master protocol.
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

 The AHB MASTER monitor can be placed inside the AHB master device(s) for use as
 checks with 0-In Check.  It can also be used as search goals and as constraints
 with 0-In Search on the AHB master.
 
 ***********************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_ahb_master_monitor (
				 hgrantx,
				 
				 hready,
				 hresp,
				 
				 hresetn,
				 hclk,
				 
				 hrdata,
				 
				 htrans,
				 haddr,
				 hwrite,
				 hsize,
				 hburst,
				 hprot,
				 
				 hwdata
				);


  parameter Constraints_Mode = 0; 
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter		      DATA_BUS_WIDTH = 32; 
  wire [31:0] pw_DATA_BUS_WIDTH = DATA_BUS_WIDTH;

  parameter		      CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE = 0;
  wire [31:0] pw_CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE =
                                    CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE;

  parameter Over_Constraints_Mode = 0;
  wire [31:0] pw_Over_Constraints_Mode = Over_Constraints_Mode;

  parameter DISABLE_CHKS_ON_IDLE = 0;
  wire [31:0] pw_DISABLE_CHKS_ON_IDLE = DISABLE_CHKS_ON_IDLE;

  input [1:0]		      	hresp; 
  input                         hgrantx;
  input                         hready;
   
  input		      		hresetn;
  input		      		hclk;
   
  input [DATA_BUS_WIDTH-1:0]	hrdata;
   
  input [1:0]		      	htrans; 

  input [31:0]		      	haddr; 

  input		      		hwrite; 

  input [2:0]		      	hsize; 

  input [2:0]		      	hburst; 

  input [3:0]		      	hprot; 
  input [DATA_BUS_WIDTH-1:0] 	hwdata;



  wire			    hgrantx_sampled;
  wire			    hready_sampled;
  wire [1:0]                hresp_sampled;
  wire			    hresetn_sampled;
  wire [DATA_BUS_WIDTH-1:0] hrdata_sampled;
  wire [1:0]		    htrans_sampled;
  wire [31:0]               haddr_sampled;
  wire			    hwrite_sampled;
  wire [2:0]                hsize_sampled;
  wire [2:0]                hburst_sampled;
  wire [3:0]                hprot_sampled;
  wire [DATA_BUS_WIDTH-1:0] hwdata_sampled;

  assign `QVL_DUT2CHX_DELAY hgrantx_sampled = hgrantx;
  assign `QVL_DUT2CHX_DELAY hready_sampled  = hready;
  assign `QVL_DUT2CHX_DELAY hresp_sampled   = hresp;
  assign `QVL_DUT2CHX_DELAY hresetn_sampled = hresetn;
  assign `QVL_DUT2CHX_DELAY hrdata_sampled  = hrdata;
  assign `QVL_DUT2CHX_DELAY htrans_sampled  = htrans;
  assign `QVL_DUT2CHX_DELAY haddr_sampled   = haddr;
  assign `QVL_DUT2CHX_DELAY hwrite_sampled  = hwrite;
  assign `QVL_DUT2CHX_DELAY hsize_sampled   = hsize;
  assign `QVL_DUT2CHX_DELAY hburst_sampled  = hburst;
  assign `QVL_DUT2CHX_DELAY hprot_sampled   = hprot;
  assign `QVL_DUT2CHX_DELAY hwdata_sampled  = hwdata;

  qvl_ahb_master_logic #(
                        .Constraints_Mode (Constraints_Mode),
                        .DATA_BUS_WIDTH (DATA_BUS_WIDTH),
                        .CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE (CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE),
                        .Over_Constraints_Mode (Over_Constraints_Mode),
                        .DISABLE_CHKS_ON_IDLE (DISABLE_CHKS_ON_IDLE)
                        )
  qvl_ahb_master (
        	 .hgrantx   (hgrantx_sampled),
        	 .hready    (hready_sampled),
        	 .hresp     (hresp_sampled),
        	 .hresetn   (hresetn_sampled),
        	 .hclk      (hclk),
        	 .hrdata    (hrdata_sampled),
        	 .htrans    (htrans_sampled),
        	 .haddr     (haddr_sampled),
        	 .hwrite    (hwrite_sampled),
        	 .hsize     (hsize_sampled),
        	 .hburst    (hburst_sampled),
        	 .hprot     (hprot_sampled),
        	 .hwdata    (hwdata_sampled)
                 );

`qvlendmodule












































