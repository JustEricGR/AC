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

`ifdef QVL_STD_DEFINES_H
// do nothing
`else
`define QVL_STD_DEFINES_H

`include "qvl_defines_v.inc"

`ifdef QVL_RACE_AVOID
  `define QVL_DUT2CHX_DELAY #1
`else
  `define QVL_DUT2CHX_DELAY 
`endif

`ifdef QVL_ASSERT_ON
`define OVL_ASSERT_ON
`define OVL_SVA
`endif // QVL_ASSERT_ON

`ifdef QVL_COVER_ON
  `ifdef QVL_SV_COVERGROUP_OFF
  `else
    `define QVL_SV_COVERGROUP
  `endif // QVL_SV_COVERGROUP_OFF
`endif // QVL_COVER_ON

`ifdef QVL_COVER_ON
  `ifdef ZI_CW_COLLECT_STATS
    `undef ZI_CW_COLLECT_STATS
  `endif

  `ifdef ZI_CW_CHECKER_STATS
    `undef ZI_CW_CHECKER_STATS
  `endif

  `define ZI_CW_COLLECT_STATS 1'b1
  `define ZI_CW_CHECKER_STATS 1'b1
`endif

// specifying interface for System Verilog

`ifdef QVL_SVA_INTERFACE
  `define qvlmodule interface
  `define qvlendmodule endinterface
`else
  `define qvlmodule module
  `define qvlendmodule endmodule
`endif

// severity levels

`define QVL_FATAL   0
`define QVL_ERROR   1
`define QVL_WARNING 2
`define QVL_INFO    3

// coverage levels

`define QVL_COVER_NONE      0
`define QVL_COVER_SANITY    1
`define QVL_COVER_BASIC     2
`define QVL_COVER_CORNER    4
`define QVL_COVER_STATISTIC 8
`define QVL_COVER_ALL       15 

// property type

`define QVL_ASSERT 0
`define QVL_ASSUME 1
`define QVL_IGNORE 2

// delay value for simulation after fatal condition

`define QVL_RUNTIME_AFTER_FATAL 100

// 32-bit biggest integer required for default value same as 32'hffff_ffff 

`define BIGGEST_INTEGER_32_BIT 4294967295 

// Functions for logarithmic calculation

`define qvl_log2(n) ((n) <= (1<<0) ? 1 :\
                     (n) <= (1<<1) ? 1 :\
                     (n) <= (1<<2) ? 2 :\
                     (n) <= (1<<3) ? 3 :\
                     (n) <= (1<<4) ? 4 :\
                     (n) <= (1<<5) ? 5 :\
                     (n) <= (1<<6) ? 6 :\
                     (n) <= (1<<7) ? 7 :\
                     (n) <= (1<<8) ? 8 :\
                     (n) <= (1<<9) ? 9 :\
                     (n) <= (1<<10) ? 10 :\
                     (n) <= (1<<11) ? 11 :\
                     (n) <= (1<<12) ? 12 :\
                     (n) <= (1<<13) ? 13 :\
                     (n) <= (1<<14) ? 14 :\
                     (n) <= (1<<15) ? 15 :\
                     (n) <= (1<<16) ? 16 :\
                     (n) <= (1<<17) ? 17 :\
                     (n) <= (1<<18) ? 18 :\
                     (n) <= (1<<19) ? 19 :\
                     (n) <= (1<<20) ? 20 :\
                     (n) <= (1<<21) ? 21 :\
                     (n) <= (1<<22) ? 22 :\
                     (n) <= (1<<23) ? 23 :\
                     (n) <= (1<<24) ? 24 :\
                     (n) <= (1<<25) ? 25 :\
                     (n) <= (1<<26) ? 26 :\
                     (n) <= (1<<27) ? 27 :\
                     (n) <= (1<<28) ? 28 :\
                     (n) <= (1<<29) ? 29 :\
                     (n) <= (1<<30) ? 30 :\
                     (n) <= (1<<31) ? 31 : 32)

// Functions for inferring width of a parameter

`define qvl_infer_width(n) ((n) <= ((1<<1)-1) ? 1 :\
                            (n) <= ((1<<2)-1) ? 2 :\
                            (n) <= ((1<<3)-1) ? 3 :\
                            (n) <= ((1<<4)-1) ? 4 :\
                            (n) <= ((1<<5)-1) ? 5 :\
                            (n) <= ((1<<6)-1) ? 6 :\
                            (n) <= ((1<<7)-1) ? 7 :\
                            (n) <= ((1<<8)-1) ? 8 :\
                            (n) <= ((1<<9)-1) ? 9 :\
                            (n) <= ((1<<10)-1) ? 10 :\
                            (n) <= ((1<<11)-1) ? 11 :\
                            (n) <= ((1<<12)-1) ? 12 :\
                            (n) <= ((1<<13)-1) ? 13 :\
                            (n) <= ((1<<14)-1) ? 14 :\
                            (n) <= ((1<<15)-1) ? 15 :\
                            (n) <= ((1<<16)-1) ? 16 :\
                            (n) <= ((1<<17)-1) ? 17 :\
                            (n) <= ((1<<18)-1) ? 18 :\
                            (n) <= ((1<<19)-1) ? 19 :\
                            (n) <= ((1<<20)-1) ? 20 :\
                            (n) <= ((1<<21)-1) ? 21 :\
                            (n) <= ((1<<22)-1) ? 22 :\
                            (n) <= ((1<<23)-1) ? 23 :\
                            (n) <= ((1<<24)-1) ? 24 :\
                            (n) <= ((1<<25)-1) ? 25 :\
                            (n) <= ((1<<26)-1) ? 26 :\
                            (n) <= ((1<<27)-1) ? 27 :\
                            (n) <= ((1<<28)-1) ? 28 :\
                            (n) <= ((1<<29)-1) ? 29 :\
                            (n) <= ((1<<30)-1) ? 30 :\
                            (n) <= ((1<<31)-1) ? 31 : 32)
     
`endif // QVL_STD_DEFINES_H
