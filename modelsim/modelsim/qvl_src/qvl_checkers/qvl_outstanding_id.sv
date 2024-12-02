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

`qvlmodule qvl_outstanding_id (clk,
                               reset_n,
                               active,
                               req,
                               req_id,
                               req_count,
                               ret,
                               ret_id,
                               ret_count,
                               flush,
                               flush_id,
                               flush_count,
                               pre_req_ids,
                               pre_req_counts
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
  parameter pre_req_ids_count = 0;
  parameter pre_req_count_width = 1;
  parameter allow_simultaneous_req_ret = 0;
  parameter allow_simultaneous_flush_req = 0;
  parameter allow_partial = 0;
  parameter disallow_req_when_full = 0;
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
  parameter pre_req_count_item_count_internal = (pre_req_ids_count == 0) 
                               ? 1: pre_req_ids_count ;
  parameter pre_req_id_width = (pre_req_ids_count == 0) ?  width :
                                   width*pre_req_ids_count;
  parameter pre_req_id_item_width = (pre_req_ids_count == 0) ?
                                         1 : width;
  parameter pre_req_ids_count_internal =  (pre_req_ids_count == 0) ?
                                                1: pre_req_ids_count;

  parameter pre_req_count_width_internal = (pre_req_ids_count == 0) ?  1: 
                           pre_req_ids_count*pre_req_count_width;

  
  parameter REQ_ID_DEPTH = 2 << (width - 1);
  parameter MAX_REQ_ID_WIDTH = 19;
  parameter MAX_REQ_ID_DEPTH = 2 << (MAX_REQ_ID_WIDTH - 1);
  parameter ALLOW_BITMAP_STATS = (width > MAX_REQ_ID_WIDTH ? 0 : 1);
  parameter STATS_ID_MEM_DEPTH = (ALLOW_BITMAP_STATS ? REQ_ID_DEPTH : MAX_REQ_ID_DEPTH);

  input clk; 
  input reset_n;
  input active;

  input req;
  input [width-1: 0] req_id;
  input [count_width-1:0] req_count;
  input ret;
  input [width-1:0] ret_id;
  input [count_width-1:0] ret_count;
  input flush;
  input [width-1:0] flush_id;
  input [count_width-1:0] flush_count;
  input [pre_req_id_width-1:0] pre_req_ids;
  input [pre_req_count_width_internal-1:0] pre_req_counts;

  wire [max_ids_width_port-1: 0] max_ids_wire;
  wire [max_count_per_id_width_internal-1:0] max_count_per_id_wire;

  wire known_ids_fire;
  wire known_flush_fire;
  wire max_ids_fire;
  wire max_count_per_id_fire;
  wire min_fire;
  wire max_fire;

  wire [63:0] fire_count;

  wire [63:0] ids_requested_and_returned;
  wire [63:0] ids_requested;
  wire [63:0] ids_returned;
  wire [63:0] ids_flushed;
  wire [63:0] unique_ids_issued;
  wire [STATS_ID_MEM_DEPTH - 1:0] unique_ids_bit_map;
  wire [63:0] maximum_count_per_any_id;
  wire [63:0] maximum_count_outstanding;
  wire [63:0] current_count_outstanding;
  wire [63:0] min_outstanding_cycles;
  wire [63:0] max_outstanding_cycles;
  wire [63:0] outstanding_ids_equals_max_ids_count;
  wire [63:0] outstanding_count_per_id_equals_max_count_per_id;
  wire [63:0] min_outstanding_cycles_equals_min;
  wire [63:0] max_outstanding_cycles_equals_max;
  wire [max_ids_width_port-1:0] req_id_addr;
  wire [max_ids_width_port-1:0] ret_id_addr;
  wire [max_ids_width_port-1:0] flush_id_addr;

  assign max_ids_wire = max_ids;
  assign max_count_per_id_wire = max_count_per_id;


  wire reset_n_sampled;
  wire active_sampled;

  wire req_sampled;
  wire [width-1: 0] req_id_sampled;
  wire [count_width-1:0] req_count_sampled;
  wire ret_sampled;
  wire [width-1:0] ret_id_sampled;
  wire [count_width-1:0] ret_count_sampled;
  wire flush_sampled;
  wire [width-1:0] flush_id_sampled;
  wire [count_width-1:0] flush_count_sampled;
  wire [pre_req_id_width-1:0] pre_req_ids_sampled;
  wire [pre_req_count_width_internal-1:0] pre_req_counts_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active;
  assign `QVL_DUT2CHX_DELAY req_sampled = req;
  assign `QVL_DUT2CHX_DELAY req_id_sampled = req_id;
  assign `QVL_DUT2CHX_DELAY req_count_sampled = req_count;
  assign `QVL_DUT2CHX_DELAY ret_sampled = ret;
  assign `QVL_DUT2CHX_DELAY ret_id_sampled = ret_id;
  assign `QVL_DUT2CHX_DELAY ret_count_sampled = ret_count;
  assign `QVL_DUT2CHX_DELAY flush_sampled = flush;
  assign `QVL_DUT2CHX_DELAY flush_id_sampled = flush_id;
  assign `QVL_DUT2CHX_DELAY flush_count_sampled = flush_count;
  assign `QVL_DUT2CHX_DELAY pre_req_ids_sampled = pre_req_ids;
  assign `QVL_DUT2CHX_DELAY pre_req_counts_sampled = pre_req_counts;

  qvl_outstanding_id_assertions
    #(.severity_level (severity_level), 
      .property_type (property_type), 
      .msg (msg), 
      .coverage_level (coverage_level),
      .DISALLOW_REQ_WHEN_FULL(disallow_req_when_full),
      .ALLOW_SIMULTANEOUS_REQ_RET(allow_simultaneous_req_ret),
      .ALLOW_SIMULTANEOUS_FLUSH_REQ(allow_simultaneous_flush_req),
      .ALLOW_PARTIAL(allow_partial),
      .MIN(min == 0 ? 1: min),
      .MAX(max == 0 ? 1: max),
      .MAX_SPECIFIED(max > 0),
      .REQ_ID_WIDTH(width),
      .RET_ID_WIDTH(width),
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
      .REQ_COUNT_WIDTH(count_width),
      .RET_COUNT_WIDTH(count_width),
      .FLUSH_COUNT_WIDTH(count_width),
      .PRE_REQ_ID_WIDTH(pre_req_id_width),
      .PRE_REQ_ID_SPECIFIED(pre_req_ids_count > 0),
      .PRE_REQ_ID_ITEM_WIDTH(pre_req_id_item_width),
      .PRE_REQ_ID_ITEM_COUNT(pre_req_ids_count_internal),
      .PRE_REQ_COUNT_WIDTH(pre_req_count_width_internal),
      .PRE_REQ_COUNT_ITEM_WIDTH(pre_req_count_width),
      .PRE_REQ_COUNT_ITEM_COUNT(pre_req_count_item_count_internal),
      .PRE_REQ_COUNT_SPECIFIED(pre_req_ids_count > 0),
      .ALLOW_SIMULTANEOUS_REQ_RET_SPECIFIED(allow_simultaneous_req_ret === 1),
      .ALLOW_SIMULTANEOUS_FLUSH_REQ_SPECIFIED(
                                           allow_simultaneous_flush_req === 1),
      .ALLOW_PARTIAL_SPECIFIED(allow_partial === 1),
      .MIN_WIDTH(`qvl_infer_width(min)),
      .MAX_WIDTH(`qvl_infer_width(max)),
      .KNOWN_IDS_CHECK(known_ids_check > 0),
      .KNOWN_FLUSH_CHECK(known_flush_check > 0)
     )
    qvl_outstanding_id_chx (
         .clock                     (clk),
         .reset                     (~reset_n_sampled),
         .areset                    (1'b0),
         .active                    (active_sampled),
         .req                       (req_sampled),
         .req_id                    (req_id_sampled),
         .req_count                 (req_count_sampled),
         .ret                       (ret_sampled),
         .ret_id                    (ret_id_sampled),
         .ret_count                 (ret_count_sampled),
         .flush                     (flush_sampled),
         .flush_id                  (flush_id_sampled),
         .flush_count               (flush_count_sampled),
         .max_ids                   (max_ids_wire),
         .max_count_per_id          (max_count_per_id_wire),
         .pre_req_id                (pre_req_ids_sampled),
         .pre_req_count             (pre_req_counts_sampled),
         .known_ids                 (known_ids_check > 0),
         .known_flush               (known_flush_check > 0),
         .max_ids_check             (max_ids > 0),
         .max_count_per_id_check    (max_count_per_id > 0),
         .min_check                 (min > 0),
         .max_check                 (max > 0),
         .known_ids_fire            (known_ids_fire),
         .known_flush_fire          (known_flush_fire),
         .max_ids_fire              (max_ids_fire),
         .max_count_per_id_fire     (max_count_per_id_fire),
         .min_fire                  (min_fire),
         .max_fire                  (max_fire),
         .ids_requested_and_returned(ids_requested_and_returned),
         .ids_requested             (ids_requested),
         .ids_returned              (ids_returned),
         .ids_flushed               (ids_flushed),
         .unique_ids_issued         (unique_ids_issued),
         .unique_ids_bit_map        (unique_ids_bit_map),
         .maximum_count_per_any_id  (maximum_count_per_any_id),
         .maximum_count_outstanding (maximum_count_outstanding),
         .current_count_outstanding (current_count_outstanding),
         .min_outstanding_cycles    (min_outstanding_cycles),
         .max_outstanding_cycles    (max_outstanding_cycles),
         .outstanding_ids_equals_max_ids_count 
                                    (outstanding_ids_equals_max_ids_count),
         .outstanding_count_per_id_equals_max_count_per_id
               (outstanding_count_per_id_equals_max_count_per_id),
         .min_outstanding_cycles_equals_min
                                    (min_outstanding_cycles_equals_min),
         .max_outstanding_cycles_equals_max
                                    (max_outstanding_cycles_equals_max),
         .req_id_addr               (req_id_addr),
         .ret_id_addr               (ret_id_addr),
         .flush_id_addr             (flush_id_addr),
         .support                   (1'b1),
         .fire_count                (fire_count)
         );

`qvlendmodule
