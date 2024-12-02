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

`qvlmodule qvl_content_addressable_memory(clk,
                                 reset_n,
                                 active,
                                 write,
                                 addr,
                                 data,
                                 match,
                                 match_found,
                                 data_mask,
                                 match_data,
                                 match_addr
                              );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;

  parameter depth = 1; // Depth of the CONTENT ADDRESSABLE MEMORY 
  parameter width = 1; // width of each data_port i.e write_data and match_
                            // data
  parameter addr_enable = 0; // Default off
                                    // on when write data is specified
  parameter match_data_enable = 0; // Default off
                                    // on when the content of match_data is to
                                    // be compared with the content-addressable
                                    // memory.
  parameter latency = 0;
  parameter allow_x = 0; //default off
  parameter addr_encoding = 0; // 0 - match_address is a bitmap in which
                                      // each bit corresponds to a location in
                                      // the content-addressale memory.
                                      // 1 - match_adress hold a one-hot bitmapi
                                      // in which each bit corresponds to a
                                      // location in the content-addressable 
                                      // memory
                                      // 2 - match_address holds a 
                                      // binary-encoded address.
  parameter lowest_addr = 0; //default off 
  parameter single_match_check =0; // Default off
  parameter address_check = 0; // Default off 

  //-----------------Internal Parameter--------------//
  
  parameter match_addr_width = ((addr_encoding === 2) ? 
                              `qvl_log2(depth) : depth);

  input                            clk;
  input                            reset_n;
  input                            active;
  input                            write;
  input                            match;
  input [(((`qvl_log2(depth))-1) * addr_enable):0]   addr;
  input [width-1:0]           data;
  input                            match_found;
  input [((match_addr_width-1) * address_check) : 0]   match_addr;
  input [width-1:0]         match_data;
  input [width-1:0]         data_mask;


  wire                match_fire;
  wire                single_match_fire; 
  wire                match_address_fire; 
  wire [63:0]         memory_accesses;
  wire [63:0]         no_matches;
  wire [63:0]         memory_writes;
  wire [63:0]         match_cycles;
  wire [63:0]         single_matches;
  wire [63:0]         multiple_matches;

  wire                checker_match;
  wire                checker_multiple_match;
  wire [match_addr_width-1:0]    checker_match_address;
  wire [(match_addr_width-1) : 0] match_addr_internal;
  wire [(`qvl_log2(depth))-1 : 0] write_addr_internal;

  
  wire                       reset_n_sampled;
  wire                       active_sampled;
  wire                       write_sampled;
  wire                       match_sampled;
  wire [(((`qvl_log2(depth))-1) * addr_enable):0] write_address_sampled;
  wire [width-1:0]           write_data_sampled;
  wire                       match_found_sampled;
  wire [((match_addr_width-1) * address_check) : 0] match_address_sampled;
  wire [width-1:0]           match_data_sampled;
  wire [width-1:0]           match_data_mask_sampled;
 
assign match_addr_internal = (address_check == 0) ? {depth{1'b0}} : match_address_sampled; 
  assign write_addr_internal = (addr_enable == 0) ? {`qvl_log2(depth){1'b0}} : write_address_sampled;


  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled =  active;
  assign `QVL_DUT2CHX_DELAY write_sampled = write;
  assign `QVL_DUT2CHX_DELAY match_sampled = match;
  assign `QVL_DUT2CHX_DELAY write_address_sampled = addr;
  assign `QVL_DUT2CHX_DELAY write_data_sampled = data;
  assign `QVL_DUT2CHX_DELAY match_found_sampled = match_found;
  assign `QVL_DUT2CHX_DELAY match_address_sampled = match_addr;
  assign `QVL_DUT2CHX_DELAY match_data_sampled = match_data;
  assign `QVL_DUT2CHX_DELAY match_data_mask_sampled = data_mask;


 qvl_content_addressable_memory_assertions #(.severity_level(severity_level),
                .property_type (property_type),
                .msg(msg),  
                .coverage_level(coverage_level),
                .DEPTH(depth),
                .WRITE_DATA_WIDTH(width),     
                .WRITE_ADDRESS_PORT_WIDTH(`qvl_log2(depth)),
                .WRITE_ADDRESS_WIDTH_BASED_ON_DEPTH(`qvl_log2(depth)),
                .WRITE_ADDRESS_SPECIFIED(addr_enable === 1),
                .BINARY_ENCODED(addr_encoding === 2),
                .TERNARY_CAM (allow_x),
                .ONE_HOT(addr_encoding === 1),
                .LOWEST_ADDRESS(lowest_addr === 1),
                .MATCH_DATA_SPECIFIED(match_data_enable === 1),     
                .MATCH_ADDRESS_SPECIFIED(address_check > 0),
                .MATCH_ADDRESS_PORT_WIDTH((addr_encoding ===2)? 
                                `qvl_log2(depth) : depth),
                .LATENCY (latency),
		.SINGLE_MATCH_CHK_ON(single_match_check),
                .ADDRESS_CHK_ON(address_check)			     
    )
   qvl_content_addressable_memory_chx (
                              .clock(clk),
                              .reset(~reset_n_sampled),
                              .areset(1'b0),
                              .active(active_sampled),
                              .write(write_sampled),
                              .write_data(write_data_sampled),
                              .match(match_sampled),
                              .match_data(match_data_sampled),
                              .match_found(match_found_sampled),
                              .write_address(write_addr_internal),
                              .match_address(match_addr_internal),
                              .match_data_mask(match_data_mask_sampled),
                              .match_check(1'b1),
                              .single_match_check(single_match_check == 1),
                              .match_address_check(address_check == 1),
                              .match_fire(match_fire),
                              .single_match_fire(single_match_fire),
                              .match_address_fire(match_address_fire),
                              .single_matches(single_matches),
                              .multiple_matches(multiple_matches),
                              .no_matches(no_matches),
                              .memory_accesses(memory_accesses),
                              .memory_writes(memory_writes),
                              .match_cycles(match_cycles),
                              .checker_match(checker_match),
                              .checker_multiple_match(checker_multiple_match),
                              .checker_match_address(checker_match_address),
                              .support(1'b1)
                              );


`qvlendmodule 
