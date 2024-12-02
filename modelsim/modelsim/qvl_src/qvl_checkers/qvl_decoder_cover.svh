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

  covergroup decoder_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Decoder Checker";

  S1 : coverpoint (!($stable(decode_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Decode_Count = {1};
           type_option.comment = "Decode Count";
           }
 
  S2 : coverpoint (!($stable(decodes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Decodes_Checked = {1};
           type_option.comment = "Decodes Checked";
           }

  endgroup : decoder_statistics

  covergroup decoder_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Decoder Checker";

  C1 : coverpoint (!($stable(all_decodes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Decodes_Checked = {1};
           type_option.comment = "All Decodes Checked";
           }

  endgroup : decoder_cornercases

  decoder_cornercases DECODER_CORNERCASES = new();
  decoder_statistics DECODER_STATISTICS = new();

  initial
    begin
      decoder_cornercases::type_option.comment = "Cornercases for Decoder Checker";
      decoder_statistics::type_option.comment = "Statistics for Decoder Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Decoder Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for Decoder Checker ----------------");
      $display("Decode Count             : %0d", decode_count);
      $display("Decodes Checked          : %0d", decodes_checked);
      $display("------------------- Corner Cases for Decoder Checker --------------");
      $display("All Decodes Checked      : %0d", all_decodes_checked);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
