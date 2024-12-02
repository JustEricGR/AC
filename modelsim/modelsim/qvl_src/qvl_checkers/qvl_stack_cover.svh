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

  reg        prevent_x_to_valid_transition_count;

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

`ifdef QVL_SV_COVERGROUP

  covergroup stack_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Stack Checker";

  S0 : coverpoint (!($stable(push_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Pushes = {1};
           type_option.comment = "Pushes";
           }

  S1 : coverpoint (!($stable(pop_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Pops = {1};
           type_option.comment = "Pops";
           }

  endgroup : stack_statistics


  covergroup stack_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Stack Checker";

  C0 : coverpoint (!($stable(full_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Stack_Is_Full = {1};
           type_option.comment = "Stack Is Full";
           }

  C1 : coverpoint (!($stable(empty_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Stack_Is_Empty = {1};
           type_option.comment = "Stack Is Empty";
           }

  C2 : coverpoint (!($stable(high_water_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Stack_Is_Over_High_water_Mark = {1};
           type_option.comment = "Stack Is Over High-water Mark";
           }

  endgroup : stack_cornercases

  stack_cornercases STACK_CORNERCASES = new();
  stack_statistics STACK_STATISTICS = new();

  initial
    begin
      stack_cornercases::type_option.comment = "Corner Cases for Stack Checker";
      stack_statistics::type_option.comment = "Statistics for Stack Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------- Coverage for Stack Checker -----------------");
      $display("Assertion instance is         : %m");
      $display("------------- Statistics for Stack Checker ---------------");
      $display("Pushes                        : %0d", push_count);
      $display("Pops                          : %0d", pop_count);
      $display("------------- Corner cases for Stack Checker -------------");
      $display("Stack Is Full                 : %0d", full_count);
      $display("Stack Is Empty                : %0d", empty_count);
      $display("Stack Is Over High_water Mark : %0d", high_water_count);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
