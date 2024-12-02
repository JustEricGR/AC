// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/reporting/avm_report_handler.svh#1 $
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

typedef class avm_report_client;

//----------------------------------------------------------------------
// CLASS avm_report_handler
//----------------------------------------------------------------------
class avm_report_handler;

  avm_report_server m_srvr;

  // This is the maximum verbosity level for this report
  // handler.  If any report has a higher verbosity level,
  // it is simply ignored

  int m_max_verbosity_level;

  // actions : severity, id, (severity,id)
  action severity_actions[severity];
  id_actions_array id_actions;
  id_actions_array severity_id_actions[severity];

  // file handles : default, severity, action, (severity,id)
  FILE default_file_handle;
  FILE severity_file_handles[severity];
  id_file_array id_file_handles;
  id_file_array severity_id_file_handles[severity];

  function new();
    m_srvr = avm_report_server::get_server();
    initialize;
  endfunction

  // forward the call to the server
  function void set_max_quit_count(int m);
    m_srvr.set_max_quit_count(m);
  endfunction

  function void summarize(FILE f = 0);
    m_srvr.summarize(f);
  endfunction

  function void report_header(FILE f = 0);
    string s;
    m_srvr.f_display(f, "----------------------------------------------------------------");
    $sformat(s, "%s  %s", avm_revision_string(), avm_copyright);
    m_srvr.f_display(f, s);
    m_srvr.f_display(f, "----------------------------------------------------------------");
  endfunction

  //--------------------------------------------------------------------
  // initialize
  // UPDATE COMMENTS
  // all severities both DISPLAY and LOG each report. In
  // addition, ERRORs are also COUNTED (so the simulation
  // will terminate when max_quit_count is reached) FATALs
  // also EXIT (ie, the simulation is immediately
  // terminated)
  //
  // All files (default, severity, id and (severity,id))
  // are initially set to zero. This means that they will be
  // ignored.
  //--------------------------------------------------------------------

  function void initialize();
    set_default_file(0);
    m_max_verbosity_level = 10000;
    set_defaults();
  endfunction

  //--------------------------------------------------------------------
  // run_hooks
  //
  // run the report hooks
  //--------------------------------------------------------------------
  virtual function bit run_hooks(avm_report_client client,
                                 severity s,
                                 string id,
                                 string message,
                                 int verbosity,
                                 string filename,
                                 int line);

    bit ok;

    ok = client.report_hook(id, message, verbosity, filename, line);

    case(s)
      MESSAGE:  ok &= client.report_message_hook(id, message, verbosity, filename, line);
      WARNING:  ok &= client.report_warning_hook(id, message, verbosity, filename, line);
      ERROR:    ok &=client.report_error_hook(id, message, verbosity, filename, line);
      FATAL:    ok &= client.report_fatal_hook(id, message, verbosity, filename, line);
    endcase

    return ok;

  endfunction

  //--------------------------------------------------------------------
  // get_severity_id_file
  //
  // Return the file id based on the severity and the id
  //--------------------------------------------------------------------
  local function FILE get_severity_id_file(severity s, string id);

    id_file_array array;

    if(severity_id_file_handles.exists(s)) begin
      array = severity_id_file_handles[s];      
      if(array.exists(id))
        return array[id];
    end

    if(id_file_handles.exists(id))
      return id_file_handles[id];

    if(severity_file_handles.exists(s))
      return severity_file_handles[s];

    return default_file_handle;

  endfunction

  //--------------------------------------------------------------------
  // set_verbosity_level
  //
  // sets the maximum verbosity level
  // for this report handler. All reports of higher
  // verbosity will be ignored
  //--------------------------------------------------------------------
  function void set_verbosity_level(int verbosity_level);
    m_max_verbosity_level = verbosity_level;
  endfunction

  //--------------------------------------------------------------------
  // get_action
  //
  // Retrieve the action based on severity and id.  First,
  // look to see if there is an action associated with the
  // (severity,id) pair.  Second, look to see if there is an
  // action associated with the id.  If neither of those has
  // an action then return the action associated with the
  // severity.
  //--------------------------------------------------------------------
  function action get_action(severity s, string id);

    id_actions_array array;

    if(severity_id_actions.exists(s)) begin
      array = severity_id_actions[s];
      if(array.exists(id))
        return array[id];
    end

    if(id_actions.exists(id))
      return id_actions[id];

    return severity_actions[s];

  endfunction

  //--------------------------------------------------------------------
  // get_file_handle
  //
  // Retrieve the file handle associated with the severity
  // and id. First, look to see if there is a file handle
  // associated with the (severity,id) pair.  Second, look
  // to see if there is a file handle associated with the
  // id.  If neither the (severity,id) pair nor the id has
  // an associated action then return the action associated
  // with the severity.
  //--------------------------------------------------------------------
  function FILE get_file_handle(severity s, string id);
    FILE f;
  
    f = get_severity_id_file(s, id);
    if(f != 0) return f;
  
    if(id_file_handles.exists(id)) begin
      f = id_file_handles[id];
      if(f != 0) return f;
    end

    if(severity_file_handles.exists(s)) begin
      f = severity_file_handles[s];
      if(f != 0) return f;
    end

    return default_file_handle;
  endfunction

  //--------------------------------------------------------------------
  // report
  //
  // add line and file info later ...
  //
  // this is the public access report function. It is not
  // visible to the user but is accessed via
  // avm_report_message, avm_report_warning,
  // avm_report_error and avm_report_fatal.
  //--------------------------------------------------------------------
  virtual function void report(
      severity s,
      string name,
      string id,
      string message,
      int verbosity,
      string filename,
      int line,
      avm_report_client client
      );
  
    string m;
    action a;
    FILE f;
    bit report_ok;
    
    // filter based on verbosity level
 
    if(verbosity > m_max_verbosity_level) begin
      return;
    end

    // determine file to send report and actions to execute

    a = get_action(s, id); 
    if( a == NO_ACTION )
      return;

    f = get_file_handle(s, id);

    // The hooks can do additional filtering.  If the hook function
    // return 1 then continue processing the report.  If the hook
    // returns 0 then skip processing the report.

    if(a & CALL_HOOK)
      report_ok = run_hooks(client, s, id, message, verbosity, filename, line);
    else
      report_ok = 1;

    if(report_ok)
      m_srvr.process_report(s, name, id, message, a, f, filename, line, verbosity, client);
    
  endfunction

  //--------------------------------------------------------------------
  // format_action
  //--------------------------------------------------------------------
  function string format_action(action a);
    string s;

    if(a == NO_ACTION) begin
      s = "NO ACTION";
    end
    else begin
      s = "";
      if(a & DISPLAY)   s = {s, "DISPLAY "};
      if(a & LOG)       s = {s, "LOG "};
      if(a & COUNT)     s = {s, "COUNT "};
      if(a & EXIT)      s = {s, "EXIT "};
      if(a & CALL_HOOK) s = {s, "CALL_HOOK "};
    end

    return s;
  endfunction

  function void set_severity_action(input severity s,
                                    input action a);
    severity_actions[s] = a;
  endfunction

  function void set_defaults();
    set_severity_action(MESSAGE, DISPLAY);
    set_severity_action(WARNING, DISPLAY);
    set_severity_action(ERROR,   DISPLAY | COUNT);
    set_severity_action(FATAL,   DISPLAY | EXIT);

    set_severity_file(MESSAGE, default_file_handle);
    set_severity_file(WARNING, default_file_handle);
    set_severity_file(ERROR,   default_file_handle);
    set_severity_file(FATAL,   default_file_handle);
  endfunction

  function void set_id_action(input string id, input action a);
    id_actions[id] = a;
  endfunction

  function void set_severity_id_action(severity s,
                                       string id,
                                       action a);
    severity_id_actions[s][id] = a;
  endfunction
  
  // set_default_file, set_severity_file, set_id_file and
  // set_severity_id_file associate verilog file descriptors
  // with different kinds of reports in this report
  // handler. It is the users responsbility to open and
  // close these file descriptors correctly. Users may take
  // advantage of the fact that up to 32 files can be
  // described by the same file descriptor to send one
  // report to many files.
  //
  // set_default_file sets the default file associated with
  // any severity or id in this report handler.

  function void set_default_file(input FILE f);
    default_file_handle = f;
  endfunction

  // set_severity_file sets the file associated with a
  // severity in this report handler.  It is not visible to
  // the user but is accessed via avm_set_severity_file. A
  // file associated with a severity overrides the default
  // file for this report handler.

  function void set_severity_file(input severity s, input FILE f);
    severity_file_handles[s] = f;
  endfunction

  // set_id_file sets the file associated with an id in this
  // report handler. It is not visible to the user but is
  // accessed via avm_set_id_file. A file associated with an
  // id overrides the default file and any files associated
  // with a severity.

  function void set_id_file(input string id, input FILE f);
    id_file_handles[id] = f;
  endfunction

  // set_severity_id_file sets the file associated with a
  // (severity,id) pair. It is not visible to the user but
  // is accessed via avm_set_severity_id_file. A file
  // associated with a (severity,id) pair overrides any
  // other file settings in this report handler

  function void set_severity_id_file(input severity s,
                                      input string id,
                                      input FILE f);
  
    severity_id_file_handles[s][id] = f;
  endfunction

  //--------------------------------------------------------------------
  // dump_state
  //--------------------------------------------------------------------
  function void dump_state();

    string s;
    severity sev;
    action a;
    string idx;
    FILE f;
 
   id_actions_array id_a_ary;
   id_file_array id_f_ary;

    m_srvr.f_display(0, "----------------------------------------------------------------------");
    m_srvr.f_display(0, "report handler state dump");
    m_srvr.f_display(0, "");

    $sformat(s, "max verbosity level = %d", m_max_verbosity_level);
    m_srvr.f_display(0, s);

    //------------------------------------------------------------------
    // actions
    //------------------------------------------------------------------

    m_srvr.f_display(0, "");   
    m_srvr.f_display(0, "+-------------+");
    m_srvr.f_display(0, "|   actions   |");
    m_srvr.f_display(0, "+-------------+");
    m_srvr.f_display(0, "");   

    m_srvr.f_display(0, "*** actions by severity");
    foreach( severity_actions[sev] ) begin
      $sformat(s, "%s = %s", sev, format_action(severity_actions[sev]));
      m_srvr.f_display(0, s);
    end

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "*** actions by id");

    foreach( id_actions[idx] ) begin
      $sformat(s, "[%-20s] --> %s", idx, format_action(id_actions[idx]));
      m_srvr.f_display(0, s);
    end

    // actions by id

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "*** actions by id and severity");

    foreach( severity_id_actions[sev] ) begin
      id_a_ary = severity_id_actions[sev];
      foreach( id_a_ary[idx] ) begin
        $sformat(s, "%s:%s --> %s", sev, idx, format_action(id_a_ary[idx]));
        m_srvr.f_display(0, s);        
      end
    end

    //------------------------------------------------------------------
    // Files
    //------------------------------------------------------------------

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "+-------------+");
    m_srvr.f_display(0, "|    files    |");
    m_srvr.f_display(0, "+-------------+");
    m_srvr.f_display(0, "");   

    $sformat(s, "default file handle = %d", default_file_handle);
    m_srvr.f_display(0, s);

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "*** files by severity");
    foreach( severity_file_handles[sev] ) begin
      $sformat(s, "%s = %d", sev, severity_file_handles[sev]);
      m_srvr.f_display(0, s);
    end

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "*** files by id");

    foreach ( id_file_handles[idx] ) begin
      $sformat(s, "id %s --> %d", idx, id_file_handles[idx]);
      m_srvr.f_display(0, s);
    end

    m_srvr.f_display(0, "");
    m_srvr.f_display(0, "*** files by id and severity");

    foreach( severity_id_file_handles[sev] ) begin
      id_f_ary = severity_id_file_handles[sev];
      foreach ( id_f_ary[idx] ) begin
        $sformat(s, "%s:%s --> %d", sev, idx, id_f_ary[idx]);
        m_srvr.f_display(0, s);
      end
    end

    m_srvr.dump_server_state();
    
    m_srvr.f_display(0, "----------------------------------------------------------------------");
  endfunction

endclass : avm_report_handler

