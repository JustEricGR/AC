library verilog;
use verilog.vl_types.all;
entity ex2 is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        ld              : in     vl_logic;
        clr             : in     vl_logic;
        fdclk           : out    vl_logic
    );
end ex2;
