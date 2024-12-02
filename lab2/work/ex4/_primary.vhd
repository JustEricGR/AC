library verilog;
use verilog.vl_types.all;
entity ex4 is
    port(
        i               : in     vl_logic_vector(5 downto 0);
        is6             : out    vl_logic
    );
end ex4;
