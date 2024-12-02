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

  parameter QVL_MSG = "PCI Express Violation : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //{32{1'b1}}; //`OVL_COVER_NONE;

  wire not_rx_link_clk = !rx_link_clk;
  wire not_tx_link_clk = !tx_link_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //-------------------------------------------------------------------------
  // Check Name : PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP - No : 17
  // Check Name : PCI_EXPRESS_INCR_SEQ_NUM_TLP - No : 18
  // Check Name : PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP - No : 19
  // Check Name : PCI_EXPRESS_RETRY_TLPs - No : 20
  // Check Name : PCI_EXPRESS_REPLAY_TIMER_NOT_EXPIRED - No : 21
  // Check Name : PCI_EXPRESS_ALL_OLD_TLPs_RETRY - No : 22
  // Check Name : PCI_EXPRESS_RETRY_AFTER_NAK - No : 23
  // Check Name : PCI_EXPRESS_MAX_UNACKD_TLP - No : 24
  // Check Name : PCI_EXPRESS_REPLAY_NUM_EXPIRED - No : 25
  // Check Name : PCI_EXPRESS_ACKNAK_SEQ_NUM - No : 26
  // Check Name : PCI_EXPRESS_ACKNAK_TIMER_EXPIRED - No : 27
  // Check Name : PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP - No : 28
  // Check Name : PCI_EXPRESS_NO_NAK_DLLP_FOR_TLP - No : 29
  //-------------------------------------------------------------------------

