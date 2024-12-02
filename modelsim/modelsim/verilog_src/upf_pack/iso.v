module upf_iso_cell_model(ISO);
   input ISO;
   event pa_corrupt_register;
   event pa_release_register;
   always @(posedge ISO)
     -> pa_corrupt_register;
   always @(negedge ISO)
     -> pa_release_register;
endmodule
