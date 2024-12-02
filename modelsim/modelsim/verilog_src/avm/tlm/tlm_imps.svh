// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/tlm_imps.svh#1 $
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


//
// These imps are used in avm_*_port, avm_*_export and avm_*_imp
//

`define BLOCKING_PUT_IMP( imp , TYPE , arg ) \
  task put( input TYPE arg ); imp.put( arg ); endtask

`define BLOCKING_GET_IMP( imp , TYPE , arg ) \
  task get( output TYPE arg ); imp.get( arg ); endtask

`define BLOCKING_PEEK_IMP( imp , TYPE , arg ) \
  task peek( output TYPE arg );imp.peek( arg ); endtask

`define NONBLOCKING_PUT_IMP( imp , TYPE , arg ) \
  function bit try_put( input TYPE arg ); \
    if( !imp.try_put( arg ) ) return 0; \
    return 1; \
  endfunction \
  function bit can_put(); return imp.can_put(); endfunction

`define NONBLOCKING_GET_IMP( imp , TYPE , arg ) \
  function bit try_get( output TYPE arg ); \
    if( !imp.try_get( arg ) ) return 0; \
    return 1; \
  endfunction \
  function bit can_get(); return imp.can_get(); endfunction

`define NONBLOCKING_PEEK_IMP( imp , TYPE , arg ) \
  function bit try_peek( output TYPE arg ); \
    if( !imp.try_peek( arg ) ) return 0; \
    return 1; \
  endfunction \
  function bit can_peek(); return imp.can_peek(); endfunction

