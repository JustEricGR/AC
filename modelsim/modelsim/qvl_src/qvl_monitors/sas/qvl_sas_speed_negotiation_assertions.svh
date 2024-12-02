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
  parameter QVL_PROPERTY_TYPE = 0; // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SAS_VIOLATION : ";

  wire not_clock = ~clock;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((non_align_primitive_in_spd_neg_window))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_P"}),
                          .msg            ("Only ALIGN0 and ALIGN1 primitives are allowed inside the speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((electrical_idle_detected_within_SNTT))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_P"}),
                          .msg            ("Electrical idle detected during Speed Negotiation Transmit Time(SNTT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((align0_to_align1_trans_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_P"}),
                          .msg            ("ALIGN0 to ALIGN1 transition should happen within speed negotiation lock time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((rate_supported_without_align_for_g1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_P"}),
                          .msg            ("ALIGN0 was not detected in G1 phase of speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((rate_supported_without_align_for_g2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_P"}),
                          .msg            ("ALIGN0 was not detected in G2 phase of speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_SPD_NEG_WINDOW_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((spd_neg_win_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SPD_NEG_WINDOW_VIOLATION_P"}),
                          .msg            ("Speed Negotiation window violation occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (non_align_primitive_in_spd_neg_window))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_N"}),
                          .msg            ("Only ALIGN0 and ALIGN1 primitives are allowed inside the speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (electrical_idle_detected_within_SNTT))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_N"}),
                          .msg            ("Electrical idle detected during Speed Negotiation Transmit Time(SNTT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (align0_to_align1_trans_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_N"}),
                          .msg            ("ALIGN0 to ALIGN1 transition should happen within speed negotiation lock time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (rate_supported_without_align_for_g1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_N"}),
                          .msg            ("ALIGN0 was not detected in G1 phase of speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (rate_supported_without_align_for_g2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_N"}),
                          .msg            ("ALIGN0 was not detected in G2 phase of speed negotiation window."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_SPD_NEG_WINDOW_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (spd_neg_win_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SPD_NEG_WINDOW_VIOLATION_N"}),
                          .msg            ("Speed Negotiation window violation occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((non_align_primitive_in_spd_neg_window))));
        M_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((electrical_idle_detected_within_SNTT))));
        M_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((align0_to_align1_trans_violation))));
        M_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((rate_supported_without_align_for_g1))));
        M_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((rate_supported_without_align_for_g2))));
        M_SAS_SPD_NEG_WINDOW_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((spd_neg_win_violation))));
        M_SAS_NON_ALIGN_PRIMITIVE_IN_SPD_NEG_WINDOW_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (non_align_primitive_in_spd_neg_window))));
        M_SAS_ELECTRICAL_IDLE_DETDCTED_DURING_SNTT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (electrical_idle_detected_within_SNTT))));
        M_SAS_ALIGN0_TO_ALIGN1_TRANS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (align0_to_align1_trans_violation))));
        M_SAS_G1RATE_SUPPORTED_WITHOUT_ALIGN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (rate_supported_without_align_for_g1))));
        M_SAS_G2RATE_SUPPORTED_WITHOUT_ALIGN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock ),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (rate_supported_without_align_for_g2))));
        M_SAS_SPD_NEG_WINDOW_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clock),
                          .reset_n   (~(areset | reset) ),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE === 1'b1) &&
                           (transaction_in_g1rate === 1'b0) &&
                           (spd_neg_win_violation))));
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
