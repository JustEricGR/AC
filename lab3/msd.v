module msd (
  input [4:0] i,
  output reg[3:0] o
);
  always @(*) begin
    if(i<10)
      o=i;
    else
      o=i/10;
      end
      
endmodule

module msd_tb;
  reg [4:0] i;
  wire [3:0] o;

  msd msd_i (.i(i), .o(o));

  integer k;
  initial begin
    $display("Time\ti\t\to");
    $monitor("%0t\t%b(%2d)\t%b(%0d)", $time, i, i, o, o);
    i = 0;
    for (k = 1; k < 32; k = k + 1)
      #10 i = k;
  end
endmodule