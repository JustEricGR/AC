//            Copyright 2006-2007 Mentor Graphics Corporation
//                         All Rights Reserved.
//           
//            THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//           INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//          CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                 TERMS.
//
//                   Questa Verifiaction Library (QVL)
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
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;

  wire not_clk = !clk; 
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 &&
                           preamble_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_P"}),
                          .msg            ("All octets of the preamble field should have a value of 8'b10101010 (ZI_PREAMBLE_FIELD)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && preamble_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_N"}),
                          .msg            ("All octets of the preamble field should have a value of 8'b10101010 (ZI_PREAMBLE_FIELD)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_SFD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && sfd_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_SFD_VIOLATION_P"}),
                          .msg            ("The start frame delimiter (SFD) should have a value of 8'b10101011 (ZI_SFD_FIELD)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_SFD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && sfd_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_SFD_VIOLATION_N"}),
                          .msg            ("The start frame delimiter (SFD) should have a value of 8'b10101011 (ZI_SFD_FIELD)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           source_addr_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_P"}),
                          .msg            ("The source address should be an individual address."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && source_addr_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_N"}),
                          .msg            ("The source address should be an individual address."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_len_type_field_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_P"}),
                          .msg            ("The LEN/TYPE field should be lesser than or equal to 16'd1500 or greater than 16'd1535."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_len_type_field_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_N"}),
                          .msg            ("The LEN/TYPE field should be lesser than or equal to 16'd1500 or greater than 16'd1535."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && illegal_type_violation === 1'b1
                           && RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_TYPE_VIOLATION_P"}),
                          .msg            ("When the LEN/TYPE field indicates a TYPE, this value should indicate one of CONTROL, TAGGED or JUMBO frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && illegal_type_violation === 1'b1
                           && RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_TYPE_VIOLATION_N"}),
                          .msg            ("When the LEN/TYPE field indicates a TYPE, this value should indicate one of CONTROL, TAGGED or JUMBO frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_frame_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("The size of an ethernet MAC frame should be equal to or greater than the minimum allowed size of 64 octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_frame_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("The size of an ethernet MAC frame should be equal to or greater than the minimum allowed size of 64 octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_length_mismatch_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_P"}),
                          .msg            ("The length of the frame should be equal to the expected length (2 x address fields + len_type field + length + fcs field)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_length_mismatch_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_N"}),
                          .msg            ("The length of the frame should be equal to the expected length (2 x address fields + len_type field + length + fcs field)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           control_frame_length_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_P"}),
                          .msg            ("The length of MAC control frames should be 64 octets (MinFrameSize - 32 bits + FCS)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           control_frame_length_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_N"}),
                          .msg            ("The length of MAC control frames should be 64 octets (MinFrameSize - 32 bits + FCS)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_ctrl_reserved_field_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_P"}),
                          .msg            ("The reserved field in a PAUSE control frame should have a value of 8'h00 in all the octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_ctrl_reserved_field_violation === 1'b1 && 
                           RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_N"}),
                          .msg            ("The reserved field in a PAUSE control frame should have a value of 8'h00 in all the octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_CRC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && packet_crc_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_CRC_VIOLATION_P"}),
                          .msg            ("The CRC computed by the receiving station should be same as the one appended to the frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_CRC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && packet_crc_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_CRC_VIOLATION_N"}),
                          .msg            ("The CRC computed by the receiving station should be same as the one appended to the frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           max_frame_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("The size of an untagged Ethernet MAC frame should be lesser than the maximum allowed size of 1518 octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           max_frame_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("The size of an untagged Ethernet MAC frame should be lesser than the maximum allowed size of 1518 octets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_rx === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_P"}),
                          .msg            ("The spacing between two packets on the receive interface should be greater than the minimum of 40 BT and 64 BT in 10G and 1G/10-100M implementations respectively."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_rx === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_N"}),
                          .msg            ("The spacing between two packets on the receive interface should be greater than the minimum of 40 BT and 64 BT in 10G and 1G/10-100M implementations respectively."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_tx === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_P"}),
                          .msg            ("The spacing between two packets on the transmit interface should be minimum of 96 BTs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_tx === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_N"}),
                          .msg            ("The spacing between two packets on the transmit interface should be minimum of 96 BTs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_frame_dest_addr_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_P"}),
                          .msg            ("The destination address in a PAUSE control frame on the transmit interface should be  globally assigned multicast address, 01-80-C2-00-00-01."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_frame_dest_addr_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_N"}),
                          .msg            ("The destination address in a PAUSE control frame on the transmit interface should be  globally assigned multicast address, 01-80-C2-00-00-01."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           reserved_ctrl_opcode_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_P"}),
                          .msg            ("The control opcode should not be reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           reserved_ctrl_opcode_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_N"}),
                          .msg            ("The control opcode should not be reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));

        A_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && g_false_car_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_P"}),
                          .msg            ("False Carrier condition detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && g_false_car_detected === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_N"}),
                          .msg            ("False Carrier condition detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && pause_frame_halfduplex_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_P"}),
                          .msg            ("In Half Duplex Mode Pause Frame Should not be Detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && pause_frame_halfduplex_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_N"}),
                          .msg            ("In Half Duplex Mode Pause Frame Should not be Detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && late_collision === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_P"}),
                          .msg            ("Late Collision is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && late_collision === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_N"}),
                          .msg            ("Late Collision is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && jam_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_P"}),
                          .msg            ("JAM Sent after collision is less than specified JAM_SIZE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT)); 
        A_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && jam_size_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_N"}),
                          .msg            ("JAM Sent after collision is less than specified JAM_SIZE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_burst_limit_exceed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_P"}),
                          .msg            ("Burst Limit exceeded from Maximum specified Limit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_burst_limit_exceed === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_N"}),
                          .msg            ("Burst Limit exceeded from Maximum specified Limit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_incorect_extension_length === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_P"}),
                          .msg            ("If Frame (or First Frame in burst) has length < SlotTime then it should be extended with SlotTime -FrameSize number of extension bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_incorect_extension_length === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_N"}),
                          .msg            ("If Frame (or First Frame in burst) has length < SlotTime then it should be extended with SlotTime -FrameSize number of extension bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 &&
                           preamble_violation === 1'b1)));
        M_GIGABIT_ETHERNET_PREAMBLE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && preamble_violation === 1'b1)));
        M_GIGABIT_ETHERNET_SFD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && sfd_violation === 1'b1)));
        M_GIGABIT_ETHERNET_SFD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && sfd_violation === 1'b1)));
        M_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           source_addr_violation === 1'b1)));
        M_GIGABIT_ETHERNET_SOURCE_ADDR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && source_addr_violation === 1'b1)));
        M_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_len_type_field_violation === 1'b1)));
        M_GIGABIT_ETHERNET_LENGTH_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_len_type_field_violation === 1'b1)));
        M_GIGABIT_ETHERNET_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && illegal_type_violation === 1'b1
                           && RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && illegal_type_violation === 1'b1
                           && RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_frame_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_MIN_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_frame_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_length_mismatch_violation === 1'b1)));
        M_GIGABIT_ETHERNET_FRAME_LENGTH_MISMATCH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           frame_length_mismatch_violation === 1'b1)));
        M_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           control_frame_length_violation === 1'b1)));
        M_GIGABIT_ETHERNET_CONTROL_FRAME_LENGTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           control_frame_length_violation === 1'b1)));
        M_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_ctrl_reserved_field_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_PAUSE_RESERVED_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_ctrl_reserved_field_violation === 1'b1 && 
                           RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_CRC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && packet_crc_violation === 1'b1)));
        M_GIGABIT_ETHERNET_CRC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && packet_crc_violation === 1'b1)));
        M_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           max_frame_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_MAX_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           max_frame_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_rx === 1'b1)));
        M_GIGABIT_ETHERNET_RX_MIN_IFG_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_rx === 1'b1)));
        M_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_tx === 1'b1)));
        M_GIGABIT_ETHERNET_TX_MIN_IFG_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           min_ifg_violation_on_tx === 1'b1)));
        M_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_frame_dest_addr_violation === 1'b1)));
        M_GIGABIT_ETHERNET_PAUSE_DEST_ADDR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           pause_frame_dest_addr_violation === 1'b1)));
        M_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           reserved_ctrl_opcode_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_RESERVED_CONTROL_OPCODE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && 
                           reserved_ctrl_opcode_violation === 1'b1 &&
                           RESERVED_VALUE_CHECK_ENABLE == 1)));
        M_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && g_false_car_detected === 1'b1)));
        M_GIGABIT_ETHERNET_FALSE_CARRIER_INDICATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && g_false_car_detected === 1'b1)));
        M_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && pause_frame_halfduplex_violation === 1'b1)));
        M_GIGABIT_ETHERNET_HALF_DUPLEX_PAUSE_FRAME_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && pause_frame_halfduplex_violation === 1'b1)));
        M_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && late_collision === 1'b1)));
        M_GIGABIT_ETHERNET_LATE_COLLISION_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && late_collision === 1'b1)));
        M_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && jam_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_JAM_SIZE_NOT_CORRECT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && jam_size_violation === 1'b1)));
        M_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_burst_limit_exceed === 1'b1)));
        M_GIGABIT_ETHERNET_GMII_BURST_LIMIT_EXCEEDED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_burst_limit_exceed === 1'b1)));
        M_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_incorect_extension_length === 1'b1)));
        M_GIGABIT_ETHERNET_GMII_INCORRECT_EXTENSION_LENGTH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0 ),
                          .enable    (1'b1),
                          .test_expr (data_valid === 1'b1 && gmii_incorect_extension_length === 1'b1)));
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
