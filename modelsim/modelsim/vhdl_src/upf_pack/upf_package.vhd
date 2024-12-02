library ieee;
use ieee.std_logic_1164.all;
package UPF_vhdl is
    type supply_net_type is record
        voltage: integer;
        state: std_logic_vector (31 downto 0);
    end record;
    type net_state is (
            OFF,
            \ON\,
            PARTIAL_ON
        );
end package ;
