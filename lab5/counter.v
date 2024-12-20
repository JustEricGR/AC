module counter #(parameter size=8, parameter init={size{1'b1}})(input clk, input rst_b, input c_up, input clr, output reg [size-1 : 0] q);
  
  always @(posedge clk, rst_b) begin
    if(!rst_b)q<=init;
    else begin
      if(clr)q<=init;
      else if(c_up)q<=q+1;
    end
    if(q=={size{1'b1}})q<=0;
  end
endmodule

module counter_tb;
  parameter size=8;
  parameter init={size{1'b1}};
  reg clk,rst_b,c_up,clr;
  wire [size-1 : 0] q;
  
  counter #(
    .size(size),
    .init(init)
    ) dut (
    .clk(clk),
    .rst_b(rst_b),
    .c_up(c_up),
    .clr(clr),
    .q(q)
    );
    
    
    
    initial begin
      clk=0;
      //#5;
      repeat(100) #5 clk=~clk;
    end
    
    initial begin
      rst_b=0;
      #5;
      rst_b=1;
    end
    
    initial begin
      c_up=1;
      #60;
      c_up=0;
      #10;
      c_up=1;
    end
    
    initial begin
      clr=0;
      #40;
      clr=1;
      #10;
      clr=0;
    end
    
    
    
    
    
  endmodule