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

  reg prevent_x_to_valid_transition_count_enq;
  reg prevent_x_to_valid_transition_count_deq;

  initial
    begin
      #1;
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count_enq = 1'b0;
      prevent_x_to_valid_transition_count_deq = 1'b0;
    end

  always @ (posedge enq_clock)
    begin
      prevent_x_to_valid_transition_count_enq <= 1'b1;
    end

  always @ (posedge deq_clock)
    begin
      prevent_x_to_valid_transition_count_deq <= 1'b1;
    end

  wire enable_coverpoint_enq; // Wire to hold "when to increment the stats"
  wire enable_coverpoint_deq; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint_enq = (areset != 1'b1 && enq_reset != 1'b1 &&
                              prevent_x_to_valid_transition_count_enq == 1'b1);

  assign #1 enable_coverpoint_deq = (areset != 1'b1 && deq_reset != 1'b1 &&
                              prevent_x_to_valid_transition_count_deq == 1'b1);

  covergroup multi_clock_multi_enq_deq_fifo_statistics_enq @ (posedge enq_clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multi Clock Multi Enqueue Dequeue FIFO Checker in Enqueue Clock";

  S0 : coverpoint (!($stable(enqueues, @ (posedge enq_clock))))
         iff (enable_coverpoint_enq)
           {
           bins Enqueues = {1};
           type_option.comment = "Enqueues";
           }
  endgroup : multi_clock_multi_enq_deq_fifo_statistics_enq

  covergroup multi_clock_multi_enq_deq_fifo_statistics_deq @ (posedge deq_clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multi Clock Multi Enqueue Dequeue FIFO Checker in Dequeue Clock";

  S0 : coverpoint (!($stable(dequeues, @ (posedge deq_clock))))
         iff (enable_coverpoint_deq)
           {
           bins Dequeues = {1};
           type_option.comment = "Dequeues";
           }
  endgroup : multi_clock_multi_enq_deq_fifo_statistics_deq

  covergroup multi_clock_multi_enq_deq_fifo_cornercases_enq @ (posedge enq_clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Multi Clock Multi Enqueue Dequeue FIFO Checker in Enqueue Clock";

  C0 : coverpoint (!($stable(full_count, @ (posedge enq_clock))))
         iff (enable_coverpoint_enq)
           {
           bins FIFO_is_Full = {1};
           type_option.comment = "FIFO is Full";
           }

  C1 : coverpoint (!($stable(high_water_count, @ (posedge enq_clock))))
         iff (enable_coverpoint_enq)
           {
           bins FIFO_is_Over_High_Water_Mark = {1};
           type_option.comment = "FIFO is Over High-water Mark";
           }
  endgroup : multi_clock_multi_enq_deq_fifo_cornercases_enq

  covergroup multi_clock_multi_enq_deq_fifo_cornercases_deq @ (posedge deq_clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Multi Clock Multi Enqueue Dequeue FIFO Checker in Dequeue Clock";

  C0 : coverpoint (!($stable(empty_count, @ (posedge deq_clock))))
         iff (enable_coverpoint_deq)
           {
           bins FIFO_is_Empty = {1};
           type_option.comment = "FIFO is Empty";
           }

  C1 : coverpoint (!($stable(low_water_count, @ (posedge deq_clock))))
         iff (enable_coverpoint_deq)
           {
           bins FIFO_is_Below_Low_Water_Mark = {1};
           type_option.comment = "FIFO is Below Low-water Mark";
           }
  endgroup : multi_clock_multi_enq_deq_fifo_cornercases_deq

  multi_clock_multi_enq_deq_fifo_cornercases_enq MULTI_CLOCK_MULTI_ENQ_DEQ_FIFO_CORNERCASES_ENQ = new();
  multi_clock_multi_enq_deq_fifo_statistics_enq MULTI_CLOCK_MULTI_ENQ_DEQ_FIFO_STATISTICS_ENQ = new();
  multi_clock_multi_enq_deq_fifo_cornercases_deq MULTI_CLOCK_MULTI_ENQ_DEQ_FIFO_CORNERCASES_DEQ = new();
  multi_clock_multi_enq_deq_fifo_statistics_deq MULTI_CLOCK_MULTI_ENQ_DEQ_FIFO_STATISTICS_DEQ = new();

  initial
    begin
      multi_clock_multi_enq_deq_fifo_cornercases_enq::type_option.comment = "Corner Cases for Multi Clock Multi Enqueue Dequeue FIFO Checker in Enqueue Clock";
      multi_clock_multi_enq_deq_fifo_statistics_enq::type_option.comment = "Statistics for Multi Clock Multi Enqueue Dequeue FIFO Checker in Enqueue Clock";
      multi_clock_multi_enq_deq_fifo_cornercases_deq::type_option.comment = "Corner Cases for Multi Clock Multi Enqueue Dequeue FIFO Checker in Dequeue Clock";
      multi_clock_multi_enq_deq_fifo_statistics_deq::type_option.comment = "Statistics for Multi Clock Multi Enqueue Dequeue FIFO Checker in Dequeue Clock";
    end
`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("----------- Coverage for Multi Clock Multi Enqueue Dequeue FIFO Checker ----------");
      $display("Assertion instance is              : %m");
      $display("----------- Statistics for Multi Clock Multi Enqueue Dequeue FIFO Checker --------");
      $display("Enqueues                : %0d", enqueues);
      $display("Dequeues                : %0d", dequeues);
      $display("----------- Corner Cases for Multi Clock Multi Enqueue Dequeue FIFO Checker -------");
      $display("FIFO is Full            : %0d", full_count);
      $display("FIFO is Empty           : %0d", empty_count);
      $display("FIFO is Over High-water Mark : %0d", high_water_count);
      $display("FIFO is Below Low-water Mark : %0d", low_water_count);
    end
`endif //QVL_CW_FINAL_COVER
`endif //QVL_COVER_ON
