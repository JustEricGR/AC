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

  //----------------------------------------------------------------------------
  //SV Covergroups start here
  //----------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
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

  covergroup usb_2_0_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for USB 2.0 Monitor";

    S00 : coverpoint (!($stable(transaction_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Transaction_count = {1};
        type_option.comment = "Transaction count";
        }

    S01 : coverpoint (!($stable(packets_received_with_error, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Packets_with_error = {1};
        type_option.comment = "Packets with error";
        }

    S02 : coverpoint (!($stable(packets_received_without_error, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Packets_without_error = {1};
        type_option.comment = "Packets without error";
        }

    S03 : coverpoint (!($stable(no_response_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins No_response_count = {1};
        type_option.comment = "No response count";
        }

    S04 : coverpoint (!($stable(incomplete_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_transactions = {1};
        type_option.comment = "Incomplete transactions";
        }

  endgroup : usb_2_0_statistics


  covergroup usb_2_0_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for USB 2.0 Monitor";

    C00 : coverpoint (!($stable(sof_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins SOF_packets = {1};
        type_option.comment = "SOF packets";
        }

    C01 : coverpoint (!($stable(token_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Token_packets = {1};
        type_option.comment = "Token packets";
        }

    C02 : coverpoint (!($stable(data_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Data_packets = {1};
        type_option.comment = "Data packets";
        }

    C03 : coverpoint (!($stable(naks_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins NAK_packets = {1};
        type_option.comment = "NAK packets";
        }

    C04 : coverpoint (!($stable(stalls_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins STALL_packets = {1};
        type_option.comment = "STALL packets";
        }

    C05 : coverpoint (!($stable(acks_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins ACK_packets = {1};
        type_option.comment = "ACK packets";
        }

    C06 : coverpoint (!($stable(pings_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins PING_packets = {1};
        type_option.comment = "PING packets";
        }

    C07 : coverpoint (!($stable(ssplits_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins SSPLIT_packets = {1};
        type_option.comment = "SSPLIT packets";
        }

    C08 : coverpoint (!($stable(csplits_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins CSPLIT_packets = {1};
        type_option.comment = "CSPLIT packets";
        }

    C09 : coverpoint (!($stable(nyets_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins NYET_packets = {1};
        type_option.comment = "NYET packets";
        }

    C10 : coverpoint (!($stable(errs_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins ERR_packets = {1};
        type_option.comment = "ERR packets";
        }

    C11 : coverpoint (!($stable(in_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins IN_transactions = {1};
        type_option.comment = "IN transactions";
        }

    C12 : coverpoint (!($stable(out_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins OUT_transactions = {1};
        type_option.comment = "OUT transactions";
        }

    C13 : coverpoint (!($stable(pre_pids_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Pre_PIDs_issued = {1};
        type_option.comment = "Pre PIDs issued";
        }

    C14 : coverpoint (!($stable(setup_tokens, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Setup_tokens = {1};
        type_option.comment = "Setup tokens";
        }

    C15 : coverpoint (!($stable(resets_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Resets_issued = {1};
        type_option.comment = "Resets issued";
        }

    C16 : coverpoint (!($stable(aborted_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Transactions_aborted = {1};
        type_option.comment = "Transactions aborted";
        }

    C17 : coverpoint (!($stable(incomplete_in_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_IN_transactions = {1};
        type_option.comment = "Incomplete IN transactions";
        }

    C18 : coverpoint (!($stable(incomplete_out_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_OUT_transactions = {1};
        type_option.comment = "Incomplete OUT transactions";
        }

    C19 : coverpoint (!($stable(time_outs, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Time_outs = {1};
        type_option.comment = "Time outs";
        }

    C20 : coverpoint (!($stable(control_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Control_transfers = {1};
        type_option.comment = "Control transfers";
        }

    C21 : coverpoint (!($stable(bulk_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Bulk_transfers = {1};
        type_option.comment = "Bulk transfers";
        }

    C22 : coverpoint (!($stable(interrupt_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Interrupt_transfers = {1};
        type_option.comment = "Interrupt transfers";
        }

    C23 : coverpoint (!($stable(isochronous_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Isochronous_transfers = {1};
        type_option.comment = "Isochronous transfers";
        }

    C24 : coverpoint (!($stable(set_address_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Address_requests = {1};
        type_option.comment = "Set Address requests";
        }

    C25 : coverpoint (!($stable(set_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Feature_requests = {1};
        type_option.comment = "Set Feature requests";
        }

    C26 : coverpoint (!($stable(clear_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Feature_requests = {1};
        type_option.comment = "Clear Feature requests";
        }

    C27 : coverpoint (!($stable(get_configuration_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Configuration_requests = {1};
        type_option.comment = "Get Configuration requests";
        }

    C28 : coverpoint (!($stable(get_interface_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Interface_requests = {1};
        type_option.comment = "Get Interface requests";
        }

    C29 : coverpoint (!($stable(get_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Status_requests = {1};
        type_option.comment = "Get Status requests";
        }

    C30 : coverpoint (!($stable(synch_frame_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Synch_Frame_requests = {1};
        type_option.comment = "Synch Frame requests";
        }

    C31 : coverpoint (!($stable(get_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Descriptor_requests = {1};
        type_option.comment = "Get Descriptor requests";
        }

    C32 : coverpoint (!($stable(set_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Descriptor_requests = {1};
        type_option.comment = "Set Descriptor requests";
        }

    C33 : coverpoint (!($stable(set_configuration_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Configuration_requests = {1};
        type_option.comment = "Set Configuration requests";
        }

    C34 : coverpoint (!($stable(set_interface_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Interface_requests = {1};
        type_option.comment = "Set Interface requests";
        }

    C35 : coverpoint (!($stable(clear_hub_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Hub_Feature_requests = {1};
        type_option.comment = "Clear Hub Feature requests";
        }

    C36 : coverpoint (!($stable(clear_port_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Port_Feature_requests = {1};
        type_option.comment = "Clear Port Feature requests";
        }

    C37 : coverpoint (!($stable(get_hub_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Hub_Descriptor_requests = {1};
        type_option.comment = "Get Hub Descriptor requests";
        }

    C38 : coverpoint (!($stable(get_hub_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Hub_Status_requests = {1};
        type_option.comment = "Get Hub Status requests";
        }

    C39 : coverpoint (!($stable(get_port_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Port_Status_requests = {1};
        type_option.comment = "Get Port Status requests";
        }

    C40 : coverpoint (!($stable(set_hub_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Hub_Descriptor_requests = {1};
        type_option.comment = "Set Hub Descriptor requests";
        }

    C41 : coverpoint (!($stable(set_hub_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Hub_Feature_requests = {1};
        type_option.comment = "Set Hub Feature requests";
        }

    C42 : coverpoint (!($stable(set_port_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Port_Feature_requests = {1};
        type_option.comment = "Set Port Feature requests";
        }

    C43 : coverpoint (!($stable(clear_tt_buffer_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_TT_Buffer_requests = {1};
        type_option.comment = "Clear TT Buffer requests";
        }

    C44 : coverpoint (!($stable(reset_tt_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Reset_TT_requests = {1};
        type_option.comment = "Reset TT requests";
        }

    C45 : coverpoint (!($stable(get_tt_state_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_TT_State_requests = {1};
        type_option.comment = "Get TT State requests";
        }

    C46 : coverpoint (!($stable(stop_tt_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Stop_TT_requests = {1};
        type_option.comment = "Stop TT requests";
        }

  endgroup : usb_2_0_cornercases

  usb_2_0_statistics  USB_2_0_STATISTICS = new();
  usb_2_0_cornercases  USB_2_0_CORNERCASES = new();

  initial
    begin
      usb_2_0_statistics::type_option.comment = "Statistics for USB 2.0 Monitor";
      usb_2_0_cornercases::type_option.comment = "Cornercases for USB 2.0 Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for USB 2.0 Monitor -------------------------");

      $display("Monitor instance                              : %m");

      $display("------------------- Statistics for USB 2.0 Monitor -------------------------");

      $display("Transaction count                             : %0d", transaction_count);
      $display("Packets with error                            : %0d", packets_received_with_error);
      $display("Packets without error                         : %0d", packets_received_without_error);
      $display("No response count                             : %0d", no_response_count);
      $display("Incomplete transactions                       : %0d", incomplete_transactions);

      $display("------------------- Cornercases for USB 2.0 Monitor -------------------------");

      $display("SOF packets                                   : %0d", sof_packets);
      $display("Token packets                                 : %0d", token_packets);
      $display("Data packets                                  : %0d", data_packets);
      $display("NAK packets                                   : %0d", naks_issued);
      $display("STALL packets                                 : %0d", stalls_issued);
      $display("ACK packets                                   : %0d", acks_issued);
      $display("PING packets                                  : %0d", pings_issued);
      $display("SSPLIT packets                                : %0d", ssplits_issued);
      $display("CSPLIT packets                                : %0d", csplits_issued);
      $display("NYET packets                                  : %0d", nyets_issued);
      $display("ERR packets                                   : %0d", errs_issued);
      $display("IN transactions                               : %0d", in_transfers);
      $display("OUT transactions                              : %0d", out_transfers);
      $display("Pre PIDs issued                               : %0d", pre_pids_issued);
      $display("Setup tokens                                  : %0d", setup_tokens);
      $display("Resets issued                                 : %0d", resets_issued);
      $display("Transactions aborted                          : %0d", aborted_transactions);
      $display("Incomplete IN transactions                    : %0d", incomplete_in_transactions);
      $display("Incomplete OUT transactions                   : %0d", incomplete_out_transactions);
      $display("Time outs                                     : %0d", time_outs);
      $display("Control transfers                             : %0d", control_transfers);
      $display("Bulk transfers                                : %0d", bulk_transfers);
      $display("Interrupt transfers                           : %0d", interrupt_transfers);
      $display("Isochronous transfers                         : %0d", isochronous_transfers);
      $display("Set Address requests                          : %0d", set_address_requests);
      $display("Set Feature requests                          : %0d", set_feature_requests);
      $display("Clear Feature requests                        : %0d", clear_feature_requests);
      $display("Get Configuration requests                    : %0d", get_configuration_requests);
      $display("Get Interface requests                        : %0d", get_interface_requests);
      $display("Get Status requests                           : %0d", get_status_requests);
      $display("Synch Frame requests                          : %0d", synch_frame_requests);
      $display("Get Descriptor requests                       : %0d", get_descriptor_requests);
      $display("Set Descriptor requests                       : %0d", set_descriptor_requests);
      $display("Set Configuration requests                    : %0d", set_configuration_requests);
      $display("Set Interface requests                        : %0d", set_interface_requests);
      $display("Clear Hub Feature requests                    : %0d", clear_hub_feature_requests);
      $display("Clear Port Feature requests                   : %0d", clear_port_feature_requests);
      $display("Get Hub Descriptor requests                   : %0d", get_hub_descriptor_requests);
      $display("Get Hub Status requests                       : %0d", get_hub_status_requests);
      $display("Get Port Status requests                      : %0d", get_port_status_requests);
      $display("Set Hub Descriptor requests                   : %0d", set_hub_descriptor_requests);
      $display("Set Hub Feature requests                      : %0d", set_hub_feature_requests);
      $display("Set Port Feature requests                     : %0d", set_port_feature_requests);
      $display("Clear TT Buffer requests                      : %0d", clear_tt_buffer_requests);
      $display("Reset TT requests                             : %0d", reset_tt_requests);
      $display("Get TT State requests                         : %0d", get_tt_state_requests);
      $display("Stop TT requests                              : %0d", stop_tt_requests);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
