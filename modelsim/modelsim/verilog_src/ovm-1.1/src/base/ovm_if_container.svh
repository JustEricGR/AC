// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_if_container.svh#1 $
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

`const int OVM_UNBOUNDED_CONNECTIONS = -1;

// This class exists because SV does not yet allow forward typedefs to
// parameterized classes (ovm_port_base)
virtual class ovm_port_base_base #(type IF = ovm_report_object) extends IF;

  pure virtual function void set_if(int i = 0);
  
endclass

class ovm_if_container #(type IF=int);

  typedef ovm_if_container #(IF) this_type;

  local int m_min_size;
  local int m_max_size; // bounds on the number of IFs

  // m_if_list holds the interfaces that (should) satisfy the
  // connectivity requirements of this. At the end of elaboration,
  // the size of this list must be between m_min_size and m_max_size
  
  local IF m_if_list[$];

  function new(int min_size = 0, int max_size = 0);
    m_min_size = min_size;
    m_max_size = max_size;
  endfunction

  //--------------------------------------------------------------------
  // accessor functions
  //--------------------------------------------------------------------

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

  function bit is_unbounded();
    return (m_max_size ==  OVM_UNBOUNDED_CONNECTIONS);
  endfunction
  
  function void copy(this_type c);
    for(int i = 0; i < c.m_if_list.size(); i++)
      m_if_list.push_back(c.m_if_list[i]);
  endfunction

  //--------------------------------------------------------------------
  // add_if
  //--------------------------------------------------------------------
  function bit add_if(IF ifc);

    //Check for already added interface
    for(int i=0; i<m_if_list.size(); ++i)
      if(m_if_list[i] == ifc) return 1;

    if(!is_unbounded() && (m_if_list.size() >= m_max_size))
      return 0;

    m_if_list.push_back(ifc);
    return 1;
    
  endfunction

  //--------------------------------------------------------------------
  // add_list
  //--------------------------------------------------------------------
  function bit add_list(this_type c);

    bit result;
    int unsigned i;

    result = 1;

    for(i = 0; i < c.m_if_list.size(); i++) begin
      result &= add_if(c.lookup_indexed_if(i));
    end

    return result;
    
  endfunction

  //--------------------------------------------------------------------
  // lookup_indexed_if
  //--------------------------------------------------------------------
  function IF lookup_indexed_if( int i = 0 );
    if ( i < 0 || i >= m_if_list.size() ) begin
      return null;
    end
    else begin
      return m_if_list[i];
    end
  endfunction

endclass
