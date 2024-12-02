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
  parameter QVL_MSG = "QVL_SATA_VIOLATION : ";

  wire not_tbc = ~tbc;
  wire not_rbc = ~rbc;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_SATA_SAPIS_TX_DATA_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_data),
                          .qualifier (tx_enable)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_TX_DATA_UNKN_P"}),
                          .msg            ("Transmit data (TX_DATA) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_TX_DATA_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_data),
                          .qualifier ((pw_DOUBLE_DATA_RATE == 1) &&
                           (tx_enable))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_TX_DATA_UNKN_N"}),
                          .msg            ("Transmit data (TX_DATA) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_TX_ENABLE_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_enable),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_TX_ENABLE_UNKN_P"}),
                          .msg            ("Signal TX_ENABLE is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_TX_ENABLE_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_enable),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_TX_ENABLE_UNKN_N"}),
                          .msg            ("Signal TX_ENABLE is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_PARTIAL_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (partial),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_PARTIAL_UNKN_P"}),
                          .msg            ("Signal PARTIAL is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_PARTIAL_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (partial),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_PARTIAL_UNKN_N"}),
                          .msg            ("Signal PARTIAL is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_SLUMBER_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (slumber),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_SLUMBER_UNKN_P"}),
                          .msg            ("Signal SLUMBER is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_SLUMBER_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (slumber),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_SLUMBER_UNKN_N"}),
                          .msg            ("Signal SLUMBER is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_DATA_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data),
                          .qualifier (rx_data_valid)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_DATA_UNKN_P"}),
                          .msg            ("Receive data (RX_DATA) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_DATA_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data),
                          .qualifier ((pw_DOUBLE_DATA_RATE == 1) &&
                           (rx_data_valid))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_DATA_UNKN_N"}),
                          .msg            ("Receive data (RX_DATA) is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_DATA_VALID_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data_valid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_DATA_VALID_UNKN_P"}),
                          .msg            ("Signal RX_DATA_VALID is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_DATA_VALID_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data_valid),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_DATA_VALID_UNKN_N"}),
                          .msg            ("Signal RX_DATA_VALID is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_LOCKED_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_locked),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_LOCKED_UNKN_P"}),
                          .msg            ("Signal RX_LOCKED is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_RX_LOCKED_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_locked),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_RX_LOCKED_UNKN_N"}),
                          .msg            ("Signal RX_LOCKED is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_K28_5_DETECT_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (k28_5_detect),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_K28_5_DETECT_UNKN_P"}),
                          .msg            ("Signal K28.5_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_K28_5_DETECT_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (k28_5_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_K28_5_DETECT_UNKN_N"}),
                          .msg            ("Signal K28.5_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_COMWAKE_DETECT_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comwake_detect),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_COMWAKE_DETECT_UNKN_P"}),
                          .msg            ("Signal COMWAKE_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_COMWAKE_DETECT_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comwake_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_COMWAKE_DETECT_UNKN_N"}),
                          .msg            ("Signal COMWAKE_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_P: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comreset_cominit_detect),
                          .qualifier ((1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_P"}),
                          .msg            ("Signal COMRESET_DETECT or COMINIT_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_N: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comreset_cominit_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_N"}),
                          .msg            ("Signal COMRESET_DETECT or COMINIT_DETECT is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_SATA_SAPIS_TX_DATA_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_data),
                          .qualifier (tx_enable)));
        M_SATA_SAPIS_TX_DATA_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_data),
                          .qualifier ((pw_DOUBLE_DATA_RATE == 1) &&
                           (tx_enable) ) ) );
        M_SATA_SAPIS_TX_ENABLE_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_enable),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_TX_ENABLE_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (tx_enable),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_PARTIAL_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (partial),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_PARTIAL_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (partial),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_SLUMBER_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (slumber),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_SLUMBER_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_tbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (slumber),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_RX_DATA_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data),
                          .qualifier (rx_data_valid)));
        M_SATA_SAPIS_RX_DATA_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data),
                          .qualifier ((pw_DOUBLE_DATA_RATE == 1) &&
                           (rx_data_valid) ) ) );
        M_SATA_SAPIS_RX_DATA_VALID_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data_valid),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_RX_DATA_VALID_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_data_valid),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_RX_LOCKED_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_locked),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_RX_LOCKED_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (rx_locked),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_K28_5_DETECT_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (k28_5_detect),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_K28_5_DETECT_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (k28_5_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_COMWAKE_DETECT_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comwake_detect),
                          .qualifier (1'b1)));
        M_SATA_SAPIS_COMWAKE_DETECT_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comwake_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
        M_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_P: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comreset_cominit_detect),
                          .qualifier ((1'b1))));
        M_SATA_SAPIS_COMRESET_COMINIT_DETECT_UNKN_N: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (not_rbc),
                          .reset_n   (~(areset | reset)),
                          .test_expr (comreset_cominit_detect),
                          .qualifier (pw_DOUBLE_DATA_RATE == 1)));
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
