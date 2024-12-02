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

  covergroup same_bit_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Same Bit Checker";

  S0 : coverpoint (!($stable(evaluations, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Evaluations = {1};
           type_option.comment = "Evaluations";
           }
 
  endgroup : same_bit_statistics

  covergroup same_bit_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Same Bit Checker";

  C0 : coverpoint (!($stable(all_bits_zero, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Bits_Zero = {1};
           type_option.comment = "All Bits Zero";
           }
  C1 : coverpoint (!($stable(all_bits_one, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Bits_One = {1};
           type_option.comment = "All Bits One";
           }

  endgroup : same_bit_cornercases

  same_bit_statistics SAME_BIT_STATISTICS = new();
  same_bit_cornercases SAME_BIT_CORNERCASES = new();

  initial
    begin
      same_bit_cornercases::type_option.comment = "Corner Cases for Same Bit Checker";
      same_bit_statistics::type_option.comment = "Statistics for Same Bit Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Same Bit Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for Same Bit Checker ----------------");
      $display("Evaluations        : %0d", evaluations);
      $display("------------------- Corner Cases for Same Bit Checker --------------");
      $display("All Bits Zero      : %0d", all_bits_zero);
      $display("All Bits One       : %0d", all_bits_one);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
