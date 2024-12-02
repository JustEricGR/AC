// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_registry.svh#1 $
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
`ifndef OVM_REGISTRY_SVH
`define OVM_REGISTRY_SVH

  class ovm_component_registry #(type T = ovm_component, 
                                string Tname = "ovm_component")
    extends ovm_object_wrapper;
    function ovm_component create_component(string name, ovm_component parent);
      T u;
      u = new(name, parent);
      return u;
    endfunction
    function string get_type_name();
      return Tname;
    endfunction
    static function bit register_me();
      ovm_component_registry #(T,Tname) w; w = new;
      ovm_factory::auto_register(w);
      return 1;
    endfunction
    static bit is_registered = register_me();
  endclass

  class ovm_object_registry #(type T = ovm_object, 
                                string Tname = "ovm_object")
    extends ovm_object_wrapper;
    function ovm_object create_object(string name);
      T u;
      u = new();
      u.set_name(name);
      return u;
    endfunction
    function string get_type_name();
      return Tname;
    endfunction
    static function bit register_me();
      ovm_object_registry #(T,Tname) w; w = new;
      ovm_factory::auto_register(w);
      return 1;
    endfunction
    static bit is_registered = register_me();
  endclass

`endif
