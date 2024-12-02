//-*- mode: fundamental; tab-width: 4; -*-
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
//	Name: system_verilog_checkers (ModelSim Standard Checker Library in System
//  Verilog)	
//								
//	Purpose: 						
//      Implements numerous predefined automated design checkers using 
//      assertion based verification and functional coverage techniques.
//
// Ported from the Verilog/PSL version of the same checkers
// This suite of checkers is a translation of the Verilog/PSL checkers into
// System Verilog.
// In many cases these checkers give identical results to the original test 
// cases, where identical is determined by the components of the Error and 
// Note messages in the assert.log files, and tracking variables tested using 
// the 'examine' command.
// The concept of 'identical' excludes Filenames and paths, Line numbers, non-
// deterministic message ordering, and other data that one would expect to be 
// different between runs and designs. 
// See the Perl file 'comp' to see how the automatic equivalence checking was 
// written.
// Of course, the test cases represent a limited set of tests and therefore 
// even checkers that evaluate as identical when tested with the existing 
// tests could differ under other circumstances.
//
// In some cases, the output is not strictly identical, because the checker
// has been implemented slightly differently. In these cases
// the output has been judged to be equivalent.
// 
// ------------------------------------------------------------------------

// Available checkers in "system_verilog_checkers" are:

//   mc_arbiter_fifo        logical check for fifo arbitration scheme
//   mc_arbiter_priority    logical check for priority arbitration scheme
//   mc_arbiter_fairness    logical check for fairness arbitration scheme
//   mc_assert_period       a signal is asserted, possibly de-asserted, within a
//                          certain window
//   mc_asserted            enabled synchronous check that a signal is asserted
//   mc_bits_on             min-max bits asserted in a register
//   mc_change_window       vectors are checked for changes or not in a
//                          signal-bound window
//   mc_change_window1      scalar version of the above
//   mc_decrement           enabled check that a register decrements by a
//                          min-max amount every min-max cycles
//   mc_delta               enabled check that a register changes by min-max
//                          amount every min-max cycles
//   mc_fifo                checks overflow/underflow of a FIFO, with optional
//                          read/write value check
//   mc_follows             assertion of one signal follows another
//   mc_gray_code           register changes by 1 and only 1 bit each time
//   mc_hamming_dist        register changes by N bits each time
//   mc_hold_period         register holds value for min-max cycles, optionally
//                          must de-assert
//   mc_increment           enabled check that a register increments by a
//                          min-max amount every min-max cycles
//   mc_memory              check memory address, uninitialized read, optional
//                          checks: value check, overwrite, precious data
//   mc_one_hot             check that 1 bit is asserted in a register
//   mc_one_cold            check that 1 bit is de-asserted in a register
//   mc_parity              parity of a register, even/odd selectable
//   mc_precious_data       source value appears in destination register during
//                          a window of time
//   mc_range               a register value falls in a min-max range
//   mc_reg_loaded          check that register is loaded in a time window
//   mc_rx_backup           when a "full" signal is asserted, check that a
//                          "transmit" signal is de-asserted
//   mc_scoreboard          temporal/logical check for ids issued and received
//                          by a scoreboard
//   mc_sequence            temporal/logical check for register values in
//                          sequence
//   mc_stack               checks overflow/underflow of a stack, with optional
//                          value check
//   mc_transition          checks that a register only transitions to a given
//                          set of values
//   mc_window              vectors are checked for assertion or not in a
//                          signal-bound window

// General characteristics of all checkers:
// 
//   Clocking

//   All checker properties are evaluated at the rising edge of clock.  Each
//   checker component takes a "clk" input as the clock.  When documentation
//   refers to "every cycle", that is construed as every rising edge of clock
//   at which reset (see below) is not asserted.

//   Reset

//   All checkers take an ACTIVE HIGH reset input (called "reset") which
//   aborts any in-progress checking and induces any reset behavior specific
//   to the checker (see documentation below for any checker-specific reset
//   behavior.)  Some checkers are best-behaved when reset is asserted at the
//   beginning of simulation.  Note that no checker will assert while reset is
//   high.

// This is a port of the original PSL/Verilog implementation
// The assertion syntax is native to System Verilog, and therefore only
// one source file is necessary (plus the include file)
// The original module structure and naming is retained

// DEFINES:
`include "system_verilog_checkers.inc"

//----------------------------------------------------------------------------  
// arbiter (mc_arbiter_fifo, mc_arbiter_priority, mc_arbiter_fairness)
//
// Checks that different arbitration schemes are held faithfully in an
// arbiter.
//
// Interface
//
// A request bit must be held high until the corresponding grant bit is
// asserted, after which the request must be de-asserted.  
// This code is enhanced from the original PSL with additional parameterized
// temporal checks.
//
// There are two 'views' into an arbiter. The first is the per-bit view, which comprises
// a request bit and a grant bit that are expected to behave according to
// some temporal rules.
// The second view is into the arbitration scheme, where there are rules that determine
// grant precedence, number of simultaneous grants allowed, and so on. As described above,
// three different grant precedence schemes are considered, and the checker is restricted
// to one grant valid at any time.
// The first part of the checker is constructed to check each request/grant line for correct 
// behavior. 
// The rules (per pair) are as follows.
// request/grant assertions must alternate, starting after a reset with request.
// grant must occur within a [min_gnt_time:max_gnt_time] window, max_gnt_time  
// must be greater than or equal to min_gnt_time, OR it can be 0, indicating that 
// grant stalled indefinitely is not an error.
// request must stay asserted until grant is asserted, and must deassert within a
// [min_dereq_time:max_dereq_time] window, max_dereq_time must be greater or equal
// to min_dereq_time. max_dereq_time of 0 is NOT valid (the requestor can't keep
// the grant forever).
// grant must deassert precisely degnt_time later
//
//
// clk	|	|	|	|	|	|	|	|	|	|	|	|	|	|	|	|	|
// req_______------------------------------------___________________
// gnt_______________------------------------------------____________
//			|  A    |			B				|  C    |
//
// A = [min_gnt_time:max_gnt_time]
// B = [min_dereq_time:max_dereq_time] (0 is not valid)
// C = [degnt_time] (0 is not valid)
//
//
// Single Grant
//
// Currently only a single grant may be asserted.
//
// Priority Arbitration - scheme = mc_arbiter_priority
// 
//   In a priority scheme, access is granted based on priority, where bit 0
//   is higher priority than bit 1.  For a grant on cycle t, the grant bit
//   must be less than any bit on cycle t-1 that was requested but not
//   granted on cycle t.
// 
// FIFO Arbitration - scheme = mc_arbiter_fifo
//
//   In a FIFO scheme, access is granted based on order of assertion, first
//   request granted first.  If two or more request bits are asserted on the
//   same cycle, they are considered in order of priority (where bit 0 is
//   higher priority and therefore granted earlier than bit 1.)  
//   
// Fairness Arbitration - scheme = mc_arbiter_fairness
//
//   In a fairness scheme, access is granted based on which of currently
//   outstanding, ungranted requests have been least recently granted.  This
//   is like an LRU (least recently used) algorithm in software.  
//
// Reset
//
// This checker requires that reset be asserted at the beginning of
// simulation.
// 
// Assertions
//
// mc_arbiter_single_grant  asserts if there is more than 1 grant at any time
// mc_arbiter_priority      asserts if priority arbitration scheme is violated
// mc_arbiter_fifo          asserts if fifo arbitration scheme is violated
// mc_arbiter_fairness      asserts if fairness arbitration scheme is violated
//
// Coverage
// Number of requests per requestor
// Number of grants per requestor
// Maximum number of outstanding requests
//
//----------------------------------------------------------------------------  

module mc_arbiter
#(parameter integer coverage_level = 2,				// sets checking intensity
  parameter integer width = 0,						// number of grants/requests
  parameter integer min_gnt_time = 1,				// see below for details
  parameter integer max_gnt_time = 100,				// if max_gnt_time is 0, it's $
  parameter integer min_dereq_time = 1,
  parameter integer max_dereq_time = 100,
  parameter integer degnt_time = 1,					// we expect de-grant to be a fixed delay >= 1

  parameter integer scheme = `MC_ARBITER_FIFO_SCHEME) // arbitration scheme, Default: mc_arbiter_fifo
(
	input clk,
	input reset,
    input [0:(width-1)] req,                          // request bits
    input [0:(width-1)] grant);                       // grant bits

	reg [0:(width-1)] prev_req;
	reg [0:(width-1)] prev_gnt;

//
// Design notes
// Does not resemble the original implementation.
// 

	initial begin
		if (degnt_time <1)
			$display("Invalid degnt_time value, %d",degnt_time);
		if (max_dereq_time === 0)
			$display("Invalid max_dereq_time value, %d",degnt_time);
	end

	always @ (posedge clk) begin
		prev_req <= req;
		prev_gnt <= grant;
	end

