// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/tlm/tlm_fifos.svh#1 $
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
// fifo definitions - blocking assignment version
//
// tlm_fifo is the basic fifo. It implements all the put,
// get and peek tlm interfaces.  analysis_fifo is an
// unbounded tlm_fifo which implements the write function
// defined in analysis_if.
//

// All the put ( + write ) methods share a single analysis
// port, put_ap. A write to this analysis port happens
// whenever a put completes or a try_put succeeds or a write
// occurs.
//
// All the get and peek methods share a single analysis
// port, get_ap. A write to this analysis port happens
// whenever a get or peek completes or a try_get or try_peek
// succeeds
//


//----------------------------------------------------------------------
// CLASS tlm_fifo
//----------------------------------------------------------------------

// begin codeblock tlm_fifo_header
class tlm_fifo #( type T = int ) extends avm_named_component;

  typedef tlm_fifo #( T ) this_type;
  
  avm_blocking_put_imp #( T , this_type ) blocking_put_export;
  avm_nonblocking_put_imp #( T , this_type ) nonblocking_put_export;
  avm_put_imp #( T , this_type ) put_export;
  
  avm_blocking_get_imp #( T , this_type ) blocking_get_export;
  avm_nonblocking_get_imp #( T , this_type ) nonblocking_get_export;
  avm_get_imp #( T , this_type ) get_export;
  
  avm_blocking_peek_imp #( T , this_type ) blocking_peek_export;
  avm_nonblocking_peek_imp #( T , this_type ) nonblocking_peek_export;
  avm_peek_imp #( T , this_type ) peek_export;
  
  avm_blocking_get_peek_imp #( T , this_type ) blocking_get_peek_export;
  avm_nonblocking_get_peek_imp #( T , this_type )
    nonblocking_get_peek_export;
  avm_get_peek_imp #( T , this_type ) get_peek_export;  

// end codeblock tlm_fifo_header caption path
  
  avm_analysis_port #( T ) put_ap , get_ap;
 
  local mailbox #( T) m;
  local int m_size;
  local int m_pending_blocked_gets;
  
  function new( string name , avm_named_component parent = null ,
		int size = 1 );
    super.new( name , parent , 0 );

    blocking_put_export = new("blocking_put_export" , this );
    nonblocking_put_export = new("nonblocking_put_export" , this );
    put_export = new("put_export" , this );

    blocking_get_export = new("blocking_get_export" , this );
    nonblocking_get_export = new("nonblocking_get_export" , this );
    get_export = new("get_export" , this );

    blocking_peek_export = new("blocking_peek_export" , this );
    nonblocking_peek_export = new("nonblocking_peek_export" , this );
    peek_export = new("peek_export" , this );
    
    blocking_get_peek_export = new("blocking_get_peek_export" , this );
    nonblocking_get_peek_export =
      new("nonblocking_get_peek_export" , this );
    get_peek_export = new("get_peek_export" , this );

    put_ap = new("put_ap" , this );
    get_ap = new("get_ap" , this );
    
    m = new( size );
    m_size = size;
    
  endfunction

  function int size();
    return m_size;
  endfunction
 
  task put( input T t );
    m.put( t );
    put_ap.write( t );
  endtask
    
  task get( output T t );
    m_pending_blocked_gets++;
    m.get( t );
    m_pending_blocked_gets--;
    get_ap.write( t );
  endtask
  
  task peek( output T t );
    m.peek( t );
    get_ap.write( t );
  endtask
   
  function bit try_put( input T t );
    if( !m.try_put( t ) ) begin
      return 0;
    end
  
    put_ap.write( t );
    return 1;
  endfunction  

  function bit try_get( output T t );
    if( !m.try_get( t ) ) begin
      return 0;
    end
  
    get_ap.write( t );
    return 1;
  endfunction 
  
  function bit try_peek( output T t );
    if( !m.try_peek( t ) ) begin
      return 0;
    end
  
    get_ap.write( t );
    return 1;
  endfunction
  
  function bit can_put();
    return m_size == 0 || m.num() < m_size;
  endfunction  

  function bit can_get();
    return m.num() > 0 && m_pending_blocked_gets == 0;
  endfunction
  
  function bit can_peek();
    return m.num() > 0;
  endfunction

  function void flush();
    T t;
  
    while( try_get( t ) );
    
    if( m.num() > 0 && m_pending_blocked_gets != 0 ) begin
      avm_report_error("flush failed" ,
		       "there are blocked gets preventing the flush");
    end
  
  endfunction
 
endclass 

 
//----------------------------------------------------------------------
// CLASS analysis_fifo
//----------------------------------------------------------------------

// An analysis_fifo is an unbounded tlm_fifo that also implements and 
// exports the write interfaces.
//
// It is very useful in objects such as scoreboards which need to be
// connected to monitors.

class analysis_fifo #( type T = int ) extends tlm_fifo #( T );

  avm_analysis_imp #( T , analysis_fifo #( T ) ) analysis_export;

  function new( string name  ,  avm_named_component parent = null );
    super.new( name , parent , 0 ); // analysis fifo must be unbounded

    analysis_export = new( "analysis_export" , this );

  endfunction

  function void write( input T t );
    void'(this.try_put( t )); // unbounded => must succeed
  endfunction

endclass
