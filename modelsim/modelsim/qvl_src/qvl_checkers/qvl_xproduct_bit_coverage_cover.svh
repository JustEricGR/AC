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

  covergroup xproduct_bit_coverage_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Xproduct Bit Coverage Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }

  endgroup : xproduct_bit_coverage_statistics

  covergroup xproduct_bit_coverage_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Xproduct Bit Coverage Checker";

  C0 : coverpoint (!($stable(matrix_covered, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Matrix_Covered = {1};
           type_option.comment = "Matrix Covered";
           }
  endgroup : xproduct_bit_coverage_cornercases 

  xproduct_bit_coverage_cornercases XPRODUCT_BIT_COVERAGE_CORNERCASES = new();
  xproduct_bit_coverage_statistics XPRODUCT_BIT_COVERAGE_STATISTICS = new();

  initial
    begin
      xproduct_bit_coverage_cornercases::type_option.comment = "Cornercases for Xproduct Bit Coverage Checker";
      xproduct_bit_coverage_statistics::type_option.comment = "Statistics for Xproduct Bit Coverage Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Xproduct Bit Coverage Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Xproduct Bit Coverage Checker ----------------");
      $display("Values Checked                       : %0d", values_checked);
      $display("------------------- Cornercases for Xproduct Bit Coverage Checker ---------------");
      $display("Matrix Covered          : %0d", matrix_covered);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON

