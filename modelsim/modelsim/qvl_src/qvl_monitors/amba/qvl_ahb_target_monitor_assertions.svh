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
  parameter QVL_WARNING = 2; // `OVL_WARNING;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  parameter QVL_MSG = "QVL_AHB_TARGET_VIOLATION : ";

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

  //---------------------------------------------------------------------
  // Known driven checks
  //---------------------------------------------------------------------

  // Assert only checks
        A_AHB_T29_hselx: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hselx),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hselx"}),
                          .msg            ("Control signal, hselx, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T30_haddr: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (haddr),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T30_haddr"}),
                          .msg            ("Address signal, haddr, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hwrite: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hwrite),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hwrite"}),
                          .msg            ("Control signal, hwrite, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_htrans: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (htrans),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_htrans"}),
                          .msg            ("Control signal, htrans, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hsize: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hsize),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hsize"}),
                          .msg            ("Control signal, hsize, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hburst: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hburst),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hburst"}),
                          .msg            ("Control signal, hburst, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hmaster: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hmaster),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hmaster"}),
                          .msg            ("Control signal, hmaster, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hmastlock: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hmastlock),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hmastlock"}),
                          .msg            ("Control signal, hmastlock, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hready_in: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hready_in),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hready_in"}),
                          .msg            ("Control signal, hready_in, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hready_out: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hready_out),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hready_out"}),
                          .msg            ("Control signal, hready_out, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hresp: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hresp),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hresp"}),
                          .msg            ("Control signal, hresp, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T29_hsplitx: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .test_expr (hsplitx),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T29_hsplitx"}),
                          .msg            ("Control signal, hsplitx, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
`endif // QVL_XCHECK_OFF

  //-------------------------------------------------------------------
  // Prorocol checks
  //-------------------------------------------------------------------

  // Assert only checks

        A_AHB_T1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_idle_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T1"}),
                          .msg            ("Target did not provide a zero wait state OKAY response to IDLE transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (no_zero_wait_state_okay_response_to_busy_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T2"}),
                          .msg            ("Target did not provide a zero wait state OKAY response to BUSY transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T3: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (target_inserted_more_than_16_wait_states_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T3"}),
                          .msg            ("Target inserted more than 16 wait states.  It is recommended, but not mandatory, that targets do not insert more than 16 wait states to prevent any single access locking the bus for a large number of clock cycles. (pg 3-20)."),
                          .severity_level (QVL_WARNING),
                          .property_type  (0));
        A_AHB_T4: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (target_must_drive_response_OKAY_when_inserting_wait_states_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T4"}),
                          .msg            ("Target did not drive the response to OKAY while inserting wait states prior to deciding its response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T5: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (error_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T5"}),
                          .msg            ("Target violated the two cycle requirement on ERROR response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T6: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (retry_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T6"}),
                          .msg            ("Target violated the two cycle requirement on RETRY response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T7: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (split_response_requires_at_least_2_cycles_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T7"}),
                          .msg            ("Target violated the two cycle requirement on SPLIT response. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (split_completion_requested_without_split_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T11"}),
                          .msg            ("Target issued a split completion request for a master, even though it did not issue a split response for that master."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T27: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((DATA_BUS_WIDTH != 8 && DATA_BUS_WIDTH != 16 &&
                           DATA_BUS_WIDTH != 32 && DATA_BUS_WIDTH != 64 && 
                           DATA_BUS_WIDTH != 128 && DATA_BUS_WIDTH != 256 && 
                           DATA_BUS_WIDTH != 512 && DATA_BUS_WIDTH != 1024))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T27"}),
                          .msg            ("Width of the data bus must be either 8,16,32,64, 128,256,512 or 1024"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_AHB_T28: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((NUMBER_OF_MASTERS == 0) || (NUMBER_OF_MASTERS > 16))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T28"}),
                          .msg            ("Illegal number of masters on the bus."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
 
  // Assume only checks

        M_AHB_T9: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
			  .test_expr (diff_master_accessing_retry_target_fire)));		                
        M_AHB_NO_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((!(hburst === ZI_SINGLE)) && Over_Constraints_Mode == 1)));
        M_AHB_NO_WRAP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (Over_Constraints_Mode == 1 &&
                           ((hburst === ZI_WRAP4) ||
                           (hburst === ZI_WRAP8) ||
                           (hburst === ZI_WRAP16)))));
        M_AHB_NO_BUSY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (Over_Constraints_Mode == 1 && htrans === ZI_BUSY)));
        M_AHB_NO_EARLY_BURST_TERMINATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (burst_in_progress && Over_Constraints_Mode == 1 &&
                           ((htrans === ZI_NONSEQUENTIAL) || (htrans === ZI_IDLE)))));

  // Both assert and assume checks					     
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_AHB_T8: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (same_master_same_addr_repeated_on_error_target_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T8"}),
                          .msg            ("Target had issued an ERROR response.  It is now being accessed by the same master that received the ERROR response with the same address.  For ERROR response, the current transfer is not repeated. (pg 3-22)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (same_master_accessing_split_target_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T10"}),
                          .msg            ("The bus protocol allows only a single outstanding transaction per bus master.  A Bus master received a split response from the target when it tried to access the target the last time.  The target has not yet issued a split completion request to this master yet.  The master must not access the target until then. (pg 3-36)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T12: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (busy_transfer_issued_when_no_burst_in_progress_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T12"}),
                          .msg            ("A BUSY transfer type was issued when there was no burst in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T13: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (first_transfer_cannot_be_sequential_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T13"}),
                          .msg            ("The first transfer of a burst or a single transfer cannot have a transfer type of SEQUENTIAL."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T14: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_must_never_attempt_transfer_wider_than_width_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T14"}),
                          .msg            ("A master must never attempt a transfer where the width (as encoded by hsize) is wider than the data bus to which it is connected. (pg 3-43)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T15: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_boundary_not_equal_to_size_of_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T15"}),
                          .msg            ("All transfers must be aligned to the address boundary equal to the size of the transfer. (pg 3-12 & pg 3-25)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T16: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_granted_bus_no_data_transfer_no_idle_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T16"}),
                          .msg            ("A master was granted the bus, but it did not perform any data transfer including IDLE.  When a master is granted the bus and it does not wish to perform any data transfer, it must issue an IDLE transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T17: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_and_control_of_curr_xfer_not_stable_thru_ext_xfer_of_prev_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T17"}),
                          .msg            ("Master did not hold the address (haddr) and control (htrans, hwrite, hsize, hburst, and hmaster) stable when the target was inserting wait states. (pg 3-8)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T18: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (ctrl_info_curr_xfer_not_identical_to_control_info_of_prev_xfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T18"}),
                          .msg            ("The control information (hwrite, hsize, hburst, and hmaster) of the current transfer was not identical to the control information of the previous transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T19: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_does_not_reflect_the_next_transfer_in_burst_during_busy_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T19"}),
                          .msg            ("A master used a BUSY transfer type.  The address did not reflect the next transfer in the burst. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T20: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_of_curr_xfer_w_seq_is_not_related_to_addr_of_prev_transfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T20"}),
                          .msg            ("The address of the current transfer with a transfer type of SEQUENTIAL was not related to the address of the previous transfer. (pg 3-9)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T21: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_of_curr_xfer_not_equal_to_addr_of_prev_xfer_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T21"}),
                          .msg            ("The address of the current transfer was not equal to the address of the previous transfer.  The address must be the same on consecutive BUSY(s) or on a BUSY-SEQ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T22: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_error_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T22"}),
                          .msg            ("Master did not perform an IDLE transfer immediately after receiving a ERROR response. (pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T23: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_retry_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T23"}),
                          .msg            ("Master did not perform an IDLE transfer immediately after receiving a RETRY response. (pg 3-22 & pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T24: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_split_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T24"}),
                          .msg            ("Master did not perform an IDLE transfer immediately after receiving a SPLIT response. (pg 3-22 & pg 3-39)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T25: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_retry_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T25"}),
                          .msg            ("A master did not continue to retry the transfer that was responded with a RETRY response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T26: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_split_response_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T26"}),
                          .msg            ("A master did not continue to retry the transfer that was responded with a SPLIT response. (pg 3-21)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T31: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hselx_changed_during_extended_cycle_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T31"}),
                          .msg            ("hselx was not stable when the target was inserting wait states. (pg 3-8)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T32: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hmaster_changed_during_extended_cycle_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T32"}),
                          .msg            ("hmaster was not stable when the target was inserting wait states. (pg 3-8)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T33: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hready_in !== hready_out && (curr_state !== ZI_TARGET_INACTIVE_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T33"}),
                          .msg            ("hready_in was not equal to hready_out when this target device was active."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AHB_T34: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((curr_state === ZI_TARGET_INACTIVE_STATE) &&((hready_out === 1'b0)))))


          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_T34"}),
                          .msg            ("Target asserted hready_out low (inserted wait states) when it was not selected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
  
        A_AHB_T35:
          assert property ( ASSERT_NEVER_P (
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hmaster >= NUMBER_OF_MASTERS) ))
          else qvl_error_t(
                          .msg            ("hmaster encoding must always be less than the number of masters in the system."),
                          .err_msg        ({QVL_MSG,"A_AHB_T35"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
`ifdef ZI_AXIS_SIM
`else
        A_AHB_TX: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AHB_TX"}),
                          .msg            ("The ahb target monitor should not be in an unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
`endif
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_AHB_T8: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (same_master_same_addr_repeated_on_error_target_fire)));
        M_AHB_T10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (same_master_accessing_split_target_fire)));
        M_AHB_T12: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (busy_transfer_issued_when_no_burst_in_progress_fire)));
        M_AHB_T13: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (first_transfer_cannot_be_sequential_fire)));
        M_AHB_T14: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_must_never_attempt_transfer_wider_than_width_fire)));
        M_AHB_T15: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_boundary_not_equal_to_size_of_transfer_fire)));
        M_AHB_T16: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_granted_bus_no_data_transfer_no_idle_transfer_fire)));
        M_AHB_T17: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_and_control_of_curr_xfer_not_stable_thru_ext_xfer_of_prev_fire)));
        M_AHB_T18: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (ctrl_info_curr_xfer_not_identical_to_control_info_of_prev_xfer_fire)));
        M_AHB_T19: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_does_not_reflect_the_next_transfer_in_burst_during_busy_fire)));
        M_AHB_T20: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_of_curr_xfer_w_seq_is_not_related_to_addr_of_prev_transfer_fire)));
        M_AHB_T21: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (addr_of_curr_xfer_not_equal_to_addr_of_prev_xfer_fire)));
        M_AHB_T22: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_error_fire)));
        M_AHB_T23: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_retry_fire)));
        M_AHB_T24: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (address_for_following_transfer_not_cancelled_on_split_fire)));
        M_AHB_T25: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_retry_response_fire)));
        M_AHB_T26: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (master_did_not_continue_to_retry_transfer_split_response_fire)));
        M_AHB_T31: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hselx_changed_during_extended_cycle_fire)));
        M_AHB_T32: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hmaster_changed_during_extended_cycle_fire)));
        M_AHB_T33: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((hready_in !== hready_out && (curr_state !== ZI_TARGET_INACTIVE_STATE)))));
        M_AHB_T34: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr ((curr_state === ZI_TARGET_INACTIVE_STATE) &&((hready_out === 1'b0)))));
        M_AHB_T35:
          assume property ( ASSERT_NEVER_P (
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (hmaster >= NUMBER_OF_MASTERS) ));
`ifdef ZI_AXIS_SIM
`else
        M_AHB_TX: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (hclk),
                          .reset_n   (hresetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown_fire)));
`endif
      end

    `QVL_IGNORE : 
      begin : qvl_ignore 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_WARNING),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif
