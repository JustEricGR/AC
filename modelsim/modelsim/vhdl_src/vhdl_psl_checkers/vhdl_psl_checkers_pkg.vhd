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
--							
--
-- -----------------------------------------------------------------------------
-- Package "vhdl_psl_checkers" defining ModelSim Standard Checker Library in PSL/VHDL.
-- -----------------------------------------------------------------------------
--
-- Available checkers in package "vhdl_psl_checkers" are:
--
--   mc_arbiter        logical check for various arbitration schemes
--   mc_assert_period  a signal is asserted, possibly de-asserted, within a
--                     certain window
--   mc_asserted       enabled synchronous check that a signal is asserted
--   mc_bits_on        min-max bits asserted in a register
--   mc_change_window  vectors are checked for changes or not in a
--                     signal-bound window
--   mc_change_window1 scalar version of the above
--   mc_decrement      enabled check that a register decrements by a
--                     min-max amount every min-max cycles
--   mc_delta          enabled check that a register changes by min-max
--                     amount every min-max cycles
--   mc_fifo           checks overflow/underflow of a FIFO, with optional
--                     read/write value check
--   mc_follows        assertion of one signal follows another
--   mc_gray_code      register changes by 1 and only 1 bit each time
--   mc_hamming_dist   register changes by N bits each time
--   mc_hold_period    register holds value for min-max cycles, optionally
--                     must de-assert
--   mc_increment      enabled check that a register increments by a
--                     min-max amount every min-max cycles
--   mc_memory         check memory address, uninitialized read, optional
--                     checks: value check, overwrite, precious data
--   mc_one_hot        check that 1 bit is asserted in a register
--   mc_one_cold       check that 1 bit is de-asserted in a register
--   mc_parity         parity of a register, even/odd selectable
--   mc_precious_data  source value appears in destination register during
--                     a window of time
--   mc_range          a register value falls in a min-max range
--   mc_reg_loaded     check that register is loaded in a time window
--   mc_rx_backup      when a "full" signal is asserted, check that a
--                     "transmit" signal is de-asserted
--   mc_scoreboard     temporal/logical check for ids issued and received
--                     by a scoreboard
--   mc_sequence       temporal/logical check for register values in
--                     sequence
--   mc_stack          checks overflow/underflow of a stack, with optional
--                     value check
--   mc_transition     checks that a register only transitions to a given
--                     set of values
--   mc_window         vectors are checked for assertion or not in a
--                     signal-bound window
--
-- General characteristics of all checkers:
-- 
--   Clocking
--
--   All checker properties are evaluated at the rising edge of clock.  Each
--   checker component takes a "clk" input as the clock.  When documentation
--   refers to "every cycle", that is construed as every rising edge of clock
--   at which reset (see below) is not asserted.
--
--   Reset
--
--   All checkers take an ACTIVE HIGH reset input (called "reset") which
--   aborts any in-progress checking and induces any reset behavior specific
--   to the checker (see documentation below for any checker-specific reset
--   behavior.)  Some checkers are best-behaved when reset is asserted at the
--   beginning of simulation.  Note that no checker will assert while reset is
--   high.
--



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Numeric_Std.ALL;

------------------------------------------------------------------------------
-- Package Declaration: mtichk
------------------------------------------------------------------------------

