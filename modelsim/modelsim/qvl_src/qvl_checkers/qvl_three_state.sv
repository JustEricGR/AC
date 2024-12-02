//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.
//
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                  TERMS.
//
//                    Questa Verification Library (QVL)
/*********************************************************************/


`include "std_qvl_defines.h"

`qvlmodule qvl_three_state (clk,
                            reset_n,
                            active,
                            enable,
                            in_data,
                            out_data
                          );
  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1; 

  input                      clk;
  input                      reset_n;
  input                      active;
  input                      enable;
  input [width-1:0]          in_data;
  input [width-1:0]          out_data;

  wire three_state_fire;
  
  //Statistics signals
  wire [63:0]                enable_transitions;
  wire [63:0]                cycles_checked; 
  wire [63:0]                fire_count; 

  wire                       reset_n_sampled;
  wire                       active_sampled;
  wire                       enable_sampled;
  wire  [width-1:0]          in_data_sampled;
  wire  [width-1:0]          out_data_sampled;

  assign `QVL_DUT2CHX_DELAY  reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY  active_sampled  = active;
  assign `QVL_DUT2CHX_DELAY  enable_sampled  = enable;
  assign `QVL_DUT2CHX_DELAY  in_data_sampled  = in_data;
  assign `QVL_DUT2CHX_DELAY  out_data_sampled = out_data;

qvl_three_state_assertions
   #(.severity_level(severity_level),
     .property_type (property_type),
     .msg(msg),
     .coverage_level(coverage_level),
     .IN_WIDTH (width),
     .OUT_WIDTH (width),
     .EN_WIDTH (1)
    )
     qvl_three_state_chx( .active      (active_sampled),
                   .clock              (clk),
                   .reset              (~reset_n_sampled),
                   .areset             (1'b0),
                   .enable             (enable_sampled),
                   .in                 (in_data_sampled),
                   .out                (out_data_sampled),
                   .three_state_check  (1'b1),                   
                   .support            (1'b1),
                   .fire_count         (fire_count),
                   .three_state_fire   (three_state_fire),
                   .enable_transitions (enable_transitions),
                   .cycles_checked     (cycles_checked)
                );

`qvlendmodule // qvl_three_state
