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

// All GEN2 assertions
	if( PCI_EXPRESS_GEN2 == 1)
	  begin : qvl_assert_PCI_EXPRESS_GEN2
	    // Assertions with positive clock
	    A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_malformed_tlp)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_P"}),
                              .msg            ("Deprecated TLP types(TcfgRd/TcfgWr) are malformed and must not be issued."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_pci_express_end_point)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_P"}),
                              .msg            ("PCI Express endpoints should not generate Deprecated TLP requests."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_legacy_end_point)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_P"}),
                              .msg            ("Legacy endpoints should not generate Deprecated TLP requests."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(io_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_P"}),
                              .msg            ("Address Type(AT) field of an I/O request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cfg_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_P"}),
                              .msg            ("Address Type(AT) field of an configuration request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(msg_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_P"}),
                              .msg            ("Address Type(AT) field of message request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_P"}),
                              .msg            ("Address Type(AT) field of completion should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(ep_field_without_data_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_P"}),
                              .msg            ("EP field of TLP without data must not be 1."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(mem_req_acs_violation_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_P"}),
                              .msg            ("Memory request initiated by device should have default address type(AT) field when ACS translation is blocking."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(msg_routing_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_P"}),
                              .msg            ("Routing 101 for MSG other than PME_TO_ACK is malformed TLP."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(ignored_msg_routing_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_P"}),
                              .msg            ("Ignored message should have routing 100."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pme_2ack_msg_function_num_non_reserved)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_P"}),
                              .msg            ("PME To Ack message should have function number reserved."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    
	    // Assertions with negative clock
	    A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_malformed_tlp)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_N"}),
                              .msg            ("Deprecated TLP types(TcfgRd/TcfgWr) are malformed and must not be issued."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 && 
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_pci_express_end_point)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_N"}),
                              .msg            ("PCI Express endpoints should not generate Deprecated TLP requests."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 && 
			       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_legacy_end_point)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_N"}),
                              .msg            ("Legacy endpoints should not generate Deprecated TLP requests."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(io_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_N"}),
                              .msg            ("Address Type(AT) field of an I/O request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(cfg_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_N"}),
                              .msg            ("Address Type(AT) field of an configuration request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(msg_req_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_N"}),
                              .msg            ("Address Type(AT) field of message request should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_at_field_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_N"}),
                              .msg            ("Address Type(AT) field of completion should be 2'b00."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(ep_field_without_data_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_N"}),
                              .msg            ("EP field of TLP without data must not be 1."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(mem_req_acs_violation_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_N"}),
                              .msg            ("Memory request initiated by device should have default address type(AT) field when ACS translation is blocking."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(msg_routing_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_N"}),
                              .msg            ("Routing 101 for MSG other than PME_TO_ACK is malformed TLP."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(ignored_msg_routing_error)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_N"}),
                              .msg            ("Ignored message should have routing 100."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pme_2ack_msg_function_num_non_reserved)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_N"}),
                              .msg            ("PME To Ack message should have function number reserved."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	  end
	
        // Additional gen1 code start
	A_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && non_zero_data_31_10_in_sspl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_P"}),
                          .msg            ("Slot power limit(SSPL) support message should have bit 31:10 of datapayload all 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && byte_8_9_non_reserved_for_routing_by_id === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_P"}),
                          .msg            ("Vendor defined message not routed by ID should have byte 8 and 9 reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_bcm_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_P"}),
                          .msg            ("BCM bit must not be set in completion by PCI Express."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_POISONNED_TLP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(poisonned_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_POISONNED_TLP_P"}),
                          .msg            ("TLP is poisonned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_more_than_2dw)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_P"}),
                          .msg            ("The first DWBE should not be non-contiguous for length > 2DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_more_than_2dw)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_P"}),
                          .msg            ("The last DWBE should not be non-contiguous for length > 2DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_2dw_non_qw_aligned)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P"}),
                          .msg            ("The first DWBE should not be non-contiguous for length = 2DW, non QW aligned  memory request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_2dw_non_qw_aligned)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P"}),
                          .msg            ("The last DWBE should not be non-contiguous for length = 2DW, non QW aligned  memory request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INVALID_REQ_ID_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_req_id)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_REQ_ID_P"}),
                          .msg            ("All request initiated from EP should have valid requester ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_before_init_cfg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_P"}),
                          .msg            ("Device is not permitted to initiate any request before initial configuration write cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_P"}),
                          .msg            ("INTx message can only be initiated from upstream port."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INVALID_COMPLETER_ID_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_completer_id)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_COMPLETER_ID_P"}),
                          .msg            ("All completions from EP should have valid completer ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completer_id_not_0_before_initial_cfg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_P"}),
                          .msg            ("All completions before initial configuration must have bus number and device number 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_P"}),
                          .msg            ("All INTx message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_act_state_nak_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_P"}),
                          .msg            ("PM Active State Nak message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_pme_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_P"}),
                          .msg            ("PM PME message should have routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_turnoff_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_P"}),
                          .msg            ("PM Turnoff message should have routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_P"}),
                          .msg            ("Error message should have routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_P"}),
                          .msg            ("Unlock message should have routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_P"}),
                          .msg            ("SSPL message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_2ack_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_P"}),
                          .msg            ("PME To Ack message should have routing 101."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_P"}),
                          .msg            ("Hot Plug message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_P"}),
                          .msg            ("Vendor defined messages should have routing 100/011/010/000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && intx_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_P"}),
                          .msg            ("All INTx message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pm_act_state_nak_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_P"}),
                          .msg            ("PM Active State Nak message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && unlock_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_P"}),
                          .msg            ("Unlcok message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_LENGTH_NT_1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_length_not_1dw === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_LENGTH_NT_1_P"}),
                          .msg            ("SSPL message should have 1 DW length."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only EP/SW upstream port can send correctable error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only EP/SW upstream port can send non fatal error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only EP/SW upstream port can send fatal error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send SSPL message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_on_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator On message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_bl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator Blink message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_off_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_on_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator On message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_bl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator Blink message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_off_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(at_pressed_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_P"}),
                          .msg            ("Only EP/SW upstream port can send Attention Button Pressed message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_000_from_rc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_P"}),
                          .msg            ("RC should not initiate message packet with routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_011_from_ep)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_P"}),
                          .msg            ("EP should not initiate message packet with routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_UR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ur)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_UR_P"}),
                          .msg            ("Completion Status UR."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_CA_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ca)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_CA_P"}),
                          .msg            ("Completion Status CA."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_CRS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_crs)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_CRS_P"}),
                          .msg            ("Completion Status CRS."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NO_SSPL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_not_sent_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_SSPL_P"}),
                          .msg            ("SSPL should be sent while transtioning from DL_DOWN to DL_UP."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COR_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COR_ERR_P"}),
                          .msg            ("Correctable error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NFT_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NFT_ERR_P"}),
                          .msg            ("Non Fatal error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_FT_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FT_ERR_P"}),
                          .msg            ("Fatal error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MRD_LK_TC_NE_0_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mrdlk_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MRD_LK_TC_NE_0_P"}),
                          .msg            ("MRDLK should have TC as 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_LK_TC_NE_0_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_TC_NE_0_P"}),
                          .msg            ("CPLLK should have TC as 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_LK_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_message_without_lock)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LK_ERR_P"}),
                          .msg            ("Unlock message should not be used when lock is not established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NO_LK_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(other_than_unlock_n_mrdlk_when_lock_established)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_LK_ERR_P"}),
                          .msg            ("Other than unlock message or MRDLK should not be used when lock has been established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_LK_ERR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_received_when_lock_not_established)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_ERR_P"}),
                          .msg            ("CPLLK should not be received when lock is not established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_TLP_USING_UNINIT_VC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tc_with_uninitialized_vc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_USING_UNINIT_VC_P"}),
                          .msg            ("TLP must not use uninitialized VC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	
	// Additional gen1 code end
	
        A_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_header_field)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_P"}),
                          .msg            ("Undefined TLP packet type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_P"}),
                          .msg            ("I/O requests should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_P"}),
                          .msg            ("Configuration requests should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_P"}),
                          .msg            ("Message requests should have a header length of 4 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_header_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_P"}),
                          .msg            ("Completions should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_P"}),
                          .msg            ("PCI Express endpoints should not generate I/O requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_P"}),
                          .msg            ("PCI Express endpoints should not generate configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_P"}),
                          .msg            ("PCI Express endpoints should not generate locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_P"}),
                          .msg            ("PCI Express endpoints should not complete locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_legacy_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_P"}),
                          .msg            ("Legacy endpoints should not generate configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_legacy_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_P"}),
                          .msg            ("Legacy endpoints should not generate locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_root_complex)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_P"}),
                          .msg            ("A Root complex should not complete a locked memory read request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_P"}),
                          .msg            ("Traffic class field of an I/O request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_P"}),
                          .msg            ("Traffic class field of a configuration request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_P"}),
                          .msg            ("Traffic class field of a message request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_P"}),
                          .msg            ("Attribute field of an I/O request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_P"}),
                          .msg            ("Attribute field of configuration request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_P"}),
                          .msg            ("Attribute field of a message request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_length_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_P"}),
                          .msg            ("I/O requests should have a length of one data word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_length_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_P"}),
                          .msg            ("Configuration requests should have a length of one data word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_P"}),
                          .msg            ("Status field of the completion packets should have only defined values."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_non_zero_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_P"}),
                          .msg            ("The first DWBE field of the TLP header should not be 4'b0000 if the length field is greater than 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LAST_DW_BE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_last_dw_be)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LAST_DW_BE_ERROR_P"}),
                          .msg            ("The last DWBE field of the TLP header should be 4'b0000 if the length field specified is 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_non_zero_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_P"}),
                          .msg            ("The last DWBE field of the TLP header should be non-zero if the length specified is greater than 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ECRC_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ecrc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ECRC_ERROR_P"}),
                          .msg            ("End to end CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TAG_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tag_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TAG_FIELD_ERROR_P"}),
                          .msg            ("The higher order three bits of the Tag field should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(address_format_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_P"}),
                          .msg            ("64 bit addressing format should not be used when the address requires only 32 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_INTR_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intr_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTR_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal interrupt signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PME_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal power management message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ERR_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ERR_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal error signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_tran_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal locked transaction support message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal slot power limit support message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal hot plug signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_specific_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_P"}),
                          .msg            ("Illegal vendor specific message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_msg_code_group)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_P"}),
                          .msg            ("Undefined message code group."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NO_TLP_DIGEST_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_tlp_digest)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_TLP_DIGEST_P"}),
                          .msg            ("Packet should contain TLP digest when TD field is 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_payload_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_P"}),
                          .msg            ("Payload should not exceed the specified maximum number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_read_req_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_P"}),
                          .msg            ("Requester should not request more than the specified maximum number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_reserved_field_error && 
                           pw_RESERVED_FIELD_CHECK_ENABLE
                           && TX_INTERFACE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_P"}),
                          .msg            ("Reserved fields in the TLP packet should be driven to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(illegal_address_length_combination)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_P"}),
                          .msg            ("The address and length combination which results in a memory access to cross 4K boundary should not be specified."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_pkt_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_P"}),
                          .msg            ("TLP packet size error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(root_complex_rcvd_cfg_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_P"}),
                          .msg            ("Configuration requests should not be issued to root complex."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&((cpl_length_field_error || cpl_lk_length_field_error) &&
                           pw_RESERVED_FIELD_CHECK_ENABLE === 1'b1 && 
                           TX_INTERFACE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_P"}),
                          .msg            ("Length field is reserved for Cpl, CplLk completion TLP packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_TYPE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_type_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_TYPE_ERROR_P"}),
                          .msg            ("Message request detected should not be of type 'MsgD'."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_type_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_P"}),
                          .msg            ("Slot power limit support messages should not be of type 'Msg' ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_doesnot_map_to_any_vc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_P"}),
                          .msg            ("TLP detected does not map to any of the VCs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ignored_message_detected)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_P"}),
                          .msg            ("Ignored messages should not be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_length_field_error && 
                           RESERVED_FIELD_CHECK_ENABLE === 1'b1
                           && TX_INTERFACE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_P"}),
                          .msg            ("Length field is reserved for all messages except for Slot power, Vendor specific, Hot plug signaling messages."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	
	// Additional gen1 code start
	A_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && non_zero_data_31_10_in_sspl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_N"}),
                          .msg            ("Slot power limit(SSPL) support message should have bit 31:0 of datapayload all 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && byte_8_9_non_reserved_for_routing_by_id === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_N"}),
                          .msg            ("Vendor defined message not routed by ID should have byte 8 and 9 reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_bcm_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_N"}),
                          .msg            ("BCM bit must not be set in completion by PCI Express."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_POISONNED_TLP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(poisonned_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_POISONNED_TLP_N"}),
                          .msg            ("TLP is poisonned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_more_than_2dw)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_N"}),
                          .msg            ("The first DWBE should not be non-contiguous for length > 2DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_more_than_2dw)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_N"}),
                          .msg            ("The last DWBE should not be non-contiguous for length > 2DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_2dw_non_qw_aligned)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N"}),
                          .msg            ("The first DWBE should not be non-contiguous for length = 2DW, non QW aligned  memory request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_2dw_non_qw_aligned)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N"}),
                          .msg            ("The last DWBE should not be non-contiguous for length = 2DW, non QW aligned  memory request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INVALID_REQ_ID_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_req_id)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_REQ_ID_N"}),
                          .msg            ("All request initiated from EP should have valid requester ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_before_init_cfg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_N"}),
                          .msg            ("Device is not permitted to initiate any request before initial configuration write cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_N"}),
                          .msg            ("INTx message can only be initiated from upstream port."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INVALID_COMPLETER_ID_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_completer_id)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INVALID_COMPLETER_ID_N"}),
                          .msg            ("All completions from EP should have valid completer ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completer_id_not_0_before_initial_cfg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_N"}),
                          .msg            ("All completions before initial configuration must have bus number and device number 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_N"}),
                          .msg            ("All INTx message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_act_state_nak_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_N"}),
                          .msg            ("PM Active State Nak message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_pme_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_N"}),
                          .msg            ("PM PME message should have routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_turnoff_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_N"}),
                          .msg            ("PM Turnoff message should have routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_N"}),
                          .msg            ("Error message should have routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_N"}),
                          .msg            ("Unlock message should have routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_N"}),
                          .msg            ("SSPL message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_2ack_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_N"}),
                          .msg            ("PME To Ack message should have routing 101."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_N"}),
                          .msg            ("Hot Plug message should have routing 100."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_msg_routing_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_N"}),
                          .msg            ("Vendor defined messages should have routing 100/011/010/000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && intx_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_N"}),
                          .msg            ("All INTx message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pm_act_state_nak_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_N"}),
                          .msg            ("PM Active State Nak message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && unlock_msg_function_num_non_reserved)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_N"}),
                          .msg            ("Unlcok message should have function number reserved."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_LENGTH_NT_1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_length_not_1dw === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_LENGTH_NT_1_N"}),
                          .msg            ("SSPL message should have 1 DW length."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only EP/SW upstream port can send correctable error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only EP/SW upstream port can send non fatal error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_err_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only EP/SW upstream port can send fatal error message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send SSPL message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_on_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator On message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_bl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator Blink message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_off_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Attention Indicator Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_on_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator On message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_bl_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator Blink message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_off_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only RC/SW downstream port can send Power Indicator Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(at_pressed_msg_direction_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_N"}),
                          .msg            ("Only EP/SW upstream port can send Attention Button Pressed message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_000_from_rc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_N"}),
                          .msg            ("RC should not initiate message packet with routing 000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_011_from_ep)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_N"}),
                          .msg            ("EP should not initiate message packet with routing 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_UR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ur)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_UR_N"}),
                          .msg            ("Completion Status UR."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_CA_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ca)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_CA_N"}),
                          .msg            ("Completion Status CA."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_STATUS_CRS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_crs)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_CRS_N"}),
                          .msg            ("Completion Status CRS."),
                          .severity_level (QVL_INFO),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NO_SSPL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_not_sent_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_SSPL_N"}),
                          .msg            ("SSPL should be sent while transtioning from DL_DOWN to DL_UP."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_COR_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COR_ERR_N"}),
                          .msg            ("Correctable error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NFT_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NFT_ERR_N"}),
                          .msg            ("Non Fatal error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_FT_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_error_msg)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FT_ERR_N"}),
                          .msg            ("Fatal error message received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_MRD_LK_TC_NE_0_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mrdlk_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MRD_LK_TC_NE_0_N"}),
                          .msg            ("MRDLK should have TC as 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_LK_TC_NE_0_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_TC_NE_0_N"}),
                          .msg            ("CPLLK should have TC as 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_LK_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_message_without_lock)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LK_ERR_N"}),
                          .msg            ("Unlock message should not be used when lock is not established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_NO_LK_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(other_than_unlock_n_mrdlk_when_lock_established)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_LK_ERR_N"}),
                          .msg            ("Other than unlock message or MRDLK should not be used when lock has been established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_CPL_LK_ERR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_received_when_lock_not_established)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_ERR_N"}),
                          .msg            ("CPLLK should not be received when lock is not established."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_TLP_USING_UNINIT_VC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tc_with_uninitialized_vc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_USING_UNINIT_VC_N"}),
                          .msg            ("TLP must not use uninitialized VC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	// Additional gen1 code end
	
        A_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_header_field)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_N"}),
                          .msg            ("Undefined TLP packet type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_N"}),
                          .msg            ("I/O requests should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_N"}),
                          .msg            ("Configuration requests should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_hdr_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_N"}),
                          .msg            ("Message requests should have a header length of 4 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_header_length_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_N"}),
                          .msg            ("Completions should have a header length of 3 DWs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_N"}),
                          .msg            ("PCI Express endpoints should not generate I/O requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_N"}),
                          .msg            ("PCI Express endpoints should not generate configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_N"}),
                          .msg            ("PCI Express endpoints should not generate locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_pci_express_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_N"}),
                          .msg            ("PCI Express endpoints should not complete locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_legacy_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_N"}),
                          .msg            ("Legacy endpoints should not generate configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_legacy_end_point)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_N"}),
                          .msg            ("Legacy endpoints should not generate locked memory read requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_root_complex)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_N"}),
                          .msg            ("A Root complex should not complete a locked memory read request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_N"}),
                          .msg            ("Traffic class field of an I/O request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_N"}),
                          .msg            ("Traffic class field of a configuration request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_tc_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_N"}),
                          .msg            ("Traffic class field of a message request should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_N"}),
                          .msg            ("Attribute field of an I/O request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_N"}),
                          .msg            ("Attribute field of configuration request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_attr_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_N"}),
                          .msg            ("Attribute field of a message request should be 2'b00."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_length_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_N"}),
                          .msg            ("I/O requests should have a length of one data word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_length_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_N"}),
                          .msg            ("Configuration requests should have a length of one data word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_N"}),
                          .msg            ("Status field of the completion packets should have only defined values."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_non_zero_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_N"}),
                          .msg            ("The first DWBE field of the TLP header should not be 4'b0000 if the length field is greater than 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LAST_DW_BE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_last_dw_be)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LAST_DW_BE_ERROR_N"}),
                          .msg            ("The last DWBE field of the TLP header should be 4'b0000 if the length field specified is 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_non_zero_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_N"}),
                          .msg            ("The last DWBE field of the TLP header should be non-zero if the length specified is greater than 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ECRC_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ecrc_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ECRC_ERROR_N"}),
                          .msg            ("End to end CRC error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TAG_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tag_field_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TAG_FIELD_ERROR_N"}),
                          .msg            ("The higher order three bits of the Tag field should be 3'b000."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(address_format_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_N"}),
                          .msg            ("64 bit addressing format should not be used when the address requires only 32 bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_INTR_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intr_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_INTR_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal interrupt signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PME_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal power management message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ERR_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ERR_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal error signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_tran_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal locked transaction support message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal slot power limit support message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal hot plug signaling message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_specific_msg_code_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_N"}),
                          .msg            ("Illegal vendor specific message code."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_msg_code_group)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_N"}),
                          .msg            ("Undefined message code group."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NO_TLP_DIGEST_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_tlp_digest)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_TLP_DIGEST_N"}),
                          .msg            ("Packet should contain TLP digest when TD field is 1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_payload_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_N"}),
                          .msg            ("Payload should not exceed the specified maximum number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_read_req_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_N"}),
                          .msg            ("Requester should not request more than the specified maximum number of bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_reserved_field_error &&
                           pw_RESERVED_FIELD_CHECK_ENABLE
                           && TX_INTERFACE == 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_N"}),
                          .msg            ("Reserved fields in the TLP packet should be driven to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(illegal_address_length_combination)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_N"}),
                          .msg            ("The address and length combination which results in a memory access to cross 4K boundary should not be specified."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_pkt_size_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_N"}),
                          .msg            ("TLP packet size error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(root_complex_rcvd_cfg_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_N"}),
                          .msg            ("Configuration requests should not be issued to root complex."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&((cpl_length_field_error || cpl_lk_length_field_error)
                           &&
                           pw_RESERVED_FIELD_CHECK_ENABLE === 1'b1 &&
                           TX_INTERFACE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_N"}),
                          .msg            ("Length field is reserved for Cpl, CplLk completion TLP packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_TYPE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_type_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_TYPE_ERROR_N"}),
                          .msg            ("Message request detected should not be of type 'MsgD'"),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_type_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_N"}),
                          .msg            ("Slot power limit support messages should not be of type 'Msg' ."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_doesnot_map_to_any_vc)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_N"}),
                          .msg            ("TLP detected does not map to any of the VCs."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ignored_message_detected)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_N"}),
                          .msg            ("Ignored messages should not be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_length_field_error &&
                           RESERVED_FIELD_CHECK_ENABLE === 1'b1
                           && TX_INTERFACE === 1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_N"}),
                          .msg            ("Length field is reserved for all messages except for Slot power, Vendor specific, Hot plug signaling messages."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER

// All GEN2 assume
	if( PCI_EXPRESS_GEN2 == 1)
	  begin : qvl_assume_PCI_EXPRESS_GEN2
	    // Assertions with positive clock
	    M_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
	    		  &&(deprecated_malformed_tlp)))));
	    M_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
	    		   &&(deprecated_req_pci_express_end_point)))));
	    M_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
	    		   &&(deprecated_req_legacy_end_point)))));
	    M_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
	    		   &&(io_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cfg_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(msg_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
	    		   &&(ep_field_without_data_error)))));
	    M_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(mem_req_acs_violation_error)))));
	    M_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(msg_routing_error)))));
	    M_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(ignored_msg_routing_error)))));
	    M_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               transaction_layer_checks_disable !== 1'b1)
                               &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pme_2ack_msg_function_num_non_reserved)))));
	    
	    // Assertions with negative clock
	    M_PCI_EXPRESS_GEN2_DEPRECATED_TLP_ERROR_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_malformed_tlp)))));
	    M_PCI_EXPRESS_GEN2_DEPRECATED_TLP_PCI_EXPRESS_END_POINT_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_pci_express_end_point)))));
	    M_PCI_EXPRESS_GEN2_DEPRECATED_REQ_LEGACY_END_POINT_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(deprecated_req_legacy_end_point)))));
	    M_PCI_EXPRESS_GEN2_IO_REQ_AT_FIELD_ERROR_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(io_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_CFG_REQ_AT_FIELD_ERROR_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(cfg_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_MSG_REQ_AT_FIELD_ERROR_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(msg_req_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_CPL_AT_FIELD_ERROR_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_at_field_error)))));
	    M_PCI_EXPRESS_GEN2_EP_BIT_VIOLATION_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
	    		   &&(ep_field_without_data_error)))));
	    M_PCI_EXPRESS_GEN2_MEM_REQ_ACS_VIOLATION_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk ),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
	    		       DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(mem_req_acs_violation_error)))));
	    M_PCI_EXPRESS_GEN2_ILLEGAL_ROUTING_FOR_NON_PME_TO_ACK_MSG_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(msg_routing_error)))));
	    M_PCI_EXPRESS_GEN2_IGNORED_MSG_ROUTING_NT_100_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(ignored_msg_routing_error)))));
	    M_PCI_EXPRESS_GEN2_PME_2_ACK_MSG_NON_RSVD_FN_NUMBER_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                               DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                               &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pme_2ack_msg_function_num_non_reserved)))));
	  end  

	// Additional gen1 code start
	M_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && non_zero_data_31_10_in_sspl === 1'b1)))));
	M_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && byte_8_9_non_reserved_for_routing_by_id === 1'b1)))));

        M_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_bcm_error)))));
	M_PCI_EXPRESS_POISONNED_TLP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(poisonned_tlp)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_more_than_2dw)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_more_than_2dw)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_2dw_non_qw_aligned)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_2dw_non_qw_aligned)))));
	M_PCI_EXPRESS_INVALID_REQ_ID_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_req_id)))));
	M_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_before_init_cfg)))));
	M_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_direction_error)))));
	M_PCI_EXPRESS_INVALID_COMPLETER_ID_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_completer_id)))));
	M_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completer_id_not_0_before_initial_cfg)))));
	M_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_msg_routing_error)))));
	M_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_act_state_nak_msg_routing_error)))));
	M_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_pme_msg_routing_error)))));
	M_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_turnoff_msg_routing_error)))));
	M_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_routing_error)))));
	M_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_msg_routing_error)))));
	M_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_routing_error)))));
	M_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_2ack_msg_routing_error)))));
	M_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_routing_error)))));
	M_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_msg_routing_error)))));
	M_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && intx_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && pm_act_state_nak_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && unlock_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_SSPL_LENGTH_NT_1_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_length_not_1dw === 1'b1)))));
	M_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_err_msg_direction_error)))));
	M_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_err_msg_direction_error)))));
	M_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_err_msg_direction_error)))));
	M_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_direction_error)))));
	M_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_on_msg_direction_error)))));
	M_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_bl_msg_direction_error)))));
	M_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_off_msg_direction_error)))));
	M_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_on_msg_direction_error)))));
	M_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_bl_msg_direction_error)))));
	M_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_off_msg_direction_error)))));
	M_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(at_pressed_msg_direction_error)))));
	M_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_000_from_rc)))));
	M_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_011_from_ep)))));
	M_PCI_EXPRESS_CPL_STATUS_UR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ur)))));
	M_PCI_EXPRESS_CPL_STATUS_CA_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ca)))));
	M_PCI_EXPRESS_CPL_STATUS_CRS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_crs)))));
	M_PCI_EXPRESS_NO_SSPL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_not_sent_error)))));
	M_PCI_EXPRESS_COR_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_error_msg)))));
	M_PCI_EXPRESS_NFT_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_error_msg)))));
	M_PCI_EXPRESS_FT_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_error_msg)))));
	M_PCI_EXPRESS_MRD_LK_TC_NE_0_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mrdlk_req_tc_field_error)))));
	M_PCI_EXPRESS_CPL_LK_TC_NE_0_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_req_tc_field_error)))));
	M_PCI_EXPRESS_LK_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_message_without_lock)))));
	M_PCI_EXPRESS_NO_LK_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(other_than_unlock_n_mrdlk_when_lock_established)))));
	M_PCI_EXPRESS_CPL_LK_ERR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_received_when_lock_not_established)))));
	M_PCI_EXPRESS_TLP_USING_UNINIT_VC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tc_with_uninitialized_vc)))));
	// Additional gen1 code end
	
        M_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_header_field)))));
        M_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_hdr_length_error)))));
        M_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_hdr_length_error)))));
        M_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_hdr_length_error)))));
        M_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_header_length_error)))));
        M_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_pci_express_end_point)))));
        M_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_legacy_end_point)))));
        M_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_legacy_end_point)))));
        M_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_root_complex)))));
        M_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_tc_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_tc_field_error)))));
        M_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_tc_field_error)))));
        M_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_attr_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_attr_field_error)))));
        M_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_attr_field_error)))));
        M_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_length_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_length_field_error)))));
        M_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_field_error)))));
        M_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_non_zero_error)))));
        M_PCI_EXPRESS_LAST_DW_BE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_last_dw_be)))));
        M_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_non_zero_error)))));
        M_PCI_EXPRESS_ECRC_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ecrc_error)))));
        M_PCI_EXPRESS_TAG_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tag_field_error)))));
        M_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(address_format_error)))));
        M_PCI_EXPRESS_INTR_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intr_msg_code_error)))));
        M_PCI_EXPRESS_PME_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_msg_code_error)))));
        M_PCI_EXPRESS_ERR_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_code_error)))));
        M_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_tran_msg_code_error)))));
        M_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_code_error)))));
        M_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_code_error)))));
        M_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_specific_msg_code_error)))));
        M_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_msg_code_group)))));
        M_PCI_EXPRESS_NO_TLP_DIGEST_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_tlp_digest)))));
        M_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_payload_size_error)))));
        M_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_read_req_size_error)))));
        M_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_reserved_field_error && 
                           pw_RESERVED_FIELD_CHECK_ENABLE
                           && TX_INTERFACE == 1)))));
        M_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(illegal_address_length_combination)))));
        M_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_pkt_size_error)))));
        M_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(root_complex_rcvd_cfg_req)))));
        M_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&((cpl_length_field_error || cpl_lk_length_field_error) &&
                           pw_RESERVED_FIELD_CHECK_ENABLE === 1'b1 && 
                           TX_INTERFACE === 1)))));
        M_PCI_EXPRESS_MSG_TYPE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_type_error)))));
        M_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_type_error)))));
        M_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_doesnot_map_to_any_vc)))));
        M_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ignored_message_detected)))));
        M_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_length_field_error && 
                           RESERVED_FIELD_CHECK_ENABLE === 1'b1
                           && TX_INTERFACE === 1)))));
	
	// Additional gen1 code start
	M_PCI_EXPRESS_SLOT_PWR_MSG_BIT_31_10_DATA_PAYLOAD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && non_zero_data_31_10_in_sspl === 1'b1)))));
	M_PCI_EXPRESS_MSG_NOT_ROUTED_BY_ID_BYT8_9_RSVD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(RESERVED_FIELD_CHECK_ENABLE === 1'b1 && byte_8_9_non_reserved_for_routing_by_id === 1'b1)))));
	M_PCI_EXPRESS_COMPLETION_BCM_BIT_SET_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_bcm_error)))));
	M_PCI_EXPRESS_POISONNED_TLP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(poisonned_tlp)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_MT_2DW_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_more_than_2dw)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_MT_2DW_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_more_than_2dw)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_FIRST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_for_2dw_non_qw_aligned)))));
	M_PCI_EXPRESS_NON_CONTIGUOUS_LAST_DW_BE_ERROR_FOR_LEN_EQ_2DW_NON_QW_ALIGNED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_for_2dw_non_qw_aligned)))));
	M_PCI_EXPRESS_INVALID_REQ_ID_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_req_id)))));
	M_PCI_EXPRESS_TLP_BEFORE_INITIAL_CONFIG_WRITE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_before_init_cfg)))));
	M_PCI_EXPRESS_INTX_FROM_DOWNSTREAM_PORT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_direction_error)))));
	M_PCI_EXPRESS_INVALID_COMPLETER_ID_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(invalid_completer_id)))));
	M_PCI_EXPRESS_BUS_DEV_NOT_0_FOR_CPL_BEFORE_INIT_WRITE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completer_id_not_0_before_initial_cfg)))));
	M_PCI_EXPRESS_INTX_MSG_ROUTING_NT_100_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_msg_routing_error)))));
	M_PCI_EXPRESS_PM_ASN_MSG_ROUTING_NT_100_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_act_state_nak_msg_routing_error)))));
	M_PCI_EXPRESS_PM_PME_MSG_ROUTING_NT_000_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_pme_msg_routing_error)))));
	M_PCI_EXPRESS_PM_TO_MSG_ROUTING_NT_011_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_turnoff_msg_routing_error)))));
	M_PCI_EXPRESS_ERR_MSG_ROUTING_NT_000_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_routing_error)))));
	M_PCI_EXPRESS_UNLOCK_MSG_ROUTING_NT_011_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_msg_routing_error)))));
	M_PCI_EXPRESS_SSPL_MSG_ROUTING_NT_100_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_routing_error)))));
	M_PCI_EXPRESS_PME_2_ACK_MSG_ROUTING_NT_101_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_2ack_msg_routing_error)))));
	M_PCI_EXPRESS_HOT_PLUG_MSG_ROUTING_NT_100_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_routing_error)))));
	M_PCI_EXPRESS_VENDOR_MSG_ROUTING_NT_VALID_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_msg_routing_error)))));
	M_PCI_EXPRESS_INTX_MSG_NON_RSVD_FN_NUMBER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intx_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_PM_MSG_NON_RSVD_FN_NUMBER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pm_act_state_nak_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_UNLOCK_MSG_NON_RSVD_FN_NUMBER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_msg_function_num_non_reserved)))));
	M_PCI_EXPRESS_SSPL_LENGTH_NT_1_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_length_not_1dw === 1'b1)))));
	M_PCI_EXPRESS_COR_ERR_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_err_msg_direction_error)))));
	M_PCI_EXPRESS_NON_FATAL_ERR_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_err_msg_direction_error)))));
	M_PCI_EXPRESS_FATAL_ERR_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_err_msg_direction_error)))));
	M_PCI_EXPRESS_SSPL_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_msg_direction_error)))));
	M_PCI_EXPRESS_AI_ON_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_on_msg_direction_error)))));
	M_PCI_EXPRESS_AI_BL_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_bl_msg_direction_error)))));
	M_PCI_EXPRESS_AI_OFF_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ai_off_msg_direction_error)))));
	M_PCI_EXPRESS_PI_ON_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_on_msg_direction_error)))));
	M_PCI_EXPRESS_PI_BL_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_bl_msg_direction_error)))));
	M_PCI_EXPRESS_PI_OFF_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pi_off_msg_direction_error)))));
	M_PCI_EXPRESS_AT_BT_MSG_DIRECTION_INVL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(at_pressed_msg_direction_error)))));
	M_PCI_EXPRESS_MSG_ROUTING_000_FROM_RC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_000_from_rc)))));
	M_PCI_EXPRESS_MSG_ROUTING_011_FROM_EP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_with_routing_011_from_ep)))));
	M_PCI_EXPRESS_CPL_STATUS_UR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ur)))));
	M_PCI_EXPRESS_CPL_STATUS_CA_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_ca)))));
	M_PCI_EXPRESS_CPL_STATUS_CRS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_crs)))));
	M_PCI_EXPRESS_NO_SSPL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(sspl_not_sent_error)))));
	M_PCI_EXPRESS_COR_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 && 		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cor_error_msg)))));
	M_PCI_EXPRESS_NFT_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_fatal_error_msg)))));
	M_PCI_EXPRESS_FT_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(fatal_error_msg)))));
	M_PCI_EXPRESS_MRD_LK_TC_NE_0_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mrdlk_req_tc_field_error)))));
	M_PCI_EXPRESS_CPL_LK_TC_NE_0_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_req_tc_field_error)))));
	M_PCI_EXPRESS_LK_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(unlock_message_without_lock)))));
	M_PCI_EXPRESS_NO_LK_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(other_than_unlock_n_mrdlk_when_lock_established)))));
	M_PCI_EXPRESS_CPL_LK_ERR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpllk_received_when_lock_not_established)))));
	M_PCI_EXPRESS_TLP_USING_UNINIT_VC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && transaction_layer_checks_disable !== 1'b1)
                           &&(tc_with_uninitialized_vc)))));
	// Additional gen1 code end
	
        M_PCI_EXPRESS_UNDEFINED_HEADER_FIELD_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_header_field)))));
        M_PCI_EXPRESS_IO_REQ_HDR_LENGTH_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_hdr_length_error)))));
        M_PCI_EXPRESS_CFG_REQ_HDR_LENGTH_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_hdr_length_error)))));
        M_PCI_EXPRESS_MSG_REQ_HDR_LENGTH_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_hdr_length_error)))));
        M_PCI_EXPRESS_CPL_HEADER_LENGTH_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_header_length_error)))));
        M_PCI_EXPRESS_IO_REQ_PCI_EXPRESS_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CFG_REQ_PCI_EXPRESS_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_pci_express_end_point)))));
        M_PCI_EXPRESS_LOCK_REQ_PCI_EXPRESS_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CPL_LK_REQ_PCI_EXPRESS_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_pci_express_end_point)))));
        M_PCI_EXPRESS_CFG_REQ_LEGACY_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_legacy_end_point)))));
        M_PCI_EXPRESS_LOCK_REQ_LEGACY_END_POINT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lock_req_legacy_end_point)))));
        M_PCI_EXPRESS_CPL_LK_REQ_ROOT_COMPLEX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_lk_req_root_complex)))));
        M_PCI_EXPRESS_IO_REQ_TC_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_tc_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_TC_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_tc_field_error)))));
        M_PCI_EXPRESS_MSG_REQ_TC_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_tc_field_error)))));
        M_PCI_EXPRESS_IO_REQ_ATTR_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_attr_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_ATTR_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_attr_field_error)))));
        M_PCI_EXPRESS_MSG_REQ_ATTR_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_attr_field_error)))));
        M_PCI_EXPRESS_IO_REQ_LENGTH_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(io_req_length_field_error)))));
        M_PCI_EXPRESS_CFG_REQ_LENGTH_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cfg_req_length_field_error)))));
        M_PCI_EXPRESS_CPL_STATUS_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_status_field_error)))));
        M_PCI_EXPRESS_FIRST_DW_BE_NON_ZERO_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(first_dw_be_error_non_zero_error)))));
        M_PCI_EXPRESS_LAST_DW_BE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_last_dw_be)))));
        M_PCI_EXPRESS_LAST_DW_BE_NON_ZERO_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(last_dw_be_error_non_zero_error)))));
        M_PCI_EXPRESS_ECRC_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ecrc_error)))));
        M_PCI_EXPRESS_TAG_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tag_field_error)))));
        M_PCI_EXPRESS_ADDRESS_FORMAT_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(address_format_error)))));
        M_PCI_EXPRESS_INTR_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(intr_msg_code_error)))));
        M_PCI_EXPRESS_PME_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(pme_msg_code_error)))));
        M_PCI_EXPRESS_ERR_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(err_msg_code_error)))));
        M_PCI_EXPRESS_LOCKED_TRAN_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_tran_msg_code_error)))));
        M_PCI_EXPRESS_SLOT_PWR_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_code_error)))));
        M_PCI_EXPRESS_HOT_PLUG_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(hot_plug_msg_code_error)))));
        M_PCI_EXPRESS_VENDOR_SPECIFIC_MSG_CODE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(vendor_specific_msg_code_error)))));
        M_PCI_EXPRESS_UNDEFINED_MSG_CODE_GROUP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(undefined_msg_code_group)))));
        M_PCI_EXPRESS_NO_TLP_DIGEST_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_tlp_digest)))));
        M_PCI_EXPRESS_MAX_PAYLOAD_SIZE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_payload_size_error)))));
        M_PCI_EXPRESS_MAX_READ_REQ_SIZE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(max_read_req_size_error)))));
        M_PCI_EXPRESS_NON_ZERO_RESERVED_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(non_zero_reserved_field_error &&
                           pw_RESERVED_FIELD_CHECK_ENABLE
                           && TX_INTERFACE == 1)))));
        M_PCI_EXPRESS_ILLEGAL_ADDRESS_LENGTH_COMBINATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(illegal_address_length_combination)))));
        M_PCI_EXPRESS_TLP_PKT_SIZE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_pkt_size_error)))));
        M_PCI_EXPRESS_ROOT_COMPLEX_RCVD_CFG_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(root_complex_rcvd_cfg_req)))));
        M_PCI_EXPRESS_CPL_LENGTH_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&((cpl_length_field_error || cpl_lk_length_field_error)
                           &&
                           pw_RESERVED_FIELD_CHECK_ENABLE === 1'b1 &&
                           TX_INTERFACE === 1)))));
        M_PCI_EXPRESS_MSG_TYPE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_type_error)))));
        M_PCI_EXPRESS_SLOT_PWR_MSG_TYPE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(slot_pwr_msg_type_error)))));
        M_PCI_EXPRESS_TLP_DOESNOT_MAP_TO_ANY_VC_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(tlp_doesnot_map_to_any_vc)))));
        M_PCI_EXPRESS_IGNORED_MESSAGE_DETECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(ignored_message_detected)))));
        M_PCI_EXPRESS_MSG_REQ_LENGTH_FIELD_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((reset === 1'b0 && areset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(msg_req_length_field_error &&
                           RESERVED_FIELD_CHECK_ENABLE === 1'b1
                           && TX_INTERFACE === 1)))));
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

`endif //QVL_ASSERT_ON
