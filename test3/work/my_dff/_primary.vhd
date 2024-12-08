library verilog;
use verilog.vl_types.all;
entity my_dff is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        d               : in     vl_logic;
        q               : out    vl_logic
    );
end my_dff;
