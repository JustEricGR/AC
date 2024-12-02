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

`qvlmodule qvl_stack(
                     clk,
                     reset_n,
                     active,
                     push,
                     pop,
                     full,
                     empty,
                     push_data,
                     pop_data,
                     preload
                    );


  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;

  parameter width = 32; 
  parameter depth = 1;
  parameter high_water = 0;
  parameter latency = 0;
  parameter preload_count = 0;
  parameter full_check = 0;
  parameter empty_check = 0;
  parameter value_check = 0;

  parameter internal_high_water = (high_water>1)?high_water:((depth>1)?(depth-1):1);

  input                  clk;
  input                  reset_n;
  input                  active;
  input                  push;
  input                  pop;
  input                  full;
  input                  empty;
  input [width-1:0] push_data;
  input [width-1:0] pop_data;
  input [((preload_count>0)?((preload_count*width)-1):width-1):0] preload;

  wire pop_fire;
  wire push_fire;
  wire push_pop_fire;
  wire full_fire;
  wire empty_fire;
  wire value_fire;
  wire [width-1:0] expected_pop_data;
  wire [63:0] pushes_and_pops;
  wire [63:0] push_count;
  wire [63:0] pop_count;
  wire [63:0] max_stack_entries;
  wire [63:0] current_stack_entries;
  wire [63:0] full_count;
  wire [63:0] empty_count;
  wire [63:0] high_water_count;


  wire                  reset_n_sampled;
  wire                  active_sampled;
  wire                  push_sampled;
  wire                  pop_sampled;
  wire                  full_sampled;
  wire                  empty_sampled;
  wire [width-1:0] push_data_sampled;
  wire [width-1:0] pop_data_sampled;
  wire [((preload_count>0)?((preload_count*width)-1):width-1):0] preload_sampled;


  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active;
  assign `QVL_DUT2CHX_DELAY push_sampled   = push;
  assign `QVL_DUT2CHX_DELAY pop_sampled   = pop;
  assign `QVL_DUT2CHX_DELAY full_sampled   = full;
  assign `QVL_DUT2CHX_DELAY empty_sampled   = empty;
  assign `QVL_DUT2CHX_DELAY push_data_sampled   = push_data;
  assign `QVL_DUT2CHX_DELAY pop_data_sampled   = pop_data;
  assign `QVL_DUT2CHX_DELAY preload_sampled   = preload;


  qvl_stack_assertions #(
                         .severity_level     (severity_level),
                         .property_type      (property_type),
                         .msg                (msg),
                         .coverage_level     (coverage_level),
                         .WIDTH              (width),
                         .DEPTH              (depth),
                         .HIGH_WATER         (internal_high_water),
                         .POP_WIDTH          (width),
                         .VALUE_SPECIFIED    (value_check>0),
                         .LATENCY            (latency),
                         .PRELOAD_SPECIFIED  (preload_count>0),
                         .PRELOAD_WIDTH      ((preload_count>0)?(preload_count*width):width),
                         .PRELOAD_ITEM_WIDTH (width),
                         .PRELOAD_ITEM_COUNT (preload_count),
                         .ADDRESS_WIDTH      (`qvl_log2(depth)),
                         .FULL_CHECK         (full_check > 0),
                         .EMPTY_CHECK        (empty_check > 0),
                         .VALUE_CHECK        (value_check > 0)
                        ) 
           qvl_stack_chx(
                         .clock                 (clk),
                         .active                (active_sampled),
                         .reset                 (~reset_n_sampled),
                         .areset                (1'b0),
                         .push                  (push_sampled),
                         .pop                   (pop_sampled),
                         .full                  (full_sampled),
                         .empty                 (empty_sampled),
                         .push_data             (push_data_sampled),
                         .pop_data              (pop_data_sampled),
                         .preload               (preload_sampled),
                         .pop_check             (1'b1),
                         .push_check            (1'b1),
                         .push_pop_check        (1'b1),
                         .full_check            (full_check>0),
                         .empty_check           (empty_check>0),
                         .value_check           (value_check>0),
                         .expected_pop_data     (expected_pop_data),
                         .push_fire             (push_fire),
                         .pop_fire              (pop_fire),
                         .push_pop_fire         (push_pop_fire),
                         .full_fire             (full_fire),
                         .empty_fire            (empty_fire),
                         .value_fire            (value_fire),
                         .pushes_and_pops       (pushes_and_pops),
                         .push_count            (push_count),
                         .pop_count             (pop_count),
                         .max_stack_entries     (max_stack_entries),
                         .current_stack_entries (current_stack_entries),
                         .full_count            (full_count),
                         .empty_count           (empty_count),
                         .high_water_count      (high_water_count),
			 .support               (1'b1)
                        );

`qvlendmodule //qvl_stack
