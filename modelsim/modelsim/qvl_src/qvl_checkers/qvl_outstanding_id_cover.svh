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

  wire all_ids_requested;
  assign all_ids_requested = &cc_uids_bit_map;

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

  covergroup outstanding_id_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Outstanding ID Checker";

  S0 : coverpoint (!($stable(ids_flushed, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Flushed = {1};
           type_option.comment = "IDs Flushed";
           }

  S1 : coverpoint (!($stable(unique_ids_issued, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Unique_IDs_Issued = {1};
           type_option.comment = "Unique IDs Issued";
           }
  endgroup : outstanding_id_statistics

  covergroup outstanding_id_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Outstanding ID Checker";

  C0 : coverpoint (!($stable(ids_requested, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Requested = {1};
           type_option.comment = "IDs Requested";
           }

  C1 : coverpoint (!($stable(ids_returned, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Returned = {1};
           type_option.comment = "IDs Returned";
           }

  C2 : coverpoint (!($stable(outstanding_ids_equals_max_ids_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Outstanding_IDs_Equal_Maximum_IDs = {1};
           type_option.comment = "Outstanding IDs Equal Maximum IDs";
           }

  C3 : coverpoint (!($stable(outstanding_count_per_id_equals_max_count_per_id, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Outstanding_Count_Per_ID_Equals_Maximum_Count_Per_ID = {1};
           type_option.comment = "Outstanding Count Per ID Equals Maximum Count Per ID";
           }

  C4 : coverpoint (!($stable(min_outstanding_cycles_equals_min, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Minimum_Cycles_Outstanding_Equals_Minimum = {1};
           type_option.comment = "Minimum Cycles Outstanding Equals Minimum";
           }

  C5 : coverpoint (!($stable(max_outstanding_cycles_equals_max, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Maximum_Cycles_Outstanding_Equals_Maximum = {1};
           type_option.comment = "Maximum Cycles Outstanding Equals Maximum";
           }

  C6 : coverpoint (!($stable(all_ids_requested, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_IDs_Requested = {1};
           type_option.comment = "All IDs Requested";
           }
  endgroup : outstanding_id_cornercases

  outstanding_id_statistics OUTSTANDING_ID_STATISTICS = new();
  outstanding_id_cornercases OUTSTANDING_ID_CORNERCASES = new();

  initial
    begin
      outstanding_id_cornercases::type_option.comment = "Corner Cases for Outstanding ID Checker";
      outstanding_id_statistics::type_option.comment = "Statistics for Outstanding ID Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Outstanding ID Checker ------------------");
      $display("Assertion instance is : %m");
      $display("------------------- Statistics for Outstanding ID Checker ----------------");
      $display("IDs Flushed                                          : %0d", ids_flushed);
      $display("Unique IDs Issued                                    : %0d", unique_ids_issued);
      $display("------------------- Corner cases for Outstanding ID Checker --------------");
      $display("IDs Requested                                        : %0d", ids_requested);
      $display("IDs Returned                                         : %0d", ids_returned);
      $display("Outstanding IDs Equal Maximum IDs                    : %0d", outstanding_ids_equals_max_ids_count);
      $display("Outstanding Count Per ID Equals Maximum Count Per ID : %0d", outstanding_count_per_id_equals_max_count_per_id);
      $display("Minimum Cycles Outstanding Equals Minimum            : %0d", min_outstanding_cycles_equals_min);
      $display("Maximum Cycles Outstanding Equals Maximum            : %0d", max_outstanding_cycles_equals_max);
      $display("All IDs Requested                                    : %0d", all_ids_requested);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
