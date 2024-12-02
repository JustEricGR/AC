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

`qvlmodule qvl_data_used (clk,
                          reset_n,
                          active,
                          test_expr,
                          valid,
                          load_condition,
                          used_condition,
                          flush,
                          start,
                          stop
                         );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 2; // Width of test_expr.
  parameter any_load = 0; // 0 - loaded when new data.
  parameter start_enable = 0;
  parameter restart = 0; // 0 - Ignore new start.
                         // 1 - Restart on new start.
  parameter no_restart_check = 0; // If 0, check is off.
  parameter start_count = 0;
  parameter stop_enable = 0;
  parameter stop_count = 0;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 
  input valid;
  input load_condition;
  input used_condition;
  input flush;
  input start;
  input stop;

  wire data_used_fire;
  wire no_restart_fire;
  wire [63:0] values_checked;
  wire [63:0] longest_unused;
  wire [63:0] shortest_unused;
  wire window;
  wire [63:0] data_used_at_window_open_count;
  wire [63:0] data_used_at_window_close_count;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled; 
  wire valid_sampled;
  wire load_condition_sampled;
  wire used_condition_sampled;
  wire flush_sampled;
  wire start_sampled; 
  wire stop_sampled;
  wire [width-1:0] test_expr_sampled; 

  assign  `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign  `QVL_DUT2CHX_DELAY active_sampled = active;
  assign  `QVL_DUT2CHX_DELAY valid_sampled = valid;
  assign  `QVL_DUT2CHX_DELAY flush_sampled = flush;
  assign  `QVL_DUT2CHX_DELAY start_sampled = start;
  assign  `QVL_DUT2CHX_DELAY stop_sampled =  stop;
  assign  `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;
  assign  `QVL_DUT2CHX_DELAY load_condition_sampled = load_condition;
  assign  `QVL_DUT2CHX_DELAY used_condition_sampled = used_condition;
  

  qvl_data_used_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .ACTION_ON_NEW_START ((restart === 1) ? 1 : (no_restart_check === 1) ? 2 :0),
      .VAR_WIDTH (width),
      .START_COUNT_WIDTH (`qvl_infer_width(start_count)),
      .STOP_COUNT_WIDTH (`qvl_infer_width(stop_count)),
      .START_DECLARED (start_enable),
      .STOP_DECLARED (stop_enable),
      .START_COUNT_DECLARED (start_count > 0),
      .STOP_COUNT_DECLARED (stop_count > 0),
      .NO_RESTART_CHK_ON(no_restart_check>0)
     )
      qvl_data_used_chx (.clock             (clk),
                         .reset             (~reset_n_sampled),
                         .areset            (1'b0),
                         .active            (active_sampled),
                         .zivar             (test_expr_sampled),
                         .load_cond         (load_condition_sampled),
                         .used_cond         (used_condition_sampled),
                         .start             ((start_enable ? start_sampled : 1'b0)),
                         .stop              ((stop_enable ? stop_sampled : 1'b0)),
                         .start_count       (start_count[(`qvl_infer_width(start_count))-1:0]),
                         .stop_count        (stop_count[(`qvl_infer_width(stop_count))-1:0]),
                         .any_load          (any_load == 1),
                         .flush             (flush_sampled),
                         .valid_data        (valid_sampled),
                         .data_used         (1'b1),
                         .data_used_fire    (data_used_fire),
                         .no_restart_check  ((no_restart_check === 1) && (start_enable) && (restart === 0)),
                         .no_restart_fire   (no_restart_fire),
                         .values_checked    (values_checked),
                         .longest_unused    (longest_unused),
                         .shortest_unused   (shortest_unused),
                         .window            (window),
                         .data_used_at_window_open_count (data_used_at_window_open_count),
                         .data_used_at_window_close_count(data_used_at_window_close_count),
                         .fire_count        (fire_count),
                         .support           (1'b1)
                         );

`qvlendmodule
