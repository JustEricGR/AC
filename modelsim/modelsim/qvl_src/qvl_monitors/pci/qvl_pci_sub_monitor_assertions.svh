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


`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_UNKNOWN 
        A_IO_pci_ad_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_ad_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_ad_en_n"}),
                          .msg            ("pci_ad_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_cbe_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_cbe_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_cbe_en_n"}),
                          .msg            ("pci_cbe_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_frame_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_frame_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_frame_en_n"}),
                          .msg            ("pci_frame_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_irdy_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_irdy_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_irdy_en_n"}),
                          .msg            ("pci_irdy_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_trdy_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_trdy_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_trdy_en_n"}),
                          .msg            ("pci_trdy_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_devsel_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_devsel_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_devsel_en_n"}),
                          .msg            ("pci_devsel_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_stop_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_stop_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_stop_en_n"}),
                          .msg            ("pci_stop_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_perr_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_perr_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_perr_en_n"}),
                          .msg            ("pci_perr_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_par_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_par_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0 && 
                           ParityErrorResponse === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_par_en_n"}),
                          .msg            ("pci_par_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_par64_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_par64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_par64_en_n"}),
                          .msg            ("pci_par64_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_req64_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_req64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_req64_en_n"}),
                          .msg            ("pci_req64_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO_pci_ack64_en_n: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_ack64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO_pci_ack64_en_n"}),
                          .msg            ("pci_ack64_en_n is undriven"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_UNKNOWN 
        M_IO_pci_ad_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_ad_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_cbe_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_cbe_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_frame_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_frame_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_irdy_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_irdy_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_trdy_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_trdy_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_devsel_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_devsel_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_stop_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_stop_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_perr_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_perr_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_par_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_par_en_n),
                          .qualifier (((ZI_FLIP_SIGNALS === 0 && 
                           ParityErrorResponse === 1)))));
        M_IO_pci_par64_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_par64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_req64_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_req64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
        M_IO_pci_ack64_en_n: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .test_expr (pci_ack64_en_n_real),
                          .qualifier (((ZI_FLIP_SIGNALS === 0)))));
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
        A_IO23: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           (((pci_rst_in_n === 1'b1 && 
                           dut_as_mas_tmp === 1'b1) &&
                           (prev_frame_out_n === 1'b1 &&
                           pci_frame_out_n === 1'b0 &&
                           (prev_gnt_n !== 1'b0 || prev_frame_in_n !== 1'b1 
                           ||(prev_irdy_in_n !== 1'b1 &&
                           prev_irdy_out_n === 1'b1)))))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO23"}),
                          .msg            ("FRAME# should not be driven low if GNT# is not asserted and the bus is idle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MP22: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           (((pci_rst_in_n === 1'b1 && 
                           dut_as_mas_tmp === 1'b1) &&
                           (count_flag === 1'b1 && add_cbe_lat === 5'h7 &&
                           (pci_ad_en_n !== 1'b0 || 
                           pci_cbe_en_n !== 1'b0))))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP22"}),
                          .msg            ("Violates: IUT always drives C/BE# and AD within eight clocks of GNT# assertion when bus is idle"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO10: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 1 && ZI_SELF_CONFIG === 0)) &&
                           ((dut_as_tar_tmp === 1 && dut_as_mas_tmp === 1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO10"}),
                          .msg            ("PCI monitor in both Master & Target mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_IO11: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 1)) &&
                           (((pci_rst_in_n === 0) &&
                           (dut_as_tar_tmp || dut_as_mas_tmp)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO11"}),
                          .msg            ("Master or Target transaction is interrupted by reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_IO12: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((Constraints_Mode && dut_as_mas_tmp && 
                           ZI_FLIP_SIGNALS === 1)  &&
                           ((pci_frame_in_n !== pci_frame_out_n) ||
                           (pci_irdy_in_n !== pci_irdy_out_n) ||
                           (pci_req64_in_n_real !== pci_req64_out_n_real))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO12"}),
                          .msg            ("Input FRAME#, IRDY#, and REQ64# signals should not be toggled when DUT is in master mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO21: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           ((pci_stop_en_n !== pci_trdy_en_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO21"}),
                          .msg            ("Outputs STOP# and TRDY# are not enabled together."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO22: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           ((pci_stop_en_n !== pci_devsel_en_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO22"}),
                          .msg            ("Outputs STOP# and DEVSEL# are not enabled together."),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
/*        A_IO24: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_devsel_in_n !== pci_devsel_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO24"}),
                          .msg            ("Violates:  Formal Tool should not drive DEVSEL#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO25: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_trdy_in_n !== pci_trdy_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO25"}),
                          .msg            ("Violates:  Formal Tool should not drive TRDY#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO26: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_stop_in_n !== pci_stop_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO26"}),
                          .msg            ("Violates:  Formal Tool should not drive STOP#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO27: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_ack64_in_n !== pci_ack64_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO27"}),
                          .msg            ("Violates:  Formal Tool should not drive ACK64#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO28: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_frame_in_n !== pci_frame_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO28"}),
                          .msg            ("Violates:  Formal Tool should not drive FRAME#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO29: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_irdy_in_n !== pci_irdy_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO29"}),
                          .msg            ("Violates:  Formal Tool should not drive IRDY#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_IO30: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_req64_in_n !== pci_req64_out_n))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_IO30"}),
                          .msg            ("Violates:  Formal Tool should not drive REQ64#."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));*/
        A_TP01_devsel: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_devsel_out_n === 1'b1 && 
                           r_pci_devsel_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_devsel_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP01_devsel"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_TP01_trdy: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_trdy_out_n === 1'b1 && 
                           r_pci_trdy_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_trdy_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP01_trdy"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_TP01_stop: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_stop_out_n === 1'b1 &&
                           r_pci_stop_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_stop_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP01_stop"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_TP01_ack64: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_ack64_out_n === 1'b1 &&
                           r_pci_ack64_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_ack64_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_TP01_ack64"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MP01_frame: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_frame_out_n === 1'b1 &&
                           r_pci_frame_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_frame_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP01_frame"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MP01_irdy: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_irdy_out_n === 1'b1 &&
                           r_pci_irdy_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_irdy_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP01_irdy"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MP01_perr: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_perr_out_n === 1'b1 &&
                           r_pci_perr_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0 &&
                           ParityErrorResponse === 1))) &&
                           ((pci_perr_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP01_perr"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_MP01_req64: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_req64_out_n === 1'b1 && 
                           r_pci_req64_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_req64_en_n !== 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_MP01_req64"}),
                          .msg            ("Violates: All Sustained Tri-State signals are driven high for one clock before being tri-stated. (2.1)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_IO23: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           (((pci_rst_in_n === 1'b1 && 
                           dut_as_mas_tmp === 1'b1) &&
                           (prev_frame_out_n === 1'b1 &&
                           pci_frame_out_n === 1'b0 &&
                           (prev_gnt_n !== 1'b0 || prev_frame_in_n !== 1'b1 
                           ||(prev_irdy_in_n !== 1'b1 &&
                           prev_irdy_out_n === 1'b1)))))))));
        M_MP22: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           (((pci_rst_in_n === 1'b1 && 
                           dut_as_mas_tmp === 1'b1) &&
                           (count_flag === 1'b1 && add_cbe_lat === 5'h7 &&
                           (pci_ad_en_n !== 1'b0 || 
                           pci_cbe_en_n !== 1'b0))))))));
        M_IO10: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 1 && ZI_SELF_CONFIG === 0)) &&
                           ((dut_as_tar_tmp === 1 && dut_as_mas_tmp === 1))))));
        M_IO11: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 1)) &&
                           (((pci_rst_in_n === 0) &&
                           (dut_as_tar_tmp || dut_as_mas_tmp)))))));
        M_IO12: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((Constraints_Mode && dut_as_mas_tmp && 
                           ZI_FLIP_SIGNALS === 1)  &&
                           ((pci_frame_in_n !== pci_frame_out_n) ||
                           (pci_irdy_in_n !== pci_irdy_out_n) ||
                           (pci_req64_in_n_real !== pci_req64_out_n_real))))));
        M_IO21: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           ((pci_stop_en_n !== pci_trdy_en_n))))));
        M_IO22: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((ZI_FLIP_SIGNALS === 0)) &&
                           ((pci_stop_en_n !== pci_devsel_en_n))))));
 /*       M_IO24: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_devsel_in_n !== pci_devsel_out_n))))));
        M_IO25: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_trdy_in_n !== pci_trdy_out_n))))));
        M_IO26: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_stop_in_n !== pci_stop_out_n))))));
        M_IO27: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_tar_tmp === 1))) &&
                           ((pci_ack64_in_n !== pci_ack64_out_n))))));
        M_IO28: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_frame_in_n !== pci_frame_out_n))))));
        M_IO29: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_irdy_in_n !== pci_irdy_out_n))))));
        M_IO30: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr (((((pw_ZI_FLIP_SIGNALS === 1) &&
                           (dut_as_mas_tmp === 1))) &&
                           ((pci_req64_in_n !== pci_req64_out_n))))));*/
        M_TP01_devsel: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_devsel_out_n === 1'b1 && 
                           r_pci_devsel_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_devsel_en_n !== 1'b0)))));
        M_TP01_trdy: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_trdy_out_n === 1'b1 && 
                           r_pci_trdy_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_trdy_en_n !== 1'b0)))));
        M_TP01_stop: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_stop_out_n === 1'b1 &&
                           r_pci_stop_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_stop_en_n !== 1'b0)))));
        M_TP01_ack64: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_ack64_out_n === 1'b1 &&
                           r_pci_ack64_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_ack64_en_n !== 1'b0)))));
        M_MP01_frame: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_frame_out_n === 1'b1 &&
                           r_pci_frame_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_frame_en_n !== 1'b0)))));
        M_MP01_irdy: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_irdy_out_n === 1'b1 &&
                           r_pci_irdy_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_irdy_en_n !== 1'b0)))));
        M_MP01_perr: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_perr_out_n === 1'b1 &&
                           r_pci_perr_out_n === 1'b0 &&
                           ZI_FLIP_SIGNALS === 0 &&
                           ParityErrorResponse === 1))) &&
                           ((pci_perr_en_n !== 1'b0)))));
        M_MP01_req64: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pci_clk_in ),
                          .reset_n   (!(!pci_rst_in_n) ),
                          .enable    (1'b1),
                          .test_expr ((((pci_req64_out_n === 1'b1 && 
                           r_pci_req64_out_n === 1'b0 && 
                           ZI_FLIP_SIGNALS === 0))) &&
                           ((pci_req64_en_n !== 1'b0)))));
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
