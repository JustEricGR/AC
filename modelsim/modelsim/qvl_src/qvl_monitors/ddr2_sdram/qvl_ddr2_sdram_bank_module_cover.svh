//              Copyright 2006 Mentor Graphics Corporation
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

  //------------------------------------------------------------------------
  // SV Covergroups start here
  //------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  initial
    begin
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge clock) prevent_x_to_valid_transition_count <= 1'b1;

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 areset === 1'b0 &&
                                 reset === 1'b0 &&
                                 prevent_x_to_valid_transition_count);

`ifdef QVL_SV_COVERGROUP
  covergroup ddr2_sdram_2_0_bank_statistics @ (posedge clock);

   type_option.strobe = 1;
   type_option.comment = "Statistics for DDR2 SDRAM 2.0 Bank Monitor";

   S0 : coverpoint (!($stable(data_accesses_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Number_of_Bank_Accesses = {1};
        type_option.comment = "Total Number of Bank Accesses";
        }

  endgroup : ddr2_sdram_2_0_bank_statistics

  covergroup ddr2_sdram_2_0_bank_cornercases @ (posedge clock);

   type_option.strobe = 1;
   type_option.comment = "Cornercases for DDR2 SDRAM 2.0 Bank Monitor";

   C0 : coverpoint (!($stable(reads_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Reads_Without_Precharge = {1};
        type_option.comment = "Reads Without Precharge";
        }

   C1 : coverpoint (!($stable(writes_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Writes_Without_Precharge = {1};
        type_option.comment = "Writes Without Precharge";
        }

   C2 : coverpoint (!($stable(seamless_reads_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Seamless_Reads = {1};
        type_option.comment = "Seamless Reads";
        }

   C3 : coverpoint (!($stable(seamless_writes_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Seamless_Writes = {1};
        type_option.comment = "Seamless Writes";
        }

   C4 : coverpoint (!($stable(reads_with_autoprecharge_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Reads_With_Precharge = {1};
        type_option.comment = "Reads With Precharge";
        }

   C5 : coverpoint (!($stable(writes_with_autoprecharge_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Writes_With_Precharge = {1};
        type_option.comment = "Writes With Precharge";
        }

   C6 : coverpoint (!($stable(single_bank_precharges_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Single_Bank_Precharges = {1};
        type_option.comment = "Single Bank Precharges";
        }

   C7 : coverpoint (!($stable(posted_reads_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Posted_Reads = {1};
        type_option.comment = "Posted Reads";
        }

   C8 : coverpoint (!($stable(posted_writes_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Posted_Writes = {1};
        type_option.comment = "Posted Writes";
        }

   C9 : coverpoint (!($stable(read_reads_to_open_page_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Read_after_Read_in_Page = {1};
        type_option.comment = "Read after Read in Page";
        }

   C10 : coverpoint (!($stable(write_writes_to_open_page_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Write_after_Write_in_Page = {1};
        type_option.comment = "Write after Write in Page";
        }

   C11 : coverpoint (!($stable(read_writes_to_open_page_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Write_after_Read_in_Page = {1};
        type_option.comment = "Write after Read in Page";
        }

   C12 : coverpoint (!($stable(write_reads_to_open_page_count, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Read_after_Write_in_Page = {1};
        type_option.comment = "Read after Write in Page";
        }

  endgroup : ddr2_sdram_2_0_bank_cornercases

  ddr2_sdram_2_0_bank_statistics  DDR2_SDRAM_2_0_BANK_STATISTICS = new();
  ddr2_sdram_2_0_bank_cornercases DDR2_SDRAM_2_0_BANK_CORNERCASES = new();

  initial
    begin
      ddr2_sdram_2_0_bank_statistics::type_option.comment = "Statistics for DDR2 SDRAM 2.0 Bank Monitor";
      ddr2_sdram_2_0_bank_cornercases::type_option.comment = "Cornercases for DDR2 SDRAM 2.0 Bank Monitor";
    end
`endif //ifdef QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for DDR2 SDRAM 2.0 Bank Monitor ----------------");
      $display("Monitor instance          : %m");
      $display("------------------- Statistics for DDR2 SDRAM 2.0 Bank Monitor --------------");
      $display("Total Number of Bank Accesses : %0d",data_accesses_count);

      $display("------------------- Cornercases for DDR2 SDRAM 2.0 Bank Monitor -------------");
      $display("Reads Without Precharge       : %0d",reads_count);
      $display("Writes Without Precharge      : %0d",writes_count);
      $display("Seamless Reads                : %0d",seamless_reads_count);
      $display("Seamless Writes               : %0d",seamless_writes_count);
      $display("Reads With Precharge          : %0d",reads_with_autoprecharge_count);
      $display("Writes With Precharge         : %0d",writes_with_autoprecharge_count);
      $display("Single Bank Precharges        : %0d",single_bank_precharges_count);
      $display("Posted Reads                  : %0d",posted_reads_count);
      $display("Posted Writes                 : %0d",posted_writes_count);
      $display("Read after Read in Page       : %0d",read_reads_to_open_page_count);
      $display("Write after Write in Page     : %0d",write_writes_to_open_page_count);
      $display("Write after Read in Page      : %0d",read_writes_to_open_page_count);
      $display("Read after Write in Page      : %0d",write_reads_to_open_page_count);
      $display("-----------------------------------------------------------------------------");
    end

  //----------------------------------------------------------------------------
`endif //ifdef QVL_MW_FINAL_COVER
`endif //ifdef QVL_COVER_ON
