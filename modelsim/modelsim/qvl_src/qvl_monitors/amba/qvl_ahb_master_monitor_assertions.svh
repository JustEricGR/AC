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
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  parameter QVL_MSG = "QVL_AHB_MASTER_VIOLATION : ";

  //---------------------------------------------------------------------
  // Parameter checks
  //---------------------------------------------------------------------

  // Assert only checks
        A_AHB_M23: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((DATA_BUS_WIDTH != 8 && DATA_BUS_WIDTH != 16 && 
                           DATA_BUS_WIDTH != 32 && DATA_BUS_WIDTH != 64 && 
                           DATA_BUS_WIDTH != 128 && DATA_BUS_WIDTH != 256 && 
                           DATA_BUS_WIDTH != 512 && DATA_BUS_WIDTH != 1024))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M23"}),
                          .msg            ("Width of the data bus must be either 8,16,3 2,64,128,256,512 or 1024"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (busy_transfer_issued_when_no_burst_in_progress_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M1"}),
                          .msg            ("A BUSY transfer type was issued when there was no burst in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (first_transfer_cannot_be_sequential_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M2"}),
                          .msg            ("The first transfer of a burst or a single transfer cannot have a transfer type of SEQUENTIAL."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M3: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_must_never_attempt_transfer_wider_than_width_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M3"}),
                          .msg            ("The master must never attempt a transfer where the width (as encoded by hsize) is wider than the data bus to which it is connected. (pg 3-43)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M4: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_boundary_not_equal_to_size_of_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M4"}),
                          .msg            ("All transfers must be aligned to the address boundary equal to the size of the transfer. (pg 3-12 & pg 3-25)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M5: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_granted_bus_no_data_transfer_no_idle_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M5"}),
                          .msg            ("The master was granted the bus, but it did not perform any data transfer including IDLE.  When a master is granted the bus and it does not wish to perform any data transfer, it must issue an IDLE transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M6_address: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_of_curr_xfer_not_stable_thru_ext_xfer_of_prev_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M6_address"}),
                          .msg            ("The master did not hold the address (haddr) stable when the target was inserting wait states. (pg 3-8)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M6_control: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (control_of_curr_xfer_not_stable_thru_ext_xfer_of_prev_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M6_control"}),
                          .msg            ("The master did not hold the control (htrans, hwrite, hsize, hburst, and hprot) stable when the target was inserting wait states. (pg 3-8)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M7: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (ctrl_info_curr_xfer_not_identical_to_control_info_of_prev_xfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M7"}),
                          .msg            ("The control information (hwrite, hsize, hburst, and hprot) of the current transfer was not identical to the control information of the previous transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M8: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_does_not_reflect_the_next_transfer_in_burst_during_busy_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M8"}),
                          .msg            ("The master used a BUSY transfer type.  The address did not reflect the next transfer in the burst. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M9: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_of_curr_xfer_w_seq_is_not_related_to_addr_of_prev_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M9"}),
                          .msg            ("The address of the current transfer with a transfer type of SEQUENTIAL was not related to the address of the previous transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_of_curr_xfer_not_equal_to_addr_of_prev_xfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M10"}),
                          .msg            ("The address of the current transfer was not equal to the address of the previous transfer.  The address must be the same on consecutive BUSY(s) or on a BUSY-SEQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_error_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M11"}),
                          .msg            ("The master did not perform an IDLE transfer immediately after receiving a ERROR response. (pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M12: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_retry_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M12"}),
                          .msg            ("The master did not perform an IDLE transfer immediately after receiving a RETRY response. (pg 3-22 & pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M13: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_split_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M13"}),
                          .msg            ("The master did not perform an IDLE transfer immediately after receiving a SPLIT response. (pg 3-22 & pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M14: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_continued_to_retry_transfer_error_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M14"}),
                          .msg            ("The master continued to retry the transfer that was responded with a ERROR response.  For ERROR response, the current transfer is not repeated (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M15: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_retry_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M15"}),
                          .msg            ("The master did not continue to retry the transfer that was responded with a RETRY response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M16: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_split_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M16"}),
                          .msg            ("The master did not continue to retry the transfer that was responded with a SPLIT response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

  // Assume only checks
        M_AHB_NO_ERROR_RESPONSE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hresp === ZI_ERROR) && (Over_Constraints_Mode == 1))));
        M_AHB_NO_RETRY_RESPONSE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hresp === ZI_RETRY) && (Over_Constraints_Mode == 1))));
        M_AHB_NO_SPLIT_RESPONSE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hresp === ZI_SPLIT) && (Over_Constraints_Mode == 1))));
        M_AHB_NO_TWO_CYCLE_RESPONSE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (((hresp === ZI_ERROR) || (hresp === ZI_RETRY) ||
                           (hresp === ZI_SPLIT)) && (Over_Constraints_Mode == 1))));
        M_AHB_NO_WAIT_STATES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hresp === ZI_OKAY) && (hready === 1'b0) &&
                           (Over_Constraints_Mode == 1))));

  // Both assert and assume checks

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER

        A_AHB_M17: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_idle_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M17"}),
                          .msg            ("Target did not provide a zero wait state OKAY response to IDLE transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_M18: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_busy_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M18"}),
                          .msg            ("Target did not provide a zero wait state OKAY response to BUSY transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_M19: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (target_must_drive_response_OKAY_when_inserting_wait_states_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M19"}),
                          .msg            ("Target did not drive the response to OKAY while inserting wait states prior to deciding its response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_M20: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (error_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M20"}),
                          .msg            ("Target violated the two cycle requirement on ERROR response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_M21: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (retry_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M21"}),
                          .msg            ("Target violated the two cycle requirement on RETRY response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_M22: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (split_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M22"}),
                          .msg            ("Target violated the two cycle requirement on SPLIT response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
`ifdef ZI_AXIS_SIM
`else
        A_AHB_MX: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_MX"}),
                          .msg            ("The ahb master monitor should not be in an unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
`endif

      end
    
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_AHB_M17: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_idle_transfer_fire)));
        M_AHB_M18: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_busy_transfer_fire)));
        M_AHB_M19: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (target_must_drive_response_OKAY_when_inserting_wait_states_fire)));
        M_AHB_M20: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (error_response_requires_at_least_2_cycles_fire)));
        M_AHB_M21: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (retry_response_requires_at_least_2_cycles_fire)));
        M_AHB_M22: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (split_response_requires_at_least_2_cycles_fire)));
`ifdef ZI_AXIS_SIM
`else
        M_AHB_MX: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown_fire)));
`endif
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

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

//---------------------------------------------------------------------
// Known driven
//---------------------------------------------------------------------

// assert only checks
        A_AHB_M24_hgrantx: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hgrantx),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hgrantx"}),
                          .msg            ("Control signal, hgrantx, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hready: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hready"}),
                          .msg            ("Control signal, hready, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hresp: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hresp),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hresp"}),
                          .msg            ("Control signal, hresp, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_htrans: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (htrans),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_htrans"}),
                          .msg            ("Control signal, htrans, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M25_haddr: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (haddr),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M25_haddr"}),
                          .msg            ("Address signal, haddr, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hwrite: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hwrite),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hwrite"}),
                          .msg            ("Control signal, hwrite, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hsize: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hsize),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hsize"}),
                          .msg            ("Control signal, hsize, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hburst: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hburst),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hburst"}),
                          .msg            ("Control signal, hburst, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_M24_hprot: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hprot),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_M24_hprot"}),
                          .msg            ("Control signal, hprot, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

`endif // QVL_XCHECK_OFF

`endif // QVL_ASSERT_ON
