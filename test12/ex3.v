module ex3(input clk, input rst_b, input clr, input c_up, output o);
  
  localparam s0=0, s1=1, s2=2, s3=3, s4=4, s5=5;
  reg [5:0] st;
  wire [5:0] st_next;
  
  assign st_next[s0]=(st[s0]&(~c_up|clr))|(st[s1]&clr)|(st[s2]&clr)|(st[s3]&clr)|(st[s4]&clr)|(st[s5]&(c_up|clr));
  assign st_next[s1]=(st[s0]&(c_up&~clr))|(st[s1]&(~c_up&~clr));
  assign st_next[s2]=(st[s1]&(c_up&~clr))|(st[s2]&(~c_up&~clr));
  assign st_next[s3]=(st[s2]&(c_up&~clr))|(st[s3]&(~c_up&~clr));
  assign st_next[s4]=(st[s3]&(c_up&~clr))|(st[s4]&(~c_up&~clr));
  assign st_next[s5]=(st[s4]&(c_up&~clr))|(st[s5]&(~c_up&~clr));
  
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b) begin
      st<=0;
      st[s0]<=1;
    end
    else st<=st_next;
  end
  
  assign o=st[s0];
  
endmodule

module ex3_tb;
  
  reg clk, rst_b, c_up, clr;
  wire o;
  
  ex3 dut(
    .clk(clk),
    .rst_b(rst_b),
    .c_up(c_up),
    .clr(clr),
    .o(o)
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
    #600 clr=1;
    #100 clr=0;
    #500 clr=1;
    #100 clr=0;
  end
  
endmodule