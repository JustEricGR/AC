library verilog;
use verilog.vl_types.all;
entity sha2indpath is
    port(
        pkt             : in     vl_logic_vector(63 downto 0);
        st_pkt          : in     vl_logic;
        clr             : in     vl_logic;
        pad_pkt         : in     vl_logic;
        zero_pkt        : in     vl_logic;
        mgln_pkt        : in     vl_logic;
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        idx             : out    vl_logic_vector(3 downto 0);
        blk             : out    vl_logic_vector(511 downto 0)
    );
end sha2indpath;
