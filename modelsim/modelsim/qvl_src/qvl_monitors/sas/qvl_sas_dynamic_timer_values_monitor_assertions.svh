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
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SAS_VIOLATION : ";

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk; 
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_SAS_TX_DP_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_plus),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TX_DP_UNKN_P"}),
                          .msg            ("Transmit D+ (tx_data_plus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_TX_DP_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_plus),
                          .qualifier (pw_ZI_FINAL_DDR == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TX_DP_UNKN_N"}),
                          .msg            ("Transmit D+ (tx_data_plus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RX_DP_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_plus),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RX_DP_UNKN_P"}),
                          .msg            ("Receive D+ (rx_data_plus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RX_DP_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_plus),
                          .qualifier (pw_ZI_FINAL_DDR == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RX_DP_UNKN_N"}),
                          .msg            ("Receive D+ (rx_data_plus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_TX_DN_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_minus),
                          .qualifier (pw_INTERFACE_TYPE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TX_DN_UNKN_P"}),
                          .msg            ("Transmit D- (tx_data_minus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_TX_DN_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_minus),
                          .qualifier (pw_ZI_FINAL_DDR == 1 && pw_INTERFACE_TYPE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TX_DN_UNKN_N"}),
                          .msg            ("Transmit D- (tx_data_minus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RX_DN_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_minus),
                          .qualifier (pw_INTERFACE_TYPE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RX_DN_UNKN_P"}),
                          .msg            ("Receive D- (rx_data_minus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SAS_RX_DN_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_minus),
                          .qualifier (pw_ZI_FINAL_DDR == 1 && pw_INTERFACE_TYPE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RX_DN_UNKN_N"}),
                          .msg            ("Receive D- (rx_data_minus) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_SAS_TX_DP_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_plus),
                          .qualifier (1'b1)));
        M_SAS_TX_DP_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_plus),
                          .qualifier (pw_ZI_FINAL_DDR == 1)));
        M_SAS_RX_DP_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_plus),
                          .qualifier (1'b1)));
        M_SAS_RX_DP_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_plus),
                          .qualifier (pw_ZI_FINAL_DDR == 1)));
        M_SAS_TX_DN_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_minus),
                          .qualifier (pw_INTERFACE_TYPE == 0)));
        M_SAS_TX_DN_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (tx_data_minus),
                          .qualifier (pw_ZI_FINAL_DDR == 1 && pw_INTERFACE_TYPE == 0)));
        M_SAS_RX_DN_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_minus),
                          .qualifier (pw_INTERFACE_TYPE == 0)));
        M_SAS_RX_DN_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~(areset | reset) ),
                          .test_expr (rx_data_minus),
                          .qualifier (pw_ZI_FINAL_DDR == 1 && pw_INTERFACE_TYPE == 0)));
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
