// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequencer.svh#1 $
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

`ifndef OVM_SEQUENCER_SVH
`define OVM_SEQUENCER_SVH

`include "methodology/ovm_meth_defines.svh"

typedef class ovm_sequencer;
typedef class ovm_seq_item_prod_if;


//------------------------------------------------------------------------------
//
// CLASS: ovm_seq_item_cons_if
//
//------------------------------------------------------------------------------

class ovm_seq_item_cons_if extends ovm_component;

  // sequencer type variable to hold parent
  ovm_sequencer parent_as_seqr;

  // component type variable to hold consumer that the interface is connected to
  ovm_component consumer;

  // constructor
  extern function new (string name="", ovm_component parent = null);

  // data functions
  extern function void do_print (ovm_printer printer);

  // create for factory usage
  extern function ovm_object create (string name="");

  // implement get_type_name
  extern virtual function string get_type_name();

  // connection method
  extern function void connect_if(ovm_seq_item_prod_if item_prod_if);

  // Macro to enable factory creation
  `ovm_component_registry(ovm_seq_item_cons_if, ovm_seq_item_cons_if)

endclass


//------------------------------------------------------------------------------
//
// CLASS: ovm_sequencer
//
//------------------------------------------------------------------------------

class ovm_sequencer extends ovm_sequencer_base;

  // sequence item consumer interface
  ovm_seq_item_cons_if seq_item_cons_if;

  // Constructor
  extern function new (string name, ovm_component parent);

  // get_type_name implementation
  extern function string get_type_name();

  // Defines how the sequencer interacts with sequencer: pull (default), or push
  protected bit pull_mode = 1;               

  // events used by the sequencer for communication with others
  // driver triggers when item is done
  ovm_event      item_done;     

  // sequence triggers when item available
  ovm_event      item_ready;    

  //Used for setting the maximum depth inside random sequences. 
  //(Beyond that depth, random creates only simple sequences.)
  int unsigned max_random_depth = 4;

  // used to place actions (functionaly this sequencers action queue)
  protected ovm_sequence m_action_q[$];

  // used to place an event of the parent seq process for acknowledgement
  protected ovm_event m_action_e[$];

  // emitted by ovm_sequencer::sync when a "do(item)" macro is executed
  local event m_eval_queue_e;
  local event m_ungrab_e;

  // task to determine when to evaluate the action queue
  extern task m_wait_for_activate();

  // task to support single item from outside
  extern task execute_item(input ovm_sequence_item item, ovm_sequence seq =
    null);

  // task to support single item from outside
  extern task apply(input ovm_sequence_item item, ovm_sequence seq = null);

  //queue of grabbing sequences
  local ovm_sequence m_grabbers[$];

  //accessor methods for sequences using local ovm_events
  extern function void m_item_ready_trigger( input ovm_object m_item=null);

  extern task item_done_wait_trigger_data(output ovm_sequence_item item);

  // Called by sequences to register a request to process an action
  extern virtual task m_sequencer_sync(input string item_name, 
    ovm_sequence parent_seq, ovm_event ack_process);

  // buffer used by sequences to store the currently generated item
  protected ovm_sequence_item m_last_queue[$];

  // variable to control the depth of the last queue
  protected int unsigned num_last_items = 1;

  // Set the item history buffer size.
  extern function void set_num_last_items (int unsigned max);

  // method that returns the item out of the last queue.  this method returns
  // the non specific type.
  extern function ovm_sequence_item last(int unsigned n);

  // Called by a sequence to place a sequence into the "last" buffer
  extern function void m_last_push_front(ovm_sequence_item item);

  // Called by run_forever, processes the action queue
  extern protected function bit process_queue(output int index);

  //invoked when a user sequence wants to gain sole access
  extern virtual task grab(ovm_sequence seq);

  //invoked when a user sequence releases sole access
  extern virtual function void ungrab(ovm_sequence seq);

  //used by m_grab to block sequences not associated with the current grabber
  extern local virtual task m_block_grabber(ovm_sequence seq);

  //called by m_grab(), returns true if seq qualifies as grabber
  extern local function bit m_is_current_grabber(ovm_sequence seq);

  //called by user to determine which sequence (if any) has the sequencer 
  //grabbed 
  extern function ovm_sequence current_grabber();

  //called by user to determine which sequence (if any) has the sequencer 
  //grabbed
  extern function bit is_grabbed();

  // Used by the sequencer in pull mode to retrieve randomized items from 
  // sequences.
  extern task get_next_item (output ovm_sequence_item item);

  // Used by the sequencer in pull mode to retrieve randomized items from 
  // sequences.
  extern task try_next_item (output ovm_sequence_item item);

  // wait delta cycles (by default) to see if an item is provided by a sequence
  // otherwise try_next_item() returns null
  extern virtual task wait_for_sequences ();

  //invoked by the sequencer after processing of a received item is completed.
  //optionally, provides the processed item
  extern function void item_done_trigger(ovm_sequence_item item=null);

  //invoked by the sequencer to determine if a relevant action is available
  extern function bit has_do_available();

  //Implement data functions
  extern function void do_copy (ovm_object rhs);
  extern function bit  do_compare (ovm_object rhs, ovm_comparer comparer);
  extern function void do_print (ovm_printer printer);
  extern function void do_record (ovm_recorder recorder);

endclass: ovm_sequencer


`endif // OVM_SEQUENCER_SVH

