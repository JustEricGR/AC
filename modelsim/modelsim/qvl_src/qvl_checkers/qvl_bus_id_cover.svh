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

  covergroup bus_id_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Bus ID Checker";

  S0 : coverpoint (!($stable(unique_ids_issued, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Unique_IDs_Issued = {1};
           type_option.comment = "Unique IDs Issued";
           }
  endgroup : bus_id_statistics

  covergroup bus_id_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Bus ID Checker";

  C0 : coverpoint (!($stable(ids_requested, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Requested = {1};
           type_option.comment = "IDs Requested";
           }

  C1 : coverpoint (!($stable(ids_returned, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins IDs_Returned = {1};
           type_option.comment = "IDs Returned";
           }

  C2 : coverpoint (!($stable(maximum_ids_are_out_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Outstanding_IDs_Equal_Maximum_IDs = {1};
           type_option.comment = "Outstanding IDs Equal max_ids";
           }
  endgroup : bus_id_cornercases

  bus_id_statistics BUS_ID_STATISTICS = new();
  bus_id_cornercases BUS_ID_CORNERCASES = new();

  initial
    begin
      bus_id_cornercases::type_option.comment = "Corner Cases for Bus ID Checker";
      bus_id_statistics::type_option.comment = "Statistics for Bus ID Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Bus ID Checker ------------------");
      $display("Assertion instance is : %m");
      $display("------------------- Statistics for Bus ID Checker ----------------");
      $display("Unique IDs Issued                   : %0d", unique_ids_issued);
      $display("------------------- Corner cases for Bus ID Checker --------------");
      $display("IDs Requested                       : %0d", ids_requested);
      $display("IDs Returned                        : %0d", ids_returned);
      $display("Outstanding IDs Equal Maximum IDs   : %0d", maximum_ids_are_out_count);
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
