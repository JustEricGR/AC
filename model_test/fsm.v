/*module fsm #(
  parameter size = 3;)(
  input clk;
  input rst;
  input in;
  output out;
  );
  reg st[1:0];//determinat sau setat secvential
  reg st_next[1:0];//determinat combinational
  
  localparam s1=0;
  localparam s2=1;
  localparam s3=2;
  
  always@(*)begin
    case(st)
      s1: begin
        out=1;
      if(in==1)
        st_next=s1;        
      else 
        st_next=s3;
      end
      s2: begin
        out=1;
        if(in)st_next=s2;
        else st_next=s3;
        end
      s3: begin
        out=0;
        if(in)st_next=s1;
        else st_next=s2;
        end
        
    endcase
  end
  
  always @(posedge clk) begin
    if(!rst)st<=s1;
    else st<=st_next;
  end

endmodule*/

module fsm_onehot(input clk;
  input rst;
  input in;
  output out;
  );
  reg st[1:0];//determinat sau setat secvential
  wire st_next[1:0];//determinat combinational
  
  localparam s1=0;
  localparam s2=1;
  localparam s3=2;
  
  assign st_next[s1]=(st[s3]&in);
  assign st_next[s2]=(st[s1]&in)|(st[s3]&(~in))|(st[s2]&in);
  assign st_next[s3]=(st[s1]&(~in))|(st[s2]&(~in));
  
  assign out = st[s1]|st[s3];
  
  
  
  always @(posedge clk, negedge rst) begin
    if(!rst) begin
      st<=0;
      st[s1]<=1;
    end
      
    else st<=st_next;
  end

endmodule