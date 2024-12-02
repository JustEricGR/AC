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

  parameter QVL_MSG = "Gigabit Ethernet Violation : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERTON
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;

  wire not_clk = !clk ;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_10b_code_violation === 1'b1
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_P"}),
                          .msg            ("Detected an invalid 10B code group."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_10b_code_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_N"}),
                          .msg            ("Detected an invalid 10B code group."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (disparity_error_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_P"}),
                          .msg            ("Disparity error detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (disparity_error_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_N"}),
                          .msg            ("Disparity error detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (symbol_following_terminate_not_sync_violation === 1'b1
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_P"}),
                          .msg            ("The terminate code-group should be followed by sync code-groups in that column."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (symbol_following_terminate_not_sync_violation === 1'b1
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_N"}),
                          .msg            ("The terminate code-group should be followed by sync code-groups in that column."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_sync_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_P"}),
                          .msg            ("In a Sync column, all the code-groups should be K28.5."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_sync_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_N"}),
                          .msg            ("In a Sync column, all the code-groups should be K28.5."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_skip_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_P"}),
                          .msg            ("In a Skip column, all the code-groups should be K28.0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_skip_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_N"}),
                          .msg            ("In a Skip column, all the code-groups should be K28.0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_align_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_P"}),
                          .msg            ("In an Align column, all the code-groups should be K28.3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_align_col_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_N"}),
                          .msg            ("In an Align column, all the code-groups should be K28.3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_following_align_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_P"}),
                          .msg            ("The first ||I|| following ||T|| should not be ||A|| and should alternate between ||A|| and ||K||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_following_align_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_N"}),
                          .msg            ("The first ||I|| following ||T|| should not be ||A|| and should alternate between ||A|| and ||K||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sync_following_sync_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_P"}),
                          .msg            ("The first ||I|| following ||T|| should not be ||K|| and should alternate between ||A|| and ||K||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sync_following_sync_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_N"}),
                          .msg            ("The first ||I|| following ||T|| should not be ||K|| and should alternate between ||A|| and ||K||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (second_idle_following_term_not_skip_or_seq_violation 
                           === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_P"}),
                          .msg            ("The second ||I|| following a ||T|| should be an ||R|| or ||Q||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (second_idle_following_term_not_skip_or_seq_violation 
                           === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_N"}),
                          .msg            ("The second ||I|| following a ||T|| should be an ||R|| or ||Q||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (non_align_or_sync_following_terminate_violation 
                           === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_P"}),
                          .msg            ("The ||T|| should be followed by an ||A|| or ||K|| in the next column."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (non_align_or_sync_following_terminate_violation 
                           === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_N"}),
                          .msg            ("The ||T|| should be followed by an ||A|| or ||K|| in the next column."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_char_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_P"}),
                          .msg            ("Control character other than Terminate, Sequence or Error detected during a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_char_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_N"}),
                          .msg            ("Control character other than Terminate, Sequence or Error detected during a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_char_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_P"}),
                          .msg            ("Control character Error detected during a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_char_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_N"}),
                          .msg            ("Control character Error detected during a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));


        A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_P"}),
                          .msg            ("Error control characters detected during idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_N"}),
                          .msg            ("Error control characters detected during idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 && 
                           invalid_control_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_P"}),
                          .msg            ("Reserved control characters should not be detected during idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_N"}),
                          .msg            ("Reserved control characters should not be detected during idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_P"}),
                          .msg            ("Data character(s) detected during idle period between frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_during_idle_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_N"}),
                          .msg            ("Data character(s) detected during idle period between frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (start_control_char_alignment_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_P"}),
                          .msg            ("A start control character should not be placed on any lane other than lane zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (start_control_char_alignment_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_N"}),
                          .msg            ("A start control character should not be placed on any lane other than lane zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_control_char_alignment_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_P"}),
                          .msg            ("A sequence control character should not be placed on any lane other than lane zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_control_char_alignment_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_N"}),
                          .msg            ("A sequence control character should not be placed on any lane other than lane zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 &&
                           |disparity_neutral_000111_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_P"}),
                          .msg            ("Sub-blocks encoded as 000111 should be generated only when the running disparity at the beginning of the sub-block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_000111_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_N"}),
                          .msg            ("Sub-blocks encoded as 000111 should be generated only when the running disparity at the beginning of the sub-block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_111000_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_P"}),
                          .msg            ("Sub-blocks encoded as 111000 should be generated only when the running disparity at the beginning of the sub-block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_111000_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_N"}),
                          .msg            ("Sub-blocks encoded as 111000 should be generated only when the running disparity at the beginning of the sub-block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 &&
                           |disparity_neutral_0011_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_P"}),
                          .msg            ("Sub-blocks encoded as 0011 should be generated only when the running disparity at the beginning of the sub-block is positiv."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_0011_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_N"}),
                          .msg            ("Sub-blocks encoded as 0011 should be generated only when the running disparity at the beginning of the sub-block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_1100_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_P"}),
                          .msg            ("Sub-blocks encoded as 1100 should be generated only when the running disparity at the beginning of the sub-block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_1100_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_N"}),
                          .msg            ("Sub-blocks encoded as 1100 should be generated only when the running disparity at the beginning of the sub-block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_spacing_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_P"}),
                          .msg            ("A minimum of 16 non-||A|| columns should be detected between two ||A|| columns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_spacing_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_N"}),
                          .msg            ("A minimum of 16 non-||A|| columns should be detected between two ||A|| columns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (max_align_spacing_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_P"}),
                          .msg            ("No more than a maximum of 31 non-||A|| columns should be detected between two ||A|| columns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (max_align_spacing_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_N"}),
                          .msg            ("No more than a maximum of 31 non-||A|| columns should be detected between two ||A|| columns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_not_following_align_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_P"}),
                          .msg            ("A ||Q|| should always follow an ||A||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_not_following_align_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_N"}),
                          .msg            ("A ||Q|| should always follow an ||A||."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (skew_limit_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_P"}),
                          .msg            ("Lane to lane skew should not be greater than the maximum limit of 41BT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (skew_limit_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_N"}),
                          .msg            ("Lane to lane skew should not be greater than the maximum limit of 41BT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (lanes_loss_of_sync == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_P"}),
                          .msg            ("Synchronization is Lost on Lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (lanes_loss_of_sync == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_N"}),
                          .msg            ("Synchronization is Lost on Lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_loss == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_P"}),
                          .msg            ("Alignment is Lost on Lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_loss == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_N"}),
                          .msg            ("Alignment is Lost on Lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_10b_code_violation === 1'b1
                           )));
        M_GIGABIT_ETHERNET_XAUI_10B_CODE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_10b_code_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (disparity_error_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (disparity_error_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (symbol_following_terminate_not_sync_violation === 1'b1
                           )));
        M_GIGABIT_ETHERNET_XAUI_TERMINATE_OS_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (symbol_following_terminate_not_sync_violation === 1'b1
                           )));
        M_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_sync_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SYNC_COL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_sync_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_skip_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SKIP_COL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_skip_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_align_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ALIGN_COL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (illegal_align_col_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_following_align_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ALIGNS_AFTER_SUCCESSIVE_TERM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_following_align_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sync_following_sync_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SYNCS_AFTER_SUCCESSIVE_TERM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sync_following_sync_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (second_idle_following_term_not_skip_or_seq_violation 
                           === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SECOND_COL_FROM_TERM_NOT_SKP_OR_SEQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (second_idle_following_term_not_skip_or_seq_violation 
                           === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (non_align_or_sync_following_terminate_violation 
                           === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_NON_ALIGN_OR_SYNC_AFTER_TERM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (non_align_or_sync_following_terminate_violation 
                           === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_char_during_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_FRAME_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_char_during_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_char_during_frame === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_FRAME_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_char_during_frame === 1'b1)));


        M_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 && 
                           invalid_control_during_idle_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_INVALID_CTRL_CHAR_DURING_IDLE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (invalid_control_during_idle_violation === 1'b1)));

        M_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_during_idle_violation === 1'b1)));

        M_GIGABIT_ETHERNET_XAUI_ERROR_CTRL_CHAR_DURING_IDLE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (error_control_during_idle_violation === 1'b1)));

        M_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_during_idle_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DATA_CHAR_DURING_IDLE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_during_idle_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (start_control_char_alignment_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_START_ALIGNMENT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (start_control_char_alignment_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_control_char_alignment_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SEQUENCE_ALIGNMENT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_control_char_alignment_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 &&
                           |disparity_neutral_000111_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_000111_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_111000_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_111000_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 &&
                           |disparity_neutral_0011_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_0011_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_1100_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (alignment_boundary == 1'b1 && 
                           |disparity_neutral_1100_error === 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_spacing_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_MIN_ALIGN_SPACING_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_spacing_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (max_align_spacing_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_MAX_ALIGN_SPACING_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (max_align_spacing_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_not_following_align_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SEQUENCE_NOT_FOLLOWING_ALIGN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (sequence_not_following_align_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (skew_limit_violation == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_SKEW_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (skew_limit_violation == 1'b1)));

        M_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (lanes_loss_of_sync == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_LOSS_OF_SYNC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (lanes_loss_of_sync == 1'b1)));

       M_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_loss == 1'b1)));
        M_GIGABIT_ETHERNET_XAUI_LOSS_OF_ALIGNMENT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (align_loss == 1'b1)));

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
