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

  wire not_clk = ~clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER

 // GEN2 assertions
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assert_PCI_EXPRESS_GEN2
	    
        // Assertions with positive clock
	A_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && eie_on_gen1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_P"}),
                          .msg            ("Electrical Idle exit(EIE K28.7) should not be used on 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1)&& eie_inconsistent_in_eie_os)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_P"}),
                          .msg            ("EIE symbol should be part of EIEOS consistently from index 1 to 14."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && 
				      (ts2_detected & (link_ctrl === ZI_COMPLIANCE_REC || 
						       link_ctrl === ZI_COMPLIANCE_REC_LOOPBK))))) 
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_P"}),
                          .msg            ("Compliance Receive bit should not be set in TS2 OS"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && phy_layer_checks_disable !== 1'b1)
                                      && eios_error_on_gen2)))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_P"}),
                          .msg            ("Two sets of a COM(K28.5) followed by three IDL(K28.3) should be transmitted as electrical idle indication when speed is greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && os_present_state === ZI_ORDERED_SET_EIE_STATE 
				      && os_next_state === ZI_ORDERED_SET_TS1_IDNT_STATE && int_pci_8b_data !== ZI_TS1_ID)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_P"}),
                          .msg            ("D10.2 symbol should appear at the end of Electrical Idle Exit Sequence Ordered Set(EIEOS)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && modified_compliance_pattern_error)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_P"}),
                          .msg            ("Modified complaince pattern error on this lane of TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	
        // Assertions with negative clock    
	A_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && eie_on_gen1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_N"}),
                          .msg            ("Electrical Idle exit(EIE K28.7) should not be used on 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
				      && eie_inconsistent_in_eie_os)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_N"}),
                          .msg            ("EIE symbol should be part of EIEOS consistently from index 1 to 14."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                                      && (ts2_detected & (link_ctrl === ZI_COMPLIANCE_REC || 
							  link_ctrl === ZI_COMPLIANCE_REC_LOOPBK)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_N"}),
                          .msg            ("Compliance Receive bit should not be set in TS2 OS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && DOUBLE_DATA_RATE === 1 && 
					 phy_layer_checks_disable !== 1'b1) && eios_error_on_gen2)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_N"}),
                          .msg            ("Two sets of a COM(K28.5) followed by three IDL(K28.3) should be transmitted as electrical idle indication when speed is greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
					 DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
					&& os_present_state === ZI_ORDERED_SET_EIE_STATE && 
					os_next_state === ZI_ORDERED_SET_TS1_IDNT_STATE && int_pci_8b_data !== ZI_TS1_ID)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_N"}),
                          .msg            ("D10.2 symbol should appear at the end of Electrical Idle Exit Sequence Ordered Set(EIEOS)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && 
				      modified_compliance_pattern_error)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_N"}),
                          .msg            ("Modified complaince pattern error on this lane of TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end
  
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_000111_error && PIPE_MONITOR == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 6'b000111 should be generated only when the running disparity at the beginning of the sub block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_111000_error && PIPE_MONITOR == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 6'b111000 should be generated only when the running disparity at the beginning of the sub block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_0011_error && PIPE_MONITOR == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 4'b0011 should be generated only when the running disparity at the beginning of the sub block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_1100_error && PIPE_MONITOR == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_P"}),
                          .msg            ("Sub blocks encoded as 4'b1100 should be generated only when the running disparity at the beginning of the sub block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_10B_CODING_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(pci_10b_code_violation_n == 1'b0 && parallel_symbol_valid === 1'b1	     && electrical_idle_detected === 1'b0 && PIPE_MONITOR == 0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_10B_CODING_VIOLATION_P"}),
                          .msg            ("Invalid 10b code on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RESERVED_K_CODE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(reserved_k_code_on_lane)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_K_CODE_P"}),
                          .msg            ("Reserved K code on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(idle_os_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_P"}),
                          .msg            ("ELECTRICAL IDLE ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(fts_os_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_P"}),
                          .msg            ("FTS ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(skp_os_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_P"}),
                          .msg            ("SKP ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_data_rate_identifier)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_P"}),
                          .msg            ("Illegal data rate identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_lane_number_identifier)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_P"}),
                          .msg            ("Illegal lane number identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_link_ctrl_field)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_P"}),
                          .msg            ("Illegal link control field in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_ts_identifier)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_P"}),
                          .msg            ("Illegal TS identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(ts1_os_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_P"}),
                          .msg            ("TS1 ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(ts2_os_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_P"}),
                          .msg            ("TS2 ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_symbol_following_com_symbol)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_P"}),
                          .msg            ("COM symbol is followed by an illegal special symbol on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(skp_not_part_of_skp_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_P"}),
                          .msg            ("SKP symbol should be a part of SKP ordered set only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(idl_not_part_of_eidle_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_P"}),
                          .msg            ("IDL symbol should be a part of electrical idle ordered set only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(fts_not_part_of_fts_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_P"}),
                          .msg            ("FTS symbol should be a part of fast training sequence only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NO_IDLE_DATA_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(no_idle_data)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_IDLE_DATA_P"}),
                          .msg            ("Idle data should be transmitted when no DLLP, TLP or special symbols are transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(compliance_pattern_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_P"}),
                          .msg            ("Compliance pattern error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SM_UNKNOWN_STATE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(os_next_state == ZI_ORDERED_SET_UNKNOWN_STATE && 	     parallel_symbol_valid === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SM_UNKNOWN_STATE_P"}),
                          .msg            ("Ordered set state machine entered unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(lane_num_detected === 1'b1 && lane_number !== PHY_LANE_NUMBER              &&(lane_number !==(number_of_lanes_with_lanenum_temp -(PHY_LANE_NUMBER + 1))))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_P"}),
                          .msg            ("Illegal lane number is assigned to this physical lane."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(symbol_data_plus_minus_fire === 1'b1 && INTERFACE_TYPE == 0	     && PIPE_MONITOR == 0 && ENABLE_DATA_PLUS_MINUS_CHECK == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_P"}),
                          .msg            ("Invalid logic levels on 'D+' and 'D-' pins of this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && 
                                       phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_000111_error && PIPE_MONITOR == 0)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 6'b000111 should be generated only when the running disparity at the beginning of the sub block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_111000_error && PIPE_MONITOR == 0)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 6'b111000 should be generated only when the running disparity at the beginning of the sub block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_0011_error && PIPE_MONITOR == 0)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 4'b0011 should be generated only when the running disparity at the beginning of the sub block is positive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_1100_error && PIPE_MONITOR == 0)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_N"}),
                          .msg            ("Sub blocks encoded as 4'b1100 should be are generated only when the running disparity at the beginning of the sub block is negative."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_10B_CODING_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(pci_10b_code_violation_n === 1'b0 && parallel_symbol_valid === 1'b1	&& electrical_idle_detected === 1'b0 && PIPE_MONITOR == 0)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_10B_CODING_VIOLATION_N"}),
                          .msg            ("Invalid 10b code on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RESERVED_K_CODE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(reserved_k_code_on_lane)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_K_CODE_N"}),
                          .msg            ("Reserved K code on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(idle_os_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_N"}),
                          .msg            ("ELECTRICAL IDLE ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(fts_os_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_N"}),
                          .msg            ("FTS ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(skp_os_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_N"}),
                          .msg            ("SKP ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_data_rate_identifier)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_N"}),
                          .msg            ("Illegal data rate identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_lane_number_identifier)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_N"}),
                          .msg            ("Illegal lane number identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_link_ctrl_field)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_N"}),
                          .msg            ("Illegal link control field in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_ts_identifier)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_N"}),
                          .msg            ("Illegal TS identifier in the TS1/TS2 ordered set on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1
&&(ts1_os_error))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_N"}),
                          .msg            ("TS1 ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(ts2_os_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_N"}),
                          .msg            ("TS2 ordered set error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_symbol_following_com_symbol)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_N"}),
                          .msg            ("COM symbol is followed by an illegal special symbol on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)&&(skp_not_part_of_skp_os)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_N"}),
                          .msg            ("SKP symbol should be a part of SKP ordered set only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(idl_not_part_of_eidle_os)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_N"}),
                          .msg            ("IDL symbol should be a part of electrical idle ordered set only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)&&(fts_not_part_of_fts_os)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_N"}),
                          .msg            ("FTS symbol should be a part of fast training sequence only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NO_IDLE_DATA_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(no_idle_data)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_IDLE_DATA_N"}),
                          .msg            ("Idle data should be transmitted when no DLLP, TLP or special symbols are transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(compliance_pattern_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_N"}),
                          .msg            ("Compliance pattern error on this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SM_UNKNOWN_STATE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(os_next_state == ZI_ORDERED_SET_UNKNOWN_STATE && parallel_symbol_valid === 1'b1)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SM_UNKNOWN_STATE_N"}),
                          .msg            ("Ordered set state machine entered unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(lane_num_detected === 1'b1 && lane_number !== PHY_LANE_NUMBER &&(lane_number !==(number_of_lanes_with_lanenum_temp -(PHY_LANE_NUMBER + 1))))))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_N"}),
                          .msg            ("Illegal lane number is assigned to this physical lane."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(symbol_data_plus_minus_fire === 1'b1 && INTERFACE_TYPE == 0 && PIPE_MONITOR == 0 && ENABLE_DATA_PLUS_MINUS_CHECK == 1)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_N"}),
                          .msg            ("Invalid logic levels on 'D+' and 'D-' pins of this lane of the TX interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER

// GEN2 assume
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assume_PCI_EXPRESS_GEN2
	
        // Assertions with positive clock
	M_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && eie_on_gen1)));
	M_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && eie_inconsistent_in_eie_os)));
	M_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && 
				      (ts2_detected & (link_ctrl === ZI_COMPLIANCE_REC 
						       || link_ctrl === ZI_COMPLIANCE_REC_LOOPBK)))));
	M_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && phy_layer_checks_disable !== 1'b1)
                                      && eios_error_on_gen2)));
	M_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && os_present_state === ZI_ORDERED_SET_EIE_STATE 
				      && os_next_state === ZI_ORDERED_SET_TS1_IDNT_STATE && int_pci_8b_data !== ZI_TS1_ID)));
        M_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       phy_layer_checks_disable !== 1'b1) && modified_compliance_pattern_error)));  

	// Assertions with negative clock
	M_PCI_EXPRESS_GEN2_EIE_SYMBOL_IN_2_5_GT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 
				       && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && eie_on_gen1)));
	M_PCI_EXPRESS_GEN2_EIE_INCONSISTENT_IN_EIEOS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 
				       && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && 
				      eie_inconsistent_in_eie_os)));
	M_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_TS2_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                                      && (ts2_detected & (link_ctrl === ZI_COMPLIANCE_REC || 
							  link_ctrl === ZI_COMPLIANCE_REC_LOOPBK)))));
	M_PCI_EXPRESS_GEN2_ILLEGAL_EIOS_COUNT_ON_NON_2_5_GT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && DOUBLE_DATA_RATE === 1 && 
				       phy_layer_checks_disable !== 1'b1) && eios_error_on_gen2)));
        M_PCI_EXPRESS_GEN2_EIEOS_WITHOUT_D10_2_SYMBOL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                                      && os_present_state === ZI_ORDERED_SET_EIE_STATE && 
				      os_next_state === ZI_ORDERED_SET_TS1_IDNT_STATE && int_pci_8b_data !== ZI_TS1_ID)));
        M_PCI_EXPRESS_GEN2_MODIFIED_COMPLIANCE_PATTERN_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && 
				       DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && 
				      modified_compliance_pattern_error)));   		     
      end

        M_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_000111_error && PIPE_MONITOR == 0)))));
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_111000_error && PIPE_MONITOR == 0)))));
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_0011_error && PIPE_MONITOR == 0)))));
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_1100_error && PIPE_MONITOR == 0)))));
        M_PCI_EXPRESS_10B_CODING_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(pci_10b_code_violation_n == 1'b0 && parallel_symbol_valid === 1'b1	     && electrical_idle_detected === 1'b0 && PIPE_MONITOR == 0)))));
        M_PCI_EXPRESS_RESERVED_K_CODE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(reserved_k_code_on_lane)))));
        M_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(idle_os_error)))));
        M_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(fts_os_error)))));
        M_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(skp_os_error)))));
        M_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_data_rate_identifier)))));
        M_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_lane_number_identifier)))));
        M_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_link_ctrl_field)))));
        M_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_ts_identifier)))));
        M_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(ts1_os_error)))));
        M_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(ts2_os_error)))));
        M_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(illegal_symbol_following_com_symbol)))));
        M_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(skp_not_part_of_skp_os)))));
        M_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(idl_not_part_of_eidle_os)))));
        M_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(fts_not_part_of_fts_os)))));
        M_PCI_EXPRESS_NO_IDLE_DATA_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(no_idle_data)))));
        M_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(compliance_pattern_error)))));
        M_PCI_EXPRESS_SM_UNKNOWN_STATE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(os_next_state == ZI_ORDERED_SET_UNKNOWN_STATE && 	     parallel_symbol_valid === 1'b1)))));
        M_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(lane_num_detected === 1'b1 && lane_number !== PHY_LANE_NUMBER              &&(lane_number !==(number_of_lanes_with_lanenum_temp -(PHY_LANE_NUMBER + 1))))))));
        M_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && phy_layer_checks_disable !== 1'b1))&&(symbol_data_plus_minus_fire === 1'b1 && INTERFACE_TYPE == 0	     && PIPE_MONITOR == 0 && ENABLE_DATA_PLUS_MINUS_CHECK == 1)))));
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_000111_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr ((((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && 
                                       phy_layer_checks_disable !== 1'b1))&&(disparity_neutral_000111_error && PIPE_MONITOR == 0)))));		     
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_111000_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_111000_error && PIPE_MONITOR == 0)))));		     
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_0011_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_0011_error && PIPE_MONITOR == 0)))));		     
        M_PCI_EXPRESS_DISPARITY_NEUTRAL_1100_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(disparity_neutral_1100_error && PIPE_MONITOR == 0)))));		     
        M_PCI_EXPRESS_10B_CODING_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
	                  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(pci_10b_code_violation_n === 1'b0 && parallel_symbol_valid === 1'b1	&& electrical_idle_detected === 1'b0 && PIPE_MONITOR == 0)))));				     
        M_PCI_EXPRESS_RESERVED_K_CODE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(reserved_k_code_on_lane)))));		     
        M_PCI_EXPRESS_IDLE_ORDERED_SET_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(idle_os_error)))));		     
        M_PCI_EXPRESS_FTS_ORDERED_SET_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(fts_os_error)))));		     
        M_PCI_EXPRESS_SKP_ORDERED_SET_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(skp_os_error)))));		     
        M_PCI_EXPRESS_ILLEGAL_DATA_RATE_IDENTIFIER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_data_rate_identifier)))));		     
        M_PCI_EXPRESS_ILLEGAL_LANE_NUM_IDENTIFIER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_lane_number_identifier)))));		     
        M_PCI_EXPRESS_ILLEGAL_LINK_CONTROL_FIELD_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_link_ctrl_field)))));		     
        M_PCI_EXPRESS_ILLEGAL_TS_IDENTIFIER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_ts_identifier)))));		     
        M_PCI_EXPRESS_TS1_ORDERED_SET_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1
