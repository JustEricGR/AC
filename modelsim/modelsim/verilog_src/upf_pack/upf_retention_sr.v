module upf_retention_sr (
  CLK, RESET,SET,
  SAVE, RESTORE, PWR,
  D, Q
 );

  input CLK;
  input RESET;
  input SET;
  input SAVE;
  input RESTORE;
  input PWR;

  output Q;
  input  D;

  event pa_store_value ;
  event pa_store_x ;
  event pa_restore_value ;
  event pa_restore_x ;
  event pa_corrupt_register ;
  event pa_release_register ;

  // store value
  always @(posedge SAVE)
  begin
    if (PWR) begin
      -> pa_store_value ;
    end else begin
      -> pa_store_x ;
    end
  end

  // go in POWERDOWN
  always @(negedge PWR)
  begin
    -> pa_corrupt_register ;
  end

  // go in POWERUP
  always @(posedge PWR)
  begin
    if (PWR && ~RESTORE) begin
      -> pa_restore_x ;
      -> pa_release_register ;
    end
  end

  // restore value 
  always @(posedge RESTORE)
  begin
    if (~PWR) begin
      -> pa_restore_x ;
    end else begin
      -> pa_restore_value ;
    end
  end

endmodule
