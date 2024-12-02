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

wire MP02_2_wire = (((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cbe === ZI_MEM_WINV_CYCLE &&
                           next_state === ZI_DATA_STATE)) &&
                           (Bit64Mode && req64_n_asserted_reg === 1'b1 &&
                           ack64_n === 1'b0 && c_be[CBE-1:CBE-4] !== 4'h0));

wire MP33_wire = ( (reset_n === 1'b1 && active === 1'b1) &&
             (|ad[ADB-1:ADB-32] === 1'b0 && bus_state == ZI_DUAL_ADDR_STATE) );

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_MZ01: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cmd === ZI_RESERVED && 
                           bus_state == ZI_ADDR_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ01"}),
                          .msg            ("Violates: IUT nevers uses C/BE# ZI_RESERVED bus command"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ02: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0)) &&
                           (irdy_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ02"}),
                          .msg            ("Violates: IUT asserts FRAME# only to indicate the start of transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ03: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0))&&
                           (!(bus_state === ZI_IDLE_STATE || z_last_data ||
                           (bus_state === ZI_EXIT_STATE && 
                           prev_devsel_n === 1'b0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ03"}),
                          .msg            ("Violates: IUT asserts FRAME# when the bus is idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ04: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           ((in_tran === 1'b0 ||
                           (next_state === ZI_EXIT_STATE && in_tran === 1'b1 &&
                           bus_state !== ZI_WAIT_STATE && 
                           bus_state !== ZI_TARGET_ABORT_STATE && 
                           bus_state !== ZI_MASTER_ABORT_STATE && 
                           bus_devsel_signal_n !== 1'b0) ||
                           (prev_frame_n === 1'b1 && 
                           bus_state !== ZI_MASTER_ABORT_STATE &&
                           (prev_stop_n === 1'b0 || prev_trdy_n === 1'b0))) && 
                           external_devsel_asserted === 1'b0 && 
                           irdy_n !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ04"}),
                          .msg            ("Violates: IRDY# is never asserted when the master is not in transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ05: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_stop_n === 1'b0))&&
                           (frame_n !== 1'b1 && irdy_n === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ05"}),
                          .msg            ("Violates: Whenever STOP# is asserted, the master must de-assert FRAME# as soon as IRDY# can be asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP02_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cbe === ZI_MEM_WINV_CYCLE && 
                           next_state === ZI_DATA_STATE)) &&
                           (c_be[3:0] !== 4'h0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP02_1"}),
                          .msg            ("Violates: IUT always asserts byte enables during each data phase of a Memory Write Invalidate cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP02_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (MP02_2_wire) ) ) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP02_2"}),
                          .msg            ("Violates: IUT always asserts byte enables during each data phase of a Memory Write Invalidate cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP03: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cbe === ZI_MEM_WINV_CYCLE && 
                           bus_state == ZI_ADDR_STATE)) &&
                           (bus_adr[1:0] !== 2'b00)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP03"}),
                          .msg            ("Violates: IUT always uses Linear Burst Ordering for Memory Write Invalidate cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (in_tran &&(prev_frame_n !== frame_n) && 
                           prev_irdy_n === 1'b0 &&
                           !(prev_devsel_n === 1'b0 &&(prev_trdy_n === 1'b0
                           || prev_stop_n === 1'b0)) && 
                           !(prev_devsel_n == 1'b1 && prev_trdy_n == 1'b1 &&
                           prev_stop_n == 1'b0) && 
                           bus_state !== ZI_MASTER_ABORT_STATE && bus_state !== ZI_EXIT_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP06"}),
                          .msg            ("Violates: Once IUT asserts IRDY# it never changes FRAME# until the current data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP07: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (in_tran &&(prev_irdy_n !== irdy_n) &&
                           prev_irdy_n === 1'b0 &&
			   !(devsel_n === 1'b1 && stop_n === 1'b1 && trdy_n === 1'b1) &&
                           !(prev_devsel_n === 1'b0 &&
                           (prev_trdy_n === 1'b0 || prev_stop_n === 1'b0)) &&
                           !(prev_devsel_n == 1'b1 && prev_trdy_n == 1'b1 &&
                           prev_stop_n == 1'b0 && frame_n === 1'b1) && 
                           prev_state !== ZI_MASTER_ABORT_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP07"}),
                          .msg            ("Violates: Once IUT asserts IRDY# it never changes IRDY# until the current data phase completes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE)) &&
                           (c_be[3:0] === ZI_READ_ACCESS_CYCLE  ||
                           c_be[3:0] === ZI_WRITE_ACCESS_CYCLE ||
                           c_be[3:0] === ZI_MEM_RDMULT_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDLINE_CYCLE || 
                           c_be[3:0] === ZI_MEM_WINV_CYCLE)) && 
                           ((ad[1:0] === 2'b01 && !reg_dual_cmd) ||
                           (bus_adr[1:0] === 2'b01 && reg_dual_cmd)))
                           ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP08"}),
                          .msg            ("Violates: IUT never uses reserved burst ordering (AD[1:0] = 01)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP09: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE))&& 
                           (c_be[3:0] === ZI_READ_ACCESS_CYCLE  ||
                           c_be[3:0] === ZI_WRITE_ACCESS_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDMULT_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDLINE_CYCLE || 
                           c_be[3:0] === ZI_MEM_WINV_CYCLE) && 
                           ((ad[1:0] === 2'b11 && !reg_dual_cmd) ||
                           (bus_adr[1:0] === 2'b11 && reg_dual_cmd))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP09"}),
                          .msg            ("Violates: IUT never uses reserved burst ordering (AD[1:0] = 11)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP11_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE ||
                           (write_cmd === 1'b1 && irdy_n === 1'b0)) &&
                           ack64_n === 1'b1)) &&(^ad[31:0] === 1'bx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP11_1"}),
                          .msg            ("Violates: The IUT's AD lines are driven to stable values during every address and data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP11_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (((next_state === ZI_DATA_STATE ||
                           (write_cmd === 1'b1 && irdy_n === 1'b0)) &&
                           ack64_n === 1'b0) &&(^ad === 1'bx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP11_2"}),
                          .msg            ("Violates: The IUT's AD lines are driven to stable values during every address and data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP12_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE || data_phase) &&
                           ack64_n === 1'b1)) &&(^c_be[3:0] === 1'bx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP12_1"}),
                          .msg            ("Violates: The IUT's C/BE# output buffers remain enabled from the first clock of the data phase through the end of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP12_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE ||
                           data_phase) && ack64_n === 1'b0) &&
                           (^c_be === 1'bx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP12_2"}),
                          .msg            ("Violates: The IUT's C/BE# output buffers remain enabled from the first clock of the data phase through the end of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP14: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b1) &&
                           (!(prev_irdy_n === 1'b0 || irdy_n === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP14"}),
                          .msg            ("Violates: IUT never deasserts FRAME# unless IRDY# is asserted or will be asserted"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP15: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b1) &&
                           (prev_irdy_n === 1'b0 && irdy_n === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP15"}),
                          .msg            ("Violates: IUT never deasserts IRDY# until at least one clock after FRAME# is deasserted"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP16: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((bus_state !== ZI_IDLE_STATE && 
                           bus_state !== ZI_EXIT_STATE && !z_last_data) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP16"}),
                          .msg            ("Violates: Once the IUT deasserts FRAME# it never reasserts FRAME# during the same transaction"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP17: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (devsel_n === 1'b0 && 
                           frame_2_devsel_lat <= 3'b100 && 
                           bus_state === ZI_MASTER_ABORT_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP17"}),
                          .msg            ("Violates: IUT never terminates with master abort once target has asserted DEVSEL#"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP18: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (((frame_2_devsel_lat < 3'b100 && 
                           reg_dual_cmd === 1'b0) ||
                           (frame_2_devsel_lat <3'b101 && 
                           reg_dual_cmd === 1'b1)) &&
                           next_state === ZI_MASTER_ABORT_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP18"}),
                          .msg            ("Violates: IUT never signals master abort earlier than 5 clocks after FRAME# was first sampled asserted"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP20: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((Constraints_Mode == 0 && ZI_FLIP_SIGNALS === 0 && 
                           prev_frame_n === 1'b1 && frame_n === 1'b0) &&
                           (prev_gnt_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP20"}),
                          .msg            ("Violates: IUT never starts a cycle unless GNT# is asserted"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP23: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((data_lat == 7 && irdy_n !== 1'b0 && 
                           initial_data_phase_done == 1'b0) ||
                           (initial_data_phase_done == 1'b1 && 
                           subs_data_lat == 8 && irdy_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP23"}),
                          .msg            ("Violates: IUT always asserts IRDY# within eight clocks on all data phases"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP27: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((illegal_burst_ordering === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP27"}),
                          .msg            ("Violates: IUT always uses Linear Burst Ordering for Configuration Cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP28_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE || 
                           bus_state === ZI_DATA_STATE ||
                           initiator_ready_reg) && 
                           (par === 1'bx || par === 1'bz) )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP28_1"}),
                          .msg            ("Violates: IUT always drives PAR within one clock of C/BE# and AD being driven."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP28_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_ADDR_STATE ||
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE || 
                           initiator_ready_reg) && 
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (par64 === 1'bx || par64 === 1'bz))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP28_2"}),
                          .msg            ("Violates: IUT always drives PAR within one clock of C/BE# and AD being driven."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP29_1: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE ||
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           (parity_32 !== par))
                           ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP29_1"}),
                          .msg            ("Violates: IUT always drives PAR such that the number of 1's on AD[31:0], C/BE[3:0], and PAR equals an even number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP29_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           ((prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (parity_64 !== par64)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP29_2"}),
                          .msg            ("Violates: IUT always drives PAR64 such that the number of 1's on AD[63:32], C/BE[7:4], and PAR64 equals an even number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP32: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_DUAL_ADDR_STATE) && 
                           (frame_n !== 1'b0))
                           ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP32"}),
                          .msg            ("Violates: IUT always holds FRAME# asserted for cycle following DUAL command."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP33: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (MP33_wire) ) ) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP33"}),
                          .msg            ("Violates: IUT never generates DUAL cycle when upper 32-bits of address are zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
/*        A_MZ07_01: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
			  .test_expr((reset_n === 1'b1 && active === 1'b1) &&
                          (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE ||
                          ((next_state === ZI_DATA_STATE || 
                            next_state === ZI_WAIT_STATE || data_phase) &&
                            ack64_n === 1'b1)) && (^c_be[3:0] === 1'bx))
			   ))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ07_01"}),
                          .msg            ("Violates: The IUT's C/BE# output buffers remain enabled from the first clock of the data phase through the end of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ07_02: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   (!(!reset_n)),
                          .enable    (1'b1),
			  .test_expr((reset_n === 1'b1 && active === 1'b1) &&
                          ((next_state === ZI_DATA_STATE || 
                            next_state === ZI_WAIT_STATE) &&
                            ack64_n === 1'b0) && (^c_be === 1'bx))
                           ))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ07_02"}),
                          .msg            ("Violates: The IUT's C/BE# output buffers should remain enabled from the first clock of the data phase through the end of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));*/
        A_MZ08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE ||
                           data_phase) && ack64_n === 1'b1)) && 
                           (^c_be[3:0] === 1'bx) )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ08"}),
                          .msg            ("Violates: Valid Combination of AD and BE during I/O cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ09: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (Bit64Mode === 1 && 
                           z_memory_transaction_cbe === 1'b1 &&
                           req64_n_asserted_reg) && 
                           (req64_n !== frame_n))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ09"}),
                          .msg            ("Violates: FRAME# and REQ64# should be identical during 64-bit memory transactions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock     ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (Bit64Mode === 1'b1 &&
                           req64_n_asserted_reg === 1'b0 &&
                           req64_n_asserted === 1'b0) &&
                           (req64_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ10"}),
                          .msg            ("Violates: REQ64# should not be asserted if it was not asserted during address phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MZ11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (Bit64Mode === 1 && 
                           z_memory_transaction_cbe === 1'b0 &&
                           next_state === ZI_ADDR_STATE) && 
                           (req64_n === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ11"}),
                          .msg            ("Violates: IUT always drives REQ64# only during memory transactions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_MP30: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && r_active === 1'b1 && 
                           ParityErrorResponse === 1'b1) &&
                           (parity_error === 1'b1 && perr_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP30"}),
                          .msg            ("Violates: IUT always drives PERR# (when enabled) active two clocks after data when data parity error is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
/*        A_MZ12: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((r_active === 1'b1 && active === 1'b0 && 
                           in_tran === 1'b1 && 
                           bus_state !== ZI_MASTER_ABORT_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ12"}),
                          .msg            ("Violates: Abrupt termination of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MZ13: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((prev_frame_n === 1'b1 && frame_n === 1'b0 && 
                           r_active === 1'b1 && frame_2_devsel_lat !== 1 &&
                           prev_stop_n !== 1'b0 && prev_irdy_n !== 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ13"}),
                          .msg            ("Violates: Abrupt termination of the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MZ06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_UNKNOWN_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MZ06"}),
                          .msg            ("Violates: PCI master monitor should not be in an Unknown State."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));*/
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_MZ01: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cmd === ZI_RESERVED && 
                           bus_state == ZI_ADDR_STATE)))));
        M_MZ02: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0)) &&
                           (irdy_n !== 1'b1)))));
        M_MZ03: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0))&&
                           (!(bus_state === ZI_IDLE_STATE || z_last_data ||
                           (bus_state === ZI_EXIT_STATE && 
                           prev_devsel_n === 1'b0)))))));
        M_MZ04: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           ((in_tran === 1'b0 ||
                           (next_state === ZI_EXIT_STATE && in_tran === 1'b1 &&
                           bus_state !== ZI_WAIT_STATE && 
                           bus_state !== ZI_TARGET_ABORT_STATE && 
                           bus_state !== ZI_MASTER_ABORT_STATE && 
                           bus_devsel_signal_n !== 1'b0) ||
                           (prev_frame_n === 1'b1 && 
                           bus_state !== ZI_MASTER_ABORT_STATE &&
                           (prev_stop_n === 1'b0 || prev_trdy_n === 1'b0))) && 
                           external_devsel_asserted === 1'b0 && 
                           irdy_n !== 1'b1)))));
        M_MZ05: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (prev_stop_n === 1'b0))&&
                           (frame_n !== 1'b1 && irdy_n === 1'b0)))));
        M_MP02_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cbe === ZI_MEM_WINV_CYCLE && 
                           next_state === ZI_DATA_STATE)) &&
                           (c_be[3:0] !== 4'h0)))));
        M_MP02_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (MP02_2_wire) ));
        M_MP03: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_cbe === ZI_MEM_WINV_CYCLE && 
                           bus_state == ZI_ADDR_STATE)) &&
                           (bus_adr[1:0] !== 2'b00)))));
        M_MP06: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (in_tran &&(prev_frame_n !== frame_n) && 
                           prev_irdy_n === 1'b0 &&
                           !(prev_devsel_n === 1'b0 &&(prev_trdy_n === 1'b0
                           || prev_stop_n === 1'b0)) && 
                           !(prev_devsel_n == 1'b1 && prev_trdy_n == 1'b1 &&
                           prev_stop_n == 1'b0) && 
                           bus_state !== ZI_MASTER_ABORT_STATE)))));
        M_MP07: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && active === 1'b1) &&
                           (in_tran &&(prev_irdy_n !== irdy_n) &&
                           prev_irdy_n === 1'b0 &&
                           !(prev_devsel_n === 1'b0 &&
                           (prev_trdy_n === 1'b0 || prev_stop_n === 1'b0)) &&
                           !(prev_devsel_n == 1'b1 && prev_trdy_n == 1'b1 &&
                           prev_stop_n == 1'b0 && frame_n === 1'b1) && 
                           prev_state !== ZI_MASTER_ABORT_STATE)))));
        M_MP08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE)) &&
                           (c_be[3:0] === ZI_READ_ACCESS_CYCLE  ||
                           c_be[3:0] === ZI_WRITE_ACCESS_CYCLE ||
                           c_be[3:0] === ZI_MEM_RDMULT_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDLINE_CYCLE || 
                           c_be[3:0] === ZI_MEM_WINV_CYCLE)) && 
                           ((ad[1:0] === 2'b01 && !reg_dual_cmd) ||
                           (bus_adr[1:0] === 2'b01 && reg_dual_cmd)))
                           ));
        M_MP09: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE))&& 
                           (c_be[3:0] === ZI_READ_ACCESS_CYCLE  ||
                           c_be[3:0] === ZI_WRITE_ACCESS_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDMULT_CYCLE || 
                           c_be[3:0] === ZI_MEM_RDLINE_CYCLE || 
                           c_be[3:0] === ZI_MEM_WINV_CYCLE) && 
                           ((ad[1:0] === 2'b11 && !reg_dual_cmd) ||
                           (bus_adr[1:0] === 2'b11 && reg_dual_cmd))))));
        M_MP11_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE ||
                           (write_cmd === 1'b1 && irdy_n === 1'b0)) &&
                           ack64_n === 1'b1)) &&(^ad[31:0] === 1'bx)))));
        M_MP11_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (((next_state === ZI_DATA_STATE ||
                           (write_cmd === 1'b1 && irdy_n === 1'b0)) &&
                           ack64_n === 1'b0) &&(^ad === 1'bx)))));
        M_MP12_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((next_state === ZI_ADDR_STATE || 
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE || data_phase) &&
                           ack64_n === 1'b1)) &&(^c_be[3:0] === 1'bx)))));
        M_MP12_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE ||
                           data_phase) && ack64_n === 1'b0) &&
                           (^c_be === 1'bx)))));
        M_MP14: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b1) &&
                           (!(prev_irdy_n === 1'b0 || irdy_n === 1'b0))))));
        M_MP15: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((prev_frame_n === 1'b0 && frame_n === 1'b1) &&
                           (prev_irdy_n === 1'b0 && irdy_n === 1'b1)))));
        M_MP16: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((bus_state !== ZI_IDLE_STATE && 
                           bus_state !== ZI_EXIT_STATE && !z_last_data) &&
                           (prev_frame_n === 1'b1 && frame_n === 1'b0)))));
        M_MP17: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (devsel_n === 1'b0 && 
                           frame_2_devsel_lat <= 3'b100 && 
                           bus_state === ZI_MASTER_ABORT_STATE))));
        M_MP18: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (((frame_2_devsel_lat < 3'b100 && 
                           reg_dual_cmd === 1'b0) ||
                           (frame_2_devsel_lat <3'b101 && 
                           reg_dual_cmd === 1'b1)) &&
                           next_state === ZI_MASTER_ABORT_STATE))));
        M_MP20: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           ((Constraints_Mode == 0 && ZI_FLIP_SIGNALS === 0 && 
                           prev_frame_n === 1'b1 && frame_n === 1'b0) &&
                           (prev_gnt_n !== 1'b0)))));
        M_MP23: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((data_lat == 7 && irdy_n !== 1'b0 && 
                           initial_data_phase_done == 1'b0) ||
                           (initial_data_phase_done == 1'b1 && 
                           subs_data_lat == 8 && irdy_n !== 1'b0)))));
        M_MP27: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           ((illegal_burst_ordering === 1'b1)))));
        M_MP28_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE || 
                           bus_state === ZI_DATA_STATE ||
                           initiator_ready_reg) && 
                           (par === 1'bx || par === 1'bz) )));
        M_MP28_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_ADDR_STATE ||
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE || 
                           initiator_ready_reg) && 
                           (prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (par64 === 1'bx || par64 === 1'bz))));
        M_MP29_1: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE ||
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           (parity_32 !== par))
                           ));
        M_MP29_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (bus_state === ZI_ADDR_STATE || 
                           bus_state === ZI_DUAL_ADDR_STATE ||
                           bus_state === ZI_DATA_STATE || 
                           (r_z_last_data_phase && prev_trdy_n === 1'b0)) && 
                           ((prev_req64_n === 1'b0 && prev_ack64_n === 1'b0) &&
                           (parity_64 !== par64)))));
        M_MP32: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (bus_state === ZI_DUAL_ADDR_STATE) && 
                           (frame_n !== 1'b0))
                           ));
        M_MP33: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock  ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (MP33_wire )));
  /*      M_MZ07_01: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   (!(!reset_n)),
                          .enable    (1'b1),
                          .test_expr((reset_n === 1'b1 && active === 1'b1) &&
                          (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE ||
                          ((next_state === ZI_DATA_STATE || 
                            next_state === ZI_WAIT_STATE || data_phase) &&
                           ack64_n === 1'b1)) && (^c_be[3:0] === 1'bx)) 					     
			   ))	     
        M_MZ07_02: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock),
                          .reset_n   (!(!reset_n)),
                          .enable    (1'b1),
			  .test_expr((reset_n === 1'b1 && active === 1'b1) &&
                          ((next_state === ZI_DATA_STATE || 
                            next_state === ZI_WAIT_STATE) &&
                            ack64_n === 1'b0) && (^c_be === 1'bx))
                          ))		     */
					     
        M_MZ08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (next_state === ZI_ADDR_STATE ||
                           next_state === ZI_DUAL_ADDR_STATE ||
                           ((next_state === ZI_DATA_STATE || 
                           next_state === ZI_WAIT_STATE ||
                           data_phase) && ack64_n === 1'b1)) && 
                           (^c_be[3:0] === 1'bx) )));
        M_MZ09: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (Bit64Mode === 1 && 
                           z_memory_transaction_cbe === 1'b1 &&
                           req64_n_asserted_reg) && 
                           (req64_n !== frame_n))));
        M_MZ10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock     ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) &&
                           (Bit64Mode === 1'b1 &&
                           req64_n_asserted_reg === 1'b0 &&
                           req64_n_asserted === 1'b0) &&
                           (req64_n === 1'b0))));
        M_MZ11: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((reset_n === 1'b1 && active === 1'b1) && 
                           (Bit64Mode === 1 && 
                           z_memory_transaction_cbe === 1'b0 &&
                           next_state === ZI_ADDR_STATE) && 
                           (req64_n === 1'b0))));
        M_MP30: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr (((reset_n === 1'b1 && r_active === 1'b1 && 
                           ParityErrorResponse === 1'b1) &&
                           (parity_error === 1'b1 && perr_n !== 1'b0)))));
 /*       M_MZ12: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((r_active === 1'b1 && active === 1'b0 && 
                           in_tran === 1'b1 && 
                           bus_state !== ZI_MASTER_ABORT_STATE))));
        M_MZ13: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(!reset_n) ),
                          .enable    (1'b1),
                          .test_expr ((prev_frame_n === 1'b1 && frame_n === 1'b0 && 
                           r_active === 1'b1 && frame_2_devsel_lat !== 1 &&
                           prev_stop_n !== 1'b0 && prev_irdy_n !== 1'b0))));
        M_MZ06: 
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
