// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/deprecated/avm_global_analysis_ports.svh#1 $
//----------------------------------------------------------------------
//   Copyright 2005-2009 Mentor Graphics Corporation
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

//  A global analysis port is a many to many broadcaster.  A
//  global analysis port of a given name and type is global
//  within in any simulation - ie, there is only one of
//  them, and it exists in the global namespace.
// 
//  This can be used to get information out of testbench
//  components buried deep in the hierarchy of the test
//  bench without the need to connect analysis ports up
//  through the hierarchy.
// 
//  However, precisely because they are global, some caution
//  should be exercised. For any global analysis port, the
//  number of "writers" may be zero, one or many, nor do we
//  have any control over who is listening.

class global_analysis_ports #( type T = int );

  //  The repository of global analysis ports of type T
  
  static analysis_port #( T ) s_analysis_ports[string];
  
  //  get_analysis port creates an analysis port of type T
  //  and this name, if such an analysis port does not
  //  exist. It then returns the analysis port.
  
  static function analysis_port #( T ) get_analysis_port( string name );
    if( !s_analysis_ports.exists( name ) ) begin
      s_analysis_ports[name] = new;
    end
    
    return s_analysis_ports[name];
  endfunction
  
endclass
