// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/tlm/ovm_exports.svh#1 $
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


class ovm_blocking_put_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT , 
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_PUT_MASK;
    m_if_name = "tlm_blocking_put";

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass 

class ovm_nonblocking_put_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT , 
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_PUT_MASK;
    m_if_name = "tlm_nonblocking_put";

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class ovm_put_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_PUT_MASK;
    m_if_name = "tlm_put";

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class ovm_blocking_get_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_GET_MASK;
    m_if_name = "tlm_blocking_get";
 
  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class ovm_nonblocking_get_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_GET_MASK;
    m_if_name = "tlm_nonblocking_get";

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )

endclass

class ovm_get_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_GET_MASK;
    m_if_name = "tlm_get";

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class ovm_blocking_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_PEEK_MASK;
    m_if_name = "tlm_blocking_peek";
 
  endfunction
  
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class ovm_nonblocking_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_PEEK_MASK;
    m_if_name = "tlm_nonblocking_peek";

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class ovm_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_PEEK_MASK;
    m_if_name = "tlm_peek";

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class ovm_blocking_get_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_GET_PEEK_MASK;
    m_if_name = "tlm_blocking_get_peek";

  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class ovm_nonblocking_get_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_GET_PEEK_MASK;
    m_if_name = "tlm_nonblocking_get_peek";

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class ovm_get_peek_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_GET_PEEK_MASK;
    m_if_name = "tlm_get_peek";

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class ovm_blocking_master_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_MASTER_MASK;
    m_if_name = "tlm_blocking_master";

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , t ) // req

  `BLOCKING_GET_IMP( this.m_if , RSP , t ) // rsp
  `BLOCKING_PEEK_IMP( this.m_if , RSP , t ) // rsp

endclass 

class ovm_nonblocking_master_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_MASTER_MASK;
    m_if_name = "tlm_nonblocking_master";

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , t ) // req

  `NONBLOCKING_GET_IMP( this.m_if , RSP , t ) // rsp
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , t ) // rsp

endclass 


class ovm_master_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_MASTER_MASK;
    m_if_name = "tlm_master";

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , t ) // req
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , t ) // req

  `BLOCKING_GET_IMP( this.m_if , RSP , t ) // rsp
  `BLOCKING_PEEK_IMP( this.m_if , RSP , t ) // rsp
  `NONBLOCKING_GET_IMP( this.m_if , RSP , t ) // rsp
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , t ) // rsp

endclass

class ovm_blocking_slave_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_SLAVE_MASK;
    m_if_name = "tlm_blocking_slave";

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , t ) // rsp

  `BLOCKING_GET_IMP( this.m_if , REQ , t ) // req
  `BLOCKING_PEEK_IMP( this.m_if , REQ , t ) // req

endclass 

class ovm_nonblocking_slave_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_SLAVE_MASK;
    m_if_name = "tlm_nonblocking_slave";

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , t ) // rsp

  `NONBLOCKING_GET_IMP( this.m_if , REQ , t ) // req
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , t ) // req

endclass 

class ovm_slave_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_SLAVE_MASK;
    m_if_name = "tlm_slave";

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , t ) // rsp
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , t ) // rsp

  `BLOCKING_GET_IMP( this.m_if , REQ , t ) // req
  `BLOCKING_PEEK_IMP( this.m_if , REQ , t ) // req
  `NONBLOCKING_GET_IMP( this.m_if , REQ , t ) // req
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , t ) // req

endclass


class ovm_blocking_transport_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_BLOCKING_TRANSPORT_MASK;
    m_if_name = "tlm_blocking_transport";

  endfunction

  `BLOCKING_TRANSPORT_IMP( this.m_if, REQ, RSP, req, rsp)

endclass

class ovm_nonblocking_transport_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_NONBLOCKING_TRANSPORT_MASK;  
    m_if_name = "tlm_nonblocking_transport";

  endfunction

  `NONBLOCKING_TRANSPORT_IMP( this.m_if, REQ, RSP, req, rsp)

endclass

class ovm_transport_export #( type REQ = int , type RSP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );
  
  function new( string name , ovm_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       OVM_EXPORT ,
	       min_size , max_size );
    m_if_mask = `TLM_TRANSPORT_MASK;  
    m_if_name = "tlm_transport";

  endfunction

  `BLOCKING_TRANSPORT_IMP( this.m_if, REQ, RSP, req, rsp)
  `NONBLOCKING_TRANSPORT_IMP( this.m_if, REQ, RSP, req, rsp)

endclass

class ovm_analysis_export #( type T = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );
  
  function new( string name , ovm_component parent = null );
    
    // check parent is 0 to facilitate hybrid
    super.new( name , parent ,
	       OVM_EXPORT ,
	       1 , OVM_UNBOUNDED_CONNECTIONS );
    m_if_mask = `TLM_ANALYSIS_MASK;
    m_if_name = "tlm_analysis";

  endfunction

  //
  // analysis export differs from all other exports
  //
  // it broadcasts to ALL connections simultaneously, not one by one
  //
  
  function void write( input T t );
    tlm_if_base #( T, T ) tif;
  
    for( int i = 0; i < this.size(); i++ ) begin
      tif = this.lookup_indexed_if( i );
      assert( tif != null );
      tif.write( t );
    end 
  endfunction

endclass
