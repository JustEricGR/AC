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
        A_ETHERNET_MII_TX_EXTRA_NIBBLE_DETECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 0 &&
                           TX_INTERFACE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_TX_EXTRA_NIBBLE_DETECTED"}),
                          .msg            ("An extra nibble was detected on the TX interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
        A_ETHERNET_RMII_TX_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 1 &&
                           TX_INTERFACE == 1)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_RMII_TX_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED"}),
                          .msg            ("Non integral number of octets are detected on the TX interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_PHY_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_PHY_SIDE 
        M_ETHERNET_MII_TX_EXTRA_NIBBLE_DETECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 0 &&
                           TX_INTERFACE == 1)));
        M_ETHERNET_RMII_TX_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 1 &&
                           TX_INTERFACE == 1)));
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
        A_ETHERNET_MII_RX_EXTRA_NIBBLE_DETECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 0 &&
                           TX_INTERFACE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_MII_RX_EXTRA_NIBBLE_DETECTED"}),
                          .msg            ("An extra nibble was detected on the RX interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
       A_ETHERNET_RMII_RX_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 1 &&
                           TX_INTERFACE == 0)))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_ETHERNET_RMII_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED"}),
                          .msg            ("Non integral number of octets are detected on the RX interface"),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTRAINT_MAC_SIDE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZI_CONSTRAINT_MAC_SIDE 
        M_ETHERNET_MII_TX_EXTRA_NIBBLE_DETECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 0 &&
                           TX_INTERFACE == 1)));
        M_ETHERNET_RMII_RX_NON_INTEGRAL_NUMBER_OF_OCTETS_DETECTED: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (areset === 1'b0 && reset === 1'b0),
                          .enable    (1'b1),
                          .test_expr (nibble_position_at_end_of_frame === 1'b1 && RMII_MON == 1 &&
                           TX_INTERFACE == 0)));
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
