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

  covergroup hamming_distance_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Hamming Distance Checker";

  S0 : coverpoint (!($stable(total_checked_cycles, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Number_of_Cycles_Checked = {1};
           type_option.comment = "Number of Cycles Checked";
           }

  S1 : coverpoint (!($stable(equal_distance_cycles, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Number_of_Equal_Distance_Cycles = {1};
           type_option.comment = "Number of Equal Distance Cycles";
           }
  endgroup : hamming_distance_statistics

  covergroup hamming_distance_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Hamming Distance Checker";

  C0 : coverpoint (!($stable(equal_distance_cycles, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Exactly_distance_Bits_Changed = {1};
           type_option.comment = "Exactly 'distance' Bits Changed";
           }

  C1 : coverpoint (!($stable(min_bits_changed_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Exactly_min_Bits_Changed = {1};
           type_option.comment = "Exactly 'min' Bits Changed";
           }

  C2 : coverpoint (!($stable(max_bits_changed_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Exactly_max_Bits_Changed = {1};
           type_option.comment = "Exactly 'max' Bits Changed";
           }
  endgroup : hamming_distance_cornercases

  hamming_distance_cornercases HAMMING_DISTANCE_CORNERCASES = new();
  hamming_distance_statistics HAMMING_DISTANCE_STATISTICS = new();

  initial
    begin
      hamming_distance_cornercases::type_option.comment = "Corner Cases for Hamming Distance Checker";
      hamming_distance_statistics::type_option.comment = "Statistics for Hamming Distance Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Hamming Distance Checker ------------------");
      $display("Assertion instance is              : %m");
      $display("------------------- Statistics for Hamming Distance Checker ----------------");
      $display("Number of Cycles Checked                    : %0d", total_checked_cycles);
      $display("Number of Equal Distance Cycles             : %0d", equal_distance_cycles);
      $display("------------------- Corner cases for Hamming Distance Checker --------------");
      $display("Exactly 'distance' Bits Changed             : %0d", equal_distance_cycles);
      $display("Exactly 'min' Bits Changed                  : %0d", min_bits_changed_count);
      $display("Exactly 'max' Bits Changed                  : %0d", max_bits_changed_count);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
