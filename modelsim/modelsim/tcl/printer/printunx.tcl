################################################################
# Printer package for Unix
# Emulate printer package for NT in a "reasonable" way
# RCS Revision History
# $Log: printunx.tcl,v $
# Revision 1.9  2002/10/09 13:48:58  navy
# N-up removed from Page-setup diolog on unix.
#
# Revision 1.8  2002/09/16 18:22:01  bkb
# Joined
#
# Revision 1.6  2002/06/10 17:52:51  navy
# printunx.tcl - selection drop in dialogs solved
#
# Revision 1.5  2002/05/22 12:51:00  bkb
# Next update from NAVY
#
# Revision 1.4  2002/05/11 17:16:30  bkb
# Print dialog updated
#
# Revision 1.3  2002/04/02 15:45:45  bkb
# Page Setup dialog extended
#
# Revision 1.2  2002/01/14 11:26:00  bkb
# Page Setup dialog added
#
# Revision 1.1  2001/11/16 15:59:47  bkb
# Initial version
#
# Revision 1.6  1998/05/03  16:49:42  Michael_Schwartz
# Initial tests with OSF/1 complete successfully
#
# Revision 1.5  1998/04/19  18:40:03  Michael_Schwartz
# Added selection and setup dialogs.
#
# Revision 1.4  1998/04/16  05:11:34  Michael_Schwartz
# Better tracking for list versus entry; removed unused code
#
# Revision 1.3  1998/04/16  04:22:54  Michael_Schwartz
# Combined with tkPBox.tcl.
# Updated to make nominal cases succeed.
#
# Revision 1.2  1998/04/14  22:43:35  Michael_Schwartz
# Added initial bodies for most commands.
#
################################################################
## Copyright (C) Schwartz Computer Consulting Services, 1998
##
## {LICENSE}
## 
## THE AUTHORS HEREBY GRANT PERMISSION TO USE, COPY, MODIFY, DISTRIBUTE,
## AND LICENSE THIS SOFTWARE AND ITS DOCUMENTATION FOR ANY PURPOSE, PROVIDED
## THAT EXISTING COPYRIGHT NOTICES ARE RETAINED IN ALL COPIES AND THAT THIS
## NOTICE IS INCLUDED VERBATIM IN ANY DISTRIBUTIONS. 
##
## NO WRITTEN AGREEMENT, LICENSE, OR ROYALTY FEE IS REQUIRED FOR ANY OF THE
## AUTHORIZED USES.
## 
## MODIFICATIONS TO THIS SOFTWARE MAY BE COPYRIGHTED BY THEIR AUTHORS
## AND NEED NOT FOLLOW THE LICENSING TERMS DESCRIBED HERE, PROVIDED THAT
## THE NEW TERMS ARE CLEARLY INDICATED ON THE FIRST PAGE OF EACH FILE WHERE
## THEY APPLY.
## 
## IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT,
## INDIRECT, SPECIAL, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING OUT OF
## THE USE OF THIS SOFTWARE, ITS DOCUMENTATION,  OR ANY DERIVATIVES
## THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.
## 
## THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
## INCLUDING, BUT NOT LIMITED TO,  THE IMPLIED WARRANTIES OF
## MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. 
## THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
## DISTRIBUTORS HAVE NO OBLIGATION  TO PROVIDE MAINTENANCE, SUPPORT,
## UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
## 
################################################################

# Need to initiate the namespace or it doesn't exist
namespace eval printer { }


# Global variables related to the printer
proc printer::init_globals { } {
  global printer::channel       ;# Global channel for multiple pipes to printer
  global printer::lpcmd         ;# Print command name
  global printer::lpcmd_devarg  ;# Flag for printer command to specify a device
  global printer::lpcmd_device	;# Value for the printer queue device (name from lpstat)
  global printer::lplistcmd     ;# Basis of printer list command
  global printer::commandlist   ;# List of allowable subcommands for printer 
  global printer::usage         ;# Standard usage message
  global printer::lpcmd_extra	;# Additional arguments to the lp command
  global printer::lplist_usecache ;# Flag (non-zero) to preserve list of printers
  global printer::commandlist_attr ;# List of allowable subcommands for printer attr
  global printer::attr		;# Array of printer attributes
  global printer::known_media	;# List of _enscript_ known medias
  global printer::known_media_params ;# Array of _enscript_ known media params
  global printer::conv_factor   ;# page sizes conversion factor - 1000 for inch
#  global printer::current_media	   ;# Current media prototype
#  global printer::current_media_param ;# Current media param 

  # It's possible that the actual locations of lp and lpstat may differ by system
  # e.g., /bin vs. /usr/bin.
  # In that case, the plan is to create a table by OS type or version, and make
  # the set as a result of a switch statement.
  # Storing the results in a profile table will work as well
  set printer::channel          ""
  set printer::lpcmd   		/bin/lp
  set printer::lpcmd_devarg     -d
  set printer::lplistcmd	"/bin/lpstat -a"
  set printer::commandlist      {attr close dialog job list open page send version}
  set printer::lpcmd_extra      ""
  set printer::lplist_usecache 0
  set printer::commandlist_attr {-get -set}
  set printer::attr(enscript_extra_opt) ""
  set printer::conv_factor "1000.0"
  set printer::attr(rangePageFrom) 0
  set printer::attr(rangePageTo) 0
  set printer::attr(PItemSel) pAll ; #Possible values pAll pPageRange pSelection
  set printer::attr(print_to_file_flag) 0
  set printer::attr(output_file) ""
  set printer::attr(CurrTextSel) {{} {}}

  set printer::usage { Usage:
    printer attr [-get|-set] ["data label" data] 
    printer close
    printer dialog [select|page_setup] [-flags flagsnum]
    printer job [start|end]
    printer list [-match matchstring]
    printer open
    printer page [start|end]
    printer send [-postscript|-nopostscript] [-hDC hdc] [-printer pname]
                 [-file|-data] file_or_data ...
    printer version
  }
}

################################################################
## printer
## This procedure looks up the subcommand, returning the usage
## message if unsuccessful.
################################################################
proc printer { args } {
  global printer::usage

  set cmd [lindex $args 0]
  if { [lsearch $printer::commandlist $cmd] == -1 } {
    error $printer::usage
  }
  eval printer::$cmd [lrange $args 1 end]  
}

