// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/reporting/avm_report_defines.svh#1 $
//----------------------------------------------------------------------
//   Copyright 2005-2009 Mentor Graphics Corporation
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

// enum severity
// a report is either a message, warning, error or fatal

typedef enum
{
  MESSAGE,
  WARNING,
  ERROR,
  FATAL
} severity;

// an action is a 4 bit integer built by bitwise or'ing of
// the following actions : DISPLAY, LOG, COUNT, and EXIT
// 
// DISPLAY sends the report to the standard output
// LOG sends the report to the file(s) for this (severity,id) pair
// COUNT counts the number of reports with the COUNT attribute.
// When this value reaches max_quit_count, the simulation terminates
// EXIT terminates the simulation immediately.

typedef bit [4:0] action;

typedef enum action
{
  NO_ACTION = 5'b00000,
  DISPLAY   = 5'b00001,
  LOG       = 5'b00010,
  COUNT     = 5'b00100,
  EXIT      = 5'b01000,
  CALL_HOOK = 5'b10000
} action_type;

typedef action id_actions_array[string];

typedef int FILE;
typedef FILE id_file_array[string];

id_actions_array s_default_action_array = '{ default : NO_ACTION };
id_file_array s_default_file_array = '{ default : 0 };
