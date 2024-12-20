module dff(input clk, input rst_b, input set_b, input d, output reg q);
  
  always @(posedge clk) begin
    if(!set_b) q<=1;
    else if(!rst_b) q<=0;
    else q<=d;
  end
endmodule


module dff_tb;

    // Declara?ie semnale
    reg clk;      // Semnalul de ceas
    reg rst_b;    // Reset asincron
    reg set_b;    // Set asincron
    reg d;        // Intrare
    wire q;       // Ie?ire

    // Instan?ierea modulului
    dff uut (
        .clk(clk),
        .rst_b(rst_b),
        .set_b(set_b),
        .d(d),
        .q(q)
    );

    // Generare semnal de ceas (clock) cu perioada de 10 ns
    

    
    
    initial begin
        clk = 0;
        forever #50 clk = ~clk; // Semnal toggle la fiecare 5 ns
    end
    
    initial begin
      #10 rst_b=0;
    end
    
    initial begin
      #20 set_b=0;
      #10 set_b=1;
    end
    
    initial begin
      #30 d = 1;              // Setare D
        #30 d = 0;              // Schimbare D
        #30 d = 1;
      end

    

endmodule