################################################################
## attr
## This function returns the current set of printer attributes
## This should model the NT version as closely as possible.
## Thus, the attributes to be considered are:
## copies, first page, last page, hDC, device, page orientation,
## resolution, pixels per inch, page dimensions, page margins,
## page minimum margins 
################################################################
proc printer::attr { args } {
  variable attr
  global printer::channel
  global printer::lpcmd_device

  if { $printer::channel == "" } {
    set hDC ?
  } else {
    set hDC $printer::channel
  }

  if { ![ info exist printer::lpcmd_device ] || $printer::lpcmd_device == "" } {
    set dev default
  } else {
    set dev $printer::lpcmd_device
  }

  set tmp_args [ lindex $args 1 ]
  set retval {}
  switch -- [ lindex $args 0 ] {
    -get {
	   foreach tmp0 $tmp_args {
	     if [catch { set tmp1 $attr($tmp0) }] {
	       lappend retval [ ::list $tmp0 ?]
	     } else { 
	       lappend retval [ ::list $tmp0 $tmp1 ]
	     }
	   }
    }
    -set {
#           puts "TMP ARGS $tmp_args"
	   foreach tmp0 $tmp_args {
	     set attr([ lindex $tmp0 0 ]) [ lindex $tmp0 1 ]
#		 #foreach tmp00 [array names attr ] {
#		 #puts "[ ::list $tmp00 $attr($tmp00) ]"
#		 #}
#	     puts "key [lindex $tmp0 0] val [ lindex $tmp0 1] "
	   }
	   #set retval 1
    }
    -getall {
	   foreach tmp0 [array names attr ] {
	     lappend retval [ ::list $tmp0 $attr($tmp0) ]
	   }
    }
    default	{
		lappend retval [::list copies ?]
		lappend retval [::list "first page" ?]
		lappend retval [::list "last page"  ?]
		lappend retval [::list "hDC" $hDC]
		lappend retval [::list device $dev]
		lappend retval [::list "page orientation"  ?]
		lappend retval [::list "resolution"  ?]
		lappend retval [::list "pixels per inch"  ?]
		lappend retval [::list "page dimensions"  "? ?"]
		lappend retval [::list "page margins"  "? ? ? ?"]
		lappend retval [::list "minimum page margins"  "? ? ? ?"]
		}
  }
  return $retval
}

################################################################
## close
## This procedure closes any open printer channel and blanks
## out the channel variable
################################################################
proc printer::close { args } {
  # This command closes and invalidates the global channel
  global printer::channel
  if { [string length $printer::channel] > 0 } {
    ::close $printer::channel
    set printer::channel ""
  }
}

################################################################
## dialog
## Bring up either the printer selection dialog or the page_setup
## dialog
## For Unix, these provide the way to set the printer and 
## provide any other arbitrary arguments to the print command.
################################################################
proc printer::dialog { args } {
  global printer::lpcmd         ;# Print command name
  global printer::lpcmd_devarg  ;# Flag for printer command to specify a device
  global printer::lplistcmd     ;# Basis of printer list command
  global printer::lpcmd_extra	;# Additional arguments to the lp command
  global printer::usage		;# Usage error message
  # [select|page_setup] [-flags flagsnum] 
  global printer::lpcmd_device	;# Value for the printer queue device (name from lpstat)
   global env

  # To be equivalent to the NT printing model, these functions should
  # actually open the channel to the selected printer.
  # However, for now, as the "generic" printer model is still under thought,
  # I'll be a bit schizoid and let this version just return the selected printer
  # name. It will set the "global" default for this printer for all future "opens",
  # though.
  switch [lindex $args 0] {
    select	{
		  ;# Build a single-selection list; highlight current device
		  set result [ tkPDialog -printers [printer::list] ]
if { 0 } {
		  if { [lindex $result 0] != 0 } {
		    set printer::lpcmd_device [lindex $result 1]
		    if { [lindex $result 0] == 2 } {
             # profile package name was changed from package to htePackage because 
             # of a naming collision with ModelSim's profile package       
            if [ catch { package require hteProfile } err ] {
                        ;# Do nothing if we can't set global values...
                      } else {
			  if [info exists env(TCL_PRINTER_CONFFILE)] {
			      hteProfile set -private $env(TCL_PRINTER_CONFFILE) \
				      -section Printer -key Default -value $printer::lpcmd_device
			  } else {
			      hteProfile set -section Printer -key Default -value $printer::lpcmd_device
			  }
                      }
                    }
		  }
}
		  return $result	;# Actually, should return an "hDC" equivalent
		}
    page_setup	{
		  ;# OLD Build a single entry widget; initialize with lpcmd_extra
		  ;# now tkPOption returns no list but only 0 - Cancel, 1 - Ok)
 		  set result [ tkPOption ] ;#-options $printer::lpcmd_extra 
if { 0 } {
		  if { [lindex $result 0] != 0 } {
                    set printer::lpcmd_extra [lindex $result 1]
		    if { [lindex $result 0] == 2 } {
            # profile package name was changed from package to htePackage because 
            # of a naming collision with ModelSim's profile package
            if [ catch { package require hteProfile } err ] {
                        ;# Do nothing if we can't set global values...
                      } else {
			  if [info exists env(TCL_PRINTER_CONFFILE)] {
			      hteProfile set -private $env(TCL_PRINTER_CONFFILE) \
				      -section Printer -key Extra -value $printer::lpcmd_extra
			  } else {
			      hteProfile set \
				      -section Printer -key Extra -value $printer::lpcmd_extra
			  }
                      }
                    }
                  }
}
                  return $result
		}
    default	{
		  error $printer::usage
		}
  }
}

################################################################
## job
## Jobs are started or ended
## Start will open/reopen the printer channel, using the previous
## printer command.
## End will close the printer channel.
################################################################
proc printer::job { args } {
  # [start|end] 
  # Under NT, it initializes/closes a job.
  # The best equivalent under Unix is to close and reopen a print job for start,
  # and to close and flush a print job for end.
  global printer::lpcmd_last
  global printer::usage
  global printer::jobstate
  global printer::channel
  global printer::debug

  switch [lindex $args 0 ] {
    start {
            if { [info exist printer::lpcmd_last] == 0 } {
              error "Can't start print job until printer is open\n$printer::usage"
            }
	    if { [info exist printer::jobstate] && $printer::jobstate == 1 } {
	      # Restart a new job after closing the last one
              if { $printer::channel != "" } {
	        ::close $printer::channel
	      }
              # To avoid actually printing reams of paper while testing...
	      if [ info exist printer::debug ] {
	        puts "I would open $printer::lpcmd_last for write"
	      } else {
                set printer::channel [::open "|$printer::lpcmd_last" w]
	      }
            }
            
            set printer::jobstate 1
          }
    end   {
            if { [info exist printer::lpcmd_last] == 0 } {
              error "Can't stop print job until printer is open\n$printer::usage"
            }
	    if { [info exist printer::jobstate] == 0 || $printer::jobstate != 1 } {
	      error "Can't stop print job until it is started\n$printer::usage"
            }
            set printer::jobstate 0
	    if { [string length $printer::channel] > 0 } {
              ::close $printer::channel
	    }
            set $printer::channel ""
          }
    default {
	    error "printer job [start|stop]\n$printer::usage"
          }
  }
}

################################################################
## list
## Returns the list of printers; this is the same list that 
## is displayed in the printer dialog select command.
## Like the Windows version, the match currently is not supported
################################################################
proc printer::list { args } {
  # [-match matchstring] 
  # This one is difficult only because lpstat and lpq have such different results.
  # For now, build to lpstat model--1st arg on each line is the item
  # If we get fancy, the 2nd arg should be "accepting"
  global printer::lplistcmd     ;# Basis of printer list command
  global printer::lplist
  global printer::lplist_usecache
  global printer::lpcmd_device

  if { [info exist printer::lplist] && [info exist printer::lplist_usecache] } {
    if { $printer::lplist_usecache != 0 } {
      return $printer::lplist
    }
  }

  set printer::lplist ""
  catch {
    set fd [ ::open "|$printer::lplistcmd" r ]

    while { [ gets $fd line ] > 0 } {
      # If the last character is a colon, this is probably an lpq-type command
      if { [string range $line end end] == ":" } {
        # Everything is cool if we skip the colon
        lappend printer::lplist [ string trimright $line :]
      } elseif { [string range $line 0 0] == " " || [ string range $line 0 0 ] == "\t" } {
        ;# It's an lpq-type command--ignore these lines
      } else {
        # Otherwise, it's pretty normal--just use the first word
        lappend printer::lplist [lindex $line 0]
      }
    }

    ::close $fd
  } err

  # If a specific device has already been selected, allow it to be
  # selected again.
  if [ info exist printer::lpcmd_device ] {
    if { [lsearch -exact $printer::lplist $printer::lpcmd_device] == -1 } {
      lappend printer::lplist $printer::lpcmd_device
    }
  }

  return $printer::lplist   
}

