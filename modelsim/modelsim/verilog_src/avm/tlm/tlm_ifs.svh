// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/tlm_ifs.svh#1 $
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

// blocking interfaces

//begin codeblock virtual_if
virtual class tlm_blocking_put_if #( type T = int );
  pure virtual task put( input T t );
endclass

virtual class tlm_blocking_get_if #( type T = int );
  pure virtual task get( output T t );
endclass

virtual class tlm_blocking_peek_if #( type T = int );
  pure virtual task peek( output T t );
endclass

virtual class tlm_blocking_get_peek_if #( type T = int );
   pure virtual task get( output T t );
   pure virtual task peek( output T t );
endclass
//end codeblock virtual_if caption path

// non blocking interfaces

virtual class tlm_nonblocking_put_if #( type T = int );
  pure virtual function bit try_put( input T t );
  pure virtual function bit can_put();
endclass

virtual class tlm_nonblocking_get_if #( type T = int );
  pure virtual function bit try_get( output T t );
  pure virtual function bit can_get();
endclass

virtual class tlm_nonblocking_peek_if #( type T = int );
  pure virtual function bit try_peek( output T t );
  pure virtual function bit can_peek();
endclass

virtual class tlm_nonblocking_get_peek_if #( type T = int );
  pure virtual function bit try_get( output T t );
  pure virtual function bit can_get();
  pure virtual function bit try_peek( output T t );
  pure virtual function bit can_peek();
endclass

// combined interfaces

virtual class tlm_put_if #( type T = int );
  pure virtual task put( input T t );
  pure virtual function bit try_put( input T t );
  pure virtual function bit can_put();
endclass

virtual class tlm_get_if #( type T = int );
  pure virtual task get( output T t );
  pure virtual function bit try_get( output T t );
  pure virtual function bit can_get();
endclass

virtual class tlm_peek_if #( type T = int );
  pure virtual task peek( output T t );
  pure virtual function bit try_peek( output T t );
  pure virtual function bit can_peek();
endclass

virtual class tlm_get_peek_if #( type T = int );
  pure virtual task get( output T t );
  pure virtual function bit try_get( output T t );
  pure virtual function bit can_get();

  pure virtual task peek( output T t );
  pure virtual function bit try_peek( output T t );
  pure virtual function bit can_peek();
endclass

// bidirectional interfaces

virtual class tlm_blocking_master_if #( type REQ = int ,
          type RSP = int );
  
  pure virtual task put( input REQ req );
  pure virtual task get( output RSP rsp );
  pure virtual task peek( output RSP rsp  );
endclass

virtual class tlm_nonblocking_master_if #( type REQ = int ,
             type RSP = int );
  
  pure virtual function bit try_put( input REQ req );
  pure virtual function bit can_put();

  pure virtual function bit try_get( output RSP rsp );
  pure virtual function bit can_get();

  pure virtual function bit try_peek( output RSP rsp );
  pure virtual function bit can_peek();
endclass

virtual class tlm_master_if #( type REQ = int , type RSP = int );
  pure virtual task put( REQ req );
  pure virtual function bit try_put( REQ req );
  pure virtual function bit can_put();

  pure virtual task get( output RSP rsp );
  pure virtual function bit try_get( output RSP rsp );
  pure virtual function bit can_get();

  pure virtual task peek( output RSP rsp  );
  pure virtual function bit try_peek( output RSP rsp );
  pure virtual function bit can_peek();
endclass

virtual class tlm_blocking_slave_if #( type REQ = int ,
               type RSP = int );
  
  pure virtual task put( RSP rsp );
  pure virtual task get( output REQ req );
  pure virtual task peek( output REQ req  );
endclass

virtual class tlm_nonblocking_slave_if #( type REQ = int ,
            type RSP = int );
  
  pure virtual function bit try_put( RSP rsp );
  pure virtual function bit can_put();

  pure virtual function bit try_get( output REQ req );
  pure virtual function bit can_get();

  pure virtual function bit try_peek( output REQ req );
  pure virtual function bit can_peek();
endclass

virtual class tlm_slave_if #( type REQ = int ,
            type RSP = int );
  
  pure virtual task put( input RSP rsp );
  pure virtual function bit try_put( input RSP rsp );
  pure virtual function bit can_put();

  pure virtual task get( output REQ req );
  pure virtual function bit try_get( output REQ req );
  pure virtual function bit can_get();

  pure virtual task peek( output REQ req  );
  pure virtual function bit try_peek( output REQ req );
  pure virtual function bit can_peek();
endclass

virtual class tlm_transport_if #( type REQ = int , type RSP = int );
  
  pure virtual task transport( input REQ request ,
                               output RSP response );

endclass

// The analysis interface allows no negotiation on the part of the
// implementor of the write method.
//
// The implementor must implement write, and implement it with no waits
// since it is a function.
//
// The analysis interface is used in analysis_port to connect monitors
// to scoreboards and coverage objects

virtual class analysis_if #( type T = int );
  pure virtual function void write( input T t );
endclass

