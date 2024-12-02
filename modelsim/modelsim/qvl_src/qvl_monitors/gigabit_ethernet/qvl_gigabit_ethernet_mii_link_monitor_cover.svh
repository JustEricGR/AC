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

  covergroup gigabit_ethernet_mii_statistics @ (posedge clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for GIGABIT_ETHERNET_MII Monitor";

    S0 : coverpoint (!($stable(total_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Total_frames = {1};
        type_option.comment = "Total frames";
        }

    S1 : coverpoint (!($stable(invalid_frame_length_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_length_between_1518_and_1536 = {1};
        type_option.comment = "Frames with length between 1518 and 1536";
        }

  endgroup : gigabit_ethernet_mii_statistics


  covergroup gigabit_ethernet_mii_cornercases @ (posedge clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for GIGABIT_ETHERNET_mii Monitor";

    C0 : coverpoint (!($stable(data_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Data_frames = {1};
        type_option.comment = "Data frames";
        }

    C1 : coverpoint (!($stable(ctrl_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Control_frames = {1};
        type_option.comment = "Control frames";
        }

    C2 : coverpoint (!($stable(jumbo_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Jumbo_data_frames = {1};
        type_option.comment = "Jumbo data frames";
        }

    C3 : coverpoint (!($stable(untagged_data_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Untagged_data_frames = {1};
        type_option.comment = "Untagged data frames";
        }

    C4 : coverpoint (!($stable(vlan_tagged_data_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_data_frames = {1};
        type_option.comment = "VLAN tagged data frames";
        }

    C5 : coverpoint (!($stable(priority_tagged_data_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_data_frames = {1};
        type_option.comment = "Priority tagged data frames";
        }

    C6 : coverpoint (!($stable(untagged_pause_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Untagged_pause_control_frames = {1};
        type_option.comment = "Untagged pause control frames";
        }

    C7 : coverpoint (!($stable(vlan_tagged_pause_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_pause_control_frames = {1};
        type_option.comment = "VLAN tagged pause control frames";
        }

    C8 : coverpoint (!($stable(priority_tagged_pause_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_pause_control_frames = {1};
        type_option.comment = "Priority tagged pause control frames";
        }

    C9 : coverpoint (!($stable(untagged_jumbo_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Untagged_jumbo_frames = {1};
        type_option.comment = "Untagged jumbo frames";
        }

    C10 : coverpoint (!($stable(vlan_tagged_jumbo_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins VLAN_tagged_jumbo_frames = {1};
        type_option.comment = "VLAN tagged jumbo frames";
        }

    C11 : coverpoint (!($stable(priority_tagged_jumbo_frames_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Priority_tagged_jumbo_frames = {1};
        type_option.comment = "Priority tagged jumbo frames";
        }

    C12 : coverpoint (!($stable(frames_with_global_address_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_globally_administered_addresses = {1};
        type_option.comment = "Frames with globally administered addresses";
        }

    C13 : coverpoint (!($stable(frames_with_local_address_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_locally_administered_addresses = {1};
        type_option.comment = "Frames with locally administered addresses";
        }

    C14 : coverpoint (!($stable(frames_with_group_address_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_multicast_group_addresses = {1};
        type_option.comment = "Frames with multicast/group addresses";
        }

    C15 : coverpoint (!($stable(frames_with_individual_address_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Frames_with_individual_addresses = {1};
        type_option.comment = "Frames with individual addresses";
        }

    C16 : coverpoint (!($stable(packets_with_pad_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Packets_with_padding = {1};
        type_option.comment = "Packets with padding";
        }

    C17 : coverpoint (!($stable(collisions_statistics_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins MII_Collisions = {1};
        type_option.comment = "MII Collisions";
        }

    C18 : coverpoint (!($stable(false_carrier_statistics_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins MII_False_carriers = {1};
        type_option.comment = "MII False carriers";
        }

    C19 : coverpoint (!($stable(min_size_untag_data_pkt_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_min_frame_size = {1};
        type_option.comment = "Packets of min_frame_size";
        }


    C20 : coverpoint (!($stable(max_size_untag_data_pkt_count, @ (posedge clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_max_frame_size = {1};
        type_option.comment = "Packets of max_frame_size";
        }



  endgroup : gigabit_ethernet_mii_cornercases

  gigabit_ethernet_mii_statistics  GIGABIT_ETHERNET_MII_STATISTICS = new();
  gigabit_ethernet_mii_cornercases  GIGABIT_ETHERNET_MII_CORNERCASES = new();

  initial
    begin
      gigabit_ethernet_mii_statistics::type_option.comment = "Statistics for GIGABIT_ETHERNET_MII Monitor";
      gigabit_ethernet_mii_cornercases::type_option.comment = "Cornercases for GIGABIT_ETHERNET_MII Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for GIGABIT_ETHERNET_MII Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for GIGABIT_ETHERNET_MII Monitor -------------------------");

      $display("Total frames                                  : %0d", total_frames_count);
      $display("Frames with length between 1518 and 1536      : %0d", invalid_frame_length_count);

      $display("------------------- Cornercases for GIGABIT_ETHERNET_MII Monitor -------------------------");

      $display("Data frames                                   : %0d", data_frames_count);
      $display("Control frames                                : %0d", ctrl_frames_count);
      $display("Jumbo data frames                             : %0d", jumbo_frames_count);
      $display("Untagged data frames                          : %0d", untagged_data_frames_count);
      $display("VLAN tagged data frames                       : %0d", vlan_tagged_data_frames_count);
      $display("Priority tagged data frames                   : %0d", priority_tagged_data_frames_count);
      $display("Untagged pause control frames                 : %0d", untagged_pause_frames_count);
      $display("VLAN tagged pause control frames              : %0d", vlan_tagged_pause_frames_count);
      $display("Priority tagged pause control frames          : %0d", priority_tagged_pause_frames_count);
      $display("Untagged jumbo frames                         : %0d", untagged_jumbo_frames_count);
      $display("VLAN tagged jumbo frames                      : %0d", vlan_tagged_jumbo_frames_count);
      $display("Priority tagged jumbo frames                  : %0d", priority_tagged_jumbo_frames_count);
      $display("Frames with globally administered addresses   : %0d", frames_with_global_address_count);
      $display("Frames with locally administered addresses    : %0d", frames_with_local_address_count);
      $display("Frames with multicast/group addresses         : %0d", frames_with_group_address_count);
      $display("Frames with individual addresses              : %0d", frames_with_individual_address_count);
      $display("Packets with padding                          : %0d", packets_with_pad_count);
      $display("Collisions                                    : %0d", collisions_statistics_count);
      $display("False carriers                                : %0d", false_carrier_statistics_count);
      $display("Packets of min_frame_size                     : %0d", min_size_untag_data_pkt_count);
      $display("Packets of max_frame_size                     : %0d", max_size_untag_data_pkt_count);
      $display("----------------------------------------------------------------------------------");
    end
`endif  //ifdef QVL_MW_FINAL_COVER
`endif  // ifdef QVL_COVER_ON