################################################################
## open
## This command will open the currently specified printer using
## the configured command, or open the default printer if nothing
## else is specified.
################################################################
proc printer::open { args } {
  # Should open a file output to the selected printer & return the file handle
  # For now, assume the first argument is a printer name, and ignore all others.
  # The caller will have to handle any exceptions raised, since no policy can
  # be established by this routine.
  global printer::lpcmd
  global printer::lpcmd_devarg
  global printer::lpcmd_device	;# Value for the printer queue device (name from lpstat)
  global printer::lpcmd_last
  global printer::channel
  global printer::debug

  set cmd $printer::lpcmd

  if { [llength $args] > 0 } {
    set cmd "$cmd $printer::lpcmd_devarg[lindex $args 0]"
  } elseif [info exist printer::lpcmd_device] {
    set cmd "$cmd $printer::lpcmd_devarg$printer::lpcmd_device"
  }

  set printer::lpcmd_last $cmd
  # To test without printing, the following debug is added
  if [ info exist printer::debug ] {
    puts "I would open $cmd for write"
  } else {
    set printer::channel [::open "|$cmd" w]
  }
  return $printer::channel
}

################################################################
## page
## Provided for compatibility; to do anything useful, at a minimum
## the type of file currently printed would need to be known.
## Currently ignored.
################################################################
proc printer::page { args } {
  # Not sure how to handle this. For postscript and text printers it's easy, though.
  # [start|end] 
  # For now, just ignore it.
}


################################################################
## Copy a file to a given open file descriptor.
################################################################
proc printer::copyfile { src destpipe } {
  set file [ ::open $src r ]
  fcopy $file $destpipe
  ::close $file
  flush $destpipe
}

################################################################
## send
# Lots of possibilities for send.
# It can get data or files to send to the printer
#   Files must be opened and data copied to the printer (or name sent to lp command line)
#   Data must be written to the printer standard input.
# It can open the files in binary or text mode (irrelevant in Unix(?))
# It can send to a named printer or to an open pipe.
#   For a named printer, it must open its own connection and close when done.
#   For an open pipe, it must NOT open its own connection and NOT close when done.
#    printer send [-postscript|-nopostscript] [-hDC hdc] [-printer pname]
#                 [-file|-data] file_or_data ...
#
# Strategy: Put the output in a temporary file and then send it all at once.
# This will best emulate what's happening under Windows
################################################################
proc printer::send { args } {

  global printer::lpcmd         ;# Print command name
  global printer::lpcmd_devarg  ;# Flag for printer command to specify a device
  global printer::lplistcmd     ;# Basis of printer list command
  global printer::lpcmd_device	;# Default printer
  global printer::lpcmd_extra	;# Additional arguments
  global printer::channel

  # to make it working in a new way.
  set printer::lpcmd $printer::attr(lpcmd)

  set tmpfile "/tmp/Printer[expr int(rand() * 10000)]"
  set execprog 1
  set pipe ""
  set postscript 1
  set source file
  set nxtptr 0
  set echopart ""
  set printerpart ""
  set lppart $printer::lpcmd
  set files ""
  set datacount 0
  set filecount 0
  set status {}

  # file is still coming as an arg
  #why to copy it ??!!
  
  if [ info exist printer::channel ] {
    if [ string length $printer::channel ] {
      set outpipe $printer::channel
    }
  }
  
  if [info exist printer::lpcmd_device] {
    set printerpart "$printer::lpcmd_devarg$printer::lpcmd_device"
  }
  if [info exist printer::lpcmd_extra] {
    set printerpart "$printerpart $printer::lpcmd_extra"
  }

  if [ catch { ::open $tmpfile w } outfile ] {
    error "Can't open $tmpfile. $outfile. Printing aborted"
  }

  # Parse arguments as follows (should move to tclParseConfigSpec?):
  # Ignore -postscript, -nopostscript.
  # Use -printer to temporarily override the device part of the lp command
  # Use -hDC to supply an existing channel (?). Not supported yet.
  # Use -file to take future (non-flag) arguments as file names
  # Use -data to take future (non-flag) arguments as output data
  foreach name $args {
    if { $nxtptr == 0 } {
      switch -exact -- $name {
	  -postscript	{ set postscript 1 }
	  -nopostscript	{ set postscript 0 }
	  -printer	{ set nxtptr 1 }
          -hDC          { set nxtptr 2 }
	  -file		{ set source file }
	  -data		{ set source data }  
	  default	{
	  		  if { $source == "data" } {
                            puts -nonewline $outfile $name
			    incr datacount
	  		  } else {
			    if [ catch { ::open $name r } infile ] {
			      lappend status $infile
			    } else {
			      fcopy $infile $outfile
			      ::close $infile
	  		      incr filecount
			    }
	  		  }
	  		}
      }
    } elseif { $nxtptr == 1 } {
      set nxtptr 0
      set printerpart "$printer::lpcmd_devarg$name"
      if [info exist printer::lpcmd_extra] {
        set printerpart "$printerpart $printer::lpcmd_extra"
      }
    } elseif { $nxtptr == 2 } {
      set nxtptr 0
      set outpipe $name
    }
  }

  # Since the print command will produce output, that output will be returned.
  # Just in case the output is redirected to stderr (I haven't checked yet),
  # I'll 'catch' the return
  ::close $outfile

  if [ catch {
    if [info exist outpipe] {
      set infile [ ::open $tmpfile r ]
      fcopy $infile $outpipe
      ::close $infile
      flush $outpipe
    } else {
	puts "_Eval _exec $lppart $printerpart $tmpfile"  
      eval exec $lppart $printerpart $tmpfile
    }
  } retval ] {
      puts "$retval"
    lappend status $retval
  } else {
    # If everything worked fine, remove the temporary file
    file delete $tmpfile
  }

  lappend status "Printed $filecount files and $datacount data arguments"
  return [join $status \n]
}

################################################################
## version
################################################################
proc printer::version { args } {
  return "0.5.0.3"
}

################################################################
## read_init
## Get the default values for initializing the package.
# Defaults can be overridden globally by use of the "hteProfile" package,
# and locally by use of $HOME/.printer.tcl file
################################################################
proc printer::read_init { } {
  # Reference the globals here for ease of use
  global printer::lpcmd         ;# Print command name
  global printer::lpcmd_devarg  ;# Flag for printer command to specify a device
  global printer::lplistcmd     ;# Basis of printer list command
  global printer::lpcmd_device	;# Default printer
  global printer::lpcmd_extra	;# Extra arguments (e.g. -oduplex)
  global env
    variable printer_file

  if [ catch { package require hteProfile } err ] {
    # Do nothing. Can't set global changes
  } else {
      if [info exists env(TCL_PRINTER_CONFFILE)] {
	  set printer_file "$env(TCL_PRINTER_CONFFILE)"
      } else {
	  set printer_file ""
      }
    set dev [hteProfile get -section Printer -private $printer_file -key Default -default None ]
    if { $dev != "None" } {
      set printer::lpcmd_device $dev
    }
    set printer::lpcmd [hteProfile get -private $printer_file -section Printer -key lp -default \$printer::lpcmd]
    set printer::lplistcmd \
    	[hteProfile get -private $printer_file -section printer -key lplist -default $printer::lplistcmd]
    set printer::lpcmd_devarg \
    	[hteProfile get -private $printer_file -section printer -key dflag -default $printer::lpcmd_devarg]
    set arg [hteProfile get -private $printer_file -section Printer -key Extra -default None ]
    if { $arg != "None" } {
      set printer::lpcmd_extra $arg
    }
  }
 
  if [ file exists $env(HOME)/.printer.tcl ] {
    source $env(HOME)/.printer.tcl
  }

}

