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

`qvlmodule qvl_memory_access (
                              clk,
                              reset_n,
                              active,
                              read_addr,
                              read_data,
                              read,
                              write_addr,
                              write_data,
                              write,
                              start_addr,
                              end_addr
                             );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter addr_width = 2;
  parameter read_old_data = 0;
  parameter initialized_check = 0;
  parameter single_access_check = 1;
  parameter single_write_check = 0;
  parameter single_read_check = 0;
  parameter data_check = 0;
  parameter data_width = 1;
  parameter latency = 0;

  input clk; 
  input reset_n;
  input active;
  input [addr_width-1:0] read_addr;
  input [data_width-1:0] read_data;
  input read;
  input [addr_width-1:0] write_addr;
  input [data_width-1:0] write_data;
  input write;
  input [addr_width-1:0] start_addr;
  input [addr_width-1:0] end_addr;


  wire initialized_fire;
  wire single_write_fire;
  wire single_read_fire;
  wire single_access_fire;
  wire range_fire;
  wire data_fire;
  wire [63:0] memory_accesses;
  wire [63:0] memory_reads;
  wire [63:0] memory_writes;
  wire [63:0] locations_read;
  wire [63:0] locations_written;
  wire [63:0] same_addr_reads_and_writes;
  wire [63:0] fire_count;

  wire  reset_n_sampled;
  wire  active_sampled;
  wire  [addr_width-1:0] read_addr_sampled;
  wire  [data_width-1:0] read_data_sampled;
  wire  read_sampled;
  wire  [addr_width-1:0] write_addr_sampled;
  wire  [data_width-1:0] write_data_sampled;
  wire  write_sampled;
  wire  [addr_width-1:0] start_addr_sampled;
  wire  [addr_width-1:0] end_addr_sampled;  


 assign `QVL_DUT2CHX_DELAY reset_n_sampled    = reset_n;
 assign `QVL_DUT2CHX_DELAY active_sampled     = active;
 assign `QVL_DUT2CHX_DELAY read_addr_sampled  = read_addr;
 assign `QVL_DUT2CHX_DELAY read_data_sampled  = read_data;
 assign `QVL_DUT2CHX_DELAY read_sampled       = read;
 assign `QVL_DUT2CHX_DELAY write_addr_sampled = write_addr;
 assign `QVL_DUT2CHX_DELAY write_data_sampled = write_data;
 assign `QVL_DUT2CHX_DELAY write_sampled      = write;
 assign `QVL_DUT2CHX_DELAY start_addr_sampled = start_addr;
 assign `QVL_DUT2CHX_DELAY end_addr_sampled   = end_addr;

  qvl_memory_access_assertions #(
                         .severity_level(severity_level),
                         .property_type(property_type),
                         .msg(msg),
                         .coverage_level(coverage_level),
                         .LATENCY(latency),
                         .READ_ADDR_WIDTH(addr_width),
                         .WRITE_ADDR_WIDTH(addr_width),
                         .DATA_OPTION_SPECIFIED(data_check),
                         .READ_DATA_WIDTH(data_width),
                         .WRITE_DATA_WIDTH(data_width),
                         .START_ADDR_WIDTH(addr_width),
                         .END_ADDR_WIDTH(addr_width),
                         .END_ADDR_SPECIFIED(1),
                         .INITIALIZED_ON(initialized_check),  
                         .SINGLE_WRITE_ON(single_write_check),  
                         .SINGLE_READ_ON(single_read_check),  
                         .SINGLE_ACCESS_ON(single_access_check),  
                         .RANGE_ON(1),  
                         .DATA_ON(data_check)  
                        )
          qvl_memory_access_chx (
                        .active(active_sampled ),
                        .clock(clk),
                        .reset(~reset_n_sampled ),
                        .areset(1'b0),
                        .read_addr(read_addr_sampled ),
                        .read_data(read_data_sampled ),
                        .read(read_sampled ),
                        .write_addr(write_addr_sampled ),
                        .write_data(write_data_sampled ),
                        .write(write_sampled ),
                        .read_old_data((read_old_data == 1)),
                        .start_addr(start_addr_sampled ),
                        .end_addr(end_addr_sampled ),
                        .initialized((initialized_check == 1)), 
                        .single_write((single_write_check == 1)) ,
                        .single_read((single_read_check == 1)),
                        .single_access(single_access_check == 1),
                        .range((~((start_addr === ({addr_width{1'b0}})) &&
                               (end_addr === ({addr_width{1'b1}})))) &&
                               (~(start_addr > end_addr))),
                        .data((data_check == 1)),
                        .initialized_fire(initialized_fire),
                        .single_write_fire(single_write_fire),
                        .single_read_fire(single_read_fire),
                        .single_access_fire(single_access_fire),
                        .range_fire(range_fire),
                        .data_fire(data_fire),
                        .memory_accesses(memory_accesses),
                        .memory_reads(memory_reads),
                        .memory_writes(memory_writes),
                        .locations_read(locations_read),
                        .locations_written(locations_written),
                        .same_addr_reads_and_writes(same_addr_reads_and_writes),
                        .support(1'b1),
                        .fire_count(fire_count)
                       );
`qvlendmodule
