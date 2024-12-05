library verilog;
use verilog.vl_types.all;
entity ex3 is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        q               : out    vl_logic_vector(5 downto 0)
    );
end ex3;