package provide printer [printer::version]

printer::init_globals

printer::read_init

################################################################
################################################################
# The following file should be in a separate file, but is
# joined with this one for conciseness and completeness in transmission.
#
# The file might be called "tkPBox.tcl", loosely based on 
# the model provided in tkFBox.tcl, used for the Unix file
# browser command.
# By comparison, this set of routines is much simpler, and
# may still have some error cases that are not handled.
#
# The user-invoked routine is 
################################################################
################################################################

# tkPBox.tcl --
#
#	Implements a "TK" standard printer selection dialog box.
#
#	The "TK" printer selection dialog box is similar to the
#	printer selection dialog box on Win95(TM). 
#
#


#----------------------------------------------------------------------
#
#		    P R I N T E R   D I A L O G
#
#----------------------------------------------------------------------

# tkPDialog --
#
#	Implements a TK printer selection dialog.
#
# Arguments:
#	args		Options parsed by the procedure.
#	  -parent
#

proc tkPDialog {args} {
    global tkPriv
    set dataName __tk_printdialog
    upvar #0 $dataName data

    tkPDialog_Config $dataName $args

    if {![string compare $data(-parent) .]} {
        set w .$dataName
    } else {
        set w $data(-parent).$dataName
    }

    # (re)create the dialog box if necessary
    #
    if {![winfo exists $w]} {
	tkPDialog_Create $w
    } elseif { ![string compare [winfo class $w] TkPDialog]} {
	destroy $w
	tkPDialog_Create $w
    }
    wm transient $w $data(-parent)

    # Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.

    wm withdraw $w
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx [winfo parent $w]]}]
    set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty [winfo parent $w]]}]
    wm geom $w [winfo reqwidth $w]x[winfo reqheight $w]+$x+$y
    wm deiconify $w
    wm title $w $data(-title)

    # Set a grab and claim the focus too.

    set oldFocus [focus]
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $w
    focus $data(okBtn)
    #$data(ent) select from 0
    #$data(ent) select to   end
    #$data(ent) icursor end

    # Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.

    tkwait variable ${dataName}(tkPDialogDoneFlag)
    catch {focus $oldFocus}
    grab release $w
    wm withdraw $w
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

#    return [::list $tkPriv(tkPDialogStatus) $tkPriv(lpcmd_extra_opt)]
    return $tkPriv(tkPDialogStatus)
}

# tkPDialog_Config --
#
#	Configures the TK filedialog according to the argument list
#
proc tkPDialog_Config {dataName argList} {
    upvar #0 $dataName data

    # 1: the configuration specs
    #
    set specs {
	{-parent "" "" "."}
	{-printers "" "" "default"}
	{-title "" "" "Select Printer"}
	{-withsave "" "" 1}
    }

    # 2: default values 
    #
if { 0 } {
    if {![info exists tkPriv(selectPrinter)]} {
	# first time the dialog has been popped up
	set tkPriv(selectPrinter) "default"
    }
}
    # 3: parse the arguments
    #
    tclParseConfigSpec $dataName $specs "" $argList
    if {![string compare $data(-title) ""]} {
	set data(-title) "Select Printer"
    }

    if {![winfo exists $data(-parent)]} {
	error "bad window path name \"$data(-parent)\""
    }
}

