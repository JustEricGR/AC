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

  parameter QVL_MSG = "USB 2.0 Violation: ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = 0;  // 0 = `OVL_ZIN2OVLSVA
                                    // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; // `OVL_COVER_ALL;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

generate 
  case (MAC_LAYER_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_MAC
        A_USB_2_0_UTMI_RX_VALID_ASSERTED_BEFORE_RX_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( rx_valid_without_rx_active))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_ASSERTED_BEFORE_RX_ACTIVE"}),
                          .msg            ("RXValid signal should be asserted after the assertion of RXActive signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_RX_VALIDH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_vald_h_without_rx_valid && latched_databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_RX_VALIDH"}),
                          .msg            ("RXValidH signal should not be asserted without asserting RXValid signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RXERROR_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_rx_error_assertion))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RXERROR_ASSERTED"}),
                          .msg            ("Illegal RXError signal assertion."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALID_NOT_NEGATED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( rx_valid_not_deasserted))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_NOT_NEGATED"}),
                          .msg            ("RXValid signal asserted after the negation of RXError signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_TX_READY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_more_data_transfer_after_tx_valid_h && latched_databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_TX_READY"}),
                          .msg            ("More than one byte transferred after the negation of TXValidH signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_RX_VALID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_more_data_transfer_after_rx_valid_h && latched_databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_RX_VALID"}),
                          .msg            ("More than one byte transferred after the negation of RXValidH signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_READY_ASSERTED_MORE_THAN_ONE_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_ready_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_READY_ASSERTED_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("TXReady signal should be asserted for one clock per byte time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALID_MORE_THAN_ONE_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_valid_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("RXValid signal should be asserted for one clock per byte time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALIDH_MORE_THAN_ONE_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_validh_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALIDH_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("RXValidH signal asserted for more than one clock cycle per byte time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MIN_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( transmit_to_receive_delay_violation_min))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MIN_ERROR"}),
                          .msg            ("Minimum inter packet delay specification is violated while receiving a packet after the transmission of a packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MAX_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( transmit_to_receive_delay_violation_max))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MAX_ERROR"}),
                          .msg            ("Maximum inter packet delay specification is violated while receiving a packet after the transmission of a packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_TX_READY_DEASSERT_ERROR: 
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tx_valid_to_tx_ready_negate_delay_violation))))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_TX_READY_DEASSERT_ERROR"}),
                          .msg            ("TXReady negedge does not come exactly after one clock of TXValid negedge."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_VALID_DEASSERT_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_and_rx_valid_simultaneous_negate_violation)))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_VALID_DEASSERT_ERROR"}),
                          .msg            ("RXValid negedge does not occur simultaneously with RXActive negedge."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_INVALID_SIGNALING_ON_LINE_STATE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_signaling_on_line_state)))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_INVALID_SIGNALING_ON_LINE_STATE"}),
                          .msg            ("Invalid LineState"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_AVALID_ASSERT_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (OTG_DEVICE == 1 && vbus_valid === 1'b1 && a_valid !== 1'b1)))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_AVALID_ASSERT_ERROR"}),
                          .msg            ("AValid signal must be asserted when VbusValid is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_BVALID_ASSERT_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (OTG_DEVICE == 1 && vbus_valid === 1'b1 && b_valid !== 1'b1)))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_BVALID_ASSERT_ERROR"}),
                          .msg            ("BValid signal must be asserted when VbusValid is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_LINE_STATE_WHEN_SESSION_NOT_VALID:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_line_state_while_power_dwn)))
          else qvl_error_t(             
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_LINE_STATE_WHEN_SESSION_NOT_VALID"}),
                          .msg            ("When a session is not valid LineState must be SE0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_ACTIVE_ASSERT_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_active_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_ACTIVE_ASSERT_ERROR"}),
                          .msg            ("RXActive is not negated for minimum legal interval between consecutive received packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALID_DEASSERT_MORE_THAN_ONE_CLOCK:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_valid_deassert_more_than_one_clock))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_DEASSERT_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("RXValid goes low for more than one consecutive clock cycle while receiving data in HS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_READY_DEASSERT_MORE_THAN_ONE_CLOCK:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_ready_deassert_more_than_one_clock))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_READY_DEASSERT_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("TXReady goes low for more than one consecutive clock cycle while transmitting data in HS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_FS_LS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_valid_delay_fs_ls_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_FS_LS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY"}),
                          .msg            ("RXActive assert to RXValid assert delay violated in FS/ LS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_HS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_valid_hs_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_HS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY"}),
                          .msg            ("RXActive assert to RXValid assert delay not in the legal range  in HS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_INTER_RX_VALID_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (inter_rx_valid_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_INTER_RX_VALID_DELAY"}),
                          .msg            ("Consecutive RXValid does not occur at legal intervals."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_INTER_TX_READY_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (inter_tx_ready_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_INTER_TX_READY_DELAY"}),
                          .msg            ("Consecutive TXReady does not occur at legal intervals."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));

        A_USB_2_0_UTMI_TX_READY_ASSERTION_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_valid_assert_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_READY_ASSERTION_DELAY"}),
                          .msg            ("TXReady remains low after legal limit while TXValid is asserted during data transmission."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALID_ASSERTION_DELAY:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_valid_assert_delay_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_ASSERTION_DELAY"}),
                          .msg            ("RXValid remains low after legal limit  while RXActive is asserted during data reception."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_ACTIVE_RX_VALID_ACTIVITY_WHILE_TX:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_path_active_while_tx)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_ACTIVE_RX_VALID_ACTIVITY_WHILE_TX"}),
                          .msg            ("RXValid and/or RXActive is active while data transmission."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_READY_TX_VALID_ACTIVITY_WHILE_RX:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_path_active_while_rx)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_READY_TX_VALID_ACTIVITY_WHILE_RX"}),
                          .msg            ("TXReady and/or TXValid is active while data reception."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_HOST_DISCONNECT_XCVR_SELECT_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((UTMI_LEVEL > 0) ?(host_disconnect === 1'b1 && speed !== 2'b00 
                                                         && xcvr_select === 'd1) : 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_HOST_DISCONNECT_XCVR_SELECT_ERROR"}),
                          .msg            ("XcvrSelect not switched to FS mode when HostDisconnect is asserted in HS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_HOST_DISCONNECT_UPDATE_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (host_disconnect_update_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_HOST_DISCONNECT_UPDATE_ERROR"}),
                          .msg            ("Early update of HostDisconnect after reversal to FS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_MAC
        M_USB_2_0_UTMI_RX_VALID_ASSERTED_BEFORE_RX_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( rx_valid_without_rx_active))));
        M_USB_2_0_UTMI_ILLEGAL_RX_VALIDH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_vald_h_without_rx_valid && latched_databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_RXERROR_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_rx_error_assertion))));
        M_USB_2_0_UTMI_RX_VALID_NOT_NEGATED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( rx_valid_not_deasserted))));
        M_USB_2_0_UTMI_ILLEGAL_TX_READY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_more_data_transfer_after_tx_valid_h && latched_databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_ILLEGAL_RX_VALID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_more_data_transfer_after_rx_valid_h && latched_databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_TX_READY_ASSERTED_MORE_THAN_ONE_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_ready_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))));
        M_USB_2_0_UTMI_RX_VALID_MORE_THAN_ONE_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_valid_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))));
        M_USB_2_0_UTMI_RX_VALIDH_MORE_THAN_ONE_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((rx_validh_more_than_one_clock &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))));
        M_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MIN_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( transmit_to_receive_delay_violation_min))));
        M_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_RX_ACTIVE_ASSERT_MAX_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( transmit_to_receive_delay_violation_max))));
        M_USB_2_0_UTMI_TX_VALID_DEASSERT_TO_TX_READY_DEASSERT_ERROR: 
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tx_valid_to_tx_ready_negate_delay_violation))));
        M_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_VALID_DEASSERT_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_and_rx_valid_simultaneous_negate_violation)));
        M_USB_2_0_UTMI_INVALID_SIGNALING_ON_LINE_STATE:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_signaling_on_line_state)));
        M_USB_2_0_UTMI_AVALID_ASSERT_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (OTG_DEVICE == 1 && vbus_valid === 1'b1 && a_valid !== 1'b1)));
        M_USB_2_0_UTMI_BVALID_ASSERT_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (OTG_DEVICE == 1 && vbus_valid === 1'b1 && b_valid !== 1'b1)));
        M_USB_2_0_UTMI_ILLEGAL_LINE_STATE_WHEN_SESSION_NOT_VALID:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_line_state_while_power_dwn)));
        M_USB_2_0_UTMI_RX_ACTIVE_DEASSERT_TO_RX_ACTIVE_ASSERT_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_active_delay_violation))); 
        M_USB_2_0_UTMI_RX_VALID_DEASSERT_MORE_THAN_ONE_CLOCK:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_valid_deassert_more_than_one_clock))); 
        M_USB_2_0_UTMI_TX_READY_DEASSERT_MORE_THAN_ONE_CLOCK:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_ready_deassert_more_than_one_clock))); 
        M_USB_2_0_UTMI_FS_LS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_valid_delay_fs_ls_violation)));
        M_USB_2_0_UTMI_HS_RX_ACTIVE_ASSERT_TO_RX_VALID_ASSERT_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_active_to_rx_valid_hs_delay_violation)));
        M_USB_2_0_UTMI_INTER_RX_VALID_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (inter_rx_valid_delay_violation))); 
        M_USB_2_0_UTMI_INTER_TX_READY_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (inter_tx_ready_delay_violation))); 
        M_USB_2_0_UTMI_RX_VALID_ASSERTION_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_valid_assert_delay_violation))); 
        M_USB_2_0_UTMI_TX_READY_ASSERTION_DELAY:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_valid_assert_delay_violation))); 
        M_USB_2_0_UTMI_RX_ACTIVE_RX_VALID_ACTIVITY_WHILE_TX:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (rx_path_active_while_tx)));
        M_USB_2_0_UTMI_TX_READY_TX_VALID_ACTIVITY_WHILE_RX:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (tx_path_active_while_rx)));
        M_USB_2_0_UTMI_HOST_DISCONNECT_XCVR_SELECT_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((UTMI_LEVEL > 0) ?(host_disconnect === 1'b1 && speed !== 2'b01 
                                                         && xcvr_select ==='d1) : 1'b0))));
        M_USB_2_0_UTMI_HOST_DISCONNECT_UPDATE_ERROR:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (host_disconnect_update_violation)));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_MAC
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

