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

  covergroup data_loaded_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Data Loaded Checker";

  S0 : coverpoint (!($stable(windows_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Windows_Checked = {1};
           type_option.comment = "Windows Checked";
           }
  endgroup : data_loaded_statistics

  covergroup data_loaded_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Data Loaded Checker";

  C0 : coverpoint (!($stable(data_loaded_at_window_open_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Data_Loaded_at_the_Begining_of_the_Window = {1};
           type_option.comment = "Data Loaded at the Begining of the Window";
           }
  C1 : coverpoint (!($stable(data_loaded_at_window_close_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Data_Loaded_at_the_End_of_the_Window = {1};
           type_option.comment = "Data Loaded at the End of the Window";
           }
  endgroup : data_loaded_cornercases

  data_loaded_cornercases DATA_LOADED_CORNERCASES = new();
  data_loaded_statistics DATA_LOADED_STATISTICS = new();

  initial
    begin
      data_loaded_cornercases::type_option.comment = "Corner cases for Data Loaded Checker";
      data_loaded_statistics::type_option.comment = "Statistics for Data Loaded Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Data Loaded Checker ------------------");
      $display("Assertion instance is                     : %m");
      $display("------------------- Statistics for Data Loaded Checker ----------------");
      $display("Windows Checked                           : %0d", windows_checked);
      $display("------------------- Corner cases for Data Loaded Checker ---------------");
      $display("Data Loaded at the Beginning of the Window: %0d", data_loaded_at_window_open_count);
      $display("Data Loaded at the End of the Window      : %0d", data_loaded_at_window_close_count);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
