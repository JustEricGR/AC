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

`qvlmodule qvl_xproduct_value_coverage (
                                      clk,
                                      reset_n,
                                      active,
                                      test_expr1,
                                      test_expr2,
                                      val1,
                                      val2
                                      );

  parameter severity_level = `QVL_ERROR;
  parameter property_type = `QVL_ASSERT;
  parameter msg = "QVL_VIOLATION : ";
  parameter coverage_level = `QVL_COVER_NONE;
  parameter width1 = 1;
  parameter width2 = 1;
  parameter val1_width = 1;
  parameter val2_width = 1;
  parameter val1_count = 0;
  parameter val2_count = 0;
  parameter min1 = 0;
  parameter min2 = 0;
  parameter max1 = 0;
  parameter max2 = 0;
  parameter coverage_check = 0;

 //Internal Parameters :
  parameter max1_real = (max1 ? max1 : {width1{1'b1}});
  parameter max2_real = (max2 ? max2 : {width2{1'b1}});
  parameter val1_is_specified = val1_count > 0;
  parameter val2_is_specified = val2_count > 0;  
  parameter val1_width_internal = (val1_is_specified ? ((val1_width*val1_count)-1):0);
  parameter val2_width_internal = (val2_is_specified ? ((val2_width*val2_count)-1):0);

  input clk; 
  input reset_n;
  input active;
  input [width1-1:0] test_expr1; 
  input [width2-1:0] test_expr2; 
  input [val1_width_internal :0] val1;
  input [val2_width_internal :0] val2;

  wire xpd_covered_fire;
  wire matrix_covered;
  parameter bmap_width = (val1_is_specified?val1_count:(max1_real-min1+1))*(val2_is_specified?val2_count:(max2_real-min2+1));
  wire [bmap_width-1:0] coverage_matrix_bitmap;

  wire  reset_n_sampled;
  wire  active_sampled;
  wire  [width1-1:0] test_expr1_sampled; 
  wire  [width2-1:0] test_expr2_sampled; 
  wire  [val1_width_internal :0] val1_sampled;
  wire  [val2_width_internal :0] val2_sampled;

  assign `QVL_DUT2CHX_DELAY   reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY   active_sampled  = active;
  assign `QVL_DUT2CHX_DELAY   test_expr1_sampled = test_expr1; 
  assign `QVL_DUT2CHX_DELAY   test_expr2_sampled = test_expr2;  
  assign `QVL_DUT2CHX_DELAY   val1_sampled = val1;
  assign `QVL_DUT2CHX_DELAY   val2_sampled = val2;

  qvl_xproduct_value_coverage_assertions #(
                                           .severity_level(severity_level),
                                           .property_type(property_type),
                                           .msg(msg),
                                           .coverage_level(coverage_level),
                                           .VAR1_WIDTH(width1),
                                           .VAR2_WIDTH(width2),
                                           .MIN1(min1),
                                           .MIN1_IS_SPECIFIED(1),
                                           .MAX1(max1_real),
                                           .MAX1_IS_SPECIFIED(1),
                                           .MIN2(min2),
                                           .MIN2_IS_SPECIFIED(1),
                                           .MAX2(max2_real),
                                           .MAX2_IS_SPECIFIED(1),
                                           .VAL1_ITEM_WIDTH(val1_width),
                                           .VAL1_ITEM_COUNT(val1_count),
                                           .VAL1_IS_SPECIFIED(val1_is_specified),
                                           .VAL2_ITEM_WIDTH(val2_width),
                                           .VAL2_ITEM_COUNT(val2_count),
                                           .VAL2_IS_SPECIFIED(val2_is_specified),
                                           .VAL1_WIDTH(val1_is_specified ? (val1_width*val1_count):1),
                                           .VAL2_WIDTH(val2_is_specified ? (val2_width*val2_count):1)
                                           )
           qvl_xproduct_value_coverage_chx (
                                           .active(active_sampled),
                                           .clock(clk),
                                           .reset(~reset_n_sampled),
                                           .areset(1'b0),
                                           .var1(test_expr1_sampled),
                                           .var2(test_expr2_sampled),
                                           .val1(val1_sampled),
                                           .val2(val2_sampled),
                                           .xval(coverage_check > 0),
                                           .xpd_covered_fire(xpd_covered_fire),
                                           .matrix_covered(matrix_covered),
                                           .coverage_matrix_bitmap(coverage_matrix_bitmap),
                                           .support(1'b1)                                                                                                 );
`qvlendmodule

