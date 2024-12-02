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

`qvlmodule qvl_minimum (clk,
                        reset_n,
                        active,
                        test_expr,
                        val 
                       );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;
  parameter val_width = 4;
  parameter twos_complement = 0; 

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 
  input [val_width-1:0] val; 

  wire [63:0] values_checked;
  wire [width-1:0] smallest_value;
  wire [width-1:0] current_value;
  wire [63:0] value_is_min;
  wire [63:0] fire_count;

  wire minimum_fire;

 wire reset_n_sampled;
 wire active_sampled;
 wire [width-1:0] test_expr_sampled; 
 wire [val_width-1:0] val_sampled;

 assign `QVL_DUT2CHX_DELAY reset_n_sampled              = reset_n;
 assign `QVL_DUT2CHX_DELAY active_sampled               = active;
 assign `QVL_DUT2CHX_DELAY test_expr_sampled            = test_expr;
 assign `QVL_DUT2CHX_DELAY val_sampled                  = val; 

 

  qvl_minimum_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .WIDTH (width),
      .VALWIDTH (val_width),
      .TWOSCOMP (twos_complement)
     )
      qvl_minimum_chx (.clock                    (clk),
                       .areset                   (1'b0),
                       .reset                    (~reset_n_sampled),
                       .active                   (active_sampled),
                       .zivar                    (test_expr_sampled),
                       .val                      (val_sampled), 
                       .minimum                  (1'b1), 
                       .minimum_fire             (minimum_fire), 
                       .used                     (1'b1), 
                       .used_cond                (1'b1), 
                       .values_checked           (values_checked),
                       .smallest_value           (smallest_value),
                       .current_value            (current_value),
                       .value_is_min             (value_is_min),
                       .support                  (1'b1),
                       .fire_count               (fire_count)
                      );
`qvlendmodule
