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

  //---------------------------------------------------------------------
  // SV Covergroups start here
  //---------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      #1;
      prevent_x_to_valid_transition_count = 1'b0;
    end

  reg [63:0] fixed_write_accesses_prev;

  always @ (posedge aclk)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Not having any siginficance in SV.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 &&
                                 areset_n == 1'b1 &&
                                 reset_n == 1'b1 &&
                                 prevent_x_to_valid_transition_count == 1'b1);

  wire simultaneous_read_write_accesses;
  assign simultaneous_read_write_accesses = (~low_power_mode & awvalid
  & awready & arvalid & arready);

`ifdef QVL_SV_COVERGROUP

  covergroup amba_axi_statistics @ (posedge aclk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for AMBA AXI Monitor";

  S0 : coverpoint (simultaneous_read_write_accesses)
         iff (enable_coverpoint && (low_power_mode==1'b0 && awvalid===1'b1
                                    && awready===1'b1 && arvalid===1'b1 &&
                                    arready===1'b1))
           {
           bins Simultaneous_Read_Write_Accesses = {1};
           type_option.comment = "Simultaneous read write accesses";
           } 

  S1 : coverpoint (!($stable(back_to_back_read_bursts, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Back_To_Back_Read_Bursts = {1};
           type_option.comment = "Back to back read data bursts";
           }

  S2 : coverpoint (!($stable(back_to_back_write_bursts, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Back_To_Back_Write_Bursts = {1};
           type_option.comment = "Back to back write data bursts";
           }

  S3 : coverpoint (!($stable(cacheable_wr_through_write_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Write_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-through write allocate reads";
           }

  S4 : coverpoint (!($stable(cacheable_wr_back_write_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Write_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-back write allocate reads";
           }

  S5 : coverpoint (!($stable(cacheable_wr_through_read_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Read_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-through read allocate writes";
           }

  S6 : coverpoint (!($stable(cacheable_wr_back_read_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Read_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-back read allocate writes";
           }

  S7 : coverpoint (!($stable(incomplete_exclusive_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Incomplete_Exclusive_Accesses = {1};
           type_option.comment = "Incomplete exclusive accesses";
           }

  S8 : coverpoint (!($stable(exclusive_access_successes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Access_Successes = {1};
           type_option.comment = "Exclusive access successes";
           }

  S9 : coverpoint (!($stable(exclusive_access_failures, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Access_Failures = {1};
           type_option.comment = "Exclusive access failures";
           }

  S10 : coverpoint (!($stable(exclusive_read_access_to_unsupported_slave, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Read_Access_to_Unsupported_Slave = {1};
           type_option.comment = "Exclusive read accesses to unsupported slave";
           }

  S11 : coverpoint (!($stable(exclusive_write_access_to_unsupported_slave, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Write_Access_to_Unsupported_Slave = {1};
           type_option.comment = "Exclusive write accesses to unsupported slave";
           }

  S12 : coverpoint (!($stable(locked_read_sequences_across_4k_boundary, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Read_Sequences_Across_4k_Boundary = {1};
           type_option.comment = "Locked read sequences across 4K boundary";
           }

  S13 : coverpoint (!($stable(locked_read_sequences_exceeding_2_transactions, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Read_Sequences_Exceeding_2_Transactions = {1};
           type_option.comment = "Locked read sequences exceeding 2 accesses";
           }

  S14 : coverpoint (!($stable(locked_write_sequences_across_4k_boundary, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Write_Sequences_Across_4k_Boundary = {1};
           type_option.comment = "Locked write sequences across 4K boundary";
           }

  S15 : coverpoint (!($stable(locked_write_sequences_exceeding_2_transactions, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Write_Sequences_Exceeding_2_Transactions = {1};
           type_option.comment = "Locked write sequences exceeding 2 accesses";
           }

  endgroup : amba_axi_statistics

  covergroup amba_axi_cornercases @ (posedge aclk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for AMBA AXI Master Monitor";

  C0 : coverpoint (!($stable(read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Read_Accesses = {1};
           type_option.comment = "Read addresses";
           }

  C1 : coverpoint (!($stable(write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Write_Accesses = {1};
           type_option.comment = "Write addresses";
           }

  C2 : coverpoint (!($stable(fixed_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Fixed_Read_Accesses = {1};
           type_option.comment = "Fixed read addresses";
           }

  C3 : coverpoint (!($stable(fixed_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Fixed_Write_Accesses = {1};
           type_option.comment = "Fixed write addresses";
           }

  C4 : coverpoint (!($stable(incr_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Incrmenting_Read_Accesses = {1};
           type_option.comment = "Incrementing read addresses";
           }

  C5 : coverpoint (!($stable(incr_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Incrementing_Write_Accesses = {1};
           type_option.comment = "Incrementing write addresses";
           }

  C6 : coverpoint (!($stable(wrap_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Wrap_Read_Accesses = {1};
           type_option.comment = "Wrapping read addresses";
           }

  C7 : coverpoint (!($stable(wrap_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Wrap_Write_Accesses = {1};
           type_option.comment = "Wrapping write addresses";
           }

  C8 : coverpoint (!($stable(non_cacheable_non_bufferable_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Non_Cacheable_Non_Bufferable_Reads = {1};
           type_option.comment = "Non-cacheable non-bufferable reads";
           }

  C9 : coverpoint (!($stable(bufferable_only_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Bufferable_Only_Reads = {1};
           type_option.comment = "Bufferable only reads";
           }

  C10 : coverpoint (!($stable(cacheable_only_non_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Without_Allocate_Reads = {1};
           type_option.comment = "Cacheable but non allocatable reads";
           }

  C11 : coverpoint (!($stable(cacheable_bufferable_non_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Bufferable_Non_Allocate_Reads = {1};
           type_option.comment = "Cacheable and bufferable but non allocatable reads";
           }

  C12 : coverpoint (!($stable(cacheable_wr_through_read_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Read_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-through read allocate reads";
           }

  C13 : coverpoint (!($stable(cacheable_wr_back_read_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Read_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-back read allocate reads";
           }

  C14 : coverpoint (!($stable(cacheable_wr_through_read_write_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Read_Write_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-through read and write allocatable reads";
           }

  C15 : coverpoint (!($stable(cacheable_wr_back_read_write_allocate_reads, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Read_Write_Allocate_Reads = {1};
           type_option.comment = "Cacheable write-back read and write allocatable reads";
           }

  C16 : coverpoint (!($stable(non_cacheable_non_bufferable_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Non_Cacheable_Non_Bufferable_Writes = {1};
           type_option.comment = "Non-cacheable non-bufferable writes";
           }

  C17 : coverpoint (!($stable(bufferable_only_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Bufferable_Only_Writes = {1};
           type_option.comment = "Bufferable only writes";
           }

  C18 : coverpoint (!($stable(cacheable_only_non_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Without_Allocate_Writes = {1};
           type_option.comment = "Cacheable but non allocatable writes";
           }

  C19 : coverpoint (!($stable(cacheable_bufferable_non_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Bufferable_Non_Allocate_Writes = {1};
           type_option.comment = "Cacheable and bufferable but non allocatable writes";
           }

  C20 : coverpoint (!($stable(cacheable_wr_through_write_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Write_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-through write allocate writes";
           }

  C21 : coverpoint (!($stable(cacheable_wr_back_write_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Write_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-back write allocate writes";
           }

  C22 : coverpoint (!($stable(cacheable_wr_through_read_write_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Through_Read_Write_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-through read and write allocatable writes";
           }

  C23 : coverpoint (!($stable(cacheable_wr_back_read_write_allocate_writes, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Cacheable_Write_Back_Read_Write_Allocate_Writes = {1};
           type_option.comment = "Cacheable write-back read and write allocatable writes";
           }

  C24 : coverpoint (!($stable(normal_secure_data_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Secure_Data_Read_Accesses = {1};
           type_option.comment = "Normal secure data read accesses";
           }

  C25 : coverpoint (!($stable(privileged_secure_data_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Priviliged_Secure_Data_Read_Accesses = {1};
           type_option.comment = "Priviliged secure data read accesses";
           }

  C26 : coverpoint (!($stable(normal_nonsecure_data_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Nonsecure_Data_Read_Accesses = {1};
           type_option.comment = "Normal nonsecure data read accesses";
           }

  C27 : coverpoint (!($stable(privileged_nonsecure_data_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Priviliged_Nonsecure_Data_Read_Accesses = {1};
           type_option.comment = "Priviliged nonsecure data read accesses";
           }

  C28 : coverpoint (!($stable(normal_secure_instruction_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Secure_Instruction_Read_Accesses = {1};
           type_option.comment = "Normal secure instruction read accesses";
           }

  C29 : coverpoint (!($stable(privileged_secure_instruction_read_access, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Privileged_Secure_Instruction_Read_Access = {1};
           type_option.comment = "Privileged secure instruction read accesses";
           }

  C30 : coverpoint (!($stable(normal_nonsecure_instruction_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Nonsecure_Instruction_Read_Accesses = {1};
           type_option.comment = "Normal nonsecure instruction read accesses";
           }

  C31 : coverpoint (!($stable(privileged_nonsecure_instruction_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Privileged_Nonsecure_Instruction_Read_Accesses = {1};
           type_option.comment = "Privileged nonsecure instruction read accesses";
           }

  C32 : coverpoint (!($stable(normal_secure_data_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Secure_Data_Write_Accesses = {1};
           type_option.comment = "Normal secure data write accesses";
           }

  C33 : coverpoint (!($stable(privileged_secure_data_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Priviliged_Secure_Data_Write_Accesses = {1};
           type_option.comment = "Privileged secure data write accesses";
           }

  C34 : coverpoint (!($stable(normal_nonsecure_data_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Nonsecure_Data_Write_Accesses = {1};
           type_option.comment = "Normal nonsecure data write accesses";
           }

  C35 : coverpoint (!($stable(privileged_nonsecure_data_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Priviliged_Nonsecure_Data_Write_Accesses = {1};
           type_option.comment = "Privileged nonsecure data write accesses";
           }

  C36 : coverpoint (!($stable(normal_secure_instruction_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Secure_Instruction_Write_Accesses = {1};
           type_option.comment = "Normal secure instruction write accesses";
           }

  C37 : coverpoint (!($stable(privileged_secure_instruction_write_access, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Privileged_Secure_Instruction_Write_Access = {1};
           type_option.comment = "Privileged secure instruction write accesses";
           }

  C38 : coverpoint (!($stable(normal_nonsecure_instruction_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Nonsecure_Instruction_Write_Accesses = {1};
           type_option.comment = "Normal nonsecure instruction write accesses";
           }

  C39 : coverpoint (!($stable(privileged_nonsecure_instruction_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Privileged_Nonsecure_Instruction_Write_Accesses = {1};
           type_option.comment = "Privileged nonsecure instruction write accesses";
           }

  C40 : coverpoint (!($stable(normal_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Read_Accesses = {1};
           type_option.comment = "Normal read accesses";
           }

  C41 : coverpoint (!($stable(exclusive_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Read_Accesses = {1};
           type_option.comment = "Exclusive read accesses";
           }

  C42 : coverpoint (!($stable(locked_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Read_Accesses = {1};
           type_option.comment = "Locked read accesses";
           }

  C43 : coverpoint (!($stable(normal_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Normal_Write_Accesses = {1};
           type_option.comment = "Normal write accesses";
           }

  C44 : coverpoint (!($stable(exclusive_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Exclusive_Write_Accesses = {1};
           type_option.comment = "Exclusive write accesses";
           }

  C45 : coverpoint (!($stable(locked_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Locked_Write_Accesses = {1};
           type_option.comment = "Locked write accesses";
           }

  C46 : coverpoint (!($stable(decode_error_read_responses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Decode_Error_Read_Responses = {1};
           type_option.comment = "Read responses with decode error";
           }

  C47 : coverpoint (!($stable(decode_error_write_responses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Decode_Error_Write_Responses = {1};
           type_option.comment = "Write responses with decode error";
           }

  C48 : coverpoint (!($stable(slave_error_read_responses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Slave_Error_Read_Responses = {1};
           type_option.comment = "Read responses with slave error";
           }

  C49 : coverpoint (!($stable(slave_error_write_responses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Slave_Error_Write_Responses = {1};
           type_option.comment = "Write responses with slave error";
           }

  C50 : coverpoint (!($stable(unaligned_read_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Unaligned_Read_Accesses = {1};
           type_option.comment = "Unaligned read accesses";
           }

  C51 : coverpoint (!($stable(narrow_read_transfers, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Narrow_Read_Transfers = {1};
           type_option.comment = "Narrow read transfers";
           }

  C52 : coverpoint (!($stable(unaligned_write_accesses, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Unaligned_Write_Accesses = {1};
           type_option.comment = "Unaligned write accesses";
           }

  C53 : coverpoint (!($stable(narrow_write_transfers, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Narrow_Write_Transfers = {1};
           type_option.comment = "Narrow write transfers";
           }

  C54 : coverpoint (!($stable(read_bursts, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Read_Bursts = {1};
           type_option.comment = "Read data bursts";
           }

  C55 : coverpoint (!($stable(write_bursts, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Write_Bursts = {1};
           type_option.comment = "Write data bursts";
           }

  C56 : coverpoint (!($stable(write_bursts_with_all_data_masked, @ (posedge aclk))))
         iff (enable_coverpoint)
           {
           bins Write_Bursts_with_all_Data_Masked = {1};
           type_option.comment = "Write bursts with all data masked";
           }

  endgroup : amba_axi_cornercases

  amba_axi_cornercases AMBA_AXI_CORNERCASES = new();
  amba_axi_statistics AMBA_AXI_STATISTICS = new();

  initial
    begin
      amba_axi_cornercases::type_option.comment = "Cornercases for AMBA AXI Monitor";
      amba_axi_statistics::type_option.comment = "Statistics for AMBA_AXI Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for AMBA AXI Monitor ------------------");
      $display("Monitor instance          : %m");
      $display("------------------- Statistics for AMBA AXI Monitor ---------------");
      $display("Back to back read bursts                       : %0d", back_to_back_read_bursts);
      $display("Back to back write bursts                      : %0d", back_to_back_write_bursts);
      $display("Cacheable write-through write allocate reads   : %0d", cacheable_wr_through_write_allocate_reads);
      $display("Cacheable write-back write allocate reads      : %0d", cacheable_wr_back_write_allocate_reads);
      $display("Cacheable write-through read allocate writes   : %0d", cacheable_wr_through_read_allocate_writes);
      $display("Cacheable write-back read allocate writes      : %0d", cacheable_wr_back_read_allocate_writes);
      $display("Incomplete exclusive accesses                  : %0d", incomplete_exclusive_accesses);
      $display("Exclusive access successes                     : %0d", exclusive_access_successes);
      $display("Exclusive access failures                      : %0d", exclusive_access_failures);
      $display("Exclusive read accesses to unsupported slave   : %0d", exclusive_read_access_to_unsupported_slave);
      $display("Exclusive write accesses to unsupported slave  : %0d", exclusive_write_access_to_unsupported_slave);
      $display("Locked read sequences across 4K boundary       : %0d", locked_read_sequences_across_4k_boundary);
      $display("Locked read sequences exceeding 2 accesses     : %0d", locked_read_sequences_exceeding_2_transactions);
      $display("Locked write sequences across 4K boundary      : %0d", locked_write_sequences_across_4k_boundary);
      $display("Locked write sequences exceeding 2 accesses    : %0d", locked_write_sequences_exceeding_2_transactions);


      $display("------------------- Cornercases for AMBA AXI Monitor ---------------");
      $display("Read addresses                                             : %0d", read_accesses);
      $display("Write addresses                                            : %0d", write_accesses);
      $display("Fixed read addresses                                       : %0d", fixed_read_accesses);
      $display("Fixed write addresses                                      : %0d", fixed_write_accesses);
      $display("Incrementing read addresses                                : %0d", incr_read_accesses);
      $display("Incrementing write addresses                               : %0d", incr_write_accesses);
      $display("Wrapping read addresses                                    : %0d", wrap_read_accesses);
      $display("Wrapping write addresses                                   : %0d", wrap_write_accesses);
      $display("Non-cacheable non-bufferable read accesses                 : %0d", non_cacheable_non_bufferable_reads);
      $display("Bufferable only reads                                      : %0d", bufferable_only_reads);
      $display("Cacheable but not allocatable reads                        : %0d", cacheable_only_non_allocate_reads);
      $display("Cacheable and bufferable but non allocatable reads         : %0d", cacheable_bufferable_non_allocate_reads);
      $display("Cacheable write-through read allocate reads                : %0d", cacheable_wr_through_read_allocate_reads);
      $display("Cacheable write-back read allocate reads                   : %0d", cacheable_wr_back_read_allocate_reads);
      $display("Cacheable write-through read and write allocate reads      : %0d", cacheable_wr_through_read_write_allocate_reads);
      $display("Cacheable write-back read and write allocate reads         : %0d", cacheable_wr_back_read_write_allocate_reads);
      $display("Non-cacheable non-bufferable write accesses                : %0d", non_cacheable_non_bufferable_writes);
      $display("Bufferable only writes                                     : %0d", bufferable_only_writes);
      $display("Cacheable but not allocatable writes                       : %0d", cacheable_only_non_allocate_writes);
      $display("Cacheable and bufferable but non allocatable writes        : %0d", cacheable_bufferable_non_allocate_writes);
      $display("Cacheable write-through write allocate writes              : %0d", cacheable_wr_through_write_allocate_writes);
      $display("Cacheable write-back write allocate writes                 : %0d", cacheable_wr_back_write_allocate_writes);
      $display("Cacheable write-through read and write allocatable writes  : %0d", cacheable_wr_through_read_write_allocate_writes);
      $display("Cacheable write-back read and write allocate writes        : %0d", cacheable_wr_back_read_write_allocate_writes);
      $display("Normal secure data read accesses                           : %0d", normal_secure_data_read_accesses);
      $display("Privileged secure data read accesses                       : %0d", privileged_secure_data_read_accesses);
      $display("Normal nonsecure data read accesses                        : %0d", normal_nonsecure_data_read_accesses);
      $display("Privileged nonsecure data read accesses                    : %0d", privileged_nonsecure_data_read_accesses);
      $display("Normal secure instruction read accesses                    : %0d", normal_secure_instruction_read_accesses);
      $display("Privileged secure instruction read accesses                : %0d", privileged_secure_instruction_read_access);
      $display("Normal nonsecure instruction read access                   : %0d", normal_nonsecure_instruction_read_accesses);
      $display("Privileged nonsecure instruction read access               : %0d", privileged_nonsecure_instruction_read_accesses);
      $display("Normal secure data write accesses                          : %0d", normal_secure_data_write_accesses);
      $display("Privileged secure data write accesses                      : %0d", privileged_secure_data_write_accesses);
      $display("Normal nonsecure data write accesses                       : %0d", normal_nonsecure_data_write_accesses);
      $display("Privileged nonsecure data write accesses                   : %0d", privileged_nonsecure_data_write_accesses);
      $display("Normal secure instruction write accesses                   : %0d", normal_secure_instruction_write_accesses);
      $display("Privileged secure instruction write accesses               : %0d", privileged_secure_instruction_read_access);
      $display("Normal nonsecure instruction write access                  : %0d", normal_nonsecure_instruction_write_accesses);
      $display("Privileged nonsecure instruction write access              : %0d", privileged_nonsecure_instruction_write_accesses);
      $display("Normal read accesses                                       : %0d", normal_read_accesses);
      $display("Exclusive read accesses                                    : %0d", exclusive_read_accesses);
      $display("Locked read accesses                                       : %0d", locked_read_accesses);
      $display("Normal write accesses                                      : %0d", normal_write_accesses);
      $display("Exclusive write accesses                                   : %0d", exclusive_write_accesses);
      $display("Locked write accesses                                      : %0d", locked_write_accesses);
      $display("Read responses with decode error                           : %0d", decode_error_read_responses);
      $display("Write responses with decode error                          : %0d", decode_error_write_responses);
      $display("Read responses with slave error                            : %0d", slave_error_read_responses);
      $display("Write responses with slave error                           : %0d", slave_error_write_responses);
      $display("Unaligned read accesses                                    : %0d", unaligned_read_accesses);
      $display("Narrow read transfers                                      : %0d", narrow_read_transfers);
      $display("Unaligned write accesses                                   : %0d", unaligned_write_accesses);
      $display("Narrow write transfers                                     : %0d", narrow_write_transfers);
      $display("Read data bursts                                           : %0d", read_bursts);
      $display("Write data bursts                                          : %0d", write_bursts);
      $display("Write data bursts with all data masked                     : %0d", write_bursts_with_all_data_masked);
      $display("--------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
