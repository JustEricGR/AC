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

  parameter QVL_MSG = "QVL_PCI_VIOLATION: ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `QVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_TP15: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((Constraints_Mode === 0 && 
                           illegal_config_cycle === 1'b1 &&
                           devsel_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP15"}),
                          .msg            ("Violates: IUT should ignore configuration command unless IDSEL is asserted and AD[1:0]=00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ01: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (!in_tran) && 
                           (devsel_n !== 1'b1 || trdy_n !== 1'b1 || 
                           stop_n !== 1'b1 || ack64_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ01"}),
                          .msg            ("Violates: DEVSEL#, TRDY# and STOP# are never changed when IUT is not involved in transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ02_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_dual_addr_cmd_reg) && 
                           (frame_2_devsel_lat > 3'b101 && devsel_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ02_1"}),
                          .msg            ("Violates: IUT should not assert DEVSEL# more than 5 clocks after FRAME# was first sampled asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ02_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (!z_dual_addr_cmd_reg) && 
                           (frame_2_devsel_lat > 3'b100 && devsel_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ02_2"}),
                          .msg            ("Violates: IUT should not assert DEVSEL# more than 4 clocks after FRAME# was first sampled asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP03: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) && 
                           (bus_cmd === ZI_RESERVED && devsel_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP03"}),
                          .msg            ("Violates: IUT never responds to reserved commands."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP05: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) && 
                           (prev_trdy_n !== trdy_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP05"}),
                          .msg            ("Violates: Once IUT has asserted TRDY# it never changes TRDY# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) && 
                           (prev_devsel_n !== devsel_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP06"}),
                          .msg            ("Violates: Once IUT has asserted TRDY# it never changes DEVSEL# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP07: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) &&
                           (prev_stop_n !== stop_n) )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP07"}),
                          .msg            ("Violates: Once IUT has asserted TRDY# it never changes STOP# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_stop_n === 1'b0 && stop_n === 1'b1 &&
                           (prev_frame_n !== 1'b1 || irdy_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP08"}),
                          .msg            ("Violates: Once IUT has asserted STOP# it never changes STOP# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP09: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_stop_n === 1'b0) &&
                           (prev_trdy_n !== trdy_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP09"}),
                          .msg            ("Violates: Once IUT has asserted STOP# it never changes TRDY# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_stop_n === 1'b0) &&
                           (prev_devsel_n !== devsel_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP10"}),
                          .msg            ("Violates: Once IUT has asserted STOP# it never changes DEVSEL# until the data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP14: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_adr[1:0] === 2'b01 || bus_adr[1:0] === 2'b11) &&
                           memory_transaction) && 
                           (devsel_n === 1'b0 && prev_devsel_n === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP14"}),
                          .msg            ("Violates: IUT never responds to reserved encodings."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP16: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_adr[1:0] === 2'b01 || bus_adr[1:0] === 2'b11) &&
                           memory_transaction && 
                           prev_data_transfer && !z_last_data) &&
                           (!(z_disconnectc || z_disconnectab)) )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP16"}),
                          .msg            ("Violates: IUT always disconnects after the first data phase when reserved burst mode was detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP17_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE || 
                           (next_state === ZI_DATA_STATE || z_data_transfer) &&
                           ack64_n === 1'b1) && (^ad[31:0] === 1'bx))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP17_1"}),
                          .msg            ("Violates: The IUT's  AD lines are driven to stable values during every address and data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP17_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((next_state === ZI_DATA_STATE || 
                           (read_cmd == 1'b1 && trdy_n === 1'b0)) &&
                           ack64_n === 1'b0) && (^ad === 1'bx))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP17_2"}),
                          .msg            ("Violates: The IUT's AD lines are driven to stable values during every address and data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP19: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE) &&
                           bus_cbe === ZI_READ) && (trdy_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP19"}),
                          .msg            ("Violates: IUT never asserts TRDY# during turnaround cycle on a read."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP20: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((prev_data_transfer === 1'b1 || 
                           prev_stop_n === 1'b0) && z_last_data) && 
                           (trdy_n !== 1'b1 || stop_n !== 1'b1 || 
                           devsel_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP20"}),
                          .msg            ("Violates: IUT always deasserts TRDY#, STOP#, and DEVSEL# the clock following the completion of the last data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP22: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_frame_n === 1'b1) && 
                           (prev_stop_n === 1'b0 && stop_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP22"}),
                          .msg            ("Violates: IUT always deasserts STOP# the cycle immediately following FRAME# being deasserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP23: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_frame_n === 1'b0 && frame_n === 1'b1 &&
                           prev_stop_n === 1'b0 && stop_n !== 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP23"}),
                          .msg            ("Violates: Once the IUT has asserted STOP# it never deasserts STOP# until FRAME# is negated."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP24: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (trdy_n === 1'b0 && stop_n === 1'b0 && 
                           devsel_n === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP24"}),
                          .msg            ("Violates: IUT always deasserts TRDY# before signaling target-abort."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP25: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) && 
                           (prev_stop_n === 1'b0 && stop_n === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b0) ||
                           z_data_transfer))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP25"}),
                          .msg            ("Violates: IUT never deasserts STOP# and continues the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP26: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((initial_data_phase_done === 1'b0 && data_lat > 16)||
                           (initial_data_phase_done === 1'b1 && data_lat > 8) ))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP26"}),
                          .msg            ("Violates: IUT always completes initial data phase within 16 clocks."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP28_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_devsel_n === 1'b1 && devsel_n === 1'b0) &&
                           (prev_trdy_n !== 1'b1 || prev_stop_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP28_1"}),
                          .msg            ("Violates: IUT always issues DEVSEL# before any other response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP28_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_prev_devsel_n === 1'b1 && 
                           prev_devsel_n === 1'b1 && devsel_n === 1'b1) &&
                           (stop_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP28_2"}),
                          .msg            ("Violates: IUT always issues DEVSEL# before any other response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP28_3: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_devsel_n === 1'b1 && devsel_n === 1'b1) &&
                           (trdy_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP28_3"}),
                          .msg            ("Violates: IUT always issues DEVSEL# before any other response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP29: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state !== ZI_IDLE_STATE &&
                           prev_devsel_n === 1'b0 &&
                           devsel_n === 1'b1 && stop_n !== 1'b0) && 
                           (z_last_data === 1'b0 || (z_last_data && 
                           !(prev_retry || prev_data_transfer))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP29"}),
                          .msg            ("Violates: Once IUT has asserted DEVSEL# it never deasserts DEVSEL# until the last data phase has completed except to signal target-abort."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP30: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_cmd === ZI_SPECIAL_CYCLE) && 
                           (devsel_n === 1'b0 || trdy_n === 1'b0 ||
                           stop_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP30"}),
                          .msg            ("Violates: IUT never responds to special cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP31_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_target_ready && bus_cmd === ZI_READ) &&
                           (bus_state === ZI_DATA_STATE || target_ready_reg) &&
                           (par === 1'bx || par === 1'bz))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP31_1"}),
                          .msg            ("Violates: IUT always drives PAR within one clock of C/BE# and AD being driven."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP31_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_target_ready && bus_cmd === ZI_READ) &&
                           (bus_state === ZI_DATA_STATE || target_ready_reg) &&
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (par64 === 1'bx || par64 === 1'bz))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP31_2"}),
                          .msg            ("Violates: IUT always drives PAR within one clock of C/BE# and AD being driven."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP32_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) &&
                           (parity_32_tar !== par))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP32_1"}),
                          .msg            ("Violates: IUT always drives PAR such that the number of 1's on AD[31:0], C/BE[3:0], and PAR equals an even number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP32_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (parity_64_tar !== par64))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP32_2"}),
                          .msg            ("Violates: IUT always drives PAR64 such that the number of 1's on AD[63:32], C/BE[7:4], and PAR64 equals an even number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ04: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE) &&
                           (prev_irdy_n !== 1'b0 && 
                           (stop_n !== 1'b1 || trdy_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ04"}),
                          .msg            ("Violates: STOP# or TRDY# should not be asserted by the target before claiming the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ05: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (master_comp_term === 1'b1) &&
                           (devsel_n !== 1'b1 || stop_n !== 1'b1 || 
                           trdy_n !== 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ05"}),
                          .msg            ("Violates: STOP#, DEVSEL#, and TRDY# should be de-asserted at the same time."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ07: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (memory_transaction === 1'b1 && 
                           ack64_n_asserted_reg) && 
                           (ack64_n !== devsel_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ07"}),
                          .msg            (" Violates: Timing and duration of DEVSEL# and ACK64# are identical if target is 64-bit capable."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((memory_transaction === 1'b0 && 
                           req64_n === 1'b1 && frame_n === 1'b0) ||
                           (memory_transaction === 1'b1 && 
                           req64_n_asserted !== 1'b1)) && 
                           (ack64_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ08"}),
                          .msg            ("Violates: ACK64# should not be asserted if REQ64# was not asserted during address phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TZ09: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (ack64_n_asserted_reg === 1'b0 && 
                           ack64_n_asserted === 1'b0) && (ack64_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ09"}),
                          .msg            ("Violates: ACK64# should not be asserted if it was not asserted along with DEVSEL#."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_TP02: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && r_active === 1'b1) &&
                           (ParityErrorResponse === 1'b1 && perr_n === 1'b0)) &&
                           (prev1_data_transfer !== 1'b1 && 
                           delay_dut_as_mas === 1'b0 && 
                           !((write_cmd === 1'b1 && irdy_n === 1'b0 &&
                           prev1_irdy_n === 1'b0 && 
                           next_state === ZI_WAIT_STATE) ||
                           ((z_data_transfer || prev_data_transfer) && 
                           prev_perr_n === 1'b0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP02"}),
                          .msg            ("Violates: IUT never reports PERR# until it has claimed the cycle and completed a data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      /*  A_TZ06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_UNKNOWN_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TZ06"}),
                          .msg            ("Violates: Bus state machine should not be in the Unknown state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));*/
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_TP15: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((Constraints_Mode === 0 && 
                           illegal_config_cycle === 1'b1 &&
                           devsel_n === 1'b0))));
        M_TZ01: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (!in_tran) && 
                           (devsel_n !== 1'b1 || trdy_n !== 1'b1 || 
                           stop_n !== 1'b1 || ack64_n !== 1'b1))));
        M_TZ02_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_dual_addr_cmd_reg) && 
                           (frame_2_devsel_lat > 3'b101 && devsel_n === 1'b0))));
        M_TZ02_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (!z_dual_addr_cmd_reg) && 
                           (frame_2_devsel_lat > 3'b100 && devsel_n === 1'b0))));
        M_TP03: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) && 
                           (bus_cmd === ZI_RESERVED && devsel_n === 1'b0))));
        M_TP05: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) && 
                           (prev_trdy_n !== trdy_n))));
        M_TP06: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) && 
                           (prev_devsel_n !== devsel_n))));
        M_TP07: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_trdy_n === 1'b0) &&
                           (prev_stop_n !== stop_n) )));
        M_TP08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_stop_n === 1'b0 && stop_n === 1'b1 &&
                           (prev_frame_n !== 1'b1 || irdy_n !== 1'b1)))));
        M_TP09: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_stop_n === 1'b0) &&
                           (prev_trdy_n !== trdy_n))));
        M_TP10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (data_phase && prev_stop_n === 1'b0) &&
                           (prev_devsel_n !== devsel_n))));
        M_TP14: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_adr[1:0] === 2'b01 || bus_adr[1:0] === 2'b11) &&
                           memory_transaction) && 
                           (devsel_n === 1'b0 && prev_devsel_n === 1'b1))));
        M_TP16: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_adr[1:0] === 2'b01 || bus_adr[1:0] === 2'b11) &&
                           memory_transaction && 
                           prev_data_transfer && !z_last_data) &&
                           (!(z_disconnectc || z_disconnectab)) )));
        M_TP17_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE || 
                           (next_state === ZI_DATA_STATE || z_data_transfer) &&
                           ack64_n === 1'b1) && (^ad[31:0] === 1'bx))));
        M_TP17_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((next_state === ZI_DATA_STATE || 
                           (read_cmd == 1'b1 && trdy_n === 1'b0)) &&
                           ack64_n === 1'b0) && (^ad === 1'bx))));
        M_TP19: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE) &&
                           bus_cbe === ZI_READ) && (trdy_n === 1'b0))));
        M_TP20: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((prev_data_transfer === 1'b1 || 
                           prev_stop_n === 1'b0) && z_last_data) && 
                           (trdy_n !== 1'b1 || stop_n !== 1'b1 || 
                           devsel_n !== 1'b1))));
        M_TP22: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_frame_n === 1'b1) && 
                           (prev_stop_n === 1'b0 && stop_n !== 1'b1))));
        M_TP23: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_frame_n === 1'b0 && frame_n === 1'b1 &&
                           prev_stop_n === 1'b0 && stop_n !== 1'b0))));
        M_TP24: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (trdy_n === 1'b0 && stop_n === 1'b0 && 
                           devsel_n === 1'b1))));
        M_TP25: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) && 
                           (prev_stop_n === 1'b0 && stop_n === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b0) ||
                           z_data_transfer))));
        M_TP26: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((initial_data_phase_done === 1'b0 && data_lat > 16)||
                           (initial_data_phase_done === 1'b1 && data_lat > 8) ))));
        M_TP28_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_devsel_n === 1'b1 && devsel_n === 1'b0) &&
                           (prev_trdy_n !== 1'b1 || prev_stop_n !== 1'b1))));
        M_TP28_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_prev_devsel_n === 1'b1 && 
                           prev_devsel_n === 1'b1 && devsel_n === 1'b1) &&
                           (stop_n !== 1'b1))));
        M_TP28_3: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (prev_devsel_n === 1'b1 && devsel_n === 1'b1) &&
                           (trdy_n !== 1'b1))));
        M_TP29: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state !== ZI_IDLE_STATE &&
                           prev_devsel_n === 1'b0 &&
                           devsel_n === 1'b1 && stop_n !== 1'b0) && 
                           (z_last_data === 1'b0 || (z_last_data && 
                           !(prev_retry || prev_data_transfer))))));
        M_TP30: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_cmd === ZI_SPECIAL_CYCLE) && 
                           (devsel_n === 1'b0 || trdy_n === 1'b0 ||
                           stop_n === 1'b0))));
        M_TP31_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_target_ready && bus_cmd === ZI_READ) &&
                           (bus_state === ZI_DATA_STATE || target_ready_reg) &&
                           (par === 1'bx || par === 1'bz))));
        M_TP31_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (z_target_ready && bus_cmd === ZI_READ) &&
                           (bus_state === ZI_DATA_STATE || target_ready_reg) &&
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (par64 === 1'bx || par64 === 1'bz))));
        M_TP32_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) &&
                           (parity_32_tar !== par))));
        M_TP32_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (parity_64_tar !== par64))));
        M_TZ04: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE) &&
                           (prev_irdy_n !== 1'b0 && 
                           (stop_n !== 1'b1 || trdy_n !== 1'b1)))));
        M_TZ05: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (master_comp_term === 1'b1) &&
                           (devsel_n !== 1'b1 || stop_n !== 1'b1 || 
                           trdy_n !== 1'b1))));
        M_TZ07: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (memory_transaction === 1'b1 && 
                           ack64_n_asserted_reg) && 
                           (ack64_n !== devsel_n))));
        M_TZ08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           ((memory_transaction === 1'b0 && 
                           req64_n === 1'b1 && frame_n === 1'b0) ||
                           (memory_transaction === 1'b1 && 
                           req64_n_asserted !== 1'b1)) && 
                           (ack64_n === 1'b0))));
        M_TZ09: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1) && (active === 1'b1) &&
                           (ack64_n_asserted_reg === 1'b0 && 
                           ack64_n_asserted === 1'b0) && (ack64_n === 1'b0))));
        M_TP02: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && r_active === 1'b1) &&
                           (ParityErrorResponse === 1'b1 && perr_n === 1'b0)) &&
                           (prev1_data_transfer !== 1'b1 && 
                           delay_dut_as_mas === 1'b0 && 
                           !((write_cmd === 1'b1 && irdy_n === 1'b0 &&
                           prev1_irdy_n === 1'b0 && 
                           next_state === ZI_WAIT_STATE) ||
                           ((z_data_transfer || prev_data_transfer) && 
                           prev_perr_n === 1'b0)))))));
   /*     M_TZ06: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_UNKNOWN_STATE)))));*/
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
