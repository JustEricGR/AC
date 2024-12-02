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
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// assert only checks

generate
// GEN2 assertions
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assert_PCI_EXPRESS_GEN2
        // Assertions with positive clock
        A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |xmtd_skip_ordered_set && xmtd_eie_before_fts_count < 4'b0100)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_TX_P"}),
                          .msg            ("Minimum four EIE symbol should be transmitted before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && current_speed_5gt === 1'b1 &&
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE &&
                           |xmtd_skip_ordered_set && xmtd_eie_before_fts_count > 4'b1000)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_TX_P"}),
                          .msg            ("Maximum eight EIE symbol can be transmitted before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_eie_os_all_lanes && current_speed_5gt == 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_TX_P"}),
                          .msg            ("Electrical Idle Exit sequence Ordered Set(EIEOS) should be detected only on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_NON_POLLING_STATE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           |xmtd_ts1 && |xmtd_compliance_receive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_NON_POLLING_STATE_P"}),
                          .msg            ("Complaince Receive bit can only be set in Polling Active state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_IN_ILLEGAL_STATE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                              ltssm_present_state !== ZI_LTSSM_CFG_RCVRCFG_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_IDLE_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_SPEED_STATE &&
                              ltssm_present_state !== ZI_LTSSM_L0_STATE &&
                              xmtd_eie_os_all_lanes && current_speed_5gt == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_IN_ILLEGAL_STATE_P"}),
                          .msg            ("EIEOS should not be transmitted in states other than Recovery.RcvrLk, Recovery.RcvrCfg and Configuration.Linkwidth.Start."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_NOT_SENT_BEFORE_FIRST_TS1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state === ZI_LTSSM_CFG_IDLE_STATE || ltssm_present_state === ZI_LTSSM_L0_STATE ||
                                ltssm_present_state === ZI_LTSSM_RX_L0s_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_IDLE_STATE || 
                                ltssm_present_state === ZI_LTSSM_L1_STATE) &&
                               current_speed_5gt == 1'b1 && |xmtd_ts1 && r_xmtd_eieos === 1'b0) || 
                              ((ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE ||
                                ltssm_present_state === ZI_LTSSM_RECOVERY_IDLE_STATE) && current_speed_5gt == 1'b1 && 
                               link_directed_to_config === 1'b1 && r_xmtd_eieos === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_NOT_SENT_BEFORE_FIRST_TS1_P"}),
                          .msg            ("EIEOS should be transmitted before first TS1 OS in Recovery.RcvrLk/Configuration.Linkwidth.Start on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_ILLEGAL_COUNT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(eie_counter === 6'd32 && (|xmtd_ts1 || |xmtd_ts2))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ILLEGAL_COUNT_P"}),
                          .msg            ("EIEOS should be transmitted every after 32 consecutive TS1 or TS2 OS on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_UPCONFIG_BIT_CHANGE_IN_CONFIG_COMPLETE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && |xmtd_ts2 &&
                              ts2_os_count_in_config_complete > 0 && (r_xmtd_upconfig_support !== (|xmtd_autonomous)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_BIT_CHANGE_IN_CONFIG_COMPLETE_P"}),
                          .msg            ("Device must not change upconfiguration bit(symbol 4 bit 6 of TS2) while in Configuration.Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_DATA_RATE_CHANGE_IN_CONFIG_COMPLETE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE
                           && |xmtd_ts2 && ts2_os_count_in_config_complete > 0 
                           && (r_xmtd_gen2_rate_support !== ((|xmtd_gen2) & (|xmtd_gen1))))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DATA_RATE_CHANGE_IN_CONFIG_COMPLETE_P"}),
                          .msg            ("Device must not change data rate value while in Configuration.Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_RECO_LK_NOT_ENTERED_FROM_CONFIF_IDLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(config_idle_illegal_timedout)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_RECO_LK_NOT_ENTERED_FROM_CONFIF_IDLE_P"}),
                          .msg            ("Device should enter to Recovery.Lk from Config.Idle after 2ms timeout if idle_2rlock_transitioned variable is 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIOS_NOT_SENT_PRIOR_TO_ENTERING_RECO_SPEED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && tx_eidle_active_lanes)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIOS_NOT_SENT_PRIOR_TO_ENTERING_RECO_SPEED_P"}),
                          .msg            ("Electrical Idle Ordered Set(EIOS) not sent prior to entering electrical idle in Recovery.Speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_RECO_SPEED_ILLEGAL_TRANSITION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(reco_speed_illegal_transition)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_RECO_SPEED_ILLEGAL_TRANSITION_P"}),
                          .msg            ("Device must not enter Recovery.Speed from Recovery.Cfg unless 32 TS2 are transmitted without being interrupted by EIEOS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 
                              && r_xmtd_gen2_rate_support === 1'b0 && |xmtd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_P"}),
                          .msg            ("Device is not capable of higher data rate but initiated speed change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));

        A_PCI_EXPRESS_GEN2_L1_IDLE_LT_40NS_ON_SPEED_NOT_2_5_GT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(l1_idle_less_than_40_ns)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_L1_IDLE_LT_40NS_ON_SPEED_NOT_2_5_GT_P"}),
                          .msg            ("Device should remain in L1.Idle for minimum of 40 ns on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_LK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && rcvd_ts1_os_count > 4'h8 
                              && |xmtd_ts1 && (|xmtd_speed_change === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_LK_P"}),
                          .msg            ("Device should set speed_change_bit in TS1 OS after receiving 8 consecutive TS1 OS with speed change bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_CFG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && rcvd_ts1_os_count >= 4'h8 
                              && |xmtd_ts2 && (|xmtd_speed_change === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_CFG_P"}),
                          .msg            ("The speed change must be set to 1 in all TS2 OS in Recovery.RcvrCfg when it has initiated speed change in Recovery.RcvrLk."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHNG_OTHER_THAN_RECO_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_speed_change && ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE 
                              && ltssm_present_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE && ltssm_present_state !== ZI_LTSSM_L0_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHNG_OTHER_THAN_RECO_P"}),
                          .msg            ("The speed change bit must not be set to 1 in state other than Recovery."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHNG_NOT_0_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_speed_change && changed_speed_recovery === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHNG_NOT_0_P"}),
                          .msg            ("The speed change bit should be 0 after successful speed negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_RECO_SPEED_TO_RECO_CFG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_RECO_SPEED_TO_RECO_CFG_P"}),
                          .msg            ("Illegal state transtion from Recovery.Speed to Recover.Cfg."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_OTHER_DEVICE_NOT_CAPABLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 
                              && r_rcvd_gen2_rate_support === 1'b0 && |xmtd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_OTHER_DEVICE_NOT_CAPABLE_P"}),
                          .msg            ("Initiated speed change when other device is not capable of higher data rate."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 && |xmtd_speed_change && xmtd_ts1_os_count_reco > 11'h8
                              && current_speed_5gt === ((|xmtd_gen2) & (|xmtd_gen1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_TX_P"}),
                          .msg            ("When speed change initiated proposed data rate should be different from current running speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_link_width > link_width_reg && r_xmtd_upconfig_support === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_P"}),
                          .msg            ("Device is not capable of upconfiguration but initiated upconfiguration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        
        // Assertions with negative clock
        A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |xmtd_skip_ordered_set && xmtd_eie_before_fts_count < 4'b0100)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_TX_N"}),
                          .msg            ("Minimum four EIE symbol should be transmitted before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |xmtd_skip_ordered_set && xmtd_eie_before_fts_count > 4'b1000)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_TX_N"}),
                          .msg            ("Maximum eight EIE symbol can be transmitted before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_eie_os_all_lanes && current_speed_5gt == 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_TX_N"}),
                          .msg            ("Electrical Idle Exit sequence Ordered Set(EIEOS) should be detected only on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_NON_POLLING_STATE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           |xmtd_ts1 && |xmtd_compliance_receive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_COMPLIANCE_RECEIVE_SET_IN_NON_POLLING_STATE_N"}),
                          .msg            ("Complaince Receive bit can only be set in Polling Active state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_IN_ILLEGAL_STATE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                              ltssm_present_state !== ZI_LTSSM_CFG_RCVRCFG_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_IDLE_STATE && 
                              ltssm_present_state !== ZI_LTSSM_RECOVERY_SPEED_STATE &&
                              ltssm_present_state !== ZI_LTSSM_L0_STATE &&
                              xmtd_eie_os_all_lanes && current_speed_5gt == 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_IN_ILLEGAL_STATE_N"}),
                           .msg            ("EIEOS should not be transmitted in states other than Recovery.RcvrLk, Recovery.RcvrCfg and Configuration.Linkwidth.Start."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_NOT_SENT_BEFORE_FIRST_TS1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state === ZI_LTSSM_CFG_IDLE_STATE || ltssm_present_state === ZI_LTSSM_L0_STATE ||
                                ltssm_present_state === ZI_LTSSM_RX_L0s_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_IDLE_STATE || 
                                ltssm_present_state === ZI_LTSSM_L1_STATE) &&
                               current_speed_5gt == 1'b1 && |xmtd_ts1 && r_xmtd_eieos === 1'b0) || 
                              ((ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE || 
                                ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE ||
                                ltssm_present_state === ZI_LTSSM_RECOVERY_IDLE_STATE) && current_speed_5gt == 1'b1  && 
                               link_directed_to_config === 1'b1 && r_xmtd_eieos === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_NOT_SENT_BEFORE_FIRST_TS1_N"}),
                          .msg            ("EIEOS should be transmitted before first TS1 OS in Recovery.RcvrLk/Configuration.Linkwidth.Start on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIEOS_ILLEGAL_COUNT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(eie_counter === 6'd32 && (|xmtd_ts1 || |xmtd_ts2))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ILLEGAL_COUNT_N"}),
                          .msg            ("EIEOS should be transmitted every after 32 consecutive TS1 or TS2 OS on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_UPCONFIG_BIT_CHANGE_IN_CONFIG_COMPLETE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && |xmtd_ts2 &&
                              ts2_os_count_in_config_complete > 0 && (r_xmtd_upconfig_support !== (|xmtd_autonomous)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_BIT_CHANGE_IN_CONFIG_COMPLETE_N"}),
                          .msg            ("Device must not change upconfiguration bit(symbol 4 bit 6 of TS2) while in Configuration.Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_DATA_RATE_CHANGE_IN_CONFIG_COMPLETE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE
                           && |xmtd_ts2 && ts2_os_count_in_config_complete > 0 
                           && (r_xmtd_gen2_rate_support !== ((|xmtd_gen2) & (|xmtd_gen1))))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_DATA_RATE_CHANGE_IN_CONFIG_COMPLETE_N"}),
                          .msg            ("Device must not change data rate value while in Configuration.Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_RECO_LK_NOT_ENTERED_FROM_CONFIF_IDLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1  && phy_layer_checks_disable !== 1'b1)
                           &&(config_idle_illegal_timedout)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_RECO_LK_NOT_ENTERED_FROM_CONFIF_IDLE_N"}),
                          .msg            ("Device should enter to Recovery.Lk from Config.Idle after 2ms timeout if idle_2rlock_transitioned variable is 0."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_EIOS_NOT_SENT_PRIOR_TO_ENTERING_RECO_SPEED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && tx_eidle_active_lanes)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIOS_NOT_SENT_PRIOR_TO_ENTERING_RECO_SPEED_N"}),
                          .msg            ("Electrical Idle Ordered Set(EIOS) not sent prior to entering electrical idle in Recovery.Speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_RECO_SPEED_ILLEGAL_TRANSITION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(reco_speed_illegal_transition)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_RECO_SPEED_ILLEGAL_TRANSITION_N"}),
                          .msg            ("Device must not enter Recovery.Speed from Recovery.Cfg unless 32 TS2 are transmitted without being interrupted by EIEOS."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 
                              && r_xmtd_gen2_rate_support === 1'b0 && |xmtd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_TX_N"}),
                          .msg            ("Device is not capable of higher data rate but initiated speed change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_L1_IDLE_LT_40NS_ON_SPEED_NOT_2_5_GT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(l1_idle_less_than_40_ns)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_L1_IDLE_LT_40NS_ON_SPEED_NOT_2_5_GT_N"}),
                          .msg            ("Device should remain in L1.Idle for minimum of 40 ns on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_LK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && rcvd_ts1_os_count > 4'h8 
                              && |xmtd_ts1 && (|xmtd_speed_change === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_LK_N"}),
                          .msg            ("Device should set speed_change_bit in TS1 OS after receiving 8 consecutive TS1 OS with speed change bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_CFG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && rcvd_ts1_os_count >= 4'h8 
                              && |xmtd_ts2 && (|xmtd_speed_change === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_SPEED_CHANGE_BIT_IN_REC_CFG_N"}),
                          .msg            ("The speed change must be set to 1 in all TS2 OS in Recovery.RcvrCfg when it has initiated speed change in Recovery.RcvrLk."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHNG_OTHER_THAN_RECO_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_speed_change && ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE 
                              && ltssm_present_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE && ltssm_present_state !== ZI_LTSSM_L0_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHNG_OTHER_THAN_RECO_N"}),
                          .msg            ("The speed change bit must not be set to 1 in state other than Recovery."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHNG_NOT_0_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_speed_change && changed_speed_recovery === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHNG_NOT_0_N"}),
                          .msg            ("The speed change bit should be 0 after successful speed negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_ILLEGAL_RECO_SPEED_TO_RECO_CFG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_ILLEGAL_RECO_SPEED_TO_RECO_CFG_N"}),
                          .msg            ("Illegal state transtion from Recovery.Speed to Recover.Cfg."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_OTHER_DEVICE_NOT_CAPABLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 
                              && r_rcvd_gen2_rate_support === 1'b0 && |xmtd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_OTHER_DEVICE_NOT_CAPABLE_N"}),
                          .msg            ("Initiated speed change when other device is not capable of higher data rate."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |xmtd_ts1 && |xmtd_speed_change && xmtd_ts1_os_count_reco > 11'h8 
                              && current_speed_5gt === ((|xmtd_gen2) & (|xmtd_gen1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_TX_N"}),
                          .msg            ("When speed change initiated proposed data rate should be different from current running speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_link_width > link_width_reg && r_xmtd_upconfig_support === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_N"}),
                          .msg            ("Device is not capable of upconfiguration but initiated upconfiguration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
      end 
endgenerate

  // Additional gen1 code start
        A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_ACT_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE && 
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_ACT_P"}),
                          .msg            ("In Polling Active lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_CFG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_POLLING_CFG_STATE && 
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_CFG_P"}),
                          .msg            ("In Polling Configuration lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(((|xmtd_ts1) || (|xmtd_ts2)) && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && 
                           xmtd_link_num !== tx_lanes_bitmap && downstream_port === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_P"}),
                          .msg            ("In Configuration state link number must be non-PAD for downstream lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CONFIG_ILLEGAL_TS2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE &&
                              (negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_STATE || 
                               negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_DONE_STATE ||
                               negotiate_present_state === ZI_NEGOTIATE_IDLE_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CONFIG_ILLEGAL_TS2_P"}),
                          .msg            ("TS2 ordered set can only be transmitted in Configuration Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_NT_PAD_IN_CONFIG_START_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_lane_num === 1'b1 && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE &&
                              (negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_STATE || 
                               negotiate_present_state === ZI_NEGOTIATE_IDLE_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_CONFIG_START_P"}),
                          .msg            ("In configuration Linkwidth Start lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_NUM_MISMATCH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && tx_link_num_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_NUM_MISMATCH_P"}),
                          .msg            ("Single link number must be transmitted on all upstream lanes in configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_COMPLETE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && 
                           xmtd_link_num !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_COMPLETE_P"}),
                          .msg            ("In Configuration Complete state link number must be non-PAD in TS2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_LANE_PAD_IN_CONFIG_COMPLETE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && 
                           xmtd_lane_num !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_PAD_IN_CONFIG_COMPLETE_P"}),
                          .msg            ("In Configuration Complete state lane number must be non-PAD in TS2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_MISMATCH_IN_RECOVERY_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(((|xmtd_ts1 && ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE) ||
                               (|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE)) && 
                              xmtd_lane_num[0] === 1'b1 && r_tx_link_num !== tx_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_MISMATCH_IN_RECOVERY_P"}),
                          .msg            ("In Recovery state link number must be same as set in configuration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_RECOLK_NOT_ENTERED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && (ltssm_present_state === ZI_LTSSM_L0_STATE 
                                            || ltssm_present_state === ZI_LTSSM_L1_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RECOLK_NOT_ENTERED_P"}),
                          .msg            ("RecoLk should be entered first before moving to RecoCfg."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_RECOCFG_NOT_ENTERED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_data && ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && rcvd_ts1_os_count >= 4'h6)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RECOCFG_NOT_ENTERED_P"}),
                          .msg            ("RecoCfg should be entered first before moving to RecoIdle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DISABLE_NOT_ENTERED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(r_rcvd_ts1_with_disabled_count > 6'd3 && |xmtd_ts1 && xmtd_disable !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISABLE_NOT_ENTERED_P"}),
                          .msg            ("Device should enter Disable state after receiving two TS with disable bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_RESET_NOT_ENTERED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_ts1_with_reset_count > 6'd2 && |xmtd_ts1 && xmtd_reset !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESET_NOT_ENTERED_P"}),
                          .msg            ("Device should enter Link Reset state after receiving two TS with reset bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));  
        A_PCI_EXPRESS_LOOPBACK_NOT_ENTERED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_ts1_with_loopbk_count > 6'd2 && |xmtd_ts1 && xmtd_loopback !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOOPBACK_NOT_ENTERED_P"}),
                          .msg            ("Device should enter Loopback state after receiving two TS with loopback bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SCRAMBLING_DISABLE_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && |xmtd_no_scramble && ltssm_next_state !== ZI_LTSSM_CFG_COMPLETE_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SCRAMBLING_DISABLE_ERROR_P"}),
                          .msg            ("Scrambling can only be disabled at the end of configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_XMTD_DURING_COMPLIANCE_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_skip_ordered_set && ltssm_present_state === ZI_LTSSM_POLLING_COMPLIANCE_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_XMTD_DURING_COMPLIANCE_P"}),
                          .msg            ("Skip ordered set must not be transmitted while compliance pattern is in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L0S_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && tx_tlp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L0S_P"}),
                          .msg            ("No TLP communicaton allowed in L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L0S_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L0S_P"}),
                          .msg            ("No DLLP communicaton allowed in L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L1_STATE && (tx_tlp === 1'b1 || rx_tlp === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L1_P"}),
                          .msg            ("No TLP communicaton allowed in L1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L1_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L1_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L1_P"}),
                          .msg            ("No DLLP communicaton allowed in L1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L2_STATE && (tx_tlp === 1'b1 || rx_tlp === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L2_P"}),
                          .msg            ("No TLP communicaton allowed in L2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L2_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L2_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L2_P"}),
                          .msg            ("No DLLP communicaton allowed in L2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_L0S_ENTRY_WHEN_DISABLED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L0_STATE && xmtd_idle_os_all_lanes && L0s_entry_supported === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_L0S_ENTRY_WHEN_DISABLED_P"}),
                          .msg            ("Device must not enter L0s when ASPM L0s entry is disabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
  // Additional gen1 code end      
        A_PCI_EXPRESS_FTS_IN_NON_L0s_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_fts_os && ltssm_present_state !== ZI_LTSSM_TX_L0s_STATE && 
                           !transmitter_in_Los_flag)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_IN_NON_L0s_P"}),
                          .msg            ("Fast training sequences should be transmitted only during L0s state of the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DISABLE_OS_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1) && (ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE)
                           &&((xmtd_disable_count !== 6'b0 && xmtd_disable_count < 6'b10000 &&(|xmtd_ts2 || |xmtd_fts_os || |xmtd_idle_data || tx_eidle_active_lanes ||(|xmtd_ts1 && !xmtd_disable) || tx_dllp_tlp_on_link)) ||(xmtd_disable_count === 6'b100001 && |xmtd_disable))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISABLE_OS_ERROR_P"}),
                          .msg            ("Disable bit should be set in atleast 16 TS1 ordered sets and should not be set in more than 32 TS1 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_COUNT_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(sixteen_idle_data_counter !== 5'b0 && sixteen_idle_data_counter < 5'b10000 &&(|xmtd_ts1 || |xmtd_ts2 || |xmtd_fts_os || |xmtd_idle_os || tx_dllp_tlp_on_link))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_COUNT_ERROR_P"}),
                          .msg            ("Atleast 16 consecutive idle data should be transmitted after receiving idle data symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS2_COUNT_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1) && |int_rcvd_rx_lane_polarity
                           &&(sixteen_ts2_counter !== 5'b0 && 
                           sixteen_ts2_counter < 5'b10000 &&(|xmtd_ts1 || 
                           |xmtd_fts_os || |xmtd_idle_data || |xmtd_idle_os))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_COUNT_ERROR_P"}),
                          .msg            ("Atleast 16 TS2 ordered sets should be transmitted after receiving one TS2 ordered set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CODE_VIOLATION_LOOPBACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(loopback_master === 1'b1 &&
                           ((tx_code_violation & link_width_bitmap) !== link_width_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CODE_VIOLATION_LOOPBACK_P"}),
                          .msg            ("Code violations detected in loopback mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_RESET_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(link_reset_on_upstream_direction === 1'b1 && 
                           link_reset_issued_on_downstream === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_RESET_UPSTREAM_P"}),
                          .msg            ("Training control reset should not be issued in the upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_LINK_WIDTH_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(link_width_negotiated && link_width !== 1 && link_width !== 2     
                           && link_width !== 4 && link_width !== 8 && link_width !== 12
                           && link_width !== 16 && link_width !== 32)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LINK_WIDTH_P"}),
                          .msg            ("Invalid negotiated link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_IDLE_DATA_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && rcvd_ts2_os_count < 5'b1000) ||(ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           rcvd_ts2_os_all_lanes_count < 5'b1000)) && xmtd_idle_data)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_IDLE_DATA_P"}),
                          .msg            ("While waiting for eight TS2 ordered sets, idle data should not be transmitted before receiving eight TS2 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_TS2_OS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1) && |int_rcvd_rx_lane_polarity
                           &&(((ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE && 
                           rcvd_ts1_os_count < 4'b1000) ||
                           (ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE &&
                           rcvd_ts1_os_all_lanes_count < 5'b1000)) && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS2_OS_P"}),
                          .msg            ("While waiting for eight TS1 ordered sets, TS2 ordered sets should not be transmitted before receiving eight TS1 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_TS1_OS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_POLLING_CFG_STATE &&
                           rcvd_ts2_os_count < 5'b1000 && |xmtd_ts1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS1_OS_P"}),
                          .msg            ("While waiting for eight TS2 ordered sets, TS1 ordered sets should not be transmitted before receiving eight TS2 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_MIN_TS1_COUNT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE &&  
                           xmtd_ts1_os_count < MIN_TS1_COUNT && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MIN_TS1_COUNT_VIOLATION_P"}),
                          .msg            ("At least 'MIN_TS1_COUNT' number of TS1 ordered sets should be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_VALID_LINK_NUM_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE || 
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) && 
                           |xmtd_link_num) ||(ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE && 
                           |xmtd_ts2 && |xmtd_link_num))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VALID_LINK_NUM_TX_P"}),
                          .msg            ("Link numbers should be initialized only during link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE && 
                           downstream_port === 1'b0 && |xmtd_link_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_TX_P"}),
                          .msg            ("Upstream ports should not initiate link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE 
                           && downstream_port === 1'b0 && |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_TX_P"}),
                          .msg            ("Upstream ports should assign lane numbers only after they are initialized by downstream ports."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE ||
                           negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE) &&
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_TX_P"}),
                          .msg            ("Lane numbers should not be initialized before valid link number is assigned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && xmtd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_TX_P"}),
                          .msg            ("Illegal proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_TX_P"}),
                          .msg            ("Illegal counter proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(change_in_link_width_after_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_TX_P"}),
                          .msg            ("The number of lanes on which valid lane numbers are detected should not change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(counter_proposed_width_greater_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_TX_P"}),
                          .msg            ("Counter proposed width should not be greater than the proposed width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_ASSIGN_ERROR_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b1 && xmtd_lane_num > r_rcvd_link_num &&
                           r_xmtd_lane_num !== xmtd_lane_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_ASSIGN_ERROR_TX_P"}),
                          .msg            ("The downstream ports should assign valid lane numbers on lanes for which the upstream port has responded with link number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS1_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 === 1'b1 &&(xmtd_ts1 !== 32'h1 && xmtd_ts1 !== 32'h3
                           && xmtd_ts1 !== 32'hF && xmtd_ts1 !== 32'hFF && 
                           xmtd_ts1 !== 32'hFFF && xmtd_ts1 !== 32'hFFFF &&
                           xmtd_ts1 !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_NOT_ALL_LANES_TX_P"}),
                          .msg            ("TS1 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS2_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 === 1'b1 &&(xmtd_ts2 !== 32'h1 && xmtd_ts2 !== 32'h3              
                           && xmtd_ts2 !== 32'hF && xmtd_ts2 !== 32'hFF && 
                           xmtd_ts2 !== 32'hFFF && xmtd_ts2 !== 32'hFFFF &&
                           xmtd_ts2 !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_NOT_ALL_LANES_TX_P"}),
                          .msg            ("TS2 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_skip_ordered_set === 1'b1 &&(xmtd_skip_ordered_set !== 32'h1 &&
                           xmtd_skip_ordered_set !== 32'h3 &&
                           xmtd_skip_ordered_set !== 32'hF &&
                           xmtd_skip_ordered_set !== 32'hFF &&
                           xmtd_skip_ordered_set !== 32'hFFF &&
                           xmtd_skip_ordered_set !== 32'hFFFF &&
                           xmtd_skip_ordered_set !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_ALL_LANES_TX_P"}),
                          .msg            ("SKP ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDL_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_os === 1'b1 && xmtd_idle_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_ALL_LANES_TX_P"}),
                          .msg            ("Electrical idle ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_FTS_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_fts_os === 1'b1 && xmtd_fts_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_ALL_LANES_TX_P"}),
                          .msg            ("FTS ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_data === 1'b1 && xmtd_idle_data !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_TX_P"}),
                          .msg            ("Idle data should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((|xmtd_reset && xmtd_reset !== tx_lanes_bitmap) ||(|xmtd_loopback && xmtd_loopback !== tx_lanes_bitmap) ||(|xmtd_disable && xmtd_disable !== tx_lanes_bitmap) ||(|xmtd_no_scramble && xmtd_no_scramble !== tx_lanes_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_TX_P"}),
                          .msg            ("Link control field of all the TS1/TS2 ordered sets should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_LINK_MISMATCH_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_lane_num === 1'b1 && xmtd_lane_num !== xmtd_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_LINK_MISMATCH_TX_P"}),
                          .msg            ("Once lane numbers are assigned in the TS1/TS2 ordered sets, the number of lanes on which valid lane numbers are detected should be equal to the number of lanes on which valid link numbers are detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NO_SKP_AFTER_FTS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_fts_flag === 1'b1 &&(|xmtd_idle_data || |xmtd_idle_os 
                           || |xmtd_ts1 || |xmtd_ts2 || tx_dllp_tlp_on_link))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_SKP_AFTER_FTS_P"}),
                          .msg            ("A single SKP ordered set should always be transmitted after the fast training sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&
                           (|xmtd_idle_data && |tx_valid))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_TX_P"}),
                          .msg            ("Idle data should be detected after link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_N_FTS_NOT_SAME_TX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(tx_n_fts_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_N_FTS_NOT_SAME_TX_P"}),
                          .msg            ("'n_fts' field of all the TS ordered sets should be same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_FTS_COUNT_ERROR_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(fts_count_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_COUNT_ERROR_P"}),
                          .msg            ("The number of FTS ordered sets detected should be equal to the specified number of FTS in TS OS during training."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_WITHIN_N_FTS_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_within_n_fts)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_WITHIN_N_FTS_P"}),
                          .msg            ("SKP ordered set should not be transmitted within first 'rx_n_fts' number of FTS ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
  // Additional gen1 code start
        A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_ACT_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE && 
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_ACT_N"}),
                          .msg            ("In Polling Active lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_CFG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_POLLING_CFG_STATE && 
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_POLLING_CFG_N"}),
                          .msg            ("In Polling Configuration lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(((|xmtd_ts1) || (|xmtd_ts2)) && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && 
                           xmtd_link_num !== tx_lanes_bitmap && downstream_port === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_N"}),
                          .msg            ("In Configuration state link number must be non-PAD for downstream lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CONFIG_ILLEGAL_TS2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE &&
                              (negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_STATE || 
                               negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_DONE_STATE ||
                               negotiate_present_state === ZI_NEGOTIATE_IDLE_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CONFIG_ILLEGAL_TS2_N"}),
                          .msg            ("TS2 ordered set can only be transmitted in Configuration Complete state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_NT_PAD_IN_CONFIG_START_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 && |xmtd_lane_num === 1'b1 && ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE &&
                              (negotiate_present_state === ZI_NEGOTIATE_LINK_NUM_STATE || 
                               negotiate_present_state === ZI_NEGOTIATE_IDLE_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_NT_PAD_IN_CONFIG_START_N"}),
                          .msg            ("In configuration Linkwidth Start lane number must be set to PAD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_NUM_MISMATCH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && tx_link_num_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_NUM_MISMATCH_N"}),
                          .msg            ("Single link number must be transmitted on all upstream lanes in configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_COMPLETE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && 
                           xmtd_link_num !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_PAD_IN_CONFIG_COMPLETE_N"}),
                          .msg            ("In Configuration Complete state link number must be non-PAD in TS2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_LANE_PAD_IN_CONFIG_COMPLETE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && 
                           xmtd_lane_num !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_PAD_IN_CONFIG_COMPLETE_N"}),
                          .msg            ("In Configuration Complete state lane number must be non-PAD in TS2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_MISMATCH_IN_RECOVERY_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(((|xmtd_ts1 && ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE) ||
                               (|xmtd_ts2 && ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE)) && 
                              xmtd_lane_num[0] === 1'b1 && r_tx_link_num !== tx_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_MISMATCH_IN_RECOVERY_N"}),
                          .msg            ("In Recovery state link number must be same as set in configuration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_RECOLK_NOT_ENTERED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && (ltssm_present_state === ZI_LTSSM_L0_STATE 
                                            || ltssm_present_state === ZI_LTSSM_L1_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RECOLK_NOT_ENTERED_N"}),
                          .msg            ("RecoLk should be entered first before moving to RecoCfg."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0)); 
        A_PCI_EXPRESS_RECOCFG_NOT_ENTERED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_data && ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && rcvd_ts1_os_count >= 4'h6)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RECOCFG_NOT_ENTERED_N"}),
                          .msg            ("RecoCfg should be entered first before moving to RecoIdle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DISABLE_NOT_ENTERED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(r_rcvd_ts1_with_disabled_count > 6'd3 && |xmtd_ts1 && xmtd_disable !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISABLE_NOT_ENTERED_N"}),
                          .msg            ("Device should enter Disable state after receiving two TS with disable bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_RESET_NOT_ENTERED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_ts1_with_reset_count > 6'd2 && |xmtd_ts1 && xmtd_reset !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESET_NOT_ENTERED_N"}),
                          .msg            ("Device should enter Link Reset state after receiving two TS with reset bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));  
        A_PCI_EXPRESS_LOOPBACK_NOT_ENTERED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_ts1_with_loopbk_count > 6'd2 && |xmtd_ts1 && xmtd_loopback !== tx_lanes_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LOOPBACK_NOT_ENTERED_N"}),
                          .msg            ("Device should enter Loopback state after receiving two TS with loopback bit set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SCRAMBLING_DISABLE_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 && |xmtd_no_scramble && ltssm_next_state !== ZI_LTSSM_CFG_COMPLETE_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SCRAMBLING_DISABLE_ERROR_N"}),
                          .msg            ("Scrambling can only be disabled at the end of configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_XMTD_DURING_COMPLIANCE_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_skip_ordered_set && ltssm_present_state === ZI_LTSSM_POLLING_COMPLIANCE_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_XMTD_DURING_COMPLIANCE_N"}),
                          .msg            ("Skip ordered set must not be transmitted while compliance pattern is in progress."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L0S_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && tx_tlp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L0S_N"}),
                          .msg            ("No TLP communicaton allowed in L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L0S_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L0S_N"}),
                          .msg            ("No DLLP communicaton allowed in L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L1_STATE && (tx_tlp === 1'b1 || rx_tlp === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L1_N"}),
                          .msg            ("No TLP communicaton allowed in L1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L1_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L1_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L1_N"}),
                          .msg            ("No DLLP communicaton allowed in L1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLP_IN_L2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L2_STATE && (tx_tlp === 1'b1 || rx_tlp === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLP_IN_L2_N"}),
                          .msg            ("No TLP communicaton allowed in L2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DLLP_IN_L2_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L2_STATE && tx_dllp === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DLLP_IN_L2_N"}),
                          .msg            ("No DLLP communicaton allowed in L2."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));  
        A_PCI_EXPRESS_L0S_ENTRY_WHEN_DISABLED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_L0_STATE && xmtd_idle_os_all_lanes && L0s_entry_supported === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_L0S_ENTRY_WHEN_DISABLED_N"}),
                          .msg            ("Device must not enter L0s when ASPM L0s entry is disabled."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));  
  // Additional gen1 code end   
        A_PCI_EXPRESS_FTS_IN_NON_L0s_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_fts_os && ltssm_present_state !== ZI_LTSSM_TX_L0s_STATE && 
                           !transmitter_in_Los_flag)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_IN_NON_L0s_N"}),
                          .msg            ("Fast training sequences should be transmitted only during L0s state of the device."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_DISABLE_OS_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && (ltssm_present_state !== ZI_LTSSM_RECOVERY_LOCK_STATE)
                           &&((xmtd_disable_count !== 6'b0 && xmtd_disable_count < 6'b10000 &&(|xmtd_ts2 || |xmtd_fts_os || |xmtd_idle_data || tx_eidle_active_lanes ||(|xmtd_ts1 && !xmtd_disable) || tx_dllp_tlp_on_link)) ||(xmtd_disable_count === 6'b100001 && |xmtd_disable))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DISABLE_OS_ERROR_N"}),
                          .msg            ("Disable bit should be set in atleast 16 TS1 ordered sets and should not be set in more than 32 TS1 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_COUNT_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(sixteen_idle_data_counter !== 5'b0 && 
                           sixteen_idle_data_counter < 5'b10000 &&(|xmtd_ts1 || |xmtd_ts2
                           || |xmtd_fts_os || |xmtd_idle_os || tx_dllp_tlp_on_link))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_COUNT_ERROR_N"}),
                          .msg            ("Atleast 16 consecutive idle data should be transmitted after receiving idle data symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS2_COUNT_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&     
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && |int_rcvd_rx_lane_polarity
                           &&(sixteen_ts2_counter !== 5'b0 && 
                           sixteen_ts2_counter < 5'b10000 &&(|xmtd_ts1 || |xmtd_fts_os || |xmtd_idle_data
                           || |xmtd_idle_os))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_COUNT_ERROR_N"}),
                          .msg            ("Atleast 16 TS2 ordered sets should be transmitted after receiving one TS2 ordered set."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CODE_VIOLATION_LOOPBACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(loopback_master === 1'b1 &&((tx_code_violation & 
                           link_width_bitmap) !== link_width_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CODE_VIOLATION_LOOPBACK_N"}),
                          .msg            ("Code violations detected in loopback mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_RESET_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(link_reset_on_upstream_direction === 1'b1 &&             
                           link_reset_issued_on_downstream === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_RESET_UPSTREAM_N"}),
                          .msg            ("Training control reset should not be issued in the upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_LINK_WIDTH_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(link_width_negotiated && link_width !== 1 && 
                           link_width !== 2 && link_width !== 4 && link_width !== 8 && link_width !== 12
                           && link_width !== 16 && link_width !== 32)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_LINK_WIDTH_N"}),
                          .msg            ("Invalid negotiated link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_IDLE_DATA_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state === ZI_LTSSM_CFG_COMPLETE_STATE && 
                           rcvd_ts2_os_count < 5'b1000) ||
                           (ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           rcvd_ts2_os_all_lanes_count < 5'b1000)) && xmtd_idle_data)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_IDLE_DATA_N"}),
                          .msg            ("While waiting for eight TS2 ordered sets, idle data should not be transmitted before receiving eight TS2 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_TS2_OS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1) && |int_rcvd_rx_lane_polarity
                           &&(((ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE &&  
                           rcvd_ts1_os_count < 4'b1000) ||
                           (ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE &&
                           rcvd_ts1_os_all_lanes_count < 5'b1000)) && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS2_OS_N"}),
                          .msg            ("While waiting for eight TS1 ordered sets, TS2 ordered sets should not be transmitted before receiving eight TS1 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ILLEGAL_TS1_OS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_POLLING_CFG_STATE && 
                           rcvd_ts2_os_count < 5'b1000 && |xmtd_ts1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ILLEGAL_TS1_OS_N"}),
                          .msg            ("While waiting for eight TS2 ordered sets, TS1 ordered sets should not be transmitted before receiving eight TS2 ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_MIN_TS1_COUNT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE &&             
                           xmtd_ts1_os_count < MIN_TS1_COUNT && |xmtd_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_MIN_TS1_COUNT_VIOLATION_N"}),
                          .msg            ("At least 'MIN_TS1_COUNT' number of TS1 ordered sets should be transmitted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_VALID_LINK_NUM_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE || 
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) &&
                           |xmtd_link_num) ||(ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE &&
                           (|xmtd_ts2 && |xmtd_link_num)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VALID_LINK_NUM_TX_N"}),
                          .msg            ("Link numbers should be initialized only during link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE &&            
                           downstream_port === 1'b0 && |xmtd_link_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_TX_N"}),
                          .msg            ("Upstream ports should not initiate link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE &&            
                           downstream_port === 1'b0 && |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_TX_N"}),
                          .msg            ("Upstream ports should assign lane numbers only after they are initialized by downstream ports."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE ||              
                           negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE) &&
                           |xmtd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_TX_N"}),
                          .msg            ("Lane numbers should not be initialized before valid link number is assigned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && xmtd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_TX_N"}),
                          .msg            ("Illegal proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_TX_N"}),
                          .msg            ("Illegal counter proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(change_in_link_width_after_ts2)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_TX_N"}),
                          .msg            ("The number of lanes on which valid lane numbers are detected should not change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&       
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(counter_proposed_width_greater_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_TX_N"}),
                          .msg            ("Counter proposed width should not be greater than the proposed width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_ASSIGN_ERROR_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk   ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b1 && xmtd_lane_num > r_rcvd_link_num &&
                           r_xmtd_lane_num !== xmtd_lane_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_ASSIGN_ERROR_TX_N"}),
                          .msg            ("The downstream ports should assign valid lane numbers on lanes for which the upstream port has responded with link number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS1_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts1 === 1'b1 &&(xmtd_ts1 !== 32'h1 && xmtd_ts1 !== 32'h3              
                           && xmtd_ts1 !== 32'hF && xmtd_ts1 !== 32'hFF &&
                           xmtd_ts1 !== 32'hFFF && xmtd_ts1 !== 32'hFFFF &&
                           xmtd_ts1 !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_NOT_ALL_LANES_TX_N"}),
                          .msg            ("TS1 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TS2_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_ts2 === 1'b1 &&(xmtd_ts2 !== 32'h1 && xmtd_ts2 !== 32'h3              
                           && xmtd_ts2 !== 32'hF && xmtd_ts2 !== 32'hFF &&
                           xmtd_ts2 !== 32'hFFF && xmtd_ts2 !== 32'hFFFF &&
                           xmtd_ts2 !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_NOT_ALL_LANES_TX_N"}),
                          .msg            ("TS2 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_skip_ordered_set === 1'b1 &&(xmtd_skip_ordered_set !== 32'h1 &&
                           xmtd_skip_ordered_set !== 32'h3 &&
                           xmtd_skip_ordered_set !== 32'hF &&
                           xmtd_skip_ordered_set !== 32'hFF &&
                           xmtd_skip_ordered_set !== 32'hFFF &&
                           xmtd_skip_ordered_set !== 32'hFFFF &&
                           xmtd_skip_ordered_set !== 32'hFFFF_FFFF))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_ALL_LANES_TX_N"}),
                          .msg            ("SKP ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDL_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_os === 1'b1 && xmtd_idle_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_ALL_LANES_TX_N"}),
                          .msg            ("Electrical idle ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_FTS_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_fts_os === 1'b1 && xmtd_fts_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_ALL_LANES_TX_N"}),
                          .msg            ("FTS ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_idle_data === 1'b1 && xmtd_idle_data !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_TX_N"}),
                          .msg            ("Idle data should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&((|xmtd_reset && xmtd_reset !== tx_lanes_bitmap) ||
                           (|xmtd_loopback && xmtd_loopback !== tx_lanes_bitmap) ||
                           (|xmtd_disable && xmtd_disable !== tx_lanes_bitmap) ||
                           (|xmtd_no_scramble && xmtd_no_scramble !== tx_lanes_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_TX_N"}),
                          .msg            ("Link control field of all the TS1/TS2 ordered sets should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_LANE_LINK_MISMATCH_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&      
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(|xmtd_lane_num === 1'b1 && xmtd_lane_num !== xmtd_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_LINK_MISMATCH_TX_N"}),
                          .msg            ("Once lane numbers are assigned in the TS1/TS2 ordered sets, the number of lanes on which valid lane numbers are detected should be equal to the number of lanes on which valid link numbers are detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NO_SKP_AFTER_FTS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(xmtd_fts_flag === 1'b1 &&(|xmtd_idle_data || |xmtd_idle_os
                           || |xmtd_ts1 || |xmtd_ts2 || tx_dllp_tlp_on_link))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NO_SKP_AFTER_FTS_N"}),
                          .msg            ("A single SKP ordered set should always be transmitted after the fast training sequence."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&       
                           |xmtd_idle_data && |tx_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_TX_N"}),
                          .msg            ("Idle data should be detected after link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_N_FTS_NOT_SAME_TX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(tx_n_fts_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_N_FTS_NOT_SAME_TX_N"}),
                          .msg            ("'n_fts' field of all the TS ordered sets should be same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_FTS_COUNT_ERROR_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(fts_count_error)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_COUNT_ERROR_N"}),
                          .msg            ("The number of FTS ordered sets detected should be equal to the specified number of FTS in TS OS during training."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_SKP_WITHIN_N_FTS_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(skp_within_n_fts)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_WITHIN_N_FTS_N"}),
                          .msg            ("SKP ordered set should not be transmitted within first 'rx_n_fts' number of FTS ordered sets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));

// Checks with constraint mode
generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assert_PCI_EXPRESS_GEN2_QVL_PROPERTY_TYPE
        // Assertions with positive clock
        A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count < 4'b0100)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_P"}),
                          .msg            ("Minimum four EIE symbol should be received before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count > 4'b1000)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_P"}),
                          .msg            ("Maximum eight EIE symbol can be received before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_eie_os_all_lanes && current_speed_5gt == 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_RX_P"}),
                          .msg            ("Electrical Idle Exit sequence Ordered Set(EIEOS) should be detected only on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 
                              && r_rcvd_gen2_rate_support === 1'b0 && |rcvd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_P"}),
                          .msg            ("Device is not capable of higher data rate but initiated speed change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 && |rcvd_speed_change && rcvd_ts1_os_count > 4'h8 
                              && current_speed_5gt === ((|rcvd_gen2) & (|rcvd_gen1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_P"}),
                          .msg            ("When speed change initiated proposed data rate should be different from current running speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_link_width > link_width_reg && r_rcvd_upconfig_support === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_P"}),
                          .msg            ("Device is not capable of upconfiguration but initiated upconfiguration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));


        // Assertions with negative clock
        A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count < 4'b0100)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_N"}),
                          .msg            ("Minimum four EIE symbol should be received before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count > 4'b1000)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_N"}),
                          .msg            ("Maximum eight EIE symbol can be received before FTS on speed other than 2.5 GT/s while exiting L0s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_eie_os_all_lanes && current_speed_5gt == 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_EIEOS_ON_2_5_GT_RX_N"}),
                          .msg            ("Electrical Idle Exit sequence Ordered Set(EIEOS) should be detected only on speed greater than 2.5 GT/s."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 
                           && r_rcvd_gen2_rate_support === 1'b0 && |rcvd_speed_change )))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_N"}),
                          .msg            ("Device is not capable of higher data rate but initiated speed change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 && |rcvd_speed_change && rcvd_ts1_os_count > 4'h8
                              && current_speed_5gt === ((|rcvd_gen2) & (|rcvd_gen1)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_N"}),
                          .msg            ("When speed change initiated proposed data rate should be different from current running speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_link_width > link_width_reg && r_rcvd_upconfig_support === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_N"}),
                          .msg            ("Device is not capable of upconfiguration but initiated upconfiguration."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        
      end 

  // Additional gen1 code start 
        A_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && rx_link_num_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_P"}),
                          .msg            ("Single link number must be received on all upstream lanes in configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));         
  // Additional gen1 code end
        
        A_PCI_EXPRESS_VALID_LINK_NUM_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE ||
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) &&
                           int_rcvd_link_num) ||(|int_rcvd_ts2 && |int_rcvd_link_num &&
                           ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VALID_LINK_NUM_RX_P"}),
                          .msg            ("Link numbers should be initialized only during link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE &&          
                           downstream_port === 1'b1 && |int_rcvd_link_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_P"}),
                          .msg            ("Upstream ports should not initiate link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_P"}),
                          .msg            ("Upstream ports should assign lane numbers only after they are initialized by downstream ports."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE ||              
                           negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE) &&
                           |int_rcvd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_P"}),
                          .msg            ("Lane numbers should not be initialized before valid link number is assigned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_P"}),
                          .msg            ("Illegal proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_P"}),
                          .msg            ("Illegal counter proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_CFG_STATE &&
                           |int_rcvd_ts2 === 1'b1 &&(r_rcvd_lane_num !== int_rcvd_lane_num ||
                           int_rcvd_lane_num !== r_xmtd_lane_num))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_P"}),
                          .msg            ("The number of lanes on which valid lane numbers are detected should not change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_ts1 === 1'b1 && downstream_port === 1'b1 &&
                           ((int_rcvd_lane_num > r_xmtd_lane_num && r_rcvd_lane_num !== int_rcvd_lane_num)
                           ||(int_rcvd_link_num > r_xmtd_link_num && 
                           r_rcvd_link_num !== int_rcvd_link_num)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_P"}),
                          .msg            ("Counter proposed width should not be greater than the proposed width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b0 && int_rcvd_lane_num > r_xmtd_link_num &&
                           r_rcvd_lane_num !== int_rcvd_lane_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_P"}),
                          .msg            ("The downstream ports should assign valid lane numbers on lanes for which the upstream port has responded with link number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE) 
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE) 
                           && (|int_rcvd_ts1 === 1'b1 && int_rcvd_ts1 !== 32'h1 && int_rcvd_ts1 !== 32'h3 &&             
                           int_rcvd_ts1 !== 32'hF && int_rcvd_ts1 !== 32'hFF && int_rcvd_ts1 !== 32'hFFF
                           && int_rcvd_ts1 !== 32'hFFFF && int_rcvd_ts1 !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_P"}),
                          .msg            ("TS1 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_ts2 === 1'b1 && int_rcvd_ts2 !== 32'h1 && int_rcvd_ts2 !== 32'h3 &&             
                           int_rcvd_ts2 !== 32'hF && int_rcvd_ts2 !== 32'hFF && int_rcvd_ts2 !== 32'hFFF 
                           && int_rcvd_ts2 !== 32'hFFFF && int_rcvd_ts2 !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_P"}),
                          .msg            ("TS2 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_skip_ordered_set === 1'b1 && int_rcvd_skip_ordered_set !== 32'h1 
                           && int_rcvd_skip_ordered_set !== 32'h3 &&
                           int_rcvd_skip_ordered_set !== 32'hF &&
                           int_rcvd_skip_ordered_set !== 32'hFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_P"}),
                          .msg            ("SKP ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_idle_os === 1'b1 && int_rcvd_idle_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_P"}),
                          .msg            ("Electrical idle ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_fts_os === 1'b1 && int_rcvd_fts_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_P"}),
                          .msg            ("FTS ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_idle_data === 1'b1 && int_rcvd_idle_data !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_P"}),
                          .msg            ("Idle data should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((|int_rcvd_reset && int_rcvd_reset !== rx_lanes_bitmap) ||
                           (|int_rcvd_loopback && int_rcvd_loopback !== rx_lanes_bitmap) ||
                           (|int_rcvd_disable && int_rcvd_disable !== rx_lanes_bitmap) ||
                           (|int_rcvd_no_scramble && int_rcvd_no_scramble !== rx_lanes_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_P"}),
                          .msg            ("Link control field of all the TS1/TS2 ordered sets should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_lane_num === 1'b1 && int_rcvd_lane_num !== int_rcvd_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_P"}),
                          .msg            ("Once lane numbers are assigned in the TS1/TS2 ordered sets, the number of lanes on which valid lane numbers are detected should be equal to the number of lanes on which valid link numbers are detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&           
                           |int_rcvd_idle_data && |int_rx_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_P"}),
                          .msg            ("Idle data should be detected after link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_N_FTS_NOT_SAME_RX_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&      
                           phy_layer_checks_disable !== 1'b1)
                           &&(rx_n_fts_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_N_FTS_NOT_SAME_RX_P"}),
                          .msg            ("'n_fts' field of all the TS ordered sets should be same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
  
  // Additional gen1 code start 
        A_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && rx_link_num_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_N"}),
                          .msg            ("Single link number must be received on all upstream lanes in configuration state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));         
  // Additional gen1 code end

        A_PCI_EXPRESS_VALID_LINK_NUM_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE ||             
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) &&
                           int_rcvd_link_num) ||(|int_rcvd_ts2 && |int_rcvd_link_num &&
                           ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_VALID_LINK_NUM_RX_N"}),
                          .msg            ("Link numbers should be initialized only during link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_link_num === 1'b1)))))              
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_N"}),
                          .msg            ("Upstream ports should not initiate link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_N"}),
                          .msg            ("Upstream ports should assign lane numbers only after they are initialized by downstream ports."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE ||              
                           negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE) &&
                           |int_rcvd_lane_num === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_N"}),
                          .msg            ("Lane numbers should not be initialized before valid link number is assigned."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(downstream_port === 1'b0 && rcvd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_N"}),
                          .msg            ("Illegal proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(downstream_port === 1'b1 && rcvd_width_error === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_N"}),
                          .msg            ("Illegal counter proposed link width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_CFG_STATE &&
                           |int_rcvd_ts2 === 1'b1 &&(r_rcvd_lane_num !== int_rcvd_lane_num ||
                           int_rcvd_lane_num !== r_xmtd_lane_num))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_N"}),
                          .msg            ("The number of lanes on which valid lane numbers are detected should not change."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_ts1 === 1'b1 && downstream_port === 1'b1 &&
                           ((int_rcvd_lane_num > r_xmtd_lane_num && r_rcvd_lane_num !== int_rcvd_lane_num)
                           ||(int_rcvd_link_num > r_xmtd_link_num &&
                           r_rcvd_link_num !== int_rcvd_link_num)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_N"}),
                          .msg            ("Counter proposed width should not be greater than the proposed width."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b0 && int_rcvd_lane_num > r_xmtd_link_num &&
                           r_rcvd_lane_num !== int_rcvd_lane_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_N"}),
                          .msg            ("The downstream ports should assign valid lane numbers on lanes for which the upstream port has responded with link number."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE) 
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE) 
                           && (|int_rcvd_ts1 === 1'b1 && int_rcvd_ts1 !== 32'h1 && int_rcvd_ts1 !== 32'h3 &&
                           int_rcvd_ts1 !== 32'hF && int_rcvd_ts1 !== 32'hFF && int_rcvd_ts1 !== 32'hFFF
                           && int_rcvd_ts1 !== 32'hFFFF && int_rcvd_ts1 !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_N"}),
                          .msg            ("TS1 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_ts2 === 1'b1 && int_rcvd_ts2 !== 32'h1 && int_rcvd_ts2 !== 32'h3 &&
                           int_rcvd_ts2 !== 32'hF && int_rcvd_ts2 !== 32'hFF && int_rcvd_ts2 !== 32'hFFF
                           && int_rcvd_ts2 !== 32'hFFFF && int_rcvd_ts2 !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_N"}),
                          .msg            ("TS2 ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_skip_ordered_set === 1'b1 && int_rcvd_skip_ordered_set !== 32'h1 
                           && int_rcvd_skip_ordered_set !== 32'h3 &&
                           int_rcvd_skip_ordered_set !== 32'hF &&
                           int_rcvd_skip_ordered_set !== 32'hFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF_FFFF)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_N"}),
                          .msg            ("SKP ordered sets must be detected only on 1, 2, 4, 8, 12, 16, or 32 lanes and must be detected on consecutive lanes."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_idle_os === 1'b1 && int_rcvd_idle_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_N"}),
                          .msg            ("Electrical idle ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_fts_os === 1'b1 && int_rcvd_fts_os !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_N"}),
                          .msg            ("FTS ordered sets should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_idle_data === 1'b1 && int_rcvd_idle_data !== link_width_bitmap)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_N"}),
                          .msg            ("Idle data should be detected on all lanes of the link."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&((|int_rcvd_reset && int_rcvd_reset !== rx_lanes_bitmap) ||
                           (|int_rcvd_loopback && int_rcvd_loopback !== rx_lanes_bitmap) ||
                           (|int_rcvd_disable && int_rcvd_disable !== rx_lanes_bitmap) ||
                           (|int_rcvd_no_scramble && int_rcvd_no_scramble !== rx_lanes_bitmap))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_N"}),
                          .msg            ("Link control field of all the TS1/TS2 ordered sets should be equal."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_lane_num === 1'b1 && int_rcvd_lane_num !== int_rcvd_link_num)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_N"}),
                          .msg            ("Once lane numbers are assigned in the TS1/TS2 ordered sets, the number of lanes on which valid lane numbers are detected should be equal to the number of lanes on which valid link numbers are detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&
                           |int_rcvd_idle_data && |int_rx_valid)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_N"}),
                          .msg            ("Idle data should be detected after link width negotiation."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_N_FTS_NOT_SAME_RX_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(rx_n_fts_field_not_same)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_N_FTS_NOT_SAME_RX_N"}),
                          .msg            ("'n_fts' field of all the TS ordered sets should be same."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER
    if( PCI_EXPRESS_GEN2 == 1)
      begin : qvl_assume_PCI_EXPRESS_GEN2_QVL_PROPERTY_TYPE
        // Assertions with positive clock
        M_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count < 4'b0100)))));
        M_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count > 4'b1000)))));
        M_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 
                           && r_rcvd_gen2_rate_support === 1'b0 && |rcvd_speed_change )))));
        M_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 && |rcvd_speed_change && rcvd_ts1_os_count > 4'h8
                              && current_speed_5gt === ((|rcvd_gen2) & (|rcvd_gen1)))))));
        M_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_link_width > link_width_reg && r_rcvd_upconfig_support === 1'b0)))));
        
        // Assertions with negative clock
        M_PCI_EXPRESS_GEN2_EIE_LT_4_BEFORE_FTS_ON_NON_2_5_GT_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count < 4'b0100)))));
        M_PCI_EXPRESS_GEN2_EIE_MT_8_BEFORE_FTS_ON_NON_2_5_GT_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RX_L0s_STATE && current_speed_5gt === 1'b1 &&
                           |rcvd_skip_ordered_set && rcvd_eie_before_fts_count > 4'b1000)))));
        M_PCI_EXPRESS_GEN2_SPEED_CHANGE_INITIATED_WHEN_NOT_CAPABLE_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 
                           && r_rcvd_gen2_rate_support === 1'b0 && |rcvd_speed_change )))));
        M_PCI_EXPRESS_GEN2_SPEED_CHANGE_MISMATCH_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && |rcvd_ts1 && |rcvd_speed_change && rcvd_ts1_os_count > 4'h8 
                              && current_speed_5gt === ((|rcvd_gen2) & (|rcvd_gen1)))))));
        M_PCI_EXPRESS_GEN2_UPCONFIG_INITIATED_WHEN_NOT_CAPABLE_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk  ),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(rcvd_link_width > link_width_reg && r_rcvd_upconfig_support === 1'b0)))));
      end 
  // Additional gen1 code start 
        M_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && rx_link_num_field_not_same)))));
  // Additional gen1 code end
        M_PCI_EXPRESS_VALID_LINK_NUM_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE ||
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) &&
                           int_rcvd_link_num) ||(|int_rcvd_ts2 && |int_rcvd_link_num &&
                           ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE))))));
        M_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE &&          
                           downstream_port === 1'b1 && |int_rcvd_link_num === 1'b1)))));
        M_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_lane_num === 1'b1)))));
        M_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE ||              
                           negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE) &&
                           |int_rcvd_lane_num === 1'b1)))));
        M_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_width_error === 1'b1)))));
        M_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_width_error === 1'b1)))));
        M_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_CFG_STATE &&
                           |int_rcvd_ts2 === 1'b1 &&(r_rcvd_lane_num !== int_rcvd_lane_num ||
                           int_rcvd_lane_num !== r_xmtd_lane_num))))));
        M_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_ts1 === 1'b1 && downstream_port === 1'b1 &&
                           ((int_rcvd_lane_num > r_xmtd_lane_num && r_rcvd_lane_num !== int_rcvd_lane_num)
                           ||(int_rcvd_link_num > r_xmtd_link_num && 
                           r_rcvd_link_num !== int_rcvd_link_num)))))));
        M_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b0 && int_rcvd_lane_num > r_xmtd_link_num &&
                           r_rcvd_lane_num !== int_rcvd_lane_num)))));
        M_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE) 
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE) 
                           && (|int_rcvd_ts1 === 1'b1 && int_rcvd_ts1 !== 32'h1 && int_rcvd_ts1 !== 32'h3 &&             
                           int_rcvd_ts1 !== 32'hF && int_rcvd_ts1 !== 32'hFF && int_rcvd_ts1 !== 32'hFFF
                           && int_rcvd_ts1 !== 32'hFFFF && int_rcvd_ts1 !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_ts2 === 1'b1 && int_rcvd_ts2 !== 32'h1 && int_rcvd_ts2 !== 32'h3 &&             
                           int_rcvd_ts2 !== 32'hF && int_rcvd_ts2 !== 32'hFF && int_rcvd_ts2 !== 32'hFFF 
                           && int_rcvd_ts2 !== 32'hFFFF && int_rcvd_ts2 !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_skip_ordered_set === 1'b1 && int_rcvd_skip_ordered_set !== 32'h1 
                           && int_rcvd_skip_ordered_set !== 32'h3 &&
                           int_rcvd_skip_ordered_set !== 32'hF &&
                           int_rcvd_skip_ordered_set !== 32'hFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_idle_os === 1'b1 && int_rcvd_idle_os !== link_width_bitmap)))));
        M_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_fts_os === 1'b1 && int_rcvd_fts_os !== link_width_bitmap)))));
        M_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_idle_data === 1'b1 && int_rcvd_idle_data !== link_width_bitmap)))));
        M_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&((|int_rcvd_reset && int_rcvd_reset !== rx_lanes_bitmap) ||
                           (|int_rcvd_loopback && int_rcvd_loopback !== rx_lanes_bitmap) ||
                           (|int_rcvd_disable && int_rcvd_disable !== rx_lanes_bitmap) ||
                           (|int_rcvd_no_scramble && int_rcvd_no_scramble !== rx_lanes_bitmap))))));
        M_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(|int_rcvd_lane_num === 1'b1 && int_rcvd_lane_num !== int_rcvd_link_num)))));
        M_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&        phy_layer_checks_disable !== 1'b1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&           
                           |int_rcvd_idle_data && |int_rx_valid)))));
        M_PCI_EXPRESS_N_FTS_NOT_SAME_RX_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&      
                           phy_layer_checks_disable !== 1'b1)
                           &&(rx_n_fts_field_not_same)))));
  // Additional gen1 code start 
        M_PCI_EXPRESS_LINK_NUM_MISMATCH_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 && 
                           DOUBLE_DATA_RATE === 1 && phy_layer_checks_disable !== 1'b1)
                           &&(ltssm_present_state === ZI_LTSSM_CFG_RCVRCFG_STATE && rx_link_num_field_not_same)))));
  // Additional gen1 code end
        M_PCI_EXPRESS_VALID_LINK_NUM_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(((ltssm_present_state == ZI_LTSSM_POLLING_ACTIVE_STATE ||             
                           ltssm_present_state == ZI_LTSSM_POLLING_SPEED_STATE) &&
                           int_rcvd_link_num) ||(|int_rcvd_ts2 && |int_rcvd_link_num &&
                           ltssm_present_state == ZI_LTSSM_POLLING_CFG_STATE))))));
        M_PCI_EXPRESS_UPSTREAM_PORT_STARTED_LINK_WIDTH_NEG_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr(((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_link_num === 1'b1)))));                     
        M_PCI_EXPRESS_UPSTREAM_PORT_INIT_LANE_NUM_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_DONE_STATE &&             
                           downstream_port === 1'b1 && |int_rcvd_lane_num === 1'b1)))));
        M_PCI_EXPRESS_LANE_INIT_BEFORE_LINK_INIT_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&((negotiate_present_state == ZI_NEGOTIATE_LINK_NUM_STATE ||              
                           negotiate_present_state == ZI_NEGOTIATE_IDLE_STATE) &&
                           |int_rcvd_lane_num === 1'b1)))));
        M_PCI_EXPRESS_PROPOSED_WIDTH_ERROR_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(downstream_port === 1'b0 && rcvd_width_error === 1'b1)))));
        M_PCI_EXPRESS_COUNTER_PROPOSED_WIDTH_ERROR_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(downstream_port === 1'b1 && rcvd_width_error === 1'b1)))));
        M_PCI_EXPRESS_CHANGE_IN_LINK_WIDTH_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE && 
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_ACTIVE_STATE &&
                           ltssm_next_state !== ZI_LTSSM_POLLING_CFG_STATE &&
                           |int_rcvd_ts2 === 1'b1 &&(r_rcvd_lane_num !== int_rcvd_lane_num ||
                           int_rcvd_lane_num !== r_xmtd_lane_num))))));
        M_PCI_EXPRESS_COUNTER_PROPOSED_GREATER_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_ts1 === 1'b1 && downstream_port === 1'b1 &&
                           ((int_rcvd_lane_num > r_xmtd_lane_num && r_rcvd_lane_num !== int_rcvd_lane_num)
                           ||(int_rcvd_link_num > r_xmtd_link_num &&
                           r_rcvd_link_num !== int_rcvd_link_num)))))));
        M_PCI_EXPRESS_LANE_ASSIGN_ERROR_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 && phy_layer_checks_disable !== 1'b1 && 
                           DOUBLE_DATA_RATE === 1)
                           &&(ltssm_next_state !== ZI_LTSSM_RECOVERY_LOCK_STATE &&             
                           ltssm_next_state !== ZI_LTSSM_RECOVERY_RCVRCFG_STATE &&
                           downstream_port === 1'b0 && int_rcvd_lane_num > r_xmtd_link_num &&
                           r_rcvd_lane_num !== int_rcvd_lane_num)))));
        M_PCI_EXPRESS_TS1_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_ACTIVE_STATE) 
                           && (ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE) 
                           && (|int_rcvd_ts1 === 1'b1 && int_rcvd_ts1 !== 32'h1 && int_rcvd_ts1 !== 32'h3 &&
                           int_rcvd_ts1 !== 32'hF && int_rcvd_ts1 !== 32'hFF && int_rcvd_ts1 !== 32'hFFF
                           && int_rcvd_ts1 !== 32'hFFFF && int_rcvd_ts1 !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_TS2_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && skip_link_training === 1'b0 &&
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_ts2 === 1'b1 && int_rcvd_ts2 !== 32'h1 && int_rcvd_ts2 !== 32'h3 &&
                           int_rcvd_ts2 !== 32'hF && int_rcvd_ts2 !== 32'hFF && int_rcvd_ts2 !== 32'hFFF
                           && int_rcvd_ts2 !== 32'hFFFF && int_rcvd_ts2 !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_SKP_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_skip_ordered_set === 1'b1 && int_rcvd_skip_ordered_set !== 32'h1 
                           && int_rcvd_skip_ordered_set !== 32'h3 &&
                           int_rcvd_skip_ordered_set !== 32'hF &&
                           int_rcvd_skip_ordered_set !== 32'hFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF &&
                           int_rcvd_skip_ordered_set !== 32'hFFFF_FFFF)))));
        M_PCI_EXPRESS_IDL_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_idle_os === 1'b1 && int_rcvd_idle_os !== link_width_bitmap)))));
        M_PCI_EXPRESS_FTS_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_fts_os === 1'b1 && int_rcvd_fts_os !== link_width_bitmap)))));
        M_PCI_EXPRESS_IDLE_DATA_NOT_ALL_LANES_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_idle_data === 1'b1 && int_rcvd_idle_data !== link_width_bitmap)))));
        M_PCI_EXPRESS_LINK_CTRL_NOT_SAME_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&((|int_rcvd_reset && int_rcvd_reset !== rx_lanes_bitmap) ||
                           (|int_rcvd_loopback && int_rcvd_loopback !== rx_lanes_bitmap) ||
                           (|int_rcvd_disable && int_rcvd_disable !== rx_lanes_bitmap) ||
                           (|int_rcvd_no_scramble && int_rcvd_no_scramble !== rx_lanes_bitmap))))));
        M_PCI_EXPRESS_LANE_LINK_MISMATCH_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(|int_rcvd_lane_num === 1'b1 && int_rcvd_lane_num !== int_rcvd_link_num)))));
        M_PCI_EXPRESS_IDLE_DATA_BEFORE_NEG_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(negotiate_present_state !== ZI_NEGOTIATE_LANE_NUM_DONE_STATE &&
                           |int_rcvd_idle_data && |int_rx_valid)))));
        M_PCI_EXPRESS_N_FTS_NOT_SAME_RX_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           skip_link_training === 1'b0 &&         
                           phy_layer_checks_disable !== 1'b1 && DOUBLE_DATA_RATE === 1)
                           &&(rx_n_fts_field_not_same)))));
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
