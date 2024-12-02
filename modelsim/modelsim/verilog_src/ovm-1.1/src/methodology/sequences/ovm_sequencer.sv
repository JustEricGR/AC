// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequencer.sv#1 $
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


`include "methodology/sequences/ovm_sequencer.svh"
`include "methodology/sequences/ovm_sequence.svh"


// new
// ---

function ovm_seq_item_cons_if::new (string name="", 
  ovm_component parent = null);
  super.new(name, parent);
  $cast(parent_as_seqr, parent);
endfunction


// do_print
// ---

function void ovm_seq_item_cons_if::do_print (ovm_printer printer);
  super.do_print(printer);
  if (consumer != null)
    printer.print_string("item consumer", consumer.get_name());
  else
    printer.print_string("item consumer", "NOT_CONNECTED");
endfunction


// create
// ---

function ovm_object ovm_seq_item_cons_if::create (string name="");
  ovm_seq_item_cons_if i; i=new(name);
  return i;
endfunction


// get_type_name
// ---

function string ovm_seq_item_cons_if::get_type_name();
  return "ovm_seq_item_cons_if";
endfunction 


// connect_if
// ---

function void ovm_seq_item_cons_if::connect_if(
  ovm_seq_item_prod_if item_prod_if);
  item_prod_if.seqr_ref = parent_as_seqr;
  consumer = item_prod_if.get_parent();
endfunction



// new
// ---

function ovm_sequencer::new (string name, ovm_component parent);
  super.new(name, parent);
  $cast(seq_item_cons_if, create_component("ovm_seq_item_cons_if",
    "seq_item_cons_if"));
  item_done      = new("item_done");
  item_ready     = new("item_ready");
  void'(get_config_int("pull_mode", pull_mode));
  void'(get_config_int("max_random_depth", max_random_depth));
  void'(get_config_int("num_last_items", num_last_items));
endfunction


// get_type_name
// ---

function string ovm_sequencer::get_type_name();
  return "ovm_sequencer";
endfunction 


// Implement data functions
// ------------------------

function void ovm_sequencer::do_copy (ovm_object rhs);
  ovm_sequencer seqr;
  super.do_copy(rhs);
  if(rhs == null) return;
  if(!$cast(seqr, rhs)) return;
  pull_mode = seqr.pull_mode;
  item_done = seqr.item_done;
  item_ready = seqr.item_ready;
  max_random_depth = seqr.max_random_depth;
  num_last_items = seqr.num_last_items;
endfunction

function bit ovm_sequencer::do_compare (ovm_object rhs, 
  ovm_comparer comparer);
  ovm_sequencer seqr;
  do_compare = 1;
  if(rhs == null) return 0;
  if(!$cast(seqr, rhs)) return 0;
  do_compare &= comparer.compare_field_int("pull_mode", pull_mode, seqr.pull_mode, 
    $bits(pull_mode));
  do_compare &= comparer.compare_object("item_done", item_done, seqr.item_done);
  do_compare &= comparer.compare_object("item_ready", item_ready, seqr.item_ready);
  do_compare &= comparer.compare_field_int("max_random_depth", max_random_depth, 
    seqr.max_random_depth, $bits(max_random_depth), OVM_DEC);
  do_compare &= comparer.compare_field_int("num_last_items", num_last_items, 
    seqr.num_last_items, $bits(num_last_items), OVM_DEC);
endfunction

function void ovm_sequencer::do_print (ovm_printer printer);
  super.do_print(printer);
  if(sequences.size() != 0)
    printer.print_field("max_random_depth", max_random_depth, 
      $bits(max_random_depth), OVM_DEC);
  printer.print_field("pull_mode", pull_mode, $bits(pull_mode));
  printer.print_field("num_last_items", num_last_items, 
    $bits(num_last_items), OVM_DEC);
endfunction

function void ovm_sequencer::do_record (ovm_recorder recorder);
  super.do_record(recorder);
  recorder.record_field("pull_mode", pull_mode, $bits(pull_mode));
  recorder.record_field("max_random_depth", max_random_depth, 
    $bits(max_random_depth), OVM_DEC);
  recorder.record_field("num_last_items", num_last_items, 
    $bits(num_last_items), OVM_DEC);
endfunction
  

// process_queue
// -------------

function bit ovm_sequencer::process_queue(output int index);

  if(m_action_q.size() == 0) begin
    return 0;
  end else begin
    for(int i = 0; i < this.m_action_q.size() ; i ++) begin : process_queue_for
      if(m_grabbers.size() == 0 || 
        m_is_current_grabber(this.m_action_q[i]) == 1) begin
        if(this.m_action_q[i].is_relevant()) begin : relevant_block
          //trigger process-specific urm_sequence::m_sync ovm_event
          m_action_e[i].trigger();
          index = i;
          return 1; //process one action at a time
        end : relevant_block
      end
      process_queue = 0;
    end : process_queue_for
  end

