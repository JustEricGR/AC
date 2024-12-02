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


  covergroup crc_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for CRC Checker";

  S1 : coverpoint (!($stable(total_crc_computations, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Total_CRC_Computations = {1};
           type_option.comment = "Total CRC Computations";
           }
  endgroup : crc_statistics

  covergroup crc_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for CRC Checker";

  C1 : coverpoint (!($stable(cycles_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Checked = {1};
           type_option.comment = "Cycles Checked";
           }
  endgroup : crc_cornercases

  crc_statistics CRC_STATISTICS = new();
  crc_cornercases CRC_CORNERCASES = new();

  initial
    begin
      crc_cornercases::type_option.comment = "Corner Cases for CRC Checker";
      crc_statistics::type_option.comment = "Statistics for CRC Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for CRC Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for CRC Checker ----------------");
      $display("Total CRC Computations   : %0d", total_crc_computations);
      $display("------------------- Corner Cases for CRC Checker --------------");
      $display("Cycles Checked           : %0d", cycles_checked);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
