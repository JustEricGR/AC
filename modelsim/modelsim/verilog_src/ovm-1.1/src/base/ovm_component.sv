// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_component.sv#1 $
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

`include "base/ovm_component.svh"

//------------------------------------------------------------------------------
// 
// Class: ovm_*_phase (predefined phases)
//
//------------------------------------------------------------------------------

`ovm_phase_func_decl(build,1)
`ovm_phase_func_decl(connect,0)
`ovm_phase_func_decl(end_of_elaboration,0)
`ovm_phase_func_decl(start_of_simulation,0)
`ovm_phase_func_decl(extract,0)
`ovm_phase_func_decl(check,0)
`ovm_phase_func_decl(report,0)

build_phase               #(ovm_component) build_ph               = new();
connect_phase             #(ovm_component) connect_ph             = new();
end_of_elaboration_phase  #(ovm_component) end_of_elaboration_ph  = new();
start_of_simulation_phase #(ovm_component) start_of_simulation_ph = new();
extract_phase             #(ovm_component) extract_ph             = new();
check_phase               #(ovm_component) check_ph               = new();
report_phase              #(ovm_component) report_ph              = new();


// DEPRECATED - DO NOT USE IN NEW CODE

`ovm_phase_func_decl(post_new,0)
`ovm_phase_func_decl(export_connections,0)
`ovm_phase_func_decl(import_connections,1)
`ovm_phase_func_decl(pre_run,0)
`ovm_phase_func_decl(configure,0)
post_new_phase            #(ovm_component) post_new_ph            = new();
export_connections_phase  #(ovm_component) export_connections_ph  = new();
import_connections_phase  #(ovm_component) import_connections_ph  = new();
pre_run_phase             #(ovm_component) pre_run_ph             = new();
configure_phase           #(ovm_component) configure_ph           = new();
ovm_component ovm_top_levels[$]; // don't use

`include "base/ovm_root.svh"

//------------------------------------------------------------------------------
//
// CLASS: ovm_component
//
//------------------------------------------------------------------------------

// new
// ---

function ovm_component::new (string name, ovm_component parent);
  string error_str;

  super.new(name);

  // If ovm_top, reset name to "" so it doesn't show in full paths then return
  if (parent==null && name == "__top__") begin
    set_name("");
    return;
  end

  // Check that we're not in or past end_of_elaboration
  if (end_of_elaboration_ph.is_in_progress() ||
      end_of_elaboration_ph.is_done() ) begin
    ovm_phase curr_phase;
    curr_phase = ovm_top.get_current_phase();
    ovm_report_fatal("ILLCRT", {"It is illegal to create a component once",
              " phasing reaches end_of_elaboration. The current phase is ", 
              curr_phase.get_name()});
  end

  if (name == "") begin
    name.itoa(m_inst_count);
    name = {"COMP_", name};
  end

  if (parent == null)
    parent = ovm_top;

  ovm_report_message("NEWCOMP",$psprintf("this=%0s, parent=%0s, name=%s",
                     this.get_full_name(),parent.get_full_name(),name),10001);

  if (parent.has_child(name) && this != parent.get_child(name)) begin
    if (parent == ovm_top) begin
      error_str = {"Name '",name,"' is not unique to other top-level ",
      "instances. If parent is a module, build a unique name by combining the ",
      "the module name and component name: $psprintf(\"\%m.\%s\",\"",name,"\")."};
      ovm_report_fatal("CLDEXT",error_str);
    end
    else
      ovm_report_fatal("CLDEXT",
        $psprintf("Cannot set '%s' as a child of '%s', %s",
                  name, parent.get_full_name(),
                  "which already has a child by that name."));
    return;
  end

  m_parent = parent;

  set_name(name);

  if (!m_parent.m_add_child(this))
    m_parent = null;

  event_pool = new("event_pool");

  // Register ovm_component phases with ovm_top; only need do once
  if (ovm_component::m_phases_loaded==0) begin
    ovm_component::m_phases_loaded = 1;
    ovm_top.insert_phase(build_ph,              null);
    ovm_top.insert_phase(post_new_ph,           build_ph);
    ovm_top.insert_phase(export_connections_ph, post_new_ph);
    ovm_top.insert_phase(connect_ph,            export_connections_ph);
    ovm_top.insert_phase(import_connections_ph, connect_ph);
    ovm_top.insert_phase(configure_ph,          import_connections_ph);
    ovm_top.insert_phase(end_of_elaboration_ph, configure_ph);
    ovm_top.insert_phase(start_of_simulation_ph,end_of_elaboration_ph);
    ovm_top.insert_phase(pre_run_ph,            start_of_simulation_ph);
    ovm_top.insert_phase(extract_ph,            pre_run_ph);
    ovm_top.insert_phase(check_ph,              extract_ph);
    ovm_top.insert_phase(report_ph,             check_ph);
  end
 
  // Now that inst name is established, reseed (if use_ovm_seeding is set)
  reseed();

  // Do local configuration settings (URM backward compatibility)
  void'(get_config_int("recording_detail", recording_detail));

  // Deprecated container of top-levels (replaced by ovm_top)
  if (parent == ovm_top)
    ovm_top_levels.push_back(this);

