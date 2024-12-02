// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/vbase/avm_vbase.svh#1 $
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


const string s_deprecated_3_0 = "Deprecated in AVM 3.0 and later";

// This class is used to indicate "no valid default value" in a parameter
virtual class avm_virtual_class; endclass

`include "vbase/avm_transaction.svh"
`include "vbase/avm_policies.svh"
`include "vbase/avm_named_component.svh"
`include "vbase/avm_connector_base.svh"
`include "vbase/avm_port_base.svh"

