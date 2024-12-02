// $Id: //dvt/mti/rel/6.5b/src/misc/avm_src/reporting/avm_extern_report_server.svh#1 $
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

  //--------------------------------------------------------------------
  // process_report
  //--------------------------------------------------------------------
function void avm_report_server::process_report(
						severity s,
						string name,
						string id,
						string message,
						action a,
						FILE f,
						string filename,
						int line,
						int verbosity,
						avm_report_client client
						);

   string m;
     
   // update counts
   incr_severity_count(s);
   incr_id_count(id);
   
   m = compose_message(s, name, id, message, filename, line); 
   
   
   if(a & DISPLAY)
   case(1)
     (name == "" && filename == "" ):
	    $messagelog("** %s:%:~S @ %0t [%:I] %s%:~V%:~C",
			s.name, s.name, $time, id ,message, verbosity,"AVM");
     (name != "" && filename == "" ):
	    $messagelog("** %s:%:~S @ %0t: %:R [%:I] %s%:~V%:~C",
			s.name, s.name, $time, name, id ,message, verbosity,"AVM");
     (name == "" && filename != "" ):
	    $messagelog("** %s:%:~S %:F(%:0L) @ %0t [%:I] %s%:~V%:~C",
			s.name, s.name, filename, line, $time, id ,message, verbosity,"AVM");
     (name != "" && filename != "" ):
	    $messagelog("** %s:%:~S %:F(%:0L) @ %0t: %:R [%:I] %s%:~V%:~C",
			s.name, s.name, filename, line, $time, name, id ,message, verbosity,"AVM");
   endcase // case (1)
   
   if(a & LOG) begin
      if(f != 0 || !(a & DISPLAY)) // no point displaying twice !
	begin 
           $fdisplay(f, m);
	end
   end
   
   if(a & EXIT) client.die();
   
   if(a & COUNT) begin
      if(get_max_quit_count() != 0) begin
         incr_quit_count();
         if(is_quit_count_reached()) begin
            client.die();
         end
      end  
   end
   
endfunction

//--------------------------------------------------------------------
// compose_message
//--------------------------------------------------------------------
function string  avm_report_server::compose_message(severity s,
						    string name,
						    string id,
						    string message,
						    string filename,
						    int line);
      
   
      string time_str;
      string line_str;
      
   
      $swrite(time_str, "%0t", $time);
      $swrite(line_str, "%0d", line);
   
      case(1)
	(name == "" && filename == ""):
	       return {"** ", s.name, ": @ ", time_str, " [", id, "] ", message};
	(name != "" && filename == ""):
	       return {"** ", s.name, ": @ ", time_str, ": ", name, " [", id, "] ", message};
	(name == "" && filename != ""):
		 return {"** ", s.name, ": ",filename, "(", line_str, ")", " @ ", time_str, " [", id, "] ", message};
	(name != "" && filename != ""):
	       return {"** ", s.name, ": ",filename, "(", line_str, ")", " @ ", time_str, ": ", name, " [", id, "] ", message};
      endcase // case(1)
      
endfunction

