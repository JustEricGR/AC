module my_dff(input clk, input rst_b, input d, output reg q);
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b)q<=1;
    else q<=d;
  end
  
endmodule

module ex3 #(
  parameter w=4
  )(
  input clk,
  input rst_b,
  input ld,
  input [w-1:0] d,
  output [w-1:0] q
  );
  
  generate
    genvar i;
    for(i=0;i<w;i=i+1) begin : loop
      //if(!ld)my_dff ffs(.clk(clk), .rst_b(rst_b), .d(0), .q(q[i]));
      my_dff ffs(.clk(clk), .rst_b(rst_b), .d(d[i]), .q(q[i]));
    end
  endgenerate
  
endmodule

module ex3_tb;
  reg clk, rst_b, ld;
  reg [3:0] d;
  wire [3:0] q;
  
  ex3 #(
    .w(4)
    ) dut (
    .clk(clk),
    .rst_b(rst_b),
    .ld(ld),
    .d(d),
    .q(q)
  );
  
  initial begin
    clk=0;
    rst_b=0;
    ld=1;
  end
  
  integer i;
  initial begin
    for(i=0;i<16;i=i+1) begin
      #50 clk=~clk;
    end
  end
  
  initial begin
    #25 rst_b=1;
  end
  
  integer j;
  initial begin
    {d}=0;
    for(j=0;j<16;j=j+1) begin
      #50 {d}=j;
    end
  end
  
endmodule
  