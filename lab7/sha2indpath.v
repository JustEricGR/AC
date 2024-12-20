` include "pktmux.v"
` include "regfl.v"

module cntr #(
  parameter w=8
  )(
  input clr, input c_up, input clk, input rst_b,
   output reg [w-1:0] q
   );
   
   always @(posedge clk, negedge rst_b) begin
     if(!rst_b)q<=0;
     else if(clr)q<=0;
     else if(c_up) q<=q+1;
    end
    
  endmodule
  
  module sha2indpath(input [63:0] pkt,
    input st_pkt, clr, pad_pkt, zero_pkt, mgln_pkt, clk, rst_b,
    output [3:0] idx, 
    output [511:0] blk
    );
    
    wire [63:0] out_rgst, out_mux;
    pktmux circ1(
      .pad_pkt(pad_pkt),
      .zero_pkt(zero_pkt),
      .mgln_pkt(mgln_pkt),
      .pkt(pkt),
      .msg_len(out_rgst),
      .o(out_mux)
      );
      
    rgst #(
      .w(64)
      ) circ2 (
      .clk(clk),
      .rst_b(rst_b),
      .ld(~(pad_pkt|zero_pkt|mgln_pkt)&st_pkt),
      .d(out_rgst+64),
      .q(out_rgst)
      );
      
    cntr #(
      .w(3)
      ) circ3 (
      .clr(clr),
      .clk(clk),
      .rst_b(rst_b),
      .c_up(st_pkt),
      .q(idx)
    );
    
    regfl circ4(
      .clk(clk),
      .rst_b(rst_b),
      .w_e(st_pkt),
      .s(idx),
      .d(out_mux),
      .q(blk)
      );  
      
      
endmodule

module sha2indpath_tb;
  
  reg [63:0] pkt;
  reg clk, rst_b, clr, st_pkt, zero_pkt, pad_pkt, mgln_pkt;
  wire [3:0] idx;
  wire [511:0] blk;
  
  task urand64(output reg [63:0] r);
    begin
      r[63:32] = $urandom;
      r[31:0] = $urandom;
    end
  endtask

  sha2indpath cut(
    .st_pkt(st_pkt),
    .clr(clr),
    .pkt(pkt),
    .pad_pkt(pad_pkt),
    .zero_pkt(zero_pkt),
    .mgln_pkt(mgln_pkt),
    .clk(clk),
    .rst_b(rst_b),
    .idx(idx),
    .blk(blk)
  );
  
  initial begin
      clk=0;
      rst_b=0;
      clr=0;
      st_pkt = 1;
      pad_pkt = 0;
      zero_pkt = 0;
      mgln_pkt = 0;
      urand64(pkt);
      
    end
    
    integer i;
    initial begin
      for(i=1;i<=27;i=i+1)begin
        #50;
        clk=~clk;
      end
    end
    
    initial begin
      #25;
      rst_b=1;
    end
    
    initial begin
  #200; clr = 1;
  #100; clr = 0;
end

initial begin
  #800; st_pkt = 0;
  #100; st_pkt = 1;
end

initial begin
  #1000; pad_pkt = 1;
  #100; pad_pkt = 0;
end

initial begin
  #1100; zero_pkt = 1;
  #100; zero_pkt = 0;
end

initial begin
  #1200; mgln_pkt = 1;
  #100; mgln_pkt = 0;
end

integer j;
initial begin
  for(j = 1; j <=12; j = j + 1) begin
    #100; urand64(pkt);
  end
end

endmodule
