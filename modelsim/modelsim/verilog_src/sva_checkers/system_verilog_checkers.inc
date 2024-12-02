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
//	Name: sysstem_verilog_checkers (ModelSim Standard Checker Library in System Verilog)	
//								
//	Purpose: 						
//      Implements numerous predefined automated design checkers using assertion
//      based verification and functional coverage techniques.
//	Ported from the PSL/Verilog version of the same checkers
//	
// ------------------------------------------------------------------------
// // System Verilog defines for ModelSim Standard Checker Library in System Verilog
// See system_verilog_checkers.v for interface documentation.
// 

// DEFINES:

`define MC_FALSE 1'b0
`define MC_TRUE 1'b1

`define MC_ARBITER_FIFO_SCHEME 0
`define MC_ARBITER_PRIORITY_SCHEME 1
`define MC_ARBITER_FAIRNESS_SCHEME 2

// simultaneous read/write not allowed
`define MC_RW_ERROR 0

// write takes precedence over read
`define MC_RW_WRITEFIRST 1

// read takes precedence over write
`define MC_RW_READFIRST 2

`define MC_EDGE_ANY 0
`define MC_EDGE_GATED 1

`define MC_WINDOW_COUNT 0
`define MC_WINDOW_GATED 1

`define MC_WINDOW_NONE 0
`define MC_WINDOW_OPEN 1
`define MC_WINDOW_CLOSED 2
