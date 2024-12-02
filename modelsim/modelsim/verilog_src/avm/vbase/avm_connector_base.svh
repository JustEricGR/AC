
// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/vbase/avm_connector_base.svh#1 $
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

const int AVM_UNBOUNDED_CONNECTIONS = -1;

typedef enum {
  AVM_PORT ,
  AVM_EXPORT ,
  AVM_IMPLEMENTATION
} avm_port_type_e;

const string s_port_type_name[avm_port_type_e] = '{
  AVM_PORT:"port" ,
  AVM_EXPORT:"export" ,
  AVM_IMPLEMENTATION:"implementation"
};
	       			      
const string s_port_type_article[avm_port_type_e] = '{
  AVM_PORT:"a" ,
  AVM_EXPORT:"an" ,
  AVM_IMPLEMENTATION:"an"
};
	       			      
typedef enum {
  AVM_CONSTRUCTION_PHASE ,
  AVM_EXPORT_CONNECTIONS_PHASE ,
  AVM_CONNECT_PHASE ,
  AVM_IMPORT_CONNECTIONS_PHASE ,
  AVM_DONE_CONNECTIONS_PHASE     
} avm_connection_phase_e;

const string s_connection_phase_methods[avm_connection_phase_e] = '{
  AVM_CONSTRUCTION_PHASE:"new" ,
  AVM_EXPORT_CONNECTIONS_PHASE:"export_connections" ,
  AVM_CONNECT_PHASE:"connect" ,
  AVM_IMPORT_CONNECTIONS_PHASE:"import_connections" ,
  AVM_DONE_CONNECTIONS_PHASE:""
};

const string s_connection_error_id = "Connection Error";
const string s_connection_debug_id = "Connections Debug";

//
// avm_connector_base stores the detailed connectivity mechanics for
// avm_*_port and avm_*_export.
//

