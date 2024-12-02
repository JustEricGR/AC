module cnt1s (
  input [5:0] i,
  output reg[2:0] o
);
integer counter;
reg[5:0] aux;
  always @(*) begin
    counter=0;
    aux=i;
    while(aux>=10) begin
      if(aux%10==1)begin
        counter=counter+1;
      end
        aux=aux/10;
    end
    if(aux==1)
      counter=counter+1;
    o=counter;
  end
endmodule

module cnt1s_tb;
  reg [5:0] i;
  wire [2:0] o;

  cnt1s cnt1s_i (.i(i), .o(o));

  integer k;
  initial begin
    $display("Time\ti\t\to");
    $monitor("%0t\t%b(%2d)\t%b(%0d)", $time, i, i, o, o);
    i = 0;
    for (k = 1; k < 64; k = k + 1)
      #10 i = k;
  end
endmodule