proc tkPDialog_Create {w} {
    set dataName [lindex [split $w .] end]
    upvar #0 $dataName data
    global tk_library
    global tkPriv
    global ::printer::known_media
    global ::printer::known_media_param
    global ::printer::attr

    toplevel $w -class TkPDialog

    # fPlpcmd: the frame with the the "printer name" field
    #

    set tkPriv(lpcmd) $::printer::attr(lpcmd)
#set tkPriv(lpcmd_extra_opt) $::printer::attr(lpcmd_extra_opt)
    set tkPriv(output_file) $printer::attr(output_file)
    set tkPriv(print_to_file_flag) $printer::attr(print_to_file_flag)

    set tkPriv(entPageFrom) $printer::attr(rangePageFrom)
    set tkPriv(entPageTo) $printer::attr(rangePageTo)
    set tkPriv(PItemSel) $printer::attr(PItemSel)

    set fPlpcmd [frame $w.fPlpcmd -bd 0]

    label $fPlpcmd.lab_lpcmd -text "Printer command:" -anchor w -pady 0 -padx 5
    set data(lpcmd) [entry $fPlpcmd.ent_lpcmd -textvariable tkPriv(lpcmd) \
    -width 20 -exportselection no]
    set data(cbPToFileFlag) [checkbutton $fPlpcmd.cbPToFileFlag -variable tkPriv(print_to_file_flag)\
			   -text "Print to file"]
#    set data(but_browse_output_file) [button $fPlpcmd.browse_output_file -text "Browse" \
#	    -command { set tkPriv(output_file) [ tk_getSaveFile -filetypes $tkPriv(printout_types) \
#	    -initialfile $tkPriv(output_file) -title "Print To"] } ]

    grid $fPlpcmd.lab_lpcmd $fPlpcmd.ent_lpcmd $fPlpcmd.cbPToFileFlag

    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #
    # fPItemSel: the frame with Select Item to print
    # Check if selection present (Up and through attrs here)
    # then assign tkPriv(PItemSel)

    set fPPrintRanges [ frame $w.fPPrintRanges ]
    label $fPPrintRanges.lab -text "Print ranges" -anchor w -pady 0 -padx 5
    set fPItemSel [ frame $fPPrintRanges.fPItemSel -bd 2 -relief groove ]

    set data(rbPItemSelpAll) [radiobutton $fPItemSel.rbPItemSelpAll -variable tkPriv(PItemSel)\
			   -text "Print all" -value pAll ]
    set data(rbPItemSelpPageRange) [radiobutton $fPItemSel.rbPItemSelpPageRange -variable tkPriv(PItemSel)\
			   -text "Print pages" -value pPageRange ]
    set data(rbPItemSelpSelection) [radiobutton $fPItemSel.rbPItemSelpSelection -variable tkPriv(PItemSel)\
			   -text "Selected text:" -value pSelection ]
    
    label $fPItemSel.labPageFrom -text "from:"
    set data(entPageFrom) [ entry $fPItemSel.entPageFrom -textvariable tkPriv(entPageFrom) \
       -width 5 -exportselection no ]
    label $fPItemSel.labPageTo   -text "to:"
    set data(entPageTo) [ entry $fPItemSel.entPageTo -textvariable tkPriv(entPageTo) \
       -width 5 -exportselection no ]

    pack $fPItemSel -side bottom -fill x
    pack $fPPrintRanges.lab -side bottom -anchor w

    if { [lindex $printer::attr(CurrTextSel) 0] == "" } {
	set CurrSelectionInd "No text selected."
	$data(rbPItemSelpSelection) configure -state disabled
	if { ![string compare $tkPriv(PItemSel) pSelection] } { set tkPriv(PItemSel) pAll }
    } else {
	set tmp [lindex $printer::attr(CurrTextSel) 0]
	set srow [lindex [split $tmp .] 0]
	set scol [lindex [split $tmp .] 1]
	set tmp [lindex $printer::attr(CurrTextSel) 1]
	set erow [lindex [split $tmp .] end]
	set ecol [lindex [split $tmp .] end]
	set CurrSelectionInd [ format "%d line %d col - %d line %d col" $srow $scol $erow $ecol ]
    }

    label $fPItemSel.labSelection -text $CurrSelectionInd -width 30

    grid $fPItemSel.rbPItemSelpAll
    grid $fPItemSel.rbPItemSelpPageRange $fPItemSel.labPageFrom $data(entPageFrom) $fPItemSel.labPageTo $data(entPageTo) 
    grid $fPItemSel.rbPItemSelpSelection $fPItemSel.labSelection - - -

    grid $fPItemSel.rbPItemSelpAll -sticky w
    grid $fPItemSel.rbPItemSelpPageRange -sticky w 
    grid $fPItemSel.rbPItemSelpSelection -sticky w


   #set tmp_try [$HTE::Editor::winData(o,text) tag range sel]

    # f1: The listbox with the printer names
if { 0 } {
    set f1 [frame $w.f1 -bd 0]
    listbox $f1.list -selectmode single -yscrollcommand "$f1.vertscroll set"
    scrollbar $f1.vertscroll -command "$f1.list yview"
    set data(list) $f1.list
    pack $f1.vertscroll -side right -fill y
    pack $f1.list -side left -fill both -expand true
    $f1.list delete 0 end

    if [ info exist data(-printers) ] {
      if { [llength $data(-printers)] > 0 } { 
        set printerlist $data(-printers)
      } else {
        set printerlist "default"
      }
    } else {
      set printerlist "default"
    }
    foreach printer $printerlist {
      $f1.list insert end $printer
    }
}
    # f3: the frame with the OK and cancel buttons
    #
    set f3 [frame $w.f3 -bd 0]
    set data(okBtn)     [button $f3.ok     -text OK     -under 0 -width 6 \
	-default active -pady 3]
    set data(cancelBtn) [button $f3.cancel -text Cancel -under 0 -width 6\
	-default normal -pady 3]
    if { $data(-withsave) != 0 } {
      set data(saveBtn) [button $f3.save -text Save -under 0 -width 6\
        -default normal -pady 3 -command "tkPDialog_SaveCmd $w"]
      bind $w <Alt-s> "tkButtonInvoke $data(saveBtn)"
    }

    # pack the widgets in fPlpcmd and f3
    #
    pack $data(okBtn) -side left -padx 4 -anchor center
    pack $data(cancelBtn) -side right -padx 4 -anchor center
    if { $data(-withsave) != 0 } {
      pack $data(saveBtn) -side left -padx 4 -anchor center -expand 1
    }

    # Pack all the frames together. We are done with widget construction.
    #

    pack $f3 -side bottom -fill x 
    pack $fPPrintRanges -side bottom -fill x -padx 10 -pady 10
    pack $fPlpcmd -side bottom -fill x

    #pack $f1 -fill both -padx 4 -pady 1 -expand true

    # Set up the event handlers
    #
    #bind $data(ent) <Return>  "tkPDialog_OkCmd $w"
    
    $data(okBtn)     config -command "tkPDialog_OkCmd $w"
    $data(cancelBtn) config -command "tkPDialog_CancelCmd $w"

    #bind $w <Alt-n> "focus $data(ent)"
    bind $w <KeyPress-Escape> "tkButtonInvoke $data(cancelBtn)"
    bind $w <Alt-c> "tkButtonInvoke $data(cancelBtn)"
    #bind $w.f1.list <ButtonRelease-1> { set tkPriv(lpcmd_extra_opt) [%W get [ %W curselection ] ] } 
    #bind $w.f1.list <KeyRelease-space>  { set tkPriv(lpcmd_extra_opt) [%W get [ %W curselection ] ] } 

    wm protocol $w WM_DELETE_WINDOW "tkPDialog_CancelCmd $w"

    # Build the focus group for all the entries
    #
    tk::FocusGroup_Create $w
    #    tkFocusGroup_BindOut $w $data(ent) "tkPDialog_EntFocusOut $w"
}

# Gets called when the entry box loses keyboard focus. Sets selection to best match 
# value in the entry box.

proc tkPDialog_EntFocusOut {w} {
    upvar #0 [winfo name $w] data
    set text [$data(ent) get]
    set list [ $data(list) get 0 end ]
    set ind [ lsearch -glob $list ${text}* ]
    if { $ind != -1 } {
      $data(list) selection set $ind
      $data(list) activate $ind
      $data(list) see $ind
    }
}

# Gets called when user presses the "OK" button
#
proc tkPDialog_OkCmd {w} {
    global tkPriv
    global printer:attr
    upvar #0 [winfo name $w] data

#    set text $tkPriv(lpcmd_extra_opt)
#Old manner return value
    set text $tkPriv(lpcmd)
    set data(tkPDialogDoneFlag) $text
    set tkPriv(tkPDialogStatus) 1

    set printer::attr(lpcmd) $tkPriv(lpcmd) 
#   set printer::attr(lpcmd_extra_opt) $tkPriv(lpcmd_extra_opt) 
    set printer::attr(rangePageFrom) $tkPriv(entPageFrom)
    set printer::attr(rangePageTo) $tkPriv(entPageTo)
    set printer::attr(PItemSel) $tkPriv(PItemSel)
    set printer::attr(print_to_file_flag) $tkPriv(print_to_file_flag)
    if { $printer::attr(print_to_file_flag) } {
	set tkPriv(printout_types) {
	    { {PostScript} {.ps} }
	    { {All Files}   *    }
	}
	set  tkPriv(output_file) [ tk_getSaveFile -filetypes $tkPriv(printout_types) \
		-initialfile $printer::attr(output_file) -title "Save Printout To"] 
	if { $tkPriv(output_file) == "" } {
	    set text $tkPriv(lpcmd)
	    set data(tkPDialogDoneFlag) $text
	    set tkPriv(tkPDialogStatus) 2	    
	} else { set printer::attr(output_file) $tkPriv(output_file) }
    }
}
# Gets called when user presses the "OK" button
#
proc tkPDialog_SaveCmd {w} {
    global tkPriv
    global printer:attr
    upvar #0 [winfo name $w] data
#Old manner return value
    set text $tkPriv(lpcmd)
    set data(tkPDialogDoneFlag) $text
    set tkPriv(tkPDialogStatus) 2

    set printer::attr(lpcmd) $tkPriv(lpcmd)
    set printer::attr(PItemSel) $tkPriv(PItemSel)
    set printer::attr(rangePageFrom) $tkPriv(entPageFrom)
    set printer::attr(rangePageTo) $tkPriv(entPageTo)
    set printer::attr(print_to_file_flag) $tkPriv(print_to_file_flag)

#    return $tkPriv(lpcmd_extra_opt)
}

