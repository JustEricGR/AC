// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/tlm/tlm_ifs.svh#1 $
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
// TLM Interfaces
//

// The unidirectional  TLM interfaces are divided into put, get and peek
// interfaces, and blocking, nonblocking and combined interfaces.
// 
// A blocking call always succeeds, but may need to consume time to do
// so. As a result, these  methods must be tasks
//
// A nonblocking call may not suceed, but consumes no time. As a result,
// these methods are functions.
//
// The difference between get and peek is that get consumes the data
// while peek does not. So successive calls to peek within the same
// delta cycle are guaranteed to return the same value.
//
// The transport interface is a bidirectional blocking interface used
// when the request and response are tightly coupled in a one to one
// relationship.

`define TASK_ERROR "TLM interface task not implemented"
`define FUNCTION_ERROR "TLM interface function not implemented"

virtual class tlm_if_base #(type T1=int, type T2=int) extends ovm_report_object;

  virtual task put( input T1 t );
    ovm_report_error("put", `TASK_ERROR);
  endtask

  virtual task get( output T2 t );
    ovm_report_error("get", `TASK_ERROR);
  endtask

  virtual task peek( output T2 t );
    ovm_report_error("peek", `TASK_ERROR);
  endtask

  virtual function bit try_put( input T1 t );
    ovm_report_error("try_put", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function bit can_put();
    ovm_report_error("can_put", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function bit try_get( output T2 t );
    ovm_report_error("try_get", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function bit can_get();
    ovm_report_error("can_get", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function bit try_peek( output T2 t );
    ovm_report_error("try_peek", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function bit can_peek();
    ovm_report_error("can_ppeek", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual task transport( input T1 req , output T2 rsp );
    ovm_report_error("transport", `TASK_ERROR);
  endtask

  virtual function bit nb_transport(input T1 req, output T2 rsp);
    ovm_report_error("nb_transport", `FUNCTION_ERROR);
    return 0;
  endfunction

  virtual function void write( input T1 t );
    ovm_report_error("write", `FUNCTION_ERROR);
  endfunction

endclass

// blocking interfaces

virtual class tlm_blocking_put_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task put( input T t );   endtask
endclass
`define TLM_BLOCKING_PUT_MASK (1<<0)

virtual class tlm_blocking_get_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task get( output T t );  endtask
endclass
`define TLM_BLOCKING_GET_MASK (1<<1)

virtual class tlm_blocking_peek_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task peek( output T t );  endtask
endclass
`define TLM_BLOCKING_PEEK_MASK (1<<2)

virtual class tlm_blocking_get_peek_if #( type T = int ) extends tlm_if_base #(T, T);
   virtual task get( output T t );   endtask
   virtual task peek( output T t );  endtask
endclass
`define TLM_BLOCKING_GET_PEEK_MASK (`TLM_BLOCKING_GET_MASK | `TLM_BLOCKING_PEEK_MASK)

// non blocking interfaces

virtual class tlm_nonblocking_put_if #( type T = int ) extends tlm_if_base #(T, T);
virtual function bit try_put( input T t ); return 0; endfunction
  virtual function bit can_put();          return 0; endfunction
endclass
`define TLM_NONBLOCKING_PUT_MASK (1<<3)

virtual class tlm_nonblocking_get_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual function bit try_get( output T t ); return 0; endfunction
virtual function bit can_get();             return 0; endfunction
endclass
`define TLM_NONBLOCKING_GET_MASK (1<<4)

virtual class tlm_nonblocking_peek_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual function bit try_peek( output T t ); return 0; endfunction
  virtual function bit can_peek();             return 0; endfunction
endclass
`define TLM_NONBLOCKING_PEEK_MASK (1<<5)

virtual class tlm_nonblocking_get_peek_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual function bit try_get( output T t );  return 0; endfunction
  virtual function bit can_get();              return 0; endfunction
  virtual function bit try_peek( output T t ); return 0; endfunction
  virtual function bit can_peek();             return 0; endfunction
endclass
`define TLM_NONBLOCKING_GET_PEEK_MASK (`TLM_NONBLOCKING_GET_MASK | `TLM_NONBLOCKING_GET_MASK)

// combined interfaces

virtual class tlm_put_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task put( input T t );             endtask
  virtual function bit try_put( input T t ); return 0; endfunction
  virtual function bit can_put();            return 0; endfunction
endclass
`define TLM_PUT_MASK (`TLM_BLOCKING_PUT_MASK | `TLM_NONBLOCKING_PUT_MASK)

virtual class tlm_get_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task get( output T t );             endtask
  virtual function bit try_get( output T t ); return 0; endfunction
  virtual function bit can_get();             return 0; endfunction
endclass
`define TLM_GET_MASK (`TLM_BLOCKING_GET_MASK | `TLM_NONBLOCKING_GET_MASK)

virtual class tlm_peek_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task peek( output T t );             endtask
  virtual function bit try_peek( output T t ); return 0; endfunction
  virtual function bit can_peek();             return 0; endfunction
endclass
`define TLM_PEEK_MASK (`TLM_BLOCKING_PEEK_MASK | `TLM_NONBLOCKING_PEEK_MASK)

virtual class tlm_get_peek_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual task get( output T t );             endtask
  virtual function bit try_get( output T t ); return 0; endfunction
  virtual function bit can_get();             return 0; endfunction

  virtual task peek( output T t );  endtask
  virtual function bit try_peek( output T t ); return 0; endfunction
  virtual function bit can_peek(); return 0; endfunction
endclass
`define TLM_GET_PEEK_MASK (`TLM_GET_MASK | `TLM_PEEK_MASK)

// bidirectional interfaces

