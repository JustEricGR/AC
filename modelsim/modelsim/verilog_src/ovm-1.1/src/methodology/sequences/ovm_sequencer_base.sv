// $Id: ovm_sequencer_base.sv,v 1.11 2007/12/21 12:49:44 jlrose Exp $
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


`include "methodology/sequences/ovm_sequencer_base.svh"
`include "methodology/sequences/ovm_sequence.svh"


// new
// ---

function ovm_seq_prod_if::new (string name="", ovm_component parent = null);
  super.new(name, parent);
  $cast(parent_as_seqr, parent);
endfunction


// do_print
// --------

function void ovm_seq_prod_if::do_print (ovm_printer printer);
  super.do_print(printer);
  if (producer != null)
    printer.print_string("sequence producer", producer.get_full_name());
  else
    printer.print_string("sequence producer", "NOT_CONNECTED");
endfunction


// create
// ------

function ovm_object ovm_seq_prod_if::create (string name="");
  ovm_seq_prod_if i; i=new(name);
  return i;
endfunction


// get_type_name
// -------------

function string ovm_seq_prod_if::get_type_name();
  return "ovm_seq_prod_if";
endfunction 


// connect_if
// -------------

function void ovm_seq_prod_if::connect_if(ovm_seq_cons_if vseq_if);
  vseq_if.seqrb_ref = parent_as_seqr;
  producer = vseq_if.get_parent();
endfunction



// new
// ---

function ovm_sequencer_base::new (string name, ovm_component parent);
  super.new(name, parent);
  $cast(seq_prod_if, create_component("ovm_seq_prod_if", "seq_prod_if"));
  void'(get_config_string("default_sequence", default_sequence));
  void'(get_config_int("count", count));
  void'(get_config_int("max_random_count", max_random_count));
endfunction


//Implement data functions
function void ovm_sequencer_base::do_copy (ovm_object rhs);
  ovm_sequencer_base seqr;
  super.do_copy(rhs);
  if(rhs == null) return;
  if(!$cast(seqr, rhs)) return;
  default_sequence = seqr.default_sequence;
  for(int i=0; i<seqr.sequences.size(); ++i)
    sequences[i] = seqr.sequences[i];
  count = seqr.count;
  max_random_count = seqr.max_random_count;
endfunction

function bit ovm_sequencer_base::do_compare (ovm_object rhs,
  ovm_comparer comparer);
  ovm_sequencer_base seqr;
  do_compare = 1;
  do_compare = super.do_compare(rhs, comparer);
  if(rhs == null) return 0;
  if(!$cast(seqr, rhs)) return 0;
  do_compare &= comparer.compare_string("default_sequence", default_sequence, 
    seqr.default_sequence);
  for(int i=0; i<seqr.sequences.size(); ++i)
    do_compare &= comparer.compare_string($psprintf("sequences[%0d]", i),
      sequences[i], seqr.sequences[i]);
  do_compare &= comparer.compare_field_int("count", count, seqr.count, $bits(count));
  do_compare &= comparer.compare_field_int("max_random_count", max_random_count, 
    seqr.max_random_count, $bits(max_random_count), OVM_DEC);
endfunction

function void ovm_sequencer_base::do_print (ovm_printer printer);
  super.do_print(printer);
  if(sequences.size() != 0) begin
    printer.print_string("default_sequence", default_sequence);
    printer.print_field("count", count, $bits(count), OVM_DEC);
    printer.print_field("max_random_count", max_random_count, 
      $bits(max_random_count), OVM_DEC);
    printer.print_array_header("sequences", sequences.size());
    for(int i=0; i<sequences.size(); ++i)
      printer.print_string($psprintf("[%0d]", i), sequences[i], "[");
    printer.print_array_footer();
  end
endfunction

function void ovm_sequencer_base::do_record (ovm_recorder recorder);
  super.do_record(recorder);
  recorder.record_string("default_sequence", default_sequence);
  for(int i=0; i<sequences.size(); ++i)
    recorder.record_string($psprintf("sequences[%0d]", i), sequences[i]);
  recorder.record_field("count", count, $bits(count), OVM_DEC);
  recorder.record_field("max_random_count", max_random_count, 
    $bits(max_random_count), OVM_DEC);
