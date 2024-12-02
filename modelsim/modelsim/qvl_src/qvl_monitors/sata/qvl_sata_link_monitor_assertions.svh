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
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERT
                                   // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`COVER_NONE;
  parameter QVL_MSG = "QVL_SATA_VIOLATION : ";

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// Checks based on ZI_TX_CONSTRAINT

generate
  case (ZI_TX_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_TX_CONSTRAINT 
        A_SATA_TX_HOLDA_P_LATENCY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_p_latency_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_P_LATENCY_VIOLATION_P"}),
                          .msg            ("The latency between the detection of first HOLDp to the detection of first HOLDAp must not be more than 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLDA_P_LATENCY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_p_latency_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_P_LATENCY_VIOLATION_N"}),
                          .msg            ("The latency between the detection of first HOLDp to the detection of first HOLDAp must not be more than 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_PMACK_WO_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_pmack_wo_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_PMACK_WO_PMREQ_VIOLATION_P"}),
                          .msg            ("PMACK must not be transmitted without the receipt of PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_PMACK_WO_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_pmack_wo_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_PMACK_WO_PMREQ_VIOLATION_N"}),
                          .msg            ("PMACK must not be transmitted without the receipt of PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_pmnack_wo_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_P"}),
                          .msg            ("PMNACK must not be transmitted without the receipt of PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_pmnack_wo_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_N"}),
                          .msg            ("PMNACK must not be transmitted without the receipt of PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_r_rdy_wo_x_rdy_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_P"}),
                          .msg            ("R_RDYp must not be transmitted without receiving X_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_r_rdy_wo_x_rdy_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_N"}),
                          .msg            ("R_RDYp must not be transmitted without receiving X_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOST_BACK_OFF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_host_back_off_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOST_BACK_OFF_VIOLATION_P"}),
                          .msg            ("The host transmitting X_RDYp must back off and start transmitting R_RDYp on receiving X_RDYp from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOST_BACK_OFF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_host_back_off_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOST_BACK_OFF_VIOLATION_N"}),
                          .msg            ("The host transmitting X_RDYp must back off and start transmitting R_RDYp on receiving X_RDYp from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_xrdy_during_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of X_RDYp while transmitting PMREQ_Pp or PMREQ_Sp primitives host shall not enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_xrdy_during_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of X_RDYp while transmitting PMREQ_Pp or PMREQ_Sp primitives host shall not enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_dpmreq_while_hpmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the device while transmitting PMREQ_Pp or PMREQ_Sp the host must start transmitting SYNCp without entering power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_dpmreq_while_hpmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the device while transmitting PMREQ_Pp or PMREQ_Sp the host must start transmitting SYNCp without entering power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tx_hpmreq_while_dpmreq_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the host while transmitting PMREQ_Pp or PMREQ_Sp the device must continue transmitting PMREQ and enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_hpmreq_while_dpmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the host while transmitting PMREQ_Pp or PMREQ_Sp the device must continue transmitting PMREQ and enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SOF_WO_RRDY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tx_sof_wo_rrdy_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SOF_WO_RRDY_VIOLATION_P"}),
                          .msg            ("SOFp must be transmitted only after receiving R_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SOF_WO_RRDY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sof_wo_rrdy_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SOF_WO_RRDY_VIOLATION_N"}),
                          .msg            ("SOFp must be transmitted only after receiving R_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tx_hold_outside_eof_sof_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P"}),
                          .msg            ("HOLDp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_hold_outside_eof_sof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N"}),
                          .msg            ("HOLDp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_dmat_outside_eof_sof_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P"}),
                          .msg            ("DMATp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_dmat_outside_eof_sof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N"}),
                          .msg            ("DMATp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_until_hold_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_P"}),
                          .msg            ("HOLDAp must be transmitted as long as HOLDp primitive is being received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_until_hold_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_N"}),
                          .msg            ("HOLDAp must be transmitted as long as HOLDp primitive is being received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLDA_WO_HOLD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_wo_hold_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_WO_HOLD_VIOLATION_P"}),
                          .msg            ("HOLDAp primitive must not be transmitted without receiving HOLDp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_HOLDA_WO_HOLD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_wo_hold_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_HOLDA_WO_HOLD_VIOLATION_N"}),
                          .msg            ("HOLDAp primitive must not be transmitted without receiving HOLDp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_WTRM_UNTIL_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_wtrm_until_sts_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_WTRM_UNTIL_STS_VIOLATION_P"}),
                          .msg            ("WTRMp primitve must be transmitted until the reception of R_OKp or R_ERRp or SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_WTRM_UNTIL_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_wtrm_until_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_WTRM_UNTIL_STS_VIOLATION_N"}),
                          .msg            ("WTRMp primitve must be transmitted until the reception of R_OKp or R_ERRp or SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_sync_after_rx_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_P"}),
                          .msg            ("On receipt of SYNCp, SYNCp primitive must be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sync_after_rx_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_N"}),
                          .msg            ("On receipt of SYNCp, SYNCp primitive must be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RIP_AFTER_EOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rip_after_eof_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RIP_AFTER_EOF_VIOLATION_P"}),
                          .msg            ("While transmitting HOLDp or HOLDAp or DMATp,  R_IPp must be transmitted after receiving EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RIP_AFTER_EOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rip_after_eof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RIP_AFTER_EOF_VIOLATION_N"}),
                          .msg            ("While transmitting HOLDp or HOLDAp or DMATp,  R_IPp must be transmitted after receiving EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rok_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("R_OKp primitive must be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rok_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("R_OKp primitive must be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rerr_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("R_ERRp primitive must be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rerr_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("R_ERRp primitive must be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_sync_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("On detection of SOFp without the transmission of R_RDY, any primitive other than SYNCp must not be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sync_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("On detection of SOFp without the transmission of R_RDY, any primitive other than SYNCp must not be transmitted until the reception of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rok_for_tx_count_err_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_P"}),
                          .msg            ("On detection of transfer count mismatch between the count specified in the pio setup and the bytes received in a frame, it must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
        A_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rok_for_tx_count_err_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_N"}),
                          .msg            ("On detection of transfer count mismatch between the count specified in the pio setup and the bytes received in a frame, it must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_TX_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_TX_CONSTRAINT 
        M_SATA_TX_HOLDA_P_LATENCY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_p_latency_violation == 1'b1)))));
        M_SATA_TX_HOLDA_P_LATENCY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_p_latency_violation == 1'b1))));
        M_SATA_TX_PMACK_WO_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_pmack_wo_pmreq_violation == 1'b1)))));
        M_SATA_TX_PMACK_WO_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_pmack_wo_pmreq_violation == 1'b1))));
        M_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_pmnack_wo_pmreq_violation == 1'b1)))));
        M_SATA_TX_PMNACK_WO_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_pmnack_wo_pmreq_violation == 1'b1))));
        M_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_r_rdy_wo_x_rdy_violation == 1'b1)))));
        M_SATA_TX_R_RDY_WO_X_RDY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_r_rdy_wo_x_rdy_violation == 1'b1))));
        M_SATA_TX_HOST_BACK_OFF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_host_back_off_violation == 1'b1)))));
        M_SATA_TX_HOST_BACK_OFF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_host_back_off_violation == 1'b1))));
        M_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_xrdy_during_pmreq_violation == 1'b1)))));
        M_SATA_TX_XRDY_DURING_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_xrdy_during_pmreq_violation == 1'b1))));
        M_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_dpmreq_while_hpmreq_violation == 1'b1)))));
        M_SATA_TX_DPMREQ_WHILE_HPMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_dpmreq_while_hpmreq_violation == 1'b1))));
        M_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tx_hpmreq_while_dpmreq_violation == 1'b1)));
        M_SATA_TX_HPMREQ_WHILE_DPMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_hpmreq_while_dpmreq_violation == 1'b1))));
        M_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_hpmreq_while_dpmreq_violation == 1'b1)))));
        M_SATA_TX_SOF_WO_RRDY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sof_wo_rrdy_violation == 1'b1))));
        M_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (tx_hold_outside_eof_sof_violation == 1'b1)));
        M_SATA_TX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_hold_outside_eof_sof_violation == 1'b1))));
        M_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_dmat_outside_eof_sof_violation == 1'b1)))));
        M_SATA_TX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_dmat_outside_eof_sof_violation == 1'b1))));
        M_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_until_hold_violation == 1'b1)))));
        M_SATA_TX_HOLDA_UNTIL_HOLD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_until_hold_violation == 1'b1))));
        M_SATA_TX_HOLDA_WO_HOLD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_holda_wo_hold_violation == 1'b1)))));
        M_SATA_TX_HOLDA_WO_HOLD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_holda_wo_hold_violation == 1'b1))));
        M_SATA_TX_WTRM_UNTIL_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_wtrm_until_sts_violation == 1'b1)))));
        M_SATA_TX_WTRM_UNTIL_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_wtrm_until_sts_violation == 1'b1))));
        M_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_sync_after_rx_sync_violation == 1'b1)))));
        M_SATA_TX_SYNC_AFTER_RX_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sync_after_rx_sync_violation == 1'b1))));
        M_SATA_TX_RIP_AFTER_EOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rip_after_eof_violation == 1'b1)))));
        M_SATA_TX_RIP_AFTER_EOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rip_after_eof_violation == 1'b1))));
        M_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rok_until_sync_violation == 1'b1)))));
        M_SATA_TX_ROK_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rok_until_sync_violation == 1'b1))));
        M_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rerr_until_sync_violation == 1'b1)))));
        M_SATA_TX_RERR_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rerr_until_sync_violation == 1'b1))));
        M_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_sync_until_sync_violation == 1'b1)))));
        M_SATA_TX_SYNC_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_sync_until_sync_violation == 1'b1))));
        M_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_rok_for_tx_count_err_violation == 1'b1)))));
        M_SATA_TX_ROK_FOR_TX_CNT_ERR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (tx_rok_for_tx_count_err_violation == 1'b1))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_TX_CONSTRAINT 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Checks with ZI_RX_CONSTRAINT

generate
  case (ZI_RX_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_RX_CONSTRAINT 
        A_SATA_RX_HOLDA_P_LATENCY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_p_latency_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_P_LATENCY_VIOLATION_P"}),
                          .msg            ("The latency between the detection of first HOLDp to the detection of first HOLDAp must not be more than 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLDA_P_LATENCY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_p_latency_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_P_LATENCY_VIOLATION_N"}),
                          .msg            ("The latency between the detection of first HOLDp to the detection of first HOLDAp must not be more than 20 dwords."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_PMACK_WO_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_pmack_wo_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_PMACK_WO_PMREQ_VIOLATION_P"}),
                          .msg            ("PMACK must not be received without transmitting PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_PMACK_WO_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_pmack_wo_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_PMACK_WO_PMREQ_VIOLATION_N"}),
                          .msg            ("PMACK must not be received without transmitting PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_pmnack_wo_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_P"}),
                          .msg            ("PMNACK must not be received without transmitting PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_pmnack_wo_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_N"}),
                          .msg            ("PMNACK must not be received without transmitting PMREQ_Pp or PMREQ_Sp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_r_rdy_wo_x_rdy_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_P"}),
                          .msg            ("R_RDYp must not be received without transmitting X_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_r_rdy_wo_x_rdy_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_N"}),
                          .msg            ("R_RDYp must not be received without transmitting X_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOST_BACK_OFF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_host_back_off_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOST_BACK_OFF_VIOLATION_P"}),
                          .msg            ("The host transmitting X_RDYp must back off and start transmitting R_RDYp on receiving X_RDYp from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOST_BACK_OFF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_host_back_off_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOST_BACK_OFF_VIOLATION_N"}),
                          .msg            ("The host transmitting X_RDYp must back off and start transmitting R_RDYp on receiving X_RDYp from the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_xrdy_during_pmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of X_RDYp while transmitting PMREQ_Pp or PMREQ_Sp primitives device shall not enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_xrdy_during_pmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of X_RDYp while transmitting PMREQ_Pp or PMREQ_Sp primitives device shall not enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_dpmreq_while_hpmreq_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the device while transmitting PMREQ_Pp or PMREQ_Sp the host must start transmitting SYNCp without entering power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_dpmreq_while_hpmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the device while transmitting PMREQ_Pp or PMREQ_Sp the host must start transmitting SYNCp without entering power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_hpmreq_while_dpmreq_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_P"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the host the device must continue transmitting PMREQ and enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_hpmreq_while_dpmreq_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_N"}),
                          .msg            ("On receipt of PMREQ_Pp or PMREQ_Sp from the host the device must continue transmitting PMREQ and enter power down mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SOF_WO_RRDY_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_sof_wo_rrdy_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SOF_WO_RRDY_VIOLATION_P"}),
                          .msg            ("SOFp must be received only after transmitting R_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SOF_WO_RRDY_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sof_wo_rrdy_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SOF_WO_RRDY_VIOLATION_N"}),
                          .msg            ("SOFp must be received only after transmitting R_RDYp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_hold_outside_eof_sof_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P"}),
                          .msg            ("HOLDp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_hold_outside_eof_sof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N"}),
                          .msg            ("HOLDp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_dmat_outside_eof_sof_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P"}),
                          .msg            ("DMATp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_dmat_outside_eof_sof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N"}),
                          .msg            ("DMATp primitive must be detected within the SOFp and EOFp primitives."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_until_hold_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_P"}),
                          .msg            ("HOLDAp must be received as long as HOLDp primitive is being transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_until_hold_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_N"}),
                          .msg            ("HOLDAp must be received as long as HOLDp primitive is being transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLDA_WO_HOLD_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_wo_hold_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_WO_HOLD_VIOLATION_P"}),
                          .msg            ("HOLDAp primitive must not be received without transmitting HOLDp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_HOLDA_WO_HOLD_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_wo_hold_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_HOLDA_WO_HOLD_VIOLATION_N"}),
                          .msg            ("HOLDAp primitive must not be received without transmitting HOLDp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_WTRM_UNTIL_STS_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_wtrm_until_sts_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_WTRM_UNTIL_STS_VIOLATION_P"}),
                          .msg            ("WTRMp primitve must be received until the transmission of R_OKp or R_ERRp or SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_WTRM_UNTIL_STS_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_wtrm_until_sts_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_WTRM_UNTIL_STS_VIOLATION_N"}),
                          .msg            ("WTRMp primitve must be received until the transmission of R_OKp or R_ERRp or SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_sync_after_tx_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_P"}),
                          .msg            ("On receipt of SYNCp, SYNCp primitive must be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sync_after_tx_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_N"}),
                          .msg            ("On receipt of SYNCp, SYNCp primitive must be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RIP_AFTER_EOF_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_rip_after_eof_violation == 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RIP_AFTER_EOF_VIOLATION_P"}),
                          .msg            ("While receiving HOLDp or HOLDAp or DMATp,  R_IPp must be received after transmitting EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RIP_AFTER_EOF_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rip_after_eof_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RIP_AFTER_EOF_VIOLATION_N"}),
                          .msg            ("While receiving HOLDp or HOLDAp or DMATp,  R_IPp must be received after transmitting EOFp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rok_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("R_OKp primitive must be received until the transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rok_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("R_OKp primitive must be received until the transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rerr_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("R_ERRp primitive must be received until the transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rerr_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("R_ERRp primitive must be received until the transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_sync_until_sync_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_P"}),
                          .msg            ("On detection of SOFp without receiving R_RDY, any primitive other than SYNCp must not be detected until transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sync_until_sync_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_N"}),
                          .msg            ("On detection of SOFp without receiving R_RDY, any primitive other than SYNCp must not be detected until transmission of SYNCp."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rok_for_tx_count_err_violation == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_P"}),
                          .msg            ("On detection of transfer count mismatch between the count specified in the pio setup and the bytes received in a frame, it must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
        A_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rok_for_tx_count_err_violation == 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_N"}),
                          .msg            ("On detection of transfer count mismatch between the count specified in the pio setup and the bytes received in a frame, it must be negatively acknowledged with R_ERRp primitive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RX_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_RX_CONSTRAINT 
        M_SATA_RX_HOLDA_P_LATENCY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_p_latency_violation == 1'b1)))));
        M_SATA_RX_HOLDA_P_LATENCY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_p_latency_violation == 1'b1))));
        M_SATA_RX_PMACK_WO_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_pmack_wo_pmreq_violation == 1'b1)))));
        M_SATA_RX_PMACK_WO_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_pmack_wo_pmreq_violation == 1'b1))));
        M_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_pmnack_wo_pmreq_violation == 1'b1)))));
        M_SATA_RX_PMNACK_WO_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_pmnack_wo_pmreq_violation == 1'b1))));
        M_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_r_rdy_wo_x_rdy_violation == 1'b1)))));
        M_SATA_RX_R_RDY_WO_X_RDY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_r_rdy_wo_x_rdy_violation == 1'b1))));
        M_SATA_RX_HOST_BACK_OFF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_host_back_off_violation == 1'b1)))));
        M_SATA_RX_HOST_BACK_OFF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_host_back_off_violation == 1'b1))));
        M_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_xrdy_during_pmreq_violation == 1'b1)))));
        M_SATA_RX_XRDY_DURING_PMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_xrdy_during_pmreq_violation == 1'b1))));
        M_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_dpmreq_while_hpmreq_violation == 1'b1)));
        M_SATA_RX_DPMREQ_WHILE_HPMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_dpmreq_while_hpmreq_violation == 1'b1))));
        M_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_hpmreq_while_dpmreq_violation == 1'b1)))));
        M_SATA_RX_HPMREQ_WHILE_DPMREQ_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_hpmreq_while_dpmreq_violation == 1'b1))));
        M_SATA_RX_SOF_WO_RRDY_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_sof_wo_rrdy_violation == 1'b1)));
        M_SATA_RX_SOF_WO_RRDY_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sof_wo_rrdy_violation == 1'b1))));
        M_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_hold_outside_eof_sof_violation == 1'b1)));
        M_SATA_RX_HOLD_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_hold_outside_eof_sof_violation == 1'b1))));
        M_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_dmat_outside_eof_sof_violation == 1'b1)))));
        M_SATA_RX_DMAT_OUTSIDE_EOF_SOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_dmat_outside_eof_sof_violation == 1'b1))));
        M_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_until_hold_violation == 1'b1)))));
        M_SATA_RX_HOLDA_UNTIL_HOLD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_until_hold_violation == 1'b1))));
        M_SATA_RX_HOLDA_WO_HOLD_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_holda_wo_hold_violation == 1'b1)))));
        M_SATA_RX_HOLDA_WO_HOLD_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_holda_wo_hold_violation == 1'b1))));
        M_SATA_RX_WTRM_UNTIL_STS_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_wtrm_until_sts_violation == 1'b1)))));
        M_SATA_RX_WTRM_UNTIL_STS_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_wtrm_until_sts_violation == 1'b1))));
        M_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_sync_after_tx_sync_violation == 1'b1)))));
        M_SATA_RX_SYNC_AFTER_TX_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sync_after_tx_sync_violation == 1'b1))));
        M_SATA_RX_RIP_AFTER_EOF_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (rx_rip_after_eof_violation == 1'b1)));
        M_SATA_RX_RIP_AFTER_EOF_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rip_after_eof_violation == 1'b1))));
        M_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rok_until_sync_violation == 1'b1)))));
        M_SATA_RX_ROK_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rok_until_sync_violation == 1'b1))));
        M_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rerr_until_sync_violation == 1'b1)))));
        M_SATA_RX_RERR_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rerr_until_sync_violation == 1'b1))));
        M_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_sync_until_sync_violation == 1'b1)))));
        M_SATA_RX_SYNC_UNTIL_SYNC_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_sync_until_sync_violation == 1'b1))));
        M_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr (((rx_rok_for_tx_count_err_violation == 1'b1)))));
        M_SATA_RX_ROK_FOR_TX_CNT_ERR_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (rx_rok_for_tx_count_err_violation == 1'b1))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_RX_CONSTRAINT 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_ASSERT_ON
