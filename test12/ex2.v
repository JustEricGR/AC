module register #(parameter w=3)
(input clk, input rst_b, input ld, input clr, input [w-1:0] d, output reg [w-1:0] q);
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b)q<=0;
    else if(clr)q<=0;
    else if(ld)q<=d;
  end
endmodule

module ex2(input clk, input rst_b, input ld, input clr, output fdclk);
  wire [2:0] q;
  
  register #(
    .w(3)
    ) rgst (
    .clk(clk),
    .rst_b(rst_b),
    .ld(ld),
    .clr((q[2]&q[1])|clr),
    .d({(q[1]&q[0])^q[2],q[2]^q[1],~q[0]}),
    .q(q)
  );
  
  assign fdclk=~(q[2]|q[1]|q[0]);
  
endmodule

module ex2_tb;
  
  reg clk, rst_b, ld, clr;
  wire fdclk;
  
  ex2 dut(
    .clk(clk),
    .rst_b(rst_b),
    .ld(ld),
    .clr(clr),
    .fdclk(fdclk)
  );
  
  initial begin
    clk=0;
    rst_b=0;
    clr=0;
    ld=1;
  end
  
  integer i;
  initial begin
    for(i=0;i<30;i=i+1) begin
      #50 clk=~clk;
    end
  end
  
  initial begin
    #25 rst_b=1;
  end
  
  initial begin
    #600 clr=1;
    #100 clr=0;
    #500 clr=1;
    #100 clr=0;
  end
  
endmodule