&&(ts1_os_error))))));		     
        M_PCI_EXPRESS_TS2_ORDERED_SET_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(ts2_os_error)))));		     
        M_PCI_EXPRESS_ILLEGAL_SYMBOL_FOLLOWING_COM_SYMBOL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(illegal_symbol_following_com_symbol)))));		     
        M_PCI_EXPRESS_SKP_NOT_PART_OF_SKP_OS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)&&(skp_not_part_of_skp_os)))));		     
        M_PCI_EXPRESS_IDL_NOT_PART_OF_EIDL_OS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(idl_not_part_of_eidle_os)))));		     
        M_PCI_EXPRESS_FTS_NOT_PART_OF_FTS_OS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0	 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)&&(fts_not_part_of_fts_os)))));		     
        M_PCI_EXPRESS_NO_IDLE_DATA_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(no_idle_data)))));		     
        M_PCI_EXPRESS_COMPLIANCE_PATTERN_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(compliance_pattern_error)))));		     
        M_PCI_EXPRESS_SM_UNKNOWN_STATE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(os_next_state == ZI_ORDERED_SET_UNKNOWN_STATE && parallel_symbol_valid === 1'b1)))));		     
        M_PCI_EXPRESS_ILLEGAL_ASSIGNED_LANE_NUMBER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(lane_num_detected === 1'b1 && lane_number !== PHY_LANE_NUMBER &&(lane_number !==(number_of_lanes_with_lanenum_temp -(PHY_LANE_NUMBER + 1))))))));		     
        M_PCI_EXPRESS_DATA_PLUS_MINUS_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
&&(symbol_data_plus_minus_fire === 1'b1 && INTERFACE_TYPE == 0 && PIPE_MONITOR == 0 && ENABLE_DATA_PLUS_MINUS_CHECK == 1)))));		     
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
