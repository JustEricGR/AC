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

  covergroup memory_access_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Memory Access Checker";

  S0 : coverpoint (!($stable(simultaneous_reads_and_writes, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Simultaneous_Reads_And_Writes = {1};
           type_option.comment = "Simultaneous Reads And Writes";
           }
  S1 : coverpoint (!($stable(locations_read, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Locations_Read = {1};
           type_option.comment = "Locations Read";
           }
  S2 : coverpoint (!($stable(locations_written, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Locations_Written = {1};
           type_option.comment = "Locations Written";
           }
  endgroup : memory_access_statistics

  covergroup memory_access_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for Memory Access Checker";

  C0 : coverpoint (!($stable(memory_reads, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Memory_Reads = {1};
           type_option.comment = "Memory Reads";
           }
  C1 : coverpoint (!($stable(memory_writes, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Memory_Writes = {1};
           type_option.comment = "Memory Writes";
           }
  C2 : coverpoint (!($stable(same_addr_reads_and_writes, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Same_Addr_Reads_and_Writes= {1};
           type_option.comment = "Same Addr Reads and Writes";
           }
  endgroup : memory_access_cornercases

  memory_access_cornercases MEMORY_ACCESS_CORNERCASES = new();
  memory_access_statistics MEMORY_ACCESS_STATISTICS = new();

  initial
    begin
      memory_access_cornercases::type_option.comment = "Corner cases for memory access Checker";
      memory_access_statistics::type_option.comment = "Statistics for memory access Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Memory Access Checker ------------------");
      $display("Assertion instance is        : %m");
      $display("------------------- Statistics for Memory Access Checker ----------------");
      $display("Simultaneous Reads And Writes: %0d", simultaneous_reads_and_writes);
      $display("Locations Read               : %0d", locations_read);
      $display("Locations Written            : %0d", locations_written);
      $display("------------------- Corner cases for Memory Access Checker ---------------");
      $display("Memory Reads                 : %0d", memory_reads);
      $display("Memory Writes                : %0d", memory_writes);
      $display("Same Addr Reads And Writes   : %0d", same_addr_reads_and_writes);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
