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

`qvlmodule qvl_back_pressure (
                               clk,
                               reset_n,
                               active,
                               back_pressure,
                               transmit_ready  );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter min = 1;
  parameter max = 1;
  
  input clk; 
  input reset_n;
  input active;
  input back_pressure;
  input transmit_ready;

  wire back_pressure_fire;
  wire [63:0] windows_checked;
  wire [63:0] minimum_response;
  wire [63:0] maximum_response;
  wire [63:0] min_boundary_count;
  wire [63:0] max_boundary_count;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire back_pressure_sampled;
  wire transmit_ready_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active; 
  assign `QVL_DUT2CHX_DELAY back_pressure_sampled = back_pressure; 
  assign `QVL_DUT2CHX_DELAY transmit_ready_sampled = transmit_ready; 

  qvl_back_pressure_assertions #(
                                 .severity_level(severity_level),
                                 .property_type(property_type),
                                 .msg(msg),
                                 .coverage_level(coverage_level),
                                 .MIN(min),
                                 .MAX(max)
                                 )
           qvl_back_pressure_chx (
                                  .clock                (clk),
                                  .reset                (~reset_n_sampled),
                                  .areset               (1'b0),
                                  .active               (active_sampled),
                                  .back_pressure        (back_pressure_sampled),
                                  .xmit_ready           (transmit_ready_sampled),
                                  .back_pressure_check  (1'b1),
                                  .back_pressure_fire   (back_pressure_fire),
                                  .windows_checked      (windows_checked),
                                  .minimum_response     (minimum_response),
                                  .maximum_response     (maximum_response),
				  .min_boundary_count   (min_boundary_count),
                                  .max_boundary_count   (max_boundary_count),
				  .support              (1'b1),
				  .fire_count           (fire_count));

`qvlendmodule
