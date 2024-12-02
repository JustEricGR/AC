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

`qvlmodule qvl_value_coverage (
                               clk,
                               reset_n,
                               active,
                               test_expr,
                               is_not
                              );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter is_not_width = 1;
  parameter is_not_count = 0;
  parameter value_coverage = 0;

  // internal parameter
  parameter values_covered_width = (1<<width);
  parameter total_is_not_width = (is_not_width*is_not_count)?(is_not_width*is_not_count):1;
  
  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 
  input [total_is_not_width-1:0] is_not; 


  wire value_coverage_fire;
  wire all_values_covered;
  wire [63:0] values_checked;
  wire [63:0] values_covered;
  wire [63:0] values_uncovered;
  wire [63:0] smallest_value_covered;
  wire [63:0] largest_value_covered;
  wire [values_covered_width-1:0] values_covered_bitmap;
  wire [63:0] fire_count;

  wire  reset_n_sampled;
  wire  active_sampled;
  wire  [width-1:0] test_expr_sampled; 
  wire  [total_is_not_width-1:0] is_not_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr; 
  assign `QVL_DUT2CHX_DELAY is_not_sampled    = is_not; 

  qvl_value_coverage_assertions #(
                                  .severity_level(severity_level),
                                  .property_type(property_type),
                                  .msg(msg),
                                  .coverage_level(coverage_level),
                                  .VAR_WIDTH(width),
                                  .IS_NOT_WIDTH(is_not_width),
                                  .IS_NOT_COUNT(is_not_count)
                                 )
           qvl_value_coverage_chx (
                                   .active(active_sampled),
                                   .clock(clk),
                                   .reset(~reset_n_sampled),
                                   .areset(1'b0),
                                   .zivar(test_expr_sampled),
                                   .is_not(is_not_sampled),
                                   .used(1'b1),
                                   .used_cond(1'b1),
                                   .value_coverage(value_coverage == 1),
                                   .value_coverage_fire(value_coverage_fire),
                                   .all_values_covered(all_values_covered),
                                   .values_checked(values_checked),
                                   .values_covered((values_covered)),
                                   .values_uncovered(values_uncovered),
                                   .smallest_value_covered(smallest_value_covered),
                                   .largest_value_covered(largest_value_covered),
                                   .values_covered_bitmap(values_covered_bitmap),
                                   .support(1'b1),
                                   .fire_count(fire_count)
                                  );
`qvlendmodule
