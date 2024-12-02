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

`qvlmodule qvl_multi_clock_multi_port_memory_access (read_clk,
                                                     write_clk,
                                                     read_reset_n,
                                                     write_reset_n,
                                                     active,
                                                     read_active,
                                                     write_active,
                                                     read,
                                                     write,
                                                     read_addr,
                                                     write_addr,
                                                     read_data,
                                                     write_data,
                                                     start_addr,
                                                     end_addr
                                                    );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter read_count = 1; // Number of read ports.
  parameter write_count = 1; // Number of write ports.
  parameter addr_width = 4; // Widths of address ports.
  parameter data_width = 4; // Widths of data ports.

  parameter latency = 0; // Read Latency for data check.
  parameter write_lock_period = 0;
  parameter read_lock_period = 0;

  parameter multiple_read_check = 0; // Check-off if 0.
  parameter single_write_check = 0; // Check-off if 0.
  parameter single_read_check = 0; // Check-off if 0.
  parameter initialized_check = 0; // Check-off if 0.
  parameter data_check = 0; // Check-off if 0.

  input read_clk; 
  input write_clk; 
  input read_reset_n;
  input write_reset_n;
  input active;
  input read_active;
  input write_active;
  input [read_count-1:0] read;
  input [write_count-1:0] write;
  input [(read_count*addr_width)-1:0] read_addr;
  input [(write_count*addr_width)-1:0] write_addr;
  input [(read_count*data_width)-1:0] read_data;
  input [(write_count*data_width)-1:0] write_data;
  input [addr_width-1:0] start_addr;
  input [addr_width-1:0] end_addr;

  wire initialized_fire;
  wire single_write_fire;
  wire single_read_fire;
  wire write_while_read_fire;
  wire read_while_write_fire;
  wire write_range_fire;
  wire read_range_fire;
  wire data_fire;
  wire multiple_read_fire;
  wire multiple_write_fire;

  wire [63:0] all_ports_read;
  wire [63:0] all_ports_written;
  wire all_locations_read;
  wire all_locations_written;

  wire [63:0] memory_accesses;
  wire [63:0] memory_reads;
  wire [63:0] memory_writes;
  wire [63:0] locations_read;
  wire [63:0] locations_written;
  wire [63:0] single_location_multiple_reads;
  wire [63:0] concurrent_reads;
  wire [63:0] concurrent_writes;
  wire [63:0] maximum_reads;
  wire [63:0] maximum_writes;
  wire [63:0] min_idle_time;
  wire [63:0] max_idle_time;
  wire [read_count-1:0] read_port_bit_map;
  wire [write_count-1:0] write_port_bit_map;
  wire [63:0] fire_count;


  wire                   read_reset_n_sampled;
  wire                   write_reset_n_sampled;
  wire                   active_sampled;
  wire                   read_active_sampled;
  wire                   write_active_sampled;
  wire [read_count-1:0]  read_sampled;
  wire [write_count-1:0] write_sampled;

  wire [(read_count*addr_width)-1:0]  read_addr_sampled;
  wire [(write_count*addr_width)-1:0] write_addr_sampled;
  wire [(read_count*data_width)-1:0]  read_data_sampled;
  wire [(write_count*data_width)-1:0] write_data_sampled;

  wire [addr_width-1:0] start_addr_sampled;
  wire [addr_width-1:0] end_addr_sampled;


  assign `QVL_DUT2CHX_DELAY read_reset_n_sampled  = read_reset_n;
  assign `QVL_DUT2CHX_DELAY write_reset_n_sampled = write_reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled        = active;
  assign `QVL_DUT2CHX_DELAY read_active_sampled   = read_active;
  assign `QVL_DUT2CHX_DELAY write_active_sampled  = write_active;
  assign `QVL_DUT2CHX_DELAY read_sampled          = read;
  assign `QVL_DUT2CHX_DELAY write_sampled         = write;
  assign `QVL_DUT2CHX_DELAY read_addr_sampled     = read_addr;
  assign `QVL_DUT2CHX_DELAY write_addr_sampled    = write_addr;
  assign `QVL_DUT2CHX_DELAY read_data_sampled     = read_data;
  assign `QVL_DUT2CHX_DELAY write_data_sampled    = write_data;
  assign `QVL_DUT2CHX_DELAY start_addr_sampled    = start_addr;
  assign `QVL_DUT2CHX_DELAY end_addr_sampled      = end_addr;

  qvl_multi_clock_multi_port_memory_access_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .READ_WIDTH (read_count),
      .READ_ITEM_COUNT (read_count),
      .READ_ADDR_ITEM_WIDTH (addr_width),
      .READ_ADDR_ITEM_COUNT (read_count),
      .READ_DATA_ITEM_WIDTH (data_width),
      .READ_DATA_ITEM_COUNT (read_count),
      .READ_DATA_WIDTH (read_count*data_width),
      .WRITE_ITEM_COUNT (write_count),
      .WRITE_WIDTH (write_count),
      .WRITE_ADDR_ITEM_WIDTH (addr_width),
      .WRITE_ADDR_ITEM_COUNT (write_count),
      .WRITE_DATA_ITEM_WIDTH (data_width),
      .WRITE_DATA_ITEM_COUNT (write_count),
      .WRITE_DATA_WIDTH (write_count*data_width),
      .START_ADDR_WIDTH (addr_width),
      .END_ADDR_WIDTH (addr_width),
      .START_ADDR_SPECIFIED (1),
      .END_ADDR_SPECIFIED (1),
      .LATENCY (latency),
      .LATENCY_WIDTH (`qvl_log2(latency)),
      .WRITE_LOCK_PERIOD (write_lock_period),
      .READ_LOCK_PERIOD (read_lock_period),
      .READ_PORT_IND_WIDTH (`qvl_log2(read_count)),
      .WRITE_PORT_IND_WIDTH (`qvl_log2(write_count)),
      .MULTIPLE_READ_CHECK (multiple_read_check > 0),
      .DATA_CHECK (data_check > 0),
      .SINGLE_WRITE_CHECK (single_write_check > 0),
      .INITIALIZED_CHECK (initialized_check > 0),
      .SINGLE_READ_CHECK (single_read_check > 0)

     )
  qvl_multi_clock_multi_port_memory_access_chx
    (.write_clock(write_clk),
     .read_clock(read_clk),
     .areset(1'b0),
     .write_reset(!write_reset_n_sampled),
     .read_reset(!read_reset_n_sampled),
     .active(active_sampled),
     .write_active(write_active_sampled),
     .read_active(read_active_sampled),
     .write(write_sampled),
     .write_addr(write_addr_sampled),
     .write_data(write_data_sampled),
     .read(read_sampled),
     .read_addr(read_addr_sampled),
     .read_data(read_data_sampled),
     .start_addr(start_addr_sampled),
     .end_addr(end_addr_sampled),

     .initialized(initialized_check == 1),
     .single_write(single_write_check == 1),
     .single_read(single_read_check == 1),
     .read_while_write(1'b1),
     .write_while_read(1'b1),
     .write_range((start_addr_sampled > 0 || end_addr_sampled < {addr_width{1'b1}}) && (end_addr_sampled >= start_addr_sampled)),
     .read_range((start_addr_sampled > 0 || end_addr_sampled < {addr_width{1'b1}}) && (end_addr_sampled >= start_addr_sampled)),
     .data(data_check == 1),
     .multiple_write(1'b1),
     .multiple_read(multiple_read_check == 1),

     .initialized_fire(initialized_fire),
     .single_write_fire(single_write_fire),
     .single_read_fire(single_read_fire),
     .write_while_read_fire(write_while_read_fire),
     .read_while_write_fire(read_while_write_fire),
     .write_range_fire(write_range_fire),
     .read_range_fire(read_range_fire),
     .data_fire(data_fire),
     .multiple_write_fire(multiple_write_fire),
     .multiple_read_fire(multiple_read_fire),

     .all_ports_written(all_ports_written),
     .all_ports_read(all_ports_read),
     .all_locations_written(all_locations_written),
     .all_locations_read(all_locations_read),

     .memory_accesses(memory_accesses),
     .memory_reads(memory_reads),
     .memory_writes(memory_writes),
     .locations_written(locations_written),
     .locations_read(locations_read),
     .single_location_multiple_reads(single_location_multiple_reads),
     .concurrent_writes(concurrent_writes),
     .concurrent_reads(concurrent_reads),
     .maximum_writes(maximum_writes),
     .maximum_reads(maximum_reads),
     .min_idle_time(min_idle_time),
     .max_idle_time(max_idle_time),
     .write_port_bit_map(write_port_bit_map),
     .read_port_bit_map(read_port_bit_map),
     .support(1'b1),
     .fire_count(fire_count)
     );

`qvlendmodule
