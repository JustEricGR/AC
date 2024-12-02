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
  parameter QVL_COVERAGE_LEVEL = 0; //{32{1'b1}}; //`OVL_COVER_NONE;

  wire not_tx_link_clk = !tx_link_clk;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// Commenting as this assertion is invalid. TLP can come in INITFC2 
/*
generate
  case (PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           !tx_10b_code_violation &&
                           phy_status && fc_init1_done && !fc_init2_done)) &&
                           ((tx_current_tlp_pkt_valid || tx_ended_tlp_pkt_valid ||
                           tx_detected_tlp_pkt_valid ||
                           tx_ended_null_tlp_pkt_valid   ||
                           tx_detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_P"}),
                          .msg            ("TL packet should not be transmitted in FC_INIT2 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           !tx_10b_code_violation &&
                           phy_status && fc_init1_done && !fc_init2_done)) &&
                           ((tx_current_tlp_pkt_valid || tx_ended_tlp_pkt_valid   ||
                           tx_detected_tlp_pkt_valid ||
                           tx_ended_null_tlp_pkt_valid   ||
                           tx_detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_N"}),
                          .msg            ("TL packet should not be transmitted in FC_INIT2 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1 && 
                           !tx_10b_code_violation &&
                           phy_status && fc_init1_done && !fc_init2_done)) &&
                           ((tx_current_tlp_pkt_valid || tx_ended_tlp_pkt_valid ||
                           tx_detected_tlp_pkt_valid ||
                           tx_ended_null_tlp_pkt_valid   ||
                           tx_detected_null_tlp_pkt_valid)))));
        M_PCI_EXPRESS_TX_TLP_IN_FC_INIT2_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           !tx_10b_code_violation &&
                           phy_status && fc_init1_done && !fc_init2_done)) &&
                           ((tx_current_tlp_pkt_valid || tx_ended_tlp_pkt_valid   ||
                           tx_detected_tlp_pkt_valid ||
                           tx_ended_null_tlp_pkt_valid   ||
                           tx_detected_null_tlp_pkt_valid)))));
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
*/
`endif // QVL_ASSERT_ON
