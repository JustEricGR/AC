library verilog;
use verilog.vl_types.all;
entity pktmux is
    port(
        pad_pkt         : in     vl_logic;
        zero_pkt        : in     vl_logic;
        mgln_pkt        : in     vl_logic;
        msg_len         : in     vl_logic_vector(63 downto 0);
        pkt             : in     vl_logic_vector(63 downto 0);
        o               : out    vl_logic_vector(63 downto 0)
    );
end pktmux;
