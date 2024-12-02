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
  parameter QVL_MSG = "QVL_DDR_SDRAM_VIOLATION : ";

wire DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs = 
                         ((BYPASS_INIT == 0) && (((mrs_cmd === 1'b1 &&
                           A[ADDR_WIDTH-1:7] !== 5'b0 && 
                           A[ADDR_WIDTH-1:7] !== 5'b00010) ||  
                           (extended_mrs_cmd === 1'b1 &&
                           A[ADDR_WIDTH-1:3] !== 9'b0)) && 
                           mrs_emrs_operating_mode_bits_tracking === 1'b1));

wire DDR_SDRAM_invalid_operating_mode = ((BYPASS_INIT == 1) && (an_active_cmd === 1'b1 &&
                           ((mode_register[ADDR_WIDTH-1:7] !== 5'b0 &&
                           mode_register[ADDR_WIDTH-1:7] !== 5'b00010) ||
                           (extended_mode_register[ADDR_WIDTH-1:3] !== 9'b0))
                           && mrs_emrs_operating_mode_bits_tracking === 1'b1));

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_DDR_SDRAM_CKE: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CKE),
                          .qualifier (((z_valid_clock_detected === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_CKE"}),
                          .msg            ("Clock enable, CKE, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_CS_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CS_n),
                          .qualifier (((CKE === 1'b1 ||(CKE_delayed === 1'b1 && 
                           CKE === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_CS_n"}),
                          .msg            ("Chip select, CS_n, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_RAS_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (RAS_n),
                          .qualifier (((CKE === 1'b1 && CS_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_RAS_n"}),
                          .msg            ("Row address strobe, RAS_n, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_CAS_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CAS_n),
                          .qualifier (((CKE === 1'b1 && CS_n === !'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_CAS_n"}),
                          .msg            ("Column adress strobe, CAS_n, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_WE_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (WE_n),
                          .qualifier (((CKE === 1'b1 && CS_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_WE_n"}),
                          .msg            ("Write enable, WE_n, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_DM: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (DM),
                          .qualifier (((CKE === 1'b1 && |data_mask_window_flag === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_DM"}),
                          .msg            ("Data mask, DM, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_ADDRESS: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (A),
                          .qualifier (((mrs_cmd === 1'b1 || extended_mrs_cmd === 1'b1 || all_read_cmds === 1'b1 || 
                           all_write_cmds === 1'b1 || 
                           all_active_cmds === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_ADDRESS"}),
                          .msg            ("Address bus, A, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_BA: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (BA),
                          .qualifier (((all_read_cmds === 1'b1 || 
                           all_write_cmds === 1'b1 || 
                           all_active_cmds === 1'b1 ||
                           (all_pre_cmds === 1'b1 && 
                           z_autoprecharge_enable === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_BA"}),
                          .msg            ("Bank address bus, BA, has a X or Z value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_DDR_SDRAM_CKE: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CKE),
                          .qualifier (((z_valid_clock_detected === 1'b1)))));
        M_DDR_SDRAM_CS_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CS_n),
                          .qualifier ((CKE === 1'b1 ||(CKE_delayed === 1'b1 && 
                           CKE === 1'b0)))));
        M_DDR_SDRAM_RAS_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (RAS_n),
                          .qualifier (((CKE === 1'b1 && CS_n !== 1'b1)))));
        M_DDR_SDRAM_CAS_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (CAS_n),
                          .qualifier (((CKE === 1'b1 && CS_n === !'b1)))));
        M_DDR_SDRAM_WE_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (WE_n),
                          .qualifier (((CKE === 1'b1 && CS_n !== 1'b1)))));
        M_DDR_SDRAM_DM: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (DM),
                          .qualifier (((CKE === 1'b1 && |data_mask_window_flag === 1'b1)))));
        M_DDR_SDRAM_ADDRESS: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (A),
                          .qualifier ((mrs_cmd === 1'b1 || extended_mrs_cmd === 1'b1 || all_read_cmds === 1'b1 || 
                           all_write_cmds === 1'b1 || 
                           all_active_cmds === 1'b1))));
        M_DDR_SDRAM_BA: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .test_expr (BA),
                          .qualifier (all_read_cmds === 1'b1 || 
                           all_write_cmds === 1'b1 || 
                           all_active_cmds === 1'b1 ||
                           (all_pre_cmds === 1'b1 && 
                           z_autoprecharge_enable === 1'b0))));
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




generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_DDR_SDRAM_violates_tRRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (an_active_cmd && !(BA === BA_saved) &&
                           (counter_tRRD > 0) && violates_tRRD === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_violates_tRRD"}),
                          .msg            ("An activate command is issued too quickly after the prior activate command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_incorrect_command_before_mode_reg_set: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT == 0) && 
                           (mode_register_set === 1'b0 && 
                           incorrect_command_before_mode_reg_set === 1'b1) && 
                           (CKE_delayed && (CS_n !== 1'b1) && 
                           !(((RAS_n === 1'b1) &&  (CAS_n === 1'b1) && 
                           (WE_n === 1'b1)) || ((!RAS_n === 1'b1) && 
                           (CAS_n === 1'b1) && (!WE_n === 1'b1)) || 
                           ((!RAS_n === 1'b1) && (!CAS_n === 1'b1) && 
                           (WE_n === 1'b1)) || ((!RAS_n === 1'b1) && 
                           (!CAS_n === 1'b1) && (!WE_n === 1'b1)) ))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_incorrect_command_before_mode_reg_set"}),
                          .msg            ("A command which should not be issued before the mode register set command is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_burst_length_value_in_mode_reg_set: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 0) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_reg[2:0] !== 3'b001) && 
                           (mode_reg[2:0] !== 3'b010) && 
                           (mode_reg[2:0] !== 3'b011) && 
                           (mode_reg[2:0] !== 3'b111)) && 
                           invalid_mode_reg_value === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_burst_length_value_in_mode_reg_set"}),
                          .msg            ("Invalid burst length value during mode register set command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_burst_length: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 1) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_register[2:0] !== 3'b001) && 
                           (mode_register[2:0] !== 3'b010) && 
                           (mode_register[2:0] !== 3'b011) && 
                           (mode_register[2:0] !== 3'b111)) &&
                           invalid_mode_reg_value === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_burst_length"}),
                          .msg            ("The burst length field of the input mode register is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_cas_latency_value_in_mode_reg_set: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 0) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_reg[6:4] !== 3'b010) && 
                           (mode_reg[6:4] !== 3'b011) && 
                           (mode_reg[6:4] !== 3'b101) && 
                           (mode_reg[6:4] !== 3'b110) ) && 
                           (mode_reg[6:4] !==  3'b100) && 
                           invalid_mode_reg_value === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_cas_latency_value_in_mode_reg_set"}),
                          .msg            ("Invalid CAS latency value during mode register set command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_cas_latency: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 1) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_register[6:4] !== 3'b010) && 
                           (mode_register[6:4] !== 3'b011) && 
                           (mode_register[6:4] !== 3'b101) && 
                           (mode_register[6:4] !== 3'b110)) && 
                           (mode_register[6:4] !== 3'b100) && 
                           invalid_mode_reg_value === 1'b1) ))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_cas_latency"}),
                          .msg            ("The CAS latency field of the input mode register is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs) ) )

          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs"}),
                          .msg            ("Invalid operating mode bits are programmed during mode register set or extended mode register set command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_invalid_operating_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (DDR_SDRAM_invalid_operating_mode) ) )  
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_invalid_operating_mode"}),
                          .msg            ("The operating mode field in the mode register or extended mode register input is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_Constraints_Mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_Constraints_Mode != 1) && 
                           (pw_Constraints_Mode != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_Constraints_Mode"}),
                          .msg            ("Constraints_Mode should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_CONTROLLER_SIDE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_CONTROLLER_SIDE != 1) && 
                           (pw_CONTROLLER_SIDE != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_CONTROLLER_SIDE"}),
                          .msg            ("CONTROLLER_SIDE should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_DATA_CONFIG: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_DDR_SDRAM_2_0 === 1)) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((pw_DATA_WIDTH != 4) && (pw_DATA_WIDTH != 8) && 
                           (pw_DATA_WIDTH != 16)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_DATA_CONFIG"}),
                          .msg            ("Data bus width should be either 4, 8 or 16."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_DLL_TRACKING_ENABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_DLL_TRACKING_ENABLE != 1) && 
                           (pw_DLL_TRACKING_ENABLE != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_DLL_TRACKING_ENABLE"}),
                          .msg            ("DLL_TRACKING_ENABLE should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_BYPASS_INIT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_BYPASS_INIT != 1) && (pw_BYPASS_INIT != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_BYPASS_INIT"}),
                          .msg            ("BYPASS_INIT should be either 1 or 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_DM_WIDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_EFFECTIVE_DM_WIDTH < 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_DM_WIDTH"}),
                          .msg            ("Data mask width should not be less than the minimum limit of 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_DATA_WIDTH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_DDR_SDRAM_2_0 === 0)) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((pw_DATA_WIDTH < 3)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_DATA_WIDTH"}),
                          .msg            ("Data bus width should not be less than the minimum limit of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_TWR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((NON_JEDEC == 0)) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tWR < 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_TWR"}),
                          .msg            ("TWR value should not be less than the minimum limit of 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TRC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRC < 4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TRC"}),
                          .msg            ("TRC value should not be less than the minimum limit of 5."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1 ))) &&
                           ((tRC < 8)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRC"}),
                          .msg            ("TRC value should not be less than the minimum limit of 9."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TRAS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRAS < 3))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TRAS"}),
                          .msg            ("TRAS value should not be less than the minimum limit of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRAS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRAS < 5)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRAS"}),
                          .msg            ("TRAS value should not be less than the minimum limit of 6."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TRP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRP < 1 ))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TRP"}),
                          .msg            ("TRP value should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRP < 2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRP"}),
                          .msg            ("TRP value should not be less than the minimum limit of 3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TRCD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRCD < 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TRCD"}),
                          .msg            ("TRCD value should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRCD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRCD < 2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRCD"}),
                          .msg            ("TRCD value should not be less than the minimum limit of 3."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRRD < 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRRD"}),
                          .msg            ("TRRD value should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TMRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((NON_JEDEC == 0)) && 
                           ((areset === 1'b0 &&
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tMRD < 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TMRD"}),
                          .msg            ("TMRD value should not be less than the minimum limit of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TRFC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tRFC < 5)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TRFC"}),
                          .msg            ("TRFC value should not be less than the minimum limit of 6."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TRFC: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRFC < 9)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TRFC"}),
                          .msg            ("TRFC value should not be less than the minimum limit of 10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TXSNR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSNR < 5)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TXSNR"}),
                          .msg            ("TXSNR value should not be less than the minimum limit of 6."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TXSNR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tXSNR < 9)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TXSNR"}),
                          .msg            ("TXSNR value should not be less than the minimum limit of 10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_2_0_TXSRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSRD < 199)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_2_0_TXSRD"}),
                          .msg            ("TXSRD value should not be less than the minimum limit of 200."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_DDR_SDRAM_1_0_TXSRD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSRD < 199)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_1_0_TXSRD"}),
                          .msg            ("TXSRD value should not be less than the minimum limit of 200."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_DDR_SDRAM_violates_tRRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0) &&
                           (an_active_cmd && !(BA === BA_saved) &&
                           (counter_tRRD > 0) && violates_tRRD === 1'b1)))));
        M_DDR_SDRAM_incorrect_command_before_mode_reg_set: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((BYPASS_INIT == 0) && 
                           (mode_register_set === 1'b0 && 
                           incorrect_command_before_mode_reg_set === 1'b1) && 
                           (CKE_delayed && (CS_n !== 1'b1) && 
                           !(((RAS_n === 1'b1) &&  (CAS_n === 1'b1) && 
                           (WE_n === 1'b1)) || ((!RAS_n === 1'b1) && 
                           (CAS_n === 1'b1) && (!WE_n === 1'b1)) || 
                           ((!RAS_n === 1'b1) && (!CAS_n === 1'b1) && 
                           (WE_n === 1'b1)) || ((!RAS_n === 1'b1) && 
                           (!CAS_n === 1'b1) && (!WE_n === 1'b1)) ))))));
        M_DDR_SDRAM_invalid_burst_length_value_in_mode_reg_set: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 0) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_reg[2:0] !== 3'b001) && 
                           (mode_reg[2:0] !== 3'b010) && 
                           (mode_reg[2:0] !== 3'b011) && 
                           (mode_reg[2:0] !== 3'b111)) && 
                           invalid_mode_reg_value === 1'b1)))));
        M_DDR_SDRAM_invalid_burst_length: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 1) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_register[2:0] !== 3'b001) && 
                           (mode_register[2:0] !== 3'b010) && 
                           (mode_register[2:0] !== 3'b011) && 
                           (mode_register[2:0] !== 3'b111)) &&
                           invalid_mode_reg_value === 1'b1)))));
        M_DDR_SDRAM_invalid_cas_latency_value_in_mode_reg_set: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 0) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_reg[6:4] !== 3'b010) && 
                           (mode_reg[6:4] !== 3'b011) && 
                           (mode_reg[6:4] !== 3'b101) && 
                           (mode_reg[6:4] !== 3'b110) ) && 
                           (mode_reg[6:4] !==  3'b100) && 
                           invalid_mode_reg_value === 1'b1)))));
        M_DDR_SDRAM_invalid_cas_latency: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((BYPASS_INIT == 1) &&(NON_JEDEC == 0)) && 
                           (an_active_cmd === 1'b1) && 
                           (((mode_register[6:4] !== 3'b010) && 
                           (mode_register[6:4] !== 3'b011) && 
                           (mode_register[6:4] !== 3'b101) && 
                           (mode_register[6:4] !== 3'b110)) && 
                           (mode_register[6:4] !== 3'b100) && 
                           invalid_mode_reg_value === 1'b1) ))));
        M_DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (DDR_SDRAM_invalid_operating_mode_bits_mrs_or_emrs) ) ); 

        M_DDR_SDRAM_invalid_operating_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (DDR_SDRAM_invalid_operating_mode) ) ) ;

        M_DDR_SDRAM_Constraints_Mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_Constraints_Mode != 1) && 
                           (pw_Constraints_Mode != 0)))));
        M_DDR_SDRAM_CONTROLLER_SIDE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_CONTROLLER_SIDE != 1) && 
                           (pw_CONTROLLER_SIDE != 0)))));
        M_DDR_SDRAM_DATA_CONFIG: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_DDR_SDRAM_2_0 === 1)) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((pw_DATA_WIDTH != 4) && (pw_DATA_WIDTH != 8) && 
                           (pw_DATA_WIDTH != 16)))));
        M_DDR_SDRAM_DLL_TRACKING_ENABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_DLL_TRACKING_ENABLE != 1) && 
                           (pw_DLL_TRACKING_ENABLE != 0)))));
        M_DDR_SDRAM_BYPASS_INIT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_BYPASS_INIT != 1) && (pw_BYPASS_INIT != 0)))));
        M_DDR_SDRAM_DM_WIDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1) && 
                           ((pw_EFFECTIVE_DM_WIDTH < 1)))));
        M_DDR_SDRAM_DATA_WIDTH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_DDR_SDRAM_2_0 === 0)) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((pw_DATA_WIDTH < 3)))));
        M_DDR_SDRAM_TWR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((NON_JEDEC == 0)) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tWR < 1)))));
        M_DDR_SDRAM_2_0_TRC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRC < 4)))));
        M_DDR_SDRAM_1_0_TRC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1 ))) &&
                           ((tRC < 8)))));
        M_DDR_SDRAM_2_0_TRAS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRAS < 3))));
        M_DDR_SDRAM_1_0_TRAS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRAS < 5)))));
        M_DDR_SDRAM_2_0_TRP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRP < 1 ))));
        M_DDR_SDRAM_1_0_TRP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRP < 2)))));
        M_DDR_SDRAM_2_0_TRCD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && ((areset === 1'b0 && 
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           (tRCD < 1))));
        M_DDR_SDRAM_1_0_TRCD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRCD < 2)))));
        M_DDR_SDRAM_1_0_TRRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRRD < 1)))));
        M_DDR_SDRAM_2_0_TMRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((((NON_JEDEC == 0)) && 
                           ((areset === 1'b0 &&
                           reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tMRD < 1)))));
        M_DDR_SDRAM_2_0_TRFC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tRFC < 5)))));
        M_DDR_SDRAM_1_0_TRFC: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) &&
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tRFC < 9)))));
        M_DDR_SDRAM_2_0_TXSNR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSNR < 5)))));
        M_DDR_SDRAM_1_0_TXSNR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) &&
                           ((tXSNR < 9)))));
        M_DDR_SDRAM_2_0_TXSRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 1) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSRD < 199)))));
        M_DDR_SDRAM_1_0_TXSRD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr (((((ZI_DDR_SDRAM_2_0 == 0) && 
                           (NON_JEDEC == 0))) && 
                           ((areset === 1'b0 && reset === 1'b0 && 
                           parameter_checks_active === 1'b1))) && 
                           ((tXSRD < 199)))));
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
