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

`qvlmodule qvl_value (
                      clk,
                      reset_n,
                      active,
                      test_expr,
                      is_not,
                      val
                     );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;
  parameter val_width = 4;
  parameter num_values = 4;
  parameter value_xz = 0;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 
  input is_not; 
  input [((val_width*num_values)-1) : 0] val;

  wire value_fire;
  wire [63:0] values_checked;
  wire [63:0] values_covered;
  wire [num_values-1:0] values_covered_bitmap;
  wire all_values_covered;
  wire [63:0] fire_count;

  wire  reset_n_sampled;
  wire  active_sampled;
  wire  [width-1:0] test_expr_sampled; 
  wire  is_not_sampled; 
  wire  [((val_width*num_values)-1) : 0] val_sampled;

  assign `QVL_DUT2CHX_DELAY  reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY  test_expr_sampled = test_expr; 
  assign `QVL_DUT2CHX_DELAY  is_not_sampled    = is_not; 
  assign `QVL_DUT2CHX_DELAY  val_sampled       = val;

  qvl_value_assertions #(
                         .severity_level(severity_level),
                         .property_type(property_type),
                         .msg(msg),
                         .coverage_level(coverage_level),
                         .WIDTH(width),
                         .SETWIDTH(val_width),
                         .SETCOUNT(num_values),
                         .VALUEX((value_xz == 1) ? 1 : 0),
                         .VALUEZ((value_xz == 2) ? 1 : 0),
                         .BIT_VEC_WLOG2(`qvl_log2(num_values)),
                         .VALUE_ON(1)
                        )
          qvl_value_chx (
                         .zivar(test_expr_sampled),
                         .clock(clk),
                         .reset(~reset_n_sampled),
                         .areset(1'b0),
                         .value(~is_not_sampled),
                         .val(val_sampled),
                         .active(active_sampled),
                         .is_not(is_not_sampled),
                         .used(1'b1),
                         .used_cond(1'b1),
                         .is_not_check(is_not_sampled),
                         .value_fire(value_fire),
                         .values_checked(values_checked),
                         .values_covered(values_covered),
                         .values_covered_bitmap(values_covered_bitmap),
                         .all_values_covered(all_values_covered),
                         .support(1'b1),
                         .fire_count(fire_count)
                        );
`qvlendmodule
