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

  covergroup resource_share_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Resource Share Checker";

  S0 : coverpoint (!($stable(resource_accessed_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Resource_Accessed_Count = {1};
           type_option.comment = "Resource Accessed Count";
           }
  endgroup : resource_share_statistics

  covergroup resource_share_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Resource Share Checker";

  C0 : coverpoint (!($stable(all_resources_enabled, @ (posedge clock))))
         iff (enable_coverpoint && (all_resources_enabled === 1'b1))
           {
           bins All_Resources_Enabled = {1};
           type_option.comment = "All Resources Enabled";
           }
  C1 : coverpoint (!($stable(max_idle_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Max_Idle_Count  = {1};
           type_option.comment = "Max Idle Count";
           }
  C2 : coverpoint (!($stable(min_idle_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Min_Idle_Count  = {1};
           type_option.comment = "Min Idle Count";
           }
  C3 : coverpoint (!($stable(max_hold_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Max_Hold_Count  = {1};
           type_option.comment = "Max Hold Count";
           }
  C4 : coverpoint (!($stable(min_hold_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Min_Hold_Count  = {1};
           type_option.comment = "Min Hold Count";
           }
  endgroup : resource_share_cornercases

  resource_share_cornercases RESOURCE_SHARE_CORNERCASES = new();
  resource_share_statistics RESOURCE_SHARE_STATISTICS = new();

  initial
    begin
      resource_share_cornercases::type_option.comment = "Corner Cases for Resource Share Checker";
      resource_share_statistics::type_option.comment = "Statistics for Resource Share Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Resource Share Checker ------------------");
      $display("Assertion instance is   : %m");
      $display("------------------- Statistics for Resource Share Checker ----------------");
      $display("Resource Accessed Count : %0d", resource_accessed_count);
      $display("------------------- Corner Cases for Resource Share Checker ---------------");
      $display("All Resources Enabled   : %0d", all_resources_enabled);
      $display("Max Idle Count          : %0d", max_idle_count);
      $display("Min Idle Count          : %0d", min_idle_count);
      $display("Max Hold Count          : %0d", max_hold_count);
      $display("Min Hold Count          : %0d", min_hold_count);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
