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
      #1;
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                                  prevent_x_to_valid_transition_count == 1'b1);

  covergroup bus_driver_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Bus Driver Checker";

  S0 : coverpoint (!($stable(cycles_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Checked = {1};
           type_option.comment = "Cycles Checked";
           }
  S1 : coverpoint (!($stable(cycles_undriven, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Undriven = {1};
           type_option.comment = "Cycles Undriven";
           }
  S2 : coverpoint (!($stable(cycles_driven, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cycles_Driven = {1};
           type_option.comment = "Cycles Driven";
           }
  endgroup : bus_driver_statistics

  covergroup bus_driver_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Bus Driver Checker";

  C0 : coverpoint (!($stable(all_driver_enabled_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins All_Driver_Enabled_Count = {1};
           type_option.comment = "All Drivers Enabled";
           }
  C1 : coverpoint (!($stable(max_undriven_cycles_elapsed_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Max_Undriven_Cycles_Elapsed_Count = {1};
           type_option.comment = "Max Undriven Cycles Elapsed";
           }
  endgroup : bus_driver_cornercases

  bus_driver_cornercases BUS_DRIVER_CORNERCASES = new();
  bus_driver_statistics BUS_DRIVER_STATISTICS = new();

  initial
    begin
      bus_driver_cornercases::type_option.comment = "Corner cases for bus driver Checker";
      bus_driver_statistics::type_option.comment = "Statistics for bus driver Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Bus Driver Checker ------------------");
      $display("Assertion instance is             : %m");
      $display("------------------- Statistics for Bus Driver Checker ----------------");
      $display("Cycles Checked                    : %0d", cycles_checked);
      $display("Cycles Undriven                   : %0d", cycles_undriven);
      $display("Cycles Driven                     : %0d", cycles_driven);
      $display("------------------- Corner cases for Bus Driver Checker ---------------");
      $display("All Driver Enabled Count          : %0d", all_driver_enabled_count);
      $display("Max Undriven Cycles Elapsed Count : %0d", max_undriven_cycles_elapsed_count);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