# Gets called when user presses the "Cancel" button
#
proc tkPDialog_CancelCmd {w} {
    upvar #0 [winfo name $w] data
    global tkPriv

    set data(tkPDialogDoneFlag) ""
    set tkPriv(tkPDialogStatus) 0 
    return $tkPriv(lpcmd)
}

# tkPDialog_Done --
#
#	Gets called when user has input a valid filename.  Pops up a
#	dialog box to confirm selection when necessary. Sets the
#	tkPriv(lpcmd_extra_opt) variable, which will break the "tkwait"
#	loop in tkPDialog and return the selected filename to the
#	script that calls tk_getOpenFile or tk_getSaveFile
#
proc tkPDialog_Done {w {lpcmd ""}} {
    upvar #0 [winfo name $w] data
    global tkPriv

    set data(tkPDialogDoneFlag) "$lpcmd"
    set tkPriv(tkPDialogStatus) 1
    return $tkPriv(lpcmd)
}

################################################################
################################################################
# Another file by itself--tkPOpt.tcl
################################################################
################################################################
# tkPOpt.tcl --
#
#	Implements a "TK" standard printer selection dialog box.
#
#	The "TK" printer selection dialog box is similar to the
#	printer selection dialog box on Win95(TM). 
#
# tkPOpt.tcl
#


#----------------------------------------------------------------------
#
#		      P R I N T E R   O P T I O N   D I A L O G
#
#----------------------------------------------------------------------

# tkPOption --
#
#	Implements a TK printer option dialog.
#
# Arguments:
#	args		Options parsed by the procedure.
#	  -parent
#

proc tkPOption {args} {
    global tkPriv
    set dataName __tk_printoption
    upvar #0 $dataName data

    tkPOption_Config $dataName $args

    if {![string compare $data(-parent) .]} {
        set w .$dataName
    } else {
        set w $data(-parent).$dataName
    }

    # (re)create the dialog box if necessary
    #
    if {![winfo exists $w]} {
	tkPOption_Create $w
    } elseif { ![string compare [winfo class $w] TkPOption]} {
	destroy $w
	tkPOption_Create $w
    }
    wm transient $w $data(-parent)

    # Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.

    wm withdraw $w
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx [winfo parent $w]]}]
    set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty [winfo parent $w]]}]
    wm geom $w [winfo reqwidth $w]x[winfo reqheight $w]+$x+$y
    wm deiconify $w
    wm title $w $data(-title)

    # Set a grab and claim the focus too.

    set oldFocus [focus]
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
        set grabStatus [grab status $oldGrab]
    }
    grab $w
    focus $data(okBtn)

    # Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.

    tkwait variable ${dataName}(tkPOptDialogDoneFlag)
    #puts "Wait Gone"
    catch {focus $oldFocus}
    grab release $w
    wm withdraw $w
    if {$oldGrab != ""} {
       if {$grabStatus == "global"} {
	       grab -global $oldGrab
	    } else {
	       grab $oldGrab
	    }
    }

    return $tkPriv(tkPOptDialogStatus)
#    return [::list $tkPriv(tkPOptDialogStatus) $tkPriv(select_enscript_extra_opt)]
}

# tkPOption_Config --
#
#	Configures the TK filedialog according to the argument list
#
proc tkPOption_Config {dataName argList} {
    upvar #0 $dataName data

    # 1: the configuration specs
    #
    set specs {
	{-options "" "" "" }
	{-parent "" "" "."}
	{-title "" "" "Page Setup"}
	{-withsave "" "" 1}
    }

    # 2: default values 
    #
    
    #set tkPriv(select_enscript_extra_opt) data(-options)

    # 3: parse the arguments
    #
    tclParseConfigSpec $dataName $specs "" $argList

    if {![string compare $data(-title) ""]} {
	set data(-title) "Page Setup"
    }

    if {![winfo exists $data(-parent)]} {
	error "bad window path name \"$data(-parent)\""
    }
}

