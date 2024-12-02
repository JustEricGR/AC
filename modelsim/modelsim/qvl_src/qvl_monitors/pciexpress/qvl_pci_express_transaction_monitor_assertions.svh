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
  parameter QVL_COVERAGE_LEVEL = 0; // {32{1'b1}}; //`OVL_COVER_NONE;

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// assert only checks

// GEN2 assertions
      generate
	if( PCI_EXPRESS_GEN2 == 1)
	  begin : qvl_assert_PCI_EXPRESS_GEN2
	    // Assertions with positive clock
	    A_ASSERT_NEVER_PCI_EXPRESS_GEN2_TX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (tx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_tx)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_PCI_EXPRESS_GEN2_TX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_P"}),
                              .msg            ("The completion for requests having ACS violation should have completion status as completion abort(CA)."),
                              .severity_level (QVL_ERROR),
                              .property_type  (1'b0));
	    
	    // Assertions with negative clock
	    A_ASSERT_NEVER_PCI_EXPRESS_GEN2_TX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_tx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
	    		   DOUBLE_DATA_RATE === 1 &&		
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_tx)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_PCI_EXPRESS_GEN2_TX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_N"}),
                              .msg            ("The completion for requests having ACS violation should have completion status as completion abort(CA)."),
                              .severity_level (QVL_ERROR),
                              .property_type  (1'b0));
	  end  
      endgenerate

      // Additional gen1 code start 
      generate
	// assertion for completion timeout
	genvar g2;
	for( g2 = 0; g2 < MAX_REQUESTS; g2 = g2 + 1)
	  begin : rx_cpl_timer_out
	    A_PCI_EXPRESS_RX_COMPLETION_TIMEOUT_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (tx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && tx_cpl_timeout_counter[g2] >= CPL_TIMEOUT_CLK)))))
	      else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_TIMEOUT_P"}),
                              .msg            ("Completion not received"),
                              .severity_level (QVL_ERROR),
                              .property_type  (1'b0));
	    A_PCI_EXPRESS_RX_COMPLETION_TIMEOUT_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_tx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			       DOUBLE_DATA_RATE === 1 &&  		    
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && tx_cpl_timeout_counter[g2] >= CPL_TIMEOUT_CLK)))))
	      else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_TIMEOUT_N"}),
                              .msg            ("Completion not received"),
                              .severity_level (QVL_ERROR),
                              .property_type  (1'b0));
	  end 
      endgenerate
        A_PCI_EXPRESS_COMPLETION_FOR_UR_NE_UR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_ur_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLETION_FOR_UR_NE_UR_P"}),
                          .msg            ("Completion status for unsupported request should be UR."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_COMPLETION_FOR_UR_NE_UR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&  		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_ur_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COMPLETION_FOR_UR_NE_UR_N"}),
                          .msg            ("Completion status for unsupported request should be UR."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_NOT_UR_FOR_POISONNED_IO_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NOT_URFOR_POISONNED_IO_WRITE_P"}),
                          .msg            ("Completion with UR should be generated for received poisonned IO Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_TX_NOT_UR_FOR_POISONNED_IO_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NOT_URFOR_POISONNED_IO_WRITE_N"}),
                          .msg            ("Completion with UR should be generated for received poisonned IO Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_NOT_UR_FOR_POISONNED_CFG_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NOT_URFOR_POISONNED_CFG_WRITE_P"}),
                          .msg            ("Completion with UR should be generated for received poisonned CFG Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_TX_NOT_UR_FOR_POISONNED_CFG_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NOT_URFOR_POISONNED_CFG_WRITE_N"}),
                          .msg            ("Completion with UR should be generated for received poisonned CFG Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));     
        A_PCI_EXPRESS_TX_MRD_CPL_LOW_ADDR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_MRD_CPL_LOW_ADDR_P"}),
                          .msg            ("For transmitted MRD completion lower address field must indicates lower bits of byte address for the first enabled byte of data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_MRD_CPL_LOW_ADDR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_MRD_CPL_LOW_ADDR_N"}),
                          .msg            ("For transmitted MRD completion lower address field must indicates lower bits of byte address for the first enabled byte of data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_P"}),
                          .msg            ("The transmitted completion for received flush request must specify a length of 1 DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_N"}),
                          .msg            ("The transmitted completion for received flush request must specify a length of 1 DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_TLP_NON_UNIQUE_TAG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_tx_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_TLP_NON_UNIQUE_TAG_P"}),
                          .msg            ("Tag should be unique for every non posted request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_TLP_NON_UNIQUE_TAG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_tx_req_negedge)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_TLP_NON_UNIQUE_TAG_N"}),
                          .msg            ("Tag should be unique for every non posted request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_RD_CPL_WITHOUT_DATA_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_RD_CPL_WITHOUT_DATA_P"}),
                          .msg            ("All read completion should have data when completion status is SC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_RD_CPL_WITHOUT_DATA_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_RD_CPL_WITHOUT_DATA_N"}),
                          .msg            ("All read completion should have data when completion status is SC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CFG1_CPL_NE_UR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (type1_cfg_not_ur)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG1_CPL_NE_UR_P"}),
                          .msg            ("PCIEXPRESS Endpoint must treat type1 configuration request as an unsupported request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CFG1_CPL_NE_UR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&			
                           transaction_layer_checks_disable !== 1'b1) &&
                           (type1_cfg_not_ur)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CFG1_CPL_NE_UR_N"}),
                          .msg            ("PCIEXPRESS Endpoint must treat type1 configuration request as an unsupported request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));     
      // Additional gen1 code end   

        A_PCI_EXPRESS_TX_COMPLETION_WITHOUT_REQUEST_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1) &&
                           (completion_without_request_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_WITHOUT_REQUEST_P"}),
                          .msg            ("Completion transmitted without a request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_COMPLETION_TC_ATTR_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_TC_ATTR_MISMATCH_P"}),
                          .msg            ("Transmitted completions should have the same value for TC and ATTR fields of the associated requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_STATUS_CSR_FOR_NONCFG_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_csr_for_non_cfg_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_STATUS_CSR_FOR_NONCFG_REQ_P"}),
                          .msg            ("The completion status CRS should not be returned for requests other than configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_P"}),
                          .msg            ("Illegal completion for I/O and configuration write requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPLD_FOR_UNSUCCESFUL_CPL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_FOR_UNSUCCESFUL_CPL_P"}),
                          .msg            ("Unsuccessful completions should not contain datapayload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LK_FOR_NON_LOCKED_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LK_FOR_NON_LOCKED_REQ_P"}),
                          .msg            ("Locked completions should be responded to only locked requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_BYTE_COUNT_VALUE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_BYTE_COUNT_VALUE_ERROR_P"}),
                          .msg            ("Completions for I/O and configuration requests should have a value of 4 in the byte count field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_P"}),
                          .msg            ("CplLK completions must be returned to locked memory requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LWR_ADDRESS_VALUE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LWR_ADDRESS_VALUE_ERROR_P"}),
                          .msg            ("Lower address field must be set to zero for all completions except for memory read completion."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_COMPLETION_WITHOUT_REQUEST_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_without_request_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_WITHOUT_REQUEST_N"}),
                          .msg            ("Completion transmitted without a request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_COMPLETION_TC_ATTR_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_TC_ATTR_MISMATCH_N"}),
                          .msg            ("Transmitted completions should have the same value for TC and ATTR fields of the associated requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_STATUS_CSR_FOR_NONCFG_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_csr_for_non_cfg_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_STATUS_CSR_FOR_NONCFG_REQ_N"}),
                          .msg            ("The completion status CRS should not be returned for requests other than configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_N"}),
                          .msg            ("Illegal completion for I/O and configuration write requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPLD_FOR_UNSUCCESFUL_CPL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPLD_FOR_UNSUCCESFUL_CPL_N"}),
                          .msg            ("Unsuccessful completions should not contain data payload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LK_FOR_NON_LOCKED_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LK_FOR_NON_LOCKED_REQ_N"}),
                          .msg            ("Locked completions should be responded to only locked requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_BYTE_COUNT_VALUE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_BYTE_COUNT_VALUE_ERROR_N"}),
                          .msg            ("Completions for I/O and configuration requests should have a value of 4 in the byte count field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_N"}),
                          .msg            ("CplLK completions must be returned to locked memory requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TX_CPL_LWR_ADDRESS_VALUE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_tx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_CPL_LWR_ADDRESS_VALUE_ERROR_N"}),
                          .msg            ("Lower address field must be set to zero for all completions except for memory read completion."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 

// Checks with Constraints_Mode          

generate
  genvar g3;
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER

// GEN2 assertions
	if( PCI_EXPRESS_GEN2 == 1)
	  begin : qvl_assert_PCI_EXPRESS_GEN2_PROPERTY_TYPE
	    // Assertions with positive clock
	    A_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_rx)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_P"}),
                              .msg            ("The completion for requests having ACS violation should have completion status as completion abort(CA)."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    
	    // Assertions with negative clock
	    A_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
	    		   DOUBLE_DATA_RATE === 1 &&		
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_rx)))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_N"}),
                              .msg            ("The completion for requests having ACS violation should have completion status as completion abort(CA)."),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	  end 
     // Additional gen1 code start
	// assertion for completion timeout
	for( g3 = 0; g3 < MAX_REQUESTS; g3 = g3 + 1)
	  begin : assert_tx_cpl_timer_out
	    A_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_P: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && rx_cpl_timeout_counter[g3] >= CPL_TIMEOUT_CLK)))))
	      else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_P"}),
                              .msg            ("Completion not transmitted"),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	    A_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_N: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (not_rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			       DOUBLE_DATA_RATE === 1 &&  		    
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && rx_cpl_timeout_counter[g3] >= CPL_TIMEOUT_CLK)))))
	      else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_N"}),
                              .msg            ("Completion not transmitted"),
                              .severity_level (QVL_ERROR),
                              .property_type  (Constraints_Mode));
	  end 
	A_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_P"}),
                          .msg            ("For received MRD completion lower address field must indicates lower bits of byte address for the first enabled byte of data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_N"}),
                          .msg            ("For received MRD completion lower address field must indicates lower bits of byte address for the first enabled byte of data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_IO_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NOT_URFOR_POISONNED_IO_WRITE_P"}),
                          .msg            ("Completion with UR should be received for transmitted poisonned IO Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode)); 
        A_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_IO_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NOT_URFOR_POISONNED_IO_WRITE_N"}),
                          .msg            ("Completion with UR should be received for transmitted poisonned IO Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_CFG_WRITE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NOT_URFOR_POISONNED_CFG_WRITE_P"}),
                          .msg            ("Completion with UR should be received for transmitted poisonned CFG0 Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode)); 
        A_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_CFG_WRITE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NOT_URFOR_POISONNED_CFG_WRITE_N"}),
                          .msg            ("Completion with UR should be received for transmitted poisonned CFG Write request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_P"}),
                          .msg            ("The received completion for flush request must specify a length of 1 DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_N"}),
                          .msg            ("The received completion for flush request must specify a length of 1 DW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_rx_req)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_P"}),
                          .msg            ("Tag should be unique for every non posted request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_rx_req_negedge)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_N"}),
                          .msg            ("Tag should be unique for every non posted request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
	A_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_P"}),
                          .msg            ("All read completion should have data when completion status is SC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_N"}),
                          .msg            ("All read completion should have data when completion status is SC."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
    // Additional gen1 code end
	
	A_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(dll_status === 1'b0 &&(|tx_valid_req_reg !== 1'b0 ||
                           |rx_valid_req_reg !== 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_P"}),
                          .msg            ("Link is deactivated when there are pending requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(dll_status === 1'b0 &&(|tx_valid_req_reg !== 1'b0 ||
                           |rx_valid_req_reg !== 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_N"}),
                          .msg            ("Link is deactivated when there are pending requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_without_request_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_P"}),
                          .msg            ("Completion received without transmitting a request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_P"}),
                          .msg            ("Completions should have the same value for TC and ATTR fields of the associated requests transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_csr_for_non_cfg_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_P"}),
                          .msg            ("The completion status CRS should not be returned for requests other than configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_P"}),
                          .msg            ("Illegal completion for I/O and configuration write requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_P"}),
                          .msg            ("Unsuccessful completions should not contain data payload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_P"}),
                          .msg            ("Locked completions should be responded to only locked requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_P"}),
                          .msg            ("Completions for I/O and configuration requests should have a value of 4 in the byte count field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_P"}),
                          .msg            ("CplLK completions must be returned to locked memory requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_P"}),
                          .msg            ("Lower address field must be set to zero for all completions except for memory read completion."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_without_request_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_N"}),
                          .msg            ("Completion received without transmitting a request."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_N"}),
                          .msg            ("Completions should have the same value for TC and ATTR fields of the associated requests transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_csr_for_non_cfg_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_N"}),
                          .msg            ("The completion status CRS should not be returned for requests other than configuration requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_N"}),
                          .msg            ("Illegal completion for I/O and configuration write requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_N"}),
                          .msg            ("Unsuccessful completions should not contain data payload."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_N"}),
                          .msg            ("Locked completions should be responded to only locked requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_N"}),
                          .msg            ("Completions for I/O and configuration requests should have a value of 4 in the byte count field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_N"}),
                          .msg            ("CplLK completions must be returned to locked memory requests."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_rx)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_N"}),
                          .msg            ("Lower address field must be set to zero for all completions except for memory read completion."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER

// GEN2 assume
	if( PCI_EXPRESS_GEN2 == 1)
	  begin : qvl_assume_PCI_EXPRESS_GEN2_PROPERTY_TYPE
	    // Assertions with positive clock
	    M_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_rx)))));
	    
	    // Assertions with negative clock
	    M_ASSERT_NEVER_PCI_EXPRESS_GEN2_RX_CPL_STATUS_NON_CA_FOR_ACS_VIOLATED_REQ_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
	    		   DOUBLE_DATA_RATE === 1 &&		
                               transaction_layer_checks_disable !== 1'b1)
                               &&(cpl_not_ca_for_acs_violated_mem_req_rx)))));
	  end 
     // Additional gen1 code start    	     
	  for( g3 = 0; g3 < MAX_REQUESTS; g3 = g3 + 1)
	  begin : assume_tx_cpl_timer_out
	    M_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_P: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && rx_cpl_timeout_counter[g3] >= CPL_TIMEOUT_CLK)))));
	    M_PCI_EXPRESS_TX_COMPLETION_TIMEOUT_N: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (not_rx_clk),
                              .reset_n   (~areset && ~reset),
                              .enable    (1'b1),
                              .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			       DOUBLE_DATA_RATE === 1 &&  		    
                               transaction_layer_checks_disable !== 1'b1) &&
                               ((PCI_EXPRESS_GEN2 === 0 || disable_cpl_timeout === 1'b0) && rx_cpl_timeout_counter[g3] >= CPL_TIMEOUT_CLK)))));
	  end 
	
	M_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_rx)))));
        M_PCI_EXPRESS_RX_MRD_CPL_LOW_ADDR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_lower_byte_error_rx)))));
	M_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_IO_WRITE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_rx)))));
        M_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_IO_WRITE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_io_write_req_rx)))));
	M_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_CFG_WRITE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_rx)))));
        M_PCI_EXPRESS_RX_NOT_UR_FOR_POISONNED_CFG_WRITE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_not_ur_for_poisonned_cfg_write_req_rx)))));
	M_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_rx)))));
        M_PCI_EXPRESS_RX_CPL_LEN_NT_1DW_FOR_FLUSH_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_length_not_1dw_for_flush_req_rx)))));
	M_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_rx_req)))));
        M_PCI_EXPRESS_RX_TLP_NON_UNIQUE_TAG_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (|non_unique_tag_in_non_posted_rx_req_negedge)))));
	M_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_rx)))));
        M_PCI_EXPRESS_RX_RD_CPL_WITHOUT_DATA_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
			   DOUBLE_DATA_RATE === 1 &&		
                           transaction_layer_checks_disable !== 1'b1) &&
                           (rd_cpl_without_data_rx)))));
     // Additional gen1 code end
	
        M_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(dll_status === 1'b0 &&(|tx_valid_req_reg !== 1'b0 ||
                           |rx_valid_req_reg !== 1'b0))))));
        M_PCI_EXPRESS_LINK_DOWN_PENDING_REQUESTS_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(dll_status === 1'b0 &&(|tx_valid_req_reg !== 1'b0 ||
                           |rx_valid_req_reg !== 1'b0))))));
        M_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_without_request_rx)))));
        M_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_rx)))));
        M_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_csr_for_non_cfg_req_rx)))));
        M_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_rx)))));
        M_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_rx)))));
        M_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_rx)))));
        M_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_rx)))));
        M_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_rx)))));
        M_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_rx)))));
        M_PCI_EXPRESS_RX_COMPLETION_WITHOUT_REQUEST_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_without_request_rx)))));
        M_PCI_EXPRESS_RX_COMPLETION_TC_ATTR_MISMATCH_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1)
                           &&(mismatch_tc_attr_in_cpl_rx)))));
        M_PCI_EXPRESS_RX_CPL_STATUS_CSR_FOR_NONCFG_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&
                           transaction_layer_checks_disable !== 1'b1) &&
                           (cpl_csr_for_non_cfg_req_rx)))));
        M_PCI_EXPRESS_RX_CPLD_CPL_FOR_IO_CFG_WRITE_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 &&	
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_io_cfg_write_rx)))));
        M_PCI_EXPRESS_RX_CPLD_FOR_UNSUCCESFUL_CPL_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(completion_cpld_for_unsuccesful_cpl_rx)))));
        M_PCI_EXPRESS_RX_CPL_LK_FOR_NON_LOCKED_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(locked_cpl_for_non_locked_req_rx)))));
        M_PCI_EXPRESS_RX_CPL_BYTE_COUNT_VALUE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(cpl_byte_count_value_error_rx)))));
        M_PCI_EXPRESS_RX_NO_LOCKED_COMPLETION_FOR_LOCKED_REQ_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(no_locked_completion_for_locked_req_rx)))));
        M_PCI_EXPRESS_RX_CPL_LWR_ADDRESS_VALUE_ERROR_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           transaction_layer_checks_disable !== 1'b1)
                           &&(lwr_address_value_error_rx)))));
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
