library verilog;
use verilog.vl_types.all;
entity fdivby3 is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        c_up            : in     vl_logic;
        clr             : in     vl_logic;
        fdclk           : out    vl_logic
    );
end fdivby3;