endfunction
  

// add_sequence
// ------------

function void ovm_sequencer_base::add_sequence(string type_name);
  //assign typename key to an int based on size
  //used with get_seq_kind to return an int key to match a type name
  sequence_ids[type_name] = sequences.size();
  //used w/ get_sequence to return a ovm_sequence factory object that 
  //matches an int id
  sequences.push_back(type_name);
endfunction


// set_sequences_queue
// -------------------

function void ovm_sequencer_base::set_sequences_queue(
                          ref string sequencer_sequence_lib[$]);
  for(int j=0; j < sequencer_sequence_lib.size(); j++) begin
    sequence_ids[sequencer_sequence_lib[j]] = sequences.size();
    this.sequences.push_back(sequencer_sequence_lib[j]);
  end
begin end
endfunction


// run phase
// ---

task ovm_sequencer_base::run();
  start_default_sequence(); 
endtask


// start_default_sequence
// ----------------------

//Executed by run()
task ovm_sequencer_base::start_default_sequence();

  ovm_sequence m_seq ;

  if(sequences.size() != 0) begin

    //get id of default sequence, even if type overrided by user
    //this provides a check that the default_sequence is in this sequencer's
    //library
    seq_kind = get_seq_kind(default_sequence);
  
    //create the sequence object
    if (!$cast(m_seq, ovm_factory::create_object(default_sequence, 
      get_full_name(), default_sequence))) 
    begin
      ovm_report_fatal("FCTSEQ", 
        $psprintf("Default sequence set to invalid value : %0s.", 
        default_sequence));
    end

    m_seq.print_sequence_info = 1;
    m_seq.set_sequencer(this);
    assert(m_seq.randomize());

    if(count != 0)
      start_sequence(m_seq);

  end

endtask


// start_sequence
// --------------

task ovm_sequencer_base::start_sequence(ovm_sequence this_seq,
  ovm_sequencer_base this_seqr=null);
  //set parent_seq to null to start new sequence tree
  this_seq.set_parent_seq(null);
  if (this_seqr == null)
    this_seq.set_sequencer(this);
  else
    this_seq.set_sequencer(this_seqr);
  this_seq.depth = 1;
  fork
    begin
      if (this.recording_detail != OVM_NONE)
        this_seq.tr_handle = begin_tr(this_seq, this_seq.get_name());
      ->this_seq.started;
      this_seq.pre_body();
      this_seq.body();
      this_seq.post_body();
      ->this_seq.ended;
      if (this.recording_detail != OVM_NONE)
        end_tr(this_seq);
    end
  join_none
endtask


// get_seq_kind
// ------------

// Return a unique sequence id given the name of a sequence.
// This id is expected to be used in inline constraints.
function int ovm_sequencer_base::get_seq_kind(string type_name);

  if (sequence_ids.exists(type_name))
    return sequence_ids[type_name];

  ovm_report_fatal("SEQNF", 
    $psprintf("Sequence type_name '%0s' not registered with this sequencer.",
    type_name));

endfunction


// get_sequence
// ------------

function ovm_sequence ovm_sequencer_base::get_sequence(int req_kind);

  ovm_sequence m_seq ;
  string m_seq_type;

  if (req_kind < 0 || req_kind >= sequences.size()) begin
    ovm_report_error("SEQRNG", 
      $psprintf("Kind arg '%0d' out of range. Need 0-%0d", 
      req_kind, sequences.size()-1));
  end

  m_seq_type = sequences[req_kind];
  if (!$cast(m_seq, ovm_factory::create_object(m_seq_type,
                                          get_full_name(),
                                          m_seq_type))) 
  begin
      ovm_report_fatal("FCTSEQ", 
        $psprintf("Factory can not produce a sequence of type %0s.",
        m_seq_type));
  end

  m_seq.print_sequence_info = 1;
  m_seq.set_sequencer (this);
  return m_seq;
  
endfunction


