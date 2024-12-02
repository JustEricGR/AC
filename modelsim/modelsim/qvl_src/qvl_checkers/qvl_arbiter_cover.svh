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

`ifdef QVL_SV_COVERGROUP

  reg prevent_x_to_valid_transition_count;
  reg [63:0] simultaneous_req_gnt;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count = 1'b0;
      simultaneous_req_gnt = 64'b0;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
      if ((|requests_temp) && (|grants_temp) && (~reset) && (~areset))
        simultaneous_req_gnt <= simultaneous_req_gnt + 1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);

  covergroup arbiter_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Arbiter Checker";

  S0 : coverpoint (!($stable(requests, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Requests = {1};
           type_option.comment = "Requests";
           }

  S1 : coverpoint (!($stable(grants, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Grants = {1};
           type_option.comment = "Grants";
           }

  S2 : coverpoint (!($stable(simultaneous_req_gnt, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Simulatneous_Requests_and_Grants = {1};
           type_option.comment = "Simulatneous Requests and Grants";
           }
  endgroup : arbiter_statistics

  covergroup arbiter_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Arbiter Checker";

  C0 : coverpoint (!($stable(all_requests_asserted, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Requests_Asserted = {1};
           type_option.comment = "All Requests Asserted";
           }

  C1 : coverpoint (!($stable(all_grants_asserted, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Grants_Asserted = {1};
           type_option.comment = "All Grants Asserted";
           }

  C2 : coverpoint (!($stable(outstanding_cycles_equals_max_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Requests_Outstanding_for_max_cycles = {1};
           type_option.comment = "Requests Outstanding for Max Cycles";
           }

  C3 : coverpoint (!($stable(outstanding_cycles_equals_min_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Requests_Outstanding_for_min_cycles = {1};
           type_option.comment = "Requests Outstanding for Min Cycles";
           }

  C4 : coverpoint (!($stable(grant_asserted_equals_max_grant_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Grant_Asserted_for_max_gnt_cycles = {1};
           type_option.comment = "Grant Asserted for Max Grant Cycles";
           }
  endgroup : arbiter_cornercases

  arbiter_cornercases ARBITER_CORNERCASES = new();
  arbiter_statistics ARBITER_STATISTICS = new();

  initial
    begin
      arbiter_cornercases::type_option.comment = "Corner Cases for Arbiter Checker";
      arbiter_statistics::type_option.comment = "Statistics for Arbiter Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Arbiter Checker ------------------");
      $display("Assertion instance is              : %m");
      $display("------------------- Statistics for Arbiter Checker ----------------");
      $display("Requests                          : %0d", requests);
      $display("Grants                            : %0d", grants);
      $display("Simultaneous Requests and Grants  : %0d", simultaneous_req_gnt);
      $display("------------------- Corner Cases for Arbiter Checker --------------");
      $display("All Requests Asserted             : %0d", all_requests_asserted);
      $display("All Grants Asserted               : %0d", all_grants_asserted);
      $display("Requests Outstanding for 'min' Cycles : %0d", outstanding_cycles_equals_min_count);
      $display("Requests Outstanding for 'max' Cycles : %0d", outstanding_cycles_equals_max_count);
      $display("Grant Asserted for 'max_gnt_cycles'   : %0d", grant_asserted_equals_max_grant_count);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
