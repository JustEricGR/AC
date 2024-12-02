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

  //----------------------------------------------------------------------
  // OVL Assertions start here
  //----------------------------------------------------------------------

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO  // Used for -quiet checkers
  parameter QVL_PROPERTY_TYPE = Constraints_Mode;
                             // 0 = `OVL_ASSERT; Not a constraint;
                             // 1 = `OVL_ASSUME; Constraints_Mode set to 1
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  parameter QVL_MSG = "QVL_APB_VIOLATION : ";

  //-----------------------------------------------------------------------
  // Protocol checks
  //-----------------------------------------------------------------------

  // Assert only checks
        A_APB_10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((ADD_BUS_WIDTH > 32))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_10"}),
                          .msg            ("Width of the APB Address bus is at most 32"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_APB_11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr ((DATA_BUS_WIDTH > 32))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_11"}),
                          .msg            ("Width of the APB data bus is at most 32"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

  // Both assert and assume checks 
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_APB_01: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_idle_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_01"}),
                          .msg            ("The bus should advance to SETUP state or remain in IDLE state, but went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_02: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_setup_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_02"}),
                          .msg            ("The bus did not advance to ENABLE state in one clock cycle, instead went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_03: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_enable_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_03"}),
                          .msg            ("The bus should advance to IDLE or SETUP state, but went to an unknown state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_04: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_04"}),
                          .msg            ("The bus should advance to IDLE state, but remained in an unknown state"),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_05: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (((penable === 1'b1) && (pselx !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_05"}),
                          .msg            ("The PENABLE signal should not be high when PSELx is low"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_06: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (paddr_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_06"}),
                          .msg            ("The PADDR address should be stable while transitioning from SETUP to ENABLE state, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_07: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwrite_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_07"}),
                          .msg            ("The PWRITE signal should be stable while transitioning from SETUP to ENABLE state, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_08: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwdata_fire)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_08"}),
                          .msg            ("The PWDATA should be stable while transitioning from SETUP to ENABLE state during write cycles, but has changed"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_APB_01: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_idle_to_unknown)));
        M_APB_02: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_setup_to_unknown)));
        M_APB_03: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_enable_to_unknown)));
        M_APB_04: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (bus_unknown_to_unknown)));
        M_APB_05: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (((penable === 1'b1) && (pselx !== 1'b1)))));
        M_APB_06: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (paddr_fire)));
        M_APB_07: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwrite_fire)));
        M_APB_08: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .enable    (1'b1),
                          .test_expr (pwdata_fire)));
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
        A_APB_09_pselx: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .test_expr (pselx),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_09_pselx"}),
                          .msg            ("Control signal, pselx, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_APB_09_penable: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .test_expr (penable),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_09_penable"}),
                          .msg            ("Control signal, penable, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_APB_09_pwrite: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pclk),
                          .reset_n   (presetn),
                          .test_expr (pwrite),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_APB_09_pwrite"}),
                          .msg            ("Control signal, pwrite, should not be X or Z"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0)); 

  
`endif // QVL_XCHECK_OFF

  reg window_APB_12_paddr;
  reg window_APB_12_pwrite;

  always @ (posedge pclk) begin 
    if ((presetn & ~(pselx === 1'b1 && penable === 1'b0)) != 1'b0) begin 
      if (!window_APB_12_paddr && 
          (pselx === 1'b1 && penable === 1'b1) == 1'b1)
        window_APB_12_paddr <= 1'b1;
      else if (window_APB_12_paddr && 
          (pselx === 1'b1 && penable === 1'b0) == 1'b1)
        window_APB_12_paddr <= 1'b0;
      end
    else 
      window_APB_12_paddr <= 1'b0;
    end

  always @ (posedge pclk) begin 
    if ((presetn & ~(pselx === 1'b1 && penable === 1'b0)) != 1'b0) begin 
      if (!window_APB_12_pwrite && 
          (pselx === 1'b1 && penable === 1'b1) == 1'b1)
        window_APB_12_pwrite <= 1'b1;
      else if (window_APB_12_pwrite && 
          (pselx === 1'b1 && penable === 1'b0) == 1'b1)
        window_APB_12_pwrite <= 1'b0;
      end
    else 
      window_APB_12_pwrite <= 1'b0;
    end
  //**** ZiCwNote ****
  // Note that every time a stop event occurs, the win_unchange assertion is
  // given a reset. This is done inorder to mimic -exclude_stop option of the
  // change window assertion.
generate

  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_WIN_UNCHANGE 
        A_APB_12_paddr: 
          assert property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((pselx === 1'b1 && penable === 1'b1)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_APB_12_paddr),
                          .test_expr   (paddr)))
          else qvl_error_t (
                          .err_msg        ({QVL_MSG,"A_APB_12_paddr"}),
                          .msg            ("To reduce power consumption, PADDR must not change after a transfer until the next access occurs"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_APB_12_pwrite: 
          assert property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((pselx === 1'b1 && penable === 1'b1)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_APB_12_pwrite),
                          .test_expr   (pwrite)))
          else qvl_error_t (
                          .err_msg        ({QVL_MSG,"A_APB_12_pwrite"}),
                          .msg            ("To reduce power consumption, PWRITE must not change after a transfer until the next access occurs"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_WIN_UNCHANGE 
        M_APB_12_paddr: 
          assume property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((pselx === 1'b1 && penable === 1'b1)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_APB_12_paddr),
                          .test_expr   (paddr)));
        M_APB_12_pwrite: 
          assume property ( ASSERT_WIN_UNCHANGE_P ( 
                          .clock       (pclk),
                          .reset_n     ((presetn & ~(pselx === 1'b1 && penable === 1'b0))),
                          .enable      (1'b1),
                          .start_event ((pselx === 1'b1 && penable === 1'b1)),
                          .end_event   ((pselx === 1'b1 && penable === 1'b0)), 
                          .window      (window_APB_12_pwrite),
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
 
`endif
