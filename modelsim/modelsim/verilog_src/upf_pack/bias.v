/*===== BIAS CORRUPT POWER AWARE MODEL =====*/
module BIAS_CORRUPT(in_bias_mode);
    input in_bias_mode;
    event pa_bias_mode_on;
    event pa_bias_mode_off;
    always @(posedge in_bias_mode)
        -> pa_bias_mode_on;
    always @(negedge in_bias_mode)
        -> pa_bias_mode_off;
endmodule
