--*- mode: fundamental; tab-width: 4; indent-tabs-mode: nil -*-
--
--------------------------------------------------------------------------
-- ModelSim Standard Checker Library Version 1.0
-- $Revision: #1 $
--
-- Copyright 2005-2009 Mentor Graphics Corporation
--
-- This source file may be used and distributed without restriction 
-- provided that this copyright statement is not removed from the file 
-- and that any derivative work contains this copyright notice.  
--
-- The source file is provided "AS IS" and Mentor Graphics makes 
-- NO WARRANTY, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
-- ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR 
-- PURPOSE, with respect to the source file or the use thereof.
--                                                                      
--	Name: vhdl_psl_checkers (ModelSim Standard Checker Library in PSL/VHDL)	
--								
--	Purpose: 						
--      Implements numerous predefined automated design checkers using assertion
--      based verification and functional coverage techniques.
--------------------------------------------------------------------------
-- Entity/architecture pairs for ModelSim Standard Checker Library in
-- PSL/VHDL.  See vhdl_psl_checkers_pkg.vhd for interface documentation.  Properties,
-- assertions, and any additional VHDL logic are defined in vhdl_psl_checkers.psl.
---------------------------------------------------------------------------

------------------------------------------------------------------------------  
-- arbiter
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_arbiter IS

  GENERIC (
    coverage_level : integer := 2;        -- sets checking intensity
    width : integer;                      -- number of grants/requests
    scheme : mc_arbiter_type);            -- arbitration scheme
  PORT (
    clk, reset : IN std_ulogic;
    req : IN std_logic_vector(0 to (width-1));    -- request bits
    grant : IN std_logic_vector(0 to (width-1))); -- grant bits

END;

ARCHITECTURE psl OF mc_arbiter IS
BEGIN
END;


------------------------------------------------------------------------------  
-- assert_period
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_assert_period IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    min : integer;                    -- minimum assertion time
    max : integer;                    -- maximum assertion time
    must_deassert : boolean);         -- require de-assertion after window
  PORT (
    clk, reset : IN std_ulogic;
    sig : IN std_ulogic;              -- signal whose assertion is checked
    enable : IN std_ulogic);          -- enable for check, active high

END;

ARCHITECTURE psl OF mc_assert_period IS
BEGIN
END;


------------------------------------------------------------------------------  
-- asserted
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_asserted IS

  GENERIC (
    coverage_level : integer := 2);   -- sets checking intensity
  PORT (
    clk, reset : IN std_ulogic;
    sig : IN std_ulogic;              -- signal whose assertion is checked
    enable : IN std_ulogic := '1');   -- enable for check, active high

END;

ARCHITECTURE psl OF mc_asserted IS
BEGIN
END;


------------------------------------------------------------------------------
-- bits_on
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_bits_on IS
  
  GENERIC (
    coverage_level : integer := 2;      -- sets checking intensity
    width : integer;                    -- width of reg
    min : integer;                      -- minimum number of bits on
    max : integer);                     -- maximum number of bits on,
                                        -- if max is 0, must be exactly min bits
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));

END;

ARCHITECTURE psl OF mc_bits_on IS
BEGIN
END;


------------------------------------------------------------------------------  
-- change_window
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_change_window IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    in_width : integer;               -- width of in vector
    in_change : boolean := true;      -- in_vec must change inside window?
    out_width : integer;              -- width of out vector
    out_change : boolean := true);    -- out_vec must change outside window?
  PORT (
    clk, reset : IN std_ulogic;
    in_vec : IN std_logic_vector((in_width-1) DOWNTO 0);    -- checked inside
    out_vec : IN std_logic_vector((out_width-1) DOWNTO 0);  -- checked outside
    start : IN std_ulogic;                      -- start of window
    stop : IN std_ulogic);                      -- end of window

END;

ARCHITECTURE psl OF mc_change_window IS
BEGIN
END;


------------------------------------------------------------------------------  
-- change_window1
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_change_window1 IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    in_change : boolean := true;      -- in_vec must change inside window?
    out_change : boolean := true);    -- out_vec must change outside window?
  PORT (
    clk, reset : IN std_ulogic;
    input : IN std_ulogic;            -- checked inside window
    output : IN std_ulogic;           -- checked inside window
    start : IN std_ulogic;            -- start of window
    stop : IN std_ulogic);            -- end of window

END;

ARCHITECTURE psl OF mc_change_window1 IS
BEGIN
END;


------------------------------------------------------------------------------
-- decrement
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_decrement IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;
    min_time : positive := 1;
    max_time : positive := 1;
    min_decr : positive := 1;
    max_decr : positive := 1);
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN unsigned((width-1) DOWNTO 0);
    enable : IN std_ulogic);      

END;

ARCHITECTURE psl OF mc_decrement IS 
BEGIN
END;


------------------------------------------------------------------------------
-- delta
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_delta IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;
    min_time : positive := 1;
    max_time : positive := 1;
    min_delta : positive := 1;
    max_delta : positive := 1);
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN unsigned((width-1) DOWNTO 0);
    enable : IN std_ulogic);      

END;

ARCHITECTURE psl OF mc_delta IS 
BEGIN
END;


------------------------------------------------------------------------------
-- fifo
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_fifo IS
  GENERIC (
    coverage_level : integer := 2;      -- sets checking intensity
    width : positive;                   -- width of data vectors
    depth : positive;                   -- # elements in FIFO
    rw_type : mc_rw_type := mc_rw_error;  -- simultaneous r/w?
    check_values : boolean := false);   -- model FIFO and check values
  PORT (
    clk, reset : IN std_ulogic;
    enqueue : IN std_ulogic;            -- write enable
    dequeue : IN std_ulogic;            -- read enable
    -- 
    -- These are needed if "check_values = true":
    --
    enqueue_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0');
    dequeue_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0'));
END ENTITY;

ARCHITECTURE psl OF mc_fifo IS 
BEGIN
END;


----------------------------------------------------------------------------
-- follows
----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_follows IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    min : natural;                    -- min cycles to follow
    max : natural;                    -- max cycles to follow
    hold_leader : boolean := false);  -- leader must hold?
  PORT (
    clk, reset : IN std_ulogic;
    leader : IN std_ulogic;
    follower : IN std_ulogic);      
END ENTITY;

ARCHITECTURE psl OF mc_follows IS
BEGIN
END;


------------------------------------------------------------------------------
-- gray_code
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_gray_code IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer);                 -- Width of register/vector
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));

END;

ARCHITECTURE psl OF mc_gray_code IS
BEGIN
END;


------------------------------------------------------------------------------
-- hamming_distance
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_hamming_dist IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- width of reg
    distance : integer);              -- number of bits that can change
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));

END;

ARCHITECTURE psl OF mc_hamming_dist IS
BEGIN
END;


------------------------------------------------------------------------------
-- hold_period
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_hold_period IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    min : positive;                   -- min cycles to hold
    max : positive;                   -- max cycles to hold
    change : boolean := false);       -- must de-assert after holding?
  PORT (
    clk, reset : IN std_ulogic;
    sig : IN std_ulogic;              -- signal to check
    enable : IN std_ulogic := '1');   -- enable for check

END;

ARCHITECTURE psl OF mc_hold_period IS
BEGIN
END;

------------------------------------------------------------------------------
-- increment
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_increment IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;
    min_time : positive := 1;
    max_time : positive := 1;
    min_incr : positive := 1;
    max_incr : positive := 1);
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN unsigned((width-1) DOWNTO 0);
    enable : IN std_ulogic);      

END;

ARCHITECTURE psl OF mc_increment IS 
BEGIN
END;

