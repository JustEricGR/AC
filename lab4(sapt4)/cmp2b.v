module cmp2b(input [1:0] x, input [1:0] y, output reg eq, output reg lt, output reg gt);
  
  always @(*) begin
    eq=0;
    lt=0;
    gt=0;
    if(x==y)eq=1;
    else if(x>y)gt=1;
    else lt=1;
  end
endmodule

module cmp2b_tb;
  reg [1:0] x,y;
  wire eq,lt,gt;
  
  
  cmp2b dut(
  .x(x),
  .y(y),
  .eq(eq),
  .lt(lt),
  .gt(gt)
  );
  
  integer i;
  initial begin
    
    
    $display("x\ty\teq\tlt\tgt");
    
    for(i=0;i<16;i=i+1) begin : loop
      {x,y}=i;
      #10;
      $display("%b\t%b\t%b\t%b\t%b",x,y,eq,lt,gt);
    end
  end
endmodule
      
      
    