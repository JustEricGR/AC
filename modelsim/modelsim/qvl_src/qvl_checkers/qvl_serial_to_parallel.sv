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

`qvlmodule qvl_serial_to_parallel (
                                   out_clk,
                                   in_clk,
                                   in_reset_n,
                                   out_reset_n,
                                   active,
                                   in_active,
                                   out_active, 
                                   load,
                                   read,
                                   msb,
                                   in_data,
                                   out_data
                                 );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 2;
  parameter latency = 0;
  parameter sync_delay = 0;
  parameter msb_convert_check = 0;
  parameter reversal_check = 0;
  parameter read_check = 0;

  input out_clk; 
  input in_clk; 
  input out_reset_n;
  input in_reset_n;
  input active;
  input out_active;
  input in_active;
  input in_data;
  input load;
  input msb;
  input [width-1:0] out_data; 
  input read;

  wire right_shift_fire;
  wire left_shift_fire;
  wire register_leak_fire;
  wire shift_mode_reversal_fire;
  wire [63:0] complete_right_shifts;
  wire [63:0] complete_left_shifts;
  wire [63:0] total_shifts;
  wire [63:0] right_shifts;
  wire [63:0] left_shifts;
  wire [63:0] hold_cycles;
  wire [63:0] parallel_data_reads;

  wire out_reset_n_sampled;
  wire in_reset_n_sampled;
  wire active_sampled;
  wire out_active_sampled;
  wire in_active_sampled;
  wire in_data_sampled;
  wire load_sampled;
  wire msb_sampled;
  wire [width-1:0] out_data_sampled; 
  wire read_sampled;

  assign `QVL_DUT2CHX_DELAY  out_reset_n_sampled = out_reset_n;
  assign `QVL_DUT2CHX_DELAY  in_reset_n_sampled  = in_reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled      = active;
  assign `QVL_DUT2CHX_DELAY  out_active_sampled  = out_active;
  assign `QVL_DUT2CHX_DELAY  in_active_sampled   = in_active;
  assign `QVL_DUT2CHX_DELAY  in_data_sampled     = in_data;
  assign `QVL_DUT2CHX_DELAY  load_sampled        = load;
  assign `QVL_DUT2CHX_DELAY  msb_sampled         = msb;
  assign `QVL_DUT2CHX_DELAY  out_data_sampled    = out_data; 
  assign `QVL_DUT2CHX_DELAY  read_sampled        = read;

  qvl_serial_to_parallel_assertions #(
                                     .severity_level(severity_level),
                                     .property_type(property_type),
                                     .msg(msg),
                                     .coverage_level(coverage_level),
                                     .WIDTH(width),
                                     .CLOCK_SYNC_LATENCY(sync_delay),
                                     .OUT_LATENCY(latency),
                                     .READ_SPECIFIED(1),
                                     .COUNTER_WIDTH(`qvl_log2(width)),
           .CLK_SYNC_LAT_COUNTER_WIDTH(`qvl_log2(width+sync_delay)),
                                     .MSB_CONVERT_CHECK(msb_convert_check > 0),
                                     .REVERSAL_CHECK(reversal_check > 0),
                                     .READ_CHECK(read_check > 0)
                                     )
          qvl_serial_to_parallel_chx (
                                     .parallel_clock(out_clk),
                                     .serial_clock(in_clk),
                                     .areset(1'b0),
                                     .parallel_reset(~out_reset_n_sampled),
                                     .serial_reset(~in_reset_n_sampled),
                                     .active(active_sampled),
                                     .parallel_active(out_active_sampled),
                                     .serial_active(in_active_sampled),
                                     .serial_data(in_data_sampled),
                                     .parallel_data(out_data_sampled),
                                     .serial_data_enable(load_sampled),
                                     .shift_mode(msb_sampled),
                                     .parallel_read(read_sampled),
                                     .right_shift_check(1'b1),
                                     .left_shift_check(msb_convert_check > 0),
                                     .register_leak_check(read_check > 0),
                                     .shift_mode_reversal_check(reversal_check > 0),
                                     .right_shift_fire(right_shift_fire),
                                     .left_shift_fire(left_shift_fire),
                                     .register_leak_fire(register_leak_fire),
                            .shift_mode_reversal_fire(shift_mode_reversal_fire),
                                  .complete_right_shifts(complete_right_shifts),
                                    .complete_left_shifts(complete_left_shifts),
                                     .total_shifts(total_shifts),
                                     .right_shifts(right_shifts),
                                     .left_shifts(left_shifts),
                                     .hold_cycles(hold_cycles),
                                     .parallel_data_reads(parallel_data_reads),
                                     .support(1'b1)
                                   );
`qvlendmodule
