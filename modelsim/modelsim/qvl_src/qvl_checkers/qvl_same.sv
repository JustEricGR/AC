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

`qvlmodule qvl_same (
                      clk,
                      reset_n,
                      active,
                      test_expr);

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter count = 2;
  parameter match_xz = 0;

  //internal parameter
  parameter width_internal = count*width;
  
  input clk; 
  input reset_n;
  input active;
  input [width_internal-1:0]test_expr;

  wire same_fire;
  wire [63:0] evaluations;
  wire [width-1:0] set_to_one_bitmap;
  wire [width-1:0] set_to_zero_bitmap;
  wire each_bit_set_to_one;
  wire each_bit_set_to_zero;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire [width_internal-1:0] test_expr_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;

  qvl_same_assertions #(
                        .severity_level(severity_level),
                        .property_type(property_type),
                        .msg(msg),
                        .coverage_level(coverage_level),
                        .MATCH_XZ(match_xz),
                        .VAR_ITEM_COUNT(count),
                        .VAR_ITEM_WIDTH(width)
                        )
           qvl_same_chx (
                         .active               (active_sampled),
                         .clock                (clk),
                         .reset                (~reset_n_sampled),
                         .areset               (1'b0),
                         .zivar                (test_expr_sampled),
                         .used                 (1'b0),
                         .used_cond            (1'b1),
                         .same                 (1'b1),
                         .same_fire            (same_fire),
                         .evaluations          (evaluations),
                         .set_to_one_bitmap    (set_to_one_bitmap),
                         .set_to_zero_bitmap   (set_to_zero_bitmap),
                         .each_bit_set_to_one  (each_bit_set_to_one),
                         .each_bit_set_to_zero (each_bit_set_to_zero),
                         .support              (1'b1));

`qvlendmodule
