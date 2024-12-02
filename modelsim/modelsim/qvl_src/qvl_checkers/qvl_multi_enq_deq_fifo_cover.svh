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

  reg [63:0] simultaneous_enq_deq;

  initial
    begin
      simultaneous_enq_deq = 64'b0;
    end

  always @ (posedge clock)
    begin
      if ((|enq) && (|deq) && (~reset) && (~areset))
        simultaneous_enq_deq <=  simultaneous_enq_deq + 1;
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  covergroup multi_enq_deq_fifo_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for Multi Enq Deq Fifo Checker";

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
  endgroup : multi_enq_deq_fifo_statistics

  covergroup multi_enq_deq_fifo_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for Multi Enq Deq Fifo Checker";

  C0 : coverpoint (!($stable(full_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins FIFO_Is_Full = {1};
           type_option.comment = "FIFO Is Full";
           }
  C1 : coverpoint (!($stable(empty_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins FIFO_Is_Empty = {1};
           type_option.comment = "FIFO Is Empty";
           }
  C2 : coverpoint (!($stable(high_water_count, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins FIFO_Is_Over_High_Water_Mark = {1};
           type_option.comment = "FIFO Is Over High-water Mark";
           }

  C3 : coverpoint (!($stable(simultaneous_enq_deq, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Simulatneous_Enqueues_and_Dequeues = {1};
           type_option.comment = "Simulatneous Enqueues and Dequeues";
           }


  endgroup : multi_enq_deq_fifo_cornercases

  multi_enq_deq_fifo_statistics MULTI_ENQ_DEQ_FIFO_STATISTICS = new();
  multi_enq_deq_fifo_cornercases MULTI_ENQ_DEQ_FIFO_CORNERCASES = new();

  initial
    begin
      multi_enq_deq_fifo_statistics::type_option.comment = "Statistics for multi enq deq fifo Checker";
      multi_enq_deq_fifo_cornercases::type_option.comment = "Corner Cases for multi enq deq fifo Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Multi Enq Deq Fifo Checker ------------------");
      $display("Assertion instance is             : %m");
      $display("------------------- Statistics for Multi Enq Deq Fifo Checker ----------------");
      $display("Enqueues                           : %0d", enqueues);
      $display("Dequeues                           : %0d", dequeues);
      $display("------------------- Corner Cases for Multi Enq Deq Fifo Checker ---------------");
      $display("FIFO Is Full                       : %0d", full_count);
      $display("FIFO Is empty                      : %0d", empty_count);
      $display("FIFO Is Over High Water Mark       : %0d", high_water_count);
      $display("Simultaneous Enqueues and Dequeues  : %0d", simultaneous_enq_deq);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
