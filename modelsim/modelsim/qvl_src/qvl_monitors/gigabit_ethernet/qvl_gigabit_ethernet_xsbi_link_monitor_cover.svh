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

  //------------------------------------------------------------------------------
  //SV Covergroups start here
  //------------------------------------------------------------------------------

  covergroup gigabit_ethernet_xsbi_statistics @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for GIGABIT_ETHERNET_XSBI Monitor";

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

  endgroup : gigabit_ethernet_xsbi_statistics


  covergroup gigabit_ethernet_xsbi_cornercases @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for GIGABIT_ETHERNET_XSBI Monitor";

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

    C17 : coverpoint (!($stable(GIGABIT_STATS.qvl_valid_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Valid_66_bit_blocks = {1};
        type_option.comment = "Valid 66-bit blocks";
        }

    C18 : coverpoint (!($stable(GIGABIT_STATS.qvl_data_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Valid_66_bit_data_blocks = {1};
        type_option.comment = "Valid 66-bit data blocks";
        }

    C19 : coverpoint (!($stable(GIGABIT_STATS.qvl_control_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Valid_66_bit_control_blocks = {1};
        type_option.comment = "Valid 66-bit control blocks";
        }

    C20 : coverpoint (!($stable(GIGABIT_STATS.qvl_idle_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Idle_blocks = {1};
        type_option.comment = "Idle blocks";
        }

    C21 : coverpoint (!($stable(GIGABIT_STATS.qvl_error_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Error_blocks = {1};
        type_option.comment = "Error blocks";
        }

    C22 : coverpoint (!($stable(GIGABIT_STATS.qvl_s0_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Blocks_with_start_on_octet_0 = {1};
        type_option.comment = "Blocks with start on octet 0";
        }

    C23 : coverpoint (!($stable(GIGABIT_STATS.qvl_s4_block_with_idle_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Blocks_starting_on_octet_4_with_idle_on_first_four_octets = {1};
        type_option.comment = "Blocks starting on octet 4 with idle on first four octets";
        }

    C24 : coverpoint (!($stable(GIGABIT_STATS.qvl_s4_block_with_os_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Blocks_starting_on_octet_4_with_an_ordered_set_on_first_four_octets = {1};
        type_option.comment = "Blocks starting on octet 4 with an ordered set on first four octets";
        }

    C25 : coverpoint (!($stable(GIGABIT_STATS.qvl_t0_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_0 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 0";
        }

    C26 : coverpoint (!($stable(GIGABIT_STATS.qvl_t1_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_1 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 1";
        }

    C27 : coverpoint (!($stable(GIGABIT_STATS.qvl_t2_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_2 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 2";
        }

    C28 : coverpoint (!($stable(GIGABIT_STATS.qvl_t3_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_3 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 3";
        }

    C29 : coverpoint (!($stable(GIGABIT_STATS.qvl_t4_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_4 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 4";
        }

    C30 : coverpoint (!($stable(GIGABIT_STATS.qvl_t5_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_5 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 5";
        }

    C31 : coverpoint (!($stable(GIGABIT_STATS.qvl_t6_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_6 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 6";
        }

    C32 : coverpoint (!($stable(GIGABIT_STATS.qvl_t7_block_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Sixtysix_bit_blocks_with_terminate_on_octet_7 = {1};
        type_option.comment = "66-bit blocks with terminate on octet 7";
        }

    C33 : coverpoint (!($stable(GIGABIT_STATS.qvl_min_size_untag_data_pkt_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_min_frame_size = {1};
        type_option.comment = "Packets of min_frame_size";
        }

    C34 : coverpoint (!($stable(GIGABIT_STATS.qvl_max_size_untag_data_pkt_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Packets_of_max_frame_size = {1};
        type_option.comment = "Packets of max_frame_size";
        }

  endgroup : gigabit_ethernet_xsbi_cornercases

  gigabit_ethernet_xsbi_statistics  GIGABIT_ETHERNET_XSBI_STATISTICS = new();
  gigabit_ethernet_xsbi_cornercases  GIGABIT_ETHERNET_XSBI_CORNERCASES = new();

  initial
    begin
      gigabit_ethernet_xsbi_statistics::type_option.comment = "Statistics for GIGABIT_ETHERNET_XSBI Monitor";
      gigabit_ethernet_xsbi_cornercases::type_option.comment = "Cornercases for GIGABIT_ETHERNET_XSBI Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for GIGABIT_ETHERNET_XSBI Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for GIGABIT_ETHERNET_XSBI Monitor -------------------------");

      $display("Total frames                                  : %0d", GIGABIT_STATS.qvl_total_frames_count);
      $display("Frames with length between 1518 and 1536      : %0d", GIGABIT_STATS.qvl_invalid_frame_length_count);

      $display("------------------- Cornercases for GIGABIT_ETHERNET_XSBI Monitor -------------------------");

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
      $display("Valid 66-bit blocks                           : %0d", GIGABIT_STATS.qvl_valid_block_count);
      $display("Valid 66-bit data blocks                      : %0d", GIGABIT_STATS.qvl_data_block_count);
      $display("Valid 66-bit control blocks                   : %0d", GIGABIT_STATS.qvl_control_block_count);
      $display("Idle blocks                                   : %0d", GIGABIT_STATS.qvl_idle_block_count);
      $display("Error blocks                                  : %0d", GIGABIT_STATS.qvl_error_block_count);
      $display("Blocks with start on octet 0                  : %0d", GIGABIT_STATS.qvl_s0_block_count);
      $display("Blocks starting on octet 4 with idle on first : %0d", GIGABIT_STATS.qvl_s4_block_with_idle_count);
      $display("Blocks starting on octet 4 with an ordered se : %0d", GIGABIT_STATS.qvl_s4_block_with_os_count);
      $display("66-bit blocks with terminate on octet 0       : %0d", GIGABIT_STATS.qvl_t0_block_count);
      $display("66-bit blocks with terminate on octet 1       : %0d", GIGABIT_STATS.qvl_t1_block_count);
      $display("66-bit blocks with terminate on octet 2       : %0d", GIGABIT_STATS.qvl_t2_block_count);
      $display("66-bit blocks with terminate on octet 3       : %0d", GIGABIT_STATS.qvl_t3_block_count);
      $display("66-bit blocks with terminate on octet 4       : %0d", GIGABIT_STATS.qvl_t4_block_count);
      $display("66-bit blocks with terminate on octet 5       : %0d", GIGABIT_STATS.qvl_t5_block_count);
      $display("66-bit blocks with terminate on octet 6       : %0d", GIGABIT_STATS.qvl_t6_block_count);
      $display("66-bit blocks with terminate on octet 7       : %0d", GIGABIT_STATS.qvl_t7_block_count);
      $display("Packets of min_frame_size                     : %0d", GIGABIT_STATS.qvl_min_size_untag_data_pkt_count);
      $display("Packets of max_frame_size                     : %0d", GIGABIT_STATS.qvl_max_size_untag_data_pkt_count);
      $display("----------------------------------------------------------------------------------");
    end

`endif //ifdef QVL_MW_FINAL_COVER
`endif //ifdef QVL_COVER_ON
