library verilog;
use verilog.vl_types.all;
entity ex3 is
    generic(
        w               : integer := 4
    );
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        ld              : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
end ex3;
