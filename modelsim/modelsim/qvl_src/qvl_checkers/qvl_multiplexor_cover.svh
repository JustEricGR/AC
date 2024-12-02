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

  covergroup multiplexor_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multiplexor Checker";

  S0 : coverpoint (!($stable(selects_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Selects_Checked = {1};
           type_option.comment = "Selects Checked";
           }
  S1 : coverpoint (!($stable(inputs_selected, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Inputs_Selected = {1};
           type_option.comment = "Inputs Selected";
           }
  S2 : coverpoint (!($stable(inputs_not_selected, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Inputs_Not_Selected = {1};
           type_option.comment = "Inputs Not Selected";
           }
  endgroup : multiplexor_statistics

  covergroup multiplexor_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Multiplexor Checker";

  C0 : coverpoint (!($stable(all_inputs_selected, @ (posedge clock))))
         iff (enable_coverpoint && !all_inputs_selected)
           {
           bins All_Inputs_Selected = {1};
           type_option.comment = "All Inputs Selected";
           }
  endgroup : multiplexor_cornercases

  multiplexor_cornercases COVERAGE_CORNERCASES = new();
  multiplexor_statistics COVERAGE_STATISTICS = new();

  initial
    begin
      multiplexor_cornercases::type_option.comment = "Cornercases for multiplexor Checker";
      multiplexor_statistics::type_option.comment = "Statistics for multiplexor Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for multiplexor Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for multiplexor Checker ----------------");
      $display("Selects Checked              : %0d", selects_checked);
      $display("Inputs Selected              : %0d", inputs_selected);
      $display("Inputs Not Selected          : %0d", inputs_not_selected);
      $display("------------------- Cornercases for multiplexor Checker ---------------");
      $display("All Inputs Selected          : %0d", all_inputs_selected);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