endfunction


// m_add_child
// -----------

function bit ovm_component::m_add_child(ovm_component child);

  if (m_children.exists(child.get_name()) &&
      m_children[child.get_name()] != child) begin
      ovm_report_warning("BDCLD",
        $psprintf("A child with the name '%0s' (type=%0s) already exists.",
           child.get_name(), m_children[child.get_name()].get_type_name()));
      return 0;
  end

  foreach (m_children[c])
    if (child == m_children[c]) begin
      ovm_report_warning("BDCHLD",
        $psprintf("A child with the name '%0s' %0s %0s'",
                  child.get_name(),
                  "already exists in parent under name '",
                  m_children[c].get_name()));
      return 0;
    end

  m_children[child.get_name()] = child;
  return 1;
endfunction


//------------------------------------------------------------------------------
//
// Hierarchy Methods
// 
//------------------------------------------------------------------------------


// get_first_child
// ---------------

function int ovm_component::get_first_child(`ref string name);
  return m_children.first(name);
endfunction


// get_next_child
// --------------

function int ovm_component::get_next_child(`ref string name);
  return m_children.next(name);
endfunction


// get_child
// ---------

function ovm_component ovm_component::get_child(string name);
  return m_children[name];
endfunction


// has_child
// ---------

function int ovm_component::has_child(string name);
  return m_children.exists(name);
endfunction


// get_num_children
// ----------------

function int ovm_component::get_num_children();
  return m_children.num();
endfunction


// get_type_name
// -------------

function string ovm_component::get_type_name();
  return "ovm_component";
endfunction


// get_full_name
// -------------

function string ovm_component::get_full_name ();
  // Note: Implementation choice to construct full name once since the
  // full name may be used often for lookups.
  if(m_name == "")
    return get_name();
  else
    return m_name;
endfunction


// get_parent
// ----------

function ovm_component ovm_component::get_parent ();
  return  m_parent;
endfunction


// set_name
// --------

function void ovm_component::set_name (string name);
  
  super.set_name(name);
  m_set_full_name();

endfunction



// m_set_full_name
// ---------------

function void ovm_component::m_set_full_name();
  if (m_parent == ovm_top || m_parent==null)
    m_name = get_name();
  else 
    m_name = {m_parent.get_full_name(), ".", get_name()};

  foreach (m_children[c]) begin
    ovm_component tmp;
    tmp = m_children[c];
    tmp.m_set_full_name(); 
  end

endfunction


// lookup
// ------

function ovm_component ovm_component::lookup( string name );

  string leaf , remainder;
  ovm_component comp;

  comp = this;
  
  m_extract_name(name, leaf, remainder);

  if (leaf == "") begin
    comp = ovm_top; // absolute lookup
    m_extract_name(remainder, leaf, remainder);
  end
  
  if (!comp.has_child(leaf)) begin
    ovm_report_warning("Lookup Error", 
       $psprintf("Cannot find child %0s",leaf));
    return null;
  end

  if( remainder != "" )
    return comp.m_children[leaf].lookup(remainder);

  return comp.m_children[leaf];

