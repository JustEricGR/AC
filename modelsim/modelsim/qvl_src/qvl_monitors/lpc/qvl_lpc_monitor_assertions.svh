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
  parameter QVL_PROPERTY_TYPE = Constraints_Mode;  // 0 = `OVL_ASSERT
                                    // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;
  parameter QVL_MSG = "QVL_LPC_VIOLATION : ";

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_LPC_lframe_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lframe_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_lframe_n"}),
                          .msg            ("lframe_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_ldrq_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (ldrq_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_ldrq_n"}),
                          .msg            ("ldrq_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_serirq: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (serirq),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_serirq"}),
                          .msg            ("serirq has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_clkrun_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (clkrun_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_clkrun_n"}),
                          .msg            ("clkrun_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_pme_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (pme_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_pme_n"}),
                          .msg            ("pme_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_lpcpd_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lpcpd_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_lpcpd_n"}),
                          .msg            ("lpcpd_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_LPC_lsmi_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lsmi_n),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_lsmi_n"}),
                          .msg            ("lsmi_n has a X or Z value"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_LPC_lframe_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lframe_n),
                          .qualifier (1'b1)));
        M_LPC_ldrq_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (ldrq_n),
                          .qualifier (1'b1)));
        M_LPC_serirq: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (serirq),
                          .qualifier (1'b1)));
        M_LPC_clkrun_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (clkrun_n),
                          .qualifier (1'b1)));
        M_LPC_pme_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (pme_n),
                          .qualifier (1'b1)));
        M_LPC_lpcpd_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lpcpd_n),
                          .qualifier (1'b1)));
        M_LPC_lsmi_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .test_expr (lsmi_n),
                          .qualifier (1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_UNKNOWN 
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
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_LPC_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_cycle_type))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_1"}),
                          .msg            ("Invalid Cycle Type and Direction detected (4.2.1.2)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lad_in_TAR))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_2"}),
                          .msg            ("Value on lad port is not 4'b1111 during the turnaround cycle (4.2.1.4)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_3: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_CHANNEL_in_non_dma_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_3"}),
                          .msg            ("CHANNEL cycles can only occur in DMA operations (4.2.1.6)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_4: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_dma_in_addr_state))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_4"}),
                          .msg            ("ADDR cycles can only occur in non-DMA operations (4.2.1.5)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_5: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lad_in_SYNC))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_5"}),
                          .msg            ("Value on lad port was not constant across contiguous synchronization cycles (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_6: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_host_in_SYNC_in_not_bus_mas_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_6"}),
                          .msg            ("The host does synchronization cycles only in bus master operations (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_7: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_sync_value_in_SYNC))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_7"}),
                          .msg            ("The lad port has an invalid SYNC value (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_8: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((CHECK_RESERVED_VALUE === 1) &&
                           (fire_SYNC_with_reserved_lad_value))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_8"}),
                          .msg            ("The lad port has a reserved SYNC value (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_9: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_peri_in_SYNC_in_bus_mas_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_9"}),
                          .msg            ("The peripheral should not be synchronizing in a bus master operation (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_size_for_data))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_10"}),
                          .msg            ("The lad port has an invalid SIZE value (4.2.1.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_size_op_in_host_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_11"}),
                          .msg            ("SIZE cycles can only happen in non-host initiated operations (4.2.1.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_12: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_size_bits_3_2_non_zero))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_12"}),
                          .msg            ("lad[3:2] must be 2'b00 in a SIZE cycle (4.2.1.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
/*        A_LPC_13: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_aborted_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_13"}),
                          .msg            ("Transfer was aborted due to the assertion of lframe_n (4.2.2.2)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));*/
        A_LPC_14: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_reserved_start_type))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_14"}),
                          .msg            ("The lad port has a reserved START type (4.2.1.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_15: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_start_type_on_abort))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_15"}),
                          .msg            ("The lad port does not have value 4'b1111 when lframe_n asserts to abort the transfer (4.2.2.2)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_16: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_lframe_not_asserted_for_4_cycles_in_abort))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_16"}),
                          .msg            ("lframe_n must be asserted for 4 contiguous cycles when aborting the transfer (4.2.2.2)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_17: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_reserved_channel_num_in_dma))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_17"}),
                          .msg            ("DMA is requested with the reserved channel number 4 (6.4)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_18: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_dma_started_for_unrequested_channel))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_18"}),
                          .msg            ("DMA operation is occurring on a channel that did not send a request for a DMA operation via the ldrq port (6.4)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_19: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_bus_mas_op_start_with_no_request))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_19"}),
                          .msg            ("Peripheral Initiated Bus Master operation is occurring on a channel that did not send a request for that via the ldrq port (7.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_20: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_sync_short_wait_too_long))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_20"}),
                          .msg            ("A Short Wait was indicated, but it took more than 8 clocks to SYNC (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
  /*      A_LPC_SYNC_too_short: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_sync_long_wait_too_long))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_SYNC_too_short"}),
                          .msg            ("A Long Wait was indicated, but it took less than 8 clocks to SYNC (4.2.1.8)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
-Senthil
*/ 
        A_LPC_21: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_bus_master_op))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_21"}),
                          .msg            ("Cycle and Start type mismatch on the bus master operation (7.2)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_25: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_invalid_start_type))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_25"}),
                          .msg            ("Invalid start type"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_26: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_invalid_size))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_26"}),
                          .msg            ("Invalid size"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_27: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_ready_or_error_sync_on_odd_byte_of_16_bit_dma_read))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_27"}),
                          .msg            ("A '0000b' (Ready) or '1010b' (Ready with Error) encoding sent on the SYNC field of an odd byte during a read operation on a 16-bit DMA channel (6.4.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_28: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_ready_or_error_sync_on_odd_byte_of_16_bit_dma_write))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_28"}),
                          .msg            ("A '0000b' (Ready) or '1010b' (Ready with Error) encoding sent on the SYNC field of an odd byte during a write operation on a 16-bit DMA channel (6.4.3)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_29: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_word_or_quad_dma_on_byte_or_word_channels))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_29"}),
                          .msg            ("Larger DMA transfer attempted on device which does not support large transfer sizes (6.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_serial_IRQ_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_serirq))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_serial_IRQ_mode"}),
                          .msg            ("Serialized IRQ mode is not currently supported"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_clkrun_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_clkrun_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_clkrun_mode"}),
                          .msg            ("Clock Run is not currently supported"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_pme_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_pme_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_pme_mode"}),
                          .msg            ("PME (power management) mode is not currently supported"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_power_down_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lpcpd_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_power_down_mode"}),
                          .msg            ("Power Down mode is not currently supported"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_LPC_SMI_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lsmi_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_SMI_mode"}),
                          .msg            ("SMI is not currently supported"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_LPC_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_cycle_type))));
        M_LPC_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lad_in_TAR))));
        M_LPC_3: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_CHANNEL_in_non_dma_op))));
        M_LPC_4: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_dma_in_addr_state))));
        M_LPC_5: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lad_in_SYNC))));
        M_LPC_6: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_host_in_SYNC_in_not_bus_mas_op))));
        M_LPC_7: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_sync_value_in_SYNC))));
        M_LPC_8: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((CHECK_RESERVED_VALUE === 1) &&
                           (fire_SYNC_with_reserved_lad_value))));
        M_LPC_9: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_peri_in_SYNC_in_bus_mas_op))));
        M_LPC_10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_size_for_data))));
        M_LPC_11: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_size_op_in_host_op))));
        M_LPC_12: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_size_bits_3_2_non_zero))));
 /*       M_LPC_13: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_aborted_op))));*/
        M_LPC_14: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_reserved_start_type))));
        M_LPC_15: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_start_type_on_abort))));
        M_LPC_16: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_lframe_not_asserted_for_4_cycles_in_abort))));
        M_LPC_17: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_reserved_channel_num_in_dma))));
        M_LPC_18: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_dma_started_for_unrequested_channel))));
        M_LPC_19: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_bus_mas_op_start_with_no_request))));
        M_LPC_20: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_sync_short_wait_too_long))));
     /*   M_LPC_SYNC_too_short: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_sync_long_wait_too_long))));
       */
          M_LPC_21: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_bus_master_op))));
        M_LPC_25: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_invalid_start_type))));
        M_LPC_26: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_invalid_size))));
        M_LPC_27: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_ready_or_error_sync_on_odd_byte_of_16_bit_dma_read))));
        M_LPC_28: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_ready_or_error_sync_on_odd_byte_of_16_bit_dma_write))));
        M_LPC_29: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) &&
                           (fire_word_or_quad_dma_on_byte_or_word_channels))));
        M_LPC_serial_IRQ_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_serirq))));
        M_LPC_clkrun_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_clkrun_n))));
        M_LPC_pme_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_pme_n))));
        M_LPC_power_down_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lpcpd_n))));
        M_LPC_SMI_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr ((1'b1) && (fire_illegal_lsmi_n))));
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

















parameter WIDTH_OF_LDRQ_WIDTH =
                            ((LDRQ_WIDTH) <= ((1<<1)-1) ? 1 :
                            (LDRQ_WIDTH) <= ((1<<2)-1) ? 2 :
                            (LDRQ_WIDTH) <= ((1<<3)-1) ? 3 :
                            (LDRQ_WIDTH) <= ((1<<4)-1) ? 4 :
                            (LDRQ_WIDTH) <= ((1<<5)-1) ? 5 :
                            (LDRQ_WIDTH) <= ((1<<6)-1) ? 6 :
                            (LDRQ_WIDTH) <= ((1<<7)-1) ? 7 :
                            (LDRQ_WIDTH) <= ((1<<8)-1) ? 8 :
                            (LDRQ_WIDTH) <= ((1<<9)-1) ? 9 :
                            (LDRQ_WIDTH) <= ((1<<10)-1) ? 10 :
                            (LDRQ_WIDTH) <= ((1<<11)-1) ? 11 :
                            (LDRQ_WIDTH) <= ((1<<12)-1) ? 12 :
                            (LDRQ_WIDTH) <= ((1<<13)-1) ? 13 :
                            (LDRQ_WIDTH) <= ((1<<14)-1) ? 14 :
                            (LDRQ_WIDTH) <= ((1<<15)-1) ? 15 :
                            (LDRQ_WIDTH) <= ((1<<16)-1) ? 16 :
                            (LDRQ_WIDTH) <= ((1<<17)-1) ? 17 :
                            (LDRQ_WIDTH) <= ((1<<18)-1) ? 18 :
                            (LDRQ_WIDTH) <= ((1<<19)-1) ? 19 :
                            (LDRQ_WIDTH) <= ((1<<20)-1) ? 20 :
                            (LDRQ_WIDTH) <= ((1<<21)-1) ? 21 :
                            (LDRQ_WIDTH) <= ((1<<22)-1) ? 22 :
                            (LDRQ_WIDTH) <= ((1<<23)-1) ? 23 :
                            (LDRQ_WIDTH) <= ((1<<24)-1) ? 24 :
                            (LDRQ_WIDTH) <= ((1<<25)-1) ? 25 :
                            (LDRQ_WIDTH) <= ((1<<26)-1) ? 26 :
                            (LDRQ_WIDTH) <= ((1<<27)-1) ? 27 :
                            (LDRQ_WIDTH) <= ((1<<28)-1) ? 28 :
                            (LDRQ_WIDTH) <= ((1<<29)-1) ? 29 :
                            (LDRQ_WIDTH) <= ((1<<30)-1) ? 30 :
                            (LDRQ_WIDTH) <= ((1<<31)-1) ? 31 : 32);

genvar s;
generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_22_LDRQ
      case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
         A_LPC_22_LDRQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_bus_mas_request_arrives_when_bus_mas_request_outstanding[s]))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_22_LDRQ"}),
                          .msg            ({QVL_MSG,"A request for a peripheral initiated bus master operation was received on ldrq[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] when another bus master request was outstanding (7.3)"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));

        `QVL_ASSUME:
          M_LPC_22_LDRQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_bus_mas_request_arrives_when_bus_mas_request_outstanding[s]))));
        `QVL_IGNORE : 
           begin : qvl_ignore_ASSERT_NEVER 
           end
         default: initial qvl_error_t (
                               .err_msg        (""),
                               .msg            (""),
                               .severity_level (QVL_ERROR),
                               .property_type  (`QVL_IGNORE));
      endcase
    end 
endgenerate

generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_23_LDRQ
      case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
         A_LPC_23_LDRQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_illegal_dma_bus_mas_request_protocol[s]))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_23_LDRQ"}),
                          .msg            ({QVL_MSG,"The sequence of values on the ldrq port[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] do not match a valid DMA or Bus Master request (6.2)"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));

        `QVL_ASSUME:
          M_LPC_23_LDRQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_illegal_dma_bus_mas_request_protocol[s]))));

	`QVL_IGNORE : 
           begin : qvl_ignore_ASSERT_NEVER 
           end
         default: initial qvl_error_t (
                               .err_msg        (""),
                               .msg            (""),
                               .severity_level (QVL_ERROR),
                               .property_type  (`QVL_IGNORE));
      endcase
    end 
