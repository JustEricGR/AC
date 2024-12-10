library verilog;
use verilog.vl_types.all;
entity ex1 is
    port(
        i               : in     vl_logic_vector(3 downto 0);
        o               : out    vl_logic_vector(3 downto 0)
    );
end ex1;
