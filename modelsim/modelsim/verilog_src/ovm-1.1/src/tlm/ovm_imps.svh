// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/tlm/ovm_imps.svh#1 $
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

class ovm_blocking_put_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_BLOCKING_PUT_MASK;
    m_if_name = "tlm_blocking_put";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class ovm_nonblocking_put_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_NONBLOCKING_PUT_MASK;
    m_if_name = "tlm_nonblocking_put";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class ovm_put_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_PUT_MASK;
    m_if_name = "tlm_put";
    assert( this.m_connector.add_if( m_if ) );
endfunction

  `BLOCKING_PUT_IMP( m_imp , T , t )
  `NONBLOCKING_PUT_IMP( m_imp , T , t )
  
endclass

class ovm_blocking_get_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_BLOCKING_GET_MASK;
    m_if_name = "tlm_blocking_get";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class ovm_nonblocking_get_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_NONBLOCKING_GET_MASK;
    m_if_name = "tlm_nonblocking_get";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class ovm_get_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_GET_MASK;
    m_if_name = "tlm_get";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_GET_IMP( m_imp , T , t )
  
endclass

class ovm_blocking_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_BLOCKING_PEEK_MASK;
    m_if_name = "tlm_blocking_peek";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class ovm_nonblocking_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_NONBLOCKING_PEEK_MASK;
    m_if_name = "tlm_nonblocking_peek";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class ovm_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_PEEK_MASK;
    m_if_name = "tlm_peek";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_PEEK_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass


class ovm_blocking_get_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_BLOCKING_GET_PEEK_MASK;
    m_if_name = "tlm_blocking_get_peek";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_GET_IMP( m_imp , T , t )
  `BLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class ovm_nonblocking_get_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_NONBLOCKING_GET_PEEK_MASK;
    m_if_name = "tlm_nonblocking_get_peek";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_GET_IMP( m_imp , T , t )
  `NONBLOCKING_PEEK_IMP( m_imp , T , t )
  
endclass

class ovm_get_peek_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_GET_PEEK_MASK;
    m_if_name = "tlm_get_peek";
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


class ovm_blocking_master_imp #( type REQ = int , type RSP = int ,
				 type IMP = int ,
				 type REQ_IMP = IMP ,
				 type RSP_IMP = IMP )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;


   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
    m_if_mask = `TLM_BLOCKING_MASTER_MASK;
    m_if_name = "tlm_blocking_master";
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_req_imp , REQ , t ) // req

  `BLOCKING_GET_IMP( m_rsp_imp , RSP , t ) // rsp
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , t ) // rsp
  
endclass

