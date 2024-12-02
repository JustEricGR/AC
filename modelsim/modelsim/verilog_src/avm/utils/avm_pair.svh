// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/utils/avm_pair.svh#1 $
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
// paramterized pair classes
//

class avm_class_pair #( type T1 = int ,
			type T2 = T1 )
  
  extends avm_transaction;

  typedef avm_class_pair #( T1 , T2 ) this_type;
  
  T1 first;
  T2 second;

  function new( input T1 f = null , input T2 s = null );
    if( f == null ) begin
      first = new;
    end
    else begin
      first = f;
    end
    if( s == null ) begin
      second = new;
    end
    else begin
      second = s;
    end
  endfunction  
  
  function string convert2string;
    string s;

    $sformat( s , "pair : %s , %s" ,
	      first.convert2string() ,
	      second.convert2string() );
    
    return s;    
  endfunction

  function bit comp( this_type t );
    return t.first.comp( first ) && t.second.comp( second );
  endfunction

  function void copy( input this_type t );
    first.copy( t.first );
    second.copy( t.second );
  endfunction

  function avm_transaction clone;
    this_type t = new;
    t.copy( this );
    return t;
  endfunction
  
endclass

class avm_built_in_pair #( type T1 = int ,
			   type T2 = T1 )
  
  extends avm_transaction;

	
  typedef avm_built_in_pair #( T1 , T2 ) this_type;
  
  T1 first;
  T2 second;

  function new( input T1 f=null , input T2 s=null);
      first = f;
      second = s;
  endfunction  
  

  
  virtual function string convert2string;
    string s;

    $sformat( s , "built-in pair : %p , %p" ,
	      first ,
	      second );

    return s;
  endfunction

  function bit comp( this_type t );
    return t.first == first && t.second == second;
  endfunction

  function void copy( input this_type t );
    first = t.first;
    second = t.second;
  endfunction
  
  function avm_transaction clone;
    this_type t = new;
    t.copy( this );
    return t;
  endfunction

endclass
