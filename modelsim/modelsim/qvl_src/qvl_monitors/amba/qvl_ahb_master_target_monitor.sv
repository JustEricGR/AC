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
 * PURPOSE      This file is part of the 0-In CheckerWare.
 *              It describes the AHB master & target monitors for the
 *              AMBA AHB bus.
 *
 * DESCRIPTION  This monitor checks the AMBA AHB master & target protocol.
 *
 * REFERENCE    AMBA Specification (Rev 2.0 13th May 1999, Issue A)
 *              ARM FAQ 23rd January 2001
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

 The AHB MASTER/TARGET monitor can be placed inside the AHB master/target
 device(s) for use as checks with 0-In Check.  It can also be used as
 search goals and as constraints with 0-In Search on the AHB master/target.

 ***********************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_ahb_master_target_monitor
                               (
				 hclk,
				 hresetn,

				 hgrantx,
				 
				 ahb_hready,
				 ahb_hresp,
				 ahb_hrdata,
				 
				 mas_htrans,
				 mas_haddr,
				 mas_hwrite,
				 mas_hsize,
				 mas_hburst,
				 mas_hprot,
				 
				 mas_hwdata,

                                 hselx,

                                 ahb_htrans,
                                 ahb_haddr,
                                 ahb_hwrite,
                                 ahb_hsize,
                                 ahb_hburst,

                                 ahb_hwdata,

                                 ahb_hmaster,
                                 ahb_hmastlock,

                                 ahb_hready_in,
                                 tar_hready_out,

                                 tar_hresp,
                                 tar_hrdata,

                                 tar_hsplitx

			       );
   
  parameter Constraints_Mode = 0; // ##0in constraint
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter		      DATA_BUS_WIDTH = 32;
  wire [31:0] pw_DATA_BUS_WIDTH = DATA_BUS_WIDTH;

  parameter NUMBER_OF_MASTERS = 16;
  wire [31:0] pw_NUMBER_OF_MASTERS = NUMBER_OF_MASTERS;

  parameter		      CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE = 0;
  wire [31:0] pw_CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE =
                                    CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE;

  parameter Over_Constraints_Mode = 0;
  wire [31:0] pw_Over_Constraints_Mode = Over_Constraints_Mode;

  parameter DISABLE_CHKS_ON_IDLE = 0;
  wire [31:0] pw_DISABLE_CHKS_ON_IDLE = DISABLE_CHKS_ON_IDLE;

  input		      		hclk;
  input		      		hresetn;
  input		      		hgrantx;
  input		      		ahb_hready;
  input [1:0]		      	ahb_hresp;
  input [DATA_BUS_WIDTH-1:0]	ahb_hrdata;
  input [1:0]		      	mas_htrans;
  input [31:0]		      	mas_haddr;
  input		      		mas_hwrite;
  input [2:0]		      	mas_hsize;
  input [2:0]		      	mas_hburst;
  input [3:0]		      	mas_hprot;
  input [DATA_BUS_WIDTH-1:0] 	mas_hwdata;

  input				hselx;
  input [1:0]			ahb_htrans;
  input [31:0]			ahb_haddr;
  input				ahb_hwrite;
  input [2:0]			ahb_hsize;
  input [2:0]			ahb_hburst;
  input [DATA_BUS_WIDTH-1:0]	ahb_hwdata;

  input [3:0]			ahb_hmaster;
  input				ahb_hmastlock;
  input				ahb_hready_in;
  input				tar_hready_out;
  input [1:0]			tar_hresp;
  input [DATA_BUS_WIDTH-1:0]	tar_hrdata;

  input [NUMBER_OF_MASTERS-1:0]	tar_hsplitx;

  qvl_ahb_master_monitor #(Constraints_Mode,
                             DATA_BUS_WIDTH,
                             CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE,
                             Over_Constraints_Mode,
                             DISABLE_CHKS_ON_IDLE
                            )

                           mas_mon (
                                    .hgrantx (hgrantx),

                                    .hready  (ahb_hready),
                                    .hresp   (ahb_hresp),

                                    .hresetn (hresetn),
                                    .hclk    (hclk),

                                    .hrdata  (ahb_hrdata),

                                    .htrans  (mas_htrans),
                                    .haddr   (mas_haddr),
                                    .hwrite  (mas_hwrite),
                                    .hsize   (mas_hsize),
                                    .hburst  (mas_hburst),
                                    .hprot   (mas_hprot),

                                    .hwdata  (mas_hwdata)
                                   );

  qvl_ahb_target_monitor #(Constraints_Mode,
                             DATA_BUS_WIDTH,
                             NUMBER_OF_MASTERS,
                             CANCEL_FOLLOWING_TRANSFER_ON_ERROR_RESPONSE,
                             Over_Constraints_Mode,
                             DISABLE_CHKS_ON_IDLE
                            )

                           tar_mon (
                                    .hselx      (hselx),

                                    .haddr      (ahb_haddr),
                                    .hwrite     (ahb_hwrite),
                                    .htrans     (ahb_htrans),
                                    .hsize      (ahb_hsize),
                                    .hburst     (ahb_hburst),

                                    .hwdata     (ahb_hwdata),

                                    .hresetn    (hresetn),
                                    .hclk       (hclk),

                                    .hmaster    (ahb_hmaster),
                                    .hmastlock  (ahb_hmastlock),

                                    .hready_in  (ahb_hready_in),
                                    .hready_out (tar_hready_out),

                                    .hresp      (tar_hresp),
                                    .hrdata     (tar_hrdata),

                                    .hsplitx    (tar_hsplitx)
                                   );


`qvlendmodule // qvl_ahb_master_target_monitor
