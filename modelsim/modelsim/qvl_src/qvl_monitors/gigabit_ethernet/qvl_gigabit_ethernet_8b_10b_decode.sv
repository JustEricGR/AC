//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.                           
//                                                                          
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY             
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS          
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE         
//                                  TERMS.                                  
//                                                                          
//       U.S. Patent Numbers 6,175,946, 6,292,765, 6,609,229, 6,848,088     
//                               and 6,885,983                              
//
/***********************************************************************
 * PURPOSE       This file is part of the 0-In CheckerWare.
 *               It describes the 10B to 8B decoder module.
 *
 * DESCRIPTION   This module decodes the input 10-bit symbols to 8-bit
 *               data and 1-bit control line indicating whether it is a
 *               data or control character. It also provides the new 
 *               disparity to be used while decoding the next symbol. 
 *
 * REFERENCE     802.3 IEEE Standard for Information Technology, CSMA/CD
 *               access method and physical layer specifications, 2002
 *
 *
 * INPUTS        datain   - encoded 10-bit symbol
 *               dispin   - current disparity
 * OUTPUTS       dataout  - decoded 8-bit data + 1-bit control
 *               dispout  - new disparity
 *               code_err - code error (invalid code-group)
 *               disp_err - disparity error 
 *
 * LAST MODIFIED 07 December 2004
 *
 *********************************************************************/

