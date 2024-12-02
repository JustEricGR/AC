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

  covergroup usb_1_1_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for USB 1.1 Monitor";

    S0 : coverpoint (!($stable(transaction_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Transaction_Count = {1};
        type_option.comment = "Transaction Count";
        }

    S1 : coverpoint (!($stable(packets_received_with_error, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Packets_With_Error = {1};
        type_option.comment = "Packets With Error";
        }

    S2 : coverpoint (!($stable(packets_received_without_error, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Packets_Without_Error = {1};
        type_option.comment = "Packets Without Error";
        }

    S3 : coverpoint (!($stable(no_response_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins No_Response_Count = {1};
        type_option.comment = "No Response Count";
        }

    S4 : coverpoint (!($stable(incomplete_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_Transactions = {1};
        type_option.comment = "Incomplete Transactions";
        }

  endgroup : usb_1_1_statistics


  covergroup usb_1_1_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for USB 1.1 Monitor";

    C0 : coverpoint (!($stable(sof_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins SOF_Packets = {1};
        type_option.comment = "SOF Packets";
        }

    C1 : coverpoint (!($stable(token_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Token_Packets = {1};
        type_option.comment = "Token Packets";
        }

    C2 : coverpoint (!($stable(data_packets, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Data_Packets = {1};
        type_option.comment = "Data Packets";
        }

    C3 : coverpoint (!($stable(naks_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins NAK_Packets = {1};
        type_option.comment = "NAK Packets";
        }

    C4 : coverpoint (!($stable(stalls_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins STALL_Packets = {1};
        type_option.comment = "STALL Packets";
        }

    C5 : coverpoint (!($stable(acks_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins ACK_Packets = {1};
        type_option.comment = "ACK Packets";
        }

    C6 : coverpoint (!($stable(in_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins In_Transactions = {1};
        type_option.comment = "In Transactions";
        }

    C7 : coverpoint (!($stable(out_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Out_Transactions = {1};
        type_option.comment = "Out Transactions";
        }

    C8 : coverpoint (!($stable(pre_pids_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Pre_PIDs_Issued = {1};
        type_option.comment = "Pre PIDs Issued";
        }

    C9 : coverpoint (!($stable(setup_tokens, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Setup_Tokens = {1};
        type_option.comment = "Setup Tokens";
        }

    C10 : coverpoint (!($stable(resets_issued, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Resets_Issued = {1};
        type_option.comment = "Resets Issued";
        }

    C11 : coverpoint (!($stable(aborted_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Transactions_Aborted = {1};
        type_option.comment = "Transactions Aborted";
        }

    C12 : coverpoint (!($stable(incomplete_in_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_IN_Transactions = {1};
        type_option.comment = "Incomplete IN Transactions";
        }

    C13 : coverpoint (!($stable(incomplete_out_transactions, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Incomplete_OUT_Transactions = {1};
        type_option.comment = "Incomplete OUT Transactions";
        }

    C14 : coverpoint (!($stable(time_outs, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Time_Outs = {1};
        type_option.comment = "Time Outs";
        }

    C15 : coverpoint (!($stable(control_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Control_Transfers = {1};
        type_option.comment = "Control Transfers";
        }

    C16 : coverpoint (!($stable(bulk_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Bulk_Transfers = {1};
        type_option.comment = "Bulk Transfers";
        }

    C17 : coverpoint (!($stable(interrupt_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Interrupt_Transfers = {1};
        type_option.comment = "Interrupt Transfers";
        }

    C18 : coverpoint (!($stable(isochronous_transfers, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Isochronous_Transfers = {1};
        type_option.comment = "Isochronous Transfers";
        }

    C19 : coverpoint (!($stable(set_address_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Address_Requests = {1};
        type_option.comment = "Set Address Requests";
        }

    C20 : coverpoint (!($stable(set_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Feature_Requests = {1};
        type_option.comment = "Set Feature Requests";
        }

    C21 : coverpoint (!($stable(clear_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Feature_Requests = {1};
        type_option.comment = "Clear Feature Requests";
        }

    C22 : coverpoint (!($stable(get_configuration_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Configuration_Requests = {1};
        type_option.comment = "Get Configuration Requests";
        }

    C23 : coverpoint (!($stable(get_interface_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Interface_Requests = {1};
        type_option.comment = "Get Interface Requests";
        }

    C24 : coverpoint (!($stable(get_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Status_Requests = {1};
        type_option.comment = "Get Status Requests";
        }

    C25 : coverpoint (!($stable(synch_frame_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Synch_Frame_Requests = {1};
        type_option.comment = "Synch Frame Requests";
        }

    C26 : coverpoint (!($stable(get_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Descriptor_Requests = {1};
        type_option.comment = "Get Descriptor Requests";
        }

    C27 : coverpoint (!($stable(set_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Descriptor_Requests = {1};
        type_option.comment = "Set Descriptor Requests";
        }

    C28 : coverpoint (!($stable(set_configuration_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Configuration_Requests = {1};
        type_option.comment = "Set Configuration Requests";
        }

    C29 : coverpoint (!($stable(set_interface_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Interface_Requests = {1};
        type_option.comment = "Set Interface Requests";
        }

    C30 : coverpoint (!($stable(clear_hub_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Hub_Feature_Requests = {1};
        type_option.comment = "Clear Hub Feature Requests";
        }

    C31 : coverpoint (!($stable(clear_port_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Clear_Port_Feature_Requests = {1};
        type_option.comment = "Clear Port Feature Requests";
        }

    C32 : coverpoint (!($stable(get_bus_state_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Bus_State_Requests = {1};
        type_option.comment = "Get Bus State Requests";
        }

    C33 : coverpoint (!($stable(get_hub_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Hub_Descriptor_Requests = {1};
        type_option.comment = "Get Hub Descriptor Requests";
        }

    C34 : coverpoint (!($stable(get_hub_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Hub_Status_Requests = {1};
        type_option.comment = "Get Hub Status Requests";
        }

    C35 : coverpoint (!($stable(get_port_status_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Get_Port_Status_Requests = {1};
        type_option.comment = "Get Port Status Requests";
        }

    C36 : coverpoint (!($stable(set_hub_descriptor_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Hub_Descriptor_Requests = {1};
        type_option.comment = "Set Hub Descriptor Requests";
        }

    C37 : coverpoint (!($stable(set_hub_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Hub_Feature_Requests = {1};
        type_option.comment = "Set Hub Feature Requests";
        }

    C38 : coverpoint (!($stable(set_port_feature_requests, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Set_Port_Feature_Requests = {1};
        type_option.comment = "Set Port Feature Requests";
        }

  endgroup : usb_1_1_cornercases

  usb_1_1_statistics  USB_1_1_STATISTICS = new();
  usb_1_1_cornercases  USB_1_1_CORNERCASES = new();

  initial
    begin
      usb_1_1_statistics::type_option.comment = "Statistics for USB 1.1 Monitor";
      usb_1_1_cornercases::type_option.comment = "Cornercases for USB 1.1 Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for USB 1.1 Monitor -------------------------");

      $display("Monitor instance                              : %m");

      $display("------------------- Statistics for USB 1.1 Monitor -------------------------");

      $display("Transaction Count                             : %0d", transaction_count);
      $display("Packets With Error                            : %0d", packets_received_with_error);
      $display("Packets Without Error                         : %0d", packets_received_without_error);
      $display("No Response Count                             : %0d", no_response_count);
      $display("Incomplete Transactions                       : %0d", incomplete_transactions);

      $display("------------------- Cornercases for USB 1.1 Monitor -------------------------");

      $display("SOF Packets                                   : %0d", sof_packets);
      $display("Token Packets                                 : %0d", token_packets);
      $display("Data Packets                                  : %0d", data_packets);
      $display("NAK Packets                                   : %0d", naks_issued);
      $display("STALL Packets                                 : %0d", stalls_issued);
      $display("ACK Packets                                   : %0d", acks_issued);
      $display("In Transactions                               : %0d", in_transactions);
      $display("Out Transactions                              : %0d", out_transactions);
      $display("Pre PIDs Issued                               : %0d", pre_pids_issued);
      $display("Setup Tokens                                  : %0d", setup_tokens);
      $display("Resets Issued                                 : %0d", resets_issued);
      $display("Transactions Aborted                          : %0d", aborted_transactions);
      $display("Incomplete IN Transactions                    : %0d", incomplete_in_transactions);
      $display("Incomplete OUT Transactions                   : %0d", incomplete_out_transactions);
      $display("Time Outs                                     : %0d", time_outs);
      $display("Control Transfers                             : %0d", control_transfers);
      $display("Bulk Transfers                                : %0d", bulk_transfers);
      $display("Interrupt Transfers                           : %0d", interrupt_transfers);
      $display("Isochronous Transfers                         : %0d", isochronous_transfers);
      $display("Set Address Requests                          : %0d", set_address_requests);
      $display("Set Feature Requests                          : %0d", set_feature_requests);
      $display("Clear Feature Requests                        : %0d", clear_feature_requests);
      $display("Get Configuration Requests                    : %0d", get_configuration_requests);
      $display("Get Interface Requests                        : %0d", get_interface_requests);
      $display("Get Status Requests                           : %0d", get_status_requests);
      $display("Synch Frame Requests                          : %0d", synch_frame_requests);
      $display("Get Descriptor Requests                       : %0d", get_descriptor_requests);
      $display("Set Descriptor Requests                       : %0d", set_descriptor_requests);
      $display("Set Configuration Requests                    : %0d", set_configuration_requests);
      $display("Set Interface Requests                        : %0d", set_interface_requests);
      $display("Clear Hub Feature Requests                    : %0d", clear_hub_feature_requests);
      $display("Clear Port Feature Requests                   : %0d", clear_port_feature_requests);
      $display("Get Bus State Requests                        : %0d", get_bus_state_requests);
      $display("Get Hub Descriptor Requests                   : %0d", get_hub_descriptor_requests);
      $display("Get Hub Status Requests                       : %0d", get_hub_status_requests);
      $display("Get Port Status Requests                      : %0d", get_port_status_requests);
      $display("Set Hub Descriptor Requests                   : %0d", set_hub_descriptor_requests);
      $display("Set Hub Feature Requests                      : %0d", set_hub_feature_requests);
      $display("Set Port Feature Requests                     : %0d", set_port_feature_requests);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
