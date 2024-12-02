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

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// PHY_LAYER_CONSTRAINT
generate
  case (PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PHY_LAYER_CONSTRAINT
	// Additional gen1 code start
	A_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init1_done === 1'b0 && tlp_detected_tx_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_P"}),
                          .msg            ("Flow control initialization must take place for VC0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (tx_dllp_updatefc_p_detected || tx_dllp_updatefc_np_detected ||
								   tx_dllp_updatefc_cpl_detected))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_P"}),
                          .msg            ("UFC must not be sent before InitFC"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_PH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_PH_INVL_P"}),
                          .msg            ("Posted UFC should have zero header credit for initialized infinite posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_PD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_PD_INVL_P"}),
                          .msg            ("Posted UFC should have zero data credit for initialized infinite posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NPH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NPH_INVL_P"}),
                          .msg            ("Non posted UFC should have zero header credit for initialized infinite non posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NPD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NPD_INVL_P"}),
                          .msg            ("Non posted UFC should have zero data credit for initialized infinite non posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPLH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPLH_INVL_P"}),
                          .msg            ("Completion UFC should have zero header credit for initialized infinite posted completion credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPLD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPLD_INVL_P"}),
                          .msg            ("Completion UFC should have zero data credit for initialized infinite completion data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_PH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_ph_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_PH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_PD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_pd_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_PD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_NPH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_nph_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_NPH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for non posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_NPD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_npd_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_NPD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for non posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_CPLH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_CPLH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for completion header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_CPLD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_CPLD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for completion data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_p_detected && ph_initial_credit_infinite_tx === 1'b1 && pd_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_np_detected && nph_initial_credit_infinite_tx === 1'b1 && npd_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised non posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_tx === 1'b1 && cpld_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised completion header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_ph_credits_allocated !== ph_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_nph_credits_allocated !== nph_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Non posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_allocated !== cplh_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Completion header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_pd_credits_allocated !== pd_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_npd_credits_allocated !== npd_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Non posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_allocated !== cpld_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Completion data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_P_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_P_MISSING_P"}),
                          .msg            ("Posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NP_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))			  		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NP_MISSING_P"}),
                          .msg            ("Non posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPL_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPL_MISSING_P"}),
                          .msg            ("Completion UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	
	
	// Additional gen1 code end
        A_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1) && (tx_ph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Posted header when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1) && (tx_nph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Non-Posted header when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cplh_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Completion packet when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_pd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Posted data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_npd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Non-Posted data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cpld_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Transmitter should not generate Completion data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	
        // Additional gen1 code start
	A_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |xmtd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_N"}),
                          .msg            ("Flow control initialization must take place for VC0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (tx_dllp_updatefc_p_detected || tx_dllp_updatefc_np_detected ||
								   tx_dllp_updatefc_cpl_detected))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_N"}),
                          .msg            ("UFC must not be sent before InitFC"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_PH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_PH_INVL_N"}),
                          .msg            ("Posted UFC should have zero header credit for initialized infinite posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_PD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_PD_INVL_N"}),
                          .msg            ("Posted UFC should have zero data credit for initialized infinite posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NPH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NPH_INVL_N"}),
                          .msg            ("Non posted UFC should have zero header credit for initialized infinite non posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NPD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NPD_INVL_N"}),
                          .msg            ("Non posted UFC should have zero data credit for initialized infinite non posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPLH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPLH_INVL_N"}),
                          .msg            ("Completion UFC should have zero header credit for initialized infinite posted completion credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPLD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPLD_INVL_N"}),
                          .msg            ("Completion UFC should have zero data credit for initialized infinite completion data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_PH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_ph_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_PH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_PD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_pd_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_PD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_NPH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_nph_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_NPH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for non posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_NPD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_npd_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_NPD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for non posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_CPLH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_allocated > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_CPLH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for completion header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_INFC_CPLD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_allocated > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_INFC_CPLD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for completion data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_p_detected && ph_initial_credit_infinite_tx === 1'b1 && pd_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_np_detected && nph_initial_credit_infinite_tx === 1'b1 && npd_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised non posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_tx === 1'b1 && cpld_initial_credit_infinite_tx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised completion header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_ph_credits_allocated !== ph_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_nph_credits_allocated !== nph_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Non posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_allocated !== cplh_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Completion header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_pd_credits_allocated !== pd_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_npd_credits_allocated !== npd_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Non posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_allocated !== cpld_credits_allocated)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Completion data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_P_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_P_MISSING_N"}),
                          .msg            ("Posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_NP_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_NP_MISSING_N"}),
                          .msg            ("Non posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_UFC_CPL_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_UFC_CPL_MISSING_N"}),
                          .msg            ("Completion UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	
	// Additional gen1 code end
	
        A_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_ph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Posted header when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_nph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Non-Posted header when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cplh_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Completion packet when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_pd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Posted data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_npd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Non-Posted data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cpld_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Transmitter should not generate Completion data when sufficient credit limit not available"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_FC_DLLP_AFTER_INIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           phy_status && fc_init2_done &&
                           r_vc_tlp_xmtd))) &&
                           (((tx_detected_dllp_pkt_valid_real &&
                           (tx_detected_dllp_pkt[15:14] == 2'b01 ||
                           tx_detected_dllp_pkt[15:14] == 2'b11)) ||
                           (tx_ended_dllp_pkt_valid_real &&
                           (tx_ended_dllp_pkt[15:14] == 2'b01 ||
                           tx_ended_dllp_pkt[15:14] == 2'b11)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FC_DLLP_AFTER_INIT_P"}),
                          .msg            ("InitFC1/InitFC2 DLLPs should not be detected once the VC initialization is done"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_FC_DLLP_AFTER_INIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           phy_status && fc_init2_done &&
                           r_vc_tlp_xmtd))) &&
                           (((tx_detected_dllp_pkt_valid_real &&
                           (tx_detected_dllp_pkt[15:14] == 2'b01 ||
                           tx_detected_dllp_pkt[15:14] == 2'b11)) ||
                           (tx_ended_dllp_pkt_valid_real &&
                           (tx_ended_dllp_pkt[15:14] == 2'b01 ||
                           tx_ended_dllp_pkt[15:14] == 2'b11)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FC_DLLP_AFTER_INIT_N"}),
                          .msg            ("InitFC1/InitFC2 DLLPs should not be detected once the VC initialization is done"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc1_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_P"}),
                          .msg            ("Uninterrupted sequence of InitFC1-P, InitFC1-NP and InitFC1-CPL DLLPsnot transmitted in the FC-Init1 state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc1_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_N"}),
                          .msg            ("Uninterrupted sequence of InitFC1-P, InitFC1-NP and InitFC1-CPL DLLPsnot transmitted in the FC-Init1 state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc2_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_P"}),
                          .msg            ("Uninterrupted sequence of InitFC2-P, InitFC2-NP and InitFC2-CPL DLLPsnot transmitted in the FC-Init2 state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc2_error))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_N"}),
                          .msg            ("Uninterrupted sequence of InitFC2-P, InitFC2-NP and InitFC2-CPL DLLPsnot transmitted in the FC-Init2 state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_hdrfc1_p_error || fire_tx_hdrfc1_np_error ||
                           fire_tx_hdrfc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_P"}),
                          .msg            ("Transmitted InitFC1 (P,NP,Cpl) DLL Packets for this virtual channel should have consistent HdrFC fields."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_hdrfc1_p_error || fire_tx_hdrfc1_np_error ||
                           fire_tx_hdrfc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_N"}),
                          .msg            ("Transmitted InitFC1 (P,NP,Cpl) DLL Packets for this virtual channel should have consistent HdrFC fields."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_datafc1_p_error || fire_tx_datafc1_np_error ||
                           fire_tx_datafc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_P"}),
                          .msg            ("Transmitted InitFC1 (P,NP,Cpl) DLL packets for this virtual channel should have consistent DataFC fields."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_datafc1_p_error || fire_tx_datafc1_np_error ||
                           fire_tx_datafc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_N"}),
                          .msg            ("Transmitted InitFC1 (P,NP,Cpl) DLL packets for this virtual channel should have consistent DataFC fields."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_PHY_LAYER_CONSTRAINT
	// Additional gen1 code start
	M_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |xmtd_tlp)))));
	M_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (tx_dllp_updatefc_p_detected || tx_dllp_updatefc_np_detected ||
								   tx_dllp_updatefc_cpl_detected))))));
	M_PCI_EXPRESS_TX_UFC_PH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_p_error)))));
	M_PCI_EXPRESS_TX_UFC_PD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_p_error)))));
	M_PCI_EXPRESS_TX_UFC_NPH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_np_error)))));
	M_PCI_EXPRESS_TX_UFC_NPD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_np_error)))));
	M_PCI_EXPRESS_TX_UFC_CPLH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_cpl_error)))));
	M_PCI_EXPRESS_TX_UFC_CPLD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_cpl_error)))));
	M_PCI_EXPRESS_TX_INFC_PH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_ph_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_PD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_pd_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_INFC_NPH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_nph_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_NPD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_npd_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_INFC_CPLH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_CPLD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_p_detected && ph_initial_credit_infinite_tx === 1'b1 && pd_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_np_detected && nph_initial_credit_infinite_tx === 1'b1 && npd_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_tx === 1'b1 && cpld_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_ph_credits_allocated !== ph_credits_allocated)))));
	M_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_nph_credits_allocated !== nph_credits_allocated)))));
	M_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_allocated !== cplh_credits_allocated)))));
	M_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_pd_credits_allocated !== pd_credits_allocated)))));
	M_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_npd_credits_allocated !== npd_credits_allocated)))));
	M_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_allocated !== cpld_credits_allocated)))));
	M_PCI_EXPRESS_TX_UFC_P_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_TX_UFC_NP_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_TX_UFC_CPL_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));			     
	// Additional gen1 code end
	
        M_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1) && (tx_ph_buffer_overflow)))));
        M_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1) && (tx_nph_buffer_overflow)))));
        M_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cplh_buffer_overflow)))));
        M_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_pd_buffer_overflow)))));
        M_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_npd_buffer_overflow)))));
        M_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cpld_buffer_overflow)))));
	// Additional gen1 code start
	M_PCI_EXPRESS_TX_NO_VC0_INITIALIZTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |xmtd_tlp)))));
	M_PCI_EXPRESS_TX_UFC_BEFORE_INITFC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (tx_dllp_updatefc_p_detected || tx_dllp_updatefc_np_detected ||
								   tx_dllp_updatefc_cpl_detected))))));
	M_PCI_EXPRESS_TX_UFC_PH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_p_error)))));
	M_PCI_EXPRESS_TX_UFC_PD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_p_error)))));
	M_PCI_EXPRESS_TX_UFC_NPH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_np_error)))));
	M_PCI_EXPRESS_TX_UFC_NPD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_np_error)))));
	M_PCI_EXPRESS_TX_UFC_CPLH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_hdrfc1_cpl_error)))));
	M_PCI_EXPRESS_TX_UFC_CPLD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_tx_ufc_datafc1_cpl_error)))));
	M_PCI_EXPRESS_TX_INFC_PH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_ph_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_PD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_p_ended))
					&& next_pd_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_INFC_NPH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_nph_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_NPD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_np_ended))
					&& next_npd_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_INFC_CPLH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_allocated > 8'h7f)))));
	M_PCI_EXPRESS_TX_INFC_CPLD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_allocated > 12'h7ff)))));
	M_PCI_EXPRESS_TX_UFC_P_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_p_detected && ph_initial_credit_infinite_tx === 1'b1 && pd_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_UFC_NP_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_np_detected && nph_initial_credit_infinite_tx === 1'b1 && npd_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_UFC_CPL_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (tx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_tx === 1'b1 && cpld_initial_credit_infinite_tx === 1'b1)))));
	M_PCI_EXPRESS_TX_PH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_ph_credits_allocated !== ph_credits_allocated)))));
	M_PCI_EXPRESS_TX_NPH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_nph_credits_allocated !== nph_credits_allocated)))));
	M_PCI_EXPRESS_TX_CPLH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_allocated !== cplh_credits_allocated)))));
	M_PCI_EXPRESS_TX_PD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_p_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_p_ended))
					&& next_pd_credits_allocated !== pd_credits_allocated)))));
	M_PCI_EXPRESS_TX_NPD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_np_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_np_ended))
					&& next_npd_credits_allocated !== npd_credits_allocated)))));
	M_PCI_EXPRESS_TX_CPLD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((tx_detected_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_detected) ||
					 (tx_ended_dllp_pkt_valid_real && tx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_allocated !== cpld_credits_allocated)))));
	M_PCI_EXPRESS_TX_UFC_P_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_TX_UFC_NP_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_TX_UFC_CPL_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_tx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_tx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));			     
	
	// Additional gen1 code end
        M_PCI_EXPRESS_TX_PH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_ph_buffer_overflow)))));
        M_PCI_EXPRESS_TX_NPH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_nph_buffer_overflow)))));
        M_PCI_EXPRESS_TX_CPLH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cplh_buffer_overflow)))));
        M_PCI_EXPRESS_TX_PD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_pd_buffer_overflow)))));
        M_PCI_EXPRESS_TX_NPD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_npd_buffer_overflow)))));
        M_PCI_EXPRESS_TX_CPLD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(tx_cpld_buffer_overflow)))));
        M_PCI_EXPRESS_FC_DLLP_AFTER_INIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           phy_status && fc_init2_done &&
                           r_vc_tlp_xmtd))) &&
                           (((tx_detected_dllp_pkt_valid_real &&
                           (tx_detected_dllp_pkt[15:14] == 2'b01 ||
                           tx_detected_dllp_pkt[15:14] == 2'b11)) ||
                           (tx_ended_dllp_pkt_valid_real &&
                           (tx_ended_dllp_pkt[15:14] == 2'b01 ||
                           tx_ended_dllp_pkt[15:14] == 2'b11)))))));
        M_PCI_EXPRESS_FC_DLLP_AFTER_INIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           phy_status && fc_init2_done &&
                           r_vc_tlp_xmtd))) &&
                           (((tx_detected_dllp_pkt_valid_real &&
                           (tx_detected_dllp_pkt[15:14] == 2'b01 ||
                           tx_detected_dllp_pkt[15:14] == 2'b11)) ||
                           (tx_ended_dllp_pkt_valid_real &&
                           (tx_ended_dllp_pkt[15:14] == 2'b01 ||
                           tx_ended_dllp_pkt[15:14] == 2'b11)))))));
        M_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc1_error))));
        M_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT1_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc1_error))));
        M_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc2_error))));
        M_PCI_EXPRESS_TX_FC_DLLP_IN_FC_INIT2_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&( fire_tx_initfc2_error))));
        M_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_hdrfc1_p_error || fire_tx_hdrfc1_np_error ||
                           fire_tx_hdrfc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))));
        M_PCI_EXPRESS_TX_SAME_HDRFC_DLLP_FC_INIT1_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_hdrfc1_p_error || fire_tx_hdrfc1_np_error ||
                           fire_tx_hdrfc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))));
        M_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_datafc1_p_error || fire_tx_datafc1_np_error ||
                           fire_tx_datafc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))));
        M_PCI_EXPRESS_TX_SAME_DATAFC_DLLP_FC_INIT1_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 && 
                           phy_status && enable_vc_id)))
                           &&(((fire_tx_datafc1_p_error || fire_tx_datafc1_np_error ||
                           fire_tx_datafc1_cpl_error) &&
                           tx_repeated_fc_sequence_temp)))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_PHY_LAYER_CONSTRAINT 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate
  
