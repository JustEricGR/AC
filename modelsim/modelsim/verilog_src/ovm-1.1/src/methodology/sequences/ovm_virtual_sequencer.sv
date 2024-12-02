// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/methodology/sequences/ovm_virtual_sequencer.sv#1 $
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


`include "methodology/sequences/ovm_virtual_sequencer.svh"



// new
// ---

function ovm_seq_cons_if::new (string name="", 
  ovm_component parent = null);
  super.new(name, parent);
endfunction


// do_print
// --------

function void ovm_seq_cons_if::do_print (ovm_printer printer);
  super.do_print(printer);
  if (seqrb_ref != null)
    printer.print_string("sequence consumer", seqrb_ref.get_full_name());
  else
    printer.print_string("sequence consumer", "NOT_CONNECTED");
endfunction


// create 
// ------

function ovm_object ovm_seq_cons_if::create (string name="");
  ovm_seq_cons_if i; i=new(name);
  return i;
endfunction


// get_type_name
// -------------

function string ovm_seq_cons_if::get_type_name();
  return "ovm_seq_cons_if";
endfunction 


// connect_if
// ----------

function void ovm_seq_cons_if::connect_if(ovm_seq_prod_if seqr_if);
  seqrb_ref = seqr_if.parent_as_seqr;
endfunction


// current_grabber
// ---------------

function ovm_sequence ovm_seq_cons_if::current_grabber();
  if ($cast(seqrnp_ref, seqrb_ref))
    return seqrnp_ref.current_grabber();
  else
    ovm_report_fatal("VSQGRB", "Cannot call current_grabber() for this type");
endfunction


// is_grabbed
// ----------

function bit ovm_seq_cons_if::is_grabbed();
  if ($cast(seqrnp_ref, seqrb_ref))
    return seqrnp_ref.is_grabbed();
  else
    ovm_report_fatal("VSQGRB", "Cannot call is_grabbed() for this type");
endfunction


// start_sequence
// --------------

task ovm_seq_cons_if::start_sequence(ovm_sequence this_seq);
  seqrb_ref.start_sequence(this_seq,seqrb_ref);
endtask


// grab
// ----

task ovm_seq_cons_if::grab(ovm_sequence this_seq);
  if ($cast(seqrnp_ref, seqrb_ref))
    seqrnp_ref.grab(this_seq);
  else
    ovm_report_fatal("VSQGRB", "Cannot call grab() for this type");
endtask


// ungrab
// ------

function void ovm_seq_cons_if::ungrab(ovm_sequence this_seq);
  if ($cast(seqrnp_ref, seqrb_ref))
    seqrnp_ref.ungrab(this_seq);
  else
    ovm_report_fatal("VSQGRB", "Cannot call ungrab() for this type");
endfunction


// is_connected
// ------------

function bit ovm_seq_cons_if::is_connected();
  if (seqrb_ref != null)
    return 1;
  else
    return 0;
endfunction


// is_virtual_sequencer
// --------------------

function bit ovm_seq_cons_if::is_virtual_sequencer();
  if (seqrb_ref == null)
    ovm_report_fatal("UNCSQR", "Cannot call connected_sequencer_type() on this unconnected interface.");
  else if ($cast(seqrnp_ref, seqrb_ref))
    return 0;
  else
    return 1;
endfunction


// get_sequencer_type_name
// -----------------------

function string ovm_seq_cons_if::get_sequencer_type_name();
  if(seqrb_ref != null)
    return seqrb_ref.get_type_name();
  else
    return "NOT_CONNECTED";
endfunction



// new
// ---

function ovm_virtual_sequencer::new (string name, ovm_component parent);
  super.new(name,parent);
endfunction


// start_default_sequence
// ----------------------

task ovm_virtual_sequencer::start_default_sequence();
  string temp_str;
  if(sequences.size() != 0) begin
    if(sequences.size() == 2) begin
      temp_str = "must have at least one user-defined virtual sequence.";
      ovm_report_fatal("NOUSEQ", $psprintf("%s %s", 
        get_full_name(), temp_str));
    end
    else 
      super.start_default_sequence();
  end
endtask


// get_type_name
// -------------

function string ovm_virtual_sequencer::get_type_name();
  return "ovm_virtual_sequencer";
endfunction


// do_print 
// --------

function void ovm_virtual_sequencer::do_print(ovm_printer printer);
  super.do_print(printer);
  if (seq_cons_if.num() != 0) begin
    printer.print_array_header("seq_cons_if", seq_cons_if.num());
    foreach(seq_cons_if[e]) begin
      printer.print_object({" [",e,"]"}, seq_cons_if[e], "[");
    end
    printer.print_array_footer();
  end
endfunction


// add_seq_cons_if
// ---------------

function void ovm_virtual_sequencer::add_seq_cons_if(string if_name);
  seq_cons_if[if_name] = null;
  $cast(seq_cons_if[if_name], create_component("ovm_seq_cons_if", 
    {"seq_cons_if[\"", if_name, "\"]"}));
  seq_cons_if[if_name].print_enabled = 0;
endfunction
