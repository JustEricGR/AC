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

  covergroup constant_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Constant Checker";

  S1 : coverpoint (!($stable(cycles_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Checked = {1};
           type_option.comment = "Cycles Checked";
           }
 
  endgroup : constant_statistics

  constant_statistics CONSTANT_STATISTICS = new();

  initial
    begin
      constant_statistics::type_option.comment = "Statistics for Constant Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Constant Checker ------------------");
      $display("Assertion instance is             : %m");
      $display("------------------- Statistics for Constant Checker ----------------");
      $display("Cycles Checked                    : %0d", cycles_checked);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
