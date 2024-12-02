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

typedef class ovm_scenario_controller_base;

class ovm_scenario_base extends ovm_object;

local static int g_id = 0;
local int id;
local ovm_scenario_base  m_parent;

// Weighted priority
local int weighted_priority = 100;

protected bit grant_flag = 0;
protected ovm_scenario_driver_base    m_driver_ptr;
protected ovm_scenario_controller_base m_scenario_controller;

function new (string name);
    super.new(name);
    id = g_id++;
endfunction // new

virtual task pre_apply();
  return;
endtask

virtual task mid_apply();
  return;
endtask

virtual task post_apply();
  return;
endtask // post_apply

virtual task pre_body();
  return;
endtask // pre_body

virtual task body();
  return;
endtask

virtual task post_body();
  return;
endtask // post_body

///////////////////////////////////////////////////
//
// is_relevant
//   indicate to the scenario_controller if this scenario is
//   ready to provide a ovm_transaction
///////////////////////////////////////////////////

virtual function bit is_relevant();
    return 1;
endfunction // bit

///////////////////////////////////////////////////
//
// get_id
//   provide the unique base_id of this scenario
///////////////////////////////////////////////////

function int get_id();
    return id;
endfunction

function int get_weighted_priority();
    return (weighted_priority);
endfunction

function void set_weighted_priority(int val);
    weighted_priority = val;
endfunction

///////////////////////////////////////////////////
//
// grant
//   called by the scenario_controller to grant a request or
//   lock operation
///////////////////////////////////////////////////

virtual function void grant(ovm_scenario_driver_base driver_ptr);
    grant_flag = 1;
    m_driver_ptr = driver_ptr;
endfunction // void

///////////////////////////////////////////////////
//
// get_parent_scenario
//   return a pointer to the parent scenario, or null
//   if this is a top-most scenario
///////////////////////////////////////////////////
  
function ovm_scenario_base get_parent_scenario();
    return m_parent;
endfunction // ovm_scenario_base

///////////////////////////////////////////////////
//
// get_depth
//   return the number of ancestor scenarios this
//   scenario has
///////////////////////////////////////////////////
  
function int get_depth();
    int i;
    ovm_scenario_base ptr; 
    i = 0;
    ptr = get_parent_scenario();

    while (ptr != null) begin
      i++;
      ptr = ptr.get_parent_scenario();
    end
    return (i);
endfunction // int

///////////////////////////////////////////////////
//
// get_scenario_path_name
///////////////////////////////////////////////////
  
function string get_scenario_path_name();
    string s;
    ovm_scenario_base seq_ptr; 
    seq_ptr = get_parent_scenario();

    $sformat(s, "%s", get_name());
    while (seq_ptr != null) begin
      $sformat(s, "%s.%s", seq_ptr.get_name(),s);
      seq_ptr = seq_ptr.get_parent_scenario();
    end
    return (s);
endfunction

///////////////////////////////////////////////////////////
//
// Lock
//    Request a scenario_controller lock, wait until lock is granted
///////////////////////////////////////////////////////////

task lock();
    
    if (m_scenario_controller == null) ovm_report_fatal("seqA", "null m_scenario_controller");
    grant_flag = 0;
    m_scenario_controller.lock_req(this);
    wait (grant_flag == 1);
    grant_flag = 0;
endtask // lock

///////////////////////////////////////////////////
//
// unlock
//   unlock this scenario if locked
///////////////////////////////////////////////////
  
function void unlock();
    if (m_scenario_controller == null) ovm_report_fatal("seqA", "null m_scenario_controller");
    m_scenario_controller.unlock_req(this);
endfunction // unlock

///////////////////////////////////////////////////
//
// is_blocked
//   indicate if another lock prevents this scenario from
//   executing
///////////////////////////////////////////////////
  
function bit is_blocked();
    if (m_scenario_controller == null) ovm_report_fatal("seqA", "null m_scenario_controller");
    return(m_scenario_controller.is_blocked(this));
endfunction

///////////////////////////////////////////////////
//
// start
//   start execution of this scenario
///////////////////////////////////////////////////
  
virtual task start(ovm_scenario_controller_base scenario_controller, 
                   ovm_scenario_base parent_seq = null,
		   int weighted_priority = 100);

    m_scenario_controller = scenario_controller;
    m_parent    = parent_seq;
    set_weighted_priority(weighted_priority);
    pre_body();
    body();
    post_body();
endtask // start

endclass

///////////////////////////////////////////////////
//
// Use the ovm_scenario class if the driver only needs
// to pass a single ovm_transaction back and forth
// for each operation.
///////////////////////////////////////////////////

virtual class ovm_scenario #(type REQ = ovm_transaction,
                              type RSP = ovm_transaction) extends ovm_scenario_base;


  typedef ovm_scenario_driver #(REQ, RSP) p_drv_t;
  protected p_drv_t p_drv;

function new (string name);
    super.new(name);
endfunction // new

///////////////////////////////////////////////////
//
// apply
//   send a scenario_item to the driver, and get
//   the response back
///////////////////////////////////////////////////

  virtual task apply_request(input REQ data_req, input bit randomize = 1);
    grant_flag = 0;
    if (m_scenario_controller == null) ovm_report_fatal("seqA", "null m_scenario_controller");
    m_scenario_controller.request(this);
    wait(grant_flag == 1);
    pre_apply();

    if (m_driver_ptr == null) ovm_report_fatal(get_full_name(), "null m_driver_ptr");
    grant_flag = 0;
    if (randomize == 1) begin
      assert(data_req.randomize());
    end
    mid_apply();
  endtask
  
virtual task apply_send(input REQ data_req, input bit randomize = 1);
    
    apply_request(data_req, randomize);

    if ($cast(p_drv, m_driver_ptr) == 0) begin
      ovm_report_fatal("ovm_scenario", "Error casting pdrv from driver_ptr");
    end
    
    p_drv.put_req.put(data_req);
    post_apply();
endtask    
    
virtual task apply(input REQ data_req, output RSP data_rsp, input bit randomize = 1);
    
    apply_request(data_req, randomize);

    if ($cast(p_drv, m_driver_ptr) == 0) begin
      ovm_report_fatal("ovm_scenario", "Error casting pdrv from driver_ptr");
    end
    
    p_drv.put_req.put(data_req);
    p_drv.get_rsp.get(data_rsp);
    post_apply();
endtask    
    
endclass

///////////////////////////////////////////////////
//
// Use the ovm_scenario_noparam class for drivers
// that need arbitrary ports and communication with
// the sequenc
///////////////////////////////////////////////////
  
virtual class ovm_scenario_noparam extends ovm_scenario_base;

function new (string name);
    super.new(name);
endfunction // new

virtual task send_request(output ovm_scenario_driver_base driver_ptr);
    grant_flag = 0;
    
    if (m_scenario_controller == null) ovm_report_fatal("seqA", "null m_scenario_controller");
    m_scenario_controller.request(this);
    wait(grant_flag == 1);
    pre_apply();

    if (m_driver_ptr == null) ovm_report_fatal(get_full_name(), "null m_driver_ptr");
    grant_flag = 0;
    driver_ptr = m_driver_ptr;
    return;
endtask

virtual task send();
endtask    
    
endclass


static int inst_num = 0;

class ovm_stimulus_scenario #(type REQ = ovm_transaction) 
  extends ovm_scenario  #(REQ, REQ);

tlm_fifo #(REQ) m_req_fifo;
ovm_blocking_put_export #(REQ) put_req_export;


function new (string name, ovm_component parent);
    string nm;
    super.new(name);
    nm.itoa(inst_num);
    inst_num++;
    // Assign null, since scenarios aren't components
    put_req_export = new({"stim_put_req_export_",nm}, null);
    m_req_fifo     = new({"stim_req_fifo_",nm}, null, 1);
    put_req_export.connect(m_req_fifo.put_export);
endfunction // new

task body();
    REQ req;

    forever begin
      m_req_fifo.get(req);
      apply_send(req);
    end
endtask // body
endclass
  
