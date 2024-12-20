module ex1(input [5:0] x, input [5:0] y, output reg [2:0] o);
  always @(*) begin
    if(x[5]==y[5]) begin
      o[2]=x[5]^1;
      o[1]=x[4]^1;
      o[0]=x[3]^1;
    end
    else begin
      o[2]=y[2]^1;
      o[1]=y[1]^1;
      o[0]=y[0]^1;
      
    end
  end
  
endmodule

module ex1_tb;
  
  reg [5:0] x,y;
  wire [2:0] o;
  
  ex1 dut(
    .x(x),
    .y(y),
    .o(o)
  );
  
  integer i;
  initial begin
    {x,y}=0;
    $monitor("%b\t%b\t%b",x,y,o);
    for(i=0;i<50;i=i+1) begin
      #10 {x,y}=i;
    end
  end
  
endmodule