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

`qvlmodule qvl_hamming_distance (clk,
                                 reset_n,
                                 active,
                                 test_expr
                                );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter distance = 0;
  parameter min = 0;
  parameter max = 0;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 

  wire   equal_fire;
  wire   min_fire;
  wire   max_fire;
  wire   [63:0] fire_count;

  wire [63:0] total_checked_cycles;
  wire [63:0] equal_distance_cycles;
  wire [63:0] min_distance;
  wire [63:0] max_distance;
  wire [63:0] min_bits_changed_count;
  wire [63:0] max_bits_changed_count;


  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;


  qvl_hamming_distance_assertions
    #(.severity_level (severity_level), 
      .property_type (property_type), 
      .msg (msg), 
      .coverage_level (coverage_level), 
      .WIDTH (width),
      .DISTANCE (distance),
      .MIN (min),
      .MAX (max), 
      .CNTWIDTH (`qvl_log2(width)))
      qvl_hamming_distance_chx (
                       .clock                  (clk),
                       .reset                  (~reset_n_sampled),
                       .areset                 (1'b0),
                       .active                 (active_sampled),
                       .zivar                  (test_expr_sampled),
                       .used                   (1'b1),
                       .used_cond              (1'b1),
                       .equal_check            (distance > 0),
                       .min_check              (min > 0),
                       .max_check              (max > 0),
                       .equal_fire             (equal_fire),
                       .min_fire               (min_fire),
                       .max_fire               (max_fire),
                       .total_checked_cycles   (total_checked_cycles),
                       .equal_distance_cycles  (equal_distance_cycles),
                       .min_distance           (min_distance),
                       .max_distance           (max_distance),
                       .min_bits_changed_count (min_bits_changed_count),
                       .max_bits_changed_count (max_bits_changed_count),
                       .support                (1'b1),
                       .fire_count             (fire_count)
                               );
`qvlendmodule
