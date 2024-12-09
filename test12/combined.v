module combined_tb;

  reg clk, rst_b, ld, clr; 
  wire fdclk_ex2, o_ex3;
  
  // Instan?a modulului ex2
  ex2 dut_ex2 (
    .clk(clk),
    .rst_b(rst_b),
    .ld(ld),
    .clr(clr),
    .fdclk(fdclk_ex2)
  );

  // Instan?a modulului ex3
  ex3 dut_ex3 (
    .clk(clk),
    .rst_b(rst_b),
    .clr(clr),
    .c_up(ld),
    .o(o_ex3)
  );

  // Semnale comune de testare
  initial begin
    clk = 0;
    rst_b = 0;  // Start cu reset activat
    clr = 0;    // Clear dezactivat
    ld = 1;     // Semnal de înc?rcare activ
  end
  
  // Generare semnal de ceas (clock)
  integer i;
  initial begin
    for (i = 0; i < 50; i = i + 1) begin
      #25 clk = ~clk;  // Flip clk la fiecare 25 ns
    end
  end

  // Reset de baz?
  initial begin
    #30 rst_b = 1;  // Dezactivare reset dup? 30 ns
  end

  // Generare semnal `clr` pentru verific?ri
  initial begin
    #400 clr = 1;  // Activare clear dup? 400 ns
    #50 clr = 0;   // Dezactivare clear
    #300 clr = 1;  // Activare clear din nou
    #50 clr = 0;   // Dezactivare clear
  end

  // Monitorizare ie?iri ?i st?ri
  initial begin
    $monitor("Time=%0d, rst_b=%b, clr=%b, ld=%b | fdclk_ex2=%b, o_ex3=%b",
             $time, rst_b, clr, ld, fdclk_ex2, o_ex3);
  end

endmodule
