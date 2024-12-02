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

`qvlmodule qvl_timeout (clk,
                        reset_n,
                        active,
                        test_expr,
                        val
                     );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 2;
  parameter val_width = 1;
  parameter max_possible_val = `BIGGEST_INTEGER_32_BIT;
    

  input clk; 
  input reset_n;
  input active;
  input [val_width-1:0] val; 
  input [width-1:0] test_expr; 

  wire [63:0] values_checked;
  wire [63:0] slowest_value_change;
  wire [63:0] fastest_value_change;
  wire [63:0] val_changed_at_max;
  wire [63:0] fire_count;

  wire timeout_fire;

  wire  reset_n_sampled;
  wire  active_sampled;
  wire  [val_width-1:0] val_sampled; 
  wire  [width-1:0] test_expr_sampled; 

  assign `QVL_DUT2CHX_DELAY  reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY  val_sampled       = val; 
  assign `QVL_DUT2CHX_DELAY  test_expr_sampled = test_expr; 

  qvl_timeout_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .WIDTH (width),
      .VALWIDTH (val_width),
      .max_possible_val (max_possible_val)
     )
      qvl_timeout_chx (.clock               (clk),
                     .areset                (1'b0),
                     .reset                 (~reset_n_sampled),
                     .active                (active_sampled),
                     .zivar                 (test_expr_sampled),
                     .val                   (val_sampled), 
                     .timeout               (1'b1),
                     .timeout_fire          (timeout_fire),
                     .values_checked        (values_checked),
                     .fastest_value_change  (fastest_value_change),
                     .slowest_value_change  (slowest_value_change),
                     .val_changed_at_max    (val_changed_at_max),
                     .support               (1'b1),
                     .fire_count            (fire_count)
                    );

`qvlendmodule
