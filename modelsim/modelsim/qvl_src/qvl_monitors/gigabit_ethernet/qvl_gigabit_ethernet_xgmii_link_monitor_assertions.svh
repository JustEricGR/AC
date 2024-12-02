//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.                           
//                                                                          
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY             
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS          
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE         
//                                  TERMS.                                  
//                                                                          
//
`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

  //---------------------------------------------------------------------

  parameter QVL_MSG = "Gigabit Ethernet Violation : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERTON
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  wire not_clk = !clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_detected_on_lane_other_than_zero === 1'b1
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_P"}),
                          .msg            ("The start control character should be aligned to lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_detected_on_lane_other_than_zero === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_N"}),
                          .msg            ("The start control character should be aligned to lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sfd_detected_on_lane_other_than_three === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_P"}),
                          .msg            ("The start frame delimiter should be aligned to lane 3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sfd_detected_on_lane_other_than_three === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_N"}),
                          .msg            ("The start frame delimiter should be aligned to lane 3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sequence_detected_on_lane_other_than_zero === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_P"}),
                          .msg            ("The sequence control character should be aligned to lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sequence_detected_on_lane_other_than_zero === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_N"}),
                          .msg            ("The sequence control character should be aligned to lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_prior_to_start_not_idle_or_sequence === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_P"}),
                          .msg            ("The column prior to the column containing start control character should have all Idle characters or a sequence ordered set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_prior_to_start_not_idle_or_sequence === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_N"}),
                          .msg            ("The column prior to the column containing start control character should have all Idle characters or a sequence ordered set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_P"}),
                          .msg            ("The sequence ordered set should not contain reserved values."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_N"}),
                          .msg            ("The sequence ordered set should not contain reserved values."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_before_start_of_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_P"}),
                          .msg            ("The terminate control character should follow a start control character."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_before_start_of_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_N"}),
                          .msg            ("The terminate control character should follow a start control character."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_before_termination_of_previous_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_P"}),
                          .msg            ("A start control character for a new frame should not be issued before terminating previous frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_before_termination_of_previous_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_N"}),
                          .msg            ("A start control character for a new frame should not be issued before terminating previous frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_before_termination_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_P"}),
                          .msg            ("Idle was detected while the frame is in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_before_termination_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_N"}),
                          .msg            ("Idle was detected while the frame is in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_P"}),
                          .msg            ("Reserved control characters should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_N"}),
                          .msg            ("Reserved control characters should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_P"}),
                          .msg            ("When the bus is idle, Idle control characters should be detected on all lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_N"}),
                          .msg            ("When the bus is idle, Idle control characters should be detected on all lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_P"}),
                          .msg            ("When Terminate is detected, all lanes following the terminate character should carry idle control character."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_N"}),
                          .msg            ("When Terminate is detected, all lanes following the terminate character should carry idle control character."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_error_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_P"}),
                          .msg            ("Error control character is detected on transmiting interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
       A_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_error_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_N"}),
                          .msg            ("Error control character is detected on transmiting interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      A_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_error_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_P"}),
                          .msg            ("Error control character is detected on receiving interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
       A_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_error_control_character_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_N"}),
                          .msg            ("Error control character is detected on receiving interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));



      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_detected_on_lane_other_than_zero === 1'b1
                           )));
        M_GIGABIT_ETHERNET_XGMII_START_ALIGNMENT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_detected_on_lane_other_than_zero === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sfd_detected_on_lane_other_than_three === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SFD_ALIGNMENT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sfd_detected_on_lane_other_than_three === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sequence_detected_on_lane_other_than_zero === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SEQUENCE_ALIGNMENT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (sequence_detected_on_lane_other_than_zero === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_prior_to_start_not_idle_or_sequence === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_NON_IDLE_OR_SEQ_PRIOR_TO_START_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_prior_to_start_not_idle_or_sequence === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_SEQUENCE_OS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_before_start_of_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_TERM_BEFORE_START_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_before_start_of_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_before_termination_of_previous_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_START_BEFORE_TERM_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_before_termination_of_previous_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_before_termination_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_IDLE_BEFORE_TERM_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_before_termination_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character_detected === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_RSVD_CONTROL_CHAR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character_detected === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_IDLE_COLUMN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (idle_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XGMII_TERMINATE_COLUMN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_col_violation === 1'b1)));
       M_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_error_control_character_detected === 1'b1)));
       M_GIGABIT_ETHERNET_XGMII_TX_ERROR_CONTROL_CHARACTER_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_error_control_character_detected === 1'b1)));
      M_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_error_control_character_detected === 1'b1)));
      M_GIGABIT_ETHERNET_XGMII_RX_ERROR_CONTROL_CHARACTER_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_error_control_character_detected === 1'b1)));
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
