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
 * PURPOSE      This file is part of 0-In CheckerWare
 *
 * DESCRIPTION  This monitor checks the PCI Local Bus Protocol
 *
 * REFERENCE    PCI Local Bus Specification Rev. 2.2, Dec. 18, 1998
 * 
 * INPUTS      The input signals that constitute the PCI monitor interface are:
 *
 *    pci_clk_in       - PCI Clock (CLK) input to the PCI Compliant Device
 *    pci_rst_in_n     - PCI Reset (RST#) input to the PCI Compliant Device
 *
 *    pci_ad_in        - PCI multiplexed Address and Data (AD) bus input
 *			 to the PCI Compliant Device, minimum 32 bits wide
 *			 (default), maximum 64 bits wide, see parameter
 *			 section below
 *    pci_ad_out       - PCI multiplexed Address and Data (AD) bus output
 *			 from the PCI Compliant Device, minimum 32 bits wide
 *			 (default), maximum 64 bits wide, see parameter
 *			 section below
 *    pci_ad_en_n      - Enable signal from the PCI compliant device to the
 *			 AD buffers
 *
 *    pci_cbe_in_n     - PCI multiplexed Bus Command and Byte Enables
 *			 (C/BE#) bus input to the PCI Compliant Device,
 *			 minimum 4 bits wide (default), maximum 8 bits wide,
 *			 see parameter section below
 *    pci_cbe_out_n    - PCI multiplexed Bus Command and Byte Enables
 *                       (C/BE#) bus output from the PCI Compliant Device
 *			 minimum 4 bits wide (default), maximum 8 bits wide,
 *			 see parameter section below
 *    pci_cbe_en_n     - Enable signal from the PCI compliant device to the
 *			 C/BE# buffers
 *
 *    pci_par_in       - PCI parity (PAR) input for pci_ad_in[31:0] and
 *			 pci_cbe_in_n[3:0] to the PCI compliant device
 *    pci_par_out      - PCI parity (PAR) output for pci_ad_out[31:0]
 *  			 and pci_cbe_out_n[3:0] from the PCI compliant device
 *    pci_par_en_n     - Enable signal from the  PCI compliant device to the
 *			 PAR buffer
 *
 *    pci_frame_in_n   - PCI Cycle Frame (FRAME#) input to the PCI Compliant
 *			 Device
 *    pci_frame_out_n  - PCI Cycle Frame (FRAME#) output from the PCI Compliant
 *			 Device
 *    pci_frame_en_n   - Enable signal from the PCI Compliant Device to the
 *			 FRAME# buffer
 *
 *    pci_irdy_in_n    - PCI Initiator Ready (IRDY#) input to the PCI Compliant
 *			 Device	
 *    pci_irdy_out_n   - PCI Initiator Ready (IRDY#) output from the PCI
 *			 Compliant Device
 *    pci_irdy_en_n    - Enable signal from the PCI Compliant Device to the
 *              	 IRDY# buffer
 *
 *    pci_trdy_in_n    - PCI Target Ready (TRDY#) input to the PCI Compliant
 *                       Device
 *    pci_trdy_out_n   - PCI Target Ready (TRDY#) output from the PCI Compliant
 *                         Device
 *    pci_trdy_en_n    - Enable signal from the PCI Compliant Device to the
 *			 TRDY# buffer
 *
 *    pci_stop_in_n    - PCI Stop (STOP#) input to the PCI Compliant Device
 *    pci_stop_out_n   - PCI Stop (STOP#) output from the  PCI Compliant Device
 *    pci_stop_en_n    - Enable signal from the PCI Compliant Device to the
 *                       STOP# buffer
 *
 *    pci_lock_in_n    - PCI lock (LOCK#) input to the PCI Compliant Device
 *
 *    pci_idsel_in     - PCI Initialization Device Select (IDSEL) input to the
 *			 PCI Compliant Device
 *
 *    pci_devsel_in_n  - PCI Device Select (DEVSEL#) input to the PCI Compliant
 *			 Device
 *    pci_devsel_out_n - PCI Device Select (DEVSEL#) output from the PCI
 *			 Compliant Device
 *    pci_devsel_en_n  - Enable signal from the PCI Compliant Device to the
 *                       DEVSEL# buffer
 *
 *    pci_req_out_n    - PCI Request (REQ#) output from the PCI Compliant
 *			 Device
 *
 *    pci_gnt_in_n     - PCI Grant (GNT#) input to the PCI Compliant Device
 *
 *    pci_perr_in_n    - PCI Parity Error (PERR#) input to the PCI Compliant
 *              	 Device
 *    pci_perr_out_n   - PCI Parity Error (PERR#) output from the PCI Compliant
 *                       Device
 *    pci_perr_en_n    - Enable signal from the PCI Compliant Device to the
 *                       PERR# buffer
 *
 *    pci_serr_out_n   - PCI System Error (SERR#) output to the PCI Compliant
 *                       Device
 *
 *    pci_req64_in_n   - PCI Request 64-bit Transfer (REQ64#) input to the  PCI
 *			 Compliant Device
 *    pci_req64_out_n  - PCI Request 64-bit Transfer (REQ64#) output from the
 *	          	 PCI Compliant Device
 *    pci_req64_en_n   - Enable signal from the PCI Compliant Device to the
 *                       REQ64# buffer
 *
 *    pci_ack64_in_n   - PCI Acknowledge 64-bit Transfer (ACK64#) input to the
 *			 PCI Compliant Device
 *    pci_ack64_out_n  - PCI Acknowledge 64-bit Transfer (ACK64#) output from
 *			 the PCI Compliant Device
 *    pci_ack64_en_n   - Enable signal from the PCI Compliant Device to the
 *                       ACK64# buffer
 *
 *    pci_par64_in     - PCI Parity Upper DWORD (PAR64) input for
 *			 pci_ad_in[63:32] and pci_cbe_in_n[7:4] to the PCI
 *			 Compliant Device
 *    pci_par64_out    - PCI Parity Upper DWORD (PAR64) output for
 *			 pci_ad_out[63:32] and pci_cbe_out_n[7:4] from the PCI
 *			 Compliant Device
 *    pci_par64_en_n   - Enable signal from the PCI Compliant Device to the
 *                         PAR64 buffer
 *
 * Note:  The Enable signals (*_en_n) above are active low signals.  When
 *       asserted (i.e., low), the pci monitor samples the corresponding "out"
 *       signal (e.g., pci_frame_out_n).  When deasserted (i.e., high), the pci
 *       monitor samples the corresponding "in" signal (e.g., pci_frame_in_n).
 *
 *
 * The following parameters help to configure the PCI monitor:
 *
 *  1. Bit64Mode (default 0) : Set this parameter to 1, if the target design is
 *			     a 64-bit capable device.
 *
 *  2. Contraints_Mode (default 0) : Set this parameter to 1, if the checks in
 *				   the monitor are to be used as contraints to
 *               			   0-In Search.
 *
 * The parameters should be specified in the order in which they are listed 
 * above.
 *
 * USAGE        The monitor should be instantiated within the target design.
 *
 *                 +--------------------------+
 *                 |                          |
 *                 |   PCI Compliant Device   |
 *                 |                          |
 *                 |          +-------------+ |
 *                 |          | pci monitor | |
 *                 |          +-------------+ |
 *                 +--------------------------+
 *                            /|\
 *                             |
 *                            \|/  PCI Local Bus
 *               <===================================>
 *                             
 *                             
 * Last Modified : 22nd June 2004
 ******************************************************************************/

`include "std_qvl_defines.h"

`qvlmodule qvl_pci_monitor (
  pci_ad_en_n, 
  pci_cbe_en_n,
  pci_frame_en_n,
  pci_irdy_en_n,
  pci_trdy_en_n,
  pci_devsel_en_n,
  pci_stop_en_n,
  pci_perr_en_n,
  pci_par_en_n,
  pci_par64_en_n,
  pci_req64_en_n,
  pci_ack64_en_n,

  pci_rst_in_n,
  pci_clk_in,
  pci_gnt_in_n,
  pci_idsel_in,
  pci_ad_in,
  pci_cbe_in_n,
  pci_frame_in_n,
  pci_irdy_in_n,
  pci_trdy_in_n,
  pci_devsel_in_n,
  pci_stop_in_n,
  pci_lock_in_n,
  pci_perr_in_n,
  pci_par_in,
  pci_par64_in,
  pci_req64_in_n,
  pci_ack64_in_n,

  pci_req_out_n,
  pci_ad_out,
  pci_cbe_out_n,
  pci_frame_out_n,
  pci_irdy_out_n,
  pci_trdy_out_n,
  pci_devsel_out_n,
  pci_stop_out_n,
  pci_perr_out_n,
  pci_serr_out_n,
  pci_par_out,
  pci_par64_out,
  pci_req64_out_n,
  pci_ack64_out_n
  );

  parameter Bit64Mode = 0;
  wire [31:0] pw_Bit64Mode = Bit64Mode;
  parameter Constraints_Mode = 0; // 0in constraint
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;
  parameter ParityErrorResponse = 1;
  wire [31:0] pw_ParityErrorResponse = ParityErrorResponse;
  parameter SELF_CONFIG = 0;
  wire [31:0] pw_SELF_CONFIG = SELF_CONFIG;
  parameter SystemErrorResponse = 1;
  wire [31:0] pw_SystemErrorResponse = SystemErrorResponse;

  parameter ADB = Bit64Mode ? 64:32;
  wire [31:0] pw_ADB = Bit64Mode;
  parameter CBE = Bit64Mode ? 8:4;
  wire [31:0] pw_CBE = CBE;

  input pci_ad_en_n;
  input	pci_cbe_en_n;
  input	pci_frame_en_n;
  input	pci_irdy_en_n;
  input	pci_trdy_en_n;
  input	pci_devsel_en_n;
  input	pci_stop_en_n;
  input	pci_perr_en_n;
  input	pci_par_en_n;
  input	pci_par64_en_n;
  input pci_req64_en_n;
  input pci_ack64_en_n;

  input	pci_req_out_n;
  input [ADB-1:0] pci_ad_out;
  input [CBE-1:0] pci_cbe_out_n;
  input	pci_frame_out_n;
  input	pci_irdy_out_n;
  input	pci_trdy_out_n;
  input	pci_devsel_out_n;
  input	pci_stop_out_n;
  input	pci_perr_out_n;
  input	pci_serr_out_n;
  input	pci_par_out;
  input	pci_par64_out;
  input	pci_req64_out_n;
  input	pci_ack64_out_n;

  input	pci_rst_in_n;
  input	pci_clk_in;
  input	pci_gnt_in_n;
  input	pci_idsel_in;
  input [ADB-1:0] pci_ad_in;
  input [CBE-1:0] pci_cbe_in_n;
  input	pci_frame_in_n;
  input	pci_irdy_in_n;
  input	pci_trdy_in_n;
  input	pci_devsel_in_n;
  input	pci_stop_in_n;
  input	pci_lock_in_n;
  input	pci_perr_in_n;
  input	pci_par_in;
  input	pci_par64_in;
  input	pci_req64_in_n;
  input	pci_ack64_in_n;

  wire  pci_ad_en_n_sampled;
  wire 	pci_cbe_en_n_sampled;
  wire 	pci_frame_en_n_sampled;
  wire 	pci_irdy_en_n_sampled;
  wire 	pci_trdy_en_n_sampled;
  wire 	pci_devsel_en_n_sampled;
  wire 	pci_stop_en_n_sampled;
  wire 	pci_perr_en_n_sampled;
  wire 	pci_par_en_n_sampled;
  wire 	pci_par64_en_n_sampled;
  wire  pci_req64_en_n_sampled;
  wire  pci_ack64_en_n_sampled;

  wire 	pci_req_out_n_sampled;
  wire  [ADB-1:0] pci_ad_out_sampled;
  wire  [CBE-1:0] pci_cbe_out_n_sampled;
  wire 	pci_frame_out_n_sampled;
  wire 	pci_irdy_out_n_sampled;
  wire 	pci_trdy_out_n_sampled;
  wire 	pci_devsel_out_n_sampled;
  wire 	pci_stop_out_n_sampled;
  wire 	pci_perr_out_n_sampled;
  wire 	pci_serr_out_n_sampled;
  wire 	pci_par_out_sampled;
  wire 	pci_par64_out_sampled;
  wire 	pci_req64_out_n_sampled;
  wire 	pci_ack64_out_n_sampled;

  wire 	pci_rst_in_n_sampled;
  wire 	pci_gnt_in_n_sampled;
  wire 	pci_idsel_in_sampled;
  wire  [ADB-1:0] pci_ad_in_sampled;
  wire  [CBE-1:0] pci_cbe_in_n_sampled;
  wire 	pci_frame_in_n_sampled;
  wire 	pci_irdy_in_n_sampled;
  wire 	pci_trdy_in_n_sampled;
  wire 	pci_devsel_in_n_sampled;
  wire 	pci_stop_in_n_sampled;
  wire 	pci_lock_in_n_sampled;
  wire 	pci_perr_in_n_sampled;
  wire 	pci_par_in_sampled;
  wire 	pci_par64_in_sampled;
  wire 	pci_req64_in_n_sampled;
  wire 	pci_ack64_in_n_sampled;

  assign `QVL_DUT2CHX_DELAY     pci_ad_en_n_sampled     = pci_ad_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_cbe_en_n_sampled    = pci_cbe_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_frame_en_n_sampled  = pci_frame_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_irdy_en_n_sampled   = pci_irdy_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_trdy_en_n_sampled   = pci_trdy_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_devsel_en_n_sampled = pci_devsel_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_stop_en_n_sampled   = pci_stop_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_perr_en_n_sampled   = pci_perr_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_par_en_n_sampled    = pci_par_en_n;
  assign `QVL_DUT2CHX_DELAY 	pci_par64_en_n_sampled  = pci_par64_en_n;
  assign `QVL_DUT2CHX_DELAY     pci_req64_en_n_sampled  = pci_req64_en_n;
  assign `QVL_DUT2CHX_DELAY     pci_ack64_en_n_sampled  = pci_ack64_en_n;

  assign `QVL_DUT2CHX_DELAY 	pci_req_out_n_sampled   = pci_req_out_n;
  assign `QVL_DUT2CHX_DELAY     pci_ad_out_sampled      = pci_ad_out;
  assign `QVL_DUT2CHX_DELAY     pci_cbe_out_n_sampled   = pci_cbe_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_frame_out_n_sampled = pci_frame_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_irdy_out_n_sampled  = pci_irdy_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_trdy_out_n_sampled  = pci_trdy_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_devsel_out_n_sampled = pci_devsel_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_stop_out_n_sampled  = pci_stop_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_perr_out_n_sampled  = pci_perr_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_serr_out_n_sampled  = pci_serr_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_par_out_sampled     = pci_par_out;
  assign `QVL_DUT2CHX_DELAY 	pci_par64_out_sampled   = pci_par64_out;
  assign `QVL_DUT2CHX_DELAY 	pci_req64_out_n_sampled = pci_req64_out_n;
  assign `QVL_DUT2CHX_DELAY 	pci_ack64_out_n_sampled = pci_ack64_out_n;

  assign `QVL_DUT2CHX_DELAY 	pci_rst_in_n_sampled    = pci_rst_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_gnt_in_n_sampled    = pci_gnt_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_idsel_in_sampled    = pci_idsel_in;
  assign `QVL_DUT2CHX_DELAY     pci_ad_in_sampled       = pci_ad_in;
  assign `QVL_DUT2CHX_DELAY     pci_cbe_in_n_sampled    = pci_cbe_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_frame_in_n_sampled  = pci_frame_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_irdy_in_n_sampled   = pci_irdy_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_trdy_in_n_sampled   = pci_trdy_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_devsel_in_n_sampled = pci_devsel_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_stop_in_n_sampled   = pci_stop_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_lock_in_n_sampled   = pci_lock_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_perr_in_n_sampled   = pci_perr_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_par_in_sampled      = pci_par_in;
  assign `QVL_DUT2CHX_DELAY 	pci_par64_in_sampled    = pci_par64_in;
  assign `QVL_DUT2CHX_DELAY 	pci_req64_in_n_sampled  = pci_req64_in_n;
  assign `QVL_DUT2CHX_DELAY 	pci_ack64_in_n_sampled  = pci_ack64_in_n;


qvl_pci_logic
  #(
      .Bit64Mode(Bit64Mode),
      .Constraints_Mode(Constraints_Mode),
      .ParityErrorResponse(ParityErrorResponse),
      .SELF_CONFIG(SELF_CONFIG),
      .SystemErrorResponse(SystemErrorResponse)
   )
   qvl_pci (
            .pci_ad_en_n     (pci_ad_en_n_sampled),
            .pci_cbe_en_n    (pci_cbe_en_n_sampled),
            .pci_frame_en_n  (pci_frame_en_n_sampled),
            .pci_irdy_en_n   (pci_irdy_en_n_sampled),
            .pci_trdy_en_n   (pci_trdy_en_n_sampled),
            .pci_devsel_en_n (pci_devsel_en_n_sampled),
            .pci_stop_en_n   (pci_stop_en_n_sampled),
            .pci_perr_en_n   (pci_perr_en_n_sampled),
            .pci_par_en_n    (pci_par_en_n_sampled),
            .pci_par64_en_n  (pci_par64_en_n_sampled),
            .pci_req64_en_n  (pci_req64_en_n_sampled),
            .pci_ack64_en_n  (pci_ack64_en_n_sampled),

            .pci_req_out_n   (pci_req_out_n_sampled),
            .pci_ad_out      (pci_ad_out_sampled),
            .pci_cbe_out_n   (pci_cbe_out_n_sampled),
            .pci_frame_out_n (pci_frame_out_n_sampled),
            .pci_irdy_out_n  (pci_irdy_out_n_sampled),
            .pci_trdy_out_n  (pci_trdy_out_n_sampled),
            .pci_devsel_out_n(pci_devsel_out_n_sampled),
            .pci_stop_out_n  (pci_stop_out_n_sampled),
            .pci_perr_out_n  (pci_perr_out_n_sampled),
            .pci_serr_out_n  (pci_serr_out_n_sampled),
            .pci_par_out     (pci_par_out_sampled),
            .pci_par64_out   (pci_par64_out_sampled),
            .pci_req64_out_n (pci_req64_out_n_sampled),
            .pci_ack64_out_n (pci_ack64_out_n_sampled),

            .pci_rst_in_n    (pci_rst_in_n_sampled),
            .pci_clk_in      (pci_clk_in),
            .pci_gnt_in_n    (pci_gnt_in_n_sampled),
            .pci_idsel_in    (pci_idsel_in_sampled),
            .pci_ad_in       (pci_ad_in_sampled),
            .pci_cbe_in_n    (pci_cbe_in_n_sampled),
            .pci_frame_in_n  (pci_frame_in_n_sampled),
            .pci_irdy_in_n   (pci_irdy_in_n_sampled),
            .pci_trdy_in_n   (pci_trdy_in_n_sampled),
            .pci_devsel_in_n (pci_devsel_in_n_sampled),
            .pci_stop_in_n   (pci_stop_in_n_sampled),
            .pci_lock_in_n   (pci_lock_in_n_sampled),
            .pci_perr_in_n   (pci_perr_in_n_sampled),
            .pci_par_in      (pci_par_in_sampled),
            .pci_par64_in    (pci_par64_in_sampled),
            .pci_req64_in_n  (pci_req64_in_n_sampled),
            .pci_ack64_in_n  (pci_ack64_in_n_sampled)
           ); 
`qvlendmodule // qvl_pci_monitor
