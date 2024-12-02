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

`qvlmodule qvl_change_timer (
                             clk,
                             reset_n,
                             active,
                             test_expr,
                             max,
                             min
                           );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter min_check = 0;
  parameter max_check = 0;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr;
  input [31:0] max; 
  input [31:0] min; 

  wire max_fire;
  wire min_fire;
  wire min_gt_max_fire;
  wire [63:0] values_checked;
  wire [63:0] shortest_change_time; 
  wire [63:0] longest_change_time; 
  wire [63:0] value_changed_at_min_count; 
  wire [63:0] value_changed_at_max_count; 
  wire [63:0] fire_count; 
 
  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled;
  wire [31:0] max_sampled; 
  wire [31:0] min_sampled; 
  
  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active; 
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;
  assign `QVL_DUT2CHX_DELAY max_sampled = max;
  assign `QVL_DUT2CHX_DELAY min_sampled = min;
  
  qvl_change_timer_assertions #(
                                .severity_level(severity_level),
                                .property_type(property_type),
                                .msg(msg),
                                .coverage_level(coverage_level),
                                .WIDTH(width),
                                .MIN_WIDTH_DEFAULT(32),
                                .MAX_WIDTH_DEFAULT(32),
                                .MAX_SPECIFIED(max_check > 0),
                                .MIN_IS_CONST(0),
                                .MIN_CONST_VAL(1),
                                .MAX_IS_CONST(0),
                                .MAX_CONST_VAL(1),
				.MIN_CHECK(min_check > 0),
				.MAX_CHECK(max_check>0)
                               )
          qvl_change_timer_chx (
                                .active(active_sampled),
                                .clock(clk),
                                .reset(~reset_n_sampled),
                                .areset(1'b0),

                                .zivar(test_expr_sampled),
                                .min(min_sampled),
                                .max(max_sampled),

                                .min_check(min_check > 0),
                                .max_check(max_check > 0),

                                .min_fire(min_fire),
                                .max_fire(max_fire),
                                .min_gt_max_fire(min_gt_max_fire),

                                .values_checked(values_checked),
                                .shortest_change_time(shortest_change_time),
                                .longest_change_time(longest_change_time),
                        .value_changed_at_min_count(value_changed_at_min_count),
                        .value_changed_at_max_count(value_changed_at_max_count),
                                .support(1'b1),
                                .fire_count(fire_count)
                                );
`qvlendmodule