endgenerate

generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_24_LDRQ
      case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
        A_LPC_24_LDRQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_dma_tc_inactive_request_for_inactive_channel[s]))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_24_LDRQ"}),
                          .msg            ({QVL_MSG,"A DMA deactivation request was received on the ldrq port[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] for a channel that does not have a DMA request outstanding (6.3)"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));

        `QVL_ASSUME:
          M_LPC_24_LDRQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_dma_tc_inactive_request_for_inactive_channel[s]))));

        `QVL_IGNORE : 
           begin : qvl_ignore_ASSERT_NEVER 
           end
         default: initial qvl_error_t (
                               .err_msg        (""),
                               .msg            (""),
                               .severity_level (QVL_ERROR),
                               .property_type  (`QVL_IGNORE));
      endcase
    end 
endgenerate

generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_30_LDRQ
        case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
         A_LPC_30_LDRQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_channel_previously_requested_by_different_ldrq[s]))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_30_LDRQ"}),
                          .msg            ({QVL_MSG,"A DMA request sent on ldrq port[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] for a channel that has already been requested by another ldrq port"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));

        `QVL_ASSUME:
          M_LPC_30_LDRQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_channel_previously_requested_by_different_ldrq[s]))));

        `QVL_IGNORE : 
           begin : qvl_ignore_ASSERT_NEVER 
           end
         default: initial qvl_error_t (
                               .err_msg        (""),
                               .msg            (""),
                               .severity_level (QVL_ERROR),
                               .property_type  (`QVL_IGNORE));
      endcase
    end
