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
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate 
  case (Constraints_Mode)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_CM
        A_USB_2_0_NUMBER_OF_ENDPOINTS_ERROR:
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((parameter_checks_active === 1'b1 &&((NUMBER_OF_ENDPOINTS > 31 && speed !== 2'b00) ||(NUMBER_OF_ENDPOINTS > 3 && speed === 2'b00)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NUMBER_OF_ENDPOINTS_ERROR"}),
                          .msg            ("Maximum number of end points supported is 31 for full/high speed devices and 3 for low speed devices."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end    
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_CM
        M_USB_2_0_NUMBER_OF_ENDPOINTS_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((parameter_checks_active === 1'b1 &&((NUMBER_OF_ENDPOINTS > 31 && speed !== 2'b00) ||(NUMBER_OF_ENDPOINTS > 3 && speed === 2'b00)))))));
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
        A_XZ_USB_2_0_OE_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (oe_n),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_OE_KNOWN_DRIVEN"}),
                          .msg            ("'oe_n' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_XZ_USB_2_0_SPEED_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (speed),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_SPEED_KNOWN_DRIVEN"}),
                          .msg            ("'speed' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_XZ_USB_2_0_ADDRESS_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (address),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ADDRESS_KNOWN_DRIVEN"}),
                          .msg            ("'address' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_XZ_USB_2_0_END_POINT_CONFIG_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (end_point_config),
                          .qualifier (( 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_END_POINT_CONFIG_KNOWN_DRIVEN"}),
                          .msg            ("'end_point_config' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_XZ_USB_2_0_DP_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp),
                          .qualifier (((oe_n === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DP_KNOWN_DRIVEN"}),
                          .msg            ("'dp' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_XZ_USB_2_0_DM_KNOWN_DRIVEN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm),
                          .qualifier (((oe_n === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_DM_KNOWN_DRIVEN"}),
                          .msg            ("'dm' is not driven to a valid level."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end    
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN_CM
        M_XZ_USB_2_0_OE_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (oe_n),
                          .qualifier (( 1'b1))));
        M_XZ_USB_2_0_SPEED_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (speed),
                          .qualifier (( 1'b1))));
        M_XZ_USB_2_0_ADDRESS_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (address),
                          .qualifier (( 1'b1))));
        M_XZ_USB_2_0_END_POINT_CONFIG_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (end_point_config),
                          .qualifier (( 1'b1))));
        M_XZ_USB_2_0_DP_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dp),
                          .qualifier (((oe_n === 1'b0)))));
        M_XZ_USB_2_0_DM_KNOWN_DRIVEN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .test_expr (dm),
                          .qualifier (((oe_n === 1'b0)))));
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
        A_USB_2_0_BIT_STUFF_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bit_stuff_err === 1'b1 && speed !== 2'b11 && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BIT_STUFF_ERR_HOST"}),
                          .msg            ("Bit stuff error occurred."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_TKN_PKT_SIZE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tkn_pkt_size_err)))))
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
        A_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_integral_number_of_bytes_in_data_pkt && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_HOST"}),
                          .msg            ("A data packet should always contain integral number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST"}),
                          .msg            ("A handshake packet should have only 8 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HOST_MIN_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( min_inter_pkt_delay_violation_host))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HOST_MIN_INTER_PKT_DLY_ERR"}),
                          .msg            ("A host should allow specified bit times of inter packet delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_HOST_MAX_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( max_inter_pkt_delay_violation_host))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HOST_MAX_INTER_PKT_DLY_ERR"}),
                          .msg            ("A host should start responding to a packet within the specified maximum inter packet delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_INVALID_SIGNALING_ON_BUS_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((se1_on_bus && host_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INVALID_SIGNALING_ON_BUS_HOST"}),
                          .msg            ("Invalid signaling levels on the USB bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
        A_USB_2_0_ILLEGAL_SE0_SIGNALING_HOST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_se0_signaling && host_tx && speed !== 2'b11)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_SE0_SIGNALING_HOST"}),
                          .msg            ("Illegal SE0 signaling."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_DEVICE_SIDE_CONSTRAINT));
      end    
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_ZID
        M_USB_2_0_BIT_STUFF_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bit_stuff_err === 1'b1 && speed !== 2'b11 && host_tx)))));
        M_USB_2_0_TKN_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((tkn_pkt_size_err)))));
        M_USB_2_0_SPLIT_PKT_SIZE_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( split_tkn_pkt_size_err))));
        M_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_integral_number_of_bytes_in_data_pkt && host_tx)))));
        M_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && host_tx)))));
        M_USB_2_0_HOST_MIN_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( min_inter_pkt_delay_violation_host))));
        M_USB_2_0_HOST_MAX_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( max_inter_pkt_delay_violation_host))));
        M_USB_2_0_INVALID_SIGNALING_ON_BUS_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((se1_on_bus && host_tx)))));
        M_USB_2_0_ILLEGAL_SE0_SIGNALING_HOST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_se0_signaling && host_tx && speed !== 2'b11)))));
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
        A_USB_2_0_BIT_STUFF_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bit_stuff_err === 1'b1 && speed !== 2'b11 && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_BIT_STUFF_ERR_DEVICE"}),
                          .msg            ("Bit stuff error occurred."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_integral_number_of_bytes_in_data_pkt && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_DEVICE"}),
                          .msg            ("A data packet should always contain integral number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE"}),
                          .msg            ("A handshake packet should have only 8 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_FUNCTION_MIN_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( min_inter_pkt_delay_violation_function))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_FUNCTION_MIN_INTER_PKT_DLY_ERR"}),
                          .msg            ("A device should allow specified bit times of inter packet delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_FUNCTION_MAX_INTER_PKT_DLY_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( max_inter_pkt_delay_violation_function))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_FUNCTION_MAX_INTER_PKT_DLY_ERR"}),
                          .msg            ("A device should start responding to a packet within the specified maximum inter packet delay."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_INVALID_SIGNALING_ON_BUS_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((se1_on_bus && device_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_INVALID_SIGNALING_ON_BUS_DEVICE"}),
                          .msg            ("Invalid signaling levels on the USB bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
        A_USB_2_0_ILLEGAL_SE0_SIGNALING_DEVICE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_se0_signaling && device_tx && speed !== 2'b11)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_USB_2_0_ILLEGAL_SE0_SIGNALING_DEVICE"}),
                          .msg            ("Illegal SE0 signaling."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_HOST_SIDE_CONSTRAINT));
      end    
    `QVL_ASSUME :
      begin : qvl_assume_ASSERT_NEVER_ZIH
        M_USB_2_0_BIT_STUFF_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((bit_stuff_err === 1'b1 && speed !== 2'b11 && device_tx)))));
        M_USB_2_0_NON_INTEGRAL_NUMBER_OF_BYTES_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((non_integral_number_of_bytes_in_data_pkt && device_tx)))));
        M_USB_2_0_HANDSHAKE_PKT_SIZE_ERR_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((handshake_pkt_size_err && device_tx)))));
        M_USB_2_0_FUNCTION_MIN_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( min_inter_pkt_delay_violation_function))));
        M_USB_2_0_FUNCTION_MAX_INTER_PKT_DLY_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (( max_inter_pkt_delay_violation_function))));
        M_USB_2_0_INVALID_SIGNALING_ON_BUS_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((se1_on_bus && device_tx)))));
        M_USB_2_0_ILLEGAL_SE0_SIGNALING_DEVICE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   ((!areset && !reset) ),
                          .enable    (1'b1),
                          .test_expr (((illegal_se0_signaling && device_tx && speed !== 2'b11)))));
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
