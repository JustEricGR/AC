library verilog;
use verilog.vl_types.all;
entity dec is
    generic(
        w               : integer := 2
    );
    port(
        s               : in     vl_logic_vector;
        e               : in     vl_logic;
        o               : out    vl_logic_vector
    );
end dec;
