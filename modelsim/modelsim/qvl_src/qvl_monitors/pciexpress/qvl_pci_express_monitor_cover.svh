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

  wire [63:0] qvl_total_packets;
  wire [63:0] qvl_more_than_one_pkt_detected_count;
  wire [63:0] qvl_non_zero_stp_count;
  wire [63:0] qvl_tlps_with_ecrc;
  wire [63:0] qvl_tlps_with_lcrc;
  wire [63:0] qvl_malformed_tlps;

  wire [63:0] qvl_com_symbols;
  wire [63:0] qvl_tl_packets;
  wire [63:0] qvl_dll_packets;
  wire [63:0] qvl_nullified_tlps;
  wire [63:0] qvl_ts1_os;
  wire [63:0] qvl_ts2_os;
  wire [63:0] qvl_ts1_ts2_os_reset;
  wire [63:0] qvl_ts1_ts2_os_disable;
  wire [63:0] qvl_ts1_ts2_os_loopback;
  wire [63:0] qvl_ts1_ts2_os_no_scramble;
  wire [63:0] qvl_fts_os;
  wire [63:0] qvl_idle_os;
  // PCI_EXPRESS_GEN2 code start
  // Different packet count for gen2
  wire [63:0] qvl_idle_os_gen2;
  wire [63:0] qvl_fts_os_gen2;
  wire [63:0] qvl_eie_os;
  wire [63:0] qvl_ts1_os_with_speed_change_bit;
  wire [63:0] qvl_ts2_os_with_speed_change_bit;
  wire [63:0] qvl_ts1_ts2_os_gen1;
  wire [63:0] qvl_ts1_ts2_os_gen2;
  wire [63:0] qvl_ts1_ts2_os_with_autonomous_bit;
  wire [63:0] qvl_ts1_os_with_compliance_rx_bit;
  wire [63:0] qvl_mt_4_eie_before_fts;
  wire [63:0] qvl_speed_change_through_l1;
  wire [63:0] qvl_reco_lk_to_reco_speed_after_timeout;
  wire [63:0] qvl_l0s_transtion_on_5gt;
  wire [63:0] qvl_l1_transtion_on_5gt;
  wire [63:0] qvl_l2_transtion_on_5gt;
  wire [63:0] qvl_polling_compliance_transtion;
  wire [63:0] qvl_reco_cfg_to_reco_speed_transtion;
  wire [63:0] qvl_speed_change_attemp_on_2_5gt;
  wire [63:0] qvl_speed_change_attemp_on_5gt;
  wire [63:0] qvl_successfull_speed_change_to_2_5gt;
  wire [63:0] qvl_successfull_speed_change_to_5gt;
  wire [63:0] qvl_modified_compliance_pattern;
  wire [63:0] qvl_deprecated_requests;
  // PCI_EXPRESS_GEN2 code end
  wire [63:0] qvl_skp_os;
  wire [63:0] qvl_pad_symbols;
  wire [63:0] qvl_stp_sdp_in_symbol_time;
  wire [63:0] qvl_number_of_Ack_dllps;
  wire [63:0] qvl_number_of_Nak_dllps;
  wire [63:0] qvl_number_of_Initfc1_P_dllps;
  wire [63:0] qvl_number_of_Initfc1_NP_dllps;
  wire [63:0] qvl_number_of_Initfc1_Cpl_dllps;
  wire [63:0] qvl_number_of_Initfc2_P_dllps;
  wire [63:0] qvl_number_of_Initfc2_NP_dllps;
  wire [63:0] qvl_number_of_Initfc2_Cpl_dllps;
  wire [63:0] qvl_number_of_Updatefc_P_dllps;
  wire [63:0] qvl_number_of_Updatefc_NP_dllps;
  wire [63:0] qvl_number_of_Updatefc_Cpl_dllps;
  wire [63:0] qvl_number_of_PM_Enter_L1_dllps;
  wire [63:0] qvl_number_of_PM_Enter_L23_dllps;
  wire [63:0] qvl_number_of_PM_Act_Req_L0_dllps;
  wire [63:0] qvl_number_of_PM_Act_Req_L1_dllps;
  wire [63:0] qvl_number_of_PM_Req_Ack_dllps;
  wire [63:0] qvl_number_of_vendor_specific_dllps;
  wire [63:0] qvl_number_of_retransmissions_from_retry_buffer;
  wire [63:0] qvl_num_duplicate_tlps;
  wire [63:0] qvl_memory_read_requests;
  wire [63:0] qvl_memory_write_requests;
  wire [63:0] qvl_io_read_requests;
  wire [63:0] qvl_io_write_requests;
  wire [63:0] qvl_type0_cfg_read_requests;
  wire [63:0] qvl_type0_cfg_write_requests;
  wire [63:0] qvl_type1_cfg_read_requests;
  wire [63:0] qvl_type1_cfg_write_requests;
  wire [63:0] qvl_message_requests;
  wire [63:0] qvl_locked_memory_requests;
  wire [63:0] qvl_completions;
  
  // PCI_EXPRESS_GEN2 code start
  // TL layer statistics for gen2
  wire [63:0] qvl_memory_read_requests_gen2;
  wire [63:0] qvl_memory_write_requests_gen2;
  wire [63:0] qvl_io_read_requests_gen2;
  wire [63:0] qvl_io_write_requests_gen2;
  wire [63:0] qvl_type0_cfg_read_requests_gen2;
  wire [63:0] qvl_type0_cfg_write_requests_gen2;
  wire [63:0] qvl_type1_cfg_read_requests_gen2;
  wire [63:0] qvl_type1_cfg_write_requests_gen2;
  wire [63:0] qvl_message_requests_gen2;
  wire [63:0] qvl_completions_gen2;
  wire [63:0] qvl_number_of_Ack_dllps_gen2;
  wire [63:0] qvl_number_of_Updatefc_P_dllps_gen2;
  wire [63:0] qvl_number_of_Updatefc_NP_dllps_gen2;
  wire [63:0] qvl_number_of_Updatefc_Cpl_dllps_gen2;
  wire [63:0] qvl_memory_translation_requests;
  wire [63:0] qvl_memory_translated_requests;
  // PCI_EXPRESS_GEN2 code end
  
  wire [63:0] qvl_locked_completions;
  wire [63:0] qvl_ur_completions;
  wire [63:0] qvl_completer_aborts;
  wire [63:0] qvl_completions_with_cfg_retry;
  wire [63:0] qvl_tlps_with_digests;

  reg [63:0] qvl_more_than_one_pkt_detected_count_posedge;
  reg [63:0] qvl_non_zero_stp_count_posedge;
  reg [63:0] qvl_tlps_with_ecrc_posedge;
  reg [63:0] qvl_tlps_with_lcrc_posedge;
  reg [63:0] qvl_malformed_tlps_posedge;

  reg [63:0] qvl_tl_packets_posedge;
  reg [63:0] qvl_dll_packets_posedge;
  reg [63:0] qvl_nullified_tlps_posedge;
  reg [63:0] qvl_ts1_os_posedge;
  reg [63:0] qvl_ts2_os_posedge;
  reg [63:0] qvl_ts1_ts2_os_reset_posedge;
  reg [63:0] qvl_ts1_ts2_os_disable_posedge;
  reg [63:0] qvl_ts1_ts2_os_loopback_posedge;
  reg [63:0] qvl_ts1_ts2_os_no_scramble_posedge;
  reg [63:0] qvl_fts_os_posedge;
  reg [63:0] qvl_idle_os_posedge;
  reg [63:0] qvl_skp_os_posedge;
  // PCI_EXPRESS_GEN2 code start
  reg [63:0] qvl_idle_os_gen2_posedge;
  reg [63:0] qvl_fts_os_gen2_posedge;
  reg [63:0] qvl_eie_os_posedge;
  reg [63:0] qvl_ts1_os_with_speed_change_bit_posedge;
  reg [63:0] qvl_ts2_os_with_speed_change_bit_posedge;
  reg [63:0] qvl_ts1_ts2_os_gen1_posedge;
  reg [63:0] qvl_ts1_ts2_os_gen2_posedge;
  reg [63:0] qvl_ts1_ts2_os_with_autonomous_bit_posedge;
  reg [63:0] qvl_ts1_os_with_compliance_rx_bit_posedge;
  reg [63:0] qvl_mt_4_eie_before_fts_posedge;
  reg [63:0] qvl_speed_change_through_l1_posedge;
  reg [63:0] qvl_reco_lk_to_reco_speed_after_timeout_posedge;
  reg [63:0] qvl_l0s_transtion_on_5gt_posedge;
  reg [63:0] qvl_l1_transtion_on_5gt_posedge;
  reg [63:0] qvl_l2_transtion_on_5gt_posedge;
  reg [63:0] qvl_polling_compliance_transtion_posedge;
  reg [63:0] qvl_reco_cfg_to_reco_speed_transtion_posedge;
  reg [63:0] qvl_speed_change_attemp_on_2_5gt_posedge;
  reg [63:0] qvl_speed_change_attemp_on_5gt_posedge;
  reg [63:0] qvl_successfull_speed_change_to_2_5gt_posedge;
  reg [63:0] qvl_successfull_speed_change_to_5gt_posedge;
  reg [63:0] qvl_modified_compliance_pattern_posedge;
  reg [63:0] qvl_deprecated_requests_posedge;
  // PCI_EXPRESS_GEN2 code end
  reg [63:0] qvl_pad_symbols_posedge;
  reg [63:0] qvl_stp_sdp_in_symbol_time_posedge;
  reg [63:0] qvl_number_of_Ack_dllps_posedge;
  reg [63:0] qvl_number_of_Nak_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc1_P_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc1_NP_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc1_Cpl_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc2_P_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc2_NP_dllps_posedge;
  reg [63:0] qvl_number_of_Initfc2_Cpl_dllps_posedge;
  reg [63:0] qvl_number_of_Updatefc_P_dllps_posedge;
  reg [63:0] qvl_number_of_Updatefc_NP_dllps_posedge;
  reg [63:0] qvl_number_of_Updatefc_Cpl_dllps_posedge;
  reg [63:0] qvl_number_of_PM_Enter_L1_dllps_posedge;
  reg [63:0] qvl_number_of_PM_Enter_L23_dllps_posedge;
  reg [63:0] qvl_number_of_PM_Act_Req_L0_dllps_posedge;
  reg [63:0] qvl_number_of_PM_Act_Req_L1_dllps_posedge;
  reg [63:0] qvl_number_of_PM_Req_Ack_dllps_posedge;
  reg [63:0] qvl_number_of_vendor_specific_dllps_posedge;
  reg [63:0] qvl_number_of_retransmissions_from_retry_buffer_posedge;
  reg [63:0] qvl_num_duplicate_tlps_posedge;
  reg [63:0] qvl_memory_read_requests_posedge;
  reg [63:0] qvl_memory_write_requests_posedge;
  reg [63:0] qvl_io_read_requests_posedge;
  reg [63:0] qvl_io_write_requests_posedge;
  reg [63:0] qvl_type0_cfg_read_requests_posedge;
  reg [63:0] qvl_type0_cfg_write_requests_posedge;
  reg [63:0] qvl_type1_cfg_read_requests_posedge;
  reg [63:0] qvl_type1_cfg_write_requests_posedge;
  reg [63:0] qvl_message_requests_posedge;
  reg [63:0] qvl_locked_memory_requests_posedge;
  reg [63:0] qvl_completions_posedge;

  // PCI_EXPRESS_GEN2 code start
  reg [63:0] qvl_memory_read_requests_gen2_posedge;
  reg [63:0] qvl_memory_write_requests_gen2_posedge;
  reg [63:0] qvl_io_read_requests_gen2_posedge;
  reg [63:0] qvl_io_write_requests_gen2_posedge;
  reg [63:0] qvl_type0_cfg_read_requests_gen2_posedge;
  reg [63:0] qvl_type0_cfg_write_requests_gen2_posedge;
  reg [63:0] qvl_type1_cfg_read_requests_gen2_posedge;
  reg [63:0] qvl_type1_cfg_write_requests_gen2_posedge;
  reg [63:0] qvl_message_requests_gen2_posedge;
  reg [63:0] qvl_completions_gen2_posedge;
  reg [63:0] qvl_number_of_Ack_dllps_gen2_posedge;
  reg [63:0] qvl_number_of_Updatefc_P_dllps_gen2_posedge;
  reg [63:0] qvl_number_of_Updatefc_NP_dllps_gen2_posedge;
  reg [63:0] qvl_number_of_Updatefc_Cpl_dllps_gen2_posedge;
  reg [63:0] qvl_memory_translation_requests_posedge;
  reg [63:0] qvl_memory_translated_requests_posedge;
  // PCI_EXPRESS_GEN2 code end
  
  reg [63:0] qvl_locked_completions_posedge;
  reg [63:0] qvl_ur_completions_posedge;
  reg [63:0] qvl_completer_aborts_posedge;
  reg [63:0] qvl_completions_with_cfg_retry_posedge;
  reg [63:0] qvl_tlps_with_digests_posedge;

  reg [63:0] qvl_more_than_one_pkt_detected_count_negedge;
  reg [63:0] qvl_non_zero_stp_count_negedge;
  reg [63:0] qvl_tlps_with_ecrc_negedge;
  reg [63:0] qvl_tlps_with_lcrc_negedge;
  reg [63:0] qvl_malformed_tlps_negedge;

  reg [63:0] qvl_tl_packets_negedge;
  reg [63:0] qvl_dll_packets_negedge;
  reg [63:0] qvl_nullified_tlps_negedge;
  reg [63:0] qvl_ts1_os_negedge;
  reg [63:0] qvl_ts2_os_negedge;
  reg [63:0] qvl_ts1_ts2_os_reset_negedge;
  reg [63:0] qvl_ts1_ts2_os_disable_negedge;
  reg [63:0] qvl_ts1_ts2_os_loopback_negedge;
  reg [63:0] qvl_ts1_ts2_os_no_scramble_negedge;
  reg [63:0] qvl_fts_os_negedge;
  reg [63:0] qvl_idle_os_negedge;
  // PCI_EXPRESS_GEN2 code start
  reg [63:0] qvl_idle_os_gen2_negedge;
  reg [63:0] qvl_fts_os_gen2_negedge;  
  reg [63:0] qvl_eie_os_negedge;
  reg [63:0] qvl_ts1_os_with_speed_change_bit_negedge;
  reg [63:0] qvl_ts2_os_with_speed_change_bit_negedge;
  reg [63:0] qvl_ts1_ts2_os_gen1_negedge;
  reg [63:0] qvl_ts1_ts2_os_gen2_negedge;
  reg [63:0] qvl_ts1_ts2_os_with_autonomous_bit_negedge;
  reg [63:0] qvl_ts1_os_with_compliance_rx_bit_negedge;
  reg [63:0] qvl_mt_4_eie_before_fts_negedge;
  reg [63:0] qvl_speed_change_through_l1_negedge;
  reg [63:0] qvl_reco_lk_to_reco_speed_after_timeout_negedge;
  reg [63:0] qvl_l0s_transtion_on_5gt_negedge;
  reg [63:0] qvl_l1_transtion_on_5gt_negedge;
  reg [63:0] qvl_l2_transtion_on_5gt_negedge;
  reg [63:0] qvl_polling_compliance_transtion_negedge;
  reg [63:0] qvl_reco_cfg_to_reco_speed_transtion_negedge;
  reg [63:0] qvl_speed_change_attemp_on_2_5gt_negedge;
  reg [63:0] qvl_speed_change_attemp_on_5gt_negedge;
  reg [63:0] qvl_successfull_speed_change_to_2_5gt_negedge;
  reg [63:0] qvl_successfull_speed_change_to_5gt_negedge;
  reg [63:0] qvl_modified_compliance_pattern_negedge;
  reg [63:0] qvl_deprecated_requests_negedge;
   // PCI_EXPRESS_GEN2 code end  
  reg [63:0] qvl_skp_os_negedge;
  reg [63:0] qvl_pad_symbols_negedge;
  reg [63:0] qvl_stp_sdp_in_symbol_time_negedge;
  reg [63:0] qvl_number_of_Ack_dllps_negedge;
  reg [63:0] qvl_number_of_Nak_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc1_P_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc1_NP_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc1_Cpl_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc2_P_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc2_NP_dllps_negedge;
  reg [63:0] qvl_number_of_Initfc2_Cpl_dllps_negedge;
  reg [63:0] qvl_number_of_Updatefc_P_dllps_negedge;
  reg [63:0] qvl_number_of_Updatefc_NP_dllps_negedge;
  reg [63:0] qvl_number_of_Updatefc_Cpl_dllps_negedge;
  reg [63:0] qvl_number_of_PM_Enter_L1_dllps_negedge;
  reg [63:0] qvl_number_of_PM_Enter_L23_dllps_negedge;
  reg [63:0] qvl_number_of_PM_Act_Req_L0_dllps_negedge;
  reg [63:0] qvl_number_of_PM_Act_Req_L1_dllps_negedge;
  reg [63:0] qvl_number_of_PM_Req_Ack_dllps_negedge;
  reg [63:0] qvl_number_of_vendor_specific_dllps_negedge;
  reg [63:0] qvl_number_of_retransmissions_from_retry_buffer_negedge;
  reg [63:0] qvl_num_duplicate_tlps_negedge;
  reg [63:0] qvl_memory_read_requests_negedge;
  reg [63:0] qvl_memory_write_requests_negedge;
  reg [63:0] qvl_io_read_requests_negedge;
  reg [63:0] qvl_io_write_requests_negedge;
  reg [63:0] qvl_type0_cfg_read_requests_negedge;
  reg [63:0] qvl_type0_cfg_write_requests_negedge;
  reg [63:0] qvl_type1_cfg_read_requests_negedge;
  reg [63:0] qvl_type1_cfg_write_requests_negedge;
  reg [63:0] qvl_message_requests_negedge;
  reg [63:0] qvl_locked_memory_requests_negedge;
  reg [63:0] qvl_completions_negedge;

  // PCI_EXPRESS_GEN2 code start
  reg [63:0] qvl_memory_read_requests_gen2_negedge;
  reg [63:0] qvl_memory_write_requests_gen2_negedge;
  reg [63:0] qvl_io_read_requests_gen2_negedge;
  reg [63:0] qvl_io_write_requests_gen2_negedge;
  reg [63:0] qvl_type0_cfg_read_requests_gen2_negedge;
  reg [63:0] qvl_type0_cfg_write_requests_gen2_negedge;
  reg [63:0] qvl_type1_cfg_read_requests_gen2_negedge;
  reg [63:0] qvl_type1_cfg_write_requests_gen2_negedge;
  reg [63:0] qvl_message_requests_gen2_negedge;
  reg [63:0] qvl_completions_gen2_negedge;
  reg [63:0] qvl_number_of_Ack_dllps_gen2_negedge;
  reg [63:0] qvl_number_of_Updatefc_P_dllps_gen2_negedge;
  reg [63:0] qvl_number_of_Updatefc_NP_dllps_gen2_negedge;
  reg [63:0] qvl_number_of_Updatefc_Cpl_dllps_gen2_negedge;
  reg [63:0] qvl_memory_translation_requests_negedge;
  reg [63:0] qvl_memory_translated_requests_negedge;
  // PCI_EXPRESS_GEN2 code end
  
  reg [63:0] qvl_locked_completions_negedge;
  reg [63:0] qvl_ur_completions_negedge;
  reg [63:0] qvl_completer_aborts_negedge;
  reg [63:0] qvl_completions_with_cfg_retry_negedge;
  reg [63:0] qvl_tlps_with_digests_negedge;

  initial
    begin
      #2;
      qvl_more_than_one_pkt_detected_count_posedge = 64'b0;
      qvl_non_zero_stp_count_posedge = 64'b0;
      qvl_tlps_with_ecrc_posedge = 64'b0;
      qvl_tlps_with_lcrc_posedge = 64'b0;
      qvl_malformed_tlps_posedge = 64'b0;

      qvl_tl_packets_posedge = 64'b0;
      qvl_dll_packets_posedge = 64'b0;
      qvl_nullified_tlps_posedge = 64'b0;
      qvl_ts1_os_posedge = 64'b0;
      qvl_ts2_os_posedge = 64'b0;
      qvl_ts1_ts2_os_reset_posedge = 64'b0;
      qvl_ts1_ts2_os_disable_posedge = 64'b0;
      qvl_ts1_ts2_os_loopback_posedge = 64'b0;
      qvl_ts1_ts2_os_no_scramble_posedge = 64'b0;
      qvl_fts_os_posedge = 64'b0;
      qvl_idle_os_posedge = 64'b0;
  // PCI_EXPRESS_GEN2 code start
      qvl_idle_os_gen2_posedge = 64'b0;
      qvl_fts_os_gen2_posedge = 64'b0;
      qvl_eie_os_posedge = 64'b0;
      qvl_ts1_os_with_speed_change_bit_posedge = 64'b0;
      qvl_ts2_os_with_speed_change_bit_posedge = 64'b0;
      qvl_ts1_ts2_os_gen1_posedge = 64'b0;
      qvl_ts1_ts2_os_gen2_posedge = 64'b0;
      qvl_ts1_ts2_os_with_autonomous_bit_posedge = 64'b0;
      qvl_ts1_os_with_compliance_rx_bit_posedge = 64'b0;
      qvl_mt_4_eie_before_fts_posedge = 64'b0;
      qvl_speed_change_through_l1_posedge = 64'b0;
      qvl_reco_lk_to_reco_speed_after_timeout_posedge = 64'b0;
      qvl_l0s_transtion_on_5gt_posedge = 64'b0;
      qvl_l1_transtion_on_5gt_posedge = 64'b0;
      qvl_l2_transtion_on_5gt_posedge = 64'b0;
      qvl_polling_compliance_transtion_posedge = 64'b0;
      qvl_reco_cfg_to_reco_speed_transtion_posedge = 64'b0;
      qvl_speed_change_attemp_on_2_5gt_posedge = 64'b0;
      qvl_speed_change_attemp_on_5gt_posedge = 64'b0;
      qvl_successfull_speed_change_to_2_5gt_posedge = 64'b0;
      qvl_successfull_speed_change_to_5gt_posedge = 64'b0;
      qvl_modified_compliance_pattern_posedge = 64'b0;
      qvl_deprecated_requests_posedge = 64'b0;
  // PCI_EXPRESS_GEN2 code end      
      qvl_skp_os_posedge = 64'b0;
      qvl_pad_symbols_posedge = 64'b0;
      qvl_stp_sdp_in_symbol_time_posedge = 64'b0;
      qvl_number_of_Ack_dllps_posedge = 64'b0;
      qvl_number_of_Nak_dllps_posedge = 64'b0;
      qvl_number_of_Initfc1_P_dllps_posedge = 64'b0;
      qvl_number_of_Initfc1_NP_dllps_posedge = 64'b0;
      qvl_number_of_Initfc1_Cpl_dllps_posedge = 64'b0;
      qvl_number_of_Initfc2_P_dllps_posedge = 64'b0;
      qvl_number_of_Initfc2_NP_dllps_posedge = 64'b0;
      qvl_number_of_Initfc2_Cpl_dllps_posedge = 64'b0;
      qvl_number_of_Updatefc_P_dllps_posedge = 64'b0;
      qvl_number_of_Updatefc_NP_dllps_posedge = 64'b0;
      qvl_number_of_Updatefc_Cpl_dllps_posedge = 64'b0;
      qvl_number_of_PM_Enter_L1_dllps_posedge = 64'b0;
      qvl_number_of_PM_Enter_L23_dllps_posedge = 64'b0;
      qvl_number_of_PM_Act_Req_L0_dllps_posedge = 64'b0;
      qvl_number_of_PM_Act_Req_L1_dllps_posedge = 64'b0;
      qvl_number_of_PM_Req_Ack_dllps_posedge = 64'b0;
      qvl_number_of_vendor_specific_dllps_posedge = 64'b0;
      qvl_number_of_retransmissions_from_retry_buffer_posedge = 64'b0;
      qvl_num_duplicate_tlps_posedge = 64'b0;
      qvl_memory_read_requests_posedge = 64'b0;
      qvl_memory_write_requests_posedge = 64'b0;
      qvl_io_read_requests_posedge = 64'b0;
      qvl_io_write_requests_posedge = 64'b0;
      qvl_type0_cfg_read_requests_posedge = 64'b0;
      qvl_type0_cfg_write_requests_posedge = 64'b0;
      qvl_type1_cfg_read_requests_posedge = 64'b0;
      qvl_type1_cfg_write_requests_posedge = 64'b0;
      qvl_message_requests_posedge = 64'b0;
      qvl_locked_memory_requests_posedge = 64'b0;
      qvl_completions_posedge = 64'b0;
      
      // PCI_EXPRESS_GEN2 code start
      qvl_memory_read_requests_gen2_posedge = 64'b0;
      qvl_memory_write_requests_gen2_posedge = 64'b0;
      qvl_io_read_requests_gen2_posedge = 64'b0;
      qvl_io_write_requests_gen2_posedge = 64'b0;
      qvl_type0_cfg_read_requests_gen2_posedge = 64'b0;
      qvl_type0_cfg_write_requests_gen2_posedge = 64'b0;
      qvl_type1_cfg_read_requests_gen2_posedge = 64'b0;
      qvl_type1_cfg_write_requests_gen2_posedge = 64'b0;
      qvl_message_requests_gen2_posedge = 64'b0;
      qvl_completions_gen2_posedge = 64'b0;
      qvl_number_of_Ack_dllps_gen2_posedge = 64'b0;
      qvl_number_of_Updatefc_P_dllps_gen2_posedge = 64'b0;
      qvl_number_of_Updatefc_NP_dllps_gen2_posedge = 64'b0;
      qvl_number_of_Updatefc_Cpl_dllps_gen2_posedge = 64'b0;
      qvl_memory_translation_requests_posedge = 64'b0;
      qvl_memory_translated_requests_posedge = 64'b0;
      // PCI_EXPRESS_GEN2 code end
      
      qvl_locked_completions_posedge = 64'b0;
      qvl_ur_completions_posedge = 64'b0;
      qvl_completer_aborts_posedge = 64'b0;
      qvl_completions_with_cfg_retry_posedge = 64'b0;
      qvl_tlps_with_digests_posedge = 64'b0;

      qvl_more_than_one_pkt_detected_count_negedge = 64'b0;
      qvl_non_zero_stp_count_negedge = 64'b0;
      qvl_tlps_with_ecrc_negedge = 64'b0;
      qvl_tlps_with_lcrc_negedge = 64'b0;
      qvl_malformed_tlps_negedge = 64'b0;

      qvl_tl_packets_negedge = 64'b0;
      qvl_dll_packets_negedge = 64'b0;
      qvl_nullified_tlps_negedge = 64'b0;
      qvl_ts1_os_negedge = 64'b0;
      qvl_ts2_os_negedge = 64'b0;
      qvl_ts1_ts2_os_reset_negedge = 64'b0;
      qvl_ts1_ts2_os_disable_negedge = 64'b0;
      qvl_ts1_ts2_os_loopback_negedge = 64'b0;
      qvl_ts1_ts2_os_no_scramble_negedge = 64'b0;
      qvl_fts_os_negedge = 64'b0;
      qvl_idle_os_negedge = 64'b0;
  // PCI_EXPRESS_GEN2 code start
      qvl_idle_os_gen2_negedge = 64'b0;
      qvl_fts_os_gen2_negedge = 64'b0;
      qvl_eie_os_negedge = 64'b0;
      qvl_ts1_os_with_speed_change_bit_negedge = 64'b0;
      qvl_ts2_os_with_speed_change_bit_negedge = 64'b0;
      qvl_ts1_ts2_os_gen1_negedge = 64'b0;
      qvl_ts1_ts2_os_gen2_negedge = 64'b0;
      qvl_ts1_ts2_os_with_autonomous_bit_negedge = 64'b0;
      qvl_ts1_os_with_compliance_rx_bit_negedge = 64'b0;
      qvl_mt_4_eie_before_fts_negedge = 64'b0;
      qvl_speed_change_through_l1_negedge = 64'b0;
      qvl_reco_lk_to_reco_speed_after_timeout_negedge = 64'b0;
      qvl_l0s_transtion_on_5gt_negedge = 64'b0;
      qvl_l1_transtion_on_5gt_negedge = 64'b0;
      qvl_l2_transtion_on_5gt_negedge = 64'b0;
      qvl_polling_compliance_transtion_negedge = 64'b0;
      qvl_reco_cfg_to_reco_speed_transtion_negedge = 64'b0;
      qvl_speed_change_attemp_on_2_5gt_negedge = 64'b0;
      qvl_speed_change_attemp_on_5gt_negedge = 64'b0;
      qvl_successfull_speed_change_to_2_5gt_negedge = 64'b0;
      qvl_successfull_speed_change_to_5gt_negedge = 64'b0;
      qvl_modified_compliance_pattern_negedge = 64'b0;
      qvl_deprecated_requests_negedge = 64'b0;
  // PCI_EXPRESS_GEN2 code end      
      qvl_skp_os_negedge = 64'b0;
      qvl_pad_symbols_negedge = 64'b0;
      qvl_stp_sdp_in_symbol_time_negedge = 64'b0;
      qvl_number_of_Ack_dllps_negedge = 64'b0;
      qvl_number_of_Nak_dllps_negedge = 64'b0;
      qvl_number_of_Initfc1_P_dllps_negedge = 64'b0;
      qvl_number_of_Initfc1_NP_dllps_negedge = 64'b0;
      qvl_number_of_Initfc1_Cpl_dllps_negedge = 64'b0;
      qvl_number_of_Initfc2_P_dllps_negedge = 64'b0;
      qvl_number_of_Initfc2_NP_dllps_negedge = 64'b0;
      qvl_number_of_Initfc2_Cpl_dllps_negedge = 64'b0;
      qvl_number_of_Updatefc_P_dllps_negedge = 64'b0;
      qvl_number_of_Updatefc_NP_dllps_negedge = 64'b0;
      qvl_number_of_Updatefc_Cpl_dllps_negedge = 64'b0;
      qvl_number_of_PM_Enter_L1_dllps_negedge = 64'b0;
      qvl_number_of_PM_Enter_L23_dllps_negedge = 64'b0;
      qvl_number_of_PM_Act_Req_L0_dllps_negedge = 64'b0;
      qvl_number_of_PM_Act_Req_L1_dllps_negedge = 64'b0;
      qvl_number_of_PM_Req_Ack_dllps_negedge = 64'b0;
      qvl_number_of_vendor_specific_dllps_negedge = 64'b0;
      qvl_number_of_retransmissions_from_retry_buffer_negedge = 64'b0;
      qvl_num_duplicate_tlps_negedge = 64'b0;
      qvl_memory_read_requests_negedge = 64'b0;
      qvl_memory_write_requests_negedge = 64'b0;
      qvl_io_read_requests_negedge = 64'b0;
      qvl_io_write_requests_negedge = 64'b0;
      qvl_type0_cfg_read_requests_negedge = 64'b0;
      qvl_type0_cfg_write_requests_negedge = 64'b0;
      qvl_type1_cfg_read_requests_negedge = 64'b0;
      qvl_type1_cfg_write_requests_negedge = 64'b0;
      qvl_message_requests_negedge = 64'b0;
      qvl_locked_memory_requests_negedge = 64'b0;
      qvl_completions_negedge = 64'b0;
      
      // PCI_EXPRESS_GEN2 code start
      qvl_memory_read_requests_gen2_negedge = 64'b0;
      qvl_memory_write_requests_gen2_negedge = 64'b0;
      qvl_io_read_requests_gen2_negedge = 64'b0;
      qvl_io_write_requests_gen2_negedge = 64'b0;
      qvl_type0_cfg_read_requests_gen2_negedge = 64'b0;
      qvl_type0_cfg_write_requests_gen2_negedge = 64'b0;
      qvl_type1_cfg_read_requests_gen2_negedge = 64'b0;
      qvl_type1_cfg_write_requests_gen2_negedge = 64'b0;
      qvl_message_requests_gen2_negedge = 64'b0;
      qvl_completions_gen2_negedge = 64'b0;
      qvl_number_of_Ack_dllps_gen2_negedge = 64'b0;
      qvl_number_of_Updatefc_P_dllps_gen2_negedge = 64'b0;
      qvl_number_of_Updatefc_NP_dllps_gen2_negedge = 64'b0;
      qvl_number_of_Updatefc_Cpl_dllps_gen2_negedge = 64'b0;
      qvl_memory_translation_requests_negedge = 64'b0;
      qvl_memory_translated_requests_negedge = 64'b0;
      // PCI_EXPRESS_GEN2 code end
      
      qvl_locked_completions_negedge = 64'b0;
      qvl_ur_completions_negedge = 64'b0;
      qvl_completer_aborts_negedge = 64'b0;
      qvl_completions_with_cfg_retry_negedge = 64'b0;
      qvl_tlps_with_digests_negedge = 64'b0;
    end

  assign qvl_total_packets = qvl_tl_packets + qvl_dll_packets;
  assign qvl_more_than_one_pkt_detected_count = (level_select == 1'b1) ? 
         qvl_more_than_one_pkt_detected_count_posedge :
         qvl_more_than_one_pkt_detected_count_negedge;
  assign qvl_non_zero_stp_count = (level_select == 1'b1) ?
         qvl_non_zero_stp_count_posedge :
         qvl_non_zero_stp_count_negedge;
  assign qvl_tlps_with_ecrc = (level_select == 1'b1) ?
         qvl_tlps_with_ecrc_posedge :
         qvl_tlps_with_ecrc_negedge;
  assign qvl_tlps_with_lcrc = (level_select == 1'b1) ?
         qvl_tlps_with_lcrc_posedge :
         qvl_tlps_with_lcrc_negedge;
  assign qvl_malformed_tlps = (level_select == 1'b1) ?
         qvl_malformed_tlps_posedge :
         qvl_malformed_tlps_negedge;
  // This code commented as modified for gen2
  //assign qvl_com_symbols = (qvl_ts1_os + qvl_ts2_os + qvl_fts_os +
  //                          qvl_idle_os + qvl_skp_os);

  // PCI_EXPRESS_GEN2 code start
  assign qvl_com_symbols = (PCI_EXPRESS_GEN2 == 1) ? (qvl_ts1_os + qvl_ts2_os + qvl_fts_os +
                            qvl_idle_os + qvl_skp_os + qvl_eie_os) : (qvl_ts1_os + qvl_ts2_os + qvl_fts_os +
                            qvl_idle_os + qvl_skp_os);
  // PCI_EXPRESS_GEN2 code end
  
  assign qvl_tl_packets = (level_select == 1'b1) ? qvl_tl_packets_posedge :
                           qvl_tl_packets_negedge;
  assign qvl_dll_packets = (level_select == 1'b1) ? qvl_dll_packets_posedge :
                            qvl_dll_packets_negedge;
  assign qvl_nullified_tlps = (level_select == 1'b1) ? 
         qvl_nullified_tlps_posedge :
         qvl_nullified_tlps_negedge;
  assign qvl_ts1_os = (level_select == 1'b1) ? 
         qvl_ts1_os_posedge :
         qvl_ts1_os_negedge;
  assign qvl_ts2_os = (level_select == 1'b1) ? 
         qvl_ts2_os_posedge :
         qvl_ts2_os_negedge;
  assign qvl_ts1_ts2_os_reset = (level_select == 1'b1) ? 
         qvl_ts1_ts2_os_reset_posedge :
         qvl_ts1_ts2_os_reset_negedge;
  assign qvl_ts1_ts2_os_disable = (level_select == 1'b1) ? 
         qvl_ts1_ts2_os_disable_posedge :
         qvl_ts1_ts2_os_disable_negedge;
  assign qvl_ts1_ts2_os_loopback = (level_select == 1'b1) ? 
         qvl_ts1_ts2_os_loopback_posedge :
         qvl_ts1_ts2_os_loopback_negedge;
  assign qvl_ts1_ts2_os_no_scramble = (level_select == 1'b1) ? 
         qvl_ts1_ts2_os_no_scramble_posedge :
         qvl_ts1_ts2_os_no_scramble_negedge;
  assign qvl_fts_os = (level_select == 1'b1) ? 
         qvl_fts_os_posedge :
         qvl_fts_os_negedge;
  assign qvl_idle_os = (level_select == 1'b1) ? 
         qvl_idle_os_posedge :
         qvl_idle_os_negedge;

  // PCI_EXPRESS_GEN2 code start
  assign qvl_idle_os_gen2 = (level_select == 1'b1) ? 
         qvl_idle_os_gen2_posedge :
         qvl_idle_os_gen2_negedge;
  assign qvl_fts_os_gen2 = (level_select == 1'b1) ? 
         qvl_fts_os_gen2_posedge :
         qvl_fts_os_gen2_negedge;
  assign qvl_eie_os = (level_select == 1'b1) ? 
         qvl_eie_os_posedge :
         qvl_eie_os_negedge; 
  assign qvl_ts1_os_with_speed_change_bit = (level_select == 1'b1) ? 
         qvl_ts1_os_with_speed_change_bit_posedge :
         qvl_ts1_os_with_speed_change_bit_negedge;
  assign qvl_ts2_os_with_speed_change_bit = (level_select == 1'b1) ? 
         qvl_ts2_os_with_speed_change_bit_posedge :
         qvl_ts2_os_with_speed_change_bit_negedge;
  assign qvl_ts1_ts2_os_gen1 = (level_select == 1'b1) ?
	 qvl_ts1_ts2_os_gen1_posedge :
         qvl_ts1_ts2_os_gen1_negedge;			       
  assign qvl_ts1_ts2_os_gen2 = (level_select == 1'b1) ?
	 qvl_ts1_ts2_os_gen2_posedge :
         qvl_ts1_ts2_os_gen2_negedge;			       
  assign qvl_ts1_ts2_os_with_autonomous_bit = (level_select == 1'b1) ?
	 qvl_ts1_ts2_os_with_autonomous_bit_posedge :
         qvl_ts1_ts2_os_with_autonomous_bit_negedge;					      
  assign qvl_ts1_os_with_compliance_rx_bit = (level_select == 1'b1) ?
         qvl_ts1_os_with_compliance_rx_bit_posedge :
         qvl_ts1_os_with_compliance_rx_bit_negedge;						     
  assign qvl_mt_4_eie_before_fts = (level_select == 1'b1) ?
         qvl_mt_4_eie_before_fts_posedge :
         qvl_mt_4_eie_before_fts_negedge;
  assign qvl_speed_change_through_l1 = (level_select == 1'b1) ?
	 qvl_speed_change_through_l1_posedge :
         qvl_speed_change_through_l1_negedge;
  assign qvl_reco_lk_to_reco_speed_after_timeout = (level_select == 1'b1) ?
         qvl_reco_lk_to_reco_speed_after_timeout_posedge :
         qvl_reco_lk_to_reco_speed_after_timeout_negedge;						   
  assign qvl_l0s_transtion_on_5gt = (level_select == 1'b1) ?
	 qvl_l0s_transtion_on_5gt_posedge :
         qvl_l0s_transtion_on_5gt_negedge;  			    
  assign qvl_l1_transtion_on_5gt = (level_select == 1'b1) ?
         qvl_l1_transtion_on_5gt_posedge :
         qvl_l1_transtion_on_5gt_negedge; 				   
  assign qvl_l2_transtion_on_5gt = (level_select == 1'b1) ?
	 qvl_l2_transtion_on_5gt_posedge :
         qvl_l2_transtion_on_5gt_negedge;
  assign qvl_polling_compliance_transtion = (level_select == 1'b1) ?
         qvl_polling_compliance_transtion_posedge :
         qvl_polling_compliance_transtion_negedge;  					    
  assign qvl_reco_cfg_to_reco_speed_transtion = (level_select == 1'b1) ?
         qvl_reco_cfg_to_reco_speed_transtion_posedge :
         qvl_reco_cfg_to_reco_speed_transtion_negedge; 						
  assign qvl_speed_change_attemp_on_2_5gt = (level_select == 1'b1) ?
         qvl_speed_change_attemp_on_2_5gt_posedge :
         qvl_speed_change_attemp_on_2_5gt_negedge;					    
  assign qvl_speed_change_attemp_on_5gt = (level_select == 1'b1) ?
         qvl_speed_change_attemp_on_5gt_posedge :
         qvl_speed_change_attemp_on_5gt_negedge; 					   
  assign qvl_successfull_speed_change_to_2_5gt = (level_select == 1'b1) ?
         qvl_successfull_speed_change_to_2_5gt_posedge :
         qvl_successfull_speed_change_to_2_5gt_negedge;   						 
  assign qvl_successfull_speed_change_to_5gt = (level_select == 1'b1) ?
         qvl_successfull_speed_change_to_5gt_posedge :
         qvl_successfull_speed_change_to_5gt_negedge;
  assign qvl_modified_compliance_pattern = (level_select == 1'b1) ?
         qvl_modified_compliance_pattern_posedge :
         qvl_modified_compliance_pattern_negedge;					   
  assign qvl_deprecated_requests = (level_select == 1'b1) ?
	 qvl_deprecated_requests_posedge : qvl_deprecated_requests_negedge; 			   
  // PCI_EXPRESS_GEN2 code end

  assign qvl_skp_os = (level_select == 1'b1) ? 
         qvl_skp_os_posedge :
         qvl_skp_os_negedge;
  assign qvl_pad_symbols = (level_select == 1'b1) ? 
         qvl_pad_symbols_posedge :
         qvl_pad_symbols_negedge;
  assign qvl_stp_sdp_in_symbol_time = (level_select == 1'b1) ? 
         qvl_stp_sdp_in_symbol_time_posedge :
         qvl_stp_sdp_in_symbol_time_negedge;
  assign qvl_number_of_Ack_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Ack_dllps_posedge :
         qvl_number_of_Ack_dllps_negedge;
  assign qvl_number_of_Nak_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Nak_dllps_posedge :
         qvl_number_of_Nak_dllps_negedge;
  assign qvl_number_of_Initfc1_P_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc1_P_dllps_posedge :
         qvl_number_of_Initfc1_P_dllps_negedge;
  assign qvl_number_of_Initfc1_NP_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc1_NP_dllps_posedge :
         qvl_number_of_Initfc1_NP_dllps_negedge;
  assign qvl_number_of_Initfc1_Cpl_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc1_Cpl_dllps_posedge :
         qvl_number_of_Initfc1_Cpl_dllps_negedge;
  assign qvl_number_of_Initfc2_P_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc2_P_dllps_posedge :
         qvl_number_of_Initfc2_P_dllps_negedge;
  assign qvl_number_of_Initfc2_NP_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc2_NP_dllps_posedge :
         qvl_number_of_Initfc2_NP_dllps_negedge;
  assign qvl_number_of_Initfc2_Cpl_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Initfc2_Cpl_dllps_posedge :
         qvl_number_of_Initfc2_Cpl_dllps_negedge;
  assign qvl_number_of_Updatefc_P_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Updatefc_P_dllps_posedge :
         qvl_number_of_Updatefc_P_dllps_negedge;
  assign qvl_number_of_Updatefc_NP_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Updatefc_NP_dllps_posedge :
         qvl_number_of_Updatefc_NP_dllps_negedge;
  assign qvl_number_of_Updatefc_Cpl_dllps = (level_select == 1'b1) ? 
         qvl_number_of_Updatefc_Cpl_dllps_posedge :
         qvl_number_of_Updatefc_Cpl_dllps_negedge;
  assign qvl_number_of_PM_Enter_L1_dllps = (level_select == 1'b1) ? 
         qvl_number_of_PM_Enter_L1_dllps_posedge :
         qvl_number_of_PM_Enter_L1_dllps_negedge;
  assign qvl_number_of_PM_Enter_L23_dllps = (level_select == 1'b1) ? 
         qvl_number_of_PM_Enter_L23_dllps_posedge :
         qvl_number_of_PM_Enter_L23_dllps_negedge;
  assign qvl_number_of_PM_Act_Req_L0_dllps = (level_select == 1'b1) ? 
         qvl_number_of_PM_Act_Req_L0_dllps_posedge :
         qvl_number_of_PM_Act_Req_L0_dllps_negedge;
  assign qvl_number_of_PM_Act_Req_L1_dllps = (level_select == 1'b1) ? 
         qvl_number_of_PM_Act_Req_L1_dllps_posedge :
         qvl_number_of_PM_Act_Req_L1_dllps_negedge;
  assign qvl_number_of_PM_Req_Ack_dllps = (level_select == 1'b1) ? 
         qvl_number_of_PM_Req_Ack_dllps_posedge :
         qvl_number_of_PM_Req_Ack_dllps_negedge;
  assign qvl_number_of_vendor_specific_dllps = (level_select == 1'b1) ? 
         qvl_number_of_vendor_specific_dllps_posedge :
         qvl_number_of_vendor_specific_dllps_negedge;
  assign qvl_number_of_retransmissions_from_retry_buffer = (level_select == 1'b1) ? 
         qvl_number_of_retransmissions_from_retry_buffer_posedge :
         qvl_number_of_retransmissions_from_retry_buffer_negedge;
  assign qvl_num_duplicate_tlps = (level_select == 1'b1) ? 
         qvl_num_duplicate_tlps_posedge :
         qvl_num_duplicate_tlps_negedge;
  assign qvl_memory_read_requests = (level_select == 1'b1) ? 
         qvl_memory_read_requests_posedge :
         qvl_memory_read_requests_negedge;
  assign qvl_memory_write_requests = (level_select == 1'b1) ? 
         qvl_memory_write_requests_posedge :
         qvl_memory_write_requests_negedge;
  assign qvl_io_read_requests = (level_select == 1'b1) ? 
         qvl_io_read_requests_posedge :
         qvl_io_read_requests_negedge;
  assign qvl_io_write_requests = (level_select == 1'b1) ? 
         qvl_io_write_requests_posedge :
         qvl_io_write_requests_negedge;
  assign qvl_type0_cfg_read_requests = (level_select == 1'b1) ? 
         qvl_type0_cfg_read_requests_posedge :
         qvl_type0_cfg_read_requests_negedge;
  assign qvl_type0_cfg_write_requests = (level_select == 1'b1) ? 
         qvl_type0_cfg_write_requests_posedge :
         qvl_type0_cfg_write_requests_negedge;
  assign qvl_type1_cfg_read_requests = (level_select == 1'b1) ? 
         qvl_type1_cfg_read_requests_posedge :
         qvl_type1_cfg_read_requests_negedge;
  assign qvl_type1_cfg_write_requests = (level_select == 1'b1) ? 
         qvl_type1_cfg_write_requests_posedge :
         qvl_type1_cfg_write_requests_negedge;
  assign qvl_message_requests = (level_select == 1'b1) ? 
         qvl_message_requests_posedge :
         qvl_message_requests_negedge;
  assign qvl_locked_memory_requests = (level_select == 1'b1) ? 
         qvl_locked_memory_requests_posedge :
         qvl_locked_memory_requests_negedge;
  assign qvl_completions = (level_select == 1'b1) ? 
         qvl_completions_posedge :
         qvl_completions_negedge;

  // PCI_EXPRESS_GEN2 code start
  assign qvl_memory_read_requests_gen2 = (level_select == 1'b1) ?  
         qvl_memory_read_requests_gen2_posedge : 
         qvl_memory_read_requests_gen2_negedge;
  assign qvl_memory_write_requests_gen2 = (level_select == 1'b1) ?
         qvl_memory_write_requests_gen2_posedge : 
         qvl_memory_write_requests_gen2_negedge;
  assign qvl_io_read_requests_gen2 = (level_select == 1'b1) ?
         qvl_io_read_requests_gen2_posedge :
         qvl_io_read_requests_gen2_negedge;
  assign qvl_io_write_requests_gen2 = (level_select == 1'b1) ?  
         qvl_io_write_requests_gen2_posedge :
         qvl_io_write_requests_gen2_negedge;
  assign qvl_type0_cfg_read_requests_gen2 = (level_select == 1'b1) ?  
         qvl_type0_cfg_read_requests_gen2_posedge :
         qvl_type0_cfg_read_requests_gen2_negedge;
  assign qvl_type0_cfg_write_requests_gen2 = (level_select == 1'b1) ?  
         qvl_type0_cfg_write_requests_gen2_posedge :
         qvl_type0_cfg_write_requests_gen2_negedge;
  assign qvl_type1_cfg_read_requests_gen2 = (level_select == 1'b1) ?  
         qvl_type1_cfg_read_requests_gen2_posedge :
         qvl_type1_cfg_read_requests_gen2_negedge;
  assign qvl_type1_cfg_write_requests_gen2 = (level_select == 1'b1) ?  
         qvl_type1_cfg_write_requests_gen2_posedge :
         qvl_type1_cfg_write_requests_gen2_negedge;
  assign qvl_message_requests_gen2 = (level_select == 1'b1) ?  
         qvl_message_requests_gen2_posedge :
         qvl_message_requests_gen2_negedge;
  assign qvl_completions_gen2 = (level_select == 1'b1) ? 
         qvl_completions_gen2_posedge : 
         qvl_completions_gen2_negedge;
  assign qvl_number_of_Ack_dllps_gen2 = (level_select == 1'b1) ?
         qvl_number_of_Ack_dllps_gen2_posedge :
         qvl_number_of_Ack_dllps_gen2_negedge;
  assign qvl_number_of_Updatefc_P_dllps_gen2 = (level_select == 1'b1) ?   
         qvl_number_of_Updatefc_P_dllps_gen2_posedge :
         qvl_number_of_Updatefc_P_dllps_gen2_negedge;
  assign qvl_number_of_Updatefc_NP_dllps_gen2 = (level_select == 1'b1) ?   
         qvl_number_of_Updatefc_NP_dllps_gen2_posedge :
         qvl_number_of_Updatefc_NP_dllps_gen2_negedge;
  assign qvl_number_of_Updatefc_Cpl_dllps_gen2  = (level_select == 1'b1) ?
         qvl_number_of_Updatefc_Cpl_dllps_gen2_posedge :
         qvl_number_of_Updatefc_Cpl_dllps_gen2_negedge;
  assign qvl_memory_translation_requests = (level_select == 1'b1) ?
         qvl_memory_translation_requests_posedge :
         qvl_memory_translation_requests_negedge;
  assign qvl_memory_translated_requests = (level_select == 1'b1) ?
         qvl_memory_translated_requests_posedge :
         qvl_memory_translated_requests_negedge;						  
  // PCI_EXPRESS_GEN2 code end
  
  assign qvl_locked_completions = (level_select == 1'b1) ? 
         qvl_locked_completions_posedge :
         qvl_locked_completions_negedge;
  assign qvl_ur_completions = (level_select == 1'b1) ? 
         qvl_ur_completions_posedge :
         qvl_ur_completions_negedge;
  assign qvl_completer_aborts = (level_select == 1'b1) ? 
         qvl_completer_aborts_posedge :
         qvl_completer_aborts_negedge;
  assign qvl_completions_with_cfg_retry = (level_select == 1'b1) ? 
         qvl_completions_with_cfg_retry_posedge :
         qvl_completions_with_cfg_retry_negedge;
  assign qvl_tlps_with_digests = (level_select == 1'b1) ? 
         qvl_tlps_with_digests_posedge :
         qvl_tlps_with_digests_negedge;

   always @(posedge clk or posedge areset)
   begin
      if(areset !== 1'b0)
      begin
         // Do Nothing
      end
      else if(reset !== 1'b0)
      begin
         // Do Nothing
      end
      else if(collect_stats === 1'b1)
      begin
            // Corner Cases
            qvl_number_of_Ack_dllps_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Ack_dllps + number_of_Ack_dllps_temp;
            qvl_number_of_Nak_dllps_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Nak_dllps + number_of_Nak_dllps_temp;
            qvl_number_of_Initfc1_P_dllps_posedge <= `ZiCwDebugDelay1
                                             qvl_number_of_Initfc1_P_dllps +
                                         number_of_Initfc1_P_dllps_temp;
            qvl_number_of_Initfc1_NP_dllps_posedge <= `ZiCwDebugDelay1
                                            qvl_number_of_Initfc1_NP_dllps +
                                        number_of_Initfc1_NP_dllps_temp;
            qvl_number_of_Initfc1_Cpl_dllps_posedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc1_Cpl_dllps +
                                       number_of_Initfc1_Cpl_dllps_temp;
            qvl_number_of_Initfc2_P_dllps_posedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc2_P_dllps +
                                       number_of_Initfc2_P_dllps_temp;
            qvl_number_of_Initfc2_NP_dllps_posedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc2_NP_dllps +
                                       number_of_Initfc2_NP_dllps_temp;
            qvl_number_of_Initfc2_Cpl_dllps_posedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Initfc2_Cpl_dllps +
                                      number_of_Initfc2_Cpl_dllps_temp;
            qvl_number_of_Updatefc_P_dllps_posedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Updatefc_P_dllps +
                                      number_of_Updatefc_P_dllps_temp;
            qvl_number_of_Updatefc_NP_dllps_posedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Updatefc_NP_dllps +
                                       number_of_Updatefc_NP_dllps_temp;
            qvl_number_of_Updatefc_Cpl_dllps_posedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Updatefc_Cpl_dllps +
                                      number_of_Updatefc_Cpl_dllps_temp;
            qvl_number_of_PM_Enter_L1_dllps_posedge <= `ZiCwDebugDelay1
                                          qvl_number_of_PM_Enter_L1_dllps +
                                      number_of_PM_Enter_L1_dllps_temp;
            qvl_number_of_PM_Enter_L23_dllps_posedge <= `ZiCwDebugDelay1
                                         qvl_number_of_PM_Enter_L23_dllps +
                                     number_of_PM_Enter_L23_dllps_temp;
            qvl_number_of_PM_Act_Req_L0_dllps_posedge <= `ZiCwDebugDelay1
                                        qvl_number_of_PM_Act_Req_L0_dllps +
                                    number_of_PM_Act_Req_L0_dllps_temp;
            qvl_number_of_PM_Act_Req_L1_dllps_posedge <= `ZiCwDebugDelay1
                                        qvl_number_of_PM_Act_Req_L1_dllps +
                                    number_of_PM_Act_Req_L1_dllps_temp;
            qvl_number_of_PM_Req_Ack_dllps_posedge <= `ZiCwDebugDelay1
                                         qvl_number_of_PM_Req_Ack_dllps +
                                     number_of_PM_Req_Ack_dllps_temp;
            qvl_number_of_vendor_specific_dllps_posedge <= `ZiCwDebugDelay1
                                     qvl_number_of_vendor_specific_dllps +
                                 number_of_vendor_specific_dllps_temp;
            qvl_number_of_retransmissions_from_retry_buffer_posedge <= `ZiCwDebugDelay1 
                             qvl_number_of_retransmissions_from_retry_buffer +
                         number_of_retransmissions_from_retry_buffer_temp;
            qvl_num_duplicate_tlps_posedge <= `ZiCwDebugDelay1
                                              qvl_num_duplicate_tlps +
                                               num_duplicate_tlps_temp;
	// Gen2 statistics
	if(PCI_EXPRESS_GEN2 == 1 && current_speed_5gt === 1'b1)
	  begin
	    qvl_number_of_Ack_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Ack_dllps_gen2 + number_of_Ack_dllps_temp;
	    qvl_number_of_Updatefc_P_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_P_dllps_gen2 + number_of_Updatefc_P_dllps_temp;
            qvl_number_of_Updatefc_NP_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_NP_dllps_gen2 + number_of_Updatefc_NP_dllps_temp;
            qvl_number_of_Updatefc_Cpl_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_Cpl_dllps_gen2 + number_of_Updatefc_Cpl_dllps_temp;
	  end
	else
	  begin
	    qvl_number_of_Ack_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Ack_dllps_gen2;
	    qvl_number_of_Updatefc_P_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_P_dllps_gen2;
            qvl_number_of_Updatefc_NP_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_NP_dllps_gen2;
            qvl_number_of_Updatefc_Cpl_dllps_gen2_posedge <= `ZiCwDebugDelay1
                     qvl_number_of_Updatefc_Cpl_dllps_gen2;
	  end
      end // collect_stats
   end

  // Statistics logic active on posedge of the clk
 
  always @ (posedge clk)
    begin
      if(areset === 1'b0 && reset === 1'b0 && collect_stats === 1'b1)
        begin
 
          // PHY layer cornercases

          // TL packets

          if(inc_tlp)
	    qvl_tl_packets_posedge <= `ZiCwDebugDelay1 qvl_tl_packets + tlp_count;
          else
            qvl_tl_packets_posedge <= `ZiCwDebugDelay1 qvl_tl_packets;

          // DLL packets
          if(inc_dllp)
	    qvl_dll_packets_posedge <= `ZiCwDebugDelay1 qvl_dll_packets + dllp_count;
          else
            qvl_dll_packets_posedge <= `ZiCwDebugDelay1 qvl_dll_packets;

          // Nullified TLPs

          if(inc_nullified_tlp)
            qvl_nullified_tlps_posedge <= `ZiCwDebugDelay1 qvl_nullified_tlps + 1'b1;
          else
            qvl_nullified_tlps_posedge <= `ZiCwDebugDelay1 qvl_nullified_tlps;
 
          // TS1 ordered sets

          if(inc_ts1_os)
            qvl_ts1_os_posedge <= `ZiCwDebugDelay1 qvl_ts1_os + 1'b1;
	  else
	    qvl_ts1_os_posedge <= `ZiCwDebugDelay1 qvl_ts1_os;

	  	    
          // TS2 ordered sets

          if(inc_ts2_os)
            qvl_ts2_os_posedge <= `ZiCwDebugDelay1 qvl_ts2_os + 1'b1;
          else
            qvl_ts2_os_posedge <= `ZiCwDebugDelay1 qvl_ts2_os;

          // TS1/TS2 ordered sets with reset bit set

          if(inc_reset)
            begin
              qvl_ts1_ts2_os_reset_posedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_reset + 1'b1;
            end
          else
            begin
              qvl_ts1_ts2_os_reset_posedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_reset;
            end

          // TS1/TS2 ordered sets with loopback bit set

          if(inc_loopback)
            begin
              qvl_ts1_ts2_os_loopback_posedge <= `ZiCwDebugDelay1
                   qvl_ts1_ts2_os_loopback + 1'b1;
            end
          else
            begin
              qvl_ts1_ts2_os_loopback_posedge <= `ZiCwDebugDelay1 
                   qvl_ts1_ts2_os_loopback;
            end

          // TS1/TS2 ordered sets with disable bit set

          if(inc_disable)
            begin
              qvl_ts1_ts2_os_disable_posedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_disable + 1'b1;
            end 
          else
            begin
              qvl_ts1_ts2_os_disable_posedge <= `ZiCwDebugDelay1 
                  qvl_ts1_ts2_os_disable;
            end

          // TS1/TS2 ordered sets with no scramble bit set

          if(inc_no_scramble)
            begin
              qvl_ts1_ts2_os_no_scramble_posedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_no_scramble + 1'b1;
            end  
          else
            begin
              qvl_ts1_ts2_os_no_scramble_posedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_no_scramble;
            end

          // FTS ordered sets

          if(inc_fts_os)
            qvl_fts_os_posedge <= `ZiCwDebugDelay1 qvl_fts_os + 1'b1;
          else
            qvl_fts_os_posedge <= `ZiCwDebugDelay1 qvl_fts_os;

          // IDLE ordered sets

          if(inc_idle_os)
            qvl_idle_os_posedge <= `ZiCwDebugDelay1 qvl_idle_os + 1'b1;
          else
            qvl_idle_os_posedge <= `ZiCwDebugDelay1 qvl_idle_os;

  // PCI_EXPRESS_GEN2 code start
	  if(PCI_EXPRESS_GEN2 == 1)
	    begin 
	      // IDLE ordered sets on gen2 speed
              if(inc_idle_os && current_speed_5gt == 1'b1)
                qvl_idle_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_idle_os_gen2 + 1'b1;
              else
                qvl_idle_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_idle_os_gen2;
	      
	      // FTS ordered sets on gen2 speed
              if(inc_fts_os && current_speed_5gt == 1'b1)
                qvl_fts_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_fts_os_gen2 + 1'b1;
              else
                qvl_fts_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_fts_os_gen2;
	      
	      // EIE ordered sets
	      if(inc_eie_os && current_speed_5gt == 1'b1)
                qvl_eie_os_posedge <= `ZiCwDebugDelay1 qvl_eie_os + 1'b1;
              else
                qvl_eie_os_posedge <= `ZiCwDebugDelay1 qvl_eie_os;
	      
	      // TS1 ordered sets with speed change bit set
              if(inc_ts1_os && inc_speed_change)
                qvl_ts1_os_with_speed_change_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_speed_change_bit + 1'b1;
	      else
	        qvl_ts1_os_with_speed_change_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_speed_change_bit;
	      
	      // TS2 ordered sets with speed change bit set
              if(inc_ts2_os && inc_speed_change)
                qvl_ts2_os_with_speed_change_bit_posedge <= `ZiCwDebugDelay1 qvl_ts2_os_with_speed_change_bit + 1'b1;
	      else
	        qvl_ts2_os_with_speed_change_bit_posedge <= `ZiCwDebugDelay1 qvl_ts2_os_with_speed_change_bit;
	      
	      // TS1/TS2 ordered sets with 2.5 GT/s data rate
              if((inc_ts1_os || inc_ts2_os)  && current_speed_5gt == 1'b0)
                qvl_ts1_ts2_os_gen1_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen1 + 1'b1;
	      else
	        qvl_ts1_ts2_os_gen1_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen1;

	      // TS1/TS2 ordered sets with 5 GT/s data rate
              if((inc_ts1_os || inc_ts2_os)  && current_speed_5gt == 1'b1)
                qvl_ts1_ts2_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen2 + 1'b1;
	      else
	        qvl_ts1_ts2_os_gen2_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen2;

	      // TS1/TS2 ordered sets with autonomous bit 
              if(inc_autonomous)
                qvl_ts1_ts2_os_with_autonomous_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_with_autonomous_bit + 1'b1;
	      else
	        qvl_ts1_ts2_os_with_autonomous_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_with_autonomous_bit;

	      // TS1 ordered sets with complaince receive bit 
              if(inc_compliance_receive && inc_ts1_os)
                qvl_ts1_os_with_compliance_rx_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_compliance_rx_bit + 1'b1;
	      else
	        qvl_ts1_os_with_compliance_rx_bit_posedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_compliance_rx_bit;
	      
	      // More than 4 EIE symbol on gen2 before FTS
              if(inc_skp_os && inc_eie_before_fts_count > 4)
                qvl_mt_4_eie_before_fts_posedge <= `ZiCwDebugDelay1 qvl_mt_4_eie_before_fts + 1'b1;
	      else
	        qvl_mt_4_eie_before_fts_posedge <= `ZiCwDebugDelay1 qvl_mt_4_eie_before_fts;

	      // Speed change through L1
	      if(ltssm_present_state === ZI_LTSSM_L1_STATE && inc_ts1_os && inc_speed_change)
		qvl_speed_change_through_l1_posedge <= `ZiCwDebugDelay1 qvl_speed_change_through_l1 + 1'b1;
	      else
		qvl_speed_change_through_l1_posedge <= `ZiCwDebugDelay1 qvl_speed_change_through_l1;
	      
	      // State transtion to Recovery Speed from reco Lk after timeout
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_SPEED_STATE)
		qvl_reco_lk_to_reco_speed_after_timeout_posedge <= `ZiCwDebugDelay1 qvl_reco_lk_to_reco_speed_after_timeout + 1'b1;
	      else
		qvl_reco_lk_to_reco_speed_after_timeout_posedge <= `ZiCwDebugDelay1 qvl_reco_lk_to_reco_speed_after_timeout;
	      
              // State transtion to L0s on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && ltssm_next_state === ZI_LTSSM_TX_L0s_STATE && current_speed_5gt == 1'b1)
		qvl_l0s_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l0s_transtion_on_5gt + 1'b1;
	      else
		qvl_l0s_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l0s_transtion_on_5gt;
	      
	      // State transtion to L1 on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && ltssm_next_state === ZI_LTSSM_L1_STATE && current_speed_5gt == 1'b1)
		qvl_l1_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l1_transtion_on_5gt + 1'b1;
	      else
		qvl_l1_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l1_transtion_on_5gt;
	      
	      // State transtion to L2 on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && ltssm_next_state === ZI_LTSSM_L2_STATE && current_speed_5gt == 1'b1)
		qvl_l2_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l2_transtion_on_5gt + 1'b1;
	      else
		qvl_l2_transtion_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_l2_transtion_on_5gt;
	      
	      // Polling compliance state transtion
	      if(ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE && ltssm_next_state === ZI_LTSSM_POLLING_COMPLIANCE_STATE)
		qvl_polling_compliance_transtion_posedge  <= `ZiCwDebugDelay1 qvl_polling_compliance_transtion + 1'b1;
	      else
		qvl_polling_compliance_transtion_posedge  <= `ZiCwDebugDelay1 qvl_polling_compliance_transtion;
	      
	      // State transition to Recovery Speed from Recovery Cfg.
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_SPEED_STATE)
		qvl_reco_cfg_to_reco_speed_transtion_posedge <= `ZiCwDebugDelay1 qvl_reco_cfg_to_reco_speed_transtion + 1'b1;
	      else
		qvl_reco_cfg_to_reco_speed_transtion_posedge <= `ZiCwDebugDelay1 qvl_reco_cfg_to_reco_speed_transtion;

	      // Speed change attemp on speed 2.5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && inc_ts1_os && inc_speed_change && current_speed_5gt == 1'b0)
		qvl_speed_change_attemp_on_2_5gt_posedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_2_5gt + 1'b1;
	      else
		qvl_speed_change_attemp_on_2_5gt_posedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_2_5gt;

	      // Speed change attemp on speed 5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && inc_ts1_os && inc_speed_change && current_speed_5gt == 1'b1)
		qvl_speed_change_attemp_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_5gt + 1'b1;
	      else
		qvl_speed_change_attemp_on_5gt_posedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_5gt;
	      
	      // Successfull speed change to speed 2.5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE 
		 && changed_speed_recovery === 1'b1 && current_speed_5gt == 1'b0)
		qvl_successfull_speed_change_to_2_5gt_posedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_2_5gt + 1'b1;
	      else
		qvl_successfull_speed_change_to_2_5gt_posedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_2_5gt;

	      // Successfull speed change to speed 5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE 
		 && changed_speed_recovery === 1'b1 && current_speed_5gt == 1'b1)
		qvl_successfull_speed_change_to_5gt_posedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_5gt + 1'b1;
	      else
		qvl_successfull_speed_change_to_5gt_posedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_5gt;

	      // Modified compliance pattern
	      if(inc_modified_compliance_pattern)
		qvl_modified_compliance_pattern_posedge <= `ZiCwDebugDelay1 qvl_modified_compliance_pattern + 1'b1;
	      else
		qvl_modified_compliance_pattern_posedge <= `ZiCwDebugDelay1 qvl_modified_compliance_pattern;
	     end
 // PCI_EXPRESS_GEN2 code end
	  
          // SKP ordered sets

          if(inc_skp_os)
            qvl_skp_os_posedge <= `ZiCwDebugDelay1 qvl_skp_os + 1'b1;
          else
            qvl_skp_os_posedge <= `ZiCwDebugDelay1 qvl_skp_os;

          // STP and SDP symbols in a symbol time

          if(inc_sdp_stp)
            begin
              qvl_stp_sdp_in_symbol_time_posedge <= `ZiCwDebugDelay1
                   qvl_stp_sdp_in_symbol_time + 1'b1;
            end
          else
            begin
              qvl_stp_sdp_in_symbol_time_posedge <= `ZiCwDebugDelay1
                   qvl_stp_sdp_in_symbol_time;
            end

          // PAD symbol occurrences

          if(inc_pad)
            qvl_pad_symbols_posedge <= `ZiCwDebugDelay1 qvl_pad_symbols + 1'b1;
          else
            qvl_pad_symbols_posedge <= `ZiCwDebugDelay1 qvl_pad_symbols;

          // Count the number of symbol times where more than
	  // one packet ended in a symbol time.

	  if(inc_end)
	    begin
	      qvl_more_than_one_pkt_detected_count_posedge <= `ZiCwDebugDelay1 
		     qvl_more_than_one_pkt_detected_count + 1'b1;
            end
          else
	    begin
	      qvl_more_than_one_pkt_detected_count_posedge <= `ZiCwDebugDelay1
		     qvl_more_than_one_pkt_detected_count;
            end

          // Count the number of symbol times where an STP packet
	  // is detected on a non zero lane.

	  if(inc_stp_on_non_zero_lane)
	    qvl_non_zero_stp_count_posedge <= `ZiCwDebugDelay1 qvl_non_zero_stp_count + 1'b1;
          else
	    qvl_non_zero_stp_count_posedge <= `ZiCwDebugDelay1 qvl_non_zero_stp_count;

          //------------------------------------------------------------
          // Transaction layer statistics
          //------------------------------------------------------------

          // Update the statistics
             
          qvl_memory_read_requests_posedge <= `ZiCwDebugDelay1
            num_memory_read_requests + qvl_memory_read_requests;
          qvl_memory_write_requests_posedge <= `ZiCwDebugDelay1
            num_memory_write_requests + qvl_memory_write_requests;
          qvl_io_read_requests_posedge <= `ZiCwDebugDelay1
            num_io_read_requests + qvl_io_read_requests;
          qvl_io_write_requests_posedge <= `ZiCwDebugDelay1
            num_io_write_requests + qvl_io_write_requests;
          qvl_type0_cfg_read_requests_posedge <= `ZiCwDebugDelay1
            num_type0_cfg_read_requests + qvl_type0_cfg_read_requests;
          qvl_type0_cfg_write_requests_posedge <= `ZiCwDebugDelay1
	    num_type0_cfg_write_requests + qvl_type0_cfg_write_requests;
          qvl_type1_cfg_read_requests_posedge <= `ZiCwDebugDelay1
            num_type1_cfg_read_requests + qvl_type1_cfg_read_requests;
          qvl_type1_cfg_write_requests_posedge <= `ZiCwDebugDelay1
            num_type1_cfg_write_requests + qvl_type1_cfg_write_requests;
          qvl_message_requests_posedge <= `ZiCwDebugDelay1
            num_message_requests + qvl_message_requests;
          qvl_locked_memory_requests_posedge <= `ZiCwDebugDelay1
            num_locked_memory_requests + qvl_locked_memory_requests;
          qvl_completions_posedge <= `ZiCwDebugDelay1 num_completions + qvl_completions;
          qvl_locked_completions_posedge <= `ZiCwDebugDelay1 
	    num_locked_completions + qvl_locked_completions;
          qvl_ur_completions_posedge <= `ZiCwDebugDelay1
            num_ur_completions + qvl_ur_completions;
          qvl_completer_aborts_posedge <= `ZiCwDebugDelay1
            num_completer_aborts + qvl_completer_aborts;
          qvl_completions_with_cfg_retry_posedge <= `ZiCwDebugDelay1
            num_completions_with_cfg_retry + qvl_completions_with_cfg_retry;
	  
  // PCI_EXPRESS_GEN2 code start
	  if(PCI_EXPRESS_GEN2 == 1)
	    begin
	      qvl_deprecated_requests_posedge <= `ZiCwDebugDelay1
		num_deprecated_requests + qvl_deprecated_requests;
	      qvl_memory_translation_requests_posedge <= `ZiCwDebugDelay1
                num_memory_translation_requests + qvl_memory_translation_requests;
	      qvl_memory_translated_requests_posedge  <= `ZiCwDebugDelay1
                num_memory_translated_requests + qvl_memory_translated_requests;
	    end
	  else
	    begin
	      qvl_deprecated_requests_posedge <= `ZiCwDebugDelay1 qvl_deprecated_requests;
	      qvl_memory_translation_requests_posedge <= `ZiCwDebugDelay1 qvl_memory_translation_requests;
	      qvl_memory_translated_requests_posedge  <= `ZiCwDebugDelay1 qvl_memory_translated_requests;
	    end

	  if(PCI_EXPRESS_GEN2 == 1 && current_speed_5gt === 1'b1)
	    begin 
	      qvl_memory_read_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_memory_read_requests + qvl_memory_read_requests_gen2;
	      qvl_memory_write_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_memory_write_requests + qvl_memory_write_requests_gen2;
              qvl_io_read_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_io_read_requests + qvl_io_read_requests_gen2;
	      qvl_io_write_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_io_write_requests + qvl_io_write_requests_gen2;
	      qvl_type0_cfg_read_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_type0_cfg_read_requests + qvl_type0_cfg_read_requests_gen2;
	      qvl_type0_cfg_write_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_type0_cfg_write_requests + qvl_type0_cfg_write_requests_gen2;
	      qvl_type1_cfg_read_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_type1_cfg_read_requests + qvl_type1_cfg_read_requests_gen2;
	      qvl_type1_cfg_write_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_type1_cfg_write_requests + qvl_type1_cfg_write_requests_gen2;
	      qvl_message_requests_gen2_posedge <= `ZiCwDebugDelay1
	        num_message_requests + qvl_message_requests_gen2;
	      qvl_completions_gen2_posedge <= `ZiCwDebugDelay1
	        num_completions + qvl_completions_gen2;
	    end
	  else
	    begin
	      qvl_memory_read_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_memory_read_requests_gen2;
	      qvl_memory_write_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_memory_write_requests_gen2;
              qvl_io_read_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_io_read_requests_gen2;
	      qvl_io_write_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_io_write_requests_gen2;
	      qvl_type0_cfg_read_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_type0_cfg_read_requests_gen2;
	      qvl_type0_cfg_write_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_type0_cfg_write_requests_gen2;
	      qvl_type1_cfg_read_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_type1_cfg_read_requests_gen2;
	      qvl_type1_cfg_write_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_type1_cfg_write_requests_gen2;
	      qvl_message_requests_gen2_posedge <= `ZiCwDebugDelay1 qvl_message_requests_gen2;
	      qvl_completions_gen2_posedge <= `ZiCwDebugDelay1 qvl_completions_gen2;
	    end
  // PCI_EXPRESS_GEN2 code end
	  
          if(inc_tlps_with_digests === 2'b11) 
            begin 
              qvl_tlps_with_digests_posedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_digests + 2'b10;
            end
          else if(inc_tlps_with_digests === 2'b01) 
            begin 
              qvl_tlps_with_digests_posedge <= `ZiCwDebugDelay1 
                                     qvl_tlps_with_digests + 1'b1; 
            end
          else
            qvl_tlps_with_digests_posedge <= `ZiCwDebugDelay1 qvl_tlps_with_digests;  
 
          if(inc_tlps_with_ecrc === 2'b11) 
            begin
              qvl_tlps_with_ecrc_posedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_ecrc + 2'b10;
            end 
          else if(inc_tlps_with_ecrc === 2'b01)  
            begin 
              qvl_tlps_with_ecrc_posedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_ecrc + 1'b1; 
            end
          else
            qvl_tlps_with_ecrc_posedge <= `ZiCwDebugDelay1 qvl_tlps_with_ecrc;

          if(inc_tlps_with_lcrc === 2'b11)
	    begin
	      qvl_tlps_with_lcrc_posedge <= `ZiCwDebugDelay1
				   qvl_tlps_with_lcrc + 2'b10;
            end
          else if(inc_tlps_with_lcrc === 2'b01)
	    begin
	      qvl_tlps_with_lcrc_posedge <= `ZiCwDebugDelay1
				   qvl_tlps_with_lcrc + 1'b1;
            end
          else
	    qvl_tlps_with_lcrc_posedge <= `ZiCwDebugDelay1 qvl_tlps_with_lcrc;

          if(inc_malformed_tlps === 2'b11)
            begin
              qvl_malformed_tlps_posedge <= `ZiCwDebugDelay1 
                                    qvl_malformed_tlps + 2'b10;
            end
          else if(inc_malformed_tlps === 2'b01)
            begin
              qvl_malformed_tlps_posedge <= `ZiCwDebugDelay1
                                    qvl_malformed_tlps + 2'b01;
            end
          else
            qvl_malformed_tlps_posedge <= `ZiCwDebugDelay1 qvl_malformed_tlps;
        end // End of if
   end // End of always

   // DDR
   always @(negedge clk or posedge areset)
   begin
      if(areset !== 1'b0)
      begin
         // Do Nothing
      end
      else if(reset !== 1'b0)
      begin
         // Do Nothing
      end
      else if(collect_stats === 1'b1 && DOUBLE_DATA_RATE == 1)
      begin
            // Corner Cases
            qvl_number_of_Ack_dllps_negedge <= `ZiCwDebugDelay1
                     qvl_number_of_Ack_dllps + number_of_Ack_dllps_temp;
            qvl_number_of_Nak_dllps_negedge <= `ZiCwDebugDelay1
                     qvl_number_of_Nak_dllps + number_of_Nak_dllps_temp;
            qvl_number_of_Initfc1_P_dllps_negedge <= `ZiCwDebugDelay1
                                             qvl_number_of_Initfc1_P_dllps +
                                         number_of_Initfc1_P_dllps_temp;
            qvl_number_of_Initfc1_NP_dllps_negedge <= `ZiCwDebugDelay1
                                            qvl_number_of_Initfc1_NP_dllps +
                                        number_of_Initfc1_NP_dllps_temp;
            qvl_number_of_Initfc1_Cpl_dllps_negedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc1_Cpl_dllps +
                                       number_of_Initfc1_Cpl_dllps_temp;
            qvl_number_of_Initfc2_P_dllps_negedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc2_P_dllps +
                                       number_of_Initfc2_P_dllps_temp;
            qvl_number_of_Initfc2_NP_dllps_negedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Initfc2_NP_dllps +
                                       number_of_Initfc2_NP_dllps_temp;
            qvl_number_of_Initfc2_Cpl_dllps_negedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Initfc2_Cpl_dllps +
                                      number_of_Initfc2_Cpl_dllps_temp;
            qvl_number_of_Updatefc_P_dllps_negedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Updatefc_P_dllps +
                                      number_of_Updatefc_P_dllps_temp;
            qvl_number_of_Updatefc_NP_dllps_negedge <= `ZiCwDebugDelay1
                                           qvl_number_of_Updatefc_NP_dllps +
                                       number_of_Updatefc_NP_dllps_temp;
            qvl_number_of_Updatefc_Cpl_dllps_negedge <= `ZiCwDebugDelay1
                                          qvl_number_of_Updatefc_Cpl_dllps +
                                      number_of_Updatefc_Cpl_dllps_temp;
            qvl_number_of_PM_Enter_L1_dllps_negedge <= `ZiCwDebugDelay1
                                          qvl_number_of_PM_Enter_L1_dllps +
                                      number_of_PM_Enter_L1_dllps_temp;
            qvl_number_of_PM_Enter_L23_dllps_negedge <= `ZiCwDebugDelay1
                                         qvl_number_of_PM_Enter_L23_dllps +
                                     number_of_PM_Enter_L23_dllps_temp;
            qvl_number_of_PM_Act_Req_L0_dllps_negedge <= `ZiCwDebugDelay1
                                        qvl_number_of_PM_Act_Req_L0_dllps +
                                    number_of_PM_Act_Req_L0_dllps_temp;
            qvl_number_of_PM_Act_Req_L1_dllps_negedge <= `ZiCwDebugDelay1
                                        qvl_number_of_PM_Act_Req_L1_dllps +
                                    number_of_PM_Act_Req_L1_dllps_temp;
            qvl_number_of_PM_Req_Ack_dllps_negedge <= `ZiCwDebugDelay1
                                         qvl_number_of_PM_Req_Ack_dllps +
                                     number_of_PM_Req_Ack_dllps_temp;
            qvl_number_of_vendor_specific_dllps_negedge <= `ZiCwDebugDelay1
                                     qvl_number_of_vendor_specific_dllps +
                                 number_of_vendor_specific_dllps_temp;
            qvl_number_of_retransmissions_from_retry_buffer_negedge <= `ZiCwDebugDelay1 
                             qvl_number_of_retransmissions_from_retry_buffer +
                         number_of_retransmissions_from_retry_buffer_temp;
            qvl_num_duplicate_tlps_negedge <= `ZiCwDebugDelay1
                                              qvl_num_duplicate_tlps +
                                               num_duplicate_tlps_temp;

	    // Gen2 statistics
	    if(PCI_EXPRESS_GEN2 == 1 && current_speed_5gt === 1'b1)
	      begin
	        qvl_number_of_Ack_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Ack_dllps_gen2 + number_of_Ack_dllps_temp;
	        qvl_number_of_Updatefc_P_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_P_dllps_gen2 + number_of_Updatefc_P_dllps_temp;
                qvl_number_of_Updatefc_NP_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_NP_dllps_gen2 + number_of_Updatefc_NP_dllps_temp;
                qvl_number_of_Updatefc_Cpl_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_Cpl_dllps_gen2 + number_of_Updatefc_Cpl_dllps_temp;
	      end
	    else
	      begin
	        qvl_number_of_Ack_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Ack_dllps_gen2;
	        qvl_number_of_Updatefc_P_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_P_dllps_gen2;
                qvl_number_of_Updatefc_NP_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_NP_dllps_gen2;
                qvl_number_of_Updatefc_Cpl_dllps_gen2_negedge <= `ZiCwDebugDelay1
                         qvl_number_of_Updatefc_Cpl_dllps_gen2;
	      end
      end // collect_stats
   end

  // Statistics logic active on negedge of the clk
 
  always @ (negedge clk)
    begin
      if(areset === 1'b0 && reset === 1'b0 && collect_stats === 1'b1 &&
         DOUBLE_DATA_RATE == 1)
        begin
 
          // PHY layer cornercases

          // TL packets

          if(inc_tlp)
	    qvl_tl_packets_negedge <= `ZiCwDebugDelay1 qvl_tl_packets + tlp_count;
          else
            qvl_tl_packets_negedge <= `ZiCwDebugDelay1 qvl_tl_packets;

          // DLL packets
          if(inc_dllp)
	    qvl_dll_packets_negedge <= `ZiCwDebugDelay1 qvl_dll_packets + dllp_count;
          else
            qvl_dll_packets_negedge <= `ZiCwDebugDelay1 qvl_dll_packets;

          // Nullified TLPs

          if(inc_nullified_tlp)
            qvl_nullified_tlps_negedge <= `ZiCwDebugDelay1 qvl_nullified_tlps + 1'b1;
          else
            qvl_nullified_tlps_negedge <= `ZiCwDebugDelay1 qvl_nullified_tlps;
 
          // TS1 ordered sets

          if(inc_ts1_os)
            qvl_ts1_os_negedge <= `ZiCwDebugDelay1 qvl_ts1_os + 1'b1;
	  else
	    qvl_ts1_os_negedge <= `ZiCwDebugDelay1 qvl_ts1_os;
 
          // TS2 ordered sets

          if(inc_ts2_os)
            qvl_ts2_os_negedge <= `ZiCwDebugDelay1 qvl_ts2_os + 1'b1;
          else
            qvl_ts2_os_negedge <= `ZiCwDebugDelay1 qvl_ts2_os;

          // TS1/TS2 ordered sets with reset bit set

          if(inc_reset)
            begin
              qvl_ts1_ts2_os_reset_negedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_reset + 1'b1;
            end
          else
            begin
              qvl_ts1_ts2_os_reset_negedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_reset;
            end

          // TS1/TS2 ordered sets with loopback bit set

          if(inc_loopback)
            begin
              qvl_ts1_ts2_os_loopback_negedge <= `ZiCwDebugDelay1
                   qvl_ts1_ts2_os_loopback + 1'b1;
            end
          else
            begin
              qvl_ts1_ts2_os_loopback_negedge <= `ZiCwDebugDelay1 
                   qvl_ts1_ts2_os_loopback;
            end

          // TS1/TS2 ordered sets with disable bit set

          if(inc_disable)
            begin
              qvl_ts1_ts2_os_disable_negedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_disable + 1'b1;
            end 
          else
            begin
              qvl_ts1_ts2_os_disable_negedge <= `ZiCwDebugDelay1 
                  qvl_ts1_ts2_os_disable;
            end

          // TS1/TS2 ordered sets with no scramble bit set

          if(inc_no_scramble)
            begin
              qvl_ts1_ts2_os_no_scramble_negedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_no_scramble + 1'b1;
            end  
          else
            begin
              qvl_ts1_ts2_os_no_scramble_negedge <= `ZiCwDebugDelay1
                  qvl_ts1_ts2_os_no_scramble;
            end

          // FTS ordered sets

          if(inc_fts_os)
            qvl_fts_os_negedge <= `ZiCwDebugDelay1 qvl_fts_os + 1'b1;
          else
            qvl_fts_os_negedge <= `ZiCwDebugDelay1 qvl_fts_os;

          // IDLE ordered sets

          if(inc_idle_os)
            qvl_idle_os_negedge <= `ZiCwDebugDelay1 qvl_idle_os + 1'b1;
          else
            qvl_idle_os_negedge <= `ZiCwDebugDelay1 qvl_idle_os;

	  
  // PCI_EXPRESS_GEN2 code start
	  if(PCI_EXPRESS_GEN2 == 1)
	    begin 
	      // IDLE ordered sets on gen2 speed
              if(inc_idle_os && current_speed_5gt == 1'b1)
                qvl_idle_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_idle_os_gen2 + 1'b1;
              else
                qvl_idle_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_idle_os_gen2;
	      
	      // FTS ordered sets on gen2 speed
              if(inc_fts_os && current_speed_5gt == 1'b1)
                qvl_fts_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_fts_os_gen2 + 1'b1;
              else
                qvl_fts_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_fts_os_gen2;
	      
	      // EIE ordered sets
	      if(inc_eie_os && current_speed_5gt == 1'b1)
                qvl_eie_os_negedge <= `ZiCwDebugDelay1 qvl_eie_os + 1'b1;
              else
                qvl_eie_os_negedge <= `ZiCwDebugDelay1 qvl_eie_os;
               
	      // TS1 ordered sets with speed change bit set
              if(inc_ts1_os && inc_speed_change)
                qvl_ts1_os_with_speed_change_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_speed_change_bit + 1'b1;
	      else
	        qvl_ts1_os_with_speed_change_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_speed_change_bit;
	      
	      // TS2 ordered sets with speed change bit set
              if(inc_ts2_os && inc_speed_change)
                qvl_ts2_os_with_speed_change_bit_negedge <= `ZiCwDebugDelay1 qvl_ts2_os_with_speed_change_bit + 1'b1;
	      else
	        qvl_ts2_os_with_speed_change_bit_negedge <= `ZiCwDebugDelay1 qvl_ts2_os_with_speed_change_bit;

	     // TS1/TS2 ordered sets with 2.5 GT/s data rate
              if((inc_ts1_os || inc_ts2_os)  && current_speed_5gt == 1'b0)
                qvl_ts1_ts2_os_gen1_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen1 + 1'b1;
	      else
	        qvl_ts1_ts2_os_gen1_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen1;

	      // TS1/TS2 ordered sets with 5 GT/s data rate
              if((inc_ts1_os || inc_ts2_os)  && current_speed_5gt == 1'b1)
                qvl_ts1_ts2_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen2 + 1'b1;
	      else
	        qvl_ts1_ts2_os_gen2_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_gen2;

	      // TS1/TS2 ordered sets with autonomous bit 
              if(inc_autonomous)
                qvl_ts1_ts2_os_with_autonomous_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_with_autonomous_bit + 1'b1;
	      else
	        qvl_ts1_ts2_os_with_autonomous_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_ts2_os_with_autonomous_bit;

	      // TS1 ordered sets with complaince receive bit 
              if(inc_compliance_receive && inc_ts1_os)
                qvl_ts1_os_with_compliance_rx_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_compliance_rx_bit + 1'b1;
	      else
	        qvl_ts1_os_with_compliance_rx_bit_negedge <= `ZiCwDebugDelay1 qvl_ts1_os_with_compliance_rx_bit;
	      
	      // More than 4 EIE symbol on gen2 before FTS
              if(inc_skp_os && inc_eie_before_fts_count > 4)
                qvl_mt_4_eie_before_fts_negedge <= `ZiCwDebugDelay1 qvl_mt_4_eie_before_fts + 1'b1;
	      else
	        qvl_mt_4_eie_before_fts_negedge <= `ZiCwDebugDelay1 qvl_mt_4_eie_before_fts;

	      // Modified compliance pattern
	      if(inc_modified_compliance_pattern)
		qvl_modified_compliance_pattern_negedge <= `ZiCwDebugDelay1 qvl_modified_compliance_pattern + 1'b1;
	      else
		qvl_modified_compliance_pattern_negedge <= `ZiCwDebugDelay1 qvl_modified_compliance_pattern;

              // Speed change through L1
	      if(ltssm_present_state === ZI_LTSSM_L1_STATE && inc_ts1_os && inc_speed_change)
		qvl_speed_change_through_l1_negedge <= `ZiCwDebugDelay1 qvl_speed_change_through_l1 + 1'b1;
	      else
		qvl_speed_change_through_l1_negedge <= `ZiCwDebugDelay1 qvl_speed_change_through_l1;	
              
              // State transtion to Recovery Speed from reco Lk after timeout
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_LOCK_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_SPEED_STATE)
		qvl_reco_lk_to_reco_speed_after_timeout_negedge <= `ZiCwDebugDelay1 qvl_reco_lk_to_reco_speed_after_timeout + 1'b1;
	      else
		qvl_reco_lk_to_reco_speed_after_timeout_negedge <= `ZiCwDebugDelay1 qvl_reco_lk_to_reco_speed_after_timeout;
	      
              // State transtion to L0s on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_TX_L0s_STATE && current_speed_5gt == 1'b1)
		qvl_l0s_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l0s_transtion_on_5gt + 1'b1;
	      else
		qvl_l0s_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l0s_transtion_on_5gt;
	      
	      // State transtion to L1 on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_L1_STATE && current_speed_5gt == 1'b1)
		qvl_l1_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l1_transtion_on_5gt + 1'b1;
	      else
		qvl_l1_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l1_transtion_on_5gt;
	      
	      // State transtion to L2 on 5 GT speed
	      if(ltssm_present_state === ZI_LTSSM_L2_STATE && current_speed_5gt == 1'b1)
		qvl_l2_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l2_transtion_on_5gt + 1'b1;
	      else
		qvl_l2_transtion_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_l2_transtion_on_5gt;

	      // Polling compliance state transtion
	      if(ltssm_present_state === ZI_LTSSM_POLLING_ACTIVE_STATE && ltssm_next_state === ZI_LTSSM_POLLING_COMPLIANCE_STATE)
		qvl_polling_compliance_transtion_negedge  <= `ZiCwDebugDelay1 qvl_polling_compliance_transtion + 1'b1;
	      else
		qvl_polling_compliance_transtion_negedge  <= `ZiCwDebugDelay1 qvl_polling_compliance_transtion;
	      
	      // State transition to Recovery Speed from Recovery Cfg.
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_RCVRCFG_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_SPEED_STATE)
		qvl_reco_cfg_to_reco_speed_transtion_negedge <= `ZiCwDebugDelay1 qvl_reco_cfg_to_reco_speed_transtion + 1'b1;
	      else
		qvl_reco_cfg_to_reco_speed_transtion_negedge <= `ZiCwDebugDelay1 qvl_reco_cfg_to_reco_speed_transtion;

	      // Speed change attemp on speed 2.5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && inc_ts1_os && inc_speed_change && current_speed_5gt == 1'b0)
		qvl_speed_change_attemp_on_2_5gt_negedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_2_5gt + 1'b1;
	      else
		qvl_speed_change_attemp_on_2_5gt_negedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_2_5gt;

	      // Speed change attemp on speed 5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_L0_STATE && inc_ts1_os && inc_speed_change && current_speed_5gt == 1'b1)
		qvl_speed_change_attemp_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_5gt + 1'b1;
	      else
		qvl_speed_change_attemp_on_5gt_negedge <= `ZiCwDebugDelay1 qvl_speed_change_attemp_on_5gt;
	      
	      // Successfull speed change to speed 2.5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE 
		 && changed_speed_recovery === 1'b1 && current_speed_5gt == 1'b0)
		qvl_successfull_speed_change_to_2_5gt_negedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_2_5gt + 1'b1;
	      else
		qvl_successfull_speed_change_to_2_5gt_negedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_2_5gt;

	      // Successfull speed change to speed 5 GT/s
	      if(ltssm_present_state === ZI_LTSSM_RECOVERY_SPEED_STATE && ltssm_next_state === ZI_LTSSM_RECOVERY_LOCK_STATE 
		 && changed_speed_recovery === 1'b1 && current_speed_5gt == 1'b1)
		qvl_successfull_speed_change_to_5gt_negedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_5gt + 1'b1;
	      else
		qvl_successfull_speed_change_to_5gt_negedge <= `ZiCwDebugDelay1 qvl_successfull_speed_change_to_5gt;

	    end
  // PCI_EXPRESS_GEN2 code end
	  
          // SKP ordered sets

          if(inc_skp_os)
            qvl_skp_os_negedge <= `ZiCwDebugDelay1 qvl_skp_os + 1'b1;
          else
            qvl_skp_os_negedge <= `ZiCwDebugDelay1 qvl_skp_os;

          // STP and SDP symbols in a symbol time

          if(inc_sdp_stp)
            begin
              qvl_stp_sdp_in_symbol_time_negedge <= `ZiCwDebugDelay1
                   qvl_stp_sdp_in_symbol_time + 1'b1;
            end
          else
            begin
              qvl_stp_sdp_in_symbol_time_negedge <= `ZiCwDebugDelay1
                   qvl_stp_sdp_in_symbol_time;
            end

          // PAD symbol occurrences

          if(inc_pad)
            qvl_pad_symbols_negedge <= `ZiCwDebugDelay1 qvl_pad_symbols + 1'b1;
          else
            qvl_pad_symbols_negedge <= `ZiCwDebugDelay1 qvl_pad_symbols;

          // Count the number of symbol times where more than
	  // one packet ended in a symbol time.

	  if(inc_end)
	    begin
	      qvl_more_than_one_pkt_detected_count_negedge <= `ZiCwDebugDelay1 
		     qvl_more_than_one_pkt_detected_count + 1'b1;
            end
          else
	    begin
	      qvl_more_than_one_pkt_detected_count_negedge <= `ZiCwDebugDelay1
		     qvl_more_than_one_pkt_detected_count;
            end

          // Count the number of symbol times where an STP packet
	  // is detected on a non zero lane.

	  if(inc_stp_on_non_zero_lane)
	    qvl_non_zero_stp_count_negedge <= `ZiCwDebugDelay1 qvl_non_zero_stp_count + 1'b1;
          else
	    qvl_non_zero_stp_count_negedge <= `ZiCwDebugDelay1 qvl_non_zero_stp_count;

          //------------------------------------------------------------
          // Transaction layer statistics
          //------------------------------------------------------------

          // Update the statistics
             
          qvl_memory_read_requests_negedge <= `ZiCwDebugDelay1
            num_memory_read_requests + qvl_memory_read_requests;
          qvl_memory_write_requests_negedge <= `ZiCwDebugDelay1
            num_memory_write_requests + qvl_memory_write_requests;
          qvl_io_read_requests_negedge <= `ZiCwDebugDelay1
            num_io_read_requests + qvl_io_read_requests;
          qvl_io_write_requests_negedge <= `ZiCwDebugDelay1
            num_io_write_requests + qvl_io_write_requests;
          qvl_type0_cfg_read_requests_negedge <= `ZiCwDebugDelay1
            num_type0_cfg_read_requests + qvl_type0_cfg_read_requests;
          qvl_type0_cfg_write_requests_negedge <= `ZiCwDebugDelay1
	    num_type0_cfg_write_requests + qvl_type0_cfg_write_requests;
          qvl_type1_cfg_read_requests_negedge <= `ZiCwDebugDelay1
            num_type1_cfg_read_requests + qvl_type1_cfg_read_requests;
          qvl_type1_cfg_write_requests_negedge <= `ZiCwDebugDelay1
            num_type1_cfg_write_requests + qvl_type1_cfg_write_requests;
          qvl_message_requests_negedge <= `ZiCwDebugDelay1
            num_message_requests + qvl_message_requests;
          qvl_locked_memory_requests_negedge <= `ZiCwDebugDelay1
            num_locked_memory_requests + qvl_locked_memory_requests;
          qvl_completions_negedge <= `ZiCwDebugDelay1 num_completions + qvl_completions;
          qvl_locked_completions_negedge <= `ZiCwDebugDelay1 
	    num_locked_completions + qvl_locked_completions;
          qvl_ur_completions_negedge <= `ZiCwDebugDelay1
            num_ur_completions + qvl_ur_completions;
          qvl_completer_aborts_negedge <= `ZiCwDebugDelay1
            num_completer_aborts + qvl_completer_aborts;
          qvl_completions_with_cfg_retry_negedge <= `ZiCwDebugDelay1
            num_completions_with_cfg_retry + qvl_completions_with_cfg_retry;

  // PCI_EXPRESS_GEN2 code start
	  if(PCI_EXPRESS_GEN2 == 1)
	    begin 
	      qvl_deprecated_requests_negedge <= `ZiCwDebugDelay1
		num_deprecated_requests + qvl_deprecated_requests;
	      qvl_memory_translation_requests_negedge <= `ZiCwDebugDelay1
                num_memory_translation_requests + qvl_memory_translation_requests;
	      qvl_memory_translated_requests_negedge  <= `ZiCwDebugDelay1
                num_memory_translated_requests + qvl_memory_translated_requests;
	    end
	  else
	    begin
	      qvl_deprecated_requests_negedge <= `ZiCwDebugDelay1 qvl_deprecated_requests;
	      qvl_memory_translation_requests_posedge <= `ZiCwDebugDelay1 qvl_memory_translation_requests;
	      qvl_memory_translated_requests_posedge  <= `ZiCwDebugDelay1 qvl_memory_translated_requests;
	    end

	  if(PCI_EXPRESS_GEN2 == 1 && current_speed_5gt === 1'b1)
	    begin 
	      qvl_memory_read_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_memory_read_requests + qvl_memory_read_requests_gen2;
	      qvl_memory_write_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_memory_write_requests + qvl_memory_write_requests_gen2;
              qvl_io_read_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_io_read_requests + qvl_io_read_requests_gen2;
	      qvl_io_write_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_io_write_requests + qvl_io_write_requests_gen2;
	      qvl_type0_cfg_read_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_type0_cfg_read_requests + qvl_type0_cfg_read_requests_gen2;
	      qvl_type0_cfg_write_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_type0_cfg_write_requests + qvl_type0_cfg_write_requests_gen2;
	      qvl_type1_cfg_read_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_type1_cfg_read_requests + qvl_type1_cfg_read_requests_gen2;
	      qvl_type1_cfg_write_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_type1_cfg_write_requests + qvl_type1_cfg_write_requests_gen2;
	      qvl_message_requests_gen2_negedge <= `ZiCwDebugDelay1
	        num_message_requests + qvl_message_requests_gen2;
	      qvl_completions_gen2_negedge <= `ZiCwDebugDelay1
	        num_completions + qvl_completions_gen2;
	    end
	  else
	    begin
	      qvl_memory_read_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_memory_read_requests_gen2;
	      qvl_memory_write_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_memory_write_requests_gen2;
              qvl_io_read_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_io_read_requests_gen2;
	      qvl_io_write_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_io_write_requests_gen2;
	      qvl_type0_cfg_read_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_type0_cfg_read_requests_gen2;
	      qvl_type0_cfg_write_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_type0_cfg_write_requests_gen2;
	      qvl_type1_cfg_read_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_type1_cfg_read_requests_gen2;
	      qvl_type1_cfg_write_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_type1_cfg_write_requests_gen2;
	      qvl_message_requests_gen2_negedge <= `ZiCwDebugDelay1 qvl_message_requests_gen2;
	      qvl_completions_gen2_negedge <= `ZiCwDebugDelay1 qvl_completions_gen2;
	    end
  // PCI_EXPRESS_GEN2 code end	     
          if(inc_tlps_with_digests === 2'b11) 
            begin 
              qvl_tlps_with_digests_negedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_digests + 2'b10;
            end
          else if(inc_tlps_with_digests === 2'b01) 
            begin 
              qvl_tlps_with_digests_negedge <= `ZiCwDebugDelay1 
                                     qvl_tlps_with_digests + 1'b1; 
            end
          else
            qvl_tlps_with_digests_negedge <= `ZiCwDebugDelay1 qvl_tlps_with_digests;  
 
          if(inc_tlps_with_ecrc === 2'b11) 
            begin
              qvl_tlps_with_ecrc_negedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_ecrc + 2'b10;
            end 
          else if(inc_tlps_with_ecrc === 2'b01)  
            begin 
              qvl_tlps_with_ecrc_negedge <= `ZiCwDebugDelay1
                                     qvl_tlps_with_ecrc + 1'b1; 
            end
          else
            qvl_tlps_with_ecrc_negedge <= `ZiCwDebugDelay1 qvl_tlps_with_ecrc;

          if(inc_tlps_with_lcrc === 2'b11)
	    begin
	      qvl_tlps_with_lcrc_negedge <= `ZiCwDebugDelay1
				   qvl_tlps_with_lcrc + 2'b10;
            end
          else if(inc_tlps_with_lcrc === 2'b01)
	    begin
	      qvl_tlps_with_lcrc_negedge <= `ZiCwDebugDelay1
				   qvl_tlps_with_lcrc + 1'b1;
            end
          else
	    qvl_tlps_with_lcrc_negedge <= `ZiCwDebugDelay1 qvl_tlps_with_lcrc;

          if(inc_malformed_tlps === 2'b11)
            begin
              qvl_malformed_tlps_negedge <= `ZiCwDebugDelay1 
                                    qvl_malformed_tlps + 2'b10;
            end
          else if(inc_malformed_tlps === 2'b01)
            begin
              qvl_malformed_tlps_negedge <= `ZiCwDebugDelay1
                                    qvl_malformed_tlps + 2'b01;
            end
          else
            qvl_malformed_tlps_negedge <= `ZiCwDebugDelay1 qvl_malformed_tlps;
        end // End of if
   end // End of always

`ifdef QVL_SV_COVERGROUP

  covergroup pci_express_statistics @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for PCI-Express Monitor";

    S0 : coverpoint (!($stable(qvl_total_packets, @ (clk)))) iff(enable_coverpoint)
        {
        bins Number_of_packets = {1};
        type_option.comment = "Number of packets";
        }

    S1 : coverpoint (!($stable(qvl_more_than_one_pkt_detected_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins Multiple_packets_ending_in_a_symbol_time_count = {1};
        type_option.comment = "Multiple packets ending in a symbol time count";
        }

    S2 : coverpoint (!($stable(qvl_non_zero_stp_count, @ (clk)))) iff(enable_coverpoint)
        {
        bins TLPs_started_on_non_zero_lane = {1};
        type_option.comment = "TLPs started on non zero lane";
        }

    S3 : coverpoint (!($stable(qvl_tlps_with_ecrc, @ (clk)))) iff(enable_coverpoint)
        {
        bins TLPs_with_ECRC_Error = {1};
        type_option.comment = "TLPs with ECRC Error";
        }

    S4 : coverpoint (!($stable(qvl_tlps_with_lcrc, @ (clk)))) iff(enable_coverpoint)
        {
        bins TLPs_with_LCRC_Error = {1};
        type_option.comment = "TLPs with LCRC Error";
        }

    S5 : coverpoint (!($stable(qvl_malformed_tlps, @ (clk)))) iff(enable_coverpoint)
        {
        bins Malformed_TLPs = {1};
        type_option.comment = "Malformed TLPs";
        }

  endgroup : pci_express_statistics

  covergroup pci_express_cornercases @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for PCI-Express Monitor";

    C0 : coverpoint (!($stable(qvl_com_symbols, @ (clk)))) iff(enable_coverpoint)
        {
        bins COM_Symbols = {1};
        type_option.comment = "COM Symbols";
        }

    C1 : coverpoint (!($stable(qvl_tl_packets, @ (clk)))) iff(enable_coverpoint)
        {
        bins Transaction_layer_packets = {1};
        type_option.comment = "Transaction layer packets";
        }

    C2 : coverpoint (!($stable(qvl_dll_packets, @ (clk)))) iff(enable_coverpoint)
        {
        bins Data_link_layer_packets = {1};
        type_option.comment = "Data link layer packets";
        }

    C3 : coverpoint (!($stable(qvl_nullified_tlps, @ (clk)))) iff(enable_coverpoint)
        {
        bins Nullified_TLPs = {1};
        type_option.comment = "Nullified TLPs";
        }

    C4 : coverpoint (!($stable(qvl_ts1_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_ordered_sets = {1};
        type_option.comment = "TS1 ordered sets";
        }

    C5 : coverpoint (!($stable(qvl_ts2_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS2_ordered_sets = {1};
        type_option.comment = "TS2 ordered sets";
        }

    C6 : coverpoint (!($stable(qvl_ts1_ts2_os_reset, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_with_reset = {1};
        type_option.comment = "TS1/TS2 ordered sets with reset";
        }

    C7 : coverpoint (!($stable(qvl_ts1_ts2_os_disable, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_with_disable = {1};
        type_option.comment = "TS1/TS2 ordered sets with disable";
        }

    C8 : coverpoint (!($stable(qvl_ts1_ts2_os_loopback, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_with_loopback = {1};
        type_option.comment = "TS1/TS2 ordered sets with loopback";
        }

    C9 : coverpoint (!($stable(qvl_ts1_ts2_os_no_scramble, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_with_no_scramble = {1};
        type_option.comment = "TS1/TS2 ordered sets with no scramble";
        }

    C10 : coverpoint (!($stable(qvl_fts_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins FTS_ordered_sets = {1};
        type_option.comment = "FTS ordered sets";
        }

    C11 : coverpoint (!($stable(qvl_idle_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins Electrical_idle_ordered_sets = {1};
        type_option.comment = "Electrical idle ordered sets";
        }

    C12 : coverpoint (!($stable(qvl_skp_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins SKIP_ordered_sets = {1};
        type_option.comment = "SKIP ordered sets";
        }

    C13 : coverpoint (!($stable(qvl_pad_symbols, @ (clk)))) iff(enable_coverpoint)
        {
        bins PAD_Symbol_occurrences = {1};
        type_option.comment = "PAD Symbol occurrences";
        }

    C14 : coverpoint (!($stable(qvl_stp_sdp_in_symbol_time, @ (clk)))) iff(enable_coverpoint)
        {
        bins SDP_and_STP_occurrences_in_a_symbol_time = {1};
        type_option.comment = "SDP and STP occurrences in a symbol time";
        }

    C15 : coverpoint (!($stable(qvl_number_of_Ack_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins ACK_DLLPs = {1};
        type_option.comment = "ACK DLLPs";
        }

    C16 : coverpoint (!($stable(qvl_number_of_Nak_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins NAK_DLLPs = {1};
        type_option.comment = "NAK DLLPs";
        }

    C17 : coverpoint (!($stable(qvl_number_of_Initfc1_P_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC1_P_DLLPs = {1};
        type_option.comment = "InitFC1-P DLLPs";
        }

    C18 : coverpoint (!($stable(qvl_number_of_Initfc1_NP_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC1_NP_DLLPs = {1};
        type_option.comment = "InitFC1-NP DLLPs";
        }

    C19 : coverpoint (!($stable(qvl_number_of_Initfc1_Cpl_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC1_Cpl_DLLPs = {1};
        type_option.comment = "InitFC1-Cpl DLLPs";
        }

    C20 : coverpoint (!($stable(qvl_number_of_Initfc2_P_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC2_P_DLLPs = {1};
        type_option.comment = "InitFC2-P DLLPs";
        }

    C21 : coverpoint (!($stable(qvl_number_of_Initfc2_NP_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC2_NP_DLLPs = {1};
        type_option.comment = "InitFC2-NP DLLPs";
        }

    C22 : coverpoint (!($stable(qvl_number_of_Initfc2_Cpl_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins InitFC2_Cpl_DLLPs = {1};
        type_option.comment = "InitFC2-Cpl DLLPs";
        }

    C23 : coverpoint (!($stable(qvl_number_of_Updatefc_P_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_P_DLLPs = {1};
        type_option.comment = "UpdateFC-P DLLPs";
        }

    C24 : coverpoint (!($stable(qvl_number_of_Updatefc_NP_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_NP_DLLPs = {1};
        type_option.comment = "UpdateFC-NP DLLPs";
        }

    C25 : coverpoint (!($stable(qvl_number_of_Updatefc_Cpl_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_Cpl_DLLPs = {1};
        type_option.comment = "UpdateFC-Cpl DLLPs";
        }

    C26 : coverpoint (!($stable(qvl_number_of_PM_Enter_L1_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins PM_Enter_L1_DLLPs = {1};
        type_option.comment = "PM_Enter_L1 DLLPs";
        }

    C27 : coverpoint (!($stable(qvl_number_of_PM_Enter_L23_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins PL_Enter_L23_DLLPs = {1};
        type_option.comment = "PL_Enter_L23 DLLPs";
        }

    C28 : coverpoint (!($stable(qvl_number_of_PM_Act_Req_L0_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins PM_Active_State_Request_L0s_DLLPs = {1};
        type_option.comment = "PM_Active_State_Request_L0s DLLPs";
        }

    C29 : coverpoint (!($stable(qvl_number_of_PM_Act_Req_L1_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins PM_Active_State_Request_L1s_DLLPs = {1};
        type_option.comment = "PM_Active_State_Request_L1s DLLPs";
        }

    C30 : coverpoint (!($stable(qvl_number_of_PM_Req_Ack_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins PM_Request_Ack_DLLPs = {1};
        type_option.comment = "PM_Request_Ack_DLLPs";
        }

    C31 : coverpoint (!($stable(qvl_number_of_vendor_specific_dllps, @ (clk)))) iff(enable_coverpoint)
        {
        bins vendor_specific_DLLPs = {1};
        type_option.comment = "vendor specific DLLPs";
        }

    C32 : coverpoint (!($stable(qvl_number_of_retransmissions_from_retry_buffer, @ (clk)))) iff(enable_coverpoint)
        {
        bins TLP_retransmissions = {1};
        type_option.comment = "TLP retransmissions";
        }

    C33 : coverpoint (!($stable(qvl_num_duplicate_tlps, @ (clk)))) iff(enable_coverpoint)
        {
        bins Duplicate_TLPs = {1};
        type_option.comment = "Duplicate TLPs";
        }

    C34 : coverpoint (!($stable(qvl_memory_read_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_read_requests = {1};
        type_option.comment = "Memory read requests";
        }

    C35 : coverpoint (!($stable(qvl_memory_write_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_write_requests = {1};
        type_option.comment = "Memory write requests";
        }

    C36 : coverpoint (!($stable(qvl_io_read_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins I_O_read_requests = {1};
        type_option.comment = "I/O read requests";
        }

    C37 : coverpoint (!($stable(qvl_io_write_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins I_O_write_requests = {1};
        type_option.comment = "I/O write requests";
        }

    C38 : coverpoint (!($stable(qvl_type0_cfg_read_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_0_configuration_read_requests = {1};
        type_option.comment = "Type 0 configuration read requests";
        }

    C39 : coverpoint (!($stable(qvl_type0_cfg_write_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_0_configuration_write_requests = {1};
        type_option.comment = "Type 0 configuration write requests";
        }

    C40 : coverpoint (!($stable(qvl_type1_cfg_read_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_1_configuration_read_requests = {1};
        type_option.comment = "Type 1 configuration read requests";
        }

    C41 : coverpoint (!($stable(qvl_type1_cfg_write_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_1_configuration_write_requests = {1};
        type_option.comment = "Type 1 configuration write requests";
        }

    C42 : coverpoint (!($stable(qvl_message_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Message_requests = {1};
        type_option.comment = "Message requests";
        }

    C43 : coverpoint (!($stable(qvl_locked_memory_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Locked_memory_read_requests = {1};
        type_option.comment = "Locked memory read requests";
        }

    C44 : coverpoint (!($stable(qvl_completions, @ (clk)))) iff(enable_coverpoint)
        {
        bins Completion_packets = {1};
        type_option.comment = "Completion packets";
        }

    C45 : coverpoint (!($stable(qvl_ur_completions, @ (clk)))) iff(enable_coverpoint)
        {
        bins Unsupported_request_completions = {1};
        type_option.comment = "Unsupported request completions";
        }

    C46 : coverpoint (!($stable(qvl_completer_aborts, @ (clk)))) iff(enable_coverpoint)
        {
        bins Completor_Aborts = {1};
        type_option.comment = "Completor Aborts";
        }

    C47 : coverpoint (!($stable(qvl_completions_with_cfg_retry, @ (clk)))) iff(enable_coverpoint)
        {
        bins Completions_with_Configuration_Request_Retry_Status = {1};
        type_option.comment = "Completions with Configuration Request Retry Status";
        }

    C48 : coverpoint (!($stable(qvl_locked_completions, @ (clk)))) iff(enable_coverpoint)
        {
        bins Locked_Completions = {1};
        type_option.comment = "Locked Completions";
        }

    C49 : coverpoint (!($stable(qvl_tlps_with_digests, @ (clk)))) iff(enable_coverpoint)
        {
        bins TLPs_with_digests = {1};
        type_option.comment = "TLPs with digests";
        }

  endgroup : pci_express_cornercases

  // PCI_EXPRESS_GEN2 code start

  covergroup pci_express_gen2_statistics @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Gen2_Statistics for PCI-Express Monitor";

    GS1 : coverpoint (!($stable(qvl_memory_write_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_write_requests_gen2 = {1};
        type_option.comment = "Memory write requests on 5.0 GT/s";
        }
			      
    GS2 : coverpoint (!($stable(qvl_memory_read_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_read_requests_gen2 = {1};
        type_option.comment = "Memory read requests on 5.0 GT/s";
        }

    GS3 : coverpoint (!($stable(qvl_io_read_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins I_O_read_requests_gen2 = {1};
        type_option.comment = "I/O read requests on 5.0 GT/s";
        }

    GS4 : coverpoint (!($stable(qvl_io_write_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins I_O_write_requests_gen2 = {1};
        type_option.comment = "I/O write requests on 5.0 GT/s";
        }

    GS5 : coverpoint (!($stable(qvl_type0_cfg_read_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_0_configuration_read_requests_gen2 = {1};
        type_option.comment = "Type 0 configuration read requests on 5.0 GT/s";
        }

    GS6 : coverpoint (!($stable(qvl_type0_cfg_write_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_0_configuration_write_requests_gen2 = {1};
        type_option.comment = "Type 0 configuration write requests on 5.0 GT/s";
        }

    GS7 : coverpoint (!($stable(qvl_type1_cfg_read_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_1_configuration_read_requests_gen2 = {1};
        type_option.comment = "Type 1 configuration read requests on 5.0 GT/s";
        }

    GS8 : coverpoint (!($stable(qvl_type1_cfg_write_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Type_1_configuration_write_requests_gen2 = {1};
        type_option.comment = "Type 1 configuration write requests on 5.0 GT/s";
        }

    GS9 : coverpoint (!($stable(qvl_message_requests_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Message_requests_gen2 = {1};
        type_option.comment = "Message requests on 5.0 GT/s";
        }

    GS10 : coverpoint (!($stable(qvl_completions_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Completion_packets_gen2 = {1};
        type_option.comment = "Completion packets on 5.0 GT/s";
        }
    GS11 : coverpoint (!($stable(qvl_number_of_Ack_dllps_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins ACK_DLLPs_gen2 = {1};
        type_option.comment = "ACK DLLPs on 5.0 GT/s";
        }
    GS12 : coverpoint (!($stable(qvl_number_of_Updatefc_P_dllps_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_P_DLLPs_gen2 = {1};
        type_option.comment = "UpdateFC-P DLLPs on 5.0 GT/s";
        }

    GS13 : coverpoint (!($stable(qvl_number_of_Updatefc_NP_dllps_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_NP_DLLPs_gen2 = {1};
        type_option.comment = "UpdateFC-NP DLLPs on 5.0 GT/s";
        }

    GS14 : coverpoint (!($stable(qvl_number_of_Updatefc_Cpl_dllps_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins UpdateFC_Cpl_DLLPs_gen2 = {1};
        type_option.comment = "UpdateFC-Cpl DLLPs on 5.0 GT/s";
        }
    GS15 : coverpoint (!($stable(qvl_polling_compliance_transtion, @ (clk)))) iff(enable_coverpoint)
        {
        bins Polling_compliance_transtion = {1};
        type_option.comment = "Polling Compliance entry";
        }
    GS16 : coverpoint (!($stable(qvl_reco_cfg_to_reco_speed_transtion, @ (clk)))) iff(enable_coverpoint)
        {
        bins Reco_cfg_to_reco_speed_transtion = {1};
        type_option.comment = "State transtion from Recovery.Cfg to Recovery.Speed";
        }
    GS17 : coverpoint (!($stable(qvl_speed_change_attemp_on_2_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins Speed_change_attemp_on_2_5gt = {1};
        type_option.comment = "Speed change attempt from 2.5 GT/s to 5.0 GT/s";
        }
    GS18 : coverpoint (!($stable(qvl_speed_change_attemp_on_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins Speed_change_attemp_on_5gt = {1};
        type_option.comment = "Speed change attempt from 5.0 GT/s to 2.5 GT/s";
        }			      
    GS19 : coverpoint (!($stable(qvl_successfull_speed_change_to_2_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins Successfull_speed_change_to_2_5gt = {1};
        type_option.comment = "successfull speed change from 2.5 GT/s to 5.0 GT/s";
        } 
    GS20 : coverpoint (!($stable(qvl_successfull_speed_change_to_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins Successfull_speed_change_to_5gt = {1};
        type_option.comment = "successfull speed change from 5.0 GT/s to 2.5 GT/s";
        }
  endgroup : pci_express_gen2_statistics
			      
  covergroup pci_express_gen2_cornercases @ (clk);

    type_option.strobe = 1;
    type_option.comment = "Gen2 Cornercases for PCI-Express Monitor";

    GC1 : coverpoint (!($stable(qvl_idle_os_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins Electrical_idle_ordered_sets_gen2 = {1};
        type_option.comment = "Electrical idle ordered sets on speed greater than 2.5 GT/s";
        }

    GC2 : coverpoint (!($stable(qvl_fts_os_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins FTS_ordered_sets_gen2 = {1};
        type_option.comment = "FTS ordered sets on gen2";
        }
			      
    GC3 : coverpoint (!($stable(qvl_eie_os, @ (clk)))) iff(enable_coverpoint)
        {
        bins Electrical_idle_exit_seq_ordered_sets = {1};
        type_option.comment = "Electrical idle exit sequence ordered sets";
        } 			      
    GC4 : coverpoint (!($stable(qvl_ts1_os_with_speed_change_bit, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_ordered_sets_with_speed_change_bit = {1};
        type_option.comment = "TS1 ordered sets with speed change bit";
        }
    GC5 : coverpoint (!($stable(qvl_ts2_os_with_speed_change_bit, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS2_ordered_sets_with_speed_change_bit = {1};
        type_option.comment = "TS2 ordered sets with speed change bit";
        }
    GC6 : coverpoint (!($stable(qvl_ts1_ts2_os_gen1, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_on_gen1 = {1};
        type_option.comment = "TS1/TS2 ordered sets with 2.5 GT/s data rate";
        }
    GC7 : coverpoint (!($stable(qvl_ts1_ts2_os_gen2, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_on_gen2 = {1};
        type_option.comment = "TS1/TS2 ordered sets with 5 GT/s data rate";
        }
    GC8 : coverpoint (!($stable(qvl_ts1_ts2_os_with_autonomous_bit, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_TS2_ordered_sets_with_autonomous_bit = {1};
        type_option.comment = "TS1/TS2 ordered sets with autonomous bit";
        }
    GC9 : coverpoint (!($stable(qvl_ts1_os_with_compliance_rx_bit, @ (clk)))) iff(enable_coverpoint)
        {
        bins TS1_ordered_sets_with_compliance_rx_bit = {1};
        type_option.comment = "TS1 ordered sets with compliance receive bit";
        }
    GC10: coverpoint (!($stable(qvl_mt_4_eie_before_fts, @ (clk)))) iff(enable_coverpoint)
        {
        bins More_than_4_eie_before_fts = {1};
        type_option.comment = "More than 4 EIE symbol occurence before FTS";
        }
    GC11 : coverpoint (!($stable(qvl_modified_compliance_pattern, @ (clk)))) iff(enable_coverpoint)
        {
        bins Modified_compliance_pattern = {1};
        type_option.comment = "Modified complaince pattern";
        }			      
    GC12: coverpoint (!($stable(qvl_speed_change_through_l1, @ (clk)))) iff(enable_coverpoint)
        {
        bins Speed_change_through_l1 = {1};
        type_option.comment = "Speed change through L1";
        } 
    GC13: coverpoint (!($stable(qvl_reco_lk_to_reco_speed_after_timeout, @ (clk)))) iff(enable_coverpoint)
        {
        bins Reco_lk_to_reco_speed_after_timeout = {1};
        type_option.comment = "Recovery Lk to Recovery speed after timeout";
        } 
    GC14: coverpoint (!($stable(qvl_l0s_transtion_on_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins L0s_transtion_on_5gt = {1};
        type_option.comment = "L0s transtion on 5.0 GT/s";
        }
    GC15: coverpoint (!($stable(qvl_l1_transtion_on_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins L1_transtion_on_5gt = {1};
        type_option.comment = "L1 transtion on 5.0 GT/s";
        }			 
    GC16: coverpoint (!($stable(qvl_l2_transtion_on_5gt, @ (clk)))) iff(enable_coverpoint)
        {
        bins L2_transtion_on_5gt = {1};
        type_option.comment = "L2 transtion on 5.0 GT/s";
        }     
    GC17 : coverpoint (!($stable(qvl_deprecated_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Deprecated_requests = {1};
        type_option.comment = "Deprecated TLP";
        }
    GC18 : coverpoint (!($stable(qvl_memory_translation_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_translation_requests = {1};
        type_option.comment = "Memory translation request(AT=01)";
        }		
    GC19 : coverpoint (!($stable(qvl_memory_translated_requests, @ (clk)))) iff(enable_coverpoint)
        {
        bins Memory_translated_requests = {1};
        type_option.comment = "Memory translated request(AT=10)";
        }	      
  endgroup : pci_express_gen2_cornercases

  			      
  generate
    if(PCI_EXPRESS_GEN2 == 1)
      begin : CG_PCI_EXPRESS_GEN2
        pci_express_gen2_cornercases  PCI_EXPRESS_GEN2_CORNERCASES = new();
        pci_express_gen2_statistics  PCI_EXPRESS_GEN2_STATISTICS = new();
      end  
  endgenerate			
      
  // PCI_EXPRESS_GEN2 code end
			      
  pci_express_statistics  PCI_EXPRESS_STATISTICS = new();
  pci_express_cornercases  PCI_EXPRESS_CORNERCASES = new();
  

  initial
    begin
  // PCI_EXPRESS_GEN2 code start
      if(PCI_EXPRESS_GEN2 == 1)
	begin
	  pci_express_gen2_cornercases::type_option.comment = "Gen2 Cornercases for PCI-Express Monitor";
	  pci_express_gen2_statistics::type_option.comment = "Gen2 Statistics for PCI-Express Monitor";
	end  
  // PCI_EXPRESS_GEN2 code end      
      pci_express_statistics::type_option.comment = "Statistics for PCI-Express Monitor";
      pci_express_cornercases::type_option.comment = "Cornercases for PCI-Express Monitor";
    end

`endif // QVL_SV_COVERGROUP
  
  
`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for PCI-Express Monitor -------------------------");

      $display("Monitor instance                         : %m");

      $display("------------------- Statistics for PCI-Express Monitor -----------------------");

      $display("Number of packets                             : %0d", qvl_total_packets);
      $display("Multiple packets ending in a symbol time count : %0d", qvl_more_than_one_pkt_detected_count);
      $display("TLPs started on non zero lane                 : %0d", qvl_non_zero_stp_count);
      $display("TLPs with ECRC Error                          : %0d", qvl_tlps_with_ecrc);
      $display("TLPs with LCRC Error                          : %0d", qvl_tlps_with_lcrc);
      $display("Malformed TLPs                                : %0d", qvl_malformed_tlps);

      $display("------------------- Cornercases for PCI-Express Monitor ----------------------");

      $display("COM Symbols                                   : %0d", qvl_com_symbols);
      $display("Transaction layer packets                     : %0d", qvl_tl_packets);
      $display("Data link layer packets                       : %0d", qvl_dll_packets);
      $display("Nullified TLPs                                : %0d", qvl_nullified_tlps);
      $display("TS1 ordered sets                              : %0d", qvl_ts1_os);
      $display("TS2 ordered sets                              : %0d", qvl_ts2_os);
      $display("TS1/TS2 ordered sets with reset               : %0d", qvl_ts1_ts2_os_reset);
      $display("TS1/TS2 ordered sets with disable             : %0d", qvl_ts1_ts2_os_disable);
      $display("TS1/TS2 ordered sets with loopback            : %0d", qvl_ts1_ts2_os_loopback);
      $display("TS1/TS2 ordered sets with no scramble         : %0d", qvl_ts1_ts2_os_no_scramble);
      $display("FTS ordered sets                              : %0d", qvl_fts_os);
      $display("Electrical idle ordered sets                  : %0d", qvl_idle_os);
      $display("SKIP ordered sets                             : %0d", qvl_skp_os);
      $display("PAD Symbol occurrences                        : %0d", qvl_pad_symbols);
      $display("SDP and STP occurrences in a symbol time      : %0d", qvl_stp_sdp_in_symbol_time);
      $display("ACK DLLPs                                     : %0d", qvl_number_of_Ack_dllps);
      $display("NAK DLLPs                                     : %0d", qvl_number_of_Nak_dllps);
      $display("InitFC1-P DLLPs                               : %0d", qvl_number_of_Initfc1_P_dllps);
      $display("InitFC1-NP DLLPs                              : %0d", qvl_number_of_Initfc1_NP_dllps);
      $display("InitFC1-Cpl DLLPs                             : %0d", qvl_number_of_Initfc1_Cpl_dllps);
      $display("InitFC2-P DLLPs                               : %0d", qvl_number_of_Initfc2_P_dllps);
      $display("InitFC2-NP DLLPs                              : %0d", qvl_number_of_Initfc2_NP_dllps);
      $display("InitFC2-Cpl DLLPs                             : %0d", qvl_number_of_Initfc2_Cpl_dllps);
      $display("UpdateFC-P DLLPs                              : %0d", qvl_number_of_Updatefc_P_dllps);
      $display("UpdateFC-NP DLLPs                             : %0d", qvl_number_of_Updatefc_NP_dllps);
      $display("UpdateFC-Cpl DLLPs                            : %0d", qvl_number_of_Updatefc_Cpl_dllps);
      $display("PM_Enter_L1 DLLPs                             : %0d", qvl_number_of_PM_Enter_L1_dllps);
      $display("PL_Enter_L23 DLLPs                            : %0d", qvl_number_of_PM_Enter_L23_dllps);
      $display("PM_Active_State_Request_L0s DLLPs             : %0d", qvl_number_of_PM_Act_Req_L0_dllps);
      $display("PM_Active_State_Request_L1s DLLPs             : %0d", qvl_number_of_PM_Act_Req_L1_dllps);
      $display("PM_Request_Ack_DLLPs                          : %0d", qvl_number_of_PM_Req_Ack_dllps);
      $display("vendor specific DLLPs                         : %0d", qvl_number_of_vendor_specific_dllps);
      $display("TLP retransmissions                           : %0d", qvl_number_of_retransmissions_from_retry_buffer);
      $display("Duplicate TLPs                                : %0d", qvl_num_duplicate_tlps);
      $display("Memory read requests                          : %0d", qvl_memory_read_requests);
      $display("Memory write requests                         : %0d", qvl_memory_write_requests);
      $display("I/O read requests                             : %0d", qvl_io_read_requests);
      $display("I/O write requests                            : %0d", qvl_io_write_requests);
      $display("Type 0 configuration read requests            : %0d", qvl_type0_cfg_read_requests);
      $display("Type 0 configuration write requests           : %0d", qvl_type0_cfg_write_requests);
      $display("Type 1 configuration read requests            : %0d", qvl_type1_cfg_read_requests);
      $display("Type 1 configuration write requests           : %0d", qvl_type1_cfg_write_requests);
      $display("Message requests                              : %0d", qvl_message_requests);
      $display("Locked memory read requests                   : %0d", qvl_locked_memory_requests);
      $display("Completion packets                            : %0d", qvl_completions);
      $display("Unsupported request completions               : %0d", qvl_ur_completions);
      $display("Completor Aborts                              : %0d", qvl_completer_aborts);
      $display("Completions with Configuration Request Retry Status : %0d", qvl_completions_with_cfg_retry);
      $display("Locked Completions                            : %0d", qvl_locked_completions);
      $display("TLPs with digests                             : %0d", qvl_tlps_with_digests);

   // PCI_EXPRESS_GEN2 code start
      if(PCI_EXPRESS_GEN2 == 1)
	begin
	  $display("------------------- Cornercases for PCI-Express Gen2 -------------------------");

	  $display("Electrical idle ordered sets on speed greater than 2.5 GT/s                : %0d", qvl_idle_os_gen2);
	  $display("FTS ordered sets on speed greater than 2.5 GT/s                            : %0d", qvl_fts_os_gen2);
	  $display("Electrical idle exit sequence ordered sets                                 : %0d", qvl_eie_os);
	  $display("TS1 ordered sets with speed change bit                                     : %0d", qvl_ts1_os_with_speed_change_bit);
	  $display("TS2 ordered sets with speed change bit                                     : %0d", qvl_ts2_os_with_speed_change_bit);
	  $display("TS1/TS2 ordered sets with 2.5 GT/s data rate                               : %0d", qvl_ts1_ts2_os_gen1);
	  $display("TS1/TS2 ordered sets with 5 GT/s data rate                                 : %0d", qvl_ts1_ts2_os_gen2);
	  $display("TS1/TS2 ordered sets with autonomous bit                                   : %0d", qvl_ts1_ts2_os_with_autonomous_bit);
	  $display("TS1 ordered sets with compliance receive bit                               : %0d", qvl_ts1_os_with_compliance_rx_bit);   
          $display("More than 4 EIE symbol occurence before FTS                                : %0d", qvl_mt_4_eie_before_fts);
	  $display("Number of times transtion from L1 to Recovery for speed change purpose     : %0d", qvl_speed_change_through_l1);
	  $display("Number of times state transtion from RecoLk to RecoSpeed after timeout     : %0d", qvl_reco_lk_to_reco_speed_after_timeout);
	  $display("Number of times state transtion to L0s on speed greater than 2.5 GT/s      : %0d", qvl_l0s_transtion_on_5gt);
	  $display("Number of times state transtion to L1  on speed greater than 2.5 GT/s      : %0d", qvl_l1_transtion_on_5gt);
	  $display("Number of times state transtion to L2  on speed greater than 2.5 GT/s      : %0d", qvl_l2_transtion_on_5gt);
	  $display("Total number of modified compliance pattern                                : %0d", qvl_modified_compliance_pattern);	  
	  $display("Deprecated TLP                                                             : %0d", qvl_deprecated_requests);
	  $display("Memory translation request(AT=01)                                          : %0d", qvl_memory_translation_requests);
	  $display("Memory translated request(AT=10)                                           : %0d", qvl_memory_translated_requests);

          $display("------------------- Statistics for PCI-Express Gen2 -------------------------");

	  $display("ACK DLLPs on 5.0 GT/s                                                      : %0d", qvl_number_of_Ack_dllps_gen2);
	  $display("UpdateFC-P DLLPs on 5.0 GT/s                                               : %0d", qvl_number_of_Updatefc_P_dllps_gen2);
          $display("UpdateFC-NP DLLPs on 5.0 GT/s                                              : %0d", qvl_number_of_Updatefc_NP_dllps_gen2);
          $display("UpdateFC-Cpl DLLPs on 5.0 GT/s                                             : %0d", qvl_number_of_Updatefc_Cpl_dllps_gen2);
	  $display("Memory read requests on 5.0 GT/s                                           : %0d", qvl_memory_read_requests_gen2);
          $display("Memory write requests on 5.0 GT/s                                          : %0d", qvl_memory_write_requests_gen2);
          $display("I/O read requests on 5.0 GT/s                                              : %0d", qvl_io_read_requests_gen2);
          $display("I/O write requests on 5.0 GT/s                                             : %0d", qvl_io_write_requests_gen2);
          $display("Type 0 configuration read requests on 5.0 GT/s                             : %0d", qvl_type0_cfg_read_requests_gen2);
          $display("Type 0 configuration write requests on 5.0 GT/s                            : %0d", qvl_type0_cfg_write_requests_gen2);
          $display("Type 1 configuration read requests on 5.0 GT/s                             : %0d", qvl_type1_cfg_read_requests_gen2);
          $display("Type 1 configuration write requests on 5.0 GT/s                            : %0d", qvl_type1_cfg_write_requests_gen2);
          $display("Message requests on 5.0 GT/s                                               : %0d", qvl_message_requests_gen2);
          $display("Completion packets on 5.0 GT/s                                             : %0d", qvl_completions_gen2);
	  $display("Number of times state transition to Polling Compliance from Polling Active : %0d", qvl_polling_compliance_transtion);
	  $display("Number of times state transition to Recovery Cfg to Recovery Speed         : %0d", qvl_reco_cfg_to_reco_speed_transtion);
	  $display("Number of attempts to change speed from 2.5 GT/s to 5.0 GT/s               : %0d", qvl_speed_change_attemp_on_2_5gt);
	  $display("Number of attempts to change speed from 5.0 GT/s to 2.5 GT/s               : %0d", qvl_speed_change_attemp_on_5gt);
	  $display("Number of sucessfull speed change from 2.5 GT/s to 5.0 GT/s                : %0d", qvl_successfull_speed_change_to_5gt);
	  $display("Number of sucessfull speed change from 5.0 GT/s to 2.5 GT/s                : %0d", qvl_successfull_speed_change_to_2_5gt);
	end  
   // PCI_EXPRESS_GEN2 code end
      $display("------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