endfunction


// m_sync
// ------

task ovm_sequencer::m_sequencer_sync(input string item_name, 
  ovm_sequence parent_seq, ovm_event ack_process);

  this.m_action_q.push_back(parent_seq);
  this.m_action_e.push_back(ack_process);

  ->m_eval_queue_e;

endtask


// execute_item
// ------------

task ovm_sequencer::execute_item(input ovm_sequence_item item,
  ovm_sequence seq = null);
  ovm_sequence temp_seq;
  if (seq == null)
    temp_seq = new();
  else
    temp_seq = seq;
  if(item.is_item()) begin
    ovm_event ack_process;
    ack_process = new({"ack_", item.get_name()});
    m_sequencer_sync(item.get_name(), temp_seq, ack_process);
    ack_process.wait_trigger();
    temp_seq.pre_do(1);
    #0;
    temp_seq.mid_do(item);
    m_last_push_front(item);
    m_item_ready_trigger(item);
    item_done_wait_trigger_data(item);
    temp_seq.post_do(item);
  end
  else begin
    ovm_sequence m_seq;
    $cast(m_seq, item);
    if (this.recording_detail != OVM_NONE)
      m_seq.tr_handle = begin_tr(m_seq, m_seq.get_name());
    //temp_seq.pre_do(0);
    //temp_seq.mid_do(item);
    m_seq.set_sequencer(this);
    //allow users to detect started when a subsequence body()
    //calls ovm_do immediately
    #0 -> m_seq.started;
    m_seq.body();
    -> m_seq.ended;
    //temp_seq.post_do(item);
    this.end_tr(item);
  end
endtask


// apply
// -----

task ovm_sequencer::apply(input ovm_sequence_item item,
  ovm_sequence seq = null);
  ovm_sequence temp_seq;
  if (seq == null)
    temp_seq = new();
  else
    temp_seq = seq;
  if(item.is_item()) begin
    ovm_event ack_process;
    ack_process = new({"ack_", item.get_name()});
    m_sequencer_sync(item.get_name(), temp_seq, ack_process);
    ack_process.wait_trigger();
    temp_seq.pre_apply();
    #0;
    temp_seq.mid_apply();
    m_last_push_front(item);
    m_item_ready_trigger(item);
    item_done_wait_trigger_data(item);
    temp_seq.post_apply();
  end
  else begin
    ovm_sequence m_seq;
    $cast(m_seq, item);
    if (this.recording_detail != OVM_NONE)
      m_seq.tr_handle = begin_tr(m_seq, m_seq.get_name());
    temp_seq.pre_apply();
    temp_seq.mid_apply();
    m_seq.set_sequencer(this);
    //allow users to detect started when a subsequence body()
    //calls ovm_do immediately
    #0 -> m_seq.started;
    m_seq.body();
    -> m_seq.ended;
    temp_seq.post_apply();
    this.end_tr(item);
  end
endtask


// wait_for_activate
// -----------------

task ovm_sequencer::m_wait_for_activate();
  if(m_action_q.size() == 0)
    @m_eval_queue_e;
  else begin  // action queue is not empty (implication says process_queue
              // already returned a 0, which means no relevant, grab qualifier
   fork // isolate inner fork block so can later disable it
    begin
     fork
      @m_eval_queue_e;  //this is a block waiting for new action entry or ungrab
      begin  // this block is detect changes for a sequence's relevance
        event trigger;
        for(int i=0; i<m_action_q.size(); ++i)
          if(m_grabbers.size() == 0 || 
            m_is_current_grabber(this.m_action_q[i]) == 1)
            if(!m_action_q[i].is_relevant()) begin
              // IUS issue work-around here...
              ovm_sequence s;
              s = m_action_q[i];
              fork 
              begin
                s.wait_for_relevant();
                ->trigger;
              end
              join_none
            end
        @trigger;
      end
     join_any
     disable fork;
    end
   join
  end
endtask


// get_next_item
// -------------
  
task ovm_sequencer::get_next_item(output ovm_sequence_item item);
  int index;
  while (!process_queue(index)) begin // select action
    m_wait_for_activate();
  end
  item_ready.wait_trigger(); // wait for pre_do, rand, mid_do to complete
  m_action_q.delete(index);
  m_action_e.delete(index);
  $cast(item, item_ready.get_trigger_data()); /* returns item passed into 
                                               m_item_ready_trigger in 
                                               ovm_sequence::m_post_sync */
endtask


// wait_for_sequences()
// -------------
  
task ovm_sequencer::wait_for_sequences();
    for (int i=0; i < 100 ; i++)
      #0;
endtask


// try_next_item()
// -------------
  
