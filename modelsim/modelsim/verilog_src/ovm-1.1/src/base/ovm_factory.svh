// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_factory.svh#1 $
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

`ifndef OVM_FACTORY_SVH
`define OVM_FACTORY_SVH

typedef class ovm_object;
typedef class ovm_component;

// To register with a factory, a class must create a wrapper which implements
// Either the create_object (for generic data object) or create_component (for
// hierarchical elements).

virtual class ovm_object_wrapper;
  virtual function ovm_object create_object (string name="");
    return null;
  endfunction
  virtual function ovm_component create_component (string name, 
       ovm_component parent); 
    return null;
  endfunction
  // The wrapper must specify the type that it can create
  pure virtual function string get_type_name();

endclass

class ovm_factory_override;
  string inst_path;
  string req_type_name;
  string type_name;

  function new (string inst_path="", string req_type_name="", 
                string type_name="");
    this.inst_path = inst_path;
    this.req_type_name = req_type_name;
    this.type_name = type_name;
  endfunction
endclass



class ovm_factory extends ovm_object;

  extern function ovm_object create (string name="");
  extern function new (string name="");

  static ovm_factory inst;

  protected ovm_object_wrapper types[string];
  protected ovm_factory_override type_overrides[string];
  protected ovm_factory_override inst_overrides[$];

  // Method for registering an object creator. This is called automatically
  // by the `ovm_*_utils macros
  extern static function void auto_register  (ovm_object_wrapper obj);

  // Methods for creating objects
  extern static function ovm_object    create_object    (string lookup_str,  
                                                         string inst_path="",
                                                         string name="");

  extern static function ovm_component create_component (string lookup_str,
                                                         string inst_path="",
                                                         string name, 
                                                         ovm_component parent);

  // Methods for overriding how objects are created
  extern static function void         set_type_override (string lookup_str,
                                                         string type_name,
                                                         bit    replace=1);

  extern static function void         set_inst_override (string inst_path,
                                                         string lookup_str,
                                                         string type_name);

  // Debug methods
  extern static function void  print_all_overrides (bit all_types=0);

  extern protected function void  m_print_all_overrides (bit all_types=0);

  extern static function void     print_override_info   (string lookup_str,
                                                         string inst_path="",
                                                         string inst_name="");

  extern protected function void  m_print_override_info (string lookup_str,
                                                         string inst_path,
                                                         string inst_name);

  // Internal methods used for setting and using overrides.
  extern  function void          auto_register_type     (ovm_object_wrapper obj);

  extern  function void          override_type          (string lookup_str,
                                                         string type_name,
                                                         string inst_path,
                                                         bit replace=1);

  extern  function ovm_object   create_type             (string lookup_str,  
                                                         string inst_path="",
                                                         string name=""); 

  extern  function ovm_component create_component_type  (string lookup_str,  
                                                         string inst_path="",
                                                         string name, 
                                                         ovm_component parent);

  extern function ovm_object_wrapper find_override      (string lookup_str,
                                                         string inst_path,
                                                         string inst_name);

endclass


`endif // OVM_FACTORY_SVH

