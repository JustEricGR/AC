//              Copyright 2006-2007 Mentor Graphics Corporation
//                           All Rights Reserved.
//
//              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                  TERMS.
//
//                   Questa Verification Library (QVL)
//

  integer error_count;
  initial error_count = 0;

  task qvl_error_t;
    input [8*256-1:0] err_msg;
    input [8*256-1:0] msg;
    input      [31:0] severity_level;
    input      [31:0] property_type;
    reg    [8*16-1:0] err_typ;
  begin
    error_count = error_count + 1;
    `ifdef QVL_SYNTHESIS_OFF
    `else
      case (severity_level)
        `QVL_FATAL   : err_typ = "QVL_FATAL";
        `QVL_ERROR   : err_typ = "QVL_ERROR";
        `QVL_WARNING : err_typ = "QVL_WARNING";
        `QVL_INFO    : err_typ = "QVL_INFO";
        default      : begin
                         err_typ = "QVL_ERROR";
                         $display("QVL_ERROR: Illegal option used in parameter severity_level, setting message type to QVL_ERROR : time %0t : %m", $time);
                       end
      endcase
      `ifdef QVL_MAX_REPORT_ERROR
        if (error_count <= `QVL_MAX_REPORT_ERROR) begin
      `endif
          case (property_type) 
            `QVL_ASSERT,
            `QVL_ASSUME : $display("%s : %0s : %0s : severity %0d : time %0t : %m",
                    err_typ, err_msg, msg, severity_level, $time);
            `QVL_IGNORE :
                    begin
                      // do nothing
                    end
            default     : $display("QVL_ERROR: Illegal option used in parameter property_type : time %0t : %m", $time);
          endcase
      `ifdef QVL_MAX_REPORT_ERROR
        end
      `endif
      if (severity_level == `QVL_FATAL) qvl_finish_t;
    `endif // QVL_SYNTHESIS_OFF
    end
  endtask

  task qvl_finish_t;
    begin
    `ifdef QVL_SYNTHESIS_OFF
    `else
      #`QVL_RUNTIME_AFTER_FATAL $finish;
    `endif // QVL_SYNTHESIS_OFF
    end
  endtask

