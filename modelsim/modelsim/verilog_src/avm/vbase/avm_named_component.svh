// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/vbase/avm_named_component.svh#1 $
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

//----------------------------------------------------------------------
// CLASS avm_named_component
//
// This is the base class for all structural components in the avm.
//
// This includes avm_env, avm_threaded_component, all the tlm
// channels, and all avm ports, exports and imps.
//
// Broadly speaking, the methods of this class are divided into three
// kinds : the basic hierarchy handling methods, including the
// constructor and remove; the methods called by avm_env to do config,
// connections, and reporting; and the hierarchical reporting methods.
//
//----------------------------------------------------------------------


typedef class avm_env;

const string s_lookup_error = "Lookup Error";  
      
virtual class avm_named_component extends avm_report_client ;

  // m_name is the full hierarchical name of this named component
  string m_name;
  string m_leaf_name;
  
  protected avm_named_component m_parent;
  protected avm_named_component m_children[string];

  //
  // The following arrays are purely for debug purposes
  //
  // They are populated in end_of_elaboration, and are empty before then
  //
  // The lists are mutually exclusive subsets of the m_children list.
  //
  // ( These lists will never be populated for components with children
  // not instantiated inside an avm_env - although these are extremely
  // rare, in practice limited to tlm_req_rsp_channel and
  // tlm_transport_channel )
  //
  
  protected avm_named_component m_components[string];
  protected avm_named_component m_ports[string];
  protected avm_named_component m_exports[string];
  protected avm_named_component m_implementations[string];

  //
  // m_env is a reference to the avm_env within which this component is
  // defined, if there is one, and null otherwise
  //
  
  avm_env m_env;

  //
  // s_current_env is a little trick to help with backward compatibility
  // with AVM 2.0. It is not to be relied on by anything other than the
  // constructor of avm_named_component. It is only protected because 
  // avm_env needs access to it, otherwise it would be local.
  //
  
  static protected avm_env s_current_env;
   
  // We must always provide a local name. For most components, a parent
  // is supplied and checked. The only exceptions to this are avm_env,
  // which must not have a parent, and components such as tlm_fifo,
  // which may not have a parent if they are being used in a static
  // component such as a module

  local bit m_is_removed;
  
  function new( string name  ,
		avm_named_component parent = null , 
		bit check_parent = 1
	      	, bit VVInstall = 1
		);

    string error_str;

    m_is_removed = 0;
    
    if( parent == null && check_parent ) begin
      assert( s_current_env != null );
      m_parent = s_current_env;
    end
    else begin
      m_parent = parent;
    end
     if(VVInstall)
       $ui_VVInstallInst(m_parent,this,name);
    m_leaf_name = name;
     
    if( m_parent != null ) begin
      m_name = { m_parent.m_name , "." };
      m_name = { m_name , name };      
      
      if( m_parent.m_children.exists( name ) ) begin
        $sformat( error_str , "name %s already exists" , m_name );
        avm_report_error("duplicate name" , error_str );
      end
      
      m_parent.m_children[m_leaf_name] = this;
    end

    else begin
      m_name = name;
    end

    set_report_name( m_name );
    
    if( parent == null && check_parent ) begin
      no_parent_message();
    end
    
  endfunction

  local function void no_parent_message();
    string s;
  
    avm_report_warning( s_deprecated_3_0 ,
			"No parent specified in constructor" , 500 );
  
	if (m_parent != null) begin
      $sformat( s , "%s assumed to be parent for %s" ,
	      m_parent.m_name , m_leaf_name );
  
      avm_report_message( s_deprecated_3_0 , s , 500 );
  
      $sformat( s , "To upgrade %s change \"avm_named_component parent = null;\" to \"avm_named_component parent;\" " , m_leaf_name );
  
      avm_report_message( s_deprecated_3_0 , s , 500 );
  
      $sformat( s ,
       "To upgrade %s add \"this\" as 2nd argument to constructor of %s" ,
	      m_parent.m_name , m_leaf_name );
  
      avm_report_message( s_deprecated_3_0 , s , 500 );
	end
  
  endfunction 
    
  // This method allows us to completely remove all trace of a component
  // from the various avm datastructures.
  //
  // It is virtual to allow sub classes ( avm_threaded_component in
  // particular ) to delete this component from their datastructures at
  // the same time.
  //
  // At present, it can only be called during the construction phase
  //  

  virtual function void remove;

    string err_str;
    int i;

    avm_named_component children[string] = m_children;
  
  
    // remove children first
  
    foreach( children[c] ) begin   
      children[c].remove;  
    end
  
    // remove this from parent's child ( or orphan ) list
    if( m_parent != null ) begin

      if( !m_parent.m_children.exists( m_leaf_name) ) begin
	$sformat( err_str , "%s not in parent's child list" , m_name );
        avm_report_fatal("remove failed" , err_str );
      end
      
      m_parent.m_children.delete( m_leaf_name );
    end
    m_is_removed = 1;

  endfunction

  //
  // This method is used by connect to determine whether it is possible 
  // to connect to this component
  //
  
  function bit is_removed();
    return m_is_removed;
  endfunction

  //
  // This method looks up name in m_env. Name is the full hierarchical
  // name of this component
  //
  // returns null if m_env does not exist or if hierarchical name does
  // not exist
  //

  function avm_named_component absolute_lookup( string name );

    string env_name , remainder;
    string lookup_failure;
  
    if( m_env == null ) begin
      avm_report_warning( s_lookup_error , "no env" );
      return null;
    end

    extract_name( name , env_name , remainder );

    if( m_env.m_name != env_name ) begin
      $sformat( lookup_failure , "env is not called %s" , env_name );
      
      m_env.avm_report_warning( s_lookup_error , lookup_failure );
      return null;
    end

    return m_env.relative_lookup( remainder );
  
  endfunction
 
  //
  // this methods looks up name in m_children - returns null if the
  // hierarchical name does not exist
  //
  // name is the name of the component relative to this component
  // eg if we're in component i1.i2 and do a relative lookup on 13.i4
  // then we will return the component i1.i2.i3.i4, if there is one
  //

  function avm_named_component relative_lookup( string name );

    string leaf , remainder;
    string lookup_failure;
  
    extract_name( name , leaf , remainder );
  
    if( !m_children.exists( leaf ) ) begin
      $sformat( lookup_failure , "Cannot find child %s" , leaf );
      avm_report_warning( s_lookup_error , lookup_failure );
      return null;
    end

    if( remainder != "" ) begin
      return m_children[leaf].relative_lookup( remainder );
    end

    return m_children[leaf];
  endfunction

  local function void extract_name(
   input string name ,
   output string leaf ,
   output string remainder );

    int i , len = name.len();
    string extract_str;
  
    for( i = 0; i < name.len(); i++ ) begin  
      if( name[i] == "." ) begin
	break;
      end
    end

    if( i == len ) begin
      leaf = name;
      remainder = "";
      return;
    end

    leaf = name.substr( 0 , i - 1 );
    remainder = name.substr( i + 1 , len - 1 );

    return;
  endfunction
  
  // end_of_elaboration gets after all the components have been
  // connected up
  
  virtual function void end_of_elaboration();
  endfunction

  // a method used by to ensure top down ordering of end_of_elaboration
  // methods

  function void do_end_of_elaboration();

    if( m_parent != null ) begin
      build_debug_lists();
    end

    end_of_elaboration();

    foreach( m_children[s] ) begin
      m_children[s].do_end_of_elaboration();
    end

  endfunction 

  //
  // This method is purely for GUI debugging purposes.
  //
  // It populates the port, export, imp and component lists from the 
  // m_children list
  //
  
  local function void build_debug_lists();  
  
    foreach( m_children[s] ) begin
      m_children[s].add_to_debug_list();
    end
  
  endfunction

  //
  // This method is purely for GUI debugging purposes.
  //
  // By default, a named component goes in its parent's component list
  //
  // This method can be overriden by subclasses - in particular, 
  // avm_connection_base
  //
  
  protected virtual function void add_to_debug_list();
    m_parent.m_components[m_leaf_name] = this;
  endfunction

  // report is a virtual method which can be overloaded in a
  // sub class. It is called after the run method of the environment
  // class has completed

  virtual function void report();
  endfunction

  // a method used by to ensure bottom up ordering of report methods

  function void do_report();
    foreach( m_children[s] ) begin
      m_children[s].do_report();
    end
    report();
  endfunction

  // configure is a virtual method which can be overloaded in a sub
  // class. It is called immediately after the construction  phase

  virtual function void configure();
  endfunction

  // a method used by to ensure top down ordering of configure methods

  function void do_configure();
    configure();
    foreach( m_children[s] ) begin
      m_children[s].do_configure();
    end
  endfunction

  // flush is a virtual method which can be overloaded in a sub class.
  // It it is called by do_flush()
  
  virtual function void flush();
  endfunction

  //
  // a method used by to ensure bottom up ordering of flush methods
  //
  // This method is not called automatically by avm_env, it needs 
  // to be called explicitly when required.
  //
  
  function void do_flush();
    foreach( m_children[s] ) begin
      m_children[s].do_flush();
    end 
    flush();
  endfunction
  
  //
  // do_set_env is called before all the connection methods. It is used
  // to set the m_env handle
  //

  function void do_set_env( avm_env e );
    m_env = e;
    foreach( m_children[s] ) begin
      m_children[s].do_set_env( e );
    end
  endfunction

  
  // user visible virtual connection functions :
  // export_connections, connect and import_connections
  //
  // export_connections is a virtual method which is used to
  // make my children's exports available to my parent.

  protected virtual function void export_connections();
    // connections of the form export.connect( child.export );
  endfunction

  // import_connections is a virtual method which is used to
  // make my parent's ports available to my children

  protected virtual function void import_connections();
    // connections of the form child.port.connect( port );
  endfunction

  // connect is a virtual method which is used to connect my
  // children's ports to my children's exports

  protected virtual function void connect();
    // connections of the form child.port.connect( child.export );
  endfunction

  // exports propagate up the hierarchy 

  function void do_export_connections();
  
    // connect up children to grandchildren first
    foreach( m_children[s] ) begin
      m_children[s].do_export_connections();
    end

    // now do my connections
    export_connections();
   
  endfunction

  // do_connect happens to be bottom up, although it could
  // be top down
  
  function void do_connect();

    foreach( m_children[s] ) begin
      m_children[s].do_connect();
    end

    // now do my connections
    connect();
  endfunction
  
  // ports propagate down the hierarchy

  function void do_import_connections();

    // do my connections first
    import_connections();
 
    // now connect children to grandchildren
    foreach( m_children[s] ) begin
      m_children[s].do_import_connections();
    end

  endfunction

  // do_run_all is virtual to allow avm_threaded_components to spawn
  // their run methods ( bottom up )
  
  virtual task do_run_all();
    foreach( m_children[s] ) begin
      m_children[s].do_run_all();
    end
  endtask
  
  // kill_all is virtual to allow avm_threaded_components to kill
  // their run methods ( top down )
  
  virtual function void do_kill_all();
    foreach( m_children[s] ) begin
      m_children[s].do_kill_all();
    end
  endfunction  

  // recursively displays max_level levels of hierarchy
  
  virtual function void do_display( int max_level = -1 ,
				    int level = 0 ,
				    bit display_connectors = 0 );

    avm_report_message("hierarchy debug" , "" , 1000 );
  
    if( level == max_level ) begin
      return;
    end
 
   foreach( m_children[s] ) begin
      
      m_children[s].do_display( max_level ,
				level + 1 ,
				display_connectors );
      
    end
  endfunction

  //
  // runs through all connections at the end of elaboration, checking
  // that the minimum number of connections have been supplied to every
  // connector
  //

  virtual function void check_connection_size();
    foreach( m_children[s] ) begin
      m_children[s].check_connection_size();    
    end
  endfunction
    
  //--------------------------------------------------------------------
  // hierarchical reporting functions
  //--------------------------------------------------------------------

  // 
  //  recursively associates action a with reports of severity s 
  //

  function void set_report_severity_action_hier( severity s, action a);

    set_report_severity_action(s, a);

    foreach( m_children[c] ) begin
      m_children[c].set_report_severity_action_hier(s, a);
    end

  endfunction

  // 
  //  recursively associates action a with reports of id "id"
  //

  function void set_report_id_action_hier( string id, action a);

    set_report_id_action(id, a);

    foreach( m_children[c] ) begin
      m_children[c].set_report_id_action_hier(id, a);
    end

  endfunction

  // 
  // recursively associates action a with reports of severity s and
  // id "id"
  //

  function void set_report_severity_id_action_hier( severity s,
						    string id,
						    action a);

    set_report_severity_id_action(s, id, a);

    foreach( m_children[c] ) begin
      m_children[c].set_report_severity_id_action_hier(s, id, a);
    end

  endfunction

  // 
  // recursively associates FILE handle f with reports of severity s.
  //
  // If LOG is part of the action associated with this report, then the
  // report will be sent to the file(s) described by f
  //

  function void set_report_severity_file_hier( severity s, FILE f);

    set_report_severity_file(s, f);

    foreach( m_children[c] ) begin
      m_children[c].set_report_severity_file_hier(s, f);
    end

  endfunction

  // 
  // recursively associates FILE handle f with all reports from this
  // named component
  //
  // If LOG is part of the action associated with this report, then the
  // report will be sent to the file(s) described by f
  //
  function void set_report_default_file_hier( FILE f);

    set_report_default_file(f);

    foreach( m_children[c] ) begin
      m_children[c].set_report_default_file_hier(f);
    end
    
  endfunction

  // 
  // recursively associates FILE handle f with reports of id "id".
  //
  // If LOG is part of the action associated with this report, then the
  // report will be sent to the file(s) described by f
  //
  
  function void set_report_id_file_hier( string id, FILE f);

    set_report_id_file(id, f);

    foreach( m_children[c] ) begin
      m_children[c].set_report_id_file_hier(id, f);
    end

  endfunction

  // 
  // recursively associates FILE handle f with reports of severity s and
  // id "id".
  //
  // If LOG is part of the action associated with this report, then the
  // report will be sent to the file(s) described by f
  //

  function void set_report_severity_id_file_hier
    ( severity s,
      string id,
      FILE f);

    set_report_severity_id_file(s, id, f);

    foreach( m_children[c] ) begin
      m_children[c].set_report_severity_id_file_hier(s, id, f);
    end

  endfunction

  // 
  // recursively sets the maximum verbosity level for reports for 
  // this named component and all those below it
  //
  // If a report from these components exceeds this maximum, it will be
  // ignored
  //

  function void set_report_verbosity_level_hier(int v);

    set_report_verbosity_level(v);

    foreach( m_children[c] ) begin
      m_children[c].set_report_verbosity_level_hier(v);
    end
    
  endfunction  
  
endclass : avm_named_component



