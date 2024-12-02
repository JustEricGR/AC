// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_factory.sv#1 $
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

`include "base/ovm_factory.svh"
`include "base/ovm_object.svh"


// create
// ------

function ovm_object ovm_factory::create (string name="");
  ovm_factory f; f=new(name);
  return f; 
endfunction

// new
// ---

function ovm_factory::new (string name="");
    super.new (name);
    if(inst==null)
      inst = this;
endfunction


// auto_register (static)
// -------------

function void ovm_factory::auto_register (ovm_object_wrapper obj);

  if (inst==null) begin
    inst = new ("ovm_factory_inst");
  end
  inst.auto_register_type(obj);

endfunction


// auto_register_type
// ------------------

function void ovm_factory::auto_register_type (ovm_object_wrapper obj);

  if (types.exists(obj.get_type_name())) begin
    ovm_report_warning("TPRGED", $psprintf("Type '%0s' already registered with factory. Support for same type names in different scopes not implemented.", obj.get_type_name()));
    return;
  end

  types[obj.get_type_name()] = obj;
  
endfunction

// print_all_overrides
// -------------------

function void  ovm_factory::print_all_overrides (bit all_types=0);
  if(inst==null) inst = new;
  inst.m_print_all_overrides(all_types);
endfunction

function void  ovm_factory::m_print_all_overrides (bit all_types=0);
  ovm_factory_override t_ov[$];
  string no_ov[$];
  string key;

  if(type_overrides.first(key)) begin
    do begin
      t_ov.push_back(type_overrides[key]);
    end while(type_overrides.next(key));
  end
  if(all_types && types.first(key)) begin
    do begin
      if(!type_overrides.exists(key) && 
         !ovm_is_match("ovm_*", types[key].get_type_name()) )
      begin
        no_ov.push_back(types[key].get_type_name());
      end
    end while(types.next(key));
  end

  $display("#### Factory Overrides");

  if(!t_ov.size() && !inst_overrides.size()) begin
    $display("  No overrides exist in the factory");
  end

  if(inst_overrides.size()) begin
    string s;
    $display("Instance Overrides");
    $display("  Requested Type Name       Instance Path                       Override Type");
    $display("  -------------------------------------------------------------------------------------");
    for(int i=0; i<inst_overrides.size(); ++i) begin
      s = {"  ",inst_overrides[i].req_type_name};
      if(s.len() > 25) begin 
        s = s.substr(0,24);
        s[24] = "+";
      end
      else 
        for(int i=s.len(); i<=25; ++i) 
          s = {s," "};
      $write(s);
      s = {"  ",inst_overrides[i].inst_path};
      if(s.len() > 35) begin 
        s = s.substr(0,34);
        s[34] = "+";
      end
      else 
        for(int i=s.len(); i<=35; ++i) 
          s = {s," "};
      $write(s);
      s = {"  ", inst_overrides[i].type_name};
      if(s.len() > 25) begin 
        s = s.substr(0,24);
        s[24] = "+";
      end
      else 
        for(int i=s.len(); i<=25; ++i) 
          s = {s," "};
      $display(s);
    end
  end
  else if(t_ov.size()) begin
    $display("No Instance Overrides");
  end
  $display("");
  if(t_ov.size()) begin
    string s;
    $display("Type Overrides");
    $display("  Requested Type Name       Override Type");
    $display("  --------------------------------------------------");
    for(int i=0; i<t_ov.size(); ++i) begin
      s = {"  ",t_ov[i].req_type_name};
      if(s.len() > 25) begin 
        s = s.substr(0,24);
        s[24] = "+";
      end
      else 
        for(int i=s.len(); i<=25; ++i) 
          s = {s," "};
      $write(s);
      s = {"  ", t_ov[i].type_name};
      if(s.len() > 25) begin 
        s = s.substr(0,24);
        s[24] = "+";
      end
      else 
        for(int i=s.len(); i<=25; ++i) 
          s = {s," "};
      $display(s);
    end
  end
  if(no_ov.size()) begin
    $display("Additional Types in the factory (no type override)");
    $display("  Type Name");
    $display("  -------------------------");
    for(int i=0; i<no_ov.size(); ++i) begin
      $display("  ", no_ov[i]);
    end
  end
  $display("####");
