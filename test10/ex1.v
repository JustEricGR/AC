module ex1(input [1:0] x, input [1:0] y, output reg [4:0] o);
  
  always @(*) begin
    if(x==y)o=x**y;
    else o=x*y;
  end
  
endmodule


module ex1_tb;
  reg [1:0] x, y;
  wire [4:0] o;
  
  ex1 dut (
    .x(x),
    .y(y),
    .o(o)
  );
  
  
  integer i;
  initial begin
    {x,y}=0;
    $monitor("%d\t%d\t%d",x,y,o);
    for(i=0;i<16;i=i+1) begin
      #10 {x,y}=i;
    end
  end
  
endmodule