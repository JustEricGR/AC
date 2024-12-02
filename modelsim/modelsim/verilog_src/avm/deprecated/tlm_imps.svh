// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/deprecated/tlm_imps.svh#1 $
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
// TLM Implementations
//
// These implementations are basically wrappers for each tlm
// interface. They both implement and delegate every method
// in the interface in question.
//
// The underlying implementation MUST be provided in the
// constructor.
//

//
// Everything from here onwards is not needed in AVM 3.0
//

typedef avm_virtual_class virtual_class;

`define WRAPPER_IMP( IMP ) \
  local IMP m_imp; \
  function new( IMP i );  m_imp = i; endfunction

`define REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP ) \
  local REQ_IMP m_req_imp; \
  local RSP_IMP m_rsp_imp; \
  function new( REQ_IMP req_imp , RSP_IMP rsp_imp ); \
    m_req_imp = req_imp; m_rsp_imp = rsp_imp; \
  endfunction

//
// tlm_*_imp #( IMP , T ) are deprecated in AVM 3.0 onwards
//
// pleaseuse avm_*_imp #( T , IMP ) instead
// [ NB the new parameter ordering ]
//

// put implementations

//----------------------------------------------------------------------
// CLASS tlm_put_imp
//----------------------------------------------------------------------

class tlm_put_imp #( type IMP = virtual_class, type T = int )
  extends tlm_put_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_PUT_IMP( m_imp,  T , t )
  `NONBLOCKING_PUT_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_blocking_put_imp
//----------------------------------------------------------------------

class tlm_blocking_put_imp #( type IMP = virtual_class, type T = int )
  extends tlm_blocking_put_if #( T );

  `WRAPPER_IMP( IMP )
  `BLOCKING_PUT_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_nonblocking_put_imp
//----------------------------------------------------------------------

class tlm_nonblocking_put_imp #( type IMP = virtual_class,
         type T = int )
  
  extends tlm_nonblocking_put_if #( T );

  `WRAPPER_IMP( IMP )
  `NONBLOCKING_PUT_IMP( m_imp , T , t )

endclass

// get implementations

//----------------------------------------------------------------------
// CLASS tlm_get_imp
//----------------------------------------------------------------------

class tlm_get_imp #( type IMP = virtual_class, type T = int )
  extends tlm_get_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_GET_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_blocking_get_imp
//----------------------------------------------------------------------

class tlm_blocking_get_imp #( type IMP = virtual_class, type T = int )
  extends tlm_blocking_get_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_GET_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_nonblocking_get_imp
//----------------------------------------------------------------------

class tlm_nonblocking_get_imp #( type IMP = virtual_class,
         type T = int )
  
  extends tlm_nonblocking_get_if #( T );

  `WRAPPER_IMP( IMP )

  `NONBLOCKING_GET_IMP( m_imp , T , t )

endclass

// peek implementations

//----------------------------------------------------------------------
// CLASS tlm_peek_imp
//----------------------------------------------------------------------

class tlm_peek_imp #( type IMP = virtual_class, type T = int )
  extends tlm_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_PEEK_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_blocking_peek_imp
//----------------------------------------------------------------------

class tlm_blocking_peek_imp #( type IMP = virtual_class, type T = int )
  extends tlm_blocking_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_PEEK_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_nonblocking_get_imp
//----------------------------------------------------------------------

class tlm_nonblocking_peek_imp #( type IMP = virtual_class,
          type T = int )
  
  extends tlm_nonblocking_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `NONBLOCKING_PEEK_IMP( m_imp , T , t )

endclass

// get peek implementations

//----------------------------------------------------------------------
// CLASS tlm_get_peek_imp
//----------------------------------------------------------------------

