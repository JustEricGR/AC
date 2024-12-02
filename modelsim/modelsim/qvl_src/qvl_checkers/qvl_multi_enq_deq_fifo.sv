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

`qvlmodule qvl_multi_enq_deq_fifo (
                                   clk,
                                   reset_n,
                                   active,
                                   enq,
                                   deq,
                                   full,  
                                   empty,
                                   enq_data,
                                   deq_data,
                                   preload
                                  );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter depth = 1;
  parameter enq_count = 1;
  parameter deq_count = 1;
  parameter pass = 0;
  parameter registered = 0;
  parameter latency = 0;
  parameter preload_count = 0;
  parameter high_water = 0;
  parameter full_check = 0;
  parameter empty_check = 0;
  parameter value_check = 0;

// internal parameters

  parameter preload_data_width = ((preload_count == 0) ? width:
                                  (preload_count * width));

  parameter internal_high_water = ((high_water != 0) ? high_water :
                                    ((depth === 1) ? 1 : depth-1));

  input clk; 
  input reset_n;
  input active;
  input [enq_count-1:0] enq;
  input [deq_count-1:0] deq;
  input full;
  input empty;
  input [(enq_count*width)-1:0] enq_data;
  input [(deq_count*width)-1:0] deq_data;
  input [preload_data_width-1 : 0] preload;
                                     
  wire enqueue_fire; 
  wire dequeue_fire; 
  wire full_fire; 
  wire empty_fire; 
  wire value_fire; 
  wire [63:0] enqueues; 
  wire [63:0] dequeues; 
  wire [63:0] enqueues_and_dequeues; 
  wire [63:0] maximum_fifo_entries; 
  wire [63:0] current_fifo_entries; 
  wire [enq_count-1:0] enqueue_bitmap; 
  wire [deq_count-1:0] dequeue_bitmap; 
  wire [deq_count*width-1:0] expected_deq_data; 
  wire [enq_count*width-1:0] last_enq_data; 
  wire [63:0] full_count; 
  wire [63:0] empty_count; 
  wire [63:0] high_water_count; 

  wire reset_n_sampled;
  wire active_sampled;
  wire [enq_count-1:0] enq_sampled;
  wire [deq_count-1:0] deq_sampled;
  wire full_sampled;
  wire empty_sampled;
  wire [(enq_count*width)-1:0] enq_data_sampled;
  wire [(deq_count*width)-1:0] deq_data_sampled;
  wire [preload_data_width-1 : 0] preload_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled  = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY enq_sampled      = enq;
  assign `QVL_DUT2CHX_DELAY deq_sampled      = deq;
  assign `QVL_DUT2CHX_DELAY full_sampled     = full;
  assign `QVL_DUT2CHX_DELAY empty_sampled    = empty;
  assign `QVL_DUT2CHX_DELAY enq_data_sampled = enq_data;
  assign `QVL_DUT2CHX_DELAY deq_data_sampled = deq_data;
  assign `QVL_DUT2CHX_DELAY preload_sampled  = preload;

  qvl_multi_enq_deq_fifo_assertions #(
                                      .severity_level(severity_level),
                                      .property_type(property_type),
                                      .msg(msg),
                                      .coverage_level(coverage_level),
                                      .ENQ_WIDTH(enq_count),
                                      .ENQ_ITEM_COUNT(enq_count),
                                      .DEQ_WIDTH(deq_count),
                                      .DEQ_ITEM_COUNT(deq_count),
                                      .ENQ_DATA_WIDTH(enq_count*width),
                                      .ENQ_DATA_ITEM_WIDTH(width),
                                      .DEQ_DATA_WIDTH(deq_count*width),
                                      .DEQ_DATA_ITEM_WIDTH(width),
                                      .DEPTH(depth),
                                      .PRELOAD_WIDTH(preload_data_width),
                                      .PRELOAD_ITEM_WIDTH(width),
                                      .PRELOAD_ITEM_COUNT(preload_count ? preload_count : 1),
                                      .PRELOAD_SPECIFIED(preload_count > 0),
                                      .NUM_ENQ_WIDTH(`qvl_log2(enq_count)),
                                      .NUM_DEQ_WIDTH(`qvl_log2(deq_count)),
                                      .HIGH_WATER(internal_high_water),
                                      .ADDR_WIDTH(`qvl_log2(depth)),
                                      .LATENCY(latency),
                                      .LATENCY_WIDTH(`qvl_log2(latency)),
                                      .REGISTERED(registered > 0),
                                      .PASS(pass > 0),
                                      .FULL_CHECK(full_check > 0),
                                      .EMPTY_CHECK(empty_check > 0),
                                      .VALUE_CHECK(value_check > 0)
                                     )
          qvl_multi_enq_deq_fifo_chx (
                                      .active(active_sampled),
                                      .clock(clk),
                                      .reset(~reset_n_sampled),
                                      .areset(1'b0),
                                      .enq(enq_sampled),
                                      .deq(deq_sampled),
                                      .full(full_sampled),
                                      .empty(empty_sampled),
                                      .enq_data(enq_data_sampled),
                                      .deq_data(deq_data_sampled),
                                      .dequeue(1'b1),
                                      .pass(pass > 0),
                                      .enqueue(1'b1),
                                      .registered(registered > 0),
                                      .value(value_check > 0 ),
                                      .full_check(full_check > 0),
                                      .empty_check(empty_check > 0),
                                      .preload(preload_sampled),
                                      .enqueue_fire(enqueue_fire),
                                      .dequeue_fire(dequeue_fire),
                                      .value_fire(value_fire),
                                      .full_fire(full_fire),
                                      .empty_fire(empty_fire),
                                      .enqueues(enqueues),
                                      .dequeues(dequeues),
                                 .enqueues_and_dequeues(enqueues_and_dequeues),
                                 .maximum_fifo_entries(maximum_fifo_entries),
                                 .current_fifo_entries(current_fifo_entries),
                                      .enqueue_bitmap(enqueue_bitmap),
                                      .dequeue_bitmap(dequeue_bitmap),
                                      .expected_deq_data(expected_deq_data),
                                      .last_enq_data(last_enq_data),
                                      .full_count(full_count),
                                      .empty_count(empty_count),
                                      .high_water_count(high_water_count),
                                      .support(1'b1)
                                     );
`qvlendmodule
