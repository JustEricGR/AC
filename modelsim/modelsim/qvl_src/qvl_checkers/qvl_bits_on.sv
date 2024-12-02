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

`qvlmodule qvl_bits_on (clk,
                        reset_n,
                        active,
		        test_expr
                       );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 1;
  parameter min = 0;
  parameter max = 1;
  
  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 

  wire   min_fire;
  wire   max_fire;
  wire   [63:0] fire_count;

  wire value_coverage_fire;
  wire all_values_covered;
  wire [63:0] values_checked;
  wire [63:0] fewest_bits_asserted;
  wire [63:0] most_bits_asserted;
  wire [63:0] min_bits_count;
  wire [63:0] max_bits_count;
  wire [width-1:0] bits_asserted_bitmap;
  wire [63:0] bits_asserted;


  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;


qvl_bits_on_assertions #(
                       .severity_level(severity_level),
                       .property_type(property_type),
                       .msg(msg),
                       .coverage_level(coverage_level),
                       .WIDTH(width),
                       .MIN(min),
                       .MAX(max),
                       .CNTWIDTH (`qvl_log2(width)),
		       .MAX_IS_SPECIFIED (max > 0),
		       .MIN_IS_SPECIFIED (min > 0)
                       )

            qvl_bits_on_chx  (.active 			(active_sampled),
			      .clock 			(clk),
			      .reset 			(~reset_n_sampled),
			      .areset 			(1'b0),
			      .zivar 			(test_expr_sampled),
			      .used 			(1'b0),
			      .used_cond 		(1'b1),
			      .min_check 		(min > 0),
			      .max_check 		(max > 0),
			      .min_fire 		(min_fire),
			      .max_fire 		(max_fire),
			      .values_checked 		(values_checked),
			      .fewest_bits_asserted 	(fewest_bits_asserted),
			      .most_bits_asserted 	(most_bits_asserted),
			      .min_bits_count 		(min_bits_count),
			      .max_bits_count 		(max_bits_count),
                              .bits_asserted 		(bits_asserted),
                              .bits_asserted_bitmap	(bits_asserted_bitmap),
                       	      .support                  (1'b1),
                              .fire_count               (fire_count)
			     );

`qvlendmodule
