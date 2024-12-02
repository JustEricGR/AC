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
 * 
 * PURPOSE      This file is part of 0-In CheckerWare.
 *              It describes the bus monitor for the AMBA3 APB bus 
 *              standard.
 *
 * DESCRIPTION  This monitor checks the AMBA3 APB protocol.
 *
 * REFERENCE    AMBA Specification Rev 3.0, ARM IHI 0024B, v1.0, 17 Aug 2004.
 * 
 * INPUTS       pclk          - Clock signal
 *              presetn       - Asynchonous Reset signal (active low)
 *              paddr         - Address Bus
 *		pselx         - Select Input
 *		penable       - Enable Input
 *		pwrite        - Read/Write Input (Write is active high)
 *		pwdata        - Write Data Bus
 *		prdata        - Read Data Bus
 *              pready        - Ready Input 
 *              pslverr       - Slave Error Input
 *
 * NOTES        The PWDATA and PRDATA buses can be implemented as a single
 *		bi-directional bus with tri-state capability.  Under such
 *		circumstances, the single data bus should be connected to both
 *		the PWDATA and PRDATA inputs of the interface checker.
 *
 * USAGE        The monitor should be instantiated within the target design.
 *
 *                 +----------+               +-----------------+
 *                 |          | -- paddr   -->| +--------------+|
 *                 |          | -- pselx   -->| | amba3_apb_mon||
 *                 |  Bridge  | -- penable -->| |              ||
 *                 |          | -- pwrite  -->| +--------------+|
 *                 |          | -- pwdata  -->|  APB Slave      |
 *                 |          | <- prdata  ---|                 |
 *                 |          | <- pready  ---|                 | 
 *                 |          | <- pslverr ---|                 | 
 *                 +----------+	              +-----------------+
 *                             
 ***********************************************************************/

`include "std_qvl_defines.h" 

`ifdef QVL_SVA_INTERFACE
`define qvlmodule interface
`define qvlendmodule endinterface
`else
`define qvlmodule module
`define qvlendmodule endmodule
`endif

`qvlmodule qvl_amba3_apb_monitor (pclk, presetn, paddr, pselx, penable, 
		   	  pwrite, pwdata, prdata, pready, pslverr);
   
  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter ADD_BUS_WIDTH  = 32;
  wire [31:0] pw_ADD_BUS_WIDTH = ADD_BUS_WIDTH;

  parameter DATA_BUS_WIDTH = 32;
  parameter pw_DATA_BUS_WIDTH = DATA_BUS_WIDTH;
   
  input	pclk;
  input presetn;
  input	[ADD_BUS_WIDTH-1:0] paddr;
  input	pselx;
  input penable;
  input pwrite;
  input	[DATA_BUS_WIDTH-1:0] pwdata;
  input [DATA_BUS_WIDTH-1:0] prdata;
  input                      pready;
  input                      pslverr;

  wire presetn_sampled;
  wire [ADD_BUS_WIDTH-1:0] paddr_sampled;
  wire pselx_sampled;
  wire penable_sampled;
  wire pwrite_sampled;
  wire [DATA_BUS_WIDTH-1:0] pwdata_sampled;
  wire [DATA_BUS_WIDTH-1:0] prdata_sampled;

  assign `QVL_DUT2CHX_DELAY presetn_sampled = presetn;
  assign `QVL_DUT2CHX_DELAY paddr_sampled   = paddr;
  assign `QVL_DUT2CHX_DELAY pselx_sampled   = pselx;
  assign `QVL_DUT2CHX_DELAY penable_sampled = penable;
  assign `QVL_DUT2CHX_DELAY pwrite_sampled  = pwrite;
  assign `QVL_DUT2CHX_DELAY pwdata_sampled  = pwdata;
  assign `QVL_DUT2CHX_DELAY prdata_sampled  = prdata;
  assign `QVL_DUT2CHX_DELAY pready_sampled  = pready;
  assign `QVL_DUT2CHX_DELAY pslverr_sampled  = pslverr;

  qvl_amba3_apb_logic
    #(.Constraints_Mode (Constraints_Mode),
      .ADD_BUS_WIDTH    (ADD_BUS_WIDTH),
      .DATA_BUS_WIDTH   (DATA_BUS_WIDTH)
     )
       qvl_apb3 (.pclk    (pclk),
                .presetn (presetn_sampled),
                .paddr   (paddr_sampled),
                .pselx   (pselx_sampled),
                .penable (penable_sampled),
                .pwrite  (pwrite_sampled),
                .pwdata  (pwdata_sampled),
                .prdata  (prdata_sampled),
                .pready  (pready_sampled),
                .pslverr (pslverr_sampled)
               );

`qvlendmodule // qvl_amba3_apb_monitor
