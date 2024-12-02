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

typedef enum {TYPE_REQ, TYPE_LOCK} REQ_TYPE;
typedef enum {FIFO, WEIGHTED, RANDOM} ARBITRATION_TYPE;

typedef class ovm_scenario_base;
typedef class ovm_scenario_driver_base;

class ovm_scenario_controller_base extends ovm_threaded_component;

  protected REQ_TYPE            arb_req_q[$];
  protected ovm_scenario_base  arb_scen_q[$];
  protected ovm_scenario_base  lock_list[$];
  local     ovm_scenario_controller_base m_push_if;

// Weighted Priority
  local ARBITRATION_TYPE   arbitration = FIFO;

///////////////////////////////////////////////////

function new (string name, ovm_component parent, ovm_scenario_controller_base push_if = null);
    super.new(name, parent);
    m_push_if = push_if;
endfunction // new

///////////////////////////////////////////////////
//
// Local functions
//
///////////////////////////////////////////////////

local function string display_queues();
    string s;

    $sformat(s, "  -- arb i/type/id: ");
    foreach (arb_scen_q[i]) begin
      $sformat(s, "%s %0d/%s/%0d ", s, i, arb_req_q[i], arb_scen_q[i].get_id());
    end
    $sformat(s, "%s\n  -- lock i/id: ", s);
    foreach (lock_list[i]) begin
      $sformat(s, "%s %0d/%0d ", s, i, lock_list[i].get_id());
    end
    return(s);
endfunction


///////////////////////////////////////////////////
//
// arb_lock_grant()
//    Find all queued lock requests and grant them if
//    possible
///////////////////////////////////////////////////

local function void arb_lock_grant();
    int i, temp;
    
    for (i = 0; i < arb_scen_q.size(); i++) begin

      // If this is a lock request, and the lock is available,
      // then grant the lock

      temp = 0;
      if (i < arb_scen_q.size()) begin
	if (arb_req_q[i] == TYPE_LOCK) begin
	  temp = is_blocked(arb_scen_q[i]) == 0;
	end
      end
      
      
      while (temp) begin
        lock_list.push_back(arb_scen_q[i]);
        arb_scen_q[i].grant(null);
        arb_req_q.delete(i);
        arb_scen_q.delete(i);
	
	temp = 0;
	if (i < arb_scen_q.size())
	  if (arb_req_q[i] == TYPE_LOCK)
	    temp = is_blocked(arb_scen_q[i]) == 0;
      end
    end // for (i = 0; i < arb_scen_q.size(); i++)
endfunction // arb_lock_grant

///////////////////////////////////////////////////
//
// choose_next_request
//    When a driver requests an operation, this funciton
//    must find the next available, unlocked, relevant scenario
///////////////////////////////////////////////////

