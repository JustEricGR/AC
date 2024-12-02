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

`qvlmodule qvl_xproduct_bit_coverage (
                                      clk,
                                      reset_n,
                                      active,
                                      test_expr1,
                                      test_expr2
                                     );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width1 = 1;
  parameter width2 = 1;
  parameter test_expr2_enable = 0;
  parameter coverage_check = 0;

  
  input clk; 
  input reset_n;
  input active;
  input [width1-1:0] test_expr1; 
  input [width2-1:0] test_expr2; 


  wire xpd_covered_fire;
  wire matrix_covered;
  parameter bmap_width = (test_expr2_enable > 0 ? width1*width2 : (width1 === 1? 1:(width1-1)*(width1-1)));
  wire [bmap_width-1:0] coverage_matrix_bitmap;

  wire reset_n_sampled;
  wire active_sampled;
  wire [width1-1:0] test_expr1_sampled; 
  wire [width2-1:0] test_expr2_sampled; 

  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled  = active;
  assign `QVL_DUT2CHX_DELAY test_expr1_sampled = test_expr1; 
  assign `QVL_DUT2CHX_DELAY test_expr2_sampled = test_expr2;  

  qvl_xproduct_bit_coverage_assertions #(
                                         .severity_level(severity_level),
                                         .property_type(property_type),
                                         .msg(msg),
                                         .coverage_level(coverage_level),
                                         .WIDTH1(width1),
                                         .WIDTH2(width2),
                                         .VAR1_IS_SPECIFIED(1),
                                         .VAR2_IS_SPECIFIED(test_expr2_enable > 0)
                                         )
           qvl_xproduct_bit_coverage_chx (
                                         .active(active_sampled),
                                         .clock(clk),
                                         .reset(~reset_n_sampled),
                                         .areset(1'b0),
                                         .var1(test_expr1_sampled),
                                         .var2(test_expr2_sampled),
                                         .xbit(coverage_check > 0),
                                         .xpd_covered_fire(xpd_covered_fire),
                                         .matrix_covered(matrix_covered),
                                         .coverage_matrix_bitmap(coverage_matrix_bitmap),
                                         .support(1'b1)                                                                                                 );
`qvlendmodule
