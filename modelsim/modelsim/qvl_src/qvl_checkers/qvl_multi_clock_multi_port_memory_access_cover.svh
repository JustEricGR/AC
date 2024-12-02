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

  reg prevent_x_to_valid_transition_count_rd;
  reg prevent_x_to_valid_transition_count_wr;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count_rd = 1'b0;
      prevent_x_to_valid_transition_count_wr = 1'b0;
    end

  always @ (posedge read_clock)
    begin
      prevent_x_to_valid_transition_count_rd <= 1'b1;
    end

  always @ (posedge write_clock)
    begin
      prevent_x_to_valid_transition_count_wr <= 1'b1;
    end

  wire enable_coverpoint_rd; // Wire to hold "when to increment the stats"
  wire enable_coverpoint_wr; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint_rd = (areset != 1'b1 && read_reset != 1'b1 &&
                              prevent_x_to_valid_transition_count_rd == 1'b1);

  assign #1 enable_coverpoint_wr = (areset != 1'b1 && write_reset != 1'b1 &&
                              prevent_x_to_valid_transition_count_wr == 1'b1);

  covergroup multi_clock_multi_port_memory_access_statistics_rd @ (posedge read_clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multi Clock Multi Port Memory Access Checker in Read Clock";

  S0 : coverpoint (!($stable(memory_reads, @ (posedge read_clock))))
         iff (enable_coverpoint_rd)
           {
           bins Memory_Reads = {1};
           type_option.comment = "Memory Reads";
           }

  S1 : coverpoint (!($stable(single_location_multiple_reads, @ (posedge read_clock))))
         iff (enable_coverpoint_rd)
           {
           bins Single_Location_Multiple_Read = {1};
           type_option.comment = "Single Location Multiple Read";
           }

  S2 : coverpoint (!($stable(concurrent_reads, @ (posedge read_clock))))
         iff (enable_coverpoint_rd)
           {
           bins Concurrent_Reads = {1};
           type_option.comment = "Concurrent Reads";
           }
  endgroup : multi_clock_multi_port_memory_access_statistics_rd

  covergroup multi_clock_multi_port_memory_access_statistics_wr @ (posedge write_clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multi Clock Multi Port Memory Access Checker in Write Clock";

  S0 : coverpoint (!($stable(memory_writes, @ (posedge write_clock))))
         iff (enable_coverpoint_wr)
           {
           bins Memory_Writes = {1};
           type_option.comment = "Memory Writes";
           }

  S1 : coverpoint (!($stable(concurrent_writes, @ (posedge write_clock))))
         iff (enable_coverpoint_wr)
           {
           bins Concurrent_Writes = {1};
           type_option.comment = "Concurrent Writes";
           }
  endgroup : multi_clock_multi_port_memory_access_statistics_wr

  covergroup multi_clock_multi_port_memory_access_cornercases_rd @ (posedge read_clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Multi Clock Multi Port Memory Access Checker in Read Clock";

  C0 : coverpoint (!($stable(all_ports_read, @ (posedge read_clock))))
         iff (enable_coverpoint_rd)
           {
           bins All_Ports_Read = {1};
           type_option.comment = "All Ports Read";
           }

  C1 : coverpoint (!($stable(all_locations_read, @ (posedge read_clock))))
         iff (enable_coverpoint_rd)
           {
           bins All_Locations_Read = {1};
           type_option.comment = "All Locations Read";
           }
  endgroup : multi_clock_multi_port_memory_access_cornercases_rd

  covergroup multi_clock_multi_port_memory_access_cornercases_wr @ (posedge write_clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Multi Clock Multi Port Memory Access Checker in Write Clock";

  C0 : coverpoint (!($stable(all_ports_written, @ (posedge write_clock))))
         iff (enable_coverpoint_wr)
           {
           bins All_Ports_Written = {1};
           type_option.comment = "All Ports Written";
           }

  C1 : coverpoint (!($stable(all_locations_written, @ (posedge write_clock))))
         iff (enable_coverpoint_wr)
           {
           bins All_Locations_Written = {1};
           type_option.comment = "All Locations Written";
           }
  endgroup : multi_clock_multi_port_memory_access_cornercases_wr

  multi_clock_multi_port_memory_access_cornercases_rd MULTI_CLOCK_MULTI_PORT_MEMORY_ACCESS_CORNERCASES_RD = new();
  multi_clock_multi_port_memory_access_statistics_rd MULTI_CLOCK_MULTI_PORT_MEMORY_ACCESS_STATISTICS_RD = new();
  multi_clock_multi_port_memory_access_cornercases_wr MULTI_CLOCK_MULTI_PORT_MEMORY_ACCESS_CORNERCASES_WR = new();
  multi_clock_multi_port_memory_access_statistics_wr MULTI_CLOCK_MULTI_PORT_MEMORY_ACCESS_STATISTICS_WR = new();

  initial
    begin
      multi_clock_multi_port_memory_access_cornercases_rd::type_option.comment = "Corner Cases for Multi Clock Multi Port Memory Access Checker in Read Clock";
      multi_clock_multi_port_memory_access_statistics_rd::type_option.comment = "Statistics for Multi Clock Multi Port Memory Access Checker in Read Clock";
      multi_clock_multi_port_memory_access_cornercases_wr::type_option.comment = "Corner Cases for Multi Clock Multi Port Memory Access Checker in Write Clock";
      multi_clock_multi_port_memory_access_statistics_wr::type_option.comment = "Statistics for Multi Clock Multi Port Memory Access Checker in Write Clock";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("----------- Coverage for Multi Clock Multi Port Memory Access Checker ----------");
      $display("Assertion instance is              : %m");
      $display("----------- Statistics for Multi Clock Multi Port Memory Access Checker --------");
      $display("Memory Reads                   : %0d", memory_reads);
      $display("Memory Writes                  : %0d", memory_writes);
      $display("Single Location Multiple Read  : %0d", single_location_multiple_reads);
      $display("Concurrent Reads               : %0d", concurrent_reads);
      $display("Concurrent Writes              : %0d", concurrent_writes);
      $display("----------- Corner Cases for Multi Clock Multi Port Memory Access Checker -------");
      $display("All Ports Read                 : %0d", all_ports_read);
      $display("All Ports Written              : %0d", all_ports_written);
      $display("All Locations Read             : %0d", all_locations_read);
      $display("All Locations Written          : %0d", all_locations_written);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
