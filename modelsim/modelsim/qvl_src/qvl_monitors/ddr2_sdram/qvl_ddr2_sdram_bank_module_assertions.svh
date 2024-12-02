//              Copyright 2006 Mentor Graphics Corporation
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
`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

//---------------------------------------------------------------------

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = ZI_CONSTRAINTS_MEMORY_SIDE;
                                      // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;
  parameter QVL_MSG = "QVL_DDR2_SDRAM_BANK_VIOLATION : ";

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// assert only checks

        A_DDR2_SDRAM_UNKNOWN_STATE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (next_state === ZI_UNKNOWN))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_UNKNOWN_STATE"}),
                          .msg            ("The bank state machine went to UNKNOWN_STATE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

// Checks based on QVL_PROPERTY_TYPE
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_DDR2_SDRAM_ACTIVATE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (act_without_precharge === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ACTIVATE"}),
                          .msg            ("An ACTIVATE command was issued to an already open bank without an intervening PRECHARGE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_BURST_ABORTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 &&
                           (z_rd_burst_in_progress === 1'b1 ||
                           z_wr_burst_in_progress === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_BURST_ABORTED_P"}),
                          .msg            ("A read or write burst was aborted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CKE_LOW: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 && (track_tMRD_counter > 1 ||
                           read_burst_counter > 0 || write_data_period > 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CKE_LOW"}),
                          .msg            ("CKE was driven low during a cycle other than self refresh or power down."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRCD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRCD_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRCD_VIOLATION"}),
                          .msg            ("The command issued violates the tRCD timing between an activation and Read/Write command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRAS_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRAS_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRAS_VIOLATION"}),
                          .msg            ("The command issued violates the tRAS timing between an activation and precharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRP_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRP_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRP_VIOLATION"}),
                          .msg            ("The command issued violates the precharge command period (tRP)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TCCD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tCCD_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TCCD_VIOLATION"}),
                          .msg            ("The command issued violates the tCCD timing between two Read/Write commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRTW_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTW_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRTW_VIOLATION"}),
                          .msg            ("The command issued violates the tRTW timing between a READ and WRITE command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TWTR_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTR_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TWTR_VIOLATION"}),
                          .msg            ("The command issued violates the tWTR timing between a Write and Read command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRTP_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTP_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRTP_VIOLATION"}),
                          .msg            ("The command issued violates the tRTP timing between a Read and Precharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TWTP_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTP_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TWTP_VIOLATION"}),
                          .msg            ("The command issued violates the tWTP timing between a Write and Precharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRTR_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTR_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRTR_VIOLATION"}),
                          .msg            ("The command issued violates the tRTR timing between two Read commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TWTW_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTW_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TWTW_VIOLATION"}),
                          .msg            ("The command issued violates the tWTW timing between two Write commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRFC_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0)&&(tRFC_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRFC_VIOLATION"}),
                          .msg            ("The command issued violates the tRFC timing between Auto Refresh and Auto Refresh/Activate command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TXSNR_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXSNR_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXSNR_VIOLATION"}),
                          .msg            ("The command issued violates the tXSNR timing required between a Self Refresh Exit and a Non-Read command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TXSRD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXSRD_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXSRD_VIOLATION"}),
                          .msg            ("The command issued violates the tXSRD timing between a Self Refresh Exit and a Read command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_WRITE_TO_IDLE_BANK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (write_cmd_without_activation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_WRITE_TO_IDLE_BANK"}),
                          .msg            ("A write command was issued to an idle bank."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_READ_TO_IDLE_BANK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (read_cmd_without_activation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_READ_TO_IDLE_BANK"}),
                          .msg            ("A read command was issued to an idle bank."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_PRECHARGE_TO_IDLE_BANK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_PRECHARGE_TO_IDLE_BANK === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (precharge_issued_to_idle_bank === 1'b1 &&
                           init_sequence_done === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_PRECHARGE_TO_IDLE_BANK"}),
                          .msg            ("A Precharge command was issued to an idle bank."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_IDLE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE"}),
                          .msg            ("An illegal command was issued when the bank was in IDLE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_PRE_ALL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_PRECHARGE_ALL))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_PRE_ALL"}),
                          .msg            ("An illegal command was issued when all banks were in PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_PRE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_PRECHARGE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_PRE"}),
                          .msg            ("An illegal command was issued when the bank was in PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_MRS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_MODE_REG_SET))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_MRS"}),
                          .msg            ("An illegal command was issued when the memory was in MODE_REG_SET state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_EMRS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_EX_MODE_REG_SET))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_EMRS"}),
                          .msg            ("An illegal command was issued when the memory was in EX_MODE_REG_SET state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_ACTIVATE_BANK))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_ACTIVE"}),
                          .msg            ("An illegal command was issued when the bank was in ACTIVATE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_WRITE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE"}),
                          .msg            ("An illegal command was issued when the bank was in WRITE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE_AP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_WRITE_AUTO_PRECHARGE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE_AP"}),
                          .msg            ("An illegal command was issued when the bank was in WRITE_AUTO_PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_READ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_READ))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_READ"}),
                          .msg            ("An illegal command was issued when the bank was in READ state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_READ_AP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_READ_AUTO_PRECHARGE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_READ_AP"}),
                          .msg            ("An illegal command was issued when the bank was in READ_AUTO_PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_ACT_PWR_DN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_ACT_PWR_DOWN))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_ACT_PWR_DN"}),
                          .msg            ("An illegal command was issued when the bank was in Active Power Down state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE_PWR_DN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_IDLE_PWR_DOWN))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE_PWR_DN"}),
                          .msg            ("An illegal command was issued when the bank was in Idle Power Down state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_CBR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_CBR_REFRESH))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_CBR"}),
                          .msg            ("An illegal command was issued when the memory was in AUTO REFRESH state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_SFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_SELF_REFRESH))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_SFR"}),
                          .msg            ("An illegal command was issued when the memory was in SELF_REFRESH state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_COMMAND_NOP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_NOP))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_COMMAND_NOP"}),
                          .msg            ("An illegal command was issued when the bank was in NOP state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_RD_BURST_8B_INTERRUPTED_AT_6B: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_rd_burst_interrupted_at_6b_boundary === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_RD_BURST_8B_INTERRUPTED_AT_6B"}),
                          .msg            ("A read burst of length 8 from a bank was interrupted at a 6-bit boundary by a command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_WR_BURST_8B_INTERRUPTED_AT_6B: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_wr_burst_interrupted_at_6b_boundary === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_WR_BURST_8B_INTERRUPTED_AT_6B"}),
                          .msg            ("A write burst of length 8 to a bank was interrupted at a 6-bit boundary by a command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_READA_BURST_8B_INTERRUPTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_rda_interruption === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_READA_BURST_8B_INTERRUPTED"}),
                          .msg            ("A read burst of length 8 from a bank with autoprecharge enabled was interrupted by a command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_WRITEA_BURST_8B_INTERRUPTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_wra_interruption === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_WRITEA_BURST_8B_INTERRUPTED"}),
                          .msg            ("A write burst of length 8 to a bank with autoprecharge enabled was interrupted by a command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_RD_BURST_8B_INTERRUPTION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_8b_rd_burst_interruption === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_RD_BURST_8B_INTERRUPTION"}),
                          .msg            ("A read burst of length 8 from a bank was interrupted at 4-bit boundary by a non Read or Read with Autoprecharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_WR_BURST_8B_INTERRUPTION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_8b_wr_burst_interruption === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_WR_BURST_8B_INTERRUPTION"}),
                          .msg            ("A Write burst of length 8 to a bank was interrupted at 4-bit boundary by a non Write or Write with Autoprecharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CKE_DRIVEN_LOW: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (cke_driven_low_illegal === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CKE_DRIVEN_LOW"}),
                          .msg            ("CKE deasserted while an operation was in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TXP_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXP_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXP_VIOLATION"}),
                          .msg            ("The command issued violates the tXP timing between a PRECHARGE POWER DOWN exit and a NON-READ command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TXARD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXARD_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXARD_VIOLATION"}),
                          .msg            ("The command issued violates the tXARD timing between Exit ACTIVE POWER DOWN with fast exit and a READ command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TXARDS_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXARDS_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXARDS_VIOLATION"}),
                          .msg            ("The command issued violates the tXARDS timing between Exit ACTIVE POWER DOWN with slow exit and a READ command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_BURST_ABORTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 &&
                           (z_rd_burst_in_progress === 1'b1 ||
                           z_wr_burst_in_progress === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_BURST_ABORTED_N"}),
                          .msg            ("A read or write burst was aborted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRC_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tRC_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRC_VIOLATION"}),
                          .msg            ("The command issued violates the tRC timing between an activation command and another activation command issued to the same bank."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_READ_AP_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && timing_for_active_after_read_ap_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_READ_AP_VIOLATION"}),
                          .msg            ("The command issued violates the timing between read with auto precharge and activation command issued to the same bank."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TMRD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tMRD_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TMRD_VIOLATION"}),
                          .msg            ("The command issued violates the tMRD timing after a MRS/EMRS command was issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
`ifdef ZI_FOR_SEARCH
`else
        A_DDR2_SDRAM_CLOCK_CHANGE_DURING_NON_PPD_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_change_during_non_ppd_mode_enable),
                          .test_expr ((next_state !== ZI_IDLE_PWR_DOWN &&
                                      clk_changed === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CLOCK_CHANGE_DURING_NON_PPD_MODE"}),
                          .msg            ("Clock frequency has changed while the DDR SDRAM is not in precharge power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CLOCK_CHANGE_DURING_ILLEGAL_CKE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_change_during_illegal_cke_enable),
                          .test_expr ((CKE !== 1'b0 &&
                                       clk_changed === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CLOCK_CHANGE_DURING_ILLEGAL_CKE"}),
                          .msg            ("Clock frequency has changed while CKE is not LOW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CLOCK_FREQUENCY_OUT_OF_RANGE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_frequency_out_of_range_enable),
                          .test_expr (clock_period < CLOCK_PERIOD_MIN ||
                                      clock_period > CLOCK_PERIOD_MAX)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CLOCK_FREQUENCY_OUT_OF_RANGE"}),
                          .msg            ("The clock frequency is out of allowed range in current speed grade of DDR SDRAM."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CKE_CHANGED_DURING_UNSTABLE_CLOCK:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (cke_change_during_clock_change_enable),
                          .test_expr (CKE !== CKE_delayed &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CKE_CHANGED_DURING_UNSTABLE_CLOCK"}),
                          .msg            ("CKE_changed_during_unstable_clock"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_PPD_EXIT_DURING_UNSTABLE_CLOCK:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (ppd_exit_during_unstable_clock_enable),
                          .test_expr (next_state !== ZI_IDLE_PWR_DOWN &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_PPD_EXIT_DURING_UNSTABLE_CLOCK"}),
                          .msg            ("Precharge power down mode exited during an unstable clock"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_DLL_NOT_RESET_AFTER_PPD_EXIT_AFTER_CLOCK_CHANGE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (dll_not_reset_after_ppd_exit_after_clock_change_enable),
                          .test_expr (BYPASS_INIT === 0 && /* (error_code > 0) &&
                                      error_code == NO_DLL_RESET && */
                                      next_state !== ZI_IDLE_PWR_DOWN &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DLL_NOT_RESET_AFTER_PPD_EXIT_AFTER_CLOCK_CHANGE"}),
                          .msg            ("DLL is not reset after precharge power down exit after clock change"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
`endif // ZI_FOR_SEARCH

      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_DDR2_SDRAM_ACTIVATE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (act_without_precharge === 1'b1))));
        M_DDR2_SDRAM_BURST_ABORTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 &&
                           (z_rd_burst_in_progress === 1'b1 ||
                           z_wr_burst_in_progress === 1'b1)))));
        M_DDR2_SDRAM_CKE_LOW: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 && (track_tMRD_counter > 1 ||
                           read_burst_counter > 0 || write_data_period > 0)))));
        M_DDR2_SDRAM_TRCD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRCD_violation === 1'b1))));
        M_DDR2_SDRAM_TRAS_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRAS_violation === 1'b1))));
        M_DDR2_SDRAM_TRP_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRP_violation === 1'b1))));
        M_DDR2_SDRAM_TCCD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tCCD_violation === 1'b1))));
        M_DDR2_SDRAM_TRTW_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTW_violation === 1'b1))));
        M_DDR2_SDRAM_TWTR_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTR_violation === 1'b1))));
        M_DDR2_SDRAM_TRTP_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTP_violation === 1'b1))));
        M_DDR2_SDRAM_TWTP_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTP_violation === 1'b1))));
        M_DDR2_SDRAM_TRTR_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRTR_violation === 1'b1))));
        M_DDR2_SDRAM_TWTW_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tWTW_violation === 1'b1))));
        M_DDR2_SDRAM_TRFC_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0)&&(tRFC_violation === 1'b1)))));
        M_DDR2_SDRAM_TXSNR_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXSNR_violation === 1'b1))));
        M_DDR2_SDRAM_TXSRD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXSRD_violation === 1'b1))));
        M_DDR2_SDRAM_WRITE_TO_IDLE_BANK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (write_cmd_without_activation === 1'b1))));
        M_DDR2_SDRAM_READ_TO_IDLE_BANK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (read_cmd_without_activation === 1'b1))));
        M_DDR2_SDRAM_PRECHARGE_TO_IDLE_BANK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_PRECHARGE_TO_IDLE_BANK === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (precharge_issued_to_idle_bank === 1'b1 &&
                           init_sequence_done === 1'b1))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_IDLE))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_PRE_ALL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_PRECHARGE_ALL))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_PRE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_PRECHARGE))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_MRS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_MODE_REG_SET))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_EMRS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_EX_MODE_REG_SET))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_ACTIVATE_BANK))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_WRITE))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_WRITE_AP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_WRITE_AUTO_PRECHARGE))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_READ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_READ))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_READ_AP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_READ_AUTO_PRECHARGE))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_ACT_PWR_DN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_ACT_PWR_DOWN))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_IDLE_PWR_DN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_IDLE_PWR_DOWN))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_CBR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_CBR_REFRESH))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_SFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) &&
                           (present_state === ZI_SELF_REFRESH))));
        M_DDR2_SDRAM_ILLEGAL_COMMAND_NOP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_command) && (present_state === ZI_NOP))));
        M_DDR2_SDRAM_RD_BURST_8B_INTERRUPTED_AT_6B: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_rd_burst_interrupted_at_6b_boundary === 1'b1))));
        M_DDR2_SDRAM_WR_BURST_8B_INTERRUPTED_AT_6B: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_wr_burst_interrupted_at_6b_boundary === 1'b1))));
        M_DDR2_SDRAM_READA_BURST_8B_INTERRUPTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_rda_interruption === 1'b1))));
        M_DDR2_SDRAM_WRITEA_BURST_8B_INTERRUPTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (bl_8_wra_interruption === 1'b1))));
        M_DDR2_SDRAM_ILLEGAL_RD_BURST_8B_INTERRUPTION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_8b_rd_burst_interruption === 1'b1))));
        M_DDR2_SDRAM_ILLEGAL_WR_BURST_8B_INTERRUPTION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (illegal_8b_wr_burst_interruption === 1'b1))));
        M_DDR2_SDRAM_CKE_DRIVEN_LOW: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (cke_driven_low_illegal === 1'b1))));
        M_DDR2_SDRAM_TXP_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXP_violation === 1'b1))));
        M_DDR2_SDRAM_TXARD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXARD_violation === 1'b1))));
        M_DDR2_SDRAM_TXARDS_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tXARDS_violation === 1'b1))));
        M_DDR2_SDRAM_BURST_ABORTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (command[4] === 1'b0 &&
                           (z_rd_burst_in_progress === 1'b1 ||
                           z_wr_burst_in_progress === 1'b1)))));
        M_DDR2_SDRAM_TRC_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tRC_violation === 1'b1)));
        M_DDR2_SDRAM_READ_AP_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && timing_for_active_after_read_ap_violation === 1'b1)));
        M_DDR2_SDRAM_TMRD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n),
                          .reset_n   (!((areset === 1'b0 && reset === 1'b0) ) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tMRD_violation === 1'b1)));
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


















































`endif //ifdef QVL_ASSERT_ON
