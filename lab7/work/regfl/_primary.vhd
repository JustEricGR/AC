library verilog;
use verilog.vl_types.all;
entity regfl is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        w_e             : in     vl_logic;
        s               : in     vl_logic_vector(2 downto 0);
        d               : in     vl_logic_vector(63 downto 0);
        q               : out    vl_logic_vector(511 downto 0)
    );
end regfl;
