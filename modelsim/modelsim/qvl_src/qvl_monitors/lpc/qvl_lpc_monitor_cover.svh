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

  //---------------------------------------------------------------------------
  //SV Covergroups start here
  //---------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always@(posedge lclk)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 && lreset_n == 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);

`ifdef QVL_SV_COVERGROUP

  covergroup lpc_statistics @ (posedge lclk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for LPC Monitor";

    S0 : coverpoint (!($stable(stats_num_total_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Total_Transfers = {1};
        type_option.comment = "Total Transfers";
        }

  endgroup : lpc_statistics


  covergroup lpc_cornercases @ (posedge lclk);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for LPC Monitor";

    C0 : coverpoint (!($stable(stats_num_host_io_read_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Host_Initiated_IO_Read_Transfers = {1};
        type_option.comment = "Host Initiated I/O Read Transfers";
        }

    C1 : coverpoint (!($stable(stats_num_host_io_write_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Host_Initiated_IO_Write_Transfers = {1};
        type_option.comment = "Host Initiated I/O Write Transfers";
        }

    C2 : coverpoint (!($stable(stats_num_host_mem_read_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Host_Initiated_Memory_Read_Transfers = {1};
        type_option.comment = "Host Initiated Memory Read Transfers";
        }

    C3 : coverpoint (!($stable(stats_num_host_mem_write_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Host_Initiated_Memory_Write_Transfers = {1};
        type_option.comment = "Host Initiated Memory Write Transfers";
        }

    C4 : coverpoint (!($stable(stats_num_dma_read_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins DMA_Read_Transfers = {1};
        type_option.comment = "DMA Read Transfers";
        }

    C5 : coverpoint (!($stable(stats_num_dma_write_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins DMA_Write_Transfers = {1};
        type_option.comment = "DMA Write Transfers";
        }

    C6 : coverpoint (!($stable(stats_num_bus_mas_io_read_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Peripheral_Initiated_IO_Read_Transfers = {1};
        type_option.comment = "Peripheral Initiated I/O Read Transfers";
        }

    C7 : coverpoint (!($stable(stats_num_bus_mas_io_write_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Peripheral_Initiated_IO_Write_Transfers = {1};
        type_option.comment = "Peripheral Initiated I/O Write Transfers";
        }

    C8 : coverpoint (!($stable(stats_num_bus_mas_mem_read_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Peripheral_Initiated_Memory_Read_Transfers = {1};
        type_option.comment = "Peripheral Initiated Memory Read Transfers";
        }

    C9 : coverpoint (!($stable(stats_num_bus_mas_mem_write_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Peripheral_Initiated_Memory_Write_Transfers = {1};
        type_option.comment = "Peripheral Initiated Memory Write Transfers";
        }

    C10 : coverpoint (!($stable(stats_num_back2back_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Back_to_Back_Transfers = {1};
        type_option.comment = "Back to Back Transfers";
        }

    C11 : coverpoint (!($stable(stats_num_aborts, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins Aborted_Transfers = {1};
        type_option.comment = "Aborted Transfers";
        }

    C12 : coverpoint (!($stable(stats_num_8_bit_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins _8_Bit_Data_Transfers = {1};
        type_option.comment = "8-bit Data Transfers";
        }

    C13 : coverpoint (!($stable(stats_num_16_bit_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins _16_Bit_Data_Transfers = {1};
        type_option.comment = "16-bit Data Transfers";
        }

    C14 : coverpoint (!($stable(stats_num_32_bit_transfers, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins _32_Bit_Data_Transfers = {1};
        type_option.comment = "32-bit Data Transfers";
        }

    C15 : coverpoint (!($stable(stats_num_dma_on_deactivated_channels, @ (posedge lclk)))) iff(enable_coverpoint)
        {
        bins DMA_Transfers_On_Deactivated_Channels = {1};
        type_option.comment = "DMA Transfers On Deactivated Channels";
        }

  endgroup : lpc_cornercases

  lpc_statistics  LPC_STATISTICS = new();
  lpc_cornercases  LPC_CORNERCASES = new();

  initial
    begin
      lpc_statistics::type_option.comment = "Statistics for LPC Monitor";
      lpc_cornercases::type_option.comment = "Corner Cases for LPC Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for LPC Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for LPC Monitor -------------------------");

      $display("Total Transfers                               : %0d", stats_num_total_transfers);

      $display("------------------- Corner Cases for LPC Monitor -------------------------");

      $display("Host Initiated I/O Read Transfers             : %0d", stats_num_host_io_read_transfers);
      $display("Host Initiated I/O Write Transfers            : %0d", stats_num_host_io_write_transfers);
      $display("Host Initiated Memory Read Transfers          : %0d", stats_num_host_mem_read_transfers);
      $display("Host Initiated Memory Write Transfers         : %0d", stats_num_host_mem_write_transfers);
      $display("DMA Read Transfers                            : %0d", stats_num_dma_read_transfers);
      $display("DMA Write Transfers                           : %0d", stats_num_dma_write_transfers);
      $display("Peripheral Initiated I/O Read Transfers       : %0d", stats_num_bus_mas_io_read_transfers);
      $display("Peripheral Initiated I/O Write Transfers      : %0d", stats_num_bus_mas_io_write_transfers);
      $display("Peripheral Initiated Memory Read Transfers    : %0d", stats_num_bus_mas_mem_read_transfers);
      $display("Peripheral Initiated Memory Write Transfers   : %0d", stats_num_bus_mas_mem_write_transfers);
      $display("Back to Back Transfers                        : %0d", stats_num_back2back_transfers);
      $display("Aborted Transfers                             : %0d", stats_num_aborts);
      $display("8-bit Data Transfers                          : %0d", stats_num_8_bit_transfers);
      $display("16-bit Data Transfers                         : %0d", stats_num_16_bit_transfers);
      $display("32-bit Data Transfers                         : %0d", stats_num_32_bit_transfers);
      $display("DMA Transfers On Deactivated Channels         : %0d", stats_num_dma_on_deactivated_channels);
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
