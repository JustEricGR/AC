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

  parameter QVL_ERROR = 1; 
  parameter QVL_INFO = 3; 
  parameter QVL_PROPERTY_TYPE = 0; 
  parameter QVL_COVERAGE_LEVEL = 0; 

  parameter QVL_MSG = "QVL_AMBA_AXI_VIOLATION : ";

  //---------------------------------------------------------------------
  // Parameter checks, assert only
  //---------------------------------------------------------------------

        AMBA_AXI_PARAM_WRITE_DATA_BUS_WIDTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable (1'b1),
                          .test_expr (illegal_write_data_bus_width)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"AMBA_AXI_PARAM_WRITE_DATA_BUS_WIDTH"}),
                          .msg            ("WRITE_DATA_BUS_WIDTH parameter should be one of 8, 16, 32, 64, 128, 256, 512 or 1024."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

        AMBA_AXI_PARAM_READ_DATA_BUS_WIDTH:
          assert property ( ASSERT_NEVER_P (
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable (1'b1),
                          .test_expr (illegal_read_data_bus_width)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"AMBA_AXI_PARAM_READ_DATA_BUS_WIDTH"}),
                          .msg            ("READ_DATA_BUS_WIDTH parameter should be one of 8, 16, 32, 64, 128, 256, 512 or 1024."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

`ifdef QVL_XCHECK_OFF
`else // QVL_XCHECK_OFF
  //---------------------------------------------------------------------
  // Known driven checks
  //---------------------------------------------------------------------

  // Master side assert and assume
generate
  case (ZI_CONSTRAINT_MASTER_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_MASTER_ASSERT_NEVER_UNKNOWN 
        A_AMBA_AXI_ARREADY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARREADY_UNKN"}),
                          .msg            ("ARREADY signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_AWREADY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWREADY_UNKN"}),
                          .msg            ("AWREADY signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rvalid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RVALID_UNKN"}),
                          .msg            ("RVALID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_WREADY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WREADY_UNKN"}),
                          .msg            ("WREADY signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_BVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bvalid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BVALID_UNKN"}),
                          .msg            ("BVALID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rid),
                          .qualifier (rvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RID_UNKN"}),
                          .msg            ("RID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_BID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bid),
                          .qualifier (bvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BID_UNKN"}),
                          .msg            ("BID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RLAST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rlast),
                          .qualifier (rvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RLAST_UNKN"}),
                          .msg            ("RLAST signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RRESP_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rresp),
                          .qualifier (rvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RRESP_UNKN"}),
                          .msg            ("RRESP signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_BRESP_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bresp),
                          .qualifier (bvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BRESP_UNKN"}),
                          .msg            ("BRESP signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_CACTIVE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (cactive),
                          .qualifier (LPI_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CACTIVE_UNKN"}),
                          .msg            ("CACTIVE signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_CSYSACK_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (csysack),
                          .qualifier (LPI_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSACK_UNKN"}),
                          .msg            ("CSYSACK signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_MASTER_ASSERT_NEVER_UNKNOWN 
        M_AMBA_AXI_ARREADY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arready),
                          .qualifier (1'b1)));
        M_AMBA_AXI_AWREADY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awready),
                          .qualifier (1'b1)));
        M_AMBA_AXI_RVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rvalid),
                          .qualifier (1'b1)));
        M_AMBA_AXI_WREADY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wready),
                          .qualifier (1'b1)));
        M_AMBA_AXI_BVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bvalid),
                          .qualifier (1'b1)));
        M_AMBA_AXI_RID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rid),
                          .qualifier (rvalid === 1'b1)));
        M_AMBA_AXI_BID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bid),
                          .qualifier (bvalid === 1'b1)));
        M_AMBA_AXI_RLAST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rlast),
                          .qualifier (rvalid === 1'b1)));
        M_AMBA_AXI_RRESP_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rresp),
                          .qualifier (rvalid === 1'b1)));
        M_AMBA_AXI_BRESP_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bresp),
                          .qualifier (bvalid === 1'b1)));
        M_AMBA_AXI_CACTIVE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (cactive),
                          .qualifier (LPI_ENABLE == 1)));
        M_AMBA_AXI_CSYSACK_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (csysack),
                          .qualifier (LPI_ENABLE == 1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_MASTER_ASSERT_NEVER_UNKNOWN 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate


// Slave side assert and assume

generate
  case (ZI_CONSTRAINT_SLAVE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_SLAVE_ASSERT_NEVER_UNKNOWN 
        A_AMBA_AXI_ARVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arvalid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARVALID_UNKN"}),
                          .msg            ("ARVALID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awvalid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWVALID_UNKN"}),
                          .msg            ("AWVALID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_RREADY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RREADY_UNKN"}),
                          .msg            ("RREADY signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WVALID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wvalid),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WVALID_UNKN"}),
                          .msg            ("WVALID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_BREADY_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bready),
                          .qualifier (1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BREADY_UNKN"}),
                          .msg            ("BREADY signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arid),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARID_UNKN"}),
                          .msg            ("ARID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awid),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWID_UNKN"}),
                          .msg            ("AWID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WID_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wid),
                          .qualifier (wvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WID_UNKN"}),
                          .msg            ("WID signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWADDR_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awaddr),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWADDR_UNKN"}),
                          .msg            ("AWADDR bus should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWLEN_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awlen),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWLEN_UNKN"}),
                          .msg            ("AWLEN signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWSIZE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awsize),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWSIZE_UNKN"}),
                          .msg            ("AWSIZE signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWBURST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awburst),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWBURST_UNKN"}),
                          .msg            ("AWBURST signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWLOCK_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awlock),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWLOCK_UNKN"}),
                          .msg            ("AWLOCK signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWCACHE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awcache),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWCACHE_UNKN"}),
                          .msg            ("AWCACHE signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWPROT_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awprot),
                          .qualifier (awvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWPROT_UNKN"}),
                          .msg            ("AWPROT signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARADDR_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (araddr),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARADDR_UNKN"}),
                          .msg            ("ARADDR bus should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARLEN_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arlen),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARLEN_UNKN"}),
                          .msg            ("ARLEN signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARSIZE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arsize),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARSIZE_UNKN"}),
                          .msg            ("ARSIZE signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARBURST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arburst),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARBURST_UNKN"}),
                          .msg            ("ARBURST signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARLOCK_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arlock),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARLOCK_UNKN"}),
                          .msg            ("ARLOCK signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARCACHE_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arcache),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARCACHE_UNKN"}),
                          .msg            ("ARCACHE signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARPROT_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arprot),
                          .qualifier (arvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARPROT_UNKN"}),
                          .msg            ("ARPROT signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WLAST_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wlast),
                          .qualifier (wvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WLAST_UNKN"}),
                          .msg            ("WLAST signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WSTRB_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wstrb),
                          .qualifier (wvalid === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WSTRB_UNKN"}),
                          .msg            ("WSTRB signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_CSYSREQ_UNKN: 
          assert property ( ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (csysreq),
                          .qualifier (LPI_ENABLE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSREQ_UNKN"}),
                          .msg            ("CSYSREQ signal should not be X or Z."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_SLAVE_ASSERT_NEVER_UNKNOWN 
        M_AMBA_AXI_ARVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arvalid),
                          .qualifier (1'b1)));
        M_AMBA_AXI_AWVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awvalid),
                          .qualifier (1'b1)));
        M_AMBA_AXI_RREADY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rready),
                          .qualifier (1'b1)));
        M_AMBA_AXI_WVALID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wvalid),
                          .qualifier (1'b1)));
        M_AMBA_AXI_BREADY_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (bready),
                          .qualifier (1'b1)));
        M_AMBA_AXI_AWID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awid),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_RID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (rid),
                          .qualifier (rvalid === 1'b1)));
        M_AMBA_AXI_WID_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wid),
                          .qualifier (wvalid === 1'b1)));
        M_AMBA_AXI_AWADDR_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awaddr),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWLEN_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awlen),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWSIZE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awsize),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWBURST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awburst),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWLOCK_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awlock),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWCACHE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awcache),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_AWPROT_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (awprot),
                          .qualifier (awvalid === 1'b1)));
        M_AMBA_AXI_ARADDR_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (araddr),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARLEN_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arlen),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARSIZE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arsize),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARBURST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arburst),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARLOCK_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arlock),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARCACHE_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arcache),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_ARPROT_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (arprot),
                          .qualifier (arvalid === 1'b1)));
        M_AMBA_AXI_WLAST_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wlast),
                          .qualifier (wvalid === 1'b1)));
        M_AMBA_AXI_WSTRB_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (wstrb),
                          .qualifier (wvalid === 1'b1)));
        M_AMBA_AXI_CSYSREQ_UNKN: 
          assume property (ASSERT_NEVER_UNKNOWN_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .test_expr (csysreq),
                          .qualifier (LPI_ENABLE == 1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_SLAVE_ASSERT_NEVER_UNKNOWN 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate
`endif // QVL_XCHECK_OFF


  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

  // Master side assert and assume

generate
  case (ZI_CONSTRAINT_MASTER_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_MASTER_ASSERT_NEVER 
        A_AMBA_AXI_EXCLUSIVE_READ_RESPONSE_MISMATCH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (low_power_mode == 1'b0 &&
                           ex_read_resp_does_not_match_expected_resp &&
                           read_address_queue_full == 1'b0 &&
                           (EXCLUSIVE_READ_RESPONSE_CHECKING_ENABLE == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_READ_RESPONSE_MISMATCH"}),
                          .msg            ("The exclusive read response detected should match the expected response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_READ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (response_other_than_okay_and_exokay_for_ex_read) &&
                           (read_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_READ"}),
                          .msg            ("Response for an exclusive read should not be other than OKAY or EXOKAY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_READ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exokay_response_for_non_exclusive_read) &&
                           (read_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_READ"}),
                          .msg            ("An EXOKAY response should not be returned for a normal (non-exclusive) read operation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_EXCLUSIVE_WRITE_RESPONSE_MISMATCH: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (ex_write_resp_does_not_match_expected_resp) &&
                           (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_WRITE_RESPONSE_MISMATCH"}),
                          .msg            ("The exclusive write response detected should match the expected response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_WRITE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (response_other_than_okay_and_exokay_for_ex_write)
                           && (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_WRITE"}),
                          .msg            ("Response for an exclusive write should not be other than OKAY or EXOKAY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_WRITE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exokay_response_for_non_exclusive_write) &&
                           (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_WRITE"}),
                          .msg            ("An EXOKAY response should not be returned for a normal (non-exclusive) write operation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_READ_DATA_BEFORE_ADDRESS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_response_without_corresponding_read_address))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_DATA_BEFORE_ADDRESS"}),
                          .msg            ("Read data transfer should not be performed before the corresponding address."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RVALID_DEASSERTED_BEFORE_RREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_valid_deasserted_before_rready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RVALID_DEASSERTED_BEFORE_RREADY"}),
                          .msg            ("RVALID should be held asserted until the master asserts RREADY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_BVALID_DEASSERTED_BEFORE_BREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wresp_valid_deasserted_before_bready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BVALID_DEASSERTED_BEFORE_BREADY"}),
                          .msg            ("BVALID should be held asserted until the master asserts BREADY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_WRITE_RESPONSE_WITHOUT_ADDR_DATA: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_response_before_corresponding_write_addr_and_data))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_RESPONSE_WITHOUT_ADDR_DATA"}),
                          .msg            ("Write response should not be sent before the corresponding address and write data burst have completed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_WRITE_RESPONSE_WITHOUT_DATA: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_response_before_corresponding_write_data))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_RESPONSE_WITHOUT_DATA"}),
                          .msg            ("Write response should not be sent before the corresponding write data burst have completed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_READ_REORDER_DEPTH_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_reordering_depth_exceeded))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_REORDER_DEPTH_VIOLATION"}),
                          .msg            ("Read data should not be reordered beyond the read data reordering depth."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_READ_INTERLEAVE_DEPTH_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_interleaving_depth_exceeded))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_INTERLEAVE_DEPTH_VIOLATION"}),
                          .msg            ("A new read data burst should not be transferred prior to completion of the previous read burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_READ_BURST_LENGTH_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (read_burst_length_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_BURST_LENGTH_VIOLATION"}),
                          .msg            ("Length of the read burst detected should match the expected length."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RLAST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rlast_not_asserted_on_last_data_phase === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RLAST_VIOLATION"}),
                          .msg            ("RLAST signal should be asserted along with the final transfer of the read data burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_READ_DATA_RESP_CHANGED_BEFORE_RREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_resp_changed_before_rready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_DATA_RESP_CHANGED_BEFORE_RREADY"}),
                          .msg            ("Once RVALID is asserted, read data/response should not change until RREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RID_CHANGED_BEFORE_RREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rid_changed_before_rready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RID_CHANGED_BEFORE_RREADY"}),
                          .msg            ("Once RVALID is asserted, RID should not change until RREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_RLAST_CHANGED_BEFORE_RREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rlast_changed_before_rready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RLAST_CHANGED_BEFORE_RREADY"}),
                          .msg            ("Once RVALID is asserted, RLAST should not change until RREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_WRITE_RESP_CHANGED_BEFORE_BREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_resp_changed_before_bready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_RESP_CHANGED_BEFORE_BREADY"}),
                          .msg            ("Once BVALID is asserted, write response should not change until BREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_BID_CHANGED_BEFORE_BREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (bid_changed_before_bready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_BID_CHANGED_BEFORE_BREADY"}),
                          .msg            ("Once BVALID is asserted, BID should not change until BREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_DECODE_ERROR_RESPONSE_BY_SLAVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((INTERFACE_TYPE == 1)  &&
                           (decode_error_response_on_slave_interface) &&
                           (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_DECODE_ERROR_RESPONSE_BY_SLAVE"}),
                          .msg            ("A slave should not issue DECERR response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_CSYSACK_DEASSERTION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1) && (ack_low_before_req))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSACK_DEASSERTION_VIOLATION"}),
                          .msg            ("Once asserted, CSYSACK should not be deasserted before CSYSREQ is deasserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
        A_AMBA_AXI_CSYSACK_ASSERTION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1) && (ack_high_before_req))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSACK_ASSERTION_VIOLATION"}),
                          .msg            ("CSYSACK should not be asserted before CSYSREQ is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MASTER_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_MASTER_NEVER  
        M_AMBA_AXI_EXCLUSIVE_READ_RESPONSE_MISMATCH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (low_power_mode == 1'b0 &&
                           ex_read_resp_does_not_match_expected_resp &&
                           read_address_queue_full == 1'b0 &&
                           (EXCLUSIVE_READ_RESPONSE_CHECKING_ENABLE == 1))));
        M_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_READ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (response_other_than_okay_and_exokay_for_ex_read) &&
                           (read_address_queue_full == 1'b0))));
        M_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_READ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exokay_response_for_non_exclusive_read) &&
                           (read_address_queue_full == 1'b0))));
        M_AMBA_AXI_EXCLUSIVE_WRITE_RESPONSE_MISMATCH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (ex_write_resp_does_not_match_expected_resp) &&
                           (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))));
        M_AMBA_AXI_ILLEGAL_RESPONSE_EXCLUSIVE_WRITE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (response_other_than_okay_and_exokay_for_ex_write)
                           && (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))));
        M_AMBA_AXI_ILLEGAL_RESPONSE_NORMAL_WRITE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exokay_response_for_non_exclusive_write) &&
                           (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0))));
        M_AMBA_AXI_READ_DATA_BEFORE_ADDRESS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_response_without_corresponding_read_address))));
        M_AMBA_AXI_WVALID_DEASSERTED_BEFORE_WREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_valid_deasserted_before_wready))));
        M_AMBA_AXI_BVALID_DEASSERTED_BEFORE_BREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wresp_valid_deasserted_before_bready))));
        M_AMBA_AXI_WRITE_RESPONSE_WITHOUT_ADDR_DATA: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_response_before_corresponding_write_addr_and_data))));
        M_AMBA_AXI_WRITE_RESPONSE_WITHOUT_DATA: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_response_before_corresponding_write_data))));
        M_AMBA_AXI_READ_REORDER_DEPTH_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_reordering_depth_exceeded))));
        M_AMBA_AXI_READ_INTERLEAVE_DEPTH_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_interleaving_depth_exceeded))));
        M_AMBA_AXI_READ_BURST_LENGTH_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (read_burst_length_violation === 1'b1))));
        M_AMBA_AXI_RLAST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rlast_not_asserted_on_last_data_phase === 1'b1))));
        M_AMBA_AXI_READ_DATA_RESP_CHANGED_BEFORE_RREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_data_resp_changed_before_rready))));
        M_AMBA_AXI_RID_CHANGED_BEFORE_RREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rid_changed_before_rready))));
        M_AMBA_AXI_RLAST_CHANGED_BEFORE_RREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (rlast_changed_before_rready))));
        M_AMBA_AXI_WRITE_RESP_CHANGED_BEFORE_BREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_resp_changed_before_bready))));
        M_AMBA_AXI_BID_CHANGED_BEFORE_BREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (bid_changed_before_bready))));
	M_AMBA_AXI_DECODE_ERROR_RESPONSE_BY_SLAVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((INTERFACE_TYPE == 1)  &&
                           (decode_error_response_on_slave_interface) &&
                           (low_power_mode == 1'b0))));
        M_AMBA_AXI_CSYSACK_DEASSERTION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1) && (ack_low_before_req))));
        M_AMBA_AXI_CSYSACK_ASSERTION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1) && (ack_high_before_req))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_MASTER_ASSERT_NEVER 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate


  // Slave side assert and assume
generate
  case (ZI_CONSTRAINT_SLAVE_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_SLAVE_ASSERT_NEVER 
        A_AMBA_AXI_ARVALID_DEASSERTED_BEFORE_ARREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (araddr_valid_deasserted_before_arready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARVALID_DEASSERTED_BEFORE_ARREADY"}),
                          .msg            ("ARVALID should be held asserted until the slave asserts ARREADY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ADDR_FOR_READ_BURST_ACROSS_4K_BOUNDARY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_issued_for_burst_crossing_4k_boundary))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ADDR_FOR_READ_BURST_ACROSS_4K_BOUNDARY"}),
                          .msg            ("The read address/control signals issued should not result in data access across a 4K boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_READ_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (illegal_length_for_wrapping_read_bursts))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_READ_BURST"}),
                          .msg            ("Burst length for a wrapping read burst should be 2, 4, 8 or 16."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_READ_BURST_SIZE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_issued_has_burst_size_larger_than_bus_width))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_BURST_SIZE_VIOLATION"}),
                          .msg            ("Read burst size should not exceed the data bus width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_RESERVED_READ_BURST_TYPE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (read_burst_type_field_with_reserved_value === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RESERVED_READ_BURST_TYPE"}),
                          .msg            ("Read burst type encoding should not be a reserved value of 2'b11."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_RESERVED_ARLOCK_ENCODING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (read_lock_field_with_reserved_encoding) &&
                           (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RESERVED_ARLOCK_ENCODING"}),
                          .msg            ("The reserved encoding of 2'b11 should not be used for ARLOCK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_READ_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_wrapping_read_bursts))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_READ_BURST"}),
                          .msg            ("Starting address of a wrapping read burst should be aligned to the size of the transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_READ_ALLOCATE_WHEN_NON_CACHEABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_allocate_attribute_set_for_non_cacheable_read_access))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_ALLOCATE_WHEN_NON_CACHEABLE"}),
                          .msg            ("Read allocate bit of a read address should not be HIGH when the cacheable bit is LOW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_READ_ACCESS_CACHEABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           cacheable_exclusive_read_access &&
                           low_power_mode == 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_READ_ACCESS_CACHEABLE"}),
                          .msg            ("An exclusive read access should not have the cacheable attribute set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_READ_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (read_addr_within_locked_seq_across_4k_boundary == 1'b1)
                           && (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_READ_SEQUENCE"}),
                          .msg            ("Transactions within a locked read sequence should be within the same 4K boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARID_CHANGED_WITHIN_LOCKED_READ_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (arid_changed_within_locked_read_sequence))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARID_CHANGED_WITHIN_LOCKED_READ_SEQUENCE"}),
                          .msg            ("All transactions within a locked read sequence should have the same ARID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ARPROT_ARCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (arprot_or_arcache_changed_within_locked_read_sequence == 1)
                           && (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ARPROT_ARCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE"}),
                          .msg            ("It is recommended that a master should not change ARPROT or ARCACHE during a sequence of locked accesses."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_READ_ADDR_CNTRL_CHANGED_BEFORE_ARREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (read_addr_cntrl_changed_before_arready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_ADDR_CNTRL_CHANGED_BEFORE_ARREADY"}),
                          .msg            ("Once ARVALID is asserted, the read address/control signals {araddr,arlen,arsize,arburst,arlock,arcache,arprot,arid} should not change until ARREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_NUMBER_OF_LOCKED_READ_ACCESSES_EXCEEDS_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (num_commands_in_locked_read_sequence_exceeds_2 == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_NUMBER_OF_LOCKED_READ_ACCESSES_EXCEEDS_2"}),
                          .msg            ("Number of accesses within a locked read sequence should not be more than 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_LOCKED_READ_BEFORE_COMPLETION_OF_PREVIOUS_READS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (locked_read_sequence_when_unresponded_reads))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_LOCKED_READ_BEFORE_COMPLETION_OF_PREVIOUS_READS"}),
                          .msg            ("A locked read sequence should not commence before completion of all previously issued read addresses."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_read_sequence_when_unresponded_reads))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS"}),
                          .msg            ("Unlocking read transaction is detected while there is a locked read sequence outstanding issued with the same ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS_DIFFERENT_ID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_read_sequence_when_unresponded_reads_different_id))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS_DIFFERENT_ID"}),
                          .msg            ("Unlocking read transaction is detected while there is a locked read sequence outstanding issued with a different ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_READ: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_exclusive_read_access))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_READ"}),
                          .msg            ("The start address of an exclusive read should be aligned to the total number of bytes in the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_READ_SIZE_NON_POWER_OF_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_read_access_size_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_READ_SIZE_NON_POWER_OF_2"}),
                          .msg            ("The number of bytes transferred in an exclusive read access should be a power of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_READ_SIZE_EXCEEDS_128: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_read_access_max_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_READ_SIZE_EXCEEDS_128"}),
                          .msg            ("The number of bytes transferred in an exclusive read burst should not exceed 128."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_READ_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_before_completion_of_unlocking_read_transaction))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_READ_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION"}),
                          .msg            ("The unlocking transaction of a locked read sequence should be completed before further transactions are initiated."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWVALID_DEASSERTED_BEFORE_AWREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (awaddr_valid_deasserted_before_awready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWVALID_DEASSERTED_BEFORE_AWREADY"}),
                          .msg            ("AWVALID should be held asserted until the slave asserts AWREADY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ADDR_FOR_WRITE_BURST_ACROSS_4K_BOUNDARY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_issued_for_burst_crossing_4k_boundary))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ADDR_FOR_WRITE_BURST_ACROSS_4K_BOUNDARY"}),
                          .msg            ("The write address/control signals issued should not result in data access across a 4K boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_WRITE_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (illegal_length_for_wrapping_write_bursts))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_WRITE_BURST"}),
                          .msg            ("Burst length for a wrapping write burst should be 2, 4, 8 or 16."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_BURST_SIZE_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_issued_has_burst_size_larger_than_bus_width))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_BURST_SIZE_VIOLATION"}),
                          .msg            ("Write burst size should not exceed the data bus width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_RESERVED_WRITE_BURST_TYPE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (write_burst_type_field_with_reserved_value === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RESERVED_WRITE_BURST_TYPE"}),
                          .msg            ("Write burst type encoding should not be a reserved value of 2'b11."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_RESERVED_AWLOCK_ENCODING: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (write_lock_field_with_reserved_encoding===1'b1) &&
                           (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_RESERVED_AWLOCK_ENCODING"}),
                          .msg            ("The reserved encoding of 2'b11 should not be used for AWLOCK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_WRITE_BURST: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_wrapping_write_bursts))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_WRITE_BURST"}),
                          .msg            ("Starting address of a wrapping write burst should be aligned to the size of the transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_ALLOCATE_WHEN_NON_CACHEABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_allocate_attribute_set_for_non_cacheable_write_access))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_ALLOCATE_WHEN_NON_CACHEABLE"}),
                          .msg            ("Write allocate bit for a write address should not be HIGH when the cacheable bit is LOW."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_WRITE_ACCESS_CACHEABLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           cacheable_exclusive_write_access &&
                           low_power_mode == 1'b0 )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_WRITE_ACCESS_CACHEABLE"}),
                          .msg            ("An exclusive write access should not have the cacheable attribute set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_WRITE_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (write_addr_within_locked_seq_across_4k_boundary == 1)
                           && (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_WRITE_SEQUENCE"}),
                          .msg            ("Transactions within a locked write sequence should be within the same 4K boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWID_CHANGED_WITHIN_LOCKED_WRITE_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (awid_changed_within_locked_write_sequence))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWID_CHANGED_WITHIN_LOCKED_WRITE_SEQUENCE"}),
                          .msg            ("All transactions within a locked write sequence should have the same AWID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_AWPROT_AWCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (awprot_or_awcache_changed_within_locked_write_sequence))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_AWPROT_AWCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE"}),
                          .msg            ("It is recommended that a master should not change AWPROT or AWCACHE during a sequence of locked accesses."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_ADDR_CNTRL_CHANGED_BEFORE_AWREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_cntrl_changed_before_awready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_ADDR_CNTRL_CHANGED_BEFORE_AWREADY"}),
                          .msg            ("Once AWVALID is asserted, the write address/control signals {awaddr,awlen,awsize,awburst,awlock,awcache,awprot,awid} should not change until AWREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_NUMBER_OF_LOCKED_WRITE_ACCESSES_EXCEEDS_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (num_commands_in_locked_write_sequence_exceeds_2 == 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_NUMBER_OF_LOCKED_WRITE_ACCESSES_EXCEEDS_2"}),
                          .msg            ("Number of accesses within a locked write sequence should not be more than 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_LOCKED_WRITE_BEFORE_COMPLETION_OF_PREVIOUS_WRITES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (locked_write_sequence_when_unresponded_writes))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_LOCKED_WRITE_BEFORE_COMPLETION_OF_PREVIOUS_WRITES"}),
                          .msg            ("A locked write sequence should not commence before completion of all previously issued write addresses."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_write_sequence_when_unresponded_writes))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES"}),
                          .msg            ("Unlocking write transaction is detected while there is a locked write sequence outstanding issued with the same ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES_DIFFERENT_ID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_write_sequence_when_unresponded_writes_different_id))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES_DIFFERENT_ID"}),
                          .msg            ("Unlocking write transaction is detected while there is a locked write sequence outstanding issued with a different ID."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_WRITE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_exclusive_write_access))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_WRITE"}),
                          .msg            ("The start address of an exclusive write should be aligned to the total number of bytes in the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_NON_POWER_OF_2: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_write_access_size_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_NON_POWER_OF_2"}),
                          .msg            ("The number of bytes transferred in an exclusive write access should be a power of 2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_EXCEEDS_128: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_write_access_max_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_EXCEEDS_128"}),
                          .msg            ("The number of bytes transferred in an exclusive write burst should not exceed 128."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_before_completion_of_unlocking_write_transaction))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION"}),
                          .msg            ("The unlocking transaction of a locked write sequence should be completed before further transactions are initiated."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WLAST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wlast_not_asserted_on_last_data_phase))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WLAST_VIOLATION"}),
                          .msg            ("WLAST signal should be asserted along with the final transfer of the write data burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WVALID_DEASSERTED_BEFORE_WREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_valid_deasserted_before_wready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WVALID_DEASSERTED_BEFORE_WREADY"}),
                          .msg            ("WVALID should be held asserted until the slave asserts WREADY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EXCLUSIVE_ACCESS_ADDRESS_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (INTERFACE_TYPE == 1 &&
                           EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           ex_write_with_no_addr_being_monitored_for_given_awid
                           && low_power_mode == 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EXCLUSIVE_ACCESS_ADDRESS_VIOLATION"}),
                          .msg            ("The address and control signals of an exclusive write should be identical to that of the exclusive read."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_strobe_asserted_for_invalid_byte_lanes)
                           && (write_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES"}),
                          .msg            ("Write data strobes should not be asserted for byte lanes that do not contain valid data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_STROBE_FIXED_BURST_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (data_on_different_byte_lanes_for_fixed_burst) &&
                           (write_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_STROBE_FIXED_BURST_VIOLATION"}),
                          .msg            ("Valid data should remain on the same byte lanes for all transfers of a fixed burst."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_EX_WRITE_BEFORE_EX_READ_RESPONSE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((EXCLUSIVE_ACCESS_ENABLE == 1) &&
                           (ex_write_before_response_for_corresponding_ex_read)
                           && (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0) &&
                           (low_power_mode == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_EX_WRITE_BEFORE_EX_READ_RESPONSE"}),
                          .msg            ("An exclusive write access should not be performed until the previously issued exclusive read has been responded."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_INTERLEAVE_DEPTH_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_interleaving_depth_exceeded))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_INTERLEAVE_DEPTH_VIOLATION"}),
                          .msg            ("Write data bursts should not be interleaved beyond the write interleaving depth."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_DATA_BEFORE_ADDRESS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((CHECK_WRITE_DATA_FOLLOWS_ADDR_ENABLE == 1) &&
                           (low_power_mode == 1'b0) &&
                           (write_data_burst_before_corresponding_address == 1)
                           && (write_address_queue_full == 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_DATA_BEFORE_ADDRESS"}),
                          .msg            ("Write data should not be transferred before the corresponding address."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_BURST_LENGTH_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_burst_length_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_BURST_LENGTH_VIOLATION"}),
                          .msg            ("Length of the write burst detected should match the expected length."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_DATA_STROBE_CHANGED_BEFORE_WREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_strobe_changed_before_wready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_DATA_STROBE_CHANGED_BEFORE_WREADY"}),
                          .msg            ("Once WVALID is asserted, write data/strobe should not change until WREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WID_CHANGED_BEFORE_WREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wid_changed_before_wready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WID_CHANGED_BEFORE_WREADY"}),
                          .msg            ("Once WVALID is asserted, WID should not change until WREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WLAST_CHANGED_BEFORE_WREADY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wlast_changed_before_wready))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WLAST_CHANGED_BEFORE_WREADY"}),
                          .msg            ("Once WVALID is asserted, WLAST should not change until WREADY is asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_VALID_HIGH_ON_FIRST_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((INTERFACE_TYPE == 0) &&
                           (low_power_mode == 1'b0) &&
                           (valid_on_first_clock_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_VALID_HIGH_ON_FIRST_CLOCK"}),
                          .msg            ("A master interface should not drive ARVALID, AWVALID OR WVALID on the first rising edge of ACLK after ARESET_n."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_ADDRESS_PHASE_WHILE_MAXIMUM_OUTSTANDING_WRITES_ALREADY_REACHED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0)  &&
                           (write_address_phase_while_maximum_outstanding_writes_already_reached))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_ADDRESS_PHASE_WHILE_MAXIMUM_OUTSTANDING_WRITES_ALREADY_REACHED"}),
                          .msg            ("Write address phase should not occur while maximum allowed outstanding write transactions are already waiting for response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_WRITE_DATA_PHASE_WHILE_MAXIMUM_OUTSTANDING_WRITES_ALREADY_REACHED:
          assert property ( ASSERT_NEVER_P (
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0)  &&
                           (write_data_phase_while_maximum_outstanding_writes_already_reached))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_WRITE_DATA_PHASE_WHILE_MAXIMUM_OUTSTANDING_WRITES_ALREADY_REACHED"}),
                          .msg            ("Write data phase should not occur while maximum allowed outstanding write transactions are already waiting for response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_CSYSREQ_ASSERTION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1)  && (req_high_before_ack))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSREQ_ASSERTION_VIOLATION"}),
                          .msg            ("Once deasserted, CSYSREQ should not be asserted before CSYSACK acknowledged the request for entry into low power state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
        A_AMBA_AXI_CSYSREQ_DEASSERTION_VIOLATION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1)  && (req_low_before_ack))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_AMBA_AXI_CSYSREQ_DEASSERTION_VIOLATION"}),
                          .msg            ("CSYSREQ should not be deasserted to indicate new request for entry to low power state even before the previous exit from low power state was acknowledged."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_SLAVE_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_SLAVE_ASSERT_NEVER 
        M_AMBA_AXI_ARVALID_DEASSERTED_BEFORE_ARREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (araddr_valid_deasserted_before_arready))));
        M_AMBA_AXI_ADDR_FOR_READ_BURST_ACROSS_4K_BOUNDARY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_issued_for_burst_crossing_4k_boundary))));
        M_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_READ_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (illegal_length_for_wrapping_read_bursts))));
        M_AMBA_AXI_READ_BURST_SIZE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_issued_has_burst_size_larger_than_bus_width))));
        M_AMBA_AXI_RESERVED_READ_BURST_TYPE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (read_burst_type_field_with_reserved_value === 1'b1))));
        M_AMBA_AXI_RESERVED_ARLOCK_ENCODING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (read_lock_field_with_reserved_encoding) &&
                           (low_power_mode == 1'b0))));
        M_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_READ_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_wrapping_read_bursts))));
        M_AMBA_AXI_READ_ALLOCATE_WHEN_NON_CACHEABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_allocate_attribute_set_for_non_cacheable_read_access))));
        M_AMBA_AXI_EXCLUSIVE_READ_ACCESS_CACHEABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           cacheable_exclusive_read_access &&
                           low_power_mode == 1'b0)));
        M_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_READ_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (read_addr_within_locked_seq_across_4k_boundary == 1'b1)
                           && (low_power_mode == 1'b0))));
        M_AMBA_AXI_ARID_CHANGED_WITHIN_LOCKED_READ_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (arid_changed_within_locked_read_sequence))));
        M_AMBA_AXI_ARPROT_ARCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (arprot_or_arcache_changed_within_locked_read_sequence == 1)
                           && (low_power_mode == 1'b0))));
        M_AMBA_AXI_READ_ADDR_CNTRL_CHANGED_BEFORE_ARREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (read_addr_cntrl_changed_before_arready))));
        M_AMBA_AXI_NUMBER_OF_LOCKED_READ_ACCESSES_EXCEEDS_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (num_commands_in_locked_read_sequence_exceeds_2 == 1))));
        M_AMBA_AXI_LOCKED_READ_BEFORE_COMPLETION_OF_PREVIOUS_READS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (locked_read_sequence_when_unresponded_reads))));
        M_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_read_sequence_when_unresponded_reads))));
        M_AMBA_AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS_DIFFERENT_ID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_read_sequence_when_unresponded_reads_different_id))));
        M_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_READ: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_exclusive_read_access))));
        M_AMBA_AXI_EXCLUSIVE_READ_SIZE_NON_POWER_OF_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_read_access_size_violation))));
        M_AMBA_AXI_EXCLUSIVE_READ_SIZE_EXCEEDS_128: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_read_access_max_violation))));
        M_AMBA_AXI_READ_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (read_addr_before_completion_of_unlocking_read_transaction))));
        M_AMBA_AXI_AWVALID_DEASSERTED_BEFORE_AWREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (awaddr_valid_deasserted_before_awready))));
        M_AMBA_AXI_ADDR_FOR_WRITE_BURST_ACROSS_4K_BOUNDARY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_issued_for_burst_crossing_4k_boundary))));
        M_AMBA_AXI_ILLEGAL_LENGTH_WRAPPING_WRITE_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (illegal_length_for_wrapping_write_bursts))));
        M_AMBA_AXI_WRITE_BURST_SIZE_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_issued_has_burst_size_larger_than_bus_width))));
        M_AMBA_AXI_RESERVED_WRITE_BURST_TYPE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (write_burst_type_field_with_reserved_value === 1'b1))));
        M_AMBA_AXI_RESERVED_AWLOCK_ENCODING: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RESERVED_VALUE_CHECKING == 1) &&
                           (write_lock_field_with_reserved_encoding===1'b1) &&
                           (low_power_mode == 1'b0))));
        M_AMBA_AXI_UNALIGNED_ADDR_FOR_WRAPPING_WRITE_BURST: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_wrapping_write_bursts))));
        M_AMBA_AXI_WRITE_ALLOCATE_WHEN_NON_CACHEABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_allocate_attribute_set_for_non_cacheable_write_access))));
        M_AMBA_AXI_EXCLUSIVE_WRITE_ACCESS_CACHEABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           cacheable_exclusive_write_access &&
                           low_power_mode == 1'b0 )));
        M_AMBA_AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_WRITE_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (write_addr_within_locked_seq_across_4k_boundary == 1)
                           && (low_power_mode == 1'b0))));
        M_AMBA_AXI_AWID_CHANGED_WITHIN_LOCKED_WRITE_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) && 
                           (awid_changed_within_locked_write_sequence))));
        M_AMBA_AXI_AWPROT_AWCACHE_CHANGED_WITHIN_LOCKED_SEQUENCE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (awprot_or_awcache_changed_within_locked_write_sequence))));
        M_AMBA_AXI_WRITE_ADDR_CNTRL_CHANGED_BEFORE_AWREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_cntrl_changed_before_awready))));
        M_AMBA_AXI_NUMBER_OF_LOCKED_WRITE_ACCESSES_EXCEEDS_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((ENABLE_RECOMMENDATION_CHECKING == 1) &&
                           (low_power_mode == 1'b0) &&
                           (num_commands_in_locked_write_sequence_exceeds_2 == 1))));
        M_AMBA_AXI_LOCKED_WRITE_BEFORE_COMPLETION_OF_PREVIOUS_WRITES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (locked_write_sequence_when_unresponded_writes))));
        M_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_write_sequence_when_unresponded_writes))));
        M_AMBA_AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES_DIFFERENT_ID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unlocking_write_sequence_when_unresponded_writes_different_id))));
        M_AMBA_AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_WRITE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (unaligned_starting_addr_for_exclusive_write_access))));
        M_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_NON_POWER_OF_2: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_write_access_size_violation))));
        M_AMBA_AXI_EXCLUSIVE_WRITE_SIZE_EXCEEDS_128: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (exclusive_write_access_max_violation))));
        M_AMBA_AXI_WRITE_ADDR_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_addr_before_completion_of_unlocking_write_transaction))));
        M_AMBA_AXI_WLAST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wlast_not_asserted_on_last_data_phase))));
        M_AMBA_AXI_WVALID_DEASSERTED_BEFORE_WREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_valid_deasserted_before_wready))));
        M_AMBA_AXI_EXCLUSIVE_ACCESS_ADDRESS_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr (INTERFACE_TYPE == 1 &&
                           EXCLUSIVE_ACCESS_ENABLE == 1 &&
                           ex_write_with_no_addr_being_monitored_for_given_awid
                           && low_power_mode == 1'b0)));
        M_AMBA_AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_strobe_asserted_for_invalid_byte_lanes)
                           && (write_address_queue_full == 1'b0))));
        M_AMBA_AXI_WRITE_STROBE_FIXED_BURST_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (data_on_different_byte_lanes_for_fixed_burst) &&
                           (write_address_queue_full == 1'b0))));
        M_AMBA_AXI_EX_WRITE_BEFORE_EX_READ_RESPONSE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((EXCLUSIVE_ACCESS_ENABLE == 1) &&
                           (ex_write_before_response_for_corresponding_ex_read)
                           && (write_address_queue_full == 1'b0) &&
                           (read_address_queue_full == 1'b0) &&
                           (low_power_mode == 1'b0))));
        M_AMBA_AXI_WRITE_INTERLEAVE_DEPTH_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_interleaving_depth_exceeded))));
        M_AMBA_AXI_WRITE_DATA_BEFORE_ADDRESS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((CHECK_WRITE_DATA_FOLLOWS_ADDR_ENABLE == 1) &&
                           (low_power_mode == 1'b0) &&
                           (write_data_burst_before_corresponding_address == 1)
                           && (write_address_queue_full == 1'b0))));
        M_AMBA_AXI_WRITE_BURST_LENGTH_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_burst_length_violation))));
        M_AMBA_AXI_WRITE_DATA_STROBE_CHANGED_BEFORE_WREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (write_data_strobe_changed_before_wready))));
        M_AMBA_AXI_WID_CHANGED_BEFORE_WREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wid_changed_before_wready))));
        M_AMBA_AXI_WLAST_CHANGED_BEFORE_WREADY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((low_power_mode == 1'b0) &&
                           (wlast_changed_before_wready))));
        M_AMBA_AXI_VALID_HIGH_ON_FIRST_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((INTERFACE_TYPE == 0) &&
                           (low_power_mode == 1'b0) &&
                           (valid_on_first_clock_violation))));
        M_AMBA_AXI_CSYSREQ_ASSERTION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1)  && (req_high_before_ack))));
        M_AMBA_AXI_CSYSREQ_DEASSERTION_VIOLATION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (aclk ),
                          .reset_n   (areset_n & reset_n ),
                          .enable    (1'b1),
                          .test_expr ((LPI_ENABLE == 1)  && (req_low_before_ack))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_SLAVE_ASSERT_NEVER 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate
`endif // QVL_ASSERT_ON
