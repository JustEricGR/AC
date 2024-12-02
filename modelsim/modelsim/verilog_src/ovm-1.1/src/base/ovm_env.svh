// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_env.svh#1 $
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
// CLASS: ovm_env
//
//------------------------------------------------------------------------------
// The ovm_env component is intended to be a container of components that
// together comprise a complete environment. The environment may
// initially consist of the entire testbench. Later, it can be reused as
// a child-env of even larger system-level environments.
//
// AVM compatibility (do_test) mode: (deprecated, do not use in new code)
//
//   The top-most ovm_env's run phase has special semantics when
//   simulation is started via 'do_test', i.e. AVM backward compatibility
//   mode. When the top env's run task returns, an automatic global_stop_
//   request is issued, thus ending the run phase. When not in 'do_test'
//   mode, the run phase behaves like any other- when it returns, it does
//   signify the end of the phase. Rather, an explicit global_stop_request
//   must be issued to end the phase. 
//------------------------------------------------------------------------------

virtual class ovm_env extends ovm_threaded_component;

  extern function new (string name="env", ovm_component parent=null);

  extern virtual function string get_type_name ();

  extern virtual task run ();

  /*** DEPRECATED - Do not use in new code.  Convert code when appropriate ***/
  extern virtual task do_task_phase (ovm_phase phase);
  extern virtual task do_test ();
  extern static task run_test(string name="");
  protected bit m_do_test_mode = 0;

endclass



//------------------------------------------------------------------------------
//
// IMPLEMENTATION
//
//------------------------------------------------------------------------------

// new
// ---

function ovm_env::new (string name="env", ovm_component parent=null);
  super.new(name,parent);
endfunction


// get_type_name
// -------------

function string ovm_env::get_type_name ();
  return "ovm_env";
endfunction


// run
// ---

task ovm_env::run();
  return; 
endtask


// do_phase (deprecated)
// --------

task ovm_env::do_task_phase (ovm_phase phase);
  
  // Top-level env has special run-phase semantic when in 'do_test' mode.
  // In all other cases, ovm_env's run phase behaves like any other.

  m_curr_phase = phase;

  if (!(m_do_test_mode && phase == run_ph && m_parent == ovm_top)) begin
    super.do_task_phase(phase);
    return;
  end

  // Delay 1 delta to ensure this env's process starts last, thus
  // allowing sub-tree of components to initialize before this
  // run-task starts.

  #0;

  // QUESTA
  `ifndef INCA  

     m_phase_process = process::self();
     phase.call_task(this);

  // INCISIVE
  `else

     // isolate inner process so it can be safely killed via disable fork,
     fork
     begin
       fork : task_phase
         phase.call_task(this);
         @m_kill_request;
       join_any
       disable task_phase;
     end
     join

  `endif

  ovm_top.stop_request(); // ends run phase

endtask


// do_test (deprecated)
// -------

task ovm_env::do_test();
  m_do_test_mode=1;
  report_header();
  ovm_top.run_global_phase();
  report_summarize();
endtask


// run_test (deprecated)
// --------

task ovm_env::run_test(string name="");
  ovm_top.run_test(name);
endtask
