module my_dff(
  input clk,
  input rst_b,
  input set_b,
  input d,
  output reg q
);

  always@(posedge clk or negedge set_b or negedge rst_b) begin
    if(!set_b) q <= 1'b1;
    else if(!rst_b) q <= 1'b0;
    else q <= d;
  end

endmodule



module rgst #(
  parameter w = 8,
  parameter initialValue = {w{1'b0}}
)(
  input clk,
  input rst_b,
  input [w-1:0]d,
  input load,
  input cl,
  output reg [w-1:0]q
);

  always@(posedge clk or negedge rst_b) begin
    if(~rst_b) q <= initialValue;
    else if(cl) q <= initialValue;
    else if(load) q <= d; 
  end

endmodule



module fac(
  input x,
  input y,
  input cin,
  output z,
  output cout
);

  assign z = x ^ y ^ cin;
  assign cout = (x & y) | (y & cin) | (x & cin);

endmodule



module counter #(
  parameter w = 8,
  parameter initialValue = 8'hff  
)(
  input clk,
  input rst_b,
  input c_up,
  input cl,
  output reg [w-1:0]q
);

  always@(posedge clk or negedge rst_b) begin
    if(~rst_b) q <= initialValue;
    else begin
      if(cl) q <= initialValue;
      else if(c_up) q <= q + 1;
    end
  end

endmodule



module decoder#(
  parameter w = 3
)(
  input [w-1:0]sel,
  input w_e,
  output reg [2**w-1:0]out
);

  always@(*) begin
    out = 0;
    out[sel] = w_e ? 1 : 0; // bitul sel din out devine 1 daca este enabled sa scriem in registru
  end
  
endmodule



module triStateDriverParamw #(
  parameter w = 4
)(
  input [w-1:0]in,
  input en,
  output [w-1:0]out
);

  assign out = en ? in : {w{1'bz}};

endmodule

module muxParamw #(
  parameter w = 4
)(
  input [w-1:0]d0, d1, d2, d3,
  input [1:0]sel,
  output [w-1:0]o
);

  wire [3:0]enable;
  
  decoder2_4 decoder(.sel(sel), .enable(enable));

  triStateDriverParamw #(4) tspw0 (.in(d0), .enable(enable[0]), .out(o));
  triStateDriverParamw #(4) tspw1 (.in(d1), .enable(enable[1]), .out(o));
  triStateDriverParamw #(4) tspw2 (.in(d2), .enable(enable[2]), .out(o));
  triStateDriverParamw #(4) tspw3 (.in(d3), .enable(enable[3]), .out(o));

endmodule



module multiOperandAdder #(
  parameter w = 8
)(
  input clk,
  input rst_b,
  input [w-1:0]valueToAdd,
  output reg [w-1:0]value
);
  
  always@(posedge clk or negedge rst_b) begin
    if(~rst_b) value <= 0;
    else value <= value + valueToAdd;
  end

endmodule



module compare(
  input [1:0]x,
  input [1:0]y,
  output reg eq,
  output reg lt,
  output reg gt
);

  always@(*) begin
    eq = 0; lt = 0; gt = 0; 
    if(x == y) eq = 1;
    else if(x < y) lt = 1;
    else if(x > y) gt = 1;
  end

endmodule