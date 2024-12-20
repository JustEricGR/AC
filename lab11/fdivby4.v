module fdivby4(input clk, input rst_b, input c_up, input clr, output fdclk);
  
  localparam S0=0, S1=1, S2=2, S3=3;
  reg [3:0] st;
  wire [3:0] st_next;
  
  assign st_next[S0]=(st[S0]&(~c_up|clr))|(st[S1]&clr)|(st[S2]&clr)|(st[S3]&(c_up|clr));
  assign st_next[S1]=(st[S0]&(c_up|~clr))|(st[S1]&(~c_up&~clr));
  assign st_next[S2]=(st[S1]&(c_up|~clr))|(st[S2]&(~c_up&~clr));
  assign st_next[S3]=(st[S2]&(c_up|~clr))|(st[S3]&(~c_up&~clr));
  
  
  
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b) begin
      st<=0;
      st[S0]<=1;
    end
    else st<=st_next;
  end
  
  assign fdclk=st[S0];
  
endmodule


module fdivby4_tb;
  
  reg clk,rst_b,c_up,clr;
  wire fdclk;
  
  fdivby4 dut(
    .clk(clk),
    .rst_b(rst_b),
    .c_up(c_up),
    .clr(clr),
    .fdclk(fdclk)
  );
  
  initial begin
    clk=0;
    rst_b=0;
    clr=0;
    c_up=1;
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
    #400 clr=1;
    #100 clr=0;
  end
  
  initial begin
    #600 c_up=0;
    #100 c_up=1;
    #400 c_up=0;
    #200 c_up=1;
  end
  
endmodule
  
  