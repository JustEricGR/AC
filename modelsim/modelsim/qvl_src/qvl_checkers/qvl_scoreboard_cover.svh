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

  wire all_ids_received;
  assign all_ids_received = &cc_uids_bit_map;

`ifdef QVL_SV_COVERGROUP

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  covergroup scroreboard_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Scroreboard Checker";

  S0 : coverpoint (!($stable(ids_flushed, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Flushed = {1};
           type_option.comment = "IDs Flushed";
           }

  S1 : coverpoint (!($stable(unique_ids_received, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Unique_IDs_Received = {1};
           type_option.comment = "Unique IDs Received";
           }
  endgroup : scroreboard_statistics

  covergroup scroreboard_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Scroreboard Checker";

  C0 : coverpoint (!($stable(ids_received, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Received = {1};
           type_option.comment = "IDs Received";
           }

  C1 : coverpoint (!($stable(ids_transmitted, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Transmitted = {1};
           type_option.comment = "IDs Transmitted";
           }

  C2 : coverpoint (!($stable(pending_ids_equals_max_ids_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Pending_IDs_Equal_Maximum_IDs = {1};
           type_option.comment = "Pending IDs Equal Maximum IDs";
           }

  C3 : coverpoint (!($stable(pending_count_per_id_equals_max_count_per_id, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Pending_Count_Per_ID_Equals_Maximum_Count_Per_ID = {1};
           type_option.comment = "Pending Count Per ID Equals Maximum Count Per ID";
           }

  C4 : coverpoint (!($stable(min_pending_cycles_equals_min, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Minimum_Cycles_Pending_Equals_Minimum = {1};
           type_option.comment = "Minimum Cycles Pending Equals Minimum";
           }

  C5 : coverpoint (!($stable(max_pending_cycles_equals_max, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Maximum_Cycles_Pending_Equals_Maximum = {1};
           type_option.comment = "Maximum Cycles Pending Equals Maximum";
           }

  C6 : coverpoint (!($stable(all_ids_received, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_IDs_Received = {1};
           type_option.comment = "All IDs Received";
           }
  endgroup : scroreboard_cornercases

  scroreboard_statistics SCOREBOARD_STATISTICS = new();
  scroreboard_cornercases SCOREBOARD_CORNERCASES = new();

  initial
    begin
      scroreboard_cornercases::type_option.comment = "Corner Cases for Scroreboard Checker";
      scroreboard_statistics::type_option.comment = "Statistics for Scroreboard Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Scoreboard Checker ------------------");
      $display("Assertion instance is : %m");
      $display("------------------- Statistics for Scoreboard Checker ----------------");
      $display("IDs Flushed                                      : %0d", ids_flushed);
      $display("Unique IDs Received                              : %0d", unique_ids_received);
      $display("------------------- Corner cases for Scoreboard Checker --------------");
      $display("IDs Received                                     : %0d", ids_received);
      $display("IDs Transmitted                                  : %0d", ids_transmitted);
      $display("Pending IDs Equal Maximum IDs                    : %0d", pending_ids_equals_max_ids_count);
      $display("Pending Count Per ID Equals Maximum Count Per ID : %0d", pending_count_per_id_equals_max_count_per_id);
      $display("Minimum Cycles Pending Equals Minimum            : %0d", min_pending_cycles_equals_min);
      $display("Maximum Cycles Pending Equals Maximum            : %0d", max_pending_cycles_equals_max);
      $display("All IDs Received                                 : %0d", all_ids_received);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
