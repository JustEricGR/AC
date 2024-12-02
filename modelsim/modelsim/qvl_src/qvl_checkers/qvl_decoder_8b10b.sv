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

`qvlmodule qvl_decoder_8b10b (clk,
                              reset_n,
                              active,
                              in_10b,
                              out_k,
                              out_8b,
                              rd,
                              force_rd_enable,
                              force_rd,
                              reserved_k_codes
                             );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;

  parameter num_decoders = 1; // Number of decoders.
  parameter cascade = 0; // 0 - Non-cascaded decoders.
  parameter reserved_k_codes_count = 0; // 0 - Number of reserved K-codes.
  parameter disparity_check = 0; // If 0, check is off.

  input clk; 
  input reset_n;
  input active;
  input [(10*num_decoders)-1:0] in_10b;
  input [num_decoders-1:0] out_k;
  input [(8*num_decoders)-1:0] out_8b;
  input [(cascade ? 1 : num_decoders)-1:0] rd;
  input [num_decoders-1:0] force_rd_enable;
  input [num_decoders-1:0] force_rd;
  input [(reserved_k_codes_count ? 8*reserved_k_codes_count : 1)-1:0] reserved_k_codes;

  wire decode_fire;
  wire invalid_10b_code_fire;
  wire reserved_k_code_fire;
  wire disparity_fire;

  wire [(8*num_decoders)-1:0] expected_out_8b;
  wire [num_decoders-1:0] expected_out_k;
  wire [(cascade ? 1 : num_decoders)-1:0] expected_rd;

  wire all_k_codes_checked;
  wire all_data_codes_checked;
  wire [63:0] decode_count;
  wire [63:0] data_code_count;
  wire [63:0] k_code_count;
  wire [63:0] force_rd_count;
  wire [63:0] rd_toggle_count;

  wire [63:0] fire_count;

  wire reset_n_sampled; 	    
  wire active_sampled ;	    
  wire [(10*num_decoders)-1:0]in_10b_sampled ;	    
  wire [num_decoders-1:0]out_k_sampled ;	    
  wire [(8*num_decoders)-1:0]out_8b_sampled ;	    
  wire [(cascade ? 1 : num_decoders)-1:0]rd_sampled ;		    
  wire [num_decoders-1:0]force_rd_enable_sampled ;
  wire [num_decoders-1:0]force_rd_sampled ;       
  wire [(reserved_k_codes_count ? 8*reserved_k_codes_count : 1)-1:0] reserved_k_codes_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled 	     = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled 	     = active;
  assign `QVL_DUT2CHX_DELAY in_10b_sampled 	     = in_10b;
  assign `QVL_DUT2CHX_DELAY out_k_sampled 	     = out_k;
  assign `QVL_DUT2CHX_DELAY out_8b_sampled 	     = out_8b;
  assign `QVL_DUT2CHX_DELAY rd_sampled 		     = rd;
  assign `QVL_DUT2CHX_DELAY force_rd_enable_sampled  = force_rd_enable;
  assign `QVL_DUT2CHX_DELAY force_rd_sampled         = force_rd;
  assign `QVL_DUT2CHX_DELAY reserved_k_codes_sampled = reserved_k_codes;

  qvl_decoder_8b10b_assertions #(
    .severity_level (severity_level),
    .property_type (property_type),
    .msg (msg),
    .coverage_level (coverage_level),
    .WIDTH_8B (8*num_decoders),
    .WIDTH_10B (10*num_decoders),
    .CASCADE (cascade),
    .WIDTH_D_OR_K (num_decoders),
    .FORCE_RD_ENABLE_PROVIDED (1),
    .WIDTH_FORCE_RD_ENABLE (num_decoders),
    .FORCE_RD_PROVIDED (1),
    .WIDTH_FORCE_RD (num_decoders),
    .RD_PROVIDED (disparity_check == 1),
    .WIDTH_RD ((cascade ? 1 : num_decoders)),
    .RSVD_K_GIVEN (reserved_k_codes_count > 0),
    .NUM_RSVD_K_CODES (reserved_k_codes_count ? reserved_k_codes_count : 1),
    .DISPARITY_CHECK (disparity_check > 0)
   )
    qvl_decoder_8b10b_chx (
     .clock                  (clk),
     .areset                 (1'b0),
     .reset                  (~reset_n_sampled),
     .active                 (active_sampled),
     .in_10b                 (in_10b_sampled),
     .out_8b                 (out_8b_sampled),
     .out_k                  (out_k_sampled),
     .rd                     (((disparity_check == 1) ? rd_sampled : 1'b0)),
     .force_rd_enable        (force_rd_enable_sampled),
     .force_rd               (force_rd_sampled),
     .reserved_k_codes       ((reserved_k_codes_count ? reserved_k_codes_sampled : 8'b0)),
     .used                   (1'b1),
     .used_cond              (1'b1),
     .decode_check           (1'b1),
     .invalid_10b_code_check (1'b1),
     .reserved_k_code_check  (reserved_k_codes_count > 0),
     .disparity_check        (disparity_check == 1),
     .decode_fire            (decode_fire),
     .invalid_10b_code_fire  (invalid_10b_code_fire),
     .reserved_k_code_fire   (reserved_k_code_fire),
     .disparity_fire         (disparity_fire),
     .expected_out_8b        (expected_out_8b),
     .expected_out_k         (expected_out_k),
     .expected_rd            (expected_rd),
     .all_k_codes_checked    (all_k_codes_checked),
     .all_data_codes_checked (all_data_codes_checked),
     .decode_count           (decode_count),
     .data_code_count        (data_code_count),
     .k_code_count           (k_code_count),
     .force_rd_count         (force_rd_count),
     .rd_toggle_count        (rd_toggle_count),
     .support                (1'b1),
     .fire_count             (fire_count)
    );

`qvlendmodule
