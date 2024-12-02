-------------------------------------------------------------------------------
--                                     Developed by:
--                                     THE VHDL CONSULTING GROUP
--
-- File name   : i21010.vhdl
-- Title       : Model of INTEL 21010-06
-- Purpose     : To provide an example model of the Intel 21010-06 in order to
--               demonstrate how to use Std_Mempak to build memory models
--             :
-- Assumptions : none
-- Limitations : No checking of input wave forms
--               *****  This model is provided for demonstration purposes *****
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
--     v1.000   | wrm        |  12/02/91  | first version
--     v1.100   | wrm        |  01/15/92  | change Convert_To_??? to To_???
-- ----------------------------------------------------------------------------
        
----------------------------------------------------------------------
-- INTEL : 4Meg x 1 DRAM
----------------------------------------------------------------------

Library ieee;
Use     ieee.STD_Logic_1164.all; -- Reference the STD_Logic system
LIBRARY std_developerskit;
USE     std_developerskit.Std_Mempak.all;
use     std_developerskit.Std_IOpak.all;


Entity INTEL21010 is

    port    ( A     : IN std_logic_vector ( 9 downto 0 ); -- mux'd address
              RAS_N : IN std_logic; -- row address strobe
              CAS_N : IN std_logic; -- column address strobe
              WE_N  : IN std_logic; -- '1' = READ, '0' = WRITE
              Q     : OUT std_logic;
              D     : IN std_logic 
            );
end INTEL21010;

