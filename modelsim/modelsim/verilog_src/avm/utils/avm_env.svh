// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/utils/avm_env.svh#1 $
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

//----------------------------------------------------------------------
// CLASS env
//----------------------------------------------------------------------

// Subclasses of the avm_env class hold all the classes in
// that together constitute the testbench. These subclasses
// must define their own run method, and may also define their own 
// connect, configure and report methods

virtual class avm_env extends avm_named_component;

  avm_connection_phase_e m_connection_phase = AVM_CONSTRUCTION_PHASE;
  local process m_run_process;
  
  function new( string name = "env" );
    super.new( name , null , 0 );
    avm_named_component::s_current_env = this;
  endfunction
  
  // 
  // Subclasses are expected to new all the named and
  // verification components that make up the testbench in
  // their constructor.
  // 
  // The sub class' constructor also needs to make a local
  // copy of all the virtual interfaces used in this
  // testbench
  
  // do_test is the top level method called from a top level
  // module or program block.  This is the only user visible
  // method in avm_env
  
  virtual task do_test();

    report_header(); // print a banner

    elaborate();
  
    do_configure();


   $ui_VVElaborate();
   
    // execution phases
    do_run_all();
 
    fork
      begin
        m_run_process = process::self();
        run();
      end
    join
  
    // finish

    do_kill_all();  
    do_report();
  
  endtask

  //
  // elaborate displays the hierarchy, connects up all the ports, exports and
  // imps, and then calls end_of_elaboration for each component
  //
  
  local function void elaborate();
    do_set_env( this );
  
    // connect up exports first ( bottom up )
    m_connection_phase = AVM_EXPORT_CONNECTIONS_PHASE;
    do_export_connections();
  
    // then connect "my" children's ports to their siblings' exports
    m_connection_phase = AVM_CONNECT_PHASE;
    do_connect();
    
    // then propagate port connections down through the 
    // hierarchy ( top down )
    m_connection_phase = AVM_IMPORT_CONNECTIONS_PHASE;
    do_import_connections();

    // check minimum connections have been made throughout hierarchy
    m_connection_phase = AVM_DONE_CONNECTIONS_PHASE;
    check_connection_size();

    do_end_of_elaboration();
  endfunction
  
  
  // connect is usually overloaded in any subclass. It connects
  // up the top level objects of the testbench. This will
  // include assignment of virtual interfaces of the form
  // transactor.m_vif = m_vif; and child port to child
  // export assignments of the form child.port.connect( child.export );

  virtual function void connect;
    return;
  endfunction

  //
  // configure is a function - ie no interraction with the scheduler is
  // allowed.
  //
  // The main intention of this method is to allow configuration of
  // verification components before the simulation starts, although it
  // may be that back door memory accesses are also done here
  //

  virtual function void configure();
    return;
  endfunction

  // The run task is where stimulus generation is
  // started and stopped, and scoreboards and coverage
  // objects are examined from within the testbench, if this
  // is required.

  virtual task run();
    avm_report_warning(
      s_deprecated_3_0 ,
      "Please use run instead of execute" ,
      500 ); 
    execute();
  endtask

  // for backwards compatibility, run calls execute

  virtual task execute();
  endtask

  // The report function is used to report on the status of
  // the avm_env subclass at the end of simulation.
  // Usually, nothing much will happen here, since the report methods
  // of the testbench components get called automatically
  // and are generally more useful.

  virtual function void report();     // report
    avm_report_message("avm_env" , "Finished Test");
    report_summarize();
    return;
  endfunction

  task do_run_all();
    super.do_run_all();
    #0; // allow all other tasks to get going before continuing
  endtask

  function void do_kill_all();
    kill();
    super.do_kill_all();
  endfunction
  
  // kills the run method.
  
  virtual function void kill;
    m_run_process.kill;
  endfunction
  
  // suspends the run method.
  
  virtual task suspend;
    m_run_process.suspend;
  endtask 
  
  // resumes the run method.
  
  virtual task resume;
    m_run_process.resume;
  endtask

endclass