PACKAGE vhdl_psl_checkers IS

  --
  -- This type is used in some of the checkers when needing a 2-dimensional
  -- array, with one dimension being effectively a std_logic_vector.
  -- 
  TYPE mc_2dim_array
      IS ARRAY (integer RANGE <>, integer RANGE <>) OF std_logic;

  CONSTANT dont_allow_zero_length_seq : boolean := false;
  CONSTANT do_allow_zero_length_seq : boolean := true;

  ----------------------------------------------------------------------------  
  -- arbiter
  --
  -- Checks that different arbitration schemes are held faithfully in an
  -- arbiter.
  --
  -- Interface
  --
  -- A request bit must be held high until the corresponding grant bit is
  -- asserted, after which the request must be de-asserted.  When PSL
  -- replicated properties are supported in ModelSim, this checker will provide
  -- a parameterized temporal check to verify the correctness and timing of the
  -- sequence: assert request bit, eventually assert grant bit, de-assert
  -- request bit within some number of cycles, change grant on next cycle.
  --
  -- Single Grant
  --
  -- Currently only a single grant may be asserted.
  --
  -- Grant Timing
  --
  -- If no grant is asserted, and a request is asserted, the grant is assumed
  -- to respond to the request in one cycle.  Once asserted, the grant cannot
  -- change until after the request is de-asserted.  When a grant is asserted
  -- on cycle t, it must be consistent with the state of requests on cycle t-1.
  --
  -- Priority Arbitration Scheme
  --   scheme = MC_ARBITER_PRIORITY_SCHEME
  -- 
  --   In a priority scheme, access is granted based on priority, where bit 0
  --   is higher priority than bit 1.  For a grant on cycle t, the grant bit
  --   must be less than any bit on cycle t-1 that was requested but not
  --   granted on cycle t.
  -- 
  -- FIFO Arbitration Scheme
  --   scheme = MC_ARBITER_FIFO_SCHEME
  --
  --   In a FIFO scheme, access is granted based on order of assertion, first
  --   request granted first.  If two or more request bits are asserted on the
  --   same cycle, they are considered in order of priority (where bit 0 is
  --   higher priority and therefore granted earlier than bit 1.)  The checker
  --   maintains a fifo of requests: it enqueues values on rising edge of req,
  --   dequeues them on rising edge of grant.  The check then requires that the
  --   rising edge of grant for a bit number be the same bit number as the
  --   value about to be dequeued from the FIFO.
  --
  --   IMPORTANT NOTE: the state of the checker's own FIFO may be unreliable if
  --   there are violations of the arbitration scheme or of the request/grant
  --   sequence.  (For example, repeatedly asserting and de-asserting a request
  --   with no grant would eventually overflow the FIFO.)
  --   
  -- Fairness Arbitration Scheme
  --   scheme = MC_ARBITER_FAIRNESS_SCHEME
  --
  --   In a fairness scheme, access is granted based on which of currently
  --   outstanding, ungranted requests have been least recently granted.  This
  --   is like an LRU (least recently used) algorithm in software.  The checker
  --   maintains a queue of grants.  When a grant is asserted, if its bit
  --   number was already present in the queue, it is removed, then put at the
  --   front of the queue.  The check is that if the grant was already present
  --   in the queue, there was no outstanding ungranted request whose bit
  --   number lay further back (less recently used) in the queue.
  --
  --   NOTE: any bit that has never been granted takes priority over a bit that
  --   has been previously granted.  When two or more bits that have never been
  --   granted are requested simultaneously, the bits must be granted in
  --   priority order -- where, for example, bit 0 takes higher priority over
  --   bit 1.
  --
  -- Reset
  --
  -- This checker requires that reset be asserted at the beginning of
  -- simulation.
  -- 
  -- Assertions
  --
  -- mc_arbiter_single_grant  asserts if there is more than 1 grant at any
  --                          time
  -- mc_arbiter_priority      for scheme = MC_ARBITER_PRIORITY_SCHEME, asserts
  --                          if priority arbitration scheme is violated
  -- mc_arbiter_fifo          for scheme = MC_ARBITER_FIFO_SCHEME, asserts
  --                          if fifo arbitration scheme is violated
  -- mc_arbiter_fairness      for scheme = MC_ARBITER_FAIRNESS_SCHEME, asserts
  --                          if fairness arbitration scheme is violated
  --
  ----------------------------------------------------------------------------
  TYPE mc_arbiter_type IS ( MC_ARBITER_FIFO_SCHEME, MC_ARBITER_PRIORITY_SCHEME,
                            MC_ARBITER_FAIRNESS_SCHEME );

  COMPONENT mc_arbiter
    GENERIC (
      coverage_level : integer := 2;        -- sets checking intensity
      width : integer;                      -- number of grants/requests
      scheme : mc_arbiter_type);            -- arbitration scheme
    PORT (
      clk, reset : IN std_ulogic;
      req : IN std_logic_vector(0 to (width-1));    -- request bits
      grant : IN std_logic_vector(0 to (width-1))); -- grant bits
  END COMPONENT;


  ----------------------------------------------------------------------------  
  -- assert_period
  --
  -- Checks that "sig" is asserted for "min" to "max" cycles.  If "max" is 0,
  -- then "sig" must be asserted for exactly "min" cycles.  With the option
  -- "must_deassert", the signal must be de-asserted at the end of the window.
  --
  -- The check is enabled by "enable" equal to '1'.  The "enable" is
  -- level-sensitive, but the check is activated by a rising edge on "sig".
  -- As always, the check is disabled when "reset" is '1'.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_assert_period
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      min : integer;                    -- minimum assertion time
      max : integer;                    -- maximum assertion time
      must_deassert : boolean);         -- require de-assertion after window
    PORT (
      clk, reset : IN std_ulogic;
      sig : IN std_ulogic;              -- signal whose assertion is checked
      enable : IN std_ulogic);          -- enable for check, active high
  END COMPONENT;
  

  ----------------------------------------------------------------------------  
  -- asserted
  --
  -- Checks that "sig" is asserted (every cycle), enabled by active-high
  -- "enable", also disabled by "reset" = '1'.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_asserted
    GENERIC (
      coverage_level : integer := 2);   -- sets checking intensity
    PORT (
      clk, reset : IN std_ulogic;
      sig : IN std_ulogic;              -- signal whose assertion is checked
      enable : IN std_ulogic := '1');   -- enable for check, active high
  END COMPONENT;
  

  ----------------------------------------------------------------------------
  -- bits_on
  --
  -- Checks that a register has "min" to "max" bits on.  Checks for exactly
  -- "min" bits if the "max" value is 0.
  --
  -- This check is made every cycle, so if a register changes to be in
  -- violation of the check and remains unchanged for several cycles, the
  -- checker will assert on all of those cycles.
  ----------------------------------------------------------------------------
  COMPONENT mc_bits_on
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- width of reg
      min : integer;                    -- minimum number of bits on
      max : integer);                   -- maximum number of bits on
                                        -- if max is 0, must be exactly min
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- change_window
  --
  -- This checker responds to a window provided by the "start" and "stop"
  -- signals.  The cycle on which there is a rising edge on the "start" signal
  -- is the first cycle inside the window.  The cycle on which there is a
  -- rising edge on the "stop" signal is the first cycle outside the window.
  --
  -- The vector "in_vec" is checked inside the window.  The vector "out_vec" is
  -- checked outside the window.  Each is required to either change all its
  -- bits at least once, or never change any of its bits; the determination is
  -- made based upon the value of "in_change" for "in_vec" and "out_change" for
  -- "out_vec".  If the "change" variable is true, then the corresponding
  -- vector MUST change ALL its bits within its corresponding window.  If the
  -- "change" variable is false, then the corresponding vector MUST NOT change
  -- ANY of its bits within its corresponding window.
  --
  -- A vector change ON the same clock edge as "start" or "stop" rise will be
  -- considered part of the check.  For example, if "in_vec" changes on the
  -- same edge as "start" rises to '1', and "in_change" is "false", then the
  -- checker will assert "mc_change_window_in".
  --
  -- Reset
  -- 
  -- The checker must have "reset" asserted at the beginning of simulation.
  -- Use of "reset" aborts the in-progress checking of the current window.
  -- Checking will resume at the rising edge of the next "start" or "stop"
  -- signal.
  --
  -- Edges of "start" and "stop" must alternate after coming out of reset.  If
  -- there are two edges in a row on either, or if both rise on the same clock
  -- edge, the checker will assert "mc_change_window_bad".
  --
  -- Assertions
  --
  --    mc_change_window_in   assertion on in_vec inside window
  --    mc_change_window_out  assertion on out_vec outside window
  --    mc_change_window_bad  bad use of "start" and "stop" signals
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_change_window
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      in_width : integer;               -- width of in vector
      in_change : boolean := true;      -- in_vec must change inside window?
      out_width : integer;              -- width of out vector
      out_change : boolean := true);    -- out_vec must change outside window?
    PORT (
      clk, reset : IN std_ulogic;
      in_vec : IN std_logic_vector((in_width-1) DOWNTO 0);  -- checked inside
      out_vec : IN std_logic_vector((out_width-1) DOWNTO 0); -- checked outside
      start : IN std_ulogic;                      -- start of window
      stop : IN std_ulogic);                      -- end of window
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- change_window1
  --
  -- This is a scalar version of the mc_change_window check described
  -- above.  It is identical in all particulars except that the signal "input"
  -- is a scalar that is checked while the window is open; the signal "output"
  -- is a scalar checked while the window is closed.
  --
  -- Assertions
  --
  --    mc_change_window1_in   assertion on input inside window
  --    mc_change_window1_out  assertion on output outside window
  --    mc_change_window1_bad  bad use of "start" and "stop" signals
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_change_window1
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      in_change : boolean := true;      -- input must change inside window?
      out_change : boolean := true);    -- output must change outside window?
    PORT (
      clk, reset : IN std_ulogic;
      input : IN std_ulogic;            -- checked inside window
      output : IN std_ulogic;           -- checked inside window
      start : IN std_ulogic;            -- start of window
      stop : IN std_ulogic);            -- end of window
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- decrement
  --
  -- If "reg" changes on a cycle in which "enable" is high, it must change
  -- again within "min_time" to "max_time" cycles, and it must decrement by an
  -- amount between "min_decr" and "max_decr".
  --
  -- Assertions
  --
  -- mc_decrement_time   asserts for a time violation (min_time/max_time)
  -- mc_decrement_value  asserts for a bad value (min_decr/max_decr) 
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_decrement
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
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- delta
  --
  -- If "reg" changes on a cycle in which "enable" is high, it must change
  -- again within "min_time" to "max_time" cycles, and it must increment or
  -- decrement by an amount between "min_delta" and "max_delta".
  --
  -- Assertions
  --
  -- mc_delta_time   asserts for a time violation (min_time/max_time)
  -- mc_delta_value  asserts for a bad value (min_delta/max_delta) 
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_delta
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
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- fifo
  --
  -- Checks that the FIFO does not overflow or underflow, optionally checks
  -- value integrity of the FIFO.  The FIFO is written when "enqueue" is
  -- asserted on positive edge of clock, read when "dequeue" is asserted on
  -- positive edge of clock.
  --
  -- Value Integrity Check
  --
  -- When "check_values" is true, the checker models the FIFO faithfully and
  -- checks that the "dequeue_data" input is what is expected as FIFO output.
  -- The "mc_fifo_value" property asserts when an unexpected value is
  -- detected.  This property is checked 1 cycle AFTER the assertion of
  -- "dequeue" -- at which point the FIFO output has been driven from the
  -- checker's internal model of a synchronous FIFO, based upon previous data
  -- input ("enqueue_data") and control ("enqueue" and "dequeue") given to the
  -- checker.
  --  
  -- When "check_values" is false, the "enqueue_data" and "dequeue_data"
  -- vectors do not need to be connected to the checker and are ignored.
  --
  -- Simultaneous Read/Write (Dequeue/Enqueue)
  -- 
  -- The parameter "rw_type" indicates whether simultaneous read-write is
  -- allowed and what happens:
  --
  --    mc_rw_error       it is an error to assert read/write
  --                      (dequeue/enqueue) on the same cycle
  --    mc_rw_writefirst  write (enqueue) takes precedence
  --    mc_rw_readfirst   read (dequeue) takes precedence
  -- 
  -- Reset
  --
  -- Reset clears the FIFO of all values and disables all control while reset
  -- is asserted.
  --
  -- Assertions
  --
  -- mc_fifo_value      asserts with a value mismatch
  -- mc_fifo_underflow  asserts with underflow (read empty FIFO)
  -- mc_fifo_overflow   asserts with overflow (write full FIFO)
  -- mc_fifo_control    bad control signals (simultaneous read/write if
  --                    rw_type = mc_rw_error)
  --
  ----------------------------------------------------------------------------
  -- 
  -- This type indicates whether simultaneous read/write is allowed:
  -- 
  TYPE mc_rw_type IS ( 
      mc_rw_error,        -- simultaneous read/write not allowed
      mc_rw_writefirst,   -- write takes precedence over read
      mc_rw_readfirst);   -- read takes precedence over write

  COMPONENT mc_fifo
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
      enqueue_data : IN std_logic_vector((width-1) DOWNTO 0)
                     := (others => '0');
      dequeue_data : IN std_logic_vector((width-1) DOWNTO 0)
                     := (others => '0'));

  END COMPONENT;


  ----------------------------------------------------------------------------
  -- follows
  --
  -- Follower signal must assert within "min" to "max" cycles after the
  -- assertion of the leader signal.  A "min" of 0 implies that follower and
  -- leader must assert on the same signal.
  --
  -- The parameter "hold_leader", when set to "true", requires that the leader
  -- continue to be asserted until the follower asserts.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_follows
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      min : natural;                    -- min cycles to follow
      max : natural;                    -- max cycles to follow
      hold_leader : boolean := false);  -- leader must hold?
    PORT (
      clk, reset : IN std_ulogic;
      leader : IN std_ulogic;
      follower : IN std_ulogic);      
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- gray_code
  --
  -- Checks that a register changes by 1 and only 1 bit with each change.  This
  -- is equivalent to "mc_hamming_dist" with distance = 1.
  --
  -- It is advisable that "reset" be asserted at the beginning of simulation to
  -- avoid an assertion with the first assignment to the register.
  --
  -- The check will never assert in reset, but the current value is always
  -- compared to the previous value on the previous clock edge, regardless of
  -- whether the previous clock edge was in reset or not.
  --
  --           -----\ /---------\ /----
  -- reg        111  X  000      X  110
  --           -----/ \---------/ \----
  --
  -- clk       \__/--\__/--\__/--\__/--
  --
  -- reset     ______/-----------\_____
  --
  -- gray_code _____________________V__
  -- 
  -- In the case illustrated above, the value coming out of reset (110) is in
  -- violation compared to (000), which was a value change made during reset.
  -- Note that the change (111) to (000) does not assert, and that the value
  -- sampled prior to reset (111) represents a correct gray code change
  -- compared to the value change after reset (110), but the value prior to
  -- reset is not preserved for purposes of the check after reset; values are
  -- compared always to the value on the previous clock edge.
  -- 
  ----------------------------------------------------------------------------
  COMPONENT mc_gray_code
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer);                 -- Width of reg
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- hamming_dist
  --
  -- Checks that a register changes by "distance" bits with each change.
  --
  -- It is advisable that "reset" be asserted at the beginning of simulation to
  -- avoid an assertion with the first assignment to the register.
  -- 
  -- The check will never assert in reset, but the current value is always
  -- compared to the previous value on the previous clock edge, regardless of
  -- whether the previous clock edge was in reset or not.
  -- 
  -- For more detail on reset behavior, see the comments above for the
  -- "gray_code" checker, which is logically equivalent to "hamming_dist" with
  -- "distance" equal to 1.
  ----------------------------------------------------------------------------
  COMPONENT mc_hamming_dist
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- width of reg
      distance : integer);              -- number of bits that can change
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- hold_period
  --
  -- Signal must hold for "min" to "max" cycles after being asserted.  The
  -- assertion must occur when "enable" is true for the checker to activate.
  -- When "change" is true, the signal must de-assert after the hold period.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_hold_period
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      min : positive;                   -- min cycles to hold
      max : positive;                   -- max cycles to hold
      change : boolean := false);       -- must de-assert after holding?
    PORT (
      clk, reset : IN std_ulogic;
      sig : IN std_ulogic;              -- signal to check
      enable : IN std_ulogic := '1');   -- enable for check
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- increment
  --
  -- If "reg" changes on a cycle in which "enable" is high, it must change
  -- again within "min_time" to "max_time" cycles, and it must increment by an
  -- amount between "min_decr" and "max_decr".
  --
  -- Assertions
  --
  -- mc_increment_time   asserts for a time violation (min_time/max_time)
  -- mc_increment_value  asserts for a bad value (min_decr/max_decr) 
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_increment
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
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- memory
  --
  -- Various checks made of a simple single-port synchronous memory, that reads
  -- or writes when "enable" is asserted, with "rw" = '1' indicating a write;
  -- "rw" = '0' indicating a read.  
  --      
  -- The following checks are always made:
  --    * Address out-of-bounds.
  --    * Read of uninitialized data.
  --      
  -- And these are made optionally, controlled by generic parameters:
  --    * precious_data: check that memory is not overwritten before read.
  --    * volatile_data: check that memory is not read twice after write
  --    * value: model the memory to check that data output matches what is
  --      expected.
  --
  -- Value Integrity Check
  --
  -- When "check_values" is true, the checker models the memory faithfully and
  -- checks that the "data_out" input is what is expected as memory output .
  -- The "mc_memory_value" property asserts when an unexpected value is
  -- detected.  This property is checked 1 cycle AFTER the assertion of read
  -- control (enable = '1' AND rw = '0') -- at which point the memory output
  -- has been driven from the checker's internal model of the memory, based
  -- upon previous data input ("data_in") and control given to the checker.
  --  
  -- When "check_values" is false, the "data_in" and "data_out" vectors do not
  -- need to be connected to the checker and are ignored.
  -- 
  -- Reset
  -- 
  -- Assertion of reset clears the vectors that the checker uses internally to
  -- perform its checks.  This is similar to what would happen if the memory is
  -- cleared (e.g., all values are considered to be uninitialized), but the
  -- memory is not in fact cleared (i.e., written with '1' or '0' to all bits).
  -- In other words, the "uninitialized", "precious_data", and "volatile"
  -- checks behave after reset as if the memory were cleared, but the "value"
  -- check itself does not.
  -- 
  -- Assertions
  --
  -- mc_memory_uninitialized  asserts for read before write at address
  --                          (read of uninitialized data)
  -- mc_memory_precious_data  if precious_data = true: asserts for
  --                          write-write at address (write of data before
  --                          being read)
  -- mc_memory_volatile       if volatile_data = true: asserts if
  --                          write-read-read at address (if data written
  --                          is read more than once)
  -- mc_memory_address        asserts for address out-of-bounds
  -- mc_memory_value          if check_values = true: asserts if "data_out"
  --                          is not expected value on read
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_memory
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- width of the memory
      start_addr : natural := 0;        -- start address of memory
      memory_size : natural;            -- number of words in memory
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
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- one_cold
  -- 
  -- Checks that a register has 1 and only 1 bit de-asserted on every cycle; if
  -- "strict" is true, the register may never have 0 bits de-asserted.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_one_cold
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- Width of reg
      strict  : boolean := true);       -- true ==> never 0 bits de-asserted
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- one_hot
  -- 
  -- Checks that a register has 1 and only 1 bit asserted on every cycle; if
  -- "strict" is true, the register may never have 0 bits asserted.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_one_hot
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- Width of reg
      strict  : boolean := true);       -- true ==> never 0 bits asserted
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- parity
  -- 
  -- Always checks that a register is of even or odd parity.  The generic
  -- parameter "even" indicates whether the check should be enabled for even or
  -- odd parity checking.
  --
  -- This check is made every cycle, so if a register changes to be in
  -- violation of the check and remains unchanged for several cycles, the
  -- checker will assert on all of those cycles.
  ----------------------------------------------------------------------------
  COMPONENT mc_parity
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- Width of reg
      even  : boolean);                 -- true ==> even parity; false ==> odd
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0));
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- precious_data
  -- 
  -- Check that the value of a source register ("src") appears in the
  -- destination register ("dest"), within a "precious data window" defined by
  -- the checker.
  --
  -- Source Change
  --
  -- The source register is considered to have changed in one of two
  -- circumstances, determined by the value of the generic "src_change":
  -- 
  --    If src_change = mc_edge_any:
  --        Any change in the source register "src".
  --    If src_change = mc_edge_gated:
  --        Rising edge of the signal "src_loaded".
  --
  -- Opening of precious data window
  --
  -- The "precious data window" -- the window of time during which the "src"
  -- value is required to appear in the "dest" register -- opens "start_count"
  -- cycles after the source change, as defined above.
  --
  -- Closing of precious data window
  --
  -- From the opening of the precious data window (see above), the "dest"
  -- register must be equal to the "src" register within a window of time
  -- defined as:
  -- 
  --    If stop_type = mc_window_count:
  --        Within "stop_count" cycles.
  --    If stop_type = mc_window_gated:
  --        When the "stop_signal" has a rising edge.
  --
  -- Reset
  --
  -- Assertion of reset at any time aborts the checking sequence.  Reset should
  -- be asserted at the beginning of simulation, else a spurious assertion may
  -- be launched with the first value driven onto "src".
  --
  -- Overlapping windows
  --
  -- From the time of a source change, to the time the checker succeeds or
  -- fails, it is not advisable that the "src" register change again.  In
  -- particular, if the "src" register changes BEFORE the precious data window
  -- opens, the check-in-progress may fail when it otherwise would not.  The
  -- check always succeeds or fails based on current values of "src" and
  -- "dest".
  --
  -- Assertions
  --
  --    This is used only when "stop_count" is valid, i.e., when "stop_type" is
  --    "mc_window_count":
  -- 
  --    mc_precious_data      asserts when "src = dest" condition is not
  --                          fulfilled in the precious data window.
  --
  --      Note: it is OK, with the counted window, for the "dest" register to
  --      change early (because then the "src = dest" condition may still be
  --      fulfilled), but it is not OK for it to change late.
  --
  --    These are used when "stop_type" is "mc_window_gated", which means
  --    that the "stop_signal" is valid:
  --
  --    mc_precious_stoptime  asserts when there is a rising edge on
  --                          "stop_signal" that occurs fewer than
  --                          "start_count" cycles after the source change.
  --    mc_precious_stopval   asserts when there is a rising edge on
  --                          "stop_signal" but "src /= dest".
  -- 
  ----------------------------------------------------------------------------
  TYPE mc_edge_type IS ( mc_edge_any, mc_edge_gated );
  TYPE mc_window_type IS ( mc_window_count, mc_window_gated );

  COMPONENT mc_precious_data
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- Width of reg
      src_change : mc_edge_type := mc_edge_gated;  -- what starts?
                   -- mc_edge_any ==> any change in src starts
                   -- mc_edge_gated ==> rising edge of "src_loaded"
      start_count : natural := 0;       -- cycles from src_change to open of
                                        -- precious data window
      stop_type : mc_window_type := mc_window_gated;  -- what stops?
                  -- mc_window_count ==> use "stop_count" for window
                  -- mc_window_gated ==> use "stop_signal" for window
      stop_count : natural := 1);       -- # cycles in precious data window
    PORT (
      clk, reset : IN std_ulogic;
      src : IN std_logic_vector((width-1) DOWNTO 0);    -- source register
      dest : IN std_logic_vector((width-1) DOWNTO 0);   -- destination
      src_loaded : IN std_ulogic;       -- valid data in source register
                   -- ignored if src_change = mc_edge_any
      stop_signal : IN std_ulogic);     -- valid data in destination register
                    -- ignored if stop_type = mc_window_gated
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- range
  -- 
  -- Checks that a register is in the range min - max.  The check for max is
  -- enabled by "max_valid" equal to '1'.  The check for min is enabled by
  -- "min_valid" equal to '1'.
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_range
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

  END COMPONENT;


  ----------------------------------------------------------------------------
  -- reg_loaded
  -- 
  -- Check that a register is loaded (changes value) within a window defined by
  -- the checker.  The window opens some number of cycles past a "start"
  -- signal.  The window closes either based on a count (some number of cycles
  -- past the cycle at which it opens) or the rising edge of a "stop" signal
  -- after the window opens.
  --
  -- The checker does not assert if the register changes after start but before
  -- the window opens, nor does it assert if there is a rising edge on "stop"
  -- prior to the window opening.
  -- 
  -- Window Opening
  -- 
  -- The window opens on the cycle as the "start" signal is asserted.  This
  -- means that if the start_count is 0, the register may change value on the
  -- same cycle as the "start" signal is asserted, and the check will have
  -- passed.
  -- 
  -- Window Closing
  -- 
  -- If "stop_type" is mc_window_gated, the window closes on the same cycle
  -- as the "stop" signal is asserted.  To pass the check, the register must
  -- change value prior to the "stop" signal being asserted.  This means that
  -- the "stop" signal must assert on some cycle after "start" asserts.
  -- 
  -- If "stop_type" is mc_window_count, the window closes AFTER
  -- "stop_count" cycles have elapsed.  By implication, if "start_count" and
  -- "stop_count" are both 0, the register must change on the same edge as
  -- "start" is asserted.
  -- 
  ----------------------------------------------------------------------------
  COMPONENT mc_reg_loaded
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- Width of reg
      start_count : natural;            -- cycles from "start" to open of
                                        -- window
      stop_type : mc_window_type;   -- what stops (closes) the window?
                  -- mc_window_count ==> use "stop_count" for window
                  -- mc_window_gated ==> use "stop_signal" for window
      stop_count : natural := 1);       -- number of cycles to close window
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0);    -- register to check
      start : IN std_ulogic;            -- start checking for open window
      stop : IN std_ulogic);            -- (optionally) close window
             -- ignored if stop_type = mc_window_gated
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- rx_backup
  -- 
  -- Assertion of the "rx_full" signal must be followed by "xmit_ready" equal
  -- '0' within min to max cycles.
  --
  -- This is similar to "mc_follows" with the sense of the following signal
  -- inverted, except that the test for the following signal ("xmit_ready" in
  -- this case) is level-based, not edge-based.  This makes a difference for
  -- the case where "min=0", in which case the checker is satisfied if
  -- "xmit_ready" is already '0' on a rising edge of "rx_full".
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_rx_backup
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      min : natural;                    -- min cycles to follow
      max : natural);                   -- max cycles to follow
    PORT (
      clk, reset : IN std_ulogic;
      rx_full : IN std_ulogic;          -- tested for rising edge
      xmit_ready : IN std_ulogic);      -- tested for level '0'
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- scoreboard
  -- 
  -- Models a scoreboard that tracks ids issued and received.  It checks that a
  -- maximum number of ids are outstanding (issued but not received) at any one
  -- time, checks the time during which a given id is outstanding, checks that
  -- a received id was previously issued, not issued twice nor simultaneously
  -- issued and received, and that an id is legal.
  -- 
  -- Reset
  --
  -- Reset must be given at the start of simulation.  Reset clears the
  -- checker's memory of what has been issued; i.e., clears the number of
  -- outstanding ids to 0.
  --
  -- Assertions
  --
  -- mc_scoreboard_badid    asserts when an id is < min_id or > max_id
  -- mc_scoreboard_max_out  asserts when the number of outstanding (issued
  --                        but not received) ids is > max_outstanding
  -- mc_scoreboard_mismatch asserts when an id was received but not issued,
  --                        issued twice in a row, or there was an attempt
  --                        to issue and receive the same id at one time
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_scoreboard
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
  END COMPONENT;


  ----------------------------------------------------------------------------
  -- sequence
  --
  -- Checks that a register's values lie in a certain sequence, with some
  -- temporal checking: that changes lie at minimum "min_change_time" cycles
  -- apart, at most "max_change_time" cycles apart.
  --
  -- There is a signal "sequence_start" that indicates the register should, on
  -- the cycle at which "sequence_start" is asserted, be equal to to the first
  -- value in the expected sequence.  (Subsequent values in the sequence will
  -- be checked for -- with temporal checking -- from the first cycle at which
  -- "sequence_start" is de-asserted.)
  -- 
  -- Reset
  --
  -- Reset must be given at the beginning of simulation to initialize the
  -- checker, else the checker will assert with "sequence_reset" and will yield
  -- spurious value assertions.
  --
  -- When reset is given, the checker is disabled until the "sequence_start"
  -- signal is asserted again.  If the "sequence_start" signal is asserted
  -- during reset, it is ignored; it must be asserted on some cycle while
  -- "reset" is 0.
  --
  -- Note on sequence checking
  --
  -- When an out-of-sequence value is detected, the checker asserts
  -- "sequence_value" and then disables itself.  To be re-enabled, the
  -- "sequence_start" signal must be asserted.
  -- 
  -- Note on "sequence_start"
  --
  -- Best use of "sequence_start" is to assert on the same edge as the register
  -- assumes its first expected value.  It should then be de-asserted on the
  -- following cycle, so that it is a one-cycle pulse.  The property
  -- "sequence_value" will assert on any cycle at which "sequence_start" is
  -- asserted and the register is not equal to the first expected value.
  -- 
  -- Temporal checking (changes too close together or too far apart, based on
  -- "min_change_time" and "max_change_time") is triggered by the falling edge
  -- of "sequence_start".  But for the purposes of cycle counting, it is as
  -- though the register changed value to the first expected value on the cycle
  -- prior to the falling edge -- in other words, as though "sequence_start"
  -- were a one-cycle pulse as recommended.
  -- 
  -- Assertions
  --
  --    mc_sequence_starttime  is a special-purpose temporal violation
  --                           (change too late or early) for the first
  --                           register change after "sequence_start". See
  --                           notes above.
  --    mc_sequence_time       is the assertion for temporal violation for
  --                           all other register changes during the
  --                           sequence (used if the sequence is of length
  --                           greater than 2).
  --    mc_sequence_value      is the assertion for a sequence violation
  --                           (wrong value in expected sequence, or value
  --                           not equal to first expected while
  --                           "sequence_start" is asserted)
  --    mc_sequence_reset      asserts if reset was not used at the
  --                           beginning of simulation, so that the checker
  --                           was not properly initialized
  --                               
  -- The sequence is given as a 2-dimensional array of std_logic values, in the
  -- type mc_2dim_array.  Here's an example assignment to a signal of this
  -- type:
  --
  --     -- This would be given to the "expected" parameter of the checker
  --     -- when the expected sequence is of length 3, and the register of
  --     -- width 4:
  --     --
  --     SIGNAL expected3_4: mc_2dim_array (0 TO 2, 3 DOWNTO 0)
  --         := ( "0001", "0010", "0100" );
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_sequence
    GENERIC (
      coverage_level : integer := 2;    -- sets checking intensity
      width : integer;                  -- width of reg
      length : integer;                 -- number of values in sequence
      min_change_time : integer;        -- minimum time between changes
      max_change_time : integer);       -- maximum time between changes
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0);   -- Register to check
      expected : IN mc_2dim_array (0 TO (length-1),
                                       (width-1) DOWNTO 0);       -- sequence
      sequence_start : IN std_ulogic);  -- signal start of sequence

  END COMPONENT;


  ----------------------------------------------------------------------------
  -- stack
  --
  -- Checks that the stack does not overflow or underflow, optionally checks
  -- value integrity of the stack.  The stack is written when "push" is
  -- asserted on positive edge of clock, read when "pop" is asserted on
  -- positive edge of clock.
  --
  -- Value Integrity Check
  --
  -- When "check_values" is true, the checker models the stack faithfully and
  -- checks that the "pop_data" input is what is expected as stack output.  The
  -- "mc_stack_value" property asserts when an unexpected value is
  -- detected.  This property is checked 1 cycle AFTER the assertion of "pop"
  -- -- at which point the stack output has been driven from the checker's
  -- internal model of a synchronous stack, based upon previous data input
  -- ("push_data") and control ("push" and "pop") given to the checker.
  --  
  -- When "check_values" is false, the "push_data" and "pop_data" vectors do
  -- not need to be connected to the checker and are ignored.
  --
  -- Reset
  --
  -- Reset clears the stack of all values and disables all control while reset
  -- is asserted.
  --
  -- Assertions
  --
  -- mc_stack_value      asserts with a value mismatch
  -- mc_stack_underflow  asserts with underflow (pop empty stack)
  -- mc_stack_overflow   asserts with overflow (push full stack)
  -- mc_stack_control    bad control signals (simultaneous push/pop)
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_stack
    GENERIC (
      coverage_level : integer := 2;      -- sets checking intensity
      width : positive := 1;              -- width of data vectors
      depth : positive;                   -- # elements in FIFO
      check_values : boolean := false);   -- model FIFO and check values
    PORT (
      clk, reset : IN std_ulogic;
      push : IN std_ulogic;               -- write enable
      pop : IN std_ulogic;                -- read enable
      -- 
      -- These are needed if "check_values = true":
      --
      push_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0');
      pop_data : IN std_logic_vector((width-1) DOWNTO 0) := (others => '0'));

  END COMPONENT;


  ----------------------------------------------------------------------------
  -- transition
  --
  -- Checks that a register only transitions to a set of expected values.  Note
  -- that the register may assume a value not in the set just after reset;
  -- otherwise every change must be to a value in the set.
  --                               
  -- The expected states are given as a 2-dimensional array of std_logic
  -- values, in the type mc_2dim_array.  Here's an example assignment to a
  -- signal of this type:
  --
  --     -- This would be given to the "expected" parameter of the checker when
  --     -- the number of expected states are 3, and the register of width 4:
  --     --
  --     SIGNAL expected3_4: mc_2dim_array (0 TO 2, 3 DOWNTO 0)
  --         := ( "0001", "0010", "0100" );
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_transition
    GENERIC (
      coverage_level : integer := 2;     -- sets checking intensity
      width : positive;                  -- width of reg
      length : positive);                -- number of expected values
    PORT (
      clk, reset : IN std_ulogic;
      reg : IN std_logic_vector((width-1) DOWNTO 0);   -- Register for check
      expected : IN mc_2dim_array (0 TO (length-1),
                                       (width-1) DOWNTO 0));     -- sequence

  END COMPONENT;


  ----------------------------------------------------------------------------
  -- window
  --
  -- This checker is similar to "change_window" (above) except that the "in"
  -- vector and "out" vector are checked for asserting (value '1') instead of
  -- changing within their respective windows.
  -- 
  -- This checker responds to a window provided by the "start" and "stop"
  -- signals.  The cycle on which there is a rising edge on the "start" signal
  -- is the first cycle inside the window.  The cycle on which there is a
  -- rising edge on the "stop" signal is the first cycle outside the window.
  --
  -- The vector "in_vec" is checked inside the window.  The vector "out_vec" is
  -- checked outside the window.  Each is required to either assert all its
  -- bits at least once, or have all its bits asserted throughout the window;
  -- the determination is made based upon the value of "hold_in" for "in_vec"
  -- and "hold_out" for "out_vec".  If the "hold" variable is true, then the
  -- corresponding vector MUST keep ALL its bits asserted within its
  -- corresponding window.  If the "hold" variable is false, then the
  -- corresponding vector MUST assert ALL its bits AT LEAST ONCE within its
  -- corresponding window.
  --
  -- Reset
  --
  -- The checker must have "reset" asserted at the beginning of simulation.
  -- Use of "reset" aborts the in-progress checking of the current window.
  -- Checking will resume at the rising edge of the next "start" or "stop"
  -- signal.
  --
  -- Edges of "start" and "stop" must alternate after coming out of reset.  If
  -- there are two edges in a row on either, or if both rise on the same clock
  -- edge, the checker will assert "mc_change_window_bad".
  --
  -- Assertions
  --
  --    mc_window_in        hold_in=false: violation on in_vec in window
  --    mc_window_in_hold   hold_in=true: hold violation for in_vec inside
  --                        window, checked every cycle
  --    mc_window_out       hold_out=false: violation on out_vec outside
  --                        window
  --    mc_window_out_hold  hold_out=true: hold violation for out_vec
  --                        outside window, checked every cycle
  --    mc_window_bad       bad use of "start" and "stop" signals
  --
  ----------------------------------------------------------------------------
  COMPONENT mc_window
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
  END COMPONENT;

  ----------------------------------------------------------------------------
  -- Utility functions -- internal use in checker definitions
  ----------------------------------------------------------------------------
  --
  -- This utility function computes the cumulative XOR of all bits in a vector
  -- 
  PURE FUNCTION mc_xor_bits (V  : std_logic_vector) RETURN std_ulogic;

  --
  -- This utility function returns whether the given vector has min-max bits
  -- asserted
  --
  PURE FUNCTION mc_bits_inrange (V : std_logic_vector; min: natural;
                                     max: natural) RETURN boolean;

  --
  -- This function returns whether a signal is undefined.
  --
  PURE FUNCTION mc_is_undef (V : std_logic_vector) RETURN boolean;

  -- 
  -- This function calculates one_hot (val = '1') or one_cold (val = '0').
  -- 
  PURE FUNCTION mc_hotcold (vec: std_logic_vector; val: std_logic;
                                strict: boolean) RETURN boolean;

  --
  -- This function returns whether all bits in the vector are equal to the
  -- given bit value.
  --
  PURE FUNCTION mc_all (vec: std_logic_vector; val: std_logic)
    RETURN boolean;

  --
  -- This function returns the maximum value.
  --
  PURE FUNCTION mc_max (left: integer; right: integer)
    RETURN integer;

  --
  -- This procedure updates the shortest and longest cycle counts of
  -- a sequence.
  --
  PROCEDURE mc_set_extremes(
    clk : IN std_ulogic;
    endpoint_engaged : IN boolean;
    endpoint_completed : IN boolean;
    allow_zero_length_seq : IN boolean;
    cycle_count : INOUT integer;
    bound_lo : INOUT integer;
    bound_hi : INOUT integer);