local function int choose_next_request();
    int i, temp;
    int avail_scen_count;
    int sum_priority_val;
    int avail_scenarios[$];

    avail_scen_count = 0;
    for (i = 0; i < arb_scen_q.size(); i++) begin
      // If this is a lock request, and the lock is available,
      // then grant the lock
      
      temp = 0;
      if (i < arb_scen_q.size()) begin
	if (arb_req_q[i] == TYPE_LOCK) begin
	  temp = is_blocked(arb_scen_q[i]) == 0;
	end
      end
      while (temp) begin
        lock_list.push_back(arb_scen_q[i]);
        arb_scen_q[i].grant(null);
        arb_req_q.delete(i);
        arb_scen_q.delete(i);

	temp = 0;
	if (i < arb_scen_q.size()) begin
	  if (arb_req_q[i] == TYPE_LOCK) begin
	    temp = is_blocked(arb_scen_q[i]) == 0;
	  end
	end
      end
      
      // choose the first i that is ready and is a request
      if (i < arb_scen_q.size())
	if (arb_req_q[i] == TYPE_REQ)
          if (is_blocked(arb_scen_q[i]) == 0)
            if (arb_scen_q[i].is_relevant() == 1) begin
	      if (arbitration == FIFO) return (i);
              else avail_scenarios.push_back(i);
	    end
    end // for (i = 0; i < arb_scen_q.size(); i++)
    
    // Return immediately if there are 0 or 1 available scenarios
    if (arbitration == FIFO) return (-1);
    if (avail_scenarios.size() < 1)  return (-1);
    if (avail_scenarios.size() == 1) return (avail_scenarios[0]);
    
    // If any locks are in place, then the available queue must
    // be checked to see if a lock prevents any scenario from proceeding
    if (lock_list.size() > 0) begin
      for (i = 0; i < avail_scenarios.size(); i++) begin
	if (is_blocked(arb_scen_q[avail_scenarios[i]]) != 0) begin
	  avail_scenarios.delete(i);
	  i--;
	end
      end
      if (avail_scenarios.size() < 1) return (-1);
      if (avail_scenarios.size() == 1) return (avail_scenarios[0]);
    end
    
    ///////////////////////////////////
    //  Weighted Priority Distribution
    ///////////////////////////////////
    if (arbitration == WEIGHTED) begin
      sum_priority_val = 0;
      for (i = 0; i < avail_scenarios.size(); i++) begin
	sum_priority_val += arb_scen_q[avail_scenarios[i]].get_weighted_priority();
      end
      
      // Pick an available scenario based on weighted priorities of available scenarios
      temp = $urandom_range(sum_priority_val-1, 0);
      sum_priority_val = 0;
      for (i = 0; i < avail_scenarios.size(); i++) begin
	if ((arb_scen_q[avail_scenarios[i]].get_weighted_priority() + 
	     sum_priority_val) > temp) begin
	  return (avail_scenarios[i]);
	end
	sum_priority_val += arb_scen_q[avail_scenarios[i]].get_weighted_priority();
      end
    end // if (arbitration == WEIGHTED)
    
    ///////////////////////////////////
    //  Random Distribution
    ///////////////////////////////////
    if (arbitration == RANDOM) begin
      i = $urandom_range(avail_scenarios.size()-1, 0);
      return (avail_scenarios[i]);
      return avail_scenarios[i];
    end
    ovm_report_fatal("Scenario controller", "Internal error: Failed to choose scenario");
endfunction 

function void set_arbitration(ARBITRATION_TYPE val);
    arbitration = val;
endfunction // void

///////////////////////////////////////////////////
//
// is_child
//    Determine if a scenario is a child of a parent
///////////////////////////////////////////////////

function bit is_child (ovm_scenario_base parent, ovm_scenario_base child);
    ovm_scenario_base scenario_ptr;

    scenario_ptr = child.get_parent_scenario();
    while (scenario_ptr != null) begin
      if (scenario_ptr.get_id() == (parent.get_id())) begin
        return (1);
      end
      scenario_ptr = scenario_ptr.get_parent_scenario();
    end
    return (0);
endfunction // bit

///////////////////////////////////////////////////
//
// is_blocked
//    Determine if a scenario is locked out
///////////////////////////////////////////////////
  
function bit is_blocked(ovm_scenario_base scenario_ptr);

    if (scenario_ptr == null)
      ovm_report_fatal("ovm_scenario_controller", "is_blocked passed null scenario_ptr");
    
    if (m_push_if == null) begin
      foreach (lock_list[i]) begin
        if ((lock_list[i].get_id() != scenario_ptr.get_id()) &&
            (is_child(lock_list[i], scenario_ptr) == 0)) begin
          return (1);
        end
      end 
      return (0);
    end else begin
      return (m_push_if.is_blocked(scenario_ptr));
    end 
endfunction // is_locked

///////////////////////////////////////////////////
//
// lock_req
//    Called by a scenario to request a lock.  Puts
//    the lock request onto the arbitration queue
///////////////////////////////////////////////////
  
function void lock_req(ovm_scenario_base scenario_ptr);
    if (scenario_ptr == null)
      ovm_report_fatal("ovm_scenario_controller", "lock_req passed null scenario_ptr");

    if (m_push_if == null) begin
      arb_scen_q.push_back(scenario_ptr);
      arb_req_q.push_back(TYPE_LOCK);
    end else begin
      m_push_if.lock_req(scenario_ptr);
    end
endfunction    
    
///////////////////////////////////////////////////
//
// unlock_req
//    Called by a scenario to request an unlock.  This
//    will remove a lock for this scenario if it exists
///////////////////////////////////////////////////
  
function void unlock_req(ovm_scenario_base scenario_ptr);
    if (scenario_ptr == null)
      ovm_report_fatal("ovm_scenario_controller", "unlock_req passed null scenario_ptr");
    if (m_push_if == null) begin
      foreach (lock_list[i]) begin
        if (lock_list[i].get_id() == scenario_ptr.get_id()) begin
          lock_list.delete(i);
          return;
        end
      end
    end else begin
      m_push_if.unlock_req(scenario_ptr);
    end 
endfunction

///////////////////////////////////////////////////
//
// request
//    Called by a scenario to request a ovm_transaction
//    to be executed by the driver
///////////////////////////////////////////////////
  
function void request(ovm_scenario_base scenario_ptr);
    if (scenario_ptr == null)
      ovm_report_fatal("ovm_scenario_controller", "request passed null scenario_ptr");

    if (m_push_if == null) begin
      arb_scen_q.push_back(scenario_ptr);
      arb_req_q.push_back(TYPE_REQ);
    end else begin
      m_push_if.request(scenario_ptr);
    end // else: !if(lock_list[i].get_id() == scenario_ptr.get_id())
endfunction

///////////////////////////////////////////////////
//
// Driver request
//    Called by a driver to request a ovm_transaction
///////////////////////////////////////////////////
  
task driver_request (input ovm_scenario_driver_base driver_ptr, 
		     output ovm_scenario_base chosen_scen, input bit non_blocking = 0 );
    ovm_scenario_base scenario_ptr;
    int select_num, req_size;

    if (driver_ptr == null)
      ovm_report_fatal("ovm_scenario_controller", "driver_request passed null driver ptr");

    #0; //Allow scenario requests in before arbitrating.  Needed for weighted distribution
    select_num = choose_next_request();

    // Non-blocking logic - if no item availabe, and a non-blocking
    // request was made, then return a null
    if ((select_num < 0) && (non_blocking == 1)) begin
      chosen_scen = null;
      return;
    end
    
    while (select_num < 0) begin
      // If we just granted a lock, allow the scenario
      // to put a request in the queue
      req_size = arb_scen_q.size();
      wait (arb_scen_q.size() != req_size);
      select_num = choose_next_request();
    end

    // If no scenario was chosen, then return null
    if (select_num < 0) begin
      chosen_scen = null;
      return;
    end
      
    scenario_ptr = arb_scen_q[select_num];
    arb_scen_q.delete(select_num);
    arb_req_q.delete(select_num);
    
    // return the driver pointer when granting the scenario
    scenario_ptr.grant(driver_ptr);
    // return the scenario pointer to the driver
    chosen_scen = scenario_ptr;
endtask // driver_request

virtual task run();
  return;
endtask // run

endclass

  
class ovm_scenario_controller #(type REQ = ovm_transaction,
				type RSP = ovm_transaction) extends ovm_scenario_controller_base;

// For driver ports to connect to the request_driver
ovm_blocking_get_export #(REQ) get_req_export;
ovm_blocking_put_export #(RSP) put_rsp_export;

// For stimulus generators to connect to the stimulus scenario
ovm_blocking_put_export #(REQ) put_req_export;

request_driver #(REQ, RSP) req_driver;
ovm_stimulus_scenario #(REQ) stimulus_scenario;

function new (string name, ovm_component parent, ovm_scenario_controller_base push_if = null);
    super.new(name, parent, push_if);
    req_driver = new("nscenr_drv", this);
    req_driver.set_scenario_controller(this);
    stimulus_scenario = new("scenario_stim", this);
    get_req_export = new("reqdrv_req_export", this);
    put_rsp_export = new("reqdrv_rsp_export", this);
    put_req_export = new("stimscen_req_export", this);
endfunction // new

function void connect();
    get_req_export.connect(req_driver.get_req_export);
    put_rsp_export.connect(req_driver.put_rsp_export);
    put_req_export.connect(stimulus_scenario.put_req_export);
endfunction

task run();
    stimulus_scenario.start(this, null);
endtask // run
  
endclass

