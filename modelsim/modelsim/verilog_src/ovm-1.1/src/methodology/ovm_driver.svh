// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/ovm_driver.svh#1 $
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

`ifndef OVM_DRIVER_SVH
`define OVM_DRIVER_SVH


typedef class ovm_driver;
typedef class ovm_seq_item_cons_if;
typedef class ovm_sequence_item;


//------------------------------------------------------------------------------
//
// CLASS: ovm_seq_item_prod_if
//
//------------------------------------------------------------------------------

class ovm_seq_item_prod_if extends ovm_component;

  // variable to hold the sequence item producer reference
  ovm_sequencer seqr_ref;

  // constructor
  extern function new (string name="", ovm_component parent = null);

  // print method for this object
  extern function void do_print (ovm_printer printer);

  // polymorphic creation
  extern function ovm_object create (string name="");

  // get_type_name implementation
  extern virtual function string get_type_name();

  // connection method for the interfaces
  extern function void connect_if(ovm_seq_item_cons_if seqr_if);

  // method to signal that the driver is done with the item
  extern function void item_done(ovm_sequence_item item=null);

  // method to query if the producer has an item available
  extern function bit has_do_available();

  // method to add delta delay for sequence item processing
  extern task wait_for_sequences();

  // method to get a base item from the producer (blocking)
  extern task get_next_item(output ovm_sequence_item item);

  // method to get a base item from the producer (blocking)
  extern task try_next_item(output ovm_sequence_item item);

  // Macro to enable factory creation
  `ovm_component_registry(ovm_seq_item_prod_if, ovm_seq_item_prod_if)

endclass


//------------------------------------------------------------------------------
//
// CLASS: ovm_driver
//
//------------------------------------------------------------------------------

virtual class ovm_driver extends ovm_threaded_component;

  // sequence item producer interface
  ovm_seq_item_prod_if seq_item_prod_if;

  // Constructor
  extern function new (string name, ovm_component parent);

endclass


`endif // OVM_DRIVER_SVH

