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

`qvlmodule qvl_arbiter (clk,
                        reset_n,
                        active,
                        req,
                        gnt
                       );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 2; // Widths of 'req' and 'gnt' signals.
  parameter req_type = 0; // 0 - All checks related to the assertion of 'req'
                          //     are off.
                          // 1 - Latched Request.
                          // 2 - Request until grant.
  parameter gnt_type = 0; // 0 - No  defined type for grant.
                          //     All related checks are off.
                          // 1 - Priority.
                          // 2 - Fair.
                          // 3 - Queue.
                          // 4 - Round Robin.
                          // 5 - Least recently used.
  parameter deassert_count = 0;
  parameter park = 0; // 0 - No park. Park Check is Off
                      // 1 - width implies park on specified channel.
                      // > width - Any park.
  parameter min = 0; // If 0, the min_check is off.
  parameter max = 0; // If 0, the max_check is off.
  parameter max_gnt_cycles = 0; // If 0, the max_gnt_check is off.
  parameter no_simultaneous_req_gnt = 0; // Not a check enable, it is a flag.

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] req; 
  input [width-1:0] gnt; 

  wire fair_fire;
  wire priority_fire;
  wire queue_fire;
  wire round_robin_fire;
  wire least_recently_used_fire;
  wire single_grant_fire;
  wire known_grant_fire;
  wire req_until_gnt_fire;
  wire park_fire;
  wire single_req_per_channel_fire;
  wire deassert_fire;
  wire min_fire;
  wire max_fire;
  wire max_grant_fire;
  wire [63:0] requests;
  wire [63:0] grants;
  wire [63:0] requests_and_grants;
  wire [63:0] fastest_grant;
  wire [63:0] slowest_grant;
  wire [63:0] outstanding_cycles_equals_min_count;
  wire [63:0] outstanding_cycles_equals_max_count;
  wire [63:0] grant_asserted_equals_max_grant_count;
  wire [63:0] maximum_requests_outstanding;
  wire [63:0] current_requests_outstanding;
  wire [63:0] requests_asserted;
  wire [width-1:0] requests_asserted_bitmap;
  wire [63:0] grants_asserted;
  wire [width-1:0] grants_asserted_bitmap;
  wire all_requests_asserted;
  wire all_grants_asserted;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] req_sampled; 
  wire [width-1:0] gnt_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY req_sampled   = req;
  assign `QVL_DUT2CHX_DELAY gnt_sampled   = gnt;

  qvl_arbiter_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .REQ_WIDTH (width),
      .GNT_WIDTH (width),
      .SUPPORT_WIDTH (1),
      .FAIR_ON (gnt_type == 2),
      .PRIORITY_ON (gnt_type == 1),
      .QUEUE_ON (gnt_type == 3),
      .ROUND_ROBIN_ON (gnt_type == 4),
      .LEAST_RECENTLY_USED_ON (gnt_type == 5),
      .SINGLE_GRANT_ON (1),
      .KNOWN_GRANT_ON (park <= width),
      .REQ_UNTIL_GNT_ON (req_type == 2),
      .PARK_CHECK_ON (park > 0),
      .SINGLE_REQ_PER_CHANNEL_ON (req_type == 1),
      .DEASSERT_CHECK_ON ((req_type == 2 || req_type == 0) && deassert_count > 0),
      .MIN_CHECK_ON (min > 0),
      .MAX_CHECK_ON (max > 0),
      .MAX_GRANT_CHECK_ON (max_gnt_cycles > 0),
      .NO_SIMULTANEOUS_REQ_GNT (no_simultaneous_req_gnt),
      .DEASSERT (deassert_count),
      .LATCH_REQ (req_type == 1),
      .PARK ((park > width) ? 1 : park),
      .ANY_PARK (park > width),
      .PARK_SPECIFIED ((park <= width) && (park > 0)),
      .ANY_PARK_SPECIFIED (park > width),
      .MIN (min),
      .MAX (max),
      .MAX_GRANT (max_gnt_cycles),
      .MAX_WIDTH (`qvl_log2(max)),
      .MIN_WIDTH (`qvl_log2(min)),
      .PTR_WIDTH (`qvl_log2(width)),
      .MUX_SELECT_WIDTH (`qvl_log2(width)),
      .LRU_MUX_WIDTH_TMP (`qvl_log2(width)),
      .NO_OF_GNTS_WIDTH (`qvl_log2(width))
     )
      qvl_arbiter_chx (.active            (active_sampled),
                       .clock             (clk),
                       .reset             (~reset_n_sampled),
                       .areset            (1'b0),
                       .req               (req_sampled),
                       .gnt               (gnt_sampled),
                       .fair              (gnt_type == 2),
                       .priority_check    (gnt_type == 1),
                       .queue             (gnt_type == 3),
                       .round_robin       (gnt_type == 4),
                       .least_recently_used (gnt_type == 5),
                       .single_grant      (1'b1),
                       .known_grant       (park <= width),
                       .req_until_gnt     (req_type == 2),
                       .park_check        (park > 0),
                       .single_req_per_channel (req_type == 1),
                       .deassert_check    ((req_type == 2 || req_type == 0) && deassert_count > 0),
                       .min_check         (min > 0),
                       .max_check         (max > 0),
                       .max_grant_check   (max_gnt_cycles > 0),
                       .fair_fire         (fair_fire),
                       .priority_fire     (priority_fire),
                       .queue_fire        (queue_fire),
                       .round_robin_fire  (round_robin_fire),
                       .least_recently_used_fire (least_recently_used_fire),
                       .single_grant_fire (single_grant_fire),
                       .known_grant_fire  (known_grant_fire),
                       .req_until_gnt_fire (req_until_gnt_fire),
                       .park_fire         (park_fire),
                       .single_req_per_channel_fire (single_req_per_channel_fire),
                       .deassert_fire     (deassert_fire),
                       .min_fire          (min_fire),
                       .max_fire          (max_fire),
                       .max_grant_fire    (max_grant_fire),
                       .requests_and_grants (requests_and_grants),
                       .requests          (requests),
                       .grants            (grants),
                       .maximum_requests_outstanding (maximum_requests_outstanding),
                       .current_requests_outstanding (current_requests_outstanding),
                       .fastest_grant     (fastest_grant),
                       .slowest_grant     (slowest_grant),
                       .requests_asserted (requests_asserted),
                       .requests_asserted_bitmap (requests_asserted_bitmap),
                       .grants_asserted   (grants_asserted),
                       .grants_asserted_bitmap (grants_asserted_bitmap),
                       .all_requests_asserted (all_requests_asserted),
                       .all_grants_asserted (all_grants_asserted),
                       .outstanding_cycles_equals_min_count (outstanding_cycles_equals_min_count),
                       .outstanding_cycles_equals_max_count (outstanding_cycles_equals_max_count),
                       .grant_asserted_equals_max_grant_count (grant_asserted_equals_max_grant_count),
                       .fire_count        (fire_count),
                       .support           (1'b1)
                       );

`qvlendmodule
