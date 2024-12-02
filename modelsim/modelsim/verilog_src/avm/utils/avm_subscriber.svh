// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/utils/avm_subscriber.svh#1 $
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

// This class provides an analysis export. A subclass needs
// to define its own write method Can be useful for
// functional coverage, where the write method will call one
// or more cov.sample methods

virtual class avm_subscriber #( type T = int ) 
  extends avm_named_component;

  typedef avm_subscriber #( T ) this_type;
  
  avm_analysis_imp #( T , this_type ) analysis_export;
  
  function new( string name , avm_named_component p );
    super.new( name , p );
    analysis_export = new( "analysis_imp" , this );
  endfunction
  
  pure virtual function void write( input T t );
    
endclass : avm_subscriber

