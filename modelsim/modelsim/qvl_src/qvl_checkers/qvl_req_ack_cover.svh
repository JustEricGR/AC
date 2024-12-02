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

  reg        prevent_x_to_valid_transition_count;
  reg [63:0] number_of_cycles_req_ack_asserted_together;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count = 1'b0;
      number_of_cycles_req_ack_asserted_together = {64{1'b0}};
    end

  always @ (posedge clock)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;

      // Updation of number_of_cycles_req_ack_asserted_together

      if( active === 1'b1 && xz_detected_req_ack !== 1'b1 && areset === 1'b0 && reset === 1'b0 &&
          new_req == 1'b1 && new_ack == 1'b1 &&
          (number_of_cycles_req_ack_asserted_together != {STAT_CNT_WIDTH{1'b1}}) )
         begin
           number_of_cycles_req_ack_asserted_together <=
             `ZiCwDebugDelay1 number_of_cycles_req_ack_asserted_together + 1'b1;
         end
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 enable_coverpoint = (areset != 1'b1 && reset != 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);


  covergroup req_ack_statistics @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Statistics for req_ack Checker";

  S0 : coverpoint (!($stable(number_of_cycles_req_ack_asserted_together, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Number_of_Cycles_Request_and_Acknowledgment_Asserted_Together = {1};
           type_option.comment = "Number of Cycles Request and Acknowledgment Asserted Together";
           }

  S1 : coverpoint (!($stable(number_of_cycles_req_ack_deasserted_together, @ (posedge clock))))
         iff (enable_coverpoint && ack_until_req_deassert)
           {
           bins Number_of_Cycles_Request_and_Acknowledgment_Deasserted_Together = {1};
           type_option.comment = "Number of Cycles Request and Acknowledgment Deasserted Together";
           }

  endgroup : req_ack_statistics


  covergroup req_ack_cornercases @ (posedge clock);

    type_option.strobe = 1;
    type_option.comment = "Corner Cases for req_ack Checker";

  C0 : coverpoint (!($stable(requests, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Requests = {1};
           type_option.comment = "Requests";
           }

  C1 : coverpoint (!($stable(acknowledgments, @ (posedge clock))))
         iff (enable_coverpoint)
           {
           bins Acknowledgments = {1};
           type_option.comment = "Acknowledgments";
           }

  C2 : coverpoint (!($stable(min_cycles_between_request_count, @ (posedge clock))))
         iff (enable_coverpoint && min_check)
           {
           bins Request_Asserted_for_Minimum_Cycles = {1};
           type_option.comment = "Request Asserted for Minimum Cycles";
           }

  C3 : coverpoint (!($stable(request_for_max_cycles_count, @ (posedge clock))))
         iff (enable_coverpoint && max_check)
           {
           bins Request_Asserted_for_Maximum_Cycles = {1};
           type_option.comment = "Request Asserted for Maximum Cycles";
           }

  C4 : coverpoint (!($stable(ack_for_max_cycles_count, @ (posedge clock))))
         iff (enable_coverpoint && max_ack_check)
           {
           bins Acknowledgment_Asserted_for_Maximum_Cycles = {1};
           type_option.comment = "Acknowledgment Asserted for Maximum Cycles";
           }
  endgroup : req_ack_cornercases

  req_ack_cornercases REQ_ACK_CORNERCASES = new();
  req_ack_statistics REQ_ACK_STATISTICS = new();

  initial
    begin
      req_ack_cornercases::type_option.comment = "Corner Cases for req_ack Checker";
      req_ack_statistics::type_option.comment = "Statistics for req_ack Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for req_ack Checker ---------------------");
      $display("Assertion instance is                                            : %m");
      $display("------------------- Statistics for req_ack Checker -------------------");
      $display("Number of Cycles Request and Acknowledgment Asserted Together    : %0d", number_of_cycles_req_ack_asserted_together);
      $display("Number of Cycles Request and Acknowledgment Deasserted Together  : %0d", (number_of_cycles_req_ack_deasserted_together * (ack_until_req_deassert > 0)));
      $display("------------------- Corner cases for req_ack Checker -----------------");
      $display("Requests                                                         : %0d", requests);
      $display("Acknowledgments                                                  : %0d", acknowledgments);
      $display("Request Asserted for Minimum Cycles                              : %0d", (min_cycles_between_request_count * (min_check > 0)));
      $display("Request Asserted for Maximum Cycles                              : %0d", (request_for_max_cycles_count * (max_check > 0)));
      $display("Acknowledgment Asserted for Maximum Cycles                       : %0d", (ack_for_max_cycles_count * (max_ack_check > 0)));
    end
`endif // QVL_CW_FINAL_COVER

`endif // QVL_COVER_ON