// MAC_LAYER_CONSTRAINT
generate
  case (MAC_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_MAC_LAYER_CONSTRAINT
	// Additional gen1 code start
	A_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_P"}),
                          .msg            ("Flow control initialization must take place for VC0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (rx_dllp_updatefc_p_detected || rx_dllp_updatefc_np_detected ||
								   rx_dllp_updatefc_cpl_detected))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_P"}),
                          .msg            ("UFC must not be sent before InitFC"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_PH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_PH_INVL_P"}),
                          .msg            ("Posted UFC should have zero header credit for initialized infinite posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_PD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_PD_INVL_P"}),
                          .msg            ("Posted UFC should have zero data credit for initialized infinite posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NPH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NPH_INVL_P"}),
                          .msg            ("Non posted UFC should have zero header credit for initialized infinite non posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NPD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NPD_INVL_P"}),
                          .msg            ("Non posted UFC should have zero data credit for initialized infinite non posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPLH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPLH_INVL_P"}),
                          .msg            ("Completion UFC should have zero header credit for initialized infinite posted completion credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPLD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPLD_INVL_P"}),
                          .msg            ("Completion UFC should have zero data credit for initialized infinite completion data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_PH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_ph_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_PH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_PD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_pd_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_PD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_NPH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_nph_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_NPH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for non posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_NPD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_npd_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_NPD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for non posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_CPLH_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_CPLH_INVL_P"}),
                          .msg            ("More than 127 credits advertisement for completion header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_CPLD_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_CPLD_INVL_P"}),
                          .msg            ("More than 2047 credits advertisement for completion data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_p_detected && ph_initial_credit_infinite_rx === 1'b1 && pd_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_np_detected && nph_initial_credit_infinite_rx === 1'b1 && npd_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised non posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_rx === 1'b1 && cpld_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_P"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised completion header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_ph_credits_limit !== ph_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_nph_credits_limit !== nph_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Non posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_limit !== cplh_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Completion header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_pd_credits_limit !== pd_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_npd_credits_limit !== npd_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Non posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_limit !== cpld_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_P"}),
                          .msg            ("Completion data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_P_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))  
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_P_MISSING_P"}),
                          .msg            ("Posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NP_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK))))))) 		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NP_MISSING_P"}),
                          .msg            ("Non posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPL_MISSING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPL_MISSING_P"}),
                          .msg            ("Completion UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	
	
	// Additional gen1 code end
        A_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_ph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Posted header when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_nph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Non-Posted header when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cplh_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Completion when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_pd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Posted data when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_npd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Non-Posted data when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cpld_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_P"}),
                          .msg            ("Receiver should not detect Completion data when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
	// Additional gen1 code start
	A_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_N"}),
                          .msg            ("Flow control initialization must take place for VC0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (rx_dllp_updatefc_p_detected || rx_dllp_updatefc_np_detected ||
								   rx_dllp_updatefc_cpl_detected))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_N"}),
                          .msg            ("UFC must not be sent before InitFC"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_PH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_PH_INVL_N"}),
                          .msg            ("Posted UFC should have zero header credit for initialized infinite posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_PD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_p_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_PD_INVL_N"}),
                          .msg            ("Posted UFC should have zero data credit for initialized infinite posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NPH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NPH_INVL_N"}),
                          .msg            ("Non posted UFC should have zero header credit for initialized infinite non posted header credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NPD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_np_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NPD_INVL_N"}),
                          .msg            ("Non posted UFC should have zero data credit for initialized infinite non posted data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPLH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPLH_INVL_N"}),
                          .msg            ("Completion UFC should have zero header credit for initialized infinite posted completion credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPLD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_cpl_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPLD_INVL_N"}),
                          .msg            ("Completion UFC should have zero data credit for initialized infinite completion data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_PH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_ph_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_PH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_PD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_pd_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_PD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_NPH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_nph_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_NPH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for non posted header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_NPD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_npd_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_NPD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for non posted data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_CPLH_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_limit > 8'h7f)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_CPLH_INVL_N"}),
                          .msg            ("More than 127 credits advertisement for completion header"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_INFC_CPLD_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_limit > 12'h7ff)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_INFC_CPLD_INVL_N"}),
                          .msg            ("More than 2047 credits advertisement for completion data"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_p_detected && ph_initial_credit_infinite_rx === 1'b1 && pd_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_np_detected && nph_initial_credit_infinite_rx === 1'b1 && npd_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised non posted header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_rx === 1'b1 && cpld_initial_credit_infinite_rx === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_N"}),
                          .msg            ("UFC need not to be transmitted for infinite advertised completion header and data credit"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_ph_credits_limit !== ph_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_nph_credits_limit !== nph_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Non posted header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_limit !== cplh_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Completion header credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_pd_credits_limit !== pd_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_npd_credits_limit !== npd_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Non posted data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_limit !== cpld_credits_limit)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_N"}),
                          .msg            ("Completion data credit should match in InitFC1 and InitFC2"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_P_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK))))))) 		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_P_MISSING_N"}),
                          .msg            ("Posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_NP_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK))))))) 		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_NP_MISSING_N"}),
                          .msg            ("Non posted UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	A_PCI_EXPRESS_RX_UFC_CPL_MISSING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK))))))) 			     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_UFC_CPL_MISSING_N"}),
                          .msg            ("Completion UFC should be transmitted every 30us(or 120us for extended sync bit set)"),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
	
	
	// Additional gen1 code end
        A_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_ph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Posted header when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_nph_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Non-Posted header when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cplh_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Completion packet when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_pd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Posted data when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_npd_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Non-Posted data when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cpld_buffer_overflow)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_N"}),
                          .msg            ("Receiver should not detect Completion when sufficient credits are not allocated"),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_MAC_LAYER_CONSTRAINT
	// Additional gen1 code start
	M_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |rcvd_tlp)))));
	M_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (rx_dllp_updatefc_p_detected || rx_dllp_updatefc_np_detected ||
								   rx_dllp_updatefc_cpl_detected))))));
	M_PCI_EXPRESS_RX_UFC_PH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_p_error)))));
	M_PCI_EXPRESS_RX_UFC_PD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_p_error)))));
	M_PCI_EXPRESS_RX_UFC_NPH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_np_error)))));
	M_PCI_EXPRESS_RX_UFC_NPD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_np_error)))));
	M_PCI_EXPRESS_RX_UFC_CPLH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_cpl_error)))));
	M_PCI_EXPRESS_RX_UFC_CPLD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_cpl_error)))));
	M_PCI_EXPRESS_RX_INFC_PH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_ph_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_PD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_pd_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_INFC_NPH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_nph_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_NPD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_npd_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_INFC_CPLH_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_CPLD_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_p_detected && ph_initial_credit_infinite_rx === 1'b1 && pd_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_np_detected && nph_initial_credit_infinite_rx === 1'b1 && npd_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_rx === 1'b1 && cpld_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_ph_credits_limit !== ph_credits_limit)))));
	M_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_nph_credits_limit !== nph_credits_limit)))));
	M_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_limit !== cplh_credits_limit)))));
	M_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_pd_credits_limit !== pd_credits_limit)))));
	M_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_npd_credits_limit !== npd_credits_limit)))));
	M_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_limit !== cpld_credits_limit)))));
	M_PCI_EXPRESS_RX_UFC_P_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_RX_UFC_NP_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_RX_UFC_CPL_MISSING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	// Additional gen1 code end
        M_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_ph_buffer_overflow)))));
        M_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_nph_buffer_overflow)))));
        M_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cplh_buffer_overflow)))));
        M_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_pd_buffer_overflow)))));
        M_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_npd_buffer_overflow)))));
        M_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cpld_buffer_overflow)))));
	// Additional gen1 code start
	M_PCI_EXPRESS_RX_NO_VC0_INITIALIZTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && (VC_ID === 0 && fc_init2_done === 1'b0 && |rcvd_tlp)))));
	M_PCI_EXPRESS_RX_UFC_BEFORE_INITFC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (VC_ID === 1'b0 && fc_init2_done === 1'b0 && (rx_dllp_updatefc_p_detected || rx_dllp_updatefc_np_detected ||
								   rx_dllp_updatefc_cpl_detected))))));
	M_PCI_EXPRESS_RX_UFC_PH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_p_error)))));
	M_PCI_EXPRESS_RX_UFC_PD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_p_error)))));
	M_PCI_EXPRESS_RX_UFC_NPH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_np_error)))));
	M_PCI_EXPRESS_RX_UFC_NPD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_np_error)))));
	M_PCI_EXPRESS_RX_UFC_CPLH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_hdrfc1_cpl_error)))));
	M_PCI_EXPRESS_RX_UFC_CPLD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (fire_rx_ufc_datafc1_p_error)))));
	M_PCI_EXPRESS_RX_INFC_PH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_ph_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_PD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_p_ended))
					&& next_pd_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_INFC_NPH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_nph_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_NPD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_np_ended))
					&& next_npd_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_INFC_CPLH_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cplh_credits_limit > 8'h7f)))));
	M_PCI_EXPRESS_RX_INFC_CPLD_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc1_cpl_ended))
					&& next_cpld_credits_limit > 12'h7ff)))));
	M_PCI_EXPRESS_RX_UFC_P_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_p_detected && ph_initial_credit_infinite_rx === 1'b1 && pd_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_UFC_NP_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_np_detected && nph_initial_credit_infinite_rx === 1'b1 && npd_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_UFC_CPL_FOR_INFINIT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (rx_dllp_updatefc_cpl_detected && cplh_initial_credit_infinite_rx === 1'b1 && cpld_initial_credit_infinite_rx === 1'b1)))));
	M_PCI_EXPRESS_RX_PH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_ph_credits_limit !== ph_credits_limit)))));
	M_PCI_EXPRESS_RX_NPH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_nph_credits_limit !== nph_credits_limit)))));
	M_PCI_EXPRESS_RX_CPLH_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cplh_credits_limit !== cplh_credits_limit)))));
	M_PCI_EXPRESS_RX_PD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_p_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_p_ended))
					&& next_pd_credits_limit !== pd_credits_limit)))));
	M_PCI_EXPRESS_RX_NPD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_np_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_np_ended))
					&& next_npd_credits_limit !== npd_credits_limit)))));
	M_PCI_EXPRESS_RX_CPLD_FC1_FC2_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((rx_detected_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_detected) ||
					 (rx_ended_dllp_pkt_valid_real && rx_dllp_initfc2_cpl_ended))
					&& next_cpld_credits_limit !== cpld_credits_limit)))));
	M_PCI_EXPRESS_RX_UFC_P_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_p_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_p_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));		     
	M_PCI_EXPRESS_RX_UFC_NP_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_np_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_np_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));			     
	M_PCI_EXPRESS_RX_UFC_CPL_MISSING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
	                  .test_expr (((DOUBLE_DATA_RATE === 1 && link_layer_checks_disable !== 1'b1) && 
				       (((extended_sync_enable === 1'b0 && ufc_cpl_30us_counter_rx >= UPDATE_FC_30US_TIMER_CLK) ||
					 (extended_sync_enable === 1'b1 && ufc_cpl_30us_counter_rx >= 4*UPDATE_FC_30US_TIMER_CLK)))))));	  
	
	// Additional gen1 code end
        M_PCI_EXPRESS_RX_PH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_ph_buffer_overflow)))));
        M_PCI_EXPRESS_RX_NPH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_nph_buffer_overflow)))));
        M_PCI_EXPRESS_RX_CPLH_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cplh_buffer_overflow)))));
        M_PCI_EXPRESS_RX_PD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_pd_buffer_overflow)))));
        M_PCI_EXPRESS_RX_NPD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_npd_buffer_overflow)))));
        M_PCI_EXPRESS_RX_CPLD_CREDIT_LIMIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1 && 
                           enable_vc_id === 1'b1)
                           &&(rx_cpld_buffer_overflow)))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_MAC_LAYER_CONSTRAINT
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_ASSERT_ON
