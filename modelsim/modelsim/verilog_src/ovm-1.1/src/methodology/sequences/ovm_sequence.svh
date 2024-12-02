// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence.svh#1 $
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

`ifndef OVM_SEQUENCE_SVH
`define OVM_SEQUENCE_SVH


typedef class ovm_sequencer;
typedef class ovm_virtual_sequencer;

//-----------------------------------------------------------------------------
//
// CLASS: ovm_sequence
//
//-----------------------------------------------------------------------------

class ovm_sequence extends ovm_sequence_item; 

  // Constructor
  extern function new(string name="ovm_sequence", 
    ovm_sequencer_base sequencer=null,
    ovm_sequence parent_seq=null);

  // handle for called sequencer methods
  ovm_sequencer b_sequencer;

  // method to cast m_sequencer into b_sequencer
  extern function void m_set_b_sequencer();

  // id counters
  local static int g_id = 0;
  local int id;

  // get the id
  extern function int get_id();

  // events for monitoring progress from outside
  event started;
  event ended;

  // bit to detect if is_relevant()/wait_for_relevant() is changed
  local bit is_rel_default;
  local bit wait_rel_default;

  //invoked by ovm_sequence::start_sequence()
  extern virtual task pre_body();

  //invoked by ovm_sequence::start_sequence() and the DO macro.
  extern virtual task body(); 

  //invoked by ovm_sequence::start_sequence()
  extern virtual task post_body(); 

  //invoked by the sequence and sequence item macros after a sequence is 
  //selected to execute, but prior to the randomization of the do action.
  extern virtual task pre_do(bit is_item); 

  //invoked by the  sequence and sequence item macros after randomization of 
  //the action.
  extern virtual function void mid_do(ovm_sequence_item this_item); 

  //Called by sequence and sequence item.   Invoked after the sequencer has 
  // triggered item_done.
  extern virtual function void post_do(ovm_sequence_item this_item); 

  //actions out of its action queue.
  extern virtual function bit is_relevant(); 

  //task to re-evaluate when sequence becomes relevant
  extern virtual task wait_for_relevant();

  //A built in function returning a "1" for ovm_sequence types.
  extern virtual function int is_item(); 

  //invoked by a user-defined sequence to gain sole access to a sequencer
  extern task grab(ovm_sequencer sequencer = null);

  //invoked by a user-defined sequence to release sole access to a sequencer
  extern function void ungrab(ovm_sequencer sequencer = null);

  //allocate a ovm_sequence_item object
  extern function ovm_sequence_item create_item (ovm_sequence_item type_var,
    ovm_sequencer_base l_sequencer);

  //register and begin processing of ovm_sequence_item objects
  //call sync() & pre_do() of parent ovm_sequence for a sequence_item object
  //or body() for a ovm_sequence object
  extern task start_item(ovm_sequence_item type_var);

  //Called by sequence and sequence item macros.  Calls ovm_sequencer::sync and 
  //waits for acknoledgement to unblock the do invocation.
  extern task m_sync(ovm_sequence_item item);

  //Called by sequence and sequence item macros.   Places generated item in 
  //a sequencers "last" buffer and triggers sequencer.item_ready with the 
  //generated item.
  extern task m_post_sync(ovm_sequence_item item);

  //A user definable function which is evaluated by the sequencer when selecting
  //complete item processing
  extern task finish_item(ovm_sequence_item type_var);

  //used as an identifier in constraints for a specific type
  rand int unsigned seq_kind;

  // For user random selection. This exludes the exhaustive and
  // random sequences. Also handles the case of no sequencer attached, or
  // virtual sequencer which has no defaults except exahaustive and random.
  // Note that seq id 2 is simple_sequence for normal sequences.
  constraint     pick_sequence { 
       (num_sequences() <= 2) || (seq_kind >= 2);
       (seq_kind <  num_sequences()) || (seq_kind == 0); }

  // This function is useful for constraining against the size of the sequence queue
  function int unsigned num_sequences;
    if(b_sequencer == null) return 0;
    else return b_sequencer.sequences.size();
  endfunction

  // Returns a new sequence object given its unique kind (integer id)
  extern function ovm_sequence get_sequence(int req_kind);

  //Used to get an identifier of the sequence name from the parent sequencer's 
  //sequence library.  Calls ovm_sequencer::get_kind(string type_name);
  //extern function int unsigned get_kind(string type_name);
  extern function int get_seq_kind(string type_name);

  //Calls ovm_sequence::do_sequence_kind().
  extern task do_sequence_kind(int unsigned req_kind);

  //invoked by a user to determine block status regarding grab() invocation
  extern function bit is_blocked();

  //returned by is_blocked() and set/cleared by m_set_is_blocked()
  local bit m_block_status;

  //invoked by a sequencer to set block status regarding grab() invocation
  extern function void m_set_is_blocked(bit block_status);

  //disable a sequences body()
  extern function void stop();

  // pre_apply
  extern virtual task pre_apply();

  // mid_apply
  extern virtual task mid_apply();

  // post_apply
  extern virtual task post_apply();

  //apply an item
  extern task apply(ovm_sequence_item req, output ovm_sequence_item rsp);

  // start
  extern task start(ovm_sequencer_base sequencer, ovm_sequence parent_seq = 
    null);

endclass: ovm_sequence

`endif // OVM_SEQUENCE_SVH
