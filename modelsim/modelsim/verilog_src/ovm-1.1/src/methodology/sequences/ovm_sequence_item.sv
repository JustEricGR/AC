// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence_item.sv#1 $
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

`include "methodology/sequences/ovm_sequence_item.svh"

//------------------------------------------------------------------------------
//
// CLASS: ovm_sequence_item
//
// implementation
//------------------------------------------------------------------------------

// new
// ---

function ovm_sequence_item::new (input string name="ovm_sequence_item", 
  ovm_sequencer_base sequencer=null, 
  ovm_sequence parent_seq = null);
  super.new(name);
  if (sequencer != null) begin
    this.set_sequencer(sequencer); // set value of this.m_sequencer,b_sequencer
                                   // and p_sequencer
  end
  if (parent_seq != null) begin
    m_parent_seq = parent_seq;
  end
endfunction


// do_copy
// -------

//Implement data functions
function void ovm_sequence_item::do_copy (ovm_object rhs);
  ovm_sequence_item si;
  super.do_copy(rhs);
  if(rhs==null) return;
  if(!$cast(si, rhs)) return;

  print_sequence_info = si.print_sequence_info;
  depth = si.depth;
  m_parent_seq = si.m_parent_seq;
  m_sequencer = si.m_sequencer;
endfunction


// do_compare
// -------

//Implement data functions
function bit ovm_sequence_item::do_compare (ovm_object rhs, ovm_comparer comparer);
  ovm_sequence_item si;
  do_compare = super.do_compare(rhs, comparer);
  if(rhs==null) return 0;
  if(!$cast(si, rhs)) return 0;
endfunction


// do_print
// --------

function void ovm_sequence_item::do_print (ovm_printer printer);
  string temp_str0;
  string temp_str1;
  super.do_print(printer);
  if(print_sequence_info) begin
    printer.print_field("depth", depth, $bits(depth), OVM_DEC, ".", "int");
    if(m_parent_seq != null) begin
      temp_str0 = m_parent_seq.get_name();
      temp_str1 = m_parent_seq.get_full_name();
    end
    printer.print_string("parent sequence (name)", temp_str0);
    printer.print_string("parent sequence (full name)", temp_str1);
    `ifdef INCA
      printer.print_object_header("parent sequence (ref)", m_parent_seq);
    `endif
    printer.print_string("root sequence (name)", m_get_root_sequence_name());
    `ifdef INCA
      printer.print_object_header("root sequence (ref)", m_get_root_sequence());
    `endif
    temp_str0 = "";
    temp_str1 = "";
    if(m_sequencer != null) begin
      temp_str0 = m_sequencer.get_name();
      temp_str1 = m_sequencer.get_full_name();
    end
    printer.print_string("sequencer (name)", temp_str0);
    printer.print_string("sequencer (full name)", temp_str1);
    `ifdef INCA
      printer.print_object_header("sequencer (ref)", m_sequencer);
    `endif
  end
endfunction


// do_record
// ---------

function void ovm_sequence_item::do_record (ovm_recorder recorder);
  super.do_record(recorder);
  recorder.record_field("depth", depth, $bits(depth), OVM_DEC);
endfunction


// set_sequencer
// ------------

function void ovm_sequence_item::set_sequencer(ovm_sequencer_base sequencer);
  /*
   m_sequencer is ovm_sequencer_base
   b_sequencer is ovm_sequencer_nonparam
   p_sequencer is user-derived sequencer type
   */
  m_sequencer = sequencer;
  this.m_set_b_sequencer(); // virtual method (see ovm_sequence.svh)
  this.m_set_p_sequencer(); // virtual method (see ovm_sequence.svh)
endfunction


// get_sequencer
// ------------

function ovm_sequencer_base ovm_sequence_item::get_sequencer();
  return this.m_sequencer ;
endfunction


// set_parent_seq
// --------------

function void ovm_sequence_item::set_parent_seq(ovm_sequence parent);
  if (parent != null)
    this.m_parent_seq = parent;
endfunction


// get_parent_seq
// --------------

function ovm_sequence ovm_sequence_item::get_parent_seq();
  return this.m_parent_seq ;
endfunction


// get_full_name
// -------------

function string ovm_sequence_item::get_full_name();
  if(m_parent_seq!=null) 
    get_full_name = {m_parent_seq.get_full_name(), "."};
  else if(m_sequencer!=null)
    get_full_name = {m_sequencer.get_full_name(), "."};
  if(get_name() != "") 
    get_full_name = {get_full_name, get_name()};
  else begin
    ovm_sequence_item tmp;
    tmp = this;
    $swrite(get_full_name, "%sitem_", get_full_name, tmp);
  end
endfunction


// get_sequence_path
// -----------------

function string ovm_sequence_item::get_sequence_path();
  ovm_sequence_item this_item;
  string seq_path;
  this_item = this;
  seq_path = this.get_name();
  while(1) begin
    if(this_item.get_parent_seq()!=null) begin
      this_item = this_item.get_parent_seq();
      seq_path = {this_item.get_name(), ".", seq_path};
    end
    else
      return seq_path;
  end
endfunction


// m_set_b_sequencer
// --- 

function void ovm_sequence_item::m_set_b_sequencer();
  return;
endfunction


// m_set_p_sequencer
// --- 

function void ovm_sequence_item::m_set_p_sequencer();
  return;
endfunction


// m_get_root_sequence_name
// --- 

function string ovm_sequence_item::m_get_root_sequence_name();
  ovm_sequence_item root_seq;
  root_seq = this;
  while(1) begin
    if(root_seq.get_parent_seq()!=null) begin
      root_seq = root_seq.get_parent_seq();
    end
    else
      return root_seq.get_name();
  end
endfunction


// m_get_root_sequence
// --- 

function ovm_sequence ovm_sequence_item::m_get_root_sequence();
  ovm_sequence_item root_seq_base;
  ovm_sequence root_seq;
  root_seq_base = this;
  while(1) begin
    if(root_seq_base.get_parent_seq()!=null) begin
      root_seq_base = root_seq_base.get_parent_seq();
      $cast(root_seq, root_seq_base);
    end
    else
      return root_seq;
  end
endfunction


// m_get_report_object
// -------------------

function ovm_report_object ovm_sequence_item::m_get_report_object();
  return get_sequencer();
endfunction


// is_item
// -------

function int ovm_sequence_item::is_item();
  return 1; 
endfunction


// get_depth
// ---------

function int ovm_sequence_item::get_depth();
  return depth;
endfunction


// create
// ------

function ovm_object ovm_sequence_item::create(string name="");
  ovm_sequence_item i; i=new(name);
  return i;
endfunction


// get_type_name
// -------------

function string ovm_sequence_item::get_type_name();
  return "ovm_sequence_item";
endfunction 

