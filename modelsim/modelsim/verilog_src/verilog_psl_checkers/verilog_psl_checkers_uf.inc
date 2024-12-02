//*- mode: fundamental; tab-width: 4; indent-tabs-mode: nil -*-
// ------------------------------------------------------------------------
// ModelSim Standard Checker Library Version 1.0
// $Revision: #1 $
//        
// Copyright 2005-2009 Mentor Graphics Corporation
//
// This source file may be used and distributed without restriction 
// provided that this copyright statement is not removed from the file 
// and that any derivative work contains this copyright notice.  
//
// The source file is provided "AS IS" and Mentor Graphics makes 
// NO WARRANTY, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
// ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR 
// PURPOSE, with respect to the source file or the use thereof.
//                                                                      
//	Name: verilog_psl_checkers_uf (ModelSim Standard Checker Library in PSL/verilog)	
//								
//	Purpose: 						
//      Implements utility functions -- internal used in verilog_psl_checkers.
// ------------------------------------------------------------------------

`define do_allow_zero_length_seq 1'b1
`define dont_allow_zero_length_seq 1'b0

// State variable mc_set_extremes_cycle_count_state: Maintains its value from call to call (static allocation)
integer mc_set_extremes_cycle_count_state = -1; 

//
// endpoint_engaged   = '1', when a sequence begins
// endpoint_completed = '1', when a sequence ends
// When a sequence ends, update bound_lo to the shortest sequence duration
// When a sequence ends, update bound_hi to the longest sequence duration
// -----------------------------------------------------------------------------------------
// NOTE:
//     When both (endpoint_completed = true) and (endpoint_engaged = true):
//         If (allow_zero_length_seq = true) then:
//             A sequence begins and ends on the same cycle (ie. zero length sequence)
//             WE DO NOT SUPPORT "OLD SEQUENCE ENDS AND A NEW ONE BEGINS ON THE SAME CYCLE".
//         If (allow_zero_length_seq = false) then:
//             An old sequence ends and a new one begins on the same cycle (ie. non-zero length sequences only)
//             WE DO NOT SUPPORT "A SEQUENCE BEGINS AND ENDS ON THE SAME CYCLE".
//     This avoids a conflict with an old sequence being aborted followed by one that
//     begins and ends on the same cycle. This restriction eliminates the need to 
//     know when an old sequence is aborted.
// -----------------------------------------------------------------------------------------
task mc_set_extremes(
    input clk,
    input endpoint_engaged,
    input endpoint_completed,
    input allow_zero_length_seq,
    inout integer bound_lo,
    inout integer bound_hi);
begin
    if (clk === 1'b1) begin
        if (endpoint_completed === 1'b1) 
            begin
                if ((endpoint_engaged === 1'b1) && (allow_zero_length_seq === `do_allow_zero_length_seq)) begin
                    // A sequence begins and ends on the same cycle (ie. zero length sequence)
                    mc_set_extremes_cycle_count_state = 0; 
                end // if
                // We have completed a sequence. Remember min and max
                if ( bound_hi < mc_set_extremes_cycle_count_state ) begin
                    // Remember the cycle count of the longest sequence
                    bound_hi = mc_set_extremes_cycle_count_state;
                end // if
                if (( bound_lo > mc_set_extremes_cycle_count_state ) || (bound_lo < 0)) begin
                    // Remember the cycle count of the shortest sequence
                    bound_lo = mc_set_extremes_cycle_count_state;
                end // if
                // Flag that we are NOT in an active sequence any more (Stop the cycle count).
                mc_set_extremes_cycle_count_state = -1;  
                if ((endpoint_engaged === 1'b1) && (allow_zero_length_seq === `dont_allow_zero_length_seq)) begin
                    // An old sequence ends and a new one begins on the same cycle (ie. non-zero length sequences only)
                    mc_set_extremes_cycle_count_state = 1; 
                end // if
            end
        else if (endpoint_engaged === 1'b1)
            begin
                // Flag that we ARE now in an active sequence (start the cycle count).
                mc_set_extremes_cycle_count_state = 1; 
            end
        else if (mc_set_extremes_cycle_count_state >= 0) begin
            // We are in an active sequence (increment the cycle count).
            mc_set_extremes_cycle_count_state = mc_set_extremes_cycle_count_state + 1;
        end // if
    end // if
end
endtask
