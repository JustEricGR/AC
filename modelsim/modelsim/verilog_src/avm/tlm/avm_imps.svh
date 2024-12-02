
// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/avm_imps.svh#1 $
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



class avm_blocking_put_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_blocking_put_if #( T ) );

  local IMP m_imp;
  local tlm_blocking_put_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class avm_nonblocking_put_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_nonblocking_put_if #( T ) );

  local IMP m_imp;
  local tlm_nonblocking_put_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class avm_put_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_put_if #( T ) );

  local IMP m_imp;
  local tlm_put_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PUT_IMP( m_imp , T , t )
  `NONBLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class avm_blocking_get_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_blocking_get_if #( T ) );

  local IMP m_imp;
  local tlm_blocking_get_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class avm_nonblocking_get_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_nonblocking_get_if #( T ) );

  local IMP m_imp;
  local tlm_nonblocking_get_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class avm_get_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_get_if #( T ) );

  local IMP m_imp;
  local tlm_get_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class avm_blocking_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_blocking_peek_if #( T ) );

  local IMP m_imp;
  local tlm_blocking_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class avm_nonblocking_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_nonblocking_peek_if #( T ) );

  local IMP m_imp;
  local tlm_nonblocking_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class avm_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_peek_if #( T ) );

  local IMP m_imp;
  local tlm_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PEEK_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass


class avm_blocking_get_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_blocking_get_peek_if #( T ) );

  local IMP m_imp;
  local tlm_blocking_get_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  `BLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class avm_nonblocking_get_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_nonblocking_get_peek_if #( T ) );

  local IMP m_imp;
  local tlm_nonblocking_get_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class avm_get_peek_imp #( type T = int , type IMP = int )
  extends avm_port_base #( tlm_get_peek_if #( T ) );

  local IMP m_imp;
  local tlm_get_peek_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_GET_IMP( m_imp , T , t )
    
   `BLOCKING_PEEK_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

//
// All the master and slave imps have two modes of operation.
//
// The first could be described as normal but unusual. In other words
// it fits the pattern of the other imps but in practise is unusual.
//
// This is when there is a single class ( type IMP ) that implements the
// entire interface, and imp -= req_imp == rsp_imp.
//
// The reason this is unusual is that we do not have C++ style name
// mangling in SV, so such a channel will not be able to implement both
// a master and a slave interface, even if REQ != RSP
//
// The abnormal but more usual pattern is where two siblings implement
// the request and response methods. In this case req_imp and rsp_imp
// are children of imp, as is the implementation itself.
//
// This second pattern is used in tlm_req_rsp_channel etc.
//


class avm_blocking_master_imp #( type REQ = int , type RSP = int ,
				 type IMP = int ,
				 type REQ_IMP = IMP ,
				 type RSP_IMP = IMP )
  extends avm_port_base #( tlm_blocking_master_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_blocking_master_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_req_imp , REQ , req )

  `BLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )
  
endclass

class avm_nonblocking_master_imp #( type REQ = int , type RSP = int ,
				    type IMP = int ,
				    type REQ_IMP = IMP ,
				    type RSP_IMP = IMP )
  
  extends avm_port_base #( tlm_nonblocking_master_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_nonblocking_master_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , req )

  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )
  
endclass

class avm_master_imp #( type REQ = int , type RSP = int ,
			type IMP = int ,
			type REQ_IMP = IMP , type RSP_IMP = IMP )
  extends avm_port_base #( tlm_master_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_master_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , req )

  `BLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , rsp )
   
endclass

class avm_blocking_slave_imp #( type REQ = int , type RSP = int ,
				type IMP = int ,
				type REQ_IMP = IMP ,
				type RSP_IMP = IMP )
  
  extends avm_port_base #( tlm_blocking_slave_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_blocking_slave_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )

  `BLOCKING_GET_IMP( m_req_imp , REQ , req )
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , req )
  
endclass

class avm_nonblocking_slave_imp #( type REQ = int , type RSP = int ,
				   type IMP = int ,
				   type REQ_IMP = IMP ,
				   type RSP_IMP = IMP )
  
  extends avm_port_base #( tlm_nonblocking_slave_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_nonblocking_slave_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )

  `NONBLOCKING_GET_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , req )
  
endclass

class avm_slave_imp #( type REQ = int , type RSP = int ,
		       type IMP = int ,
		       type REQ_IMP = IMP , type RSP_IMP = IMP )
  extends avm_port_base #( tlm_slave_if #( REQ , RSP ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

  local tlm_slave_if #( REQ , RSP ) m_if;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = imp , RSP_IMP rsp_imp = imp );
     super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )
  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , rsp )

  `BLOCKING_GET_IMP( m_req_imp , REQ , req )
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_GET_IMP( m_req_imp , REQ , req )
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , req )
   
endclass

class avm_transport_imp #( type REQ = int ,
			   type RSP = int , type IMP = int )
  extends avm_port_base #( tlm_transport_if #( REQ , RSP ) );

  local IMP m_imp;
  local tlm_transport_if #( REQ , RSP ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  task transport( input REQ request , output RSP response );
    m_imp.transport( request , response );
  endtask
  
endclass

class avm_analysis_imp #( type T = int , type IMP = int )
  extends avm_port_base #( analysis_if #( T ) );

  local IMP m_imp;
  local analysis_if #( T ) m_if;
 
  function new( string name , IMP imp );
    super.new( name , imp , AVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  function void write( input T t );
    m_imp.write( t );
  endfunction
  
endclass
