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
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_ALL;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (0) //Always Targets. Never as Constraints
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_I2C_KNOWN_sda_out: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_sda_out"}),
                          .msg            ("Control signal, sda_out, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_sda_in: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_sda_in"}),
                          .msg            ("Control signal, sda_in, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_sda_out_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_sda_out_en_n"}),
                          .msg            ("Control signal, sda_out_en_n, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_scl_out: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_scl_out"}),
                          .msg            ("Control signal, scl_out, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_scl_out_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_scl_out_en_n"}),
                          .msg            ("Control signal, scl_out_en_n, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_scl_in: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_scl_in"}),
                          .msg            ("Control signal, scl_in, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_slave_addr: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_slave_addr"}),
                          .msg            ("Control signal, slave_addr, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_I2C_KNOWN_clock_prescale_count: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_KNOWN_clock_prescale_count"}),
                          .msg            ("Clock prescale value should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_I2C_KNOWN_sda_out: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_sda_in: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_sda_out_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_scl_out: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_scl_out_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_scl_in: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_slave_addr: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
        M_I2C_KNOWN_clock_prescale_count: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .test_expr (ZI_DISABLE_CHECKS ),
                          .qualifier (1'b1)));
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
`endif // QVL_ASSERT_ON
