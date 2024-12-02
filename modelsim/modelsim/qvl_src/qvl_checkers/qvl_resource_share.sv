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

`qvlmodule qvl_resource_share (
                                clk,
                                reset_n,
                                active,
                                resource_enables,
                                min_idle,
                                max_idle, 
                                min_hold,
                                max_hold
                              );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter resource_count = 1;
  parameter min_idle_check = 0;
  parameter max_idle_check = 0;
  parameter min_hold_check = 0;
  parameter max_hold_check = 0;

  input clk; 
  input reset_n;
  input active;
  input [resource_count-1:0] resource_enables;
  input [31:0] min_idle;
  input [31:0] max_idle;
  input [31:0] min_hold;
  input [31:0] max_hold;

  wire resource_conflict_fire;
  wire min_idle_fire;
  wire max_idle_fire;
  wire min_hold_fire;
  wire max_hold_fire;
  wire [63:0] resource_accessed_count;
  wire [resource_count-1:0] resource_enable_bitmap;
  wire [(`qvl_log2(resource_count)):0] accessed_signal_count;
  wire [63:0] minimum_resource_hold_time;
  wire [63:0] maximum_resource_hold_time;
  wire [63:0] minimum_resource_idle_time;
  wire [63:0] maximum_resource_idle_time;
  wire all_resources_enabled;
  wire [63:0] min_idle_count;
  wire [63:0] max_idle_count;
  wire [63:0] min_hold_count;
  wire [63:0] max_hold_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire [resource_count-1:0] resource_enables_sampled;
  wire [31:0] min_idle_sampled;
  wire [31:0] max_idle_sampled;
  wire [31:0] min_hold_sampled;
  wire [31:0] max_hold_sampled;                          

  assign `QVL_DUT2CHX_DELAY reset_n_sampled          = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled           = active;
  assign `QVL_DUT2CHX_DELAY resource_enables_sampled = resource_enables;
  assign `QVL_DUT2CHX_DELAY min_idle_sampled         = min_idle;
  assign `QVL_DUT2CHX_DELAY max_idle_sampled         = max_idle;
  assign `QVL_DUT2CHX_DELAY min_hold_sampled         = min_hold;
  assign `QVL_DUT2CHX_DELAY max_hold_sampled         = max_hold;                       



  qvl_resource_share_assertions #(
                                  .severity_level(severity_level),
                                  .property_type(property_type),
                                  .msg(msg),
                                  .coverage_level(coverage_level),
                                  .WRITE_WIDTH(resource_count),
                          .WRITE_WIDTH_LOG2(`qvl_log2(resource_count)),
                                  .MIN_IDLE_WIDTH(32),
                                  .MAX_IDLE_WIDTH(32),
                                  .MIN_HOLD_WIDTH(32),
                                  .MAX_HOLD_WIDTH(32),
                                  .MIN_IDLE_CHECK(min_idle_check > 0),
                                  .MAX_IDLE_CHECK(max_idle_check > 0),
                                  .MIN_HOLD_CHECK(min_hold_check > 0),
                                  .MAX_HOLD_CHECK(max_hold_check > 0)
                                 )
         qvl_resource_share_chx (
                                 .clock(clk),
                                 .reset(~reset_n_sampled),
                                 .areset(1'b0), 
                                 .active(active_sampled),
                                 .resource_enable(resource_enables_sampled),
                                 .min_idle(min_idle_sampled),
                                 .max_idle(max_idle_sampled),
                                 .min_hold(min_hold_sampled),
                                 .max_hold(max_hold_sampled),
                                 // checks
                                 .resource_conflict_check(1'b1),
                                 .min_idle_check(min_idle_check > 0),
                                 .max_idle_check(max_idle_check > 0),
                                 .min_hold_check(min_hold_check > 0),
                                 .max_hold_check(max_hold_check > 0),
                                 // fires
                                .resource_conflict_fire(resource_conflict_fire),
                                 .min_idle_fire(min_idle_fire),
                                 .max_idle_fire(max_idle_fire),
                                 .min_hold_fire(min_hold_fire),
                                 .max_hold_fire(max_hold_fire),
                                 // statistics
                              .resource_accessed_count(resource_accessed_count),
                                .resource_enable_bitmap(resource_enable_bitmap),
                                 .accessed_signal_count(accessed_signal_count),
                       .minimum_resource_hold_time(minimum_resource_hold_time),
                       .maximum_resource_hold_time(maximum_resource_hold_time),
                       .minimum_resource_idle_time(minimum_resource_idle_time),
                       .maximum_resource_idle_time(maximum_resource_idle_time),
                                 // corner cases
                                 .all_resources_enabled(all_resources_enabled),
                                 .min_idle_count(min_idle_count),
                                 .max_idle_count(max_idle_count),
                                 .min_hold_count(min_hold_count),
                                 .max_hold_count(max_hold_count),
                                 .support(1'b1)
                               );
`qvlendmodule
