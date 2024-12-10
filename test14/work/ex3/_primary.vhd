library verilog;
use verilog.vl_types.all;
entity ex3 is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        \out\           : out    vl_logic_vector(3 downto 0)
    );
end ex3;
