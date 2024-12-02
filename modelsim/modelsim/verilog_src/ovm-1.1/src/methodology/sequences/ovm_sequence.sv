// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence.sv#1 $
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

`include "methodology/sequences/ovm_sequence.svh"


// new
// ---

function ovm_sequence::new (string name="ovm_sequence",  
  ovm_sequencer_base sequencer=null,
  ovm_sequence parent_seq=null);
  super.new(name, sequencer, parent_seq);
  id = g_id++;
endfunction


// get_id
// ------

function int ovm_sequence::get_id();
  return id;
endfunction


// m_set_b_sequencer
// -----------------

function void ovm_sequence::m_set_b_sequencer();
  if($cast(b_sequencer, m_sequencer))
    begin end
endfunction


// pre_body
// --------

task ovm_sequence::pre_body();
  begin end
endtask


// body
// ----

task ovm_sequence::body();
  begin end
endtask


// post_body
// ---------

task ovm_sequence::post_body();
  begin end
endtask


// pre_do
// ------

task ovm_sequence::pre_do(bit is_item);
  begin end
endtask


// mid_do
// ------

function void ovm_sequence::mid_do(ovm_sequence_item this_item);
  begin end
endfunction


// post_do
// -------

function void ovm_sequence::post_do(ovm_sequence_item this_item);
  begin end
endfunction


// wait_for_relevant
// -----------------

task ovm_sequence::wait_for_relevant();
  event e;
  wait_rel_default = 1;
  if (is_rel_default != wait_rel_default)
    ovm_report_fatal("RELMSM", 
      "is_relevant() was implemented without defining wait_for_relevant()");
  @e;  // this is intended to never return
endtask

// is_relevant
// -----------

function bit ovm_sequence::is_relevant(); 
  is_rel_default = 1;
  return 1;
endfunction


// is_item
// -------

function int ovm_sequence::is_item(); 
  return 0;
endfunction


// get_sequence
// ------------

function ovm_sequence ovm_sequence::get_sequence(int req_kind);
  ovm_sequence m_seq;
  string m_seq_type;
  if (req_kind < 0 || req_kind >= m_sequencer.sequences.size()) begin
    ovm_report_error("SEQRNG", 
      $psprintf("Kind arg '%0d' out of range. Need 0-%0d",
      req_kind,m_sequencer.sequences.size()-1));
  end
  m_seq_type = m_sequencer.sequences[req_kind];
  if (!$cast(m_seq, ovm_factory::create_object(m_seq_type, get_full_name(), 
    m_seq_type))) 
  begin
    ovm_report_fatal("FCTSEQ", 
      $psprintf("Factory can not produce a sequence of type %0s.",
      m_seq_type));
  end
  m_seq.print_sequence_info = 1;
  return m_seq;
endfunction


// get_seq_kind
// --------

function int ovm_sequence::get_seq_kind(string type_name);
  if(m_sequencer)
    return m_sequencer.get_seq_kind(type_name);
  else 
    ovm_report_fatal("NULLSQ", $psprintf("%0s sequencer is null.",
      get_type_name()));
endfunction


// do_sequence_kind
// ----------------

task ovm_sequence::do_sequence_kind(int unsigned req_kind);
  string m_seq_type;
  ovm_sequence m_seq ;
  m_seq_type = m_sequencer.sequences[req_kind];

  if (!$cast(m_seq, ovm_factory::create_object(m_seq_type, get_full_name(),
    m_seq_type))) 
    ovm_report_fatal("FCTSEQ", 
      $psprintf("Factory can not produce a sequence of type %0s.", m_seq_type));
  m_seq.print_sequence_info = 1;
  m_seq.depth = this.depth + 1;
  m_seq.set_parent_seq(this);
  m_seq.set_sequencer(m_sequencer);
  this.pre_do(0); 
  //randomize the sequence
  assert(m_seq.randomize()) else $fatal;
  this.mid_do(m_seq);
  ->m_seq.started;
  m_seq.body();
  ->m_seq.ended;
  this.post_do(m_seq);
endtask


// create_item
// -----------

function ovm_sequence_item ovm_sequence::create_item(
  ovm_sequence_item type_var, ovm_sequencer_base l_sequencer);

  if (!type_var.is_item()) begin
    void'(l_sequencer.get_seq_kind(type_var.get_type_name()));
  end

  if (!$cast( type_var , ovm_factory::create_object( type_var.get_type_name(),
    this.get_full_name(), type_var.get_name())))
  begin
    ovm_report_error("FCTRYF", 
      $psprintf("Factory could not produce an object of type %0s",
      type_var.get_type_name()));
  end

  type_var.print_sequence_info = 1;
  type_var.set_parent_seq(this);
  type_var.set_sequencer(l_sequencer);
  type_var.depth = this.depth + 1;
  type_var.reseed();
  return type_var;

endfunction


// m_sync
// ------

task ovm_sequence::m_sync(ovm_sequence_item item);
  ovm_event ack_process;
  ack_process = new({"ack_", item.get_name()});
  b_sequencer.m_sequencer_sync(item.get_name(), this, ack_process);
  ack_process.wait_trigger();
  #0;
  if (m_sequencer.recording_detail != OVM_NONE) begin
    //record sequence item into aggregate items stream
    void'(m_sequencer.begin_tr(item, "aggregate items"));
  end
endtask


// start_item
// ----------

task ovm_sequence::start_item(ovm_sequence_item type_var);

  if (type_var.is_item()) begin 
    //register with sequencer and begin processing of ovm_sequence_item objects
    this.m_sync(type_var);
    this.pre_do(1);
  end 
  //is sequence
  else begin 
    if (m_sequencer.recording_detail != OVM_NONE)
      //record sequences into m_get_root_sequence_name() stream
      type_var.tr_handle = m_sequencer.begin_child_tr(
        type_var,                          //ovm_transaction tr
        type_var.m_parent_seq.tr_handle,   //parent tr_handle
        m_get_root_sequence_name()         //string stream_name
        );
    this.pre_do(0);
  end

endtask


// m_post_sync
// -----------

task ovm_sequence::m_post_sync(ovm_sequence_item item);
  b_sequencer.m_last_push_front(item);
  b_sequencer.m_item_ready_trigger(item);
  b_sequencer.item_done_wait_trigger_data(item); /* wait until driver
                                                  completes the item and 
                                                  signals item_done_trigger()
                                                  */
endtask


// finish_item
// -----------

task ovm_sequence::finish_item( ovm_sequence_item type_var );

  ovm_sequence m_seq;

  //complete processing of ovm_sequence
  //for ovm_sequence_item, call mid_do(), send to m_post_sync(), and post_do()
  this.mid_do(type_var);
  if(type_var.is_item()) begin
    this.m_post_sync( type_var );
  end
  else begin //is sequence 
    //for ovm_sequence, call body()
    $cast(m_seq, type_var);
    //allow users to detect started when a subsequence body()
    //calls ovm_do immediately
    #0 -> m_seq.started;
    m_seq.body();
    -> m_seq.ended;
  end
  this.post_do(type_var);
  m_sequencer.end_tr(type_var);

endtask


// grab()
// ------
                                                                                
task ovm_sequence::grab(ovm_sequencer sequencer = null);
  if (sequencer == null)
    b_sequencer.grab(this);
  else
    sequencer.grab(this);
endtask
                                                                                
                                                                                
// ungrab()
// ------
                                                                                
function void ovm_sequence::ungrab(ovm_sequencer sequencer = null);
  if (sequencer == null)
    b_sequencer.ungrab(this);
  else
    sequencer.ungrab(this);
endfunction


// is_blocked()
// ------
                                                                                
function bit ovm_sequence::is_blocked();
   return m_block_status;
endfunction


// m_set_is_blocked()
// ------
                                                                                
function void ovm_sequence::m_set_is_blocked(bit block_status);
   m_block_status = block_status;
endfunction


// stop()
// ------
                                                                                
function void ovm_sequence::stop();
   disable body;
endfunction


// pre_apply
// ---------

task ovm_sequence::pre_apply();
  begin end
endtask


// mid_apply
// ---------

task ovm_sequence::mid_apply();
  begin end
endtask


// post_apply
// ---------

task ovm_sequence::post_apply();
  begin end
endtask


// apply
// -----

task ovm_sequence::apply(ovm_sequence_item req, output ovm_sequence_item
  rsp);
  b_sequencer.apply(req,this);
  $cast(rsp, b_sequencer.item_done.get_trigger_data());
endtask


// start
// -----

task ovm_sequence::start(ovm_sequencer_base sequencer, ovm_sequence
  parent_seq = null);
  set_sequencer(sequencer);
  set_parent_seq(parent_seq);
  pre_body();
  body();
  post_body();
endtask
