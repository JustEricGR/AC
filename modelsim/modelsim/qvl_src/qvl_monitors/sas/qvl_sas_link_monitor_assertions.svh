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

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_mode; // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SAS_VIOLATION : ";

  wire not_clk = ~clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_SAS_IDLE_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           ((cominit_idle_time_violation && r_cominit_seq) ||
                           (comsas_idle_time_violation && r_comsas_seq)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IDLE_COUNT_VIOLATION_P"}),
                          .msg            ("Idle time violation during reset sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ADDR_FRAME_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (addr_frame_type_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ADDR_FRAME_TYPE_VIOLATION_P"}),
                          .msg            ("Address Frame Type field in the Address Frame should have the value 0h or 1h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IAF_DEV_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (iaf_device_type_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IAF_DEV_TYPE_VIOLATION_P"}),
                          .msg            ("Device Type field in the Identification Address Frame should be 1h, 2h or 3h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IAF_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (iaf_max_frame_size_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IAF_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("Identification Address Frame should contain 32 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_PROTOCOL_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_protocol_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_PROTOCOL_VIOLATION_P"}),
                          .msg            ("Protocol field in the Open Address Frame should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_FEATURE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_feature_field_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_FEATURE_VIOLATION_P"}),
                          .msg            ("Feature field in the Open Address Frame should be set to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_LINK_RATE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_link_rate_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_LINK_RATE_VIOLATION_P"}),
                          .msg            ("Link Rate field in the Open Address Frame should be 0h or 1h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_max_frame_size_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("Open Address Frame should contain 32 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CONNECTION_TAG_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_conn_tag_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CONNECTION_TAG_VIOLATION_P"}),
                          .msg            ("For a SMP initiator the connection tag field of an open address frame should be ffffh."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (TRANSPORT_LAYER_CHECKS_ENABLE ===  1 &&
                           smp_req_frame_type_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_P"}),
                          .msg            ("The Information Unit Type field in the SMP request should be 40h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_FUNCTION_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_fn_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_FUNCTION_VIOLATION_P"}),
                          .msg            ("Illegal function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_phy_operation_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_P"}),
                          .msg            ("Illegal phy operation field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_prog_min_phy_rate_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_P"}),
                          .msg            ("Program minimun phy rate field in the SMP request should have the values 8h or 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_prog_max_phy_rate_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_P"}),
                          .msg            ("Program maximum phy rate field in the SMP request should have the values 8h or 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_FRAME_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_frame_type_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_FRAME_TYPE_VIOLATION_P"}),
                          .msg            ("The Information Unit Type field in the SMP response should be 41h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_FUNCTION_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_fn_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_FUNCTION_VIOLATION_P"}),
                          .msg            ("Illegal function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_route_attr_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_P"}),
                          .msg            ("Routing attribute field in the SMP DISCOVER response should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_attached_dev_type_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_P"}),
                          .msg            ("Attached device type field in the SMP response should have the values 0h, 1h or 2h or 3h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_fn_result_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_P"}),
                          .msg            ("Illegal Function Result field in the SMP response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_cur_phy_rate_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_P"}),
                          .msg            ("Current physical link rate field in the SMP DISCOVER response should have the values 0h, 1h, 2h, 3h, 8h or 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_RES_FN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_res_fn_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_RES_FN_VIOLATION_P"}),
                          .msg            ("Function field in the SMP request and response should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_task_atribute_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_P"}),
                          .msg            ("Task Attribute field in the command frame should have the values 0h, 1h, 2h or 4h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_task_man_fn_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_P"}),
                          .msg            ("Illegal task management function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_DATA_PRES_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_pres_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_DATA_PRES_VIOLATION_P"}),
                          .msg            ("DATAPRES field in the response frame should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_RESPONSE_STATUS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (status_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_RESPONSE_STATUS_VIOLATION_P"}),
                          .msg            ("Illegal status field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_PHY_IDENTIFIER_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (phy_identifier_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_PHY_IDENTIFIER_VIOLATION_P"}),
                          .msg            ("Phy identifier value should be less than or equal to 80h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FIS_TYPE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (fis_type_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FIS_TYPE_VIOLATION_P"}),
                          .msg            ("FIS type field in the REPORT PHY SATA response should have the value 34h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SENSE_LENGTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sense_length_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SENSE_LENGTH_VIOLATION_P"}),
                          .msg            ("Sense data list length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESPONSE_LENGTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (response_length_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESPONSE_LENGTH_VIOLATION_P"}),
                          .msg            ("Response data list length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESPONSE_LIST_LENGTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (response_list_length_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESPONSE_LIST_LENGTH_VIOLATION_P"}),
                          .msg            ("Response data list length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sense_list_length_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_P"}),
                          .msg            ("Sense data list length should be set to a non zero value if DATAPRES field is set to 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RETRANSMIT_BIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (retransmit_bit_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RETRANSMIT_BIT_VIOLATION_P"}),
                          .msg            ("Retransmit bit should be set to zero for COMMAND, TASK and XFERRDY frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("CLOSE primitive should be detected 3 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BREAK_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (break_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BREAK_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("BREAK primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BROADCAST_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (change_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BROADCAST_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("Broadcast primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_HARD_RESET_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hard_rst_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HARD_RESET_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("HARD RESET primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_xrdy_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA XRDY primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_wtrm_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA WTRM primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_sync_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA SYNC primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rrdy_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA RRDY primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_ROK_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rok_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_ROK_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA ROK primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RERR_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rerr_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RERR_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA RERR primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_hold_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA HOLD primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_holda_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA HOLDA primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RIP_PRIMITIVE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rip_prim_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RIP_PRIMITIVE_VIOLATION_P"}),
                          .msg            ("SATA RIP primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CRC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (crc_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CRC_VIOLATION_P"}),
                          .msg            ("Invalid CRC detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EXPANDER_AIP_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (aip_xmtd_by_non_expander)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EXPANDER_AIP_VIOLATION_P"}),
                          .msg            ("Non expander device should not transmit an AIP primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (primitive_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_P"}),
                          .msg            ("Illegal Primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (stp_hold_holda_dword_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_P"}),
                          .msg            ("HOLD should be acknowledged with HOLDA primitive within 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_AIP_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_aip_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_AIP_PRIMITIVE_P"}),
                          .msg            ("Reserved AIP primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_BROADCAST_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_broadcast_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_BROADCAST_PRIMITIVE_P"}),
                          .msg            ("Reserved BROADCAST primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_CLOSE_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_close_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_CLOSE_PRIMITIVE_P"}),
                          .msg            ("Reserved CLOSE primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_NOTIFY_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_notify_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_NOTIFY_PRIMITIVE_P"}),
                          .msg            ("Reserved NOTIFY primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_OPEN_REJ_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_opn_rej_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_OPEN_REJ_PRIMITIVE_P"}),
                          .msg            ("Reserved OPEN REJECT primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_DONE_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_done_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_DONE_PRIMITIVE_P"}),
                          .msg            ("Reserved DONE primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_NAK_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_nak_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_NAK_PRIMITIVE_P"}),
                          .msg            ("Reserved NAK primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_RRDY_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_rrdy_primitive)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_RRDY_PRIMITIVE_P"}),
                          .msg            ("Reserved RRDY primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (done_prim_in_smp_stp)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_P"}),
                          .msg            ("DONE primitive should not be detected in SMP or STP transactions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_pathway_block_from_non_expander_device)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_P"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(PATHWAY BLOCKED)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_bad_des_not_by_expander_device)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_P"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(BAD DESTINATION)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_no_des_not_from_expander)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_P"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(NO DESTINATION)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (frame_with_crc_err_without_nak)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_P"}),
                          .msg            ("Frames with CRC error should be acknowledged with a NAK primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_MORE_THAN_3CONSECUTIVE_AIP_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (more_than_3consecutive_aip)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_MORE_THAN_3CONSECUTIVE_AIP_P"}),
                          .msg            ("No more than 3 consecutive AIP primitives should be detected without an intermediate idle dword."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_AIP_DWORD_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (aip_dword_count_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_AIP_DWORD_COUNT_VIOLATION_P"}),
                          .msg            ("AIP primitives should be detected once in every 128 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN_DWORD_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (align_dword_count_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN_DWORD_COUNT_VIOLATION_P"}),
                          .msg            ("ALIGN primitives should be detected once in every 2048 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (stp_align_dword_count_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_P"}),
                          .msg            ("Two consecutive ALIGN primitives should be detected once every 256 dwords in a STP initiator port."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ACK_NAK_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ack_nak_timeout_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ACK_NAK_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Frames should be acknowledged within the time specified by the parameter ACK_NAK_TIMEOUT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CREDIT_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (credit_timeout_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CREDIT_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Port which accepts an OPEN address frame should send atleast one RRDY primitive within the time specified by the parameter CREDIT_TIMEOUT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_min_frame_size_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("Observed frame size for the current frame type is less than the expected minimum frame size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_max_frame_size_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_P"}),
                          .msg            ("Observed frame size for the current frame type is greater than the expected maximum frame size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FOUR_BYTE_ALIGN_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (four_byte_align_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FOUR_BYTE_ALIGN_VIOLATION_P"}),
                          .msg            ("All frames should contain integral number of dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SOAF_WITHOUT_EOAF_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (soaf_det === 1'b1 && soaf_detected)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SOAF_WITHOUT_EOAF_P"}),
                          .msg            ("SOAF primitive is detected without an EOAF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_UNKNOWN_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (next_state === ZI_UNKNOWN_STATE)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_UNKNOWN_P"}),
                          .msg            ("State machine entered into unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_HOTPLUG_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hotplug_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HOTPLUG_TIMEOUT_VIOLATION_P"}),
                          .msg            ("The device should not transmit another INIT sequence while waiting for cominit sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_HARD_RESET_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hard_reset_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HARD_RESET_VIOLATION_P"}),
                          .msg            ("After detecting hard reset, no data should be transmitted within the time specified by the parameter HARD_RESET_PERIOD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_timeout_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Close timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EOF_DETECTED_WITHOUT_SOF_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_detect === 1'b0 && eof_det == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EOF_DETECTED_WITHOUT_SOF_P"}),
                          .msg            ("EOF occured without SOF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SOF_DETECTED_WITHOUT_EOF_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_detect === 1'b1 && sof_det == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SOF_DETECTED_WITHOUT_EOF_P"}),
                          .msg            ("SOF occured without EOF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (no_frame_after_done === 1'b1 && sof_det === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_P"}),
                          .msg            ("Frames should not be transmitted after DONE primitive is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_affliation_prim_count_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_P"}),
                          .msg            ("When detected, three consecutive CLOSE_AFFILIATION primitives must be detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (waiting_for_ack_nak === 1'b1 && sof_det === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_P"}),
                          .msg            ("Interlocked frames should not be transmitted again without getting an ACK or NAK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((wtrm_received === 1'b0 &&
                           (r_ok_det || r_err_det) &&
                           wtrm === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_P"}),
                          .msg            ("R_OK/R_ERR primitive should be transmitted only after receiving WTRM primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (credit_count === 0 &&
                           sof_det_received === 1'b1 &&
                           next_state !== ZI_SMP_WAIT_FOR_REQ_STATE &&
                           next_state !== ZI_SMP_WAIT_FOR_RES_STATE)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_P"}),
                          .msg            ("Frame received without credit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_sof_det === 1'b1 &&
                           sata_xrdy_transmitted === 1'b0 &&
                           sata_rrdy_rcvd === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY"}),
                          .msg            ("FIS transmitted without exchange of XRDY and RRDY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (xferrdy_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P"}),
                          .msg            ("Xferrdy frame not receiving ACK or NAK should be closed by DONE(ACK/NAK-TIMEOUT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P"}),
                          .msg            ("DATA frame not receiving ACK or NAK should be closed by DONE(ACK/NAK-TIMEOUT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN0_PRIMITIVE_EXPECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN0_PRIMITIVE_EXPECTED_P"}),
                          .msg            ("ALIGN0 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN1_PRIMITIVE_EXPECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN1_PRIMITIVE_EXPECTED_P"}),
                          .msg            ("ALIGN1 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN2_PRIMITIVE_EXPECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN2_PRIMITIVE_EXPECTED_P"}),
                          .msg            ("ALIGN2 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN3_PRIMITIVE_EXPECTED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align3_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align2_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN3_PRIMITIVE_EXPECTED_P"}),
                          .msg            ("ALIGN3 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (frame_transmitted === 1'b0 &&
                           (ack_det_received || nak_det_received) &&
                           (present_state === ZI_WAIT_COMMAND_ACK_STATE ||
                           present_state === ZI_WAIT_TASK_ACK_STATE ||
                           present_state === ZI_WAIT_SSP_RES_ACK_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_P"}),
                          .msg            ("Device should not send ACK or NAK without receiving a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (xferrdy_received === 1'b0 &&
                           info_unit_type === 8'h01 && data_sent === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_P"}),
                          .msg            ("Initiator should not send DATA frame without receiving XFERRDY frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_TARGET_PORT_XFER_TAG_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tgt_prt_xfer_tag_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TARGET_PORT_XFER_TAG_VIOLATION_P"}),
                          .msg            ("SSP initiator port should set the target port transfer tag field to 16'hffff for all the SSP frames except data frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_ssp_connection)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_P"}),
                          .msg            ("Illegal primitive detected in a SSP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_smp_connection)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_P"}),
                          .msg            ("Illegal primitive detected in a SMP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_stp_connection)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_P"}),
                          .msg            ("Illegal primitive detected in a STP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_outside_connection)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_P"}),
                          .msg            ("Illegal primitive detected outside the connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_RESPONSE_CODE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_res_code_err)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_RESPONSE_CODE_VIOLATION_P"}),
                          .msg            ("Response code field in the SSP response frame should have the values 8'h0, 8'h02, 8'h04, 8'h05, 8'h08 or 8'h09."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_INVALID_FRAME_TYPE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_ssp_frame_type === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_INVALID_FRAME_TYPE_P"}),
                          .msg            ("Illegal SSP frame type detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EXPANDER_ERROR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (error_xmtd_by_non_expander)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EXPANDER_ERROR_VIOLATION_P"}),
                          .msg            ("Non Expander device should not transmit an ERROR primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BREAK_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (break_timeout_count == break_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BREAK_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Break timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_addr_res_timeout_count === 
                           open_addr_res_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Response to open address request should be received within 1 ms."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_COMSAS_TIMEOUT__VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (comsas_timeout_count === ZI_COMSAS_TIMEOUT_COUNT)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_COMSAS_TIMEOUT__VIOLATION_P"}),
                          .msg            ("Device transmitting COMSAS sequence should receive a COMSAS sequence within the specified time out period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ident_timeout_count === ident_frame_timeout)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Device transmitting identification address frame should receive the same within the specified time out period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DONE_TIMEOUT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (done_timeout_violation)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DONE_TIMEOUT_VIOLATION_P"}),
                          .msg            ("Done timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IDLE_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           ((cominit_idle_time_violation && r_cominit_seq) ||
                           (comsas_idle_time_violation && r_comsas_seq)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IDLE_COUNT_VIOLATION_N"}),
                          .msg            ("Idle time violation during reset sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ADDR_FRAME_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (addr_frame_type_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ADDR_FRAME_TYPE_VIOLATION_N"}),
                          .msg            ("Address Frame Type field in the Address Frame should have the values 0h or 1h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IAF_DEV_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (iaf_device_type_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IAF_DEV_TYPE_VIOLATION_N"}),
                          .msg            ("Device Type field in the Identification Address Frame should be 1h, 2h or 3h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IAF_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (iaf_max_frame_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IAF_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("Identification Address Frame should contain 32 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_PROTOCOL_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_protocol_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_PROTOCOL_VIOLATION_N"}),
                          .msg            ("Protocol field in the Open Address Frame should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_FEATURE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_feature_field_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_FEATURE_VIOLATION_N"}),
                          .msg            ("Feature field in the Open Address Frame should be set to zero."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_LINK_RATE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_link_rate_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_LINK_RATE_VIOLATION_N"}),
                          .msg            ("Link Rate field in the Open Address Frame should be 0h or 1h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OAF_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_max_frame_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OAF_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("Open Address Frame should contain 32 bytes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CONNECTION_TAG_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_conn_tag_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CONNECTION_TAG_VIOLATION_N"}),
                          .msg            ("For a SMP initiator the connection tag field of an open address frame should be ffffh."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1)) &&
                           (smp_req_frame_type_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_N"}),
                          .msg            ("The Information Unit Type field in the SMP request should be 40h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_FUNCTION_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_fn_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_FUNCTION_VIOLATION_N"}),
                          .msg            ("Illegal function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_phy_operation_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_N"}),
                          .msg            ("Illegal phy operation field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_prog_min_phy_rate_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_N"}),
                          .msg            ("Program minimun phy rate field in the SMP request should have the values 8h or 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_prog_max_phy_rate_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_N"}),
                          .msg            ("Program maximum phy rate field in the SMP request should have the values 8h or 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES__FRAME_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_frame_type_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES__FRAME_TYPE_VIOLATION_N"}),
                          .msg            ("The Information Unit Type field in the SMP response should be 41h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_FUNCTION_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_fn_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_FUNCTION_VIOLATION_N"}),
                          .msg            ("Illegal function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_fn_result_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_N"}),
                          .msg            ("Illegal Function Result field in the SMP response."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_route_attr_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_N"}),
                          .msg            ("Routing attribute field in the SMP DISCOVER response should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_attached_dev_type_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_N"}),
                          .msg            ("Attached device type field in the SMP response should have the values 0h, 1h or 2h or 3h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_cur_phy_rate_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_N"}),
                          .msg            ("Current physical link rate field in the SMP DISCOVER response should have the values 0h, 1h, 2h, 3h, 8h and 9h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SMP_REQ_RES_FN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_res_fn_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SMP_REQ_RES_FN_VIOLATION_N"}),
                          .msg            ("Function field in the SMP request and response should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (ssp_task_atribute_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_N"}),
                          .msg            ("Task Attribute field in the command frame should have the values 0h, 1h, 2h or 4h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (ssp_task_man_fn_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_N"}),
                          .msg            ("Illegal task management function field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_DATA_PRES_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (data_pres_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_DATA_PRES_VIOLATION_N"}),
                          .msg            ("DATAPRES field in the response frame should have the values 0h, 1h or 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_RESPONSE_STATUS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (status_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_RESPONSE_STATUS_VIOLATION_N"}),
                          .msg            ("Illegal status field."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_PHY_IDENTIFIER_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (phy_identifier_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_PHY_IDENTIFIER_VIOLATION_N"}),
                          .msg            ("Phy identifier value should be less than or equal to 80h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FIS_TYPE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (fis_type_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FIS_TYPE_VIOLATION_N"}),
                          .msg            ("FIS type field in the REPORT PHY SATA response should have the value 34h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SENSE_LENGTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (sense_length_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SENSE_LENGTH_VIOLATION_N"}),
                          .msg            ("Sense data list length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESPONSE_LENGTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (response_length_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESPONSE_LENGTH_VIOLATION_N"}),
                          .msg            ("Response data list length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESPONSE_LIST_LENGTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (response_list_length_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESPONSE_LIST_LENGTH_VIOLATION_N"}),
                          .msg            ("Response data li st length should be set to zero if the DATAPRES field is set to no data."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (sense_list_length_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_N"}),
                          .msg            ("Sense data list length should be set to a non zero value if DATAPRES field is set to 2h."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RETRANSMIT_BIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (retransmit_bit_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RETRANSMIT_BIT_VIOLATION_N"}),
                          .msg            ("Retransmit bit should be set to zero for COMMAND, TASK and XFERRDY frames."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("CLOSE primitive should be detected 3 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BREAK_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (break_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BREAK_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("BREAK primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BROADCAST_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (change_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BROADCAST_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("Broadcast primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_HARD_RESET_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hard_rst_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HARD_RESET_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("HARD RESET primitive should be detected 6 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_xrdy_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA XRDY primitive should be detdcted 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_wtrm_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA WTRM primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_sync_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA SYNC primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rrdy_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA RRDY primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_ROK_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rok_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_ROK_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA ROK primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RERR_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rerr_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RERR_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA RERR primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_hold_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA HOLD primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_holda_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA HOLDA primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SATA_RIP_PRIMITIVE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rip_prim_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SATA_RIP_PRIMITIVE_VIOLATION_N"}),
                          .msg            ("SATA RIP primitive should be detected 2 times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CRC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (crc_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CRC_VIOLATION_N"}),
                          .msg            ("Invalid CRC detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EXPANDER_AIP_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (aip_xmtd_by_non_expander))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EXPANDER_AIP_VIOLATION_N"}),
                          .msg            ("Non expander device should not transmit an AIP primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (primitive_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_N"}),
                          .msg            ("Illegal Primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (stp_hold_holda_dword_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_N"}),
                          .msg            ("HOLD should be acknowledged with HOLDA primitive within 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_AIP_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_aip_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_AIP_PRIMITIVE_N"}),
                          .msg            ("Reserved AIP primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_BROADCAST_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_broadcast_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_BROADCAST_PRIMITIVE_N"}),
                          .msg            ("Reserved BROADCAST primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_CLOSE_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_close_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_CLOSE_PRIMITIVE_N"}),
                          .msg            ("Reserved CLOSE primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_NOTIFY_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_notify_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_NOTIFY_PRIMITIVE_N"}),
                          .msg            ("Reserved NOTIFY primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_OPEN_REJ_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_opn_rej_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_OPEN_REJ_PRIMITIVE_N"}),
                          .msg            ("Reserved OPEN REJECT primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_DONE_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_done_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_DONE_PRIMITIVE_N"}),
                          .msg            ("Reserved DONE primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_NAK_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_nak_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_NAK_PRIMITIVE_N"}),
                          .msg            ("Reserved NAK primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_RESERVED_RRDY_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_rrdy_primitive))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_RESERVED_RRDY_PRIMITIVE_N"}),
                          .msg            ("Reserved RRDY primitive detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (done_prim_in_smp_stp))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_N"}),
                          .msg            ("DONE primitive should not be detected in SMP or STP transactions."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_pathway_block_from_non_expander_device))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_N"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(PATHWAY BLOCK)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_bad_des_not_by_expander_device))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_N"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(BAD DESTINATION)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_no_des_not_from_expander))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_N"}),
                          .msg            ("A non expander device should not transmit OPEN REJECT(NO DESTINATION)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (frame_with_crc_err_without_nak))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_N"}),
                          .msg            ("Frames with CRC error should be acknowledged with a NAK primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_MORE_THAN_3CONSECUTIVE_AIP_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (more_than_3consecutive_aip))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_MORE_THAN_3CONSECUTIVE_AIP_N"}),
                          .msg            ("No more than 3 consecutive AIP primitives should be detected without an intermediate idle dword."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_AIP_DWORD_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (aip_dword_count_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_AIP_DWORD_COUNT_VIOLATION_N"}),
                          .msg            ("AIP primitives should be detected once in every 128 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN_DWORD_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (align_dword_count_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN_DWORD_COUNT_VIOLATION_N"}),
                          .msg            ("ALIGN primitives should be detected once in every 2048 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (stp_align_dword_count_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_N"}),
                          .msg            ("Two consecutive ALIGN primitives should be detected once every 256 dwords in a STP initiator port."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ACK_NAK_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ack_nak_timeout_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ACK_NAK_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Frames should be acknowledged within the time specified by the parameter ACK_NAK_TIMEOUT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CREDIT_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (credit_timeout_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CREDIT_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Port which accepts an OPEN address frame should send atleast one RRDY primitive within the time specified by the parameter CREDIT_TIMEOUT."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_min_frame_size_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("Observed frame size for the current frame type is less than the specified minimum frame size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_max_frame_size_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_N"}),
                          .msg            ("Observed frame size for the current frame type is greater than the specified maximum frame size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FOUR_BYTE_ALIGN_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (four_byte_align_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FOUR_BYTE_ALIGN_VIOLATION_N"}),
                          .msg            ("All frames should contain integral number of dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SOAF_WITHOUT_EOAF_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (soaf_det === 1'b1 && soaf_detected))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SOAF_WITHOUT_EOAF_N"}),
                          .msg            ("SOAF primitive is detected without an EOAF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_UNKNOWN_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (next_state === ZI_UNKNOWN_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_UNKNOWN_N"}),
                          .msg            ("State machine entered into unknown state."),
                          .severity_level (QVL_INFO),
                          .property_type  (QVL_PROPERTY_TYPE));
        A_SAS_HOTPLUG_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hotplug_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HOTPLUG_TIMEOUT_VIOLATION_N"}),
                          .msg            ("The device should not transmit another INIT sequence while waiting for cominit sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_HARD_RESET_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hard_reset_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_HARD_RESET_VIOLATION_N"}),
                          .msg            ("After detecting hard reset, no data should be transmitted within the time specified by the parameter HARD_RESET_PERIOD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_timeout_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Close timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EOF_DETECTED_WITHOUT_SOF_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sof_detect === 1'b0 && eof_det == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EOF_DETECTED_WITHOUT_SOF_N"}),
                          .msg            ("EOF occured without SOF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SOF_DETECTED_WITHOUT_EOF_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sof_detect === 1'b1 && sof_det == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SOF_DETECTED_WITHOUT_EOF_N"}),
                          .msg            ("SOF occured without EOF."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (no_frame_after_done === 1'b1 && sof_det === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_N"}),
                          .msg            ("Frames should not be transmitted after DONE primitive is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_affliation_prim_count_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_N"}),
                          .msg            ("When detected, three consecutive CLOSE_AFFILIATION primitives must be detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (waiting_for_ack_nak === 1'b1 && sof_det === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_N"}),
                          .msg            ("Interlocked frames should not be transmitted again without getting an ACK or NAK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (wtrm_received === 1'b0 &&
                           (r_ok_det || r_err_det) &&
                           wtrm === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_N"}),
                          .msg            ("R_OK/R_ERR primitive should be transmitted only after receiving WTRM primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (credit_count === 0 && sof_det_received === 1'b1 &&
                           next_state !== ZI_SMP_WAIT_FOR_REQ_STATE &&
                           next_state !== ZI_SMP_WAIT_FOR_RES_STATE))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_N"}),
                          .msg            ("Frame received without credit."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_sof_det === 1'b1 &&
                           sata_xrdy_transmitted === 1'b0 &&
                           sata_rrdy_rcvd === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY_N"}),
                          .msg            ("FIS transmitted without exchange of XRDY and RRDY."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (xferrdy_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N"}),
                          .msg            ("Xferrdy frame not receiving ACK or NAK should be closed by DONE(ACK/NAK-TIMEOUT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (data_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N"}),
                          .msg            ("DATA frame not receiving ACK or NAK should be closed by DONE(ACK/NAK-TIMEOUT)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN0_PRIMITIVE_EXPECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           (align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN0_PRIMITIVE_EXPECTED_N"}),
                          .msg            ("ALIGN0 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN1_PRIMITIVE_EXPECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) 
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           && 
                           (align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN1_PRIMITIVE_EXPECTED_N"}),
                          .msg            ("ALIGN1 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN2_PRIMITIVE_EXPECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN2_PRIMITIVE_EXPECTED_N"}),
                          .msg            ("ALIGN2 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ALIGN3_PRIMITIVE_EXPECTED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align3_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align2_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ALIGN3_PRIMITIVE_EXPECTED_N"}),
                          .msg            ("ALIGN3 primitive is expected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (frame_transmitted === 1'b0 &&
                           (ack_det_received || nak_det_received) &&
                           (present_state === ZI_WAIT_COMMAND_ACK_STATE ||
                           present_state === ZI_WAIT_TASK_ACK_STATE ||
                           present_state === ZI_WAIT_SSP_RES_ACK_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_N"}),
                          .msg            ("Device should not send ACK or NAK without receiving a frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (xferrdy_received === 1'b0 &&
                           info_unit_type === 8'h01 && data_sent === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_N"}),
                          .msg            ("Initiator should not send DATA frame without receiving XFERRDY frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_TARGET_PORT_XFER_TAG_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (tgt_prt_xfer_tag_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_TARGET_PORT_XFER_TAG_VIOLATION_N"}),
                          .msg            ("SSP initiator port should set the target port transfer tag field to 16'hffff for all the SSP frames except data frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_ssp_connection))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_N"}),
                          .msg            ("Illegal primitive detected in a SSP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_smp_connection))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_N"}),
                          .msg            ("Illegal primitive detected in a SMP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_stp_connection))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_N"}),
                          .msg            ("Illegal primitive detected in a STP connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_outside_connection))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_N"}),
                          .msg            ("Illegal primitive detected outside the connection."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_RESPONSE_CODE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_res_code_err))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_RESPONSE_CODE_VIOLATION_N"}),
                          .msg            ("Response code field in the SSP response frame should have the values 8'h0, 8'h02, 8'h04, 8'h05, 8'h08 or 8'h09."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_SSP_INVALID_FRAME_TYPE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (invalid_ssp_frame_type === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_SSP_INVALID_FRAME_TYPE_N"}),
                          .msg            ("Illegal SSP frame type detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_EXPANDER_ERROR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (error_xmtd_by_non_expander))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_EXPANDER_ERROR_VIOLATION_N"}),
                          .msg            ("Non Expander device should not transmit an ERROR primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_BREAK_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (break_timeout_count == break_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_BREAK_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Break timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_addr_res_timeout_count === 
                           open_addr_res_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Response to open address request should be received within 1 ms."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_COMSAS_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (comsas_timeout_count === ZI_COMSAS_TIMEOUT_COUNT))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_COMSAS_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Device transmitting COMSAS sequence should receive a COMSAS sequence within the specified time out period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ident_timeout_count === ident_frame_timeout))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Device transmitting identification address frame should receive the same within the specified time out period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
        A_SAS_DONE_TIMEOUT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (done_timeout_violation))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SAS_DONE_TIMEOUT_VIOLATION_N"}),
                          .msg            ("Done timeout occured."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_SAS_IDLE_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           ((cominit_idle_time_violation && r_cominit_seq) ||
                           (comsas_idle_time_violation && r_comsas_seq)))));
        M_SAS_ADDR_FRAME_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (addr_frame_type_err)));
        M_SAS_IAF_DEV_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (iaf_device_type_err)));
        M_SAS_IAF_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (iaf_max_frame_size_err)));
        M_SAS_OAF_PROTOCOL_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_protocol_err)));
        M_SAS_OAF_FEATURE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_feature_field_err)));
        M_SAS_OAF_LINK_RATE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_link_rate_err)));
        M_SAS_OAF_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_max_frame_size_err)));
        M_SAS_CONNECTION_TAG_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (oaf_conn_tag_err)));
        M_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (TRANSPORT_LAYER_CHECKS_ENABLE ===  1 &&
                           smp_req_frame_type_err)));
        M_SAS_SMP_REQ_FUNCTION_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_fn_err)));
        M_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_phy_operation_err)));
        M_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_prog_min_phy_rate_err)));
        M_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_prog_max_phy_rate_err)));
        M_SAS_SMP_RES_FRAME_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_frame_type_err)));
        M_SAS_SMP_RES_FUNCTION_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_fn_err)));
        M_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_route_attr_err)));
        M_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_attached_dev_type_err)));
        M_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_fn_result_err)));
        M_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk   ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_res_cur_phy_rate_err)));
        M_SAS_SMP_REQ_RES_FN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (smp_req_res_fn_err)));
        M_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_task_atribute_err)));
        M_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_task_man_fn_err)));
        M_SAS_SSP_DATA_PRES_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_pres_err)));
        M_SAS_SSP_RESPONSE_STATUS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (status_err)));
        M_SAS_PHY_IDENTIFIER_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (phy_identifier_violation)));
        M_SAS_FIS_TYPE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (fis_type_violation)));
        M_SAS_SENSE_LENGTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sense_length_violation)));
        M_SAS_RESPONSE_LENGTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (response_length_violation)));
        M_SAS_RESPONSE_LIST_LENGTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (response_list_length_violation)));
        M_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sense_list_length_violation)));
        M_SAS_RETRANSMIT_BIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (retransmit_bit_violation)));
        M_SAS_CLOSE_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_prim_violation)));
        M_SAS_BREAK_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (break_prim_violation)));
        M_SAS_BROADCAST_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (change_prim_violation)));
        M_SAS_HARD_RESET_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hard_rst_prim_violation)));
        M_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_xrdy_prim_violation)));
        M_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_wtrm_prim_violation)));
        M_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_sync_prim_violation)));
        M_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rrdy_prim_violation)));
        M_SAS_SATA_ROK_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rok_prim_violation)));
        M_SAS_SATA_RERR_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rerr_prim_violation)));
        M_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_hold_prim_violation)));
        M_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_holda_prim_violation)));
        M_SAS_SATA_RIP_PRIMITIVE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_rip_prim_violation)));
        M_SAS_CRC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (crc_err)));
        M_SAS_EXPANDER_AIP_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (aip_xmtd_by_non_expander)));
        M_SAS_ILLEGAL_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (primitive_violation)));
        M_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (stp_hold_holda_dword_violation)));
        M_SAS_RESERVED_AIP_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_aip_primitive)));
        M_SAS_RESERVED_BROADCAST_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_broadcast_primitive)));
        M_SAS_RESERVED_CLOSE_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_close_primitive)));
        M_SAS_RESERVED_NOTIFY_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_notify_primitive)));
        M_SAS_RESERVED_OPEN_REJ_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_opn_rej_primitive)));
        M_SAS_RESERVED_DONE_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_done_primitive)));
        M_SAS_RESERVED_NAK_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_nak_primitive)));
        M_SAS_RESERVED_RRDY_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (reserved_rrdy_primitive)));
        M_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (done_prim_in_smp_stp)));
        M_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_pathway_block_from_non_expander_device)));
        M_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_bad_des_not_by_expander_device)));
        M_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_rej_no_des_not_from_expander)));
        M_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (frame_with_crc_err_without_nak)));
        M_SAS_MORE_THAN_3CONSECUTIVE_AIP_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (more_than_3consecutive_aip)));
        M_SAS_AIP_DWORD_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (aip_dword_count_violation)));
        M_SAS_ALIGN_DWORD_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (align_dword_count_violation)));
        M_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (stp_align_dword_count_violation)));
        M_SAS_ACK_NAK_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ack_nak_timeout_violation)));
        M_SAS_CREDIT_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (credit_timeout_violation)));
        M_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_min_frame_size_violation)));
        M_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_max_frame_size_err)));
        M_SAS_FOUR_BYTE_ALIGN_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (four_byte_align_violation)));
        M_SAS_SOAF_WITHOUT_EOAF_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (soaf_det === 1'b1 && soaf_detected)));
        M_SAS_UNKNOWN_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (next_state === ZI_UNKNOWN_STATE)));
        M_SAS_HOTPLUG_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hotplug_violation)));
        M_SAS_HARD_RESET_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (hard_reset_violation)));
        M_SAS_CLOSE_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_timeout_violation)));
        M_SAS_EOF_DETECTED_WITHOUT_SOF_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_detect === 1'b0 && eof_det == 1'b1)));
        M_SAS_SOF_DETECTED_WITHOUT_EOF_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sof_detect === 1'b1 && sof_det == 1'b1)));
        M_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (no_frame_after_done === 1'b1 && sof_det === 1'b1)));
        M_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (close_affliation_prim_count_violation)));
        M_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (waiting_for_ack_nak === 1'b1 && sof_det === 1'b1)));
        M_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((wtrm_received === 1'b0 &&
                           (r_ok_det || r_err_det) &&
                           wtrm === 1'b1))));
        M_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (credit_count === 0 &&
                           sof_det_received === 1'b1 &&
                           next_state !== ZI_SMP_WAIT_FOR_REQ_STATE &&
                           next_state !== ZI_SMP_WAIT_FOR_RES_STATE)));
        M_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (sata_sof_det === 1'b1 &&
                           sata_xrdy_transmitted === 1'b0 &&
                           sata_rrdy_rcvd === 1'b0)));
        M_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (xferrdy_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout)));
        M_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (data_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout)));
        M_SAS_ALIGN0_PRIMITIVE_EXPECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)));
        M_SAS_ALIGN1_PRIMITIVE_EXPECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ALIGN2_PRIMITIVE_EXPECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ALIGN3_PRIMITIVE_EXPECTED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align3_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align2_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (frame_transmitted === 1'b0 &&
                           (ack_det_received || nak_det_received) &&
                           (present_state === ZI_WAIT_COMMAND_ACK_STATE ||
                           present_state === ZI_WAIT_TASK_ACK_STATE ||
                           present_state === ZI_WAIT_SSP_RES_ACK_STATE))));
        M_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (xferrdy_received === 1'b0 &&
                           info_unit_type === 8'h01 && data_sent === 1'b1)));
        M_SAS_TARGET_PORT_XFER_TAG_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tgt_prt_xfer_tag_violation)));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_ssp_connection)));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_smp_connection)));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_inside_stp_connection)));
        M_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (illegal_primitive_outside_connection)));
        M_SAS_SSP_RESPONSE_CODE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ssp_res_code_err)));
        M_SAS_SSP_INVALID_FRAME_TYPE_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (invalid_ssp_frame_type === 1'b1)));
        M_SAS_EXPANDER_ERROR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (error_xmtd_by_non_expander)));
        M_SAS_BREAK_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (break_timeout_count == break_timeout)));
        M_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (open_addr_res_timeout_count === 
                           open_addr_res_timeout)));
        M_SAS_COMSAS_TIMEOUT__VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (comsas_timeout_count === ZI_COMSAS_TIMEOUT_COUNT)));
        M_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (ident_timeout_count === ident_frame_timeout)));
        M_SAS_DONE_TIMEOUT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (done_timeout_violation)));
        M_SAS_IDLE_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           ((cominit_idle_time_violation && r_cominit_seq) ||
                           (comsas_idle_time_violation && r_comsas_seq)))));
        M_SAS_ADDR_FRAME_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (addr_frame_type_err))));
        M_SAS_IAF_DEV_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (iaf_device_type_err))));
        M_SAS_IAF_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (iaf_max_frame_size_err))));
        M_SAS_OAF_PROTOCOL_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_protocol_err))));
        M_SAS_OAF_FEATURE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_feature_field_err))));
        M_SAS_OAF_LINK_RATE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_link_rate_err))));
        M_SAS_OAF_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_max_frame_size_err))));
        M_SAS_CONNECTION_TAG_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (oaf_conn_tag_err))));
        M_SAS_SMP_REQ_FRAME_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1)) &&
                           (smp_req_frame_type_err))));
        M_SAS_SMP_REQ_FUNCTION_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_fn_err))));
        M_SAS_SMP_REQ_PHY_OPERATION_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_phy_operation_err))));
        M_SAS_SMP_REQ_PROG_MIN_PHY_RATE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_prog_min_phy_rate_err))));
        M_SAS_SMP_REQ_PROG_MAX_PHY_RATE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_prog_max_phy_rate_err))));
        M_SAS_SMP_RES__FRAME_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_frame_type_err))));
        M_SAS_SMP_RES_FUNCTION_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_fn_err))));
        M_SAS_SMP_RES_FUNCTION_RESULT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_fn_result_err))));
        M_SAS_SMP_RES_ROUTE_ATTRIBUTE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_route_attr_err))));
        M_SAS_SMP_RES_ATTACHED_DEV_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_attached_dev_type_err))));
        M_SAS_SMP_RES_CUR_PHY_RATE_VIOATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_res_cur_phy_rate_err))));
        M_SAS_SMP_REQ_RES_FN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (smp_req_res_fn_err))));
        M_SAS_SSP_COM_TASK_ATTRIBUTE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (ssp_task_atribute_err))));
        M_SAS_SSP_TASK_MANAGEMENT_FN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (ssp_task_man_fn_err))));
        M_SAS_SSP_DATA_PRES_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (data_pres_err))));
        M_SAS_SSP_RESPONSE_STATUS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (status_err))));
        M_SAS_PHY_IDENTIFIER_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (phy_identifier_violation))));
        M_SAS_FIS_TYPE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (fis_type_violation))));
        M_SAS_SENSE_LENGTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (sense_length_violation))));
        M_SAS_RESPONSE_LENGTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (response_length_violation))));
        M_SAS_RESPONSE_LIST_LENGTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (response_list_length_violation))));
        M_SAS_SENSE_DATA_LIST_LENGTH_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (sense_list_length_violation))));
        M_SAS_RETRANSMIT_BIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (TRANSPORT_LAYER_CHECKS_ENABLE === 1) &&
                           (retransmit_bit_violation))));
        M_SAS_CLOSE_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_prim_violation))));
        M_SAS_BREAK_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (break_prim_violation))));
        M_SAS_BROADCAST_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (change_prim_violation))));
        M_SAS_HARD_RESET_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hard_rst_prim_violation))));
        M_SAS_SATA_XRDY_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_xrdy_prim_violation))));
        M_SAS_SATA_WTRM_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_wtrm_prim_violation))));
        M_SAS_SATA_SYNC_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_sync_prim_violation))));
        M_SAS_SATA_RRDY_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rrdy_prim_violation))));
        M_SAS_SATA_ROK_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rok_prim_violation))));
        M_SAS_SATA_RERR_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rerr_prim_violation))));
        M_SAS_SATA_HOLD_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_hold_prim_violation))));
        M_SAS_SATA_HOLDA_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_holda_prim_violation))));
        M_SAS_SATA_RIP_PRIMITIVE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_rip_prim_violation))));
        M_SAS_CRC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (crc_err))));
        M_SAS_EXPANDER_AIP_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (aip_xmtd_by_non_expander))));
        M_SAS_ILLEGAL_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (primitive_violation))));
        M_SAS_STP_HOLD_HOLDA_DWORD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (stp_hold_holda_dword_violation))));
        M_SAS_RESERVED_AIP_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_aip_primitive))));
        M_SAS_RESERVED_BROADCAST_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_broadcast_primitive))));
        M_SAS_RESERVED_CLOSE_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_close_primitive))));
        M_SAS_RESERVED_NOTIFY_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_notify_primitive))));
        M_SAS_RESERVED_OPEN_REJ_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_opn_rej_primitive))));
        M_SAS_RESERVED_DONE_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_done_primitive))));
        M_SAS_RESERVED_NAK_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_nak_primitive))));
        M_SAS_RESERVED_RRDY_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (reserved_rrdy_primitive))));
        M_SAS_DONE_PRIMITIVE_IN_SMP_OR_STP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (done_prim_in_smp_stp))));
        M_SAS_OPEN_REJ_PATHWAY_BLOCK_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_pathway_block_from_non_expander_device))));
        M_SAS_OPEN_REJ_BAD_DESTINATION_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_bad_des_not_by_expander_device))));
        M_SAS_OPEN_REJ_NO_DESTINATION_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_rej_no_des_not_from_expander))));
        M_SAS_FRAME_WITH_CRC_ERR_WITHOUT_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (frame_with_crc_err_without_nak))));
        M_SAS_MORE_THAN_3CONSECUTIVE_AIP_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (more_than_3consecutive_aip))));
        M_SAS_AIP_DWORD_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (aip_dword_count_violation))));
        M_SAS_ALIGN_DWORD_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (align_dword_count_violation))));
        M_SAS_STP_ALIGN_DWORD_COUNT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (stp_align_dword_count_violation))));
        M_SAS_ACK_NAK_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ack_nak_timeout_violation))));
        M_SAS_CREDIT_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (credit_timeout_violation))));
        M_SAS_SSP_MIN_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_min_frame_size_violation))));
        M_SAS_SSP_MAX_FRAME_SIZE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_max_frame_size_err))));
        M_SAS_FOUR_BYTE_ALIGN_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (four_byte_align_violation))));
        M_SAS_SOAF_WITHOUT_EOAF_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (soaf_det === 1'b1 && soaf_detected))));
        M_SAS_UNKNOWN_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (next_state === ZI_UNKNOWN_STATE))));
        M_SAS_HOTPLUG_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hotplug_violation))));
        M_SAS_HARD_RESET_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (hard_reset_violation))));
        M_SAS_CLOSE_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_timeout_violation))));
        M_SAS_EOF_DETECTED_WITHOUT_SOF_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sof_detect === 1'b0 && eof_det == 1'b1))));
        M_SAS_SOF_DETECTED_WITHOUT_EOF_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sof_detect === 1'b1 && sof_det == 1'b1))));
        M_SAS_NO_FRAME_AFTER_DONE_PRIMITIVE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (no_frame_after_done === 1'b1 && sof_det === 1'b1))));
        M_SAS_CLOSE_AFFILIATION_PRIM_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (close_affliation_prim_count_violation))));
        M_SAS_INTERLOCKED_FRAME_WITHOUT_ACK_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (waiting_for_ack_nak === 1'b1 && sof_det === 1'b1))));
        M_SAS_ROK_OR_RERR_DETECTED_BEFORE_WTRM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (wtrm_received === 1'b0 &&
                           (r_ok_det || r_err_det) &&
                           wtrm === 1'b1))));
        M_SAS_FRAME_RECEIVED_WITHOUT_CREDIT_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (credit_count === 0 && sof_det_received === 1'b1 &&
                           next_state !== ZI_SMP_WAIT_FOR_REQ_STATE &&
                           next_state !== ZI_SMP_WAIT_FOR_RES_STATE))));
        M_SAS_FIS_TRANSMITTED_WITHOUT_EXCHANGING_XRDY_AND_RRDY_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (sata_sof_det === 1'b1 &&
                           sata_xrdy_transmitted === 1'b0 &&
                           sata_rrdy_rcvd === 1'b0))));
        M_SAS_XFERRDY_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (xferrdy_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout))));
        M_SAS_DATA_RECEIVED_WITHOUT_ACK_NAK_WITHOUT_DONE_ACK_NAK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (data_received_ack_nak === 1'b1 &&
                           ack_nak_timeout_count === ack_nak_timeout &&
                           !done_det_ack_nak_timeout))));
        M_SAS_ALIGN0_PRIMITIVE_EXPECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           (align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ALIGN1_PRIMITIVE_EXPECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) 
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           && 
                           (align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ALIGN2_PRIMITIVE_EXPECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ALIGN3_PRIMITIVE_EXPECTED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (!(pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0)
                           &&
                           !(align0_expected === 1'b1 &&
                           (sas_align1_detect || sas_align2_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align1_expected === 1'b1 &&
                           (sas_align2_detect || sas_align3_detect ||
                           sas_align_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           !(align2_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align3_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1)
                           &&
                           (align3_expected === 1'b1 &&
                           (sas_align_detect || sas_align1_detect ||
                           sas_align2_detect) &&
                           ZI_ALIGN_ROTATION_CHECK_ENABLE === 1))));
        M_SAS_ACK_NAK_RECEIVED_WITHOUT_FRAME_TRANSMISSION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (frame_transmitted === 1'b0 &&
                           (ack_det_received || nak_det_received) &&
                           (present_state === ZI_WAIT_COMMAND_ACK_STATE ||
                           present_state === ZI_WAIT_TASK_ACK_STATE ||
                           present_state === ZI_WAIT_SSP_RES_ACK_STATE)))));
        M_SAS_DATA_FRAME_FROM_INITIATOR_WITHOUT_XFERRDY_FRAME_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (xferrdy_received === 1'b0 &&
                           info_unit_type === 8'h01 && data_sent === 1'b1))));
        M_SAS_TARGET_PORT_XFER_TAG_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (tgt_prt_xfer_tag_violation))));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_SSP_CONNECTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_ssp_connection))));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_SMP_CONNECTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_smp_connection))));
        M_SAS_ILLEGAL_PRIMITIVE_INSIDE_STP_CONNECTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_inside_stp_connection))));
        M_SAS_ILLEGAL_PRIMITIVE_OUTSIDE_CONNECTION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (illegal_primitive_outside_connection))));
        M_SAS_SSP_RESPONSE_CODE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ssp_res_code_err))));
        M_SAS_SSP_INVALID_FRAME_TYPE_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (invalid_ssp_frame_type === 1'b1))));
        M_SAS_EXPANDER_ERROR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (error_xmtd_by_non_expander))));
        M_SAS_BREAK_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (break_timeout_count == break_timeout))));
        M_SAS_OPEN_ADDR_RESPOSNE_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (open_addr_res_timeout_count === 
                           open_addr_res_timeout))));
        M_SAS_COMSAS_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (comsas_timeout_count === ZI_COMSAS_TIMEOUT_COUNT))));
        M_SAS_IDENT_FRAME_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (ident_timeout_count === ident_frame_timeout))));
        M_SAS_DONE_TIMEOUT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1 &&
                           transaction_in_g1rate === 1'b0) &&
                           (done_timeout_violation))));
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
