module ex3(input clk, 
  input rst_b, 
  input a,b,c, 
  output m,n,p);
  
  localparam s0=0, s1=1, s2=2, s3=3, s4=4, s5=5;
  reg [5:0] st;
  wire [5:0] st_next;
  
  assign st_next[s0]=(st[s0]&~a);
  assign st_next[s1]=st[s0]&(a|c);
  assign st_next[s2]=(st[s0]&(a|b))|(st[s1]&~b);
  assign st_next[s3]=(st[s1]&~b)|(st[s2]&(b|c));
  assign st_next[s4]=(st[s2]&~b)|(st[s3]&(~a|~b|c));
  assign st_next[s5]=(st[s0]|(a|~b))|(st[s3]&(a|b|c))|(st[s4]&~c);
  
  always @(posedge clk) begin
    if(!rst_b) begin
      st<=0;
      st[s0]<=1;
    end
    else st<=st_next;
  end
  
endmodule
  