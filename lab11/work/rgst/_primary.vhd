library verilog;
use verilog.vl_types.all;
entity rgst is
    generic(
        w               : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        ld              : in     vl_logic;
        clr             : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
end rgst;
