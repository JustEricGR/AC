module rgst #(
    parameter w=8
)(
    input clk, rst_b, ld, input [w-1:0] d, output reg [w-1:0] q
);
    always @ (posedge clk, negedge rst_b)
      if (!rst_b)q <= 0;
      else if (ld)q <= d;
    
endmodule

module regfl_4x8(
  input clk,
  input rst_b,
  input [7:0] wr_data,
  input [1:0] wr_addr,
  input wr_e,
  output reg [7:0] rd_data,
  input [1:0] rd_addr
  );
  
  reg [3:0] o;
  wire [7:0] d0,d1,d2,d3;
  
  always @(*) begin
    if(wr_e) begin
      case(wr_addr)
        0 : o = 4'b0001;
        1 : o = 4'b0010;
        2 : o = 4'b0100;
        3 : o = 4'b1000;
        default : o = 0;
      endcase
    end
    else o=0;
  end
  
  rgst #(
    .w(8)
    ) reg0 (
    .clk(clk),
    .rst_b(rst_b),
    .ld(o[0]),
    .d(wr_data),
    .q(d0)
    );
    
    rgst #(
    .w(8)
    ) reg1 (
    .clk(clk),
    .rst_b(rst_b),
    .ld(o[1]),
    .d(wr_data),
    .q(d1)
    );
    
    rgst #(
    .w(8)
    ) reg2 (
    .clk(clk),
    .rst_b(rst_b),
    .ld(o[2]),
    .d(wr_data),
    .q(d2)
    );
  
    rgst #(
    .w(8)
    ) reg3 (
    .clk(clk),
    .rst_b(rst_b),
    .ld(o[3]),
    .d(wr_data),
    .q(d3)
    );
    
    always @(*) begin
      case(rd_addr)
        0 : rd_data = d0;
        1 : rd_data = d1;
        2 : rd_data = d2;
        3 : rd_data = d3;
      endcase
    end
  endmodule
  
  module regfl_4x8_tb;
    
    reg clk, rst_b, wr_e;
    reg [7:0] wr_data;
    reg [1:0] wr_addr, rd_addr;
    wire [7:0] rd_data;
  
    regfl_4x8 dut(
      .clk(clk),
      .rst_b(rst_b),
      .wr_e(wr_e),
      .wr_data(wr_data),
      .wr_addr(wr_addr),
      .rd_addr(rd_addr),
      .rd_data(rd_data)
    );
    
    initial begin
    clk = 0;
    rst_b = 0;
    wr_addr = 2'h0;
    wr_data = 2'ha2;
    wr_e = 1;
    rd_addr = 2'h3;
  end
  
  integer i;
  initial begin
    for(i = 1; i <= 18; i = i + 1) begin
      #50; clk = ~clk;
    end
  end
  
  initial begin
    #5; rst_b = 1;
  end
  
  initial begin
    #100; wr_addr = 2'h2; wr_data = 8'h2e; rd_addr = 2'h0;
    #100; wr_addr = 2'h1; wr_data = 8'h98; rd_addr = 2'h1;
    #100; wr_addr = 2'h3; wr_data = 8'h55; rd_addr = 2'h2;
    #100; wr_addr = 2'h0; wr_data = 8'h20; rd_addr = 2'h0;
    #100; wr_addr = 2'h1; wr_data = 8'hff; rd_addr = 2'h3;
    #100; wr_addr = 2'h3; wr_data = 8'hc7; rd_addr = 2'h1;
    #100; wr_addr = 2'h2; wr_data = 8'hb5; rd_addr = 2'h2;
    #100; wr_addr = 2'h3; wr_data = 8'h91; rd_addr = 2'h3;
  end
  
  initial begin
    #200; wr_e = 0;
    #100; wr_e = 1;
    #400; wr_e = 0;
    #100; wr_e = 1;
  end
  
endmodule
  
    
  
  
  