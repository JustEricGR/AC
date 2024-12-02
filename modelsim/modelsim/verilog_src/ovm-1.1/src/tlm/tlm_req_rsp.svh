// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/tlm/tlm_req_rsp.svh#1 $
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

// This file contains the two bidirectional tlm channels

//+ tlm_req_rsp_channel contains a request fifo and a response fifo.
// These fifos can be of any size. This channel is particularly useful
// for dealing with pipelined protocols.

class tlm_req_rsp_channel #( type REQ = int , type RSP = int )
  extends ovm_component;

  typedef tlm_req_rsp_channel #( REQ , RSP ) this_type;

  protected  tlm_fifo #( REQ ) m_request_fifo;
  protected tlm_fifo #( RSP ) m_response_fifo;

  // request exports and analysis_port

  ovm_put_export #( REQ ) put_request_export;
  ovm_blocking_put_export #( REQ ) blocking_put_request_export;
  ovm_nonblocking_put_export #( REQ ) nonblocking_put_request_export;

  ovm_get_export #( REQ ) get_request_export;
  ovm_blocking_get_export #( REQ ) blocking_get_request_export;
  ovm_nonblocking_get_export #( REQ ) nonblocking_get_request_export;

  ovm_peek_export #( REQ ) peek_request_export;
  ovm_blocking_peek_export #( REQ ) blocking_peek_request_export;
  ovm_nonblocking_peek_export #( REQ ) nonblocking_peek_request_export;

  ovm_get_peek_export #( REQ ) get_peek_request_export;
  ovm_blocking_get_peek_export #( REQ )
    blocking_get_peek_request_export;
  ovm_nonblocking_get_peek_export #( REQ )
    nonblocking_get_peek_request_export;

  ovm_analysis_port #( REQ ) request_ap;

  // response exports and analysis_port

  ovm_put_export #( RSP ) put_response_export;
  ovm_blocking_put_export #( RSP ) blocking_put_response_export;
  ovm_nonblocking_put_export #( RSP ) nonblocking_put_response_export;

  ovm_get_export #( RSP ) get_response_export;
  ovm_blocking_get_export #( RSP ) blocking_get_response_export;
  ovm_nonblocking_get_export #( RSP ) nonblocking_get_response_export;

  ovm_peek_export #( RSP ) peek_response_export;
  ovm_blocking_peek_export #( RSP ) blocking_peek_response_export;
  ovm_nonblocking_peek_export #( RSP ) nonblocking_peek_response_export;

  ovm_get_peek_export #( RSP ) get_peek_response_export;
  
  ovm_blocking_get_peek_export #( RSP )
    blocking_get_peek_response_export;
  
  ovm_nonblocking_get_peek_export #( RSP )
    nonblocking_get_peek_response_export;

  ovm_analysis_port #( RSP ) response_ap;

  // master and slave exports

  ovm_master_imp #( REQ , RSP ,
		    this_type ,
		    tlm_fifo #( REQ ) , tlm_fifo #( RSP ) 
                   ) master_export;
  
  ovm_slave_imp #( REQ , RSP ,
		   this_type ,
		   tlm_fifo #( REQ ) , tlm_fifo #( RSP )
                 ) slave_export;

  ovm_blocking_master_imp #( REQ , RSP ,
			     this_type ,
			     tlm_fifo #( REQ ) , tlm_fifo #( RSP )
			    ) blocking_master_export;
  
  ovm_blocking_slave_imp #( REQ , RSP ,
			    this_type ,
			    tlm_fifo #( REQ ) , tlm_fifo #( RSP )
			   ) blocking_slave_export;

  ovm_nonblocking_master_imp #( REQ , RSP ,
				this_type ,
				tlm_fifo #( REQ ) , tlm_fifo #( RSP )
			      ) nonblocking_master_export;
  
  ovm_nonblocking_slave_imp #( REQ , RSP ,
			       this_type ,
			       tlm_fifo #( REQ ) , tlm_fifo #( RSP ) 
			     ) nonblocking_slave_export;

  // constructor : the default size for the request and response fifos
  // is one.

  function new( string name , ovm_component parent = null , 
                int request_fifo_size = 1 ,
                int response_fifo_size = 1 );


    // check parent = false because this component could be used in
    // module and so have no parent
    
    super.new( name, parent );

    m_request_fifo = new("request_fifo" , this , request_fifo_size );
    m_response_fifo = new("response_fifo" , this , response_fifo_size );

    request_ap = new("request_ap" , this );
    response_ap = new("response_ap" , this );
            
    create_request_exports();
    create_response_exports();
    
    create_master_slave_exports();

    set_report_id_action_hier( s_connection_error_id , OVM_NO_ACTION );
    
    
  endfunction // new

  function void post_new();
    export_request_connections();
    export_response_connections();
    
    m_request_fifo.put_ap.connect( request_ap );
    m_response_fifo.put_ap.connect( response_ap );
  endfunction  

  function void create_request_exports();
    put_request_export = new("put_request_export" , this );
  
    blocking_put_request_export =
      new("blocking_put_request_export" , this );
  
    nonblocking_put_request_export =
      new("nonblocking_put_request_export" , this );
  
    get_request_export = new("get_request_export" , this );
  
    blocking_get_request_export
      = new("blocking_get_request_export" , this );
  
    nonblocking_get_request_export
      = new("nonblocking_get_request_export" , this );
  
    peek_request_export = new("peek_request_export" , this );
  
    blocking_peek_request_export
      = new("blocking_peek_request_export" , this );
  
    nonblocking_peek_request_export
      = new("nonblocking_peek_request_export" , this );

    get_peek_request_export = new("get_peek_request_export" , this );
  
    blocking_get_peek_request_export
      = new("blocking_get-peek_request_export" , this );
  
    nonblocking_get_peek_request_export
      = new("nonblocking_get_peek_request_export" , this );
  
  endfunction 

  function void create_response_exports();
    put_response_export = new("put_response_export" , this );
  
    blocking_put_response_export =
      new("blocking_put_response_export" , this );
  
    nonblocking_put_response_export =
      new(" nonblocking_put_response_export" , this );
  
    get_response_export = new("get_response_export" , this );
  
    blocking_get_response_export
      = new("blocking_get_response_export" , this );
  
    nonblocking_get_response_export
      = new("nonblocking_get_response_export" , this );
  
    peek_response_export = new("peek_response_export" , this );
  
    blocking_peek_response_export
      = new("blocking_peek_response_export" , this );
  
    nonblocking_peek_response_export
      = new("nonblocking_peek_response_export" , this );

    get_peek_response_export = new("get_peek_response_export" , this );
  
    blocking_get_peek_response_export
      = new("blocking_get-peek_response_export" , this );
  
    nonblocking_get_peek_response_export
      = new("nonblocking_get_peek_response_export" , this );
  
  endfunction 


  function void create_master_slave_exports();
 
    master_export = new("master_export" , this ,
			m_request_fifo , m_response_fifo );
  
    slave_export = new( "slave_export" , this ,
			m_request_fifo , m_response_fifo );
 
    blocking_master_export = new("blocking_master_export" , this ,
				 m_request_fifo , m_response_fifo );
  

    blocking_slave_export = new("blocking_slave_export" , this ,
				m_request_fifo , m_response_fifo );

    nonblocking_master_export = new("nonlocking_master_export" , this ,
				    m_request_fifo , m_response_fifo );
  

    nonblocking_slave_export = new("nonblocking_slave_export" , this ,
				   m_request_fifo , m_response_fifo );
  endfunction
  
  function void export_request_connections();

    put_request_export.connect( m_request_fifo.put_export );
    blocking_put_request_export.connect(
      m_request_fifo.blocking_put_export );
  
    nonblocking_put_request_export.connect( 
      m_request_fifo.nonblocking_put_export );

    get_request_export.connect( m_request_fifo.get_export );
  
    blocking_get_request_export.connect(
      m_request_fifo.blocking_get_export );
  
    nonblocking_get_request_export.connect( 
      m_request_fifo.nonblocking_get_export );

    peek_request_export.connect( m_request_fifo.peek_export );
  
    blocking_peek_request_export.connect(
      m_request_fifo.blocking_peek_export );

    nonblocking_peek_request_export.connect( 
      m_request_fifo.nonblocking_peek_export );

    get_peek_request_export.connect( m_request_fifo.get_peek_export );
  
    blocking_get_peek_request_export.connect( 
      m_request_fifo.blocking_get_peek_export );

    nonblocking_get_peek_request_export.connect( 
      m_request_fifo.nonblocking_get_peek_export );

  endfunction

  function void export_response_connections();

    put_response_export.connect( m_response_fifo.put_export );
				 
    blocking_put_response_export.connect(
      m_response_fifo.blocking_put_export );
					 
    nonblocking_put_response_export.connect(
      m_response_fifo.nonblocking_put_export );

    get_response_export.connect( m_response_fifo.get_export );
  
    blocking_get_response_export.connect(
      m_response_fifo.blocking_get_export );
  
    nonblocking_get_response_export.connect(
      m_response_fifo.nonblocking_get_export );

    peek_response_export.connect( m_response_fifo.peek_export );

    blocking_peek_response_export.connect(
      m_response_fifo.blocking_peek_export );

    nonblocking_peek_response_export.connect(
      m_response_fifo.nonblocking_peek_export );

    get_peek_response_export.connect( m_response_fifo.get_peek_export );

    blocking_get_peek_response_export.connect(
      m_response_fifo.blocking_get_peek_export );

    nonblocking_get_peek_response_export.connect(
      m_response_fifo.nonblocking_get_peek_export );

  endfunction
endclass

// tlm_transport_channel is a tlm_req_rsp_channel that implements the
// transport interface. Because the requests and responses have a
// tightly coupled one to one relationship, the fifo sizes must be one.

class tlm_transport_channel #( type REQ = int , type RSP = int ) 
  extends tlm_req_rsp_channel #( REQ , RSP );

  typedef tlm_transport_channel #( REQ , RSP ) this_type;

  ovm_transport_imp #( REQ , RSP , this_type ) transport_export;

  function new( string name ,
		ovm_component parent = null );
    
    super.new( name , parent , 1 , 1 );
    
    transport_export = new( "transport_export" , this );
    
  endfunction

  // The transport task simply calls put( request ) followed by
  // get( response ).

// begin codeblock transport
  task transport( input REQ request , output RSP response );
    this.m_request_fifo.put( request );
    this.m_response_fifo.get( response );
  endtask
// end codeblock transport caption path

  function bit nb_transport( input REQ req, output RSP rsp );
    if(this.m_request_fifo.try_put(req)) 
      return this.m_response_fifo.try_get(rsp);
    else
      return 0;
  endfunction

endclass
