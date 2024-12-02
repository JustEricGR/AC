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

`qvlmodule qvl_bus_driver (
                            clk,
                            reset_n,
                            active,
                            test_expr,
                            driver_enables
                           );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter num_drivers = 1; 
  parameter max_undriven_cycles = 0;
  parameter no_driver_check = 0;

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr;
  input [num_drivers-1:0] driver_enables;

  wire multiple_driver_fire;
  wire no_driver_fire;
  wire [63:0] cycles_checked;
  wire [63:0] cycles_driven;
  wire [63:0] cycles_undriven;
  wire [63:0] longest_cycles_undriven;
  wire [63:0] shortest_cycles_undriven;
  wire [63:0] longest_cycles_driven;
  wire [63:0] shortest_cycles_driven;
  wire [63:0] all_driver_enabled_count;
  wire [63:0] max_undriven_cycles_elapsed_count;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled;
  wire [num_drivers-1:0] driver_enables_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled   = test_expr;
  assign `QVL_DUT2CHX_DELAY driver_enables_sampled   = driver_enables;

  qvl_bus_driver_assertions #(
                              .severity_level(severity_level),
                              .property_type(property_type),
                              .msg(msg),
                              .coverage_level(coverage_level),
                              .MAX_UNDRIVEN_CYCLES(max_undriven_cycles),
                              .VARWIDTH(width),
                              .DRIVER_EN_WIDTH(num_drivers),
			      .NO_DRIVER_CHECK(no_driver_check)
                             )
          qvl_bus_driver_chx (
                              .zivar(test_expr_sampled),
                              .driver_enables(driver_enables_sampled),
                              .used(1'b1),
                              .used_cond(1'b1),
                              .clock(clk),
                              .areset(1'b0),
                              .reset(~reset_n_sampled),
                              .active(active_sampled),
                              .multiple_driver(1'b1),
                              .no_driver(no_driver_check > 0),
                              .multiple_driver_fire(multiple_driver_fire),
                              .no_driver_fire(no_driver_fire),
                              .cycles_checked(cycles_checked),
                              .cycles_driven(cycles_driven),
                              .cycles_undriven(cycles_undriven),
                              .longest_cycles_undriven(longest_cycles_undriven),
                            .shortest_cycles_undriven(shortest_cycles_undriven),
                              .longest_cycles_driven(longest_cycles_driven),
                              .shortest_cycles_driven(shortest_cycles_driven),
                            .all_driver_enabled_count(all_driver_enabled_count),
          .max_undriven_cycles_elapsed_count(max_undriven_cycles_elapsed_count),
                              .support(1'b1),
                              .fire_count(fire_count)
                             );
`qvlendmodule
