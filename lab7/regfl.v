module dec #(parameter w=2)(
	input [w-1:0] s,
	input e,
	output reg [2**w-1:0] o
);
	always @ (*) begin
		o = 0;
		if (e)
  		  o[s] = 1;
	end
endmodule

module rgst #(
    parameter w=8
)(
    input clk, rst_b, ld, clr, input [w-1:0] d, output reg [w-1:0] q
);
    always @ (posedge clk, negedge rst_b)
        if (!rst_b)                 q <= 0;
        else if (clr)               q <= 0;
        else if (ld)                q <= d;
endmodule

module regfl(input clk, input rst_b, input w_e, input [2:0] s, input [63:0] d, output [511:0] q);
   
   wire [7:0] o;
   
   dec #(
    .w(3)
    ) dec1 (
    .s(s),
    .e(w_e),
    .o(o)
    );
    
   
   generate
     genvar i;
     for(i=0;i<8;i=i+1) begin : loop
       rgst #(
        .w(64)
        ) register (
        .clk(clk),
        .clr(1'b0),
        .rst_b(rst_b),
        .ld(o[i]),
        .d(d),
        .q(q[((64*(8-i))-1) : (64*(7-i))])
        );
      end
    endgenerate
    
  endmodule
  
  module regfl_tb;
    reg clk, rst_b, w_e;
    reg [2:0]s;
    reg [63:0]d;
    wire [511:0]q;
    
  task urand64(output reg [63:0] r);
    begin
      r[63:32] = $urandom;
      r[31:0] = $urandom;
    end
  endtask
    
    regfl dut(
      .clk(clk),
      .rst_b(rst_b),
      .w_e(w_e),
      .s(s),
      .d(d),
      .q(q)
      );
      
    initial begin
      clk=0;
      rst_b=0;
      w_e=1;
      urand64(d);
      urand64(s);
    end
    
    integer i;
    initial begin
      for(i=1;i<=26;i=i+1)begin
        #50;
        clk=~clk;
      end
    end
    
    initial begin
      #25;
      rst_b=1;
    end
    
    initial begin
      #600;
      w_e=0;
      #100;
      w_e=1;
    end
    
    integer j;
    initial begin
      for(j=1;j<=12;j=j+1) begin
        #100; urand64(d); urand64(s);
      end
    end
    
  endmodule
    
    
      
        
     