proc tkPOption_Create {w} {
    set dataName [lindex [split $w .] end]
    upvar #0 $dataName data
    global tk_library
    global tkPriv
    global ::printer::known_media
    global ::printer::known_media_params
    global ::printer::conv_factor

    #internal function variables
    variable enscript_list_media_opt "--list-media"
    variable enscript_pipe_cmd
    variable paramorderlist
    variable i 
    #variable printer_attr
    variable pipeId

    toplevel $w -class TkPOption

    # fPOpt: the frame with the the "printer options" field
    #

    set tkPriv(enscript_extra_opt) $::printer::attr(enscript_extra_opt)
    set fPOpt [frame $w.fPOpt -bd 0]
    label $fPOpt.lab -text "Enscript extra options:" -anchor w -pady 0 
    set data(ent) [entry $fPOpt.ent -textvariable tkPriv(enscript_extra_opt) -exportselection no]

    pack $fPOpt.lab -side left 
    pack $data(ent) -expand yes -fill x -pady 0 
    #-padx 4 -pady 0

    #N-up
    #set tkPriv(nupnum) $::printer::attr(nupnum)
    #set fPNup [frame $w.fPNup -bd 0]
    #label $fPNup.lab -text "N-up:" -anchor w -pady 0
    #set data(nupnum) [entry $fPNup.nupnum -textvariable tkPriv(nupnum) -exportselection no]
    #pack $fPNup.lab -side left
    #pack $data(nupnum) -expand yes -fill x -pady 0 
    

    # fPOptButtons: the frame with the OK and cancel buttons
    #
    set fPOptButtons [frame $w.fPOptButtons -bd 0]

    set data(okBtn)     [button $fPOptButtons.ok     -text OK     -under 0 -width 6 \
	-default active -pady 3]
    set data(cancelBtn) [button $fPOptButtons.cancel -text Cancel -under 0 -width 6\
	-default normal -pady 3]
    if { $data(-withsave) == 0 } {
      ;# Can't put up save button
    } else {
#Disable Save Btn
if { 0 } {
      set data(saveBtn) [button $fPOptButtons.save -text "Save" -under 0 -width 6\
        -default normal -pady 3 -command "tkPOption_SaveCmd $w" ]
      bind $w <Alt-s> "tkButtonInvoke $data(saveBtn)"
}
    }

    pack $data(okBtn) -side left -padx 4 -anchor center
    pack $data(cancelBtn) -side right -padx 4 -anchor center
    if [ info exist data(saveBtn) ] {
      pack $data(saveBtn) -side left -padx 4 -anchor center -expand 1
    }

    # fMOrient
    #

    set tkPriv(pageOrient) $::printer::attr(enscript_page_orientation)
    set tkPriv(pageOrientWas) $tkPriv(pageOrient)
    set fMOrient [ frame $w.fMOrient -bd 0 ]
    label $fMOrient.lab -text "Media orientation:" -pady 0 -width 20 -anchor w 
    set data(rbLandscape) [radiobutton $fMOrient.rbland -variable tkPriv(pageOrient)\
			   -text Landscape -value landscape \
			       -command { tkPOption_rbLandscape } ] ;#$data(rbLandscape)
    set data(rbPortrait)  [radiobutton $fMOrient.rbport -variable tkPriv(pageOrient)\
			   -text Portrait -value portrait \
			       -command { tkPOption_rbPortrait } ] ;#$data(rbPortrait)
    grid $fMOrient.lab $data(rbLandscape) $data(rbPortrait)
    grid $fMOrient.lab -sticky we -padx 0
    grid columnconfigure $fMOrient 0 -weight 1
    grid columnconfigure $fMOrient 1 -weight 0
    grid columnconfigure $fMOrient 2 -weight 0


    #Running enscript to get known media parameters of it and place them 
    #into ::printer::known_media_params

    #Run enscript to get media types from its output.
    set enscript_pipe_cmd [ list [ format "|%s" $HTE::Configuration(Printer,enscript_cmd) ] \
	    $enscript_list_media_opt ]
    if [ catch { open [ join $enscript_pipe_cmd ] r } pipeId ] {
	    return {} ;#Here MUST be some error handling if no enscript around.
    }
 
    #Header skips
    gets $pipeId buff_line 
    gets $pipeId buff_line 
    gets $pipeId buff_line 

    set ::printer::known_media {}
    array unset ::printer::known_media_params
    set enscript_pcoord_factor $::printer::attr(enscript_pcoord_factor)

    #Assuming enscript output as: name             width  height  llx     lly     urx     ury
    # llx - low left x, lly - low left y, urx - upper right x, ury - upper right y

    while { [ gets $pipeId buff_line ] >= 0 } {
       regsub -all {[ \t]+} $buff_line " " tmp_line; #killing tabs
       set tmp_list [ split $tmp_line ]
      	set tmp_media  [ lindex $tmp_list 0 ]
      	set widthP  [ expr { [ lindex $tmp_list 1 ] * $enscript_pcoord_factor } ]
      	set heightP [ expr { [ lindex $tmp_list 2 ] * $enscript_pcoord_factor } ]
      	set llxP    [ expr { [ lindex $tmp_list 3 ] * $enscript_pcoord_factor } ]
      	set llyP    [ expr { [ lindex $tmp_list 4 ] * $enscript_pcoord_factor } ]
      	set urxP    [ expr { [ lindex $tmp_list 5 ] * $enscript_pcoord_factor } ]
      	set uryP    [ expr { [ lindex $tmp_list 6 ] * $enscript_pcoord_factor } ]

	    lappend ::printer::known_media $tmp_media


	#Calculating margins and reodering'em according to HTE list scheme: width height , left top right bottom 
       set tmp_list {}
	    lappend tmp_list [ list $widthP $heightP ] ; #{width height} 
	
	    set tmp_list2 {}
	    lappend tmp_list2 $llxP                        ;#left margin
	    lappend tmp_list2 [ expr { $heightP - $uryP } ] ; #upper margin
      	lappend tmp_list2 [ expr { $widthP - $urxP } ]  ; #right margin
	    lappend tmp_list2 $llyP                         ; #bottom margin

	    lappend tmp_list $tmp_list2

	#Warning! the $tmp_media is used as a key for array!

	    set ::printer::known_media_params(enscript_${tmp_media}_params) $tmp_list 

	# so known_media_params is list of lists!

    }

    catch { close $pipeId }

    #end of run enscript and get medias.

    #Frame with listbox and media size entries fMParam.
    set fMParam [frame $w.fMParam -bd 0]

    #Adding a listbox to fMParam
    set data(lbframe) [frame $fMParam.lbframe]
    set data(medialistbox) $data(lbframe).mediaListBox
    listbox $data(medialistbox) -listvar ::printer::known_media \
	-height 7 -yscrollcommand "$data(lbframe).scroll set" -exportselection no; # -width 12 Dirty!!
#Dirty!! But how else to put full var name there??
    scrollbar $data(lbframe).scroll -command "$data(medialistbox) yview" -width 12

    set tmp_media [lindex [lindex [printer attr -get current_media] 0] 1]
    $data(medialistbox) selection set \
	[lsearch -exact $::printer::known_media $tmp_media]
    $data(medialistbox) activate [$data(medialistbox) curselection]
    $data(medialistbox) yview scroll [$data(medialistbox) curselection] units

    set data(paramframe) [ frame $fMParam.paramframe ]

    set page_dims $::printer::attr(page dimensions)
    set page_margs $::printer::attr(page margins)

    set f $::printer::conv_factor

    set tkPriv(page_width)    [expr { [lindex $page_dims 0] / $f }]
    set tkPriv(page_height)   [expr { [lindex $page_dims 1] / $f }]
    set tkPriv(marg_left)     [expr { [lindex $page_margs 0]/ $f }]
    set tkPriv(marg_right)    [expr { [lindex $page_margs 2]/ $f }]
    set tkPriv(marg_top)      [expr { [lindex $page_margs 1]/ $f }]
    set tkPriv(marg_bottom)   [expr { [lindex $page_margs 3]/ $f }]

    #if orientation is landscape one has to switch appearence of dialog.
   if {[string equal $tkPriv(pageOrient) landscape]} {
      tkPOption_OrientParamSubst landscape	
   }
   
   set page_params_ol [ list width height ]
   set page_margs_ol  [ list left top right bottom ]
    
   foreach i $page_params_ol {
	   label $data(paramframe).lab${i} -text "Page $i:" -pady 0
	   set data(ent_${i}) [ entry $data(paramframe).ent_${i} -width 6 \
	      -textvariable tkPriv(page_${i}) -exportselection no ]
      grid $data(paramframe).lab${i} $data(ent_${i})
      grid $data(paramframe).lab${i} -sticky w
      grid $data(ent_${i}) -sticky e -padx 3
   }

   foreach i $page_margs_ol {
      label $data(paramframe).lab${i} -text "Margin $i:" -pady 0
      set data(ent_${i}) [ entry $data(paramframe).ent_${i} -width 6 \
         -textvariable tkPriv(marg_${i}) -exportselection no ]
      grid $data(paramframe).lab${i} $data(ent_${i})
      grid $data(paramframe).lab${i} -sticky w
      grid $data(ent_${i}) -sticky e -padx 3
   }


    # pack lbframe 
    pack $data(lbframe).scroll -side right -fill y
    pack $data(medialistbox) -side left -fill both -expand yes
    #pack $data(lbframe) -side top -fill y    # pack fMParam together
    pack $data(paramframe) -side left -fill x 
    pack $data(lbframe) -side right -fill both -expand yes

    # Pack all the frames together. We are done with widget construction.
    # fPOptButtons, fMOpt, fMOrient and fMParam 
    pack $fPOptButtons -side bottom -fill x -padx 5
    #pack $fPNup -side bottom -fill x -padx 5
    pack $fPOpt -side bottom -fill x -padx 5
    pack $fMOrient -side bottom -fill x -padx 5
    pack $fMParam -side bottom -fill x -padx 5

    # Set up the event handlers
    #
    #bind $data(ent) <Return>  "tkPOption_OkCmd $w"
    
    $data(okBtn)     config -command "tkPOption_OkCmd $w"
    $data(cancelBtn) config -command "tkPOption_CancelCmd $w"

    #bind $w <Alt-n> "focus $data(ent)"
    bind $w <KeyPress-Escape> "tkButtonInvoke $data(cancelBtn)"
    bind $w <Alt-c> "tkButtonInvoke $data(cancelBtn)"
    bind $w <<ListboxSelect>> "tkPOption_MediaListbox $w"

    wm protocol $w WM_DELETE_WINDOW "tkPOption_CancelCmd $w"

    # Build the focus group for all the entries
    #
    tk::FocusGroup_Create $w
    wm resizable $w 0 0
}

