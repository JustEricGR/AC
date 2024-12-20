module my_dff(input clk, input rst_b, input en, input [3:0] d, output reg [3:0] q);
  always @(posedge clk) begin
    if(!rst_b)q<=1;
    else if(en) q<=d;
  end
endmodule

module ex1(input clk, input rst_b, input en, output [3:0] q);
  generate
    genvar i;
    for(i=0;i<4;i=i+1) begin : loop
      if(i==0)my_dff ffs(.clk(clk), .rst_b(rst_b), .en(en), .d(1), .q(q[i]));
      else my_dff ffs(.clk(clk), .rst_b(rst_b), .en(en), .d(q[i-1]+1), .q(q[i]));
    end
  endgenerate
endmodule

module ex1_tb;
  reg clk, rst_b, en;
  wire [3:0] q;
  
  ex1 dut(
    .clk(clk),
    .rst_b(rst_b),
    .en(en),
    .q(q)
  );
  
  initial begin
    clk=0;
    rst_b=0;
    en=1;
  end
  
  integer i=0;
  initial begin
    for(i=0;i<20;i=i+1) begin
      #50 clk=~clk;
    end
  end
  
  initial begin
    #25 rst_b=1;
  end
  
endmodule
  