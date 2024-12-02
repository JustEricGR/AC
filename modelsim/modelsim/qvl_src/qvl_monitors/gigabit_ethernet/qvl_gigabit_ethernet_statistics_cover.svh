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
  reg [63:0] qvl_total_frames_count_posedge;
  reg [63:0] qvl_data_frames_count_posedge;
  reg [63:0] qvl_ctrl_frames_count_posedge;
  reg [63:0] qvl_jumbo_frames_count_posedge;
  reg [63:0] qvl_untagged_data_frames_count_posedge;
  reg [63:0] qvl_vlan_tagged_data_frames_count_posedge;
  reg [63:0] qvl_priority_tagged_data_frames_count_posedge;
  reg [63:0] qvl_untagged_pause_frames_count_posedge;
  reg [63:0] qvl_vlan_tagged_pause_frames_count_posedge;
  reg [63:0] qvl_priority_tagged_pause_frames_count_posedge;
  reg [63:0] qvl_untagged_jumbo_frames_count_posedge;
  reg [63:0] qvl_vlan_tagged_jumbo_frames_count_posedge;
  reg [63:0] qvl_priority_tagged_jumbo_frames_count_posedge;
  reg [63:0] qvl_frames_with_global_address_count_posedge;
  reg [63:0] qvl_frames_with_local_address_count_posedge;
  reg [63:0] qvl_frames_with_group_address_count_posedge;
  reg [63:0] qvl_frames_with_individual_address_count_posedge;
  reg [63:0] qvl_min_size_untag_data_pkt_count_posedge;
  reg [63:0] qvl_max_size_untag_data_pkt_count_posedge;
  reg [63:0] qvl_packets_with_pad_count_posedge;
  reg [63:0] qvl_remote_faults_count_posedge;
  reg [63:0] qvl_local_faults_count_posedge;
  reg [63:0] qvl_lane0_termnates_count_posedge;
  reg [63:0] qvl_lane1_termnates_count_posedge;
  reg [63:0] qvl_lane2_termnates_count_posedge;
  reg [63:0] qvl_lane3_termnates_count_posedge;
  reg [63:0] qvl_align_column_count_posedge;
  reg [63:0] qvl_sync_column_count_posedge;
  reg [63:0] qvl_skip_column_count_posedge;
  reg [63:0] qvl_valid_block_count_posedge;
  reg [63:0] qvl_data_block_count_posedge;
  reg [63:0] qvl_control_block_count_posedge;
  reg [63:0] qvl_idle_block_count_posedge;
  reg [63:0] qvl_error_block_count_posedge;
  reg [63:0] qvl_s0_block_count_posedge;
  reg [63:0] qvl_s4_block_with_idle_count_posedge;
  reg [63:0] qvl_s4_block_with_os_count_posedge;
  reg [63:0] qvl_t0_block_count_posedge;
  reg [63:0] qvl_t1_block_count_posedge;
  reg [63:0] qvl_t2_block_count_posedge;
  reg [63:0] qvl_t3_block_count_posedge;
  reg [63:0] qvl_t4_block_count_posedge;
  reg [63:0] qvl_t5_block_count_posedge;
  reg [63:0] qvl_t6_block_count_posedge;
  reg [63:0] qvl_t7_block_count_posedge;

  reg [63:0] qvl_total_frames_count_negedge;
  reg [63:0] qvl_data_frames_count_negedge;
  reg [63:0] qvl_ctrl_frames_count_negedge;
  reg [63:0] qvl_jumbo_frames_count_negedge;
  reg [63:0] qvl_untagged_data_frames_count_negedge;
  reg [63:0] qvl_vlan_tagged_data_frames_count_negedge;
  reg [63:0] qvl_priority_tagged_data_frames_count_negedge;
  reg [63:0] qvl_untagged_pause_frames_count_negedge;
  reg [63:0] qvl_vlan_tagged_pause_frames_count_negedge;
  reg [63:0] qvl_priority_tagged_pause_frames_count_negedge;
  reg [63:0] qvl_untagged_jumbo_frames_count_negedge;
  reg [63:0] qvl_vlan_tagged_jumbo_frames_count_negedge;
  reg [63:0] qvl_priority_tagged_jumbo_frames_count_negedge;
  reg [63:0] qvl_frames_with_global_address_count_negedge;
  reg [63:0] qvl_frames_with_local_address_count_negedge;
  reg [63:0] qvl_frames_with_group_address_count_negedge;
  reg [63:0] qvl_frames_with_individual_address_count_negedge;
  reg [63:0] qvl_min_size_untag_data_pkt_count_negedge;
  reg [63:0] qvl_max_size_untag_data_pkt_count_negedge;
  reg [63:0] qvl_packets_with_pad_count_negedge;
  reg [63:0] qvl_remote_faults_count_negedge;
  reg [63:0] qvl_local_faults_count_negedge;
  reg [63:0] qvl_lane0_termnates_count_negedge;
  reg [63:0] qvl_lane1_termnates_count_negedge;
  reg [63:0] qvl_lane2_termnates_count_negedge;
  reg [63:0] qvl_lane3_termnates_count_negedge;
  reg [63:0] qvl_align_column_count_negedge;
  reg [63:0] qvl_sync_column_count_negedge;
  reg [63:0] qvl_skip_column_count_negedge;
  reg [63:0] qvl_valid_block_count_negedge;
  reg [63:0] qvl_data_block_count_negedge;
  reg [63:0] qvl_control_block_count_negedge;
  reg [63:0] qvl_idle_block_count_negedge;
  reg [63:0] qvl_error_block_count_negedge;
  reg [63:0] qvl_s0_block_count_negedge;
  reg [63:0] qvl_s4_block_with_idle_count_negedge;
  reg [63:0] qvl_s4_block_with_os_count_negedge;
  reg [63:0] qvl_t0_block_count_negedge;
  reg [63:0] qvl_t1_block_count_negedge;
  reg [63:0] qvl_t2_block_count_negedge;
  reg [63:0] qvl_t3_block_count_negedge;
  reg [63:0] qvl_t4_block_count_negedge;
  reg [63:0] qvl_t5_block_count_negedge;
  reg [63:0] qvl_t6_block_count_negedge;
  reg [63:0] qvl_t7_block_count_negedge;

  wire [63:0] qvl_total_frames_count = (level_select === 1'b1) ?
       qvl_total_frames_count_posedge :
       qvl_total_frames_count_negedge;
  wire [63:0] qvl_data_frames_count = (level_select === 1'b1) ?
       qvl_data_frames_count_posedge :
       qvl_data_frames_count_negedge;
  wire [63:0] qvl_ctrl_frames_count = (level_select === 1'b1) ?
       qvl_ctrl_frames_count_posedge :
       qvl_ctrl_frames_count_negedge;
  wire [63:0] qvl_jumbo_frames_count = (level_select === 1'b1) ?
       qvl_jumbo_frames_count_posedge :
       qvl_jumbo_frames_count_negedge;
  wire [63:0] qvl_untagged_data_frames_count = (level_select === 1'b1) ?
       qvl_untagged_data_frames_count_posedge :
       qvl_untagged_data_frames_count_negedge;
  wire [63:0] qvl_vlan_tagged_data_frames_count = (level_select === 1'b1) ?
       qvl_vlan_tagged_data_frames_count_posedge :
       qvl_vlan_tagged_data_frames_count_negedge;
  wire [63:0] qvl_priority_tagged_data_frames_count = (level_select === 1'b1) ?
       qvl_priority_tagged_data_frames_count_posedge :
       qvl_priority_tagged_data_frames_count_negedge;
  wire [63:0] qvl_untagged_pause_frames_count = (level_select === 1'b1) ?
       qvl_untagged_pause_frames_count_posedge :
       qvl_untagged_pause_frames_count_negedge;
  wire [63:0] qvl_vlan_tagged_pause_frames_count = (level_select === 1'b1) ?
       qvl_vlan_tagged_pause_frames_count_posedge :
       qvl_vlan_tagged_pause_frames_count_negedge;
  wire [63:0] qvl_priority_tagged_pause_frames_count = (level_select === 1'b1) ?
       qvl_priority_tagged_pause_frames_count_posedge :
       qvl_priority_tagged_pause_frames_count_negedge;
  wire [63:0] qvl_untagged_jumbo_frames_count = (level_select === 1'b1) ?
       qvl_untagged_jumbo_frames_count_posedge :
       qvl_untagged_jumbo_frames_count_negedge;
  wire [63:0] qvl_vlan_tagged_jumbo_frames_count = (level_select === 1'b1) ?
       qvl_vlan_tagged_jumbo_frames_count_posedge :
       qvl_vlan_tagged_jumbo_frames_count_negedge;
  wire [63:0] qvl_priority_tagged_jumbo_frames_count = (level_select === 1'b1) ?
       qvl_priority_tagged_jumbo_frames_count_posedge :
       qvl_priority_tagged_jumbo_frames_count_negedge;
  wire [63:0] qvl_frames_with_global_address_count = (level_select === 1'b1) ?
       qvl_frames_with_global_address_count_posedge :
       qvl_frames_with_global_address_count_negedge;
  wire [63:0] qvl_frames_with_local_address_count = (level_select === 1'b1) ?
       qvl_frames_with_local_address_count_posedge :
       qvl_frames_with_local_address_count_negedge;
  wire [63:0] qvl_frames_with_group_address_count = (level_select === 1'b1) ?
       qvl_frames_with_group_address_count_posedge :
       qvl_frames_with_group_address_count_negedge;
  wire [63:0] qvl_frames_with_individual_address_count = (level_select===1'b1) ?
       qvl_frames_with_individual_address_count_posedge :
       qvl_frames_with_individual_address_count_negedge;
  wire [63:0] qvl_min_size_untag_data_pkt_count = (level_select === 1'b1) ?
       qvl_min_size_untag_data_pkt_count_posedge :
       qvl_min_size_untag_data_pkt_count_negedge;
  wire [63:0] qvl_max_size_untag_data_pkt_count = (level_select === 1'b1) ?
       qvl_max_size_untag_data_pkt_count_posedge :
       qvl_max_size_untag_data_pkt_count_negedge;
  wire [63:0] qvl_packets_with_pad_count = (level_select === 1'b1) ?
       qvl_packets_with_pad_count_posedge :
       qvl_packets_with_pad_count_negedge;
  wire [63:0] qvl_remote_faults_count = (level_select === 1'b1) ?
       qvl_remote_faults_count_posedge :
       qvl_remote_faults_count_negedge;
  wire [63:0] qvl_local_faults_count = (level_select === 1'b1) ?
       qvl_local_faults_count_posedge :
       qvl_local_faults_count_negedge;
  wire [63:0] qvl_lane0_termnates_count = (level_select === 1'b1) ?
       qvl_lane0_termnates_count_posedge :
       qvl_lane0_termnates_count_negedge;
  wire [63:0] qvl_lane1_termnates_count = (level_select === 1'b1) ?
       qvl_lane1_termnates_count_posedge :
       qvl_lane1_termnates_count_negedge;
  wire [63:0] qvl_lane2_termnates_count = (level_select === 1'b1) ?
       qvl_lane2_termnates_count_posedge :
       qvl_lane2_termnates_count_negedge;
  wire [63:0] qvl_lane3_termnates_count = (level_select === 1'b1) ?
       qvl_lane3_termnates_count_posedge :
       qvl_lane3_termnates_count_negedge;
  wire [63:0] qvl_align_column_count = (level_select === 1'b1) ?
       qvl_align_column_count_posedge :
       qvl_align_column_count_negedge;
  wire [63:0] qvl_sync_column_count = (level_select === 1'b1) ?
       qvl_sync_column_count_posedge :
       qvl_sync_column_count_negedge;
  wire [63:0] qvl_skip_column_count = (level_select === 1'b1) ?
       qvl_skip_column_count_posedge :
       qvl_skip_column_count_negedge;
  wire [63:0] qvl_valid_block_count = (level_select === 1'b1) ?
       qvl_valid_block_count_posedge :
       qvl_valid_block_count_negedge;
  wire [63:0] qvl_data_block_count = (level_select === 1'b1) ?
       qvl_data_block_count_posedge :
       qvl_data_block_count_negedge;
  wire [63:0] qvl_control_block_count = (level_select === 1'b1) ?
       qvl_control_block_count_posedge :
       qvl_control_block_count_negedge;
  wire [63:0] qvl_idle_block_count = (level_select === 1'b1) ?
       qvl_idle_block_count_posedge :
       qvl_idle_block_count_negedge;
  wire [63:0] qvl_error_block_count = (level_select === 1'b1) ?
       qvl_error_block_count_posedge :
       qvl_error_block_count_negedge;
  wire [63:0] qvl_s0_block_count = (level_select === 1'b1) ?
       qvl_s0_block_count_posedge :
       qvl_s0_block_count_negedge;
  wire [63:0] qvl_s4_block_with_idle_count = (level_select === 1'b1) ?
       qvl_s4_block_with_idle_count_posedge :
       qvl_s4_block_with_idle_count_negedge;
  wire [63:0] qvl_s4_block_with_os_count = (level_select === 1'b1) ?
       qvl_s4_block_with_os_count_posedge :
       qvl_s4_block_with_os_count_negedge;
  wire [63:0] qvl_t0_block_count = (level_select === 1'b1) ?
       qvl_t0_block_count_posedge :
       qvl_t0_block_count_negedge;
  wire [63:0] qvl_t1_block_count = (level_select === 1'b1) ?
       qvl_t1_block_count_posedge :
       qvl_t1_block_count_negedge;
  wire [63:0] qvl_t2_block_count = (level_select === 1'b1) ?
       qvl_t2_block_count_posedge :
       qvl_t2_block_count_negedge;
  wire [63:0] qvl_t3_block_count = (level_select === 1'b1) ?
       qvl_t3_block_count_posedge :
       qvl_t3_block_count_negedge;
  wire [63:0] qvl_t4_block_count = (level_select === 1'b1) ?
       qvl_t4_block_count_posedge :
       qvl_t4_block_count_negedge;
  wire [63:0] qvl_t5_block_count = (level_select === 1'b1) ?
       qvl_t5_block_count_posedge :
       qvl_t5_block_count_negedge;
  wire [63:0] qvl_t6_block_count = (level_select === 1'b1) ?
       qvl_t6_block_count_posedge :
       qvl_t6_block_count_negedge;
  wire [63:0] qvl_t7_block_count = (level_select === 1'b1) ?
       qvl_t7_block_count_posedge :
       qvl_t7_block_count_negedge;
  wire [63:0] qvl_invalid_frame_length_count = invalid_frame_length_count;
  wire [63:0] qvl_collisions_count = collisions_statistics_count;
  wire [63:0] qvl_false_carrier_count = false_carrier_statistics_count;
  wire [63:0] qvl_carrier_extn_count = carrier_extn_statistics_count;
  wire [63:0] qvl_back_to_back_frames_count = back_to_back_frames_statistics_count;

  initial
    begin
      qvl_total_frames_count_posedge = 64'b0;
      qvl_data_frames_count_posedge = 64'b0;
      qvl_ctrl_frames_count_posedge = 64'b0;
      qvl_jumbo_frames_count_posedge = 64'b0;
      qvl_untagged_data_frames_count_posedge = 64'b0;
      qvl_vlan_tagged_data_frames_count_posedge = 64'b0;
      qvl_priority_tagged_data_frames_count_posedge = 64'b0;
      qvl_untagged_pause_frames_count_posedge = 64'b0;
      qvl_vlan_tagged_pause_frames_count_posedge = 64'b0;
      qvl_priority_tagged_pause_frames_count_posedge = 64'b0;
      qvl_untagged_jumbo_frames_count_posedge = 64'b0;
      qvl_vlan_tagged_jumbo_frames_count_posedge = 64'b0;
      qvl_priority_tagged_jumbo_frames_count_posedge = 64'b0;
      qvl_frames_with_global_address_count_posedge = 64'b0;
      qvl_frames_with_local_address_count_posedge = 64'b0;
      qvl_frames_with_group_address_count_posedge = 64'b0;
      qvl_frames_with_individual_address_count_posedge = 64'b0;
      qvl_min_size_untag_data_pkt_count_posedge = 64'b0;
      qvl_max_size_untag_data_pkt_count_posedge = 64'b0;
      qvl_packets_with_pad_count_posedge = 64'b0;
      qvl_remote_faults_count_posedge = 64'b0;
      qvl_local_faults_count_posedge = 64'b0;
      qvl_lane0_termnates_count_posedge = 64'b0;
      qvl_lane1_termnates_count_posedge = 64'b0;
      qvl_lane2_termnates_count_posedge = 64'b0;
      qvl_lane3_termnates_count_posedge = 64'b0;
      qvl_align_column_count_posedge = 64'b0;
      qvl_sync_column_count_posedge = 64'b0;
      qvl_skip_column_count_posedge = 64'b0;
      qvl_valid_block_count_posedge = 64'b0;
      qvl_data_block_count_posedge = 64'b0;
      qvl_control_block_count_posedge = 64'b0;
      qvl_idle_block_count_posedge = 64'b0;
      qvl_error_block_count_posedge = 64'b0;
      qvl_s0_block_count_posedge = 64'b0;
      qvl_s4_block_with_idle_count_posedge = 64'b0;
      qvl_s4_block_with_os_count_posedge = 64'b0;
      qvl_t0_block_count_posedge = 64'b0;
      qvl_t1_block_count_posedge = 64'b0;
      qvl_t2_block_count_posedge = 64'b0;
      qvl_t3_block_count_posedge = 64'b0;
      qvl_t4_block_count_posedge = 64'b0;
      qvl_t5_block_count_posedge = 64'b0;
      qvl_t6_block_count_posedge = 64'b0;
      qvl_t7_block_count_posedge = 64'b0;

      qvl_total_frames_count_negedge = 64'b0;
      qvl_data_frames_count_negedge = 64'b0;
      qvl_ctrl_frames_count_negedge = 64'b0;
      qvl_jumbo_frames_count_negedge = 64'b0;
      qvl_untagged_data_frames_count_negedge = 64'b0;
      qvl_vlan_tagged_data_frames_count_negedge = 64'b0;
      qvl_priority_tagged_data_frames_count_negedge = 64'b0;
      qvl_untagged_pause_frames_count_negedge = 64'b0;
      qvl_vlan_tagged_pause_frames_count_negedge = 64'b0;
      qvl_priority_tagged_pause_frames_count_negedge = 64'b0;
      qvl_untagged_jumbo_frames_count_negedge = 64'b0;
      qvl_vlan_tagged_jumbo_frames_count_negedge = 64'b0;
      qvl_priority_tagged_jumbo_frames_count_negedge = 64'b0;
      qvl_frames_with_global_address_count_negedge = 64'b0;
      qvl_frames_with_local_address_count_negedge = 64'b0;
      qvl_frames_with_group_address_count_negedge = 64'b0;
      qvl_frames_with_individual_address_count_negedge = 64'b0;
      qvl_min_size_untag_data_pkt_count_negedge = 64'b0;
      qvl_max_size_untag_data_pkt_count_negedge = 64'b0;
      qvl_packets_with_pad_count_negedge = 64'b0;
      qvl_remote_faults_count_negedge = 64'b0;
      qvl_local_faults_count_negedge = 64'b0;
      qvl_lane0_termnates_count_negedge = 64'b0;
      qvl_lane1_termnates_count_negedge = 64'b0;
      qvl_lane2_termnates_count_negedge = 64'b0;
      qvl_lane3_termnates_count_negedge = 64'b0;
      qvl_align_column_count_negedge = 64'b0;
      qvl_sync_column_count_negedge = 64'b0;
      qvl_skip_column_count_negedge = 64'b0;
      qvl_valid_block_count_negedge = 64'b0;
      qvl_data_block_count_negedge = 64'b0;
      qvl_control_block_count_negedge = 64'b0;
      qvl_idle_block_count_negedge = 64'b0;
      qvl_error_block_count_negedge = 64'b0;
      qvl_s0_block_count_negedge = 64'b0;
      qvl_s4_block_with_idle_count_negedge = 64'b0;
      qvl_s4_block_with_os_count_negedge = 64'b0;
      qvl_t0_block_count_negedge = 64'b0;
      qvl_t1_block_count_negedge = 64'b0;
      qvl_t2_block_count_negedge = 64'b0;
      qvl_t3_block_count_negedge = 64'b0;
      qvl_t4_block_count_negedge = 64'b0;
      qvl_t5_block_count_negedge = 64'b0;
      qvl_t6_block_count_negedge = 64'b0;
      qvl_t7_block_count_negedge = 64'b0;
    end

  always @ (posedge clk)
    begin
      if (areset === 1'b0 && reset === 1'b0 && collect_stats === 1'b1)
        begin
          qvl_total_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_total_frames_count +
            inc_total_frames_count;
          qvl_data_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_data_frames_count +
            inc_data_frames_count;
          qvl_ctrl_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_ctrl_frames_count +
            inc_ctrl_frames_count;
          qvl_jumbo_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_jumbo_frames_count +
            inc_jumbo_frames_count;
          qvl_untagged_data_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_untagged_data_frames_count +
            inc_untagged_data_frames_count;
          qvl_vlan_tagged_data_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_data_frames_count +
            inc_vlan_tagged_data_frames_count;
          qvl_priority_tagged_data_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_data_frames_count +
            inc_priority_tagged_data_frames_count;
          qvl_untagged_pause_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_untagged_pause_frames_count +
            inc_untagged_pause_frames_count;
          qvl_vlan_tagged_pause_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_pause_frames_count +
            inc_vlan_tagged_pause_frames_count;
          qvl_priority_tagged_pause_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_pause_frames_count +
            inc_priority_tagged_pause_frames_count;
          qvl_untagged_jumbo_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_untagged_jumbo_frames_count +
            inc_untagged_jumbo_frames_count;
          qvl_vlan_tagged_jumbo_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_jumbo_frames_count +
            inc_vlan_tagged_jumbo_frames_count;
          qvl_priority_tagged_jumbo_frames_count_posedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_jumbo_frames_count +
            inc_priority_tagged_jumbo_frames_count;
          qvl_frames_with_global_address_count_posedge <= `ZiCwDebugDelay1
            qvl_frames_with_global_address_count +
            inc_frames_with_global_address_count;
          qvl_frames_with_local_address_count_posedge <= `ZiCwDebugDelay1
            qvl_frames_with_local_address_count +
            inc_frames_with_local_address_count;
          qvl_frames_with_group_address_count_posedge <= `ZiCwDebugDelay1
            qvl_frames_with_group_address_count +
            inc_frames_with_group_address_count;
          qvl_frames_with_individual_address_count_posedge <= `ZiCwDebugDelay1
            qvl_frames_with_individual_address_count +
            inc_frames_with_individual_address_count;
          qvl_min_size_untag_data_pkt_count_posedge <= `ZiCwDebugDelay1
            qvl_min_size_untag_data_pkt_count +
            inc_min_size_untag_data_pkt_count;
          qvl_max_size_untag_data_pkt_count_posedge <= `ZiCwDebugDelay1
            qvl_max_size_untag_data_pkt_count +
            inc_max_size_untag_data_pkt_count;
          qvl_packets_with_pad_count_posedge <= `ZiCwDebugDelay1
            qvl_packets_with_pad_count +
            inc_packets_with_pad_count;
          qvl_remote_faults_count_posedge <= `ZiCwDebugDelay1
            qvl_remote_faults_count +
            inc_remote_faults_count;
          qvl_local_faults_count_posedge <= `ZiCwDebugDelay1
            qvl_local_faults_count +
            inc_local_faults_count;
          qvl_lane0_termnates_count_posedge <= `ZiCwDebugDelay1
            qvl_lane0_termnates_count +
            inc_lane0_termnates_count;
          qvl_lane1_termnates_count_posedge <= `ZiCwDebugDelay1
            qvl_lane1_termnates_count +
            inc_lane1_termnates_count;
          qvl_lane2_termnates_count_posedge <= `ZiCwDebugDelay1
            qvl_lane2_termnates_count +
            inc_lane2_termnates_count;
          qvl_lane3_termnates_count_posedge <= `ZiCwDebugDelay1
            qvl_lane3_termnates_count +
            inc_lane3_termnates_count;
          qvl_align_column_count_posedge <= `ZiCwDebugDelay1
            qvl_align_column_count +
            inc_align_column_count;
          qvl_sync_column_count_posedge <= `ZiCwDebugDelay1
            qvl_sync_column_count +
            inc_sync_column_count;
          qvl_skip_column_count_posedge <= `ZiCwDebugDelay1
            qvl_skip_column_count +
            inc_skip_column_count;
          qvl_valid_block_count_posedge <= `ZiCwDebugDelay1
            qvl_valid_block_count +
            inc_valid_block_count;
          qvl_data_block_count_posedge <= `ZiCwDebugDelay1
            qvl_data_block_count +
            inc_data_block_count;
          qvl_control_block_count_posedge <= `ZiCwDebugDelay1
            qvl_control_block_count +
            inc_control_block_count;
          qvl_idle_block_count_posedge <= `ZiCwDebugDelay1
            qvl_idle_block_count +
            inc_idle_block_count;
          qvl_error_block_count_posedge <= `ZiCwDebugDelay1
            qvl_error_block_count +
            inc_error_block_count;
          qvl_s0_block_count_posedge <= `ZiCwDebugDelay1
            qvl_s0_block_count +
            inc_s0_block_count;
          qvl_s4_block_with_idle_count_posedge <= `ZiCwDebugDelay1
            qvl_s4_block_with_idle_count +
            inc_s4_block_with_idle_count;
          qvl_s4_block_with_os_count_posedge <= `ZiCwDebugDelay1
            qvl_s4_block_with_os_count +
            inc_s4_block_with_os_count;
          qvl_t0_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t0_block_count +
            inc_t0_block_count;
          qvl_t1_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t1_block_count +
            inc_t1_block_count;
          qvl_t2_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t2_block_count +
            inc_t2_block_count;
          qvl_t3_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t3_block_count +
            inc_t3_block_count;
          qvl_t4_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t4_block_count +
            inc_t4_block_count;
          qvl_t5_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t5_block_count +
            inc_t5_block_count;
          qvl_t6_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t6_block_count +
            inc_t6_block_count;
          qvl_t7_block_count_posedge <= `ZiCwDebugDelay1
            qvl_t7_block_count +
            inc_t7_block_count;
        end
    end

  always @ (negedge clk)
    begin
      if (areset === 1'b0 && reset === 1'b0 && collect_stats === 1'b1 &&
          DDR === 1)
        begin
          qvl_total_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_total_frames_count +
            inc_total_frames_count;
          qvl_data_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_data_frames_count +
            inc_data_frames_count;
          qvl_ctrl_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_ctrl_frames_count +
            inc_ctrl_frames_count;
          qvl_jumbo_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_jumbo_frames_count +
            inc_jumbo_frames_count;
          qvl_untagged_data_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_untagged_data_frames_count +
            inc_untagged_data_frames_count;
          qvl_vlan_tagged_data_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_data_frames_count +
            inc_vlan_tagged_data_frames_count;
          qvl_priority_tagged_data_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_data_frames_count +
            inc_priority_tagged_data_frames_count;
          qvl_untagged_pause_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_untagged_pause_frames_count +
            inc_untagged_pause_frames_count;
          qvl_vlan_tagged_pause_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_pause_frames_count +
            inc_vlan_tagged_pause_frames_count;
          qvl_priority_tagged_pause_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_pause_frames_count +
            inc_priority_tagged_pause_frames_count;
          qvl_untagged_jumbo_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_untagged_jumbo_frames_count +
            inc_untagged_jumbo_frames_count;
          qvl_vlan_tagged_jumbo_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_vlan_tagged_jumbo_frames_count +
            inc_vlan_tagged_jumbo_frames_count;
          qvl_priority_tagged_jumbo_frames_count_negedge <= `ZiCwDebugDelay1
            qvl_priority_tagged_jumbo_frames_count +
            inc_priority_tagged_jumbo_frames_count;
          qvl_frames_with_global_address_count_negedge <= `ZiCwDebugDelay1
            qvl_frames_with_global_address_count +
            inc_frames_with_global_address_count;
          qvl_frames_with_local_address_count_negedge <= `ZiCwDebugDelay1
            qvl_frames_with_local_address_count +
            inc_frames_with_local_address_count;
          qvl_frames_with_group_address_count_negedge <= `ZiCwDebugDelay1
            qvl_frames_with_group_address_count +
            inc_frames_with_group_address_count;
          qvl_frames_with_individual_address_count_negedge <= `ZiCwDebugDelay1
            qvl_frames_with_individual_address_count +
            inc_frames_with_individual_address_count;
          qvl_min_size_untag_data_pkt_count_negedge <= `ZiCwDebugDelay1
            qvl_min_size_untag_data_pkt_count +
            inc_min_size_untag_data_pkt_count;
          qvl_max_size_untag_data_pkt_count_negedge <= `ZiCwDebugDelay1
            qvl_max_size_untag_data_pkt_count +
            inc_max_size_untag_data_pkt_count;
          qvl_packets_with_pad_count_negedge <= `ZiCwDebugDelay1
            qvl_packets_with_pad_count +
            inc_packets_with_pad_count;
          qvl_remote_faults_count_negedge <= `ZiCwDebugDelay1
            qvl_remote_faults_count +
            inc_remote_faults_count;
          qvl_local_faults_count_negedge <= `ZiCwDebugDelay1
            qvl_local_faults_count +
            inc_local_faults_count;
          qvl_lane0_termnates_count_negedge <= `ZiCwDebugDelay1
            qvl_lane0_termnates_count +
            inc_lane0_termnates_count;
          qvl_lane1_termnates_count_negedge <= `ZiCwDebugDelay1
            qvl_lane1_termnates_count +
            inc_lane1_termnates_count;
          qvl_lane2_termnates_count_negedge <= `ZiCwDebugDelay1
            qvl_lane2_termnates_count +
            inc_lane2_termnates_count;
          qvl_lane3_termnates_count_negedge <= `ZiCwDebugDelay1
            qvl_lane3_termnates_count +
            inc_lane3_termnates_count;
          qvl_align_column_count_negedge <= `ZiCwDebugDelay1
            qvl_align_column_count +
            inc_align_column_count;
          qvl_sync_column_count_negedge <= `ZiCwDebugDelay1
            qvl_sync_column_count +
            inc_sync_column_count;
          qvl_skip_column_count_negedge <= `ZiCwDebugDelay1
            qvl_skip_column_count +
            inc_skip_column_count;
          qvl_valid_block_count_negedge <= `ZiCwDebugDelay1
            qvl_valid_block_count +
            inc_valid_block_count;
          qvl_data_block_count_negedge <= `ZiCwDebugDelay1
            qvl_data_block_count +
            inc_data_block_count;
          qvl_control_block_count_negedge <= `ZiCwDebugDelay1
            qvl_control_block_count +
            inc_control_block_count;
          qvl_idle_block_count_negedge <= `ZiCwDebugDelay1
            qvl_idle_block_count +
            inc_idle_block_count;
          qvl_error_block_count_negedge <= `ZiCwDebugDelay1
            qvl_error_block_count +
            inc_error_block_count;
          qvl_s0_block_count_negedge <= `ZiCwDebugDelay1
            qvl_s0_block_count +
            inc_s0_block_count;
          qvl_s4_block_with_idle_count_negedge <= `ZiCwDebugDelay1
            qvl_s4_block_with_idle_count +
            inc_s4_block_with_idle_count;
          qvl_s4_block_with_os_count_negedge <= `ZiCwDebugDelay1
            qvl_s4_block_with_os_count +
            inc_s4_block_with_os_count;
          qvl_t0_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t0_block_count +
            inc_t0_block_count;
          qvl_t1_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t1_block_count +
            inc_t1_block_count;
          qvl_t2_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t2_block_count +
            inc_t2_block_count;
          qvl_t3_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t3_block_count +
            inc_t3_block_count;
          qvl_t4_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t4_block_count +
            inc_t4_block_count;
          qvl_t5_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t5_block_count +
            inc_t5_block_count;
          qvl_t6_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t6_block_count +
            inc_t6_block_count;
          qvl_t7_block_count_negedge <= `ZiCwDebugDelay1
            qvl_t7_block_count +
            inc_t7_block_count;
        end
    end
`endif //ifdef QVL_COVER_ON
