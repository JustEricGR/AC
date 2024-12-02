// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/deprecated/avm_verification_component.svh#1 $
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

virtual class avm_verification_component extends avm_threaded_component;
  function new( string name , avm_named_component parent );
    super.new( name , parent );
    avm_report_warning( s_deprecated_3_0 ,
      "avm_verification_component is deprecated in AVM 3.0 and later.");
    avm_report_message( s_deprecated_3_0 ,
      "Please use avm_threaded_component instead" );
  endfunction
endclass
  
