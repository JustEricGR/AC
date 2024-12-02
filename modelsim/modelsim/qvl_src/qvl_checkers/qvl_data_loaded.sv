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

`qvlmodule qvl_data_loaded (
                            clk,
                            reset_n,
                            active,
                            start,
                            stop, 
                            load_condition
                           );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter start_count = 0;
  parameter stop_count = 0;
  parameter restart = 0;
  parameter no_restart_check = 0;

  input clk; 
  input reset_n;
  input active;
  input start;
  input stop;
  input load_condition;

  wire [63:0] fire_count;
  wire data_loaded_fire;
  wire no_restart_fire;
  wire [63:0] windows_checked;
  wire [63:0] longest_wait;
  wire [63:0] shortest_wait;
  wire window;
  wire [63:0] data_loaded_at_window_open_count;
  wire [63:0] data_loaded_at_window_close_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire start_sampled;
  wire stop_sampled;
  wire load_condition_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY start_sampled   = start;
  assign `QVL_DUT2CHX_DELAY stop_sampled   = stop;
  assign `QVL_DUT2CHX_DELAY load_condition_sampled   = load_condition;

  qvl_data_loaded_assertions #(
                              .severity_level(severity_level),
                              .property_type(property_type),
                              .msg(msg),
                              .coverage_level(coverage_level),
                              .VAR_WIDTH(3),
 .ACTION_ON_NEW_START((restart == 1) ? 1 : ((no_restart_check === 1) ? 2 : 0)),
                              .START_COUNT_WIDTH((`qvl_infer_width(start_count))),
                              .STOP_COUNT_WIDTH((`qvl_infer_width(stop_count))),
                              .START_COUNT_DECLARED(start_count > 0),
                              .STOP_DECLARED(stop_count == 0),
                              .STOP_COUNT_DECLARED(stop_count > 0),
			      .NO_RESTART_CHK_ON(no_restart_check >0)
                             )
         qvl_data_loaded_chx (
                               .clock(clk),
                               .reset(~reset_n_sampled),
                               .areset(1'b0), 
                               .active(active_sampled),
                               .zivar(3'b101), 
                               .start(start_sampled), 
                               .stop(stop_sampled),
                               .start_count(start_count[`qvl_infer_width(start_count) - 1:0]),
                               .stop_count(stop_count[`qvl_infer_width(stop_count) - 1:0]),
                               .load_cond(load_condition_sampled),
                               .data_loaded(1'b1),
                               .no_restart_check((no_restart_check > 0)),
                               .data_loaded_fire(data_loaded_fire),
                               .no_restart_fire(no_restart_fire),
                               .windows_checked(windows_checked),
                               .longest_wait(longest_wait),
                               .shortest_wait(shortest_wait),
                               .window(window),
          .data_loaded_at_window_open_count(data_loaded_at_window_open_count),
          .data_loaded_at_window_close_count(data_loaded_at_window_close_count),
                               .support(1'b1),
                               .fire_count(fire_count)
                             );
`qvlendmodule
