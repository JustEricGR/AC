module dff(input clk, input rst_b, input set_b, input d, output reg q);
  
  always @(posedge clk, negedge rst_b, negedge set_b) begin
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
        forever #5 clk = ~clk; // Semnal toggle la fiecare 5 ns
    end

    // Simulare
    initial begin
        // Ini?ializare semnale
        rst_b = 1; set_b = 1; d = 0;

        // Testare secven?ial?
        #10 rst_b = 0;          
        #10 rst_b = 1;          
        #10 set_b = 0;          // Aplicare set
        #10 set_b = 1;          // Eliberare set
        #10 d = 1;              // Setare D
        #20 d = 0;              // Schimbare D
        #20 d = 1;              // Schimbare D
        #20 rst_b = 0;          // Reset din nou
        #10 rst_b = 1;          // Eliberare reset
        #10 $finish;            // Terminare simulare
    end

    // Salvare forme de und? pentru vizualizare (op?ional)
    initial begin
        $dumpfile("dff_waveform.vcd");
        $dumpvars(0, dff_tb);
    end

endmodule