// Assert only checks

        A_PCI_EXPRESS_ACKNAK_TIMER_EXPIRED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up && TX_DLLP_RX_TLP_SIDE)) 
                           &&( acknak_timer_expired))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACKNAK_TIMER_EXPIRED_P"}),
                          .msg            ("Received TL packet should be acknowledged by either Ack or Nak DLL packet before the expiry of the Ack_Nak timer"),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ACKNAK_TIMER_EXPIRED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && TX_DLLP_RX_TLP_SIDE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( acknak_timer_expired))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACKNAK_TIMER_EXPIRED_N"}),
                          .msg            ("Received TL packet should be acknowledged by either Ack or Nak DLL packet before the expiry of the Ack_Nak timer"),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NO_NAK_DLLP_FOR_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up && TX_DLLP_RX_TLP_SIDE)) 
                           &&( fire_no_nak_dllp_for_tlp))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_NAK_DLLP_FOR_TLP_P"}),
                          .msg            ("Transmitter should send an Ack DLLP for TLPs received without error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NO_NAK_DLLP_FOR_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up && 
                           TX_DLLP_RX_TLP_SIDE)) 
                           &&( fire_no_nak_dllp_for_tlp))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_NAK_DLLP_FOR_TLP_N"}),
                          .msg            ("Transmitter should send an Ack DLLP for TLPs received without error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));

// Checks based on Constraints_Mode && TX_DLLP_RX_TLP_SIDE
generate
  case (Constraints_Mode && TX_DLLP_RX_TLP_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_TX_DLLP_RX_TLP_SIDE 
        A_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && link_up)) && (fire_tlp_seq_num_after_link_up_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_P"}),
                          .msg            ("Sequence number of the first TL packet detected should be '0000_0000_0000'"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up))
                           &&( fire_tlp_seq_num_after_link_up_error))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_N"}),
                          .msg            ("Sequence number of the first TL packet detected should be '0000_0000_0000'"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_INCR_SEQ_NUM_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) && 
                           ((fire_expected_tlp_seq_num_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INCR_SEQ_NUM_TLP_P"}),
                          .msg            ("Sequence numbers in the successive TLPs should be in the increasing order."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_INCR_SEQ_NUM_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INCR_SEQ_NUM_TLP_N"}),
                          .msg            ("Sequence numbers in the successive TLPs should be in the increasing order."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) 
                           &&((fire_tlp_seq_num_after_null_tlp_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_P"}),
                          .msg            ("Sequence number of the TLP following the nullified TLP should be same as that of nullified TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_tlp_seq_num_after_null_tlp_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_N"}),
                          .msg            ("Sequence number of the TLP following the nullified TLP should be same as that of nullified TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_TLPs_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((link_layer_checks_disable !== 1'b1 && phy_status && link_up)) && ((replay_num >= 2 && !retry_progress)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_TLPs_P"}),
                          .msg            ("Transmitter should retransmit the retry buffer starting from the oldest unacknowledged TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_TLPs_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) &&
                           ((replay_num >= 2 && !retry_progress)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_TLPs_N"}),
                          .msg            ("Transmitter should retransmit the retry buffer starting from the oldest unacknowledged TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) &&
                           (((detected_bad_seq_num || ended_bad_seq_num) &&
                           !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_P"}),
                          .msg            ("The data link layer should not re-transmit the TLPs from the retry buffer without the expiry of the replay timer or a nak."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&(((detected_bad_seq_num || ended_bad_seq_num) && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_N"}),
                          .msg            ("The data link layer should not re-transmit the TLPs from the retry buffer without the expiry of the replay timer or a nak."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up))
                           &&((fire_expected_tlp_seq_num_error && retry_progress_temp && 
                           !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_P"}),
                          .msg            ("Once re-transmission of retry buffer is initiated then all the contents of the retry buffer should be retransmitted before transmitting the new TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_expected_tlp_seq_num_error && retry_progress_temp &&
                           !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_N"}),
                          .msg            ("Once re-transmission of retry buffer is initiated then all the contents of the retry buffer should be retransmitted before transmitting the new TLP."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_AFTER_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up &&(present_retry_state == ZI_RETRY_AFTER_NAK_STATE))) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_AFTER_NAK_P"}),
                          .msg            ("Transmitter should re-transmit TLPs from retry buffer after receiving a NAK."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_RETRY_AFTER_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up &&
                           (present_retry_state == ZI_RETRY_AFTER_NAK_STATE))) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RETRY_AFTER_NAK_N"}),
                          .msg            ("Transmitter should re-transmit TLPs from retry buffer after receiving a NAK."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_MAX_UNACKD_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&((num_outstanding_tlps > 2047)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_UNACKD_TLP_P"}),
                          .msg            ("Maximum number of unacknowledged TLPs should not exceed 2048"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_MAX_UNACKD_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE &&
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) &&
                           ((num_outstanding_tlps > 2047)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_UNACKD_TLP_N"}),
                          .msg            ("Maximum number of unacknowledged TLPs should not exceed 2048"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&TX_DLLP_RX_TLP_SIDE)));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_TX_DLLP_RX_TLP_SIDE 
        M_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && link_up)) && (fire_tlp_seq_num_after_link_up_error))));
        M_PCI_EXPRESS_FIRST_TLP_AFTER_LINK_UP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up))
                           &&( fire_tlp_seq_num_after_link_up_error))))));
        M_PCI_EXPRESS_INCR_SEQ_NUM_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) && 
                           ((fire_expected_tlp_seq_num_error && !retry_scheduled)))));
        M_PCI_EXPRESS_INCR_SEQ_NUM_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))));
        M_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) 
                           &&((fire_tlp_seq_num_after_null_tlp_error && !retry_scheduled)))));
        M_PCI_EXPRESS_SEQ_NUM_AFTER_NULL_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_tlp_seq_num_after_null_tlp_error && !retry_scheduled)))));
        M_PCI_EXPRESS_RETRY_TLPs_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((link_layer_checks_disable !== 1'b1 && phy_status && link_up)) && ((replay_num >= 2 && !retry_progress)))))));
        M_PCI_EXPRESS_RETRY_TLPs_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) &&
                           ((replay_num >= 2 && !retry_progress)))));
        M_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) &&
                           (((detected_bad_seq_num || ended_bad_seq_num) &&
                           !retry_scheduled)))));
        M_PCI_EXPRESS_RETRY_WITHOUT_REPLAY_OR_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&(((detected_bad_seq_num || ended_bad_seq_num) && !retry_scheduled)))));
        M_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up))
                           &&((fire_expected_tlp_seq_num_error && retry_progress_temp && 
                           !retry_scheduled)))));
        M_PCI_EXPRESS_ALL_OLD_TLPs_RETRANSMITTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&((fire_expected_tlp_seq_num_error && retry_progress_temp &&
                           !retry_scheduled)))));
        M_PCI_EXPRESS_RETRY_AFTER_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up &&(present_retry_state == ZI_RETRY_AFTER_NAK_STATE))) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))));
        M_PCI_EXPRESS_RETRY_AFTER_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up &&
                           (present_retry_state == ZI_RETRY_AFTER_NAK_STATE))) 
                           &&((fire_expected_tlp_seq_num_error && !retry_scheduled)))));
        M_PCI_EXPRESS_MAX_UNACKD_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&((num_outstanding_tlps > 2047)))));
        M_PCI_EXPRESS_MAX_UNACKD_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE &&
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) &&
                           ((num_outstanding_tlps > 2047)))));
      end

    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Checks based on Constraints_Mode && !TX_DLLP_RX_TLP_SIDE
