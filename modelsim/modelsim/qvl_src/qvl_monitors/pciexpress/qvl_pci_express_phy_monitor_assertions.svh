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
A_PCI_EXPRESS_IDL_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(idl_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_IN_DLLP_TLP_P"}),
                          .msg            ("IDL symbol should not be a part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER

// GEN2 assertions
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assert_PCI_EXPRESS_GEN2
	
	// Assertions with positive clock
	
 	A_PCI_EXPRESS_EIE_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eie_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EIE_IN_DLLP_TLP_P"}),
                          .msg            ("EIE symbol should not be a part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));

	// Assertions with negative clock
	A_PCI_EXPRESS_EIE_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eie_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EIE_IN_DLLP_TLP_N"}),
                          .msg            ("EIE symbol should not be a part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
      end 
	
        A_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0	 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(stp_should_be_followed_by_end_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_P"}),
                          .msg            ("Every STP symbol should be followed by an END/EDB symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_EDB_WITHOUT_STP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(edb_without_stp_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EDB_WITHOUT_STP_P"}),
                          .msg            ("Every EDB symbol should be preceded by a STP symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(sdp_should_be_followed_by_end_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_P"}),
                          .msg            ("Every SDP symbol should be followed by an END symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_END_WITHOUT_STP_SDP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(end_without_stp_or_sdp_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_END_WITHOUT_STP_SDP_P"}),
                          .msg            ("Every END symbol should be preceded by a STP / SDP symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_IDL_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(idl_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_IN_DLLP_TLP_P"}),
                          .msg            ("IDL symbol should not be a part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_COM_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(com_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COM_IN_DLLP_TLP_P"}),
                          .msg            ("COM symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PAD_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(pad_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PAD_IN_DLLP_TLP_P"}),
                          .msg            ("PAD symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_FTS_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(fts_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_IN_DLLP_TLP_P"}),
                          .msg            ("FTS symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_IN_DLLP_TLP_P"}),
                          .msg            ("SKP symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_NO_STP_SDP_LANE0_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(r_idle_data_detected === 1'b1 && 
                           xmting_dllp_tlp === 1'b1 &&
                           ((descrambled_data[7:0] !== ZI_STP 
                           && d_or_k_code[0] === 1'b1 &&  
                           descrambled_data[7:0] !== ZI_SDP) || d_or_k_code[0] === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_STP_SDP_LANE0_P"}),
                          .msg            ("SDP, STP symbols should be placed on lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_MORE_THAN_ONE_STP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_stp_symbol)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MORE_THAN_ONE_STP_P"}),
                          .msg            ("There should not be more than one STP symbol in a symbol time."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_MORE_THAN_ONE_SDP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_sdp_symbol)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MORE_THAN_ONE_SDP_P"}),
                          .msg            ("There should not be more than one SDP symbol in a symbol time."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PADDING_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(padding_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PADDING_ERROR_P"}),
                          .msg            ("Padding error detected when link is X8 or wider."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(padding_when_link_width_1_2_4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_P"}),
                          .msg            ("PAD symbols should not be transmitted after an end of TL or DL packet when link is < X8."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_END_OF_PKT_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(end_of_pkt_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_END_OF_PKT_ERROR_P"}),
                          .msg            ("Total length of the packet should always be an integral multiple of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(tlp_on_link_when_dll_is_down)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_P"}),
                          .msg            ("TLP should not be transmitted when data link layer is down."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(spl_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_P"}),
                          .msg            ("Special reserved symbols should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(invalid_code_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_P"}),
                          .msg            ("Invalid 10B codes should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_received)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_P"}),
                          .msg            ("SKP ordered sets should be received within 5664 symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_OS_NOT_XMTD_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_xmtd)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_OS_NOT_XMTD_P"}),
                          .msg            ("SKP ordered sets should be scheduled once every 1180 to 1538 symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(sdp_stp_on_wrong_lanes && link_width > 4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_P"}),
                          .msg            ("STP and SDP symbols should always be placed on lanes which are multiples of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_EIDLE_NOT_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && 
                           electrical_idle_detected === 1'b0 &&
                           ((ttx_eidle_count === 2 && pw_INTERFACE_TYPE === 1) 
                           ||(ttx_eidle_count === 20 && pw_INTERFACE_TYPE === 0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EIDLE_NOT_DETECTED_P"}),
                          .msg            ("Electrical idle is not detected on the bus within the specified maximum time interval after detecting EIOS."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && 
                           electrical_idle_detected === 1'b0 && 
                           r_electrical_idle_detected === 1'b1 &&
                           ((ttx_eidle_count <= 7 && pw_INTERFACE_TYPE === 1) ||
                           (ttx_eidle_count <= 70 && pw_INTERFACE_TYPE === 0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_P"}),
                          .msg            ("Bus should be in the electrical idle state for the specified minimum time interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(stp_should_be_followed_by_end_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_N"}),
                          .msg            ("Every STP symbol should be followed by an END/EDB symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_EDB_WITHOUT_STP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(edb_without_stp_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EDB_WITHOUT_STP_N"}),
                          .msg            ("Every EDB symbol should be preceded by a STP symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(sdp_should_be_followed_by_end_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_N"}),
                          .msg            ("Every SDP symbol should be followed by an END symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_END_WITHOUT_STP_SDP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(end_without_stp_or_sdp_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_END_WITHOUT_STP_SDP_N"}),
                          .msg            ("Every END symbol should be preceded by a STP / SDP symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_IDL_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(idl_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_IN_DLLP_TLP_N"}),
                          .msg            ("IDL symbol should not be a part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_COM_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0	 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(com_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COM_IN_DLLP_TLP_N"}),
                          .msg            ("COM symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PAD_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(pad_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PAD_IN_DLLP_TLP_N"}),
                          .msg            ("PAD symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_FTS_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(fts_in_dllp_tlp)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_IN_DLLP_TLP_N"}),
                          .msg            ("FTS symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_in_dllp_tlp)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_IN_DLLP_TLP_N"}),
                          .msg            ("SKP symbol should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_NO_STP_SDP_LANE0_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(r_idle_data_detected === 1'b1 && xmting_dllp_tlp === 1'b1 &&
                           ((descrambled_data[7:0] !== ZI_STP && d_or_k_code[0] === 1'b1 &&  
                           descrambled_data[7:0] !== ZI_SDP) || d_or_k_code[0] === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_STP_SDP_LANE0_N"}),
                          .msg            ("SDP, STP symbols should be placed on lane 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_MORE_THAN_ONE_STP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_stp_symbol)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MORE_THAN_ONE_STP_N"}),
                          .msg            ("There should not be more than one STP symbol in a symbol time."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_MORE_THAN_ONE_SDP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_sdp_symbol)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MORE_THAN_ONE_SDP_N"}),
                          .msg            ("There should not be more than one SDP symbol in a symbol time."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PADDING_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(padding_error)))))		     
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PADDING_ERROR_N"}),
                          .msg            ("Padding error detected when link is X8 or wider."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(padding_when_link_width_1_2_4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_N"}),
                          .msg            ("PAD symbols should not be transmitted after an end of TL or DL packet when link is < X8."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_END_OF_PKT_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(end_of_pkt_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_END_OF_PKT_ERROR_N"}),
                          .msg            ("Total length of the packet should always be an integral multiple of 4."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(tlp_on_link_when_dll_is_down)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_N"}),
                          .msg            ("TLP should not be transmitted when data link layer is down."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(spl_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_N"}),
                          .msg            ("Special reserved symbols should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(invalid_code_in_dllp_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_N"}),
                          .msg            ("Invalid 10B codes should not be part of DLL or TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_received)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_N"}),
                          .msg            ("SKP ordered sets should be received within 5664 symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SKP_OS_NOT_XMTD_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_xmtd)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_OS_NOT_XMTD_N"}),
                          .msg            ("SKP ordered sets should be scheduled once every 1180 to 1538 symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(sdp_stp_on_wrong_lanes && link_width > 4)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_N"}),
                          .msg            ("STP and SDP symbols should always be placed on lanes which are multiples of four."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_EIDLE_NOT_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && electrical_idle_detected === 1'b0 &&((ttx_eidle_count === 2 && pw_INTERFACE_TYPE === 1) ||(ttx_eidle_count === 20 
                           && pw_INTERFACE_TYPE === 0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_EIDLE_NOT_DETECTED_N"}),
                          .msg            ("Electrical idle is not detected on the bus within the specified maximum time interval after detecting EIOS."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
        A_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && electrical_idle_detected === 1'b0 && r_electrical_idle_detected === 1'b1 &&((ttx_eidle_count <= 7 && 
                           pw_INTERFACE_TYPE === 1) ||(ttx_eidle_count <= 70 && pw_INTERFACE_TYPE === 0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_N"}),
                          .msg            ("Bus should be in the electrical idle state for the specified minimum time interval."),
                          .severity_level (QVL_ERROR),
                          .property_type  ((Constraints_Mode)));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER

// GEN2 assume
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assume_PCI_EXPRESS_GEN2
	
	// Assertions with positive clock
	
 	M_PCI_EXPRESS_EIE_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eie_in_dllp_tlp)))));

	// Assertions with negative clock
	M_PCI_EXPRESS_EIE_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eie_in_dllp_tlp)))));
      end 
	
        M_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0	 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(stp_should_be_followed_by_end_error)))));
        M_PCI_EXPRESS_EDB_WITHOUT_STP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(edb_without_stp_error)))));
        M_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(sdp_should_be_followed_by_end_error)))));
        M_PCI_EXPRESS_END_WITHOUT_STP_SDP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(end_without_stp_or_sdp_error)))));
        M_PCI_EXPRESS_IDL_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(idl_in_dllp_tlp)))));
        M_PCI_EXPRESS_COM_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(com_in_dllp_tlp)))));
        M_PCI_EXPRESS_PAD_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(pad_in_dllp_tlp)))));
        M_PCI_EXPRESS_FTS_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(fts_in_dllp_tlp)))));
        M_PCI_EXPRESS_SKP_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_in_dllp_tlp)))));
        M_PCI_EXPRESS_NO_STP_SDP_LANE0_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(r_idle_data_detected === 1'b1 && 
                           xmting_dllp_tlp === 1'b1 &&
                           ((descrambled_data[7:0] !== ZI_STP 
                           && d_or_k_code[0] === 1'b1 &&  
                           descrambled_data[7:0] !== ZI_SDP) || d_or_k_code[0] === 1'b0))))));
        M_PCI_EXPRESS_MORE_THAN_ONE_STP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_stp_symbol)))));
        M_PCI_EXPRESS_MORE_THAN_ONE_SDP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_sdp_symbol)))));
        M_PCI_EXPRESS_PADDING_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(padding_error)))));
        M_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(padding_when_link_width_1_2_4)))));
        M_PCI_EXPRESS_END_OF_PKT_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(end_of_pkt_error)))));
        M_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(tlp_on_link_when_dll_is_down)))));
        M_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(spl_in_dllp_tlp)))));
        M_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(invalid_code_in_dllp_tlp)))));
        M_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_received)))));
        M_PCI_EXPRESS_SKP_OS_NOT_XMTD_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_xmtd)))));
        M_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(sdp_stp_on_wrong_lanes && link_width > 4)))));
        M_PCI_EXPRESS_EIDLE_NOT_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && 
                           electrical_idle_detected === 1'b0 &&
                           ((ttx_eidle_count === 2 && pw_INTERFACE_TYPE === 1) 
                           ||(ttx_eidle_count === 20 && pw_INTERFACE_TYPE === 0)))))));
        M_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && 
                           electrical_idle_detected === 1'b0 && 
                           r_electrical_idle_detected === 1'b1 &&
                           ((ttx_eidle_count <= 7 && pw_INTERFACE_TYPE === 1) ||
                           (ttx_eidle_count <= 70 && pw_INTERFACE_TYPE === 0)))))));
        M_PCI_EXPRESS_STP_NOT_FOLLOWED_BY_END_EDB_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(stp_should_be_followed_by_end_error)))));
        M_PCI_EXPRESS_EDB_WITHOUT_STP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(edb_without_stp_error)))));
        M_PCI_EXPRESS_SDP_NOT_FOLLOWED_BY_END_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(sdp_should_be_followed_by_end_error)))));
        M_PCI_EXPRESS_END_WITHOUT_STP_SDP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(end_without_stp_or_sdp_error)))));
        M_PCI_EXPRESS_IDL_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(idl_in_dllp_tlp)))));
        M_PCI_EXPRESS_COM_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0	 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(com_in_dllp_tlp)))));
        M_PCI_EXPRESS_PAD_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(pad_in_dllp_tlp)))));
        M_PCI_EXPRESS_FTS_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
			  .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(fts_in_dllp_tlp)))));		     
        M_PCI_EXPRESS_SKP_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_in_dllp_tlp)))));
        M_PCI_EXPRESS_NO_STP_SDP_LANE0_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                           electrical_idle_detected === 1'b0 && 
                           DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(r_idle_data_detected === 1'b1 && xmting_dllp_tlp === 1'b1 &&
                           ((descrambled_data[7:0] !== ZI_STP && d_or_k_code[0] === 1'b1 &&  
                           descrambled_data[7:0] !== ZI_SDP) || d_or_k_code[0] === 1'b0))))));
        M_PCI_EXPRESS_MORE_THAN_ONE_STP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_stp_symbol)))));
        M_PCI_EXPRESS_MORE_THAN_ONE_SDP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(more_than_one_sdp_symbol)))));
        M_PCI_EXPRESS_PADDING_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(padding_error)))));
        M_PCI_EXPRESS_PAD_WHEN_LINK_WIDTH_1_2_4_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(padding_when_link_width_1_2_4)))));
        M_PCI_EXPRESS_END_OF_PKT_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(end_of_pkt_error)))));
        M_PCI_EXPRESS_TLP_WHEN_LINK_DOWN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(tlp_on_link_when_dll_is_down)))));
        M_PCI_EXPRESS_SPL_RESERVED_SYMBOLS_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(spl_in_dllp_tlp)))));
        M_PCI_EXPRESS_INVALID_CODE_IN_DLLP_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(invalid_code_in_dllp_tlp)))));
        M_PCI_EXPRESS_SKP_OS_NOT_RECEIVED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_received)))));
        M_PCI_EXPRESS_SKP_OS_NOT_XMTD_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(skp_os_not_xmtd)))));
        M_PCI_EXPRESS_SDP_STP_ON_INCORRECT_LANES_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(sdp_stp_on_wrong_lanes && link_width > 4)))));
        M_PCI_EXPRESS_EIDLE_NOT_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && electrical_idle_detected === 1'b0 &&((ttx_eidle_count === 2 && pw_INTERFACE_TYPE === 1) 
                           ||(ttx_eidle_count === 20 && pw_INTERFACE_TYPE === 0)))))));
        M_PCI_EXPRESS_TTX_IDLE_MIN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((reset === 1'b0 && areset === 1'b0 && electrical_idle_detected === 1'b0 && DOUBLE_DATA_RATE == 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eidle_os_flag === 1'b1 && electrical_idle_detected === 1'b0 && r_electrical_idle_detected === 1'b1 
                           &&((ttx_eidle_count <= 7 && pw_INTERFACE_TYPE === 1) ||(ttx_eidle_count <= 70 && pw_INTERFACE_TYPE === 0)))))));
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
