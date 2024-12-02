// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/reporting/avm_report_server.svh#1 $
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
// CLASS avm_report_server
//----------------------------------------------------------------------
class avm_report_server;

  local int max_quit_count; 
  local int quit_count;
  local int severity_count[severity];
  local int id_count[string];


  // Singleton object that maintains a single global report server
  static avm_report_server global_report_server;

  static function avm_report_server get_server();
    if (global_report_server == null)
      global_report_server = new;
    return global_report_server;
  endfunction

  protected function new();
    set_max_quit_count(0);
    reset_quit_count();
    reset_severity_counts();
  endfunction

  //--------------------------------------------------------------------
  // accessors for setting, getting, and incrementing
  // the various counts
  //--------------------------------------------------------------------
  function int get_max_quit_count();
    return max_quit_count;
  endfunction

  function void set_max_quit_count(int m);
    if(m < 0)
      m = 0;
    max_quit_count = m;
  endfunction

  function void reset_quit_count();
    quit_count = 0;
  endfunction

  function void incr_quit_count();
    quit_count++;
  endfunction

  function int get_quit_count();
    return quit_count;
  endfunction

  function bit is_quit_count_reached();
    return (quit_count >= max_quit_count);
  endfunction

  function void reset_severity_counts();
    severity s;

    s = s.first();
    forever begin
      severity_count[s] = 0;
      if(s == s.last()) break;
      s = s.next();
    end

  endfunction

  function int get_severity_count(severity s);
    return severity_count[s];
  endfunction

  function void incr_severity_count(severity s);
    severity_count[s]++;
  endfunction

  function void set_id_count(string id, int n);
    id_count[id] = n;
  endfunction

  function int get_id_count(string id);
    if(id_count.exists(id))
      return id_count[id];
    return 0;
  endfunction

  function void incr_id_count(string id);
    if(id_count.exists(id))
      id_count[id]++;
    else
      id_count[id] = 1;
  endfunction

  //--------------------------------------------------------------------
  // f_display
  //--------------------------------------------------------------------
  function void f_display(FILE f, string s);
    if(f == 0) begin
      $display(s);
    end
    else begin
      $fdisplay(f, s);
    end
  endfunction

  //--------------------------------------------------------------------
  // process_report
  //--------------------------------------------------------------------
  extern virtual function void process_report(
      severity s,
      string name,
      string id,
      string message,
      action a,
      FILE f,
      string filename,
      int line,
      int verbosity,
      avm_report_client client
    );
  //--------------------------------------------------------------------
  // compose_message
  //--------------------------------------------------------------------
  extern virtual function string compose_message(severity s,
						 string name,
						 string id,
						 string message,
						 string filename,
						 int line);
  //--------------------------------------------------------------------
  // summarize
  //
  // summarize prints out report statistics to the standard
  // output
  //--------------------------------------------------------------------
  function void  summarize(FILE f = 0);
    string id;
    string name;
    string output_str;

    f_display(f, "");
    f_display(f, "--- AVM Report Summary ---");
    f_display(f, "");

    if(max_quit_count != 0) begin
      if (is_quit_count_reached())
	f_display(f, "Quit count reached!");
      $sformat(output_str, "Quit count : %d of %d",
                             quit_count, max_quit_count);
      f_display(f, output_str);
    end

    f_display(f, "** Report counts by severity");
    for(severity s = s.first(); 1; s = s.next()) begin
      if(severity_count.exists(s)) begin
        $sformat(output_str, "%-8s :%5d", s.name, severity_count[s]);
        f_display(f, output_str);
      end
      if(s == s.last()) break;
    end

    f_display(f, "** Report counts by id");
    for(int found = id_count.first(id);
         found;
         found = id_count.next(id)) begin
    
      $sformat(output_str, "[%-20s] %5d", id, id_count[id]);
      f_display(f, output_str);
    end

  endfunction

  //--------------------------------------------------------------------
  // dump_server_state
  //--------------------------------------------------------------------
  function void dump_server_state();

    string s;
    severity sev;
    string id;

    f_display(0, "report server state");
    f_display(0, "");   
    f_display(0, "+-------------+");
    f_display(0, "|   counts    |");
    f_display(0, "+-------------+");
    f_display(0, "");

    $sformat(s, "max quit count = %5d", max_quit_count);
    f_display(0, s);
    $sformat(s, "quit count = %5d", quit_count);
    f_display(0, s);

    sev = sev.first();
    forever begin
      $sformat(s, "%-8s :%5d", sev.name(), severity_count[sev]);
      f_display(0, s);
      if(sev == sev.last())
        break;
      sev = sev.next();
    end

    if(id_count.first(id))
    do begin
      $sformat(s, "[%-20s] = %5d", id, id_count[id]);
      f_display(0, s);
    end
    while (id_count.next(id));

  endfunction

endclass

`include "reporting/avm_extern_report_server.svh"

