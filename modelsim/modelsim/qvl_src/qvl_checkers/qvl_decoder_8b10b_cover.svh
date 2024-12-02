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

`ifdef QVL_SV_COVERGROUP

  covergroup decoder_8b10b_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Decoder 8B10B Checker";

  S0 : coverpoint (!($stable(decode_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Decode_count = {1};
           type_option.comment = "Decode Count";
           }

  S1 : coverpoint (!($stable(data_code_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Data_code_count = {1};
           type_option.comment = "Data Code Count";
           }

  S2 : coverpoint (!($stable(k_code_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins K_code_count = {1};
           type_option.comment = "K Code Count";
           }

  S3 : coverpoint (!($stable(force_rd_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Force_running_disparity_count = {1};
           type_option.comment = "Force Running Disparity Count";
           }

  S4 : coverpoint (!($stable(rd_toggle_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Running_disparity_toggle_count = {1};
           type_option.comment = "Running Disparity Toggle Count";
           }
  endgroup : decoder_8b10b_statistics

  covergroup decoder_8b10b_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Decoder 8B10B Checker";

  C0 : coverpoint (!($stable(all_data_codes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_data_codes_checked = {1};
           type_option.comment = "All Data Codes Checked";
           }

  C1 : coverpoint (!($stable(all_k_codes_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_K_codes_checked = {1};
           type_option.comment = "All K Codes Checked";
           }
  endgroup : decoder_8b10b_cornercases

  decoder_8b10b_statistics DECODER_8B10B_STATISTICS = new();
  decoder_8b10b_cornercases DECODER_8B10B_CORNERCASES = new();

  initial
    begin
      decoder_8b10b_statistics::type_option.comment = "Statistics for Decoder 8B10B Checker";
      decoder_8b10b_cornercases::type_option.comment = "Corner Cases for Decoder 8B10B Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Decoder 8B10B Checker ------------------");
      $display("Assertion instance is          : %m");
      $display("------------------- Statistics for Decoder 8B10B Checker ----------------");
      $display("Decode Count                   : %0d", decode_count);
      $display("Data Code Count                : %0d", data_code_count);
      $display("K Code Count                   : %0d", k_code_count);
      $display("Force Running Disparity Count  : %0d", force_rd_count);
      $display("Running Disparity Toggle Count : %0d", rd_toggle_count);
      $display("------------------- Corner Cases for Decoder 8B10B Checker --------------");
      $display("All Data Codes Checked         : %0d", all_data_codes_checked);
      $display("All K Codes Checked            : %0d", all_k_codes_checked);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
