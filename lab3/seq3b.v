module seq3b (
  input [3:0] i,
  output reg o
);
  integer count;
  integer parcurgere;
  always @(*) begin
    count=0;
    o=0;
    //parcurgere=0;
    for (parcurgere = 0; parcurgere < 4; parcurgere = parcurgere + 1) begin
      
      if (((1 << parcurgere) & i) != 0) begin
        count = count + 1;  
        if (count == 3) begin
          o = 1;  
          
        end
      end else begin
        count = 0;  
      end
    end
  end
endmodule

module seq3b_tb;
  reg [3:0] i;
  wire o;

  seq3b seq3b_i (.i(i), .o(o));

  integer k;
  initial begin
    $display("Time\ti\t\to");
    $monitor("%0t\t%b(%2d)\t%b", $time, i, i, o);
    i = 0;
    for (k = 1; k < 16; k = k + 1)
      #10 i = k;
  end
endmodule