class avm_connector_base #( type IF = int )
  extends avm_named_component;
 
  typedef avm_connector_base #( IF ) connector_type;
  
  local int m_min_size , m_max_size; // bounds on the number of IFs
  local avm_port_type_e m_port_type; // ie, PORT, EXPORT or IMP

  // m_if_list holds the interfaces that (should) satisfy the
  // connectivity requirements of this. At the end of elaboration,
  // the size of this list must be between m_min_size and m_max_size
  
  local IF m_if_list[$];
    
  // Consider port->port->export->export->imp.
  // provided_by list points to RHS of "->"

  // the provided_by list is list of connectors that "this" uses to
  // satisfy its conenctivity requirements

  // all the interfaces of all the m_provided_by[i] are copied into
  // this.m_if_list

  local avm_connector_base #( IF ) m_provided_by[string];
  
  // Consider port->port->export->export->imp.
  // provided_to_list point to LHS of "->"
  
  // the provided_to list is the list of connectors that use "this" to
  // satisfy their connectivity requirements

  // all the interfaces of this.m_if_list are copied into all the
  // m_provided_to[i]
  
  local avm_connector_base #( IF ) m_provided_to[string];

  function new( string name , avm_named_component parent ,
		avm_port_type_e port_type ,
		int min_size , int max_size ,
		bit check_parent );
    
     // don't show this component in the GUI
     super.new( name , parent , check_parent, 0 ); 
    m_min_size = min_size;
    m_max_size = max_size;

    m_port_type = port_type;
  endfunction
  
  // returns the actual number of interfaces held

  function int size();
    return m_if_list.size();
  endfunction

  // the maximum number of interfaces that can be held

  function int max_size();
    return m_max_size;
  endfunction

  // the minimum permissible number of interface that must be held by
  // the time elaboration is finished

  function int min_size();
    return m_min_size;
  endfunction
  
  //
  // For new style binding avm_*_port -> avm_*_port -> avm_*_export ->
  // to avm_*_imp
  //
  
  function bit connect_to( input connector_type c );
    string s;
  
    c.check_min_connection_size();
 
    for( int i = 0; i < c.m_if_list.size(); i++ ) begin
     
      if( !add_if( c.m_if_list[i] ) ) begin
	$sformat( s , "Cannot connect to %s" , c.m_name );
	avm_report_error( s_connection_error_id , s );
	return 0;
      end
      
    end

    update_connection_lists( c );
    return 1;
  endfunction  

  function void update_connection_lists( input connector_type c );
    m_provided_by[c.m_name] = c;
    c.m_provided_to[m_name] = this;
  endfunction

  //
  // For old style binding eg avm_*_port -> tlm_*_if or avm_*_export to
  // to tlm_*_if
  //
 
  function bit add_if( IF _if );
    string s;
    
    if( size() == m_max_size ) begin
      $sformat( s , "Maximum number of interfaces (%0d) exceeded" ,
		m_max_size );
      
      avm_report_error( s_connection_error_id , s );
      return 0;
    end
  
    m_if_list.push_back( _if );
    return 1;
  endfunction

  //
  // For multiport access
  //
  
  function IF lookup_indexed_if( int i = 0 );
    string s;
  
    if( i < 0 || i >= size() ) begin
      $sformat( s , "Index %0d out of range [0,%0d]" , i , size() );
      avm_report_warning( s_connection_error_id , s );
 //     return null_if;
    end

    return m_if_list[i];
  endfunction

  // checks min connection size. Max size checking is done as interfaces
  // are added, on the fly.
  
  function void check_min_connection_size();
    string s;
  
    if( size() < m_min_size ) begin
      $sformat( s , 
    "requires at least %0d connection%s, but actually has %0d connection%s" ,
		m_min_size , ( m_min_size > 1 ? "s" : "" ) ,
		size() , ( size() != 1 ? "s" : "" ) );
      
      avm_report_error( s_connection_error_id , s );
    end
  endfunction

  // checks that the connection types are legal
  
  function bit check_types( connector_type provider );

    string s;
  
    if( m_port_type == AVM_IMPLEMENTATION ||
	( m_port_type == AVM_EXPORT &&
	  provider.m_port_type == AVM_PORT ) ) begin

      
      $sformat( s , "Cannot connect %s to %s" ,
		s_port_type_name[m_port_type] ,
		s_port_type_name[provider.m_port_type] );

      avm_report_error( s_connection_error_id , s );
      return 0;
      
    end

    return 1; 
  endfunction

  // checks that this connection is being made in the correct phase
  
  function bit check_phase( connector_type provider );

    string s;
    avm_env env;
    avm_connection_phase_e required_phase , actual_phase;
  
    env = ( m_env == null ? s_current_env : m_env );

    if( env == null ) begin
        // can't check phase outside of an avm_env
      return 1;
    end
  
    required_phase = get_required_phase( provider.m_port_type );
    actual_phase = env.m_connection_phase;
 
    if( required_phase != actual_phase ) begin

      $sformat( s , "You have attempted to connect %s to %s in %s" ,
		m_name , provider.m_name ,
		s_connection_phase_methods[actual_phase] );

      avm_report_warning( s_connection_error_id , s );

       $sformat( s , "You can only connect %s %s to %s %s in %s" ,
		 s_port_type_article[m_port_type] ,
		 s_port_type_name[m_port_type] ,
		 s_port_type_article[m_port_type] ,
		 s_port_type_name[provider.m_port_type] ,
		 s_connection_phase_methods[required_phase] );     

      avm_report_error(s_connection_error_id , s );
      return 0;
    end
  
    return 1;
  endfunction

  // checks that the parent child relationships are correct
  
  function bit check_relationship( connector_type provider );  
    string s;
    avm_named_component grandparent;
    avm_named_component provider_grandparent;
  

    if( m_parent == null || provider == null || provider.m_parent == null ) begin
      // don't check if we have a parentless analysis port
      return 1;
    end

    grandparent = m_parent.m_parent;
    provider_grandparent = provider.m_parent.m_parent;

    if( grandparent == null || grandparent.m_env == null || provider_grandparent == null ) begin
      // don't check if one or both ends are in a module
      return 1;
    end
  
    // we can't use the actual phase because we may not be in an avm_env
  
    case( get_required_phase( provider.m_port_type ) )
    AVM_IMPORT_CONNECTIONS_PHASE : begin
      if( grandparent != provider.m_parent ) begin

	$sformat( s ,
		  "connect ( child port -> port ) : %s should be a child of %s" , 
		  m_parent.m_name , provider.m_parent.m_name );
	
	avm_report_error( s_connection_error_id , s );
	return 0;	
      end    
    end
      
    AVM_CONNECT_PHASE : begin
      if( grandparent != provider_grandparent ) begin
	$sformat( s ,
		  "connect ( port -> export ) : %s should be a sibling of %s" ,
		  m_parent.m_name , provider.m_parent.m_name );
      
	avm_report_error( s_connection_error_id , s );
	return 0;
      end
    end
      
    AVM_EXPORT_CONNECTIONS_PHASE : begin
      if( m_parent != provider_grandparent ) begin
	
	$sformat( s ,
		  "connect ( export -> child export ) : %s should be a parent of %s",
		  m_parent.m_name , provider.m_parent.m_name );
	
	avm_report_error(s_connection_error_id , s );
	return 0;
      end
    end
    endcase

    return 1;
  endfunction
 
  //
  // recurses rightwards through the port->port->export->export->imp
  // connections, printing out where it has got to and how many
  // interfaces are held at each point
  //     

  function void debug_connected_to( int level = 0 ,
				    int max_level = -1 );
    string s;

    if( size() > 1 ) begin
  
      if( m_provided_by.num() > 0 ) begin
	$sformat( s , "has %0d interfaces from %0d places" ,
		  size() , m_provided_by.num() );
      end
      else begin
	$sformat( s , "has %0d interfaces" , size() );
      end
      
      avm_report_message( s_connection_debug_id , s );
    end
  
    foreach( m_provided_by[i] ) begin
      $sformat( s , " has %0d interface%s provided by %s" ,
		m_provided_by[i].size() ,
		( m_provided_by[i].size() > 1 ? "s" : "" ) ,
		m_provided_by[i].m_name  );
      avm_report_message("Connections Debug" , s );
    end

    if( m_port_type == AVM_IMPLEMENTATION ) begin
      $sformat( s , " implemented by %s" , m_parent.m_name );
      avm_report_message( s_connection_debug_id , s ); 
    end

    if( level == max_level ) begin
      return;
    end
 
    foreach( m_provided_by[i] ) begin
      m_provided_by[i].debug_connected_to( level + 1 , max_level );
    end
  
  endfunction

  //
  // recurses leftwards through the port->port->export->export->imp
  // connections, printing out where it has got to and how many
  // interfaces are held at each point
  //     

  function void debug_provided_to( int level = 0 , int max_level = -1 );
    string s;

    if( m_provided_to.num() == 0 ) begin
      return;
    end

    if( size() > 1 ) begin

      if( m_provided_to.num() > 1 ) begin
  
	$sformat( s , "provides %0d interfaces to %0d ports/exports" ,
	          size() , m_provided_to.num() );

      end
      else begin
	$sformat( s , "provides %0d interfaces" , size() );
      end
	
      avm_report_message( s_connection_debug_id , s );
    end
      
    foreach( m_provided_to[i] ) begin
      $sformat( s , "provides %0d interface%s to %s" ,
	       size() ,
	       ( size() > 1 ? "s" : "") ,
	       m_provided_to[i].m_name );
      
      avm_report_message( s_connection_debug_id , s );
    end

    if( level == max_level ) begin
      return;
    end
 
    foreach( m_provided_to[i] ) begin
      m_provided_to[i].debug_provided_to( level + 1 , max_level );
    end
  
  endfunction

  local function avm_connection_phase_e
  get_required_phase( avm_port_type_e provider_port_type );
  
    if( m_port_type == AVM_EXPORT &&
	( provider_port_type == AVM_EXPORT ||
	  provider_port_type == AVM_IMPLEMENTATION )
      ) begin
      
      return AVM_EXPORT_CONNECTIONS_PHASE;
 
   end

    if( m_port_type == AVM_PORT &&
	( provider_port_type == AVM_EXPORT ||
	  provider_port_type == AVM_IMPLEMENTATION )
      ) begin
      
      return AVM_CONNECT_PHASE;

    end
  
    if( m_port_type == AVM_PORT && provider_port_type == AVM_PORT ) begin
      return AVM_IMPORT_CONNECTIONS_PHASE;
    end

    avm_report_error( s_connection_error_id ,
		      "no valid required phase" );
  
    return AVM_DONE_CONNECTIONS_PHASE;
     
  endfunction

  // 
  // do_display is virtual in avm_named_component. We only print
  // anything if display_connectors is true
  //

  function void do_display( int max_level = -1 ,
			    int level = 0 ,
                            bit display_connectors = 0 );
  
    if( display_connectors ) begin
      avm_report_message("hierarchy debug" , "" , 1000 );
    end
  
  endfunction  

  function void check_connection_size();
    check_min_connection_size();
  endfunction
  
  //
  // This method is purely for GUI debugging purposes.
  //
  // puts this into correct debug list
  //
  
  local virtual function void add_to_debug_list();
  
    case( m_port_type )
      AVM_PORT : m_parent.m_ports[m_leaf_name] = this;
      AVM_EXPORT : m_parent.m_exports[m_leaf_name] = this; 
      AVM_IMPLEMENTATION : m_parent.m_implementations[m_leaf_name] = this;
    endcase
  endfunction

endclass
