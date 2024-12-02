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
  parameter QVL_COVERAGE_LEVEL = 0; //{32{1'b1}}; //`OVL_COVER_ALL;

  wire not_rx_clk = ~rx_clk;

  //---------------------------------------------------------------------
  // Parameter Checks
  //---------------------------------------------------------------------

        A_PCI_EXPRESS_PARAM_DEVICE_TYPE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (parameter_checks_active == 1'b1 &&
                           PCI_EXPRESS_DEVICE_TYPE != 0 &&
                           PCI_EXPRESS_DEVICE_TYPE != 1 &&
                           PCI_EXPRESS_DEVICE_TYPE != 4 &&
                           PCI_EXPRESS_DEVICE_TYPE != 5 &&
                           PCI_EXPRESS_DEVICE_TYPE != 6 &&
                           PCI_EXPRESS_DEVICE_TYPE != 7)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PARAM_DEVICE_TYPE_ERR"}),
                          .msg            ("Illegal value specified for PCI Express device type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_PARAM_MAX_LINK_WIDTH_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (parameter_checks_active == 1'b1 &&
                           MAX_LINK_WIDTH != 1 &&
                           MAX_LINK_WIDTH != 2 &&
                           MAX_LINK_WIDTH != 4 &&
                           MAX_LINK_WIDTH != 8 &&
                           MAX_LINK_WIDTH != 12 &&
                           MAX_LINK_WIDTH != 16 &&
                           MAX_LINK_WIDTH != 32)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PARAM_MAX_LINK_WIDTH_ERR"}),
                          .msg            ("Illegal value specified for maximum link width supported."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_PAYLOAD_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (device_control_register[7:5] != 0 &&
                           device_control_register[7:5] != 1 &&
                           device_control_register[7:5] != 2 &&
                           device_control_register[7:5] != 3 &&
                           device_control_register[7:5] != 4 &&
                           device_control_register[7:5] != 5)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_PAYLOAD_SIZE"}),
                          .msg            ("Reserved encoding for maximum payload size field of device control register should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_READ_REQUEST_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (device_control_register[14:12] != 0 &&
                           device_control_register[14:12] != 1 &&
                           device_control_register[14:12] != 2 &&
                           device_control_register[14:12] != 3 &&
                           device_control_register[14:12] != 4 &&
                           device_control_register[14:12] != 5)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_READ_REQUEST_SIZE"}),
                          .msg            ("Reserved encoding for maximum read request size field of device control register should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------  
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && 
                           data_aligned === 1'b0 && data_not_aligned === 1'b0 &&	
                           fifo_empty === 1'b1 && phy_status === 1'b1) ||
                           (phy_status === 1'b0 && data_aligned === 1'b1         
                           && |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1
                           && |active_lanes_bitmap === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P"}),
                          .msg            ("Lane to lane deskew should not exceed the specified maximum limit of five symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE == 1 &&(|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && data_aligned === 1'b0 && 
                           data_not_aligned === 1'b0 && fifo_empty === 1'b1 && 
                           phy_status === 1'b0) ||(phy_status === 1'b0 && 
                           data_aligned === 1'b1 && 
                           |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1 
                           && |active_lanes_bitmap === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N"}),
                          .msg            ("Lane to lane deskew should not exceed the specified maximum limit of five symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && 
                           data_aligned === 1'b0 && data_not_aligned === 1'b0 &&	
                           fifo_empty === 1'b1 && phy_status === 1'b1) ||
                           (phy_status === 1'b0 && data_aligned === 1'b1         
                           && |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1
                           && |active_lanes_bitmap === 1'b1))))));
        M_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE == 1 &&(|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && data_aligned === 1'b0 && 
                           data_not_aligned === 1'b0 && fifo_empty === 1'b1 && 
                           phy_status === 1'b0) ||(phy_status === 1'b0 && 
                           data_aligned === 1'b1 && 
                           |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1 
                           && |active_lanes_bitmap === 1'b1))))));
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
