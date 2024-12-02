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

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_GIGABIT_ETHERNET_XSBI_INVALID_CTRL_CODE_TYPE_1E: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_control_code_in_type_1e === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_INVALID_CTRL_CODE_TYPE_1E"}),
                          .msg            ("Control blocks of type 0x1E should contain codes of either Idle or Error control characters."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_INVALID_SYNC_HEADER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_sync_header_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_INVALID_SYNC_HEADER"}),
                          .msg            ("Synchronization header should be either 2'b01 or 2'b10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_INVALID_BLOCK_TYPE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_block_type_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_INVALID_BLOCK_TYPE"}),
                          .msg            ("Block type field should be defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_NULL_VALUE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (non_zero_null_fields_on_tx === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_NULL_VALUE_VIOLATION"}),
                          .msg            ("The null fields in a 66b block should be encoded with zero on transmit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_INVALID_O_CODE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_o_code_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_INVALID_O_CODE_VIOLATION"}),
                          .msg            ("The O-Code that encodes the /Q/ control character should be encoded with all zeros."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_TERMINATE_BLOCK_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (control_char_folowing_terminate_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_TERMINATE_BLOCK_ERROR"}),
                          .msg            ("The control codes following a terminate character in a 66b block should be zeros, indicating Idles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_ERROR_CONTROL_CHARACTER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (error_control_character === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_ERROR_CONTROL_CHARACTER"}),
                          .msg            ("The control codes contain Error Code 7'h1e."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_RESERVED_CONTROL_CHARACTER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_RESERVED_CONTROL_CHARACTER"}),
                          .msg            ("The control character in a block contains Reserved control code"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_INVALID_CONTROL_CHARACTER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_control_character === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_INVALID_CONTROL_CHARACTER"}),
                          .msg            ("The control character in a block contains Invalid control code i.e other than specified in Table 49-1 of IEEE 802.3-2005"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_START_OR_IDLE_BLOCK_EXPECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_or_idle_block_expected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_START_OR_IDLE_BLOCK_EXPECTED"}),
                          .msg            ("While IDLE Blocks are being recieved then only IDLE,Order Set and Start Blocks should follow"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_TERMINATE_OR_CONTROL_BLOCK_EXPECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_or_ctrl_block_expected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_TERMINATE_OR_CONTROL_BLOCK_EXPECTED"}),
                          .msg            ("While Data Blocks are being recieved then only Data, Terminate or Control Blocks should follow"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_XSBI_SEQUENCE_OS_VIOLATION:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_XSBI_SEQUENCE_OS_VIOLATION"}),
                          .msg            ("The sequence ordered set should not contain reserved values"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_GIGABIT_ETHERNET_XSBI_INVALID_CTRL_CODE_TYPE_1E: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_control_code_in_type_1e === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_INVALID_SYNC_HEADER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_sync_header_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_INVALID_BLOCK_TYPE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_block_type_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_NULL_VALUE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (non_zero_null_fields_on_tx === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_INVALID_O_CODE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_o_code_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_TERMINATE_BLOCK_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (control_char_folowing_terminate_violation === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_ERROR_CONTROL_CHARACTER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (error_control_character === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_RESERVED_CONTROL_CHARACTER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_control_character === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_BLOCK_CONTAINS_INVALID_CONTROL_CHARACTER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_control_character === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_START_OR_IDLE_BLOCK_EXPECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (start_or_idle_block_expected === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_TERMINATE_OR_CONTROL_BLOCK_EXPECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (terminate_or_ctrl_block_expected === 1'b1)));
        M_GIGABIT_ETHERNET_XSBI_SEQUENCE_OS_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (reserved_values_on_sequence_os === 1'b1)));
 
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
