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
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = {32{1'b1}}; //`OVL_COVER_ALL;

  wire not_link_clk = !link_clk;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           dlcmsm_present_state == ZI_DL_DOWN_STATE &&
                           dlcmsm_next_state == ZI_DL_DOWN_STATE))) &&
                           ((current_dllp_pkt_valid || ended_dllp_pkt_valid || 
                           detected_dllp_pkt_valid ||
                           current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid   ||
                           detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_P"}),
                          .msg            ("DLL or TL packet should not be detected in the DL_Down state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           dlcmsm_present_state == ZI_DL_DOWN_STATE &&
                           dlcmsm_next_state == ZI_DL_DOWN_STATE)))
                           &&((current_dllp_pkt_valid || ended_dllp_pkt_valid || 
                           detected_dllp_pkt_valid ||
                           current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid  ||
                           detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_N"}),
                          .msg            ("DLL or TL packet should not be detected in the DL_Down state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && dlcmsm_present_state == ZI_DL_ACTIVE_STATE &&
                           r_vc_tlp_detected))) &&
                           (((detected_dllp_pkt_valid &&(init_fc1_detected ||
                           init_fc2_detected) && 
                           detected_dllp_pkt[10:8] == 3'b0) ||
                           (ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[10:8] == 3'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_P"}),
                          .msg            ("InitFC1/InitFC2 DLLPs should not be detected in the DL_Active state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && dlcmsm_present_state == ZI_DL_ACTIVE_STATE &&
                           r_vc_tlp_detected))) &&
                           (((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) 
                           && detected_dllp_pkt[10:8] == 3'b0) ||
                           (ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[10:8] == 3'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_N"}),
                          .msg            ("InitFC1/InitFC2 DLLPs should not be detected in the DL_Active state"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_IN_FC_INIT1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !fc_init1_done))) &&((current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid   || detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   || detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_FC_INIT1_P"}),
                          .msg            ("TL packet should not be detected in FC_INIT1 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_IN_FC_INIT1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !fc_init1_done)))
                           &&((current_tlp_pkt_valid || ended_tlp_pkt_valid ||
                           detected_tlp_pkt_valid || ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_FC_INIT1_N"}),
                          .msg            ("TL packet should not be detected in FC_INIT1 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DLL_PKT_16BIT_CRC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&( dllp_pkt_16bit_crc_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLL_PKT_16BIT_CRC_P"}),
                          .msg            ("DLL Packet should have a valid 16 bit CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DLL_PKT_16BIT_CRC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&( dllp_pkt_16bit_crc_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLL_PKT_16BIT_CRC_N"}),
                          .msg            ("DLL Packet should have a valid 16 bit CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status &&(detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_unknown_detected || dllp_unknown_ended)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_P"}),
                          .msg            ("Undefined DLL Packet type detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status &&(detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_unknown_detected || dllp_unknown_ended)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_N"}),
                          .msg            ("Undefined DLL Packet type detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !VENDOR_SPECIFIC_ENCODING_ENABLE &&
                           (detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_vendor_specific_detected || dllp_vendor_specific_ended)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_P"}),
                          .msg            ("Vendor specific DLL packet should not be detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !VENDOR_SPECIFIC_ENCODING_ENABLE &&
                           (detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_vendor_specific_detected || dllp_vendor_specific_ended)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_N"}),
                          .msg            ("Vendor specific DLL packet should not be detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RESERVED_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && RESERVED_FIELD_CHECK_ENABLE)))
                           &&((fire_detected_dllp_reserved_field_error ||
                           fire_ended_dllp_reserved_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_FIELD_ERROR_P"}),
                          .msg            ("Reserved bits of DLL packet should be set to 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RESERVED_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && RESERVED_FIELD_CHECK_ENABLE)))
                           &&((fire_detected_dllp_reserved_field_error ||
                           fire_ended_dllp_reserved_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_FIELD_ERROR_N"}),
                          .msg            ("Reserved field of DLL packet should be set to 0"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DLL_PKT_LENGTH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_dllp_pkt_length_violation || 
                           ended_dllp_pkt_length_violation ||
                           current_dllp_pkt_length_violation)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLL_PKT_LENGTH_P"}),
                          .msg            ("Length of DLL packet should be 6 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DLL_PKT_LENGTH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_dllp_pkt_length_violation || 
                           ended_dllp_pkt_length_violation ||
                           current_dllp_pkt_length_violation)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLL_PKT_LENGTH_N"}),
                          .msg            ("Length of DLL packet should be 6 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_LINK_CRC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_tlp_link_crc_error || ended_tlp_link_crc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_LINK_CRC_P"}),
                          .msg            ("TLP should have a valid 32 bit Link CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_LINK_CRC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE &&
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_tlp_link_crc_error || ended_tlp_link_crc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_LINK_CRC_N"}),
                          .msg            ("TLP should have a valid 32 bit Link CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NULL_TLP_LINK_CRC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_null_tlp_link_crc_error || ended_null_tlp_link_crc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NULL_TLP_LINK_CRC_P"}),
                          .msg            ("Link CRC of the null TL packet should be logical not of the computed CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NULL_TLP_LINK_CRC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((detected_null_tlp_link_crc_error || ended_null_tlp_link_crc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NULL_TLP_LINK_CRC_N"}),
                          .msg            ("Link CRC of the null TL packet should be logical not of the computed CRC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NULL_TLP_WITH_END_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_tlp_pkt_valid && 
                           lcrc_inverted_of_detected_crc) ||(ended_tlp_pkt_valid &&
                           lcrc_inverted_of_ended_crc))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NULL_TLP_WITH_END_P"}),
                          .msg            ("Nullified TL packet should end with EDB symbol"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NULL_TLP_WITH_END_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_tlp_pkt_valid && 
                           lcrc_inverted_of_detected_crc) ||(ended_tlp_pkt_valid &&
                           lcrc_inverted_of_ended_crc))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NULL_TLP_WITH_END_N"}),
                          .msg            ("Nullified TL packet should end with EDB symbol"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1000 &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} !== 12'b0) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1000 &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} !== 12'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_P"}),
                          .msg            ("Minimum initial credit advertisement violation for posted data credit type"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1000 &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} !== 12'b0) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1000 &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} !== 12'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_N"}),
                          .msg            ("Minimum initial credit advertisement violation for posted data credit type"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DEVICE_TYPE !== 4 && TX_INTERFACE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((cpld_minimum_credit_violation_switch || cpld_minimum_credit_violation_endpoint)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_P"}),
                          .msg            ("Minimum initial credit advertisement violation for completion data credit type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DEVICE_TYPE !== 4 && TX_INTERFACE == 1 &&
                           DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((cpld_minimum_credit_violation_switch || cpld_minimum_credit_violation_endpoint)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_N"}),
                          .msg            ("Minimum initial credit advertisement violation for completion data credit type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DEVICE_TYPE == 0 || DEVICE_TYPE == 1 || DEVICE_TYPE == 7) &&
                           TX_INTERFACE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1100 &&
                           {detected_dllp_pkt[21:16],detected_dllp_pkt[31:30]} !== 8'h00) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1100 &&
                           {ended_dllp_pkt[21:16],ended_dllp_pkt[31:30]} !== 8'h00))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_P"}),
                          .msg            ("For endpoints, minimum initial credit advertisement for completion header credit type should be infinite (8'h00)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DEVICE_TYPE == 0 || DEVICE_TYPE == 1 || DEVICE_TYPE == 7) &&
                           TX_INTERFACE == 1 &&
                           DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1100 &&
                           {detected_dllp_pkt[21:16],detected_dllp_pkt[31:30]} !== 8'h00) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1100 &&
                           {ended_dllp_pkt[21:16],ended_dllp_pkt[31:30]} !== 8'h00))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_N"}),
                          .msg            ("For endpoints, minimum initial credit advertisement for completion header credit type should be infinite (8'h00)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           dlcmsm_present_state == ZI_DL_DOWN_STATE &&
                           dlcmsm_next_state == ZI_DL_DOWN_STATE))) &&
                           ((current_dllp_pkt_valid || ended_dllp_pkt_valid || 
                           detected_dllp_pkt_valid ||
                           current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid   ||
                           detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))));
        M_PCI_EXPRESS_DLP_TLP_IN_DL_DOWN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           dlcmsm_present_state == ZI_DL_DOWN_STATE &&
                           dlcmsm_next_state == ZI_DL_DOWN_STATE)))
                           &&((current_dllp_pkt_valid || ended_dllp_pkt_valid || 
                           detected_dllp_pkt_valid ||
                           current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid  ||
                           detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))));
        M_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && dlcmsm_present_state == ZI_DL_ACTIVE_STATE &&
                           r_vc_tlp_detected))) &&
                           (((detected_dllp_pkt_valid &&(init_fc1_detected ||
                           init_fc2_detected) && 
                           detected_dllp_pkt[10:8] == 3'b0) ||
                           (ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[10:8] == 3'b0))))));
        M_PCI_EXPRESS_FC_DLLP_IN_DL_ACTIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && dlcmsm_present_state == ZI_DL_ACTIVE_STATE &&
                           r_vc_tlp_detected))) &&
                           (((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) 
                           && detected_dllp_pkt[10:8] == 3'b0) ||
                           (ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[10:8] == 3'b0))))));
        M_PCI_EXPRESS_TLP_IN_FC_INIT1_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !fc_init1_done))) &&((current_tlp_pkt_valid ||
                           ended_tlp_pkt_valid   || detected_tlp_pkt_valid ||
                           ended_null_tlp_pkt_valid   || detected_null_tlp_pkt_valid)))));
        M_PCI_EXPRESS_TLP_IN_FC_INIT1_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !fc_init1_done)))
                           &&((current_tlp_pkt_valid || ended_tlp_pkt_valid ||
                           detected_tlp_pkt_valid || ended_null_tlp_pkt_valid   ||
                           detected_null_tlp_pkt_valid)))));
        M_PCI_EXPRESS_DLL_PKT_16BIT_CRC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&( dllp_pkt_16bit_crc_violation))));
        M_PCI_EXPRESS_DLL_PKT_16BIT_CRC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&( dllp_pkt_16bit_crc_violation))));
        M_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status &&(detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_unknown_detected || dllp_unknown_ended)))));
        M_PCI_EXPRESS_UNDEFINED_DLLP_ENCODING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status &&(detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_unknown_detected || dllp_unknown_ended)))));
        M_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !VENDOR_SPECIFIC_ENCODING_ENABLE &&
                           (detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_vendor_specific_detected || dllp_vendor_specific_ended)))));
        M_PCI_EXPRES_VENDOR_SPEC_DLLP_TYPE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && !VENDOR_SPECIFIC_ENCODING_ENABLE &&
                           (detected_dllp_pkt_valid || ended_dllp_pkt_valid))))
                           &&((dllp_vendor_specific_detected || dllp_vendor_specific_ended)))));
        M_PCI_EXPRESS_RESERVED_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && RESERVED_FIELD_CHECK_ENABLE)))
                           &&((fire_detected_dllp_reserved_field_error ||
                           fire_ended_dllp_reserved_field_error)))));
        M_PCI_EXPRESS_RESERVED_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation &&
                           phy_status && RESERVED_FIELD_CHECK_ENABLE)))
                           &&((fire_detected_dllp_reserved_field_error ||
                           fire_ended_dllp_reserved_field_error)))));
        M_PCI_EXPRESS_DLL_PKT_LENGTH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_dllp_pkt_length_violation || 
                           ended_dllp_pkt_length_violation ||
                           current_dllp_pkt_length_violation)))));
        M_PCI_EXPRESS_DLL_PKT_LENGTH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_dllp_pkt_length_violation || 
                           ended_dllp_pkt_length_violation ||
                           current_dllp_pkt_length_violation)))));
        M_PCI_EXPRESS_TLP_LINK_CRC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_tlp_link_crc_error || ended_tlp_link_crc_error)))));
        M_PCI_EXPRESS_TLP_LINK_CRC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE &&
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_tlp_link_crc_error || ended_tlp_link_crc_error)))));
        M_PCI_EXPRESS_NULL_TLP_LINK_CRC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&((detected_null_tlp_link_crc_error || ended_null_tlp_link_crc_error)))));
        M_PCI_EXPRESS_NULL_TLP_LINK_CRC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((detected_null_tlp_link_crc_error || ended_null_tlp_link_crc_error)))));
        M_PCI_EXPRESS_NULL_TLP_WITH_END_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_tlp_pkt_valid && 
                           lcrc_inverted_of_detected_crc) ||(ended_tlp_pkt_valid &&
                           lcrc_inverted_of_ended_crc))))));
        M_PCI_EXPRESS_NULL_TLP_WITH_END_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE && 
                           link_layer_checks_disable !== 1'b1 && 
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_tlp_pkt_valid && 
                           lcrc_inverted_of_detected_crc) ||(ended_tlp_pkt_valid &&
                           lcrc_inverted_of_ended_crc))))));
        M_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1000 &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} !== 12'b0) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1000 &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} !== 12'b0))))));
        M_PCI_EXPRESS_PD_MINIMUM_CREDIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1000 &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {detected_dllp_pkt[27:24], detected_dllp_pkt[39:32]} !== 12'b0) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1000 &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} < 
                           minimum_posted_data_credits &&
                           {ended_dllp_pkt[27:24], ended_dllp_pkt[39:32]} !== 12'b0))))));
        M_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DEVICE_TYPE !== 4 && TX_INTERFACE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((cpld_minimum_credit_violation_switch || cpld_minimum_credit_violation_endpoint)))));
        M_PCI_EXPRESS_CPLD_MINIMUM_CREDIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((DEVICE_TYPE !== 4 && TX_INTERFACE == 1 &&
                           DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&((cpld_minimum_credit_violation_switch || cpld_minimum_credit_violation_endpoint)))));
        M_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DEVICE_TYPE == 0 || DEVICE_TYPE == 1 || DEVICE_TYPE == 7) &&
                           TX_INTERFACE == 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1100 &&
                           {detected_dllp_pkt[21:16],detected_dllp_pkt[31:30]} !== 8'h00) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1100 &&
                           {ended_dllp_pkt[21:16],ended_dllp_pkt[31:30]} !== 8'h00))))));
        M_PCI_EXPRESS_CPLH_MINIMUM_CREDIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_link_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((((DEVICE_TYPE == 0 || DEVICE_TYPE == 1 || DEVICE_TYPE == 7) &&
                           TX_INTERFACE == 1 &&
                           DOUBLE_DATA_RATE === 1 &&
                           link_layer_checks_disable !== 1'b1 &&
                           !link_10b_code_violation && phy_status)))
                           &&(((detected_dllp_pkt_valid &&(init_fc1_detected || init_fc2_detected) &&
                           detected_dllp_pkt[14:11] === 4'b1100 &&
                           {detected_dllp_pkt[21:16],detected_dllp_pkt[31:30]} !== 8'h00) ||(ended_dllp_pkt_valid &&(init_fc1_ended || init_fc2_ended) &&
                           ended_dllp_pkt[14:11] === 4'b1100 &&
                           {ended_dllp_pkt[21:16],ended_dllp_pkt[31:30]} !== 8'h00))))));
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
