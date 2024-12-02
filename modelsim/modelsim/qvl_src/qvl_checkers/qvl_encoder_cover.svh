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

  covergroup encoder_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Encoder Checker";

  S1 : coverpoint (!($stable(encode_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Encode_Count = {1};
           type_option.comment = "Encode Count";
           }
 
  S2 : coverpoint (!($stable(encodes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Encodes_Checked = {1};
           type_option.comment = "Encodes Checked";
           }

  endgroup : encoder_statistics

  covergroup encoder_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Encoder Checker";

  C1 : coverpoint (!($stable(all_encodes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Encodes_Checked = {1};
           type_option.comment = "All Encodes Checked";
           }

  endgroup : encoder_cornercases

  encoder_cornercases ENCODER_CORNERCASES = new();
  encoder_statistics ENCODER_STATISTICS = new();

  initial
    begin
      encoder_cornercases::type_option.comment = "Cornercases for Encoder Checker";
      encoder_statistics::type_option.comment = "Statistics for Encoder Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Encoder Checker ------------------");
      $display("Assertion instance is    : %m");
      $display("------------------- Statistics for Encoder Checker ----------------");
      $display("Encode Count             : %0d", encode_count);
      $display("Encodes Checked          : %0d", encodes_checked);
      $display("------------------- Corner Cases for Encoder Checker --------------");
      $display("All Encodes Checked      : %0d", all_encodes_checked);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
