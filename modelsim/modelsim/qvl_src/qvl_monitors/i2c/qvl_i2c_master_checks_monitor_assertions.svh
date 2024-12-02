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

  parameter QVL_MSG = "QVL_I2C_MASTER_VIOLATION :";
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
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_no_scl_low_when_sda_high_bus_idle)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_no_scl_low_when_sda_high_bus_idle"}),
                          .msg            ("SCL should not toggle when the bus is IDLE."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_inactive: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_inactive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_inactive"}),
                          .msg            ("If scl_in on the bus is not equal to scl_out, then scl_out should be made inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_inactive: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_inactive)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_inactive"}),
                          .msg            ("If sda_in on the bus is not equal to sda_out, then sda_out should be made inactive."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_after_clock_sync_high_width_to_be_equal_that_of_device_had_shortest_high: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_after_clock_sync_high_width_to_be_equal_that_of_device_had_shortest_high)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_after_clock_sync_high_width_to_be_equal_that_of_device_had_shortest_high"}),
                          .msg            ("Once Clock synchronization is over, the HIGH to LOW transition of SCL should be synchornized with the other device's HIGH to LOW transition of SCL."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_ms_no_arb_and_clk_sync_allowed_in_hs_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b0),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&(master_active || slave_active) &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_no_arb_and_clk_sync_allowed_in_hs_mode)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_ms_no_arb_and_clk_sync_allowed_in_hs_mode"}),
                          .msg            ("Arbitration and Clock synchronization are not allowed in HS Mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_max_txn_len_to_equal_length_parameter_value: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_max_txn_len_to_equal_length_parameter_value)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_max_txn_len_to_equal_length_parameter_value"}),
                          .msg            ("Master should signal STOP or Re-Start, if the Read/Write Transaction length reaches the configured value of Max Transaction Length Count Parameter, MAX_TXN_LENGTH."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_serial_data_length_always_8_bits_wide: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_serial_data_length_always_8_bits_wide)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_serial_data_length_always_8_bits_wide"}),
                          .msg            ("Every data phase is only 8 bits wide."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_mas_to_stop_or_restart_if_slv_issues_slave_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           ((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_mas_to_stop_or_restart_if_slv_issues_slave_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_mas_to_stop_or_restart_if_slv_issues_slave_nack"}),
                          .msg            ("Master to Restart/Stop the transaction, if slave issues NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_cbus_transaction_ends_with_stop: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_cbus_transaction_ends_with_stop)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_cbus_transaction_ends_with_stop"}),
                          .msg            ("CBUS transactions should always end with STOP."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_during_arbitration_if_own_address_master_to_switch_role_as_slave: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_arbitration_if_own_address_master_to_switch_role_as_slave)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_during_arbitration_if_own_address_master_to_switch_role_as_slave"}),
                          .msg            ("For a I2C device that has Master and Slave functions together, During arbitration, if slave address matches with its own slave address, the Master should abrubtly terminate the arbitration cycle to provide sufficient time for it's slave to respond to the transaction."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_sda_to_be_stable_as_long_as_slave_asserts_scl_low_towards_slave_wait: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_sda_to_be_stable_as_long_as_slave_asserts_scl_low_towards_slave_wait)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_sda_to_be_stable_as_long_as_slave_asserts_scl_low_towards_slave_wait"}),
                          .msg            ("SDA Should be held stable as long as SCL is low."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_for_read_txn_mas_should_assert_ack_or_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_for_read_txn_mas_should_assert_ack_or_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_for_read_txn_mas_should_assert_ack_or_nack"}),
                          .msg            ("For Read data transactions, Master should assert ACK/NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_for_write_txn_mas_should_deassert_sda_out_during_ack_or_nack: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_for_write_txn_mas_should_deassert_sda_out_during_ack_or_nack)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_for_write_txn_mas_should_deassert_sda_out_during_ack_or_nack"}),
                          .msg            ("For Write transactions, Master should deassert sda_out_en signal during ACK/NACK."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_during_write_data_master_should_drive_sda_during_data_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_write_data_master_should_drive_sda_during_data_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_during_write_data_master_should_drive_sda_during_data_txn"}),
                          .msg            ("For Write transactions, Master should drive SDA during data transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_during_write_data_master_should_drive_scl_during_data_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_write_data_master_should_drive_scl_during_data_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_during_write_data_master_should_drive_scl_during_data_txn"}),
                          .msg            ("During Write transactions, Master should drive SCL during data transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_during_address_phase_master_should_drive_sda_and_scl: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_address_phase_master_should_drive_sda_and_scl)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_during_address_phase_master_should_drive_sda_and_scl"}),
                          .msg            ("During address phase, Master should drive SDA and SCL."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_except_start_byte_start_to_follow_at_least_one_data_phase: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b0),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_except_start_byte_start_to_follow_at_least_one_data_phase)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_except_start_byte_start_to_follow_at_least_one_data_phase"}),
                          .msg            ("Except for Start Byte transfer, every Start signal should follow, at least one data phase."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_reserved_addresses_not_allowed: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_reserved_addresses_not_allowed)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_reserved_addresses_not_allowed"}),
                          .msg            ("Reserved addresses should not be issued."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_gcall_address_2nd_byte_8b00_not_allowed: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_gcall_address_2nd_byte_8b00_not_allowed)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_gcall_address_2nd_byte_8b00_not_allowed"}),
                          .msg            ("On the 2nd byte of GCALL address, 8'h00 is not allowed."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_master_to_issue_gcall_address_first_before_any_valid_txn: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_master_to_issue_gcall_address_first_before_any_valid_txn)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_master_to_issue_gcall_address_first_before_any_valid_txn"}),
                          .msg            ("After reset, Master should issue GCALL address before any other transfer."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_start_byte_to_follow_repeated_start: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_start_byte_to_follow_repeated_start)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_start_byte_to_follow_repeated_start"}),
                          .msg            ("Start byte transfer should follow Repeated Start."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_cbus_not_needed_in_fast_or_hs_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_cbus_not_needed_in_fast_or_hs_mode)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_cbus_not_needed_in_fast_or_hs_mode"}),
                          .msg            ("CBUS not allowed in Fast or HS mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_reseved_addresses_not_allowed_in_hs_mode: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_reseved_addresses_not_allowed_in_hs_mode)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_reseved_addresses_not_allowed_in_hs_mode"}),
                          .msg            ("Reserved address, 8'b0000_1000 is not allowed in HS Mode."),
                          .severity_level (QVL_ERROR),
                          .property_type  (ZI_CONSTARINT));
        A_I2C_m_why_same_address_of_slave_which_is_part_of_same_device: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_why_same_address_of_slave_which_is_part_of_same_device)))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_I2C_m_why_same_address_of_slave_which_is_part_of_same_device"}),
                          .msg            ("If the I2C device has Master and Slave functions, as a Master, it should not issue the address that addresses its own slave."),
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
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_no_scl_low_when_sda_high_bus_idle)))));
        M_I2C_ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_inactive: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_if_scl_in_inequal_to_scl_out_should_make_scl_out_inactive)))));
        M_I2C_ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_inactive: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_if_sda_in_inequal_to_sda_out_should_make_sda_out_inactive)))));
        M_I2C_ms_after_clock_sync_high_width_to_be_equal_that_of_device_had_shortest_high: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_after_clock_sync_high_width_to_be_equal_that_of_device_had_shortest_high)))));
        M_I2C_ms_no_arb_and_clk_sync_allowed_in_hs_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&(master_active || slave_active) &&
                           (sampling_enable || (start_or_repeated_start || stop_state) ) &&
                           ((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(ms_no_arb_and_clk_sync_allowed_in_hs_mode)))));
        M_I2C_m_max_txn_len_to_equal_length_parameter_value: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_max_txn_len_to_equal_length_parameter_value)))));
        M_I2C_m_serial_data_length_always_8_bits_wide: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_serial_data_length_always_8_bits_wide)))));
        M_I2C_m_mas_to_stop_or_restart_if_slv_issues_slave_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&
                           ((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_mas_to_stop_or_restart_if_slv_issues_slave_nack)))));
        M_I2C_m_cbus_transaction_ends_with_stop: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_cbus_transaction_ends_with_stop)))));
        M_I2C_m_during_arbitration_if_own_address_master_to_switch_role_as_slave: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_arbitration_if_own_address_master_to_switch_role_as_slave)))));
        M_I2C_m_sda_to_be_stable_as_long_as_slave_asserts_scl_low_towards_slave_wait: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_sda_to_be_stable_as_long_as_slave_asserts_scl_low_towards_slave_wait)))));
        M_I2C_m_for_read_txn_mas_should_assert_ack_or_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_for_read_txn_mas_should_assert_ack_or_nack)))));
        M_I2C_m_for_write_txn_mas_should_deassert_sda_out_during_ack_or_nack: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_for_write_txn_mas_should_deassert_sda_out_during_ack_or_nack)))));
        M_I2C_m_during_write_data_master_should_drive_sda_during_data_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_write_data_master_should_drive_sda_during_data_txn)))));
        M_I2C_m_during_write_data_master_should_drive_scl_during_data_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_write_data_master_should_drive_scl_during_data_txn)))));
        M_I2C_m_during_address_phase_master_should_drive_sda_and_scl: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_during_address_phase_master_should_drive_sda_and_scl)))));
        M_I2C_m_except_start_byte_start_to_follow_at_least_one_data_phase: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_except_start_byte_start_to_follow_at_least_one_data_phase)))));
        M_I2C_m_reserved_addresses_not_allowed: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_reserved_addresses_not_allowed)))));
        M_I2C_m_gcall_address_2nd_byte_8b00_not_allowed: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_gcall_address_2nd_byte_8b00_not_allowed)))));
        M_I2C_m_master_to_issue_gcall_address_first_before_any_valid_txn: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_master_to_issue_gcall_address_first_before_any_valid_txn)))));
        M_I2C_m_start_byte_to_follow_repeated_start: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_start_byte_to_follow_repeated_start)))));
        M_I2C_m_cbus_not_needed_in_fast_or_hs_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_cbus_not_needed_in_fast_or_hs_mode)))));
        M_I2C_m_reseved_addresses_not_allowed_in_hs_mode: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_reseved_addresses_not_allowed_in_hs_mode)))));
        M_I2C_m_why_same_address_of_slave_which_is_part_of_same_device: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clock ),
                          .reset_n   (!(areset) ),
                          .enable    (1'b1),
                          .test_expr (((areset == 1'b0 && reset == 1'b0 &&((master_active || dut_as_master) && (slave_active || dut_as_slave)) && 
                           clock_enable &&((ZI_DISABLE_CHECKS == 1)? dut_as_master : 1'b1)) 
                           &&(m_why_same_address_of_slave_which_is_part_of_same_device)))));
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
