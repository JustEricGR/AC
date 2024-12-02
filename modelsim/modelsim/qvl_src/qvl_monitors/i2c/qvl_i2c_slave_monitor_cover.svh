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


`ifdef QVL_COVER_ON

  //------------------------------------------------------------------------------
  //SV Covergroups start here
  //------------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always@(posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 reset == 1'b0 &&
                                 areset == 1'b0 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

`ifdef QVL_SV_COVERGROUP

  covergroup i2c_slave_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for I2C_SLAVE Monitor";

    S0 : coverpoint (!($stable(total_starts, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Starts = {1};
        type_option.comment = "Total Starts";
        }

    S1 : coverpoint (!($stable(total_reads, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Reads = {1};
        type_option.comment = "Total Reads";
        }

    S2 : coverpoint (!($stable(total_writes, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Writes = {1};
        type_option.comment = "Total Writes";
        }

    S3 : coverpoint (!($stable(total_stops, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Stops = {1};
        type_option.comment = "Total Stops";
        }

    S4 : coverpoint (!($stable(total_repeated_starts, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Repeated_Starts = {1};
        type_option.comment = "Total Repeated Starts";
        }

    S5 : coverpoint (!($stable(total_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Valid_Transactions = {1};
        type_option.comment = "Total Valid Transactions";
        }

    S6 : coverpoint (!($stable(total_data_phases, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Valid_Data_Phases = {1};
        type_option.comment = "Total Valid Data Phases";
        }

    S7 : coverpoint (!($stable(total_gcall_addresses, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Gcall_Addresses = {1};
        type_option.comment = "Total Gcall Addresses";
        }

    S8 : coverpoint (!($stable(total_gcall_slave_rst_cycles, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Gcall_Slave_Resets = {1};
        type_option.comment = "Total Gcall Slave Resets";
        }

    S9 : coverpoint (!($stable(total_gcall_slve_no_rst_cycles, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Gcall_NO_Slave_Resets = {1};
        type_option.comment = "Total Gcall NO Slave Resets";
        }

    S10 : coverpoint (!($stable(total_hw_gcalls, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_HW_Gcalls = {1};
        type_option.comment = "Total HW Gcalls";
        }

    S11 : coverpoint (!($stable(total_hs_mode_cycles, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_HS_Mode_Entries = {1};
        type_option.comment = "Total HS Mode Entries";
        }

    S12 : coverpoint (!($stable(total_start_bytes, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Start_Bytes = {1};
        type_option.comment = "Total Start Bytes";
        }

    S13 : coverpoint (!($stable(total_acks, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_ACKs = {1};
        type_option.comment = "Total ACKs";
        }

    S14 : coverpoint (!($stable(total_nacks, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_NACKs = {1};
        type_option.comment = "Total NACKs";
        }

    S15 : coverpoint (!($stable(total_cbus_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_CBUS_Transactions = {1};
        type_option.comment = "Total CBUS Transactions";
        }

  endgroup : i2c_slave_statistics


  covergroup i2c_slave_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for I2C_SLAVE Monitor";

    C0 : coverpoint (!($stable(total_7bits_address_phases, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_7_Bit_Addresses = {1};
        type_option.comment = "Total 7 Bit Addresses";
        }

    C1 : coverpoint (!($stable(total_10bit_address_phases, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_10_Bit_Addresses = {1};
        type_option.comment = "Total 10 Bit Addresses";
        }

  endgroup : i2c_slave_cornercases

  i2c_slave_statistics  I2C_SLAVE_STATISTICS = new();
  i2c_slave_cornercases  I2C_SLAVE_CORNERCASES = new();

  initial
    begin
      i2c_slave_statistics::type_option.comment = "Statistics for I2C_SLAVE Monitor";
      i2c_slave_cornercases::type_option.comment = "Cornercases for I2C_SLAVE Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for I2C_SLAVE Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for I2C_SLAVE Monitor -------------------------");

      $display("Total Starts                                  : %0d", total_starts);
      $display("Total Reads                                   : %0d", total_reads);
      $display("Total Writes                                  : %0d", total_writes);
      $display("Total Stops                                   : %0d", total_stops);
      $display("Total Repeated Starts                         : %0d", total_repeated_starts);
      $display("Total Valid Transactions                      : %0d", total_transactions);
      $display("Total Valid Data Phases                       : %0d", total_data_phases);
      $display("Total Gcall Addresses                         : %0d", total_gcall_addresses);
      $display("Total Gcall Slave Resets                      : %0d", total_gcall_slave_rst_cycles);
      $display("Total Gcall NO Slave Resets                   : %0d", total_gcall_slve_no_rst_cycles);
      $display("Total HW Gcalls                               : %0d", total_hw_gcalls);
      $display("Total HS Mode Entries                         : %0d", total_hs_mode_cycles);
      $display("Total Start Bytes                             : %0d", total_start_bytes);
      $display("Total ACKs                                    : %0d", total_acks);
      $display("Total NACKs                                   : %0d", total_nacks);
      $display("Total CBUS Transactions                       : %0d", total_cbus_transactions);

      $display("------------------- Cornercases for I2C_SLAVE Monitor -------------------------");

      $display("Total 7 Bit Addresses                         : %0d", total_7bits_address_phases);
      $display("Total 10 Bit Addresses                        : %0d", total_10bit_address_phases);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
