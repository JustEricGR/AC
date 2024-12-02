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

`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

  //---------------------------------------------------------------------

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = {32{1'b1}}; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SAS_VIOLATION : ";

  wire not_clk = ~clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_SAS_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_000111_error &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_000111_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 6'b000111 should be generated only when the running disparity at the begining of the sub block is positive"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_111000_error &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_111000_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 6'b111000 should be generated only when the running disparity at the begining of the sub block is negative"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_0011_error &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_0011_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 4'b0011 should be generated only when the running disparity at the begining of the sub block is positive"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_1100_error &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_1100_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 4'b1100 should be generated only when the running disparity at the begining of the sub block is negative"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_10B_CODING_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (sas_10b_code_violation == 1'b0 &&
                           parallel_symbol_valid &&
                           ~electrical_idle_detected &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_10B_CODING_VIOLATION_P"}),
                          .msg            ("Invalid 10b code on interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RESERVED_K_CODE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (reserved_k_code === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_K_CODE_P"}),
                          .msg            ("Allowed K-codes in SAS protocol are K28.5 and K28.3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_000111_error && 
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_000111_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 6'b000111 should be generated only when the running disparity at the begining of the sub block is positive"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_111000_error && 
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_111000_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 6'b111000 should be generated only when the running disparity at the begining of the sub block is negative"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_0011_error && 
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_0011_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 4'b0011 should be generated only when the running disparity at the begining of the sub block is positive"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 && 
                           disparity_neutral_1100_error &&
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DISPARITY_NEUTRAL_1100_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 4'b1100 should be generated only when the running disparity at the begining of the sub block is negative"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_10B_CODING_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           sas_10b_code_violation === 1'b0 &&
                           parallel_symbol_valid &&
                           ~electrical_idle_detected && 
                           first_k_code_detected === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_10B_CODING_VIOLATION_N"}),
                          .msg            ("Invalid 10b code on interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RESERVED_K_CODE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           reserved_k_code === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_K_CODE_N"}),
                          .msg            ("Allowed K-codes in SAS protocol are K28.5 and K28.3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_SAS_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_000111_error &&
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_111000_error &&
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_0011_error &&
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (disparity_neutral_1100_error &&
                           first_k_code_detected === 1'b0)));
        M_SAS_10B_CODING_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (sas_10b_code_violation == 1'b0 &&
                           parallel_symbol_valid &&
                           ~electrical_idle_detected &&
                           first_k_code_detected === 1'b0)));
        M_SAS_RESERVED_K_CODE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (reserved_k_code === 1'b1)));
        M_SAS_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_000111_error && 
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_111000_error && 
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           disparity_neutral_0011_error && 
                           first_k_code_detected === 1'b0)));
        M_SAS_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 && 
                           disparity_neutral_1100_error &&
                           first_k_code_detected === 1'b0)));
        M_SAS_10B_CODING_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           sas_10b_code_violation === 1'b0 &&
                           parallel_symbol_valid &&
                           ~electrical_idle_detected && 
                           first_k_code_detected === 1'b0)));
        M_SAS_RESERVED_K_CODE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr (pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0 &&
                           reserved_k_code === 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_ASSERT_ON
