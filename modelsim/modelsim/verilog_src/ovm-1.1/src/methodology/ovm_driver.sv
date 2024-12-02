// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/ovm_driver.sv#1 $
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

`include "methodology/ovm_driver.svh"


// new
// ---

function ovm_seq_item_prod_if::new (string name="", 
  ovm_component parent = null);
  super.new(name, parent);
endfunction


// do_print
// --------

function void ovm_seq_item_prod_if::do_print (ovm_printer printer);
  super.do_print(printer);
  if (seqr_ref != null)
    printer.print_string("item producer", seqr_ref.get_name());
  else
    printer.print_string("item producer", "NOT_CONNECTED");
endfunction


// create
// ------

function ovm_object ovm_seq_item_prod_if::create (string name="");
  ovm_seq_item_prod_if i; i=new(name);
  return i;
endfunction


// get_type_name
// -------------

function string ovm_seq_item_prod_if::get_type_name();
  return "ovm_seq_item_prod_if";
endfunction 


// connect_if
// ----------

function void ovm_seq_item_prod_if::connect_if(
  ovm_seq_item_cons_if seqr_if);
  $cast(seqr_ref, seqr_if.parent_as_seqr);
  seqr_if.consumer = m_parent;
endfunction


// item_done
// ---------

function void ovm_seq_item_prod_if::item_done( ovm_sequence_item item=null);
  seqr_ref.item_done_trigger(item);
endfunction


// has_do_available
// ----------------

function bit ovm_seq_item_prod_if::has_do_available();
  has_do_available = seqr_ref.has_do_available();
endfunction


// wait_for_sequences
// ------------------

task ovm_seq_item_prod_if::wait_for_sequences();
  seqr_ref.wait_for_sequences();
endtask


// get_next_item
// -------------

task ovm_seq_item_prod_if::get_next_item(output ovm_sequence_item item);
  ovm_sequence_item base_item;
  seqr_ref.get_next_item(item);
endtask


// try_next_item
// -------------

task ovm_seq_item_prod_if::try_next_item(output ovm_sequence_item item);
  ovm_sequence_item base_item;
  seqr_ref.try_next_item(item);
endtask



// new
// ---

function ovm_driver::new (string name, ovm_component parent);
  super.new(name, parent);
  $cast(seq_item_prod_if, create_component("ovm_seq_item_prod_if", 
    "seq_item_prod_if"));
endfunction


