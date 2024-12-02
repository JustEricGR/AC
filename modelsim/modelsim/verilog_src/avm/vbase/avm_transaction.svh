// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/vbase/avm_transaction.svh#1 $
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

// Any given transaction type T must extend this class and
// therefore provide an implementation of convert2string and clone
// 
// In addition, it must also provide :
//  function void copy( input T t );
//  function bit comp( input T a , input T b );
// 
// These functions are used in the functors in policies.svh,
// which are in turn used in tlm_fifos.svh and
// in_order_comparator.svh, as well as being generally
// useful
//
// We do not put copy and comp in the base class since the
// signature involves T. Neither method is virtual, although they
// might well call super.copy and super.comp when defined in a subclass
//
// The usual implementation of clone is 
//
// function avm_transaction clone();
//   T t = new();
//   t.copy( this );
//   return t;
// endfunction
//
// Alternatively, the AVM_CLONE_METHOD may be used :
//
// `include "avm_macros.svh" 
// 
// 'AVM_CLONE_METHOD( T );
//
// and then to do a clone in a task, do :
//
// T new_t;
// $cast( new_t , t.clone() );
//
// Alternatively, the AVM_CLONE macro may be used :
//
// `include "avm_macros.svh"
//
// T new_t;
// `AVM_CLONE( new_t , t )
//

virtual class avm_transaction;

  pure virtual function avm_transaction clone;
  pure virtual function string convert2string;

endclass
