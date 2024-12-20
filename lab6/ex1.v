module ex1(input clk, input rst_b, input [1:0] in, output reg out);
  
  localparam S0=0;
  localparam S1=1;
  
  reg state, next_state;
  
  always @(*) begin
    next_state=state;
    out=0;
    case(state)
      S0: begin
        if(in==2'b11) begin
          next_state=S1;
          out=0;
        end
        else begin
          next_state=S0;
          if(in==2'b00)out=0;
          else if(in==2'b01 || in==2'b10) out=1;
        end
      end
      S1: begin
        if(!in) begin
          next_state=S0;
          out=1;
        end
        else begin
          next_state=S1;
          if(in==2'b11)out=1;
          else if(in==2'b01 || in==2'b10)out=0;
        end
      end
    endcase
  end
  
  always @(posedge clk, negedge rst_b) begin
    state<=S0;
    if(!rst_b)state<=S0;
    else state<=next_state;
  end
endmodule
  
  module ex1_tb;
    reg clk,rst_b;
    reg [1:0] in;
    wire out;
    
    ex1 dut(
      .clk(clk),
      .rst_b(rst_b),
      .in(in),
      .out(out)
      );
      
    initial begin
      clk=0;
      rst_b=0;
      in[1]=0;
      in[0]=1;
    end
    
    integer i;
    initial begin
      for(i=0;i<=9;i=i+1) begin
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
      in[1]=1;
      #200;
      in[1]=0;
    end
    
    initial begin
      #200;
      in[0]=0;
    end
    
  endmodule
        
        