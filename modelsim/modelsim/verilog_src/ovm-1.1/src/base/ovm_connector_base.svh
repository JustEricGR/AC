// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_connector_base.svh#1 $
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

typedef enum {
  OVM_PORT ,
  OVM_EXPORT ,
  OVM_IMPLEMENTATION
} ovm_port_type_e;

`const string s_connection_error_id = "Connection Error";
`const string s_connection_debug_id = "Connections Debug";


//------------------------------------------------------------------------------
//
// CLASS: ovm_connector_base
//
//------------------------------------------------------------------------------
// ovm_connector_base stores the detailed connectivity mechanics for
// ovm_*_port and ovm_*_export.
//------------------------------------------------------------------------------

virtual class ovm_connector_base extends ovm_component;

  protected ovm_port_type_e m_port_type; // ie, PORT, EXPORT or IMP

  function new( string name, ovm_component parent,
                ovm_port_type_e port_type );
    super.new(name, parent );
    m_port_type = port_type;
  endfunction

  function bit is_port();
    return m_port_type == OVM_PORT;
  endfunction

  function bit is_export();
    return m_port_type == OVM_EXPORT;
  endfunction

  function bit is_imp();
    return m_port_type == OVM_IMPLEMENTATION;
  endfunction

  function string get_type_name();
    //return "ovm_connector_base";
    case( m_port_type )
      OVM_PORT : return "port";
      OVM_EXPORT : return "export";
      OVM_IMPLEMENTATION : return "implementation";
    endcase
  endfunction

endclass



//------------------------------------------------------------------------------
//
// CLASS: ovm_connector #(IF)
//
//------------------------------------------------------------------------------

