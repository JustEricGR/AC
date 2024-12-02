// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_virtual_sequencer.svh#1 $
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

`ifndef OVM_VIRTUAL_SEQUENCER_SVH
`define OVM_VIRTUAL_SEQUENCER_SVH


//------------------------------------------------------------------------------
//
// CLASS: ovm_seq_cons_if
//
//------------------------------------------------------------------------------

class ovm_seq_cons_if extends ovm_component;

  // variable to hold the sequence consumer as an ovm_sequencer_base
  ovm_sequencer_base seqrb_ref;

  // variable to hold the sequence consumer as an ovm_sequencer if the
  // consumer is that type
  ovm_sequencer seqrnp_ref;

  // constructor
  extern function new (string name="", ovm_component parent = null);

  // do_print for this object
  extern function void do_print (ovm_printer printer);

  // polymorphic creation
  extern function ovm_object create (string name="");

  // get_type_name implementation
  extern virtual function string get_type_name();

  // method to connect this object to an ovm_sequence_prod_if
  //extern function void connect_if(ovm_seq_prod_if_base seqr_if);
  extern function void connect_if(ovm_seq_prod_if seqr_if);

  // method to query who the current grabber of the connected sequencer is
  extern function ovm_sequence current_grabber();

  // method to query if the connected sequencer is grabbed
  extern function bit is_grabbed();

  // method to start a sequence on the connected sequencer
  extern task start_sequence(ovm_sequence this_seq);

  // method to grab the connected sequencer
  extern task grab(ovm_sequence this_seq);

  // method to ungrab the connected sequencer
  extern function void ungrab(ovm_sequence this_seq);

  // method to query if this interface object is connected
  extern function bit is_connected();

  // method to query whether this interface is connected to a virtual sequencer
  // or sequencer
  extern function bit is_virtual_sequencer();

  // method to get the connecte sequencer's type name
  extern function string get_sequencer_type_name();

  // Macro to enable factory creation
  `ovm_component_registry(ovm_seq_cons_if, ovm_seq_cons_if)

endclass


//------------------------------------------------------------------------------
//
// CLASS: ovm_virtual_sequencer
//
//------------------------------------------------------------------------------

class ovm_virtual_sequencer extends ovm_sequencer_base;

  //ovm_seq_cons_if_base seq_cons_if[string];
  ovm_seq_cons_if seq_cons_if[string];

  // Constructor
  extern function new (string name, ovm_component parent);

  // Provide implementations virtual methods such as get_type_name and create,
  // and register fields for outside access and debug. 
  extern virtual function string get_type_name();

  extern virtual function void do_print(ovm_printer printer);

  // Function executed on startup to process user-selected default_sequence
  extern virtual protected task start_default_sequence();

  extern virtual function void add_seq_cons_if(string if_name);

endclass: ovm_virtual_sequencer


`endif // OVM_VIRTUAL_SEQUENCER_SVH

