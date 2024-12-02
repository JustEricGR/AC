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

  covergroup bits_off_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Bits Off Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
  
  endgroup : bits_off_statistics

  covergroup bits_off_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Bits Off Checker";

  C0 : coverpoint (!($stable(min_bits_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Minimum_Bits_Deasserted = {1};
           type_option.comment = "Minimim Bits Deasserted";
           }

  C1 : coverpoint (!($stable(max_bits_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Maximum_Bits_Deasserted = {1};
           type_option.comment = "Maximum Bits Deasserted";
           }

  endgroup : bits_off_cornercases

  bits_off_cornercases BITS_OFF_CORNERCASES = new();
  bits_off_statistics BITS_OFF_STATISTICS = new();

  initial
    begin
      bits_off_cornercases::type_option.comment = "Cornercases for Bits Off Checker";
      bits_off_statistics::type_option.comment = "Statistics for Bits Off Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Bits Off Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Bits Off Checker ----------------");
      $display("Values Checked                       : %0d", values_checked);
      $display("------------------- Cornercases for Bits Off Checker ---------------");
      $display("Minimum Bits Deasserted             : %0d", min_bits_count);
      $display("Maximum Bits Deasserted             : %0d", max_bits_count);

    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON

