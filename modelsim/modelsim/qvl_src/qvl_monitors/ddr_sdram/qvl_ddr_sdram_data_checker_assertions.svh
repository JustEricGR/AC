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
//*****************************************************************************

`include "std_qvl_task.h"
`include "std_qvl_property.svh"

`ifdef QVL_ASSERT_ON

  parameter QVL_ERROR = 1; //`OVL_ERROR;
  parameter QVL_INFO = 3; // `OVL_INFO;
  parameter QVL_PROPERTY_TYPE = ZI_CONSTRAINTS_MODE_MEMORY_SIDE; 
                                      // 0 = `OVL_ASSERT
                                      // 1 = `OVL_ASSUME
  parameter QVL_COVERAGE_LEVEL = 0; //`OVL_COVER_NONE;
  parameter QVL_MSG = "DDR SDRAM Bank Violation: ";


wire [BYTE_ENABLES_WIDTH-1:0] temp_data_fire2;

// This function is written for OVL_ASSERTIONS.

function [BYTE_ENABLES_WIDTH-1:0] temp_data_fire1;

input [BUS_DATA_WIDTH-1:0]     cached_read_data;
input [BYTE_ENABLES_WIDTH-1:0] cached_data_valid_flag;
input [BUS_DATA_WIDTH-1:0]     read_data;

integer idx;
reg [BUS_DATA_WIDTH-1:0]                     temp_read_data;
reg [BUS_DATA_WIDTH-1:0]                     temp_cached_read_data;
reg [BYTE_ENABLES_WIDTH-1:0]                 temp_data_valid;
reg [BYTE_ENABLES_WIDTH-1:0]                 temp_data_fire;

begin
  temp_cached_read_data = cached_read_data;
  temp_read_data = read_data;
  temp_data_valid = cached_data_valid_flag;
  temp_data_fire = {BYTE_ENABLES_WIDTH{1'b0}};

  for (idx=0; idx<BYTE_ENABLES_WIDTH; idx=idx+1)
    begin
      temp_data_fire = temp_data_fire >> 1;
      if (temp_data_valid[0] === 1'b1)
        begin
          if (temp_cached_read_data[7:0] !== temp_read_data[7:0])
            begin
              temp_data_fire[BYTE_ENABLES_WIDTH-1] = 1'b1;
            end
        end
      temp_data_valid = temp_data_valid >> 1;
      temp_cached_read_data = temp_cached_read_data >> 8;
      temp_read_data = temp_read_data >> 8;
    end
  temp_data_fire1 = temp_data_fire;
end
endfunction

assign temp_data_fire2 = temp_data_fire1(cached_read_data,
                                         cached_data_valid_flag,
                                         read_data);

  //---------------------------------------------------------------------
  // Protocol checks
  //---------------------------------------------------------------------
//----------------------------------------
//********** fire ***********
//----------------------------------------

//Assert Only Check

        A_DDR_SDRAM_bad_data:
          assert property ( ASSERT_NEVER_P (
                          .clock     (clk ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (cke && muxed_read_cmd) &&
                           (read_cache_hit && bad_data_chk === 1'b1) &&
                           (|temp_data_fire2))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_bad_data"}),
                          .msg            ("One or more bytes of data read from the addressed DDR SDRAM location did not match the data byte(s) written to the corresponding address"),
                          .severity_level (QVL_ERROR),
                          .property_type  (0));


generate
  case (QVL_PROPERTY_TYPE)
    `QVL_ASSERT : 
      begin : qvl_assert_ASSERT_NEVER 
        A_DDR_SDRAM_read_before_write: 
          assert property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (cke && muxed_read_cmd) &&
                           (read_before_write_chk === 1'b1 &&
                           !muxed_reusing_cache_entrys_flag &&
                           !location_written_hit))))
          else qvl_error_t(
                          .err_msg        ({QVL_MSG,"A_DDR_SDRAM_read_before_write"}),
                          .msg            ("A read operation was performed on the DDR SDRAM address that was not previously written into"),
                          .severity_level (QVL_ERROR),
                          .property_type  (QVL_PROPERTY_TYPE));
      end

    `QVL_ASSUME : 
      begin : qvl_assume_ASSERT_NEVER 
        M_DDR_SDRAM_read_before_write: 
          assume property ( ASSERT_NEVER_P ( 
                          .clock     (clk ),
                          .reset_n   ((areset === 1'b0 && reset === 1'b0) ),
                          .enable    (1'b1),
                          .test_expr ((areset === 1'b0 && reset === 1'b0) &&
                           (cke && muxed_read_cmd) &&
                           (read_before_write_chk === 1'b1 &&
                           !muxed_reusing_cache_entrys_flag &&
                           !location_written_hit))));
      end

    `QVL_IGNORE : 
      begin : qvl_ignore_ASSERT_NEVER 
      end
    default: initial qvl_error_t (
                          .err_msg        (""),
                          .msg            (""),
                          .severity_level (QVL_ERROR),
                          .property_type  (`QVL_IGNORE));
  endcase

endgenerate


`endif // QVL_ASSERT_ON
