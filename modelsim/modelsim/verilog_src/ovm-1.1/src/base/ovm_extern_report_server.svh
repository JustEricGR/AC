// $Id: //dvt/mti/rel/6.5b/src/misc/ovm_src/ovm-1.1/src/base/ovm_extern_report_server.svh#1 $
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

`ifndef OVM_EXTERN_REPORT_SERVER_SVH
`define OVM_EXTERN_REPORT_SERVER_SVH


  //--------------------------------------------------------------------
  // report
  //
  // add line and file info later ...
  //
  // this is the public access report function. It is not
  // visible to the user but is accessed via
  // ovm_report_info, ovm_report_warning,
  // ovm_report_error and ovm_report_fatal.
  //--------------------------------------------------------------------
  function void ovm_report_server::report(
      ovm_severity s,
      string name,
      string id,
      string mess,
      int verbosity_level,
      string filename,
      int line,
      ovm_report_object client
      );
  
    string m;
    ovm_action a;
    OVM_FILE f;
    bit report_ok;
    ovm_report_handler rh;

    rh = client.get_report_handler();
    
    // filter based on verbosity level
 
    if(verbosity_level > rh.m_max_verbosity_level) begin
       return;
    end

    // determine file to send report and actions to execute

    a = rh.get_action(s, id); 
    if( a == OVM_NO_ACTION )
      return;

    f = rh.get_file_handle(s, id);

    // The hooks can do additional filtering.  If the hook function
    // return 1 then continue processing the report.  If the hook
    // returns 0 then skip processing the report.

    if(a & OVM_CALL_HOOK)
      report_ok = rh.run_hooks(client, s, id, mess, verbosity_level, filename, line);
    else
      report_ok = 1;

    if(report_ok) begin
      m = compose_message(s, name, id, mess, filename, line); 
      process_report(s, name, id, mess, a, f, filename, line, m, verbosity_level, client);
    end
    
  endfunction


  //--------------------------------------------------------------------
  // process_report
  //--------------------------------------------------------------------
  function void  ovm_report_server::process_report(
      ovm_severity s,
      string name,
      string id,
      string message,
      ovm_action a,
      OVM_FILE f,
      string filename,
      int line,
      string composed_message,
      int verbosity_level,
      ovm_report_object client
    );

    // update counts
    incr_severity_count(s);
    incr_id_count(id);

    if(a & OVM_DISPLAY)
     begin
	typedef enum
		    {
		     MESSAGE,
		     WARNING,
		     ERROR,
		     FATAL
		     } severity;
	ovm_severity_type osv;
	severity asv;
	osv = ovm_severity_type'(s);
	asv = severity'(s);
	case(1)
	  (name == "" && filename == "" ):
		 $messagelog("%s%:~S @ %0t [%:I] %s%:~V%:~C",
			     osv.name, asv.name, $time, id ,message, verbosity_level,"OVM");
	  (name != "" && filename == "" ):
	    $messagelog("%s%:~S @ %0t: %:R [%:I] %s%:~V%:~C",
			osv.name, asv.name, $time, name, id ,message, verbosity_level,"OVM");
	  (name == "" && filename != "" ):
	    $messagelog("%s%:~S %:F(%:0L) @ %0t [%:I] %s%:~V%:~C",
			osv.name, asv.name, filename, line, $time, id ,message, verbosity_level,"OVM");
	  (name != "" && filename != "" ):
	    $messagelog("%s%:~S %:F(%:0L) @ %0t: %:R [%:I] %s%:~V%:~C",
			osv.name, asv.name, filename, line, $time, name, id ,message, verbosity_level,"OVM");
	endcase // case (1)
     end

    if(a & OVM_LOG) begin
      if(f != 0 || !(a & OVM_DISPLAY)) // no point displaying twice !
      begin 
        $fdisplay(f, composed_message);
      end
    end

    if(a & OVM_EXIT) client.die();

    if(a & OVM_COUNT) begin
      if(get_max_quit_count() != 0) begin
        incr_quit_count();
        if(is_quit_count_reached()) begin
          client.die();
        end
      end  
    end

    if (a & OVM_STOP) $stop;

  endfunction

  //--------------------------------------------------------------------
  // compose_message
  //--------------------------------------------------------------------
  function string  ovm_report_server::compose_message(
    ovm_severity s,
    string name,
    string id,
    string message,
    string filename,
    int    line						     
);
     ovm_severity_type sv;
     string time_str;
     string line_str;
      
     sv = ovm_severity_type'(s);
     $swrite(time_str, "%0t", $time);
     $swrite(line_str, "%0d", line);
   
     case(1)
       (name == "" && filename == ""):
	      return {sv.name(), " @ ", time_str, " [", id, "] ", message};
       (name != "" && filename == ""):
	      return {sv.name(), " @ ", time_str, ": ", name, " [", id, "] ", message};
       (name == "" && filename != ""):
		return {sv.name(), " ",filename, "(", line_str, ")", " @ ", time_str, " [", id, "] ", message};
       (name != "" && filename != ""):
	        return {sv.name(), " ", filename, "(", line_str, ")", " @ ", time_str, ": ", name, " [", id, "] ", message};
     endcase // case(1)
  endfunction 

`endif // OVM_EXTERN_REPORT_SERVER_SVH