endfunction


// m_extract_name
// --------------

function void ovm_component::m_extract_name(input string name ,
                                            output string leaf ,
                                            output string remainder );
  int i , len;
  string extract_str;
  len = name.len();
  
  for( i = 0; i < name.len(); i++ ) begin  
    if( name[i] == "." ) begin
      break;
    end
  end

  if( i == len ) begin
    leaf = name;
    remainder = "";
    return;
  end

  leaf = name.substr( 0 , i - 1 );
  remainder = name.substr( i + 1 , len - 1 );

  return;
endfunction
  

// flush
// -----

function void ovm_component::flush();
  return;
endfunction


// do_flush  (flush_hier?)
// --------

function void ovm_component::do_flush();
  foreach( m_children[s] )
    m_children[s].do_flush();
  flush();
endfunction
  

//------------------------------------------------------------------------------
//
// Factory Methods
// 
//------------------------------------------------------------------------------

// create
// ------

function ovm_object  ovm_component::create (string name =""); 
  ovm_report_error("ILLCRT",
    "create cannot be called on a ovm_component. Use create_component instead.");
  return null;
endfunction


// clone
// ------

function ovm_object  ovm_component::clone ();
  ovm_report_error("ILLCLN","clone cannot be called on a ovm_component. ");
  return null;
endfunction


// print_override_info
// -------------------

function void  ovm_component::print_override_info (string type_name, 
                                                   string inst_name="");
  ovm_factory::print_override_info(type_name, get_full_name(), inst_name);
endfunction


// create_component
// ----------------

function ovm_component ovm_component::create_component (string type_name,
                                                        string inst_name);
  return ovm_factory::create_component(type_name, get_full_name(),
                                       inst_name, this);
endfunction


// create_object
// -------------

function ovm_object ovm_component::create_object (string type_name,
                                                  string name="");
  return ovm_factory::create_object(type_name, get_full_name(), name);
endfunction


// set_type_override (static)
// -----------------

function void ovm_component::set_type_override (string override_type,
                                                string type_name,
                                                bit    replace=1);
   ovm_factory::set_type_override(override_type, type_name, replace);
endfunction 


// set_inst_override
// -----------------

function void  ovm_component::set_inst_override (string inst_path,  
                                                 string override_type,
                                                 string type_name);
  if(inst_path == "")
    inst_path = get_full_name();
  else
    inst_path = {get_full_name(), ".", inst_path};
  ovm_factory::set_inst_override(inst_path, override_type, type_name);
endfunction 


//------------------------------------------------------------------------------
//
// Hierarchical report configuration interface
//
//------------------------------------------------------------------------------

// set_report_severity_action_hier
// -------------------------------

function void ovm_component::set_report_severity_action_hier( ovm_severity s,
                                                              ovm_action a);
  set_report_severity_action(s, a);
  foreach( m_children[c] )
    m_children[c].set_report_severity_action_hier(s, a);
endfunction


// set_report_id_action_hier
// -------------------------

function void ovm_component::set_report_id_action_hier( string id, ovm_action a);
  set_report_id_action(id, a);
  foreach( m_children[c] )
    m_children[c].set_report_id_action_hier(id, a);
endfunction


// set_report_severity_id_action_hier
// ----------------------------------

function void ovm_component::set_report_severity_id_action_hier( ovm_severity s,
                                                                 string id,
                                                                 ovm_action a);
  set_report_severity_id_action(s, id, a);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_action_hier(s, id, a);
endfunction


// set_report_severity_file_hier
// -----------------------------

function void ovm_component::set_report_severity_file_hier( ovm_severity s,
                                                            OVM_FILE f);
  set_report_severity_file(s, f);
  foreach( m_children[c] )
    m_children[c].set_report_severity_file_hier(s, f);
endfunction


// set_report_default_file_hier
// ----------------------------

