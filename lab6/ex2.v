module ex2(input clk, input rst_b, input i, output reg o);
  localparam S0=0, S1=1, S2=2, S3=3, S4=4;
  
  reg [3:0] state, next_state;
  initial state=S0;
  
  always @(*) begin
    next_state=state;
    o=0;
    case(state)
      S0 : begin
        o=0;
        if(i)next_state=S1;
        else next_state=S0;
      end
      S1 : begin
        o=0;
        if(i)next_state=S1;
        else next_state=S2;
      end
      S2 : begin
        o=0;
        if(i)next_state=S3;
        else next_state=S0;
      end
      S3 : begin
        o=0;
        if(i)next_state=S4;
        else next_state=S2;
      end
      S4 : begin
        o=1;
        if(i)next_state=S1;
        else next_state=S2;
      end
    endcase
  end
  
  always @(posedge clk, negedge rst_b) begin
    if(!rst_b)state<=S0;
    else state<=next_state;
  end
endmodule
  
  module ex2_tb;
    reg i,clk,rst_b;
    wire o;
    
    ex2 dut(
      .clk(clk),
      .i(i),
      .o(o));
      
    initial begin
      clk=0;
      rst_b=0;
      i=1;
    end
    
    integer k;
    initial begin
      for(k=0;k<=14;k=k+1) begin
        #50;
        clk=~clk;
      end
    end
    
    initial begin
      #25;
      rst_b=1;
    end
    
    initial begin
      #100;
      i=0;
      #100;
      i=1;
      #200;
      i=0;
      #100;
      i=1;
    end
    
  endmodule
      