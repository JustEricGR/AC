// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence_builtin.sv#1 $
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

`include "methodology/sequences/ovm_sequence_builtin.svh"


//------------------------------------------------------------------------------
//
// CLASS: ovm_random_sequence
//
// implementation
//------------------------------------------------------------------------------

// new
// ---

function ovm_random_sequence::new(string name="ovm_random_sequence", 
  ovm_sequencer_base sequencer=null,
  ovm_sequence parent_seq=null);
  super.new(name, sequencer, parent_seq);
endfunction


// body
// ----

task ovm_random_sequence::body();
  if (m_sequencer.count == -1) begin
    assert(randomize(l_count) with { l_count > 0 && l_count <
      m_sequencer.max_random_count; });
    m_sequencer.count = l_count;
  end
  else
    l_count = m_sequencer.count;
  max_kind = m_sequencer.sequences.size();
  l_exhaustive_seq_kind = m_sequencer.get_seq_kind("ovm_exhaustive_sequence");
  repeat (l_count) begin
    assert(randomize(l_kind) with { l_kind > l_exhaustive_seq_kind && 
      l_kind < max_kind; });
    do_sequence_kind(l_kind);
  end
  m_sequencer.m_random_count++;
  
endtask 


//Implement data functions
function void ovm_random_sequence::do_copy (ovm_object rhs);
  ovm_random_sequence seq;
  if(rhs==null) return;
  if(!$cast(seq, rhs)) return;
  l_count = seq.l_count;
endfunction

function bit ovm_random_sequence::do_compare (ovm_object rhs, ovm_comparer comparer);
  ovm_random_sequence seq;
  do_compare = 1;
  if(rhs==null) return 0;
  if(!$cast(seq, rhs)) return 0;
  do_compare &= comparer.compare_field_int("l_count", l_count, seq.l_count, 
    $bits(l_count));
endfunction

function void ovm_random_sequence::do_print (ovm_printer printer);
  printer.print_field("l_count", l_count, $bits(l_count));
endfunction

function void ovm_random_sequence::do_record (ovm_recorder recorder);
  recorder.record_field("l_count", l_count, $bits(l_count));
endfunction


//------------------------------------------------------------------------------
//
// CLASS: ovm_exhaustive_sequence
//
// implementation
//------------------------------------------------------------------------------

// new
// ---

function ovm_exhaustive_sequence::new(string name="ovm_exhaustive_sequence", 
  ovm_sequencer_base sequencer=null,
  ovm_sequence parent_seq=null);
  super.new(name, sequencer, parent_seq);
endfunction


// body
// ----

task ovm_exhaustive_sequence::body();
  l_count = m_sequencer.sequences.size() - 2;
  max_kind = m_sequencer.sequences.size();
  l_exhaustive_seq_kind = m_sequencer.get_seq_kind("ovm_exhaustive_sequence");
  repeat (l_count) begin
    assert(randomize(l_kind) with { l_kind > l_exhaustive_seq_kind && 
      l_kind < max_kind; }); // l_kind is randc
    do_sequence_kind(l_kind);
  end
  m_sequencer.m_exhaustive_count++;
endtask 


//Implement data functions
function void ovm_exhaustive_sequence::do_copy (ovm_object rhs);
  ovm_exhaustive_sequence seq;
  if(rhs==null) return;
  if(!$cast(seq, rhs)) return;
  l_count = seq.l_count;
endfunction

function bit ovm_exhaustive_sequence::do_compare (ovm_object rhs, ovm_comparer comparer);
  ovm_exhaustive_sequence seq;
  do_compare = 1;
  if(rhs==null) return 0;
  if(!$cast(seq, rhs)) return 0;
  do_compare &= comparer.compare_field_int("l_count", l_count, seq.l_count, 
    $bits(l_count));
endfunction

function void ovm_exhaustive_sequence::do_print (ovm_printer printer);
  printer.print_field("l_count", l_count, $bits(l_count));
endfunction

function void ovm_exhaustive_sequence::do_record (ovm_recorder recorder);
  recorder.record_field("l_count", l_count, $bits(l_count));
endfunction


//------------------------------------------------------------------------------
//
// CLASS: ovm_simple_sequence
//
// implementation
//------------------------------------------------------------------------------

// new
// ---

function ovm_simple_sequence::new (string name="ovm_simple_sequence", 
  ovm_sequencer_base sequencer=null,
  ovm_sequence parent_seq=null);
  super.new(name, sequencer, parent_seq);
endfunction

// body
// ----

task ovm_simple_sequence::body();
  `ovm_do(item)
  m_sequencer.m_simple_count++;
endtask

function void ovm_simple_sequence::do_print (ovm_printer printer);
  super.do_print(printer);
  printer.print_object("item", item);
endfunction

