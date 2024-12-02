// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_report_global.svh#1 $
//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

`ifndef OVM_REPORT_GLOBAL_SVH
`define OVM_REPORT_GLOBAL_SVH

// Provides a global reporter and a set of global reporting
// functions.  These can be use in modules or in any class
// not derived from ovm_report_client.

ovm_reporter _global_reporter = new();

function void ovm_report_info(string id,
			      string message,
                              int verbosity = 300,
			      string filename = "",
			      int line = 0);
  _global_reporter.ovm_report_info(id, message, verbosity, filename, line);
endfunction

function void ovm_report_message(string id,
				 string message,
                                 int verbosity = 300,
				 string filename = "",
				 int line = 0);
  _global_reporter.ovm_report_message(id, message, verbosity, filename, line);
endfunction

function void ovm_report_warning(string id,
                                 string message,
                                 int verbosity = 200,
				 string filename = "",
				 int line = 0);
  _global_reporter.ovm_report_warning(id, message, verbosity, filename, line);
endfunction

function void ovm_report_error(string id,
                               string message,
                               int verbosity = 100,
			       string filename = "",
			       int line = 0);
  _global_reporter.ovm_report_error(id, message, verbosity, filename, line);
endfunction

function void ovm_report_fatal(string id,
	                       string message,
                               int verbosity = 0,
			       string filename = "",
			       int line = 0);
  _global_reporter.ovm_report_fatal(id, message, verbosity, filename, line);
endfunction

`endif // OVM_REPORT_GLOBAL_SVH
