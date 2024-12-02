// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/tlm/tlm_imps.svh#1 $
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


//
// These imps are used in ovm_*_port, ovm_*_export and ovm_*_imp
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

`define BLOCKING_TRANSPORT_IMP( imp, REQ, RSP, req_arg, rsp_arg) \
  task transport( input REQ req_arg, output RSP rsp_arg); \
    imp.transport(req_arg, rsp_arg); \
  endtask

`define NONBLOCKING_TRANSPORT_IMP( imp, REQ, RSP, req_arg, rsp_arg) \
  function bit nb_transport( input REQ req_arg, output RSP rsp_arg); \
    return imp.nb_transport(req_arg, rsp_arg); \
  endfunction

