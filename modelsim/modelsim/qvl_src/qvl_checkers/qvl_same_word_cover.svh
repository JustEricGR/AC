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

  covergroup same_word_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Same Word Checker";

  S0 : coverpoint (!($stable(evaluations, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Evaluations = {1};
           type_option.comment = "Evaluations";
           }
  endgroup : same_word_statistics


  covergroup same_word_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Same Word Checker";

  C0 : coverpoint (!($stable(each_bit_set_to_one, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_Bit_Set_To_One = {1};
           type_option.comment = "Each Bit Set To One";
           }

  C1 : coverpoint (!($stable(each_bit_set_to_zero, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_Bit_Set_To_Zero = {1};
           type_option.comment = "Each Bit Set To Zero";
           }
  endgroup : same_word_cornercases

  same_word_statistics SAME_WORD_STATISTICS = new();
  same_word_cornercases SAME_WORD_CORNERCASES = new();

  initial
    begin
      same_word_cornercases::type_option.comment = "Corner Cases for Same Word Checker";
      same_word_statistics::type_option.comment = "Statistics for Same Word Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------- Coverage for Same Word Checker -----------------");
      $display("Assertion instance is   : %m");
      $display("------------- Statistics for Same Word Checker ---------------");
      $display("Evaluations             : %0d", evaluations);
      $display("------------- Corner cases for Same Word Checker -------------");
      $display("Each Bit Set To One     : %0d", each_bit_set_to_one);
      $display("Each Bit Set To Zero    : %0d", each_bit_set_to_zero);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