function void ovm_component::set_report_default_file_hier( OVM_FILE f);
  set_report_default_file(f);
  foreach( m_children[c] )
    m_children[c].set_report_default_file_hier(f);
endfunction


// set_report_id_file_hier
// -----------------------
  
function void ovm_component::set_report_id_file_hier( string id, OVM_FILE f);
  set_report_id_file(id, f);
  foreach( m_children[c] )
    m_children[c].set_report_id_file_hier(id, f);
endfunction


// set_report_severity_id_file_hier
// --------------------------------

function void ovm_component::set_report_severity_id_file_hier ( ovm_severity s,
                                                                string id,
                                                                OVM_FILE f);
  set_report_severity_id_file(s, id, f);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_file_hier(s, id, f);
endfunction


// set_report_verbosity_level_hier
// -------------------------------

function void ovm_component::set_report_verbosity_level_hier(int v);
  set_report_verbosity_level(v);
  foreach( m_children[c] )
    m_children[c].set_report_verbosity_level_hier(v);
endfunction  


//------------------------------------------------------------------------------
//
// Phase interface 
//
//------------------------------------------------------------------------------


// do_func_phase
// -------------

function void ovm_component::do_func_phase (ovm_phase phase);
  // If in build_ph, don't build if already done
  m_curr_phase = phase;
  if (!(phase == build_ph && m_build_done))
    phase.call_func(this);
endfunction


// do_kill_all
// -----------

function void ovm_component::do_kill_all();
  foreach(m_children[c])
    m_children[c].do_kill_all();
endfunction


// build
// -----

function void ovm_component::build();
  m_build_done = 1;
  apply_config_settings();
endfunction


// connect
// -------

function void ovm_component::connect();
  return;
endfunction


// configure
// ---------

function void ovm_component::configure();
  return;
endfunction


// start_of_simulation
// -------------------

function void ovm_component::start_of_simulation();
  return;
endfunction


// end_of_elaboration
// ------------------

function void ovm_component::end_of_elaboration();
  return;
endfunction


// extract
// -------

function void ovm_component::extract();
  return;
endfunction


// check
// -----

function void ovm_component::check();
  return;
endfunction


// report
// ------

function void ovm_component::report();
  return;
endfunction


// stop
// ----

task ovm_component::stop(string ph_name);
  return;
endtask


// resolve_bindings
// ----------------

function void ovm_component::resolve_bindings();
  return;
endfunction


// do_resolve_bindings
// -------------------

function void ovm_component::do_resolve_bindings();
  foreach( m_children[s] )
    m_children[s].do_resolve_bindings();
  resolve_bindings();
endfunction



//------------------------------------------------------------------------------
//
// Recording interface
//
//------------------------------------------------------------------------------

// accept_tr
// ---------

function void ovm_component::accept_tr (ovm_transaction tr,
                                        time accept_time=0);
  ovm_event e;
  tr.accept_tr(accept_time);
  do_accept_tr(tr);
  e = event_pool.get("accept_tr");
  if(e!=null) 
    e.trigger();
endfunction

// begin_tr
// --------