------------------------------------------------------------------------------
-- memory
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_memory IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- width of the memory
    start_addr : natural := 0;        -- start address of memory
    memory_size : positive;           -- number of words in memory
    precious_data : boolean := false; -- precious data check (see above)
    volatile_data : boolean := false; -- volatile data check (see above)            
    check_values : boolean := false); -- check data output value?
  PORT (
    clk, reset : IN std_ulogic;
    enable : IN std_ulogic;                   -- enable read/write
    RW : IN std_ulogic;                       -- '1' write, '0' read
    addr : IN natural;                        -- address as integer
    --
    -- Used in case of "check_values = true", otherwise ignored:
    -- 
    data_in : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0');
    data_out : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0'));
END;

ARCHITECTURE psl OF mc_memory IS
BEGIN
END;


------------------------------------------------------------------------------
-- one_cold
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_one_cold IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- Width of reg
    strict  : boolean := true);       -- true ==> never 0 bits de-asserted
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));
END;

ARCHITECTURE psl OF mc_one_cold IS
BEGIN
END;
  

------------------------------------------------------------------------------
-- one_hot
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_one_hot IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- Width of reg
    strict  : boolean := true);       -- true ==> never 0 bits asserted
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));
END;

ARCHITECTURE psl OF mc_one_hot IS
BEGIN
END;
  

------------------------------------------------------------------------------
-- parity
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_parity IS
  
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- Width of register
    even  : boolean);                 -- true ==> even parity; false ==> odd
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0));

END;

ARCHITECTURE psl OF mc_parity IS
BEGIN
END;


------------------------------------------------------------------------------
-- precious_data
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_precious_data IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- Width of reg
    src_change : mc_edge_type := mc_edge_any;
                 -- mc_edge_any ==> any change in src starts
                 -- mc_edge_gated ==> rising edge of "src_loaded"
    start_count : natural;            -- cycles from src_change to open of
                                      -- precious data window
    stop_type : mc_window_type := mc_window_gated;  -- what stops?
                -- mc_window_count ==> use "stop_count" for window
                -- mc_window_gated ==> use "stop_signal" for window
    stop_count : integer);            -- # cycles in precious data window
                 -- stop_count < 0 ==> use stop_signal instead of cycle count
  PORT (
    clk, reset : IN std_ulogic;
    src : IN std_logic_vector((width-1) DOWNTO 0);    -- source register
    dest : IN std_logic_vector((width-1) DOWNTO 0);   -- destination register
    src_loaded : IN std_ulogic;       -- valid data in source register
                 -- ignored if src_change = mc_edge_any
    stop_signal : IN std_ulogic);     -- valid data in destination register
                  -- ignored if stop_type = mc_window_gated
END;

ARCHITECTURE psl OF mc_precious_data IS
BEGIN
END;


------------------------------------------------------------------------------
-- range
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_range IS

  GENERIC (
    coverage_level : integer := 2;            -- sets checking intensity
    width : integer;                          -- Width of reg
    min : natural;                            -- minimum value
    max : natural);                           -- maximum value
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN unsigned((width-1) DOWNTO 0);    -- Register to check
    min_valid : IN std_ulogic;                -- check for min
    max_valid : IN std_ulogic);               -- check for max

END;

ARCHITECTURE psl OF mc_range IS
BEGIN
END;
  

------------------------------------------------------------------------------
-- reg_loaded
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_reg_loaded IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    width : integer;                  -- Width of reg
    start_count : natural;            -- cycles from "start" to open of
                                      -- window
    stop_type : mc_window_type;   -- what stops (closes) the window?
                -- mc_window_count ==> use "stop_count" for window
                -- mc_window_gated ==> use "stop_signal" for window
    stop_count : natural := 1);       -- # cycles in window
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0);    -- register to check
    start : IN std_ulogic;            -- start checking for open window
    stop : IN std_ulogic);            -- (optionally) close window
           -- ignored if stop_type = mc_window_gated

END;

ARCHITECTURE psl OF mc_reg_loaded IS
BEGIN
END;


