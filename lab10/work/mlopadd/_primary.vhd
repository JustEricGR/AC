library verilog;
use verilog.vl_types.all;
entity mlopadd is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        x               : in     vl_logic_vector(9 downto 0);
        a               : out    vl_logic_vector(15 downto 0)
    );
end mlopadd;
