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

  parameter QVL_MSG = "QVL_AMBA3_APB_VIOLATION : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_ALL;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_AMBA3_APB_09_pselx: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pselx),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_UNKOWN_AMBA3_APB_09_pselx"}),
                          .msg            ("Control signal, pselx, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_09_penable: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (penable),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_UNKOWN_AMBA3_APB_09_penable"}),
                          .msg            ("Control signal, penable, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_09_pwrite: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pwrite),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_UNKOWN_AMBA3_APB_09_pwrite"}),
                          .msg            ("Control signal, pwrite, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_09_pready: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_UNKOWN_AMBA3_APB_09_pready"}),
                          .msg            ("Control signal, pready, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_09_pslverr: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pslverr),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_UNKOWN_AMBA3_APB_09_pslverr"}),
                          .msg            ("Control signal, pslverr, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_AMBA3_APB_09_pselx: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pselx),
                          .qualifier (1'b1)));
        M_AMBA3_APB_09_penable: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (penable),
                          .qualifier (1'b1)));
        M_AMBA3_APB_09_pwrite: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pwrite),
                          .qualifier (1'b1)));
        M_AMBA3_APB_09_pready: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pready),
                          .qualifier (1'b1)));
        M_AMBA3_APB_09_pslverr: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk ),
                          .reset_n   (presetn),
                          .test_expr (pslverr),
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
        A_AMBA3_APB_01: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_idle_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_01"}),
                          .msg            ("The bus should advance to SETUP state or remain in IDLE state, but went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_02: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_setup_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_02"}),
                          .msg            ("The bus did not advance to ACCESS or WAIT state in one clock cycle from SETUP state, instead went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_03: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_access_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_03"}),
                          .msg            ("The bus should advance to IDLE or SETUP state, but went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_04: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_wait_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_04"}),
                          .msg            ("The bus should advance to ACCESS or stay in WAIT state, but went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_UNKN: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_UNKN"}),
                          .msg            ("The bus should advance to IDLE state, but remained in an unknown state"),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
//        A_AMBA3_APB_05: 
//          assert property ( ASSERT_NEVER_P ( 
//                          .clock     (pclk),
//                          .reset_n   (presetn),
//                          .enable    (1'b1),
//                          .test_expr ((penable === 1'b1) && (pselx !== 1'b1))))
//          else qvl_error_t(
//                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_05"}),
//                          .msg            ("The PENABLE signal should not be high when PSELx is low"),
//                          .severity_level (QVL_ERROR),
//                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (paddr_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_06"}),
                          .msg            ("The PADDR address should be stable from SETUP until ACCESS state, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_07: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwrite_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_07"}),
                          .msg            ("The PWRITE signal should be stable from SETUP until ACCESS state, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwdata_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_08"}),
                          .msg            ("The PWDATA should be stable from SETUP until ACCESS state during write cycles, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pw_ADD_BUS_WIDTH > 32))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_10"}),
                          .msg            ("Width of the APB Address bus is at most 32"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pw_DATA_BUS_WIDTH > 32))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_11"}),
                          .msg            ("Width of the APB data bus is at most 32"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_13: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pslverr === 1'b1) && ( (pselx === 1'b0) || (pready === 1'b0) || (penable === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_AMBA3_APB_13"}),
                          .msg            ("The protocol recommends PSLVERR to be low when any of PSEL, PENABLE or PREADY is low"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_AMBA3_APB_01: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_idle_to_unknown)));
        M_AMBA3_APB_02: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_setup_to_unknown)));
        M_AMBA3_APB_03: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_access_to_unknown)));
        M_AMBA3_APB_04: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_wait_to_unknown)));
        M_AMBA3_APB_UNKN: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown)));
//        M_AMBA3_APB_05: 
//          assume property ( ASSERT_NEVER_P ( 
//                          .clock     (pclk),
//                          .reset_n   (presetn),
//                          .enable    (1'b1),
//                          .test_expr ((penable === 1'b1) && (pselx !== 1'b1))));
        M_AMBA3_APB_06: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (paddr_fire)));
        M_AMBA3_APB_07: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwrite_fire)));
        M_AMBA3_APB_08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwdata_fire)));
        M_AMBA3_APB_10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pw_ADD_BUS_WIDTH > 32))));
        M_AMBA3_APB_11: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pw_DATA_BUS_WIDTH > 32))));
        M_AMBA3_APB_13: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((pslverr === 1'b1) && ( (pselx === 1'b0) || (pready === 1'b0) || (penable === 1'b0)))));
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

  //**** ZiCwNote ****
  // Note that every time a stop event occurs, the win_unchange assertion is
  // given a reset. This is done inorder to mimic -exclude_stop option of the
  // change window assertion.
 
  reg window_AMBA3_APB_12_paddr;
  reg window_AMBA3_APB_12_pwrite;

  always @ (posedge pclk) begin 
    if ((presetn & ~(pselx === 1'b1 && penable === 1'b0)) != 1'b0) begin 
      if (!window_AMBA3_APB_12_paddr && 
          (next_state === ZI_ACCESS_STATE) == 1'b1)
        window_AMBA3_APB_12_paddr <= 1'b1;
      else if (window_AMBA3_APB_12_paddr && 
          (pselx === 1'b1 && penable === 1'b0) == 1'b1)
        window_AMBA3_APB_12_paddr <= 1'b0;
      end
    else 
      window_AMBA3_APB_12_paddr <= 1'b0;
    end

  always @ (posedge pclk) begin 
    if ((presetn & ~(pselx === 1'b1 && penable === 1'b0)) != 1'b0) begin 
      if (!window_AMBA3_APB_12_pwrite && 
          (next_state === ZI_ACCESS_STATE) == 1'b1)
        window_AMBA3_APB_12_pwrite <= 1'b1;
      else if (window_AMBA3_APB_12_pwrite && 
          (pselx === 1'b1 && penable === 1'b0) == 1'b1)
        window_AMBA3_APB_12_pwrite <= 1'b0;
      end
    else 
      window_AMBA3_APB_12_pwrite <= 1'b0;
    end

generate

  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_WIN_UNCHANGE 
        A_AMBA3_APB_12_paddr: 
          assert property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((next_state === ZI_ACCESS_STATE)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_AMBA3_APB_12_paddr),
                          .test_expr   (paddr)))
          else qvl_error_t (
                          .err_msg        ({QVL_MSG,"A_ASSERT_WIN_UNCHANGE_AMBA3_APB_12_paddr"}),
                          .msg            ("To reduce power consumption, PADDR must not change after a transfer until the next access occurs"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_AMBA3_APB_12_pwrite: 
          assert property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((next_state === ZI_ACCESS_STATE)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_AMBA3_APB_12_pwrite),
                          .test_expr   (pwrite)))
          else qvl_error_t (
                          .err_msg        ({QVL_MSG,"A_ASSERT_WIN_UNCHANGE_AMBA3_APB_12_pwrite"}),
                          .msg            ("To reduce power consumption, PWRITE must not change after a transfer until the next access occurs"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_WIN_UNCHANGE 
        M_AMBA3_APB_12_paddr: 
          assume property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((next_state === ZI_ACCESS_STATE)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_AMBA3_APB_12_paddr),
                          .test_expr   (paddr)));
        M_AMBA3_APB_12_pwrite: 
          assume property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((next_state === ZI_ACCESS_STATE)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_AMBA3_APB_12_pwrite),
                          .test_expr   (pwrite)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_WIN_UNCHANGE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate
 

  //-----------------------------------------------------------------------------

`endif // QVL_ASSERT_ON
