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

`qvlmodule qvl_assert_follower (clk,
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
  parameter max_leaders = 16;
  parameter known_follower_check = 0;

  input                      clk;
  input                      reset_n;
  input                      active;
  input                      leader;
  input                      follower;

  wire assert_follower_fire;
  wire max_leader_fire;
  wire known_follower_fire;

  // Statistics and corner cases 

  wire [63:0] max_leaders_outstanding;
  wire [63:0] max_response_time;
  wire [63:0] min_response_time;
  wire [63:0] windows_checked;
  wire [63:0] outstanding_leaders;
  wire [63:0] min_response_time_equals_min;
  wire [63:0] max_response_time_equals_max;
  wire [63:0] fire_count;
  
  wire [(`qvl_infer_width(max_leaders)-1) : 0] max_leader_wire = max_leaders;
  wire [(`qvl_infer_width(min)-1) : 0] min_wire = min;
  wire [(`qvl_infer_width(max)-1) : 0] max_wire = max;

  wire reset_n_sampled;
  wire active_sampled; 
  wire leader_sampled;
  wire follower_sampled;
 
  assign `QVL_DUT2CHX_DELAY reset_n_sampled  = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active; 
  assign `QVL_DUT2CHX_DELAY leader_sampled   = leader;
  assign `QVL_DUT2CHX_DELAY follower_sampled = follower;
    
qvl_assert_follower_assertions    
    #(.severity_level         (severity_level),
      .property_type          (property_type),
      .msg                    (msg),
      .coverage_level         (coverage_level),
      .MAX_WIDTH              (`qvl_infer_width(max)),
      .MIN_WIDTH              (`qvl_infer_width(min)),
      .MAX_SPECIFIED          (max > 0),
      .MIN_SPECIFIED          (min > 0),
      .MAX_LEADER_SPECIFIED   (1),
      .MAX_LEADER_IS_CONST    (1),
      .MAX_LEADER_WIDTH_PARAM (4),
      .MAX_LEADER_WIDTH_PORT  (`qvl_infer_width(max_leaders)),
      .MAX_LEADER_CONST_VAL   (max_leaders),
      .MIN_IS_CONST           (1),
      .MAX_IS_CONST           (1),
      .AF_CHECK_ON            (1),
      .ML_CHECK_ON            (1),
      .KF_CHECK_ON            (known_follower_check == 1)
      )
   qvl_assert_follower_chx
     (
     .clock(clk),
     .areset(1'b0),
     .reset(~reset_n_sampled),
     .active(active_sampled),
     .leader(leader_sampled),
     .follower(follower_sampled),
     .min(min_wire),
     .max(max_wire),
     .max_leader(max_leader_wire),
     .assert_follower_check(1'b1),
     .max_leader_check(1'b1),
     .known_follower_check(known_follower_check == 1),
     .assert_follower_fire(assert_follower_fire),
     .max_leader_fire(max_leader_fire),
     .known_follower_fire(known_follower_fire),
     .max_leaders_outstanding(max_leaders_outstanding),
     .max_response_time(max_response_time),
     .min_response_time(min_response_time),
     .windows_checked(windows_checked),
     .outstanding_leaders(outstanding_leaders),
     .min_response_time_equals_min(min_response_time_equals_min),
     .max_response_time_equals_max(max_response_time_equals_max),
     .support(1'b1),
     .fire_count(fire_count)
      );

`qvlendmodule
