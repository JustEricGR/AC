// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/avm_exports.svh#1 $
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
// These classes PROVIDE a number of identical tlm interfaces for use in
// a port. 
//
// For each tlm interface, there is a corresponding avm_<if>_export.
//
// They all inherit from avm_port_base< if > and implement if
//
// They implement if primarilly to support backward compatibility with
// AVM 2.0
//

class avm_blocking_put_export #( type T = int )
  extends avm_port_base #( tlm_blocking_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT , 
	       min_size , max_size );
    
  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_put_export #( type T = int )
  extends avm_port_base #( tlm_nonblocking_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT , 
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class avm_put_export #( type T = int )
  extends avm_port_base #( tlm_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class avm_blocking_get_export #( type T = int )
  extends avm_port_base #( tlm_blocking_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );
 
  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_get_export #( type T = int )
  extends avm_port_base #( tlm_nonblocking_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )

endclass

class avm_get_export #( type T = int )
  extends avm_port_base #( tlm_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class avm_blocking_peek_export #( type T = int )
  extends avm_port_base #( tlm_blocking_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );
 
  endfunction
  
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_peek_export #( type T = int )
  extends avm_port_base #( tlm_nonblocking_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class avm_peek_export #( type T = int )
  extends avm_port_base #( tlm_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_blocking_get_peek_export #( type T = int )
  extends avm_port_base #( tlm_blocking_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_get_peek_export #( type T = int )
  extends avm_port_base #( tlm_nonblocking_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class avm_get_peek_export #( type T = int )
  extends avm_port_base #( tlm_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_blocking_master_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_blocking_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , req )

  `BLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `BLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass 

class avm_nonblocking_master_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_nonblocking_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , req )

  `NONBLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass 


class avm_master_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , req )

  `BLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `BLOCKING_PEEK_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass

class avm_blocking_slave_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_blocking_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `BLOCKING_GET_IMP( this.m_if , REQ , req )
  `BLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass 

class avm_nonblocking_slave_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_nonblocking_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `NONBLOCKING_GET_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass 

class avm_slave_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `BLOCKING_GET_IMP( this.m_if , REQ , req )
  `BLOCKING_PEEK_IMP( this.m_if , REQ , req )
  `NONBLOCKING_GET_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass


class avm_transport_export #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_transport_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_EXPORT ,
	       min_size , max_size );

  endfunction

  task transport( input REQ request , output RSP response );
    this.m_if.transport( request , response );
  endtask

endclass

class avm_analysis_export #( type T = int )
  extends avm_port_base #( analysis_if #( T ) );
  
  function new( string name , avm_named_component parent = null );
    
    // check parent is 0 to facilitate hybrid
    super.new( name , parent ,
	       AVM_EXPORT ,
	       1 , AVM_UNBOUNDED_CONNECTIONS , 0 );

  endfunction

  //
  // analysis export differs from all other exports
  //
  // it broadcasts to ALL connections simultaneously, not one by one
  //
  
  function void write( input T t );
    analysis_if #( T ) tif;
  
    for( int i = 0; i < this.size(); i++ ) begin
      tif = this.lookup_indexed_if( i );
      assert( tif != null );
      tif.write( t );
    end 
  endfunction

endclass
