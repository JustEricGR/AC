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

  always@(posedge clk)
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
  covergroup sas_statistics @ (posedge clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for SAS Monitor";

    S0 : coverpoint (!($stable(no_of_transactions, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Transactions = {1};
        type_option.comment = "Transactions";
        }

    S1 : coverpoint (!($stable(no_of_data_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins DATA_frames = {1};
        type_option.comment = "DATA frames";
        }

    S2 : coverpoint (!($stable(no_of_command_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins COMMAND_frames = {1};
        type_option.comment = "COMMAND frames";
        }

    S3 : coverpoint (!($stable(no_of_xferrdy_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins XFERRDY_frames = {1};
        type_option.comment = "XFERRDY frames";
        }

    S4 : coverpoint (!($stable(no_of_response_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins RESPONSE_frames = {1};
        type_option.comment = "RESPONSE frames";
        }

    S5 : coverpoint (!($stable(no_of_task_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins TASK_frames = {1};
        type_option.comment = "TASK frames";
        }

    S6 : coverpoint (!($stable(no_of_open_addr_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins OPEN_address_frames = {1};
        type_option.comment = "OPEN address frames";
        }

    S7 : coverpoint (!($stable(no_of_ident_addr_frames, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins IDENTIFICATION_address_frames = {1};
        type_option.comment = "IDENTIFICATION address frames";
        }

    S8 : coverpoint (!($stable(no_of_non_align0_align_bursts, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins ALIGN_bursts_with_non_ALIGN0_primitive = {1};
        type_option.comment = "ALIGN bursts with non ALIGN0 primitive";
        }

    S9 : coverpoint (!($stable(no_of_times_timeout_occured, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Time_outs = {1};
        type_option.comment = "Time outs";
        }

  endgroup : sas_statistics


  covergroup sas_cornercases @ (posedge clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for SAS Monitor";

    C0 : coverpoint (!($stable(no_of_phy_reset_seq_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins PHY_reset_sequences = {1};
        type_option.comment = "PHY reset sequences";
        }

    C1 : coverpoint (!($stable(no_of_link_reset_seq_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Link_reset_sequences = {1};
        type_option.comment = "Link reset sequences";
        }

    C2 : coverpoint (!($stable(transactions_completed_without_err, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Transactions_completed = {1};
        type_option.comment = "Transactions completed";
        }

    C3 : coverpoint (!($stable(ack_received, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins ACK_received = {1};
        type_option.comment = "ACK received";
        }

    C4 : coverpoint (!($stable(nak_received_with_crc_err, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins NAK_received_with_CRC_error = {1};
        type_option.comment = "NAK received with CRC error";
        }

    C5 : coverpoint (!($stable(connection_req_accepted, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_accepted = {1};
        type_option.comment = "Connection requests accepted";
        }

    C6 : coverpoint (!($stable(connection_req_rej_with_no_des, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_NO_DESTINATION = {1};
        type_option.comment = "Connection requests rejected with NO DESTINATION";
        }

    C7 : coverpoint (!($stable(connection_req_rej_with_bad_des, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_BAD_DESTINATION = {1};
        type_option.comment = "Connection requests rejected with BAD DESTINATION";
        }

    C8 : coverpoint (!($stable(connection_req_rej_with_wr_des, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_WRONG_DESTINATION = {1};
        type_option.comment = "Connection requests rejected with WRONG DESTINATION";
        }

    C9 : coverpoint (!($stable(connection_req_rej_with_lnk_rate_not_supp, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_LINK_RATE_NOT_SUPPORTED = {1};
        type_option.comment = "Connection requests rejected with LINK RATE NOT SUPPORTED";
        }

    C10 : coverpoint (!($stable(connection_req_rej_with_retry, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_RETRY = {1};
        type_option.comment = "Connection requests rejected with RETRY";
        }

    C11 : coverpoint (!($stable(connection_req_rej_with_protocol_not_supp, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_PROTOCOL_NOT_SUPPORTED = {1};
        type_option.comment = "Connection requests rejected with PROTOCOL NOT SUPPORTED";
        }

    C12 : coverpoint (!($stable(connection_req_rej_with_pathway_block, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_PATHWAY_BLOCKED = {1};
        type_option.comment = "Connection requests rejected with PATHWAY BLOCKED";
        }

    C13 : coverpoint (!($stable(connection_req_rej_with_resource_busy, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_rejected_with_RESOURCE_BUSY = {1};
        type_option.comment = "Connection requests rejected with RESOURCE BUSY";
        }

    C14 : coverpoint (!($stable(frames_with_crc_error, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_CRC_error = {1};
        type_option.comment = "Frames with CRC error";
        }

    C15 : coverpoint (!($stable(no_of_ssp_transactions, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins SSP_transactions = {1};
        type_option.comment = "SSP transactions";
        }

    C16 : coverpoint (!($stable(no_of_smp_transactions, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins SMP_transactions = {1};
        type_option.comment = "SMP transactions";
        }

    C17 : coverpoint (!($stable(no_of_stp_transactions, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins STP_transactions = {1};
        type_option.comment = "STP transactions";
        }

    C18 : coverpoint (!($stable(no_of_times_ack_nak_timeout_occured, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins ACK_NAK_timeouts = {1};
        type_option.comment = "ACK/NAK timeouts";
        }

    C19 : coverpoint (!($stable(no_of_times_credit_timeout_occured, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Credit_timeouts = {1};
        type_option.comment = "Credit timeouts";
        }

    C20 : coverpoint (!($stable(connection_req_wait_on_partial, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_waiting_on_partial = {1};
        type_option.comment = "Connection requests waiting on partial";
        }

    C21 : coverpoint (!($stable(connection_req_wait_on_device, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_waiting_on_device = {1};
        type_option.comment = "Connection requests waiting on device";
        }

    C22 : coverpoint (!($stable(connection_req_wait_on_connection, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Connection_requests_waiting_on_connection = {1};
        type_option.comment = "Connection requests waiting on connection";
        }

    C23 : coverpoint (!($stable(disparity_err_occured, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Disparity_errors = {1};
        type_option.comment = "Disparity errors";
        }

  endgroup : sas_cornercases

  sas_statistics  SAS_STATISTICS = new();
  sas_cornercases  SAS_CORNERCASES = new();

  initial
    begin
      sas_statistics::type_option.comment = "Statistics for SAS Monitor";
      sas_cornercases::type_option.comment = "Cornercases for SAS Monitor";
    end
  `endif // QVL_SV_COVERGROUP

  `ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for SAS Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for SAS Monitor -------------------------");

      $display("Transactions                                  : %0d", no_of_transactions);
      $display("DATA frames                                   : %0d", no_of_data_frames);
      $display("COMMAND frames                                : %0d", no_of_command_frames);
      $display("XFERRDY frames                                : %0d", no_of_xferrdy_frames);
      $display("RESPONSE frames                               : %0d", no_of_response_frames);
      $display("TASK frames                                   : %0d", no_of_task_frames);
      $display("OPEN address frames                           : %0d", no_of_open_addr_frames);
      $display("IDENTIFICATION address frames                 : %0d", no_of_ident_addr_frames);
      $display("ALIGN bursts with non ALIGN0 primitive        : %0d", no_of_non_align0_align_bursts);
      $display("Time outs                                     : %0d", no_of_times_timeout_occured);

      $display("------------------- Cornercases for SAS Monitor -------------------------");

      $display("PHY reset sequences                           : %0d", no_of_phy_reset_seq_count);
      $display("Link reset sequences                          : %0d", no_of_link_reset_seq_count);
      $display("Transactions completed                        : %0d", transactions_completed_without_err);
      $display("ACK received                                  : %0d", ack_received);
      $display("NAK received with CRC error                   : %0d", nak_received_with_crc_err);
      $display("Connection requests accepted                  : %0d", connection_req_accepted);
      $display("Connection requests rejected with NO DESTINATION           : %0d", connection_req_rej_with_no_des);
      $display("Connection requests rejected with BAD DESTINATION          : %0d", connection_req_rej_with_bad_des);
      $display("Connection requests rejected with WRONG DESTINATION        : %0d", connection_req_rej_with_wr_des);
      $display("Connection requests rejected with LINK RATE NOT SUPPORTED  : %0d", connection_req_rej_with_lnk_rate_not_supp);
      $display("Connection requests rejected with RETRY                    : %0d", connection_req_rej_with_retry);
      $display("Connection requests rejected with PROTOCOL NOT SUPPORTED   : %0d", connection_req_rej_with_protocol_not_supp);
      $display("Connection requests rejected with PATHWAY BLOCKED          : %0d", connection_req_rej_with_pathway_block);
      $display("Connection requests rejected with RESOURCE BUSY            : %0d", connection_req_rej_with_resource_busy);
      $display("Frames with CRC error                         : %0d", frames_with_crc_error);
      $display("SSP transactions                              : %0d", no_of_ssp_transactions);
      $display("SMP transactions                              : %0d", no_of_smp_transactions);
      $display("STP transactions                              : %0d", no_of_stp_transactions);
      $display("ACK/NAK timeouts                              : %0d", no_of_times_ack_nak_timeout_occured);
      $display("Credit timeouts                               : %0d", no_of_times_credit_timeout_occured);
      $display("Connection requests waiting on partial        : %0d", connection_req_wait_on_partial);
      $display("Connection requests waiting on device         : %0d", connection_req_wait_on_device);
      $display("Connection requests waiting on connection     : %0d", connection_req_wait_on_connection);
      $display("Disparity errors                              : %0d", disparity_err_occured);
      $display("----------------------------------------------------------------------------------");
    end
  `endif // QVL_MW_FINAL_COVER
`endif // QVL_SV_COVERGROUP
