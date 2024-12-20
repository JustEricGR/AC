module pktmux(input pad_pkt, input zero_pkt, input mgln_pkt, input [63:0] msg_len, input [63:0] pkt, output reg [63:0] o);
  
  always @(*) begin
    if(pad_pkt) begin
      o=0;
      o[63]=1;
    end
    else if(zero_pkt)o=0;
    else if(mgln_pkt)o=msg_len;
    else o=pkt;
  end
  
endmodule

module pktmux_tb;
  reg pad_pkt, zero_pkt, mgln_pkt;
  reg [63:0] msg_len, pkt;
  wire [63:0] o;
  
  task urand64(output reg [63:0] r);
    begin
      r[63:32] = $urandom;
      r[31:0] = $urandom;
    end
  endtask
  
  pktmux dut(
    .pad_pkt(pad_pkt),
    .zero_pkt(zero_pkt),
    .mgln_pkt(mgln_pkt),
    .msg_len(msg_len),
    .pkt(pkt),
    .o(o)
    );
    
    initial begin
  pad_pkt = 0;
  zero_pkt = 0;
  mgln_pkt = 0;
  urand64(msg_len);
  urand64(pkt);
end

integer i;
initial begin
  for(i = 1; i <= 12; i = i + 1) begin
    #100; urand64(msg_len); urand64(pkt);
  end
end

initial begin
  #100; pad_pkt = 1;
  #100; pad_pkt = 0;
  #300; pad_pkt = 1;
  #100; pad_pkt = 0;
  #300; pad_pkt = 1;
  #100; pad_pkt = 0;
end

initial begin
  #200; zero_pkt = 1;
  #100; zero_pkt = 0;
  #300; zero_pkt = 1;
  #100; zero_pkt = 0;
  #300; zero_pkt = 1;
  #100; zero_pkt = 0;
end

initial begin
  #300; mgln_pkt = 1;
  #100; mgln_pkt = 0;
  #300; mgln_pkt = 1;
  #100; mgln_pkt = 0;
  #300; mgln_pkt = 1;
  #100; mgln_pkt = 0;
end
  
endmodule
    
    