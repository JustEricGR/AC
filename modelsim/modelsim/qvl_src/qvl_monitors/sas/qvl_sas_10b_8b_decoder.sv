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
*
* DESCRIPTION   This module performs 10b to 8b decoding.
*
* REFERENCE     Serial Attached SCSI, Revision 1.1, Revision 2, Nov 20, 2003.
*
* USAGE         This sub module is instantiated in the qvl_sas_link_monitor
*               module.
*
* Last Modified : 24th Dec 2003
*
***********************************************************************/

`ifdef ZiCwDebug
`define ZiCwDebugDelay1 #1
`define ZiCwQuietIfNoCwDebug
`else
`define ZiCwDebugDelay1
`define ZiCwQuietIfNoCwDebug -quiet
`endif //ZiCwDebug

`ifdef QVL_COVER_ON
  `ifdef QVL_SV_COVERGROUP_OFF
    // Do nothing
  `else
    `define QVL_SV_COVERGROUP
  `endif
  `ifdef QVL_MW_FINAL_COVER_OFF
    // Do nothing
  `else
    `define QVL_MW_FINAL_COVER
  `endif
`endif

`qvlmodule qvl_sas_10b_8b_decoder (
				 reset,
				 areset,
                                 clk,
				 sas_10b_data,
				 sas_valid,
                                 electrical_idle_detected,
				 sas_current_rd,

				 sas_8b_data,
				 sas_d_or_k_code,
				 sas_10b_code_violation,
				 disparity_error_bitmap
				);

  // Parameter declarations

  parameter Constraints_Mode = 0;
  wire [31:0] pw_Constraints_Mode = Constraints_Mode;

  parameter DOUBLE_DATA_RATE = 0;
  wire [31:0] pw_DOUBLE_DATA_RATE = DOUBLE_DATA_RATE;

  // Input declarations

  input reset;
  input areset;
  input clk;

  input [9:0] sas_10b_data;
  input sas_valid;
  input sas_current_rd;
  input electrical_idle_detected;

  // Output declarations

  output [7:0] sas_8b_data;
  output sas_d_or_k_code;
  output sas_10b_code_violation;
  output disparity_error_bitmap;

  // Internal parameter declarations

  parameter ZI_POSITIVE = 1'b1;
  parameter ZI_NEGATIVE = 1'b0; 

  // Register declarations

  reg [7:0] next_sas_8b_data;
  reg next_sas_10b_code_violation;
  reg next_sas_d_or_k_code;
  reg disparity_error_bitmap;
  reg temp_sas_current_rd;

  // Wire declarations

  assign sas_8b_data = next_sas_8b_data;
  assign sas_10b_code_violation = next_sas_10b_code_violation;
  assign sas_d_or_k_code = next_sas_d_or_k_code;

  `protect

  initial
    begin
      #0;
      next_sas_8b_data = 1'b0;
      next_sas_d_or_k_code = 1'b0;
      next_sas_10b_code_violation = 1'b0;
      disparity_error_bitmap = 1'b0;
    end


   always @ (sas_current_rd or sas_10b_data or sas_valid or 
	     electrical_idle_detected)
     begin

       next_sas_8b_data = 8'b0; 
       next_sas_d_or_k_code = 1'b0;
       next_sas_10b_code_violation = 1'b0;
       disparity_error_bitmap = 1'b0;
       temp_sas_current_rd = sas_current_rd;
       
       if (electrical_idle_detected === 1'b0 && sas_valid === 1'b1)
         begin 
           decode_10B_to_8B_RD (sas_10b_data,
                                temp_sas_current_rd,
                                next_sas_8b_data,
                                next_sas_10b_code_violation,
                                next_sas_d_or_k_code);

            if (next_sas_10b_code_violation === 1'b0)
              begin

                // Symbol received with disparity error
                disparity_error_bitmap = 1'b1;

              end 
          end
     end

  // --------------------------------------------------------------------
  // 10B to 8B decoder task.
  // task name : decode_10B_to_8B_RD
  // Inouts    : B10, dispin
  // Outputs   : B8, Valid, D_or_K
  //---------------------------------------------------------------------

  task decode_10B_to_8B_RD;
  input [9:0]   B10 ;
  input dispin;
  output [7:0]	B8 ;
  output	valid ;
  output	D_or_K ;
  
  reg code_err;
  reg disp_err;

  reg [9:0]   datain ;
  reg ai;
  reg bi;
  reg ci;
  reg di;
  reg ei;
  reg ii;
  reg fi;
  reg gi;
  reg hi;
  reg ji;
  reg aeqb;
  reg ceqd;
  reg p22;
  reg p13;
  reg p31;
  reg p40;
  reg p04;
  reg disp6a;
  reg disp6a2;
  reg disp6a0;
  reg disp6b;
  reg p22bceeqi;
  reg p22bncneeqi;
  reg p13in;
  reg p31i;
  reg p13dei;
  reg p22aceeqi;
  reg p22ancneeqi;
  reg p13en;
  reg anbnenin;
  reg abei;
  reg cdei;
  reg cndnenin;
  reg p22enin;
  reg p22ei;
  reg p31dnenin;
  reg p31e;
  reg compa;
  reg compb;
  reg compc;
  reg compd;
  reg compe;
  reg ao;
  reg bo;
  reg co;
  reg d_o;
  reg eo;
  reg feqg;
  reg heqj;
  reg fghj22;
  reg fghjp13;
  reg fghjp31;
  reg dispout;
  reg ko;
  reg k28;
  reg k28p;
  reg fo;
  reg go;
  reg ho;
  reg disp6p;
  reg disp6n;
  reg disp4p;
  reg disp4n;
  begin

    datain = B10;

    ai = datain[0] ;
    bi = datain[1] ;
    ci = datain[2] ;
    di = datain[3] ;
    ei = datain[4] ;
    ii = datain[5] ;
    fi = datain[6] ;
    gi = datain[7] ;
    hi = datain[8] ;
    ji = datain[9] ;

    aeqb = (ai & bi) | (!ai & !bi) ;
    ceqd = (ci & di) | (!ci & !di) ;
    p22 = (ai & bi & !ci & !di) |
               (ci & di & !ai & !bi) |
               ( !aeqb & !ceqd) ;
    p13 = ( !aeqb & !ci & !di) |
               ( !ceqd & !ai & !bi) ;
    p31 = ( !aeqb & ci & di) |
               ( !ceqd & ai & bi) ;

    p40 = ai & bi & ci & di ;
    p04 = !ai & !bi & !ci & !di ;

    disp6a = p31 | (p22 & dispin) ; // pos disp if p22 and was pos, or p31.
    disp6a2 = p31 & dispin ;  // disp is ++ after 4 bits
    disp6a0 = p13 & ! dispin ; // -- disp after 4 bits

    disp6b = (ei & ii & ! disp6a0) | (disp6a & (ei | ii)) | disp6a2 ;

    // The 5B/6B decoding special cases where ABCDE != abcde

    p22bceeqi = p22 & bi & ci & (ei == ii) ;
    p22bncneeqi = p22 & !bi & !ci & (ei == ii) ;
    p13in = p13 & !ii ;
    p31i = p31 & ii ;
    p13dei = p13 & di & ei & ii ;
    p22aceeqi = p22 & ai & ci & (ei == ii) ;
    p22ancneeqi = p22 & !ai & !ci & (ei == ii) ;
    p13en = p13 & !ei ;
    anbnenin = !ai & !bi & !ei & !ii ;
    abei = ai & bi & ei & ii ;
    cdei = ci & di & ei & ii ;
    cndnenin = !ci & !di & !ei & !ii ;

    // non-zero disparity cases:
    p22enin = p22 & !ei & !ii ;
    p22ei = p22 & ei & ii ;
    p31dnenin = p31 & !di & !ei & !ii ;
    p31e = p31 & ei ;

    compa = p22bncneeqi | p31i | p13dei | p22ancneeqi |
                  p13en | abei | cndnenin ;
    compb = p22bceeqi | p31i | p13dei | p22aceeqi |
                  p13en | abei | cndnenin ;
    compc = p22bceeqi | p31i | p13dei | p22ancneeqi |
                  p13en | anbnenin | cndnenin ;
    compd = p22bncneeqi | p31i | p13dei | p22aceeqi |
                  p13en | abei | cndnenin ;
    compe = p22bncneeqi | p13in | p13dei | p22ancneeqi |
                  p13en | anbnenin | cndnenin ;

    ao = ai ^ compa ;
    bo = bi ^ compb ;
    co = ci ^ compc ;
    d_o = di ^ compd ;
    eo = ei ^ compe ;

    feqg = (fi & gi) | (!fi & !gi) ;
    heqj = (hi & ji) | (!hi & !ji) ;
    fghj22 = (fi & gi & !hi & !ji) |
                  (!fi & !gi & hi & ji) |
                  ( !feqg & !heqj) ;
    fghjp13 = ( !feqg & !hi & !ji) |
                   ( !heqj & !fi & !gi) ;
    fghjp31 = ( (!feqg) & hi & ji) |
                   ( !heqj & fi & gi) ;

    dispout = fghjp31 | (disp6b & fghj22) ;

    ko = ( (ci & di & ei & ii) | ( !ci & !di & !ei & !ii) |
                  (p13 & !ei & ii & gi & hi & ji) |
                  (p31 & ei & !ii & !gi & !hi & !ji)) ;

    k28 = (ci & di & ei & ii) | ! (ci | di | ei | ii) ;
    // k28 with positive disp into fghi - .1, .2, .5, and .6 special cases
    k28p = ! (ci | di | ei | ii) ;
    fo = (ji & !fi & (hi | !gi | k28p)) |
              (fi & !ji & (!hi | gi | !k28p)) |
              (k28p & gi & hi) |
              (!k28p & !gi & !hi) ;
    go = (ji & !fi & (hi | !gi | !k28p)) |
              (fi & !ji & (!hi | gi |k28p)) |
              (!k28p & gi & hi) |
              (k28p & !gi & !hi) ;
    ho = ((ji ^ hi) & ! ((!fi & gi & !hi & ji & !k28p) | (!fi & gi & hi & !ji 
           & k28p) | (fi & !gi & !hi & ji & !k28p) | (fi & !gi & hi & !ji & 
           k28p))) | (!fi & gi & hi & ji) | (fi & !gi & !hi & !ji) ;

    disp6p = (p31 & (ei | ii)) | (p22 & ei & ii) ;
    disp6n = (p13 & ! (ei & ii)) | (p22 & !ei & !ii) ;
    disp4p = fghjp31 ;
    disp4n = fghjp13 ;

    code_err = p40 | p04 | (fi & gi & hi & ji) | (!fi & !gi & !hi & !ji) |
                      (p13 & !ei & !ii) | (p31 & ei & ii) |
                      (ei & ii & fi & gi & hi) | (!ei & !ii & !fi & !gi & !hi) |
                      (ei & !ii & gi & hi & ji) | (!ei & ii & !gi & !hi & !ji) |
                      (!p31 & ei & !ii & !gi & !hi & !ji) |
                      (!p13 & !ei & ii & gi & hi & ji) |
                      (((ei & ii & !gi & !hi & !ji) |
                        (!ei & !ii & gi & hi & ji)) &
                       ! ((ci & di & ei) | (!ci & !di & !ei))) |
                      (disp6p & disp4p) | (disp6n & disp4n) |
                      (ai & bi & ci & !ei & !ii & ((!fi & !gi) | fghjp13)) |
                      (!ai & !bi & !ci & ei & ii & ((fi & gi) | fghjp31)) |
                      (fi & gi & !hi & !ji & disp6p) |
                      (!fi & !gi & hi & ji & disp6n) |
                      (ci & di & ei & ii & !fi & !gi & !hi) |
                      (!ci & !di & !ei & !ii & fi & gi & hi) ;
  
     {D_or_K,B8} = {ko, ho, go, fo, eo, d_o, co, bo, ao} ;

    // my disp err fires for any legal codes that violate disparity, 
    // may fire for illegal codes
    disp_err = !((dispin & disp6p) | (disp6n & !dispin) |
                        (dispin & !disp6n & fi & gi) |
                        (dispin & ai & bi & ci) |
                        (dispin & !disp6n & disp4p) |
                        (!dispin & !disp6p & !fi & !gi) |
                        (!dispin & !ai & !bi & !ci) |
                        (!dispin & !disp6p & disp4n) |
                        (disp6p & disp4p) | (disp6n & disp4n)) ;

    valid = !code_err;
    //valid = !disp_err && !code_err && dispout;
 end
endtask 
`endprotect

`ifdef ZI_INLINED_PSL
`include "0in_ac_inline_for_mod_zi_cw_sas_10b_8b_decoder.inc"
`endif
`ifdef ZI_INLINED_CHX
`include "zi_cw_sas_10b_8b_decoder.zi_chx.inc"
`else
`ifdef ZI_INLINED_CHX_zi_cw_sas_10b_8b_decoder
`include "zi_cw_sas_10b_8b_decoder.zi_chx.inc"
`endif
`endif

`qvlendmodule // End of module qvl_sas_10b_8b_decoder