endfunction

// print_override_info
// -------------------

function void  ovm_factory::print_override_info (string lookup_str,
                                                 string inst_path="",
                                                 string inst_name="");
  if(inst==null) inst = new;
  inst.m_print_override_info(lookup_str, inst_path, inst_name);
endfunction

function void  ovm_factory::m_print_override_info (string lookup_str,
                                                 string inst_path,
                                                 string inst_name);
 
  ovm_factory_override i_ov[$];
  ovm_factory_override t_ov;
  bit match;
  bit first_inst;
  
  for (int index=0; index < inst_overrides.size(); index++) begin
    if (inst_name != "") begin
      if (ovm_is_match(inst_overrides[index].inst_path,
                   {inst_path,".",inst_name}))
        i_ov.push_back(inst_overrides[index]);
    end
    else if (ovm_is_match(inst_overrides[index].inst_path, {inst_path})) begin
        i_ov.push_back(inst_overrides[index]);
    end
  end 

  t_ov = type_overrides[type_overrides[lookup_str].type_name];

  first_inst = 0;

  $display("#### Factory creation information");
  $display("   Type name (lookup string): ", lookup_str);
  $display("   Instance path            : ", inst_path);
  $display("   Instance name            : ", inst_name);
  for(int i=0; i<i_ov.size(); ++i) begin
    if (ovm_is_match(i_ov[i].req_type_name, lookup_str)) 
      match = 1; 
    else
      match = 0;
    $write("   Instance override");
    if(match==0) $write(" (ignored because required type does ",
                        "not match requested type for the instance path)\n");
    else if(first_inst==1) $write(" (disabled do to previous instance override)\n");
    else $write(" (enabled)\n");
    $display("      Required type   -- ", i_ov[i].req_type_name);
    $display("      Override inst   -- ", i_ov[i].inst_path);
    $display("      Override type   -- ", i_ov[i].type_name);
    if(match)
      first_inst = 1;
  end
  if(type_overrides[lookup_str].type_name != lookup_str) begin
    $write("   Type override");
    if(first_inst) $write(" (disabled do to instance override)\n");
    else $write(" (enabled)\n");
    $display("      Required type -- ", lookup_str);
    $display("      Override type -- ", type_overrides[lookup_str].type_name);
  end
  $write("   Base type requested: ", lookup_str);
  if(i_ov.size()) $write(" (disabled do to instance override)\n");
  else if(type_overrides[lookup_str].type_name != lookup_str)
    $write(" (disabled do to type override)\n");
  $display("####");
endfunction


// override_type
// -------------

function void ovm_factory::override_type (string lookup_str,
                                          string type_name,
                                          string inst_path,
                                          bit replace=1);
  
  ovm_factory_override tmp;

  // check that type is registered with the factory
  if (!types.exists(type_name)) begin
    if (inst_path == "")
      ovm_report_fatal("TYPNTF", $psprintf("Cannot register type override '%0s' because the type it's supposed to produce, '%0s', is not registered with the factory.", lookup_str, type_name));
    else
      ovm_report_fatal("TYPNTF", $psprintf("Cannot register instance override '%0s' for instance '%s' because the type it's supposed to produce, '%0s', is not registered with the factory.", lookup_str, inst_path, type_name));
    return;
  end

  // check if an instance override
  if (inst_path != "") begin
    tmp = new(inst_path, lookup_str, type_name);
    inst_overrides.push_back(tmp);
    return;
  end

  // check if the lookup string already exists
  if (type_overrides.exists(lookup_str)) begin

    if (replace==1) begin
      m_sc.scratch1 = type_overrides[lookup_str].type_name;
    end
    else if (replace==0) begin
      m_sc.scratch1 = type_overrides[lookup_str].type_name;
      ovm_report_warning("TPREGD", $psprintf("Lookup string '%0s' already registered to produce '%0s'.  Set replace argument to replace existing entry.", lookup_str, m_sc.scratch1));
      return;
    end
  end
  else begin
  end

  tmp = new("", lookup_str, type_name);

  type_overrides[lookup_str] = tmp;

