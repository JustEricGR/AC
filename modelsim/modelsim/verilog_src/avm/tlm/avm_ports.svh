// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/avm_ports.svh#1 $
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
// These classes REQUIRE a number of identical tlm interfaces for use in 
// some IP
//
// For each tlm interface, there is a corresponding avm_<if>_port.
//
// They all inherit from avm_port_base< if > and implement if
//
// They implement if so that we can do things like p.put( t ),
// p.get( p ) and p.peek( p ).
//
// In the case of a multiport, we need to use lookup_indexed_if eg :
//
// p.lookup_indexed_if( 3 ).put( t );
//

class avm_blocking_put_port #( type T = int )
  extends avm_port_base #( tlm_blocking_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT , 
	       min_size , max_size );
    
  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_put_port #( type T = int )
  extends avm_port_base #( tlm_nonblocking_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT , 
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class avm_put_port #( type T = int )
  extends avm_port_base #( tlm_put_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , T , t )
  `BLOCKING_PUT_IMP( this.m_if , T , t )

endclass

class avm_blocking_get_port #( type T = int )
  extends avm_port_base #( tlm_blocking_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );
 
  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_get_port #( type T = int )
  extends avm_port_base #( tlm_nonblocking_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )

endclass

class avm_get_port #( type T = int )
  extends avm_port_base #( tlm_get_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )

endclass 

class avm_blocking_peek_port #( type T = int )
  extends avm_port_base #( tlm_blocking_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );
 
  endfunction
  
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_peek_port #( type T = int )
  extends avm_port_base #( tlm_nonblocking_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class avm_peek_port #( type T = int )
  extends avm_port_base #( tlm_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 


class avm_blocking_get_peek_port #( type T = int )
  extends avm_port_base #( tlm_blocking_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_nonblocking_get_peek_port #( type T = int )
  extends avm_port_base #( tlm_nonblocking_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )

endclass

class avm_get_peek_port #( type T = int )
  extends avm_port_base #( tlm_get_peek_if #( T ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_GET_IMP( this.m_if , T , t )
  `BLOCKING_GET_IMP( this.m_if , T , t )
  
  `NONBLOCKING_PEEK_IMP( this.m_if , T , t )
  `BLOCKING_PEEK_IMP( this.m_if , T , t )

endclass 

class avm_blocking_master_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_blocking_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , req )

  `BLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `BLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass 

class avm_nonblocking_master_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_nonblocking_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );

    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , req )

  `NONBLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass 


class avm_master_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_master_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PUT_IMP( this.m_if , REQ , req )

  `BLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `BLOCKING_PEEK_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_GET_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( this.m_if , RSP , rsp )

endclass

class avm_blocking_slave_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_blocking_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `BLOCKING_GET_IMP( this.m_if , REQ , req )
  `BLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass 

class avm_nonblocking_slave_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_nonblocking_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `NONBLOCKING_GET_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass 

class avm_slave_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_slave_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction
  
  `BLOCKING_PUT_IMP( this.m_if , RSP , rsp )
  `NONBLOCKING_PUT_IMP( this.m_if , RSP , rsp )

  `BLOCKING_GET_IMP( this.m_if , REQ , req )
  `BLOCKING_PEEK_IMP( this.m_if , REQ , req )
  `NONBLOCKING_GET_IMP( this.m_if , REQ , req )
  `NONBLOCKING_PEEK_IMP( this.m_if , REQ , req )

endclass


class avm_transport_port #( type REQ = int , type RSP = int )
  extends avm_port_base #( tlm_transport_if #( REQ , RSP ) );
  
  function new( string name , avm_named_component parent ,
		int min_size = 1 , int max_size = 1 );
    
    super.new( name , parent ,
	       AVM_PORT ,
	       min_size , max_size );

  endfunction

  task transport( input REQ request , output RSP response );
    this.m_if.transport( request , response );
  endtask

endclass


class avm_analysis_port #( type T = int )
  extends avm_port_base #( analysis_if #( T ) );

  typedef avm_port_base #( analysis_if #( T ) ) port_type;

  //
  // You must specify a parent - there is no default value
  //
  // In modules, the parent must be null
  //
  
  function new( string name , avm_named_component parent );
    
    // check parent is 0 to facilitate hybrid
    super.new( name , parent ,
	       AVM_PORT ,
	       0 , AVM_UNBOUNDED_CONNECTIONS , 0 );

  endfunction

  //
  // analysis port differs from all other ports
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

  // for backwards compatibility with 2.0
  function void register( analysis_if #( T ) _if );
    connect_to_if( _if );
  endfunction

  virtual function void connect( port_type provider );
    string s;

    if( m_connector.m_env != null || m_connector.is_removed() ) begin
      // if we're in a avm_env, do the connect normally
      super.connect( provider );
      return;
    end

    // otherwise, we register the provider itself    
    
    if( !m_connector.check_types( provider.m_connector ) ) begin
    
      $sformat( s , "Cannot connect %s to %s" ,
		m_connector.m_name , provider.m_connector.m_name );
 
      m_connector.avm_report_error( s_connection_error_id , s );
      
      // unless action assoiated with s_connection_error_id determines
      // otherwise, make best attempt to complete connection
      
    end
  
    connect_to_if( provider );
    m_connector.update_connection_lists( provider.m_connector );
  
    m_if = null;

  endfunction
    
endclass
