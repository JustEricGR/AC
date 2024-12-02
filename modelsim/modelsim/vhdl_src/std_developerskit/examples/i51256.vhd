-------------------------------------------------------------------------------
--                                     Developed by:
--                                     THE VHDL CONSULTING GROUP
--
-- File name   : i51256.v110
-- Title       : Model of INTEL 51256S/L-07
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
--     v1.110   | wrm        |  01/29/92  | first version
-- ----------------------------------------------------------------------------
        
----------------------------------------------------------------------
-- INTEL : 32K X 8 SRAM
----------------------------------------------------------------------

Library ieee;
Use     ieee.STD_Logic_1164.all; -- Reference the STD_Logic system
LIBRARY std_developerskit;
USE     std_developerskit.Std_Mempak.all;
use     std_developerskit.Std_IOpak.all;
use     std_developerskit.Std_Timing.all;


Entity INTEL51256SL is

    port    ( A     : IN    std_logic_vector ( 14 downto 0 ); -- address
              DQ    : INOUT std_logic_vector ( 7 downto 0);   -- input/output data
              CS_N  : IN    std_logic;                        -- chip select
              WE_N  : IN    std_logic;                        -- '1' = READ, '0' = WRITE
              OE_N  : IN    std_logic                         -- output enable
            );
end INTEL51256SL;