//
// Never expecting reset to be false and multiple grants 
//

	always @ (posedge clk)
		if (reset === 1'b0)
			assert ($onehot0(grant))
			else $error("Assertion assert_mc_arbiter_single_grant");

//
// Now the per-bit checks (requestor's view of the arbiter)
//

	generate // one for every bit in the vector
	genvar req_index;
	for (req_index = 0; req_index < width; req_index = req_index + 1) begin: per_bit
//
// After reset, req must be the first event, not grant
//

		property mc_arbiter_req_first;
			@ (posedge clk)
				$fell(reset) |-> 
				(~grant[req_index] && ~req[req_index]) [*1:$] 
				##1 (~grant[req_index] && $rose(req[req_index]));
		endproperty
		
		assert property (mc_arbiter_req_first)
		else $error("Assertion assert__mc_arbiter_req_first");

//
// When a req starts a cycle, it must conform to the above description
// There are two versions depending on whether max_gnt_time is 0 (i.e., $)
// or not. The other two maximum times are not allowed to be 0. We could do it but
// it needs 8 separate cases - possible enhancement! Can't write an expression that
// returns either a valid number or $, otherwise it could be done as a ? : expr.
//
		if (max_gnt_time != 0) begin: indefinite_stall_ok
			property mc_arbiter_per_bit_cycle;
				disable iff (reset)
				@ (posedge clk)
					$rose(req[req_index]) |->
					(~grant[req_index] && req[req_index]) [*min_gnt_time : max_gnt_time]
					##1 (req[req_index] && grant[req_index])[*min_dereq_time : max_dereq_time]
					##1 (~req[req_index] && grant[req_index])[*degnt_time]
					##1 $fell(grant[req_index]);
			endproperty

			assert property (mc_arbiter_per_bit_cycle)
			else $error("Assertion assert__mc_arbiter_per_bit_cycle");
		end
		else begin: indefinite_stall_bad
			property mc_arbiter_per_bit_cycle;
				disable iff (reset)
				@ (posedge clk)
					$rose(req[req_index]) |->
					(~grant[req_index] && req[req_index]) [*min_gnt_time : $]
					##1 (req[req_index] && grant[req_index])[*min_dereq_time : max_dereq_time]
					##1 (~req[req_index] && grant[req_index])[*degnt_time]
					##1 $fell(grant[req_index]);
			endproperty

			assert property (mc_arbiter_per_bit_cycle)
			else $error("Assertion assert__mc_arbiter_per_bit_cycle");
		end
	end
	endgenerate

//
// Priority scheme checks. Generated according to three possible values of scheme
// parameter. The schemes determine who gets the grant when there are multiple
// simultaneous requests
//
// `MC_ARBITER_PRIORITY_SCHEME
// This checker operates when a req is granted, i.e. on the rising edge of grant.
// How do we detect an unfulfilled higher-priority request, and when is the latest it can occur 
// and still should pre-empt? 
// The checker looks at the previous cycle and asserts if any higher-priority reqs were high.
// This is not parameterizable.
// 
// `MC_ARBITER_FAIRNESS_SCHEME
// Least recently used scheme. When any bit is granted, we save the time at which the
// grant occurred for that bit. Also when a grant is detected, we check that there
// wasn't a more deserving bit with 'req' asserted. In this case, more deserving
// means with an older time stamp. This is similar to the FIFO scheme, except that the
// fairness time stamp records the 'grant' time, not the 'req' time.
//
// `MC_ARBITER_FIFO_SCHEME
// First request gets first grant scheme. When any bit is requested, we save the time of the
// request. When a grant is detected, we check that there isn't a bit with an earlier
// time stamp and its request still outstanding. 
//

//
// `MC_ARBITER_PRIORITY_SCHEME
//
	generate
	genvar pri_index;
	genvar pri_i;
	if (scheme === `MC_ARBITER_PRIORITY_SCHEME) begin: priority_scheme

		reg [0:(width-1)] higher_priority_bits_mem [0:(width-1)];
		int i,j;
		reg [0:(width-1)] tempvar;

		initial begin // priorities are fixed therefore this never changes
			for (i=0; i< width; i=i+1) begin
				for (j=0;j<width;j=j+1) begin
					tempvar[j] = (j<i);
				end
				higher_priority_bits_mem[i] = tempvar;
			end
		end

		for (pri_index = 1; pri_index < width; pri_index = pri_index +1) begin: pri_per_bit // 0 has no higher priority bits!

			property mc_arbiter_priority;
				disable iff (reset)
				@ (posedge clk)
				$rose(grant[pri_index]) |->
					(($past(req,1) & higher_priority_bits_mem[pri_index]) === '0);
			endproperty

			assert property (mc_arbiter_priority)
			else $error("Assertion assert__mc_arbiter_priority");
		end
	end
	endgenerate

//
// `MC_ARBITER_FAIRNESS_SCHEME
// 
	generate
	genvar fair_index;
	if (scheme === `MC_ARBITER_FAIRNESS_SCHEME) begin: fairness_scheme
		time fairness_record [0:(width-1)];	// record grant times
		int fairness;
		int most_deserving_requestor;
		int fair_i, fair_j, fair_k;

		initial begin
			for (fair_i = 0; fair_i < width; fair_i = fair_i + 1) begin
				fairness_record[fair_i] = $time;
			end
		end

// 
// Assesses fairness every clock edge
// If there are no requests outstanding, fairness will be 0,
// but that's OK because there won't be a grant next cycle
//

		always @ (posedge clk) begin
			fairness = 0;
			for (fair_j = 1; fair_j < width; fair_j = fair_j + 1) begin
				if ((fairness_record[fair_j] < fairness_record[fairness]) && 
						(req[fair_j] === 1'b1))	// Who is the most deserving
												// requesting candidate?
					fairness = fair_j;
			end
		end
//
// If there is a new grant, update the fairness record for the
// lucky recipient, and increment the current fairness value.
// Only looks at the first grant (it's an error if there
// was more than one anyway, and will assert elsewhere)
// 

		always @ (posedge clk) begin
			most_deserving_requestor <= fairness;	// most_deserving_requestor
													// is determined at previous
													// clock edge.

			if (grant !== prev_gnt) begin
				for (fair_k = 0; fair_k < width; fair_k = fair_k + 1) begin
					if (grant[fair_k]) begin
						fairness_record[fair_k] <= $time;
						break;
					end
				end
			end
		end

		for (fair_index = 0; fair_index < width; fair_index = fair_index +1) begin: fair_per_bit

			property mc_arbiter_fairness;
				disable iff (reset)
				@ (posedge clk)
					$rose(grant[fair_index]) 
					|-> fair_index === most_deserving_requestor;
			endproperty

			assert property (mc_arbiter_fairness)
			else $error("Assertion assert__mc_arbiter_fairness");
		end
	end
	endgenerate

//
// `MC_ARBITER_FIFO_SCHEME
//
//
	generate
	genvar fifo_index;
	if (scheme === `MC_ARBITER_FIFO_SCHEME) begin: fifo_scheme
		time fifo_record [0:(width-1)];	// record grant times
		int next_up = 0;
		int fifo_i, fifo_j, fifo_k;

		initial begin
			for (fifo_i = 0; fifo_i < width; fifo_i = fifo_i + 1) begin
				fifo_record[fifo_i] = $time;
			end
		end

// 
// Assess which should be the next grant up every clock edge
// If there are no requests outstanding, next_up will be unchanged,
// but that's OK because there shouldn't be a grant next cycle
//
// If there is a new request, save the time for the bit. Note that 
// there can be multiple simultaneous new requests, so we check all
// the bits.
// 

		always @ (posedge clk) begin
			if (req !== prev_req) begin		// update the saved request time
											// on positive edge of req
				for (fifo_k = 0; fifo_k < width; fifo_k = fifo_k + 1) begin
					if ((req[fifo_k]) && (~prev_req[fifo_k]))
						fifo_record[fifo_k] = $time;
				end
			end
											// Who is the oldest
											// still-requesting candidate?
			for (fifo_j = width-1; fifo_j >= 0; fifo_j = fifo_j - 1) begin
				if (req[fifo_j] === 1'b1)	// current candidate is better if
											// either next_up is non-requestor,
											// or if it's a requestor with a later
											// time.
					if (~req[next_up] 
						|| (req[next_up] && (fifo_record[fifo_j] <= fifo_record[next_up])))
						next_up = fifo_j;
			end
		end // always

		for (fifo_index = 0; fifo_index < width; fifo_index = fifo_index +1) begin: fifo_per_bit

			property mc_arbiter_fifo;
				disable iff (reset)
				@ (posedge clk)
					$rose(grant[fifo_index]) 
					|-> fifo_index === next_up;
			endproperty

			assert property (mc_arbiter_fifo)
			else $error("Assertion assert__mc_arbiter_fifo");
		end
	end
	endgenerate


	int FA_arbiter_count_requests [(width-1):0];
	int FA_arbiter_count_grants [(width-1):0];
	int FA_arbiter_request_highwater;

	always @ (posedge clk or posedge reset) begin
		if (reset)
			FA_arbiter_request_highwater = 0;
		else begin
			if ($countones(req) > FA_arbiter_request_highwater)
				FA_arbiter_request_highwater <= $countones(req);
		end
	end
	
	generate
		genvar arb_index;
		if (coverage_level >= 2) begin: FC_arbiter_per_bit
			for (arb_index=0; arb_index < width; arb_index = arb_index +1) begin: FC_arbiter_count_requests
				always @ (posedge req[arb_index] or posedge reset) begin
					if (reset)
						FA_arbiter_count_requests[arb_index] <= 0;
					else
					 	FA_arbiter_count_requests[arb_index] <= FA_arbiter_count_requests[arb_index] + 1;
				end
				always @ (posedge grant[arb_index] or posedge reset) begin
					if (reset)
						FA_arbiter_count_grants[arb_index] <= 0;
					else
					 	FA_arbiter_count_grants[arb_index] <= FA_arbiter_count_grants[arb_index] + 1;
				end
			end
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------  
// assert_period
//
// Checks that "sig" is asserted for "min" to "max" cycles.  If "max" is 0,
// then "sig" must be asserted for exactly "min" cycles.  With the option
// "must_deassert", the signal must be de-asserted at the end of the window.
//
// The check is enabled by "enable" equal to '1'.  The "enable" is
// level-sensitive, but the check is activated by a rising edge on "sig".
// As always, the check is disabled when "reset" is '1'.
// 
// The inputs are overconstrained, so we have to define some of the 
// unspecified functionality.
// Truth table for interaction between max and must_deassert:
//
//                   max <0   max===0                (0<max<min)   max >=min
// must_deassert=0   error    min_and_max(max=min)    error        min_only
// must_deassert=1   error    min_and_max(max=min)    error        min_and_max
//----------------------------------------------------------------------------  

module mc_assert_period
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer min = 0,                    // minimum assertion time
  parameter integer max = 0,                    // maximum assertion time
  parameter integer must_deassert = `MC_FALSE)  // require de-assertion after window
(
	input clk,
	input reset,
	input sig,                              // signal whose assertion is checked
	input enable);		                    // enable for check, active high

	int FA_assert_period_bound_lo;
	int FA_assert_period_bound_hi;

// The properties are used both for the assertion and for coverage. Since the
// assertion without 'must_deassert' requires that maximum hold 
// time can be unconstrained, we can only observe the coverage event if it 
// eventually falls. 
// The workaround would be to use a different property for the coverage, 
// terminating the sequence after it meets min.
// In fact both these properties are doing triple-duty: assert, cover, and count
// the extent of the assert period. The count also requires a
// terminating deassertion. If there is no deassertion, the bounds aren't 
// updated. There could also be a workaround for this, by updating the bounds on 
// every cycle, but it would be expensive in compute time and only relevant in 
// the case where the signal was stuck until the end of simulation time.
// The behavior of this implementation is slightly different from the original 
// PSL/verilog, which does terminate the !must_deassert case
// at min cycles, thus recording a coverage event, but also recording the cycle 
// count wrongly.

	property p_meets_min_assert;
		int x;
		disable iff (reset === 1'b1)
		@ (posedge clk) ((enable === 1'b1) && $rose(sig),x=0) |-> 
			((sig === 1'b1),x=x+1) [* min:$] 
			##1 (sig === 1'b0,record_bounds(x)) ;
	endproperty

	property p_meets_min_and_max_assert;
		int x;
		disable iff (reset == 1'b1)
		@ (posedge clk) ((enable === 1'b1) && $rose(sig),x=0) |-> 
			((sig === 1'b1),x=x+1) [* min:((max==0)?(min):(max))] 
			##1 (sig === 1'b0,record_bounds(x));
	endproperty
//
// simple case - only required to check for minimum hold
//
	generate 
	if ((must_deassert == `MC_FALSE) && (max>=min)) begin:assert_period_min_only
		assert property (p_meets_min_assert)
		else $error("Assertion assert__mc_assert_period");

		cover property (p_meets_min_assert) 
			$info("Coverage event cover__FC_assert_period");
	end
	endgenerate
//
// check for minimum hold AND maximum hold
//
	generate
	if (((must_deassert==`MC_TRUE) && (max >= min)) || (max == 0)) 
	begin: assert_period_min_and_max 
		assert property (p_meets_min_and_max_assert)
		else $error("Assertion assert__mc_assert_period");

		cover property (p_meets_min_and_max_assert) 
		$info("Coverage event cover__FC_assert_period");
	end
	endgenerate

	initial begin
		if ((max<0) || ((max > 0) && (max < min)))
			$display("%m - Invalid max parameter,%d, min is %d",max,min);
	end

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

//
// This process synchronizes the static values in record_bounds with the 
// variables defined at the top scope
// in this module.
// This is used so that the existing test infrastructure works. Otherwise we 
// could use the data in the record_bounds static variables directly
// 
	always_comb begin
		FA_assert_period_bound_lo = record_bounds.low_bound;
		FA_assert_period_bound_hi = record_bounds.high_bound;
	end

endmodule

//--------------------------------------------------------------------------  
// asserted
//
// Checks that "sig" is asserted (every cycle), enabled by active-high
// "enable", also disabled by "reset" = '1'.
//
//--------------------------------------------------------------------------  

module mc_asserted
#(parameter integer coverage_level = 2)         // sets checking intensity
(
	input clk,
	input reset,
	input sig,               // signal whose assertion is checked
	input enable);           // enable for check, active high

// 
// Uses immediate assertion syntax
// 

	always @ (posedge clk)
		if ((reset == 1'b0) && (enable == 1'b1))
			assert (sig === 1'b1)
			else $error("Assertion assert__mc_asserted");
//
// the coverage
//
	property mc_asserted(sig);
		@ (posedge clk)
			((reset === 1'b0) && (enable === 1'b1) && (sig === 1'b1));
	endproperty

	cover property (mc_asserted(sig)) 
	$info("Coverage event cover__FC_asserted");
endmodule

//----------------------------------------------------------------------------
// bits_on
//
// Checks that a register has "min" to "max" bits on.  Checks for exactly
// "min" bits if the "max" value is 0.
//
// This check is made every cycle, so if a register changes to be in
// violation of the check and remains unchanged for several cycles, the
// checker will assert on all of those cycles.
//----------------------------------------------------------------------------

module mc_bits_on
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer width = 0,                  // width of reg
  parameter integer min = 0,                    // minimum number of bits on
  parameter integer max = 0)                    // maximum number of bits on,
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);

	integer FA_bits_on_bound_lo = -1;
	integer FA_bits_on_bound_hi = -1;
//
// Uses immediate assertion syntax
// If max is set to 0 then the number of ones must be exactly min
// Or - if max is not 0, then the number of ones must be between min and max, 
// inclusive
//
	always @ (posedge clk)
		if (reset === 1'b0)
			assert (  ((max === 0) && ($countones(sigreg) === min)) 
			|| (($countones(sigreg) >= min) && ($countones(sigreg) <= max)))
			else $error("Assertion assert__mc_bits_on");

// The original also has high and low watermark tracking (checked in the 
// transcript output)

	generate
		if (coverage_level >= 1) begin
			int bits_set;

			always @ (sigreg) begin
				if (reset == 1'b0) begin
				bits_set = $countones(sigreg);
					if (FA_bits_on_bound_hi < bits_set) 
						FA_bits_on_bound_hi = bits_set;
					if ((FA_bits_on_bound_lo > bits_set) || (FA_bits_on_bound_lo == -1))
						FA_bits_on_bound_lo = bits_set;
				end
			end
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------  
// change_window
//
// This checker responds to a window provided by the "start" and "stop"
// signals.  The cycle on which there is a rising edge on the "start" signal
// is the first cycle inside the window.  The cycle on which there is a
// rising edge on the "stop" signal is the first cycle outside the window.
//
// The vector "in_vec" is checked inside the window.  The vector "out_vec" is
// checked outside the window.  Each is required to either change all its
// bits at least once, or never change any of its bits; the determination is
// made based upon the value of "in_change" for "in_vec" and "out_change" for
// "out_vec".  If the "change" variable is true, then the corresponding
// vector MUST change ALL its bits within its corresponding window.  If the
// "change" variable is false, then the corresponding vector MUST NOT change
// ANY of its bits within its corresponding window.
//
// A vector change ON the same clock edge as "start" or "stop" rise will be
// considered part of the check.  For example, if "in_vec" changes on the
// same edge as "start" rises to '1', and "in_change" is "false", then the
// checker will assert "mc_change_window_in".
//
// Reset
// 
// The checker must have "reset" asserted at the beginning of simulation.
// Use of "reset" aborts the in-progress checking of the current window.
// Checking will resume at the rising edge of the next "start" or "stop"
// signal.
//
// Edges of "start" and "stop" must alternate after coming out of reset.  If
// there are two edges in a row on either, or if both rise on the same clock
// edge, the checker will assert "mc_change_window_bad".
//
// Assertions
//
//    mc_change_window_in   assertion on in_vec inside window
//    mc_change_window_out  assertion on out_vec outside window
//    mc_change_window_bad  bad use of "start" and "stop" signals
//
//----------------------------------------------------------------------------  

module mc_change_window
#(parameter coverage_level = 2,         // sets checking intensity
  parameter integer in_width = 0,       // width of in vector
  parameter in_change = `MC_TRUE,       // in_vec must change inside window? (boolean)
  parameter integer out_width = 0,      // width of out vector
  parameter out_change = `MC_TRUE)      // out_vec must change outside window?  (boolean)
(
	input clk,
	input reset,
	input [(in_width-1):0] in_vec,    // checked inside
	input [(out_width-1):0] out_vec,  // checked outside
	input start,                      // start of window
	input stop);                      // end of window

	reg [(in_width-1):0] in_original;
	reg [(out_width-1):0] out_original;
	reg prev_start;
	reg prev_stop;
	

	always @ (posedge clk) begin
		prev_start <= start;
		prev_stop <= stop;
		if (reset) begin
			in_original <= '0;
			out_original <= '0;
		end
		else if (start && ~prev_start)
			in_original <= in_vec;
		else if (stop && ~prev_stop)
			out_original <= out_vec;
	end

// 
// sequence match is initiated when start rises
//
	property track_in_vector;
		reg [(in_width-1):0] in_changes;
		disable iff (reset)
		@ (posedge clk)
			($rose(start),in_changes = '0)
			|-> (~stop && ((in_change === `MC_TRUE) || $stable(in_vec)), in_changes=(in_changes | (in_original ^ in_vec))) [*1:$] 
			##1 ($rose(stop) &&  (((in_change === `MC_TRUE) && (&in_changes)) || (in_change === `MC_FALSE)) );
	endproperty
//
// sequence match is initiated when stop rises
//
	property track_out_vector;
		reg [(out_width-1):0] out_changes;
		disable iff (reset)
		@ (posedge clk)
			($rose(stop),out_changes = '0)
			|-> (~start && (out_change ===`MC_TRUE || $stable(out_vec)), out_changes=(out_changes | (out_original ^ out_vec))) [*1:$] 
			##1 ($rose(start) && ( ((out_change === `MC_TRUE) && (&out_changes)) || (out_change === `MC_FALSE) ) );
	endproperty
//
// Also assert if start isn't followed by stop and stop isn't followed by start
//
	property mc_window_start_then_stop;
		disable iff (reset)
		@ (posedge clk)
			($rose(start) && ~$rose(stop)) |-> 
			##1 ~$rose(start) [*0:$] 
			##0 $rose(stop);
	endproperty

	property mc_window_stop_then_start;
		disable iff (reset)
		@ (posedge clk)
			($rose(stop) && ~$rose(start)) |-> 
			##1 ~$rose(stop) [*0:$] 
			##0 $rose(start);
	endproperty


	assert property (track_in_vector) 
	else $error("Assertion assert__mc_change_window_in");
	
	assert property (track_out_vector) 
	else $error("Assertion assert__mc_change_window_out");

	assert property (mc_window_start_then_stop) 
	else $error("Assertion assert__mc_change_window_bad");

	assert property (mc_window_stop_then_start) 
	else $error("Assertion assert__mc_change_window_bad");

	cover property (mc_window_start_then_stop) 
	$info("Coverage event cover__FC_change_window_open");

	cover property (mc_window_stop_then_start) 
	$info("Coverage event cover__FC_change_window_close");

	always @ (posedge clk)
		assert ((reset === 1'b1) || ~((~prev_start & start) && (~prev_stop & stop))) 
		else  $error("Assertion assert__mc_change_window_bad");

endmodule

//----------------------------------------------------------------------------  
// change_window1
//
// This is a scalar version of the mc_change_window check described
// above.  It is identical in all particulars except that the signal "input"
// is a scalar that is checked while the window is open; the signal "output"
// is a scalar checked while the window is closed.
//
// Assertions
//
//    mc_change_window1_in   assertion on input inside window
//    mc_change_window1_out  assertion on output outside window
//    mc_change_window1_bad  bad use of "start" and "stop" signals
//
//----------------------------------------------------------------------------  

module mc_change_window1
#(parameter coverage_level = 2,     // sets checking intensity
  parameter in_change = `MC_TRUE,   // in_vec must change inside window?  (boolean)
  parameter out_change = `MC_TRUE)  // out_vec must change outside window?  (boolean)
(
	input clk,
	input reset,
	input siginput,          // checked inside window
	input sigoutput,         // checked inside window
	input start,             // start of window
	input stop);             // end of window

	reg  in_original;
	reg  out_original;
	reg prev_start;
	reg prev_stop;
	

	always @ (posedge clk) begin
		prev_start <= start;
		prev_stop <= stop;
		if (reset) begin
			in_original <= 1'b0;
			out_original <= 1'b0;
		end
		else if (start && ~prev_start)
			in_original <= siginput;
		else if (stop && ~prev_stop)
			out_original <= sigoutput;
	end

//
// Note in both these sequences that we don't check for 'no changes' until the 
// end of the window period (out or in) - although any change within the window 
// is an immediate invalidating event
// This behavior is slightly different from the original, it is a workaround
// necessary at the time of writing and could be changed.
// 
// sequence match is initiated when start rises

	property track_in_vector;
		reg in_changes;
		disable iff (reset)
		@ (posedge clk)
			($rose(start),in_changes = 1'b0)
			|-> (~stop && ((in_change === `MC_TRUE) || $stable(siginput)) , in_changes=(in_changes | (in_original ^ siginput))) [*1:$] 
			##1 ($rose(stop) &&  (((in_change === `MC_TRUE) && in_changes) || (in_change === `MC_FALSE)) );
	endproperty

// sequence match is initiated when stop rises

	property track_out_vector;
		reg out_changes;
		disable iff (reset)
		@ (posedge clk)
			($rose(stop),out_changes = 1'b0)
			|-> (~start && ((out_change === `MC_TRUE) || $stable(sigoutput)), out_changes=(out_changes | (out_original ^ sigoutput))) [*1:$] 
			##1 ($rose(start) && (((out_change === `MC_TRUE) && out_changes) || (out_change === `MC_FALSE)) );
	endproperty
//
// It's bad if: 
//  start and stop rise on the same clock
//  start isn't followed by stop;
//  stop isn't followed by start
// This catches the same errors as the original but asserts slightly differently
//

	property mc_window_start_then_stop;
		disable iff (reset)
		@ (posedge clk)
			($rose(start) && ~$rose(stop)) |-> 
			##1 ~$rose(start) [*0:$] 
			##0 $rose(stop);
	endproperty

	property mc_window_stop_then_start;
		disable iff (reset)
		@ (posedge clk)
			($rose(stop) && ~$rose(start)) |-> 
			##1 ~$rose(stop) [*0:$] 
			##0 $rose(start);
	endproperty


	assert property (track_in_vector) 
	else $error("Assertion assert__mc_change_window1_in");

	assert property (track_out_vector) 
	else $error("Assertion assert__mc_change_window1_out");

	assert property (mc_window_start_then_stop) 
	else $error("Assertion assert__mc_change_window1_bad");

	assert property (mc_window_stop_then_start) 
	else $error("Assertion assert__mc_change_window1_bad");

	cover property (mc_window_start_then_stop) 
	$info("Coverage event cover__FC_change_window1_open");
	cover property (mc_window_stop_then_start) 
	$info("Coverage event cover__FC_change_window1_close");

	always @ (posedge clk)
		assert ((reset === 1'b1) || ~((~prev_start & start) && (~prev_stop & stop))) 
		else  $error("Assertion assert__mc_change_window1_bad");

endmodule

//----------------------------------------------------------------------------
// decrement
//
// If "reg" changes on a cycle in which "enable" is high, it must change
// again within "min_time" to "max_time" cycles, and it must decrement by an
// amount between "min_decr" and "max_decr".
//
// Assertions
//
// mc_decrement_time   asserts for a time violation (min_time/max_time)
// mc_decrement_value  asserts for a bad value (min_decr/max_decr) 
//
//----------------------------------------------------------------------------

module mc_decrement
#(parameter integer coverage_level = 2,                 // sets checking intensity
  parameter integer width = 0,
  parameter integer min_time = 1,
  parameter integer max_time = 1,
  parameter integer min_decr = 1,
  parameter integer max_decr = 1)
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,
	input enable);   

    integer FA_decrement_bound_hi = -1;
    integer FA_decrement_bound_lo = -1;

    reg [(width-1):0] min_decrement = min_decr; // Keep the math to width bits
    reg [(width-1):0] max_decrement = max_decr; // Keep the math to width bits

    property mc_decrement_time;
		int x;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            ((~$stable(sigreg) && (enable===1'b1)),x=0) |-> 
			##1 ((($stable(sigreg)),x=x+1) [*(min_time-1):(max_time-1)]) 
			##1 (~$stable(sigreg),record_bounds(x+1));
    endproperty

    assert property (mc_decrement_time) 
	else $error("Assertion assert__mc_decrement_time");

// Original was written as a 'never', rewritten here in the 'always' sense

    property mc_decrement_value;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            (enable === 1'b0) 
            || $stable(sigreg)
			|| ( (sigreg <= ($past(sigreg,1) - min_decrement)) && ( sigreg >= ($past(sigreg,1)-max_decrement) ));
    endproperty

    assert property (mc_decrement_value) 
	else $error("Assertion assert__mc_decrement_value");

    cover property (mc_decrement_time) 
	$info("Coverage event cover__FC_decrement");

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

	always @ (posedge clk) begin
		FA_decrement_bound_lo = record_bounds.low_bound;
		FA_decrement_bound_hi = record_bounds.high_bound;
	end


endmodule

//----------------------------------------------------------------------------
// delta
//
// If "reg" changes on a cycle in which "enable" is high, it must change
// again within "min_time" to "max_time" cycles, and it must increment or
// decrement by an amount between "min_delta" and "max_delta".
//
// Assertions
//
// mc_delta_time   asserts for a time violation (min_time/max_time)
// mc_delta_value  asserts for a bad value (min_delta/max_delta) 
//
//----------------------------------------------------------------------------

module mc_delta
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer width = 1,
  parameter integer min_time = 1,
  parameter integer max_time = 1,
  parameter integer min_delta = 1,
  parameter integer max_delta = 1)
(
    input clk,
	input reset,
	input [(width-1):0] sigreg,
	input enable);
    integer FA_delta_bound_hi = -1;
    integer FA_delta_bound_lo = -1;

    reg [(width-1):0] min_delt = min_delta; // Keep the math to width bits
    reg [(width-1):0] max_delt = max_delta; // Keep the math to width bits	
	reg [(width-1):0] prev_sigreg = '0;
	reg [(width-1):0] change = '0;

	always @ (posedge clk)
		prev_sigreg <= sigreg;

	always @ (sigreg or prev_sigreg)
		if (prev_sigreg >= sigreg)
			change = prev_sigreg - sigreg;
		else
			change = sigreg - prev_sigreg;

    property mc_delta_time;
		int x;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            ((~$stable(sigreg) && (enable===1'b1)),x=0) |-> 
			##1 ((($stable(sigreg)),x=x+1) [*(min_time-1):(max_time-1)]) 
			##1 (~$stable(sigreg),record_bounds(x+1));
    endproperty

    assert property (mc_delta_time) 
	else $error("Assertion assert__mc_delta_time");

    property mc_delta_value;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            (enable === 1'b0) 
            || $stable(sigreg)
			|| (change >=min_delt) && (change <= max_delt);
    endproperty

    assert property (mc_delta_value) 
	else $error("Assertion assert__mc_delta_value");

    cover property (mc_delta_time) 
	$info("Coverage event cover__FC_delta");


//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

	always @ (posedge clk) begin
		FA_delta_bound_lo = record_bounds.low_bound;
		FA_delta_bound_hi = record_bounds.high_bound;
	end


endmodule

//----------------------------------------------------------------------------
// fifo (mc_fifo, mc_fifo_check_values)
//
// Checks that the FIFO does not overflow or underflow, optionally checks
// value integrity of the FIFO.  The FIFO is written when "enqueue" is
// asserted on positive edge of clock, read when "dequeue" is asserted on
// positive edge of clock.
//
// Value Integrity Check
//
// When "check_values" is true, the checker models the FIFO faithfully and
// checks that the "dequeue_data" input is what is expected as FIFO output.
// The "mc_fifo_value" property asserts when an unexpected value is
// detected.  This property is checked 1 cycle AFTER the assertion of
// "dequeue" -- at which point the FIFO output has been driven from the
// checker's internal model of a synchronous FIFO, based upon previous data
// input ("enqueue_data") and control ("enqueue" and "dequeue") given to the
// checker.
//
// When "check_values" is false, the "enqueue_data" and "dequeue_data"
// are ignored.
//
// Simultaneous Read/Write (Dequeue/Enqueue)
// 
// The parameter "rw_type" indicates whether simultaneous read-write is
// allowed and what happens:
//
//    0 == mc_rw_error       it is an error to assert read/write
//                           (dequeue/enqueue) on the same cycle
//    1 == mc_rw_writefirst  write (enqueue) takes precedence
//    2 == mc_rw_readfirst   read (dequeue) takes precedence
// 
// Reset
//
// Reset clears the FIFO of all values and disables all control while reset
// is asserted.
//
// Assertions
//
// mc_fifo_value      asserts with a value mismatch
// mc_fifo_underflow  asserts with underflow (read empty FIFO)
// mc_fifo_overflow   asserts with overflow (write full FIFO)
// mc_fifo_control    bad control signals (simultaneous read/write if
//                    rw_type = 0(i.e. mc_rw_error))
//
//----------------------------------------------------------------------------

module mc_fifo
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer width = 0,                    // width of data vectors
  parameter integer depth = 0,                    // # elements in FIFO
  parameter integer rw_type = `MC_RW_ERROR,       // simultaneous r/w? Default: mc_rw_error
  parameter integer check_values = `MC_FALSE)     // model FIFO and check_values, Default: FALSE        
(
	input clk,
	input reset,
	input enqueue,                                // write enable
	input dequeue,                                // read enable
	input [(width-1):0] enqueue_data,
	input [(width-1):0] dequeue_data);

	int fifo_count = 0;
	integer FA_fifo_bound_hi = -1;

// This is a checker for a simple, synchronous FIFO.
// The overflow/underflow checking is simple.
// The checker maintains a count of how many data items are currently in the FIFO.
// When 'reset' is asserted, this count goes to 0.
// When 'enqueue' is asserted, the count is incremented and when 
// 'dequeue' is asserted, the count is decremented. The count must never 
// exceed the FIFO size, 'depth' and it must never decrement below 0. Thus
// the rules are simple, the only complication is when 'enqueue' and 'dequeue'
// occur at the same time.
//

//
// The equations for fifo_count
// enqueue and dequeue together may or may not be legal,
// but in all such cases fifo_count stays the same. The error
// is detected in the assertion.
// Outside of reset, fifo_count only changes for valid assertions of enqueue
// by itself, or dequeue by itself.
// 

	always @ (posedge clk) begin
		if (reset === 1'b1)
			fifo_count <= 0;
		else if (( enqueue & ~dequeue) && (fifo_count != depth)) begin
				fifo_count <= fifo_count + 1;
				if (FA_fifo_bound_hi < fifo_count+1)
					FA_fifo_bound_hi = fifo_count+1;
		end
		else if ((dequeue & ~enqueue) && (fifo_count != 0))
				fifo_count <= fifo_count - 1;
	end

//
// underflow is when the count is 0 with a dequeue AND 
// (there is no enqueue OR we get simultaneous enqueue and read goes first)
//

	property mc_fifo_underflow;
		disable iff (reset === 1'b1)
		@ (posedge clk) not
			(dequeue && (fifo_count == 0)) && (~enqueue || (enqueue &&(rw_type == `MC_RW_READFIRST)));
	endproperty

	assert property (mc_fifo_underflow) 
	else $error("Assertion assert__mc_fifo_underflow");

//
// overflow is when we get an enqueue when full, AND
// (there is no dequeue OR there is a dequeue but it's write first)
//
	property mc_fifo_overflow;
		disable iff (reset === 1'b1)
		@ (posedge clk) not
			(enqueue && (fifo_count == depth)) && (~dequeue || (dequeue &&(rw_type == `MC_RW_WRITEFIRST)));
	endproperty

	assert property (mc_fifo_overflow) 
	else $error("Assertion assert__mc_fifo_overflow");
// 
// A control error occurs when the rw_type is `MC_RW_ERROR if dequeue and 
// enqueue occur simultaneously
//

	generate 
		if (rw_type === `MC_RW_ERROR) begin: fifo_control

			property mc_fifo_control_error;
				disable iff (reset === 1'b1)
				@ (posedge clk) not
					(dequeue & enqueue && (rw_type == `MC_RW_ERROR) );
			endproperty
		
			assert property (mc_fifo_control_error)
				else $error("Assertion assert__mc_fifo_control");
		end
	endgenerate
//
// Next is the value-checking stuff.
// This is only turned on if check_values is true.
// To check values, we have to mirror the FIFO, and do everything
// it does, which means we neeed a real memory
//
	generate 
		if (check_values == `MC_TRUE) begin: fifo_model
			reg [(width-1):0] fifo_mirror [(depth-1):0];
			reg [(width-1):0] fifo_mirror_out;
			int read_addr = 0;
			int write_addr = 0;

			always @ (posedge clk) begin
				if (reset) begin
					read_addr <= 0;
					write_addr <= 0;
				end
//
// We use the same algorithm as above to determine what to do with the data 
// and pointers. We can use fifo_count since we already derived it
// First the simple write case:
//
				else if (( enqueue & ~dequeue) && (fifo_count != depth)) begin
					fifo_mirror[write_addr] <= enqueue_data;
					if (write_addr === depth-1)
						write_addr <= 0;
					else
						write_addr <= write_addr + 1;
				end
//
// then the simple read case
//
				else if ((dequeue & ~enqueue) && (fifo_count != 0)) begin
					if (read_addr === depth - 1)
						read_addr <= 0;
					else
						read_addr <= read_addr + 1;
					fifo_mirror_out <= fifo_mirror[read_addr];
				end
// then the read-write case, read first
				else if ((dequeue & enqueue) && (fifo_count !=0) && (rw_type === `MC_RW_READFIRST)) begin
					if (read_addr === depth - 1)
						read_addr <= 0;
					else
						read_addr <= read_addr + 1;
					fifo_mirror_out <= fifo_mirror[read_addr];
					fifo_mirror[write_addr] <= enqueue_data;
					if (write_addr === depth-1)
						write_addr <= 0;
					else
						write_addr <= write_addr + 1;
				end
// then the read-write case, write first
				else if ((dequeue & enqueue) && (fifo_count != depth) && (rw_type === `MC_RW_WRITEFIRST)) begin
					fifo_mirror[write_addr] <= enqueue_data;
					if (write_addr === depth-1)
						write_addr <= 0;
					else
						write_addr <= write_addr + 1;
					if (read_addr === depth - 1)
						read_addr <= 0;
					else
						read_addr <= read_addr + 1;
					fifo_mirror_out <= fifo_mirror[read_addr];
				end
			end // always @ (posedge clk)

			property mc_fifo_value;
				disable iff (reset === 1'b1)
				@ (posedge clk)
					(dequeue === 1'b1) |=> (fifo_mirror_out === dequeue_data);
			endproperty

			assert property (mc_fifo_value) 
			else $error("Assertion assert__mc_fifo_value");
		end // check_values true
	endgenerate
//
// Coverage of simultaneous R/W when it isn't an error
//
	generate
		if (rw_type !== `MC_RW_ERROR) begin: fifo_simultaneous_rw

			property mc_fifo_simultaneous_rw;
			disable iff (reset === 1'b1)
			@ (posedge clk)
				((enqueue === 1'b1) && (dequeue === 1'b1));
			endproperty

			cover property (mc_fifo_simultaneous_rw)
			$info("Coverage event cover__FC_fifo_simultaneous_rw");

		end // rw_type not MC_RW_ERROR
	endgenerate

//
// Functional coverage
// Was there a dequeue request?
// Did the queue ever go to empty?
// Was there an enqueue request?
// Did the queue ever go to full?

	property mc_fifo_pop;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			dequeue === 1'b1;
	endproperty

	property mc_fifo_empty;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			((dequeue === 1'b1) |-> ##1 (fifo_count === 0));
	endproperty

	property mc_fifo_push;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			enqueue === 1'b1;
	endproperty

	property mc_fifo_full;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			((enqueue === 1'b1) |-> ##1 (fifo_count === depth));
	endproperty

	cover property (mc_fifo_pop)
	$info("Coverage event cover__FC_fifo_pop");

	cover property (mc_fifo_empty)
	$info("Coverage event cover__FC_fifo_empty");

	cover property (mc_fifo_push)
	$info("Coverage event cover__FC_fifo_push");

	cover property (mc_fifo_full)
	$info("Coverage event cover__FC_fifo_full");

endmodule

//--------------------------------------------------------------------------
// follows
//
// Follower signal must assert within "min" to "max" cycles after the
// assertion of the leader signal.  A "min" of 0 implies that follower and
// leader must assert on the same signal.
//
// The parameter "hold_leader", when set to "true", requires that the leader
// continue to be asserted until the follower asserts.
//
//--------------------------------------------------------------------------

module mc_follows
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer min = 0,                    // min cycles to follow
  parameter integer max = 0,                    // max cycles to follow
  parameter bit hold_leader = `MC_FALSE)    // leader must hold? (boolean)
(
	input clk,
	input reset,
	input leader,
	input follower);

	integer FA_follows_bound_hi;
	integer FA_follows_bound_lo;
	
// 
// Assumes 1-bit leader and follower
//

	property mc_follows;
		int x;
		disable iff (reset)
		@ (posedge clk)
			($rose(leader), x=0) |-> 
			(~follower && ((hold_leader & leader) || (~hold_leader)),x=x+1) [*min:max] ##1 ($rose(follower),record_bounds(x));
	endproperty

	assert property (mc_follows)
	else $error("Assertion assert__mc_follows");

//
// Coverage
//

	cover property (mc_follows)
	$info("Coverage event FC_follows");
	

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

//
// The update_hold_periods event serves to synchronize the static values in the 
// function with the variables at module scope.
// This is only used so that the existing test infrastructure works
// 
//
	always @ (posedge clk) begin
		FA_follows_bound_lo = record_bounds.low_bound;
		FA_follows_bound_hi = record_bounds.high_bound;
	end

endmodule

//----------------------------------------------------------------------------
// gray_code
//
// Checks that a register changes by 1 and only 1 bit with each change.  This
// is equivalent to "mc_hamming_dist" with distance = 1.
//
// It is advisable that "reset" be asserted at the beginning of simulation to
// avoid an assertion with the first assignment to the register.
//
// The check will never assert in reset, but the current value is always
// compared to the previous value on the previous clock edge, regardless of
// whether the previous clock edge was in reset or not.
//
//           -----\ /---------\ /----
// reg        111  X  000      X  110
//           -----/ \---------/ \----
//
// clk       \__/--\__/--\__/--\__/--
//
// reset     ______/-----------\_____
//
// gray_code _____________________V__
// 
// In the case illustrated above, the value coming out of reset (110) is in
// violation compared to (000), which was a value change made during reset.
// Note that the change (111) to (000) does not assert, and that the value
// sampled prior to reset (111) represents a correct gray code change
// compared to the value change after reset (110), but the value prior to
// reset is not preserved for purposes of the check after reset; values are
// compared always to the value on the previous clock edge.
// 
//----------------------------------------------------------------------------

module mc_gray_code
#(parameter integer coverage_level = 2,        // sets checking intensity
  parameter integer width = 0)                 // Width of register/vector
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);

	reg [(width-1):0] prev_reg;
//
// Uses immediate assertion syntax and a variable to hold previous value
//

	always @ (posedge clk) begin
		prev_reg <= sigreg;
		if (reset === 1'b0)
			assert($countones(sigreg ^ prev_reg) < 2)
			else $error("Assertion assert__mc_gray_code");
	end
//
// The coverage checks that there was at least one change when reset was false
//

	property mc_gray_code(sigreg, prev_reg);
		@ (posedge clk)
			((reset === 1'b0) && (sigreg !== prev_reg));
	endproperty

	cover property (mc_gray_code(sigreg, prev_reg)) 
	$info("Coverage event cover__FC_gray_code");

endmodule

//----------------------------------------------------------------------------
// hamming_distance
//
// Checks that a register changes by "distance" bits with each change.
//
// It is advisable that "reset" be asserted at the beginning of simulation to
// avoid an assertion with the first assignment to the register.
// 
// The check will never assert in reset, but the current value is always
// compared to the previous value on the previous clock edge, regardless of
// whether the previous clock edge was in reset or not.
// 
// For more detail on reset behavior, see the comments above for the
// "gray_code" checker, which is logically equivalent to "hamming_dist" with
// "distance" equal to 1.
//----------------------------------------------------------------------------

module mc_hamming_dist
#(parameter integer coverage_level = 2,        // sets checking intensity
  parameter integer width = 0,                 // width of reg
  parameter integer distance = 0)              // number of bits that can change
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);
	reg [(width-1):0] prev_reg;
//
// Uses immediate assertion syntax and a variable to hold previous value
//

	always @ (posedge clk) begin
		prev_reg <= sigreg;
		if (reset === 1'b0)
			assert(($countones(sigreg ^ prev_reg) === distance) || ($countones(sigreg ^ prev_reg) === 0))
			else $error("Assertion assert__mc_hamming_dist");
	end
//
// The coverage checks that there was at least one change when reset was false
//

	property mc_hamming_dist(sigreg, prev_reg);
		@ (posedge clk)
			((reset === 1'b0) && (sigreg !== prev_reg));
	endproperty

	cover property (mc_hamming_dist(sigreg, prev_reg)) 
	$info("Coverage event cover__FC_hamming_distance");
endmodule

//----------------------------------------------------------------------------
// hold_period
//
// Signal must hold for "min" cycles after being asserted.
// If (max >= min) then the signal must deassert at max
// The assertion must occur when "enable" is true for the checker to activate.
//
// change = 0 trumps max, ie if change is false then sig asserted beyond max
// is not an error. This implements the same functionality as the original
// implementation and conforms to the specification; however, the specification
// is overconstrained.
//
// When reset is true or goes true the sequence is aborted and neither 
// assertions nor coverage are recorded.
// The enable input is tested only as part of the antecedent.
// The integers FA_hold_period_bound_lo and FA_hold_period_bound_hi record
// the lowest and highest hold periods seen, respectively
//
//----------------------------------------------------------------------------
/*	class abcd;
		int a;
	endclass
*/
module mc_hold_period
#(parameter integer coverage_level = 2,        // sets checking intensity
  parameter integer min = 0,                   // min cycles to hold
  parameter integer max = 0,                   // max cycles to hold
  parameter change = `MC_FALSE)                // must de-assert after holding? (boolean)
(
	input clk,
	input reset,
	input sig,                                 // signal to check
	input enable);                             // enable for check
	
	integer FA_hold_period_bound_lo;
	integer FA_hold_period_bound_hi;

	event update_hold_periods;	

	class abc;
		int a;
	endclass

//
// The specification is analyzed as follows
// There are two separate behaviors implied, either a basic meets-minimum-hold 
// or a meets-minimum-hold AND doesn't-exceed-maximum-hold.
// The truth table of (valid maximum specified, i.e. max>=min) against (change) 
// is used to determine which behavior is required:
//
// !max_valid & !change implies simple hold check
// !max_valid &  change is an error
//  max_valid & !change implies simple hold check (though is actually ambiguous;
//  value of max is ignored)
//  max_valid &  change implies both minimum hold check and maximum hold check
//
// Basic property structure uses an antecedent implication (sig goes true)
// that isn't asserted on failure but initiates the check.
// 
// There are two separate properties and we assert one or the other depending on
//  the above truth table
// This has the disadvantage that it creates generated block names, making it 
// hard to match the original results.
// It would be possible to include the truth table logic within the properties,
// and have only one assertion, but the overall structure would be less clear.
// 
// Coverage notes
//
// What are min and max bounds? Depends somewhat if you're interested in failing
// cases as well as passing cases.
// Let's assume that, since failing cases are already covered by assertion, 
// we're only really interested in passing cases.
// We use local variable x to increment on clk during the sequence.
// When a hold time is known, i.e. sig goes to zero, we send the accumulated 
// value of local variable x to the record_bounds function
// Note, this won't catch the case where sig never goes low.
//

	property p_meets_min_hold;
		int x;
		disable iff (reset === 1'b1)
		@ (posedge clk) 
			((enable === 1'b1) && $rose(sig),x=0) |-> 
			((sig === 1'b1),x=x+1) [* min:$] 
			##1 (sig === 1'b0,record_bounds(x)) ;
	endproperty

	property p_meets_min_and_max_hold;
		int x;
		disable iff (reset == 1'b1)
		@ (posedge clk) 
			((enable === 1'b1) && $rose(sig),x=0) |-> 
			((sig === 1'b1),x=x+1) [* min:max] 
			##1 (sig === 1'b0,record_bounds(x));
	endproperty

	if (!change) begin: check_min_hold // simple case - only required to check for minimum hold
		assert property (p_meets_min_hold)
		else $error("Assertion assert__mc_hold_period");

		cover property (p_meets_min_hold) 
		begin 
			$info("Coverage event cover__FC_hold_period"); 
			-> update_hold_periods; 
		end
	end

	if (change && (max >= min)) begin: check_min_and_max_hold // check for minimum hold AND maximum hold
		assert property (p_meets_min_and_max_hold)
		else $error("Assertion assert__mc_hold_period");

		cover property (p_meets_min_and_max_hold) 
		begin 
			$info("Coverage event cover__FC_hold_period"); 
			-> update_hold_periods; 
		end
	end

	initial begin
		if (change && (max<min))
			$display("%m - Invalid parameters, hold max of %d is less than min of %d, with change true",max,min);
	end

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

//
// The update_hold_periods event serves to synchronize the static values in the 
// function with the variables at module scope.
// This is only used so that the existing test infrastructure works
// 
//
	always @ (update_hold_periods) begin
		FA_hold_period_bound_lo = record_bounds.low_bound;
		FA_hold_period_bound_hi = record_bounds.high_bound;
	end

endmodule


//----------------------------------------------------------------------------
// increment
//
// If "reg" changes on a cycle in which "enable" is high, it must change
// again within "min_time" to "max_time" cycles, and it must increment by an
// amount between "min_decr" and "max_decr".
//
// Assertions
//
// mc_increment_time   asserts for a time violation (min_time/max_time)
// mc_increment_value  asserts for a bad value (min_decr/max_decr) 
//
//----------------------------------------------------------------------------

module mc_increment
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer width = 0,
  parameter integer min_time = 1,
  parameter integer max_time = 1,
  parameter integer min_incr = 1,
  parameter integer max_incr = 1)
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,
	input enable); 
    integer FA_increment_bound_hi = -1;
    integer FA_increment_bound_lo = -1;

    reg [(width-1):0] min_increment = min_incr; // Keep the math to width bits
    reg [(width-1):0] max_increment = max_incr; // Keep the math to width bits

    property mc_increment_time;
		int x;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            ((~$stable(sigreg) && (enable===1'b1)),x=0) |-> 
			##1 ((($stable(sigreg)),x=x+1) [*(min_time-1):(max_time-1)]) 
			##1 (~$stable(sigreg),record_bounds(x+1));
    endproperty

    assert property (mc_increment_time) 
	else $error("Assertion assert__mc_increment_time");

// Original was written as a 'never', rewritten here in the 'always' sense

    property mc_increment_value;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            (enable === 1'b0) 
            || $stable(sigreg)
			|| ( (sigreg >= ($past(sigreg,1) + min_increment)) && ( sigreg <= ($past(sigreg,1) + max_increment) ));
    endproperty

    assert property (mc_increment_value) 
	else $error("Assertion assert__mc_increment_value");

    cover property (mc_increment_time) 
	$info("Coverage event cover__FC_increment");

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

	always @ (posedge clk) begin
		FA_increment_bound_lo = record_bounds.low_bound;
		FA_increment_bound_hi = record_bounds.high_bound;
	end

endmodule

//----------------------------------------------------------------------------
// memory (mc_memory, mc_memory_check_values)
//
// Various checks made of a simple single-port synchronous memory, that reads
// or writes when "enable" is asserted, with "rw" = '1' indicating a write;
// "rw" = '0' indicating a read.  
//      
// The following checks are always made:
//    * Address out-of-bounds.
//    * Read of uninitialized data.
//      
// And these are made optionally, controlled by generic parameters:
//    * precious_data: check that memory is not overwritten before read.
//    * volatile_data: check that memory is not read twice after write
//    * value: model the memory to check that data output matches what is
//      expected.
//
// Value Integrity Check
//
// When "check_values" is true, the checker models the memory faithfully and
// checks that the "data_out" input is what is expected as memory output .
// The "mc_memory_value" property asserts when an unexpected value is
// detected.  This property is checked 1 cycle AFTER the assertion of read
// control (enable = '1' AND rw = '0') -- at which point the memory output
// has been driven from the checker's internal model of the memory, based
// upon previous data input ("data_in") and control given to the checker.
//
// When "check_values" is false, the "enqueue_data" and "dequeue_data"
// are ignored.
// 
// Reset
// Unlike the original, reset sets the memory bits to 'x.
// 
// Assertions
//
// mc_memory_uninitialized  asserts for read before write at address
//                          (read of uninitialized data)
// mc_memory_precious_data  if precious_data = true: asserts for
//                          write-write at address (write of data before
//                          being read)
// mc_memory_volatile       if volatile_data = true: asserts if
//                          write-read-read at address (if data written
//                          is read more than once)
// mc_memory_address        asserts for address out-of-bounds
// mc_memory_value          if check_values = true: asserts if "data_out"
//                          is not expected value on read
//
//----------------------------------------------------------------------------

module mc_memory
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer width = 0,                    // width of the memory
  parameter integer start_addr = 0,               // start address of memory
  parameter integer memory_size = 0,              // number of words in memory
  parameter precious_data = `MC_FALSE,            // precious data check (see above), Default: FALSE
  parameter volatile_data = `MC_FALSE,            // volatile data check (see above), Default: FALSE          
  parameter integer check_values = `MC_FALSE)     // check_values, Default: FALSE        
(
	input clk,
	input reset,
	input enable,                          // enable read/write
	input RW,                              // '1' write, '0' read
    input [31:0] addr,                     // address as integer
	input [(width-1):0] data_in,
	input [(width-1):0] data_out);
//
// local variables
//
	int mem_written [(memory_size-1):0];
	reg addr_valid;
	integer FA_memory_bound_lo = -1;
	integer FA_memory_bound_hi = 0;
	integer FA_memory_bound_write = 0;
	integer FA_memory_bound_read = 0;
	integer FA_memory_omissions = 0;

//
// Address out of bounds is straightforward.
//
// For the 'check_values' we will have to replicate the memory. 
// For the 'uninitialized', 'precious_data' and 'volatile' we have to track
// status on a per-address basis
// We can do that on an as-needed basis, creating instances each time, or
// create arrays of the right size from the beginning.
// The first technique might be preferable for a sparsely and rarely used
// memory, but if there is heavy memory usage, the second technique is
// probably better.
//

// The validity of memory depends on whether it has yet been written and
// on precious_data and volatile_data settings. Validity always initializes
// to 0. Other transitions are as follows:

	initial begin
		initialize_model;
	end

	assign addr_valid = (($unsigned(addr) >= $unsigned(start_addr)) 
			&& ($unsigned(addr) < $unsigned(start_addr + memory_size)));

//
// Always test for read-before-write
// Record whether every location has been written, then assert
// if an unwritten location is read.
//

	always @ (posedge clk)	begin
		if (reset)
			initialize_model;
		else if ( (addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b1)) // Write
			mem_written[addr-start_addr] <= `MC_TRUE;
	end

	property mc_memory_uninitialized;
		disable iff (reset)
		@ (posedge clk)
			((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b0)) |-> ((mem_written[addr - start_addr] == `MC_TRUE));
	endproperty

	assert property (mc_memory_uninitialized) 
	else $error("Assertion assert__mc_memory_uninitialized");

	function void initialize_model;
		int i;
		for (i=0; i< memory_size; i=i+1) begin
			mem_written[i] = `MC_FALSE;
		end
	endfunction
//
// Always test for address out of range
// 

	property mc_memory_address;
		disable iff (reset)
		@ (posedge clk)
			(enable === 1'b1) |-> (addr_valid === 1'b1);
	endproperty

	assert property (mc_memory_address)
	else $error("Assertion assert__mc_memory_address");

//
// if precious_data is true
//
	generate
		begin: written_block	// technically unnecessary hierarchy, but matches the original
								// and therefore makes checking against it easier
		if (precious_data === `MC_TRUE) begin: precious_data_check
		int precious_write_ok [(memory_size-1):0];
		int i,j;

			initial begin
				for (i=0; i< memory_size; i=i+1) begin
				precious_write_ok[i] = `MC_TRUE;
				end
			end

			always @ (posedge clk)	begin
				if (reset) begin
					for (j=0; j< memory_size; j=j+1) begin
					precious_write_ok[j] = `MC_TRUE;
					end
				end
				else if ((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b0))// Read
					precious_write_ok[addr-start_addr] <= `MC_TRUE;
				else if ((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b1)) // Write
					precious_write_ok[addr-start_addr] <= `MC_FALSE;
			end
		property mc_memory_precious_data;
			disable iff (reset)
			@ (posedge clk)
				((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b1)) |-> 
					((precious_write_ok[addr-start_addr] === `MC_TRUE));
		endproperty

		assert property (mc_memory_precious_data) 
		else $error("Assertion assert__mc_memory_precious_data");
		end
//
// if volatile_data is true
// (note we don't check if mem_written is false as this duplicates the initialized check)
//
		if (volatile_data === `MC_TRUE) begin: volatile_data_check
		int volatile_read_ok [(memory_size-1):0];
		int i, j;

			initial begin
				for (i=0; i< memory_size; i=i+1) begin
				volatile_read_ok[i] = `MC_FALSE;
				end
			end

			always @ (posedge clk)	begin
				if (reset) begin
					for (j=0; j< memory_size; j=j+1) begin
					volatile_read_ok[j] = `MC_FALSE;
					end
				end
				else if ((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b0))// Read
					volatile_read_ok[addr-start_addr] <= `MC_FALSE;
				else if ((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b1)) // Write
					volatile_read_ok[addr-start_addr] <= `MC_TRUE;
			end
		property mc_memory_volatile_data;
			disable iff (reset)
			@ (posedge clk)
				((addr_valid == 1'b1) && (enable === 1'b1) && (RW== 1'b0) && (mem_written[addr-start_addr] == `MC_TRUE)) |-> 
					((volatile_read_ok[addr-start_addr] === `MC_TRUE));
		endproperty

		assert property (mc_memory_volatile_data) 
		else $error("Assertion assert__mc_memory_volatile_data");

		end
		end
	endgenerate

//
// if check_values is true
//
	generate
		if (check_values === `MC_TRUE) begin: memory_model
			reg[(width-1):0] memory_model [(memory_size-1):0];
			reg[(width-1):0] memory_model_out;
			int i,j;
			
			initial begin
				for (i=0; i< memory_size; i=i+1) begin
					memory_model[j] = 'x;
				end
			end

			always @ (posedge clk) begin
				if (reset === 1'b1)	begin
					for (i=0; i< memory_size; i=i+1) begin
						memory_model[j] = 'x;
					end
				end
				else if ( (addr_valid == 1'b1) && (enable === 1'b1) && (RW == 1'b1)) // write
					memory_model[addr-start_addr] <= data_in;
				else if ( (addr_valid == 1'b1) && (enable === 1'b1) && (RW == 1'b0)) // read
					memory_model_out <= memory_model[addr-start_addr];
			end

			property mc_memory_value;
				disable iff (reset)
				@ (posedge clk)
					( (addr_valid == 1'b1) && (enable === 1'b1) && (RW == 1'b0)) |-> ##1 (memory_model_out === data_out);
			endproperty
	
			assert property (mc_memory_value) 
			else $error("Assertion assert__mc_memory_value");
		end
	endgenerate
//
// Coverage
// As with the original, we record reads and writes even when the address is invalid.
//
	property mc_memory_read;
		disable iff (reset)
		@ (posedge clk)
			((enable === 1'b1) && (RW == 1'b0));
	endproperty

	property mc_memory_write;
		disable iff (reset)
		@ (posedge clk)
			((enable === 1'b1) && (RW == 1'b1));
	endproperty

	cover property (mc_memory_read)
	$info("Coverage event FC_memory_read");

	cover property (mc_memory_write)
	$info("Coverage event FC_memory_write");

//
// We also track:
//	FA_memory_bound_hi - highest address seen (when enabled and not reset, but including invalid)
// 	FA_memory_bound_lo - lowest address seen (when enabled and not reset, but including invalid)
//	FA_memory_bound_write - number of valid writes to unique addresses
//	FA_memory_bound_read - number of valid reads from unique addresses
//	FA_memory_bound_omissions - valid writes - valid reads
//
// Note that these are all reset by 'reset'
// This behavior is similar to the original.
// 

	generate
		if (coverage_level >= 2) begin
			always @ (posedge clk) begin
				if (reset === 1'b1) begin
    				FA_memory_bound_lo = -1;
    				FA_memory_bound_hi = 0;
	    			FA_memory_bound_write = 0;
	    			FA_memory_bound_read = 0;
    				FA_memory_omissions = 0;
				end
				else if (enable === 1'b1) begin
					if (FA_memory_bound_lo == -1)
						 FA_memory_bound_lo = addr;
					else if (FA_memory_bound_lo > addr)
						 FA_memory_bound_lo = addr;
					if (FA_memory_bound_hi < addr)
						 FA_memory_bound_hi = addr;
					if ((addr_valid == 1'b1) && (mem_written[addr-start_addr] == `MC_FALSE) && (RW== 1'b1)) begin
						FA_memory_bound_write = FA_memory_bound_write +1;
						FA_memory_omissions = FA_memory_omissions + 1;
					end
					if ((addr_valid==1'b1) && (mem_written[addr-start_addr] == `MC_TRUE) && (RW== 1'b0)) begin // Read
						FA_memory_bound_read = FA_memory_bound_read +1;
						FA_memory_omissions = FA_memory_omissions - 1;
					end
				end
			end
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------
// one_cold
// 
// Checks that a register has 1 and only 1 bit de-asserted on every cycle; if
// "strict" is true, the register may never have 0 bits de-asserted.
//
//----------------------------------------------------------------------------

module mc_one_cold
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer width = 0,                  // Width of reg
  parameter strict = `MC_TRUE)                  // true ==> never 0 bits de-asserted (boolean)
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);
	int covercount;

// The assertion
// Immediate assertion syntax is used
// NB the $error user text is strictly designed to match the PSL output, to 
// make comparison between test output easy


	always @ (posedge clk) begin
		if (!reset && (strict == `MC_TRUE))
			assert ($onehot(~sigreg))
			else $error("Assertion assert__mc_one_cold");
		else if (!reset)
			assert ($onehot0(~sigreg))
			else $error("Assertion assert__mc_one_cold");
	end
// The functional coverage
// First check that each bit has been 0

	generate
		genvar index;
		property FC_one_cold(sigreg_bit);
			disable iff (reset) 
			@ (posedge clk)
				sigreg_bit === 1'b0;
		endproperty

		for (index=0; index < width; index++) 
		begin:FC_cld // mis-spelling of cold to match original PSL/Verilog test
			cover property (FC_one_cold(sigreg[index]))
			$info("Coverage event cover__FC_one_cold");
		end
	endgenerate


// Cover the zero-colds case where strict is false
// 
	generate
		if (strict == `MC_FALSE) begin: no_colds

		property FC_one_cold_corner (sigreg);
			disable iff (reset)
			@ (posedge clk)
				(~sigreg) === '0; // workaround!

		endproperty
//
// at time of writing, this syntax causes double output of coverage events 
// because SV erroneously outputs PSL-style messages even without the $info line
//
		cover property (FC_one_cold_corner(sigreg))
		$info("Coverage event cover__FC_one_cold_corner");
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------
// one_hot
// 
// Checks that a register has 1 and only 1 bit asserted on every cycle; if
// "strict" is true, the register may never have 0 bits asserted.
//
//----------------------------------------------------------------------------

module mc_one_hot
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer width = 0,                  // Width of reg
  parameter strict = `MC_TRUE)                  // true ==> never 0 bits asserted (boolean)
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);
	int covercount;

// The assertion
// Immediate assertion syntax is used
// NB the $error user text is strictly designed to match the PSL output, to 
// make comparison between test output easy


	always @ (posedge clk) begin
		if (!reset && (strict == `MC_TRUE))
			assert ($onehot(sigreg))
			else $error("Assertion assert__mc_one_hot");
		else if (!reset)
			assert ($onehot0(sigreg))
			else $error("Assertion assert__mc_one_hot");
	end
// The functional coverage
// First check that each bit has been asserted

	generate
		genvar hot_index;
		property FC_one_hot(sigreg_bit);
			disable iff (reset) 
			@ (posedge clk)
				sigreg_bit === 1'b1;
		endproperty

		for (hot_index=0; hot_index < width; hot_index++) 
		begin:FC_hot
			cover property (FC_one_hot(sigreg[hot_index])) 
			$info("Coverage event cover__FC_one_hot");
		end
	endgenerate


// Cover the zero-hots case where strict is false
// 
	generate
		if (strict == `MC_FALSE) begin: no_hots

		property FC_one_hot_corner (sigreg);
			disable iff (reset)
			@ (posedge clk)
				sigreg === 0;
		endproperty
	
		cover property (FC_one_hot_corner(sigreg)) 
		$info("Coverage event cover__FC_one_hot_corner");
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------
// parity
// 
// Always checks that a register is of even or odd parity.  The generic
// parameter "even" indicates whether the check should be enabled for even or
// odd parity checking.
//
// This check is made every cycle, so if a register changes to be in
// violation of the check and remains unchanged for several cycles, the
// checker will assert on all of those cycles.
//----------------------------------------------------------------------------

module mc_parity
#(parameter integer coverage_level = 2,         // sets checking intensity
  parameter integer width = 0,                  // Width of register
  parameter bit even = `MC_FALSE)               // true ==> even parity; false ==> odd (boolean)
(
	input clk,
	input reset,
	input [(width-1):0] sigreg);

	integer parity;

//
// Uses immediate assertion syntax
//
	always @ (posedge clk)
		if (~reset)
			assert (^sigreg === ~even)
			else $error("Assertion assert__mc_parity");

endmodule

//----------------------------------------------------------------------------
// precious_data
// 
// Check that the value of a source register ("src") appears in the
// destination register ("dest"), within a "precious data window" defined by
// the checker.
//
// Source Change
//
// The source register is considered to have changed in one of two
// circumstances, determined by the value of the generic "src_change":
// 
//    0 == mc_edge_any      Any change in the source register "src".
//    1 == mc_edge_gated    Rising edge of the signal "src_loaded".
//
// Opening of precious data window
//
// The "precious data window" // the window of time during which the "src"
// value is required to appear in the "dest" register // opens "start_count"
// cycles after the source change, as defined above.
//
// Closing of precious data window
//
// From the opening of the precious data window (see above), the "dest"
// register must be equal to the "src" register within a window of time
// defined as:
// 
//    0 == mc_window_count     Within "stop_count" cycles.
//    1 == mc_window_gated     When the "stop_signal" has a rising edge.
//
// Reset
//
// Assertion of reset at any time aborts the checking sequence.  Reset should
// be asserted at the beginning of simulation, else a spurious assertion may
// be launched with the first value driven onto "src".
//
// Overlapping windows
//
// From the time of a source change, to the time the checker succeeds or
// fails, it is not advisable that the "src" register change again.  In
// particular, if the "src" register changes BEFORE the precious data window
// opens, the check-in-progress may fail when it otherwise would not.  The
// check always succeeds or fails based on current values of "src" and
// "dest".
//
// Assertions
//
//    This is used only when "stop_count" is valid, i.e., when "stop_type" is
//    0(i.e. mc_window_count):
// 
//    mc_precious_data      asserts when "src = dest" condition is not
//                          fulfilled in the precious data window.
//
//      Note: it is OK, with the counted window, for the "dest" register to
//      change early (because then the "src = dest" condition may still be
//      fulfilled), but it is not OK for it to change late.
//
//    These are used when "stop_type" is 1(i.e. mc_window_gated), which means
//    that the "stop_signal" is valid:
//
//    mc_precious_stoptime  asserts when there is a rising edge on
//                          "stop_signal" that occurs fewer than
//                          "start_count" cycles after the source change.
//    mc_precious_stopval   asserts when there is a rising edge on
//                          "stop_signal" but "src /= dest".
// 
//----------------------------------------------------------------------------

module mc_precious_data
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer width = 0,                    // Width of reg
  parameter integer src_change = `MC_EDGE_ANY,    // 0(i.e. mc_edge_any) ==> any change in src starts
                                                  // 1(i.e. mc_edge_gated) ==> rising edge of "src_loaded"
  parameter integer start_count = 0,              // cycles from src_change to open of
                                                  // precious data window
  parameter integer stop_type = `MC_WINDOW_GATED, // what stops?
                                                  // 0(i.e. mc_window_count) ==> use "stop_count" for window
                                                  // 1(i.e. mc_window_gated) ==> use "stop_signal" for window
  parameter integer stop_count = 1)               // # cycles in precious data window
                                                  // stop_count < 0 ==> use stop_signal instead of cycle count
(
	input clk,
	input reset,
	input [(width-1):0] src,                     // source register
	input [(width-1):0] dest,                    // destination register
	input src_loaded,                            // valid data in source register
                                                    // ignored if src_change = mc_edge_any
	input stop_signal);                          // valid data in destination register
                                                    // ignored if stop_type = mc_window_gated

	reg [(width-1):0] prev_src;		// so we can detect a change in src
	reg prev_src_loaded;			// so we can detect a change in src_loaded 
	reg prev_stop_signal;			// ditto for stop_signal
	logic antecedent_condition;		// simplify the later equations - create a combinatorial
            						// condition that indicates the start of a check

	integer FA_precious_data_bound_hi = -1;
	integer FA_precious_data_bound_lo = -1;


	always @ (posedge clk) begin
		prev_src <= src;
		prev_src_loaded <= src_loaded;
		prev_stop_signal <= stop_signal;
	end

	always @ (src or prev_src or src_loaded or prev_src_loaded)
		antecedent_condition = (((src_change === `MC_EDGE_GATED) && (src_loaded & ~prev_src_loaded))
					|| ((src_change === `MC_EDGE_ANY) && (src !== prev_src)))
					&& (reset === 1'b0);

// Cover the antecedent condition (per the original implementation)
	property FC_precious_data;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			antecedent_condition;
	endproperty

	cover property (FC_precious_data) 
	$info("Coverage event cover__FC_precious_data");

// Two different types of check, depending on stop_type 
// (MC_WINDOW_COUNT or MC_WINDOW_GATED)
// First we do MC_WINDOW_COUNT which uses the start_count and stop_count 
// parameters to count a window within which we must see the src data in dest

	generate
		if (stop_type === `MC_WINDOW_COUNT) begin: precious_data
			property mc_precious_data;
                int x;
				disable iff (reset === 1'b1)
				@ (posedge clk)
				(antecedent_condition,x=0) |-> 
					##start_count ((dest !== src,x=x+1) [* 0:stop_count]) 
					##1 ((dest === src),record_bounds(x+start_count));
			endproperty
			assert property (mc_precious_data) 
			else $error("Assertion assert__mc_precious_data");
		end
	endgenerate

// Second case is when stop_type is  MC_WINDOW_GATED

	generate
		if (stop_type === `MC_WINDOW_GATED) begin: precious_stopval
        // Check that dest and src are equal when the stop signal is asserted
        	property mc_precious_stopval;
                int x;
				disable iff (reset === 1'b1)
				@ (posedge clk)
				    (~stop_signal  ##1 stop_signal) |-> ##0 (dest === src);
			endproperty
			assert property (mc_precious_stopval) 
			else $error("Assertion assert__mc_precious_stopval");

        // Check that the stop_signal isn't asserted too soon

        	property mc_precious_stoptime;
                int x;
				disable iff (reset === 1'b1)
				@ (posedge clk)
				(antecedent_condition,x=0) |-> 
				( (~$rose(stop_signal),x=x+1) [*start_count:$]) 
				##1 ($rose(stop_signal), record_bounds(x));
			endproperty
			assert property (mc_precious_stoptime) 
			else $error("Assertion assert__mc_precious_stoptime");
		end
	endgenerate

//
// Extra coverage - monitor sequence completion times
//
//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

//
// This process synchronizes the static values in the function with the 
// variables at module scope.
// This is only used so that the existing test infrastructure works - not a 
// recommended construct!
// 
	always @ (posedge clk) begin
		FA_precious_data_bound_lo = record_bounds.low_bound;
		FA_precious_data_bound_hi = record_bounds.high_bound;
	end


endmodule

//----------------------------------------------------------------------------
// range
// 
// Checks that a register is in the range min - max.  The check for max is
// enabled by "max_valid" equal to '1'.  The check for min is enabled by
// "min_valid" equal to '1'.
//
//----------------------------------------------------------------------------

module mc_range
#(parameter integer coverage_level = 2,                   // sets checking intensity
  parameter integer width = 0,                            // Width of reg
  parameter integer min = 0,                              // minimum value
  parameter integer max = 0)                              // maximum value
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,                           // Register to check
	input min_valid,                                      // check for min
	input max_valid);                                     // check for max

    int FA_range_bound_hi = '0;
    int FA_range_bound_lo = '1;

// assert under any of these conditions:
// 1. (reset false) and (min_valid true) and (sigreg < min)
// 2. (reset false) and (max_valid true) and (sigreg > max)
// We assert the falseness of the OR of these two.

    always @ (posedge clk)
        assert ( ~(((reset===1'b0) && (min_valid===1) && ($unsigned(sigreg) < $unsigned(min))) 
                || ((reset===1'b0) && (max_valid===1) && ($unsigned(sigreg) > $unsigned(max))))) 
        else $error("Assertion assert__mc_range");

//
// the coverage
//
	property FC_range(sig);
        disable iff (reset == 1'b1)
		@ (posedge clk)
			~$stable(sigreg);
	endproperty

	cover property (FC_range(sigreg)) 
	$info("Coverage event cover__FC_range");

//
// Catching min and max values of reg can be written in Verilog
//

    generate
        if (coverage_level >= 1) begin: capture_extremes
            always @ (sigreg) begin
                if ((reset===1'b0) && ($unsigned(sigreg) > $unsigned(FA_range_bound_hi)))
                    FA_range_bound_hi = sigreg;
                if ((reset===1'b0) && ($unsigned(sigreg) < $unsigned(FA_range_bound_lo)))
                    FA_range_bound_lo = sigreg;
            end
        end
    endgenerate

endmodule

//----------------------------------------------------------------------------
// reg_loaded
// 
// Check that a register is loaded (changes value) within a window defined by
// the checker.  The window opens some number of cycles past a "start"
// signal.  The window closes either based on a count (some number of cycles
// past the cycle at which it opens) or the rising edge of a "stop" signal
// after the window opens.
//
// The checker does not assert if the register changes after start but before
// the window opens, nor does it assert if there is a rising edge on "stop"
// prior to the window opening.
// 
// Window Opening
// 
// The window opens on the cycle as the "start" signal is asserted.  This
// means that if the start_count is 0, the register may change value on the
// same cycle as the "start" signal is asserted, and the check will have
// passed.
// 
// Window Closing
// 
// If "stop_type" is 1(i.e. mc_window_gated), the window closes on the same cycle
// as the "stop" signal is asserted.  To pass the check, the register must
// change value prior to the "stop" signal being asserted.  This means that
// the "stop" signal must assert on some cycle after "start" asserts.
// 
// If "stop_type" is 0(i.e. mc_window_count), the window closes AFTER
// "stop_count" cycles have elapsed.  By implication, if "start_count" and
// "stop_count" are both 0, the register must change on the same edge as
// "start" is asserted.
// 
//----------------------------------------------------------------------------

module mc_reg_loaded
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer width = 0,                    // Width of reg
  parameter integer start_count = 0,              // cycles from "start" to open of
                                                  // window
  parameter integer stop_type = `MC_WINDOW_GATED, // what stops (closes) the window?
                                                  // 0(i.e. mc_window_count) ==> use "stop_count" for window
                                                  // 1(i.e. mc_window_gated) ==> use "stop_signal" for window
  parameter integer stop_count = 1)               // # cycles in window
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,                   // register to check
	input start,                                  // start checking for open window
	input stop);                                  // (optionally) close window
                                                  // ignored if stop_type = mc_window_gated


    integer FA_reg_loaded_bound_hi = -1;
    integer FA_reg_loaded_bound_lo = -1;

    logic antecedent_condition;

    property engaged;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            $rose(start);
    endproperty

    cover property (engaged) $info("Coverage event cover__FC_reg_loaded");

    
    generate
        if (stop_type === `MC_WINDOW_COUNT) begin: reg_loaded_window_count
            property mc_reg_loaded;
                int x;
                disable iff (reset === 1'b1)
                @ (posedge clk)
                    ($rose(start),x=0) |-> 
					##start_count (($stable(sigreg),x=x+1) [*0:stop_count]) 
                    ##1 (~$stable(sigreg),record_bounds(x+start_count));
            endproperty
            assert property (mc_reg_loaded) 
			else $error("Assertion assert__mc_reg_loaded");
        end

    endgenerate

    generate
        if (stop_type === `MC_WINDOW_GATED) begin: reg_loaded_window_gated

//
// don't put the reset in the sequence - use it in the disable iff statement
// in the property (disable iff's can't be nested)
// 

            sequence s_reg_loaded;
                int x;
                ##0 (1,x=start_count)
                ##start_count ($stable(sigreg) && ~$rose(stop), x=x+1) [*0:$] 
                ##1 (~$stable(sigreg) && ~$rose(stop),record_bounds(x))
                ##1 (~$rose(stop)) [*0:$]
                ##1 ($rose(stop));
            endsequence

            property mc_reg_loaded;
                disable iff (reset === 1'b1)
                @ (posedge clk)
                    $rose(start) |-> s_reg_loaded;
            endproperty

            assert property (mc_reg_loaded) 
			else $error("Assertion assert__mc_reg_loaded");
        end
    endgenerate

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"

//
// This process synchronizes the static values in the function with the 
// variables at module scope.
// This is only used so that the existing test infrastructure works - not a 
// recommended construct!
// 
//
	always @ (posedge clk) begin
		FA_reg_loaded_bound_lo = record_bounds.low_bound;
		FA_reg_loaded_bound_hi = record_bounds.high_bound;
	end

endmodule

//--------------------------------------------------------------------------
// rx_backup
// 
// Assertion of the "rx_full" signal must be followed by "xmit_ready" equal
// '0' within min to max cycles.
//
// This is similar to "mc_follows" with the sense of the following signal
// inverted, except that the test for the following signal ("xmit_ready" in
// this case) is level-based, not edge-based.  This makes a difference for
// the case where "min=0", in which case the checker is satisfied if
// "xmit_ready" is already '0' on a rising edge of "rx_full".
//
//--------------------------------------------------------------------------

module mc_rx_backup
#(parameter integer coverage_level = 2,       // sets checking intensity
  parameter integer min = 0,                  // min cycles to follow
  parameter integer max = 0)                  // max cycles to follow
(
	input clk,
	input reset,
	input rx_full,                           // tested for rising edge
	input xmit_ready);                       // tested for level '0'

    integer FA_rx_backup_bound_hi = -1;
    integer FA_rx_backup_bound_lo = -1;

    property mc_rx_backup;
        int x;
        disable iff (reset === 1'b1)
        @ (posedge clk)
            ($rose(rx_full),x=0) |-> ((xmit_ready !== 1'b0,x=x+1) [*min:max]) 
			##1 (xmit_ready === 1'b0,record_bounds(x));
    endproperty

    assert property (mc_rx_backup) 
    else $error("Assertion assert__mc_rx_backup");
    cover property (mc_rx_backup) $info ("Coverage event cover__FC_rx_backup");

//
// include the utility function, record_bounds
// This is the function used to extract the 'x' variables out of the sequence 
// instances and store them statically
// The function is called from within the covered sequence instances, when they 
// complete successfully
//

`include "system_verilog_checkers_uf.inc"


//
// This process synchronizes the static values in the function with the 
// variables at module scope.
// This is only used so that the existing test infrastructure works - not a 
// recommended construct!
// 
//
	always @ (posedge clk) begin
		FA_rx_backup_bound_lo = record_bounds.low_bound;
		FA_rx_backup_bound_hi = record_bounds.high_bound;
	end
	

endmodule

//--------------------------------------------------------------------------
// scoreboard
// 
// Models a scoreboard that tracks ids issued and received.  It checks that a
// maximum number of ids are outstanding (issued but not received) at any one
// time, checks the time during which a given id is outstanding, checks that
// a received id was previously issued, not issued twice nor simultaneously
// issued and received, and that an id is legal.
// 
// Note that a checker such as this one has multiple temporal and state-machine
// elements. After the first error has been detected, the state machine is 
// potentially no longer in a meaningful state. Therefore all errors after the
// first until the next reset is received may be spurious.
// 
// Reset
//
// Reset must be given at the start of simulation.  Reset clears the
// checker's memory of what has been issued; i.e., clears the number of
// outstanding ids to 0.
//
// Assertions
//
// mc_scoreboard_badid    asserts when an id is < min_id or > max_id
// mc_scoreboard_max_out  asserts when the number of outstanding (issued
//                        but not received) ids is > max_outstanding
// mc_scoreboard_mismatch asserts when an id was received but not issued,
//                        issued twice in a row, or there was an attempt
//                        to issue and receive the same id at one time
//
//--------------------------------------------------------------------------

module mc_scoreboard
#(parameter integer coverage_level = 2,       // sets checking intensity
  parameter integer min_id = 0,               // minimum allowable id
  parameter integer max_id = 0,               // maximum allowable id
  parameter integer max_outstanding = 0)      // maximum number of ids that can be
                                              // issued but not received
(
	input clk,
	input reset,
	input signed [31:0] issue_id,             // id issued by the scoreboard
	input issue_en,                           // when '1', issue the issue_id
	input signed [31:0] rx_id,                // id received by the scoreboard
	input rx_en);                             // when '1', receive the rx_id

	wire valid_issue;
	wire valid_rx;

	int id_count = 0;
	int rx_id_valid = `MC_FALSE;
//
// First some very basic, non-temporal checking
// It's an error if one of the enables is asserted and its id is outside
// the range.
// It's an error if we get a valid rx after reset, before any issue
// It's an error if we get a simultaneous issue and rx on the same id
//

	property mc_scoreboard_badid;
		disable iff (reset)
		@ (posedge clk)
			not ((issue_en && ((issue_id < min_id) || (issue_id > max_id)))
				 || (rx_en && ((rx_id < min_id) || (rx_id > max_id))));
	endproperty
	
	assert property (mc_scoreboard_badid)
	else $error("Assertion assert__mc_scoreboard_badid");

	property mc_scoreboard_rx_after_reset;
		@ (posedge clk)
			$fell(reset) |=> 
			~rx_en [*0:$]
			##1 valid_issue;
	endproperty

	assert property (mc_scoreboard_rx_after_reset)
	else $error("Assertion assert__mc_scoreboard_rx_after_reset");

	property mc_scoreboard_simultaneous;
		disable iff (reset)
		@ (posedge clk)
			not (rx_en && issue_en && (rx_id == issue_id));
	endproperty

	assert property (mc_scoreboard_simultaneous)
	else $error("Assertion assert__mc_scoreboard_simultaneous");

// 
// The temporal checking works by starting a new sequence for every valid issue,
// and checking it through to completion on reception of the same ID
// If the same ID is issued while the sequence is running, it asserts to 
// indicate a duplicate issue.
// When a sequence starts, we need to increment the number of outstanding IDs.
// When a sequence finishes, we need to decrement the number of outstanding IDs.
//
// Use valid_issue to decide if we start a new sequence.
// which happens under these conditions:
// 	reset is false and issue_en is asserted
// 	we aren't simultaneously trying to issue and receive the same id
// 	issue_id is numerically valid
//
// (Conditions two and three in the above list will assert separately)
// 
// The sequences will be started and matched even if the max_oustanding is
// exceeded. The max_outstanding condition is checked separately.
//

	assign valid_issue = ~reset && issue_en
						&&  ~ ((issue_id == rx_id) && rx_en && issue_en)
						&& (issue_id >= min_id)
						&& (issue_id <= max_id);
//
// valid_rx is a bit harder. 
// The first test for a valid rx is the mechanical one - we don't want to
// even consider a candidate until these conditions are true:
//	not reset and rx_en is true
//  we aren't simultaneously trying to issue and read the same id
// 	the id is in the valid range
//
// (Conditions two and three in the above list will assert separately)
// 
// Then there is the additional check that the incoming rx is expected.
// An incoming rx is valid if it there is a sequence 
// that it terminates correctly. Since only one rx is received at a time,
// we determine this by having any sequence that does terminate correctly
// update a the rx_id_valid variable. On the clock edge following an 
// otherwise valid rx_id, we check this variable as well. If it has
// the value `MC_FALSE,  it means no sequence
// terminated because of it, and it is therefore unmatched. This data
// can only be valid for one match attempt, so on the same clock edge
// we reset rx_id_valid.
// 
// unmatched_rx_id asserts one clock after the offending rx_id
// (due to processing order we can't assert on the edge it happens).
// 
//
	assign valid_rx = 	~reset & rx_en
						&& ~ ((issue_id == rx_id) && rx_en && issue_en)
						&& (rx_id >= min_id) 
						&& (rx_id <= max_id);


	property mc_scoreboard_unmatched_rx;
		disable iff (reset)
		@ (posedge clk)
			valid_rx |=> (rx_id_valid === `MC_TRUE);
	endproperty

	assert property (mc_scoreboard_unmatched_rx)
	else $error("Assertion assert__mc_scoreboard_unmatched_rx_id");

// 
// The mc_scoreboard_duplicate_issue property looks for a sequence to
// begin (with the valid issue of an issue_id) and terminate (with
// the valid reception of the same id). If it sees the same id issued
// while it is waiting, it asserts.
// We also use this property to count waiting sequences, in a static variable
// in a function.
//

	property mc_scoreboard_duplicate_issue;
		reg signed [31:0] remember_id;
		disable iff (reset)
		@ (posedge clk)
			((valid_issue, remember_id = issue_id),start_new_sq)  |=> 
			~(valid_issue && (issue_id == remember_id)) [*0:$]
			##1 (valid_rx && (rx_id == remember_id), got_my_rx_id);
	endproperty
//
// These two functions are only called from within the above sequence.
// Calling them increments and decrements the id_count, so any other calls
// will invalidate this count.
// We initialize them by blasting their variables directly (not really
// good practice - would be better to use C++ techniques probably).
// 

	function void got_my_rx_id;
		rx_id_valid = `MC_TRUE;
		id_count = id_count -1;
	endfunction

	function void start_new_sq;
		id_count = id_count +1;
	endfunction

	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			id_count = 0;
		end		
		rx_id_valid <= `MC_FALSE;	// but it can get written to `MC_TRUE when one of its 
									// sequences finishes, within the same time slot, so
									// that it will be observed true next time slot.
	end

	assert property (mc_scoreboard_duplicate_issue)
	else begin
		$error("Assertion assert__mc_scoreboard_duplicate_issue");
		id_count = id_count - 1;	// We asserted out of the sequence and so it shouldn't
									// count towards our tokens out
									// But this is a case where continuing after an error can
									// be pointless
	end
//
// We have a property that watches the id_count to make sure it
// never exceeds max_outstanding.
// We can't assert on the clk edge it actually happens on, due to processing order,
// it asserts one clock late
//

	property mc_scoreboard_max_out;
		disable iff (reset)
		@ (posedge clk)
			(id_count <= max_outstanding);
	endproperty

	assert property (mc_scoreboard_max_out)
	else $error("Assertion assert__mc_scoreboard_max_out");

endmodule

//----------------------------------------------------------------------------
// sequence
// This has been rewritten from the original and is functionally slightly different.
// 
// The specification is to look for a sequence of register values occurring
// such that the changes from one value to the next occur between
// a minimum and a maximum number of cycles.
// The register size is parameterized by 'width' and the number of items in the
// sequence is determined by parameter 'length'
// The ordered data-to-match is flattened and passed into the module in a 
// 1-dimensional register, 'expected'.
// The parameters min_change_time and max_change_time determine the 
// change window.
// Each instance of the check starts when start_sequence rises, thus there can
// be multiple sequences being evaluated at any time. start_sequence asserted 
// before a previous check has completed is not an error (though one or both is 
// unlikely to succeed unless the sequence is repetitive).
// This behavior is slightly different from the original Verilog/PSL version, but 
// clearer (IMO).
// At the clk on which start_sequence rises, the data must match the first value
// in the sequence and must change to the next value not fewer than min_change_time
// cycles later and not more than max_change_time cycles. Then the check is repeated
// for the next value in the series until 'length' values have been tested.
// The final value is tested to hold at least min_change_time_cycles, behavior
// after that is not tested.
//     
// The sequence may be thought of as a 2-dimensional array of reg values, packed
// into a reg vector.  Here's an example assignment to a signal of this
// type:
//
//     This would be given to the "expected" parameter of the checker
//     when the expected sequence is of length 3, and the register of
//     width 4:
//
//     reg [0:((3*4)-1)] expected3_4 = {4'b0001, 4'b0010, 4'b0100};
//         or
//     reg [0:((length*width)-1)] expected3_4 = {4'b0001, 4'b0010, 4'b0100};
//
//----------------------------------------------------------------------------

module mc_sequence
#(parameter integer coverage_level = 2,       // sets checking intensity
  parameter integer width = 0,                // width of reg
  parameter integer length = 0,               // number of values in sequence
  parameter integer min_change_time = 1,      // minimum time between changes in sequence
  parameter integer max_change_time = 1)      // maximum time between changes
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,                 // Register to check
	input [0:((length*width)-1)] expected,
	input sequence_start);                   // start of sequence

	reg [(width-1):0] expected_2D [(length-1):0];
	reg [(width-1):0] tempreg;
	int l,w;

//
// Translate the one-dimensional input data into a two-dimensional memory
// Generally only expect to do this once at the beginning, and it makes later
// code clearer, since conceptually data is 2D
//

	always @ (expected) begin
		for (l=0; l<length; l=l+1) begin
			for (w=0;w<width;w=w+1) begin
				tempreg[width-1-w] = expected[(l*width) + w];
			end
			expected_2D[l] = tempreg;
		end
	end

//
// This is the repetitive sequence, which must match immediately when called and hold for a valid
// number of cycles.
//

	sequence s_repeat_element(data_to_match);
		@ (posedge clk)
			(sigreg === data_to_match) [*min_change_time:max_change_time];
	endsequence

//
// The property mc_sequence causes a sequence to start whenever sequence_start rises, and 
// expects 'length' matches of s_repeat_element. The local variable 'j' counts each
// match.
//
	property mc_sequence;
		int j;
		disable iff (reset)
		@ (posedge clk)
			($rose(sequence_start),j=0) |->  (s_repeat_element(expected_2D[j]),j=j+1)[*length];
	endproperty

	property mc_sequence_started;
		disable iff (reset)
		@ (posedge clk)
			$rose(sequence_start);
	endproperty

	assert property (mc_sequence) else $error("Assertion assert_mc_sequence");

	cover property (mc_sequence_started) $info("Coverage event - started mc_sequence");
	cover property (mc_sequence) $info("Coverage event - completed mc_sequence");

endmodule

//----------------------------------------------------------------------------
// stack (mc_stack, mc_stack_check_values)
//
// Checks that the stack does not overflow or underflow, optionally checks
// value integrity of the stack.  The stack is written when "push" is
// asserted on positive edge of clock, read when "pop" is asserted on
// positive edge of clock.
//
// Value Integrity Check
//
// When "check_values" is true, the checker models the stack faithfully and
// checks that the "pop_data" input is what is expected as stack output.  The
// "mc_stack_value" property asserts when an unexpected value is
// detected.  This property is checked 1 cycle AFTER the assertion of "pop"
// at which point the stack output has been driven from the checker's
// internal model of a synchronous stack, based upon previous data input
// ("push_data") and control ("push" and "pop") given to the checker.
//
// When "check_values" is false, the "push_data" and "pop_data"
// are ignored.
//  
// Reset
//
// Reset clears the stack of all values and disables all control while reset
// is asserted.
//
// Assertions
//
// mc_stack_value      asserts with a value mismatch
// mc_stack_underflow  asserts with underflow (pop empty stack)
// mc_stack_overflow   asserts with overflow (push full stack)
// mc_stack_control    bad control signals (simultaneous push/pop)
//
//----------------------------------------------------------------------------

module mc_stack
#(parameter integer coverage_level = 2,          // sets checking intensity
  parameter integer width = 1,                   // width of data vectors
  parameter integer depth = 0,                   // # elements in stack
  parameter integer check_values = `MC_FALSE)    // check_values, Default: FALSE        
(
	input clk,
	input reset,
	input push,                                  // write enable
	input pop,                                   // read enable
	input [(width-1):0] push_data,
	input [(width-1):0] pop_data);

	int stack_count = 0;
	integer FA_stack_bound_hi = -1;

// This is a checker for a simple stack (LIFO-style memory).
// The overflow/underflow checking is simple.
// The checker maintains a count of how many data items are currently in the stack.
// When 'reset' is asserted, this count goes to 0.
// When 'push' is asserted, the count is incremented and when 
// 'pop' is asserted, the count is decremented. The count must never 
// exceed the stack size, 'depth' and it must never decrement below 0. Thus
// the rules are simple, the only complication is when 'push' and 'pop'
// occur at the same time, and this is always treated as an error
//

//
// The equations for stack_count
// Outside of reset, fifo_count only changes for valid assertions of push
// by itself, or pop by itself.
// 

	always @ (posedge clk) begin
		if (reset === 1'b1)
			stack_count <= 0;
		else if (( push & ~pop) && (stack_count < depth)) begin
				stack_count <= stack_count + 1;
				if (FA_stack_bound_hi < stack_count+1)
					FA_stack_bound_hi = stack_count+1;
		end
		else if ((pop & ~push) && (stack_count != 0))
				stack_count <= stack_count - 1;
	end

//
// underflow is when the count is 0 with a pop 
//

	property mc_stack_underflow;
		disable iff (reset === 1'b1)
		@ (posedge clk) not
			(pop && (stack_count == 0));
	endproperty

	assert property (mc_stack_underflow) 
	else $error("Assertion assert__mc_stack_underflow");

//
// overflow is when we get an push when full AND no pop
// (the bad case of pop AND push is detected separately)
//
	property mc_stack_overflow;
		disable iff (reset === 1'b1)
		@ (posedge clk) not
			(push && (stack_count == depth) && ~pop);
	endproperty

	assert property (mc_stack_overflow) 
	else $error("Assertion assert__mc_stack_overflow");
//
// pop and push together is a control error
//
	property mc_stack_control_error;
		disable iff (reset === 1'b1)
		@ (posedge clk) not
			(pop & push);
	endproperty
		
	assert property (mc_stack_control_error)
	else $error("Assertion assert__mc_stack_control");
//
// Next is the value-checking stuff.
// This is only turned on if check_values is true.
// To check values, we have to mirror the stack, and do everything
// it does, which means we neeed a real memory
//
	generate 
		if (check_values == `MC_TRUE) begin: stack_model
			reg [(width-1):0] stack_mirror [(depth-1):0];
			reg [(width-1):0] stack_mirror_out;

			int write_addr = 0;
			int read_addr = 0;

			always @ (posedge clk) begin
				if (reset) begin
					write_addr <= 0;
				end
//
// We use the same algorithm as above to determine what to do with the data 
// and pointers. We can use stack_count since we already derived it
// First the write case:
//
				else if (( push & ~pop) && (stack_count != depth)) begin
					stack_mirror[write_addr] <= push_data;
					if (write_addr === depth-1) 
						write_addr <= 0;
					else
						write_addr <= write_addr + 1;
					read_addr <= write_addr;
				end
//
// then the read case
//
				else if ((pop & ~push) && (stack_count != 0)) begin
					if (read_addr === 0)
						read_addr <= depth-1;
					else
						read_addr <= read_addr - 1;
					stack_mirror_out <= stack_mirror[read_addr];
					write_addr <= read_addr;
				end
			end // always @ (posedge clk)

			property mc_stack_value;
				disable iff (reset === 1'b1)
				@ (posedge clk)
					(pop === 1'b1) |=> (stack_mirror_out === pop_data);
			endproperty

			assert property (mc_stack_value) 
			else $error("Assertion assert__mc_stack_value");
		end // check_values true
	endgenerate

//
// Functional coverage
// Was there a pop request?
// Did the stack ever go to empty?
// Was there an push request?
// Did the stacl ever go to full?

	property mc_stack_pop;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			pop === 1'b1;
	endproperty

	property mc_stack_empty;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			((pop === 1'b1) |-> ##1 (stack_count === 0));
	endproperty

	property mc_stack_push;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			push === 1'b1;
	endproperty

	property mc_stack_full;
		disable iff (reset === 1'b1)
		@ (posedge clk)
			((push === 1'b1) |-> ##1 (stack_count === depth));
	endproperty

	cover property (mc_stack_pop)
	$info("Coverage event cover__FC_stack_pop");

	cover property (mc_stack_empty)
	$info("Coverage event cover__FC_stack_empty");

	cover property (mc_stack_push)
	$info("Coverage event cover__FC_stack_push");

	cover property (mc_stack_full)
	$info("Coverage event cover__FC_stack_full");
endmodule

//----------------------------------------------------------------------------
// transition
//
// Checks that a register only transitions to a set of expected values.  Note
// that the register may assume a value not in the set just after reset;
// otherwise every change must be to a value in the set.
//                               
// The sequence may be thought of as a 2-dimensional array of reg values, packed
// into a reg vector.  Here's an example assignment to a signal of this
// type:
//
//     This would be given to the "expected" parameter of the checker
//     when the expected sequence is of length 3, and the register of
//     width 4:
//
//     reg [0:((3*4)-1)] expected3_4 = {4'b0001, 4'b0010, 4'b0100};
//         or
//     reg [0:((length*width)-1)] expected3_4 = {4'b0001, 4'b0010, 4'b0100};
//
//----------------------------------------------------------------------------

module mc_transition
#(parameter integer coverage_level = 2,        // sets checking intensity
  parameter integer width = 0,                 // width of reg
  parameter integer length = 0)                // number of expected values
(
	input clk,
	input reset,
	input [(width-1):0] sigreg,   // Register for check
	input [0:((length*width)-1)] expected);

	reg [(width-1):0] expected_2D [(length-1):0];
	reg [(width-1):0] tempreg;
	reg [(width-1):0] prevreg;
	int l,w;
//
// Translate the one-dimensional input data into a two-dimensional memory
// Generally only expect to do this once at the beginning, and it makes later
// code clearer, since conceptually data is 2D
//

	always @ (expected) begin
		for (l=0; l<length; l=l+1) begin
			for (w=0;w<width;w=w+1) begin
				tempreg[width-1-w] = expected[(l*width) + w];
			end
			expected_2D[l] = tempreg;
		end
	end

//
// look for a match to a given vector in the memory
//
	function sigreg_is_in_expected;
		input [(width-1):0] sigreg;
		int index;
		sigreg_is_in_expected = `MC_FALSE;
		for (index=0; index<length; index = index+1) begin
			if (sigreg === expected_2D[index]) begin
				sigreg_is_in_expected = `MC_TRUE;
				break;
			end
		end
	endfunction

//
// Construct the assertion
//
	property mc_transition;
		disable iff (reset)
		@ (posedge clk)
			(sigreg !== $past(sigreg,1)) |-> (sigreg_is_in_expected(sigreg) === `MC_TRUE);
	endproperty

	assert property (mc_transition)
	else $error("Assertion assert__mc_transition");

//
// Functional coverage - has each transition element been hit?
// (this is where it helps to have the data organized two-dimensionally)
//

	generate
		genvar t_index;
		for (t_index =0; t_index<length; t_index = t_index + 1) begin: trn_element
			property mc_transition_one_element;
				disable iff (reset)
				@ (posedge clk)
					(sigreg !== $past(sigreg,1)) |-> sigreg === expected_2D[t_index];
			endproperty
			
		cover property (mc_transition_one_element) $info("Coverage event cover__FC_transition");
		end
	endgenerate

endmodule

//----------------------------------------------------------------------------  
// window
//
// This checker is similar to "change_window" (above) except that the "in"
// vector and "out" vector are checked for asserting (value '1') instead of
// changing within their respective windows.
// 
// This checker responds to a window provided by the "start" and "stop"
// signals.  The cycle on which there is a rising edge on the "start" signal
// is the first cycle inside the window.  The cycle on which there is a
// rising edge on the "stop" signal is the first cycle outside the window.
//
// The vector "in_vec" is checked inside the window.  The vector "out_vec" is
// checked outside the window.  Each is required to either assert all its
// bits at least once, or have all its bits asserted throughout the window;
// the determination is made based upon the value of "hold_in" for "in_vec"
// and "hold_out" for "out_vec".  If the "hold" variable is true, then the
// corresponding vector MUST keep ALL its bits asserted within its
// corresponding window.  If the "hold" variable is false, then the
// corresponding vector MUST assert ALL its bits AT LEAST ONCE within its
// corresponding window.
//
// Reset
//
// The checker must have "reset" asserted at the beginning of simulation.
// Use of "reset" aborts the in-progress checking of the current window.
// Checking will resume at the rising edge of the next "start" or "stop"
// signal.
//
// Edges of "start" and "stop" must alternate after coming out of reset.  If
// there are two edges in a row on either, or if both rise on the same clock
// edge, the checker will assert "mc_change_window_bad".
//
// Assertions
//
//    mc_window_in        hold_in=false: violation on in_vec in window
//    mc_window_in_hold   hold_in=true: hold violation for in_vec inside
//                        window, checked every cycle
//    mc_window_out       hold_out=false: violation on out_vec outside
//                        window
//    mc_window_out_hold  hold_out=true: hold violation for out_vec
//                        outside window, checked every cycle
//    mc_window_bad       bad use of "start" and "stop" signals
//
//----------------------------------------------------------------------------  

module mc_window
#(parameter integer coverage_level = 2,           // sets checking intensity
  parameter integer in_width = 0,                 // width of in vector
  parameter hold_in = `MC_TRUE,                   // in_vec must assert in window? (boolean)
  parameter integer out_width = 0,                // width of out vector
  parameter hold_out = `MC_FALSE)                 // out_vec must assert out of window? (boolean)
(
	input clk,
	input reset,
	input [(in_width-1):0] in_vec,               // checked inside
	input [(out_width-1):0] out_vec,             // checked outside
	input start,                                 // start of window
	input stop);                                 // end of window

//
// Track the vector in_vec between start and stop,
// but behavior depends on hold_in
// out_vec between stop and start and depends on hold_out
//

		property mc_track_in_vector;
			reg [(out_width-1):0] in_trk;
			disable iff (reset)
			@ (posedge clk)
				($rose(start), in_trk = in_vec) |->
				(~stop && ((hold_in === ` MC_FALSE) || &in_vec), in_trk = in_trk | in_vec) [*1:$]
				##1 $rose(stop) && (((hold_in===`MC_FALSE) && &in_trk) || ((hold_in===`MC_TRUE) && &in_vec));
		endproperty
		
		assert property (mc_track_in_vector)
		else $error("Assertion assert__mc_window_in");
	
		property mc_track_out_vector;
			reg [(out_width-1):0] out_trk;
			disable iff (reset)
			@ (posedge clk)
				($rose(stop), out_trk = out_vec) |->
				(~start && ((hold_out===`MC_FALSE) || &out_vec), out_trk = out_trk | out_vec) [*1:$]
				##1 $rose(start) && (((hold_out===`MC_FALSE) && &out_trk) || ((hold_out===`MC_TRUE) && &out_vec));
		endproperty
		
		assert property (mc_track_out_vector)
		else $error("Assertion assert__mc_window_out");


// Also assert if start isn't followed by stop and stop isn't followed by start
	property mc_window_start_then_stop;
		disable iff (reset)
		@ (posedge clk)
			($rose(start) && ~$rose(stop)) |-> 
			##1 ~$rose(start) [*0:$] ##0 $rose(stop);
	endproperty

	property mc_window_stop_then_start;
		disable iff (reset)
		@ (posedge clk)
			($rose(stop) && ~$rose(start)) |-> 
			##1 ~$rose(stop) [*0:$] ##0 $rose(start);
	endproperty


	assert property (mc_window_start_then_stop) 
	else $error("Assertion assert__mc_window_bad");

	assert property (mc_window_stop_then_start) 
	else $error("Assertion assert__mc_window_bad");

	cover property (mc_window_start_then_stop) 
	$info("Coverage event cover__FC_window_open");

	cover property (mc_window_stop_then_start) 
	$info("Coverage event cover__FC_window_close");

	always @ (posedge clk)
		assert (reset || ~(stop & start)) 
		else  $error("Assertion assert__mc_window_bad");

endmodule
