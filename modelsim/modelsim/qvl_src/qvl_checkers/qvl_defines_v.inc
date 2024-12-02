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

`ifdef ZiQVLStdDefines
// do nothing
`else
`define ZiQVLStdDefines


// the above MUST be the first ifdef


`ifdef ZI_AXIS_SIM
`ifdef ZI_XMAP_SIM_DB
`ifdef ZI_NO_STATS
`else
`define ZI_CW_COLLECT_STATS
`endif // ZI_NO_STATS
`else // ZI_AXIS_SIM_DB
// if ZI_AXIS_SIM but not ZI_AXIS_SIM_DB, no stats
`endif // ZI_AXIS_SIM_DB
`else // ZI_AXIS_SIM
`ifdef ZI_FOR_SEARCH
`define ZI_CW_COLLECT_STATS
`else
`ifdef ZI_NO_STATS
`else
`define ZI_CW_COLLECT_STATS
`endif // ZI_NO_STATS
`endif // ZI_FOR_SEARCH
`endif // ZI_AXIS_SIM

//`ifdef ZI_CW_NO_FIRE_XZ
//`else
//`define ZI_CW_FIRE_XZ
//`endif

// Data Types
`define ZiCwStatistic                     0
`define ZiCwCornerCase                    1
`define ZiCwPrecondition                  2
`define ZiCwEval                          3

`define ZiCwNormal                        `ZiCwStatistic

// Accumulation Types
`define ZiCwSum                           0
`define ZiCwMin                           1
`define ZiCwMax                           2
`define ZiCwCurrent                       4
`define ZiCwBitOr                         5
`define ZiCwBitAnd                        6

// Report Operator
`define ZiCwInteger                       0
`define ZiCwNumberOfOnes                  1
`define ZiCwNumberOfZeros                 2
`define ZiCwIsAllOne                      3
`define ZiCwIsAllZero                     4
`define ZiCwIndicesOfOnes                 5
`define ZiCwIndicesOfZeros                6
`define ZiCwHex                           7
`define ZiCwBinary                        8

// Target Coverage
`define ZiCwTCOff                         0
`define ZiCwTCOn                          1

// null defines
`define ZiCwAllChecks                     "all_checks"
//`define ZiCwAllChecks                     ""
`define ZiCwNoStatCtrl                    0

`ifdef ZiCwDebug
`define ZiCwDebugDelay1 #1
`else
`define ZiCwDebugDelay1
`endif //ZiCwDebug


`ifdef ZI_CW_IN_RANGE
// do nothing
`else
`define ZI_CW_IN_RANGE 4
`endif // ZI_CW_IN_RANGE

// Target Coverage
//`ifdef ZI_CW_TARGET_COVERAGE
`define ZI_CW_CHECKER_STATS 1'b1
`define ZI_CW_CHX_STATS 1'b1
//`else
//`define ZI_CW_CHECKER_STATS checker_stats
//`define ZI_CW_CHX_STATS chx_stats
//`endif // !ifdef ZI_CW_TARGET_COVERAGE


`ifdef ZI_IDENTIFY
`ifdef ZI_CW_STAT_CNT_WIDTH
// do nothing
`else
`define ZI_CW_STAT_CNT_WIDTH 8
`endif // 
`ifdef ZI_CW_FOR_FPGA
`else
`define ZI_CW_FOR_FPGA
`endif // ZI_CW_FOR_FPGA
`endif // ifdef ZI_IDENTIFY

`ifdef ZI_PD
`ifdef ZI_CW_STAT_CNT_WIDTH
// do nothing
`else
`define ZI_CW_STAT_CNT_WIDTH 8
`endif
`ifdef ZI_CW_FOR_FPGA
`else
`define ZI_CW_FOR_FPGA
`endif // ZI_CW_FOR_FPGA
`endif // ifdef ZI_PD

`ifdef ZI_CW_STAT_CNT_WIDTH
// do nothing
`else
`define ZI_CW_STAT_CNT_WIDTH 64
`endif // ZI_CW_STAT_CNT_WIDTH


// the following MUST be the last endif
`endif // ZiQVLStdDefines