`qvlmodule qvl_gigabit_ethernet_8b_10b_decode (datain, 
                                             dispin, 
                                             dataout, 
                                             dispout, 
                                             code_err, 
                                             disp_err
                                            );

  input [9:0]   datain;
  input         dispin;
  output [8:0]  dataout;
  output        dispout;
  output        code_err;
  output        disp_err;

  // Internal wires for 10b decoding. This module is a pure combinatorial 
  // 8b/10b decoder.
  wire ai;
  wire bi;
  wire ci;
  wire di;
  wire ei;
  wire ii;
  wire fi;
  wire gi;
  wire hi;
  wire ji;
  wire aeqb;
  wire ceqd;
  wire p22;
  wire p13;
  wire p31;
  wire p40;
  wire p04;
  wire disp6a;
  wire disp6a2;
  wire disp6a0;
  wire disp6b;
  wire p22bceeqi;
  wire p22bncneeqi;
  wire p13in;
  wire p31i;
  wire p13dei;
  wire p22aceeqi;
  wire p22ancneeqi;
  wire p13en;
  wire anbnenin;
  wire abei;
  wire cdei;
  wire cndnenin;
  wire p22enin;
  wire p22ei;
  wire p31dnenin;
  wire p31e;
  wire compa;
  wire compb;
  wire compc;
  wire compd;
  wire compe;
  wire ao;
  wire bo;
  wire co;
  wire doo;
  wire eo;
  wire feqg;
  wire heqj;
  wire fghj22;
  wire fghjp13;
  wire fghjp31;
  wire ko;
  wire alt7;
  wire k28;
  wire k28p;
  wire fo;
  wire go;
  wire ho;
  wire disp6p;
  wire disp6n;
  wire disp4p;
  wire disp4n;


  assign ai = datain[0];
  assign bi = datain[1];
  assign ci = datain[2];
  assign di = datain[3];
  assign ei = datain[4];
  assign ii = datain[5];
  assign fi = datain[6];
  assign gi = datain[7];
  assign hi = datain[8];
  assign ji = datain[9];

  assign aeqb = (ai & bi) | (!ai & !bi);
  assign ceqd = (ci & di) | (!ci & !di);
  assign p22 = (ai & bi & !ci & !di) |
             (ci & di & !ai & !bi) |
             ( !aeqb & !ceqd);
  assign p13 = ( !aeqb & !ci & !di) |
             ( !ceqd & !ai & !bi);
  assign p31 = ( !aeqb & ci & di) |
             ( !ceqd & ai & bi);

  assign p40 = ai & bi & ci & di;
  assign p04 = !ai & !bi & !ci & !di;

  assign disp6a = p31 | (p22 & dispin); // pos disp if p22 and was pos, or p31.
  assign disp6a2 = p31 & dispin;  // disp is ++ after 4 bits
  assign disp6a0 = p13 & ! dispin; // -- disp after 4 bits
    
  assign disp6b = (ei & ii & ! disp6a0) | (disp6a & (ei | ii)) | disp6a2;

  // The 5B/6B decoding special cases where ABCDE != abcde

  assign p22bceeqi = p22 & bi & ci & (ei == ii);
  assign p22bncneeqi = p22 & !bi & !ci & (ei == ii);
  assign p13in = p13 & !ii;
  assign p31i = p31 & ii;
  assign p13dei = p13 & di & ei & ii;
  assign p22aceeqi = p22 & ai & ci & (ei == ii);
  assign p22ancneeqi = p22 & !ai & !ci & (ei == ii);
  assign p13en = p13 & !ei;
  assign anbnenin = !ai & !bi & !ei & !ii;
  assign abei = ai & bi & ei & ii;
  assign cdei = ci & di & ei & ii;
  assign cndnenin = !ci & !di & !ei & !ii;

  // non-zero disparity cases:
  assign p22enin = p22 & !ei & !ii;
  assign p22ei = p22 & ei & ii;
  //assign p13in = p12 & !ii;
  //assign p31i = p31 & ii;
  assign p31dnenin = p31 & !di & !ei & !ii;
  //assign p13dei = p13 & di & ei & ii;
  assign p31e = p31 & ei;

  assign compa = p22bncneeqi | p31i | p13dei | p22ancneeqi | 
                p13en | abei | cndnenin;
  assign compb = p22bceeqi | p31i | p13dei | p22aceeqi | 
                p13en | abei | cndnenin;
  assign compc = p22bceeqi | p31i | p13dei | p22ancneeqi | 
                p13en | anbnenin | cndnenin;
  assign compd = p22bncneeqi | p31i | p13dei | p22aceeqi |
                p13en | abei | cndnenin;
  assign compe = p22bncneeqi | p13in | p13dei | p22ancneeqi | 
                p13en | anbnenin | cndnenin;

  assign ao = ai ^ compa;
  assign bo = bi ^ compb;
  assign co = ci ^ compc;
  assign doo = di ^ compd;
  assign eo = ei ^ compe;

  assign feqg = (fi & gi) | (!fi & !gi);
  assign heqj = (hi & ji) | (!hi & !ji);
  assign fghj22 = (fi & gi & !hi & !ji) |
                (!fi & !gi & hi & ji) |
                ( !feqg & !heqj);
  assign fghjp13 = ( !feqg & !hi & !ji) |
                 ( !heqj & !fi & !gi);
  assign fghjp31 = ( (!feqg) & hi & ji) |
                 ( !heqj & fi & gi);

  assign dispout = fghjp31 | (disp6b & fghj22);

  assign ko = ( (ci & di & ei & ii) | ( !ci & !di & !ei & !ii) |
                (p13 & !ei & ii & gi & hi & ji) |
                (p31 & ei & !ii & !gi & !hi & !ji));

  assign alt7 =   (fi & !gi & !hi & // 1000 cases, where disp6b is 1
                 ((dispin & ci & di & !ei & !ii) | ko |
                  (dispin & !ci & di & !ei & !ii))) |
                (!fi & gi & hi & // 0111 cases, where disp6b is 0
                 (( !dispin & !ci & !di & ei & ii) | ko |
                  ( !dispin & ci & !di & ei & ii)));

  assign k28 = (ci & di & ei & ii) | ! (ci | di | ei | ii);
  // k28 with positive disp into fghi - .1, .2, .5, and .6 special cases
  assign k28p = ! (ci | di | ei | ii);
  assign fo = (ji & !fi & (hi | !gi | k28p)) |
            (fi & !ji & (!hi | gi | !k28p)) |
            (k28p & gi & hi) |
            (!k28p & !gi & !hi);
  assign go = (ji & !fi & (hi | !gi | !k28p)) |
            (fi & !ji & (!hi | gi |k28p)) |
            (!k28p & gi & hi) |
            (k28p & !gi & !hi);
  assign ho = ((ji ^ hi) & ! ((!fi & gi & !hi & ji & !k28p) | 
            (!fi & gi & hi & !ji & k28p) | 
            (fi & !gi & !hi & ji & !k28p) | 
            (fi & !gi & hi & !ji & k28p))) |
            (!fi & gi & hi & ji) | (fi & !gi & !hi & !ji);

  assign disp6p = (p31 & (ei | ii)) | (p22 & ei & ii);
  assign disp6n = (p13 & ! (ei & ii)) | (p22 & !ei & !ii);
  assign disp4p = fghjp31;
  assign disp4n = fghjp13;

  assign code_err = p40 | p04 | (fi & gi & hi & ji) | (!fi & !gi & !hi & !ji) |
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
                    (!ci & !di & !ei & !ii & fi & gi & hi);

  assign dataout = {ko, ho, go, fo, eo, doo, co, bo, ao};

  // disparity error fires for any legal codes that violate disparity

   assign disp_err = ((dispin & disp6p) | (disp6n & !dispin) |
                      (dispin & !disp6n & fi & gi) |
                      (dispin & ai & bi & ci) |
                      (dispin & !disp6n & disp4p) |
                      (!dispin & !disp6p & !fi & !gi) |
                      (!dispin & !ai & !bi & !ci) |
                      (!dispin & !disp6p & disp4n) |
                      (disp6p & disp4p) | (disp6n & disp4n));




`ifdef ZI_INLINED_PSL
`include "0in_ac_inline_for_mod_zi_cw_gigabit_ethernet_8b_10b_decode.inc"
`endif
`ifdef ZI_INLINED_CHX
`include "zi_cw_gigabit_ethernet_8b_10b_decode.zi_chx.inc"
`else
`ifdef ZI_INLINED_CHX_zi_cw_gigabit_ethernet_8b_10b_decode
`include "zi_cw_gigabit_ethernet_8b_10b_decode.zi_chx.inc"
`endif
`endif

`qvlendmodule // zi_cw_gigabit_ethernet_8b_10b_decode
