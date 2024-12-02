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

  wire not_clk = ~clk;
  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (ZI_RECEIVE_CONSTRAINT)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_SATA_ALIGNP_D24_3_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((align_p_D24_3_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ALIGNP_D24_3_VIOLATION_P"}),
                          .msg            ("The COMRESET or COMINIT or COMWAKE bursts must not have any characters other than ALINGp or D24.3 characters."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_ALIGNP_D24_3_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (align_p_D24_3_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_ALIGNP_D24_3_VIOLATION_N"}),
                          .msg            ("The COMRESET or COMINIT or COMWAKE bursts must not have any characters other than ALINGp or D24.3 characters."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_BURST_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset),
                          .enable    (1'b1),
                          .test_expr ((comreset_burst_violation === 1'b1) & 
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_BURST_VIOLATION_P"}),
                          .msg            ("COMRESET OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_BURST_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_burst_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_BURST_VIOLATION_N"}),
                          .msg            ("COMRESET OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comreset_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_BURST_TIME_VIOLATION_P"}),
                          .msg            ("Burst time of each burst in COMRESET signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_BURST_TIME_VIOLATION_N"}),
                          .msg            ("Burst time of each burst in COMRESET signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comreset_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_P"}),
                          .msg            ("The interburst spacing in COMRESET signalling must be 320ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_inter_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_N"}),
                          .msg            ("The interburst spacing in COMRESET signalling must be 320ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((h_comwake_wo_cominit_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_P"}),
                          .msg            ("HOST must not transmit COMWAKE without the reception of COMINIT from the DEVICE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (h_comwake_wo_cominit_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_N"}),
                          .msg            ("HOST must not transmit COMWAKE without the reception of COMINIT from the DEVICE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((d_comwake_wo_h_comwake_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_P"}),
                          .msg            ("DEVICE must not transmit COMWAKE without the reception of COMWAKE from the HOST."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (d_comwake_wo_h_comwake_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_N"}),
                          .msg            ("DEVICE must not transmit COMWAKE without the reception of COMWAKE from the HOST."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((d10_2_before_d_comwake_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_P"}),
                          .msg            ("HOST must not start the transmission of D10.2 characterswithout the reception of COMWAKE from the DEVICE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (d10_2_before_d_comwake_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_N"}),
                          .msg            ("HOST must not start the transmission of D10.2 characterswithout the reception of COMWAKE from the DEVICE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_BURST_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_burst_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_BURST_VIOLATION_P"}),
                          .msg            ("COMINIT OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_BURST_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_burst_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_BURST_VIOLATION_N"}),
                          .msg            ("COMINIT OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_BURST_TIME_VIOLATION_P"}),
                          .msg            ("Burst time of each burst in COMINIT signaling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_BURST_TIME_VIOLATION_N"}),
                          .msg            ("Burst time of each burst in COMINIT signaling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_P"}),
                          .msg            ("The interburst spacing in COMINIT signalling must be 320ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_inter_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_N"}),
                          .msg            ("The interburst spacing in COMINIT signalling must be 320ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_BURST_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_burst_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_BURST_VIOLATION_P"}),
                          .msg            ("COMWAKE OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_BURST_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_burst_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_BURST_VIOLATION_N"}),
                          .msg            ("COMWAKE OOB signalling must consist of at least 6 bursts."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_BURST_TIME_VIOLATION_P"}),
                          .msg            ("The burst spacing in the COMWAKE signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_BURST_TIME_VIOLATION_N"}),
                          .msg            ("The burst spacing in the COMWAKE signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_P"}),
                          .msg            ("The interburst spacing in the COMWAKE signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_inter_burst_time_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_N"}),
                          .msg            ("The interburst spacing in the COMWAKE signalling must be 106.7ns."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_LAST_IDLE_VIOLATION_P: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_last_idle_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_LAST_IDLE_VIOLATION_P"}),
                          .msg            ("The bus should not be idle for more than 228.3ns after the deassertion of COMWAKE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
        A_SATA_COMWAKE_LAST_IDLE_VIOLATION_N: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_last_idle_violation === 1'b1))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_SATA_COMWAKE_LAST_IDLE_VIOLATION_N"}),
                          .msg            ("The bus should not be idle for more than 228.3ns after the deassertion of COMWAKE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_RECEIVE_CONSTRAINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_SATA_ALIGNP_D24_3_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((align_p_D24_3_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_ALIGNP_D24_3_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (align_p_D24_3_violation === 1'b1))));
        M_SATA_COMRESET_BURST_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk),
                          .reset_n   (~areset),
                          .enable    (1'b1),
                          .test_expr ((comreset_burst_violation === 1'b1) & 
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMRESET_BURST_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_burst_violation === 1'b1))));
        M_SATA_COMRESET_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comreset_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMRESET_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_burst_time_violation === 1'b1))));
        M_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comreset_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMRESET_INTER_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comreset_inter_burst_time_violation === 1'b1))));
        M_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((h_comwake_wo_cominit_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_H_COMWAKE_WO_COMINIT_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (h_comwake_wo_cominit_violation === 1'b1))));
        M_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((d_comwake_wo_h_comwake_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_D_COMWAKE_WO_H_COMWAKE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (d_comwake_wo_h_comwake_violation === 1'b1))));
        M_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((d10_2_before_d_comwake_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_D10_2_BEFORE_D_COMWAKE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (d10_2_before_d_comwake_violation === 1'b1))));
        M_SATA_COMINIT_BURST_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_burst_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMINIT_BURST_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_burst_violation === 1'b1))));
        M_SATA_COMINIT_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMINIT_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_burst_time_violation === 1'b1))));
        M_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((cominit_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMINIT_INTER_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (cominit_inter_burst_time_violation === 1'b1))));
        M_SATA_COMWAKE_BURST_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_burst_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMWAKE_BURST_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_burst_violation === 1'b1))));
        M_SATA_COMWAKE_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMWAKE_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_burst_time_violation === 1'b1))));
        M_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_inter_burst_time_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMWAKE_INTER_BURST_TIME_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_inter_burst_time_violation === 1'b1))));
        M_SATA_COMWAKE_LAST_IDLE_VIOLATION_P: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((comwake_last_idle_violation === 1'b1) &
                           (bypass_power_on_seq === 1'b0))));
        M_SATA_COMWAKE_LAST_IDLE_VIOLATION_N: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (not_clk ),
                          .reset_n   (~(areset | reset)),
                          .enable    (1'b1),
                          .test_expr ((pw_DOUBLE_DATA_RATE == 1) &
                           (bypass_power_on_seq === 1'b0) &
                           (comwake_last_idle_violation === 1'b1))));
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
