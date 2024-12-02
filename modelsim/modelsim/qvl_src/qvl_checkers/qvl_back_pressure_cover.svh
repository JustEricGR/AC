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

  covergroup back_pressure_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Back Pressure Checker";

  S0 : coverpoint (!($stable(windows_checked, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Windows_Checked = {1};
           type_option.comment = "Windows Checked";
           }

  endgroup : back_pressure_statistics

  covergroup back_pressure_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Back Pressure Checker";


  C0 : coverpoint (!($stable(min_boundary_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins xmit_ready_Deasserted_at_Minimum_Boundary = {1};
           type_option.comment = "'transmit_ready' Deasserted at Minimum Cycles";
           }

  C1 : coverpoint (!($stable(max_boundary_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins xmit_ready_Deasserted_at_Maximum_Boundary = {1};
           type_option.comment = "'transmit_ready' Deasserted at Maximum Cycles";
           }

  endgroup : back_pressure_cornercases 

  back_pressure_statistics BACK_PRESSURE_STATISTICS = new();
  back_pressure_cornercases BACK_PRESSURE_CORNERCASES = new();

  initial
    begin
      back_pressure_statistics::type_option.comment = "Statistics for Back Pressure Checker";
      back_pressure_cornercases::type_option.comment = "Cornercases for Back Pressure Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Back Pressure Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Back Pressure Checker ----------------");
      $display("Windows Checked                                      : %0d", windows_checked);
      $display("------------------- Cornercases for Back Pressure Checker ---------------");
      $display("'transmit_ready' Deasserted at Minimum Cycles        : %0d", min_boundary_count);
      $display("'transmit_ready' Deasserted at Maximum Cycles        : %0d", max_boundary_count);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON

