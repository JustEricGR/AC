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

  covergroup assert_leader_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Assert Leader Checker";

  S0 : coverpoint (!($stable(windows_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Windows_Checked = {1};
           type_option.comment = "Windows Checked";
           }
  endgroup : assert_leader_statistics

  covergroup assert_leader_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Assert Leader Checker";

  C0 : coverpoint (!($stable(max_response_time_equals_max, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Maximum_Response_Time_Equals_max = {1};
           type_option.comment = "Maximum Response Time Equals 'max'";
           }

  C1 : coverpoint (!($stable(min_response_time_equals_min, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Minimum_Response_Time_Equals_min = {1};
           type_option.comment = "Minimum Response Time Equals 'min'";
           }
  endgroup : assert_leader_cornercases

  assert_leader_statistics ASSERT_LEADER_STATISTICS = new();
  assert_leader_cornercases ASSERT_LEADER_CORNERCASES = new();

  initial
    begin
      assert_leader_statistics::type_option.comment = "Statistics for Assert Leader Checker";
      assert_leader_cornercases::type_option.comment = "Corner Cases for Assert Leader Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Assert Leader Checker ------------------");
      $display("Assertion instance is            : %m");
      $display("------------------- Statistics for Assert Leader Checker ----------------");
      $display("Windows Checked                  : %0d", windows_checked);
      $display("------------------- Corner Cases for Assert Leader Checker --------------");
      $display("Maximum Response Time Equals 'max' : %0d", max_response_time_equals_max);
      $display("Minimum Response Time Equals 'min' : %0d", min_response_time_equals_min);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
