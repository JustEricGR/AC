module mux_2s #(
  parameter size=4,
  parameter aux={size{1'bz}}
  )(
  input [size-1 : 0] d0,d1,d2,d3,
  input [1:0] sel,
  output reg [size-1 : 0] out
  );
  
  always @(*) begin
    out = aux;
    case(sel)
      2'b00 : out = d0;
      2'b01 : out = d1;
      2'b10 : out = d2;
      2'b11 : out = d3;
    endcase
  end
  
endmodule

module mux_tb;
  parameter size=4;
  parameter aux={size{1'bz}};
  reg [size-1 : 0] d0,d1,d2,d3;
  reg [1:0] sel;
  wire [size-1 : 0] out;
  
  mux_2s #(
    .size(size),
    .aux(aux)
    ) dut (
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .sel(sel),
    .out(out)
    );
    
    integer i;
    
    initial begin
      
      
      $display("d0\td1\td2\td3\tsel\tout");
      
      for (i = 0; i < 16; i = i + 1) begin
          {d0,d1,d2,d3,sel} = i; 
          #10; 
          $display("%b\t%b\t%b\t%b\t%b\t%b", d0, d1, d2, d3, sel, out);
      end
    end
  endmodule
  
  
