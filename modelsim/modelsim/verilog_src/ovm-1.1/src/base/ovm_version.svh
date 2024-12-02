// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_version.svh#1 $
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

`ifndef OVM_VERSION_SVH
`define OVM_VERSION_SVH

string ovm_name = "OVM";
int    ovm_major_rev = 1;
int    ovm_minor_rev = 1;
string    ovm_fix_rev = "update-1";
string ovm_mgc_copyright = "(C) 2007-2009 Mentor Graphics Corporation";
string ovm_cdn_copyright = "(C) 2007-2008 Cadence Design Systems, Inc.";

function string ovm_revision_string();
  string s;
  if(ovm_fix_rev == "")
    $sformat(s, "%s-%1d.%1d", ovm_name, ovm_major_rev, ovm_minor_rev, ovm_fix_rev);
  else
    $sformat(s, "%s-%1d.%1d.%s", ovm_name, ovm_major_rev, ovm_minor_rev, ovm_fix_rev);
  return s;
endfunction

`endif // OVM_VERSION_SVH
