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

  reg [63:0] simultaneous_inserts_removes;
  initial
  begin
    simultaneous_inserts_removes = 64'b0;
  end
  always @(posedge clock)
    begin
      if((|insert) && (|remove) && (~reset) && (~areset) &&
         (~qvl_cdi_insert_fire_c) && (~qvl_cdi_remove_fire_c))
        simultaneous_inserts_removes <= simultaneous_inserts_removes +1;
    end

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

  covergroup channel_data_integrity_statistics @(posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Channel Data Integrity Checker";

  S0 : coverpoint (!($stable(simultaneous_inserts_removes, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Simultaneous_Inserts_and_Removes = {1};
           type_option.comment = "Simultaneous Inserts and Removes";
           }
  S1 : coverpoint (!($stable(inserts, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Inserts = {1};
           type_option.comment = "Inserts";
           }
  S2 : coverpoint (!($stable(removes, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Removes = {1};
           type_option.comment = "Removes";
           }
  S3 : coverpoint (!($stable(cancels, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Cancels = {1};
           type_option.comment = "Cancels";
           }
  endgroup : channel_data_integrity_statistics 

  covergroup channel_data_integrity_cornercases @(posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Channel Data Integrity Checker";

  C0 : coverpoint (!($stable(full_count, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Channel_is_Full = {1};
           type_option.comment = " Channel is Full";
           }
  
  C1 : coverpoint (!($stable(empty_count, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Channel_is_Empty = {1};
           type_option.comment = " Channel is Empty";
           }
  C2 : coverpoint (!($stable(high_water_count, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Channel_is_Over_High_water_Mark = {1};
           type_option.comment = " Channel is Over High water Mark";
           }
  
  C3 : coverpoint (!($stable(each_bit_set_to_one, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_bit_Set_to_One = {1};
           type_option.comment = " Each Bit Set to One";
           }

  C4 : coverpoint (!($stable(each_bit_set_to_zero, @(posedge clock))))
         iff (enable_coverpoint)
           {
           bins Each_bit_Set_to_Zero = {1};
           type_option.comment = "Each Bit Set to Zero"; 
           }

  endgroup : channel_data_integrity_cornercases 

  channel_data_integrity_statistics CHANNEL_DATA_INTEGRITY_STATISTICS = new();
  channel_data_integrity_cornercases CHANNEL_DATA_INTEGRITY_CORNERCASES = new();

  initial
    begin
      channel_data_integrity_cornercases::type_option.comment =
                             "Corner Cases for Channel Data Integrity Checker";
      channel_data_integrity_statistics::type_option.comment = 
                             "Statistics for Channel Data Integrity Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------- Coverage for Channel Data Integrity Checker ---------");
      $display("Assertion instance is                  : %m");
      $display("------- Statistics for Channel Data Integrity Checker -------");
      $display("Simultaneous Inserts and Removes   : %0d",simultaneous_inserts_removes);
      $display("Inserts                            : %0d",inserts);
      $display("Removes                            : %0d",removes);
      $display("Cancels                            : %0d",cancels);
      $display("------- Corner Cases for Channel Data Integrity Checker -----");
      $display("Channel is Full                    : %0d",full_count);
      $display("Channel is Empty                   : %0d",empty_count);
      $display("Channel is Over High-water Mark    : %0d",high_water_count);
      $display("Each Bit Set to One                : %0d",each_bit_set_to_one);
      $display("Each Bit Set to Zero               : %0d",each_bit_set_to_zero);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
