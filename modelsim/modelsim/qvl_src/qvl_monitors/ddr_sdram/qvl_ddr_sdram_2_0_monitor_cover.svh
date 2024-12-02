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

  reg prevent_x_to_valid_transition_count = 1'b0;
  
  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of 
      // simulation
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
  covergroup ddr_sdram_statistics @ (posedge clock);

  type_option.strobe = 1;
  type_option.comment = "Statistics for DDR SDRAM Monitor";

  S0 : coverpoint (!($stable(stats_counter_all_active_cmds, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Active_Commands = {1};
           type_option.comment = "Active Commands";
           }

  endgroup : ddr_sdram_statistics

  covergroup ddr_sdram_cornercases @ (posedge clock);

  type_option.strobe = 1;
  type_option.comment = "Cornercases for DDR SDRAM Monitor";

  C0 : coverpoint (!($stable(stats_counter_all_read_cmds, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Read_Commands = {1};
           type_option.comment = "Read Commands";
           }

  C1 : coverpoint (!($stable(stats_counter_all_write_cmds, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Write_Commands = {1};
           type_option.comment = "Write Commands";
           }

  C2 : coverpoint (!($stable(stats_counter_all_pre_cmds, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Precharge_Commands = {1};
           type_option.comment = "Precharge Commands";
           }

  C3 : coverpoint (!($stable(stats_counter_all_burst_stop_cmds, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Burst_Stop_Commands = {1};
           type_option.comment = "Burst Stop Commands";
           }

  C4 : coverpoint (!($stable(stats_counter_mrs_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Mode_Register_Set_Commands = {1};
           type_option.comment = "Mode Register Set Commands";
           }

  C5 : coverpoint (!($stable(stats_counter_cbr_refresh_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins CBR_Refresh_Commands = {1};
           type_option.comment = "CBR Refresh Commands";
           }

  C6 : coverpoint (!($stable(stats_counter_self_refresh_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Self_Refresh_Commands = {1};
           type_option.comment = "Self Refresh Commands";
           }

  C7 : coverpoint (!($stable(stats_counter_power_down_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Power_Down_Commands = {1};
           type_option.comment = "Power Down Commands";
           }

  C8 : coverpoint (!($stable(stats_counter_extended_mrs_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Extended_Mode_Register_Set_Commands = {1};
           type_option.comment = "Mode Register Set Commands";
           }

  C9 : coverpoint (!($stable(stats_counter_precharge_all_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Precharge_all_Commands = {1};
           type_option.comment = "Precharge all Commands";
           }

  C10 : coverpoint (!($stable(stats_counter_nop_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins NOP_Commands = {1};
           type_option.comment = "NOP Commands";
           }

  C11 : coverpoint (!($stable(stats_counter_dsel_cmd, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Deselect_Commands = {1};
           type_option.comment = "Deselect Commands";
           }

  endgroup : ddr_sdram_cornercases

  ddr_sdram_cornercases DDR_SDRAM_CORNERCASES = new();
  ddr_sdram_statistics DDR_SDRAM_STATISTICS = new();

  initial
    begin
      ddr_sdram_cornercases::type_option.comment = "Cornercases for DDR SDRAM Monitor";
      ddr_sdram_statistics::type_option.comment = "Statistics for DDR SDRAM Monitor";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for DDR SDRAM Monitor ------------------");
      $display("Monitor instance                          : %m");
      $display("------------------- Statistics for DDR SDRAM Monitor ---------------");
      $display("Active Commands                           : %0d", stats_counter_all_active_cmds);
      $display("------------------- Cornercases for DDR SDRAM Monitor ---------------");
      $display("Read Commands                             : %0d", stats_counter_all_read_cmds);
      $display("Write Commands                            : %0d", stats_counter_all_write_cmds);
      $display("Precharge Commands                        : %0d", stats_counter_all_pre_cmds);
      $display("Burst Stop Commands                       : %0d", stats_counter_all_burst_stop_cmds);
      $display("Mode Register Set Commands                : %0d", stats_counter_mrs_cmd);
      $display("CBR (auto) Refresh Commands               : %0d", stats_counter_cbr_refresh_cmd);
      $display("Self Refresh Commands                     : %0d", stats_counter_self_refresh_cmd);
      $display("Power Down Commands                       : %0d", stats_counter_power_down_cmd);
      $display("Extended Mode Register Set Commands       : %0d", stats_counter_extended_mrs_cmd);
      $display("Precharge All Commands                    : %0d", stats_counter_precharge_all_cmd);
      $display("NOP Commands                              : %0d", stats_counter_nop_cmd);
      $display("Deselect Commands                         : %0d", stats_counter_dsel_cmd);
      $display("--------------------------------------------------------------------");
    end
`endif // QVL_MW_FINAL_COVER
`endif // QVL_COVER_ON
