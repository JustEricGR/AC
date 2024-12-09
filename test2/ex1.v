module ex1(input [4:0] i, output reg [4:0] o);
  reg [4:0] aux;
  reg [4:0] in;
  
  always @(*) begin
    in=i;
    
    while(in!=0) begin
      aux=in%10;
      in=in/10;
    end
    o=aux;
  end
  
  
endmodule

module ex1_tb;
  reg [4:0] i;
  wire [4:0] o;
  
  ex1 dut(
    .i(i),
    .o(o)
  );
  
  integer k;
  initial begin
    {i}=0;
    $monitor("%d\t%d",i,o);
    for(k=0;k<32;k=k+1) begin
      #10 {i}=k;
    end
  end
  
endmodule