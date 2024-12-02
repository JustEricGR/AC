// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/utils/avm_threaded_component.svh#1 $
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
// CLASS avm_threaded_component
//
// Every verification component that needs to start
// executing before simulation needs to inherit from this
// class. Typically, this is the case for transactors and is
// not the case for stimulus generators and coverage
// objects. Some scoreboards do need to start at time zero,
// in which case they will need to inherit from this class,
// others will be purely reactive, in which case they don't.
//
//----------------------------------------------------------------------

virtual class avm_threaded_component extends avm_named_component;
    
  protected process m_main_process;
  
  // constructor. same as avm_named_component
  
  function new( string name , avm_named_component parent ) ;
    super.new( name , parent );
  endfunction

  // not really a user visible method. do_run_all is used by
  // avm_env to kick off all all of the run methods in all
  // of the verification components
  
   task do_run_all();
   
   super.do_run_all();
    fork
      begin
        m_main_process = process::self();
        run();
      end
    join_none;
   endtask : do_run_all

  // not really a user visible method. kill_all is used by
  // avm_env to kill off all all of the run methods in all
  // of the verification components
  
  function void do_kill_all();
    kill();
    super.do_kill_all();
  endfunction : do_kill_all
    
  // kills the run method
  
  virtual function void kill;
   if (m_main_process != null) begin
      m_main_process.kill;
      m_main_process = null;
      end
  endfunction
  
  // suspends the run method.
  
  virtual task suspend;
    m_main_process.suspend;
  endtask 
  
  // resumes the run method.
  
  virtual task resume;
    m_main_process.resume;
  endtask
  
  // run must be overloaded in any subclass. This is the
  // task that gets kicked off by the environment class.
  // use start_thread to execute this task.
  pure virtual task run();
    
endclass : avm_threaded_component 

