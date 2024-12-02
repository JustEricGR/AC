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

  parameter QVL_MSG = "QVL_I2C_SLAVE_VIOLATION :";
  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = ZI_CONSTARINT; // 0 = `OVL_ZIN2OVLSVA
//  parameter QVL_PROPERTY_TYPE = 0; // 0 = `OVL_ZIN2OVLSVA
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_ALL;

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_I2C_ms_no_scl_low_when_sda_high_bus_idle: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&  
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_no_scl_low_when_sda_high_bus_idle)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_no_scl_low_when_sda_high_bus_idle"}),
                          .msg            ("SCL should not toggle when the bus is IDLE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_en_n_inactive: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && 
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_en_n_inactive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_en_n_inactive"}),
                          .msg            ("If scl_in on the bus is not equal to scl_out, then scl_out_en_n should be made inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_en_n_inactive: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&  
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_en_n_inactive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_en_n_inactive"}),
                          .msg            ("If sda_in on the bus is not equal to sda_out, then sda_en_n should be made inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_address_should_match_when_the_slave_device_responds_for_a_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b0),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_address_should_match_when_the_slave_device_responds_for_a_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_address_should_match_when_the_slave_device_responds_for_a_txn"}),
                          .msg            ("When Slave claims the transaction by signaling ACK during address phase, the address seen on the bus should match with its address."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_bit_level_hand_shake_is_not_allowed_by_stretching_scl_low: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_bit_level_hand_shake_is_not_allowed_by_stretching_scl_low)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_bit_level_hand_shake_is_not_allowed_by_stretching_scl_low"}),
                          .msg            ("Slave interruption through signaling SCL LOW can be only at the 8 bits boundary, it cannot be between the data/address bits."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_for_write_txn_slv_should_assert_ack_or_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_for_write_txn_slv_should_assert_ack_or_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_for_write_txn_slv_should_assert_ack_or_nack"}),
                          .msg            ("For Write transactions, slave should assert ACK/NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_for_read_txn_slv_should_deassert_sda_out_en_n_during_ack_or_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_for_read_txn_slv_should_deassert_sda_out_en_n_during_ack_or_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_for_read_txn_slv_should_deassert_sda_out_en_n_during_ack_or_nack"}),
                          .msg            ("For Read transactions, Slave should deassert sda_out_en during ACK/NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_during_read_data_slave_should_drive_sda_during_data_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_during_read_data_slave_should_drive_sda_during_data_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_during_read_data_slave_should_drive_sda_during_data_txn"}),
                          .msg            ("For Read transactions, Slave should drive SDA during data transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_during_read_data_slave_should_drive_scl_during_data_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_during_read_data_slave_should_drive_scl_during_data_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_during_read_data_slave_should_drive_scl_during_data_txn"}),
                          .msg            ("For Read transactions, Slave should drive SCL during data transfers."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_no_ack_for_cbus_cycle: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_no_ack_for_cbus_cycle)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_no_ack_for_cbus_cycle"}),
                          .msg            ("No ACK is issued for CBUS Cycle."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_gcall_address_1st_phase_to_have_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_gcall_address_1st_phase_to_have_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_gcall_address_1st_phase_to_have_nack"}),
                          .msg            ("For the 1st phase of GCALL address, NACK should be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_start_byte_to_follow_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_start_byte_to_follow_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_start_byte_to_follow_nack"}),
                          .msg            ("START Byte should always follow NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_s_hs_mode_signaling_should_be_followed_w_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_hs_mode_signaling_should_be_followed_w_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_s_hs_mode_signaling_should_be_followed_w_nack"}),
                          .msg            ("HS Mode signaling should always be followed with NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_I2C_ms_no_scl_low_when_sda_high_bus_idle: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&  
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_no_scl_low_when_sda_high_bus_idle)))));
        M_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_en_n_inactive: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && 
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_en_n_inactive)))));
        M_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_en_n_inactive: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&  
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_en_n_inactive)))));
        M_I2C_s_address_should_match_when_the_slave_device_responds_for_a_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_address_should_match_when_the_slave_device_responds_for_a_txn)))));
        M_I2C_s_bit_level_hand_shake_is_not_allowed_by_stretching_scl_low: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_bit_level_hand_shake_is_not_allowed_by_stretching_scl_low)))));
        M_I2C_s_for_write_txn_slv_should_assert_ack_or_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_for_write_txn_slv_should_assert_ack_or_nack)))));
        M_I2C_s_for_read_txn_slv_should_deassert_sda_out_en_n_during_ack_or_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_for_read_txn_slv_should_deassert_sda_out_en_n_during_ack_or_nack)))));
        M_I2C_s_during_read_data_slave_should_drive_sda_during_data_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_during_read_data_slave_should_drive_sda_during_data_txn)))));
        M_I2C_s_during_read_data_slave_should_drive_scl_during_data_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr ((((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(slave_active) )&&(s_during_read_data_slave_should_drive_scl_during_data_txn)))));
        M_I2C_s_no_ack_for_cbus_cycle: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_no_ack_for_cbus_cycle)))));
        M_I2C_s_gcall_address_1st_phase_to_have_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_gcall_address_1st_phase_to_have_nack)))));
        M_I2C_s_start_byte_to_follow_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_start_byte_to_follow_nack)))));
        M_I2C_s_hs_mode_signaling_should_be_followed_w_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 && clock_enable &&(master_active || dut_as_master) &&(slave_active || dut_as_slave) &&((ZI_DISABLE_CHECKS == 1)? dut_as_slave : 1'b1)) 
                           &&(s_hs_mode_signaling_should_be_followed_w_nack)))));
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