Architecture Behavioral of INTEL51256SL is
begin
    model : PROCESS
        constant SPACESTR : string(1 to 12) := "            ";

        ----------------------------------------------------------------------------
        -- timing data
        ---------------------------------------------------------------------------- 
        constant T_AA  : time := 70.0 ns;                  -- address access time
        constant T_ACS : time := 70.0 ns;                  -- chip select access time
        constant T_OH  : time := 10.0 ns;                  -- output hold from address change
        constant T_CLZ : time :=  5.0 ns;                  -- chip select to output in low Z
        constant T_CHZ : time := 35.0 ns;                  -- chip deslect to output in high Z
        constant T_OE  : time := 40.0 ns;                  -- output enable access time
        constant T_OLZ : time :=  5.0 ns;                  -- output enable to output in low Z
        constant T_OHZ : time := 35.0 ns;                  -- output enable to output in high Z

        constant T_CW  : time := 45.0 ns;                  -- chip select to end of write
        constant T_AW  : time := 65.0 ns;                  -- address valid to end of write
        constant T_WP  : time := 45.0 ns;                  -- write pulse width
        constant T_WR  : time :=  5.0 ns;                  -- write recovery time
        constant T_DW  : time := 30.0 ns;                  -- data valid to end of write
        constant T_DH  : time := 0.0 ns;                   -- data hold time
        constant T_WHZ : time := 40.0 ns;                  -- write enable to output in high Z
        constant T_OW  : time :=  5.0 ns;                  -- output active from end of write
        
        variable sram1 : mem_id_type;                           -- memory data structure pointer
        variable cs_n_internal : std_logic;                     -- holds current cs_n value
        variable we_n_internal : std_logic;                     -- holds current we_n value
        variable oe_n_internal : std_logic;                     -- holds current oe_n value
        variable latch_addr : std_logic_vector (14 downto 0);   -- holds address to be written to
        variable latch_data : std_logic_vector (7 downto 0);    -- holds data to be written
        variable t_delay, t2_delay : time;
        variable data_out : std_logic_vector (7 downto 0);      -- data to be output
        variable tf_we_n : time := 0.0 ns;                      -- time we_n fell
        variable tf_cs_n : time := 0.0 ns;                      -- time cs_n fell
        variable write_end : time := -T_WR;                     -- time write occurred
        variable dq_event : time := 0.0 ns;                     -- time of last event on DQ
        variable dq_last_event : time := 0.0 ns;                -- time of previous event on DQ
        variable dq_change : time;                              -- time data to be written was
                                                                -- placed on DQ
        variable we_n_cntrld : boolean := FALSE;                -- true if we_n cntrld write cycle
        variable cs_n_cntrld : boolean := FALSE;                -- true of cs_n cntrld write cycle

                
    begin
        sram1 := SRAM_INITIALIZE ( name =>            "SRAM CHIP # 1",
                                   length =>          32768,
                                   width =>           8,
                                   default_word =>    std_logic_vector'("")
                                 );

        -- initialize output to either high impedance state or  'X'
        cs_n_internal := To_X01(CS_N);
        we_n_internal := To_X01(WE_N);
        oe_n_internal := To_X01(OE_N);
        if ( (cs_n_internal = '0') and (we_n_internal = '1') and (oe_n_internal = '0') ) then
            DQ <= (others => 'X');
        else
            DQ <= (others => 'Z');
        end if;

        loop
            wait on A, CS_N, WE_N, OE_N;   -- wait for a change to occur on A, CS_N, WE_N, or OE_N

            -- convert control line to X01 format
            cs_n_internal := To_X01(CS_N); 
            we_n_internal := To_X01(WE_N);
            oe_n_internal := To_X01(OE_N);

            -- keep track of when we_n or cs_n fell
            if falling_edge(we_n) then
                tf_we_n := NOW;
            end if;
            if falling_edge(cs_n) then
                tf_cs_n := NOW;
            end if;

            -- keep track of the time of the last 2 events on DQ
            if dq'event then
               dq_last_event := dq_event;
               dq_event := NOW;
            end if;

            -- checks timing errors on input to device
            assert NOT (A'event and we_n_internal = '0')
                report "INTEL 51256S/L-07 ERROR:  Address changed while WE_N was low"
                severity ERROR;

            assert NOT (A'event and ( (NOW - write_end) < T_WR) )
                report "INTEL 51256S/L-07 ERROR:  Address changed before end of write "
                       & "recovery time"
                 severity ERROR;

            assert NOT (falling_edge(oe_n) and ( (NOW - write_end) < T_WR) )
                report "INTEL 51256S/L-07 ERROR:  oe_n fell befor end of write recovery time"
                severity ERROR;
                 
            if (cs_n_internal = '0') and falling_edge(we_n) then
                -- start of we_n controlled write
                -- DQ will go to Z and current address will be latched
                -- if cs_n is also falling then it may be a cs_n controlled write
                we_n_cntrld := TRUE;
                if falling_edge(cs_n) then
                    cs_n_cntrld := TRUE;
                end if;
                latch_addr := A;
                if oe_n_internal = '0' then
                    DQ <= transport (others => 'Z') after T_WHZ;
                end if;
            elsif ( (cs_n_internal = '0') or rising_edge(cs_n) )
                                                   and rising_edge(we_n) and we_n_cntrld then
                -- end of we_n controlled write
                -- write data and check for timing errors on input lines
                -- at end of write data that was written will be output if oe_n is low
                write_end := NOW;
                assert NOT ( (NOW - tf_we_n) < T_WP)
                    report "INTEL 51256S/L-07 ERROR:  Minimum pulse width of we_n during"
                           & LF & SPACESTR & "a write has been violated"
                    severity ERROR;
                assert (A'last_event >= T_AW)
                    report "INTEL 51256S/L-07 ERROR:  Address not valid to end of write"
                    severity ERROR;
                
                if DQ'event then
                    dq_change := dq_last_event;
                else
                    dq_change := dq_event;
                end if;
                assert ( (NOW - dq_change) >= T_DW )
                    report "INTEL 51256S/L-07 ERROR:  Data hold time for write violated"
                    severity ERROR;
                    
                if DQ'event then
                    latch_data := DQ'last_value;
                else
                    latch_data := DQ;
                end if;
                Mem_Write ( mem_id => sram1,
                            address => latch_addr,
                            data => latch_data
                          );
                cs_n_cntrld := FALSE;
                we_n_cntrld := FALSE;
                if oe_n_internal = '0' then
                     DQ <= latch_data after T_OW;
                end if;
            elsif (we_n_internal = '0') and falling_edge(cs_n) then
                -- start of cs_n controlled write
                -- latch current address
                -- if we_n is falling it may also be a we_n controlled write       
                latch_addr := A;
                cs_n_cntrld := TRUE;
                if falling_edge(we_n) then
                    we_n_cntrld := TRUE;
                end if;
            elsif ( (we_n_internal = '0') or rising_edge(we_n) )
                                                    and rising_edge (cs_n) and cs_n_cntrld then
                -- end of cs_n controlled write
                -- write data an dcheck for timing errors on input lines
                write_end := NOW;
                assert NOT ( (NOW - tf_cs_n) < T_CW)
                    report "INTEL 51256S/L-07 ERROR:  Minimum pulse width of cs_n during"
                           & LF & SPACESTR & "a write has been violated"
                    severity ERROR;
                assert (A'last_event >= T_AW)
                    report "INTEL 51256S/L-07 ERROR:  Address not valid to end of write"
                    severity ERROR;

                if DQ'event then
                    dq_change := dq_last_event;
                else
                    dq_change := dq_event;
                end if;
                assert ( (NOW - dq_change) >= T_DW )
                    report "INTEL 51256S/L-07 ERROR:  Data hold time for write violated"
                    severity ERROR;
                    
                if DQ'event then
                    latch_data := DQ'last_value;
                else
                    latch_data := DQ;
                end if;
                Mem_Write ( mem_id => sram1,
                            address => latch_addr,
                            data => latch_data
                          );
                cs_n_cntrld := FALSE;
                we_n_cntrld := FALSE;
            elsif (cs_n_internal = '1') or ( (oe_n_internal = '1') and (we_n_internal = '1') ) then
                -- no operation being performed
                -- output should go to high Z state
                t_delay := time'high;
                if cs_n'event then
                    t_delay := minimum(t_delay, T_CHZ);
                end if;
                if oe_n'event then
                    t_delay := minimum(t_delay, T_OHZ);
                end if;
                if we_n'event then
                    t_delay := minimum(t_delay, T_WHZ);
                end if;
                if cs_n'event or oe_n'event or we_n'event then
                    DQ <= transport (others => 'Z') after t_delay;
                end if;
            elsif (cs_n_internal = '0') and (oe_n_internal = '0') and (we_n_internal = '1') then
                -- read operation
                t_delay := time'low;
                -- wait maximum amount of time between chip enable low and output enable low
                -- before setting dq to X's.  This takes priority over address changes
                t_delay := maximum(t_delay, T_CLZ - cs_n'last_event);
                t_delay := maximum(t_delay, T_OLZ - oe_n'last_event);
                if (t_delay >= 0.0 ns) and (cs_n'event or oe_n'event or A'event or we_n'event) then
                    DQ <= transport (others => 'X') after t_delay;
                end if;
                t2_delay := T_OH - A'last_event;
                if (t2_delay >= 0.0 ns) and (t2_delay > t_delay)
                   and (cs_n'event or oe_n'event or A'event or we_n'event) then
                    DQ <= transport (others => 'X') after t2_delay;
                end if;
                t_delay := time'low;
                t_delay := maximum(t_delay, T_ACS - cs_n'last_event);
                t_delay := maximum(t_delay, T_OE - oe_n'last_event);
                t_delay := maximum(t_delay, T_AA - A'last_event);
                if (t_delay >= 0.0 ns) and (cs_n'event or oe_n'event or A'event or we_n'event) then
                    Mem_Read( mem_id => sram1,
                              address => A,
                              data => data_out
                            );
                    DQ <= transport data_out after t_delay;
                end if;
            end if;
        end loop;
    end process;
end Behavioral;
