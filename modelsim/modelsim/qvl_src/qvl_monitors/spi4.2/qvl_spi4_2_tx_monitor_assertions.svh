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

  parameter QVL_MSG = "QVL_SPI4_2_TX_VIOLATION : ";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = 0; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_ALL;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------

wire inverted_tdclk = !tdclk;
wire inverted_tsclk = !tsclk;


A_SPI4_2_TX_16_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(next_state_data === ZI_UNKNOWN_STATE)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_16_P"}),
                  .msg            ("Monitor data path state machine went to UNKNOWN STATE because of invalid control word."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_18_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                   (enable_fifo_status_if === 1'b1))&&(present_state_data === ZI_PAYLOAD_CONTROL &&                  
                   next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || 
                   latched_sop_negedge === 1'b1) && fifo_status_tsclk === ZI_FIFO_ERROR)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_18_P"}),
                  .msg            ("SOP should not be issued to a port, when an error condition has been reported on FIFO status interface."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_21_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(enable_fifo_status_if === 1'b1))&&(max_burst_2_violation === 1'b1)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_21_P"}),
                  .msg            ("Size of the Payload transferred to a port should not exceed the MAX_BURST_2 limit when its FIFO is in HUNGRY condition."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_22_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(enable_fifo_status_if === 1'b1))&&(max_burst_1_violation === 1'b1)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_22_P"}),
                  .msg            ("Size of the Payload transferred to a port should not exceed the MAX_BURST_1 limit when its FIFO is in STARVING condition."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_38_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(enable_fifo_status_if === 1'b1))&&
                   (no_training_sequence_after_reset_data === 1'b1 && LINK_SIDE_P === 1'b1 &&(data_max_t !== 0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_38_P"}),
                  .msg            ("Only Training sequence should be transmitted on data path interface after reset till valid FIFO status is received."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_26_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tsclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(next_state_fifo === ZI_UNKNOWN_STATE)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_26_P"}),
                  .msg            ("Monitor FIFO interface state machine went to UNKNOWN_STATE because of invalid input on TSTAT."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_16_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(next_state_data === ZI_UNKNOWN_STATE)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_16_N"}),
                  .msg            ("Monitor data path state machine went to UNKNOWN STATE because of invalid control word."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_18_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                   (enable_fifo_status_if === 1'b1))&&(present_state_data === ZI_PAYLOAD_CONTROL &&                 
                   next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1) && fifo_status_tsclk === ZI_FIFO_ERROR)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_18_N"}),
                  .msg            ("SOP should not be issued to a port, when an error condition has been reported on FIFO status interface."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_21_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(enable_fifo_status_if === 1'b1))&&(max_burst_2_violation === 1'b1)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_21_N"}),
                  .msg            ("Size of the Payload transferred to a port should not exceed the MAX_BURST_2 limit when its FIFO is in HUNGRY condition."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_22_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(enable_fifo_status_if === 1'b1))&&(max_burst_1_violation === 1'b1)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_22_N"}),
                  .msg            ("Size of the Payload transferred to a port should not exceed the MAX_BURST_1 limit when its FIFO is in STARVING condition."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_38_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                   (enable_fifo_status_if === 1'b1))&&(no_training_sequence_after_reset_data === 1'b1 &&                
                   LINK_SIDE_P === 1'b1 &&(data_max_t !== 0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_38_N"}),
                  .msg            ("Only Training sequence should be transmitted on data path interface after reset till valid FIFO status is received."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_26_N: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (inverted_tsclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(next_state_fifo === ZI_UNKNOWN_STATE)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_26_N"}),
                  .msg            ("Monitor FIFO interface state machine went to UNKNOWN_STATE because of invalid input on TSTAT."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_01_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((calendar_len < 1)) &&(((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_01_P"}),
                  .msg            ("CALENDAR_LEN should not be less than the minimum limit of 1."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_02_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((calendar_m < 1)) &&(((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_02_P"}),
                  .msg            ("CALENDAR_M should not be less than the minimum limit of 1."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_06_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((max_burst_2 < 1)) &&(((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_06_P"}),
                  .msg            ("MAX_BURST_2 should not be less than the minimum limit of 1."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_07_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((max_burst_1 < max_burst_2)) &&(((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_07_P"}),
                  .msg            ("MAX_BURST_1 should not be less than the minimum limit of MAX_BURST_2."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_08_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((data_max_t > 0) && (((data_max_t < data_training_sequence_len)) &&(((parameter_checks_active === 1'b1 || 	   
                   next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_08_P"}),
                  .msg            ("DATA_MAX_T should not be less than the minimum limit of 21 half clock cycles (Training sequence length)."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_09_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((fifo_max_t > 0) && (((fifo_max_t < fifo_training_sequence_len)) &&(((parameter_checks_active === 1'b1 || 	   
                   next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_09_P"}),
                  .msg            ("FIFO_MAX_T should not be less than the minimum limit of 20 (Training sequence length)."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_10_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((data_training_sequences_cnt < 1)) &&(((parameter_checks_active === 1'b1 || 	   
                   next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_10_P"}),
                  .msg            ("DATA_TRAINING_SEQUENCES_CNT should not be less than the minimum limit of 1."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_11_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && 
                   areset === 1'b0 && reset === 1'b0) &&(((calendar_len * calendar_m) < ZI_CAL_LEN_CAL_M_PRODUCT) &&                 
                   lvds_io_wire === 1'b1 && enable_fifo_status_if === 1'b1 &&(fifo_max_t !== 0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_11_P"}),
                  .msg            ("Product of CALENDAR_LEN and CALENDAR_M should not be less than 16 when LVDS_IO mode is selected."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_12_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk ),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((min_packet_len < 1)) &&(((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0))))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_12_P"}),
                  .msg            ("Minimum packet size should not be less than the minimum limit of 1."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));
A_SPI4_2_TX_PARAM_13_P: 
  assert property ( ASSERT_NEVER_P ( 
                  .clock     (tdclk),
                  .reset_n   (!(areset) ),
                  .enable    (1'b1),
                  .test_expr ((((parameter_checks_active === 1'b1 || next_state_fifo === ZI_CALENDAR_SELECTION_WORD) && areset === 1'b0 && reset === 1'b0) &&(max_packet_len < min_packet_len)))))
  else qvl_error_t(
                  .err_msg        ({QVL_MSG,"A_SPI4_2_TX_PARAM_13_P"}),
                  .msg            ("Maximum packet size should not be specified to be less than the minimum packet size."),
                  .severity_level (QVL_ERROR),
                  .property_type  (QVL_PROPERTY_TYPE));




generate
  case (ZI_PHY_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZPL 
        A_SPI4_2_TX_40_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl && sop_preceded === 1'b0 &&(z_payload_control | z_idle_control) &&(z_eop | z_eop_abort))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_40_P"}),
                          .msg            ("EOP should not be issued to a port without a preceding SOP."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_39_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_ACTIVE &&( control_word_extension === 1'b0 &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) && latched_port_address[7:0] === port_address_received &&
                           z_sop && !z_eop && !z_eop_abort) ||(control_word_extension === 1'b1 && next_state_data === ZI_DATA_BURST &&
                           present_state_data === ZI_PAYLOAD_CONTROL && prev_latched_port_address[15:0] === {port_address_received, latched_port_address[7:0]} && z_sop))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_39_P"}),
                          .msg            ("Another SOP should not be issued to an active port without completing the previous transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_36_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && no_sop_when_port_inactive === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_36_P"}),
                          .msg            ("A Payload control word should not be issued to a port without SOP information, when the port is inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_35_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl &&(effective_tdat[15:12] === 4'b0011 || effective_tdat[15:12] === 4'b0101 ||((effective_tdat[15:12] === 4'b0001 || 
                           effective_tdat[15:12] === 4'b0111) && control_word_extension === 1'b0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_35_P"}),
                          .msg            ("Reserved encoding should not be transmitted as part of control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_33_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(min_packet_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_33_P"}),
                          .msg            ("Size of a packet should not be less than the specified min packet size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_34_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(max_packet_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_34_P"}),
                          .msg            ("Size of a packet should not be greater than the specified max packet size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_37_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(control_word_extension === 1'b1 && invalid_extended_pld_ctrl_termination === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_37_P"}),
                          .msg            ("A control word was not transmitted after indicating control word extension."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_00_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(z_tctl & !(z_idle_control | z_payload_control | z_training_control))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_00_P"}),
                          .msg            ("A control word other than Idle Control/Payload Control/Training Control should not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_01_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_01_P"}),
                          .msg            ("A Payload Control word should not be immediately followed by an Idle Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_02_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_trnctl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_02_P"}),
                          .msg            ("A Payload Control word should not be immediately followed by a Training Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_03_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_03_P"}),
                          .msg            ("A Training Control word should not be immediately followed by an Idle Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_04_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_pld === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_04_P"}),
                          .msg            ("A Training Control word should not be immediately followed by a Payload Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_05_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_idle_2_data === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_05_P"}),
                          .msg            ("An Idle Control word should not be followed by Payload transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_06_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_data_2_trnctl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_06_P"}),
                          .msg            ("Payload transfer should not be followed by a Training Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_07_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_payload_control === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_07_P"}),
                          .msg            ("A Payload Control word should not be followed by another Payload Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_08_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_training === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_08_P"}),
                          .msg            ("Length of the Training sequence on data path should not be greater than 21 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_09_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(fast_training_sequence_transition === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_09_P"}),
                          .msg            ("Length of the Training sequence on data path should not be less than 21 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_10_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_burst_end === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_10_P"}),
                          .msg            ("Payload transfer should end with an EOP or pause at a 16 byte block boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_11_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(parity_failed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_11_P"}),
                          .msg            ("DIP4 parity error occurred on data path interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_12_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(data_training_sequence_violation === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_12_P"}),
                          .msg            ("At least DATA_TRAINING_SEQUENCES_CNT number of Training sequences should occur on data path interface for every DATA_MAX_T half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_13_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (|sop_cnt && sop_cnt < ZI_SOP_DISTANCE && z_sop && next_state_data === ZI_PAYLOAD_CONTROL)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_13_P"}),
                          .msg            ("Successive SOPs should be separated by 8 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_14_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(reset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (present_state_data === ZI_DATA_BURST && z_eop_1_byte_valid &&(next_state_data === ZI_PAYLOAD_CONTROL || 
                           next_state_data === ZI_IDLE_CONTROL) &&(|latched_data[7:0] !== 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_14_P"}),
                          .msg            ("Unused byte of a Payload, terminated by EOP with one byte valid, should be 0x00 (hex)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_15_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_PAUSED && present_state_data === ZI_PAYLOAD_CONTROL &&
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_15_P"}),
                          .msg            ("SOP should not be issued to a port, when it is in paused status."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_17_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_training_data === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_17_P"}),
                          .msg            ("All the Training Data of a Training sequence on data path should be identical."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_19_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tdclk === ZI_SATISFIED && 
                           z_latched_status_update && present_state_data === ZI_PAYLOAD_CONTROL && 
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_19_P"}),
                          .msg            ("SOP should not be issued to a port beyond L_MAX distance, after the FIFO status became SATISFIED."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_20_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tsclk === ZI_SATISFIED && 
                           z_latched_status_update &&(word_cnt_satisfied > l_max))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_20_P"}),
                          .msg            ("Payload should not be transferred to a port beyond L_MAX distance, after the FIFO status became SATISFIED."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_40_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl && sop_preceded === 1'b0 &&(z_payload_control | z_idle_control) &&(z_eop | z_eop_abort))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_40_N"}),
                          .msg            ("EOP should not be issued to a port without a preceding SOP."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_39_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_ACTIVE &&( control_word_extension === 1'b0 &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) && latched_port_address[7:0] === port_address_received && z_sop && !z_eop && !z_eop_abort) ||
                           (control_word_extension === 1'b1 && next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && 
                           prev_latched_port_address[15:0] === {port_address_received, latched_port_address[7:0]} && z_sop))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_39_N"}),
                          .msg            ("Another SOP should not be issued to an active port without completing the previous transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_36_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && no_sop_when_port_inactive === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_36_N"}),
                          .msg            ("A Payload control word should not be issued to a port without SOP information, when the port is inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_35_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl &&(effective_tdat[15:12] === 4'b0011 || effective_tdat[15:12] === 4'b0101 ||
                           ((effective_tdat[15:12] === 4'b0001 || effective_tdat[15:12] === 4'b0111) && control_word_extension === 1'b0)))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_35_N"}),
                          .msg            ("Reserved encoding should not be transmitted as part of control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_33_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(min_packet_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_33_N"}),
                          .msg            ("Size of a packet should not be less than the specified min packet size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_34_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(max_packet_violation === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_34_N"}),
                          .msg            ("Size of a packet should not be greater than the specified max packet size."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_37_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (control_word_extension === 1'b1 && invalid_extended_pld_ctrl_termination === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_37_N"}),
                          .msg            ("A control word was not transmitted after indicating control word extension."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_00_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl & !(z_idle_control | z_payload_control | z_training_control))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_00_N"}),
                          .msg            ("A control word other than Idle Control/Payload Control/Training Control should not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_01_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_01_N"}),
                          .msg            ("A Payload Control word should not be immediately followed by an Idle Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_02_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&  narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_trnctl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_02_N"}),
                          .msg            ("A Payload Control word should not be immediately followed by a Training Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_03_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&  narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_idle === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_03_N"}),
                          .msg            ("A Training Control word should not be immediately followed by an Idle Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_04_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_pld === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_04_N"}),
                          .msg            ("A Training Control word should not be immediately followed by a Payload Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_05_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_idle_2_data === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_05_N"}),
                          .msg            ("An Idle Control word should not be followed by Payload transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_06_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_data_2_trnctl === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_06_N"}),
                          .msg            ("Payload transfer should not be followed by a Training Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_07_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_payload_control === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_07_N"}),
                          .msg            ("A Payload Control word should not be followed by another Payload Control word."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_08_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_training === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_08_N"}),
                          .msg            ("Length of the Training sequence on data path should not be greater than 21 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_09_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(fast_training_sequence_transition === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_09_N"}),
                          .msg            ("Length of the Training sequence on data path should not be less than 21 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_10_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_burst_end === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_10_N"}),
                          .msg            ("Payload transfer should end with an EOP or pause at a 16 byte block boundary."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_11_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(parity_failed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_11_N"}),
                          .msg            ("DIP4 parity error occurred on data path interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_12_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(data_training_sequence_violation === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_12_N"}),
                          .msg            ("At least DATA_TRAINING_SEQUENCES_CNT number of Training sequences should occur on data path interface for every DATA_MAX_T half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_13_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (|sop_cnt && sop_cnt < ZI_SOP_DISTANCE && z_sop && next_state_data === ZI_PAYLOAD_CONTROL)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_13_N"}),
                          .msg            ("Successive SOPs should be separated by 8 half clock cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_14_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(reset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (present_state_data === ZI_DATA_BURST && z_eop_1_byte_valid &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) &&(|latched_data[7:0] !== 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_14_N"}),
                          .msg            ("Unused byte of a Payload, terminated by EOP with one byte valid, should be 0x00 (hex)."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_15_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_PAUSED && present_state_data === ZI_PAYLOAD_CONTROL && 
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_15_N"}),
                          .msg            ("SOP should not be issued to a port, when it is in paused status."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_17_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_training_data === 1'b1 &&(data_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_17_N"}),
                          .msg            ("All the Training Data of a Training sequence on data path should be identical."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_19_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tdclk === ZI_SATISFIED && 
                           z_latched_status_update && present_state_data === ZI_PAYLOAD_CONTROL &&
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_19_N"}),
                          .msg            ("SOP should not be issued to a port beyond L_MAX distance, after the FIFO status became SATISFIED."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
        A_SPI4_2_TX_20_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tsclk === ZI_SATISFIED && 
                           z_latched_status_update &&(word_cnt_satisfied > l_max))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_20_N"}),
                          .msg            ("Payload should not be transferred to a port beyond L_MAX distance, after the FIFO status became SATISFIED."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_PHY_LAYER_CONSTRAINT));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZPL 
        M_SPI4_2_TX_40_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl && sop_preceded === 1'b0 &&(z_payload_control | z_idle_control) &&(z_eop | z_eop_abort))))));
        M_SPI4_2_TX_39_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_ACTIVE &&( control_word_extension === 1'b0 &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) && latched_port_address[7:0] === port_address_received &&
                           z_sop && !z_eop && !z_eop_abort) ||(control_word_extension === 1'b1 && next_state_data === ZI_DATA_BURST &&
                           present_state_data === ZI_PAYLOAD_CONTROL && prev_latched_port_address[15:0] === {port_address_received, latched_port_address[7:0]} && z_sop))))));
        M_SPI4_2_TX_36_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && no_sop_when_port_inactive === 1'b1)))));
        M_SPI4_2_TX_35_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl &&(effective_tdat[15:12] === 4'b0011 || effective_tdat[15:12] === 4'b0101 ||((effective_tdat[15:12] === 4'b0001 || 
                           effective_tdat[15:12] === 4'b0111) && control_word_extension === 1'b0)))))));
        M_SPI4_2_TX_33_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(min_packet_violation === 1'b1)))));
        M_SPI4_2_TX_34_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(max_packet_violation === 1'b1)))));
        M_SPI4_2_TX_37_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(control_word_extension === 1'b1 && invalid_extended_pld_ctrl_termination === 1'b1)))));
        M_SPI4_2_TX_00_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(z_tctl & !(z_idle_control | z_payload_control | z_training_control))))));
        M_SPI4_2_TX_01_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_idle === 1'b1)))));
        M_SPI4_2_TX_02_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_trnctl === 1'b1)))));
        M_SPI4_2_TX_03_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_idle === 1'b1)))));
        M_SPI4_2_TX_04_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_pld === 1'b1)))));
        M_SPI4_2_TX_05_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_idle_2_data === 1'b1)))));
        M_SPI4_2_TX_06_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_data_2_trnctl === 1'b1)))));
        M_SPI4_2_TX_07_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_payload_control === 1'b1)))));
        M_SPI4_2_TX_08_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_training === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_09_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(fast_training_sequence_transition === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_10_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_burst_end === 1'b1)))));
        M_SPI4_2_TX_11_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(parity_failed === 1'b1)))));
        M_SPI4_2_TX_12_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(data_training_sequence_violation === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_13_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (|sop_cnt && sop_cnt < ZI_SOP_DISTANCE && z_sop && next_state_data === ZI_PAYLOAD_CONTROL)))));
        M_SPI4_2_TX_14_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(reset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (present_state_data === ZI_DATA_BURST && z_eop_1_byte_valid &&(next_state_data === ZI_PAYLOAD_CONTROL || 
                           next_state_data === ZI_IDLE_CONTROL) &&(|latched_data[7:0] !== 1'b0))))));
        M_SPI4_2_TX_15_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_PAUSED && present_state_data === ZI_PAYLOAD_CONTROL &&
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))));
        M_SPI4_2_TX_17_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_training_data === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_19_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tdclk === ZI_SATISFIED && 
                           z_latched_status_update && present_state_data === ZI_PAYLOAD_CONTROL && 
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))));
        M_SPI4_2_TX_20_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tsclk === ZI_SATISFIED && 
                           z_latched_status_update &&(word_cnt_satisfied > l_max))))));
        M_SPI4_2_TX_40_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl && sop_preceded === 1'b0 &&(z_payload_control | z_idle_control) &&(z_eop | z_eop_abort))))));
        M_SPI4_2_TX_39_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_ACTIVE &&( control_word_extension === 1'b0 &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) && latched_port_address[7:0] === port_address_received && z_sop && !z_eop && !z_eop_abort) ||
                           (control_word_extension === 1'b1 && next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && 
                           prev_latched_port_address[15:0] === {port_address_received, latched_port_address[7:0]} && z_sop))))));
        M_SPI4_2_TX_36_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (next_state_data === ZI_DATA_BURST && present_state_data === ZI_PAYLOAD_CONTROL && no_sop_when_port_inactive === 1'b1)))));
        M_SPI4_2_TX_35_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl &&(effective_tdat[15:12] === 4'b0011 || effective_tdat[15:12] === 4'b0101 ||
                           ((effective_tdat[15:12] === 4'b0001 || effective_tdat[15:12] === 4'b0111) && control_word_extension === 1'b0)))))));
        M_SPI4_2_TX_33_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(min_packet_violation === 1'b1)))));
        M_SPI4_2_TX_34_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(max_packet_violation === 1'b1)))));
        M_SPI4_2_TX_37_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (control_word_extension === 1'b1 && invalid_extended_pld_ctrl_termination === 1'b1)))));
        M_SPI4_2_TX_00_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (z_tctl & !(z_idle_control | z_payload_control | z_training_control))))));
        M_SPI4_2_TX_01_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_idle === 1'b1)))));
        M_SPI4_2_TX_02_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&  narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_pld_2_trnctl === 1'b1)))));
        M_SPI4_2_TX_03_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 &&  narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_idle === 1'b1)))));
        M_SPI4_2_TX_04_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_trnctl_2_pld === 1'b1)))));
        M_SPI4_2_TX_05_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_idle_2_data === 1'b1)))));
        M_SPI4_2_TX_06_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_transition_data_2_trnctl === 1'b1)))));
        M_SPI4_2_TX_07_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_payload_control === 1'b1)))));
        M_SPI4_2_TX_08_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_state_retention_training === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_09_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(fast_training_sequence_transition === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_10_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_burst_end === 1'b1)))));
        M_SPI4_2_TX_11_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(parity_failed === 1'b1)))));
        M_SPI4_2_TX_12_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(data_training_sequence_violation === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_13_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (|sop_cnt && sop_cnt < ZI_SOP_DISTANCE && z_sop && next_state_data === ZI_PAYLOAD_CONTROL)))));
        M_SPI4_2_TX_14_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(reset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (present_state_data === ZI_DATA_BURST && z_eop_1_byte_valid &&(next_state_data === ZI_PAYLOAD_CONTROL ||
                           next_state_data === ZI_IDLE_CONTROL) &&(|latched_data[7:0] !== 1'b0))))));
        M_SPI4_2_TX_15_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (port_status === ZI_PORT_PAUSED && present_state_data === ZI_PAYLOAD_CONTROL && 
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))));
        M_SPI4_2_TX_17_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&(invalid_training_data === 1'b1 &&(data_max_t !== 0))))));
        M_SPI4_2_TX_19_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tdclk === ZI_SATISFIED && 
                           z_latched_status_update && present_state_data === ZI_PAYLOAD_CONTROL &&
                           next_state_data === ZI_DATA_BURST &&(latched_sop_posedge === 1'b1 || latched_sop_negedge === 1'b1))))));
        M_SPI4_2_TX_20_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tdclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset === 1'b0 && reset === 1'b0 && narrow_framed_tdat_enable === 1'b1) &&
                           (enable_fifo_status_if === 1'b1))&&(fifo_status_tsclk === ZI_SATISFIED && 
                           z_latched_status_update &&(word_cnt_satisfied > l_max))))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZPL 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate



generate
  case (ZI_LINK_LAYER_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER_ZLL 
        A_SPI4_2_TX_23_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_status_pattern_end === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_23_P"}),
                          .msg            ("Length of the FIFO status sequence should not be less than the value of CALENDAR_LEN multiplied by CALENDAR_M."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_24_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(dip2_parity_failed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_24_P"}),
                          .msg            ("DIP2 parity error occurred on the FIFO status interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_25_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_state_retention_fifo === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_25_P"}),
                          .msg            ("Length of the FIFO status sequence should not be greater than the value of CALENDAR_LEN multiplied by CALENDAR_M."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_28_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&((no_training_sequence_after_reset_fifo === 1'b1) &&(fifo_max_t !== 0) &&(LINK_SIDE_P === 1'b0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_28_P"}),
                          .msg            ("When LVDS_IO mode is enabled, training sequences should be transmitted on FIFO status interface after reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_29_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(no_framing_pattern_after_reset_fifo === 1'b1 && LINK_SIDE_P === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_29_P"}),
                          .msg            ("When LVTTL_IO mode is enabled, framing pattern (2'b11) should be transmitted on FIFO status interface after reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_30_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_retention_training_fifo === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_30_P"}),
                          .msg            ("Length of the Training sequence on FIFO interface should not be greater than 20."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_31_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(fast_transition_training_fifo === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_31_P"}),
                          .msg            ("Length of the Training sequence on FIFO interface should not be less than 20."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_32_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(fifo_training_sequence_violation === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_32_P"}),
                          .msg            ("At least one Training sequence should occur on FIFO interface for every FIFO_MAX_T cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_27_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(bandwidth_reprovisioning === 32'b1 &&
                           next_state_fifo === ZI_CALENDAR_SELECTION_WORD && !(tstat === 2'b01 || tstat === 2'b10))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_27_P"}),
                          .msg            ("The value of calendar selection word should be either 2'b01 or 2'b10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_23_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(invalid_status_pattern_end === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_23_N"}),
                          .msg            ("Length of the FIFO status sequence should not be less than the value of CALENDAR_LEN multiplied by CALENDAR_M."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_24_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(dip2_parity_failed === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_24_N"}),
                          .msg            ("DIP2 parity error occurred on the FIFO status interface."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_25_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(invalid_state_retention_fifo === 1'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_25_N"}),
                          .msg            ("Length of the FIFO status sequence should not be greater than the value of CALENDAR_LEN multiplied by CALENDAR_M."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_28_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (no_training_sequence_after_reset_fifo === 1'b1 &&(fifo_max_t !== 0) && LINK_SIDE_P === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_28_N"}),
                          .msg            ("when LVDS_IO mode is enabled,training sequences should be transmitted on FIFO status interface after reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_29_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (no_framing_pattern_after_reset_fifo === 1'b1 && LINK_SIDE_P === 1'b0)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_29_N"}),
                          .msg            ("When LVTTL_IO mode is enabled, framing pattern (2'b11) should be transmitted on FIFO status interface after reset."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_30_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (invalid_retention_training_fifo === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_30_N"}),
                          .msg            ("Length of the Training sequence on FIFO interface should not be greater than 20."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_31_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (fast_transition_training_fifo === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_31_N"}),
                          .msg            ("Length of the Training sequence on FIFO interface should not be less than 20."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_32_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (fifo_training_sequence_violation === 1'b1 &&(fifo_max_t !== 0))))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_32_N"}),
                          .msg            ("At least one Training sequence should occur on FIFO interface for every FIFO_MAX_T cycles."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
        A_SPI4_2_TX_27_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (next_state_fifo === ZI_CALENDAR_SELECTION_WORD && !(tstat === 2'b01 || tstat === 2'b10) && bandwidth_reprovisioning === 32'b1)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SPI4_2_TX_27_N"}),
                          .msg            ("The value of calendar selection word should be either 2'b01 or 2'b10."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_LINK_LAYER_CONSTRAINT));
      end
    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER_ZLL 
        M_SPI4_2_TX_23_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_status_pattern_end === 1'b1)))));
        M_SPI4_2_TX_24_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(dip2_parity_failed === 1'b1)))));
        M_SPI4_2_TX_25_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_state_retention_fifo === 1'b1)))));
        M_SPI4_2_TX_28_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&((no_training_sequence_after_reset_fifo === 1'b1) &&(fifo_max_t !== 0) &&(LINK_SIDE_P === 1'b0))))));
        M_SPI4_2_TX_29_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(no_framing_pattern_after_reset_fifo === 1'b1 && LINK_SIDE_P === 1'b0)))));
        M_SPI4_2_TX_30_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(invalid_retention_training_fifo === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_31_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(fast_transition_training_fifo === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_32_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(fifo_training_sequence_violation === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_27_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (next_state_fifo === ZI_CALENDAR_SELECTION_WORD && !(tstat === 2'b01 || tstat === 2'b10) && bandwidth_reprovisioning === 32'b1)))));
        M_SPI4_2_TX_23_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(invalid_status_pattern_end === 1'b1)))));
        M_SPI4_2_TX_24_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(dip2_parity_failed === 1'b1)))));
        M_SPI4_2_TX_25_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&(invalid_state_retention_fifo === 1'b1)))));
        M_SPI4_2_TX_28_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (no_training_sequence_after_reset_fifo === 1'b1 &&(fifo_max_t !== 0) && LINK_SIDE_P === 1'b0)))));
        M_SPI4_2_TX_29_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (no_framing_pattern_after_reset_fifo === 1'b1 && LINK_SIDE_P === 1'b0)))));
        M_SPI4_2_TX_30_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (invalid_retention_training_fifo === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_31_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (fast_transition_training_fifo === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_32_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (inverted_tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1 && lvds_io_wire === 1'b1) &&
                           (fifo_training_sequence_violation === 1'b1 &&(fifo_max_t !== 0))))));
        M_SPI4_2_TX_27_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (tsclk),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset === 1'b0 && reset === 1'b0 && enable_fifo_status_if === 1'b1)&&(bandwidth_reprovisioning === 32'b1 &&
                           next_state_fifo === ZI_CALENDAR_SELECTION_WORD && !(tstat === 2'b01 || tstat === 2'b10))))));
      end
    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER_ZLL 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase
endgenerate

`endif // QVL_ASSERT_ON

