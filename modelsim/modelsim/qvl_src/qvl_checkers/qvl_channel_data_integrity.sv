//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.
//
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                  TERMS.
//
//                    Questa Verification Library (QVL)


`include "std_qvl_defines.h"

`qvlmodule qvl_channel_data_integrity(
                                 clk,
                                 reset_n,
                                 active,
                                 insert,
				 remove,
				 cancel,
				 empty,
                                 insert_data,
                                 remove_data,
                                 cancel_data
                              );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;


  parameter width = 1; //width of each data port
  parameter depth = 1; // Depth of the channel
  parameter insert_count = 1; // number of insert_data signals
  parameter remove_count = 1; // number of remove_data signals
  parameter cancel_count = 1; //  number of cancel_data signals  


  parameter pass = 0;
  parameter registered = 0;
  parameter latency = 0;
  parameter high_water = 0; 
  parameter insert_check = 0; //default off check
  parameter cancel_check = 0; //default off check
  parameter empty_check = 0; //default off check
// internal parameter
  parameter internal_high_water = (high_water != 0) ? high_water :
                                    ((depth === 1) ? 1 : depth-1);                

  input                          clk;
  input                          reset_n;
  input                          active;
  input [insert_count-1:0]      insert;
  input [(width * insert_count)-1:0] insert_data;
  input [remove_count-1:0]      remove;
  input [(width * remove_count)-1:0] remove_data;
  input [cancel_count-1:0]  cancel;
  input [(width * cancel_count)-1:0] cancel_data;
  input empty;
  
  wire data_fire;
  wire remove_fire;
  wire cancel_fire;
  wire insert_fire;
  wire empty_fire;

   //Statistics signals
  wire[63:0] inserts_and_removes;
  wire [63:0] inserts;
  wire [63:0] removes;
  wire [63:0] cancels;
  wire [63:0] maximum_count;
  wire [63:0] current_count;
  wire [width-1:0] set_to_one_bitmap;
  wire [width-1:0] set_to_zero_bitmap;

  wire each_bit_set_to_one;
  wire each_bit_set_to_zero;
  wire [63:0] full_count;
  wire [63:0] empty_count;
  wire [63:0] high_water_count;

  wire                               reset_n_sampled;
  wire                               active_sampled;
  wire [insert_count-1:0]           insert_sampled;
  wire [(width * insert_count)-1:0] insert_data_sampled;
  wire [remove_count-1:0]           remove_sampled;
  wire [(width * remove_count)-1:0] remove_data_sampled;
  wire [cancel_count-1:0]       cancel_sampled;
  wire [(width * cancel_count)-1:0] cancel_data_sampled;
  wire                               empty_sampled;
  
  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled  = active;
  assign `QVL_DUT2CHX_DELAY insert_sampled = insert;
  assign `QVL_DUT2CHX_DELAY insert_data_sampled = insert_data;
  assign `QVL_DUT2CHX_DELAY remove_sampled = remove; 
  assign `QVL_DUT2CHX_DELAY remove_data_sampled = remove_data; 
  assign `QVL_DUT2CHX_DELAY cancel_sampled = cancel;
  assign `QVL_DUT2CHX_DELAY cancel_data_sampled = cancel_data;
  assign `QVL_DUT2CHX_DELAY empty_sampled = empty; 


  qvl_channel_data_integrity_assertions
   #(.severity_level(severity_level),
     .property_type (property_type),
     .msg(msg),
     .coverage_level(coverage_level),
     .IN_DATA_WIDTH(width),
     .IN_DATA_COUNT(insert_count),
     .IN_C(insert_count),
     .RM_DATA_WIDTH(width),
     .RM_DATA_COUNT(remove_count),
     .RM_C(remove_count),
     .CNCL_DATA_WIDTH(width),
     .CNCL_DATA_COUNT(cancel_count),
     .DEPTH(depth),
     .DEPTH_IS_SPECIFIED(1),
     .DEPTH_LOG2(`qvl_log2(depth)),
     .HIGH_WATER(internal_high_water),
     .LATENCY(latency),
     .PASS(pass),
     .REGISTERED(registered),
     .INS_CHK_IS_ON(insert_check === 1),
     .IN_CNT_W(`qvl_log2(insert_count)),
     .RM_CNT_W(`qvl_log2(remove_count)),
     .CN_CNT_W(`qvl_log2(cancel_count)),
     .EMPTY_CHK_IS_ON(empty_check === 1),
     .CANCEL_CHK_IS_ON(cancel_check === 1)
    )
   qvl_channel_data_integrity_chx(
               .active(active),
               .clock(clk),
               .reset(~reset_n_sampled),
               .areset(1'b0),
               .insert(insert_sampled),
               .remove(remove_sampled),
               .insert_data(insert_data_sampled),
               .remove_data(remove_data_sampled),
               .cancel(cancel_sampled),
               .cancel_data(cancel_data_sampled),
               .empty(empty_sampled),
               .data(1'b1),
               .insert_check(insert_check ===1),
               .remove_check(1'b1),
               .empty_check(empty_check === 1),
               .cancel_check(cancel_check === 1),
               .data_fire(data_fire),
               .insert_fire(insert_fire),
               .remove_fire(remove_fire),
               .empty_fire(empty_fire),
               .cancel_fire(cancel_fire),
               .inserts_and_removes(inserts_and_removes),
               .inserts(inserts),
               .removes(removes),
               .cancels(cancels),
               .maximum_count(maximum_count),
               .current_count(current_count),
               .set_to_one_bitmap(set_to_one_bitmap),
               .set_to_zero_bitmap(set_to_zero_bitmap),
               .each_bit_set_to_one(each_bit_set_to_one),
               .each_bit_set_to_zero(each_bit_set_to_zero),
               .full_count(full_count),
               .empty_count(empty_count),
               .high_water_count(high_water_count),
               .support(1'b1)
             ); 
`qvlendmodule
