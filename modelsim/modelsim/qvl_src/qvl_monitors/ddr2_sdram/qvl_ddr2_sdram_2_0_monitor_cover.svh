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

  wire enable_coverpoint; // Wire to hold when to increment the stats

  initial
    begin
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge ck) prevent_x_to_valid_transition_count <= 1'b1;

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 areset === 1'b0 &&
                                 reset === 1'b0 &&
                                 prevent_x_to_valid_transition_count);

`ifdef QVL_SV_COVERGROUP
  covergroup ddr2_sdram_2_0_statistics @ (posedge ck);

   type_option.strobe = 1;
   type_option.comment = "Statistics for DDR2 SDRAM 2.0 Monitor";

   S0 : coverpoint (!($stable(data_accesses_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Total_Number_of_Memory_Accesses = {1};
        type_option.comment = "Total Number of Memory Accesses";
        }

  endgroup : ddr2_sdram_2_0_statistics

  covergroup ddr2_sdram_2_0_cornercases @ (posedge ck);

   type_option.strobe = 1;
   type_option.comment = "Cornercases for DDR2 SDRAM 2.0 Monitor";

   C0 : coverpoint (!($stable(multiple_banks_open_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Multiple_Banks_Activation = {1};
        type_option.comment = "Multiple Banks Activation";
        }

   C1 : coverpoint (!($stable(cbr_refresh_commands_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins CBR_Refresh_Commands = {1};
        type_option.comment = "CBR Refresh Commands";
        }

   C2 : coverpoint (!($stable(all_bank_precharges_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Precharge_All_Banks = {1};
        type_option.comment = "Precharge All Banks";
        }

   C3 : coverpoint (!($stable(mrs_prog_interleaved_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Interleaved_Bursts = {1};
        type_option.comment = "Interleaved Bursts";
        }

   C4 : coverpoint (!($stable(mrs_prog_sequential_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Sequential_Bursts = {1};
        type_option.comment = "Sequential Bursts";
        }

   C5 : coverpoint (!($stable(self_refresh_commands_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Self_Refresh_Commands = {1};
        type_option.comment = "Self Refresh Commands";
        }

   C6 : coverpoint (!($stable(pwrdn_commands_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Power_Down_Commands = {1};
        type_option.comment = "Power Down Commands";
        }

   C7 : coverpoint (!($stable(nop_commands_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins NOP_Commands = {1};
        type_option.comment = "NOP Commands";
        }

   C8 : coverpoint (!($stable(deselect_commands_count, @ (posedge ck)))) iff(enable_coverpoint)
        {
        bins Deselect_Commands = {1};
        type_option.comment = "Deselect Commands";
        }

  endgroup : ddr2_sdram_2_0_cornercases

  ddr2_sdram_2_0_statistics  DDR2_SDRAM_2_0_STATISTICS = new();
  ddr2_sdram_2_0_cornercases DDR2_SDRAM_2_0_CORNERCASES = new();

  initial
    begin
      ddr2_sdram_2_0_statistics::type_option.comment = "Statistics for DDR2 SDRAM 2.0 Monitor";
      ddr2_sdram_2_0_cornercases::type_option.comment = "Cornercases for DDR2 SDRAM 2.0 Monitor";
    end
`endif // ifdef QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for DDR2 SDRAM 2.0 Monitor ---------------------");
      $display("Monitor instance          : %m");
      $display("------------------- Statistics for DDR2 SDRAM 2.0 Monitor -------------------");
      $display("Total Number of Memory Accesses : %0d",data_accesses_count);

      $display("------------------ Cornercases for DDR2 SDRAM 2.0 Monitor -------------------");
      $display("Multiple Banks Activation       : %0d",multiple_banks_open_count);
      $display("CBR Refresh Commands            : %0d",cbr_refresh_commands_count);
      $display("Precharge All Banks             : %0d",all_bank_precharges_count);
      $display("Interleaved Bursts              : %0d",mrs_prog_interleaved_count);
      $display("Sequential Bursts               : %0d",mrs_prog_sequential_count);
      $display("Self Refresh Commands           : %0d",self_refresh_commands_count);
      $display("Power Down Commands             : %0d",pwrdn_commands_count);
      $display("NOP Commands                    : %0d",nop_commands_count);
      $display("Deselect Commands               : %0d",deselect_commands_count);
      $display("------------------------------------------------------------------------------");
    end

  //----------------------------------------------------------------------------
`endif //ifdef QVL_MW_FINAL_COVER
`endif // ifdef QVL_COVER_ON
