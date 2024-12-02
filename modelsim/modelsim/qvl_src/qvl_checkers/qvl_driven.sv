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

`qvlmodule qvl_driven (clk,
                       reset_n,
                       active,
		       test_expr
                      );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width = 4;
  
  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr; 

  wire [63:0] fire_count;
  wire [63:0] values_checked;
  wire driven_fire;


  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled   = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled    = active;
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;


qvl_driven_assertions #(
                       .severity_level(severity_level),
                       .property_type(property_type),
                       .msg(msg),
                       .coverage_level(coverage_level),
                       .WIDTH(width)
                       )

            qvl_driven_chx (.zivar          (test_expr_sampled) , 
                            .used           (1'b1), 
                            .used_cond      (1'b1),
                            .clock          (clk), 
                            .reset          (~reset_n_sampled), 
                            .areset         (1'b0), 
                            .driven         (1'b1),
		            .active         (active_sampled) , 
                            .driven_fire    (driven_fire),
                            .values_checked (values_checked), 
                            .support        (1'b1),
	                    .fire_count     (fire_count));


`qvlendmodule
