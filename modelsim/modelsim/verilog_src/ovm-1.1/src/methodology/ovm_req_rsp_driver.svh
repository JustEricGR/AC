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

/******************************************************************************

  FILE : ovm_req_rsp_driver.svh
                                                                                
******************************************************************************/

`ifndef OVM_REQ_RSP_DRIVER_SVH
`define OVM_REQ_RSP_DRIVER_SVH


//-----------------------------------------------------------------------------
//
// CLASS: ovm_req_rsp_driver
//
//-----------------------------------------------------------------------------

class ovm_req_rsp_driver #(type REQ = ovm_sequence_item,
  type RSP = ovm_sequence_item) extends ovm_driver;

  function new(string name, ovm_component parent);
    super.new(name, parent);
  endfunction

  task get_next_item(output REQ this_req);
    ovm_sequence_item item;
    seq_item_prod_if.get_next_item(item);
    $cast(this_req, item);
  endtask

  task put(input RSP this_rsp);
    seq_item_prod_if.item_done(this_rsp);
  endtask

endclass


`endif // OVM_REQ_RSP_DRIVER_SVH
