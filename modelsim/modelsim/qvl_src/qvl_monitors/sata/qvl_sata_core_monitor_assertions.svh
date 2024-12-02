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

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// Checks based on ZI_TX_CONSTRAINT

generate
  case (ZI_TX_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_TX_CONSTRAINT 
        A_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_h_comwake_to_d_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P"}),
                          .msg            ("Device must transmit the first ALIGNp within 880us after the deassertion of COMWAKE by the host."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_h_comwake_to_d_align_p_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N"}),
                          .msg            ("Device must transmit the first ALIGNp within 880us after the deassertion of COMWAKE by the host."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_d_comwake_to_D10_2_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_P"}),
                          .msg            ("Host must transmit D10.2 characters within 533ns from the deassertion of COMWAKE by the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_d_comwake_to_D10_2_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_N"}),
                          .msg            ("Host must transmit D10.2 characters within 533ns from the deassertion of COMWAKE by the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_NO_2048_ALIGNP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_no_2048_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_NO_2048_ALIGNP_VIOLATION_P"}),
                          .msg            ("After transmitting COMWAKE the device must transmit at least 2048 ALIGNp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_NO_2048_ALIGNP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_no_2048_align_p_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_NO_2048_ALIGNP_VIOLATION_N"}),
                          .msg            ("After transmitting COMWAKE the device must transmit at least 2048 ALIGNp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RETRY_INTERVAL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_retry_interval_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RETRY_INTERVAL_VIOLATION_P"}),
                          .msg            ("When Asynchronous signal recovery is enabled COMRESET must not be transmitted by the host before the expiry of RETRY interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RETRY_INTERVAL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_retry_interval_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RETRY_INTERVAL_VIOLATION_N"}),
                          .msg            ("When Asynchronous signal recovery is enabled COMRESET must not be transmitted by the host before the expiry of RETRY interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_h_align_before_d_align_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P"}),
                          .msg            ("Host must not transmit ALIGNp primitives before receiving ALIGNp primitives from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_h_align_before_d_align_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N"}),
                          .msg            ("Host must not transmit ALIGNp primitives before receiving ALIGNp primitives from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_COMWAKE_IN_PARTIAL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_in_partial_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_IN_PARTIAL_VIOLATION_P"}),
                          .msg            ("Comwake must not be asserted when partial signal is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_COMWAKE_IN_PARTIAL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_in_partial_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_IN_PARTIAL_VIOLATION_N"}),
                          .msg            ("Comwake must not be asserted when partial signal is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_COMWAKE_IN_SLUMBER_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_in_slumber_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_IN_SLUMBER_VIOLATION_P"}),
                          .msg            ("Comwake must not be asserted when partial signal is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_COMWAKE_IN_SLUMBER_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_in_slumber_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_IN_SLUMBER_VIOLATION_N"}),
                          .msg            ("Comwake must not be asserted when partial signal is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((partial_slumber_active_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_P"}),
                          .msg            ("The partial and slumber inputs should not be asserted at the same instant."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (partial_slumber_active_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_N"}),
                          .msg            ("The partial and slumber inputs should not be asserted at the same instant."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_TX_CONSTRAINT 
        M_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_h_comwake_to_d_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_TX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_h_comwake_to_d_align_p_violation === 1'b1))));
        M_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_d_comwake_to_D10_2_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_TX_D_COMWAKE_TO_D10_2_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_d_comwake_to_D10_2_violation === 1'b1))));
        M_SATA_TX_NO_2048_ALIGNP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_no_2048_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_TX_NO_2048_ALIGNP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_no_2048_align_p_violation === 1'b1))));
        M_SATA_TX_RETRY_INTERVAL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_retry_interval_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_TX_RETRY_INTERVAL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_retry_interval_violation === 1'b1))));
        M_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((tx_h_align_before_d_align_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_TX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (tx_h_align_before_d_align_violation === 1'b1))));
        M_SATA_COMWAKE_IN_PARTIAL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_in_partial_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_COMWAKE_IN_PARTIAL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_in_partial_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_COMWAKE_IN_SLUMBER_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_in_slumber_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_COMWAKE_IN_SLUMBER_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_in_slumber_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((partial_slumber_active_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_PARTIAL_SLUMBER_ACTIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (partial_slumber_active_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_TX_CONSTRAINT 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Checks based on ZI_RX_CONSTRAINT

generate
  case (ZI_RX_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_RX_CONSTRAINT 
        A_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_h_comwake_to_d_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P"}),
                          .msg            ("Host must see the first ALIGNp from the device within 880us after the deassertion of COMWAKE by the host."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_h_comwake_to_d_align_p_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N"}),
                          .msg            ("Host must see the first ALIGNp from the device within 880us after the deassertion of COMWAKE by the host."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_d_comwake_to_D10_2_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_P"}),
                          .msg            ("Host must transmit D10.2 characters within 533ns from the deassertion of COMWAKE by the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_d_comwake_to_D10_2_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_N"}),
                          .msg            ("Host must transmit D10.2 characters within 533ns from the deassertion of COMWAKE by the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_NO_2048_ALIGNP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_no_2048_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_NO_2048_ALIGNP_VIOLATION_P"}),
                          .msg            ("After receiving COMWAKE the host must receive at least 2048 ALIGNp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_NO_2048_ALIGNP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_no_2048_align_p_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_NO_2048_ALIGNP_VIOLATION_N"}),
                          .msg            ("After receiving COMWAKE the host must receive at least 2048 ALIGNp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RETRY_INTERVAL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_retry_interval_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RETRY_INTERVAL_VIOLATION_P"}),
                          .msg            ("When Asynchronous signal recovery is enabled COMRESET must not be transmitted by the host before the expiry of RETRY interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RETRY_INTERVAL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_retry_interval_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RETRY_INTERVAL_VIOLATION_N"}),
                          .msg            ("When Asynchronous signal recovery is enabled COMRESET must not be transmitted by the host before the expiry of RETRY interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_h_align_before_d_align_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P"}),
                          .msg            ("Host must not transmit ALIGNp primitives before receiving ALIGNp primitives from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_h_align_before_d_align_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N"}),
                          .msg            ("Host must not transmit ALIGNp primitives before receiving ALIGNp primitives from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cr_ci_and_cw_active_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_P"}),
                          .msg            ("The comreset_cominit_detect and comwake inputs should not be asserted at the same instant."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cr_ci_and_cw_active_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_N"}),
                          .msg            ("The comreset_cominit_detect and comwake inputs should not be asserted at the same instant."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_RX_CONSTRAINT 
        M_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_h_comwake_to_d_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_RX_H_COMWAKE_TO_D_ALIGNP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_h_comwake_to_d_align_p_violation === 1'b1))));
        M_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_d_comwake_to_D10_2_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_RX_D_COMWAKE_TO_D10_2_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_d_comwake_to_D10_2_violation === 1'b1))));
        M_SATA_RX_NO_2048_ALIGNP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_no_2048_align_p_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_RX_NO_2048_ALIGNP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_no_2048_align_p_violation === 1'b1))));
        M_SATA_RX_RETRY_INTERVAL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_retry_interval_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_RX_RETRY_INTERVAL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_retry_interval_violation === 1'b1))));
        M_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((rx_h_align_before_d_align_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_RX_H_ALIGN_BEFORE_D_ALIGN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (rx_h_align_before_d_align_violation === 1'b1))));
        M_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cr_ci_and_cw_active_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0) &
                           (pw_INTERFACE_TYPE == 2))));
        M_SATA_CR_CI_AND_CW_ACTIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cr_ci_and_cw_active_violation === 1'b1) &
                           (pw_INTERFACE_TYPE == 2))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_RX_CONSTRAINT 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate


`endif // QVL_ASSERT_ON
