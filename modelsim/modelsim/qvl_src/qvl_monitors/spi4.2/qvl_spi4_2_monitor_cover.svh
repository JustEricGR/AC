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

  always@(posedge rdclk)
    begin
      prevent_x_to_valid_transition_count = 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 && 
                              prevent_x_to_valid_transition_count == 1'b1);

`ifdef QVL_SV_COVERGROUP

  covergroup spi4_2_statistics;

    type_option.strobe = 1;
    type_option.comment = "Statistics for SPI4_2 Monitor";

    S0 : coverpoint (!($stable(packet_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Packets_Transferred = {1};
        type_option.comment = "Number of Packets Transferred";
        }

    S1 : coverpoint (!($stable(byte_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Bytes_Transferred = {1};
        type_option.comment = "Number of Bytes Transferred";
        }

    S2 : coverpoint (!($stable(max_idle_control_count_between_transaction, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Minimum_Length_of_Packets_Transferred = {1};
        type_option.comment = "Maximum Idle Controls Between Transactions";
        }

    S3 : coverpoint (!($stable(max_packet_size, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Maximum_Length_of_a_Packet = {1};
        type_option.comment = "Maximum Packet Size.";
        }
  endgroup : spi4_2_statistics

  //covergroup spi4_2_cornercases @ (posedge rdclk);
  covergroup spi4_2_cornercases;


    type_option.strobe = 1;
    type_option.comment = "Cornercases for SPI4_2 Monitor";

    C0 : coverpoint (!($stable(fifo_status_starving_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins STARVING_FIFO_Status_Count = {1};
        type_option.comment = "STARVING FIFO Status Count";
        }

    C1 : coverpoint (!($stable(fifo_status_hungry_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins HUNGRY_FIFO_Status_Count = {1};
        type_option.comment = "HUNGRY FIFO Status Count";
        }

    C2 : coverpoint (!($stable(fifo_status_satisfied_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins SATISFIED_FIFO_Status_Count = {1};
        type_option.comment = "SATISFIED FIFO Status Count";
        }

    C3 : coverpoint (!($stable(idle_control_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Idle_Controls = {1};
        type_option.comment = "Number of Idle Controls";
        }

    C4 : coverpoint (!($stable(payload_control_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Payload_Controls = {1};
        type_option.comment = "Number of Payload Controls";
        }

    C5 : coverpoint (!($stable(data_training_pattern_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Data_Path_Training_sequences = {1};
        type_option.comment = "Number of Data Path Training sequences";
        }

    C6 : coverpoint (!($stable(fifo_training_pattern_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_FIFO_interface_Training_sequences = {1};
        type_option.comment = "Number of FIFO interface Training sequences";
        }

    C7 : coverpoint (!($stable(packets_w_app_error, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Packets_with_Application_Error = {1};
        type_option.comment = "Number of Packets with Application Error";
        }

    C8 : coverpoint (!($stable(eops_1_byte_valid_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_EOPs_with_One_byte_valid = {1};
        type_option.comment = "Number of EOPs with One byte valid";
        }

    C9 : coverpoint (!($stable(eops_2_bytes_valid_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_EOPs_with_Two_bytes_valid = {1};
        type_option.comment = "Number of EOPs with Two bytes valid";
        }

    C10 : coverpoint (!($stable(no_pause_packet_transfer, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_Unpaused_Packet_transfers = {1};
        type_option.comment = "Number of Unpaused Packet transfers";
        }

    C11 : coverpoint (!($stable(fifo_error_cnt, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins FIFO_Status_Error_Count = {1};
        type_option.comment = "FIFO Status Error Count";
        }

    C12 : coverpoint (!($stable(packets_w_parity_error, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_DIP4_Parity_Errors = {1};
        type_option.comment = "Number of DIP4 Parity Errors";
        }

    C13 : coverpoint (!($stable(status_pattern_w_parity_error, @ (posedge rdclk)))) iff(enable_coverpoint)
        {
        bins Number_of_DIP2_Parity_Errors = {1};
        type_option.comment = "Number of  DIP2 Parity Errors";
        }

  endgroup : spi4_2_cornercases

  spi4_2_statistics  SPI4_2_STATISTICS = new();
  spi4_2_cornercases  SPI4_2_CORNERCASES = new();

  always @(posedge rdclk) begin

   integer k; 

//Normal Stats.

    SPI4_2_STATISTICS.S0.stop();
    SPI4_2_STATISTICS.S1.stop();
    SPI4_2_STATISTICS.S2.stop();
    SPI4_2_STATISTICS.S3.stop();

    SPI4_2_STATISTICS.S1.start();
    
    for (k=0; k<(byte_cnt-$past(byte_cnt)); k++) 
      SPI4_2_STATISTICS.sample();

    SPI4_2_STATISTICS.S1.stop();

    SPI4_2_STATISTICS.S0.start();

    for (k=0; k<(packet_cnt-$past(packet_cnt)); k++) 
      SPI4_2_STATISTICS.sample();

    SPI4_2_STATISTICS.S0.stop();

    SPI4_2_STATISTICS.S2.start();
   
    for (k=0; k<(max_idle_control_count_between_transaction-$past(max_idle_control_count_between_transaction)); k++)
      SPI4_2_STATISTICS.sample();

    SPI4_2_STATISTICS.S2.stop();

    SPI4_2_STATISTICS.S3.start();

    for (k=0; k<(max_packet_size-$past(max_packet_size)); k++)
      SPI4_2_STATISTICS.sample();

    SPI4_2_STATISTICS.S3.stop();

//Corner Cases

    SPI4_2_CORNERCASES.C0.stop();
    SPI4_2_CORNERCASES.C1.stop();
    SPI4_2_CORNERCASES.C2.stop();
    SPI4_2_CORNERCASES.C3.stop();
    SPI4_2_CORNERCASES.C4.stop();
    SPI4_2_CORNERCASES.C5.stop();
    SPI4_2_CORNERCASES.C6.stop();
    SPI4_2_CORNERCASES.C7.stop();
    SPI4_2_CORNERCASES.C8.stop();
    SPI4_2_CORNERCASES.C9.stop();
    SPI4_2_CORNERCASES.C10.stop();
    SPI4_2_CORNERCASES.C11.stop();
    SPI4_2_CORNERCASES.C12.stop();
    SPI4_2_CORNERCASES.C13.stop();

    SPI4_2_CORNERCASES.C0.start();

    for (k=0; k<(fifo_status_starving_cnt-$past(fifo_status_starving_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C0.stop();

    SPI4_2_CORNERCASES.C1.start();

    for (k=0; k<(fifo_status_hungry_cnt-$past(fifo_status_hungry_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C1.stop();

    SPI4_2_CORNERCASES.C2.start();

    for (k=0; k<(fifo_status_satisfied_cnt-$past(fifo_status_satisfied_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C2.stop();

    SPI4_2_CORNERCASES.C3.start();
   
    for (k=0; k<(idle_control_cnt-$past(idle_control_cnt)); k++) 
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C3.stop();

    SPI4_2_CORNERCASES.C4.start();
  
    for (k=0; k<(payload_control_cnt-$past(payload_control_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C4.stop();


    SPI4_2_CORNERCASES.C5.start();
 
    for (k=0; k<(data_training_pattern_cnt-$past(data_training_pattern_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C5.stop();



    SPI4_2_CORNERCASES.C6.start();

    for (k=0; k<(fifo_training_pattern_cnt-$past(fifo_training_pattern_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C6.stop();

    SPI4_2_CORNERCASES.C7.start();

    for (k=0; k<(packets_w_app_error-$past(packets_w_app_error)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C7.stop();

    SPI4_2_CORNERCASES.C8.start();

    for (k=0; k<(eops_1_byte_valid_cnt-$past(eops_1_byte_valid_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C8.stop();

    SPI4_2_CORNERCASES.C9.start();
  
    for (k=0; k<(eops_2_bytes_valid_cnt-$past(eops_2_bytes_valid_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C9.stop();

    SPI4_2_CORNERCASES.C10.start();
 
    for (k=0; k<(no_pause_packet_transfer-$past(no_pause_packet_transfer)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C10.stop();


    SPI4_2_CORNERCASES.C11.start();

    for (k=0; k<(fifo_error_cnt-$past(fifo_error_cnt)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C11.stop();


    SPI4_2_CORNERCASES.C12.start();

    for (k=0; k<(packets_w_parity_error-$past(packets_w_parity_error)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C12.stop();

//Coverpoint 13

    SPI4_2_CORNERCASES.C13.start();

    for (k=0; k<(status_pattern_w_parity_error-$past(status_pattern_w_parity_error)); k++)
      SPI4_2_CORNERCASES.sample();

    SPI4_2_CORNERCASES.C13.stop();

      
  end

  initial
    begin
      spi4_2_statistics::type_option.comment = "Statistics for SPI4_2 Monitor";
      spi4_2_cornercases::type_option.comment = "Cornercases for SPI4_2 Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for SPI4_2 Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for SPI4_2 Monitor -------------------------");

      $display("Number of Packets Transferred                 : %0d", packet_cnt);
      $display("Number of Bytes Transferred                   : %0d", byte_cnt);
      $display("Maximum Idle Controls Between Transactions    : %0d", max_idle_control_count_between_transaction);
      $display("Maximum Packet Size                           : %0d", max_packet_size);

      $display("------------------- Cornercases for SPI4_2 Monitor -------------------------");

      $display("STARVING FIFO Status Count                    : %0d", fifo_status_starving_cnt);
      $display("HUNGRY FIFO Status Count                      : %0d", fifo_status_hungry_cnt);
      $display("SATISFIED FIFO Status Count                   : %0d", fifo_status_satisfied_cnt);
      $display("Number of Idle Controls                       : %0d", idle_control_cnt);
      $display("Number of Payload Controls                    : %0d", payload_control_cnt);
      $display("Number of Data Path Training sequences        : %0d", data_training_pattern_cnt);
      $display("Number of FIFO interface Training sequences   : %0d", fifo_training_pattern_cnt);
      $display("Number of Packets with Application Error      : %0d", packets_w_app_error);
      $display("Number of EOPs with One byte valid            : %0d", eops_1_byte_valid_cnt);
      $display("Number of EOPs with Two bytes valid           : %0d", eops_2_bytes_valid_cnt);
      $display("Number of Unpaused Packet transfers           : %0d", no_pause_packet_transfer);
      $display("FIFO Status Error Count                       : %0d", fifo_error_cnt);
      $display("Number of DIP4 Parity Errors                  : %0d", packets_w_parity_error);
      $display("Number of  DIP2 Parity Errors                 : %0d", status_pattern_w_parity_error);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
