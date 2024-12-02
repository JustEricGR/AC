/*===== CORRUPT POWER AWARE MODEL =====*/
module CORRUPT(PWR);
   input PWR;
   event pa_corrupt_register;
   event pa_release_register;
   always @(negedge PWR)
     -> pa_corrupt_register;
   always @(posedge PWR)
     -> pa_release_register;
endmodule