Architecture Behavioral of INTEL21010 is
begin
    -------------------------------------------------------------------
    -- Address : The address is determined by latching in the first 11
    -- bits using RAS.  The high order 11 bits of the address are then
    -- latched using CAS.
    -- WRITE CYCLE : D is latched on the falling edge of WE_N or CAS_N
    -- which ever occurs last.
    -------------------------------------------------------------------
    model : PROCESS 
        variable address : std_logic_vector ( 19 downto 0 );
        variable RAS_N_internal : std_logic;
        variable CAS_N_internal : std_logic;
        variable  WE_N_internal : std_logic;
        variable     A_internal : std_logic_vector ( 9 downto 0 );
        variable     D_internal : std_logic;
        variable     Data       : UX01;
        variable     tf_RAS     : time := -1.0 us;
        variable     tf_CAS     : time := -1.0 us;
        variable     tf_WE      : time := -1.0 us;
        variable     tr_RAS     : time := -1.0 us;
        variable     tr_CAS     : time := -1.0 us;
        variable t_addr         : time := -1.0 us;        
        variable     dram1      : mem_id_type;
        variable t_rcd, t_rac   : time;
        variable t_rad          : time;
        variable t_out_delay    : time;
        variable init_count     : integer := 0;

        constant t_off_max : time := 20 ns;     -- output buffer turnoff delay time
        constant t_clz_min : time := 0.0 ns;    -- cas to output in low z
        constant t_cac_max : time := 20 ns;     -- access time from cas
        constant t_aa_max  : time := 30 ns;     -- access time from column address
        constant t_rac_max : time := 60 ns;     -- access time from ras
        constant t_rcd_max : time := 40 ns;     -- ras to cas delay time
        constant t_rad_max : time := 30 ns;     -- ras to column address delay time
        constant t_t       : time := 5 ns;      -- transistion time
        constant t_cpa_max : time :=40.0 ns;    -- access time from cas precharge

        function maximum ( Constant a, b : IN time) return time is

        begin
            if (a > b) then
                return a;
            else
                return b;
            end if;
        end;
        
    begin
        dram1 := DRAM_INITIALIZE ( name =>            "DRAM CHIP # 1",
                                   rows =>            512,
                                   columns =>         2048,
                                   width =>           1,
                                   refresh_period =>  8.0 ms,
                                   default_word =>    std_logic_vector'("")
                                 );
        Q <= 'Z';
            

        loop
            wait on RAS_N, CAS_N, WE_N, A;
            --------------------------------------------------------------
            -- strip the strength
            --------------------------------------------------------------
            A_internal     := To_X01 ( A     );
            RAS_N_internal := To_X01 ( RAS_N );
            CAS_N_internal := To_X01 ( CAS_N );
            WE_N_internal  := To_X01 ( WE_N  );
            D_internal     := To_X01 ( D     );

            --------------------------------------------------------------
            -- Latch low address
            --------------------------------------------------------------
            if falling_edge ( RAS_N ) then
                address (19 downto 11) := A_internal(8 downto 0);
                address (10) := A_internal(9);
                tf_ras := NOW;
            end if;

            --------------------------------------------------------------
            -- if no cycle in last 8 ms device must be reinitialized with 8 cycles
            -- therefore initialization count must start at 0 again
            --------------------------------------------------------------                        

            if (tf_ras < (NOW - 8.0 ms)) then
               init_count := 0;
            end if;

            --------------------------------------------------------------
            -- Latch high address
            --------------------------------------------------------------
            if falling_edge ( CAS_N ) then
                address (9 downto 0) := A_internal;
                tf_cas := NOW;
            end if;

            --------------------------------------------------------------            
            -- record the time at which WE fell
            --------------------------------------------------------------            
            if falling_edge ( WE_N ) then
                tf_WE  := NOW;
            end if;

            --------------------------------------------------------------
            -- set output to 'Z'
            --------------------------------------------------------------
            if rising_edge ( CAS_N ) then
                tr_cas := NOW;                
                q <= 'Z' after t_off_max;
            end if;

            --------------------------------------------------------------
            -- record the time in when the address changed
            --------------------------------------------------------------
            if (A'event and (RAS_N_internal = '0')) then
                t_addr := NOW;
            end if;

            
            --------------------------------------------------------------
            -- ACCESS CYCLES
            --------------------------------------------------------------

            if (rising_edge(RAS_N) and (CAS_N_internal='1') and
               (tf_CAS < tf_RAS) and
               (tr_CAS < tf_RAS) ) then
                ----------------------------------------------------------
                -- RAS ONLY Refresh
                ----------------------------------------------------------
                Mem_Row_Refresh ( mem_id => dram1,
                                  row =>    address(19 downto 11)
                                );
                assert false report "ran Mem_Row_Refresh" severity NOTE;
            elsif ( falling_edge (RAS_N) and (CAS_N_internal = '0') ) then
                ----------------------------------------------------------
                -- CAS-BEFORE-RAS Refresh cycle  and hidden refresh
                ----------------------------------------------------------
                Mem_Refresh (mem_id => dram1);
                assert false report "ran Mem_Refresh" severity NOTE;
            elsif (RAS_N_internal = '0') then
                if    (WE_N_internal = '1') then
                    ------------------------------------------------------
                    -- Read Cycle : regular and page-mode
                    ------------------------------------------------------
                    t_rcd := tf_cas - tf_ras;
                    t_rad := t_addr - tf_ras;
                    t_rac := maximum (t_rcd - t_rcd_max, t_rad - t_rad_max);
                    if (t_rac > 0.0 fs) then
                        t_rac := t_rac_max + t_rac;
                    else
                       t_rac := t_rac_max;
                    end if;
                    if falling_edge (CAS_N) then
                        Mem_Read ( data =>    data,
                                   mem_id =>  dram1,
                                   address => address
                                 );
                        assert false report "ran Mem Read" severity NOTE;
                        Q <= transport '-' after t_clz_min;
                        if (t_rcd > t_rcd_max) then
                            t_out_delay := t_cac_max;
                        elsif (t_rad > t_rad_max) then
                             t_out_delay := t_aa_max - (tf_cas - t_addr);
                        else
                             t_out_delay := t_rac - (tf_cas - tf_ras);
                        end if;
                        t_out_delay := maximum (t_out_delay, t_cpa_max - (tf_cas - tr_cas));
                        Q <= transport data after t_out_delay; -- drive the data
                    end if;
                elsif (WE_N_internal = '0') then
                    ------------------------------------------------------
                    -- Write Cycle : regular and page mode
                    ------------------------------------------------------
                    -- determine whether WE or CAS had fallen first
                    -- If WE fall first, then Q remains at Z until the next CAS cycle
                    -- otherwise the data on Q remains
                    ------------------------------------------------------
                    if ( (CAS_N_internal = '0') and (RAS_N_internal = '0') and
                          ( falling_edge (CAS_N) or falling_edge(WE_N)) ) then
                      --  if (tf_WE < tf_CAS) then
                            -- early write                            
                      
                      --  else
                            -- then read-write-modify
                            NULL;
                      --  end if;
                        -- write data to memory;
                        Mem_Write ( mem_id =>  dram1,
                                    address => address,
                                    data =>    D_internal
                                  );
                        assert false report "ran Mem_Write" severity NOTE;
                    end if;
                end if;
            end if;
            
            --------------------------------------------------------------
            -- wake up memory and increment wake up count
            --------------------------------------------------------------

            if ( rising_edge(RAS_N) and (tf_ras > 0.0 fs) ) then
               init_count := (init_count + 1) mod 8;
               if init_count = 0 then
                  Mem_Wake_Up(mem_id => dram1);
                  assert false report "ran Mem_Wake_UP" severity NOTE;
               end if;
            end if;
            
        end loop;
    end process;
end Behavioral;





