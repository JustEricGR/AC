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
//*****************************************************************************

`ifdef QVL_COVER_ON
  //------------------------------------------------------------------------
  // SV Covergroups start here
  //------------------------------------------------------------------------

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  reg prevent_x_to_valid_transition_count;

  initial
    // This is required to prevent the coverpoints to increment 
    // when 'x' to '0' transition that happens during start of 
    // simulation
    begin
      prevent_x_to_valid_transition_count = 1'b0;
    end 

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end  

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 reset == 1'b0 &&
                                 areset == 1'b0 &&
                                 prevent_x_to_valid_transition_count);

`ifdef QVL_SV_COVERGROUP
  covergroup ddr_sdram_bank_statistics @ (posedge clock);

  type_option.strobe = 1;
  type_option.comment = "Statistics for DDR SDRAM Bank Monitor";

  S0 : coverpoint (!($stable(stats_counter_activates, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Active_Commands = {1};
           type_option.comment = "Active Commands";
           }

  endgroup : ddr_sdram_bank_statistics

  covergroup ddr_sdram_bank_cornercases @ (posedge clock);

  type_option.strobe = 1;
  type_option.comment = "Cornercases for DDR SDRAM Bank Monitor";

  C0 : coverpoint (!($stable(stats_counter_reads, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_Commands = {1};
           type_option.comment = "Read Commands";
           }

  C1 : coverpoint (!($stable(stats_counter_read_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_without_auto_precharge_Commands = {1};
           type_option.comment = "Read Without Auto Precharge Commands";
           }

  C2 : coverpoint (!($stable(stats_counter_reada_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_with_auto_precharge_Commands = {1};
           type_option.comment = "Read With Auto Precharge Commands";
           }

  C3 : coverpoint (!($stable(stats_counter_read_after_read_in_page, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_after_Read_in_Page = {1};
           type_option.comment = "Read After Read In Page";
           }

  C4 : coverpoint (!($stable(stats_counter_read_after_write_in_page, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_after_Write_in_Page = {1};
           type_option.comment = "Read After Write In Page";
           }

  C5 : coverpoint (!($stable(stats_counter_writes, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_Commands = {1};
           type_option.comment = "Write Commands";
           }

  C6 : coverpoint (!($stable(stats_counter_write_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_without_auto_precharge_Commands = {1};
           type_option.comment = "Write Without Auto Precharge Commands";
           }

  C7 : coverpoint (!($stable(stats_counter_writea_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_with_auto_precharge_Commands = {1};
           type_option.comment = "Write With Auto Precharge Commands";
           }

  C8 : coverpoint (!($stable(stats_counter_write_after_read_in_page, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_after_Read_in_Page = {1};
           type_option.comment = "Write After Read In Page";
           }

  C9 : coverpoint (!($stable(stats_counter_write_after_write_in_page, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_after_Write_in_Page = {1};
           type_option.comment = "Write After Write In Page";
           }

  C10 : coverpoint (!($stable(stats_counter_pre_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Precharge_Commands = {1};
           type_option.comment = "Precharge Commands";
           }

  C11 : coverpoint (!($stable(stats_counter_bursts_stopped, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Burst_Operations_Terminated = {1};
           type_option.comment = "Burst Operations Terminated";
           }


  endgroup : ddr_sdram_bank_cornercases

  ddr_sdram_bank_cornercases DDR_SDRAM_BANK_CORNERCASES = new();
  ddr_sdram_bank_statistics DDR_SDRAM_BANK_STATISTICS = new();

  initial
    begin
      ddr_sdram_bank_cornercases::type_option.comment = "Cornercases for DDR SDRAM Bank Monitor";
      ddr_sdram_bank_statistics::type_option.comment = "Statistics for DDR SDRAM Bank Monitor";
    end

`endif //ifdef QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for DDR SDRAM Bank Monitor ------------------");
      $display("Monitor instance                     : %m");
      $display("------------------- Statistics for DDR SDRAM Bank Monitor ---------------");
      $display("Active Commands                      : %0d", stats_counter_activates);
      $display("------------------- Cornercases for DDR SDRAM Bank Monitor ---------------");
      $display("Read Commands                        : %0d", stats_counter_reads);
      $display("Read Commands Without Autoprecharge  : %0d", stats_counter_read_cmd);
      $display("Read Commands With Autoprecharge     : %0d", stats_counter_reada_cmd);
      $display("Read after Read in Page              : %0d", stats_counter_read_after_read_in_page);
      $display("Read after Write in Page             : %0d", stats_counter_read_after_write_in_page);
      $display("Write Commands                       : %0d", stats_counter_writes);
      $display("Write Commands Without Autoprecharge : %0d", stats_counter_write_cmd);
      $display("Write Commands With Autoprecharge    : %0d", stats_counter_writea_cmd);
      $display("Write after Read in Page             : %0d", stats_counter_write_after_read_in_page);
      $display("Write after Write in Page            : %0d", stats_counter_write_after_write_in_page);
      $display("Precharge Commands                   : %0d", stats_counter_pre_cmd);
      $display("Burst Operations Terminated          : %0d", stats_counter_bursts_stopped);
      $display("--------------------------------------------------------------------");
    end
`endif // QVL_MW_FINAL_COVER
`endif // QVL_COVER_ON
