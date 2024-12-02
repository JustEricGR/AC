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
      #1;
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
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

  covergroup gigabit_ethernet_xaui_statistics @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for GIGABIT_ETHERNET_XAUI Monitor";

    S0 : coverpoint (!($stable(GIGABIT_STATS.qvl_total_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Total_frames = {1};
        type_option.comment = "Total frames";
        }

    S1 : coverpoint (!($stable(GIGABIT_STATS.qvl_invalid_frame_length_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_length_between_1518_and_1536 = {1};
        type_option.comment = "Frames with length between 1518 and 1536";
        }

  endgroup : gigabit_ethernet_xaui_statistics


  covergroup gigabit_ethernet_xaui_cornercases @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for GIGABIT_ETHERNET_XAUI Monitor";

    C0 : coverpoint (!($stable(GIGABIT_STATS.qvl_data_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Data_frames = {1};
        type_option.comment = "Data frames";
        }

    C1 : coverpoint (!($stable(GIGABIT_STATS.qvl_ctrl_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Control_frames = {1};
        type_option.comment = "Control frames";
        }

    C2 : coverpoint (!($stable(GIGABIT_STATS.qvl_jumbo_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Jumbo_data_frames = {1};
        type_option.comment = "Jumbo data frames";
        }

    C3 : coverpoint (!($stable(GIGABIT_STATS.qvl_untagged_data_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Untagged_data_frames = {1};
        type_option.comment = "Untagged data frames";
        }

    C4 : coverpoint (!($stable(GIGABIT_STATS.qvl_vlan_tagged_data_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_data_frames = {1};
        type_option.comment = "VLAN tagged data frames";
        }

    C5 : coverpoint (!($stable(GIGABIT_STATS.qvl_priority_tagged_data_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_data_frames = {1};
        type_option.comment = "Priority tagged data frames";
        }

    C6 : coverpoint (!($stable(GIGABIT_STATS.qvl_untagged_pause_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Untagged_pause_control_frames = {1};
        type_option.comment = "Untagged pause control frames";
        }

    C7 : coverpoint (!($stable(GIGABIT_STATS.qvl_vlan_tagged_pause_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_pause_control_frames = {1};
        type_option.comment = "VLAN tagged pause control frames";
        }

    C8 : coverpoint (!($stable(GIGABIT_STATS.qvl_priority_tagged_pause_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_pause_control_frames = {1};
        type_option.comment = "Priority tagged pause control frames";
        }

    C9 : coverpoint (!($stable(GIGABIT_STATS.qvl_untagged_jumbo_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Untagged_jumbo_frames = {1};
        type_option.comment = "Untagged jumbo frames";
        }

    C10 : coverpoint (!($stable(GIGABIT_STATS.qvl_vlan_tagged_jumbo_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_jumbo_frames = {1};
        type_option.comment = "VLAN tagged jumbo frames";
        }

    C11 : coverpoint (!($stable(GIGABIT_STATS.qvl_priority_tagged_jumbo_frames_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_jumbo_frames = {1};
        type_option.comment = "Priority tagged jumbo frames";
        }

    C12 : coverpoint (!($stable(GIGABIT_STATS.qvl_frames_with_global_address_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_globally_administered_addresses = {1};
        type_option.comment = "Frames with globally administered addresses";
        }

    C13 : coverpoint (!($stable(GIGABIT_STATS.qvl_frames_with_local_address_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_locally_administered_addresses = {1};
        type_option.comment = "Frames with locally administered addresses";
        }

    C14 : coverpoint (!($stable(GIGABIT_STATS.qvl_frames_with_group_address_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_multicast_group_addresses = {1};
        type_option.comment = "Frames with multicast/group addresses";
        }

    C15 : coverpoint (!($stable(GIGABIT_STATS.qvl_frames_with_individual_address_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_individual_addresses = {1};
        type_option.comment = "Frames with individual addresses";
        }

    C16 : coverpoint (!($stable(GIGABIT_STATS.qvl_packets_with_pad_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Packets_with_padding = {1};
        type_option.comment = "Packets with padding";
        }

    C17 : coverpoint (!($stable(GIGABIT_STATS.qvl_align_column_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Align_ordered_sets = {1};
        type_option.comment = "Align ordered sets";
        }

    C18 : coverpoint (!($stable(GIGABIT_STATS.qvl_sync_column_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sync_ordered_sets = {1};
        type_option.comment = "Sync ordered sets";
        }

    C19 : coverpoint (!($stable(GIGABIT_STATS.qvl_skip_column_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Skip_ordered_sets = {1};
        type_option.comment = "Skip ordered sets";
        }
    
    C20 : coverpoint (!($stable(GIGABIT_STATS.qvl_min_size_untag_data_pkt_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_min_frame_size = {1};
        type_option.comment = "Packets of min_frame_size";
        }
    
    C21 : coverpoint (!($stable(GIGABIT_STATS.qvl_max_size_untag_data_pkt_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_max_frame_size = {1};
        type_option.comment = "Packets of max_frame_size";
        }

  endgroup : gigabit_ethernet_xaui_cornercases

  gigabit_ethernet_xaui_statistics  GIGABIT_ETHERNET_XAUI_STATISTICS = new();
  gigabit_ethernet_xaui_cornercases  GIGABIT_ETHERNET_XAUI_CORNERCASES = new();

  initial
    begin
      gigabit_ethernet_xaui_statistics::type_option.comment = "Statistics for GIGABIT_ETHERNET_XAUI Monitor";
      gigabit_ethernet_xaui_cornercases::type_option.comment = "Cornercases for GIGABIT_ETHERNET_XAUI Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for GIGABIT_ETHERNET_XAUI Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for GIGABIT_ETHERNET_XAUI Monitor -------------------------");

      $display("Total frames                                  : %0d", GIGABIT_STATS.qvl_total_frames_count);
      $display("Frames with length between 1518 and 1536      : %0d", GIGABIT_STATS.qvl_invalid_frame_length_count);

      $display("------------------- Cornercases for GIGABIT_ETHERNET_XAUI Monitor -------------------------");

      $display("Data frames                                   : %0d", GIGABIT_STATS.qvl_data_frames_count);
      $display("Control frames                                : %0d", GIGABIT_STATS.qvl_ctrl_frames_count);
      $display("Jumbo data frames                             : %0d", GIGABIT_STATS.qvl_jumbo_frames_count);
      $display("Untagged data frames                          : %0d", GIGABIT_STATS.qvl_untagged_data_frames_count);
      $display("VLAN tagged data frames                       : %0d", GIGABIT_STATS.qvl_vlan_tagged_data_frames_count);
      $display("Priority tagged data frames                   : %0d", GIGABIT_STATS.qvl_priority_tagged_data_frames_count);
      $display("Untagged pause control frames                 : %0d", GIGABIT_STATS.qvl_untagged_pause_frames_count);
      $display("VLAN tagged pause control frames              : %0d", GIGABIT_STATS.qvl_vlan_tagged_pause_frames_count);
      $display("Priority tagged pause control frames          : %0d", GIGABIT_STATS.qvl_priority_tagged_pause_frames_count);
      $display("Untagged jumbo frames                         : %0d", GIGABIT_STATS.qvl_untagged_jumbo_frames_count);
      $display("VLAN tagged jumbo frames                      : %0d", GIGABIT_STATS.qvl_vlan_tagged_jumbo_frames_count);
      $display("Priority tagged jumbo frames                  : %0d", GIGABIT_STATS.qvl_priority_tagged_jumbo_frames_count);
      $display("Frames with globally administered addresses   : %0d", GIGABIT_STATS.qvl_frames_with_global_address_count);
      $display("Frames with locally administered addresses    : %0d", GIGABIT_STATS.qvl_frames_with_local_address_count);
      $display("Frames with multicast/group addresses         : %0d", GIGABIT_STATS.qvl_frames_with_group_address_count);
      $display("Frames with individual addresses              : %0d", GIGABIT_STATS.qvl_frames_with_individual_address_count);
      $display("Packets with padding                          : %0d", GIGABIT_STATS.qvl_packets_with_pad_count);
      $display("Align ordered sets                            : %0d", GIGABIT_STATS.qvl_align_column_count);
      $display("Sync ordered sets                             : %0d", GIGABIT_STATS.qvl_sync_column_count);
      $display("Skip ordered sets                             : %0d", GIGABIT_STATS.qvl_skip_column_count);
      $display("Packets of min_frame_size                     : %0d", GIGABIT_STATS.qvl_min_size_untag_data_pkt_count);
      $display("Packets of max_frame_size                     : %0d", GIGABIT_STATS.qvl_max_size_untag_data_pkt_count);
      $display("----------------------------------------------------------------------------------");
    end

`endif //ifdef QVL_MW_FINAL_COVER
`endif //ifdef QVL_COVER_ON