class ovm_connector #(type IF=int) extends ovm_connector_base;
 
  typedef ovm_connector #(IF) connector_type;
  
  local int unsigned if_mask;

  local ovm_if_container #(IF) m_if_container;

  ovm_port_base_base #(IF) port_h;

  // Consider port->port->export->export->imp.
  // provided_by list points to RHS of "->"

  // the provided_by list is list of connectors that "this" uses to
  // satisfy its conenctivity requirements

  // all the interfaces of all the m_provided_by[i] are copied into
  // this.m_if_list

  local connector_type m_provided_by[string];
  
  // Consider port->port->export->export->imp.
  // provided_to_list point to LHS of "->"
  
  // the provided_to list is the list of connectors that use "this" to
  // satisfy their connectivity requirements

  local connector_type m_provided_to[string];

  function new( string name , ovm_component parent ,
                ovm_port_type_e port_type,
                int min_size = 0, int max_size = 1 );
    
    super.new( name, parent, port_type );
    m_if_container = new(min_size, max_size);
  endfunction

  //----------------------------------------------------------------------------
  // accessor and convenience functions
  //----------------------------------------------------------------------------

  function ovm_if_container #(IF) get_if_container();
    return m_if_container;
  endfunction

  function int size();
    return m_if_container.size();
  endfunction

  function int min_size();
    return m_if_container.min_size();
  endfunction

  function int max_size();
    return m_if_container.max_size();
  endfunction

  //----------------------------------------------------------------------------
  // connect_to
  //
  // For new style binding ovm_*_port -> ovm_*_port -> ovm_*_export ->
  // to ovm_*_imp
  //
  //----------------------------------------------------------------------------
  function bit connect_to( input connector_type c );
    string s;

    if(!c.m_if_container.add_list(m_if_container)) begin
      s = {"Cannot connect to " , c.get_full_name()};
      ovm_report_error( s_connection_error_id , s );
      return 0;
    end

    // set the value if m_if to the first entry
    // in the interface list 
    c.port_h.set_if();

    //debug_connected_to();

    return 1;
  endfunction  

  //--------------------------------------------------------------------
  // end_of_elaboration
  //--------------------------------------------------------------------
  function void end_of_elaboration();
    check_min_connection_size();
  endfunction

  //----------------------------------------------------------------------------
  // update_connection_lists
  //----------------------------------------------------------------------------
  function void update_connection_lists( input connector_type c );
    m_provided_by[c.get_full_name()] = c;
    c.m_provided_to[get_full_name()] = this;
  endfunction


  //----------------------------------------------------------------------------
  // resolve_bindings
  //----------------------------------------------------------------------------
  virtual function void resolve_bindings();

    if(!is_imp() || is_imp() && m_provided_to.num() == 0)
      return;
   resolve_bindings_all();

  endfunction


  //----------------------------------------------------------------------------
  // resolve_bindings_all
  //----------------------------------------------------------------------------
  function void resolve_bindings_all();
    connector_type c;

    foreach (m_provided_to[s]) begin
      c = m_provided_to[s];
      if(connect_to(c))
        c.resolve_bindings_all();
    end

   check_min_connection_size();
 
  endfunction


  //--------------------------------------------------------------------
  // check_min_connection_size
  //--------------------------------------------------------------------

  function void check_min_connection_size();
    string s;
  
    if( size() < min_size() ) begin
      $sformat( s,
                "connection count of %0d does not meet required minimum of %0d" ,
                size(), min_size() );
      ovm_report_error( s_connection_error_id , s );
    end
  endfunction

  
  //----------------------------------------------------------------------------
  // add_if
  //
  // For old style binding eg ovm_*_port -> tlm_*_if or ovm_*_export to
  // to tlm_*_if
  //
  //----------------------------------------------------------------------------
  function bit add_if( IF _if );
    string s;
    
    if(!m_if_container.add_if(_if)) begin
      s.itoa(max_size());
      s = {"Maximum number of interfaces (",s,") exceeded"};
      ovm_report_error( s_connection_error_id , s );
      return 0;
    end

    return 1;
  endfunction

  //----------------------------------------------------------------------------
  // lookup_indexed_if
  //
  // For multiport access
  //
  //----------------------------------------------------------------------------
  function IF lookup_indexed_if( int i = 0 );
    string s;
    IF ifc;
    ifc = m_if_container.lookup_indexed_if(i);
  
    if(ifc == null) begin
      $sformat( s , "Index %0d out of range [0,%0d]" , i , size() );
      ovm_report_warning( s_connection_error_id , s );
    end
    return ifc;
  endfunction

  //----------------------------------------------------------------------------
  // check_types
  //
  // checks that the connection types are legal
  //----------------------------------------------------------------------------
  function bit check_types( connector_type provider );

    string s;
  
    if( is_imp() || ( is_export() && provider.is_port())) begin

      s = {"Cannot connect ", get_type_name(),
           "s to ", provider.get_type_name(),"s"};

      ovm_report_error( s_connection_error_id , s );
      return 0;
      
    end

    return 1; 
  endfunction


  //----------------------------------------------------------------------------
  // check_phase
  //
  // checks that this connection is being made in the correct phase
  //----------------------------------------------------------------------------
  function bit check_phase( connector_type provider );

    string s;
    ovm_phase required_phase, actual_phase;
  
    required_phase = get_required_phase(provider);
    actual_phase = ovm_top.get_current_phase();
 
    if( required_phase != actual_phase ) begin

      s = {"You have attempted to connect ", get_full_name(),
           " to ",provider.get_full_name(), " in phase '",
           actual_phase.get_name(),"'" };

      ovm_report_warning( s_connection_error_id , s );

      s = {"You can only connect ", get_type_name(), "s to ", 
           provider.get_type_name(), "s in phase '",
           required_phase.get_name(), "'" };

      ovm_report_error(s_connection_error_id , s );
      return 0;
    end
  
    return 1;
  endfunction


  //----------------------------------------------------------------------------
  // check_relationship
  //
  // checks that the parent child relationships are correct
  //----------------------------------------------------------------------------
  function bit check_relationship( connector_type provider );  
    string s;
    ovm_component grandparent;
    ovm_component provider_grandparent;
  
    if( m_parent == null || provider == null || provider.m_parent == null ) begin
      // don't check if we have a parentless analysis port
      return 1;
    end

    grandparent = m_parent.m_parent;
    provider_grandparent = provider.m_parent.m_parent;

    // don't check if one or both ends are at top-level
    if( grandparent == ovm_top || provider_grandparent == ovm_top)
      return 1;
  
    // REVIEW: temporarily disabling the check in preparation for
    // import/export_connections deprecation
    return 1;

    // IUS doesn't support a class handle as a case item so use if/else
    if ( get_required_phase(provider) == import_connections_ph)
      if( grandparent != provider.m_parent ) begin
        s = {"connect ( child port -> port ) : ", m_parent.get_full_name(),
             " should be a child of %s", provider.m_parent.get_full_name()};
        ovm_report_error( s_connection_error_id , s );
        return 0;
      end    
      
    else if ( get_required_phase(provider) == connect_ph)
      if( grandparent != provider_grandparent ) begin
        s = {"connect ( port -> export ) : ", m_parent.get_full_name(),
             " should be a sibling of %s", provider.m_parent.get_full_name()};
        ovm_report_error( s_connection_error_id , s );
        return 0;
      end
      
    else if ( get_required_phase(provider) == export_connections_ph)
      if( m_parent != provider_grandparent ) begin
        s = {"connect ( export -> child export ) : ", m_parent.get_full_name(),
             " should be a parent of %s", provider.m_parent.get_full_name()};
        ovm_report_error(s_connection_error_id , s );
        return 0;
      end

    return 1;
  endfunction

 
  //----------------------------------------------------------------------------
  // get_required_phase
  //----------------------------------------------------------------------------
  local function ovm_phase get_required_phase(ovm_connector_base provider);
  
    if( is_export() && ( provider.is_export() || provider.is_imp()))
      return export_connections_ph;
 
    if( is_port() && ( provider.is_export() || provider.is_imp()))
      return connect_ph;
  
    if( is_port() && provider.is_port())
      return import_connections_ph;

    ovm_report_error(s_connection_error_id, "no valid required phase");
    return null;
     
  endfunction







  // Deprecated ...


  //----------------------------------------------------------------------------
  // do_display
  // 
  // do_display is virtual in ovm_component. We only print
  // anything if display_connectors is true
  //----------------------------------------------------------------------------
  function void do_display( int max_level = -1 ,
                            int level = 0 ,
                            bit display_connectors = 0 );
  
    if( display_connectors ) begin
      ovm_report_info("hierarchy debug" , "" , 1000 );
    end
  
  endfunction  


  //----------------------------------------------------------------------------
  // debug_connected_to
  //     
  // recurses rightwards through the port->port->export->export->imp
  // connections, printing out where it has got to and how many
  // interfaces are held at each point
  //----------------------------------------------------------------------------
  function void debug_connected_to( int level = 0 ,
                                    int max_level = -1 );
    string s, nm;
    int sz;
    connector_type connector;

    if( size() > 1 ) begin
  
      if( m_provided_by.num() > 0 ) begin
          $sformat( s , "has %0d interfaces from %0d places" ,
          size() , m_provided_by.num() );
      end
      else begin
        $sformat( s , "has %0d interfaces" , size() );
      end
      
      ovm_report_info( s_connection_debug_id , s );
    end
  
    foreach( m_provided_by[i] ) begin
      connector = m_provided_by[i];
      sz =  connector.size();
      nm = connector.get_full_name();
      $sformat( s , " has %0d interface%s provided by %s" , sz,
                ( connector.size() == 1 ? "" : "s" ) , nm );
      ovm_report_info("Connections Debug" , s );
    end

