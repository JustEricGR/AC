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

`qvlmodule qvl_crc (clk,
                    reset_n,
                    active,
                    test_expr,
                    initialize,
                    valid,
                    compare,
                    crc,
                    crc_latch
                   );

  parameter severity_level = `QVL_ERROR;

  parameter property_type = `QVL_ASSERT;

  parameter msg = "QVL_VIOLATION : ";

  parameter coverage_level = `QVL_COVER_NONE;

  parameter width = 1;

  parameter data_width = 0;

  parameter crc_width = 5;

  parameter crc_enable = 0;

  parameter crc_latch_enable = 0;

  parameter polynomial = 5; 

  parameter initial_value = 0;

  parameter lsb_first = 0;

  parameter big_endian = 0;

  parameter reverse_endian = 0;

  parameter invert = 0;

  parameter combinational = 0;


  // Internal parameters

  parameter crc_poly_specified = (polynomial == 0) ? 0 : 1; 

  parameter latch_crc_specified = (crc_latch_enable == 0) ? 0 : 1; 

  parameter crc_computation_width_internal = (data_width > 0) ? 
                                            data_width : width;

  parameter crc_comp_counter_width = `qvl_log2(crc_computation_width_internal); 

  parameter in_crc_specified = (crc_enable == 0) ? 0 : 1; 

  parameter int_initial_crc_value = (initial_value == 0) ? 0 : 
                                              (initial_value + 1);

  input clk; 
  input reset_n;
  input active;
  input [width-1:0] test_expr;
  input initialize;
  input [crc_width-1:0] crc;
  input compare;
  input valid;
  input crc_latch;

  wire  crc_fire;
  wire  [63:0] min_data_count;
  wire  [63:0] max_data_count;
  wire  [63:0] total_crc_computations;
  wire  [63:0] cycles_checked;
  wire  [crc_width-1:0] expected_crc_value;
  wire  [63:0] fire_count;
  wire  [crc_width-1:0] crc_polynomial_wire;

  assign crc_polynomial_wire = polynomial;
  
  wire reset_n_sampled;
  wire active_sampled;
  wire [width-1:0] test_expr_sampled;
  wire initialize_sampled;
  wire [crc_width-1:0] crc_sampled;
  wire compare_sampled;
  wire valid_sampled;
  wire crc_latch_sampled;
  
  assign `QVL_DUT2CHX_DELAY reset_n_sampled = reset_n;
  assign `QVL_DUT2CHX_DELAY active_sampled = active; 
  assign `QVL_DUT2CHX_DELAY test_expr_sampled = test_expr;
  assign `QVL_DUT2CHX_DELAY initialize_sampled = initialize;
  assign `QVL_DUT2CHX_DELAY crc_sampled = crc; 
  assign `QVL_DUT2CHX_DELAY compare_sampled = compare; 
  assign `QVL_DUT2CHX_DELAY valid_sampled = valid; 
  assign `QVL_DUT2CHX_DELAY crc_latch_sampled = crc_latch; 
 

  qvl_crc_assertions
    #(.severity_level (severity_level),
      .property_type (property_type),
      .msg (msg),
      .CRC_POLY_SPECIFIED (crc_poly_specified),
      .CRC_POLY_WIDTH (crc_width),
      .DATA_WIDTH (width),
      .CRC_COMPUTATION_WIDTH (crc_computation_width_internal),
      .LATCH_CRC_SPECIFIED (latch_crc_specified),
      .CRC_COMP_COUNTER_WIDTH (crc_comp_counter_width),
      .IN_CRC_SPECIFIED (in_crc_specified),
      .INITIAL_CRC_VALUE (int_initial_crc_value),
      .FINAL_CRC_INVERT(invert),
      .CONVERSE_CRC_ENDIAN(reverse_endian),
      .LSB_FIRST(lsb_first),
      .BIG_ENDIAN(big_endian),
      .CRC_COMBO(combinational)
     )
    qvl_crc_chx
             (
              .clock                        (clk),
              .areset                       (1'b0),
              .reset                        (~reset_n_sampled),
              .active                       (active_sampled),
              .in_data                      (test_expr_sampled),
              .start_crc                    (initialize_sampled),
              .in_crc                       (crc_sampled),
              .latch_crc                    (latch_crc_specified ?
                                                      crc_latch_sampled: 1'b0),
              .in_data_valid                (valid_sampled),
              .compare_crc_enable           (compare_sampled),
              .crc_polynomial               (crc_polynomial_wire),
              .crc_check                    (1'b1),
              .crc_fire                     (crc_fire),
              .min_data_count               (min_data_count),
              .max_data_count               (max_data_count),
              .total_crc_computations       (total_crc_computations),
              .cycles_checked               (cycles_checked),
              .expected_crc_value           (expected_crc_value),
              .support                      (1'b1),
              .fire_count                   (fire_count)
             );

`qvlendmodule                    
