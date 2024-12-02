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

  covergroup maximum_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Maximum Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }

  endgroup : maximum_statistics

  covergroup maximum_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Maximum Checker";

  C0 : coverpoint (!($stable(value_is_max, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_at_Maximum = {1};
           type_option.comment = "Values at Maximum";
           }

  endgroup : maximum_cornercases

  maximum_cornercases MAXIMUM_CORNERCASES = new();
  maximum_statistics MAXIMUM_STATISTICS = new();

  initial
    begin
      maximum_cornercases::type_option.comment = "Cornercases for Maximum Checker";
      maximum_statistics::type_option.comment = "Statistics for Maximum Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Maximum Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for Maximum Checker ----------------");
      $display("Values Checked             : %0d", values_checked);
      $display("------------------- Corner Cases for Maximum Checker --------------");
      $display("Values at Maximum          : %0d", value_is_max);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