END;


------------------------------------------------------------------------------
-- Package body: utility functions
------------------------------------------------------------------------------
PACKAGE BODY vhdl_psl_checkers IS

  PURE FUNCTION mc_xor_bits (V : std_logic_vector) RETURN std_ulogic IS
    VARIABLE reduce : std_ulogic;
  BEGIN
    FOR i IN V'RANGE LOOP
      IF i = V'LEFT THEN
        reduce := V(i);
      ELSE
        reduce := reduce XOR V(i);
      END IF;
    END LOOP;
    RETURN reduce;
  END mc_xor_bits;

  PURE FUNCTION mc_bits_inrange (V : std_logic_vector; min: natural;
                                     max: natural) RETURN boolean IS
    variable count : integer := 0;
  BEGIN
    FOR i IN V'RANGE LOOP
      IF V(i) = '1' THEN
        count := count + 1;
        IF (count > max) THEN
          return false;
        END IF;
      END IF;
    END LOOP;
    IF (count < min) THEN
      return false;
    ELSE
      return true;
    END IF;
  END mc_bits_inrange;

  PURE FUNCTION mc_is_undef (V : std_logic_vector) RETURN boolean IS
  BEGIN
    FOR i IN V'RANGE LOOP
      IF V(i) = 'U' THEN
        RETURN true;
      END IF;
    END LOOP;
    RETURN false;
  END mc_is_undef;

  --
  -- This function makes the check, based on strictness, for hot/cold.  It
  -- counts the bits equal to val, always returning false when encountering the
  -- second bit; returns false for 0 bits when strict is true.
  --
  PURE FUNCTION mc_hotcold (vec: std_logic_vector; val: std_logic;
                                strict: boolean)
    RETURN boolean IS
    VARIABLE count : integer := 0;
  BEGIN

    -- 
    -- This counts the bits and returns false as soon as 2 are found:
    -- 
    FOR i IN vec'RANGE LOOP
      IF (vec(i) = val) THEN
        IF (count = 1) THEN
          return false;
        ELSE
          count := count + 1;
        END IF;
      END IF;
    END LOOP;

    -- 
    -- Now return false if the hotness/coldness is strict and no bits were
    -- counted.
    -- 
    IF strict = true AND count = 0 THEN
      return false;
    ELSE
      return true;
    END IF;

  END FUNCTION;


  --
  -- This function returns whether all bits in the vector are equal to the
  -- given bit value.
  --
  PURE FUNCTION mc_all (vec: std_logic_vector; val: std_logic) 
    RETURN boolean IS
  BEGIN
    FOR i IN vec'RANGE LOOP
      IF (vec(i) /= val) THEN
        RETURN false;
      END IF;
    END LOOP;
    RETURN true;
  END FUNCTION;

  --
  -- This function returns the maximum value.
  --
  PURE FUNCTION mc_max (left: integer; right: integer)
    RETURN integer IS
  BEGIN
      IF (left > right) THEN
        RETURN left;
      END IF;
      RETURN right;
  END FUNCTION;

  --
  -- endpoint_engaged   = '1', when a sequence begins
  -- endpoint_completed = '1', when a sequence ends
  -- When a sequence ends, update bound_lo to the shortest sequence duration
  -- When a sequence ends, update bound_hi to the longest sequence duration
  -- -----------------------------------------------------------------------------------------
  -- NOTE:
  --     When both (endpoint_completed = true) and (endpoint_engaged = true):
  --         If (allow_zero_length_seq = true) then:
  --             A sequence begins and ends on the same cycle (ie. zero length sequence)
  --             WE DO NOT SUPPORT "OLD SEQUENCE ENDS AND A NEW ONE BEGINS ON THE SAME CYCLE".
  --         If (allow_zero_length_seq = false) then:
  --             An old sequence ends and a new one begins on the same cycle (ie. non-zero length sequences only)
  --             WE DO NOT SUPPORT "A SEQUENCE BEGINS AND ENDS ON THE SAME CYCLE".
  --     This avoids a conflict with an old sequence being aborted followed by one that
  --     begins and ends on the same cycle. This restriction eliminates the need to 
  --     know when an old sequence is aborted.
  -- -----------------------------------------------------------------------------------------
  PROCEDURE mc_set_extremes(
    clk : IN std_ulogic;
    endpoint_engaged : IN boolean;
    endpoint_completed : IN boolean;
    allow_zero_length_seq : IN boolean;
    cycle_count : INOUT integer;
    bound_lo : INOUT integer;
    bound_hi : INOUT integer) IS
  BEGIN
    if (clk = '1') then
        if (endpoint_completed = true) then
            if ((endpoint_engaged = true) AND allow_zero_length_seq) then
                -- A sequence begins and ends on the same cycle (ie. zero length sequence)
                cycle_count := 0; 
            end if;
            -- We have completed a sequence. Remember min and max
            if ( bound_hi < cycle_count ) then
                -- Remember the cycle count of the longest sequence
                bound_hi := cycle_count;
            end if;
            if (( bound_lo > cycle_count ) or (bound_lo < 0)) then
                -- Remember the cycle count of the shortest sequence
                bound_lo := cycle_count;
            end if;
            -- Flag that we are NOT in an active sequence any more (Stop the cycle count).
            cycle_count := -1;  
            if ((endpoint_engaged = true) AND (NOT allow_zero_length_seq)) then
                -- An old sequence ends and a new one begins on the same cycle (ie. non-zero length sequences only)
                cycle_count := 1; 
            end if;
        elsif (endpoint_engaged = true) then
            -- Flag that we ARE now in an active sequence (start the cycle count).
            cycle_count := 1;    
        elsif (cycle_count >= 0) then
            -- We are in an active sequence (increment the cycle count).
            cycle_count := cycle_count + 1;
        end if;
    end if;
  END PROCEDURE mc_set_extremes;

END;
