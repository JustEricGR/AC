package ENV is

  procedure stop (STATUS : INTEGER);

  procedure finish (STATUS : INTEGER);

  function resolution_limit return DELAY_LENGTH;

end ENV;

package body env is

  -- For both STOP and FINISH the STATUS values are those used
  -- in the Verilog $finish task
  -- 0 prints nothing
  -- 1 prints simulation time and location
  -- 2 prints simulation time, location, and statistics about
  --   the memory and CPU times used in simulation

  -- Other STATUS values are interpreted as 0.

  procedure stop (STATUS : INTEGER) is
  begin
    assert false
    report "ERROR: builtin subprogram STOP not called"
    severity note;
  end;

  procedure finish (STATUS : INTEGER) is
  begin
    assert false
    report "ERROR: builtin subprogram FINISH not called"
    severity note;
  end;
   
  function resolution_limit return delay_length is
  begin
    assert false 
    report "ERROR: builtin function RESOLUTION_LIMIT not called" 
    severity note;
    return 0 hr;
  end;     
  

end env;

