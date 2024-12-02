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

  parameter QVL_MSG = "USB 1.1 Violation: ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = 0;  // 0 = `OVL_ZIN2OVLSVA
                                    // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

A_USB1_1_PARAM_CTRL_MAX_PKT_SIZE_ERR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset)),
                  .enable    (1'b1),
                  .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                   (parameter_checks_active === 1'b1)) &&
                   (~(CONTROL_XFR_MAX_PKT_SIZE === 8 || 
                   CONTROL_XFR_MAX_PKT_SIZE === 16 ||
                   CONTROL_XFR_MAX_PKT_SIZE === 32 ||
                   CONTROL_XFR_MAX_PKT_SIZE === 64))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_PARAM_CTRL_MAX_PKT_SIZE_ERR"}),
                  .msg            ("Illegal value specified for the control transfer maximum data payload size."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_PARAM_INT_MAX_PKT_SIZE_ERR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                   (parameter_checks_active === 1'b1)) &&
                   (INTERRUPT_XFR_MAX_PKT_SIZE > 64)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_PARAM_INT_MAX_PKT_SIZE_ERR"}),
                  .msg            ("Illegal value specified for the interrupt transfer maximum data payload size."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_PARAM_ISO_MAX_PKT_SIZE_ERR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                   (parameter_checks_active === 1'b1)) &&
                   (ISO_XFR_MAX_PKT_SIZE > 1023)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_PARAM_ISO_MAX_PKT_SIZE_ERR"}),
                  .msg            ("Illegal value specified for the isochronous transfer maximum data payload size."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_PARAM_BULK_MAX_PKT_SIZE_ERR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                   (parameter_checks_active === 1'b1)) &&
                   (~(BULK_XFR_MAX_PKT_SIZE === 8 || 
                   BULK_XFR_MAX_PKT_SIZE === 16 ||
                   BULK_XFR_MAX_PKT_SIZE === 32 ||
                   BULK_XFR_MAX_PKT_SIZE === 64))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_PARAM_BULK_MAX_PKT_SIZE_ERR"}),
                  .msg            ("Illegal value specified for the bulk transfer maximum data payload size."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_PARAM_INT_LS_MAX_PKT_SIZE_ERR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                   (parameter_checks_active === 1'b1)) &&
                   (INTERRUPT_XFR_LS_MAX_PKT_SIZE > 8)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_PARAM_INT_LS_MAX_PKT_SIZE_ERR"}),
                  .msg            ("Illegal value specified for the interrupt transfer maximum data payload size of low speed pipes."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_LOW_SPEED_PORT_SPECIFIED_FOR_HOST: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                   (PORT_TYPE === 0 && speed === 1'b0)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_LOW_SPEED_PORT_SPECIFIED_FOR_HOST"}),
                  .msg            ("Host downstream port is not a full speed port."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_LOW_SPEED_PORT_SPECIFIED_FOR_HUB_UPSTREAM_PORT: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                   (PORT_TYPE === 1 && speed === 1'b0)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_LOW_SPEED_PORT_SPECIFIED_FOR_HUB_UPSTREAM_PORT"}),
                  .msg            ("Hub upstream port is not a full speed port."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));
A_USB1_1_DATA_PID_ERR_ISO_XFR: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (clock ),
                  .reset_n   ((!areset && !reset) ),
                  .enable    (1'b1),
                  .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                   (data_pid_err_for_iso_xfr === 1'b1 && 
                   device_addressed === 1'b1)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_USB1_1_DATA_PID_ERR_ISO_XFR"}),
                  .msg            ("An isochronous transfer should always use DATA0 packet id during transmission of data packets."),
                  .severity_level (QVL_ERROR),
                  .property_type  (1'b0));



generate
  case (ZI_HUB_UPSTREAM_PORT_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZIH 
        A_USB1_1_GET_INTERFACE_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_interface_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_INTERFACE_REQUEST_TO_HUB"}),
                          .msg            ("GET_INTERFACE request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_SET_INTERFACE_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_interface_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_INTERFACE_REQUEST_TO_HUB"}),
                          .msg            ("SET INTERFACE request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_SYNCH_FRAME_REQUEST_TO_HUB: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_frame_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SYNCH_FRAME_REQUEST_TO_HUB"}),
                          .msg            ("SYNCH FRAME request should not be issued to hub."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_CLEAR_FEATURE_HUB_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_hub_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CLEAR_FEATURE_HUB_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE hub class request should have 'windex' of zero and 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_CLEAR_PORT_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_port_feature_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CLEAR_PORT_FEATURE_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE (clear port feature) hub class request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_GET_STATE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_state_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_STATE_REQUEST_ERR"}),
                          .msg            ("A GET_STATE hub class request should have 'wvalue' of zero and 'wlength' of one."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_GET_PORT_STATUS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_port_status_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_PORT_STATUS_REQUEST_ERR"}),
                          .msg            ("A GET_STATUS (get port status) hub class request should have 'wvalue' of zero and 'wlength' of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_GET_HUB_STATUS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_hub_status_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_HUB_STATUS_REQUEST_ERR"}),
                          .msg            ("A GET_STATUS (get hub status) hub class request should have 'wvalue', 'windex' of zero and 'wlength' of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_SET_HUB_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_hub_feature_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_HUB_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE (set hub feature) hub class request should have 'windex', 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_SET_PORT_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_port_feature_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_PORT_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE (set port feature) hub class request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HUB_UPSTREAM_PORT_CONSTRAINT));
     end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZIH 
        M_USB1_1_GET_INTERFACE_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_interface_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_SET_INTERFACE_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_interface_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_SYNCH_FRAME_REQUEST_TO_HUB: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_frame_request_to_hub === 1'b1 && 
                           device_addressed === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_CLEAR_FEATURE_HUB_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_hub_request_err === 1'b1)))));
        M_USB1_1_CLEAR_PORT_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_port_feature_request_err === 1'b1)))));
        M_USB1_1_GET_STATE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_state_request_err === 1'b1)))));
        M_USB1_1_GET_PORT_STATUS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_port_status_request_err === 1'b1)))));
        M_USB1_1_GET_HUB_STATUS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_hub_status_request_err === 1'b1)))));
        M_USB1_1_SET_HUB_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_hub_feature_request_err === 1'b1)))));
        M_USB1_1_SET_PORT_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_port_feature_request_err === 1'b1)))));
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




generate
  case (Constraints_Mode)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_CM
`ifdef ZiCwDebug
        A_USB1_1_TOP_SM_UNKNOWN_STATE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (next_state_main === ZI_UNKNOWN_STATE && 
                           present_state_main !== ZI_UNKNOWN_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_TOP_SM_UNKNOWN_STATE"}),
                          .msg            ("Main state machine entered in to unknown state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_TRAN_SM_UNKNOWN_STATE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (next_state_tran === ZI_TRAN_UNKNOWN_STATE && 
                           present_state_tran !== ZI_UNKNOWN_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_TRAN_SM_UNKNOWN_STATE"}),
                          .msg            ("Transaction state machine entered in to unknown state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
`endif // ZiCwDebug
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_CM
// Unknown state checks
`ifdef ZiCwDebug
        M_USB1_1_TOP_SM_UNKNOWN_STATE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (next_state_main === ZI_UNKNOWN_STATE && 
                           present_state_main !== ZI_UNKNOWN_STATE)))));
        M_USB1_1_TRAN_SM_UNKNOWN_STATE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (next_state_tran === ZI_TRAN_UNKNOWN_STATE && 
                           present_state_tran !== ZI_UNKNOWN_STATE)))));
`endif // ZiCwDebug
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
        A_USB1_1_ADDRESS_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (address),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ADDRESS_KNOWN_DRIVEN"}),
                          .msg            ("Input 'address' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_END_POINT_CONFIG_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (end_point_config),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_END_POINT_CONFIG_KNOWN_DRIVEN"}),
                          .msg            ("Input 'end_point_config' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_OE_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (oe_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_OE_KNOWN_DRIVEN"}),
                          .msg            ("Input 'oe_n' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_SPEED_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (speed),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SPEED_KNOWN_DRIVEN"}),
                          .msg            ("Input 'speed' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_DP_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp),
                          .qualifier ((reset === 1'b0 && areset === 1'b0) &&
                                      (oe_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DP_KNOWN_DRIVEN"}),
                          .msg            ("Input 'dp' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_USB1_1_DM_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm),
                          .qualifier ((reset === 1'b0 && areset === 1'b0) && 
                                      (oe_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DM_KNOWN_DRIVEN"}),
                          .msg            ("Input 'dm' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_CM 
        M_USB1_1_ADDRESS_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (address),
                          .qualifier (1'b1)));
        M_USB1_1_END_POINT_CONFIG_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (end_point_config),
                          .qualifier (1'b1)));
        M_USB1_1_OE_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (oe_n),
                          .qualifier (1'b1)));
        M_USB1_1_SPEED_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (speed),
                          .qualifier (1'b1)));
        M_USB1_1_DP_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp),
                          .qualifier ((reset === 1'b0 && areset === 1'b0) &&
                                      (oe_n === 1'b0))));
        M_USB1_1_DM_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm),
                          .qualifier ((reset === 1'b0 && areset === 1'b0) &&
                                      (oe_n === 1'b0))));
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
  case ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZIHH 
        A_USB1_1_FRAME_NUMBER_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (frame_number_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_FRAME_NUMBER_ERR"}),
                          .msg            ("Frame numbers received in two successive frames should be in increasing order and should differ by one."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_TKN_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_pkt_size_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_TKN_PKT_SIZE_ERR"}),
                          .msg            ("Token packets should have 24 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SOF_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sof_pkt_size_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SOF_PKT_SIZE_ERR"}),
                          .msg            (" SOF Packets should have 24 bits only."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_TKN_CRC_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_crc_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_TKN_CRC_ERR"}),
                          .msg            ("Token paket CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sof_issued_to_low_spd_device === 1'b1 &&      
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE"}),
                          .msg            ("SOF Packets should not be issued to low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SOF_PKTS_AT_IRREGULAR_INTERVALS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (frame_interval_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SOF_PKTS_AT_IRREGULAR_INTERVALS"}),
                          .msg            ("SOF packets should be received every 1 ms."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_ISSUED_STALL: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_issued_by_host === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_ISSUED_STALL"}),
                          .msg            ("A Host should not issue STALL handshake."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_ISSUED_NAK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (nak_issued_by_host === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_ISSUED_NAK"}),
                          .msg            ("A Host should not issue NAK handshake."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ack_issued_by_host_during_non_in_transaction === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR"}),
                          .msg            ("A Host can issue ACK handshake only during IN transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SETUP_DATA_PID_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_data_pid_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SETUP_DATA_PID_ERR"}),
                          .msg            ("Setup data should always contain DATA0 packet id."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SETUP_TKN_TO_NON_CTRL_ENDPOINT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_tkn_issued_to_non_control_endpoint === 1'b1 &&
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SETUP_TKN_TO_NON_CTRL_ENDPOINT"}),
                          .msg            ("A Host should not issue SETUP token to non control endpoints."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_issued_token_before_xfr_complete === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE"}),
                          .msg            ("A Host should not issue a token before the completion of the current transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_REQUEST_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (brequest_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_REQUEST_NOT_DEFINED"}),
                          .msg            ("Brequest not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_REQUEST_TYPE_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bmrequest_type_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_REQUEST_TYPE_NOT_DEFINED"}),
                          .msg            ("Type field in the 'bmrequesttype' is not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_REQUEST_RECIPIENT_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bmrequest_recipient_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_REQUEST_RECIPIENT_NOT_DEFINED"}),
                          .msg            ("Recipient field of 'bmrequesttype' is not defined."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CLEAR_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_request_wlength_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CLEAR_FEATURE_REQUEST_ERR"}),
                          .msg            ("A CLEAR_FEATURE request should have a value of zero for 'wlength'."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CLEAR_FEATURE_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_request_device_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CLEAR_FEATURE_REQUEST_DEVICE_ERR"}),
                          .msg            ("A CLEAR FEATURE request(device as receipient) should have zero value wlength and windex."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_GET_CONFIGURATION_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_configuration_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_CONFIGURATION_REQUEST_ERR"}),
                          .msg            ("A GET_CONFIGURATION request should have a value of zero for 'wvalue' , 'windex' and a value of one for 'wlength'."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_GET_INTERFACE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_interface_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_INTERFACE_REQUEST_ERR"}),
                          .msg            ("A GET_INTERFACE request should have 'wvalue' of zero and 'wlength' of one."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_GET_STATUS_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_status_request_device_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_STATUS_REQUEST_DEVICE_ERR"}),
                          .msg            ("A GET_STATUS request with device as receipient should have 'wvalue' of zero, 'windex' of zero and 'wlength' of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_GET_STATUS_REQUEST_NON_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_status_request_non_device_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_GET_STATUS_REQUEST_NON_DEVICE_ERR"}),
                          .msg            ("A GET_STATUS request with non device as recipient should have 'wvalue' of zero and 'wlength' of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SET_ADDRESS_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_address_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_ADDRESS_REQUEST_ERR"}),
                          .msg            ("A SET_ADDRESS request should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SET_CONFIGURATION_REQEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_configuration_req_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_CONFIGURATION_REQEST_ERR"}),
                          .msg            ("A SET_CONFIGURATION request should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SET_FEATURE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_feature_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_FEATURE_REQUEST_ERR"}),
                          .msg            ("A SET_FEATURE request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SET_FEATURE_REQUEST_DEVICE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_feature_request_device_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_FEATURE_REQUEST_DEVICE_ERR"}),
                          .msg            ("A SET FEATURE request(device as receipient) should have 'wlength' and 'windex' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SET_INTERFACE_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_interface_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SET_INTERFACE_REQUEST_ERR"}),
                          .msg            ("A SET_INTERFACE request should have 'wlength' of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SYNC_FRAME_REQUEST_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_frame_request_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SYNC_FRAME_REQUEST_ERR"}),
                          .msg            ("A SYNCH_FRAME request should have 'wvalue' of zero and 'wlength'of two."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZIHH 
        M_USB1_1_FRAME_NUMBER_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (frame_number_err === 1'b1)))));
        M_USB1_1_TKN_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_pkt_size_err === 1'b1)))));
        M_USB1_1_SOF_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sof_pkt_size_err === 1'b1)))));
        M_USB1_1_TKN_CRC_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_crc_err === 1'b1)))));
        M_USB1_1_SOF_PKT_ISSUED_TO_LOW_SPD_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sof_issued_to_low_spd_device === 1'b1 &&      
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_SOF_PKTS_AT_IRREGULAR_INTERVALS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (frame_interval_err === 1'b1)))));
        M_USB1_1_HOST_ISSUED_STALL: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_issued_by_host === 1'b1)))));
        M_USB1_1_HOST_ISSUED_NAK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (nak_issued_by_host === 1'b1)))));
        M_USB1_1_ACK_ISSUED_BY_HOST_DURING_NON_IN_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ack_issued_by_host_during_non_in_transaction === 1'b1)))));
        M_USB1_1_SETUP_DATA_PID_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_data_pid_err === 1'b1)))));
        M_USB1_1_SETUP_TKN_TO_NON_CTRL_ENDPOINT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_tkn_issued_to_non_control_endpoint === 1'b1 &&
                           device_addressed === 1'b1)))));
        M_USB1_1_HOST_ISSUED_TKN_BEFORE_XFR_COMPLETE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_issued_token_before_xfr_complete === 1'b1)))));
        M_USB1_1_REQUEST_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (brequest_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_REQUEST_TYPE_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bmrequest_type_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_REQUEST_RECIPIENT_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bmrequest_recipient_not_defined === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_CLEAR_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_request_wlength_err === 1'b1)))));
        M_USB1_1_CLEAR_FEATURE_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (clear_feature_request_device_err === 1'b1)))));
        M_USB1_1_GET_CONFIGURATION_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_configuration_request_err === 1'b1)))));
        M_USB1_1_GET_INTERFACE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_interface_request_err === 1'b1)))));
        M_USB1_1_GET_STATUS_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_status_request_device_err === 1'b1)))));
        M_USB1_1_GET_STATUS_REQUEST_NON_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (get_status_request_non_device_err === 1'b1)))));
        M_USB1_1_SET_ADDRESS_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_address_request_err === 1'b1)))));
        M_USB1_1_SET_CONFIGURATION_REQEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_configuration_req_err === 1'b1)))));
        M_USB1_1_SET_FEATURE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_feature_request_err === 1'b1)))));
        M_USB1_1_SET_FEATURE_REQUEST_DEVICE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_feature_request_device_err === 1'b1)))));
        M_USB1_1_SET_INTERFACE_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (set_interface_request_err === 1'b1)))));
        M_USB1_1_SYNC_FRAME_REQUEST_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_frame_request_err === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZIHH
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ 
        A_USB1_1_PKT_ID_CHK_FIELD_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pkt_check_field_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_PKT_ID_CHK_FIELD_ERR"}),
                          .msg            ("Packet ID check field should be one's complement of the packet ID field."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_PKT_ID_NOT_DEFINED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pkt_id_undefined === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_PKT_ID_NOT_DEFINED"}),
                          .msg            ("Illegal packet ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ 
        M_USB1_1_PKT_ID_CHK_FIELD_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pkt_check_field_err === 1'b1)))));
        M_USB1_1_PKT_ID_NOT_DEFINED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pkt_id_undefined === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ2 
        A_USB1_1_DATA_CRC_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data_crc_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DATA_CRC_ERR"}),
                          .msg            ("Data paket CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_NON_INTEGRAL_NUMBER_OF_BYTES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (non_integral_number_of_bytes_in_data_pkt === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NON_INTEGRAL_NUMBER_OF_BYTES"}),
                          .msg            ("A data packet should always contain integral number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HANDSHAKE_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (handshake_pkt_size_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HANDSHAKE_PKT_SIZE_ERR"}),
                          .msg            ("A Handshake packet should have only 8 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ2 
        M_USB1_1_DATA_CRC_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data_crc_err === 1'b1)))));
        M_USB1_1_NON_INTEGRAL_NUMBER_OF_BYTES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (non_integral_number_of_bytes_in_data_pkt === 1'b1)))));
        M_USB1_1_HANDSHAKE_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (handshake_pkt_size_err === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ2
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate





generate
  case ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ3 
        A_USB1_1_BIT_STUFF_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bit_stuff_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_BIT_STUFF_ERR"}),
                          .msg            ("Bit stuff error occurred."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ3 
        M_USB1_1_BIT_STUFF_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bit_stuff_err === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ3
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ4 
        A_USB1_1_ISO_XFR_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (iso_xfr_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ISO_XFR_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for isochronous end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_BULK_XFR_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bulk_xfr_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_BULK_XFR_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for bulk end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_INT_XFR_FULL_SPD_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (int_xfr_full_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_INT_XFR_FULL_SPD_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for interrupt bulk end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CTRL_XFR_FULL_SPD_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_full_spd_max_pkt_size_err === 1'b1 &&  
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CTRL_XFR_FULL_SPD_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for control end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_INT_XFR_LOW_SPD_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (int_xfr_low_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_INT_XFR_LOW_SPD_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for interrupt end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CTRL_XFR_LOW_SPD_MAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_low_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CTRL_XFR_LOW_SPD_MAX_PKT_SIZE_ERR"}),
                          .msg            ("A device or host should not transfer more than the maximum number of bytes specified for control end points."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ4 
        M_USB1_1_ISO_XFR_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (iso_xfr_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_BULK_XFR_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bulk_xfr_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_INT_XFR_FULL_SPD_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (int_xfr_full_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_CTRL_XFR_FULL_SPD_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_full_spd_max_pkt_size_err === 1'b1 &&  
                           device_addressed === 1'b1)))));
        M_USB1_1_INT_XFR_LOW_SPD_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (int_xfr_low_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_CTRL_XFR_LOW_SPD_MAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_low_spd_max_pkt_size_err === 1'b1 && 
                           device_addressed === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ4
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZ 
        A_USB1_1_IN_END_POINT_RECEIVED_OUT_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (in_endpoint_received_out_token === 1'b1 &&
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_IN_END_POINT_RECEIVED_OUT_TKN"}),
                          .msg            ("Host should not issue OUT token for an IN only end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZ
        M_USB1_1_IN_END_POINT_RECEIVED_OUT_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (in_endpoint_received_out_token === 1'b1 &&
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZ
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ5 
        A_USB1_1_OUT_ENDPOINT_RECEIVED_IN_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (out_endpoint_received_in_token === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_OUT_ENDPOINT_RECEIVED_IN_TKN"}),
                          .msg            ("Host should not issue IN token for an OUT only end point."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ5
        M_USB1_1_OUT_ENDPOINT_RECEIVED_IN_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (out_endpoint_received_in_token === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ5
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ6 
        A_USB1_1_SYNC_PATTERN_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_pattern_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SYNC_PATTERN_ERR"}),
                          .msg            ("Every packet should start with a proper sync pattern."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (no_response_for_pkt_received_without_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR"}),
                          .msg            ("Host or Device should respond with proper response packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_NAK_STALL_DURING_HANDSHAKE_PHASE_OF_IN_TRANSACTION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (nak_stall_issued_in_handshake_phase_of_in_transaction === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NAK_STALL_DURING_HANDSHAKE_PHASE_OF_IN_TRANSACTION"}),
                          .msg            ("NAK or STALL handshake packets should not be received during handshake phase of IN transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CTRL_XFR_SEQ_BIT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (ctrl_xfr_seq_bit_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CTRL_XFR_SEQ_BIT_ERR"}),
                          .msg            ("Sequence bit mismatch occured in control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_BULK_XFR_SEQ_BIT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (bulk_xfr_seq_bit_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_BULK_XFR_SEQ_BIT_ERR"}),
                          .msg            ("Sequence bit mismatch occured in bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_INT_XFR_SEQ_BIT_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (int_xfr_seq_bit_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_INT_XFR_SEQ_BIT_ERR"}),
                          .msg            ("Sequence bit mismatch occured in interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CTRL_XFR_DATA_PHASE_DIR_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_data_phase_dir_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CTRL_XFR_DATA_PHASE_DIR_ERR"}),
                          .msg            ("Direction of data phase of control transfer should match with the direction specified in the setup data."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_CTRL_XFR_DATA_PHASE_LENGTH_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_data_phase_length_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_CTRL_XFR_DATA_PHASE_LENGTH_ERR"}),
                          .msg            ("A Host or Device should transfer only 'wlength' number of bytes during the data phase of control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_NO_STATUS_PHASE_AFTER_SETUP_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_phase_not_followed_by_status_phase === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NO_STATUS_PHASE_AFTER_SETUP_PHASE"}),
                          .msg            ("Status phase should follow setup phase when 'wlength' field of setup data contains a value of zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_EOP_WITHOUT_SOP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (eop_without_sop === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_EOP_WITHOUT_SOP"}),
                          .msg            ("An end of packet was received without start of packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_WMAX_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (wmax_pkt_size_violation === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_WMAX_PKT_SIZE_ERR"}),
                          .msg            ("A Host or Device should not transfer more than the negotiated maximum number of bytes in the data packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_BULK_XFR_DATA_PID_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data0_pid_not_received_in_first_bulk_pkt === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_BULK_XFR_DATA_PID_ERR"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of a bulk transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_INT_XFR_DATA_PID_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data0_pid_not_received_in_first_int_pkt === 1'b1 &&
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_INT_XFR_DATA_PID_ERR"}),
                          .msg            ("A Host or Device should send DATA0 PID in the data packet of the first transaction of an interrupt transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_SETUP_DATA_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_data_size_err === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_SETUP_DATA_SIZE_ERR"}),
                          .msg            ("SETUP data should always contain 8 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_ILLEGAL_SE0_SIGNALING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (illegal_signaling === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ILLEGAL_SE0_SIGNALING"}),
                          .msg            ("Illegal SE0 signaling on bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ6
        M_USB1_1_SYNC_PATTERN_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (sync_pattern_err === 1'b1)))));
        M_USB1_1_NO_RESPONSE_FOR_PKT_RECEIVED_WITHOUT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (no_response_for_pkt_received_without_err === 1'b1)))));
        M_USB1_1_NAK_STALL_DURING_HANDSHAKE_PHASE_OF_IN_TRANSACTION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (nak_stall_issued_in_handshake_phase_of_in_transaction === 1'b1)))));
        M_USB1_1_CTRL_XFR_SEQ_BIT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (ctrl_xfr_seq_bit_err === 1'b1)))));
        M_USB1_1_BULK_XFR_SEQ_BIT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (bulk_xfr_seq_bit_err === 1'b1)))));
        M_USB1_1_INT_XFR_SEQ_BIT_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0) &&
                           (SEQUENCE_BIT_TRACKING_ENABLE === 1'b1 && 
                           device_addressed === 1'b1)) &&
                           (int_xfr_seq_bit_err === 1'b1)))));
        M_USB1_1_CTRL_XFR_DATA_PHASE_DIR_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_data_phase_dir_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_CTRL_XFR_DATA_PHASE_LENGTH_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ctrl_xfr_data_phase_length_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_NO_STATUS_PHASE_AFTER_SETUP_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_phase_not_followed_by_status_phase === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_EOP_WITHOUT_SOP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (eop_without_sop === 1'b1)))));
        M_USB1_1_WMAX_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (wmax_pkt_size_violation === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_BULK_XFR_DATA_PID_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data0_pid_not_received_in_first_bulk_pkt === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_INT_XFR_DATA_PID_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (data0_pid_not_received_in_first_int_pkt === 1'b1 &&
                           device_addressed === 1'b1)))));
        M_USB1_1_SETUP_DATA_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (setup_data_size_err === 1'b1)))));
        M_USB1_1_ILLEGAL_SE0_SIGNALING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (illegal_signaling === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ6
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ7 
        A_USB1_1_INVALID_SIGNALLING_ON_BUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (current_data_state === ZI_UNDEF_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_INVALID_SIGNALLING_ON_BUS"}),
                          .msg            ("Invalid signaling level on the USB bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ7
        M_USB1_1_INVALID_SIGNALLING_ON_BUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (current_data_state === ZI_UNDEF_STATE)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ7
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZHH 
        A_USB1_1_DEVICE_ISSUED_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_issued_by_device === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DEVICE_ISSUED_TKN"}),
                          .msg            ("A Device should not issue token packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_STALL_NAK_HANDSHAKE_FOR_SETUP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_with_stall_nak_for_setup_data === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_STALL_NAK_HANDSHAKE_FOR_SETUP"}),
                          .msg            ("Function should not respond with STALL or NAK handshake for setup data during control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_NO_ACK_HANDSHAKE_FOR_SETUP: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_not_responded_with_ack_for_setup_data === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NO_ACK_HANDSHAKE_FOR_SETUP"}),
                          .msg            ("Function should acknowledge with ACK handshake when setup data is received without error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_ACK_RECEIVED_FOR_IN_TKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_with_ack_for_in_tkn === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ACK_RECEIVED_FOR_IN_TKN"}),
                          .msg            ("Function should not respond with ACK handshake for IN token."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (device_initiated_pkt_xfr_when_no_pkt_is_due === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING"}),
                          .msg            ("Devices should not initiate a packet transfer when the host is not waiting."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZHH
        M_USB1_1_DEVICE_ISSUED_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (tkn_issued_by_device === 1'b1)))));
        M_USB1_1_STALL_NAK_HANDSHAKE_FOR_SETUP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_with_stall_nak_for_setup_data === 1'b1)))));
        M_USB1_1_NO_ACK_HANDSHAKE_FOR_SETUP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_not_responded_with_ack_for_setup_data === 1'b1)))));
        M_USB1_1_ACK_RECEIVED_FOR_IN_TKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_with_ack_for_in_tkn === 1'b1)))));
        M_USB1_1_DEVICE_INITIATED_XFR_WHEN_HOST_NOT_WAITING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (device_initiated_pkt_xfr_when_no_pkt_is_due === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZHH
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZHH2 
        A_USB1_1_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ack_issued_by_device_during_in_transaction === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR"}),
                          .msg            ("A Device can issue ACK handshake only during non IN transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HANDSHAKE_PKT_IN_ISO_XFR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (handshake_pkt_iso_transfer_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HANDSHAKE_PKT_IN_ISO_XFR"}),
                          .msg            ("Handshake packets should not be generated for isochronous transfers."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_STALL_RECEIVE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_receive_err === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_STALL_RECEIVE_ERR"}),
                          .msg            ("If STALL handshake is received during data phase or status phase of control transfer, then successive access to that control endpoint should result in reception of stall handshake until the completion of next setup phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_RESPONSE_FOR_OUT_SETUP_TOKEN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (response_received_for_out_setup_token === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_RESPONSE_FOR_OUT_SETUP_TOKEN"}),
                          .msg            ("Device should not respond with any packets on reception of OUT or SETUP tokens."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_DEVICE_INITIATED_XFR_WHEN_NOT_IDLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (device_initiated_transfer_when_not_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_DEVICE_INITIATED_XFR_WHEN_NOT_IDLE"}),
                          .msg            ("Device should not initiate a transfer when bus is not idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_FUNCTION_MIN_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_min_inter_pkt_dly_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_FUNCTION_MIN_INTER_PKT_DLY_ERR"}),
                          .msg            ("A device should allow two bit times of interpacket delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_FUNCTION_MAX_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_max_inter_pkt_dly_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_FUNCTION_MAX_INTER_PKT_DLY_ERR"}),
                          .msg            ("A Function should start responding to a packet within the specified maximum interpacket delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_FUNCTION_RESPONDS_FOR_ERR_PKT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_for_err_pkt === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_FUNCTION_RESPONDS_FOR_ERR_PKT"}),
                          .msg            ("Device should not respond for packets received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_STALL_NOT_RECEIVED_UNSUPPORTED_REQUEST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_not_received_for_unsupported_request === 1'b1
                           && device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_STALL_NOT_RECEIVED_UNSUPPORTED_REQUEST"}),
                          .msg            ("STALL handshake should be issued by device whenever an undefined request is issued during control transfer. This stall handshake can be issued during data phase or during status phase of control transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZHH2
        M_USB1_1_ACK_ISSUED_BY_DEVICE_DURING_IN_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (ack_issued_by_device_during_in_transaction === 1'b1)))));
        M_USB1_1_HANDSHAKE_PKT_IN_ISO_XFR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (handshake_pkt_iso_transfer_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_STALL_RECEIVE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_receive_err === 1'b1 && 
                           device_addressed === 1'b1)))));
        M_USB1_1_RESPONSE_FOR_OUT_SETUP_TOKEN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (response_received_for_out_setup_token === 1'b1)))));
        M_USB1_1_DEVICE_INITIATED_XFR_WHEN_NOT_IDLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (device_initiated_transfer_when_not_idle === 1'b1)))));
        M_USB1_1_FUNCTION_MIN_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_min_inter_pkt_dly_violation === 1'b1)))));
        M_USB1_1_FUNCTION_MAX_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_max_inter_pkt_dly_violation === 1'b1)))));
        M_USB1_1_FUNCTION_RESPONDS_FOR_ERR_PKT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (function_responded_for_err_pkt === 1'b1)))));
        M_USB1_1_STALL_NOT_RECEIVED_UNSUPPORTED_REQUEST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (stall_not_received_for_unsupported_request === 1'b1
                           && device_addressed === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZHH2
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZHF 
        A_USB1_1_TOKEN_BEFORE_TIMEOUT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_issued_token_before_timeout === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_TOKEN_BEFORE_TIMEOUT"}),
                          .msg            ("Host should wait for 18 bit times to indicate a timeout."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_XFR_INITIATED_WHEN_NOT_IDLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_initiated_transfer_when_not_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_XFR_INITIATED_WHEN_NOT_IDLE"}),
                          .msg            ("Host should not initiate a transfer when the bus is not idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_MIN_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_min_inter_pkt_dly_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_MIN_INTER_PKT_DLY_ERR"}),
                          .msg            ("A Host should allow two bit times of interpacket delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_MAX_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_max_inter_pkt_dly_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_MAX_INTER_PKT_DLY_ERR"}),
                          .msg            ("A Host should start responding to a packet within the specified maximum interpacket delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
        A_USB1_1_HOST_RESPONDS_FOR_ERR_PKT: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_responded_for_err_data_pkt === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HOST_RESPONDS_FOR_ERR_PKT"}),
                          .msg            ("Host should not respond for packets received with error."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZHF
        M_USB1_1_TOKEN_BEFORE_TIMEOUT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_issued_token_before_timeout === 1'b1)))));
        M_USB1_1_XFR_INITIATED_WHEN_NOT_IDLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_initiated_transfer_when_not_idle === 1'b1)))));
        M_USB1_1_HOST_MIN_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_min_inter_pkt_dly_violation === 1'b1)))));
        M_USB1_1_HOST_MAX_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_max_inter_pkt_dly_violation === 1'b1)))));

        M_USB1_1_HOST_RESPONDS_FOR_ERR_PKT: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (host_responded_for_err_data_pkt === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZHF
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZZZZ8 
        A_USB1_1_NO_DATA1_PID_DURING_STATUS_PHASE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (no_data1_pid_in_status_phase === 1'b1 && 
                           device_addressed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_NO_DATA1_PID_DURING_STATUS_PHASE"}),
                          .msg            ("STATUS phase of data transfer should always contain DATA1 packet id."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_HOST_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT||ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZZZZ8
        M_USB1_1_NO_DATA1_PID_DURING_STATUS_PHASE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (no_data1_pid_in_status_phase === 1'b1 && 
                           device_addressed === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZZZZ8
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate




generate
  case ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZIF 
        A_USB1_1_HUB_CLASS_REQUEST_TO_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (hub_class_request_to_device === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_HUB_CLASS_REQUEST_TO_DEVICE"}),
                          .msg            ("HUB class specific requests should not be issued to functions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_XFR_INITIATED_WHEN_NOT_CONFIGURED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (transfer_initiated_without_address_assignment === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_XFR_INITIATED_WHEN_NOT_CONFIGURED"}),
                          .msg            ("Host should not initiate transactions to non zero end points when address is not assigned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT));
        A_USB1_1_BULK_ISO_ON_LOW_SPD_BUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bulk_iso_xfr_on_low_speed_bus === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_BULK_ISO_ON_LOW_SPD_BUS"}),
                          .msg            ("Bulk transfers and Isochronous transfers are not supported by low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT)));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZIF
        M_USB1_1_HUB_CLASS_REQUEST_TO_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (hub_class_request_to_device === 1'b1 && 
                           PACKET_ISSUE_CHECK_ENABLE === 1)))));
        M_USB1_1_XFR_INITIATED_WHEN_NOT_CONFIGURED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (transfer_initiated_without_address_assignment === 1'b1)))));
        M_USB1_1_BULK_ISO_ON_LOW_SPD_BUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (bulk_iso_xfr_on_low_speed_bus === 1'b1)))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZIF
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT))
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_USB1_1_PRE_PID_ISSUED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pre_pid_issued === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB1_1_PRE_PID_ISSUED"}),
                          .msg            ("PRE packets should not be issued on low speed interfaces."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((ZI_FUNCTION_UPSTREAM_PORT_CONSTRAINT||ZI_HUB_DOWNSTREAM_PORT_CONSTRAINT||ZI_HUB_UPSTREAM_PORT_CONSTRAINT)));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_USB1_1_PRE_PID_ISSUED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0) &&
                           (pre_pid_issued === 1'b1)))));

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
