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
      #1;
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  covergroup assert_timer_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Assert Timer Checker";

  S0 : coverpoint (!($stable(assertions_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Assertions_Checked = {1};
           type_option.comment = "Assertions Checked";
           }
  endgroup : assert_timer_statistics

  covergroup assert_timer_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Assert Timer Checker";

  C0 : coverpoint (!($stable(asserted_for_max_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Signal_Was_Asserted_for_max_Cycles = {1};
           type_option.comment = "Signal Asserted for 'max' Cycles";
           }
  C1 : coverpoint (!($stable(asserted_for_min_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Signal_Was_Asserted_for_min_Cycles = {1};
           type_option.comment = "Signal Asserted for 'min' Cycles";
           }
  endgroup : assert_timer_cornercases

  assert_timer_statistics ASSERT_TIMER_STATISTICS = new();
  assert_timer_cornercases ASSERT_TIMER_CORNERCASES = new();

  initial
    begin
      assert_timer_statistics::type_option.comment = "Statistics for Assert Timer Checker";
      assert_timer_cornercases::type_option.comment = "Corner Cases for Assert Timer Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Assert Timer Checker ------------------");
      $display("Assertion instance is                : %m");
      $display("------------------- Statistics for Assert Timer Checker ----------------");
      $display("Assertions Checked                   : %0d", assertions_checked);
      $display("------------------- Corner Cases for Assert Timer Checker ---------------");
      $display("Signal Was Asserted for 'max' Cycles : %0d", asserted_for_max_count);
      $display("Signal Was Asserted for 'min' Cycles : %0d", asserted_for_min_count);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
