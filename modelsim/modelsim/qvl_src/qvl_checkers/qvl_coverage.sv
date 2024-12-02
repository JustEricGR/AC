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

`include "std_qvl_defines.h"

`qvlmodule qvl_coverage (clk,
                         reset_n,
                         active,
                         test_expr
                        );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;

  input clk;
  input reset_n;
  input active;
  input test_expr;

  wire [63:0] covered_count;
  wire [63:0] fire_count;
  wire [63:0] subexpressions_covered;
  wire subexpressions_covered_bitmap;
  wire all_subexpressions_covered;
  wire covered_fire;
  
  wire reset_n_sampled;
  wire active_sampled;
  wire test_expr_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;
  
  qvl_coverage_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level)
     )
      qvl_coverage_chx (.active                        (active_sampled),
                        .clock                         (clk),
                        .reset                         (~reset_n_sampled),
                        .areset                        (1'b0),
                        .zivar                         (test_expr_sampled),
                        .sop                           (1'b0),
                        .pos                           (1'b0),
                        .covered_check                 (1'b1),
                        .covered_fire                  (covered_fire),
                        .covered_count                 (covered_count),
                        .subexpressions_covered        (subexpressions_covered),
                        .subexpressions_covered_bitmap (subexpressions_covered_bitmap),
                        .all_subexpressions_covered    (all_subexpressions_covered),
                        .fire_count                    (fire_count),
                        .support                       (1'b1)
                       );

`qvlendmodule