virtual class tlm_blocking_master_if #( type REQ = int ,
          type RSP = int ) extends tlm_if_base #(REQ, RSP);
  
  virtual task put( input REQ t );  endtask
  virtual task get( output RSP t );  endtask
  virtual task peek( output RSP t  );  endtask
endclass
`define TLM_BLOCKING_MASTER_MASK (`TLM_BLOCKING_GET_MASK | `TLM_BLOCKING_GET_MASK | `TLM_BLOCKING_PEEK_MASK)

virtual class tlm_nonblocking_master_if #( type REQ = int,  type RSP = int )
  extends tlm_if_base #(REQ, RSP);
  
  virtual function bit try_put( input REQ t ); return 0; endfunction
  virtual function bit can_put(); return 0; endfunction

  virtual function bit try_get( output RSP t ); return 0; endfunction
  virtual function bit can_get(); return 0; endfunction

  virtual function bit try_peek( output RSP t ); return 0; endfunction
  virtual function bit can_peek(); return 0; endfunction
endclass
`define TLM_NONBLOCKING_MASTER_MASK (`TLM_NONBLOCKING_GET_MASK | `TLM_NONBLOCKING_GET_MASK | `TLM_NONBLOCKING_PEEK_MASK)

virtual class tlm_master_if #( type REQ = int , type RSP = int )
  extends tlm_if_base #(REQ, RSP);

  virtual task put( REQ t );           endtask
  virtual function bit try_put( REQ t ); return 0; endfunction
  virtual function bit can_put(); return 0; endfunction

  virtual task get( output RSP t );                   endtask
  virtual function bit try_get( output RSP t ); return 0; endfunction
  virtual function bit can_get(); return 0; endfunction

  virtual task peek( output RSP t  );                 endtask
  virtual function bit try_peek( output RSP t ); return 0; endfunction
  virtual function bit can_peek(); return 0; endfunction
endclass
`define TLM_MASTER_MASK (`TLM_BLOCKING_MASTER_MASK | `TLM_NONBLOCKING_MASTER_MASK)

virtual class tlm_blocking_slave_if #( type REQ = int ,
               type RSP = int ) extends tlm_if_base #(RSP, REQ);
  
  virtual task put( RSP t );           endtask
  virtual task get( output REQ t );    endtask
  virtual task peek( output REQ t  );  endtask
endclass
`define TLM_BLOCKING_SLAVE_MASK (`TLM_BLOCKING_GET_MASK | `TLM_BLOCKING_GET_MASK | `TLM_BLOCKING_PEEK_MASK)

virtual class tlm_nonblocking_slave_if #( type REQ = int ,
                                          type RSP = int )
  extends tlm_if_base #(RSP, REQ);
  
  virtual function bit try_put( RSP t ); return 0; endfunction
  virtual function bit can_put(); return 0; endfunction

  virtual function bit try_get( output REQ t ); return 0; endfunction
  virtual function bit can_get(); return 0; endfunction

  virtual function bit try_peek( output REQ t ); return 0; endfunction
  virtual function bit can_peek(); return 0; endfunction
endclass
`define TLM_NONBLOCKING_SLAVE_MASK (`TLM_NONBLOCKING_GET_MASK | `TLM_NONBLOCKING_GET_MASK | `TLM_NONBLOCKING_PEEK_MASK)

virtual class tlm_slave_if #( type REQ = int ,
                              type RSP = int )
  extends tlm_if_base #(RSP, REQ);
  
  virtual task put( input RSP t );  endtask
  virtual function bit try_put( input RSP t ); return 0; endfunction
  virtual function bit can_put(); return 0; endfunction

  virtual task get( output REQ t );  endtask
  virtual function bit try_get( output REQ t ); return 0; endfunction
  virtual function bit can_get(); return 0; endfunction

  virtual task peek( output REQ t  );  endtask
  virtual function bit try_peek( output REQ t ); return 0; endfunction
  virtual function bit can_peek(); return 0; endfunction
endclass
`define TLM_SLAVE_MASK (`TLM_BLOCKING_MASTER_MASK | `TLM_NONBLOCKING_MASTER_MASK)

virtual class tlm_blocking_transport_if #( type REQ = int , type RSP = int )
  extends tlm_if_base #(REQ, RSP);
  
  virtual task transport( input REQ request, output RSP response );
  endtask

endclass
`define TLM_BLOCKING_TRANSPORT_MASK (1<<6)

virtual class tlm_nonblocking_transport_if #( type REQ = int , type RSP = int )
  extends tlm_if_base #(REQ, RSP);
  
  virtual function bit nb_transport( input REQ req, output RSP rsp );
    return 0;
  endfunction

endclass
`define TLM_NONBLOCKING_TRANSPORT_MASK (1<<7)

virtual class tlm_transport_if #( type REQ = int , type RSP = int )
  extends tlm_if_base #(REQ, RSP);
  
  virtual task transport( input REQ req, output RSP rsp );
  endtask

  virtual function bit nb_transport( input REQ req, output RSP rsp );
    return 0;
  endfunction

endclass
`define TLM_TRANSPORT_MASK (`TLM_BLOCKING_TRANSPORT_MASK | `TLM_NONBLOCKING_TRANSPORT_MASK)

// The analysis interface allows no negotiation on the part of the
// implementor of the write method.
//
// The implementor must implement write, and implement it with no waits
// since it is a function.
//
// The analysis interface is used in analysis_port to connect monitors
// to scoreboards and coverage objects

virtual class analysis_if #( type T = int ) extends tlm_if_base #(T, T);
  virtual function void write( input T t ); endfunction
endclass
`define TLM_ANALYSIS_MASK (1<<7)

