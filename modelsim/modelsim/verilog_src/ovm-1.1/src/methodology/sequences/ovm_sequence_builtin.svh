// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_sequence_builtin.svh#1 $
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

`ifndef OVM_SEQUENCE_BUILTIN_SVH
`define OVM_SEQUENCE_BUILTIN_SVH

`include "methodology/ovm_meth_defines.svh"


//-----------------------------------------------------------------------------
//
// CLASS: ovm_random_sequence
//
//-----------------------------------------------------------------------------

class ovm_random_sequence extends ovm_sequence;

  rand protected int unsigned l_count;
  local int unsigned l_exhaustive_seq_kind;
  local int unsigned max_kind;
  rand local int unsigned l_kind;
  protected bit m_success;

  extern function new (string name="ovm_random_sequence", 
    ovm_sequencer_base sequencer=null,
    ovm_sequence parent_seq=null);

  extern virtual task body (); 

  //Implement data functions
  extern function void do_copy (ovm_object rhs);
  extern function bit  do_compare (ovm_object rhs, ovm_comparer comparer);
  extern function void do_print (ovm_printer printer);
  extern function void do_record (ovm_recorder recorder);

  function ovm_object create (string name="");
    ovm_random_sequence i; i=new(name);
    return i;
  endfunction

  virtual function string get_type_name();
     return "ovm_random_sequence";
  endfunction 
  
  // Macro for factory creation
  `ovm_object_registry(ovm_random_sequence, ovm_random_sequence)

endclass


//-----------------------------------------------------------------------------
//
// CLASS: ovm_exhaustive_sequence
//
//-----------------------------------------------------------------------------

class ovm_exhaustive_sequence extends ovm_sequence;

  rand protected int unsigned l_count;
  local int unsigned l_exhaustive_seq_kind;
  local int unsigned max_kind;
  randc local bit[9:0] l_kind;
  protected bit m_success;

  extern function new (string name="ovm_exhaustive_sequence", 
    ovm_sequencer_base sequencer=null,
    ovm_sequence parent_seq=null);

  extern virtual task body (); 

  //Implement data functions
  extern function void do_copy (ovm_object rhs);
  extern function bit  do_compare (ovm_object rhs, ovm_comparer comparer);
  extern function void do_print (ovm_printer printer);
  extern function void do_record (ovm_recorder recorder);

  function ovm_object create (string name="");
    ovm_exhaustive_sequence i; i=new(name);
    return i;
  endfunction

  virtual function string get_type_name();
     return "ovm_exhaustive_sequence";
  endfunction 

  // Macro for factory creation
  `ovm_object_registry(ovm_exhaustive_sequence, ovm_exhaustive_sequence)

endclass


//-----------------------------------------------------------------------------
//
// CLASS: ovm_simple_sequence
//
//-----------------------------------------------------------------------------

class ovm_simple_sequence extends ovm_sequence;

  // constructor
  extern function new (string name="ovm_simple_sequence", 
    ovm_sequencer_base sequencer=null, 
    ovm_sequence parent_seq=null);

  // defines the behavior of this core sequence.
  extern virtual task body(); 

  protected rand ovm_sequence_item item;

  extern function void do_print (ovm_printer printer);

  function ovm_object create (string name="");
    ovm_simple_sequence i; i=new(name);
    return i;
  endfunction

  virtual function string get_type_name();
     return "ovm_simple_sequence";
  endfunction 

  // Macro for factory creation
  `ovm_object_registry(ovm_simple_sequence, ovm_simple_sequence)

endclass


`endif // OVM_SEQUENCE_BUILTIN_SVH

