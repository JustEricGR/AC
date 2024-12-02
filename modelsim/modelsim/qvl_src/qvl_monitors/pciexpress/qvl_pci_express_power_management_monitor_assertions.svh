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

  wire not_tx_clk = ~tx_clk;
  wire not_rx_clk = ~rx_clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

// assert_only checks

        A_PCI_EXPRESS_PM_PME_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && xmtd_pm_pme_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_DOWNSTREAM_P"}),
                          .msg            ("Downstream ports should not transmit PM_PME message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PME_TO_ACK_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && xmtd_pme_to_ack_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_DOWNSTREAM_P"}),
                          .msg            ("Downstream ports should not transmit PME_TO_ACK message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ENTER_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && |xmtd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_DOWNSTREAM_P"}),
                          .msg            ("Downstream ports should not transmit PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && xmtd_pm_enter_l23_dllp &&
                           xmtd_pme_to_ack_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_P"}),
                          .msg            ("Upstream port should not transmit PM_Enter_L23 DLL packet without acknowledging the received PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_TURN_OFF_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && xmtd_pme_turn_off_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TURN_OFF_UPSTREAM_P"}),
                          .msg            ("Upstream ports should not transmit PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_REQUEST_ACK_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && xmtd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_REQUEST_ACK_UPSTREAM_P"}),
                          .msg            ("Upstream ports should not transmit PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ACTIVE_STATE_NAK_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && xmtd_pm_active_state_nak_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ACTIVE_STATE_NAK_UPSTREAM_P"}),
                          .msg            ("Upstream ports should not transmit PM_Active_State_Nak TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_OUTSTANDING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (tx_num_outstanding_tlps !== 12'b0 && 
                           |xmtd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_OUTSTANDING_P"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets should not be transmitted when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_AFTER_PM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (|xmtd_pm_enter_command_flag === 1'b1 && xmtd_tlp &&
                           downstream_port === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_AFTER_PM_P"}),
                          .msg            ("New TL packets should not be transmitted after transmitting PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 messages."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_AFTER_ACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b1 && xmtd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_AFTER_ACK_P"}),
                          .msg            ("New TL packets should not be transmitted by the down stream ports after transmitting PM_Request_Ack message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_OUTSTANDING_WHEN_ACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (tx_num_outstanding_tlps !== 12'b0 && 
                           xmtd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_OUTSTANDING_WHEN_ACK_P"}),
                          .msg            ("PM_Request_Ack DLL packet should not be transmitted when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ACK_WITHOUT_PM_COMMAND_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && xmtd_pm_request_ack_dllp &&
                           |rcvd_pm_enter_command_flag !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACK_WITHOUT_PM_COMMAND_P"}),
                          .msg            ("PM_Request_Ack DLL packet should not be transmitted without receiving PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NAK_WITHOUT_PM_REQ_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b1 && xmtd_pm_active_state_nak_tlp &&
                           rcvd_pm_enter_command_flag[2] !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NAK_WITHOUT_PM_REQ_P"}),
                          .msg            ("PM_Active_State_Nak should not be transmitted without receiving PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PME_ACK_WITHOUT_TURN_OFF_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && xmtd_pme_to_ack_tlp &&
                           rcvd_pme_turn_off_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_ACK_WITHOUT_TURN_OFF_P"}),
                          .msg            ("PME_TO_Ack message should not be transmitted without receiving PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_OS_WITHOUT_ACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1))&&
                           (downstream_port === 1'b0 && 
                           rcvd_pm_request_ack_flag === 1'b0 &&
                           xmtd_pm_enter_command_flag !== 3'b0 && |xmtd_idle_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_OS_WITHOUT_ACK_P"}),
                          .msg            ("Downstream ports should not transit to electrical idle state without receiving PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_PME_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && xmtd_pm_pme_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_DOWNSTREAM_N"}),
                          .msg            ("Downstream ports should not transmit PM_PME message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PME_TO_ACK_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && xmtd_pme_to_ack_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_DOWNSTREAM_N"}),
                          .msg            ("Downstream ports should not transmit PME_TO_ACK message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ENTER_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && |xmtd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_DOWNSTREAM_N"}),
                          .msg            ("Downstream ports should not transmit PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_pm_enter_l23_dllp &&
                           xmtd_pme_to_ack_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_N"}),
                          .msg            ("Upstream port should not transmit PM_Enter_L23 DLL packet without acknowledging the received PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_TURN_OFF_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_pme_turn_off_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TURN_OFF_UPSTREAM_N"}),
                          .msg            ("Upstream ports should not transmit PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_REQUEST_ACK_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_REQUEST_ACK_UPSTREAM_N"}),
                          .msg            ("Upstream ports should not transmit PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PM_ACTIVE_STATE_NAK_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_pm_active_state_nak_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ACTIVE_STATE_NAK_UPSTREAM_N"}),
                          .msg            ("Upstream ports should not transmit PM_Active_State_Nak TL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_OUTSTANDING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(tx_num_outstanding_tlps !== 12'b0 && |xmtd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_OUTSTANDING_N"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets should not be transmitted when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_AFTER_PM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(|xmtd_pm_enter_command_flag === 1'b1 && xmtd_tlp &&
                           downstream_port === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_AFTER_PM_N"}),
                          .msg            ("New TL packets should not be transmitted after transmitting PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 messages."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_AFTER_ACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b1 && xmtd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_AFTER_ACK_N"}),
                          .msg            ("New TL packets should not be transmitted by the down stream ports after transmitting PM_Request_Ack message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_TLPS_OUTSTANDING_WHEN_ACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(tx_num_outstanding_tlps !== 12'b0 && 
                           xmtd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TLPS_OUTSTANDING_WHEN_ACK_N"}),
                          .msg            ("PM_Request_Ack DLL packet should not be transmitted when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_ACK_WITHOUT_PM_COMMAND_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && xmtd_pm_request_ack_dllp &&                                
			   |rcvd_pm_enter_command_flag !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACK_WITHOUT_PM_COMMAND_N"}),
                          .msg            ("PM_Request_Ack DLL packet should not be transmitted without receiving PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_NAK_WITHOUT_PM_REQ_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 &&
                           pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b1 && 
                           xmtd_pm_active_state_nak_tlp &&
                           rcvd_pm_enter_command_flag[2] !== 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NAK_WITHOUT_PM_REQ_N"}),
                          .msg            ("PM_Active_State_Nak should not be transmitted without receiving PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_PME_ACK_WITHOUT_TURN_OFF_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && xmtd_pme_to_ack_tlp &&
                           rcvd_pme_turn_off_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_ACK_WITHOUT_TURN_OFF_N"}),
                          .msg            ("PME_TO_Ack message should not be transmitted without receiving PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));
        A_PCI_EXPRESS_IDLE_OS_WITHOUT_ACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_tx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pw_DOUBLE_DATA_RATE === 1'b1 && pm_checks_disable !== 1'b1)
                           &&(downstream_port === 1'b0 && 
                           rcvd_pm_request_ack_flag === 1'b0 &&
                           xmtd_pm_enter_command_flag !== 3'b0 && |xmtd_idle_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_IDLE_OS_WITHOUT_ACK_N"}),
                          .msg            ("Downstream ports should not transit to electrical idle state without receiving PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (1'b0));  

// Checks with Constraints_Mode

generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pme_to_ack_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_P"}),
                          .msg            ("PME_TO_Ack message should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_PME_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_pme_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_UPSTREAM_P"}),
                          .msg            ("PM_PME message should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_ENTER_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && |rcvd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_UPSTREAM_P"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pme_turn_off_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_P"}),
                          .msg            ("PME_Turn_Off message should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_P"}),
                          .msg            ("PM_Request_Ack DLL packet should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_active_state_nak_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_P"}),
                          .msg            ("PM_Active_State_Nak message should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_request_ack_dllp &&
                           |xmtd_pm_enter_command_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_P"}),
                          .msg            ("PM_Request_Ack should not be issued in downstream direction without a PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_active_state_nak_tlp && 
                           xmtd_pm_enter_command_flag[2] === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_P"}),
                          .msg            ("PM_Active_State_Nak message should not be issued in downstream direction without a PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && 
                           rx_num_outstanding_tlps !== 12'b0 && 
                           rcvd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_P"}),
                          .msg            ("PM_Request_Ack message should not be issued when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_request_ack_flag &&
                           rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_P"}),
                          .msg            ("TL packets should not be issued once PM_Request_Ack DLL packet is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pme_to_ack_tlp &&
                           xmtd_pme_turn_off_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_P"}),
                          .msg            ("PME_TO_Ack message should not be issued in upstream direction without a PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_enter_l23_dllp &&       
                           rcvd_pme_to_ack_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_P"}),
                          .msg            ("PM_Enter_L23 DLL packet should not be issued before PME_TO_Ack message is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (rx_num_outstanding_tlps !== 12'b0 && 
                           |rcvd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_P"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet should not be issued when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_AFTER_PM_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (|rcvd_pm_enter_command_flag === 1'b1 && rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_AFTER_PM_P"}),
                          .msg            ("TL packets should not be issued once PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b0 &&
                           rcvd_pm_enter_command_flag !== 3'b0 && |rcvd_idle_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_P"}),
                          .msg            ("Electrical idle ordered sets should not be detectedwithout transmitting PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&	 
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pme_to_ack_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_N"}),
                          .msg            ("PME_TO_Ack message should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_PME_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_pme_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_PME_UPSTREAM_N"}),
                          .msg            ("PM_PME message should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_ENTER_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && |rcvd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_UPSTREAM_N"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23, PM_Active_State_Request_L1 DLL packets should not be issued in downstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pme_turn_off_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_N"}),
                          .msg            ("PME_Turn_Off message should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_N"}),
                          .msg            ("PM_Request_Ack DLL packet should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_active_state_nak_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_N"}),
                          .msg            ("PM_Active_State_Nak message should not be issued in upstream direction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_request_ack_dllp &&
                           |xmtd_pm_enter_command_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_N"}),
                          .msg            ("PM_Request_Ack should not be issued in downstream direction without a PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_active_state_nak_tlp
                           && xmtd_pm_enter_command_flag[2] === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_N"}),
                          .msg            ("PM_Active_State_Nak message should not be issued in downstream direction without a PM_Active_State_Request_L1 DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && 
                           rx_num_outstanding_tlps !== 12'b0 && 
                           rcvd_pm_request_ack_dllp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_N"}),
                          .msg            ("PM_Request_Ack message should not be issued when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && 
                           rcvd_pm_request_ack_flag && rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_N"}),
                          .msg            ("TL packets should not be issued once PM_Request_Ack DLL packet is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pme_to_ack_tlp && 
                           xmtd_pme_turn_off_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_N"}),
                          .msg            ("PME_TO_Ack message should not be issued in upstream direction without a PME_Turn_Off message."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_enter_l23_dllp &&
                           rcvd_pme_to_ack_flag === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_N"}),
                          .msg            ("PM_Enter_L23 DLL packet should not be issued before PME_TO_Ack message is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(rx_num_outstanding_tlps !== 12'b0 && |rcvd_pm_enter_command)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_N"}),
                          .msg            ("PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet should not be issued when TL packets are outstanding."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_TLPS_AFTER_PM_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(|rcvd_pm_enter_command_flag === 1'b1 && rcvd_tlp)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_TLPS_AFTER_PM_N"}),
                          .msg            ("TL packets should not be issued once PM_Enter_L1, PM_Enter_L23 or PM_Active_State_Request_L1 DLL packet is issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
        A_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b0 && 
                           rcvd_pm_enter_command_flag !== 3'b0 && |rcvd_idle_os)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_N"}),
                          .msg            ("Electrical idle ordered sets should not be detected without transmitting PM_Request_Ack DLL packet."),
                          .severity_level (QVL_ERROR),
                          .property_type  (Constraints_Mode));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pme_to_ack_tlp)))));
        M_PCI_EXPRESS_PM_PME_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_pme_tlp)))));
        M_PCI_EXPRESS_PM_ENTER_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && |rcvd_pm_enter_command)))));
        M_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pme_turn_off_tlp)))));
        M_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_request_ack_dllp)))));
        M_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_active_state_nak_tlp)))));
        M_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_request_ack_dllp &&
                           |xmtd_pm_enter_command_flag === 1'b0)))));
        M_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_active_state_nak_tlp && 
                           xmtd_pm_enter_command_flag[2] === 1'b0)))));
        M_PCI_EXPRESS_RX_TLPS_OUTSTANDING_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && 
                           rx_num_outstanding_tlps !== 12'b0 && 
                           rcvd_pm_request_ack_dllp)))));
        M_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b0 && rcvd_pm_request_ack_flag &&
                           rcvd_tlp)))));
        M_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pme_to_ack_tlp &&
                           xmtd_pme_turn_off_flag === 1'b0)))));
        M_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && rcvd_pm_enter_l23_dllp &&       
                           rcvd_pme_to_ack_flag === 1'b0)))));
        M_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (rx_num_outstanding_tlps !== 12'b0 && 
                           |rcvd_pm_enter_command)))));
        M_PCI_EXPRESS_RX_TLPS_AFTER_PM_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (|rcvd_pm_enter_command_flag === 1'b1 && rcvd_tlp)))));
        M_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1)&&
                           (downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b0 &&
                           rcvd_pm_enter_command_flag !== 3'b0 && |rcvd_idle_os)))));
        M_PCI_EXPRESS_PME_TO_ACK_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&	 
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pme_to_ack_tlp)))));
        M_PCI_EXPRESS_PM_PME_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_pme_tlp)))));
        M_PCI_EXPRESS_PM_ENTER_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && |rcvd_pm_enter_command)))));
        M_PCI_EXPRESS_PM_TURN_OFF_DOWNSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pme_turn_off_tlp)))));
        M_PCI_EXPRESS_PM_REQUEST_ACK_DOWNSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_request_ack_dllp)))));
        M_PCI_EXPRESS_ACTIVE_STATE_NAK_DOWNSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 &&
                           pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_active_state_nak_tlp)))));
        M_PCI_EXPRESS_ACK_RCVD_WITHOUT_PM_ENTER_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_request_ack_dllp &&
                           |xmtd_pm_enter_command_flag === 1'b0)))));
        M_PCI_EXPRESS_NAK_WITHOUT_REQ_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && rcvd_pm_active_state_nak_tlp
                           && xmtd_pm_enter_command_flag[2] === 1'b0)))));
        M_PCI_EXPRESS_RX_TLPS_OUTSTANDING_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && 
                           rx_num_outstanding_tlps !== 12'b0 && 
                           rcvd_pm_request_ack_dllp)))));
        M_PCI_EXPRESS_TL_PKT_AFTER_ACK_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b0 && 
                           rcvd_pm_request_ack_flag && rcvd_tlp)))));
        M_PCI_EXPRESS_PME_TO_ACK_WITHOUT_TURN_OFF_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pme_to_ack_tlp && 
                           xmtd_pme_turn_off_flag === 1'b0)))));
        M_PCI_EXPRESS_PM_ENTER_L23_BEFORE_ACK_UPSTREAM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && rcvd_pm_enter_l23_dllp &&
                           rcvd_pme_to_ack_flag === 1'b0)))));
        M_PCI_EXPRESS_RX_TLPS_OUTSTANDING_PM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(rx_num_outstanding_tlps !== 12'b0 && |rcvd_pm_enter_command)))));
        M_PCI_EXPRESS_RX_TLPS_AFTER_PM_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(|rcvd_pm_enter_command_flag === 1'b1 && rcvd_tlp)))));
        M_PCI_EXPRESS_RX_IDLE_OS_WITHOUT_ACK_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_rx_clk),
                          .reset_n   (~areset && ~reset),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && 
                           pm_checks_disable !== 1'b1 && pw_DOUBLE_DATA_RATE === 1'b1)
                           &&(downstream_port === 1'b1 && 
                           xmtd_pm_request_ack_flag === 1'b0 && 
                           rcvd_pm_enter_command_flag !== 3'b0 && |rcvd_idle_os)))));
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
