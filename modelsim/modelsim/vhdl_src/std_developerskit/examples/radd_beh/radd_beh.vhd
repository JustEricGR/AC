-- ----------------------------------------------------------------------------
--
-- File name   :  regadd_beh.vhdl
-- Title       :  Design Example for Synth_Regpak
--
-- Author      : mkd
-- Date        : 7/15/92
-- ----------------------------------------------------------------------------
-- synopsys translate_off
LIBRARY ieee;
-- synopsys translate_on
use ieee.std_logic_1164.all;
-- synopsys translate_off
library std_developerskit; 
-- synopsys translate_on
use std_developerskit.synth_regpak.all;


ENTITY regadd_beh is
     port( result   :  out std_logic_vector (3 downto 0);
           c_out    :  out std_logic;
           overflow :  out std_logic;
           left_in  :  in  std_logic_vector (3 downto 0);
           right_in :  in  std_logic_vector (3 downto 0);
           c_in     :  in  std_logic
          );
END regadd_beh;

ARCHITECTURE behavioral_arch of regadd_beh is
BEGIN
    basic_process: process (left_in, right_in, c_in)
        variable reslt : std_logic_vector (3 downto 0);             
        variable ovf   : std_logic;
        variable c_ot  : std_logic;
    begin
        RegAdd(reslt, c_ot, ovf, left_in, right_in, c_in, TwosComp);
	result   <= reslt;
        c_out    <= c_ot;
        overflow <= ovf;
    end process;

END behavioral_arch;

