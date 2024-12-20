module ex1 #(parameter shift=5)(input [5:0] a, output [5:0] b);
  assign b={a[shift-1 : 0], a[5-shift : shift]};
  
endmodule

module ex1_tb;
  reg [5:0] a;
  //reg shift;
  wire [5:0] b;
  
  ex1 #(
    .shift(2)
    ) dut (
    .a(a),
    //shift(shift),
    .b(b)
  );
  
  integer i;
  initial begin
    //shift=2;
    {a}=0;
    $monitor("%b\t%b",a,b);
    for(i=0;i<64;i=i+1) begin
      #10 {a}=i;
    end
  end
  
endmodule