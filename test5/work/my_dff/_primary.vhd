library verilog;
use verilog.vl_types.all;
entity my_dff is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        en              : in     vl_logic;
        d               : in     vl_logic_vector(3 downto 0);
        q               : out    vl_logic_vector(3 downto 0)
    );
end my_dff;
