`include "ex1.v"
`include "ex2.v"

module ORA(input clk, input rst_b, input [3:0] in, output [3:0] out);
  generate
    genvar i;
    for(i=0;i<4;i=i+1) begin : loop
      if(i==0)my_dff ffs(.clk(clk), .set(rst_b), .d(out[3]^in[0]^in[1]^in[2]^in[3]), .q(out[i]));
      else if(i==1)my_dff ffs(.clk(clk), .set(rst_b), .d(out[3]^out[0]), .q(out[i]));
      else my_dff ffs(.clk(clk), .set(rst_b), .d(out[i-1]), .q(out[i]));
    end
  endgenerate
endmodule

module ex3(input clk, input rst_b, output [3:0] out);
  wire [3:0] lfsrOut, dutOut;
  ex2 tpg(.clk(clk), .rst_b(rst_b), .q(lfsrOut));
  ex1 dut(.i(lfsrOut), .o(dutOut));
  ORA oraa(.clk(clk), .rst_b(rst_b), .in(dutOut), .out(out));
  
endmodule

module ex3_tb;
  reg clk, rst_b;
  wire [3:0] out;
  
  ex3 cut(
    .clk(clk),
    .rst_b(rst_b),
    .out(out)
    );
    
    initial begin
      clk=0;
      rst_b=0;
    end
    
    integer k;
    initial begin
      for(k=0;k<50;k=k+1) begin
        #50 clk = ~clk;
      end
    end
    
    initial begin
      #25;
      rst_b=1;
    end
    
  endmodule