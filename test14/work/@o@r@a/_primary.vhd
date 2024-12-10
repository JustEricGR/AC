library verilog;
use verilog.vl_types.all;
entity ORA is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        \in\            : in     vl_logic_vector(3 downto 0);
        \out\           : out    vl_logic_vector(3 downto 0)
    );
end ORA;
