module fac(input x, input y, input cin, output z, output cout);
  
  assign cout = (cin&y) | (x&cin) | (x&y);
  assign z = x^y^cin;
endmodule

module add2b(input [1:0] x, input [1:0] y, input cin, output [1:0] z, output cout);
  wire aux;
  fac ffs1(.x(x[0]), .y(y[0]), .cin(cin), .z(z[0]), .cout(aux));
  fac ffs2(.x(x[1]), .y(y[1]), .cin(aux), .z(z[1]), .cout(cout));
endmodule

module add2b_tb;
  reg [1:0]x,y;
  reg cin;
  wire [1:0] z;
  wire cout,aux;
  
  
  add2b dut (
        .x(x),
        .y(y),
        .cin(cin),
        .z(z),
        .cout(cout)
    );
    
  integer i;
  initial begin
    {x,y,cin}=0;
    
    $display("x\ty\tcin\tcout\tz");
    for(i=0;i<16;i=i+1) begin : loop
      {x,y,cin}=i;
      #20;
      $display("%b\t%b\t%b\t%b\t%b",x,y,cin,cout,z);
    end
    
    //#20;
  end
endmodule