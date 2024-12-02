// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_port_base.svh#1 $
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

`const string s_removed_id = "component has been removed";
`const string s_connect_id = "connect";

//----------------------------------------------------------------------
// ovm_port_base
//
// ovm_port_base extends but does not implement IF
//
// IF is typically a TLM or analysis interface. This interface will
// be implemented in ovm_<IF>_port, ovm_<IF>_export, or ovm_<IF>_imp.
//
// Mostly ovm_port_base delegates to m_connector.
//
//----------------------------------------------------------------------
virtual class ovm_port_base #(type IF = ovm_object)
  extends ovm_port_base_base #(IF);
   
  typedef ovm_connector #( IF ) connector_type;
  typedef ovm_port_base #( IF ) this_type;
  
  connector_type m_connector;
  int unsigned m_if_mask;
  string m_if_name;
  protected IF m_if;
  ovm_if_container #(IF) m_if_container;

  function new( string name , ovm_component parent ,
		ovm_port_type_e port_type ,
		int min_size = 0 , int max_size = 1 );
    set_name(name);
    m_connector = new( name, parent, port_type,
                       min_size, max_size );
    m_connector.port_h = this;
    m_if_container = m_connector.get_if_container();

  endfunction

  // port->port, port->export/imp, export->export/imp connections

  //--------------------------------------------------------------------
  // connect
  //--------------------------------------------------------------------
  function void connect( this_type provider );
    string s;
    connector_type provider_connector;

    // Check the provider interface mask against this (requirer) mask.
    // The provider must provide at least the set of interface functions
    // that the requirer requires.  It may provide more, but that's the
    // minimumn needed for this connection.
    if( (provider.m_if_mask & m_if_mask) != m_if_mask) begin
      $sformat(s, "cannot connect provider of %s interface to a requirer of %s interface",
               provider.m_if_name, m_if_name);
      m_connector.ovm_report_error(s_connect_id, s);
      return;
    end

    provider_connector = provider.m_connector;
  
  /*
    if( m_connector.is_removed() ) begin
          
      $sformat( s , "Ignoring attempted connection from %s to %s" ,
		m_connector.get_full_name() ,
		provider_connector.get_full_name() );
 
      m_connector.ovm_report_info( s_removed_id , s );
      return;	   
    end

    if( provider_connector.is_removed() ) begin
      
      $sformat( s , "Ignoring attempted connection from %s to %s" ,
		m_connector.get_full_name(),
		provider_connector.get_full_name() );
 
      provider_connector.ovm_report_info( s_removed_id , s );
      
      return;		   
    end
    */
  
    if( !m_connector.check_types( provider_connector ) ||
        !m_connector.check_relationship( provider_connector ) ) begin
    
      $sformat( s , "Cannot connect %s to %s" ,
		m_connector.get_full_name(),
		provider_connector.get_full_name() );
 
      m_connector.ovm_report_error( s_connection_error_id , s );
      
      // unless action assoiated with s_connection_error_id determines
      // otherwise, make best attempt to complete connection
      
    end
  
    m_connector.update_connection_lists(provider_connector);

  endfunction

  //--------------------------------------------------------------------
  // remove
  //--------------------------------------------------------------------
  function void remove();
    //m_connector.remove();
  endfunction
		       
  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  function int size();
    return m_if_container.size();
  endfunction

  //--------------------------------------------------------------------
  // connect_to_if
  //
  // port/export -> old style if conenction
  //--------------------------------------------------------------------
  function void connect_to_if( input IF _if );
    assert( m_connector.add_if( _if ) );
  endfunction

  //--------------------------------------------------------------------
  // lookup_indexed_if
  //
  // looks up ith index
  //--------------------------------------------------------------------
  function IF lookup_indexed_if( int i = 0 );
    return m_if_container.lookup_indexed_if( i );
  endfunction

  //--------------------------------------------------------------------
  // set_if
  //--------------------------------------------------------------------
  function void set_if(int i = 0);
    m_if = lookup_indexed_if(i);
  endfunction

  //--------------------------------------------------------------------
  // debug_connected_to
  //
  // recursive debug following RHS of requires->provides
  // end point is an imp
  //--------------------------------------------------------------------
  function void debug_connected_to( int level = 0 ,
				    int max_level = -1 );
  
    m_connector.debug_connected_to( level , max_level );

  endfunction

  //--------------------------------------------------------------------
  // debug_provided_to
  //
  // recusrive debug following LHS of requires->provides
  // end point is a port 
  //--------------------------------------------------------------------
  function void debug_provided_to( int level = 0 ,
				   int max_level = -1 ); 

    m_connector.debug_provided_to( level , max_level );
  
  endfunction

  `include "compatibility/urm_port_compatibility.svh"
endclass
