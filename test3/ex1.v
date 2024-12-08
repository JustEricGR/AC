module mux_2s #(
  parameter w=4
  )(
  input [w-1 : 0] d0,d1,d2,d3,
  input [1:0] sel,
  output reg [w-1 : 0] o
  );
  
  always @(*) begin
    o=4'bz;
    case(sel)
      0:o=d0;
      1:o=d1;
      2:o=d2;
      3:o=d3;
      default:o=d0;
    endcase
  end
  
endmodule

module mux2s_tb;
  parameter w=4;
  //parameter aux={size{1'bz}};
  reg [w-1 : 0] d0,d1,d2,d3;
  reg [1:0] sel;
  wire [w-1 : 0] o;
  
  mux_2s #(
    .w(w)
    //.aux(aux)
    ) dut (
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .sel(sel),
    .o(o)
    );
    
    integer i;
    
    initial begin
      
      
      $display("d0\td1\td2\td3\tsel\tout");
      
      for (i = 0; i < 100; i = i + 1) begin
          {d0,d1,d2,d3,sel} = i; 
          #10; 
          $display("%b\t%b\t%b\t%b\t%b\t%b", d0, d1, d2, d3, sel, o);
      end
    end
  endmodule
  
  
