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

  covergroup data_used_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Data Used Checker";

  S0 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
  endgroup : data_used_statistics

  covergroup data_used_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Data Used Checker";

  C0 : coverpoint (!($stable(data_used_at_window_open_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Data_Used_at_the_Beginning_of_the_Window = {1};
           type_option.comment = "Data Used at the Beginning of the Window";
           }

  C1 : coverpoint (!($stable(data_used_at_window_close_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Data_Used_at_the_End_of_the_Window = {1};
           type_option.comment = "Data Used at the End of the Window";
           }
  endgroup : data_used_cornercases

  data_used_statistics DATA_USED_STATISTICS = new();
  data_used_cornercases DATA_USED_CORNERCASES = new();

  initial
    begin
      data_used_statistics::type_option.comment = "Statistics for Data Used Checker";
      data_used_cornercases::type_option.comment = "Corner Cases for Data Used Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Data Used Checker ------------------");
      $display("Assertion instance is              : %m");
      $display("------------------- Statistics for Data Used Checker ----------------");
      $display("Values Checked                        : %0d", values_checked);
      $display("------------------- Corner Cases for Data Used Checker --------------");
      $display("Data Used at the Beginning of the Window : %0d", data_used_at_window_open_count);
      $display("Data Used at the End of the Window       : %0d", data_used_at_window_close_count);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
