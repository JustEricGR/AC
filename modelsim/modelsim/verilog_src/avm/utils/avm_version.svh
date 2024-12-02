// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/utils/avm_version.svh#1 $
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

string avm_name = "AVM";
int    avm_major_rev = 3;
int    avm_minor_rev = 0;
string avm_sub_rev = "update-4";
string avm_configuration = "-MTI";
string avm_copyright = "(C) 2005-2009 Mentor Graphics Corporation";

function string avm_revision_string();
  string s;
  $sformat(s, "%s-%1d.%1d-%s%s", avm_name, avm_major_rev, avm_minor_rev, avm_sub_rev, avm_configuration);
  return s;
endfunction