class tlm_get_peek_imp #( type IMP = virtual_class, type T = int )
  extends tlm_get_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_GET_IMP( m_imp , T , t )
  `BLOCKING_PEEK_IMP( m_imp , T , t )

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )

endclass



//----------------------------------------------------------------------
// CLASS tlm_blocking_get_peek_imp
//----------------------------------------------------------------------

class tlm_blocking_get_peek_imp #( type IMP = virtual_class,
           type T = int )
  
  extends tlm_blocking_get_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `BLOCKING_GET_IMP( m_imp , T , t )
  `BLOCKING_PEEK_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS tlm_nonblocking_get_peek_imp
//----------------------------------------------------------------------

class tlm_nonblocking_get_peek_imp #( type IMP = virtual_class,
              type T = int )
  
  extends tlm_nonblocking_get_peek_if #( T );

  `WRAPPER_IMP( IMP )

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )

endclass

//----------------------------------------------------------------------
// CLASS blocking_master_imp
//
// blocking master implementation
//----------------------------------------------------------------------

class tlm_blocking_master_imp #( type REQ_IMP = virtual_class,
                                 type RSP_IMP = virtual_class,
                                 type REQ = int ,
                                 type RSP = int )
  extends tlm_blocking_master_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `BLOCKING_PUT_IMP( m_req_imp , REQ , req )
  `BLOCKING_GET_IMP( m_rsp_imp ,RSP , rsp )
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )

endclass

//----------------------------------------------------------------------
// CLASS nonblocking_master_imp
//
// nonblocking master implementation
//----------------------------------------------------------------------

class tlm_nonblocking_master_imp #( type REQ_IMP = virtual_class,
                                    type RSP_IMP = virtual_class,
                                    type REQ = int ,
                                    type RSP = int )
  extends tlm_nonblocking_master_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )

endclass

//----------------------------------------------------------------------
// CLASS master_imp
//
// master implementation
//----------------------------------------------------------------------

class tlm_master_imp #( type REQ_IMP = virtual_class,
                        type RSP_IMP = virtual_class,
                        type REQ = int ,
                        type RSP = int )
  extends tlm_master_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `BLOCKING_PUT_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , req )

  `BLOCKING_GET_IMP( m_rsp_imp ,RSP , rsp )
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )

endclass

//----------------------------------------------------------------------
// CLASS blocking_slave_imp
//
// blocking slave implementation
//----------------------------------------------------------------------

class tlm_blocking_slave_imp #( type REQ_IMP = virtual_class,
                                type RSP_IMP = virtual_class,
                                type REQ = int ,
                                type RSP = int )
  extends tlm_blocking_slave_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )
  `BLOCKING_GET_IMP( m_req_imp , REQ , req )
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , req )
 
endclass

//----------------------------------------------------------------------
// CLASS nonblocking_slave_imp
//
// nonblocking slave implementation
//----------------------------------------------------------------------

class tlm_nonblocking_slave_imp #( type REQ_IMP = virtual_class,
                                   type RSP_IMP = virtual_class,
                                   type REQ = int ,
                                   type RSP = int )
  extends tlm_nonblocking_slave_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_GET_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , req )

endclass

//----------------------------------------------------------------------
// CLASS slave_imp
//
// slave implementation
//----------------------------------------------------------------------

class tlm_slave_imp #( type REQ_IMP = virtual_class,
                       type RSP_IMP = virtual_class,
                       type REQ = int ,
                       type RSP = int )
  extends tlm_slave_if #( REQ , RSP );

  `REQ_RSP_WRAPPER_IMP( REQ_IMP , RSP_IMP )

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )

  `BLOCKING_GET_IMP( m_req_imp , REQ , req )
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_GET_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , req )

endclass

//----------------------------------------------------------------------
// CLASS transport_imp
//
// transport implementation
//----------------------------------------------------------------------

class tlm_transport_imp #( type IMP = virtual_class,
                           type REQ = int ,
                           type RSP = int )
  extends tlm_transport_if #( REQ , RSP );

  `WRAPPER_IMP( IMP )

  task transport( input REQ request , output RSP response );
    m_imp.transport( request , response );
  endtask

endclass

//----------------------------------------------------------------------
// CLASS analysis_imp
//
// analysis implementation
//----------------------------------------------------------------------

class analysis_imp #( type IMP = virtual_class, type T = int )
  extends analysis_if #( T );

  `WRAPPER_IMP( IMP )

  function void write( input T t );
    m_imp.write( t );
  endfunction

endclass
