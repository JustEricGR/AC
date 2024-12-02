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
  parameter QVL_MSG = "QVL_DDR2_SDRAM_VIOLATION : ";

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// assert only checks

        A_DDR2_SDRAM_CONSTRAINTS_MODE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           constraints_mode > 'd1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CONSTRAINTS_MODE"}),
                          .msg            ("Constraints_Mode parameter should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_CONTROLLER_SIDE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           controller_side > 'd1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CONTROLLER_SIDE"}),
                          .msg            ("CONTROLLER_SIDE parameter should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_DLL_TRACKING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           perform_dll_tracking > 'd1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DLL_TRACKING"}),
                          .msg            ("DLL_TRACKING_ENABLE parameter should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_DATA_CONFIG: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((( (ZI_DDR2_SDRAM_2_0 === 1)) && ((areset === 1'b0 &&
                           reset === 1'b0 && parameter_checks_active === 1'b1)
                           && (~(data_width === 'd4 || data_width === 'd8 ||
                           data_width === 'd16)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DATA_CONFIG"}),
                          .msg            ("DATA_BUS_WIDTH parameter should be either 4, 8 or 16."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_ROW_ADDRESS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           row_addr_width < 'd12)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ROW_ADDRESS"}),
                          .msg            ("ROW_ADDRESS_WIDTH parameter should not be less than the minimum limit of 12."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_DATA_WIDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((( (ZI_DDR2_SDRAM_2_0 === 0)) && ((areset === 1'b0 &&
                           reset === 1'b0 && parameter_checks_active === 1'b1)
                           && data_width < 'd4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DATA_WIDTH"}),
                          .msg            ("DATA_BUS_WIDTH parameter should not be less than the minimum limit of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRAS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           tras_value < 'd6)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRAS"}),
                          .msg            ("TRAS timing parameter should not be less than the minimum limit of 6."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRCD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           trcd_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRCD"}),
                          .msg            ("TRCD timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           trp_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRP"}),
                          .msg            ("TRP timing parameter should not  be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           trrd_value < 'd1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRRD"}),
                          .msg            ("TRRD timing parameter should not be less than the minimum limit of 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TCCD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           tccd_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TCCD"}),
                          .msg            ("TCCD timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRTW: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           trtw_value < 'd4)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRTW"}),
                          .msg            ("TRTW timing parameter should not be less than the minimum limit of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TWTR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           twtr_value < 'd1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TWTR"}),
                          .msg            ("TWTR timing parameter should not be less than the minimum limit of 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TWR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           twr_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TWR"}),
                          .msg            ("TWR timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TRFC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           trfc_value < 'd9)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRFC"}),
                          .msg            ("TRFC timing parameter should not be less than the minimum limit of 9."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TXSNR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           txsnr_value < 'd10)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXSNR"}),
                          .msg            ("TXSNR timing parameter should not be less than the minimum limit of 10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TXSRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           txsrd_value < 'd200)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXSRD"}),
                          .msg            ("TXSRD timing parameter should not be less than the minimum limit of 200."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TMRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           tmrd_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TMRD"}),
                          .msg            ("TMRD timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TXP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           txp_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXP"}),
                          .msg            ("TXP timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_DDR2_SDRAM_TXARD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 &&
                           parameter_checks_active === 1'b1) &&
                           txard_value < 'd2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TXARD"}),
                          .msg            ("TXARD timing parameter should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

// Checks with QVL_PROPERTY_TYPE

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_DDR2_SDRAM_DLL_NOT_RESET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0 && DLL_TRACKING_ENABLE === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (dll_not_reset_before_active === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DLL_NOT_RESET"}),
                          .msg            ("DLL was not reset prior to first activation command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TRRD_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRRD_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TRRD_VIOLATION"}),
                          .msg            ("The command issued violates the tRRD timing between activation commands to different banks."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_MRS_PRECHARGE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (mrs_during_non_precharge === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_MRS_PRECHARGE"}),
                          .msg            ("A mode register set command was issued when one or more banks were not in precharge state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_AUTO_REFRESH_PRECHARGE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (auto_during_non_precharge === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_AUTO_REFRESH_PRECHARGE"}),
                          .msg            ("An auto refresh command was issued when one or more banks were not in precharge state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_SELF_REFRESH_PRECHARGE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (selfref_during_non_precharge === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_SELF_REFRESH_PRECHARGE"}),
                          .msg            ("A self refresh command was issued when one or more banks were not in precharge state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_INSUFFICIENT_AUTO_REFRESH_ACTIVATE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (insufficient_autorefs_before_active === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_INSUFFICIENT_AUTO_REFRESH_ACTIVATE"}),
                          .msg            ("Sufficient number (2) of auto refresh commands were not issued prior to the first activation command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_MODE_REGISTER_NOT_SET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (modereg_not_set_before_active === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_MODE_REGISTER_NOT_SET"}),
                          .msg            ("Mode register was not programmed prior to the first activation command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CAS_LATENCY_INVALID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (cas_latency_invalid === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CAS_LATENCY_INVALID"}),
                          .msg            ("Invalid CAS latency value was programmed in the mode register during MRS command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CAS_LATENCY_INVALID_BYPASS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (cas_latency_invalid_bypass === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CAS_LATENCY_INVALID_BYPASS"}),
                          .msg            ("The CAS latency field of the input mode register is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (additive_latency_invalid === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID"}),
                          .msg            ("Invalid Additive latency value was programmed in the extended mode register during EMRS command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID_BYPASS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (additive_latency_invalid_bypass === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID_BYPASS"}),
                          .msg            ("The additive latency field of the input extended mode register is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_INCORRECT_COMMAND_BEFORE_MRS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (illegal_cmd_before_mrs === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_INCORRECT_COMMAND_BEFORE_MRS"}),
                          .msg            ("An invalid command was issued before programming the mode register (only NOP, DESELECT and PRECHARGE are valid at this point)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TDLL_VIOLATION_AFTER_DLL_RESET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (tdll_reset_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TDLL_VIOLATION_AFTER_DLL_RESET"}),
                          .msg            ("A Read or Read with Autoprecharge command was issued before 200 clock cycles after DLL reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_EMRS_PRECHARGE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (emrs_during_non_precharge === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_EMRS_PRECHARGE"}),
                          .msg            ("An extended mode register set command was issued when one or more banks were not in precharge state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_EMRS_3_BEFORE_EMRS_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (emrs_2_not_issued_before_emrs_3 === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_EMRS_3_BEFORE_EMRS_2"}),
                          .msg            ("An EMRS(3) command was issued prior to an EMRS(2) command during initialization sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_EMRS_BEFORE_EMRS_3: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (emrs_3_not_issued_before_emrs === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_EMRS_BEFORE_EMRS_3"}),
                          .msg            ("An EMRS command to enable DLL was issued prior to an EMRS(3) during initialization sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_SEQUENTIAL_ACTIVATION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (sequential_activation_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_SEQUENTIAL_ACTIVATION_VIOLATION"}),
                          .msg            ("The number of activation commands in a rolling window of (4*tRRD + 2tCK) exceeded 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_TCKE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tCKE_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_TCKE_VIOLATION"}),
                          .msg            ("CKE signal should be held at a valid input level for atleast tCKE clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS1:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_reserved_states_in_emrs1_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS1"}),
                          .msg            ("Bits BA2 and A13-A15 are reserved for future use and they must be set to 0 when programming EMRS1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_OCD_VALUE_FOR_DDR2_800_EMRS1:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && 
                           illegal_ocd_value_for_ddr2_800_emrs1_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_OCD_VALUE_FOR_DDR2_800_EMRS1"}),
                          .msg            ("It is mandatory to to set both the bits A2 and A6 as HIGH while programing the EMRS1 for DDR SDRAM speed grade 800."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS2:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && 
                           illegal_reserved_states_in_emrs2_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS2"}),
                          .msg            ("Bits BA2 and A13-A15 are reserved for future use and they must be set to 0 when programming EMRS2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_HTSRR_BIT_STATE_IN_EMRS2:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && 
                           illegal_htsrr_bit_states_in_emrs2_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_HTSRR_BIT_STATE_IN_EMRS2"}),
                          .msg            ("When high temperature self refresh is not supported the respective bit in EMRS2 programming should be set to 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_PASR_BIT_STATES_IN_EMRS2:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && 
                           illegal_pasr_bit_states_in_emrs2_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_PASR_BIT_STATES_IN_EMRS2"}),
                          .msg            ("When partial self refresh is not supported the pasr bits should always be set to 0s to represent full page access during EMRS2 programming"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_DCC_BIT_STATE_IN_EMRS2:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && 
                           illegal_dcc_bit_states_in_emrs2_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_DCC_BIT_STATE_IN_EMRS2"}),
                          .msg            ("When duty cycle control is not supported the relevant bit should always be set to 0 during EMRS2 programming."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS3:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_reserved_states_in_emrs3_programming === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS3"}),
                          .msg            ("Bits BA2 and A0-A15 are reserved for future use and they must be set to 0 when programming EMRS3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ODT_VIOLATION_DURING_DLL_STABILIZATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       odt_violation_during_dll_stabilization === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ODT_VIOLATION_DURING_DLL_STABILIZATION"}),
                          .msg            ("ODT should be LOW while dll is within its lock period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

        A_DDR2_SDRAM_FIRST_EMRS_NOT_ISSUED_WITH_OCD_EXIT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                      first_emrs_not_issued_with_ocd_exit === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_FIRST_EMRS_NOT_ISSUED_WITH_OCD_EXIT"}),
                          .msg            ("First EMRS command during initialisation should be issued with OCD exit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

        A_DDR2_SDRAM_EMRS2_IS_NOT_ISSUED_AFTER_FIRST_PRECHARGE_ALL:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       emrs2_is_not_issued_after_first_precharge_all === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_EMRS2_IS_NOT_ISSUED_AFTER_FIRST_PRECHARGE_ALL"}),
                          .msg            ("emrs2_is_not_issued_after_first_precharge_all."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_OCD_DEFAULT_CALIBRATION_NOT_SET_AFTER_SECOND_MRS:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&  
                                      ocd_default_calibration_not_set_after_second_mrs === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_OCD_DEFAULT_CALIBRATION_NOT_SET_AFTER_SECOND_MRS"}),
                          .msg            ("ocd_default_calibration_not_set_after_second_mrs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_INVALID_BL_BEFORE_ENTERING_OCD_CALIBRATION_EXIT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       invalid_bl_before_entering_ocd_calibration_exit === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_INVALID_BL_BEFORE_ENTERING_OCD_CALIBRATION_EXIT"}),
                          .msg            ("invalid_bl_before_entering_ocd_calibration_exit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_OCD_DRIVE0_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_drive0_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_OCD_DRIVE0_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE"}),
                          .msg            ("ocd_drive0_mode_not_followed_by_ocd_cali_exit_mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_OCD_DRIVE1_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_drive1_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_OCD_DRIVE1_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE"}),
                          .msg            ("ocd_drive1_mode_not_followed_by_ocd_cali_exit_mode."),
                          .severity_level (QVL_ERROR), 
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_OCD_ADJUST_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_adjust_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_OCD_ADJUST_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE"}),
                          .msg            ("ocd_adjust_mode_not_followed_by_ocd_cali_exit_mode."),
                          .severity_level (QVL_ERROR), 
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE0_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       illegal_dq_dqs_in_ocd_drive0_mode === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE0_MODE"}),
                          .msg            ("illegal_dq_dqs_in_ocd_drive0_mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE1_MODE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       illegal_dq_dqs_in_ocd_drive1_mode === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE1_MODE"}),
                          .msg            ("illegal_dq_dqs_in_ocd_drive1_mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));

      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_DDR2_SDRAM_DLL_NOT_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0 && DLL_TRACKING_ENABLE === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (dll_not_reset_before_active === 1'b1))));
        M_DDR2_SDRAM_TRRD_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (tRRD_violation === 1'b1))));
        M_DDR2_SDRAM_MRS_PRECHARGE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (mrs_during_non_precharge === 1'b1))));
        M_DDR2_SDRAM_AUTO_REFRESH_PRECHARGE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (auto_during_non_precharge === 1'b1))));
        M_DDR2_SDRAM_SELF_REFRESH_PRECHARGE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (selfref_during_non_precharge === 1'b1))));
        M_DDR2_SDRAM_INSUFFICIENT_AUTO_REFRESH_ACTIVATE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (insufficient_autorefs_before_active === 1'b1))));
        M_DDR2_SDRAM_MODE_REGISTER_NOT_SET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (modereg_not_set_before_active === 1'b1))));
        M_DDR2_SDRAM_CAS_LATENCY_INVALID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (cas_latency_invalid === 1'b1))));
        M_DDR2_SDRAM_CAS_LATENCY_INVALID_BYPASS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (cas_latency_invalid_bypass === 1'b1))));
        M_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (additive_latency_invalid === 1'b1))));
        M_DDR2_SDRAM_ADDITIVE_LATENCY_INVALID_BYPASS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 1) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (additive_latency_invalid_bypass === 1'b1))));
        M_DDR2_SDRAM_INCORRECT_COMMAND_BEFORE_MRS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (illegal_cmd_before_mrs === 1'b1))));
        M_DDR2_SDRAM_TDLL_VIOLATION_AFTER_DLL_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (tdll_reset_violation === 1'b1))));
        M_DDR2_SDRAM_EMRS_PRECHARGE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (emrs_during_non_precharge === 1'b1))));
        M_DDR2_SDRAM_EMRS_3_BEFORE_EMRS_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (emrs_2_not_issued_before_emrs_3 === 1'b1))));
        M_DDR2_SDRAM_EMRS_BEFORE_EMRS_3: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((BYPASS_INIT === 0) &&
                           (areset === 1'b0 && reset === 1'b0) &&
                           (emrs_3_not_issued_before_emrs === 1'b1))));
        M_DDR2_SDRAM_SEQUENTIAL_ACTIVATION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (sequential_activation_violation === 1'b1))));
        M_DDR2_SDRAM_TCKE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) && tCKE_violation === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS1:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_reserved_states_in_emrs1_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_OCD_VALUE_FOR_DDR2_800_EMRS1:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_ocd_value_for_ddr2_800_emrs1_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS2:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_reserved_states_in_emrs2_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_HTSRR_BIT_STATE_IN_EMRS2:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_htsrr_bit_states_in_emrs2_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_PASR_BIT_STATES_IN_EMRS2:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_pasr_bit_states_in_emrs2_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_DCC_BIT_STATE_IN_EMRS2:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_dcc_bit_states_in_emrs2_programming === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_RESERVED_STATES_IN_EMRS3:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           illegal_reserved_states_in_emrs3_programming === 1'b1)));
       A_DDR2_SDRAM_ODT_VIOLATION_DURING_DLL_STABILIZATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       odt_violation_during_dll_stabilization === 1'b1)));
        A_DDR2_SDRAM_FIRST_EMRS_NOT_ISSUED_WITH_OCD_EXIT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                      first_emrs_not_issued_with_ocd_exit === 1'b1)));
        A_DDR2_SDRAM_EMRS2_IS_NOT_ISSUED_AFTER_FIRST_PRECHARGE_ALL:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       emrs2_is_not_issued_after_first_precharge_all === 1'b1)));
        A_DDR2_SDRAM_OCD_DEFAULT_CALIBRATION_NOT_SET_AFTER_SECOND_MRS:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                      ocd_default_calibration_not_set_after_second_mrs === 1'b1)));
        A_DDR2_SDRAM_INVALID_BL_BEFORE_ENTERING_OCD_CALIBRATION_EXIT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       invalid_bl_before_entering_ocd_calibration_exit === 1'b1)));
        A_DDR2_SDRAM_OCD_DRIVE0_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_drive0_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)));
        A_DDR2_SDRAM_OCD_DRIVE1_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_drive1_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)));
        A_DDR2_SDRAM_OCD_ADJUST_MODE_NOT_FOLLOWED_BY_OCD_CALI_EXIT_MODE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       ocd_adjust_mode_not_followed_by_ocd_cali_exit_mode === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE0_MODE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       illegal_dq_dqs_in_ocd_drive0_mode === 1'b1)));
        A_DDR2_SDRAM_ILLEGAL_DQ_DQS_IN_OCD_DRIVE1_MODE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (ck),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                                       illegal_dq_dqs_in_ocd_drive1_mode === 1'b1)));
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




`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

//----------------------------------------
////********** known_driven ***********
//----------------------------------------

// assert only checks

        A_DDR2_SDRAM_CKE_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (cke),
                          .qualifier ((z_valid_clock_detected === 1'b1) )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CKE_LEVEL"}),
                          .msg            ("cke is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

// Checks with QVL_PROPERTY_TYPE

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_DDR2_SDRAM_CS_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (cs_n),
                          .qualifier ((cke === 1'b1 || (r_cke === 1'b1 && cke === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CS_LEVEL"}),
                          .msg            ("cs_n is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_RAS_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ras_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_RAS_LEVEL"}),
                          .msg            ("ras_n is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_CAS_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (cas_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_CAS_LEVEL"}),
                          .msg            ("cas_n is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_WE_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (we_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_WE_LEVEL"}),
                          .msg            ("we_n is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_DM_RDQS_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (dm_rdqs),
                          .qualifier ((cke === 1'b1 && write_burst === 1'b1 &&
                           rdqs_enable === 1'b0 && DATA_BUS_WIDTH === 8))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_DM_RDQS_LEVEL"}),
                          .msg            ("dm_rdqs is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_LDM_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ldm),
                          .qualifier ((cke === 1'b1 && write_burst === 1'b1 &&
                           DATA_BUS_WIDTH === 16))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_LDM_LEVEL"}),
                          .msg            ("ldm is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_UDM_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (udm),
                          .qualifier ((cke === 1'b1 && write_burst === 1'b1 &&
                           DATA_BUS_WIDTH === 16))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_UDM_LEVEL"}),
                          .msg            ("udm is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_ADDRESS_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (a),
                          .qualifier ((command === 6'b110000 || command === 6'b110011 ||
                           command === 6'b110101 || command === 6'b110100))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_ADDRESS_LEVEL"}),
                          .msg            ("Address lines are not driven to valid levels."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR2_SDRAM_BANK_LEVEL: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ba),
                          .qualifier ((command === 6'b110000 || command === 6'b110011 ||
                           command === 6'b110101 || command === 6'b110100))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR2_SDRAM_BANK_LEVEL"}),
                          .msg            ("Bank Address lines are not driven to valid levels."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_DDR2_SDRAM_CS_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (cs_n),
                          .qualifier ((cke === 1'b1 || (r_cke === 1'b1 && cke === 1'b0)))));
        M_DDR2_SDRAM_RAS_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ras_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))));
        M_DDR2_SDRAM_CAS_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (cas_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))));
        M_DDR2_SDRAM_WE_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (we_n),
                          .qualifier ((cke === 1'b1 && !cs_n === 1'b1))));
        M_DDR2_SDRAM_DM_RDQS_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (dm_rdqs),
                          .qualifier (cke === 1'b1 && write_burst === 1'b1 &&
                           rdqs_enable === 1'b0 && DATA_BUS_WIDTH === 8)));
        M_DDR2_SDRAM_LDM_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ldm),
                          .qualifier (cke === 1'b1 && write_burst === 1'b1 &&
                           DATA_BUS_WIDTH === 16)));
        M_DDR2_SDRAM_UDM_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (udm),
                          .qualifier (cke === 1'b1 && write_burst === 1'b1 &&
                           DATA_BUS_WIDTH === 16)));
        M_DDR2_SDRAM_ADDRESS_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (a),
                          .qualifier (command === 6'b110000 || command === 6'b110011 || command === 6'b110101 || command === 6'b110100)));
        M_DDR2_SDRAM_BANK_LEVEL: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (ck ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (ba),
                          .qualifier (command === 6'b110000 || command === 6'b110011 ||command === 6'b110101 || command === 6'b110100) ));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate
`endif // QVL_XCHECK_OFF

`endif //ifdef QVL_ASSERT_ON
