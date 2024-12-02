// $Id: ovm_sequencer_base.svh,v 1.10 2007/12/21 12:49:44 jlrose Exp $
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

`ifndef OVM_SEQUENCER_BASE_SVH
`define OVM_SEQUENCER_BASE_SVH

`include "methodology/ovm_meth_defines.svh"

typedef class ovm_sequence;
typedef class ovm_sequencer_base;
typedef class ovm_seq_cons_if;


//------------------------------------------------------------------------------
//
// CLASS: ovm_seq_prod_if
//
//------------------------------------------------------------------------------

class ovm_seq_prod_if extends ovm_component;

  // variable to hold the parent a ovm_sequencer_base type
  ovm_sequencer_base parent_as_seqr;

  // variable to hold sequence producer as an ovm_component type
  ovm_component producer;

  // constructor
  extern function new (string name="", ovm_component parent = null);

  // data method do_print
  extern function void do_print (ovm_printer printer);

  // polymorphic create method
  extern function ovm_object create (string name="");

  // return proper type name string
  extern virtual function string get_type_name();

  // connect interface method for producer to consumer
  extern function void connect_if(ovm_seq_cons_if vseq_if);

  // Macro to enable factory creation
  `ovm_component_registry(ovm_seq_prod_if, ovm_seq_prod_if)

endclass


//------------------------------------------------------------------------------
//
// CLASS: ovm_sequencer_base
//
//------------------------------------------------------------------------------

virtual class ovm_sequencer_base extends ovm_threaded_component;

  // sequence producer interface (virtual sequencer connection)
  ovm_seq_prod_if seq_prod_if;

  // This property defines which sequence will be auto-started (default=main).
  protected string default_sequence = "ovm_random_sequence";               

  // The sequeunce aray holds the type names of the sequence types registered
  // to this sequencer; the factory will actually create the instances on demand.
  string sequences[$];

  // The ids array associates each sequence entry (above) with an integer
  // number. This allows sequences to be randomly selected by randomizing
  // a number between 0 and the sequences array size.
  protected int sequence_ids[string];

  //set main and random sequence count variable if != -1
  //also accessed by ovm_main/random_sequence 
  int count = -1;

  // testing fields
  int m_random_count = 0;
  int m_exhaustive_count = 0;
  int m_simple_count = 0;

  //user settable property to limit main/random subsequences 
  //also accessed by ovm_main/random_sequence 
  int unsigned max_random_count = 10;

  // Constructor
  extern function new (string name, ovm_component parent);

  //Utility funciton used to copy sequence libraries.  Only used internally.
  extern protected function void set_sequences_queue(
    ref string sequencer_sequence_lib[$]);

  // Add a new sequence type (by name) to this sequencer's sequences queue
  extern protected function void add_sequence(string type_name);

  // Externed virtual declaration of the run() phase method.  This method
  // calls the necessary methods for the sequencer to operate.  Derivative 
  // implementations must call super.run().
  extern virtual task run();

  // Function executed on startup to process user-selected default_sequence
  extern protected virtual task start_default_sequence();

  //invokes pre_body(), body() and post_body() of a sequence.
  extern task start_sequence(ovm_sequence this_seq,
    ovm_sequencer_base this_seqr=null);

  // variable used to randomly select a sequence from the sequences array
  protected rand int seq_kind;

  // Returns an integer identifier of a sequence registered with a sequencer
  extern function int get_seq_kind(string type_name);

  // Returns a new sequence object given its unique kind (integer id)
  extern function ovm_sequence get_sequence(int req_kind);

  //Implement data functions
  extern function void do_copy (ovm_object rhs);
  extern function bit  do_compare (ovm_object rhs, ovm_comparer comparer);
  extern function void do_print (ovm_printer printer);
  extern function void do_record (ovm_recorder recorder);

endclass: ovm_sequencer_base


`endif // OVM_SEQUENCER_BASE_SVH

