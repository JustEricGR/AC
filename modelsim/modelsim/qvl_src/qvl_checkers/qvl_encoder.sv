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

`qvlmodule qvl_encoder (clk,
                        reset_n,
                        active,
                        in_data,
                        out_data
                       );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter in_width = 2;
  parameter out_width = 1;
  parameter lsb = 0; // If 0, the -lsb option not specified.
  parameter multibit_check = 0; // If 0, the multibit check is off.

  input clk; 
  input reset_n;
  input active;
  input [in_width-1:0] in_data; 
  input [out_width-1:0] out_data; 

  wire [63:0] encode_count;
  wire [63:0] encodes_checked;
  wire [in_width-1:0] encodes_checked_bitmap;
  wire all_encodes_checked;
  wire [63:0] fire_count;

  wire encode_fire;
  wire zero_fire;
  wire multibit_fire;
  
  wire reset_n_sampled;
  wire active_sampled;
  wire [in_width-1:0] in_data_sampled; 
  wire [out_width-1:0] out_data_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled  = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled   = active;
  assign `QVL_DUT2CHX_DELAY in_data_sampled  = in_data; 
  assign `QVL_DUT2CHX_DELAY out_data_sampled = out_data; 

  qvl_encoder_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .coverage_level (coverage_level),
      .INWIDTH (in_width),
      .CHKWIDTH (`qvl_log2(in_width)),
      .OUTWIDTH (out_width),
      .MULTIBIT_CHK_ON(multibit_check>0)
     )
      qvl_encoder_chx (.clock                    (clk),
                       .areset                   (1'b0),
                       .reset                    (~reset_n_sampled),
                       .active                   (active_sampled),
                       .in                       (in_data_sampled),
                       .out                      (out_data_sampled), 
                       .lsb                      (lsb > 0), 
                       .used                     (1'b1), 
                       .used_cond                (1'b1), 
                       .encode_check             (1'b1),
                       .zero_check               (1'b1),
                       .multibit_check           (multibit_check > 0),
                       .encode_fire              (encode_fire),
                       .zero_fire                (zero_fire),
                       .multibit_fire            (multibit_fire),
                       .encode_count             (encode_count),
                       .encodes_checked          (encodes_checked),
                       .encodes_checked_bitmap   (encodes_checked_bitmap),
                       .all_encodes_checked      (all_encodes_checked),
                       .support                  (1'b1),
                       .fire_count               (fire_count)
                      );

`qvlendmodule
