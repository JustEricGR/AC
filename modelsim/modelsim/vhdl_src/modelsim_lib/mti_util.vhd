--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--  
-- --------------------------------------------------------------------

package util is

-----------------------------------------------------------------------
-- SIGNAL SPY 
-----------------------------------------------------------------------
  type del_mode is (MTI_INERTIAL, MTI_TRANSPORT);
  type forcetype is (default, deposit, drive, freeze);
  attribute builtin_subprogram : string;
        
  procedure disable_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0);
       attribute builtin_subprogram of disable_signal_spy : procedure is "disable_signal_spy_vhdl";

  procedure enable_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0);
       attribute builtin_subprogram of enable_signal_spy : procedure is "enable_signal_spy_vhdl";

  procedure init_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0;
                     control_state      : IN integer := -1);
       attribute builtin_subprogram of init_signal_spy : procedure is "init_signal_spy_vhdl_wc";

  procedure init_signal_driver (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     delay              : IN time := 0 ps;
                     delay_mode         : IN del_mode := MTI_INERTIAL;
                     verbose            : IN integer := 0) ;
       attribute builtin_subprogram of init_signal_driver : procedure is "init_signal_driver_vhdl";

  procedure signal_force (
                     destination_signal : IN string ;
                     force_value        : IN string;
                     force_delay        : IN time := 0 ps;
                     force_type         : IN forcetype := default;
                     cancel_period      : IN time := -1 ms;
                     verbose            : IN integer := 0) ;
       attribute builtin_subprogram of signal_force : procedure is "signal_force_vhdl";

  procedure signal_release (
                     destination_signal : IN string ;
                     verbose            : IN integer := 0) ;
       attribute builtin_subprogram of signal_release : procedure is "signal_release_vhdl";

-----------------------------------------------------------------------
-- OTHER UTILITIES 
-----------------------------------------------------------------------
  function to_real( time_val : IN time ) return real;
       attribute builtin_subprogram of to_real: function is "util_to_real";  

  function to_time( real_val : IN real ) return time;
       attribute builtin_subprogram of to_time: function is "util_to_time";  

  function get_resolution return real;
       attribute builtin_subprogram of get_resolution: function is "util_get_resolution";  

-----------------------------------------------------------------------
-- CALENDAR TIME/DATE
-----------------------------------------------------------------------
-- The last date/time representable in this implementation is
-- Tuesday 19 January 2038 at 03:14:07.999999 UTC.
-- The represents 2147483647.999999 seconds past the Epoch.
  subtype mti_time_t is integer range -1 to integer'high;
  type mti_clocktime_rec is record
    second : integer range 0 to 61; -- allows up to 2 leap-seconds
    minute : integer range 0 to 59;
    hour   : integer range 0 to 23; -- 24-hour clock
    day   : integer range 1 to 31;
    month : integer range 1 to 12;
    year  : integer range 1969 to 2038;
    day_of_week   : integer range 1 to 7; -- day of week, 1=Sunday
    day_of_year   : integer range 1 to 366; -- day number in year
    dst    : integer range -1 to 1; -- is daylight saving time +1=true,0=false,-1=don't know
    utc_offset : integer range -12*60*60 to (12+1)*60*60; -- local timezone offset from UTC in seconds (includes DST)
    tv_sec : mti_time_t; -- time (seconds) since 01 JAN 1970 00:00:00 UTC
    tv_usec : integer range 0 to 999999; -- time (microseconds) past tv_sec
  end record;

  -- This constant represents the Epoch:  Thursday January 01, 1970 at 00:00:00 UTC,
  -- except for the special value, -1, of the tv_sec field, used to indicate "get current time".
  constant mti_epoch : mti_clocktime_rec := (
    second => 0,
    minute => 0,
    hour => 0,
    day => 1,
    month => 1,
    year => 1970,
    day_of_week => 5,
    day_of_year => 1,
    dst => 0,
    utc_offset => 0,
    tv_sec => -1,
    tv_usec => 0
  );

  -- Returns a mti_time_t record that represents a calandar date and time.
  -- The input "t" represents the number of seconds since the Epoch,
  -- defined as January 01, 1970 00:00:00 UTC.
  -- Call with t == -1 (the default) to get the current wall clock time and date.
  -- If localize is TRUE (the default), then the return element values are expressed
  -- with respect to the local timezone; else they are left as Coordinated Universal Time
  -- (UTC, same as Greenwich Mean Time GMT).
  -- Note that localize has no effect on the values tv_sec and tv_usec, which are unique
  -- for any given time regardless of the local timezone.
  impure function get_clocktime(t : in mti_time_t := -1; localize : in boolean := true) return mti_clocktime_rec;
       attribute builtin_subprogram of get_clocktime : function is "vh_get_clocktime";

  -- Return a string representing the local date and time represented by the input record value.
  -- When "tr.tv_sec" >= 0, as it will in the return value from get_clocktime,
  -- only the first 6 record elements are used when producing the return string.
  -- When called with no argument (or with an mti_clocktime_rec whose tv_sec element == -1),
  -- the current date and time for the local timezone is obtained (all other record element
  -- values are ignored in this case).
  impure function get_asctime(tr : in mti_clocktime_rec := mti_epoch) return string;
       attribute builtin_subprogram of get_asctime : function is "vh_get_asctime";

  -- This function returns the local timezone string abbreviation as described in
  -- Base Definitions volume of IEEE Std 1003.1-2001, Chapter 8, Environment Variables
  -- for the time represented by the value passed in.  If tv_sec == -1, then the
  -- current time local timezone is obtained.  If tv_sec >= 0, then the first 6 record
  -- elements are used.
  impure function get_local_timezone(tr : in mti_clocktime_rec := mti_epoch) return string;
       attribute builtin_subprogram of get_local_timezone : function is "vh_get_local_timezone";

