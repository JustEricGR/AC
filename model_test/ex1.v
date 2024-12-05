module ex1(input [5:0] in, output reg [4:0] msd);
  
  reg [5:0] sm;
  reg [3:0] digit;
  //initial copie=in;
  
  always @(*) begin
    digit=0;
    if(!in[5])sm=in;
    else sm={in[5],~in[4:0]};
    
    while(sm!=0) begin
      digit=sm%10;
      sm=sm/10;
    end
    msd={~in[5],digit};
  end
endmodule


module ex1_tb;
  
  reg [5:0] in;
  wire [4:0] msd;
  
  ex1 dut(
    .in(in),
    .msd(msd));
    
    
    integer i;
    initial begin
      {in}=0;
      $monitor("%d\t%b\t",in,msd);
      for(i=0;i<32;i=i+1) begin
        #10 {in}=i;
      end
    end
      
      
  endmodule

      
    