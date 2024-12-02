
// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/vbase/avm_port_base.svh#1 $
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

const string s_removed_id = "component has been removed";

//
// avm_port_base extends but does not implement IF
//
// IF is typically a TLM or analysis interface. This interface will
// be implemented in avm_<IF>_port, avm_<IF>_export, or avm_<IF>_imp.
//
// Mostly avm_port_base delegates to m_connector.
//

virtual class avm_port_base #( type IF = avm_virtual_class )
  extends IF;
   
  typedef avm_connector_base #( IF ) connector_type;
  typedef avm_port_base #( IF ) this_type;
  
  avm_connector_base #( IF ) m_connector;
  
  protected IF m_if;
  
  function new( string name , avm_named_component parent ,
		avm_port_type_e port_type ,
		int min_size = 1 , int max_size = 1 ,
		bit check_parent = 1 );
    
    // check parent is 1 except for analysis ports
    m_connector = new( name , parent ,
		       port_type ,
		       min_size , max_size ,
		       check_parent );
    
     $ui_VVInstallPort(parent,this,name);
  endfunction

  // port->port, port->export/imp, export->export/imp connections
  
  function void connect( this_type provider );
    string s;
    avm_connector_base #( IF ) provider_connector;

    provider_connector = provider.m_connector;
  
    if( m_connector.is_removed() ) begin
          
      $sformat( s , "Ignoring attempted connection from %s to %s" ,
		m_connector.m_name , provider_connector.m_name );
 
      m_connector.avm_report_message( s_removed_id , s );
      return;	   
    end

    if( provider_connector.is_removed() ) begin
      
      $sformat( s , "Ignoring attempted connection from %s to %s" ,
		m_connector.m_name , provider_connector.m_name );
 
      provider_connector.avm_report_message( s_removed_id , s );
      
      return;		   
    end
  
    if( !m_connector.check_types( provider_connector ) ||
	!m_connector.check_phase( provider_connector ) ||
	!m_connector.check_relationship( provider_connector ) ) begin
    
      $sformat( s , "Cannot connect %s to %s" ,
		m_connector.m_name , provider_connector.m_name );
 
      m_connector.avm_report_error( s_connection_error_id , s );
      
      // unless action assoiated with s_connection_error_id determines
      // otherwise, make best attempt to complete connection
      
    end
  
    assert( m_connector.connect_to( provider_connector ) );

    if( provider_connector.size() != 0 ) begin
      m_if = m_connector.lookup_indexed_if();
      assert( m_if != null );
    end
    else begin
      
      // the provider's size could be zero if its minimum size is zero
      // this is the case for avm_analysis_port
      
      assert( provider_connector.min_size() == 0 );
      m_if = null;
    end
  
  endfunction
    
  function void remove();
    m_connector.remove();
  endfunction
		       
  function int size();
    return m_connector.size();
  endfunction

  // port/export -> old style if conenction
   
  function void connect_to_if( input IF _if );
    assert( m_connector.add_if( _if ) );
  endfunction

  // looks up ith index
  
  function IF lookup_indexed_if( int i = 0 );
    return m_connector.lookup_indexed_if( i );
  endfunction

  // recursive debug following RHS of requires->provides
  // end point is an imp
  
  function void debug_connected_to( int level = 0 ,
				    int max_level = -1 );
  
    m_connector.debug_connected_to( level , max_level );

  endfunction

  // recusrive debug following LHS of requires->provides
  // end point is a port 
  
  function void debug_provided_to( int level = 0 ,
				   int max_level = -1 ); 

    m_connector.debug_provided_to( level , max_level );
  
  endfunction

endclass