generate 
  case (MAC_LAYER_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_MAC
        A_USB_2_0_UTMI_TX_READY_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_ready),
                          .qualifier (((tx_valid === 1'b1 || r_tx_valid === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_READY_KNOWN_DRIVEN"}),
                          .msg            ("TXReady is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALID_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_valid),
                          .qualifier (((rx_active === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALID_KNOWN_DRIVEN"}),
                          .msg            ("RXValid is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_VALIDH_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_valid_h),
                          .qualifier (((rx_valid === 1'b1 && databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_VALIDH_KNOWN_DRIVEN"}),
                          .msg            ("RXValidH is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_ACTIVE_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_active),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_ACTIVE_KNOWN_DRIVEN"}),
                          .msg            ("RXActive is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DATA_OUT_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr ((latched_databus16_8?{data_out_low_actual,data_out_high_actual}:{8'b00,data_out_low_actual})),
                          .qualifier (((rx_valid === 1'b1 && rx_active === 1'b1 && BI_DIRECTIONAL == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_OUT_KNOWN_DRIVEN"}),
                          .msg            ("DataOut is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_ERROR_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_error),
                          .qualifier (((rx_active)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_ERROR_KNOWN_DRIVEN"}),
                          .msg            ("RXError is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_LINE_STATE_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (line_state),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_LINE_STATE_KNOWN_DRIVEN"}),
                          .msg            ("LineState is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ID_DIG_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (id_dig),
                          .qualifier ((OTG_DEVICE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ID_DIG_KNOWN_DRIVEN"}),
                          .msg            ("IdDig is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_AVALID_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (a_valid),
                          .qualifier ((OTG_DEVICE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_AVALID_KNOWN_DRIVEN"}),
                          .msg            ("AValid is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_BVALID_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (b_valid),
                          .qualifier ((OTG_DEVICE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_BVALID_KNOWN_DRIVEN"}),
                          .msg            ("BValid is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_VBUS_VALID_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (vbus_valid),
                          .qualifier ((OTG_DEVICE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_VBUS_VALID_KNOWN_DRIVEN"}),
                          .msg            ("VbusValid is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_SESS_END_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (sess_end),
                          .qualifier ((OTG_DEVICE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SESS_END_KNOWN_DRIVEN"}),
                          .msg            ("SessEnd is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_HOST_DISCONNECT_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (host_disconnect),
                          .qualifier ((OTG_DEVICE == 1 && dp_pulldown === 1'b1 && dm_pulldown === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_HOST_DISCONNECT_KNOWN_DRIVEN"}),
                          .msg            ("HostDisconnect is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
     end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_MAC
        M_USB_2_0_UTMI_TX_READY_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_ready),
                          .qualifier (((tx_valid === 1'b1 || r_tx_valid === 1'b1)))));
        M_USB_2_0_UTMI_RX_VALID_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_valid),
                          .qualifier (((rx_active === 1'b1)))));
        M_USB_2_0_UTMI_RX_VALIDH_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_valid_h),
                          .qualifier (((rx_valid === 1'b1 && databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_RX_ACTIVE_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_active),
                          .qualifier (( 1'b1))));
        M_USB_2_0_UTMI_DATA_OUT_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr ((latched_databus16_8?{data_out_low_actual,data_out_high_actual}:{8'b00,data_out_low_actual})),
                          .qualifier (((rx_valid === 1'b1 && rx_active === 1'b1 && BI_DIRECTIONAL == 0)))));
        M_USB_2_0_UTMI_RX_ERROR_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (rx_error),
                          .qualifier (((rx_active)))));
        M_USB_2_0_UTMI_LINE_STATE_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (line_state),
                          .qualifier (( 1'b1))));
        M_USB_2_0_UTMI_ID_DIG_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (id_dig),
                          .qualifier ((OTG_DEVICE == 1))));
        M_USB_2_0_UTMI_AVALID_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (a_valid),
                          .qualifier ((OTG_DEVICE == 1))));
        M_USB_2_0_UTMI_BVALID_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (b_valid),
                          .qualifier ((OTG_DEVICE == 1))));
        M_USB_2_0_UTMI_VBUS_VALID_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (vbus_valid),
                          .qualifier ((OTG_DEVICE == 1))));
        M_USB_2_0_UTMI_SESS_END_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (sess_end),
                          .qualifier ((OTG_DEVICE == 1))));
        M_USB_2_0_UTMI_HOST_DISCONNECT_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (host_disconnect),
                          .qualifier ((OTG_DEVICE == 1 && dp_pulldown === 1'b0 && dm_pulldown === 1'b0))));
     end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_MAC
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
  case (PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_PHY
        A_USB_2_0_UTMI_ILLEGAL_TX_VALIDH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tx_vald_h_without_tx_valid))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_TX_VALIDH"}),
                          .msg            ("TXValidH signal should not be asserted without asserting TXValid signal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DATA_CHANGE_BEFORE_TX_READY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_data_changed_before_sampling &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_CHANGE_BEFORE_TX_READY"}),
                          .msg            ("Value on DataIn bus must be held until TXReady is sampled asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MIN_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( receive_to_transmit_delay_violation_min))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MIN_ERROR"}),
                          .msg            ("Minimum inter packet delay specification is violated while transmitting a packet after the reception of a packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MAX_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( receive_to_transmit_delay_violation_max))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MAX_ERROR"}),
                          .msg            ("Maximum inter packet delay specification is violated while transmitting a packet after the reception of a packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));

        A_USB_2_0_UTMI_SUSPENDM_TERM_SELECT_FS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((suspendm === 1'b0 && term_select !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SUSPENDM_TERM_SELECT_FS"}),
                          .msg            ("While SuspendM is active  TermSelect is not in Full-Speed mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_OP_MODE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((op_mode === 2'b11 && UTMI_LEVEL == 0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_OP_MODE"}),
                          .msg            ("iReserved opmode used at level0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));

        A_USB_2_0_UTMI_SUSPENDM_NEGATION_RESET_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (present_state_reset === ZI_SUSPEND_STATE && line_state === ZI_SE0_STATE && suspendm === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SUSPENDM_NEGATION_RESET_ERROR"}),
                          .msg            ("SuspendM is not combinatorially negated when reset is entered from suspended state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));

        A_USB_2_0_UTMI_ILLEGAL_COMB_OP_MODE_XCVR_SELECT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (op_mode === 2'b11 && xcvr_select !== 'd0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_COMB_OP_MODE_XCVR_SELECT"}),
                          .msg            ("Illegal Opmode and XcvrSelect combination."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));

        A_USB_2_0_UTMI_DP_PULLDOWN_VALUE_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (((PORT_TYPE == 1 || PORT_TYPE == 3) && dp_pulldown === 1'b1) || 
                                     ((PORT_TYPE == 0 || PORT_TYPE == 2) && dp_pulldown === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DP_PULLDOWN_VALUE_ERROR"}),
                          .msg            ("Illegal DpPulldown value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DM_PULLDOWN_VALUE_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (((PORT_TYPE == 1 || PORT_TYPE == 3) && dm_pulldown === 1'b1) || 
                                     ((PORT_TYPE == 0 || PORT_TYPE == 2) && dm_pulldown === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DM_PULLDOWN_VALUE_ERROR"}),
                          .msg            ("Illegal DmPulldown value."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ILLEGAL_XCVR_SELECT:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL == 2 && xcvr_select === 'd3))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_XCVR_SELECT"}),
                          .msg            ("Illegal XcvrSelect at level2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));

          
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_PHY
        M_USB_2_0_UTMI_ILLEGAL_TX_VALIDH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tx_vald_h_without_tx_valid))));
        M_USB_2_0_UTMI_DATA_CHANGE_BEFORE_TX_READY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_data_changed_before_sampling &&
                           (DEVICE_SPEED !== 0 ||(xcvr_select === 1'b1 && term_select === 1'b1)))))));
        M_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MIN_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( receive_to_transmit_delay_violation_min))));
        M_USB_2_0_UTMI_RX_DEASSERT_TO_TX_VALID_ASSERT_MAX_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( receive_to_transmit_delay_violation_max))));
        M_USB_2_0_UTMI_SUSPENDM_TERM_SELECT_FS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((suspendm === 1'b0 && term_select !== 1'b1))));
        M_USB_2_0_UTMI_ILLEGAL_OP_MODE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((op_mode === 2'b11 && UTMI_LEVEL == 0))));
        M_USB_2_0_UTMI_SUSPENDM_NEGATION_RESET_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (present_state_reset === ZI_SUSPEND_STATE && line_state === ZI_SE0_STATE && suspendm === 1'b0)));
        M_USB_2_0_UTMI_ILLEGAL_COMB_OP_MODE_XCVR_SELECT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (op_mode === 2'b11 && xcvr_select !== 'd0))));
        M_USB_2_0_UTMI_DP_PULLDOWN_VALUE_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (((PORT_TYPE == 1 || PORT_TYPE == 3) && dp_pulldown === 1'b1) || 
                                     ((PORT_TYPE == 0 || PORT_TYPE == 2) && dp_pulldown === 1'b0)))));
        M_USB_2_0_UTMI_DM_PULLDOWN_VALUE_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL > 0 && (((PORT_TYPE == 1 || PORT_TYPE == 3) && dm_pulldown === 1'b1) || 
                                     ((PORT_TYPE == 0 || PORT_TYPE == 2) && dm_pulldown === 1'b0)))));
        M_USB_2_0_UTMI_ILLEGAL_XCVR_SELECT:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (UTMI_LEVEL == 2 && xcvr_select === 'd3))); 
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PHY
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

generate 
  case (PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_PHY
        A_USB_2_0_UTMI_TX_VALID_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_valid),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALID_KNOWN_DRIVEN"}),
                          .msg            ("TXValid is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TX_VALIDH_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_valid_h),
                          .qualifier (((tx_valid === 1'b1 && databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALIDH_KNOWN_DRIVEN"}),
                          .msg            ("TXValidH is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DATA_IN_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr ((latched_databus16_8?{data_in_low_actual,data_in_high_actual}:{8'b00,data_in_low_actual})),
                          .qualifier (((tx_valid === 1'b1 && BI_DIRECTIONAL == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_IN_KNOWN_DRIVEN"}),
                          .msg            ("DataIn is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DATABUS16_8_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (databus16_8),
                          .qualifier (((DEVICE_SPEED == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATABUS16_8_KNOWN_DRIVEN"}),
                          .msg            ("DataBus16_8 is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_XCVR_SELECT_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (xcvr_select),
                          .qualifier (((DEVICE_SPEED == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_XCVR_SELECT_KNOWN_DRIVEN"}),
                          .msg            ("XcvrSelect is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_TERM_SELECT_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (term_select),
                          .qualifier (((DEVICE_SPEED == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TERM_SELECT_KNOWN_DRIVEN"}),
                          .msg            ("TermSelect is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DRV_VBUS_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (drv_vbus),
                          .qualifier (((OTG_DEVICE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DRV_VBUS_KNOWN_DRIVEN"}),
                          .msg            ("DrvVbus is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_CHRG_VBUS_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (chrg_vbus),
                          .qualifier (((OTG_DEVICE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_CHRG_VBUS_KNOWN_DRIVEN"}),
                          .msg            ("ChrgVbus is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DISCHRG_VBUS_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dischrg_vbus),
                          .qualifier (((OTG_DEVICE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DISCHRG_VBUS_KNOWN_DRIVEN"}),
                          .msg            ("DischrgVbus is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_ID_PULLUP_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dischrg_vbus),
                          .qualifier (((OTG_DEVICE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ID_PULLUP_KNOWN_DRIVEN"}),
                          .msg            ("IdPullup is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DP_PULLDOWN_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp_pulldown),
                          .qualifier (((UTMI_LEVEL != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DP_PULLDOWN_KNOWN_DRIVEN"}),
                          .msg            ("DpPulldown is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_USB_2_0_UTMI_DM_PULLDOWN_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm_pulldown),
                          .qualifier (((UTMI_LEVEL != 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DM_PULLDOWN_KNOWN_DRIVEN"}),
                          .msg            ("DmPulldown is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_PHY 
        M_USB_2_0_UTMI_TX_VALID_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_valid),
                          .qualifier (( 1'b1))));
        M_USB_2_0_UTMI_TX_VALIDH_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (tx_valid_h),
                          .qualifier (((tx_valid === 1'b1 && databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_DATA_IN_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr ((latched_databus16_8?{data_in_low_actual,data_in_high_actual}:{8'b00,data_in_low_actual})),
                          .qualifier (((tx_valid === 1'b1 && BI_DIRECTIONAL == 0)))));
        M_USB_2_0_UTMI_DATABUS16_8_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (databus16_8),
                          .qualifier (((DEVICE_SPEED == 0)))));
        M_USB_2_0_UTMI_XCVR_SELECT_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (xcvr_select),
                          .qualifier (((DEVICE_SPEED == 0)))));
        M_USB_2_0_UTMI_TERM_SELECT_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (term_select),
                          .qualifier (((DEVICE_SPEED == 0)))));
        M_USB_2_0_UTMI_DRV_VBUS_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (drv_vbus),
                          .qualifier (((OTG_DEVICE == 1)))));
        M_USB_2_0_UTMI_CHRG_VBUS_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (chrg_vbus),
                          .qualifier (((OTG_DEVICE == 1)))));
        M_USB_2_0_UTMI_DISCHRG_VBUS_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dischrg_vbus),
                          .qualifier (((OTG_DEVICE == 1)))));
        M_USB_2_0_UTMI_ID_PULLUP_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (id_pullup),
                          .qualifier (((OTG_DEVICE == 1)))));
        M_USB_2_0_UTMI_DP_PULLDOWN_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp_pulldown),
                          .qualifier (((UTMI_LEVEL != 1)))));
        M_USB_2_0_UTMI_DM_PULLDOWN_KNOWN_DRIVEN: 
          assume property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm_pulldown),
                          .qualifier (((UTMI_LEVEL != 0)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_PHY 
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
  case (Constraints_Mode)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_CM
        A_USB_2_0_UTMI_TX_VALID_RX_ACTIVE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_valid === 1'b1 && rx_active === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TX_VALID_RX_ACTIVE_ASSERTED"}),
                          .msg            ("TXValid and RXActive signal should not be asserted together."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_ON_THE_GO_SUPPORT_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (first_clock_after_reset === 1'b1 && 
                                      UTMI_LEVEL == 0 && OTG_DEVICE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ON_THE_GO_SUPPORT_ERROR"}),
                          .msg            ("UTM interface at Level 0 does not support On-The-Go devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_NUMBER_OF_ENDPOINTS_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((first_clock_after_reset === 1'b1 &&
                           ((NUMBER_OF_ENDPOINTS > 31 && DEVICE_SPEED != 2) ||
                           (NUMBER_OF_ENDPOINTS > 3 && DEVICE_SPEED == 2)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_NUMBER_OF_ENDPOINTS_ERROR"}),
                          .msg            ("Maximum number of end points supported is 31 for full/high speed devices and 3 for low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DATABUS16_8_LEVEL_CHANGE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( latched_databus16_8 !== databus16_8 &&
                           first_clock_after_reset == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATABUS16_8_LEVEL_CHANGE"}),
                          .msg            ("Signal 'databus16_8' should not be toggled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_SESS_NOT_VALID_FOR_NORMAL_OPER:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (sess_not_valid_for_normal_oper)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SESS_NOT_VALID_FOR_NORMAL_OPER"}),
                          .msg            ("Valid session not in progress for doing normal operation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_END_PREV_SESS_BEFORE_NEW_SESS_REQ_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (end_prev_sess_before_new_sess_req )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_END_PREV_SESS_BEFORE_NEW_SESS_REQ_ERROR"}),
                          .msg            ("Previous session must be over before requesting new session."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DEV_DISCONN_BEFORE_SRP_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_disconn_before_srp_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DEV_DISCONN_BEFORE_SRP_ERROR"}),
                          .msg            ("Device must be disconnected before starting session request protocol."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_SRP_AT_NON_FULL_SPEED:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (srp_initiated_at_wrong_speed)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SRP_AT_NON_FULL_SPEED"}),
                          .msg            ("Session request protocol not initiated at full speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_VBUS_AND_DATA_LINE_PULSING_ORDER_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (pulsing_order_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_VBUS_AND_DATA_LINE_PULSING_ORDER_ERROR"}),
                          .msg            ("Session request protocol not initiated at full speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DATA_LINE_PULSE_DURATION_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (data_line_pulse_duration_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_LINE_PULSE_DURATION_ERROR"}),
                          .msg            ("Data-line pulse duration violated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_INVALID_CHIRP_SEQUENCE:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_chirp_sequence)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_INVALID_CHIRP_SEQUENCE"}),
                          .msg            ("Chirp sequence for high speed detection is invalid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_TIMEOUT_KJ_CHIRP_DURATION:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (chirp_kj_duration_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TIMEOUT_KJ_CHIRP_DURATION"}),
                          .msg            ("Chirp duration for K or J driven by the hub during High speed detection sequence, has timed out."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_J_STATE_DURING_DEV_K_CHIRP:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (device_j_state_during_chirping)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_J_STATE_DURING_DEV_K_CHIRP"}),
                          .msg            ("Line state has transitioned to J state while device was sending K chirp during speed detect sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DEV_INITIATE_WITH_J_DURING_CHIRP:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (device_initiated_with_j_during_chirp)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DEV_INITIATE_WITH_J_DURING_CHIRP"}),
                          .msg            ("Line state has transitioned to J state in order to begin chirping by the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_TERM_SEL_DEASSERT_TIMEOUT:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (term_sel_deassert_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_TERM_SEL_DEASSERT_TIMEOUT"}),
                          .msg            ("term_select signal did not change to low level before 500us after detecting the device as a high speed device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_FULL_SPEED_REVERSAL_ERROR:
          assert property ( ASSERT_NEVER_P (
                            .clock (clock ),
                            .reset_n   ((!areset && !reset) ),
                            .enable    (1'b1),
                            .test_expr (full_speed_reversal_err)))
          else qvl_error_t(
                            .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_FULL_SPEED_REVERSAL_ERROR"}),
                            .msg            ("Full speed reversal timeout."),
                            .severity_level (QVL_ERROR),
                            .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_CHIRP_KJ_START_DELAY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (chirp_kj_seq_start_delay_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_CHIRP_KJ_START_DELAY"}),
                          .msg            ("ChirpKJ not asserted by downstream port within legal limit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DEV_CHIRP_DEASSERT_MAX_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_deassert_max))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DEV_CHIRP_DEASSERT_MAX_DELAY"}),
                          .msg            ("Device chirp on bus after legal limit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DEV_CHIRP_ASSERT_MAX_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_assert_max))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DEV_CHIRP_ASSERT_MAX_DELAY"}),
                          .msg            ("Device ChirpK assertion timeout"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DEV_CHIRP_SUSPEND_ASSERT_MAX_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_suspend_assert_max))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DEV_CHIRP_SUSPEND_ASSERT_MAX_DELAY"}),
                          .msg            ("Device ChirpK assertion timeout after entering reset handshake from suspend state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_SUSPENDM_ASSERT_MAX_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (suspendm_assert_max))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SUSPENDM_ASSERT_MAX_DELAY"}),
                          .msg            ("SuspendM not asserted within legal limit after detecting suspend mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_REMOTE_WAKE_UP_MIN_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (remote_wake_up_min_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_REMOTE_WAKE_UP_MIN_DELAY"}),
                          .msg            ("Early remote wakeup signaling"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));

        A_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MAX_DURATION_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_max_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MAX_DURATION_ERROR"}),
                          .msg            ("Illegally long resume signaling asserted on the bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MIN_DURATION_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_min_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MIN_DURATION_ERROR"}),
                          .msg            ("Illegally short resume signaling asserted on the bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_SPEED_MISMATCH_AFTER_RESUME:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (speed_mismatch_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SPEED_MISMATCH_AFTER_RESUME"}),
                          .msg            ("Speed mismatch between pre suspend and post resume."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_RESUME_NORMAL_OPER_MAX_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_normal_operation_max))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RESUME_NORMAL_OPER_MAX_ERROR"}),
                          .msg            ("Normal operation  timeout after resume release."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_RESUME_K_DURATION_MIN_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_K_duration_min_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RESUME_K_DURATION_MIN_ERROR"}),
                          .msg            ("Resume K not seen on the bus for minimum legal duration"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_SE0_ASSERT_TO_END_RESUME_COUNT_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (se0_after_resume_K_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_SE0_ASSERT_TO_END_RESUME_COUNT_ERROR"}),
                          .msg            ("SE0 not seen on the bus at expected time after resume K is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_REMOTE_WAKE_UP_MAX_DELAY:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_delay_max_violation))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_REMOTE_WAKE_UP_MAX_DELAY"}),
                          .msg            ("FS K is not asserted within legal limit after suspendM is negated."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_RESET_INTERVAL_MIN_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (reset_interval_min))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_RESET_INTERVAL_MIN_ERROR"}),
                          .msg            ("Minimum reset interval violated."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_ILLEGAL_PORT_TYPE_LEVEL_0:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (first_clock_after_reset === 1'b1 && 
                                      UTMI_LEVEL === 0 && (PORT_TYPE === 0 || 
                                      PORT_TYPE === 2)))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_ILLEGAL_PORT_TYPE_LEVEL_0"}),
                          .msg            ("UTMI level 0 can only operate in peripheral mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_HOST_RECEIVED_SOF_WITHOUT_HNP:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (sof_pkt_received_from_device === 1'b1))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_HOST_RECEIVED_SOF_WITHOUT_HNP"}),
                          .msg            ("SOF cannot be received from the device before Host negotiation protocol."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_CM
        M_USB_2_0_UTMI_TX_VALID_RX_ACTIVE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tx_valid === 1'b1 && rx_active === 1'b1)))));
        M_USB_2_0_UTMI_ON_THE_GO_SUPPORT_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (first_clock_after_reset === 1'b1 && 
                                      UTMI_LEVEL == 0 && OTG_DEVICE == 1)));
        M_USB_2_0_UTMI_NUMBER_OF_ENDPOINTS_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((first_clock_after_reset === 1'b1 &&
                           ((NUMBER_OF_ENDPOINTS > 31 && DEVICE_SPEED != 2) ||
                           (NUMBER_OF_ENDPOINTS > 3 && DEVICE_SPEED == 2)))))));
        M_USB_2_0_UTMI_DATABUS16_8_LEVEL_CHANGE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( latched_databus16_8 !== databus16_8 &&
                           first_clock_after_reset == 1'b0))));
        M_USB_2_0_UTMI_SESS_NOT_VALID_FOR_NORMAL_OPER:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (sess_not_valid_for_normal_oper)));
        M_USB_2_0_UTMI_END_PREV_SESS_BEFORE_NEW_SESS_REQ_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (end_prev_sess_before_new_sess_req)));
        M_USB_2_0_UTMI_DEV_DISCONN_BEFORE_SRP_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_disconn_before_srp_violation)));
        M_USB_2_0_UTMI_SRP_AT_NON_FULL_SPEED:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (srp_initiated_at_wrong_speed)));
        M_USB_2_0_UTMI_VBUS_AND_DATA_LINE_PULSING_ORDER_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (pulsing_order_violation)));
        M_USB_2_0_UTMI_DATA_LINE_PULSE_DURATION_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (data_line_pulse_duration_violation)));
        M_USB_2_0_UTMI_INVALID_CHIRP_SEQUENCE:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (invalid_chirp_sequence)));
        M_USB_2_0_UTMI_TIMEOUT_KJ_CHIRP_DURATION:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (chirp_kj_duration_timeout)));
        M_USB_2_0_UTMI_J_STATE_DURING_DEV_K_CHIRP:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (device_j_state_during_chirping)));
        M_USB_2_0_UTMI_DEV_INITIATE_WITH_J_DURING_CHIRP:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (device_initiated_with_j_during_chirp)));
        M_USB_2_0_UTMI_TERM_SEL_DEASSERT_TIMEOUT:
          assume property ( ASSERT_NEVER_P (
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (term_sel_deassert_timeout)));
        M_USB_2_0_UTMI_FULL_SPEED_REVERSAL_ERROR:
          assume property ( ASSERT_NEVER_P (
                          .clock (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (full_speed_reversal_err)));
        M_USB_2_0_UTMI_CHIRP_KJ_START_DELAY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (chirp_kj_seq_start_delay_violation)));
        M_USB_2_0_UTMI_DEV_CHIRP_DEASSERT_MAX_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_deassert_max))); 
        M_USB_2_0_UTMI_DEV_CHIRP_ASSERT_MAX_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_assert_max))); 
        M_USB_2_0_UTMI_DEV_CHIRP_SUSPEND_ASSERT_MAX_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (dev_chirp_k_suspend_assert_max))); 
        M_USB_2_0_UTMI_SUSPENDM_ASSERT_MAX_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (suspendm_assert_max))); 
        M_USB_2_0_UTMI_REMOTE_WAKE_UP_MIN_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (remote_wake_up_min_violation))); 
        M_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MAX_DURATION_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_max_violation))); 
        M_USB_2_0_UTMI_RESUME_SIGNAL_ASSERT_MIN_DURATION_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_min_violation))); 
        M_USB_2_0_UTMI_SPEED_MISMATCH_AFTER_RESUME:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (speed_mismatch_violation))); 
        M_USB_2_0_UTMI_RESUME_NORMAL_OPER_MAX_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_normal_operation_max))); 
        M_USB_2_0_UTMI_RESUME_K_DURATION_MIN_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_K_duration_min_violation)));
        M_USB_2_0_UTMI_SE0_ASSERT_TO_END_RESUME_COUNT_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (se0_after_resume_K_violation))); 
        M_USB_2_0_UTMI_REMOTE_WAKE_UP_MAX_DELAY:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (resume_signal_delay_max_violation)));
        M_USB_2_0_UTMI_RESET_INTERVAL_MIN_ERROR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (reset_interval_min))); 
        M_USB_2_0_UTMI_ILLEGAL_PORT_TYPE_LEVEL_0:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (first_clock_after_reset === 1'b1 && 
                                      UTMI_LEVEL == 0 && (PORT_TYPE == 0 || 
                                      PORT_TYPE == 2)))); 
        M_USB_2_0_UTMI_HOST_RECEIVED_SOF_WITHOUT_HNP:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (sof_pkt_received_from_device == 1'b1))); 
    end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_CM
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

generate 
  case (Constraints_Mode)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN_CM
        A_USB_2_0_UTMI_DATA_LOW_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (data_low),
                          .qualifier (((BI_DIRECTIONAL == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_LOW_KNOWN_DRIVEN"}),
                          .msg            ("Data[7:0] bus is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_DATA_HIGH_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (data_high),
                          .qualifier (((BI_DIRECTIONAL == 1 && latched_databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_DATA_HIGH_KNOWN_DRIVEN"}),
                          .msg            ("Data[15:8] bus is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_UTMI_VALIDH_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (valid_h),
                          .qualifier (((BI_DIRECTIONAL == 1 && latched_databus16_8 === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_UTMI_VALIDH_KNOWN_DRIVEN"}),
                          .msg            ("ValidH is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_CM
        M_USB_2_0_UTMI_DATA_LOW_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (data_low),
                          .qualifier (((BI_DIRECTIONAL == 1)))));
        M_USB_2_0_UTMI_DATA_HIGH_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (data_high),
                          .qualifier (((BI_DIRECTIONAL == 1 && latched_databus16_8 === 1'b1)))));
        M_USB_2_0_UTMI_VALIDH_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (valid_h),
                          .qualifier (((BI_DIRECTIONAL == 1 && latched_databus16_8 === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN_CM
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
  case (ZI_DEVICE_SIDE_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_ZID
        A_USB_2_0_TKN_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tkn_pkt_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_TKN_PKT_SIZE_ERR"}),
                          .msg            ("Token packets should have 24 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SPLIT_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( split_tkn_pkt_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SPLIT_PKT_SIZE_ERR"}),
                          .msg            ("A SPLIT token should have 32 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && host_is_transmitting)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST"}),
                          .msg            ("A handshake packet should have only 8 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_ZID
        M_USB_2_0_TKN_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tkn_pkt_size_err))));
        M_USB_2_0_SPLIT_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( split_tkn_pkt_size_err))));
        M_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && host_is_transmitting)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZID
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate


generate 
  case (ZI_HOST_SIDE_CONSTRAINT)
    `QVL_ASSERT :
      begin : qvl_assert_ASSERT_NEVER_ZIH
        A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && device_is_transmitting)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE"}),
                          .msg            ("A handshake packet should have only 8 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
      end
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_ZIH
        M_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && device_is_transmitting)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZIH
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate

`endif // QVL_ASSERT_ON
