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

`qvlmodule qvl_assert_leader (clk,
                              reset_n,
                              active,
                              leader,
                              follower
                             );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;

  parameter min = 0;
  parameter max = 0;
  parameter max_leaders = 0;

  input clk; 
  input reset_n;
  input active;
  input leader;
  input follower;

  wire assert_leader_fire;

  wire [63:0] max_response_time;
  wire [63:0] min_response_time;
  wire [63:0] windows_checked;
  wire [63:0] outstanding_leaders;
  wire [63:0] min_response_time_equals_min;
  wire [63:0] max_response_time_equals_max;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire leader_sampled;
  wire follower_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled  = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY leader_sampled   = leader; 
  assign `QVL_DUT2CHX_DELAY follower_sampled = follower;


  qvl_assert_leader_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .MAX_WIDTH (`qvl_infer_width(max)),
      .MIN_WIDTH (`qvl_infer_width(min)),
      .MAX_LEADER_WIDTH (`qvl_infer_width(max_leaders)),
      .MAX_SPECIFIED (max > 0),
      .MIN_SPECIFIED (min > 0),
      .MAX_LEADER_SPECIFIED (max_leaders > 0),
      .MAX_IS_CONST (1),
      .MAX_CONST_VAL (max),
      .MAX_LEADER_IS_CONST (1),
      .MAX_LEADER_CONST_VAL (max_leaders)
     )
      qvl_assert_leader_chx (
        .active            (active_sampled),
        .clock             (clk),
        .reset             (~reset_n_sampled),
        .areset            (1'b0),
        .leader            (leader_sampled),
        .follower          (follower_sampled),
        .max               (max[(`qvl_infer_width(max))-1:0]),
        .min               (min[(`qvl_infer_width(min))-1:0]),
        .max_leader        (max_leaders[(`qvl_infer_width(max_leaders))-1:0]),
        .assert_leader_check (1'b1),
        .assert_leader_fire  (assert_leader_fire),
        .max_response_time   (max_response_time),
        .min_response_time   (min_response_time),
        .outstanding_leaders (outstanding_leaders),
        .windows_checked     (windows_checked),
        .min_response_time_equals_min (min_response_time_equals_min),
        .max_response_time_equals_max (max_response_time_equals_max),
        .fire_count        (fire_count),
        .support           (1'b1)
        );

`qvlendmodule
