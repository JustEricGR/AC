//-*- mode: fundamental; tab-width: 4 -*-
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
//	Name: system_verilog_checkers_uf (ModelSim Standard Checker Library in System Verilog)	
//								
//	Purpose: 						
//      Implements utility functions -- internal used in system_verilog_checkers.
// ------------------------------------------------------------------------

//
// initialize the bounds in the function below
//

	initial begin
		record_bounds.high_bound = -1;
		record_bounds.low_bound = -1;
	end
	
	function void record_bounds (input integer x);
	static int high_bound;
	static int low_bound;

	begin
	// The high bound is easy as it starts lowest possible, so we always ratchet it up
		if (x > high_bound)
			high_bound = x;

	// The low bound is slightly trickier; we have to test for the non-value -1
		if (( low_bound == -1) || (x < low_bound))
			low_bound = x;
	end
	endfunction
