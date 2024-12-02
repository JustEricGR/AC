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

`qvlmodule qvl_multiplexor (
                            clk,
                            reset_n,
                            active,
                            in_data,
                            mux_select,
                            out_data
                           );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter in_width = 1;
  parameter out_width = 1;
  parameter select_width = 1;
  parameter item_count = 1;
  parameter binary = 0;

  input clk; 
  input reset_n;
  input active;
  input [in_width-1:0] in_data; 
  input [select_width-1:0] mux_select;
  input [out_width-1:0] out_data; 

  wire multiplexor_fire;
  wire [63:0] selects_checked;
  wire [63:0] inputs_selected;
  wire [item_count-1:0] inputs_selected_bitmap;
  wire [63:0] inputs_not_selected;
  wire all_inputs_selected;
  wire [63:0] fire_count;

  wire reset_n_sampled;
  wire active_sampled;
  wire [in_width-1:0] in_data_sampled; 
  wire [select_width-1:0] mux_select_sampled;
  wire [out_width-1:0] out_data_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled    = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled     = active;
  assign `QVL_DUT2CHX_DELAY in_data_sampled    = in_data;
  assign `QVL_DUT2CHX_DELAY mux_select_sampled = mux_select;
  assign `QVL_DUT2CHX_DELAY out_data_sampled   = out_data;

  qvl_multiplexor_assertions #(
                               .severity_level(severity_level),
                               .property_type(property_type),
                               .msg(msg),
                               .coverage_level(coverage_level),
                               .IN_WIDTH(in_width),
                               .OUT_WIDTH(out_width),
                               .SELECT_WIDTH(select_width),
                               .IN_ITEM_COUNT(item_count),
                               .BINARY(binary),
                               .BIN_SEL_WIDTH_REQD(`qvl_log2(item_count)),
                               .CNTWIDTH(`qvl_log2(select_width)) 
                              )
           qvl_multiplexor_chx (
                                .active(active_sampled),
                                .clock(clk),
                                .reset(~reset_n_sampled),
                                .areset(1'b0),
                                .in(in_data_sampled),
                                .out(out_data_sampled),
                                .select(mux_select_sampled),
                                .used(1'b1),
                                .used_cond(1'b1),
                                .multiplexor_check(1'b1),
                                .multiplexor_fire(multiplexor_fire),
                                .selects_checked(selects_checked),
                                .inputs_selected(inputs_selected),
                                .inputs_selected_bitmap(inputs_selected_bitmap),
                                .inputs_not_selected(inputs_not_selected),
                                .all_inputs_selected(all_inputs_selected),
                                .support(1'b1),
                                .fire_count(fire_count)
                               );
`qvlendmodule

