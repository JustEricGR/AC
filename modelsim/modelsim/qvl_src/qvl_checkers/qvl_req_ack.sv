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

`qvlmodule qvl_req_ack(
                       clk,
                       reset_n,
                       active,
                       req,
                       ack,
                       ack_assert_to_req_deassert_min,
                       ack_assert_to_req_deassert_max,
                       req_deassert_to_ack_deassert_min,
                       req_deassert_to_ack_deassert_max,
                       ack_deassert_to_req_deassert_min,
                       ack_deassert_to_req_deassert_max
                      );


  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION: ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter max = 0;
  parameter max_check = 0;
  parameter min = 0;
  parameter no_simultaneous_req_ack = 0;
  parameter new_req_after_ack = 0;
  parameter req_until_ack = 0;
  parameter min_max_port_width = 32;
  parameter ack_assert_to_req_deassert_max_check = 0;
  parameter req_deassert_to_ack_deassert_max_check = 0;
  parameter ack_until_req_deassert = 0;
  parameter ack_deassert_to_req_deassert_max_check = 0;
  parameter max_ack = 0;

  input clk;
  input reset_n;
  input active;
  input req;
  input ack;
  input [min_max_port_width-1:0] ack_assert_to_req_deassert_min;
  input [min_max_port_width-1:0] ack_assert_to_req_deassert_max;
  input [min_max_port_width-1:0] req_deassert_to_ack_deassert_min;
  input [min_max_port_width-1:0] req_deassert_to_ack_deassert_max;
  input [min_max_port_width-1:0] ack_deassert_to_req_deassert_min;
  input [min_max_port_width-1:0] ack_deassert_to_req_deassert_max;

  wire single_req_fire;
  wire single_ack_fire;
  wire req_until_ack_fire; 
  wire max_fire; 
  wire min_fire; 
  wire ack_deassert_to_req_deassert_fire; 
  wire max_ack_fire; 
  wire ack_assert_to_req_deassert_fire;
  wire req_deassert_to_ack_deassert_fire;
  wire ack_until_req_deassert_fire;
  wire [63:0] requests;
  wire [63:0] acknowledgments;
  wire [63:0] requests_and_acknowledgments;
  wire [63:0] fastest_acknowledgment;
  wire [63:0] slowest_acknowledgment;
  wire current_unacknowledged_requests;
  wire [63:0] min_cycles_between_request_count;
  wire [63:0] request_for_max_cycles_count;
  wire [63:0] ack_for_max_cycles_count;
  wire [63:0] min_cycles_between_ack_asrt_to_req_dsrt;
  wire [63:0] max_cycles_between_ack_asrt_to_req_dsrt;
  wire [63:0] min_cycles_between_req_dsrt_to_ack_dsrt;
  wire [63:0] max_cycles_between_req_dsrt_to_ack_dsrt;
  wire [63:0] min_cycles_between_ack_dsrt_to_req_dsrt;
  wire [63:0] max_cycles_between_ack_dsrt_to_req_dsrt;
  wire [63:0] number_of_cycles_req_ack_deasserted_together;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire req_sampled;
  wire ack_sampled;
  wire [min_max_port_width-1:0] ack_assert_to_req_deassert_min_sampled;
  wire [min_max_port_width-1:0] ack_assert_to_req_deassert_max_sampled;
  wire [min_max_port_width-1:0] req_deassert_to_ack_deassert_min_sampled;
  wire [min_max_port_width-1:0] req_deassert_to_ack_deassert_max_sampled;
  wire [min_max_port_width-1:0] ack_deassert_to_req_deassert_min_sampled;
  wire [min_max_port_width-1:0] ack_deassert_to_req_deassert_max_sampled;


  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active;
  assign `QVL_DUT2CHX_DELAY req_sampled = req;
  assign `QVL_DUT2CHX_DELAY ack_sampled = ack;
  assign `QVL_DUT2CHX_DELAY ack_assert_to_req_deassert_min_sampled = ack_assert_to_req_deassert_min;
  assign `QVL_DUT2CHX_DELAY ack_assert_to_req_deassert_max_sampled = ack_assert_to_req_deassert_max;
  assign `QVL_DUT2CHX_DELAY req_deassert_to_ack_deassert_min_sampled = req_deassert_to_ack_deassert_min;
  assign `QVL_DUT2CHX_DELAY req_deassert_to_ack_deassert_max_sampled = req_deassert_to_ack_deassert_max;
  assign `QVL_DUT2CHX_DELAY ack_deassert_to_req_deassert_min_sampled = ack_deassert_to_req_deassert_min;
  assign `QVL_DUT2CHX_DELAY ack_deassert_to_req_deassert_max_sampled = ack_deassert_to_req_deassert_max;

  wire ack_assert_to_req_deassert_check =  ((ack_assert_to_req_deassert_max_check > 0) || 
                                            (ack_assert_to_req_deassert_min_sampled > 0));

  wire req_deassert_to_ack_deassert_check = ((req_deassert_to_ack_deassert_max_check > 0) || 
                                             (req_deassert_to_ack_deassert_min_sampled > 0));

  wire ack_deassert_to_req_deassert_check = ((ack_deassert_to_req_deassert_max_check > 0) || 
                                             (ack_deassert_to_req_deassert_min_sampled > 0));

  qvl_req_ack_assertions #(
                           .severity_level                             (severity_level),
                           .property_type                              (property_type),
                           .msg                                        (msg),
                           .coverage_level                             (coverage_level),
                           .MAX                                        (max),
                           .MIN                                        (min),
                           .MAX_ACK                                    (max_ack),
                           .MAX_ACK_SPECIFIED                          (max_ack > 0),
                           .REQ_UNTIL_ACK_SPECIFIED                    (req_until_ack > 0),
                           .NO_SIMULTANEOUS_REQ_ACK                    (no_simultaneous_req_ack > 0),
                           .NO_SIMULTANEOUS_REQ_ACK_SPECIFIED          (no_simultaneous_req_ack > 0),
                           .NEW_REQ_AFTER_ACK                          (new_req_after_ack > 0),
                           .NEW_REQ_AFTER_ACK_SPECIFIED                (new_req_after_ack > 0),
			   .ACK_UNTIL_REQ_DEASSERT_SPECIFIED           (ack_until_req_deassert > 0),

                           .ACK_ASSERT_TO_REQ_DEASSERT_MIN_SPECIFIED   (1'b1),
                           .ACK_ASSERT_TO_REQ_DEASSERT_MAX_SPECIFIED   (ack_assert_to_req_deassert_max_check > 0),
			   .REQ_DEASSERT_TO_ACK_DEASSERT_MIN_SPECIFIED (1'b1),
	                   .REQ_DEASSERT_TO_ACK_DEASSERT_MAX_SPECIFIED (req_deassert_to_ack_deassert_max_check > 0),
                           .ACK_DEASSERT_TO_REQ_DEASSERT_MIN_SPECIFIED (1'b1),
                           .ACK_DEASSERT_TO_REQ_DEASSERT_MAX_SPECIFIED (ack_deassert_to_req_deassert_max_check > 0),

                           .SINGLE_REQ_ON                              (1'b1),
                           .SINGLE_ACK_ON                              (1'b1),
                           .REQ_UNTIL_ACK_ON                           (1'b1),
			   .MAX_CHECK_ON                               ((max_check > 0) || (max > 0)),
			   .MIN_CHECK_ON                               (min > 0),
	                   .MAX_ACK_CHECK_ON                           (max_ack > 0),
                           .ACK_UNTIL_REQ_D_ON                         (1'b1),

	                   .ACK_D_TO_REQ_D_ON                          (1'b1),
                           .ACK_A_TO_REQ_D_CHECK_ON                    (1'b1),
                           .REQ_D_TO_ACK_D_CHECK_ON                    (1'b1),

                           .ACK_TO_REQ_CNT_WIDTH_MIN                   (min_max_port_width),
                           .ACK_TO_REQ_CNT_WIDTH_MAX                   (min_max_port_width),
                           .REQ_TO_ACK_DEASSERT_CNT_WIDTH_MIN          (min_max_port_width),
                           .REQ_TO_ACK_DEASSERT_CNT_WIDTH_MAX          (min_max_port_width),
                           .ACK_DEASSERT_TO_REQ_DEASSERT_CNT_WIDTH_MIN (min_max_port_width),
                           .ACK_DEASSERT_TO_REQ_DEASSERT_CNT_WIDTH_MAX (min_max_port_width)
                          ) 
  qvl_req_ack_assertions_chx(
                           .clock                                        (clk),
                           .reset                                        (~reset_n_sampled),
                           .active                                       (active_sampled),
                           .req                                          (req_sampled),
                           .ack                                          (ack_sampled),

                           .areset                                       (1'b0),
                           .single_req                                   (1'b1),
                           .single_ack                                   (1'b1),

                           .max_check                                    ((max_check > 0) || (max > 0)),
                           .min_check                                    (min > 0),
                           .req_until_ack                                (req_until_ack > 0),
                           .ack_assert_to_req_deassert_check             (ack_assert_to_req_deassert_check > 0),
                           .req_deassert_to_ack_deassert_check           (req_deassert_to_ack_deassert_check > 0),
                           .ack_until_req_deassert                       (ack_until_req_deassert > 0), 
		           .ack_deassert_to_req_deassert                 (ack_deassert_to_req_deassert_check > 0),
                           .max_ack_check                                (max_ack > 0),

                           .ack_assert_to_req_deassert_min               (ack_assert_to_req_deassert_min_sampled),
                           .ack_assert_to_req_deassert_max               (ack_assert_to_req_deassert_max_sampled),
                           .req_deassert_to_ack_deassert_min             (req_deassert_to_ack_deassert_min_sampled),
                           .req_deassert_to_ack_deassert_max             (req_deassert_to_ack_deassert_max_sampled),
                           .ack_deassert_to_req_deassert_min             (ack_deassert_to_req_deassert_min_sampled),
                           .ack_deassert_to_req_deassert_max             (ack_deassert_to_req_deassert_max_sampled),

                           .single_req_fire                              (single_req_fire),
                           .single_ack_fire                              (single_ack_fire),
                           .req_until_ack_fire                           (req_until_ack_fire), 
                           .max_fire                                     (max_fire),
                           .min_fire                                     (min_fire),
                           .ack_deassert_to_req_deassert_fire            (ack_deassert_to_req_deassert_fire), 
                           .max_ack_fire                                 (max_ack_fire), 
                           .ack_assert_to_req_deassert_fire              (ack_assert_to_req_deassert_fire),
                           .req_deassert_to_ack_deassert_fire            (req_deassert_to_ack_deassert_fire),
                           .ack_until_req_deassert_fire                  (ack_until_req_deassert_fire),
                           .requests                                     (requests),
                           .acknowledgments                              (acknowledgments),
                           .requests_and_acknowledgments                 (requests_and_acknowledgments),
                           .fastest_acknowledgment                       (fastest_acknowledgment),
                           .slowest_acknowledgment                       (slowest_acknowledgment),
                           .current_unacknowledged_requests              (current_unacknowledged_requests),
		           .min_cycles_between_request_count             (min_cycles_between_request_count),
                           .request_for_max_cycles_count                 (request_for_max_cycles_count),
                           .ack_for_max_cycles_count                     (ack_for_max_cycles_count),
                           .min_cycles_between_ack_asrt_to_req_dsrt      (min_cycles_between_ack_asrt_to_req_dsrt),
                           .max_cycles_between_ack_asrt_to_req_dsrt      (max_cycles_between_ack_asrt_to_req_dsrt),
                           .min_cycles_between_req_dsrt_to_ack_dsrt      (min_cycles_between_req_dsrt_to_ack_dsrt),
                           .max_cycles_between_req_dsrt_to_ack_dsrt      (max_cycles_between_req_dsrt_to_ack_dsrt),
                           .min_cycles_between_ack_dsrt_to_req_dsrt      (min_cycles_between_ack_dsrt_to_req_dsrt),
                           .max_cycles_between_ack_dsrt_to_req_dsrt      (max_cycles_between_ack_dsrt_to_req_dsrt),
                           .number_of_cycles_req_ack_deasserted_together (number_of_cycles_req_ack_deasserted_together),

			   .support                                      (1'b1),
			   .fire_count                                   (fire_count)
                         );

`qvlendmodule //qvl_req_ack
