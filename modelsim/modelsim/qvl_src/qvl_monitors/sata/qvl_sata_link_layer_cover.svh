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

  always@(clk)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
      //cover_reset <= `ZiCwDebugDelay1 (areset | reset);
    end


  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.
  

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 //cover_reset == 1'b0 &&
                                 reset == 1'b0 &&
                                 areset == 1'b0 &&
                                 //cover_reset == 1'b0 &&
                                 prevent_x_to_valid_transition_count == 1'b1);


`ifdef QVL_SV_COVERGROUP
  covergroup sata_link_statistics @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for SATA LINK Monitor";

    S0 : coverpoint (!($stable(total_primitives, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_primitives = {1};
        type_option.comment = "Total number of primitives.";
        }

    S1 : coverpoint (!($stable(total_no_of_malformed_frames, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_malformed_frames = {1};
        type_option.comment = "Total number of malformed frames.";
        }

    S2 : coverpoint (!($stable(fis_count_exceeded_pio_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_transaction_that_exceeded_the_transfer_count = {1};
        type_option.comment = "Total number of transaction that exceeded the transfer count.";
        }

    S3 : coverpoint (!($stable(fis_count_less_pio_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_transaction_that_had_less_transfer_count = {1};
        type_option.comment = "Total number of transaction that had less transfer count.";
        }

    S4 : coverpoint (!($stable(total_frames_with_crc_err, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_frames_with_CRC_error = {1};
        type_option.comment = "Total number of frames with CRC error.";
        }

  endgroup : sata_link_statistics


  covergroup sata_link_cornercases @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for SATA LINK Monitor";

    C0 : coverpoint (!($stable(total_no_of_comwake_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_COMWAKE_detected = {1};
        type_option.comment = "Total number of times COMWAKE detected.";
        }

    C1 : coverpoint (!($stable(no_of_partial_initiated_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_partial_intiated = {1};
        type_option.comment = "Total number of times partial intiated.";
        }

    C2 : coverpoint (!($stable(no_of_slumber_initiated_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_slumber_intiated = {1};
        type_option.comment = "Total number of times slumber intiated.";
        }

    C3 : coverpoint (!($stable(no_of_partial_entered_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_partial_entered = {1};
        type_option.comment = "Total number of times partial entered.";
        }

    C4 : coverpoint (!($stable(no_of_slumber_entered_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_times_slumber_entered = {1};
        type_option.comment = "Total number of times slumber entered.";
        }

    C5 : coverpoint (!($stable(total_no_of_align_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_ALIGNp = {1};
        type_option.comment = "Total number of ALIGNp.";
        }

    C6 : coverpoint (!($stable(total_no_of_cont_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_CONTp = {1};
        type_option.comment = "Total number of CONTp.";
        }

    C7 : coverpoint (!($stable(total_no_of_dmat_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DMATp = {1};
        type_option.comment = "Total number of DMATp.";
        }

    C8 : coverpoint (!($stable(total_no_of_eof_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_EOFp = {1};
        type_option.comment = "Total number of EOFp.";
        }

    C9 : coverpoint (!($stable(total_no_of_hold_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_HOLDp = {1};
        type_option.comment = "Total number of HOLDp.";
        }

    C10 : coverpoint (!($stable(total_no_of_holda_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_HOLDAp = {1};
        type_option.comment = "Total number of HOLDAp.";
        }

    C11 : coverpoint (!($stable(total_no_of_pmack_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PMACKp = {1};
        type_option.comment = "Total number of PMACKp.";
        }

    C12 : coverpoint (!($stable(total_no_of_pmnak_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PMNAKp = {1};
        type_option.comment = "Total number of PMNAKp.";
        }

    C13 : coverpoint (!($stable(total_no_of_pmreqp_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PMREQ_Pp = {1};
        type_option.comment = "Total number of PMREQ_Pp.";
        }

    C14 : coverpoint (!($stable(total_no_of_pmreqs_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_PMREQ_Sp = {1};
        type_option.comment = "Total number of PMREQ_Sp.";
        }

    C15 : coverpoint (!($stable(total_no_of_r_err_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_R_ERRp = {1};
        type_option.comment = "Total number of R_ERRp.";
        }

    C16 : coverpoint (!($stable(total_no_of_r_ip_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_R_IPp = {1};
        type_option.comment = "Total number of R_IPp.";
        }

    C17 : coverpoint (!($stable(total_no_of_r_ok_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_R_OKp = {1};
        type_option.comment = "Total number of R_OKp.";
        }

    C18 : coverpoint (!($stable(total_no_of_r_rdy_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_R_RDYp = {1};
        type_option.comment = "Total number of R_RDYp.";
        }

    C19 : coverpoint (!($stable(total_no_of_sof_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_SOFp = {1};
        type_option.comment = "Total number of SOFp.";
        }

    C20 : coverpoint (!($stable(total_no_of_sync_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_SYNCp = {1};
        type_option.comment = "Total number of SYNCp.";
        }

    C21 : coverpoint (!($stable(total_no_of_x_rdy_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_X_RDYp = {1};
        type_option.comment = "Total number of X_RDYp.";
        }

    C22 : coverpoint (!($stable(total_no_of_wtrm_p_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_WTRMp = {1};
        type_option.comment = "Total number of WTRMp.";
        }

    C23 : coverpoint (!($stable(total_tx_put_on_hold_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_frame_transfers_that_were_put_on_hold_by_HOLDp = {1};
        type_option.comment = "Total number of frame transfers that were put on hold by HOLDp.";
        }

    C24 : coverpoint (!($stable(total_dma_setup_fis_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DMA_setup_fis = {1};
        type_option.comment = "Total number of DMA setup fis.";
        }

    C25 : coverpoint (!($stable(total_bist_act_fis_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_BIST_Activate_fis = {1};
        type_option.comment = "Total number of BIST Activate fis.";
        }

    C26 : coverpoint (!($stable(total_data_fis_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_number_of_DATA_fis = {1};
        type_option.comment = "Total number of DATA fis.";
        }

  endgroup : sata_link_cornercases

  sata_link_statistics  SATA_LINK_STATISTICS = new();
  sata_link_cornercases  SATA_LINK_CORNERCASES = new();

  initial
    begin
      sata_link_statistics::type_option.comment = "Statistics for SATA LINK Monitor";
      sata_link_cornercases::type_option.comment = "Cornercases for SATA LINK Monitor";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for SATA LINK Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for SATA LINK Monitor -------------------------");

      $display("Total number of primitives.                                    : %0d", total_primitives);
      $display("Total number of malformed frames.                              : %0d", total_no_of_malformed_frames);
      $display("Total number of transaction that exceeded the transfer count.  : %0d", fis_count_exceeded_pio_count);
      $display("Total number of transaction that had less transfer count.      : %0d", fis_count_less_pio_count);
      $display("Total number of frames with CRC error.                         : %0d", total_frames_with_crc_err);

      $display("------------------- Cornercases for SATA LINK Monitor -------------------------");

      $display("Total number of times COMWAKE detected.  : %0d", total_no_of_comwake_count);
      $display("Total number of times partial intiated.  : %0d", no_of_partial_initiated_count);
      $display("Total number of times slumber intiated.  : %0d", no_of_slumber_initiated_count);
      $display("Total number of times partial entered.   : %0d", no_of_partial_entered_count);
      $display("Total number of times slumber entered.   : %0d", no_of_slumber_entered_count);
      $display("Total number of ALIGNp.                  : %0d", total_no_of_align_p_count);
      $display("Total number of CONTp.                   : %0d", total_no_of_cont_p_count);
      $display("Total number of DMATp.                   : %0d", total_no_of_dmat_p_count);
      $display("Total number of EOFp.                    : %0d", total_no_of_eof_p_count);
      $display("Total number of HOLDp.                   : %0d", total_no_of_hold_p_count);
      $display("Total number of HOLDAp.                  : %0d", total_no_of_holda_p_count);
      $display("Total number of PMACKp.                  : %0d", total_no_of_pmack_p_count);
      $display("Total number of PMNAKp.                  : %0d", total_no_of_pmnak_p_count);
      $display("Total number of PMREQ_Pp.                : %0d", total_no_of_pmreqp_p_count);
      $display("Total number of PMREQ_Sp.                : %0d", total_no_of_pmreqs_p_count);
      $display("Total number of R_ERRp.                  : %0d", total_no_of_r_err_p_count);
      $display("Total number of R_IPp.                   : %0d", total_no_of_r_ip_p_count);
      $display("Total number of R_OKp.                   : %0d", total_no_of_r_ok_p_count);
      $display("Total number of R_RDYp.                  : %0d", total_no_of_r_rdy_p_count);
      $display("Total number of SOFp.                    : %0d", total_no_of_sof_p_count);
      $display("Total number of SYNCp.                   : %0d", total_no_of_sync_p_count);
      $display("Total number of X_RDYp.                  : %0d", total_no_of_x_rdy_p_count);
      $display("Total number of WTRMp.                   : %0d", total_no_of_wtrm_p_count);
      $display("Total number of frame transfers that were put on hold by HOLDp.  : %0d", total_tx_put_on_hold_count);
      $display("Total number of DMA setup fis.           : %0d", total_dma_setup_fis_count);
      $display("Total number of BIST Activate fis.       : %0d", total_bist_act_fis_count);
      $display("Total number of DATA fis.                : %0d", total_data_fis_count);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