# Gets called when user presses the "OK" button
#
proc tkPOption_OkCmd {w} {
    global tkPriv
    global ::printer::attr
    global ::printer::known_media
    global ::printer::known_media_params
    global ::printer::conv_factor
    upvar #0 [winfo name $w] data

    set tmp_media $::printer::attr(current_media)
    set ::printer::attr(current_media) $tmp_media 

    set f $::printer::conv_factor

    #if orientation was Landscape one has to correct back 
    #page parameters.
    if {[string equal $tkPriv(pageOrient) landscape]} {
	tkPOption_OrientParamSubst portrait
    }

    lappend page_dims  [ expr { int($tkPriv(page_width)  * $f) }]
    lappend page_dims  [ expr { int($tkPriv(page_height) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_left) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_top) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_right) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_bottom) * $f) }]

    if {[string equal $tkPriv(pageOrient) landscape]} {
      	tkPOption_OrientParamSubst landscape
    }

#    puts "$page_dims"

    set ::printer::attr(page\ dimensions) $page_dims
    set ::printer::attr(page\ margins) $page_margs

    set ::printer::attr(enscript_extra_opt) $tkPriv(enscript_extra_opt)
    set ::printer::attr(enscript_page_orientation) $tkPriv(pageOrient)
    #set ::printer::attr(nupnum) $tkPriv(nupnum)
       
    set text $tkPriv(enscript_extra_opt)
    set data(tkPOptDialogDoneFlag) $text
    set tkPriv(tkPOptDialogStatus) 1
#    return $tkPriv(enscript_extra_opt)
}

# Resets all entry fields in after the media list box change

proc tkPOption_rbPortrait {} {
    global tkPriv
    #switching page params back
    #if safeguard pageOrientWas was landscape
    #to prevent double switching
    if {[string equal $tkPriv(pageOrientWas) landscape]} {
	set tkPriv(pageOrientWas) $tkPriv(pageOrient)
	tkPOption_OrientParamSubst $tkPriv(pageOrient)
    }
}

proc tkPOption_rbLandscape {} {
    global tkPriv
    #switching page params
    #if safeguard pageOrientWas was portrait
    #to prevent double switching
    if {[string equal $tkPriv(pageOrientWas) portrait]} {
	set tkPriv(pageOrientWas) $tkPriv(pageOrient)
	tkPOption_OrientParamSubst $tkPriv(pageOrient)
    }
}

proc tkPOption_MediaListbox {w} {
    global tkPriv
    global ::printer::attr
    global ::printer::known_media
    global ::printer::known_media_params
    global ::printer::conv_factor

    set dataName [lindex [split $w .] end]
    upvar #0 $dataName data

    set tmp_media [lindex $::printer::known_media [$data(medialistbox) curselection] ]
    set new_attrs $::printer::known_media_params(enscript_${tmp_media}_params)
    set page_dims [lindex $new_attrs 0]
    set page_margs [lindex $new_attrs 1]
    set ::printer::attr(current_media) $tmp_media

    set f $::printer::conv_factor

    set tkPriv(page_width)    [expr { [lindex $page_dims 0] / $f }]
    set tkPriv(page_height)   [expr { [lindex $page_dims 1] / $f }]
    set tkPriv(marg_left)     [expr { [lindex $page_margs 0]/ $f }]
    set tkPriv(marg_right)    [expr { [lindex $page_margs 2]/ $f }]
    set tkPriv(marg_top)      [expr { [lindex $page_margs 1]/ $f }]
    set tkPriv(marg_bottom)   [expr { [lindex $page_margs 3]/ $f }]

    if {[string equal $tkPriv(pageOrient) landscape]} {
	tkPOption_OrientParamSubst landscape
    }
}

# Gets called when user presses the "Save" button
# Options saved and then treated like OK.
# Perhaps the save script itself should be something passed in to the creation of
# the command itself
#
proc tkPOption_SaveCmd {w} {
    global tkPriv
    upvar #0 [winfo name $w] data

    global ::printer::attr
    global ::printer::known_media
    global ::printer::known_media_params
    global ::printer::conv_factor

    set tmp_media $::printer::attr(current_media)
    set ::printer::attr(current_media) $tmp_media 

    #if orientation was Landscape one has to correct back 
    #page parameters.
    if {[string equal $tkPriv(pageOrient) landscape]} {
	tkPOption_OrientParamSubst portrait
    }

    set f $::printer::conv_factor

    lappend page_dims  [ expr { int($tkPriv(page_width)  * $f) }]
    lappend page_dims  [ expr { int($tkPriv(page_height) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_left) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_top) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_right) * $f) }]
    lappend page_margs [ expr { int($tkPriv(marg_bottom) * $f) }]

    #correcting it back
    if {[string equal $tkPriv(pageOrient) landscape]} {
      	tkPOption_OrientParamSubst landscape
    }

    set ::printer::attr(page\ dimensions) $page_dims
    set ::printer::attr(page\ margins) $page_margs

    set ::printer::attr(enscript_extra_opt) $tkPriv(enscript_extra_opt)
    set ::printer::attr(enscript_page_orientation) $tkPriv(pageOrient)
    #set ::printer::attr(nupnum) $tkPriv(nupnum)

#    set text $tkPriv(enscript_extra_opt)
    set data(tkPOptDialogDoneFlag) "" ;#$text
    set tkPriv(tkPOptDialogStatus) 2
#    return $tkPriv(enscript_extra_opt)
}

# Gets called when user presses the "Cancel" button
#
proc tkPOption_CancelCmd {w} {
    upvar #0 [winfo name $w] data
    global tkPriv
    set data(tkPOptDialogDoneFlag) ""
    set tkPriv(tkPOptDialogStatus) 0 
#    return $tkPriv(enscript_extra_opt)
}

# tkPOption_Done --
#
#	Gets called when user has input a valid filename.  Pops up a
#	dialog box to confirm selection when necessary. Sets the
#	tkPriv(enscript_extra_opt) variable, which will break the "tkwait"
#	loop in tkPOption and return the selected filename to the
#	script that calls tk_getOpenFile or tk_getSaveFile
#

#Substitution of orientation paramters. Necessary for 
#windows dialog box "clever behavior" emulation.
#protrait as paramter leads to landscape->portrait trans.
#landscape as paramter leads to portrait->landscape trans.
#All enscript functions count ought to get parameters of
#margings in relation to the page orientation in printer.
#Thus enscript should get always "portrait" transformed 
#data. 
#Sheer madness.

proc tkPOption_OrientParamSubst { neworient } {
    global tkPriv
    switch $neworient {
	portrait {
	set tmp $tkPriv(page_width)
	set tkPriv(page_width) $tkPriv(page_height)
	set tkPriv(page_height) $tmp
	set tmp $tkPriv(marg_right)
	set tkPriv(marg_right) $tkPriv(marg_bottom)
	set tkPriv(marg_bottom) $tkPriv(marg_left)
	set tkPriv(marg_left) $tkPriv(marg_top)
	set tkPriv(marg_top) $tmp
	}
	landscape {
	set tmp $tkPriv(page_width)
	set tkPriv(page_width) $tkPriv(page_height)
	set tkPriv(page_height) $tmp
	set tmp $tkPriv(marg_right)
	set tkPriv(marg_right) $tkPriv(marg_top)
	set tkPriv(marg_top) $tkPriv(marg_left)
	set tkPriv(marg_left) $tkPriv(marg_bottom)
	set tkPriv(marg_bottom) $tmp
	}
    }
}
