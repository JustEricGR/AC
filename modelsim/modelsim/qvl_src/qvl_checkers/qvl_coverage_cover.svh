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

  covergroup covered_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Coverage Checker";

  S0 : coverpoint (!($stable(covered_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Covered_Count = {1};
           type_option.comment = "Covered Count";
           }
  endgroup : covered_statistics

  covergroup covered_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Coverage Checker";

  C0 : coverpoint (($rose(&bit_stats, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Subexpressions_Covered = {1};
           type_option.comment = "All Subexpressions Covered";
           }
  endgroup : covered_cornercases

  covered_cornercases COVERED_CORNERCASES = new();
  covered_statistics COVERED_STATISTICS = new();

  initial
    begin
      covered_cornercases::type_option.comment = "Cornercases for Coverage Checker";
      covered_statistics::type_option.comment = "Statistics for Coverage Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Coverage Checker ------------------");
      $display("Assertion instance is            : %m");
      $display("------------------- Statistics for Coverage Checker ----------------");
      $display("Covered Count                    : %0d", covered_count);
      $display("------------------- Cornercases for Coverage Checker ---------------");
      $display("All Subexpressions Covered       : %0d", &bit_stats);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