generate
  case (Constraints_Mode && !TX_DLLP_RX_TLP_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_NOT_TX_DLLP_RX_TLP_SIDE 
        A_PCI_EXPRESS_REPLAY_NUM_EXPIRED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) && (replay_num_elapsed))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_REPLAY_NUM_EXPIRED_P"}),
                          .msg            ("Replay num counter has been expired without receiving an Ack/Nak DLLP for the re-transmitted TLPs from the retry buffer"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_REPLAY_NUM_EXPIRED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( replay_num_elapsed))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_REPLAY_NUM_EXPIRED_N"}),
                          .msg            ("Replay num counter has been expired without receiving an Ack/Nak DLLP for the re-transmitted TLPs from the retry buffer"),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_ACKNAK_SEQ_NUM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&( fire_acknak_seq_number_mismatch))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACKNAK_SEQ_NUM_P"}),
                          .msg            ("The AckNak sequence number of the transmitted DLLP should match with the sequence number of any of the TLPs in the retry buffer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_ACKNAK_SEQ_NUM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( fire_acknak_seq_number_mismatch))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACKNAK_SEQ_NUM_N"}),
                          .msg            ("The AckNak sequence number of the transmitted DLLP should match with the sequence number of any of the TLPs in the retry buffer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&( fire_no_ack_dllp_for_bad_tlp))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_P"}),
                          .msg            ("Transmitter should send a Nak DLLP for TLPs received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
        A_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( fire_no_ack_dllp_for_bad_tlp))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_N"}),
                          .msg            ("Transmitter should send a Nak DLLP for TLPs received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode&&!TX_DLLP_RX_TLP_SIDE)));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_NOT_TX_DLLP_RX_TLP_SIDE
        M_PCI_EXPRESS_REPLAY_NUM_EXPIRED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           phy_status && link_up)) && (replay_num_elapsed))));
        M_PCI_EXPRESS_REPLAY_NUM_EXPIRED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( replay_num_elapsed))));
        M_PCI_EXPRESS_ACKNAK_SEQ_NUM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&( fire_acknak_seq_number_mismatch))));
        M_PCI_EXPRESS_ACKNAK_SEQ_NUM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( fire_acknak_seq_number_mismatch))));
        M_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && phy_status && 
                           link_up)) &&( fire_no_ack_dllp_for_bad_tlp))));
        M_PCI_EXPRESS_NO_ACK_DLLP_FOR_BAD_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && phy_status && link_up)) 
                           &&( fire_no_ack_dllp_for_bad_tlp))));
      end

    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate
`endif // QVL_ASSERT_ON
