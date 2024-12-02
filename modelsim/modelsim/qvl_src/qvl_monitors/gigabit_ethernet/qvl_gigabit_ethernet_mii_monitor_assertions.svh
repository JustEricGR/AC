//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.                           
//                                                                          
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY             
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS          
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE         
//                                  TERMS.                                  
//                                                                          
//
`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

  //---------------------------------------------------------------------

  parameter QVL_MSG = "<monitor name> Violation: ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// Checks with ZI_CONSTRAINT_PHY_SIDE

generate
  case (ZI_CONSTRAINT_PHY_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_CONSTRAINT_PHY_SIDE 
        A_ETHERNET_MII_TX_EN_ASSERTED_WHEN_CARRIER_SENSED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_when_crs_asserted_violation === 1'b1 )))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_EN_ASSERTED_WHEN_CARRIER_SENSED"}),
                          .msg            ("In half duplex mode, TX_EN should not be asserted when carrier sense is high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_MII_TX_EN_ASSERTED_WHEN_COLLISION_DETECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_when_col_asserted_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_EN_ASSERTED_WHEN_COLLISION_DETECTED"}),
                          .msg            ("In half duplex mode, TX_EN should not be asserted when a collision is detected."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_MII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE"}),
                          .msg            ("In half duplex mode, the transmit interface is non-idle when the receive interface is already active."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_MII_TX_START_WITH_NON_PREAMBLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_starting_with_non_preamble === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_START_WITH_NON_PREAMBLE"}),
                          .msg            ("When TX_EN is asserted, it indicates that a frame transmission has started. The frame transmission should always begin with a preamble."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_MII_TX_ER_ASSERTED_DURING_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_er_asserted_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_ER_ASSERTED_DURING_FRAME"}),
                          .msg            ("TX_ER is asserted while Frame is in progress i.e. TX_EN is also high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_MII_RESERVED_VALUES_ON_TX_INTERFACE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_tx_interface === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RESERVED_VALUES_ON_TX_INTERFACE"}),
                          .msg            ("Reserved values detected on the transmit interface when TX_EN was not asserted and TX_ER was asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_PHY_SIDE 
        M_ETHERNET_MII_TX_EN_ASSERTED_WHEN_CARRIER_SENSED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_when_crs_asserted_violation === 1'b1 )));
        M_ETHERNET_MII_TX_EN_ASSERTED_WHEN_COLLISION_DETECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_when_col_asserted_violation === 1'b1)));
        M_ETHERNET_MII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)));
        M_ETHERNET_MII_TX_START_WITH_NON_PREAMBLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_starting_with_non_preamble === 1'b1)));
        M_ETHERNET_MII_TX_ER_ASSERTED_DURING_FRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_er_asserted_during_frame === 1'b1)));
        M_ETHERNET_MII_RESERVED_VALUES_ON_TX_INTERFACE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_tx_interface === 1'b1)));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_CONSTRAINT_PHY_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

// Checks with ZI_CONSTRAINT_MAC_SIDE

generate
  case (ZI_CONSTRAINT_MAC_SIDE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZI_CONSTRAINT_MAC_SIDE 
        A_ETHERNET_MII_COLLISION_DETECTED_WITHOUT_CARRIER: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_asserted_when_crs_deasserted_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_COLLISION_DETECTED_WITHOUT_CARRIER"}),
                          .msg            ("In half duplex mode, a collision was detected even when there is no carrier sense."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_ETHERNET_MII_CRS_DEASSERTED_DURING_COLLISION: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (crs_deasserted_when_col_asserted === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_CRS_DEASSERTED_DURING_COLLISION"}),
                          .msg            ("In half duplex mode, carrier sense should be held high throughout the collision period."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_ETHERNET_MII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE"}),
                          .msg            ("In half duplex mode, the receive interface is non-idle when the transmit interface is already active."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_ETHERNET_MII_RESERVED_VALUES_ON_RX_INTERFACE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_rx_interface === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RESERVED_VALUES_ON_RX_INTERFACE"}),
                          .msg            ("Reserved values detected on receive interface when the RX_DV was not asserted and RX_ER was asserted."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_ETHERNET_MII_RX_START_WITH_NON_PREAMBLE_OR_SFD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_dv_asserted_starting_with_non_preamble_or_sfd ===
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RX_START_WITH_NON_PREAMBLE_OR_SFD"}),
                          .msg            ("When RX_DV is asserted, it indicates that a frame reception has started. A frame reception must always begin with a preamble or SFD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_ETHERNET_MII_RX_ER_ASSERTED_DURING_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_er_asserted_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RX_ER_ASSERTED_DURING_FRAME"}),
                          .msg            ("RX_ER is asserted while Frame is in progress i.e. RX_DV is also high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));

      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_MAC_SIDE 
        M_ETHERNET_MII_COLLISION_DETECTED_WITHOUT_CARRIER: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (col_asserted_when_crs_deasserted_violation === 1'b1)));
        M_ETHERNET_MII_CRS_DEASSERTED_DURING_COLLISION: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (crs_deasserted_when_col_asserted === 1'b1)));
        M_ETHERNET_MII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)));
        M_ETHERNET_MII_RESERVED_VALUES_ON_RX_INTERFACE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_rx_interface === 1'b1)));
        M_ETHERNET_MII_RX_START_WITH_NON_PREAMBLE_OR_SFD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_dv_asserted_starting_with_non_preamble_or_sfd ===
                           1'b1)));
        M_ETHERNET_MII_RX_ER_ASSERTED_DURING_FRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_er_asserted_during_frame === 1'b1)));
 
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZI_CONSTRAINT_MAC_SIDE 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate

`endif // QVL_ASSERT_ON
