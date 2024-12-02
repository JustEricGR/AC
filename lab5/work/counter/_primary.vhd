library verilog;
use verilog.vl_types.all;
entity counter is
    generic(
        size            : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        c_up            : in     vl_logic;
        clr             : in     vl_logic;
        q               : out    vl_logic_vector
    );
end counter;
