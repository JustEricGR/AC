module ex4 (
	input [5:0] i,
	output reg is6
);
	always @(*) begin
	  if(i/60==1)
	    is6=1;
	   else
	     is6=0;
	end
endmodule

module ex4_tb;
	reg [5:0] i;
	wire is6;

	ex4 ex4_i (.i(i), .is6(is6));

	integer k;
	initial begin
		$display("Time\ti\ti_dec\tis6");
		$monitor("%0t\t%b\t%0d\t%b", $time, i, i, is6);
		i = 0;
		for (k = 1; k < 64; k = k + 1)
			#10 i = k;
	end
endmodule