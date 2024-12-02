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
  parameter QVL_COVERAGE_LEVEL = 0; // `OVL_COVER_NONE;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

generate
  case (ZI_DEVICE_SIDE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PKT_ZID 
        A_USB_2_0_PKT_ID_CHK_FIELD_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pkt_id_check_field_error === 1'b1 && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PKT_ID_CHK_FIELD_ERR_HOST"}),
                          .msg            ("Packet ID check field should be one's complement of the packet ID field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_PKT_ID_NOT_DEFINED_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pid_undefined === 1'b1 && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PKT_ID_NOT_DEFINED_HOST"}),
                          .msg            ("Illegal packet ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_DATA2_MDATA_FOR_NON_ISO_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((mdata_data2_pid_detected && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA2_MDATA_FOR_NON_ISO_HOST"}),
                          .msg            ("Packet ID MDATA and DATA2 should be used for high speed, high bandwidth isochronous end points only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_ILLEGAL_TOKEN_ON_FULL_SPD_LINK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_pkt_id_on_full_low_speed_link)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_TOKEN_ON_FULL_SPD_LINK"}),
                          .msg            ("Packet ID SPLIT, MDATA, DATA2, PING, ERR, NYET is not allowed on a full/low speed link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_PRE_PID_ISSUED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( pre_pid_on_low_speed_link))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PRE_PID_ISSUED"}),
                          .msg            ("PRE packets should not be issued on low/high speed interfaces."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_FRAME_NUMBER_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( frame_number_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_FRAME_NUMBER_ERR"}),
                          .msg            ("Illegal frame number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SPLIT_TKN_S_BIT_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_s_bit && speed === 2'b11)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SPLIT_TKN_S_BIT_ERROR"}),
                          .msg            ("Illegal 's' bit in the SPLIT token. Expected 's' bit is 1'b0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SPLIT_TKN_E_BIT_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_e_bit && speed === 2'b11)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SPLIT_TKN_E_BIT_ERROR"}),
                          .msg            ("Illegal 'e' bit in the SPLIT token. Expected 'e' bit is 1'b0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_CSPLIT_TKN_U_BIT_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((u_bit_error && speed === 2'b11)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CSPLIT_TKN_U_BIT_ERROR"}),
                          .msg            ("Illegal 'u' bit in the Complete-SPLIT token."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_TKN_CRC_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tkn_crc_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_TKN_CRC_ERR"}),
                          .msg            ("Token packet CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SOF_PKTS_AT_IRREGULAR_INTERVALS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( frame_interval_count_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SOF_PKTS_AT_IRREGULAR_INTERVALS"}),
                          .msg            ("SOF packets should be detected every 1ms for a full speed bus, and once in every 125us for high speed bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((sof_issued_on_low_speed_link && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE"}),
                          .msg            ("SOF packets should not be issued to low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_DATA_CRC_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data_crc_err && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA_CRC_ERR_HOST"}),
                          .msg            ("Data packet CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HOST_ISSUED_ILLEGAL_HANDSHAKE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_handshake_by_host))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HOST_ISSUED_ILLEGAL_HANDSHAKE"}),
                          .msg            ("Host returned STALL, NAK, NYET, ERR handshake packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ack_issued_by_host_during_non_in_transaction))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR"}),
                          .msg            ("A host can issue ACK handshake only during IN transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_PING_NEXT_TRANSACTION_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( out_did_not_follow_ping))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PING_NEXT_TRANSACTION_ERROR"}),
                          .msg            ("OUT transaction did not follow succesful PING."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_PING_NOT_INITIATED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ping_did_not_follow_out))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PING_NOT_INITIATED"}),
                          .msg            ("Host must issue PING token to a Control/Bulk OUT end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_DATA_PID_ERR_ISO_XFR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_data0_pid_detected && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA_PID_ERR_ISO_XFR_HOST"}),
                          .msg            ("An isochronous transfer should always use DATA0 packet ID during transmission of data packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_TOKEN_BEFORE_TIMEOUT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( host_issued_token_before_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_TOKEN_BEFORE_TIMEOUT"}),
                          .msg            ("Host should wait for specified number of bit times to indicate timeout."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
         A_USB_2_0_HOST_RESPONDS_FOR_ERR_PKT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( host_responded_for_err_data_pkt))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HOST_RESPONDS_FOR_ERR_PKT"}),
                          .msg            ("Host should not respond for packets received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
          A_USB_2_0_SETUP_DATA_PID_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_data_pid_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SETUP_DATA_PID_ERR"}),
                          .msg            ("Setup data should always contain DATA0 packet id."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data1_pid_in_status_phase && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_HOST"}),
                          .msg            ("STATUS phase of data transfer should always contain DATA1 packet id."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((host_issued_token_before_xfr_complete && host_tx))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE"}),
                          .msg            ("A Host should not issue a token before the completion of the current transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_HOST"}),
                          .msg            ("Sequence bit mismatch occured in control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_BULK_XFR_SEQ_BIT_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bulk_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BULK_XFR_SEQ_BIT_ERR_HOST"}),
                          .msg            ("Sequence bit mismatch occured in bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_INT_XFR_SEQ_BIT_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((int_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INT_XFR_SEQ_BIT_ERR_HOST"}),
                          .msg            ("Sequence bit mismatch occured in interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_BULK_XFR_DATA_PID_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_bulk_pkt && SEQUENCE_BIT_TRACKING_ENABLE && host_tx && device_addressed)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BULK_XFR_DATA_PID_ERR_HOST"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of a bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_INT_XFR_DATA_PID_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_int_pkt && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INT_XFR_DATA_PID_ERR_HOST"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of an interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_data_phase_length_err && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_HOST"}),
                          .msg            ("A Host or Device should transfer only 'wlength' number of bytes during the data phase of control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_WMAX_PKT_SIZE_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((wmax_pkt_size_violation && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_WMAX_PKT_SIZE_ERR_HOST"}),
                          .msg            ("A host or device should not transfer more than the specified maximum number of bytes in the data packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SSPLIT_NO_PAYLOAD_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data_payload_for_start_split && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SSPLIT_NO_PAYLOAD_HOST"}),
                          .msg            ("A Start-SPLIT token issued to an isochronous end point with 'start', 'middle' or 'end' encoding must have data payload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_SETUP_DATA_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_data_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SETUP_DATA_SIZE_ERR"}),
                          .msg            ("SETUP data should always contain 8 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
   end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PKT_ZID 
        M_USB_2_0_PKT_ID_CHK_FIELD_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pkt_id_check_field_error === 1'b1 && host_tx)))));
         M_USB_2_0_PKT_ID_NOT_DEFINED_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pid_undefined === 1'b1 && host_tx)))));
        M_USB_2_0_DATA2_MDATA_FOR_NON_ISO_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((mdata_data2_pid_detected && host_tx)))));
        M_USB_2_0_ILLEGAL_TOKEN_ON_FULL_SPD_LINK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_pkt_id_on_full_low_speed_link)))));
        M_USB_2_0_PRE_PID_ISSUED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( pre_pid_on_low_speed_link))));
        M_USB_2_0_FRAME_NUMBER_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( frame_number_error))));
        M_USB_2_0_SPLIT_TKN_S_BIT_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_s_bit && speed === 2'b11)))));
        M_USB_2_0_SPLIT_TKN_E_BIT_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_e_bit && speed === 2'b11)))));
        M_USB_2_0_CSPLIT_TKN_U_BIT_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((u_bit_error && speed === 2'b11)))));
        M_USB_2_0_TKN_CRC_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( tkn_crc_err))));
        M_USB_2_0_SOF_PKTS_AT_IRREGULAR_INTERVALS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( frame_interval_count_error))));
        M_USB_2_0_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((sof_issued_on_low_speed_link && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_DATA_CRC_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data_crc_err && host_tx)))));
        M_USB_2_0_HOST_ISSUED_ILLEGAL_HANDSHAKE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_handshake_by_host))));
        M_USB_2_0_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ack_issued_by_host_during_non_in_transaction))));
        M_USB_2_0_PING_NEXT_TRANSACTION_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( out_did_not_follow_ping))));
        M_USB_2_0_PING_NOT_INITIATED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ping_did_not_follow_out))));
        M_USB_2_0_DATA_PID_ERR_ISO_XFR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_data0_pid_detected && host_tx)))));
        M_USB_2_0_TOKEN_BEFORE_TIMEOUT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( host_issued_token_before_timeout))));
        M_USB_2_0_HOST_RESPONDS_FOR_ERR_PKT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( host_responded_for_err_data_pkt))));
        M_USB_2_0_SETUP_DATA_PID_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_data_pid_err))));
        M_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data1_pid_in_status_phase && host_tx)))));
        M_USB_2_0_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( host_issued_token_before_xfr_complete))));
        M_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))));
        M_USB_2_0_BULK_XFR_SEQ_BIT_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bulk_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))));
        M_USB_2_0_INT_XFR_SEQ_BIT_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((int_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))));
        M_USB_2_0_BULK_XFR_DATA_PID_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_bulk_pkt && SEQUENCE_BIT_TRACKING_ENABLE && host_tx && device_addressed)))));
        M_USB_2_0_INT_XFR_DATA_PID_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_int_pkt && SEQUENCE_BIT_TRACKING_ENABLE && host_tx)))));
        M_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_data_phase_length_err && host_tx)))));
        M_USB_2_0_WMAX_PKT_SIZE_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((wmax_pkt_size_violation && host_tx)))));
        M_USB_2_0_SSPLIT_NO_PAYLOAD_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data_payload_for_start_split && host_tx)))));
        M_USB_2_0_SETUP_DATA_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_data_size_err))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PKT_ZID 
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
      begin : qvl_assert_ASSERT_NEVER_PKT_ZIH 
         A_USB_2_0_PKT_ID_CHK_FIELD_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pkt_id_check_field_error === 1'b1 && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PKT_ID_CHK_FIELD_ERR_DEVICE"}),
                          .msg            ("Packet ID check field should be one's complement of the packet ID field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_PKT_ID_NOT_DEFINED_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pid_undefined === 1'b1 && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PKT_ID_NOT_DEFINED_DEVICE"}),
                          .msg            ("Illegal packet ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_DATA2_MDATA_FOR_NON_ISO_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((mdata_data2_pid_detected && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA2_MDATA_FOR_NON_ISO_DEVICE"}),
                          .msg            ("Packet ID MDATA and DATA2 should be used for high speed, high bandwidth isochronous end points only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_DATA_CRC_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data_crc_err && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA_CRC_ERR_DEVICE"}),
                          .msg            ("Data packet CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_HIGH_SPEED_END_POINT_ISSUED_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( err_handshake_by_non_hub))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HIGH_SPEED_END_POINT_ISSUED_ERR"}),
                          .msg            ("A high speed end point returned ERR handshake packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_DEVICE_ISSUED_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( device_issued_token))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DEVICE_ISSUED_TKN"}),
                          .msg            ("A device should not issue token packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ack_issued_by_device_during_in_transaction))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR"}),
                          .msg            ("A device can issue ACK handshake only during non IN transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_HANDSHAKE_PKT_IN_ISO_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( handshake_pkt_iso_transfer_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HANDSHAKE_PKT_IN_ISO_XFR"}),
                          .msg            ("Handshake packets should not be generated for isochronous transfers."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_PING_HANDSHAKE_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_handshake_for_ping))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_PING_HANDSHAKE_ERROR"}),
                          .msg            ("High speed end points must respond with either NAK, ACK or STALL handshake."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_STALL_RECEIVE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stall_receive_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_STALL_RECEIVE_ERR"}),
                          .msg            ("If STALL handshake is received during data phase or status phase of control transfer, then successive access to that control endpoint should result in reception of stall handshake until the completion of next setup phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_DATA_PID_ERR_ISO_XFR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_data0_pid_detected && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DATA_PID_ERR_ISO_XFR_DEVICE"}),
                          .msg            ("An isochronous transfer should always use DATA0 packet ID during transmission of data packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_RESPONSE_FOR_OUT_SETUP_TOKEN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( response_received_for_out_setup_token))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_RESPONSE_FOR_OUT_SETUP_TOKEN"}),
                          .msg            ("Device should not respond with any packets on reception of OUT or SETUP token."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_FUNCTION_RESPONDS_FOR_ERR_PKT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_responded_for_err_pkt))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_FUNCTION_RESPONDS_FOR_ERR_PKT"}),
                          .msg            ("Function should not respond for packets received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_STALL_NAK_HANDSHAKE_FOR_SETUP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stall_nak_issued_to_setup_data))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_STALL_NAK_HANDSHAKE_FOR_SETUP"}),
                          .msg            ("Function should not respond with STALL or NAK handshake for setup data during control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_ACK_RECEIVED_FOR_IN_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_responded_with_ack_for_in_tkn))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ACK_RECEIVED_FOR_IN_TKN"}),
                          .msg            ("Function should not respond with ACK handshake for IN token."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_NO_ACK_HANDSHAKE_FOR_SETUP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_not_responded_with_ack_for_setup_data))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NO_ACK_HANDSHAKE_FOR_SETUP"}),
                          .msg            ("Function should acknowledge with ACK handshake when setup data is received without error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( no_response_for_pkt_received_without_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR"}),
                          .msg            ("Device should respond with proper response packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data1_pid_in_status_phase && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_DEVICE"}),
                          .msg            ("STATUS phase of data transfer should always contain DATA1 packetid."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_DEVICE"}),
                          .msg            ("Sequence bit mismatch occured in control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_BULK_XFR_SEQ_BIT_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bulk_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BULK_XFR_SEQ_BIT_ERR_DEVICE"}),
                          .msg            ("Sequence bit mismatch occured in bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_INT_XFR_SEQ_BIT_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((int_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INT_XFR_SEQ_BIT_ERR_DEVICE"}),
                          .msg            ("Sequence bit mismatch occured in interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_BULK_XFR_DATA_PID_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_bulk_pkt && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BULK_XFR_DATA_PID_ERR_DEVICE"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of a bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_INT_XFR_DATA_PID_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_int_pkt && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INT_XFR_DATA_PID_ERR_DEVICE"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of an interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_data_phase_length_err && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_DEVICE"}),
                          .msg            ("A Host or Device should transfer only 'wlength' number of bytes during the data phase of control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( device_initiated_pkt_xfr_when_no_pkt_is_due))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING"}),
                          .msg            ("Devices should not initiate a packet transfer when the host is not waiting."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_WMAX_PKT_SIZE_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((wmax_pkt_size_violation && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_WMAX_PKT_SIZE_ERR_DEVICE"}),
                          .msg            ("A host or device should not transfer more than the specified maximum number of bytes in the data packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_SSPLIT_NO_PAYLOAD_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data_payload_for_start_split && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SSPLIT_NO_PAYLOAD_DEVICE"}),
                          .msg            ("A Start-SPLIT token issued to an isochronous end point with 'start', 'middle' or 'end' encoding must have data payload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
     end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PKT_ZIH 
        M_USB_2_0_PKT_ID_CHK_FIELD_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pkt_id_check_field_error === 1'b1 && device_tx)))));
        M_USB_2_0_PKT_ID_NOT_DEFINED_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((pid_undefined === 1'b1 && device_tx)))));
        M_USB_2_0_DATA2_MDATA_FOR_NON_ISO_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((mdata_data2_pid_detected && device_tx)))));
        M_USB_2_0_DATA_CRC_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data_crc_err && device_tx)))));
        M_USB_2_0_HIGH_SPEED_END_POINT_ISSUED_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( err_handshake_by_non_hub))));
        M_USB_2_0_DEVICE_ISSUED_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( device_issued_token))));
        M_USB_2_0_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ack_issued_by_device_during_in_transaction))));
        M_USB_2_0_HANDSHAKE_PKT_IN_ISO_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( handshake_pkt_iso_transfer_err))));
        M_USB_2_0_PING_HANDSHAKE_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( illegal_handshake_for_ping))));
        M_USB_2_0_STALL_RECEIVE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stall_receive_err))));
        M_USB_2_0_DATA_PID_ERR_ISO_XFR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_data0_pid_detected && device_tx)))));
        M_USB_2_0_RESPONSE_FOR_OUT_SETUP_TOKEN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( response_received_for_out_setup_token))));
        M_USB_2_0_FUNCTION_RESPONDS_FOR_ERR_PKT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_responded_for_err_pkt))));
        M_USB_2_0_STALL_NAK_HANDSHAKE_FOR_SETUP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stall_nak_issued_to_setup_data))));
        M_USB_2_0_ACK_RECEIVED_FOR_IN_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_responded_with_ack_for_in_tkn))));
        M_USB_2_0_NO_ACK_HANDSHAKE_FOR_SETUP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( function_not_responded_with_ack_for_setup_data))));
        M_USB_2_0_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( no_response_for_pkt_received_without_err))));
        M_USB_2_0_NO_DATA1_PID_DURING_STATUS_PHASE_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data1_pid_in_status_phase && device_tx)))));
        M_USB_2_0_CTRL_XFR_SEQ_BIT_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))));
        M_USB_2_0_BULK_XFR_SEQ_BIT_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bulk_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))));
        M_USB_2_0_INT_XFR_SEQ_BIT_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((int_xfr_seq_bit_err && device_addressed && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))));
        M_USB_2_0_BULK_XFR_DATA_PID_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_bulk_pkt && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))));
        M_USB_2_0_INT_XFR_DATA_PID_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((data0_pid_not_received_in_first_int_pkt && SEQUENCE_BIT_TRACKING_ENABLE && device_tx)))));
        M_USB_2_0_CTRL_XFR_DATA_PHASE_LENGTH_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((ctrl_xfr_data_phase_length_err && device_tx)))));
        M_USB_2_0_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( device_initiated_pkt_xfr_when_no_pkt_is_due))));
        M_USB_2_0_WMAX_PKT_SIZE_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((wmax_pkt_size_violation && device_tx)))));
        M_USB_2_0_SSPLIT_NO_PAYLOAD_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((no_data_payload_for_start_split && device_tx)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PKT_ZIH 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate




generate
  case (Constraints_Mode)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PKT_CM 
        A_USB_2_0_BULK_ISO_ON_LOW_SPD_BUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( bulk_iso_xfr_on_low_speed_bus))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BULK_ISO_ON_LOW_SPD_BUS"}),
                          .msg            ("Bulk transfers and Isochronous transfers are not supported by low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_NON_CONTROL_ENDPOINT_ZERO: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( end_point_zero_not_ctrl))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NON_CONTROL_ENDPOINT_ZERO"}),
                          .msg            ("End point zero should always be a control end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_ILLEGAL_CTRL_XFR_WMAX_PACKET_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ctrl_xfr_wmax_packet_size_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_CTRL_XFR_WMAX_PACKET_SIZE"}),
                          .msg            ("Illegal 'wMaxPacketSize' specified for control transfer end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_ILLEGAL_BULK_XFR_WMAX_PACKET_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( bulk_xfr_wmax_packet_size_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_BULK_XFR_WMAX_PACKET_SIZE"}),
                          .msg            ("Illegal 'wMaxPacketSize' specified for bulk transfer end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_ILLEGAL_INTERRUPT_XFR_WMAX_PACKET_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( int_xfr_wmax_packet_size_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_INTERRUPT_XFR_WMAX_PACKET_SIZE"}),
                          .msg            ("Illegal 'wMaxPacketSize' specified for interrupt transfer end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB_2_0_ILLEGAL_ISOCHRONOUS_XFR_WMAX_PACKET_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( iso_xfr_wmax_packet_size_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_ISOCHRONOUS_XFR_WMAX_PACKET_SIZE"}),
                          .msg            ("Illegal 'wMaxPacketSize' specified for isochronous transfer end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PKT_CM 
        M_USB_2_0_BULK_ISO_ON_LOW_SPD_BUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( bulk_iso_xfr_on_low_speed_bus))));
        M_USB_2_0_NON_CONTROL_ENDPOINT_ZERO: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( end_point_zero_not_ctrl))));
        M_USB_2_0_ILLEGAL_CTRL_XFR_WMAX_PACKET_SIZE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ctrl_xfr_wmax_packet_size_error))));
        M_USB_2_0_ILLEGAL_BULK_XFR_WMAX_PACKET_SIZE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( bulk_xfr_wmax_packet_size_error))));
        M_USB_2_0_ILLEGAL_INTERRUPT_XFR_WMAX_PACKET_SIZE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( int_xfr_wmax_packet_size_error))));
        M_USB_2_0_ILLEGAL_ISOCHRONOUS_XFR_WMAX_PACKET_SIZE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( iso_xfr_wmax_packet_size_error))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PKT_CM 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate




