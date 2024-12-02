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

  parameter QVL_MSG = "Gigabit Ethernet Violation : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = Constraints_Mode; // 0 = `OVL_ASSERTON
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
        A_GIGABIT_ETHERNET_RGMII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE"}),
                          .msg            ("In half duplex mode, the transmit interface is non-idle when the receive interface is already active."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_TX_INTERFACE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_tx_interface === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_TX_INTERFACE"}),
                          .msg            ("Reserved values detected on the transmit interface when TX_EN is low and TX_ER is high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_TX_WITHOUT_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (carrier_extn_on_tx_not_following_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_TX_WITHOUT_FRAME"}),
                          .msg            ("Carrier extension detected on transmit interface without a preceding frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_GIGABIT_ETHERNET_RGMII_TX_START_WITH_NON_PREAMBLE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_starting_with_non_preamble === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_TX_START_WITH_NON_PREAMBLE"}),
                          .msg            ("When TX_EN is asserted, it indicates that a frame transmission has started. The frame transmission should always begin with a preamble."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));

        A_GIGABIT_ETHERNET_RGMII_TX_ER_ASSERTED_DURING_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_er_asserted_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_TX_ER_ASSERTED_DURING_FRAME"}),
                          .msg            ("TX_ER is asserted while Frame is in progress i.e. TX_EN is also high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_GIGABIT_ETHERNET_RGMII_TX_EXTENSION_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_extension_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_TX_EXTENSION_ERR"}),
                          .msg            ("TX_ER is asserted with TD carrying 0x1F while extension bits are being sent."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_PHY_SIDE 
        M_GIGABIT_ETHERNET_RGMII_TX_INTERFACE_ACTIVE_WHEN_RX_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_TX_INTERFACE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_tx_interface === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_TX_WITHOUT_FRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (carrier_extn_on_tx_not_following_frame === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_TX_START_WITH_NON_PREAMBLE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (txc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_en_asserted_starting_with_non_preamble === 1'b1)));

       M_GIGABIT_ETHERNET_RGMII_TX_ER_ASSERTED_DURING_FRAME: 
         assume property ( ASSERT_NEVER_P ( 
                         .clock     (txc ),
                         .reset_n   (areset === 1'b0 && reset === 1'b0),
                         .enable    (1'b1),
                         .test_expr (tx_er_asserted_during_frame === 1'b1)));
       M_GIGABIT_ETHERNET_RGMII_TX_EXTENSION_ERR: 
         assume property ( ASSERT_NEVER_P ( 
                         .clock     (txc ),
                         .reset_n   (areset === 1'b0 && reset === 1'b0),
                         .enable    (1'b1),
                         .test_expr (tx_extension_error === 1'b1)));
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
        A_GIGABIT_ETHERNET_RGMII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE"}),
                          .msg            ("In half duplex mode, the receive interface is non-idle when the transmit interface is already active."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_RX_INTERFACE: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_rx_interface === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_RX_INTERFACE"}),
                          .msg            ("Reserved values detected on receive interface when the RX_DV is low and RX_ER is high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_RX_WITHOUT_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (carrier_extn_on_rx_not_following_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_RX_WITHOUT_FRAME"}),
                          .msg            ("Carrier extension detected on receive interface without a preceding frame."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_RX_START_WITH_NON_PREAMBLE_OR_SFD: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_dv_asserted_starting_with_non_preamble_or_sfd === 
                           1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RX_START_WITH_NON_PREAMBLE_OR_SFD"}),
                          .msg            ("When RX_DV is asserted, it indicates that a frame reception has started. A frame reception must always begin with a preamble or SFD."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));

        A_GIGABIT_ETHERNET_RGMII_RX_ER_ASSERTED_DURING_FRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_er_asserted_during_frame === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RX_ER_ASSERTED_DURING_FRAME"}),
                          .msg            ("RX_ER is asserted while Frame is in progress i.e. RX_DV is also high."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_RX_EXTENSION_ERR: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_extension_error === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RX_EXTENSION_ERR"}),
                          .msg            ("RX_ER is asserted with RD carrying 0x1F while extension bits are being sent."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_INVALID_DUPLEX_STATUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_duplex_indication === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_INVALID_DUPLEX_STATUS"}),
                          .msg            ("In Band status during interframe not having a valid Indication of Duplex status."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_INVALID_CLK_SPEED_STATUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_clk_speed_indication === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_INVALID_CLK_SPEED_STATUS"}),
                          .msg            ("In Band status during interframe not having a valid Indication for RXC clock speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_RESERVED_CLK_SPEED_STATUS: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                                      reserved_clk_speed_indication === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_RESERVED_CLK_SPEED_STATUS"}),
                          .msg            ("In Band status during interframe having a Reserved Indication for RXC clock speed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
        A_GIGABIT_ETHERNET_RGMII_INVALID_NIBBLES_ON_NEGEDGE_INTERFRAME: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_nibble_on_negedge === 1'b1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_GIGABIT_ETHERNET_RGMII_INVALID_NIBBLES_ON_NEGEDGE_INTERFRAME"}),
                          .msg            ("In Band status during interframe must have nibbles repeated on posedge and negedge"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));


      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_MAC_SIDE 
        M_GIGABIT_ETHERNET_RGMII_RX_INTERFACE_ACTIVE_WHEN_TX_ACTIVE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (tx_and_rx_interface_active_violation === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_RESERVED_VALUES_ON_RX_INTERFACE: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                           reserved_values_on_rx_interface === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_CAR_EXTN_ON_RX_WITHOUT_FRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (carrier_extn_on_rx_not_following_frame === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_RX_START_WITH_NON_PREAMBLE_OR_SFD: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_dv_asserted_starting_with_non_preamble_or_sfd === 
                           1'b1)));
        M_GIGABIT_ETHERNET_RGMII_RX_ER_ASSERTED_DURING_FRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_er_asserted_during_frame === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_RX_EXTENSION_ERR: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (rx_extension_error === 1'b1)));
        M_GIGABIT_ETHERNET_RGMII_INVALID_DUPLEX_STATUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_duplex_indication === 1'b1)));
         M_GIGABIT_ETHERNET_RGMII_INVALID_CLK_SPEED_STATUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_clk_speed_indication === 1'b1)));
         M_GIGABIT_ETHERNET_RGMII_RESERVED_CLK_SPEED_STATUS: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (RESERVED_VALUE_CHECK_ENABLE == 1 &&
                                      reserved_clk_speed_indication === 1'b1)));
         M_GIGABIT_ETHERNET_RGMII_INVALID_NIBBLES_ON_NEGEDGE_INTERFRAME: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rxc ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (invalid_nibble_on_negedge === 1'b1)));
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
