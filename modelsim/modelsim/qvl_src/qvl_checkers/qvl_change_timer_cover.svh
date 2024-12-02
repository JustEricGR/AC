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

  covergroup change_timer_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Change Timer Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
  endgroup : change_timer_statistics

  covergroup change_timer_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Change Timer Checker";

  C0 : coverpoint (!($stable(value_changed_at_max_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Value_Changed_at_max = {1};
           type_option.comment = "Value Changed at 'max' Cycles";
           }
  C1 : coverpoint (!($stable(value_changed_at_min_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Value_Changed_at_min = {1};
           type_option.comment = "Value Changed at 'min' Cycles";
           }
  endgroup : change_timer_cornercases

  change_timer_statistics CHANGE_TIMER_STATISTICS = new();
  change_timer_cornercases CHANGE_TIMER_CORNERCASES = new();

  initial
    begin
      change_timer_statistics::type_option.comment = "Statistics for Change Timer Checker";
      change_timer_cornercases::type_option.comment = "Corner Cases for Change Timer Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Change Timer Checker ------------------");
      $display("Assertion instance is : %m");
      $display("------------------- Statistics for Change Timer Checker ----------------");
      $display("Values Checked        : %0d", values_checked);
      $display("------------------- Corner Cases for Change Timer Checker ---------------");
      $display("Value Changed at 'max': %0d", value_changed_at_max_count);
      $display("Value Changed at 'min': %0d", value_changed_at_min_count);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
