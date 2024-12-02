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

  covergroup minimum_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Minimum Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
 
  endgroup : minimum_statistics

  covergroup minimum_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Minimum Checker";

  C0 : coverpoint (!($stable(value_is_min, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_at_Minimum = {1};
           type_option.comment = "Values at Minimum";
           }

  endgroup : minimum_cornercases

  minimum_cornercases MINIMUM_CORNERCASES = new();
  minimum_statistics MINIMUM_STATISTICS = new();

  initial
    begin
      minimum_cornercases::type_option.comment = "Cornercases for Minimum Checker";
      minimum_statistics::type_option.comment = "Statistics for Minimum Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Minimum Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for Minimum Checker ----------------");
      $display("Values Checked              : %0d", values_checked);
      $display("------------------- Corner Cases for Minimum Checker --------------");
      $display("Values at Minimum           : %0d", value_is_min);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
