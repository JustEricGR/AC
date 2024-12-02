library verilog;
use verilog.vl_types.all;
entity c1_add4b is
    port(
        x               : in     vl_logic_vector(3 downto 0);
        y               : in     vl_logic_vector(3 downto 0);
        cin             : in     vl_logic;
        z               : out    vl_logic_vector(3 downto 0)
    );
end c1_add4b;
