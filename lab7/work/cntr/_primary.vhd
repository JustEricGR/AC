library verilog;
use verilog.vl_types.all;
entity cntr is
    generic(
        w               : integer := 8
    );
    port(
        clr             : in     vl_logic;
        c_up            : in     vl_logic;
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        q               : out    vl_logic_vector
    );
end cntr;
