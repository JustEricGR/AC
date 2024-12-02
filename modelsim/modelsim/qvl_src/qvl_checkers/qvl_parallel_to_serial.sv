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

`qvlmodule qvl_parallel_to_serial (
                                   in_clk,
                                   out_clk,
                                   in_reset_n,
                                   out_reset_n,
                                   active,
                                   in_active,
                                   out_active,
                                   load,
                                   hold,
                                   msb,
                                   in_data, 
                                   out_data
                                 );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;
  parameter latency = 0;
  parameter sync_delay = 0;
  parameter msb_convert_check = 0;
  parameter hold_check = 0;
  parameter reversal_check = 0;
  parameter consecutive_load_check = 0;

  input in_clk; 
  input out_clk; 
  input in_reset_n;
  input out_reset_n;
  input active;
  input in_active;
  input out_active;
  input [width-1:0] in_data; 
  input load;
  input hold; 
  input msb;
  input out_data;

  wire right_shift_fire;
  wire left_shift_fire;
  wire hold_fire;
  wire shift_mode_reversal_fire;
  wire load_before_conversion_fire;
  wire no_load_after_full_conversion_fire;
  wire [63:0] complete_right_shifts;
  wire [63:0] complete_left_shifts;
  wire [63:0] total_shifts;
  wire [63:0] right_shifts;
  wire [63:0] left_shifts;
  wire [63:0] load_cycles;
  wire [63:0] hold_cycles;
  wire [63:0] fire_count;

  wire in_reset_n_sampled;
  wire out_reset_n_sampled;
  wire active_sampled;
  wire in_active_sampled;
  wire out_active_sampled;
  wire [width-1:0] in_data_sampled; 
  wire load_sampled;
  wire hold_sampled; 
  wire msb_sampled;
  wire out_data_sampled;


  assign `QVL_DUT2CHX_DELAY in_reset_n_sampled  = in_reset_n;
  assign `QVL_DUT2CHX_DELAY out_reset_n_sampled = out_reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled      = active;
  assign `QVL_DUT2CHX_DELAY in_active_sampled   = in_active;
  assign `QVL_DUT2CHX_DELAY out_active_sampled  = out_active;
  assign `QVL_DUT2CHX_DELAY in_data_sampled     = in_data;
  assign `QVL_DUT2CHX_DELAY load_sampled        = load;
  assign `QVL_DUT2CHX_DELAY hold_sampled        = hold; 
  assign `QVL_DUT2CHX_DELAY msb_sampled         = msb;
  assign `QVL_DUT2CHX_DELAY out_data_sampled    = out_data;

  qvl_parallel_to_serial_assertions #(
                                     .severity_level(severity_level),
                                     .property_type(property_type),
                                     .msg(msg),
                                     .coverage_level(coverage_level),
                                     .WIDTH(width),
                                     .CLOCK_SYNC_LATENCY(sync_delay),
                                     .OUT_LATENCY(latency),
                .OUT_LATENCY_COUNTER_WIDTH(`qvl_log2(latency + width)),
                                     .COUNTER_WIDTH(`qvl_log2(width)),
                                     .MSB_CONVERT_CHECK(msb_convert_check > 0),
                                     .HOLD_CHECK(hold_check > 0),
                                     .REVERSAL_CHECK(reversal_check > 0),
                                     .CONSEC_LOAD_CHECK(consecutive_load_check > 0)
                                     )
         qvl_parallel_to_serial_chx (
                                     .parallel_clock(in_clk),
                                     .serial_clock(out_clk),
                                     .areset(1'b0),
                                     .parallel_reset(~in_reset_n_sampled),
                                     .serial_reset(~out_reset_n_sampled),
                                     .active(active_sampled),
                                     .parallel_active(in_active_sampled),
                                     .serial_active(out_active_sampled),
                                     .parallel_data(in_data_sampled),
                                     .serial_data(out_data_sampled),
                                     .parallel_load(load_sampled),
                                     .hold(hold_sampled),
                                     .shift_mode(msb_sampled),
                                     .right_shift_check(1'b1),
                                     .left_shift_check(msb_convert_check > 0),
                                     .hold_check(hold_check > 0),
                                     .load_before_conversion_check(1'b1),
  .no_load_after_full_conversion_check(consecutive_load_check > 0),
                      .shift_mode_reversal_check(reversal_check > 0),
                                     .right_shift_fire(right_shift_fire),
                                     .left_shift_fire(left_shift_fire),
                                     .hold_fire(hold_fire),
                            .shift_mode_reversal_fire(shift_mode_reversal_fire),
                      .load_before_conversion_fire(load_before_conversion_fire),
        .no_load_after_full_conversion_fire(no_load_after_full_conversion_fire),
                                  .complete_right_shifts(complete_right_shifts),
                                    .complete_left_shifts(complete_left_shifts),
                                     .total_shifts(total_shifts),
                                     .right_shifts(right_shifts),
                                     .left_shifts(left_shifts),
                                     .load_cycles(load_cycles),
                                     .hold_cycles(hold_cycles),
                                     .support(1'b1),
                                     .fire_count(fire_count)
                                   );
`qvlendmodule
