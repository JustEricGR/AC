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

`qvlmodule qvl_state_transition (clk,
                                 reset_n,
                                 active,
                                 test_expr,
                                 val,
                                 next_val,
                                 start,
                                 condition
                                 );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter next_count = 1;
  parameter start_enable = 0;
  parameter condition_enable = 0;
  parameter match_by_cycle = 0;
  parameter is_not_check = 0;

  // Internal Parameters //
  parameter stat_cnt_width = `ZI_CW_STAT_CNT_WIDTH;
  parameter bit_cnt_width = 63;
  parameter val_width = width;
  parameter cond_width = next_count;

  input                      clk;
  input                      reset_n;
  input                      active;
  input [width-1:0]          test_expr;
  input [val_width-1:0]      val;    
  input [(next_count*width)-1:0]     next_val;
  input                      start;
  input [cond_width-1:0]     condition;

  wire                       state_transition_fire;
  wire [stat_cnt_width-1:0]  cycles_checked;
  wire [bit_cnt_width:0]     number_of_transitions_covered;
  wire [next_count-1:0]      transitions_covered_bitmap;
  wire [bit_cnt_width:0]     number_of_transitions_uncovered;
  wire                       all_transitions_covered;
  wire                       support;
  wire [63:0]                fire_count;

  wire                       reset_n_sampled;
  wire                       active_sampled;
  wire [width-1:0]           test_expr_sampled;
  wire [val_width-1:0]       val_sampled;    
  wire [(next_count*width)-1:0]     next_val_sampled;
  wire                       start_sampled;
  wire [cond_width-1:0]      condition_sampled;

  assign `QVL_DUT2CHX_DELAY  reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled  = active;
  assign `QVL_DUT2CHX_DELAY  test_expr_sampled = test_expr;
  assign `QVL_DUT2CHX_DELAY  val_sampled = val;
  assign `QVL_DUT2CHX_DELAY  next_val_sampled = next_val;
  assign `QVL_DUT2CHX_DELAY  start_sampled = start;
  assign `QVL_DUT2CHX_DELAY  condition_sampled = condition;	

  qvl_state_transition_assertions    
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .VAR_WIDTH (width),
      .VAL_WIDTH (val_width),
   
      .NEXT_WIDTH (next_count*width),
      .NEXT_ITEM_WIDTH (width),
      .NEXT_ITEM_COUNT (next_count),
      .NEXT_IS_CONST (0),

      .COND_WIDTH (next_count),
      .COND_ITEM_WIDTH_TMP (1),
      .COND_ITEM_COUNT_TMP (next_count),

      .COND_SPECIFIED (condition_enable),
      .COND_ITEM_WIDTH (1),
      .COND_ITEM_COUNT (next_count),
      .BIT_VEC_WLOG2 (`qvl_log2(next_count)),
      .START_SPECIFIED (start_enable),
      .COND_ENABLE (condition_enable > 0),
      .IS_NOT_CHECK (is_not_check > 0)
      )
    qvl_state_transition_chx (
       .clock(clk),
       .areset(1'b0),
       .reset(~reset_n_sampled),
       .active(active_sampled),
       .zivar(test_expr_sampled),
       .val(val_sampled),
       .next(next_val_sampled),
       .start(start_enable? start_sampled : 1'b1),
       .cond(condition_enable? condition_sampled: {next_count{1'b0}}),
       .match_by_cycle((match_by_cycle == 1)),
       .is_not((is_not_check == 1)),
       .state_transition_check(!(is_not_check > 0)),
       .is_not_check(is_not_check > 0),
       .state_transition_fire(state_transition_fire),
       .cycles_checked(cycles_checked),
       .number_of_transitions_covered(number_of_transitions_covered),
       .transitions_covered_bitmap(transitions_covered_bitmap),
       .number_of_transitions_uncovered(number_of_transitions_uncovered),
       .all_transitions_covered(all_transitions_covered),
       .support(1'b0),
       .fire_count(fire_count)
      );

`qvlendmodule
