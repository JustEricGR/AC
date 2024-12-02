library verilog;
use verilog.vl_types.all;
entity r4b is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        ld              : in     vl_logic;
        sh              : in     vl_logic;
        sh_in           : in     vl_logic;
        d               : in     vl_logic_vector(3 downto 0);
        q               : out    vl_logic_vector(3 downto 0)
    );
end r4b;
