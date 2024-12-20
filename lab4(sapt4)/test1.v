module dec;
  
  reg [1:0] s;
  reg e;
  wire [3:0] y;
  
  //dec cut(.s(s), .e(e), .y(y));
  assign y = e ? (1 << s) : 0;
  
  integer i;
  initial begin
    {s,e} = 0;
    for(i=0;i<8;i=i+1) 
      #20 s=i;
    #20;
    $finish;
    end
  endmodule
    