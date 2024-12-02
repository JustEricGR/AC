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

  covergroup bits_on_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Bits On Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }

  endgroup : bits_on_statistics

  covergroup bits_on_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Bits On Checker";

  C0 : coverpoint (!($stable(min_bits_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Minimum_Bits_Asserted = {1};
           type_option.comment = "Minimum Bits Asserted";
           }

  C1 : coverpoint (!($stable(max_bits_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Maximum_Bits_Asserted = {1};
           type_option.comment = "Maximum Bits Asserted";
           }

  endgroup : bits_on_cornercases

  bits_on_cornercases BITS_ON_CORNERCASES = new();
  bits_on_statistics BITS_ON_STATISTICS = new();

  initial
    begin
      bits_on_cornercases::type_option.comment = "Cornercases for Bits On Checker";
      bits_on_statistics::type_option.comment = "Statistics for Bits On Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Bits On Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Bits On Checker ----------------");
      $display("Values Checked                       : %0d", values_checked);
      $display("------------------- Cornercases for Bits On Checker ---------------");
      $display("Minimum Bits Asserted              : %0d", min_bits_count);
      $display("Maximum Bits Asserted              : %0d", max_bits_count);

    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON

