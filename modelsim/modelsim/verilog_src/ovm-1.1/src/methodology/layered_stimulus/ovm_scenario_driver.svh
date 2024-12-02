// $Id: ovm_scenario_driver.svh,v 1.3 2007/12/20 17:24:55 jlrose Exp $
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


typedef class ovm_scenario_driver_base;
typedef class ovm_scenario_controller_base;
typedef class ovm_scenario_base;

class ovm_scenario_driver_base extends ovm_threaded_component;

  protected ovm_scenario_controller_base m_scenario_controller_ptr;
  protected ovm_scenario_base scenario_base_ptr;

function new (string name, ovm_component parent);
    super.new(name, parent);
endfunction // new

function void set_scenario_controller(ovm_scenario_controller_base scenario_controller_ptr);
    m_scenario_controller_ptr = scenario_controller_ptr;
endfunction

task run();
  return;
endtask // run

endclass

///////////////////////////////////////////////////
//
// Use the ovm_scenario_driver class if the driver only needs
// to pass a single ovm_transaction back and forth
// for each operation.
///////////////////////////////////////////////////

class tlm_scenario_fifo #(type T = int) extends tlm_fifo #(T);

  //--------------------------------------------------------------------
  // constructor (new)
  //--------------------------------------------------------------------
  function new(string name, ovm_component parent = null, int size = 1);
    super.new(name, parent);
  endfunction // new

  task wait_for_pending_get();
    wait(m_pending_blocked_gets > 0);
  endtask // wait_for_pending_get

  function bit pending_get_in_progress();
    return (m_pending_blocked_gets > 0);
  endfunction // bit

endclass 

class tlm_scenario_req_rsp_channel #( type REQ = int , type RSP = int )
  extends tlm_req_rsp_channel #(REQ, RSP);

  tlm_scenario_fifo #( REQ ) m_scenario_request_fifo;

  function new( string name , ovm_component parent = null , 
                int request_fifo_size = 1 ,
                int response_fifo_size = 1 );
    super.new(name, parent, request_fifo_size, response_fifo_size);
    m_scenario_request_fifo = new("scenario_request_fifo", this, request_fifo_size);
    m_request_fifo = m_scenario_request_fifo;

  endfunction // new

  function bit pending_get_in_progress();
    return (m_scenario_request_fifo.pending_get_in_progress());
  endfunction // bit

  task wait_for_pending_get();
    m_scenario_request_fifo.wait_for_pending_get();
  endtask // wait_for_pending_get

endclass

virtual class ovm_scenario_driver #(type REQ = ovm_transaction, type RSP = ovm_transaction) 
  extends ovm_scenario_driver_base;

typedef ovm_scenario_driver #(REQ, RSP) p_drv;

  tlm_scenario_req_rsp_channel #(REQ, RSP) req_rsp;
  ovm_blocking_get_export #(REQ) get_req_export;
  ovm_blocking_put_export #(RSP) put_rsp_export;
  ovm_blocking_get_export #(REQ) get_req;
  ovm_blocking_put_export #(REQ) put_req;
  ovm_blocking_put_export #(RSP) put_rsp;
  ovm_blocking_get_export #(RSP) get_rsp;




function new (string name, ovm_component parent);
    super.new(name, parent);
    req_rsp = new("sqrdrv_req_rsp", this);
    put_req = new("sqrdrv_put_req", this);
    get_rsp = new("sqrdrv_get_rsp", this);
    put_rsp = new("sqrdrv_put_rsp", this);
    get_req = new("sqrdrv_get_req", this);
    get_req_export = new("sqrdrv_get_req_export", this);
    put_rsp_export = new("sqrdrv_put_rsp_export", this);
    
    get_req.connect(req_rsp.blocking_get_request_export);
    put_req.connect(req_rsp.blocking_put_request_export);
    get_rsp.connect(req_rsp.blocking_get_response_export);
    put_rsp.connect(req_rsp.blocking_put_response_export);
    get_req_export.connect(req_rsp.blocking_get_request_export);
    put_rsp_export.connect(req_rsp.blocking_put_response_export);
    
endfunction // new

///////////////////////////////////////////////////
//
// get_next_item
//   Called by the driver to issue a request from
//   the scenario_controller and return the next scenario item
///////////////////////////////////////////////////

virtual task get_next_item(output REQ req_item, input bit non_blocking = 0);

    if (m_scenario_controller_ptr == null) begin
      req_item = null;
      return;
    end
    m_scenario_controller_ptr.driver_request(this, scenario_base_ptr, non_blocking);
    if (scenario_base_ptr == null) begin
      req_item = null;
      return;
    end
    get_req.get(req_item);
    return;
endtask

virtual task run();
endtask // run

endclass

///////////////////////////////////////////////////
//
// Use the ovm_scenario_driver_noparam class for drivers
// that need arbitrary ports and communication with
// the sequenc
///////////////////////////////////////////////////
  
virtual class ovm_scenario_driver_noparam extends ovm_scenario_driver_base;

typedef ovm_scenario_driver_noparam p_drv;
  
function new (string name, ovm_component parent);
    super.new(name, parent);
endfunction // new

virtual task run();
endtask // run

endclass

class request_driver #(type REQ = ovm_transaction,
                       type RSP = ovm_transaction)  extends ovm_scenario_driver #(REQ, RSP);

REQ req;
RSP rsp;

//tlm_blocking_peek_if #(REQ), get_peek;

function new (string name, ovm_component parent);
    super.new(name, parent);
//    get_peek.new("nb_get_peek", this);
endfunction // new

task run();
    // Somehow, wait for driver to have done a try_get()
//    wait (can_put() == 1);
    forever begin
      // Wait for driver to issue get()
      req_rsp.wait_for_pending_get();
      if (m_scenario_controller_ptr == null) begin
        ovm_report_fatal(get_full_name(), "request_driver has Null scenario_controller");
      end
      
      m_scenario_controller_ptr.driver_request(this, scenario_base_ptr);
    end // forever begin
endtask // run

endclass

