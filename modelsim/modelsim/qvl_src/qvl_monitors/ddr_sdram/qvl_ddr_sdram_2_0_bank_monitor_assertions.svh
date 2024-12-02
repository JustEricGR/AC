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
//*****************************************************************************

`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON 

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = ZI_CONSTRAINTS_MODE_MEMORY_SIDE; 
                                      // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;
  parameter QVL_MSG = "QVL_DDR_SDRAM_BANK_VIOLATION : ";

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

//----------------------------------------
//********** fire ***********
//----------------------------------------

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_DDR_SDRAM_con_auto_precharge_min_delay_violation: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (((other_bank_write_cmd == 1'b1 && 
                           writea_counter != 0) ||
                           (other_bank_read_cmd == 1'b1 && reada_counter != 0)
                           || ((reada_cmd == 1'b1 || writea_cmd == 1'b1) &&
                           ((any_bank_active_cmd && !active_cmd) || 
                           other_bank_pre_cmd == 1'b1))) && 
                           CON_AUTO_PRECHARGE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_con_auto_precharge_min_delay_violation"}),
                          .msg            ("Concurrent Auto Precharge minimum delay violation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_idle: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0) &&
                           (error_code > 0)) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_IDLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_idle"}),
                          .msg            ("Illegal command is issued when the bank is in IDLE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_pall: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_PALL)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_pall"}),
                          .msg            ("Illegal command is issued when all the banks are in PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_mrs: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_MRS)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_mrs"}),
                          .msg            ("Illegal command is issued when all the banks are in MODE REGISTER SET state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_emrs: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_EMRS)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_emrs"}),
                          .msg            ("Illegal command is issued when all the banks are in EXTENDENDED MODE REGISTER SET state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_aref: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_AREF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_aref"}),
                          .msg            ("Illegal command is issued when all the banks are in AUTO REFRESH state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_active: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_ACTIVE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_active"}),
                          .msg            ("Illegal command is issued when the bank is in ACTIVE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_write: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_WRITE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_write"}),
                          .msg            ("Illegal command is issued when the bank is in WRITE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_writea: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_WRITEA)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_writea"}),
                          .msg            ("Illegal command is issued when the bank is in WRITE WITH AUTOPRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_read: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_READ))
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_read"}),
                          .msg            ("Illegal command is issued when the bank is in READ state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_reada: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_READA)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_reada"}),
                          .msg            ("Illegal command is issued when the bank is in READ WITH AUTOPRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_illegal_command_pre: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_PRE))
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_illegal_command_pre"}),
                          .msg            ("Illegal command is issued when the bank is in PRECHARGE state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_why_precharge_an_idle_bank: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (why_precharge_an_idle_bank_enable === 1'b1 && 
                           end_of_initialization === 1'b1) && 
                           (error_code == WHY_PRECHARGE_AN_IDLE_BANK)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_why_precharge_an_idle_bank"}),
                          .msg            ("A precharge command is issued while the bank is already in a precharged state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tRC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRC) && 
                           (violates_tRC_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRC"}),
                          .msg            ("A command which violates RAS cycle timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tRP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRP) && 
                           (violates_tRP_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRP"}),
                          .msg            ("A command which violates RAS precharge timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tRCD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRCD) && 
                           (violates_tRCD_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRCD"}),
                          .msg            ("A command which violates RAS to CAS delay timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tRAS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRAS) && 
                           (violates_tRAS_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRAS"}),
                          .msg            ("A command which violates RAS timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tMRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TMRD) && 
                           (violates_tMRD_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tMRD"}),
                          .msg            ("A command which violates tMRD timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tRFC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRFC) && 
                           (violates_tRFC_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRFC"}),
                          .msg            ("A command which violates tRFC timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tXSNR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TXSNR) && 
                           (violates_tXSNR_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tXSNR"}),
                          .msg            ("A command which violates tXSNR timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tXSRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TXSRD) && 
                           (violates_tXSRD_enable === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tXSRD"}),
                          .msg            ("A read/read with autoprecharge command which violates tXSRD timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_no_auto_refresh: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == NO_AUTO_REFRESH) && 
                           (no_auto_refresh_enable === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_no_auto_refresh"}),
                          .msg            ("Atleast two auto refresh commands should be issued after reset and before active command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_no_dll_reset: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == NO_DLL_RESET) && 
                           (no_dll_reset_enable === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_no_dll_reset"}),
                          .msg            ("DLL is not reset after it is enabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tDLL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == VIOLATES_TDLL) && 
                           (violates_tdll_enable === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tDLL"}),
                          .msg            ("Atleast 200 clocks delay should be given between the DLL enable and a read/read with autoprecharge command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_CKE_signal_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((next_state !== SELF_REFRESH && 
                           next_state !== IDLE_POWER_DOWN && 
                           next_state !== ACTIVE_POWER_DOWN && 
                           CKE === 1'b0 && 
                           CKE_low_for_non_selfrefresh_or_powerdown_enable === 1'b1)
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_CKE_signal_P"}),
                          .msg            ("CKE is low when control signals and/or the monitor state machine are not pointing to SELF REFRESH or POWER DOWN mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_self_ref_or_power_down_exit: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((current_state === SELF_REFRESH || 
                           current_state === ACTIVE_POWER_DOWN || 
                           current_state === IDLE_POWER_DOWN) && 
                           CKE === 1'b1 && 
                           !(power_down_exit === 1'b1 || 
                           self_refresh_exit === 1'b1) && 
                           !(nop_cmd === 1'b1 || dsel_cmd === 1'b1) &&
                           invalid_self_refresh_or_power_down_exit_enable === 1'b1) 
                           )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_self_ref_or_power_down_exit"}),
                          .msg            ("Only NOP or DSEL command should be issued during SELF REFRESH or POWER DOWN exit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_CKE_signal_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (next_state !== SELF_REFRESH && 
                           next_state !== IDLE_POWER_DOWN && 
                           next_state !== ACTIVE_POWER_DOWN && 
                           CKE === 1'b0 &&
                           CKE_low_for_non_selfrefresh_or_powerdown_enable === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_CKE_signal_N"}),
                          .msg            ("CKE is low when control signals and/or the monitor state machine are not pointing to SELF REFRESH or POWER DOWN mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
//BIPS

`ifdef ZI_FOR_SEARCH
`else
        A_DDR_SDRAM_clock_change_during_non_ppd_mode:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_change_during_non_ppd_mode_enable),
                          .test_expr ((next_state !== IDLE_POWER_DOWN &&
                                      clk_changed === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_clock_change_during_non_ppd_mode"}),
                          .msg            ("Clock frequency has changed while the DDR SDRAM is not in precharge power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_clock_change_during_illegal_cke:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_change_during_illegal_cke_enable),
                          .test_expr ((CKE !== 1'b0 &&
                                       clk_changed === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_clock_change_during_illegal_cke"}),
                          .msg            ("Clock frequency has changed while CKE is not LOW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_violates_tCLK:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (violates_tCLK_enable),
                          .test_expr ((error_code > 0) &&
                                      (error_code == VIOLATES_TRC))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tCLK"}),
                          .msg            ("A command which violates TCLK cycle timing is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
         A_DDR_SDRAM_clock_frequency_out_of_range:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (clock_frequency_out_of_range_enable),
                          .test_expr (clock_period < CLOCK_PERIOD_MIN ||
                                      clock_period > CLOCK_PERIOD_MAX)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_clock_frequency_out_of_range"}),
                          .msg            ("The clock frequency is out of allowed range in current speed grade of DDR SDRAM."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
          A_DDR_SDRAM_CKE_changed_during_unstable_clock:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (cke_change_during_clock_change_enable),
                          .test_expr (CKE !== CKE_delayed &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_CKE_changed_during_unstable_clock"}),
                          .msg            ("CKE_changed_during_unstable_clock"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
         A_DDR_SDRAM_ppd_exit_during_unstable_clock:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (ppd_exit_during_unstable_clock_enable),
                          .test_expr (next_state !== IDLE_POWER_DOWN &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_ppd_exit_during_unstable_clock"}),
                          .msg            ("Precharge power down mode exited during an unstable clock"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_dll_not_reset_after_ppd_exit_after_clock_change:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (dll_not_reset_after_ppd_exit_after_clock_change_enable),
                          .test_expr (BYPASS_INIT === 0 && (error_code > 0) &&
                                      error_code == NO_DLL_RESET &&
                                      next_state !== IDLE_POWER_DOWN &&
                                      clk_changed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_dll_not_reset_after_ppd_exit_after_clock_change"}),
                          .msg            ("DLL is not reset after precharge power down exit after clock change"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
`endif
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_DDR_SDRAM_con_auto_precharge_min_delay_violation: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (((other_bank_write_cmd == 1'b1 && 
                           writea_counter != 0) ||
                           (other_bank_read_cmd == 1'b1 && reada_counter != 0)
                           || ((reada_cmd == 1'b1 || writea_cmd == 1'b1) &&
                           ((any_bank_active_cmd && !active_cmd) || 
                           other_bank_pre_cmd == 1'b1))) && 
                           CON_AUTO_PRECHARGE == 1)))));
        M_DDR_SDRAM_illegal_command_idle: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0) &&
                           (error_code > 0)) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_IDLE)))));
        M_DDR_SDRAM_illegal_command_pall: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_PALL)))));
        M_DDR_SDRAM_illegal_command_mrs: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_MRS)))));
        M_DDR_SDRAM_illegal_command_emrs: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_EMRS)))));
        M_DDR_SDRAM_illegal_command_aref: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_AREF)))));
        M_DDR_SDRAM_illegal_command_active: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_ACTIVE)))));
        M_DDR_SDRAM_illegal_command_write: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_WRITE)))));
        M_DDR_SDRAM_illegal_command_writea: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_WRITEA)))));
        M_DDR_SDRAM_illegal_command_read: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_READ))
                           )));
        M_DDR_SDRAM_illegal_command_reada: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_READA)))));
        M_DDR_SDRAM_illegal_command_pre: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) &&
                           (illegal_command_enable === 1'b1) && 
                           (error_code == ILLEGAL_COMMAND_PRE))
                           )));
        M_DDR_SDRAM_why_precharge_an_idle_bank: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) && 
                           (error_code > 0) && 
                           (why_precharge_an_idle_bank_enable === 1'b1 && 
                           end_of_initialization === 1'b1) && 
                           (error_code == WHY_PRECHARGE_AN_IDLE_BANK)))));
        M_DDR_SDRAM_violates_tRC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRC) && 
                           (violates_tRC_enable === 1'b1))));
        M_DDR_SDRAM_violates_tRP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRP) && 
                           (violates_tRP_enable === 1'b1))));
        M_DDR_SDRAM_violates_tRCD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRCD) && 
                           (violates_tRCD_enable === 1'b1))));
        M_DDR_SDRAM_violates_tRAS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRAS) && 
                           (violates_tRAS_enable === 1'b1))));
        M_DDR_SDRAM_violates_tMRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TMRD) && 
                           (violates_tMRD_enable === 1'b1))));
        M_DDR_SDRAM_violates_tRFC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TRFC) && 
                           (violates_tRFC_enable === 1'b1))));
        M_DDR_SDRAM_violates_tXSNR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TXSNR) && 
                           (violates_tXSNR_enable === 1'b1))));
        M_DDR_SDRAM_violates_tXSRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((error_code > 0) && 
                           (error_code == VIOLATES_TXSRD) && 
                           (violates_tXSRD_enable === 1'b1))));
        M_DDR_SDRAM_no_auto_refresh: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == NO_AUTO_REFRESH) && 
                           (no_auto_refresh_enable === 1'b1)))));
        M_DDR_SDRAM_no_dll_reset: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == NO_DLL_RESET) && 
                           (no_dll_reset_enable === 1'b1)))));
        M_DDR_SDRAM_violates_tDLL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT === 0) && (error_code > 0) && 
                           (error_code == VIOLATES_TDLL) && 
                           (violates_tdll_enable === 1'b1)))));
        M_DDR_SDRAM_violates_CKE_signal_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((next_state !== SELF_REFRESH && 
                           next_state !== IDLE_POWER_DOWN && 
                           next_state !== ACTIVE_POWER_DOWN && 
                           CKE === 1'b0 && 
                           CKE_low_for_non_selfrefresh_or_powerdown_enable === 1'b1)
                           )));
        M_DDR_SDRAM_invalid_self_ref_or_power_down_exit: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((current_state === SELF_REFRESH || 
                           current_state === ACTIVE_POWER_DOWN || 
                           current_state === IDLE_POWER_DOWN) && 
                           CKE === 1'b1 && 
                           !(power_down_exit === 1'b1 || 
                           self_refresh_exit === 1'b1) && 
                           !(nop_cmd === 1'b1 || dsel_cmd === 1'b1) &&
                           invalid_self_refresh_or_power_down_exit_enable === 1'b1) 
                           )));
        M_DDR_SDRAM_violates_CKE_signal_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock_n ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (next_state !== SELF_REFRESH && 
                           next_state !== IDLE_POWER_DOWN && 
                           next_state !== ACTIVE_POWER_DOWN && 
                           CKE === 1'b0 &&
                           CKE_low_for_non_selfrefresh_or_powerdown_enable === 1'b1)))));
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
