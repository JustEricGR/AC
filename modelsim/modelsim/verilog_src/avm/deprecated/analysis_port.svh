// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/deprecated/analysis_port.svh#1 $
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


//----------------------------------------------------------------------
// CLASS analysis_port
//
// This is an analysis port ( aka observer ), more or less
// identical to the analysis port in SysC
//----------------------------------------------------------------------

// analysis_port is essentially a thin layer around a list of
// analysis_ifs.
//
// It is used to broadcast transactions to zero, one or many
// subscribers.
//
// Typically, it used to connect a monitor to a coverage object or a
// scoreboard.
//
// Since analysis_port implements analysis_if, we can chain
// analysis_port by registering one analysis_port with another. This is
// how we do hierarchical binding.

class analysis_port #( type T = int ) extends analysis_if #( T );
  
  local analysis_if #( T ) if_list[$];
  local avm_reporter r;

  function new();
    r = new();
    r.avm_report_warning(
      s_deprecated_3_0 ,
      "please use avm_analysis_port instead of analysis_port" ,
      500 );
    
  endfunction
  
  //+ The register method adds a subscriber to the analysis port
  
  function void register( input analysis_if #( T ) i );

    if( i == null ) begin
      r.avm_report_fatal("analysis_port" , "cannot register null interface" );
    end

    for( int j = 0; j < if_list.size(); j++ ) begin
      if( i == if_list[j] ) begin
        r.avm_report_error("analysis_port" , "same interface registered twice" );
      end
    end

    if_list.push_back( i );
  endfunction
  
  //+ the write method is used to broadcast t to many subscribers
  
  function void write( input T t );
    analysis_if #( T ) temp;
    for( int i = 0; i < if_list.size; i++ ) begin
      temp = if_list[i];
      assert( temp != null );
      temp.write( t );
    end
  endfunction
    
endclass

