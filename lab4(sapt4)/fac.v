module fac(input x, input y, input cin, output z, output cout);
  
  assign cout = (cin&y) | (x&cin) | (x&y);
  assign z = x^y^cin;
endmodule

module fac_tb;
  reg x,y,cin;
  wire z,cout;
  
  
  fac uut (
        .x(x),
        .y(y),
        .cin(cin),
        .z(z),
        .cout(cout)
    );
    
  integer i;
  initial begin
    {x,y,cin}=0;
    
  
    for(i=0;i<8;i=i+1) begin : loop
      {x,y,cin}=i;
      #20;
      $display("%b %b %b %b %b",x,y,cin,cout,z);
    end
    
    //#20;
  end
endmodule