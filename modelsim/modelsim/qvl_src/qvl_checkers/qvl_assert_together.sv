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

`qvlmodule qvl_assert_together (clk,
                                reset_n,
                                active,
		                test_expr1,
		                test_expr2
                                );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
   
  input clk; 
  input reset_n;
  input active;
  input test_expr1; 
  input test_expr2; 

  wire [63:0] fire_count;
  wire [63:0] transitions_checked;
  wire assert_together_fire;
  
  wire reset_n_sampled;
  wire active_sampled; 
  wire test_expr1_sampled;
  wire test_expr2_sampled;

  assign `QVL_DUT2CHX_DELAY reset_n_sampled    = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled     = active; 
  assign `QVL_DUT2CHX_DELAY test_expr1_sampled = test_expr1;
  assign `QVL_DUT2CHX_DELAY test_expr2_sampled = test_expr2;

qvl_assert_together_assertions #(
                                 .severity_level(severity_level),
                                 .property_type(property_type),
                                 .msg(msg),
                                 .coverage_level(coverage_level)
                                 )

            qvl_assert_together_chx (.clock (clk),
			             .reset (~reset_n_sampled),
			             .areset (1'b0),
			             .active (active_sampled),
			             .assert_together (1'b1),
			             .var1 (test_expr1_sampled),
			    	     .var2 (test_expr2_sampled),
				     .assert_together_fire (assert_together_fire),
				     .transitions_checked (transitions_checked),
				     .support (1'b1),
				     .fire_count(fire_count));

`qvlendmodule