generate
  case (ZI_FUNCTION_SIDE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PKT_ZIF 
        A_USB_2_0_CSPLIT_TO_ISO_END_POINT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( csplit_for_isochronous_out_transfer))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CSPLIT_TO_ISO_END_POINT"}),
                          .msg            ("Complete SPLIT token should not be issued for an isochronous OUT transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_IN_END_POINT_RECEIVED_OUT_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((in_endpoint_received_out_token && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_IN_END_POINT_RECEIVED_OUT_TKN"}),
                          .msg            ("Host should not issue OUT token to IN only end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_OUT_ENDPOINT_RECEIVED_IN_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((out_endpoint_received_in_token && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_OUT_ENDPOINT_RECEIVED_IN_TKN"}),
                          .msg            ("Host should not issue IN token to OUT only end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SETUP_TKN_TO_NON_CTRL_ENDPOINT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_tkn_issued_to_non_control_endpoint))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SETUP_TKN_TO_NON_CTRL_ENDPOINT"}),
                          .msg            ("A Host should not issue SETUP token to non control end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_CTRL_XFR_DATA_PHASE_DIR_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ctrl_xfr_data_phase_dir_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CTRL_XFR_DATA_PHASE_DIR_ERR"}),
                          .msg            ("Direction of data phase of control transfer should match with the direction specified in the setup data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_REQUEST_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((brequest_not_defined && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_REQUEST_NOT_DEFINED"}),
                          .msg            ("Brequest not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_REQUEST_TYPE_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bmrequest_type_not_defined && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_REQUEST_TYPE_NOT_DEFINED"}),
                          .msg            ("Type field in the 'bmrequesttype' is not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_REQUEST_RECIPIENT_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bmrequest_recipient_not_defined && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_REQUEST_RECIPIENT_NOT_DEFINED"}),
                          .msg            ("Recipient field of 'bmrequesttype' is not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_NO_STATUS_PHASE_AFTER_SETUP_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_phase_not_followed_by_status_phase))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NO_STATUS_PHASE_AFTER_SETUP_PHASE"}),
                          .msg            ("Status should follow setup phase when 'wlength' field of the setup data contains a value of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_CLEAR_REQUEST_OTG_ERR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((clear_feature_request_otg_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEAR_REQUEST_OTG_ERR"}),
                          .msg            ("On-The-Go feature selector cannot be cleared with a CLEAR_FEATURE command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_CLEAR_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_request_wlength_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEAR_FEATURE_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE request should have a value of zero for 'wlength'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_CLEAR_FEATURE_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_request_device_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEAR_FEATURE_REQUEST_DEVICE_ERR"}),
                          .msg            ("A CLEAR FEATURE request(device as receipient) should have zero value wlength and windex."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_GET_CONFIGURATION_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_configuration_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_CONFIGURATION_REQUEST_ERR"}),
                          .msg            ("A GET_CONFIGURATION request should have a value of zero for 'wvalue' , 'windex' and a value of one for 'wlength'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_GET_INTERFACE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_interface_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_INTERFACE_REQUEST_ERR"}),
                          .msg            ("A GET_INTERFACE request should have 'wvalue' of zero and 'wlength' of one."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_GET_STATUS_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_status_request_device_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_STATUS_REQUEST_DEVICE_ERR"}),
                          .msg            ("A GET_STATUS request with device as receipient should have 'wvalue' of zero, 'windex' of zero and 'wlength' of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_GET_STATUS_REQUEST_NON_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_status_request_non_device_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_STATUS_REQUEST_NON_DEVICE_ERR"}),
                          .msg            ("A GET_STATUS request with non device as recipient should have 'wvalue' of zero and 'wlength' of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SET_ADDRESS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_address_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_ADDRESS_REQUEST_ERR"}),
                          .msg            ("A SET_ADDRESS request should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SET_CONFIGURATION_REQEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_configuration_req_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_CONFIGURATION_REQEST_ERR"}),
                          .msg            ("A SET_CONFIGURATION request should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SET_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_feature_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SET_FEATURE_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_feature_request_device_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_FEATURE_REQUEST_DEVICE_ERR"}),
                          .msg            ("A SET FEATURE request(device as receipient) should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SET_INTERFACE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_interface_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_INTERFACE_REQUEST_ERR"}),
                          .msg            ("A SET_INTERFACE request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_SYNC_FRAME_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( sync_frame_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SYNC_FRAME_REQUEST_ERR"}),
                          .msg            ("A SYNCH_FRAME request should have 'wvalue' of zero and 'wlength'of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
        A_USB_2_0_HUB_CLASS_REQUEST_TO_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((hub_class_request_to_device && device_addressed && PACKET_ISSUE_CHECK_ENABLE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HUB_CLASS_REQUEST_TO_DEVICE"}),
                          .msg            ("HUB class specific requests should not be issued to functions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_SIDE_CONSTRAINT));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PKT_ZIF 
        M_USB_2_0_CSPLIT_TO_ISO_END_POINT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( csplit_for_isochronous_out_transfer))));
        M_USB_2_0_IN_END_POINT_RECEIVED_OUT_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((in_endpoint_received_out_token && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_OUT_ENDPOINT_RECEIVED_IN_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((out_endpoint_received_in_token && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_SETUP_TKN_TO_NON_CTRL_ENDPOINT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_tkn_issued_to_non_control_endpoint))));
        M_USB_2_0_CTRL_XFR_DATA_PHASE_DIR_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( ctrl_xfr_data_phase_dir_err))));
        M_USB_2_0_REQUEST_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((brequest_not_defined && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_REQUEST_TYPE_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bmrequest_type_not_defined && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_REQUEST_RECIPIENT_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bmrequest_recipient_not_defined && PACKET_ISSUE_CHECK_ENABLE)))));
        M_USB_2_0_NO_STATUS_PHASE_AFTER_SETUP_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( setup_phase_not_followed_by_status_phase))));
        M_USB_2_0_CLEAR_REQUEST_OTG_ERR:
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_request_otg_err))));
        M_USB_2_0_CLEAR_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_request_wlength_err))));
        M_USB_2_0_CLEAR_FEATURE_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_request_device_err))));
        M_USB_2_0_GET_CONFIGURATION_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_configuration_request_err))));
        M_USB_2_0_GET_INTERFACE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_interface_request_err))));
        M_USB_2_0_GET_STATUS_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_status_request_device_err))));
        M_USB_2_0_GET_STATUS_REQUEST_NON_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_status_request_non_device_err))));
        M_USB_2_0_SET_ADDRESS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_address_request_err))));
        M_USB_2_0_SET_CONFIGURATION_REQEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_configuration_req_err))));
        M_USB_2_0_SET_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_feature_request_err))));
        M_USB_2_0_SET_FEATURE_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_feature_request_device_err))));
        M_USB_2_0_SET_INTERFACE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_interface_request_err))));
        M_USB_2_0_SYNC_FRAME_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( sync_frame_request_err))));
        M_USB_2_0_HUB_CLASS_REQUEST_TO_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((hub_class_request_to_device && device_addressed && PACKET_ISSUE_CHECK_ENABLE)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PKT_ZIF 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate




generate
  case (ZI_HUB_UPSTREAM_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PKT_ZIHU 
        A_USB_2_0_GET_INTERFACE_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((get_interface_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_INTERFACE_REQUEST_TO_HUB"}),
                          .msg            ("GET_INTERFACE request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_SET_INTERFACE_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((set_interface_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_INTERFACE_REQUEST_TO_HUB"}),
                          .msg            ("SET INTERFACE request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_SYNCH_FRAME_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((sync_frame_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SYNCH_FRAME_REQUEST_TO_HUB"}),
                          .msg            ("SYNCH FRAME request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_CLEAR_FEATURE_HUB_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_hub_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEAR_FEATURE_HUB_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE hub class request should have 'windex' of zero and 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_CLEAR_PORT_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_port_feature_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEAR_PORT_FEATURE_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE (clear port feature) hub class request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_CLEARTT_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_tt_buffer_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_CLEARTT_REQUEST_ERR"}),
                          .msg            ("A CLEAR_TT_BUFFER hub class request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_RESET_TT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( reset_tt_buffer_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_RESET_TT_ERR"}),
                          .msg            ("A RESET_TT hub class request should have 'wlength', 'wvalue' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_GET_PORT_STATUS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_port_status_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_PORT_STATUS_REQUEST_ERR"}),
                          .msg            ("A GET_STATUS (get port status) hub class request should have 'wvalue' of zero and 'wlength' of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_GET_HUB_STATUS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_hub_status_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_GET_HUB_STATUS_REQUEST_ERR"}),
                          .msg            ("A GET_STATUS (get hub status) hub class request should have 'wvalue', 'windex' of zero and 'wlength' of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_SET_HUB_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_hub_feature_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_HUB_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE (set hub feature) hub class request should have 'windex', 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_SET_PORT_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_port_feature_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SET_PORT_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE (set port feature) hub class request should have 'windex', 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
        A_USB_2_0_STOP_TT_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stop_tt_buffer_request_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_STOP_TT_REQUEST_ERR"}),
                          .msg            ("A STOP TT hub class request should have 'wvalue', 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_CONSTRAINT));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PKT_ZIHU 
        M_USB_2_0_GET_INTERFACE_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((get_interface_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB_2_0_SET_INTERFACE_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((set_interface_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB_2_0_SYNCH_FRAME_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((sync_frame_request_to_hub === 1'b1 && device_addressed === 1'b1 && PACKET_ISSUE_CHECK_ENABLE == 1)))));
        M_USB_2_0_CLEAR_FEATURE_HUB_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_feature_hub_request_err))));
        M_USB_2_0_CLEAR_PORT_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_port_feature_request_err))));
        M_USB_2_0_CLEARTT_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( clear_tt_buffer_request_err))));
        M_USB_2_0_RESET_TT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( reset_tt_buffer_request_err))));
        M_USB_2_0_GET_PORT_STATUS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_port_status_request_err))));
        M_USB_2_0_GET_HUB_STATUS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( get_hub_status_request_err))));
        M_USB_2_0_SET_HUB_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_hub_feature_request_err))));
        M_USB_2_0_SET_PORT_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( set_port_feature_request_err))));
        M_USB_2_0_STOP_TT_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( stop_tt_buffer_request_err))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PKT_ZIHU 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate

`endif // QVL_ASSERT_ON
