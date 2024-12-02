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
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);

  covergroup mutex_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Mutex Checker";

  S1 : coverpoint (!($stable(values_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Values_Checked = {1};
           type_option.comment = "Values Checked";
           }
  endgroup : mutex_statistics

  covergroup mutex_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Mutex Checker";

  C0 : coverpoint (!($stable(all_off, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Zero = {1};
           type_option.comment = "All Zero";
           }

  C1 : coverpoint (!($stable(all_mutex_checked, @ (posedge clock))))
         iff (enable_coverpoint && !all_mutex_checked)
           {
           bins All_Mutex_Checked = {1};
           type_option.comment = "All Mutex Checked";
           }
  endgroup : mutex_cornercases

  mutex_cornercases MUTEX_CORNERCASES = new();
  mutex_statistics MUTEX_STATISTICS = new();

  initial
    begin
      mutex_cornercases::type_option.comment = "Cornercases for Mutex Checker";
      mutex_statistics::type_option.comment = "Statistics for Mutex Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Mutex Checker ------------------");
      $display("Assertion instance is              : %m");
      $display("------------------- Statistics for Mutex Checker ----------------");
      $display("Values Checked                    : %0d", values_checked);
      $display("------------------- Cornercases for Mutex Checker ---------------");
      $display("All Zero                          : %0d", all_off);
      $display("All Mutex Checked                 : %0d", all_mutex_checked);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