endgenerate 
    
generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_31_LDRQ
       case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
        A_LPC_31_LDRQ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_unauthorized_channel_request_bus_mas[s]))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_LPC_31_LDRQ"}),
                          .msg            ({QVL_MSG, "A Bus Master request sent on ldrq port[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] that is not allowed to perform Bus Master cycles as two other ports have already registerd Bus Master requests"}),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
       `QVL_ASSUME:
        M_LPC_31_LDRQ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (lclk ),
                          .reset_n   (!(!lreset_n) ),
                          .enable    (1'b1),
                          .test_expr (!(1'b0 === lreset_n) &&
                           (fire_unauthorized_channel_request_bus_mas[s]))));

       `QVL_IGNORE : 
                    begin : qvl_ignore_ASSERT_NEVER 
                    end
        default: initial qvl_error_t ( .err_msg        (""),
                                        .msg            (""),
                                        .severity_level (QVL_ERROR),
                                        .property_type  (`QVL_IGNORE));
       endcase
    end 
endgenerate

generate
  for (s = 0; s < LDRQ_WIDTH; s = s + 1)
    begin  : LPC_32_LDRQ
      case  (QVL_PROPERTY_TYPE)
       `QVL_ASSERT : 
          A_LPC_32_LDRQ: 
             assert property ( ASSERT_NEVER_P ( 
                             .clock     (lclk ),
                             .reset_n   (!(!lreset_n) ),
                             .enable    (1'b1),
                             .test_expr (!(1'b0 === lreset_n) &&
                              (fire_ldrq_message_prior_to_8_clocks_of_dma_abort[s]))))
             else qvl_error_t(
                             .err_msg        ({QVL_MSG,"A_LPC_32_LDRQ"}),
                             .msg            ({QVL_MSG,"A message started on ldrq port[",8'd48+s[WIDTH_OF_LDRQ_WIDTH:0],"] prior to 8 clocks from deassertion of a DMA request using SYNC field (6.4.4)"}),
                             .severity_level (QVL_ERROR),
                             .property_type  (Constraints_Mode));
       `QVL_ASSUME:
          M_LPC_32_LDRQ: 
            assume property ( ASSERT_NEVER_P ( 
                            .clock     (lclk ),
                            .reset_n   (!(!lreset_n) ),
                            .enable    (1'b1),
                            .test_expr (!(1'b0 === lreset_n) &&
                             (fire_ldrq_message_prior_to_8_clocks_of_dma_abort[s]))));
       `QVL_IGNORE : 
           begin : qvl_ignore_ASSERT_NEVER 
           end
         default: initial qvl_error_t (
                               .err_msg        (""),
                               .msg            (""),
                               .severity_level (QVL_ERROR),
                               .property_type  (`QVL_IGNORE));
      endcase
    end 
endgenerate



`endif // QVL_ASSERT_ON
