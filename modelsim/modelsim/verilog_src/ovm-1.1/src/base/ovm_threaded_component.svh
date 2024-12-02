// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_threaded_component.svh#1 $
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// 
// CLASS: ovm_threaded_component
//
//------------------------------------------------------------------------------

virtual class ovm_threaded_component extends ovm_component;
    
  extern function new( string name , ovm_component parent );

  extern virtual  task                   run     ();

  // process control for task-based phases, e.g. 'run'
  extern virtual  task                   suspend ();
  extern virtual  task                   resume  ();
  extern virtual  task                   restart ();
  extern virtual  function void          kill    ();
  extern function string                 status  ();

  extern virtual  function void  do_kill_all ();

  // method called to execute a task-based phase (e.g. 'run').
  // Overrides can do pre- and post-phase activities;
  // should call super.do_task_phase.
  extern virtual task do_task_phase (ovm_phase phase);

  `ifndef INCA
  protected process m_phase_process;
  `endif
  protected event m_kill_request;

  // prevents unnecessary phase insertion
  local static bit m_phases_loaded=0;

endclass : ovm_threaded_component 



//-----------------------------------------------------------------------------
//
// IMPLEMENTATION
//
//-----------------------------------------------------------------------------

`ovm_phase_task_decl(run,0)
run_phase #(ovm_threaded_component) run_ph = new();


// new
// ---

function ovm_threaded_component::new (string name, ovm_component parent);
  super.new(name, parent);
  if (!(parent==null && name == "__top__")) begin
    if (!ovm_threaded_component::m_phases_loaded) begin
      ovm_threaded_component::m_phases_loaded=1;
      ovm_top.insert_phase(run_ph, pre_run_ph);
    end
  end
endfunction


// do_task_phase
// -------------

task ovm_threaded_component::do_task_phase (ovm_phase phase);

  m_curr_phase = phase;
  // QUESTA
  `ifndef INCA  

    fork
      begin
        m_phase_process = process::self();
        phase.call_task(this);
        @m_kill_request;
      end
    join

  `else
  // INCISIVE
   fork begin // isolate inner fork so can safely kill via disable fork
     fork : task_phase
       // process 1 - call task; if returns, keep alive until kill request
       begin
         phase.call_task(this);
         @m_kill_request;
       end
       // process 2 - any kill request will preempt process 1
       @m_kill_request;
     join_any
     disable fork;
   end
   join
  `endif

endtask


// do_kill_all
// -----------

function void ovm_threaded_component::do_kill_all();
  super.do_kill_all();
  kill();
endfunction


// kill
// ----

function void ovm_threaded_component::kill();
  `ifndef INCA
    if (m_phase_process != null) begin
      m_phase_process.kill;
      m_phase_process = null;
    end
  `else
     ->m_kill_request;
  `endif
endfunction


// suspend
// -------

task ovm_threaded_component::suspend();
  `ifndef INCA
  if(m_phase_process != null)
    m_phase_process.suspend;
  `else
  ovm_report_error("UNIMP", "suspend not implemented in IUS");
  `endif
endtask


// resume
// ------

task ovm_threaded_component::resume();
  `ifndef INCA
  if(m_phase_process!=null) 
    m_phase_process.resume;
  `else
   ovm_report_error("UNIMP", "resume not implemented in IUS");
  `endif
endtask


// restart
// -------

task ovm_threaded_component::restart();
  ovm_report_warning("UNIMP",
      $psprintf("%0s: restart not implemented",this.get_name()));
endtask


// status
//-------

function string ovm_threaded_component::status();

  `ifndef INCA
  process::state ps;

  if(m_phase_process == null)
    return "<unknown>";

  ps = m_phase_process.status();

  return ps.name();
  `else
   ovm_report_error("UNIMP", "status not implemented in IUS");
  `endif

endfunction


// run
// ---

task ovm_threaded_component::run();
  return;
endtask