----------------------------------------------------------------------------
-- rx_backup
----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_rx_backup IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    min : natural;                    -- min cycles to follow
    max : natural);                   -- max cycles to follow
  PORT (
    clk, reset : IN std_ulogic;
    rx_full : IN std_ulogic;          -- tested for rising edge
    xmit_ready : IN std_ulogic);      -- tested for level '0'
END ENTITY;

ARCHITECTURE psl OF mc_rx_backup IS
BEGIN
END;


----------------------------------------------------------------------------
-- scoreboard
----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_scoreboard IS
  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    min_id : natural;                 -- minimum allowable id
    max_id : natural;                 -- maximum allowable id
    max_outstanding: positive);       -- maximum number of ids that can be
                                      -- issued but not received
  PORT (
    clk, reset : IN std_ulogic;
    issue_id : IN natural;            -- id issued by the scoreboard
    issue_en : IN std_ulogic;         -- when '1', issue the issue_id
    rx_id : IN natural;               -- id received by the scoreboard
    rx_en : IN std_ulogic);           -- when '1', receive the rx_id
END ENTITY;

ARCHITECTURE psl OF mc_scoreboard IS
BEGIN
END;


------------------------------------------------------------------------------
-- sequence
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_sequence IS
  
  GENERIC (
    coverage_level : integer := 2;  -- sets checking intensity
    width : positive;               -- width of reg
    length : positive;              -- number of values in sequence
    min_change_time : positive;     -- minimum time between changes in sequence
    max_change_time : positive);    -- maximum time between changes
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0);   -- Register to check
    expected : IN mc_2dim_array (0 TO (length-1),(width-1) DOWNTO 0);
    sequence_start : IN std_ulogic);    -- start of sequence

END;

ARCHITECTURE psl OF mc_sequence IS
BEGIN
END;


------------------------------------------------------------------------------
-- stack
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_stack IS
  GENERIC (
    coverage_level : integer := 2;      -- sets checking intensity
    width : positive;                   -- width of data vectors
    depth : positive;                   -- # elements in stack
    check_values : boolean := false);   -- model stack and check values
  PORT (
    clk, reset : IN std_ulogic;
    push : IN std_ulogic;            -- write enable
    pop : IN std_ulogic;            -- read enable
    -- 
    -- These are needed if "check_values = true":
    --
    push_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0');
    pop_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0'));
END ENTITY;

ARCHITECTURE psl OF mc_stack IS 
BEGIN
END;


------------------------------------------------------------------------------
-- transition
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_transition IS
  
  GENERIC (
    coverage_level : integer := 2;     -- sets checking intensity
    width : positive;                  -- width of reg
    length : positive);                -- number of expected values
  PORT (
    clk, reset : IN std_ulogic;
    reg : IN std_logic_vector((width-1) DOWNTO 0);   -- Register for check
    expected : IN mc_2dim_array (0 TO (length-1),(width-1) DOWNTO 0));

END;

ARCHITECTURE psl OF mc_transition IS
BEGIN
END;


------------------------------------------------------------------------------  
-- window
------------------------------------------------------------------------------  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

LIBRARY vhdl_psl_checkers;
USE vhdl_psl_checkers.vhdl_psl_checkers.ALL;

ENTITY mc_window IS

  GENERIC (
    coverage_level : integer := 2;    -- sets checking intensity
    in_width : integer;               -- width of in vector
    hold_in : boolean := true;        -- in_vec must assert in window?
    out_width : integer;              -- width of out vector
    hold_out : boolean := false);     -- out_vec must assert out of window?
  PORT (
    clk, reset : IN std_ulogic;
    in_vec : IN std_logic_vector((in_width-1) DOWNTO 0); -- checked inside
    out_vec : IN std_logic_vector((out_width-1) DOWNTO 0); -- checked outside
    start : IN std_ulogic;                          -- start of window
    stop : IN std_ulogic);                          -- end of window

END;

ARCHITECTURE psl OF mc_window IS
BEGIN
END;
