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
  reg [63:0] simultaneous_enq_deq;

  initial
    begin
      simultaneous_enq_deq = 64'b0; 
    end
   
  always @ (posedge clock)
    begin
      if ((enq) && (deq) && (~reset) && (~areset))
        simultaneous_enq_deq <=  simultaneous_enq_deq + 1;
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

  covergroup fifo_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Fifo Checker";

  S0 : coverpoint (!($stable(enqueues, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Enqueues = {1};
           type_option.comment = "Enqueues";
           }

  S1 : coverpoint (!($stable(dequeues, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Dequeues = {1};
           type_option.comment = "Dequeues";
           }

  endgroup : fifo_statistics

  covergroup fifo_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for FIFO Checker";

  C0 : coverpoint (!($stable(full_count, @ (posedge clock))))
         iff(enable_coverpoint)
           {
            bins FIFO_is_Full = {1};
            type_option.comment = "FIFO is Full";
           }

  C1 : coverpoint (!($stable(empty_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins FIFO_is_Empty = {1};
           type_option.comment = "FIFO is Empty";
           }
  
  C2 : coverpoint (!($stable(high_water_count, @ (posedge clock))))
         iff (enable_coverpoint)
         {
          bins FIFO_is_Over_High_water_Mark = {1};
          type_option.comment = "FIFO is Over High-water Mark";
         }

  C3 : coverpoint (!($stable(simultaneous_enq_deq, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Simulatneous_Enqueues_and_Dequeues = {1};
           type_option.comment = "Simulatneous Enqueues and Dequeues";
           }

  endgroup : fifo_cornercases

  fifo_cornercases FIFO_CORNERCASES = new();
  fifo_statistics FIFO_STATISTICS = new();

  initial
    begin
      fifo_cornercases::type_option.comment = "Corner Cases for FIFO Checker";
      fifo_statistics::type_option.comment = "Statistics for FIFO Checker";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for FIFO Checker ------------------");
      $display("Assertion instance is               : %m");
      $display("------------------- Statistics for FIFO Checker ----------------");
      $display("Enqueues                            : %0d", enqueues);
      $display("Dequeues                            : %0d", dequeues);
      $display("------------------- Corner Cases for FIFO Checker --------------");
      $display("FIFO is Full                        : %0d", full_count);
      $display("FIFO is Empty                       : %0d", empty_count);
      $display("FIFO is Over High-water Mark        : %0d", high_water_count );
      $display("Simultaneous Enqueues and Dequeues  : %0d", simultaneous_enq_deq);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
