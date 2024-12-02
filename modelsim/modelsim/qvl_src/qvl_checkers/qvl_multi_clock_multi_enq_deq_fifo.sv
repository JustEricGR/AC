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

`qvlmodule qvl_multi_clock_multi_enq_deq_fifo (enq_clk,
                                               deq_clk,
                                               enq_reset_n,
                                               deq_reset_n,
                                               active,
                                               enq_active,
                                               deq_active,
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
  parameter width = 1; // Widths of data ports.
  parameter depth = 2; // Depth of FIFO.
  parameter enq_count = 1; // Number of enq ports.
  parameter deq_count = 1; // Number of deq ports.
  parameter latency = 0; // Latency for value check.
  parameter preload_count = 0; // Number of items for pre-load.
  parameter high_water = 0; // Indicating FIFO high water mark.
  parameter low_water = 1; // Indicating FIFO low water mark.
  parameter full_check = 0; // Check-off if 0.
  parameter empty_check = 0; // Check-off if 0.
  parameter value_check = 0; // Check-off if 0.

  input enq_clk;
  input deq_clk;
  input enq_reset_n;
  input deq_reset_n;
  input active;
  input enq_active;
  input deq_active;
  input [enq_count-1:0] enq;
  input [deq_count-1:0] deq;
  input full;
  input empty;
  input [(enq_count*width)-1:0] enq_data;
  input [(deq_count*width)-1:0] deq_data;
  input [(preload_count ? preload_count*width : width)-1:0] preload;

  wire enqueue_fire;
  wire dequeue_fire;
  wire value_fire;
  wire full_fire;
  wire empty_fire;

  wire [63:0] enqueues_and_dequeues;
  wire [63:0] enqueues;
  wire [63:0] dequeues;
  wire [63:0] maximum_fifo_entries;
  wire [63:0] current_fifo_entries;
  wire [enq_count-1:0] enqueue_bitmap;
  wire [deq_count-1:0] dequeue_bitmap;
  wire [63:0] full_count;
  wire [63:0] empty_count;
  wire [63:0] high_water_count;
  wire [63:0] low_water_count;

  wire [(deq_count*width)-1:0] expected_deq_data;

  // internal parameter
  parameter internal_high_water = high_water ? high_water :
                                  (depth === 1) ? 1 : depth-1;


  wire                 enq_reset_n_sampled;
  wire                 deq_reset_n_sampled;
  wire                 active_sampled;
  wire                 enq_active_sampled;
  wire                 deq_active_sampled;

  wire [enq_count-1:0] enq_sampled;
  wire [deq_count-1:0] deq_sampled;
  wire                 full_sampled;
  wire                 empty_sampled;

  wire [(enq_count*width)-1:0] enq_data_sampled;
  wire [(deq_count*width)-1:0] deq_data_sampled;

  wire [(preload_count ? preload_count*width : width)-1:0] preload_sampled;

  assign `QVL_DUT2CHX_DELAY enq_reset_n_sampled = enq_reset_n;
  assign `QVL_DUT2CHX_DELAY deq_reset_n_sampled = deq_reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled      = active;
  assign `QVL_DUT2CHX_DELAY enq_active_sampled  = enq_active;
  assign `QVL_DUT2CHX_DELAY deq_active_sampled  = deq_active;
  assign `QVL_DUT2CHX_DELAY enq_sampled         = enq;
  assign `QVL_DUT2CHX_DELAY deq_sampled         = deq;
  assign `QVL_DUT2CHX_DELAY full_sampled        = full;
  assign `QVL_DUT2CHX_DELAY empty_sampled       = empty;
  assign `QVL_DUT2CHX_DELAY enq_data_sampled    = enq_data;
  assign `QVL_DUT2CHX_DELAY deq_data_sampled    = deq_data;
  assign `QVL_DUT2CHX_DELAY preload_sampled     = preload;

  qvl_multi_clock_multi_enq_deq_fifo_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .ENQ_WIDTH (enq_count),
      .ENQ_ITEM_COUNT (enq_count),
      .DEQ_WIDTH (deq_count),
      .DEQ_ITEM_COUNT (deq_count),
      .ENQ_DATA_WIDTH (enq_count*width),
      .ENQ_DATA_ITEM_WIDTH (width),
      .ENQ_DATA_ITEM_COUNT (enq_count),
      .DEQ_DATA_WIDTH (deq_count*width),
      .DEQ_DATA_ITEM_WIDTH (width),
      .DEQ_DATA_ITEM_COUNT (deq_count),
      .ENQ_DATA_SPECIFIED (value_check == 1),
      .DEQ_DATA_SPECIFIED (value_check == 1),
      .DEPTH (depth),
      .HIGH_WATER (internal_high_water),
      .LOW_WATER (low_water),
      .LATENCY (latency),
      .PRELOAD_WIDTH (preload_count ? (preload_count*width) : width),
      .PRELOAD_ITEM_WIDTH (width),
      .PRELOAD_ITEM_COUNT (preload_count ? preload_count : 1),
      .PRELOAD_SPECIFIED (preload_count > 0),
      .ADDR_WIDTH (`qvl_log2(depth)),
      .FULL_CHECK (full_check > 0),
      .EMPTY_CHECK (empty_check > 0),
      .VALUE_CHECK (value_check > 0)
     )
  qvl_multi_clock_multi_enq_deq_fifo_chx
    (.enq_clock(enq_clk),
     .deq_clock(deq_clk),
     .active(active_sampled),
     .enq_active(enq_active_sampled),
     .deq_active(deq_active_sampled),
     .areset(1'b0),
     .enq_reset(~enq_reset_n_sampled),
     .deq_reset(~deq_reset_n_sampled),
     .enq(enq_sampled),
     .deq(deq_sampled),
     .enq_data(enq_data_sampled),
     .deq_data(deq_data_sampled),
     .full(full_sampled),
     .empty(empty_sampled),
     .preload(preload_sampled),
     .enqueue_check(1'b1),
     .dequeue_check(1'b1),
     .value_check(value_check == 1),
     .full_check(full_check == 1),
     .empty_check(empty_check == 1),
     .enqueue_fire(enqueue_fire),
     .dequeue_fire(dequeue_fire),
     .value_fire(value_fire),
     .full_fire(full_fire),
     .empty_fire(empty_fire),
     .enqueues_and_dequeues(enqueues_and_dequeues),
     .enqueues(enqueues),
     .dequeues(dequeues),
     .maximum_fifo_entries(maximum_fifo_entries),
     .current_fifo_entries(current_fifo_entries),
     .enqueue_bitmap(enqueue_bitmap),
     .dequeue_bitmap(dequeue_bitmap),
     .full_count(full_count),
     .empty_count(empty_count),
     .high_water_count(high_water_count),
     .low_water_count(low_water_count),
     .expected_deq_data(expected_deq_data),
     .support(1'b1)
     );

`qvlendmodule
