module ex1(input [1:0] i, output [3:0] o);
  assign o=i*i;
  
endmodule


module ex1_tb;
  reg [1:0] i;
  wire [3:0] o;
  
  ex1 dut(
    .i(i),
    .o(o)
  );
  
  integer k;
  initial begin
    {i}=0;
    $monitor("%d\t%d",i,o);
    
    for(k=0;k<4;k=k+1) begin
      #10 {i}=k;
    end
  end
  
endmodule