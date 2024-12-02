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

`qvlmodule qvl_scoreboard (clk,
                           reset_n,
                           active,
                           rx,
                           rx_id,
                           rx_count,
                           tx,
                           tx_id,
                           tx_count,
                           flush,
                           flush_id,
                           flush_count,
                           pre_rx_ids,
                           pre_rx_counts
                          );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 6;
  parameter count_width = 2;
  parameter min = 0;
  parameter max = 0;
  parameter max_ids = 16;
  parameter max_count_per_id = 8;
  parameter flush_enable = 0;
  parameter flush_count_enable = 0;
  parameter pre_rx_ids_count = 0;
  parameter pre_rx_count_width = 1;
  parameter allow_simultaneous_rx_tx = 0;
  parameter allow_simultaneous_flush_rx = 0;
  parameter allow_partial = 0;
  parameter disallow_rx_when_full = 0; 
  parameter known_ids_check = 1;
  parameter known_flush_check = 0;

  // Internal parameters
  parameter max_count_per_id_default = 8;
  parameter max_ids_width_port = (max_ids >0) ? `qvl_infer_width(max_ids): 4;
  parameter max_count_per_id_width_port = (max_count_per_id > 0) ? 
                                        `qvl_infer_width(max_count_per_id) : 4;
  parameter max_count_per_id_width_param = 
                                  `qvl_infer_width(max_count_per_id_default);
  parameter max_ids_is_constant = 1;
  parameter max_count_per_id_item_count = 1;
  parameter flush_id_specified = flush_enable;
  parameter max_count_per_id_width_internal = (max_count_per_id > 0) ?
                 max_count_per_id_width_port : max_count_per_id_width_param +1; 
  parameter pre_rx_count_item_count_internal = (pre_rx_ids_count == 0) 
                               ? 1: pre_rx_ids_count ;
  parameter pre_rx_id_width = (pre_rx_ids_count == 0) ?  width :
                                   width*pre_rx_ids_count;
  parameter pre_rx_id_item_width = (pre_rx_ids_count == 0) ?
                                         1 : width;
  parameter pre_rx_id_item_count_internal =  (pre_rx_ids_count == 0) ?
                                                1: pre_rx_ids_count;

  parameter pre_rx_count_width_internal = (pre_rx_ids_count == 0) ?  1: 
                           pre_rx_ids_count*pre_rx_count_width;
  input clk; 
  input reset_n;
  input active;

  input rx;
  input [width-1: 0] rx_id;
  input [count_width-1:0] rx_count;
  input tx;
  input [width-1:0] tx_id;
  input [count_width-1:0] tx_count;
  input flush;
  input [width-1:0] flush_id;
  input [count_width-1:0] flush_count;
  input [pre_rx_id_width-1:0] pre_rx_ids;
  input [pre_rx_count_width_internal-1:0] pre_rx_counts;

  wire [max_ids_width_port-1: 0] max_ids_wire;
  wire [max_count_per_id_width_internal-1:0] max_count_per_id_wire;

  wire known_ids_fire;
  wire known_flush_fire;
  wire max_ids_fire;
  wire max_count_per_id_fire;
  wire min_fire;
  wire max_fire;

  wire [63:0] fire_count;

  wire [63:0] ids_received_and_transmitted;
  wire [63:0] ids_received;
  wire [63:0] ids_transmitted;
  wire [63:0] ids_flushed;
  wire [63:0] unique_ids_received;
  wire [15:0] unique_ids_bit_map;
  wire [63:0] maximum_count_per_any_id;
  wire [63:0] maximum_count_pending;
  wire [63:0] current_count_pending;
  wire [63:0] min_pending_cycles;
  wire [63:0] max_pending_cycles;
  wire [63:0] pending_ids_equals_max_ids_count;
  wire [63:0] pending_count_per_id_equals_max_count_per_id;
  wire [63:0] min_pending_cycles_equals_min;
  wire [63:0] max_pending_cycles_equals_max;
  wire [max_ids_width_port-1:0] rx_id_addr;
  wire [max_ids_width_port-1:0] tx_id_addr;
  wire [max_ids_width_port-1:0] flush_id_addr;

  assign max_ids_wire = max_ids;
  assign max_count_per_id_wire = max_count_per_id;

  wire                   reset_n_sampled;
  wire                   active_sampled;
  wire                   rx_sampled;
  wire [width-1: 0]      rx_id_sampled;
  wire [count_width-1:0] rx_count_sampled;
  wire                   tx_sampled;
  wire [width-1: 0]      tx_id_sampled;
  wire [count_width-1:0] tx_count_sampled;
  wire                   flush_sampled;
  wire [width-1:0]       flush_id_sampled;
  wire [count_width-1:0] flush_count_sampled;
  wire [pre_rx_id_width-1:0] pre_rx_ids_sampled;
  wire [pre_rx_count_width_internal-1:0] pre_rx_counts_sampled;
 
  assign `QVL_DUT2CHX_DELAY  reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled = active; 
  assign `QVL_DUT2CHX_DELAY  rx_sampled = rx; 
  assign `QVL_DUT2CHX_DELAY  rx_id_sampled = rx_id; 
  assign `QVL_DUT2CHX_DELAY  rx_count_sampled = rx_count; 
  assign `QVL_DUT2CHX_DELAY  tx_sampled = tx; 
  assign `QVL_DUT2CHX_DELAY  tx_id_sampled = tx_id; 
  assign `QVL_DUT2CHX_DELAY  tx_count_sampled = tx_count;
  assign `QVL_DUT2CHX_DELAY  flush_sampled = flush; 
  assign `QVL_DUT2CHX_DELAY  flush_id_sampled = flush_id; 
  assign `QVL_DUT2CHX_DELAY  flush_count_sampled = flush_count; 
  assign `QVL_DUT2CHX_DELAY  pre_rx_ids_sampled = pre_rx_ids;
  assign `QVL_DUT2CHX_DELAY  pre_rx_counts_sampled = pre_rx_counts;


  qvl_scoreboard_assertions
    #(.severity_level(severity_level), 
      .property_type(property_type), 
      .msg(msg), 
      .coverage_level(coverage_level),
      .DISALLOW_RX_WHEN_FULL(disallow_rx_when_full),
      .ALLOW_SIMULTANEOUS_RX_TX(allow_simultaneous_rx_tx),
      .ALLOW_SIMULTANEOUS_FLUSH_RX(allow_simultaneous_flush_rx),
      .ALLOW_PARTIAL(allow_partial),
      .MIN(min == 0 ? 1: min),
      .MAX(max == 0 ? 1: max),
      .MAX_SPECIFIED(max > 0),
      .RX_ID_WIDTH(width),
      .TX_ID_WIDTH(width),
      .FLUSH_SPECIFIED(flush_enable),
      .FLUSH_ID_SPECIFIED(flush_id_specified),
      .FLUSH_COUNT_SPECIFIED(flush_count_enable),
      .FLUSH_ID_WIDTH(width),
      .MAX_IDS_WIDTH_PORT(max_ids_width_port),
      .MAX_IDS_SPECIFIED(max_ids > 0),
      .MAX_IDS_IS_CONSTANT(max_ids_is_constant),
      .MAX_IDS_CONST_VAL(max_ids > 0 ? max_ids: 16),
      .MAX_COUNT_PER_ID_WIDTH_PORT(max_count_per_id_width_port),
      .MAX_COUNT_PER_ID_ITEM_COUNT(max_count_per_id_item_count),
      .MAX_COUNT_PER_ID_WIDTH_PARAM(max_count_per_id_width_param),
      .MAX_COUNT_PER_ID_SPECIFIED(max_count_per_id > 0),
      .MIN_SPECIFIED(min > 0),
      .RX_COUNT_WIDTH(count_width),
      .TX_COUNT_WIDTH(count_width),
      .FLUSH_COUNT_WIDTH(count_width),
      .PRE_RX_ID_WIDTH(pre_rx_id_width),
      .PRE_RX_ID_SPECIFIED(pre_rx_ids_count > 0),
      .PRE_RX_ID_ITEM_WIDTH(pre_rx_id_item_width),
      .PRE_RX_ID_ITEM_COUNT(pre_rx_id_item_count_internal),
      .PRE_RX_COUNT_WIDTH(pre_rx_count_width_internal),
      .PRE_RX_COUNT_ITEM_WIDTH(pre_rx_count_width),
      .PRE_RX_COUNT_ITEM_COUNT(pre_rx_count_item_count_internal),
      .PRE_RX_COUNT_SPECIFIED(pre_rx_ids_count > 0),
      .ALLOW_SIMULTANEOUS_RX_TX_SPECIFIED(allow_simultaneous_rx_tx === 1),
      .ALLOW_SIMULTANEOUS_FLUSH_RX_SPECIFIED(allow_simultaneous_flush_rx === 1),
      .ALLOW_PARTIAL_SPECIFIED(allow_partial === 1),
      .MIN_WIDTH(`qvl_infer_width(min)),
      .MAX_WIDTH(`qvl_infer_width(max)),
      .KNOWN_IDS_CHECK(known_ids_check === 1),
      .KNOWN_FLUSH_CHECK(known_flush_check === 1)
     )
   qvl_scoreboard_chx (
         .clock                            (clk),
         .reset                            (~reset_n_sampled),
         .areset                           (1'b0),
         .active                           (active_sampled),
         .rx                               (rx_sampled),
         .rx_id                            (rx_id_sampled),
         .rx_count                         (rx_count_sampled),
         .tx                               (tx_sampled),
         .tx_id                            (tx_id_sampled),
         .tx_count                         (tx_count_sampled),
         .flush                            (flush_sampled),
         .flush_id                         (flush_id_sampled),
         .flush_count                      (flush_count_sampled),
         .max_ids                          (max_ids_wire),
         .max_count_per_id                 (max_count_per_id_wire),
         .pre_rx_id                        (pre_rx_ids_sampled),
         .pre_rx_count                     (pre_rx_counts_sampled),
         .known_ids                        (known_ids_check > 0),
         .known_flush                      (known_flush_check > 0),
         .max_ids_check                    (max_ids > 0),
         .max_count_per_id_check           (max_count_per_id > 0),
         .min_check                        (min > 0),
         .max_check                        (max > 0),
         .known_ids_fire                   (known_ids_fire),
         .known_flush_fire                 (known_flush_fire),
         .max_ids_fire                     (max_ids_fire),
         .max_count_per_id_fire            (max_count_per_id_fire),
         .min_fire                         (min_fire),
         .max_fire                         (max_fire),
         .ids_received_and_transmitted     (ids_received_and_transmitted),
         .ids_received                     (ids_received),
         .ids_transmitted                  (ids_transmitted),
         .ids_flushed                      (ids_flushed),
         .unique_ids_received              (unique_ids_received),
         .unique_ids_bit_map               (unique_ids_bit_map),
         .maximum_count_per_any_id         (maximum_count_per_any_id),
         .maximum_count_pending            (maximum_count_pending),
         .current_count_pending            (current_count_pending),
         .min_pending_cycles               (min_pending_cycles),
         .max_pending_cycles               (max_pending_cycles),
         .pending_ids_equals_max_ids_count (pending_ids_equals_max_ids_count),
         .pending_count_per_id_equals_max_count_per_id
                               (pending_count_per_id_equals_max_count_per_id),
         .min_pending_cycles_equals_min    (min_pending_cycles_equals_min),
         .max_pending_cycles_equals_max    (max_pending_cycles_equals_max),
         .rx_id_addr                       (rx_id_addr),
         .tx_id_addr                       (tx_id_addr),
         .flush_id_addr                    (flush_id_addr),
         .support                          (1'b1)
         );

`qvlendmodule
