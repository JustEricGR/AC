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

`qvlmodule qvl_mutex (clk,
                      reset_n,
                      active,
                      test_expr
                     );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 

  wire [63:0] values_checked;
  wire [63:0] all_off;
  wire all_mutex_checked;
  wire [width-1:0] mutex_checked;
  wire [width-1:0] mutex_bitmap;
  wire mutex_fire;

  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;

  qvl_mutex_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .WIDTH (width)
     )
      qvl_mutex_chx (.active            (active_sampled),
                     .clock             (clk),
                     .reset             (~reset_n_sampled),
                     .areset            (1'b0),
                     .zivar             (test_expr_sampled),
                     .used              (1'b1),
                     .used_cond         (1'b1),
                     .mutex             (1'b1),
                     .mutex_fire        (mutex_fire),
                     .values_checked    (values_checked),
                     .mutex_checked     (mutex_checked),
                     .mutex_bitmap      (mutex_bitmap),
                     .all_off           (all_off),
                     .all_mutex_checked (all_mutex_checked),
                     .support           (1'b1)
                    );

`qvlendmodule
