module my_dff(input clk, input rst_b, input set, input d, output reg q);
  always @(posedge clk, negedge rst_b, negedge set) begin
    if(!set)q<=1;
    else if(!rst_b)q<=0;
    else q<=d;
  end
  
endmodule

module ex2(input clk, input rst_b, output [3:0]q);
  generate 
    genvar i;
    for(i=0;i<4;i=i+1) begin : loop
      if(i==0)my_dff ffs(.clk(clk), .set(rst_b), .d(q[3]), .q(q[i]));
      else my_dff ffs(.clk(clk), .set(rst_b), .d(q[3]^q[i-1]), .q(q[i]));
    end
  endgenerate
endmodule

module ex2_tb;
  reg clk, rst_b;
  wire [3:0] q;
  
  ex2 dut(
    .clk(clk),
    .rst_b(rst_b),
    .q(q));
    
    initial begin
      clk=0;
      rst_b=0;
    end
    
    integer i;
    initial begin
      for(i=0;i<50;i=i+1) begin
        #50 clk = ~clk;
      end
    end
    
    initial begin
      #25;
      rst_b=1;
    end
    
  endmodule