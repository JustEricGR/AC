module ex2(input [3:0] i, output [1:0] o);
  assign o[0]=(~i[3]&i[0])|(~i[2]&i[0]);
  assign o[1]=(~i[1]&~i[0])|(~i[3]&~i[0]);
  
endmodule

module ex2_tb;
  reg [3:0] i;
  wire [1:0] o;
  
  ex2 dut(
    .i(i),
    .o(o)
  );
  
  integer k;
  
  initial begin
    {i}=0;
    $monitor("%b\t%b",i,o);
    
    for(k=0;k<16;k=k+1) begin
      #10 {i}=k;
    end
  end
  
endmodule