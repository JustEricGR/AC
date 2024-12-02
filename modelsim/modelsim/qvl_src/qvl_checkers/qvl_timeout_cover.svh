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

  assign collect_stats = 1'b1; // Not having any significance in SV.

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  covergroup timeout_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Timeout Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
 
  S1 : coverpoint (!($stable(fastest_value_change, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Fastest_Value_Change_Time = {1};
           type_option.comment = "Fastest Value Change Time";
           }

  S2 : coverpoint (!($stable(slowest_value_change, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Slowest_Value_Change_Time = {1};
           type_option.comment = "Slowest Value Change Time";
           }
  endgroup : timeout_statistics

  covergroup timeout_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Timeout Checker";

  C0 : coverpoint (!($stable(val_changed_at_max, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Value_Changed_at_Maximum_Limit = {1};
           type_option.comment = "Value Changed at Maximum Limit";
           }

  endgroup : timeout_cornercases

  timeout_cornercases TIMEOUT_CORNERCASES = new();
  timeout_statistics TIMEOUT_STATISTICS = new();

  initial
    begin
      timeout_cornercases::type_option.comment = "Cornercases for Timeout Checker";
      timeout_statistics::type_option.comment = "Statistics for Timeout Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Timeout Checker ------------------");
      $display("Assertion instance is             : %m");
      $display("------------------- Statistics for Timeout Checker ----------------");
      $display("Values Checked                    : %0d", values_checked);
      $display("Fastest Value Change Time         : %0d", fastest_value_change);
      $display("Slowest Value Change Time         : %0d", slowest_value_change);
      $display("------------------- Corner Cases for Timeout Checker --------------");
      $display("Value Changed at Maximum Limit    : %0d", val_changed_at_max);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
