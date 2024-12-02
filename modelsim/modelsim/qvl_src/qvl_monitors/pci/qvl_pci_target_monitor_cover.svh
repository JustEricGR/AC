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

  always@(posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 reset_n == 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  wire [63:0] rw_cnt = read_cnt + writ_cnt;

`ifdef QVL_SV_COVERGROUP

  covergroup pci_target_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for PCI Target Monitor";

    S0 : coverpoint (!($stable(rw_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Total_Transfers = {1};
        type_option.comment = "Total Transfers";
        }

    S1 : coverpoint (!($stable(unkn_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Unknown_Commands = {1};
        type_option.comment = "Unknown Commands";
        }

  endgroup : pci_target_statistics


  covergroup pci_target_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for PCI Target Monitor";

    C0 : coverpoint (!($stable(read_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Read_Transfers = {1};
        type_option.comment = "Read Transfers";
        }

    C1 : coverpoint (!($stable(writ_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Write_Transfers = {1};
        type_option.comment = "Write Transfers";
        }

    C2 : coverpoint (!($stable(intr_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Interrupt_Acknowledge_Cycles = {1};
        type_option.comment = "Interrupt Acknowledge Cycles";
        }

    C3 : coverpoint (!($stable(spec_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Special_Cycles = {1};
        type_option.comment = "Special Cycles";
        }

    C4 : coverpoint (!($stable(rese_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Reserved_Cycles = {1};
        type_option.comment = "Reserved Cycles";
        }

    C5 : coverpoint (!($stable(dual_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Dual_Address_Cycles = {1};
        type_option.comment = "Dual Address Cycles";
        }

    C6 : coverpoint (!($stable(addr_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Address_States = {1};
        type_option.comment = "Address States";
        }

    C7 : coverpoint (!($stable(dual_add_st_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Dual_Address_States = {1};
        type_option.comment = "Dual Address States";
        }

    C8 : coverpoint (!($stable(fast_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Address_Fast_Decodes = {1};
        type_option.comment = "Address Fast Decodes";
        }

    C9 : coverpoint (!($stable(medm_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Address_Medium_Decodes = {1};
        type_option.comment = "Address Medium Decodes";
        }

    C10 : coverpoint (!($stable(slow_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Address_Slow_Decodes = {1};
        type_option.comment = "Address Slow Decodes";
        }

    C11 : coverpoint (!($stable(bdge_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Address_Bridge_Decodes = {1};
        type_option.comment = "Address Bridge Decodes";
        }

    C12 : coverpoint (!($stable(rtry_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Retry_States = {1};
        type_option.comment = "Retry States";
        }

    C13 : coverpoint (!($stable(dnab_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Disconnect_A_or_B_States = {1};
        type_option.comment = "Disconnect A/B States";
        }

    C14 : coverpoint (!($stable(dntc_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Disconnect_C_States = {1};
        type_option.comment = "Disconnect C States";
        }

    C15 : coverpoint (!($stable(tabr_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Target_Aborts = {1};
        type_option.comment = "Target Aborts";
        }

    C16 : coverpoint (!($stable(mabr_cnt, @ (posedge clock)))) iff(enable_coverpoint)
        {
        bins Master_Aborts = {1};
        type_option.comment = "Master Aborts";
        }

  endgroup : pci_target_cornercases

  pci_target_statistics PCI_TARGET_STATISTICS = new();
  pci_target_cornercases PCI_TARGET_CORNERCASES = new();

  initial
    begin
      pci_target_statistics::type_option.comment = "Statistics for PCI Target Monitor";
      pci_target_cornercases::type_option.comment = "Corner Cases for PCI Target Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("-------- Coverage for PCI Target Monitor ----------");

      $display("Monitor instance             : %m");

      $display("-------- Statistics for PCI Target Monitor --------");

      $display("Total Transfers              : %0d", rw_cnt);
      $display("Unknown Commands             : %0d", unkn_cnt);

      $display("------ Corner Cases for PCI Target Monitor ---------");

      $display("Read Transfers               : %0d", read_cnt);
      $display("Write Transfers              : %0d", writ_cnt);
      $display("Interrupt Acknowledge Cycles : %0d", intr_cnt);
      $display("Special Cycles               : %0d", spec_cnt);
      $display("Reserved Cycles              : %0d", rese_cnt);
      $display("Dual Address Cycles          : %0d", dual_cnt);
      $display("Address States               : %0d", addr_cnt);
      $display("Dual Address States          : %0d", dual_add_st_cnt);
      $display("Address Fast Decodes         : %0d", fast_cnt);
      $display("Address Medium Decodes       : %0d", medm_cnt);
      $display("Address Slow Decodes         : %0d", slow_cnt);
      $display("Address Bridge Decodes       : %0d", bdge_cnt);
      $display("Retry States                 : %0d", rtry_cnt);
      $display("Disconnect A/B States        : %0d", dnab_cnt);
      $display("Disconnect C States          : %0d", dntc_cnt);
      $display("Target Aborts                : %0d", tabr_cnt);
      $display("Master Aborts                : %0d", mabr_cnt);
      $display("---------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
