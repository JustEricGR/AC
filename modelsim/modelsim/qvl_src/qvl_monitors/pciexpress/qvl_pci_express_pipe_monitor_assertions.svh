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
  parameter QVL_COVERAGE_LEVEL = 0;// {32{1'b1}}; //`OVL_COVER_NONE;

  wire not_pclk = ~pclk;

  //---------------------------------------------------------------------
  // Parameter checks
  //---------------------------------------------------------------------

// assert only checks

        A_PCI_EXPRESS_PARAM_DEVICE_TYPE_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (parameter_checks_active == 1'b1 &&
                           PCI_EXPRESS_DEVICE_TYPE != 0 &&
                           PCI_EXPRESS_DEVICE_TYPE != 1 &&
                           PCI_EXPRESS_DEVICE_TYPE != 4 &&
                           PCI_EXPRESS_DEVICE_TYPE != 5 &&
                           PCI_EXPRESS_DEVICE_TYPE != 6 &&
                           PCI_EXPRESS_DEVICE_TYPE != 7)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PARAM_DEVICE_TYPE_ERR"}),
                          .msg            ("Illegal value specified for PCI Express device type."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_PARAM_MAX_LINK_WIDTH_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (parameter_checks_active == 1'b1 &&
                           MAX_LINK_WIDTH != 1 &&
                           MAX_LINK_WIDTH != 2 &&
                           MAX_LINK_WIDTH != 4 &&
                           MAX_LINK_WIDTH != 8 &&
                           MAX_LINK_WIDTH != 16 &&
                           MAX_LINK_WIDTH != 32)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PARAM_MAX_LINK_WIDTH_ERR"}),
                          .msg            ("Illegal value specified for maximum link width supported."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_PAYLOAD_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (device_control_register[7:5] != 0 &&
                           device_control_register[7:5] != 1 &&
                           device_control_register[7:5] != 2 &&
                           device_control_register[7:5] != 3 &&
                           device_control_register[7:5] != 4 &&
                           device_control_register[7:5] != 5)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_PAYLOAD_SIZE"}),
                          .msg            ("Reserved encoding for maximum payload size field of device control register should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));
        A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_READ_REQUEST_SIZE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   ((!(areset) && !(reset))),
                          .enable    (1'b1),
                          .test_expr (device_control_register[14:12] != 0 &&
                           device_control_register[14:12] != 1 &&
                           device_control_register[14:12] != 2 &&
                           device_control_register[14:12] != 3 &&
                           device_control_register[14:12] != 4 &&
                           device_control_register[14:12] != 5)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RESERVED_VALUE_FOR_MAX_READ_REQUEST_SIZE"}),
                          .msg            ("Reserved encoding for maximum read request size field of device control register should not be used."),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));

// Checks with Constraints_Mode

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr ((((|deskew_fifo_full && com_read_from_all_lanes === 1'b0 && 
                           data_aligned === 1'b0 && data_not_aligned === 1'b0 &&
                           fifo_empty === 1'b1 && phy_status === 1'b1) ||
                           (phy_status === 1'b0 && data_aligned === 1'b1 && 
                           |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1
                           && |active_lanes_bitmap === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P"}),
                          .msg            ("Lane to lane deskew should not exceed the specified maximum limit of five symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((ZI_DOUBLE_DATA_RATE === 1 &&(|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && data_aligned === 1'b0 && 
                           data_not_aligned === 1'b0 && fifo_empty === 1'b1 && 
                           phy_status === 1'b0) ||(phy_status === 1'b0 && data_aligned === 1'b1 
                           && |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1 
                           && |active_lanes_bitmap === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N"}),
                          .msg            ("Lane to lane deskew should not exceed the specified maximum limit of five symbol times."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr ((((|deskew_fifo_full && com_read_from_all_lanes === 1'b0 && 
                           data_aligned === 1'b0 && data_not_aligned === 1'b0 &&
                           fifo_empty === 1'b1 && phy_status === 1'b1) ||
                           (phy_status === 1'b0 && data_aligned === 1'b1 && 
                           |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1
                           && |active_lanes_bitmap === 1'b1))))));
        M_PCI_EXPRESS_DESKEW_LIMIT_EXCEEDED_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((ZI_DOUBLE_DATA_RATE === 1 &&(|deskew_fifo_full && 
                           com_read_from_all_lanes === 1'b0 && data_aligned === 1'b0 && 
                           data_not_aligned === 1'b0 && fifo_empty === 1'b1 && 
                           phy_status === 1'b0) ||(phy_status === 1'b0 && data_aligned === 1'b1 
                           && |(com_read_from_fifo & ~(active_lanes_bitmap)) === 1'b1 
                           && |active_lanes_bitmap === 1'b1))))));
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

// Checks with PHY_LAYER_CONSTRAINT

generate
  case (PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_PHY_LAYER_CONSTRAINT
        if( PCI_EXPRESS_GEN2 == 1)
          begin : qvl_assert_PCI_EXPRESS_GEN2_PHY_LAYER_CONSTRAINT
            A_PIPE_GEN2_RATE_INVALID_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (reset === 1'b1 && rate === 1'b1)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_RATE_INVALID_DURING_RESET"}),
                              .msg            ("While reset is asserted Rate must be set to 2.5 GT/s signalling rate."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_RATE_CHANGE_IN_P1_P2: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && rate !== r_rate)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_RATE_CHANGE_IN_P1_P2"}),
                              .msg            ("Rate can only be changed when MAC is in P0 state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_RATE_INVALID_DURING_P1_P2: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr ((present_state_pd === ZI_P1_STATE || present_state_pd === ZI_P2_STATE)
                                          && rate === 1'b1)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_RATE_INVALID_DURING_P1_P2"}),
                              .msg            ("Before transtioning to P1 or P2 Rate must be set to 2.5 GT/s signalling rate."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_RATE_CHANGES_WHEN_TXELECIDLE_DEASSERTED: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr ((|(link_width_bitmap & (~tx_elecidle))) && rate !== r_rate)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_RATE_CHANGES_WHEN_TXELECIDLE_DEASSERTED"}),
                              .msg            ("Rate signal should be changed only when TxElecidle is asserted."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_TXMARGIN_CHANGE_IN_P1_P2: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && tx_margin !== r_tx_margin)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_TX_MARGIN_CHANGE_IN_P1_P2"}),
                              .msg            ("TxMargin can only be changed when MAC is in P0 state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_TXDEEMPH_CHANGE_IN_P1_P2: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && tx_deemph !== r_tx_deemph)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_TX_DEEMPH_CHANGE_IN_P1_P2"}),
                              .msg            ("TxDeemph can only be changed when MAC is in P0 state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
            A_PIPE_GEN2_TXELECIDLE_DEASSERTED_BEFORE_PHYSTATUS_ASSERTED_DURING_RATE_CHANGES: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (enable_rate_change_check === 1'b1 && (|(link_width_bitmap & (~tx_elecidle))))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_GEN2_TXELECIDLE_DEASSERTED_BEFORE_PHYSTATUS_ASSERTED_DURING_RATE_CHANGES"}),
                              .msg            ("During signalling rate change, TxElecidle should be asserted until there is PhyStatus from PHY."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));                                           
                                                 
          end

        // Additional Gen1 checks start
        A_PIPE_TX_DETECT_RX_ASSERTED_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && tx_detect_rx_loopback === 1'b1 )))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_TX_DETECT_RX_ASSERTED_DURING_RESET"}),
                              .msg            ("During Reset#, TxDetectRxLoopback should be deasserted."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TX_ELECIDLE_DEASSERTED_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|(link_width_bitmap & (~tx_elecidle))))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_TX_ELECIDLE_DEASSERTED_DURING_RESET"}),
                              .msg            ("During Reset#, TxElecIdle should be asserted."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TX_COMPLIANCE_ASSERTED_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|tx_compliance === 1'b1))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_TX_COMPLIANCE_ASSERTED_DURING_RESET"}),
                              .msg            ("During Reset#, TxCompliance should be deasserted."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_RX_POLARITY_ASSERTED_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|rx_polarity === 1'b1))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_RX_POLARITY_ASSERTED_DURING_RESET"}),
                              .msg            ("During Reset#, RxPolarity should be deasserted."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_POWERDOWN_DURING_RESET: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && power_down !== 2'b10)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_POWERDOWN_DURING_RESET"}),
                              .msg            ("During Reset#, PowerDown should be P1."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_POWERDOWN_NOT_P0_IN_L0: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (ltssm_present_state === ZI_LTSSM_L0_STATE && power_down !== 2'b00 && transmitter_in_Los_flag === 1'b0)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_POWERDOWN_NOT_P0_IN_L0"}),
                              .msg            ("PowerDown should be P0 in L0 state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_POWERDOWN_NOT_P0s_IN_L0s: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && ltssm_next_state === ZI_LTSSM_L0_STATE && p0s_flag === 1'b0)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_POWERDOWN_NOT_P0s_IN_L0s"}),
                              .msg            ("PowerDown should be P0s in L0s state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_POWERDOWN_NOT_P1_IN_L1_L2_DETECT_DISABLE: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr ((ltssm_present_state === ZI_LTSSM_L1_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE && p1_flag === 1'b0) || 
                                          (ltssm_present_state === ZI_LTSSM_L2_STATE && ltssm_next_state === ZI_LTSSM_POLLING_ACTIVE_STATE && p1_flag === 1'b0) ||
                                          (ltssm_present_state === ZI_LTSSM_DISABLE_STATE && power_down !== 2'b10 && (|(link_width_bitmap & tx_elecidle))))))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_POWERDOWN_NOT_P1_IN_L1_L2_DETECT_DISABLE"}),
                              .msg            ("PowerDown should be P1 in L1, L2, Detect or Disable state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_RX_POLARITY_IN_OTHERTHAN_POL_CONFIG: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && (|r_rx_polarity === 1'b0) && (|rx_polarity === 1'b1) && 
                               ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_RX_POLARITY_IN_OTHERTHAN_POL_CONFIG"}),
                              .msg            ("RxPolarity can only be asserted in Polling Configuration state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TX_COMPLIANCE_IN_OTHERTHAN_POL_COMP: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (skip_link_training === 1'b0 && (|tx_compliance === 1'b1) && ltssm_present_state !== ZI_LTSSM_POLLING_COMPLIANCE_STATE)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_TX_COMPLIANCE_IN_OTHERTHAN_POL_COMP"}),
                              .msg            ("TxCompliance can only be asserted in Polling Compliance state."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_16_BIT_COM_ON_HIGH: 
              assert property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (|xmtd_idle_os && com_on_high_hold === 1'b1)))
              else qvl_error_t(
                              .err_msg        ({QVL_MSG,"A_PIPE_16_BIT_COM_ON_HIGH"}),
                              .msg            ("For 16 Bit interface MAC should always align the EIOS so that COM is on lower order data lines TXData[7:0]."),
                              .severity_level (QVL_ERROR),
                              .property_type  (PHY_LAYER_CONSTRAINT));
        
        // Additional Gen1 checks end
        
        A_PIPE_TX_DETECT_RX_DEASSERT_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((((r_phystatus === 1'b1 && 
                           tx_detect_rx_loopback === 1'b1 && r_tx_detect_rx_loopback === 1'b1) ||
                           (r_tx_detect_rx_loopback === 1'b1 && 
                           tx_detect_rx_loopback === 1'b0 && r_phystatus === 1'b0)) && 
                           present_state_pd === ZI_P1_STATE && skip_link_training === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TX_DETECT_RX_DEASSERT_ERROR"}),
                          .msg            ("'TxDetectRx/Loopback' should be deasserted at the clock edge where the PHY component signals the completion of the receiver detection by asserting 'PhyStatus' for one clock."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TXELECIDLE_NOT_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_elecidle_deasserted === 1'b1 && skip_link_training === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TXELECIDLE_NOT_ASSERTED"}),
                          .msg            ("'TxElecidle' must always be asserted while in power down states P0s and P1."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TXDETECTRX_TXELECIDLE_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((skip_link_training === 1'b0 && present_state_pd === ZI_P0_STATE 
                           &&(|(link_width_bitmap & tx_elecidle)) && tx_detect_rx_loopback)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TXDETECTRX_TXELECIDLE_ASSERTED"}),
                          .msg            ("'TxDetectRx/Loopback' and 'TxElecidle' should not be asserted together when the PHY is in P0 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TXCOMPLIANCE_RXPOLARITY_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((skip_link_training === 1'b0 && present_state_pd !== ZI_P0_STATE 
                           &&(|tx_compliance === 1'b1 || |rx_polarity === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TXCOMPLIANCE_RXPOLARITY_ASSERTED"}),
                          .msg            ("'TxCompliance' and 'RxPolarity' should only be asserted when the PHY is in P0 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_ILLEGAL_POWER_DOWN_COMMAND: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((next_state_pd == ZI_UNKNOWN_STATE && power_down !== r_power_down)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_ILLEGAL_POWER_DOWN_COMMAND"}),
                          .msg            ("Illegal power down command. MAC layer should direct the PHY layer to legal states only."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TX_COMPLIANCE_MORE_THAN_ONE_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (( tx_compliance_more_than_one_clock))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TX_COMPLIANCE_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("'TxCompliance' should not be asserted more than one clock cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
        A_PIPE_TX_DETECT_RX_ASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_detect_rx_loopback === 1'b1 &&
                           (present_state_pd == ZI_P0s_STATE ||
                           present_state_pd == ZI_P2_STATE))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_TX_DETECT_RX_ASSERTED"}),
                          .msg            ("'TxDetectRx/Loopback' should be asserted only when the PHY is P1, P0 state."),
                          .severity_level (QVL_ERROR),
                          .property_type  (PHY_LAYER_CONSTRAINT));
      end

    `QVL_ASSUME : 
       begin : qvl_assume_ASSERT_NEVER_PHY_LAYER_CONSTRAINT
        if( PCI_EXPRESS_GEN2 == 1)
          begin : qvl_assume_PCI_EXPRESS_GEN2_PHY_LAYER_CONSTRAINT
            M_PIPE_GEN2_RATE_INVALID_DURING_RESET: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset)),
                              .enable    (1'b1),
                              .test_expr (reset === 1'b1 && rate === 1'b1)));
            M_PIPE_GEN2_RATE_CHANGE_IN_P1_P2: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && rate !== r_rate)));
            M_PIPE_GEN2_RATE_INVALID_DURING_P1_P2: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr ((present_state_pd === ZI_P1_STATE || present_state_pd === ZI_P2_STATE)
                                          && rate === 1'b1)));
            M_PIPE_GEN2_RATE_CHANGES_WHEN_TXELECIDLE_DEASSERTED: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr ((|(link_width_bitmap & (~tx_elecidle))) && rate !== r_rate)));
            M_PIPE_GEN2_TXMARGIN_CHANGE_IN_P1_P2: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && tx_margin !== r_tx_margin)));
            M_PIPE_GEN2_TXDEEMPH_CHANGE_IN_P1_P2: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (present_state_pd !== ZI_P0_STATE && tx_deemph !== r_tx_deemph)));
            M_PIPE_GEN2_TXELECIDLE_DEASSERTED_BEFORE_PHYSTATUS_ASSERTED_DURING_RATE_CHANGES: 
              assume property ( ASSERT_NEVER_P ( 
                              .clock     (pclk),
                              .reset_n   (!(areset) && !(reset)),
                              .enable    (1'b1),
                              .test_expr (enable_rate_change_check === 1'b1 && (|(link_width_bitmap & (~tx_elecidle))))));
          end

        // Additional Gen1 checks start
        M_PIPE_TX_DETECT_RX_ASSERTED_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && tx_detect_rx_loopback === 1'b1 )));
        M_PIPE_TX_ELECIDLE_DEASSERTED_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|(link_width_bitmap & (~tx_elecidle))))));
        M_PIPE_TX_COMPLIANCE_ASSERTED_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|tx_compliance === 1'b1))));
        M_PIPE_RX_POLARITY_ASSERTED_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && (|rx_polarity === 1'b1))));
        M_PIPE_POWERDOWN_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && power_down !== 2'b10)));
        M_PIPE_POWERDOWN_NOT_P0_IN_L0: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (ltssm_present_state === ZI_LTSSM_L0_STATE && power_down !== 2'b00 && transmitter_in_Los_flag === 1'b0)));
        M_PIPE_POWERDOWN_NOT_P0s_IN_L0s: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && ltssm_next_state === ZI_LTSSM_L0_STATE && p0s_flag === 1'b0)));
        M_PIPE_POWERDOWN_NOT_P1_IN_L1_L2_DETECT_DISABLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr ((ltssm_present_state === ZI_LTSSM_L1_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE && p1_flag === 1'b0) || 
                                      (ltssm_present_state === ZI_LTSSM_L2_STATE && ltssm_next_state === ZI_LTSSM_POLLING_ACTIVE_STATE && p1_flag === 1'b0) ||
                                      (ltssm_present_state === ZI_LTSSM_DISABLE_STATE && power_down !== 2'b10 && (|(link_width_bitmap & tx_elecidle))))));
        M_PIPE_RX_POLARITY_IN_OTHERTHAN_POL_CONFIG: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && (|r_rx_polarity === 1'b0) && (|rx_polarity === 1'b1) && 
                           ltssm_present_state !== ZI_LTSSM_POLLING_CFG_STATE)));
        M_PIPE_TX_COMPLIANCE_IN_OTHERTHAN_POL_COMP: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && (|tx_compliance === 1'b1) && ltssm_present_state !== ZI_LTSSM_POLLING_COMPLIANCE_STATE)));
        M_PIPE_16_BIT_COM_ON_HIGH: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|xmtd_idle_os && com_on_high_hold === 1'b1)));
        // Additional Gen1 checks end
                                         
        M_PIPE_TX_DETECT_RX_DEASSERT_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((((r_phystatus === 1'b1 && 
                           tx_detect_rx_loopback === 1'b1 && r_tx_detect_rx_loopback === 1'b1) ||
                           (r_tx_detect_rx_loopback === 1'b1 && 
                           tx_detect_rx_loopback === 1'b0 && r_phystatus === 1'b0)) && 
                           present_state_pd === ZI_P1_STATE && skip_link_training === 1'b0)))));
        M_PIPE_TXELECIDLE_NOT_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_elecidle_deasserted === 1'b1 && skip_link_training === 1'b0)))));
        M_PIPE_TXDETECTRX_TXELECIDLE_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((skip_link_training === 1'b0 && present_state_pd === ZI_P0_STATE 
                           &&(|(link_width_bitmap & tx_elecidle)) && tx_detect_rx_loopback)))));
        M_PIPE_TXCOMPLIANCE_RXPOLARITY_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((skip_link_training === 1'b0 && present_state_pd !== ZI_P0_STATE 
                           &&(|tx_compliance === 1'b1 || |rx_polarity === 1'b1))))));
        M_PIPE_ILLEGAL_POWER_DOWN_COMMAND: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((next_state_pd == ZI_UNKNOWN_STATE && power_down !== r_power_down)))));
        M_PIPE_TX_COMPLIANCE_MORE_THAN_ONE_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (( tx_compliance_more_than_one_clock))));
        M_PIPE_TX_DETECT_RX_ASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((tx_detect_rx_loopback === 1'b1 &&
                           (present_state_pd == ZI_P0s_STATE ||
                           present_state_pd == ZI_P2_STATE))))));
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

// Checks with MAC_LAYER_CONSTRAINT

generate
  case (MAC_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_MAC_LAYER_CONSTRAINT
        
        // Additional gen1 checks start
        A_PIPE_PHYSTATUS_DURING_RESET: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && phystatus === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_PHYSTATUS_DURING_RESET"}),
                          .msg            ("During Reset#, PhysStatus should be asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_REC_DETECT_RX_STATUS_INVALID: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && tx_detect_rx_loopback === 1'b1 && rx_status[2:0] !== 3'b000 && rx_status[2:0] !== 3'b011)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_REC_DETECT_RX_STATUS_INVALID"}),
                          .msg            ("During receiver detection RxStatus should contain value 000/011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_REC_DETECT_PHYSTATUS_DEASSERTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && tx_detect_rx_loopback === 1'b1 && rx_status === 3'b011 && phystatus === 1'b0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_REC_DETECT_PHYSTATUS_DEASSERTED"}),
                          .msg            ("During receiver detection PhyStatus should be asserted when RxStatus is 011."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_DECODE_ERR_NO_EDB_SYM: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|edb_not_found)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_DECODE_ERR_NO_EDB_SYM"}),
                          .msg            ("Rx Status indicates 8/10b Decode error but RxData does not contain EDB symbol."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_DECODE_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b100)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_DECODE_ERROR"}),
                          .msg            ("Decode Error(RxStatus 100)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_DISPARITY_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b111)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_DISPARITY_ERROR"}),
                          .msg            ("Disparity Error(RxStatus 111)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_EB_UNDERFLOW_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b110)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_EB_UNDERFLOW_ERROR"}),
                          .msg            ("Elastic buffer underflow error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_EB_OVERFLOW_ERROR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b101)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_EB_OVERFLOW_ERROR"}),
                          .msg            ("Elastic buffer overflow error."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_RXSTATUS_001_NOT_ALIGN_WITH_COM: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|com_not_found_when_rxstatus_001)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_RXSTATUS_001_NOT_ALIGN_WITH_COM"}),
                          .msg            ("RxStatus can be 001 only during clock when COM of SKIP OS received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_RXSTATUS_010_NOT_ALIGN_WITH_COM: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|com_not_found_when_rxstatus_010)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_RXSTATUS_010_NOT_ALIGN_WITH_COM"}),
                          .msg            ("RxStatus can be 010 only during clock when COM of SKIP OS received."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_SKP_ADDED_RXSTATUS_NOT_001: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|int_skp_added && rx_status_hold !== 3'b001)))
          else qvl_error_t(
                           .err_msg        ({QVL_MSG,"A_PIPE_SKP_ADDED_RXSTATUS_NOT_001"}),
                          .msg            ("RxStatus not containing 001 but Skip added."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        A_PIPE_SKP_REMOVED_RXSTATUS_NOT_010: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|int_skp_removed && rx_status_hold !== 3'b010)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_SKP_REMOVED_RXSTATUS_NOT_010"}),
                          .msg            ("RxStatus not containing 010 but Skip removed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
        // Additional gen1 checks end
        
        A_PIPE_PHYSTATUS_ASSERTED_MORE_THAN_ONE_CLOCK: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((r_phystatus === 1'b1 && phystatus === 1'b1 && 
                           present_state_pd !== ZI_P2_STATE && p2_p1_transit !== 1'b1 &&                
                           skip_link_training === 1'b0 && present_state_pd !== ZI_RESET_STATE)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PIPE_PHYSTATUS_ASSERTED_MORE_THAN_ONE_CLOCK"}),
                          .msg            ("'PhyStatus' should be asserted for only one clock cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (MAC_LAYER_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_MAC_LAYER_CONSTRAINT
        // Additional gen1 checks start
        M_PIPE_PHYSTATUS_DURING_RESET: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && reset === 1'b1 && phystatus === 1'b0)));
        M_PIPE_REC_DETECT_RX_STATUS_INVALID: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && tx_detect_rx_loopback === 1'b1 && rx_status[2:0] !== 3'b000 && rx_status[2:0] !== 3'b011)));
        M_PIPE_REC_DETECT_PHYSTATUS_DEASSERTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (skip_link_training === 1'b0 && tx_detect_rx_loopback === 1'b1 && rx_status === 3'b011 && phystatus === 1'b0)));
        M_PIPE_DECODE_ERR_NO_EDB_SYM: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|edb_not_found)));
        M_PIPE_DECODE_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b100)));
        M_PIPE_DISPARITY_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b100)));
        M_PIPE_EB_UNDERFLOW_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b110)));
        M_PIPE_EB_OVERFLOW_ERROR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (rx_status === 3'b101)));
        M_PIPE_RXSTATUS_001_NOT_ALIGN_WITH_COM: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|com_not_found_when_rxstatus_001)));
        M_PIPE_RXSTATUS_010_NOT_ALIGN_WITH_COM: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|com_not_found_when_rxstatus_010)));
        M_PIPE_SKP_ADDED_RXSTATUS_NOT_001: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|int_skp_added && rx_status_hold !== 3'b001)));
        M_PIPE_SKP_REMOVED_RXSTATUS_NOT_010: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (|int_skp_removed && rx_status_hold !== 3'b010)));
        // Additional gen1 checks end
        
        M_PIPE_PHYSTATUS_ASSERTED_MORE_THAN_ONE_CLOCK: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (pclk),
                          .reset_n   (!(areset) && !(reset)),
                          .enable    (1'b1),
                          .test_expr (((r_phystatus === 1'b1 && phystatus === 1'b1 && 
                           present_state_pd !== ZI_P2_STATE && p2_p1_transit !== 1'b1 &&                
                           skip_link_training === 1'b0 && present_state_pd !== ZI_RESET_STATE)))));
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
