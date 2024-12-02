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

  covergroup cam_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Content Addressable Memory Checker";

  S0 : coverpoint (!($stable(memory_writes, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Memory_Writes = {1};
           type_option.comment = "Memory Writes";
           }

  S1 : coverpoint (!($stable(match_cycles, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Match_Cycles = {1};
           type_option.comment = "Match Cycles";
           }
  endgroup : cam_statistics

  covergroup cam_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Content Addressable Memory Checker";

  C0 : coverpoint (!($stable(single_matches, @ (posedge clock))))
         iff(enable_coverpoint)
           {
            bins Single_Matches = {1};
            type_option.comment = "Single Matches";
           }

  C1 : coverpoint (!($stable(multiple_matches, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Multiple_Matches = {1};
           type_option.comment = "Multiple Matches";
           }
  
  C2 : coverpoint (!($stable(no_matches, @ (posedge clock))))
         iff (enable_coverpoint)
         {
          bins No_Matches = {1};
          type_option.comment = "No Matches";
         }
  endgroup : cam_cornercases

  cam_cornercases CAM_CORNERCASES = new();
  cam_statistics CAM_STATISTICS = new();

  initial
    begin
      cam_cornercases::type_option.comment = "Corner Cases for Content Addressable Memory Checker";
      cam_statistics::type_option.comment = "Statistics for  Content Addressable Memory Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------- Coverage for Content Addressable Memory Checker -----");
      $display("Assertion instance is     : %m");
      $display("------- Statistics for Content Addressable Memory Checker ---");
      $display("Memory Writes             : %0d", memory_writes);
      $display("Match Cycles              : %0d", match_cycles);
      $display("------- Corner Cases for Content Addressable Checker --------");
      $display("Single Matches            : %0d", single_matches);
      $display("Multiple Matches          : %0d", multiple_matches);
      $display("No Matches                : %0d", no_matches);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
