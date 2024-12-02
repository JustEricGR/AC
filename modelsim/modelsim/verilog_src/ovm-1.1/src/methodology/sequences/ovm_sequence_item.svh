// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence_item.svh#1 $
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

`ifndef OVM_SEQUENCE_ITEM_SVH
`define OVM_SEQUENCE_ITEM_SVH


typedef class ovm_sequencer_base;
typedef class ovm_sequence;

//------------------------------------------------------------------------------
//
// CLASS: ovm_sequence_item
//
// declaration
//------------------------------------------------------------------------------

class ovm_sequence_item extends ovm_transaction;

  //constructor function
  extern function new (input string name="ovm_sequence_item", 
    ovm_sequencer_base sequencer=null, 
    ovm_sequence parent_seq=null);

  // Bit to control whether sequence info is printed in do_print()
  bit print_sequence_info;

  // transaction recording variable
  int tr_handle;

  //Implement data functions
  extern function void do_copy (ovm_object rhs);
  extern function bit do_compare (ovm_object rhs, ovm_comparer comparer);
  extern function void do_print (ovm_printer printer);
  extern function void do_record (ovm_recorder recorder);

  // used by sequences to identify their parent sequencer
  ovm_sequencer_base m_sequencer;

  //used to set the parent sequencer
  extern function void set_sequencer (ovm_sequencer_base sequencer);

  // virtual function to set the b_sequencer variable
  extern virtual function void m_set_b_sequencer();

  // virtual function to set the p_sequencer variable
  extern virtual function void m_set_p_sequencer();

  //used to get the parent sequencer
  extern function ovm_sequencer_base get_sequencer();

  // used by sequences to identify their parent sequence 
  ovm_sequence m_parent_seq;

  //used to set the parent sequence
  extern function void set_parent_seq (ovm_sequence parent);

  //used to get the parent sequence
  extern function ovm_sequence get_parent_seq();

  //show the full hierarchy to the item
  extern function string get_full_name();

  //show the seuqence path to the item
  extern function string get_sequence_path();

  //used by hierarchical sequences to get root sequence name for tr. recording
  extern virtual function string m_get_root_sequence_name();

  //used for printing root_sequence reference
  extern virtual function ovm_sequence m_get_root_sequence();

  // used for reporting
  extern protected virtual function ovm_report_object m_get_report_object();

  // used to determine if a ovm_sequence_item base object is an item (1) or 
  // sequence (0)
  extern virtual function int is_item();

  // Depth from sequencer
  int depth;

  // Function to return protected property depth_from_driver
  extern function int get_depth();

  // polymorphic creation
  extern function ovm_object create (string name="");

  // return type name string
  extern virtual function string get_type_name();

endclass: ovm_sequence_item


`endif  //OVM_SEQUENCE_ITEM_SVH 
