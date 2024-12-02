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

// Coverage of Statistics //

  covergroup state_transition_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for State Transition Checker";

  S0 : coverpoint (!($stable(cycles_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Checked = {1};
           type_option.comment = "Cycles Checked";
           }

  S1 : coverpoint (!($stable(number_of_transitions_covered, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Number_of_Transitions_Covered = {1};
           type_option.comment = "Number of Transitions Covered";
           }
  endgroup : state_transition_statistics


// Coverage of Corner Cases //

  covergroup state_transition_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for State Transition Checker";

  C0 : coverpoint (!($stable(all_transitions_covered,  @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Transitions_Covered = {1};
           type_option.comment = "All Transitions Covered";
           }

  endgroup : state_transition_cornercases
  
  state_transition_cornercases STATE_TRANSITION_CORNERCASES = new();
  state_transition_statistics STATE_TRANSITION_STATISTICS = new();

  initial
    begin
      #1;
      state_transition_cornercases::type_option.comment = "Corner Cases for State Transition Checker";
      state_transition_statistics::type_option.comment = "Statistics for State Transition Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("----------- Coverage for State Transition Checker ----------");
      $display("Assertion instance is   : %m");
      $display("----------- Statistics for State Transition Checker --------");
      $display("Cycles Checked                                 : %0d", cycles_checked);
      $display("Number of Transitions Covered                  : %0d", number_of_transitions_covered);
      $display("----------- Corner Cases for State Transition Checker -------");
      $display("All Transitions Covered                        : %0d", all_transitions_covered);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