class ovm_nonblocking_master_imp #( type REQ = int , type RSP = int ,
				    type IMP = int ,
				    type REQ_IMP = IMP ,
				    type RSP_IMP = IMP )
  
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
     
    m_if_mask = `TLM_NONBLOCKING_MASTER_MASK;
    m_if_name = "tlm_nonblocking_master";
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , t ) // req

  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , t ) // rsp
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , t ) // rsp
  
endclass

class ovm_master_imp #( type REQ = int , type RSP = int ,
			type IMP = int ,
			type REQ_IMP = IMP , type RSP_IMP = IMP )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
    m_if_mask = `TLM_MASTER_MASK;
    m_if_name = "tlm_master";
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_req_imp , REQ , t ) // req
  `NONBLOCKING_PUT_IMP( m_req_imp , REQ , t ) // req

  `BLOCKING_GET_IMP( m_rsp_imp , RSP , t ) // rsp
  `BLOCKING_PEEK_IMP( m_rsp_imp , RSP , t ) // rsp
  `NONBLOCKING_GET_IMP( m_rsp_imp , RSP , t ) // rsp
  `NONBLOCKING_PEEK_IMP( m_rsp_imp , RSP , t ) // rsp
   
endclass

class ovm_blocking_slave_imp #( type REQ = int , type RSP = int ,
				type IMP = int ,
				type REQ_IMP = IMP ,
				type RSP_IMP = IMP )
  
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
    m_if_mask = `TLM_BLOCKING_SLAVE_MASK;
    m_if_name = "tlm_blocking_slave";
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , t ) // rsp

  `BLOCKING_GET_IMP( m_req_imp , REQ , t ) // req
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , t ) // req
  
endclass

class ovm_nonblocking_slave_imp #( type REQ = int , type RSP = int ,
				   type IMP = int ,
				   type REQ_IMP = IMP ,
				   type RSP_IMP = IMP )
  
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
    m_if_mask = `TLM_NONBLOCKING_SLAVE_MASK;
    m_if_name = "tlm_nonblocking_slave";
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , t ) // rsp

  `NONBLOCKING_GET_IMP( m_req_imp , REQ , t ) // req
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , t ) // req
  
endclass

class ovm_slave_imp #( type REQ = int , type RSP = int ,
		       type IMP = int ,
		       type REQ_IMP = IMP , type RSP_IMP = IMP )
  extends ovm_port_base #( tlm_if_base #(RSP, REQ) );

  local REQ_IMP m_req_imp;
  local RSP_IMP m_rsp_imp;

   function new( string name , IMP imp ,
		 REQ_IMP req_imp = null , RSP_IMP rsp_imp = null );
     super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
     if(req_imp==null) $cast(req_imp, imp);
     if(rsp_imp==null) $cast(rsp_imp, imp);
     
     m_if = this;
     m_req_imp = req_imp;
     m_rsp_imp = rsp_imp;
    m_if_mask = `TLM_SLAVE_MASK;
    m_if_name = "tlm_slave";
     
    assert( this.m_connector.add_if( m_if ) );
  endfunction 

  `BLOCKING_PUT_IMP( m_rsp_imp , RSP , t ) // rsp
  `NONBLOCKING_PUT_IMP( m_rsp_imp , RSP , t ) // rsp

  `BLOCKING_GET_IMP( m_req_imp , REQ , t ) // req
  `BLOCKING_PEEK_IMP( m_req_imp , REQ , t ) // req
  `NONBLOCKING_GET_IMP( m_req_imp , REQ , t ) // req
  `NONBLOCKING_PEEK_IMP( m_req_imp , REQ , t ) // req
   
endclass

class ovm_blocking_transport_imp #( type REQ = int ,
                                    type RSP = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_BLOCKING_TRANSPORT_MASK;
    m_if_name = "tlm_blocking_transport";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_TRANSPORT_IMP( m_imp, REQ, RSP, req, rsp)
  
endclass

class ovm_nonblocking_transport_imp #( type REQ = int ,
                                       type RSP = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_NONBLOCKING_TRANSPORT_MASK;
    m_if_name = "tlm_nonblocking_transport";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `NONBLOCKING_TRANSPORT_IMP( m_imp, REQ, RSP, req, rsp)
  
endclass

class ovm_transport_imp #( type REQ = int ,
                           type RSP = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(REQ, RSP) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_TRANSPORT_MASK;
    m_if_name = "tlm_transport";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  `BLOCKING_TRANSPORT_IMP( m_imp, REQ, RSP, req, rsp)
  `NONBLOCKING_TRANSPORT_IMP( m_imp, REQ, RSP, req, rsp)
  
endclass

class ovm_analysis_imp #( type T = int , type IMP = int )
  extends ovm_port_base #( tlm_if_base #(T,T) );

  local IMP m_imp;
 
  function new( string name , IMP imp );
    super.new( name , imp , OVM_IMPLEMENTATION , 1 , 1 );
    
    m_if = this;
    m_imp = imp;
    m_if_mask = `TLM_ANALYSIS_MASK;
    m_if_name = "tlm_analysis";
    assert( this.m_connector.add_if( m_if ) );
  endfunction

  function void write( input T t );
    m_imp.write( t );
  endfunction
  
endclass
