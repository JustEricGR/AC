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

  covergroup same_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Same Checker";

  S0 : coverpoint (!($stable(evaluations, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Evaluations = {1};
           type_option.comment = "Evaluations";
           }

  endgroup : same_statistics

  covergroup same_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Same Checker";


  C0 : coverpoint (!($stable(each_bit_set_to_one, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_Bit_Set_to_One = {1};
           type_option.comment = "Each Bit Set to One";
           }

  C1 : coverpoint (!($stable(each_bit_set_to_zero, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_Bit_Set_to_Zero = {1};
           type_option.comment = "Each Bit Set to Zero";
           }

  endgroup : same_cornercases 

  same_statistics SAME_STATISTICS = new();
  same_cornercases SAMEE_CORNERCASES = new();

  initial
    begin
     same_statistics::type_option.comment = "Statistics for Same Checker";
     same_cornercases::type_option.comment = "Corner Cases for Same Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Same Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Same Checker ----------------");
      $display("Evaluations                                            : %0d", evaluations);
      $display("------------------- Corner Cases for Same Checker --------------");
      $display("Each Bit Set to One                                    : %0d", each_bit_set_to_one);
      $display("Each Bit Set to Zero                                   : %0d", each_bit_set_to_zero);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON

