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

  //---------------------------------------------------------------------------
  //SV Covergroups start here
  //---------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge hclk)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats"

  assign collect_stats = 1'b1; // Enable stats collection.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 && hresetn == 1'b1 &&
			      prevent_x_to_valid_transition_count == 1'b1);

  wire [63:0] total_count;
  assign total_count = (read_count + write_count + 
                        idle_transfer_received_count +
                        busy_transfer_received_count);

`ifdef QVL_SV_COVERGROUP

  covergroup amba_ahb_statistics @ (posedge hclk);

    type_option.strobe = 1;
    type_option.comment = "Statistics for AMBA AHB Target Monitor";

    S0 : coverpoint (!($stable(total_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {
        bins Total_Transfers = {1};
	type_option.comment = "Total Transfers"; 
        }
  endgroup : amba_ahb_statistics

  covergroup amba_ahb_cornercases @ (posedge hclk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for AMBA AHB Target Monitor";

    C0 : coverpoint (!($stable(read_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {
        bins Read_Transfers = {1};
	type_option.comment = "Read Transfers";
        }

    C1 : coverpoint (!($stable(write_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {
        bins Write_Transfers = {1};
	type_option.comment = "Write Transfers";
        }

    C2 : coverpoint (!($stable(idle_transfer_received_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {
        bins IDLE_Transfers = {1};
	type_option.comment = "IDLE Transfers";
        }

    C3 : coverpoint (!($stable(busy_transfer_received_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {
        bins BUSY_Transfers = {1};
	type_option.comment = "BUSY Transfers";
        }

    C4 : coverpoint (!($stable(okay_response_issued_count, @ (posedge hclk)))) iff(enable_coverpoint) 
        {
        bins OKAY_Responses = {1}; 
	type_option.comment = "OKAY Responses";
        }

    C5 : coverpoint (!($stable(error_response_issued_count, @ (posedge hclk)))) iff(enable_coverpoint)                    
        { 
        bins ERROR_Responses = {1};  
	type_option.comment = "ERROR Responses";
        }

    C6 : coverpoint (!($stable(retry_response_issued_count, @ (posedge hclk)))) iff(enable_coverpoint)                    
        { 
        bins RETRY_Responses = {1};  
	type_option.comment = "RETRY Responses";
        }

    C7 : coverpoint (!($stable(split_response_issued_count, @ (posedge hclk)))) iff(enable_coverpoint)                    
        { 
        bins SPLIT_Responses = {1};  
	type_option.comment = "SPLIT Responses";
        } 

    C8 : coverpoint (!($stable(single_burst_count, @ (posedge hclk)))) iff(enable_coverpoint)    
        { 
        bins SINGLE_Burst_Type = {1};  
	type_option.comment = "SINGLE Burst Type";
        }

   C9 : coverpoint (!($stable(incr_burst_count, @ (posedge hclk)))) iff(enable_coverpoint) 
        { 
        bins INCR_Burst_Type = {1};  
	type_option.comment = "INCR Burst Type";
        }

   C10 : coverpoint (!($stable(wrap4_burst_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {  
        bins WRAP4_Burst_Type = {1};   
	type_option.comment = "WRAP4 Burst Type";
        }

   C11 : coverpoint (!($stable(incr4_burst_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {  
        bins INCR4_Burst_Type = {1};   
	type_option.comment = "INCR4 Burst Type";
        }

   C12 : coverpoint (!($stable(wrap8_burst_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {   
        bins WRAP8_Burst_Type = {1};    
	type_option.comment = "WRAP8 Burst Type";
        }

   C13 : coverpoint (!($stable(incr8_burst_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {   
        bins INCR8_Burst_Type = {1};    
	type_option.comment = "INCR8 Burst Type";
        }

   C14 : coverpoint (!($stable(wrap16_burst_count, @ (posedge hclk)))) iff(enable_coverpoint) 
        {   
        bins WRAP16_Burst_Type = {1};     
	type_option.comment = "WRAP16 Burst Type";
        }

   C15 : coverpoint (!($stable(incr16_burst_count, @ (posedge hclk)))) iff(enable_coverpoint) 
        {    
        bins INCR16_Burst_Type = {1};     
	type_option.comment = "INCR16 Burst Type";
        }

   C16 : coverpoint (!($stable(hsize_byte_count, @ (posedge hclk)))) iff(enable_coverpoint) 
        {    
        bins Byte_Transfer_Size = {1};     
	type_option.comment = "Byte Transfer Size";
        }

   C17 : coverpoint (!($stable(hsize_halfword_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {     
        bins Half_Word_Transfer_Size = {1};      
	type_option.comment = "Half Word Transfer Size";
        }

   C18 : coverpoint (!($stable(hsize_word_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {      
        bins Word_Transfer_Size = {1};       
	type_option.comment = "Word Transfer Size";
        }

   C19 : coverpoint (!($stable(hsize_doubleword_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {        
        bins Double_Word_Transfer_Size = {1};        
	type_option.comment = "Double Word Transfer Size";
        }

   C20 : coverpoint (!($stable(hsize_4word_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {        
        bins Four_Word_Transfer_Size = {1};        
	type_option.comment = "Four Word Transfer Size";
        }

   C21 : coverpoint (!($stable(hsize_8word_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {        
        bins Eight_Word_Transfer_Size = {1};        
	type_option.comment = "Eight Word Transfer Size";
        }

   C22 : coverpoint (!($stable(hsize_512bits_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {        
        bins Five12_Bits_Transfer_Size = {1};        
	type_option.comment = "512 Bits Transfer Size";
        }

   C23 : coverpoint (!($stable(hsize_1024bits_count, @ (posedge hclk)))) iff(enable_coverpoint)
        {        
        bins Thousand24_Bits_Transfer_Size = {1};        
	type_option.comment = "1024 Bits Transfer Size";
        }
  endgroup : amba_ahb_cornercases

  amba_ahb_statistics  AMBA_AHB_STATISTICS = new();
  amba_ahb_cornercases AMBA_AHB_CORNERCASES = new();

  initial
    begin
      amba_ahb_statistics::type_option.comment = "Statistics for AMBA AHB Target Monitor";
      amba_ahb_cornercases::type_option.comment = "Cornercases for AMBA AHB Target Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final
    begin
      $display("------------------- Coverage for AMBA AHB Target Monitor -------------------------");
      $display("Monitor instance                      : %m");
      $display("------------------- Statistics for AMBA AHB Target Monitor -----------------------");
      $display("Total Transfers                       : %0d", total_count);
      $display("------------------- Cornercases for AMBA AHB Target Monitor -----------------------");
      $display("Read Transfers                        : %0d", read_count);
      $display("Write Transfers                       : %0d", write_count);
      $display("IDLE Transfers                        : %0d", idle_transfer_received_count);
      $display("BUSY Transfers                        : %0d", busy_transfer_received_count);
      $display("OKAY Responses                        : %0d", okay_response_issued_count);
      $display("ERROR Responses                       : %0d", error_response_issued_count);
      $display("RETRY Responses                       : %0d", retry_response_issued_count);
      $display("SPLIT Responses                       : %0d", split_response_issued_count);
      $display("SINGLE Burst Type                     : %0d", single_burst_count);
      $display("INCR Burst Type                       : %0d", incr_burst_count);
      $display("WRAP4 Burst Type                      : %0d", wrap4_burst_count);
      $display("INCR4 Burst Type                      : %0d", incr4_burst_count);
      $display("WRAP8 Burst Type                      : %0d", wrap8_burst_count); 
      $display("INCR8 Burst Type                      : %0d", incr8_burst_count);
      $display("WRAP16 Burst Type                     : %0d", wrap16_burst_count); 
      $display("INCR16 Burst Type                     : %0d", incr16_burst_count);
      $display("Byte (8 bits) Transfer Size           : %0d", hsize_byte_count);
      $display("Half Word (16 bits) Transfer Size     : %0d", hsize_halfword_count);
      $display("Word (32 bits) Transfer Size          : %0d", hsize_word_count);
      $display("Double Word (64 bits) Transfer Size   : %0d", hsize_doubleword_count);
      $display("4 Word (128 bits) Transfer Size       : %0d", hsize_4word_count);
      $display("8 Word (256 bits) Transfer Size       : %0d", hsize_8word_count);
      $display("512 Bits Transfer Size                : %0d", hsize_512bits_count);
      $display("1024 Bits Transfer Size               : %0d", hsize_1024bits_count); 
      $display("----------------------------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

`endif // QVL_COVER_ON
