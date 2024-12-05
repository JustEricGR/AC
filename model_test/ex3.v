module my_dff(input clk, input reset, input d, output reg q);
  always @(posedge clk or negedge reset) begin
    if(!reset)q<=1;
    else q<=d;
  end
endmodule

module ex3(input clk, input reset, output [5:0] q);
  
  
  generate
    genvar i;
    for(i=0;i<6;i=i+1) begin : loop
      if(i==2 || i==4 || i==5)my_dff ffs1(.clk(clk), .reset(reset), .d(q[5]^q[i-1]), .q(q[i]));
      else if(i==0)my_dff ffs2(.clk(clk), .reset(reset), .d(q[5]), .q(q[0]));
      else my_dff ffs3(.clk(clk), .reset(reset), .d(q[i-1]), .q(q[i]));
    end
  endgenerate
  
endmodule

module ex3_tb;
  reg clk, reset;
  wire [5:0] q;
  
  ex3 dut(
    .clk(clk),
    .reset(reset),
    .q(q));
    
    initial begin
      clk=0;
      reset=0;
    end
    
    integer i;
    initial begin
      for(i=0;i<50;i=i+1) begin
        #50 clk = ~clk;
      end
    end
    
    initial begin
      #25;
      reset=1;
    end
    
  endmodule