task ovm_sequencer::try_next_item(output ovm_sequence_item item);
  fork // isolate inner fork block so can later disable it
   begin
    fork : try_next_fork
     get_next_item(item);
     //items will be lost if wait_for_sequences does not delay sufficiently
     wait_for_sequences();
    join_any
    disable fork;
   end
  join
endtask
  

// item_done_trigger
// -----------------

function void ovm_sequencer::item_done_trigger(ovm_sequence_item 
  item=null);
  item_done.trigger(item);
endfunction
  

// has_do_available
// -----------------

function bit ovm_sequencer::has_do_available();
  for(int i = 0; i < this.m_action_q.size() ; i ++)
    if(this.m_action_q[i].is_relevant())
      return 1;
  return 0;
endfunction


// m_item_ready_trigger
// --------------------

function void ovm_sequencer::m_item_ready_trigger(
                    input ovm_object m_item=null);
  item_ready.trigger(m_item);
endfunction


// item_done_wait_trigger_data
// ------------------------

task ovm_sequencer::item_done_wait_trigger_data(output 
  ovm_sequence_item item);
  ovm_object m_object;
  item_done.wait_trigger_data(m_object);
  if (m_object != null) begin
    if(!$cast(item, m_object)) 
      ovm_report_fatal("ILLCST", $psprintf("cast failure on %0s %0s", 
        m_object.get_name(), m_object.get_type_name()));
  end
endtask


// grab()
// ------

task ovm_sequencer::grab(ovm_sequence seq);
  // already holds the grab
  if(m_grabbers[0] == seq)
    ovm_report_warning("DUPGRB", 
      "Duplicate grab for this sequence.  grab() ignored.");
    // grabbers queue is empty.  requestor gets.
  else if(!m_grabbers.size()) begin
      m_grabbers[0] = seq;
    end
  else begin
    // is child of grabber
    if(m_is_current_grabber(seq)) begin
      m_grabbers.push_front(seq);
    end
    else begin
      // block grab requestor
      m_block_grabber(seq);
      m_grabbers.push_front(seq);
    end
  end
endtask: grab


// m_block_grabber()
// -----------------

task ovm_sequencer::m_block_grabber(ovm_sequence seq);
  seq.m_set_is_blocked(1);
  while(1)  begin
    @ m_ungrab_e;
    if(m_is_current_grabber(seq) || m_grabbers.size() == 0) begin
      seq.m_set_is_blocked(0);
      return;
    end
  end
endtask: m_block_grabber


// m_is_current_grabber()
// ------

function bit ovm_sequencer::m_is_current_grabber(ovm_sequence seq);
  if(seq == m_grabbers[0])
    m_is_current_grabber = 1;
  else begin
    while(seq.get_parent_seq()) begin
      if(seq.get_parent_seq() == m_grabbers[0])
        return 1;
      else
        seq = seq.get_parent_seq();
    end
    m_is_current_grabber = 0;
  end
endfunction : m_is_current_grabber


// ungrab()
// ------

function void ovm_sequencer::ungrab(ovm_sequence seq);
  if(seq == m_grabbers[0]) begin
    m_grabbers.delete(0);
    -> m_ungrab_e;
    -> m_eval_queue_e;
  end
  else 
    ovm_report_error("ILNGRB", $psprintf("Illegal ungrab by %0s", 
      seq.get_name()));
endfunction : ungrab


// current_grabber()
// ------

function ovm_sequence ovm_sequencer::current_grabber();
  if(m_grabbers.size())
    return m_grabbers[0];
  else
    return null;
endfunction :current_grabber


// is_grabbed()
// ------

function bit ovm_sequencer::is_grabbed();
  if(m_grabbers.size())
    return 1;
  else
    return 0;
endfunction :is_grabbed


// m_last_push_front
// --------------

function void ovm_sequencer::m_last_push_front(ovm_sequence_item item);
   if(!num_last_items)
     return;

   if(m_last_queue.size() == num_last_items)
     void'(m_last_queue.pop_back());

   this.m_last_queue.push_front(item);
endfunction


// set_num_last_items
// ----------------

function void ovm_sequencer::set_num_last_items(int unsigned max);
  if(max > 1024) begin
    ovm_report_warning("HSTOB", 
      $psprintf("Invalid last size; 1024 is the maximum and will be used", 
      max));
    max = 1024;
  end

  //shrink the buffer
  while((m_last_queue.size() != 0) && (m_last_queue.size() > max)) begin
     void'(m_last_queue.pop_back());
  end

  num_last_items = max;
endfunction


// last
// ----

function ovm_sequence_item ovm_sequencer::last(int unsigned n);
  if(n > num_last_items) begin
    ovm_report_warning("HSTOB",
      $psprintf("Invalid last access (%0d), the max history is %0d", n,
      num_last_items));
    return null;
  end
  if(n == m_last_queue.size())
    return null;

  return m_last_queue[n];
endfunction