function integer ovm_component::begin_tr (ovm_transaction tr,
                                          string stream_name ="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  return m_begin_tr(tr, 0, 0, stream_name, label, desc, begin_time);
endfunction

// begin_child_tr
// --------------

function integer ovm_component::begin_child_tr (ovm_transaction tr,
                                          integer parent_handle=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  return m_begin_tr(tr, parent_handle, 1, stream_name, label, desc, begin_time);
endfunction

// m_begin_tr
// ----------

function integer ovm_component::m_begin_tr (ovm_transaction tr,
                                          integer parent_handle=0,
                                          bit    has_parent=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  ovm_event e;
  integer stream_h;
  integer tr_h;
  integer link_tr_h;
  string name;

  tr_h = 0;
  if(has_parent)
    link_tr_h = tr.begin_child_tr(begin_time, parent_handle);
  else
    link_tr_h = tr.begin_tr(begin_time);

  if (tr.get_name() != "")
    name = tr.get_name();
  else
    name = tr.get_type_name();

  if(stream_name == "") stream_name="main";

  if (recording_detail != OVM_NONE) begin

    if(m_stream_handle.exists(stream_name))
        stream_h = m_stream_handle[stream_name];

    if (ovm_check_handle_kind("Fiber", stream_h) != 1) 
      begin  
        stream_h = ovm_create_fiber(stream_name, "TVM", get_full_name());
        m_stream_handle[stream_name] = stream_h;
      end

    if(has_parent == 0) 
      tr_h = ovm_begin_transaction("Begin_No_Parent, Link", 
                             stream_h,
                             name,
                             label,
                             desc,
                             begin_time);
    else begin
      tr_h = ovm_begin_transaction("Begin_End, Link", 
                             stream_h,
                             name,
                             label,
                             desc,
                             begin_time);
      if(parent_handle!=0)
        ovm_link_transaction(parent_handle, tr_h, "child");
    end

    m_tr_h[tr] = tr_h;

    if (ovm_check_handle_kind("Transaction", link_tr_h) == 1)
      ovm_link_transaction(tr_h,link_tr_h);
        
    do_begin_tr(tr,stream_name,tr_h); 
        
    e = event_pool.get("begin_tr");
    if (e!=null) 
      e.trigger(tr);
        
  end
 
  return tr_h;

endfunction


// end_tr
// ------

function void ovm_component::end_tr (ovm_transaction tr,
                                     time end_time=0,
                                     bit free_handle=1);
  ovm_event e;
  integer tr_h;
  tr_h = 0;

  tr.end_tr(end_time,free_handle);

  if (recording_detail != OVM_NONE) begin

    if (m_tr_h.exists(tr)) begin

      tr_h = m_tr_h[tr];

      do_end_tr(tr, tr_h); // callback

      m_tr_h.delete(tr);

      if (ovm_check_handle_kind("Transaction", tr_h) == 1) begin  

        ovm_default_recorder.tr_handle = tr_h;
        tr.record(ovm_default_recorder);

        ovm_end_transaction(tr_h,end_time);

        if (free_handle)
           ovm_free_transaction_handle(tr_h);

      end
    end
    else begin
      do_end_tr(tr, tr_h); // callback
    end


    e = event_pool.get("end_tr");
    if(e!=null) 
      e.trigger();
  end

endfunction

// record_error_tr
// ---------------

function integer ovm_component::record_error_tr (string stream_name="main",
                                              ovm_object info=null,
                                              string label="error_tr",
                                              string desc="",
                                              time   error_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;

  if(keep_active) etype = "Error, Link";
  else etype = "Error";

  if(error_time == 0) error_time = $time;

  stream_h = m_stream_handle[stream_name];
  if (ovm_check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = ovm_create_fiber(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_error_tr = ovm_begin_transaction(etype, stream_h, label,
                         label, desc, error_time);
  if(info!=null) begin
    ovm_default_recorder.tr_handle = record_error_tr;
    info.record(ovm_default_recorder);
  end

  ovm_end_transaction(record_error_tr,error_time);
endfunction


// record_event_tr
// ---------------

function integer ovm_component::record_event_tr (string stream_name="main",
                                              ovm_object info=null,
                                              string label="event_tr",
                                              string desc="",
                                              time   event_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;

  if(keep_active) etype = "Event, Link";
  else etype = "Event";

  if(event_time == 0) event_time = $time;

  stream_h = m_stream_handle[stream_name];
  if (ovm_check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = ovm_create_fiber(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_event_tr = ovm_begin_transaction(etype, stream_h, label,
                         label, desc, event_time);
  if(info!=null) begin
    ovm_default_recorder.tr_handle = record_event_tr;
    info.record(ovm_default_recorder);
  end

  ovm_end_transaction(record_event_tr,event_time);
endfunction

// do_accept_tr
// ------------

function void ovm_component::do_accept_tr (ovm_transaction tr);
  return;
endfunction


// do_begin_tr
// -----------

function void ovm_component::do_begin_tr (ovm_transaction tr,
                                          string stream_name,
                                          integer tr_handle);
  return;
endfunction


// do_end_tr
// ---------

function void ovm_component::do_end_tr (ovm_transaction tr,
                                        integer tr_handle);
  return;
endfunction


//------------------------------------------------------------------------------
//
// Configuration interface
//
//------------------------------------------------------------------------------


// set_config_int
// --------------

function void  ovm_component::set_config_int    (string      inst_name,
                                                 string      field_name,
                                                 ovm_bitstream_t value);
  ovm_int_config_setting cfg;
  cfg = new({get_full_name(), ".", inst_name}, field_name,
              value, get_full_name());
  m_configuration_table.push_front(cfg);
endfunction


// set_config_string
// -----------------

function void ovm_component::set_config_string  (string      inst_name,  
                                                 string      field_name,
                                                 string      value);
  ovm_string_config_setting cfg;
  cfg = new({get_full_name(), ".", inst_name}, field_name,
              value, get_full_name());
  m_configuration_table.push_front(cfg);
endfunction


// set_config_object
// -----------------

function void ovm_component::set_config_object  (string      inst_name,
                                                 string      field_name,
                                                 ovm_object  value,
                                                 bit         clone=1);
  ovm_object_config_setting cfg;
  if(clone && (value != null)) begin
    ovm_object tmp;
    tmp = value.clone();

    // If create not implemented, or clone is attempted on objects that
    // do not t allow cloning (e.g. components) clone will return null.
    if(tmp == null) begin
      ovm_report_warning("INVCLN", {"Clone failed during set_config_object, ",
        "the original reference will be used for configuration. Check that ",
        "the create method for the object type is defined properly."});
      `ifdef INCA
        $stacktrace;
      `endif
    end
    else
      value = tmp;
  end

  cfg = new({get_full_name(), ".", inst_name}, field_name,
             value, get_full_name(), clone);
  m_configuration_table.push_front(cfg);

endfunction


// MACROS: (used in get_config_* method implementations)
// -------

`define OVM_LOCAL_SCOPE_STACK(STACK, START) \
  begin \
    ovm_component oc; \
    oc = START; \
    if(oc!=null) begin \
      do begin \
        STACK.push_front(oc.m_parent); \
        oc = oc.m_parent; \
      end while(oc); \
    end \
    else \
      STACK.push_front(null); \
  end

`define OVM_APPLY_CONFIG_SETTING(STACK, CFG) \
  foreach(STACK[s]) begin \
    comp = STACK[s]; \
    if(rtn) break; \
    if(comp==null) begin \
      for(int i=0; i<global_configuration_table.size(); ++i) begin \
         if(global_configuration_table[i].component_match(this) && \
            global_configuration_table[i].field_match(field_name))  \
         begin \
           if($cast(CFG, global_configuration_table[i])) begin \
             if(print_config_matches)   \
               global_configuration_table[i].print_match(this,null,field_name);\
             value = CFG.value; \
             rtn = 1; \
             break; \
           end \
         end \
      end \
    end \
    else begin \
      for(int i = 0; i<comp.m_configuration_table.size(); ++i) begin \
         if(comp.m_configuration_table[i].component_match(this) && \
            comp.m_configuration_table[i].field_match(field_name))  \
         begin \
           if($cast(CFG, comp.m_configuration_table[i])) begin \
             if(print_config_matches)   \
               comp.m_configuration_table[i].print_match(this,comp,field_name);\
             value = CFG.value; \
             rtn = 1; \
             break; \
           end \
         end \
      end \
    end \
  end


// get_config_int
// --------------

function bit ovm_component::get_config_int (string field_name,
                                            inout ovm_bitstream_t value);
  ovm_component stack[$];
  ovm_component comp;
  ovm_int_config_setting cfg;
  bit rtn; rtn = 0;
  `OVM_LOCAL_SCOPE_STACK(stack, this)
  `OVM_APPLY_CONFIG_SETTING(stack, cfg)
  return rtn;
endfunction
  

// get_config_string
// -----------------

function bit ovm_component::get_config_string (string field_name,
                                               inout string value);
  ovm_component stack[$];
  ovm_component comp;
  ovm_string_config_setting cfg;
  bit rtn; rtn = 0;
  `OVM_LOCAL_SCOPE_STACK(stack, this)
  `OVM_APPLY_CONFIG_SETTING(stack, cfg)
  return rtn;
endfunction

  
// get_config_object
// -----------------

function bit ovm_component::get_config_object (string field_name,
                                               inout ovm_object value,  
                                               input bit clone=1);
  ovm_component stack[$];
  ovm_component comp;
  ovm_object_config_setting cfg;
  bit rtn; rtn = 0;
  `OVM_LOCAL_SCOPE_STACK(stack, this)
  `OVM_APPLY_CONFIG_SETTING(stack, cfg)
  if(rtn && clone && (value != null)) begin
    ovm_object tmp;
    tmp = value.clone();
    if(tmp != null) 
      tmp = value;
  end
  return rtn;
endfunction
 

// apply_config_settings
// ---------------------

function void ovm_component::apply_config_settings (bit verbose=0);
  ovm_component stack[$];
  ovm_config_setting cfg;
  ovm_int_config_setting cfg_int;
  ovm_string_config_setting cfg_str;
  ovm_object_config_setting cfg_obj;
  ovm_component comp;
  `OVM_LOCAL_SCOPE_STACK(stack, this)
  //apply any override that matches this component. Go bottom up and then back
  //to front so the last override in the global scope has precedence to the
  //first override in the parent scope.
  for(int i=stack.size()-1; i>=0; --i) begin
    if(stack[i]!=null) begin
      for(int j=stack[i].m_configuration_table.size()-1; j>=0; --j) begin
        cfg = stack[i].m_configuration_table[j];
        if(ovm_is_match(cfg.inst, get_full_name())) begin
          if($cast(cfg_int, cfg)) begin
             set_int_local(cfg_int.field, cfg_int.value);
          end
          else if($cast(cfg_str, cfg)) begin
            set_string_local(cfg_str.field, cfg_str.value);
          end
          else if($cast(cfg_obj, cfg)) begin
            set_object_local(cfg_obj.field, cfg_obj.value, cfg_obj.clone);
          end
        end
      end
    end
    else begin
      for(int j=global_configuration_table.size()-1; j>=0; --j) begin
        //not sure why I need this cast. Seems like a bug
        $cast(cfg, global_configuration_table[j]);
        if(ovm_is_match(cfg.inst, get_full_name())) begin
          if($cast(cfg_int, cfg)) begin
            set_int_local(cfg_int.field, cfg_int.value);
          end
          else if($cast(cfg_str, cfg)) begin
            set_string_local(cfg_str.field, cfg_str.value);
          end
          else if($cast(cfg_obj, cfg)) begin
            set_object_local(cfg_obj.field, cfg_obj.value, cfg_obj.clone);
          end
        end
      end
    end
  end
endfunction


// print_config_settings
// ---------------------

function void ovm_component::print_config_settings (string field="",
                                                    ovm_component comp=null,
                                                    bit recurse=0);
  static int depth;
  ovm_component stack[$];
  ovm_component cc;
  string all_matches;
  string v,r;
  all_matches = "";

  if(comp==null)
    comp = this;

  `OVM_LOCAL_SCOPE_STACK(stack, comp)
  cc = comp;

  $swrite(v, "%s", cc.get_full_name());
  while(v.len()<17) v = {v," "};
  foreach(stack[s]) begin
    comp = stack[s];
    if(comp==null) begin
      for(int i=0; i<global_configuration_table.size(); ++i) begin
         r =  global_configuration_table[i].matches_string(cc, null);
         if(r != "")
           all_matches = {all_matches, v, r, "\n"};
      end
    end
    else begin
      for(int i=0; i<comp.m_configuration_table.size(); ++i) begin
        r = comp.m_configuration_table[i].matches_string(cc, comp);
        if(r != "")
          all_matches = {all_matches, v, r, "\n"};
      end
    end
  end

  // Note: should use ovm_printer for formatting
  if(((all_matches != "") || (recurse == 1)) && depth == 0) begin
    $display("Configuration settings for component %s (recurse = %0d)",
             cc.get_full_name(), recurse);
    $display("Set to            Set from         Component match   Field name   Type    Value");
    $display("-------------------------------------------------------------------------------");
  end
  if(all_matches == "")
    $display("%s NONE", v);
  else
    $write("%s", all_matches);

  if(recurse) begin
    depth++;
    if(cc.m_children.first(v))
      do this.print_config_settings(field, cc.m_children[v], recurse);
      while(cc.m_children.next(v));
    depth--;
  end
endfunction




//------------------------------------------------------------------------------
//
// DEPRECATED - DO NOT USE
//
//------------------------------------------------------------------------------

// do_display (deprecated)
// ----------

function void ovm_component::do_display( int max_level = -1 ,
                                         int level = 0 ,
                                         bit display_connectors = 0 );
  if( level == max_level )
    return;

   foreach( m_children[s] )
     m_children[s].do_display( max_level , level + 1 ,
                               display_connectors );
endfunction


// check_connection_size (deprecated)
// ---------------------

function void ovm_component::check_connection_size();
  foreach( m_children[s] ) 
    m_children[s].check_connection_size();
endfunction


// global_stop_request (static, deprecated)
// -------------------

function void ovm_component::global_stop_request();
  ovm_root top;
  top = get_top();
  top.stop_request();
endfunction


// post_new (deprecated)
// --------

function void ovm_component::post_new();
  return;
endfunction


// export_connections (deprecated)
// ------------------

function void ovm_component::export_connections();
  return;
endfunction


// import_connections (deprecated)
// ------------------

function void ovm_component::import_connections();
  return;
endfunction


// pre_run (deprecated)
// -------

function void ovm_component::pre_run();
  return;
endfunction


// absolute_lookup (deprecated)
// ---------------

function ovm_component ovm_component::absolute_lookup( string name );
  name = {".",name};
  return lookup(name);
endfunction
 

// relative_lookup (deprecated)
// ---------------

function ovm_component ovm_component::relative_lookup( string name );
  return lookup(name);
endfunction


// build_debug_lists (deprecated)
// -----------------

function void ovm_component::build_debug_lists();  
  foreach(m_children[s])
    m_children[s].add_to_debug_list();
endfunction


// add_to_debug_list (deprecated)
// -----------------

function void ovm_component::add_to_debug_list();
  m_parent.m_components[get_name()] = this;
endfunction


// find_component (deprecated)
// --------------

function ovm_component ovm_component::find_component (string comp_match);
  return ovm_top.find(comp_match);
endfunction



// find_components (deprecated)
// ---------------

function void ovm_component::find_components (string comp_match,
                                              ref ovm_component comps[$]);
  ovm_top.find_all(comp_match,comps);
endfunction


// get_component (deprecated)
// -------------

ovm_component m__comps[$]; // deprecated, do not use

function ovm_component ovm_component::get_component (int ele);
  if (m__comps.size()==0)
    ovm_top.find_all("*",m__comps);
  if (ele < m__comps.size())
    return m__comps[ele];
  return null;
endfunction


// get_num_components (deprecated)
// ------------------

function int ovm_component::get_num_components ();
  while (m__comps.size()!=0)
    m__comps.delete(0);
  ovm_top.find_all("*",m__comps);
  get_num_components = m__comps.size();
endfunction


/*
// get_child_old
// -------------

function ovm_component ovm_component::get_child_old(int index);
  int curr;
  string c;
  int num;
 
  if (index < 0 || index >= this.m_children.num()) begin
    num = this.m_children.num();
    ovm_report_error("BDINDX",
                     $psprintf("index %0d out of range. Valid range is [0:%0d]",
                     index, num));
     return null; 
  end

  curr = 0;

  if(!m_children.first(c))
    return null;

  while (curr != index) begin
    void'(m_children.next(c)); 
    curr++;
  end

  return m_children[c];

endfunction
*/

