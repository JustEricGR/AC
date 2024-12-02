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
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);

  covergroup value_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Value Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
  S1 : coverpoint (!($stable(values_covered, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Covered = {1};
           type_option.comment = "Values Covered";
           }
  endgroup : value_statistics

  covergroup value_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Value Checker";

  C0 : coverpoint (!($stable(all_values_covered, @ (posedge clock))))
         iff (enable_coverpoint && !all_values_covered)
           {
           bins All_Values_Covered = {1};
           type_option.comment = "All Values Covered";
           }
  endgroup : value_cornercases

  value_cornercases VALUE_CORNERCASES = new();
  value_statistics VALUE_STATISTICS = new();

  initial
    begin
      value_cornercases::type_option.comment = "Corner cases for value Checker";
      value_statistics::type_option.comment = "Statistics for value Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Value Checker ------------------");
      $display("Assertion instance is       : %m");
      $display("------------------- Statistics for Value Checker ----------------");
      $display("Values Checked              : %0d", values_checked);
      $display("Values Covered              : %0d", values_covered);
      $display("------------------- Corner cases for Value Checker ---------------");
      $display("All Values Covered          : %0d", all_values_covered);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