end;


package body util is

  procedure disable_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0 ) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.disable_signal_spy not called"
    severity note;
  end;

  procedure enable_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0 ) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.enable_signal_spy not called"
    severity note;
  end;

  procedure init_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0;
                     control_state      : IN integer := -1) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.init_signal_spy not called"
    severity note;
  end;

  procedure init_signal_driver (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     delay              : IN time := 0 ps;
                     delay_mode         : IN del_mode := MTI_INERTIAL;
                     verbose            : IN integer := 0) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.init_signal_driver not called"
    severity note;
  end;

  procedure signal_force (
                     destination_signal : IN string ;
                     force_value        : IN string;
                     force_delay        : IN time := 0 ps;
                     force_type         : IN forcetype := default;
                     cancel_period      : IN time := -1 ms;
                     verbose            : IN integer := 0) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.signal_force not called"
    severity note;
  end;

  procedure signal_release (
                     destination_signal : IN string ;
                     verbose            : IN integer := 0) is
  begin
    assert false
    report "ERROR: builtin procedure modelsim_lib.util.signal_release not called"
    severity note;
  end;

  function to_real( time_val : IN time ) return real is
  begin
    assert false 
    report "ERROR: builtin function modelsim_lib.util.to_real not called" 
    severity note;
    return 0.0;
  end;     

  function to_time( real_val : IN real ) return time is
  begin
    assert false 
    report "ERROR: builtin function modelsim_lib.util.to_time not called" 
    severity note;
    return 0 ns;
  end;     

  function get_resolution return real is
  begin
    assert false 
    report "ERROR: builtin function modelsim_lib.util.get_resolution not called" 
    severity note;
    return 0.0;
  end;     

  impure function get_clocktime(t : in mti_time_t := -1; localize : in boolean := true) return mti_clocktime_rec is
  begin
    assert false
    report "ERROR: builtin function modelsim_lib.util.get_clocktime not called"
    severity note;
    return mti_epoch;
  end;

  impure function get_asctime(tr : in mti_clocktime_rec:= mti_epoch) return string is
  begin
    assert false
    report "ERROR: builtin function modelsim_lib.util.get_asctime not called"
    severity note;
    return "";
  end;

  impure function get_local_timezone(tr : in mti_clocktime_rec := mti_epoch) return string is
  begin
    assert false
    report "ERROR: builtin function modelsim_lib.util.get_local_timezone not called"
    severity note;
    return "";
  end;

end;