endfunction


// find_override
// -------------

function ovm_object_wrapper ovm_factory::find_override(string lookup_str,
                                                       string inst_path,
                                                       string inst_name);

  // First see if any instance-specific override; return first match
  for (int index=0; index < inst_overrides.size(); index++) begin

    if (ovm_is_match(inst_overrides[index].req_type_name, lookup_str)) begin

      if (inst_name != "") begin

        if (ovm_is_match(inst_overrides[index].inst_path,
                     {inst_path,".",inst_name}))
          return types[inst_overrides[index].type_name];

      end
      else if (ovm_is_match(inst_overrides[index].inst_path, {inst_path})) begin

        return types[inst_overrides[index].type_name];

      end
    end
  end 

  // Next, lookup simple overrides queue
  if (type_overrides.exists(lookup_str)) begin
    return types[type_overrides[lookup_str].type_name];
  end

  // No override found
  return null;

endfunction


// create_type
// -----------

function ovm_object ovm_factory::create_type (string     lookup_str,  
                                              string     inst_path="",  
                                              string     name=""); 

  ovm_object_wrapper wrapper;

  wrapper = find_override(lookup_str, inst_path, name);

  // no override exists, so use lookup_str directly
  if (wrapper==null) begin
    if(!types.exists(lookup_str)) begin
      ovm_report_warning("BDTYP",$psprintf("Cannot create an object based on lookup string '%0s'.  This type is not registered with the factory.", lookup_str));
      return null;
    end
    wrapper = types[lookup_str];
  end

  return wrapper.create_object(name);

endfunction


// create_component_type
// ---------------------

function ovm_component ovm_factory::create_component_type (string     lookup_str,  
                                              string     inst_path="",  
                                              string     name, 
                                              ovm_component   parent);

  ovm_object_wrapper wrapper;

  // no override exists, so use lookup_str directly
  wrapper = find_override(lookup_str, inst_path, name);
  if (wrapper == null) begin
    if(!types.exists(lookup_str)) begin 
      ovm_report_warning("BDTYP", $psprintf("Cannot create an object based on lookup string '%0s'.  This type is not registered with the factory.", lookup_str));
      return null;
    end
    else begin
      wrapper = types[lookup_str];
    end
  end

  return wrapper.create_component(name, parent);

endfunction


// create_object (static)
// -------------

function ovm_object ovm_factory::create_object (string     lookup_str,  
                                                string     inst_path="", 
                                                string     name="");

  if (inst==null)
    inst = new ("ovm_factory_inst");

  return inst.create_type(lookup_str, inst_path, name);

endfunction


// create_component (static)
// ----------------

function ovm_component ovm_factory::create_component (string lookup_str,  
                                            string   inst_path="", 
                                            string   name, 
                                            ovm_component parent);

  if (inst==null)
    inst = new ("ovm_factory_inst");

  create_component = inst.create_component_type(lookup_str, inst_path, name, parent);

endfunction


// set_type_override (static)
// -----------------

function void ovm_factory::set_type_override (string lookup_str,
                                              string type_name,
                                              bit replace=1);
  if (inst==null)
    inst = new ("ovm_factory_inst");

  inst.override_type (lookup_str, type_name, "", replace);

endfunction


// set_inst_override (static)
// -----------------

function void ovm_factory::set_inst_override (string inst_path,
                                              string lookup_str,
                                              string type_name);

  if (inst==null)
    inst = new ("ovm_factory_inst");

  inst.override_type (lookup_str, type_name, inst_path, 0);

endfunction

