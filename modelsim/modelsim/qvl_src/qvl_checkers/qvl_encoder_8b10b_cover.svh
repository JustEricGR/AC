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

  covergroup encoder_8b10b_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Encoder 8B10B Checker";

  S0 : coverpoint (!($stable(encode_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Encode_count = {1};
           type_option.comment = "Encode Count";
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
  endgroup : encoder_8b10b_statistics

  covergroup encoder_8b10b_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Encoder 8B10B Checker";

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
  endgroup : encoder_8b10b_cornercases

  encoder_8b10b_statistics ENCODER_8B10B_STATISTICS = new();
  encoder_8b10b_cornercases ENCODER_8B10B_CORNERCASES = new();

  initial
    begin
      encoder_8b10b_statistics::type_option.comment = "Statistics for Encoder 8B10B Checker";
      encoder_8b10b_cornercases::type_option.comment = "Corner Cases for Encoder 8B10B Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Encoder 8B10B Checker ------------------");
      $display("Assertion instance is          : %m");
      $display("------------------- Statistics for Encoder 8B10B Checker ----------------");
      $display("Encode Count                   : %0d", encode_count);
      $display("Data Code Count                : %0d", data_code_count);
      $display("K Code Count                   : %0d", k_code_count);
      $display("Force Running Disparity Count  : %0d", force_rd_count);
      $display("Running Disparity Toggle Count : %0d", rd_toggle_count);
      $display("------------------- Corner Cases for Encoder 8B10B Checker --------------");
      $display("All Data Codes Checked         : %0d", all_data_codes_checked);
      $display("All K Codes Checked            : %0d", all_k_codes_checked);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
