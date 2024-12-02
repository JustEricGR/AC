// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/reporting/avm_report_client.svh#1 $
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

typedef class avm_named_component;
typedef class avm_env;

//----------------------------------------------------------------------
// CLASS avm_report_client
//
// This is the "user interface" for reporting.  Any object
// that wants to do reporting inherits from this class thus
// making available all the reporting methods.
//
// Each client has a reference to a report handler which
// owns the low-level report processing and state
// information for the client.  The report handler in turn
// sends reports to a central server with forwards them to
// their final destination.
//
// A report has a severity, an id (a string), and a message
// (also a string). It also has an optional verbosity level
// - the default is 0.
//
// If the verbosity level of the report is greater than the
// maximum verbosity level of the report server, then the
// report is simply ignored.
//
// We find out the relevant set of actions to be taken for
// this (severity,id) pair and process the message
// accordingly.
//
// Actions can be set for a severity level, an id, or a
// (severity,action) pair.  The priority ordering is
// (severity,id), id, severity.
//
// File descriptors can be set for a default, severity
// level, an id, or a (severity,action) pair. The priority
// ordering is (severity,id), id, severity, default. File
// descriptors are just ordinary verilog file descriptors;
// as such they may refer to more than one file. It is the
// user's responsibility to open and close them.
//
// The setting of actions and files propagates downwards
// through the named_object hierarchy (see named_object)
//
// File names and line numbers are not yet implemented
//
//----------------------------------------------------------------------
virtual class avm_report_client;

  // m_rh is a handle to the report handler
  protected avm_report_handler m_rh;
  local string m_report_name;

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(string name = "");
    m_report_name = name;
    m_rh = new();
  endfunction

  function avm_report_handler get_report_handler();
    return m_rh;
  endfunction

  function void set_report_handler(avm_report_handler hndlr);
    m_rh = hndlr;
  endfunction

  function string get_report_name();
    return m_report_name;
  endfunction

  function void set_report_name(string s);
    m_report_name = s;
  endfunction

  //--------------------------------------------------------------------
  // Basic reporting methods
  //
  // The basic reporting methods avm_report_message,
  // avm_report_warning, avm_report_error and
  // avm_report_fatal. These four methods have the same
  // arguments : the message id, the message itself, the
  // verbosity, a filename, and a line number.
  // The message is sent to the local report
  // server with the appropriate severity level, and the
  // local report server format the report and decides
  // what, it anything, to do with it.
  function void avm_report_message( input string id,
                                    input string message,
                                    int verbosity = 300,
                                    string filename = "",
                                    int line = 0);
    m_rh.report(MESSAGE, m_report_name, id, message, verbosity, filename, line, this);
  endfunction

  function void avm_report_warning( input string id,
                                    input string message,
                                    int verbosity = 200,
                                    string filename = "",
                                    int line = 0);
    m_rh.report(WARNING, m_report_name, id, message, verbosity, filename, line, this);
  endfunction

  function void avm_report_error( input string id,
                                  input string message,
                                  int verbosity = 100,
                                  string filename = "",
                                  int line = 0);
    m_rh.report(ERROR, m_report_name, id, message, verbosity, filename, line, this);
  endfunction

  function void avm_report_fatal( input string id,
                                  input string message,
                                  int verbosity = 0,
                                  string filename = "",
                                  int line = 0);
    m_rh.report(FATAL, m_report_name, id, message, verbosity, filename, line, this);
  endfunction

  function void report_summarize(FILE f = 0);
    m_rh.summarize(f);
  endfunction

  virtual function void report_header(FILE f = 0);
    m_rh.report_header(f);
  endfunction

  //--------------------------------------------------------------------
  // report action hooks
  //--------------------------------------------------------------------
  virtual function bit report_hook( string id,
                                    string message,
                                    int verbosity,
                                    string filename,
                                    int line);
    return 1;
  endfunction

  virtual function bit report_message_hook( string id,
                                            string message,
                                            int verbosity,
                                            string filename,
                                            int line);
    return 1;
  endfunction

   virtual function bit report_warning_hook( string id,
                                             string message,
                                             int verbosity,
                                             string filename,
                                             int line);
    return 1;
  endfunction

  virtual function bit report_error_hook( string id,
                                          string message,
                                          int verbosity,
                                          string filename,
                                          int line);
    return 1;
  endfunction

  virtual function bit report_fatal_hook( string id,
                                          string message,
                                          int verbosity,
                                          string filename,
                                          int line);
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // reset_report_handler
  //
  // returns the local report server back to their default settings.
  //--------------------------------------------------------------------
  function void reset_report_handler;
    m_rh.initialize;
  endfunction

  //--------------------------------------------------------------------
  // set_report_max_quit_count
  //
  // sets the max quit count on the server
  //--------------------------------------------------------------------
  function void set_report_max_quit_count(int m);
    m_rh.set_max_quit_count(m);
  endfunction

  // set_report_verbosity_level sets the maximum verbosity
  // level for the local report handle
  function void set_report_verbosity_level (int verbosity_level);
    m_rh.set_verbosity_level(verbosity_level);
  endfunction

  // set actions, according to severity, id, or (severity,id)

  // set_report_severity_action sets sets the action associated
  // with this severity for the local report server
  function void set_report_severity_action ( severity s,  action a);
    m_rh.set_severity_action(s, a);
  endfunction

  // set_report_id_action sets sets the action associated with
  // this id for the local report server and (optionally)
  // the children of this named component's report servers.

  function void set_report_id_action
    ( string id,
      action a);
    m_rh.set_id_action(id, a);
  endfunction

  // set_report_severity_id_action sets sets the action
  // associated with this (severity,id) for the local report
  // server and (optionally) the children of this named
  // component' report servers.

  function void set_report_severity_id_action
    ( severity s,
      string id,
      action a);
    m_rh.set_severity_id_action(s, id, a);
  endfunction

  // set_report_default_file, set_report_severity_file,
  // set_report_id_file, and set_report_severity_id_file set
  // files, according to default, severity, id, or
  // (severity,id).
  //
  // The user is responsible for opening and closing these
  // files
  //
  // set_report_default_file sets the default file descriptor
  // for the local report server and (optionally) the
  // children of this named component's report servers.

  function void set_report_default_file ( FILE f);
    m_rh.set_default_file(f);
  endfunction

  // set_report_severity_file sets associates a file descriptor
  // with a severity for the local report server and
  // (optioanally) the children of this named component's
  // report servers.

  function void set_report_severity_file
    ( severity s,
      FILE f);
    m_rh.set_severity_file(s, f);
  endfunction

  // set_report_id_file sets associates a file descriptor with
  // an id for the local report server and (optionally) the
  // children of this named component's report servers.

  function void set_report_id_file
    ( string id,
      FILE f);
    m_rh.set_id_file(id, f);
  endfunction

  // set_report_severity_id_file sets associates a file
  // descriptor with a (severity,id) pair for the local
  // report server and (optionally) the children of this
  // named component's report servers.

  function void set_report_severity_id_file
    ( severity s,
      string id,
      FILE f);
    m_rh.set_severity_id_file(s, id, f);
  endfunction

  function void dump_report_state();
    m_rh.dump_state();
  endfunction

  //--------------------------------------------------------------------
  // die
  //
  // This function is used by the report handler to trigger the death of
  // the simulation.  If the client is a threaded_component then use
  // kill() funciton avm_threaded_component to cause its death.
  // Otherwise simply summarize the reports and call $finish
  //--------------------------------------------------------------------
  virtual function void die();

    avm_named_component nc;
    avm_env e = null;

    if( $cast(nc, this) ) begin
      $display("%s : die", m_report_name);
      e = nc.m_env;
    end

    if(e != null)
      e.do_kill_all();
    else begin
      report_summarize();
      $finish;
    end

  endfunction

endclass

//----------------------------------------------------------------------
// CLASS avm_reporter
//
// trivial report wrapper for use by objects that aren't
// derived from avm_report_client
//----------------------------------------------------------------------
class avm_reporter extends avm_report_client;

  function new(string name = "reporter");
    super.new(name);
  endfunction
endclass
