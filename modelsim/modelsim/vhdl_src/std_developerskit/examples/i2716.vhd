-------------------------------------------------------------------------------
--                                     Developed by:
--                                     THE VHDL CONSULTING GROUP
--
-- File name   : i2716.v110
-- Title       : Model of INTEL 2716
-- Purpose     : To provide an example model of the Intel 51256S/L-07 in order to
--               demonstrate how to use Std_Mempak to build memory models
--             :
-- Assumptions : none
-- Limitations : *****  This model is provided for demonstration purposes *****
--               *****  only.                                             *****
-- Known Errors: none
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Proprietary Information <<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This source code contains proprietary information of The VHDL Consulting
-- Group and shall not be disclosed other than as provided in the software
-- licensing agreement.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- THE VHDL CONSULTING GROUP MAKES NO WARRANTY OF ANY KIND WITH REGARD TO
-- THE USE OF THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
-- FOR A PARTICULAR PURPOSE.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Liability <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- IN NO EVENT SHALL THE VHDL CONSULTING GROUP BE LIABLE FOR ANY
-- INCIDENTAL, INDIRECT, SPECIAL, OR CONSEQUENTIAL DAMAGES WHATSOEVER
-- ( INCLUDING BUT NOT LIMITED TO LOST PROFITS) ARISING IN OF OR RELATED
-- TO THE USE OF THIS SOFTWARE, EVEN IF THE VHDL CONSULTING GROUP HAS
-- BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>> USE OF MODEL <<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Licensees of the Std_Developerskit may freely copy, modify, or otherwise
-- make use of this model.
-- ----------------------------------------------------------------------------
--   Version No:| Author:    |  Mod. Date:| Changes Made:
--     v1.110   | wrm        |  02/12/92  | first version
-- ----------------------------------------------------------------------------
        
----------------------------------------------------------------------
-- INTEL : 2K X 8 EPROM
----------------------------------------------------------------------

Library ieee;
Use     ieee.STD_Logic_1164.all; -- Reference the STD_Logic system
LIBRARY std_developerskit;
USE     std_developerskit.Std_Mempak.all;
use     std_developerskit.Std_IOpak.all;
use     std_developerskit.Std_Timing.all;


Entity INTEL2716 is

    port    ( A     : IN    std_logic_vector ( 10 downto 0 );  -- address
              Q     : OUT std_logic_vector ( 7 downto 0);      -- output data
              CE_N  : IN    std_logic;                         -- chip enable
              OE_N  : IN    std_logic                          -- output enable
            );
end INTEL2716;

Architecture Behavioral of INTEL2716 is
begin
    model : PROCESS

        ----------------------------------------------------------------------------
        -- timing data
        ----------------------------------------------------------------------------

        constant T_ACC : time := 450 ns;    -- address to output delay
        constant T_CE  : time := 450 ns;    -- ce_n to output delay
        constant T_OE  : time := 120 ns;    -- output enable to output delay
        constant T_DF  : time := 100 ns;    -- ce_n or oe_n high to output float
        constant T_OH  : time :=   0 ns;    -- output hold from address, ce_n, or
                                            -- oe_n whichever occurs first
        
        variable rom1 : mem_id_type;                            -- memory data structure pointer
        variable ce_n_internal : std_logic;                     -- holds current ce_n value
        variable oe_n_internal : std_logic;                     -- holds current oe_n value
        variable data_out : std_logic_vector (7 downto 0);      -- data to be output
        variable tf_ce_n : time := -T_CE;                       -- time that ce_n fell
        variable tf_oe_n : time := -T_OE;                       -- time that oe_n fell
        variable q_to_x : time;                     -- when reading time from change in address,
                                                    -- ce_n, or oe_n until Q goes to X
        variable q_to_valid : time;                 -- when reading time from change in address,
                                                    -- ce_n, or oe_n until Q gets valid data

                
    begin
        rom1 := ROM_INITIALIZE ( name =>            "ROM CHIP # 1",
                                 length =>          2048,
                                 width =>           8,
                                 default_word =>    std_logic_vector'(""),
                                 file_name =>       "rom1.dat"
                               );

        ce_n_internal := To_X01(CE_N);
        oe_n_internal := To_X01(OE_N);
        if (ce_n_internal = '0') or (oe_n_internal = '0') then
            Q <= (others => 'X');
        else
           Q <= (others => 'Z');
        end if;

        loop
            wait on A, CE_N, OE_N;   -- wait for a change to occur on A, CS_N, or OE_N

            -- convert control line to X01 format
            ce_n_internal := To_X01(CE_N); 
            oe_n_internal := To_X01(OE_N);

            -- determine when control lines fell
            if falling_edge(ce_n) then
                tf_ce_n := NOW;
            end if;
            if falling_edge(oe_n) then
                tf_oe_n := NOW;
            end if;

            
            if ( (ce_n_internal = '1') or (oe_n_internal = '1') ) then
                -- if both ce_N and oe_n are rising or one is low and the other is rising then
                -- the outputs should go into high Z state
                if (rising_edge(CE_N) and rising_edge(OE_N))
                   or (rising_edge(CE_N) and (oe_n_internal = '0'))
                   or (rising_edge(OE_N) and (ce_n_internal = '0')) then
                    Q <= transport (others => 'X') after T_OH, (others => 'Z') after T_DF;
                end if;
            elsif (ce_n_internal = '0') and (oe_n_internal = '0') then
                 -- ce_n low and oe_n low means that the memory is being read
                 q_to_x :=maximum(tf_ce_n+T_CE, tf_oe_n+T_OE) - NOW;  -- time from control lines 
                                                                      -- low to low impedance - NOW
                 q_to_valid := maximum( NOW + T_ACC - A'last_event,   -- time from now until valid
                                        tf_ce_n + T_CE,               -- data is output
                                        tf_oe_n + T_OE,
                                        time'low
                                      ) - NOW;
                 if (q_to_x >= 0 ns) and (q_to_x < q_to_valid) then   -- if control lines changed 
                     Q <= transport (others => 'X') after q_to_X;     -- then Q should go to X
                                                                      -- if q_to_x > 0 ns
                 elsif A'event then                                   -- otherwise if address
                                                                      -- if address changed then
                     Q <= transport (others => 'X') after T_OH;       -- Q gets X after T_OH
                 end if;                 
                 if q_to_valid >= 0 ns then                           -- if q_to_valid data > 0 
                     Mem_Read ( mem_id => rom1,                       -- then put data onto Q
                                address => A,                         -- after q_to_valid data
                                data => data_out
                              );
                     Q <= transport data_out after q_to_valid;
                 end if;
            end if;

        end loop;
    end process;
end Behavioral;
