module fac( 
    input a, b, cin,
    output cout, sum );
    
    assign cout = b&cin | a&cin | a&b;
    assign sum = a^b^cin;

endmodule

module c1_add4b(input [3:0] x, input [3:0] y, input cin, output [3:0] z);
  wire [3:0] aux;
  
  fac adder1(.a(x[0]), .b(y[0]), .cin(cin), .cout(aux[0]), .sum(z[0]));
  generate
    genvar i;
    for(i=1;i<4;i=i+1) begin : loop
      fac adder(.a(x[i]), .b(y[i]), .cin(aux[i-1]), .cout(aux[i]), .sum(z[i]));
    end
  endgenerate
endmodule

module c1_tb;
  reg [3:0] x,y;
  reg cin;
  wire [3:0] z;
  
  
  c1_add4b dut(
  .x(x),
  .y(y),
  .cin(cin),
  .z(z)
  );
  
  integer i;
  initial begin
    
    
    $display("x\ty\tcin\tz");
    
    for(i=0;i<512;i=i+1) begin : loop
      {x,y,cin}=i;
      #10;
      $display("%b\t%b\t%b\t%b",x,y,cin,z);
    end
  end
endmodule 