/*
    if( is_imp() ) begin
      $sformat( s , " implemented by %s" , m_parent.get_full_name() );
      ovm_report_info( s_connection_debug_id , s ); 
    end
    */

    if( level == max_level ) begin
      return;
    end
 
    foreach( m_provided_by[i] ) begin
      connector = m_provided_by[i];
      connector.debug_connected_to( level + 1 , max_level );
    end
  
  endfunction


  //----------------------------------------------------------------------------
  // debug_provided_to
  //
  // recurses leftwards through the port->port->export->export->imp
  // connections, printing out where it has got to and how many
  // interfaces are held at each point
  //----------------------------------------------------------------------------
  function void debug_provided_to( int level = 0 , int max_level = -1 );
    string s, nm;
    connector_type connector;

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

      ovm_report_info( s_connection_debug_id , s );
    end
      
    foreach( m_provided_to[i] ) begin
      connector = m_provided_to[i];
      nm = connector.get_full_name();
      $sformat( s , "provides %0d interface%s to %s" ,
                size() , ( size() == 1 ? "" : "s") , nm );
      
      ovm_report_info( s_connection_debug_id , s );
    end

    if( level == max_level ) begin
      return;
    end
 
    foreach( m_provided_to[i] ) begin
      connector = m_provided_to[i];
      connector.debug_provided_to( level + 1 , max_level );
    end
  
  endfunction


  //----------------------------------------------------------------------------
  // add_to_debug_list
  //
  // This method is purely for GUI debugging purposes.
  //
  // puts this into correct debug list
  //
  //----------------------------------------------------------------------------
  local virtual function void add_to_debug_list();
  
    case( m_port_type )
      OVM_PORT : m_parent.m_ports[get_full_name()] = this;
      OVM_EXPORT : m_parent.m_exports[get_full_name()] = this; 
      OVM_IMPLEMENTATION : m_parent.m_implementations[get_full_name()] = this;
    endcase
  endfunction

endclass

