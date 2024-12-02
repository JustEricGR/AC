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

`qvlmodule qvl_bus_id (clk,
                       reset_n,
                       active,
                       req,
                       req_id,
                       ret,
                       ret_id
                      );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;
  parameter max_ids = 16;
  parameter allow_simultaneous_req_ret = 0;
  parameter disallow_req_when_full = 0;
  parameter unique_ids_check = 1;
  parameter known_ids_check = 1;

  // Internal parameters
  parameter max_ids_width_port = (max_ids >0) ? `qvl_infer_width(max_ids): 5;
  parameter req_id_is_constant = 0;
  parameter max_ids_is_constant = 1;

  input clk; 
  input reset_n;
  input active;

  input req;
  input [width-1: 0] req_id;
  input ret;
  input [width-1:0] ret_id;

  wire [max_ids_width_port-1: 0] max_ids_wire;

  wire unique_ids_fire;
  wire known_ids_fire;
  wire max_ids_fire;

  wire [63:0] ids_requested_and_returned;
  wire [63:0] ids_requested;
  wire [63:0] ids_returned;
  wire [63:0] unique_ids_issued;
  wire [63:0] maximum_ids_outstanding;
  wire [63:0] maximum_ids_are_out_count;
  wire [63:0] current_ids_outstanding;

  wire [63:0] fire_count;

  assign max_ids_wire = max_ids;

  wire reset_n_sampled;
  wire active_sampled;
  wire req_sampled;
  wire [width-1: 0] req_id_sampled;
  wire ret_sampled; 
  wire [width-1: 0] ret_id_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY req_sampled   = req;
  assign `QVL_DUT2CHX_DELAY req_id_sampled    = req_id;
  assign `QVL_DUT2CHX_DELAY ret_sampled = ret; 
  assign `QVL_DUT2CHX_DELAY ret_id_sampled = ret_id;


  qvl_bus_id_assertions #(
      .severity_level              (severity_level), 
      .property_type               (property_type), 
      .msg                         (msg), 
      .coverage_level              (coverage_level),
      .REQ_ID_WIDTH                (width),
      .RET_ID_WIDTH                (width),
      .REQ_ID_IS_CONSTANT          (req_id_is_constant),
      .MAX_IDS_WIDTH_PORT          (max_ids_width_port),
      .MAX_IDS_SPECIFIED           (max_ids > 0),
      .MAX_IDS_IS_CONSTANT         (max_ids_is_constant),
      .MAX_IDS_CONST_VAL           (max_ids > 0 ? max_ids: 16),
      .DISALLOW_REQ_WHEN_FULL      (disallow_req_when_full),
      .ALLOW_SIMULTANEOUS_REQ_RET  (allow_simultaneous_req_ret),
      .KNOWN_IDS_CHECK             (known_ids_check > 0),
      .UNIQUE_IDS_CHECK            (unique_ids_check > 0)			  
     )
    qvl_bus_id_chx (
         .clock                       (clk),
         .reset                       (~reset_n_sampled),
         .areset                      (1'b0),
         .active                      (active_sampled),
         .req                         (req_sampled),
         .req_id                      (req_id_sampled),
         .ret                         (ret_sampled),
         .ret_id                      (ret_id_sampled),
         .max_ids                     (max_ids_wire),
         .unique_ids                  (unique_ids_check > 0),
         .known_ids                   (known_ids_check > 0),
         .max_ids_check               (max_ids > 0),
         .unique_ids_fire             (unique_ids_fire),
         .known_ids_fire              (known_ids_fire),
         .max_ids_fire                (max_ids_fire),
         .ids_requested_and_returned  (ids_requested_and_returned),
         .ids_requested               (ids_requested),
         .ids_returned                (ids_returned),
         .unique_ids_issued           (unique_ids_issued),
         .maximum_ids_outstanding     (maximum_ids_outstanding),
         .maximum_ids_are_out_count   (maximum_ids_are_out_count),
         .current_ids_outstanding     (current_ids_outstanding),
         .support                     (1'b1),
         .fire_count                  (fire_count)
        );

`qvlendmodule
