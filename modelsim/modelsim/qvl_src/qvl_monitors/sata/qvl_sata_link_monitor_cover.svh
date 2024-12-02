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
  //reg cover_reset;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
      //cover_reset = 1'b0;
    end

  always@(tx_clk)
    begin
      prevent_x_to_valid_transition_count = 1'b1;
      //cover_reset <= `ZiCwDebugDelay1 (areset | reset);
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 //cover_reset == 1'b0 &&
                                 reset == 1'b0 &&
                                 areset == 1'b0 &&
                                 prevent_x_to_valid_transition_count == 1'b1);
`ifdef QVL_SV_COVERGROUP
  covergroup sata_statistics @ (tx_clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for SATA Monitor";

    S0 : coverpoint (!($stable(total_no_of_comreset_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_COMRESET_detected = {1};
        type_option.comment = "Total number of times COMRESET detected.";
        }

    S1 : coverpoint (!($stable(total_regfis_with_good_sts_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_good_statuses_sent_through_REG_FIS = {1};
        type_option.comment = "Total number of good statuses sent through REG FIS.";
        }

    S2 : coverpoint (!($stable(total_regfis_with_bad_sts_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_bad_statuses_sent_through_REG_FIS = {1};
        type_option.comment = "Total number of bad statuses sent through REG FIS.";
        }

  endgroup : sata_statistics


  covergroup sata_cornercases @ (tx_clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for SATA Monitor";

    C0 : coverpoint (!($stable(total_no_of_cominit_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_COMINIT_detected = {1};
        type_option.comment = "Total number of times COMINIT detected.";
        }

    C1 : coverpoint (!($stable(total_no_of_unsolicit_cominit_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_unsolicited_COMINITs_detected = {1};
        type_option.comment = "Total number of unsolicited COMINITs detected.";
        }

    C2 : coverpoint (!($stable(total_aborted_transfers_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_aborted_transactions = {1};
        type_option.comment = "Total number of aborted transactions.";
        }

    C3 : coverpoint (!($stable(no_of_times_srst_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_SRST_bit_was_set_to_1 = {1};
        type_option.comment = "Total number of times SRST bit was set to '1'..";
        }

    C4 : coverpoint (!($stable(total_reg_d2h_fis_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_REG_device_to_host_FIS = {1};
        type_option.comment = "Total number of REG device to host FIS.";
        }

    C5 : coverpoint (!($stable(total_reg_h2d_fis_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_REG_host_to_device_FIS = {1};
        type_option.comment = "Total number of REG host to device FIS.";
        }

    C6 : coverpoint (!($stable(total_pio_setup_fis_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PIO_setup_FIS = {1};
        type_option.comment = "Total number of PIO setup FIS.";
        }

    C7 : coverpoint (!($stable(total_dma_act_fis_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DMA_Activate_FIS = {1};
        type_option.comment = "Total number of DMA Activate FIS.";
        }

    C8 : coverpoint (!($stable(total_set_dev_bit_fis_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_Set_device_bits_FIS = {1};
        type_option.comment = "Total number of Set device bits FIS.";
        }

    C9 : coverpoint (!($stable(total_dev_rst_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DEVICE_RESET_command = {1};
        type_option.comment = "Total number of DEVICE RESET command.";
        }

    C10 : coverpoint (!($stable(total_set_feat_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_SET_FEATURE_command = {1};
        type_option.comment = "Total number of SET FEATURE command.";
        }

    C11 : coverpoint (!($stable(total_identify_dev_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_IDENTIFY_DEVICE_command = {1};
        type_option.comment = "Total number of IDENTIFY DEVICE command.";
        }

    C12 : coverpoint (!($stable(total_rd_log_ext_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_READ_LOG_EXT_command = {1};
        type_option.comment = "Total number of READ LOG EXT command.";
        }

    C13 : coverpoint (!($stable(total_non_data_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_NON_DATA_command = {1};
        type_option.comment = "Total number of NON DATA command.";
        }

    C14 : coverpoint (!($stable(total_pio_in_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PIO_data_in_command = {1};
        type_option.comment = "Total number of PIO data-in command.";
        }

    C15 : coverpoint (!($stable(total_pio_out_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PIO_data_out_command = {1};
        type_option.comment = "Total number of PIO data-out command.";
        }

    C16 : coverpoint (!($stable(total_dma_in_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DMA_data_in_command = {1};
        type_option.comment = "Total number of DMA data-in command.";
        }

    C17 : coverpoint (!($stable(total_dma_out_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DMA_data_out_command = {1};
        type_option.comment = "Total number of DMA data-out command.";
        }

    C18 : coverpoint (!($stable(total_packet_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PACKET_command = {1};
        type_option.comment = "Total number of PACKET command.";
        }

    C19 : coverpoint (!($stable(total_rd_queued_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_READ_DMA_QUEUED_command = {1};
        type_option.comment = "Total number of READ DMA QUEUED command.";
        }

    C20 : coverpoint (!($stable(total_wr_queued_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_WRITE_DMA_QUEUED_command = {1};
        type_option.comment = "Total number of WRITE DMA QUEUED command.";
        }

    C21 : coverpoint (!($stable(total_rd_fpdma_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_READ_FPDMA_command = {1};
        type_option.comment = "Total number of READ FPDMA command.";
        }

    C22 : coverpoint (!($stable(total_wr_fpdma_cmd_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_WRITE_FPDMA_command = {1};
        type_option.comment = "Total number of WRITE FPDMA command.";
        }

    C23 : coverpoint (!($stable(total_regfis_with_err_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_REG_device_to_host_FIS_with_ERR_bit_set = {1};
        type_option.comment = "Total number of REG device to host FIS with ERR bit set.";
        }

    C24 : coverpoint (!($stable(total_sdbfis_with_err_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_Set_device_bits_FIS_with_ERR_bit_set = {1};
        type_option.comment = "Total number of Set device bits FIS with ERR bit set.";
        }

    C25 : coverpoint (!($stable(total_piofis_with_err_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PIO_setup_FIS_with_ERR_bit_set = {1};
        type_option.comment = "Total number of PIO setup FIS with ERR bit set.";
        }

    C26 : coverpoint (!($stable(total_dmasu_with_auto_act_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_fo_DMA_setup_FIS_with_autoactivate_bit_set = {1};
        type_option.comment = "Total number fo DMA setup FIS with autoactivate bit set.";
        }

    C27 : coverpoint (!($stable(total_regfis_with_notif_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_Asynchronous_notifiction_requested_by_device_and_serviced_with_REG_FIS = {1};
        type_option.comment = "Total number of times Asynchronous notifiction requested by device and serviced with REG FIS.";
        }

    C28 : coverpoint (!($stable(total_sdbfis_with_serv_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_Set_device_bits_FISes_with_SERV_bit_set = {1};
        type_option.comment = "Total number of Set device bits FISes with SERV bit set.";
        }

    C29 : coverpoint (!($stable(total_regfis_with_rel_set_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_REG_device_to_host_FISes_with_REL_bit_set = {1};
        type_option.comment = "Total number of REG device to host FISes with REL bit set.";
        }

    C30 : coverpoint (!($stable(successful_pio_in_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_successful_PIO_data_in_transfers = {1};
        type_option.comment = "Total number of successful PIO data-in transfers.";
        }

    C31 : coverpoint (!($stable(successful_pio_out_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_PIO_data_out_transfers = {1};
        type_option.comment = "Successful PIO data-out transfers.";
        }

    C32 : coverpoint (!($stable(successful_dma_in_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_DMA_data_in_transfers = {1};
        type_option.comment = "Successful DMA data-in transfers";
        }

    C33 : coverpoint (!($stable(successful_dma_out_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_DMA_data_out_transfers = {1};
        type_option.comment = "Successful DMA data-out transfers.";
        }

    C34 : coverpoint (!($stable(successful_rd_qdma_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_READ_DMA_queued_transfers = {1};
        type_option.comment = "Successful READ DMA queued transfers.";
        }

    C35 : coverpoint (!($stable(successful_wr_qdma_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_WRITE_DMA_queued_transfers = {1};
        type_option.comment = "Successful WRITE DMA queued transfers.";
        }

    C36 : coverpoint (!($stable(successful_rd_fpdma_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_READ_FPDMA_transfers = {1};
        type_option.comment = "Successful READ FPDMA transfers.";
        }

    C37 : coverpoint (!($stable(successful_wr_fpdma_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Successful_WRITE_FPDMA_transfers = {1};
        type_option.comment = "Successful WRITE FPDMA transfers.";
        }

    C38 : coverpoint (!($stable(un_successful_pio_in_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_PIO_data_in_transfers = {1};
        type_option.comment = "Unsuccessful PIO data-in transfers.";
        }

    C39 : coverpoint (!($stable(un_successful_pio_out_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_PIO_data_out_transfers = {1};
        type_option.comment = "Unsuccessful PIO data-out transfers.";
        }

    C40 : coverpoint (!($stable(un_successful_dma_in_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_DMA_data_in_transfers = {1};
        type_option.comment = "Unsuccessful DMA data-in transfers.";
        }

    C41 : coverpoint (!($stable(un_successful_dma_out_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_DMA_data_out_transfers = {1};
        type_option.comment = "Unsuccessful DMA data-out transfers.";
        }

    C42 : coverpoint (!($stable(un_successful_rd_qdma_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_READ_DMA_queued_transfers = {1};
        type_option.comment = "Unsuccessful READ DMA queued transfers.";
        }

    C43 : coverpoint (!($stable(un_successful_wr_qdma_tx_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_WRITE_DMA_queued_transfers = {1};
        type_option.comment = "Unsuccessful WRITE DMA queued transfers.";
        }

    C44 : coverpoint (!($stable(un_successful_rd_fpdma_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_READ_FPDMA_transfers = {1};
        type_option.comment = "Unsuccessful READ FPDMA transfers.";
        }

    C45 : coverpoint (!($stable(un_successful_wr_fpdma_count, @ (tx_clk)))) iff(enable_coverpoint)
        {
        bins Unsuccessful_WRITE_FPDMA_transfers = {1};
        type_option.comment = "Unsuccessful WRITE FPDMA transfers.";
        }

  endgroup : sata_cornercases

  sata_statistics  SATA_STATISTICS = new();
  sata_cornercases  SATA_CORNERCASES = new();

  initial
    begin
      sata_statistics::type_option.comment = "Statistics for SATA Monitor";
      sata_cornercases::type_option.comment = "Cornercases for SATA Monitor";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for SATA Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for SATA Monitor -------------------------");

      $display("Total number of times COMRESET detected.             : %0d", total_no_of_comreset_count);
      $display("Total number of good statuses sent through REG FIS.  : %0d", total_regfis_with_good_sts_count);
      $display("Total number of bad statuses sent through REG        : %0d", total_regfis_with_bad_sts_count);

      $display("------------------- Cornercases for SATA Monitor -------------------------");

      $display("Total number of times COMINIT detected.        : %0d", total_no_of_cominit_count);
      $display("Total number of unsolicited COMINITs detected  : %0d", total_no_of_unsolicit_cominit_count);
      $display("Total number of aborted transactions.          : %0d", total_aborted_transfers_count);
      $display("Total number of times SRST bit was set to '1'  : %0d", no_of_times_srst_set_count);
      $display("Total number of REG device to host FIS.        : %0d", total_reg_d2h_fis_count);
      $display("Total number of REG host to device FIS.        : %0d", total_reg_h2d_fis_count);
      $display("Total number of PIO setup FIS.                 : %0d", total_pio_setup_fis_count);
      $display("Total number of DMA Activate FIS.              : %0d", total_dma_act_fis_count);
      $display("Total number of Set device bits FIS.           : %0d", total_set_dev_bit_fis_count);
      $display("Total number of DEVICE RESET command.          : %0d", total_dev_rst_cmd_count);
      $display("Total number of SET FEATURE command.           : %0d", total_set_feat_cmd_count);
      $display("Total number of IDENTIFY DEVICE command.       : %0d", total_identify_dev_cmd_count);
      $display("Total number of READ LOG EXT command.          : %0d", total_rd_log_ext_cmd_count);
      $display("Total number of NON DATA command.              : %0d", total_non_data_cmd_count);
      $display("Total number of PIO data-in command.           : %0d", total_pio_in_cmd_count);
      $display("Total number of PIO data-out command.          : %0d", total_pio_out_cmd_count);
      $display("Total number of DMA data-in command.           : %0d", total_dma_in_cmd_count);
      $display("Total number of DMA data-out command.          : %0d", total_dma_out_cmd_count);
      $display("Total number of PACKET command.                : %0d", total_packet_cmd_count);
      $display("Total number of READ DMA QUEUED command.       : %0d", total_rd_queued_cmd_count);
      $display("Total number of WRITE DMA QUEUED command.      : %0d", total_wr_queued_cmd_count);
      $display("Total number of READ FPDMA command.            : %0d", total_rd_fpdma_cmd_count);
      $display("Total number of WRITE FPDMA command.           : %0d", total_wr_fpdma_cmd_count);
      $display("Total number of REG device to host FIS with ERR bit set.    : %0d", total_regfis_with_err_set_count);
      $display("Total number of Set device bits FIS with ERR bit set.       : %0d", total_sdbfis_with_err_set_count);
      $display("Total number of PIO setup FIS with ERR bit set.             : %0d", total_piofis_with_err_set_count);
      $display("Total number fo DMA setup FIS with autoactivate bit set.    : %0d", total_dmasu_with_auto_act_count);
      $display("Total number of times Asynchronous notifiction requested by device and serviced with REG FIS. : %0d", total_regfis_with_notif_count);
      $display("Total number of Set device bits FISes with SERV bit set.    : %0d", total_sdbfis_with_serv_set_count);
      $display("Total number of REG device to host FISes with REL bit set.  : %0d", total_regfis_with_rel_set_count);
      $display("Total number of successful PIO data-in transfers.           : %0d", successful_pio_in_tx_count);
      $display("Successful PIO data-out transfers.             : %0d", successful_pio_out_tx_count);
      $display("Successful DMA data-in transfers               : %0d", successful_dma_in_tx_count);
      $display("Successful DMA data-out transfers.             : %0d", successful_dma_out_tx_count);
      $display("Successful READ DMA queued transfers.          : %0d", successful_rd_qdma_tx_count);
      $display("Successful WRITE DMA queued transfers.         : %0d", successful_wr_qdma_tx_count);
      $display("Successful READ FPDMA transfers.               : %0d", successful_rd_fpdma_count);
      $display("Successful WRITE FPDMA transfers.              : %0d", successful_wr_fpdma_count);
      $display("Unsuccessful PIO data-in transfers.            : %0d", un_successful_pio_in_tx_count);
      $display("Unsuccessful PIO data-out transfers.           : %0d", un_successful_pio_out_tx_count);
      $display("Unsuccessful DMA data-in transfers.            : %0d", un_successful_dma_in_tx_count);
      $display("Unsuccessful DMA data-out transfers.           : %0d", un_successful_dma_out_tx_count);
      $display("Unsuccessful READ DMA queued transfers.        : %0d", un_successful_rd_qdma_tx_count);
      $display("Unsuccessful WRITE DMA queued transfers.       : %0d", un_successful_wr_qdma_tx_count);
      $display("Unsuccessful READ FPDMA transfers.             : %0d", un_successful_rd_fpdma_count);
      $display("Unsuccessful WRITE FPDMA transfers.            : %0d", un_successful_wr_fpdma_count);
      $display("----------------------------------------------------------------------------------");
    end
`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
