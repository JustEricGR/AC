module my_dff(input clk, input rst_b, input d, output reg q);
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b)q<=1;
    else q<=d;
  end
endmodule

module lfsr5b(input clk, input rst_b, output [4:0] q);
  
  generate 
    genvar i;
    for(i=0;i<5;i=i+1) begin : loop
      if(i==0)my_dff ffs(.clk(clk), .rst_b(rst_b), .d(q[4]), .q(q[i]));
      else if(i==2)my_dff ffs(.clk(clk), .rst_b(rst_b), .d(q[4]^q[i-1]), .q(q[i]));
      else my_dff ffs(.clk(clk), .rst_b(rst_b), .d(q[i-1]), .q(q[i]));
    end
  endgenerate
endmodule

module lfsr5b_tb;
  reg clk, rst_b;
  wire [4:0] q;
  
  lfsr5b dut (
    .clk(clk),
    .rst_b(rst_b),
    .q(q)
  );
  
  initial begin
    clk=0;
    rst_b=0;
  end
  
  integer i;
  initial begin
    for(i=0;i<70;i=i+1) begin
      #50 clk=~clk;
    end
  end
  
  initial begin
    #25 rst_b=1;
  end
  
endmodule
    
    
    
    