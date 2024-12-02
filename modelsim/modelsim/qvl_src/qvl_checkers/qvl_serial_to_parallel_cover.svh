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

  reg par_prevent_x_to_valid_transition_count;
  reg ser_prevent_x_to_valid_transition_count;

  initial
    begin
      #1;
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      par_prevent_x_to_valid_transition_count = 1'b0;
      ser_prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge parallel_clock)
    begin
      par_prevent_x_to_valid_transition_count <= 1'b1;
    end

  always @ (posedge serial_clock)
    begin
      ser_prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire par_enable_coverpoint; // Wire to hold "when to increment the stats"
  wire ser_enable_coverpoint; // Wire to hold "when to increment the stats"

  assign #1 par_enable_coverpoint = 
                            (par_prevent_x_to_valid_transition_count == 1'b1);
  assign #1 ser_enable_coverpoint = 
                            (ser_prevent_x_to_valid_transition_count == 1'b1);

  covergroup serial_to_parallel_pclk_statistics @ (posedge parallel_clock);

    type_option.strobe = 1;
    type_option.comment = "Parallel Clock Statistics for Serial To Parallel Checker";

  S0 : coverpoint (!($stable(parallel_data_reads, @ (posedge parallel_clock))))
         iff (par_enable_coverpoint)
           {
           bins Parallel_Data_Reads = {1};
           type_option.comment = "Read Cycles";
           }
  endgroup : serial_to_parallel_pclk_statistics

  covergroup serial_to_parallel_sclk_statistics @ (posedge serial_clock);

    type_option.strobe = 1;
    type_option.comment = "Serial Clock Statistics for Serial To Parallel Checker";

  S1 : coverpoint (!($stable(total_shifts, @ (posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Total_Shifts = {1};
           type_option.comment = "Total Conversions";
           }
  S2 : coverpoint (!($stable(right_shifts, @ (posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Right_Shifts = {1};
           type_option.comment = "Right Shifts";
           }
  S3 : coverpoint (!($stable(left_shifts, @ (posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Left_Shifts = {1};
           type_option.comment = "Left Shifts";
           }
  S4 : coverpoint (!($stable(hold_cycles, @(posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Hold_Cycles = {1};
           type_option.comment = "Hold Cycles";
           }
  endgroup : serial_to_parallel_sclk_statistics

  covergroup serial_to_parallel_sclk_cornercases @ (posedge serial_clock);

    type_option.strobe = 1;
    type_option.comment = "Serial Clock Corner Cases for Serial To Parallel Checker";

  C0 : coverpoint (!($stable(complete_right_shifts, @ (posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Complete_Right_Shifts = {1};
           type_option.comment = "MSB Conversions";
           }
  C1 : coverpoint (!($stable(complete_left_shifts, @ (posedge serial_clock))))
         iff (ser_enable_coverpoint)
           {
           bins Complete_Left_Shifts  = {1};
           type_option.comment = "LSB Conversions";
           }
  endgroup : serial_to_parallel_sclk_cornercases

  serial_to_parallel_pclk_statistics SERIAL_TO_PARALLEL_PCLK_STATISTICS = new();
  serial_to_parallel_sclk_statistics SERIAL_TO_PARALLEL_SCLK_STATISTICS = new();
  serial_to_parallel_sclk_cornercases SERIAL_TO_PARALLEL_SCLK_CORNERCASES = new();

  initial
    begin
      serial_to_parallel_pclk_statistics::type_option.comment = "Parallel Clock Statistics for Serial To Parallel Checker";
      serial_to_parallel_sclk_statistics::type_option.comment = "Serial Clock Statistics for Serial To Parallel Checker";
      serial_to_parallel_sclk_cornercases::type_option.comment = "Serial Clock Corner Cases for Serial To Parallel Checker";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_CW_FINAL_COVER
  final
    begin
      $display("------------------- Coverage for Serial To Parallel Checker ------------------");
      $display("Assertion instance is : %m");
      $display("------------------- Parallel Clock Statistics for Serial To Parallel Checker ----------------");
      $display("Read Cycles           : %0d", parallel_data_reads);
      $display("------------------- Serial Clock Statistics for Serial To Parallel Checker ----------------");
      $display("Total Conversions     : %0d", total_shifts);
      $display("Right Shifts          : %0d", right_shifts);
      $display("Left Shifts           : %0d", left_shifts);
      $display("Hold Cycles           : %0d", hold_cycles);
      $display("------------------- Serial Clock Corner Cases for Serial To Parallel Checker ---------------");
      $display("MSB Conversions       : %0d", complete_right_shifts);
      $display("LSB Conversions       : %0d", complete_left_shifts);
    end
`endif // QVL_CW_FINAL_COVER
`endif // QVL_COVER_ON
