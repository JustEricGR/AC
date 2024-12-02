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

`qvlmodule qvl_decoder (clk,
                        reset_n,
                        active,
                        in_data,
                        out_data
                       );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter in_width = 1;
  parameter out_width = 2;
  parameter msb = 0; // If 0, the -msb option not specified.

  input clk; 
  input reset_n;
  input active;
  input [in_width-1:0] in_data; 
  input [out_width-1:0] out_data; 

  wire [63:0] decode_count;
  wire [63:0] decodes_checked;
  wire [out_width-1:0] decodes_checked_bitmap;
  wire all_decodes_checked;
  wire [63:0] fire_count;

  wire decode_fire;

  wire reset_n_sampled; 
  wire active_sampled;  
  wire [in_width-1:0] in_data_sampled; 
  wire [out_width-1:0] out_data_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled  = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY in_data_sampled  = in_data; 
  assign `QVL_DUT2CHX_DELAY out_data_sampled = out_data; 

  qvl_decoder_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .INWIDTH (in_width),
      .OUTWIDTH (out_width)
     )
      qvl_decoder_chx (.clock                    (clk),
                       .areset                   (1'b0),
                       .reset                    (~reset_n_sampled ),
                       .active                   (active_sampled ),
                       .in                       (in_data_sampled ),
                       .out                      (out_data_sampled ), 
                       .msb                      (msb > 0), 
                       .used                     (1'b1), 
                       .used_cond                (1'b1), 
                       .decode_check             (1'b1),
                       .decode_fire              (decode_fire),
                       .decode_count             (decode_count),
                       .decodes_checked          (decodes_checked),
                       .decodes_checked_bitmap   (decodes_checked_bitmap),
                       .all_decodes_checked      (all_decodes_checked),
                       .support                  (1'b1),
                       .fire_count               (fire_count)
                      );

`qvlendmodule
