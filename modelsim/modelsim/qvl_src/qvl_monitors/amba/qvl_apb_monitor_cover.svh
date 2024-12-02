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

  //------------------------------------------------------------------------
  // SV Covergroups start here
  //------------------------------------------------------------------------

  reg prevent_x_to_valid_transition_count;

  initial
    begin
      // This is required to prevent the coverpoints to increment
      // when 'x' to '0' transition that happens during start of
      // simulation
      prevent_x_to_valid_transition_count = 1'b0;
    end

  always @ (posedge pclk)
    begin
      prevent_x_to_valid_transition_count <= 1'b1;
    end

  wire enable_coverpoint; // Wire to hold "when to increment the stats" 

  assign collect_stats = 1'b1; // Enable stats collection.

  assign #1 enable_coverpoint = (collect_stats == 1'b1 && presetn == 1'b1 &&
                              prevent_x_to_valid_transition_count == 1'b1);

  wire [63:0] total_count;
  assign total_count = read_count + write_count;

`ifdef QVL_SV_COVERGROUP

  covergroup apb_statistics @ (posedge pclk);

   type_option.strobe = 1;
   type_option.comment = "Statistics for AMBA APB Monitor";

   S0 : coverpoint (!($stable(total_count, @ (posedge pclk)))) iff(enable_coverpoint) 
	{
	bins Total_Transfers = {1};
        type_option.comment = "Total Transfers";
	}

   S1 : coverpoint (!($stable(idle_count, @ (posedge pclk)))) iff(enable_coverpoint)         
        {       
        bins Idle_State_Count = {1}; 
        type_option.comment = "Idle State Count"; 
        }

   S2 : coverpoint (!($stable(enable_count, @ (posedge pclk)))) iff(enable_coverpoint)
        {
        bins Enable_State_Count = {1}; 
        type_option.comment = "Enable State Count";
        }

   S3 : coverpoint (!($stable(setup_count, @ (posedge pclk)))) iff(enable_coverpoint)
	{
	bins Setup_State_Count = {1};
        type_option.comment = "Setup State Count";
	}

  endgroup : apb_statistics

  covergroup apb_cornercases @ (posedge pclk);

    type_option.strobe = 1;
    type_option.comment = "Cornercases for AMBA APB Monitor"; 

    C0 : coverpoint (!($stable(back2back_count, @ (posedge pclk)))) iff(enable_coverpoint)
        { 
        bins Back_to_Back_Transfers = {1};
        type_option.comment = "Back to Back Transfers";
        }

    C1 : coverpoint (!($stable(read_count, @ (posedge pclk)))) iff(enable_coverpoint)
        {
        bins Read_Transfers = {1};
        type_option.comment = "Read Transfers";
        }

    C2 : coverpoint (!($stable(write_count, @ (posedge pclk)))) iff(enable_coverpoint)
        { 
        bins Write_Transfers = {1};
        type_option.comment = "Write Transfers";
        }

  endgroup : apb_cornercases

  apb_statistics  APB_STATISTICS = new();
  apb_cornercases APB_CORNERCASES = new();

  initial
    begin
      apb_statistics::type_option.comment = "Statistics for AMBA APB Monitor";
      apb_cornercases::type_option.comment = "Cornercases for AMBA APB Monitor";
    end

`endif // QVL_SV_COVERGROUP

`ifdef QVL_MW_FINAL_COVER

  final 
    begin
      $display("------------ Coverage for AMBA APB Monitor --------------------");
      $display("Monitor instance           : %m");
      $display("------------ Statistics for AMBA APB Monitor ------------------");  
      $display("Total Transfers            : %0d", total_count);
      $display("Idle State Count           : %0d", idle_count);
      $display("Enable State Count         : %0d", enable_count);
      $display("Setup State Count          : %0d", setup_count);
      $display("------------ Cornercases for AMBA APB Monitor -----------------");
      $display("Back to Back Transfers     : %0d", back2back_count);
      $display("Read Transfers             : %0d", read_count);
      $display("Write Transfers            : %0d", write_count);
      $display("---------------------------------------------------------------");
    end

`endif // QVL_MW_FINAL_COVER

  //---------------------------------------------------------------------------

`endif // QVL_COVER_ON
