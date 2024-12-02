#!/usr/bin/wish -f
#
# $Id: //dvt/mti/rel/6.5b/src/tkgui/tddebug.tcl#1 $
#
# tdebug.tcl - A simple debugger for tcl scripts
# Version 1.0
#
# Copyright (C) 1993 Gregor Schmid 
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software

# Please send bug-reports, suggestions etc. to
#
# 		schmid@fb3-s7.math.tu-berlin.de
#

# This file was written with emacs using Jamie Lokier's folding mode
# That's what the funny # {{{ marks are there for

# {{{ setup global variables

# If we can't use send, .tdebugrc is already sourced by
# TdChoose.tcl
if {! [info exists td_priv(.tdebugrc)]} {
    if {[file exists "~/.tdebugrc" ]} {source "~/.tdebugrc"}
}

# Setup default values for variables not set from .tdebugrc
# Most variables have only 2 legal alternatives, so we can
# also check for correctness.

button .td_dummy

set vartable [list \
		  [list scrollbarside          right   left] \
		  [list wrap                   none    word] \
		  [list wrapback               none    word] \
		  [list fullnames              0       1] \
		  [list update                 slow    high] \
		  [list delay                  300     NOCHECK] \
		  [list detail                 high    low] \
		  [list constrainscroll        0       1] \
		  [list globalvars             1       0] \
		  [list arrayvars              1       0] \
		  [list height                 10      NOCHECK] \
		  [list listwidth              60      NOCHECK] \
		  [list varwidth               20      NOCHECK] \
		  [list backtracewidth         80      NOCHECK] \
		  [list backtraceheight        10      NOCHECK] \
		  [list errorwidth             80      NOCHECK] \
		  [list errorheight            10      NOCHECK] \
		  [list widgetswidth           80      NOCHECK] \
		  [list widgetsheight          10      NOCHECK] \
		  [list useblt                 \
		       [expr {[info commands blt_busy] eq "blt_busy"}] \
		       0] \
		  [list preparedtag            {-background grey90} NOCHECK] \
		  [list activetag              {-background orange -relief raised \
		      -borderwidth 1} NOCHECK] \
		  [list breaktag               {-foreground red -background gold -relief raised \
		      -borderwidth 1} NOCHECK] \
		  [list tagpriority            {prepared sel active break} NOCHECK] \
		 ]

foreach i $vartable {
    if {[lindex $i 2] != "NOCHECK"} {
	if {![info exists td_priv([lindex $i 0])] || \
		$td_priv([lindex $i 0]) != [lindex $i 2]} {
	    set td_priv([lindex $i 0]) [lindex $i 1]
    }   } else {
	if {![info exists td_priv([lindex $i 0])]} {
	    set td_priv([lindex $i 0]) [lindex $i 1]
}   }   }

destroy .td_dummy

trace variable td_priv(wrap) w td_configure
trace variable td_priv(wrapback) w td_configure
trace variable td_priv(fullnames) w td_configure

# the execution state of the debugger
set td_priv(state) stop

# miscellaneous
set td_priv(eval) ""
set td_priv(evalsave) ""
set td_priv(proc) ""
set td_priv(waitinproc) ""
set td_priv(current) ""
set td_priv(listheight) {0 10 0 0}

# }}}
# {{{ debugger procs

# {{{ td_prepareProc

# Prepare a procedure for debugging.
# This is done by inserting calls to td_eval into the body of
# the procedure.
# The original body is preserved and can be restored via
# td_restoreProc.
#
# Args:
# proc		Name of the procedure to debug
# start		First line to prepare
# end		Last Line to prepare (or -1 for end)

proc td_prepareProc {proc {start 0} {end -1}} {
    global td_priv td_Listing

    td_appBusy 1
    if {[catch {set script [info body $proc]} err]} {
	td_appBusy 0
	error $err
    }
    # check whether proc has already been prepared
    if {[string match #tdebug* $script]} {
	# if so, use original script and reprepare
	set script $td_priv(body.$proc)
	set merge 1
    } else {
	set td_priv(body.$proc) $script
	set merge 0
    }
    set script [split $script \n]
    set length [llength $script]
    if {$end < 0 || $end > $length - 1} {
	set end [expr {$length - 1}]
    }
    set res [td_parseScript $script $proc $start $end]
    if {$merge} {
	set res [split $res \n]
	set temp [lrange $res $start $end]
	set script [lrange [split [info body $proc] \n] 1 end]
	set script [lrange $script 0 [expr {[llength $script] - 2}]]
	set res [eval lreplace \$script $start $end $temp]
	set res [join $res \n]
    } else {
	# clear breakpoints for proc
	set td_priv(break.$proc) ""
	set td_priv(result.$proc) ""
    }
    incr start
    incr end
    td_addRegion $proc $start $end
    eval "td_origProc $proc \{[td_makeArgs $proc]\} \{#tdebug \n\
	    $res \n td_eval $proc end end \{\}\}"
    if {$td_priv(current) == $proc} {
	set view [lindex $td_priv(listheight) 2]
	set td_priv(current) ""
	td_displayProc $proc
	if {$td_priv(constrainscroll)} {
	    td_constrainScroll $view
	} else {
	    $td_Listing yview $view
    }   }
    td_appBusy 0
}

# }}}
# {{{ td_restoreProc

# Restore the original body of a procedure that has been modified
# by td_prepareProc
#
# Args:
# proc		Name of the procedure to restore.
# start		First line to restore
# end		Last line to restore (or -1 for end)

proc td_restoreProc {proc {start 0} {end -1}} {
    global td_priv td_Listing td_Result td_Vars

    if {[string match #tdebug* [info body $proc]]} {
	if {$end == -1} {
	    # complete restore
	    eval "td_origProc $proc \{[td_makeArgs $proc]\} \
		    \{$td_priv(body.$proc)\}"
	    unset td_priv(body.$proc)
	    unset td_priv(break.$proc)
	    unset td_priv(result.$proc)
	    unset td_priv(regions.$proc)
	} else {
	    set orig [split $td_priv(body.$proc) \n]
	    set new [split [info body $proc] \n]
	    set len [llength $orig]
	    if {$end >= $len} {
		set end [expr {$len - 1}]
	    }
	    set temp [lrange $orig $start $end]
	    set new [eval lreplace \$new [expr {$start + 1}] [expr {$end + 1}] $temp]
	    eval "td_origProc $proc \{[td_makeArgs $proc]\} \{[join $new \n]\}"
	    incr start
	    incr end
	    td_removeRegion $proc $start $end
	    td_removeBreaks $proc $start $end
	}
	# if proc is currently displayed, redisplay it
	if {$proc == $td_priv(current)} {
	    set view [lindex $td_priv(listheight) 2]
	    set td_priv(current) ""
	    td_displayProc $proc
	    if {$td_priv(constrainscroll)} {
		td_constrainScroll $view
	    } else {
		$td_Listing yview $view
	    }
	    $td_Result configure -state normal
	    $td_Result delete 0 end
	    $td_Result configure -state disabled
	    $td_Vars delete 0 end
	    if {$td_priv(state) == "waiting"} {
		set td_priv(state) break
		update
    }   }   }
}

# }}}
# {{{ td parseScript

# Parse a tcl script and insert calls to td_eval at appropriate
# places.
# Don't try to parse subexpressions if td_priv(detail)
# is set to low.
#
# Args:
# script   	A list of lines of tcl script
# name		The name of the procedure being prepared
# start		First line to be parsed
# end		Last line to be parsed
#
# Result:	A string, the modified script

proc td_parseScript {script name {start 0} {end -1}} {
    global td_priv
    set switch -1
    set result ""
    set high_detail [string compare $td_priv(detail) "low"]
    set len [llength $script]
    if {$end >= 0 && $len > $end + 1} {
	set len [expr {$end + 1}]
    }

    for {set lnum 0} {$lnum <$start} {incr lnum} {
	append result [lindex $script $lnum]\n
    }
    for {set lnum $start} {$lnum<$len} {} {
	set line [lindex $script $lnum]; incr lnum

	#split the line in pieces
        regexp "(^\[ \t\]*)(\[^ \t;\]*)(.*)" $line match blank token rest

	# skip empty lines
	if {[string match "#*" $token]} {append result $line\n ; continue}
	if {![string compare "" $token]} {append result $line\n ; continue}

	if {[string match "\}*" $token]} {
	    # closing brace
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum] 
	    }
	    set rline $line
	} elseif {[regexp "(break|continue|return)(\[ \t;\]|$)" $line]} {
	    # avoid uplevel with these
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum]
	    }
	    set rline "td_eval $name $lnum.0 $lnum.end {} ; $line"
	} elseif { [info complete $line] && $lnum > $switch } {
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum]
	    }
	    set rline "td_eval $name $lnum.0 $lnum.end \{$line\}"
	} elseif {[string match "bind" $token]} {
	    #don't debug bindings
	    set rline $line
	    while {$lnum < $len} {
		if {[info complete $rline]} break
		append rline \n[lindex $script $lnum]
		incr lnum
	}   } elseif {[string match "switch" $token]} {
	    # try to avoid switch cases - needs better handling !!
	    set temp $line
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum]
	    }
	    set rline "td_eval $name $lnum.0 $lnum.end {} ; $line"
	    set l $lnum
	    while {$l < $len} {
		if {[info complete $temp]} break
		append temp \n[lindex $script $l]
		incr l
	    }
	    set switch $l
	    puts $switch
	} elseif {$lnum > $switch} {
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum] 
	    }
	    set rline "td_eval $name $lnum.0 $lnum.end {} ; $line"
	} else {
	    if {$high_detail} {
		set line [td_parseLine $line $name $lnum]
	    }
	    set rline $line
	    puts $rline
	}
	append result "$rline\n"
    }
    set len [llength $script]
    for {} {$lnum < $len} {} {
	append result [lindex $script $lnum]\n
	incr lnum
    }
   
    return $result
}

# }}}
# {{{ td_parseLine

# Search for bracketed command expressions in a line of tcl script.
# Insert a call to td_eval for each of those.

# Args:
# line		The string to be parsed
# name		Name of the procedure this line belongs to
# lnum		Current line number
#
# Result:	The parsed line.

proc td_parseLine {line name lnum} {
    global td_priv

    # regular expression to search for brackets and backslashes
    set r {(([^][\\]*)(\[|\]|\\))(.*)}
    # start of current expression
    set last 0
    # length of current expression
    set length 0
    # rest of expression to be parsed
    set m4 $line
    # The modified expression
    set pline ""		
    
    while {[regexp $r $m4 m m1 m2 m3 m4]} {
	incr length [string length $m1]
	switch -exact $m3 {
	    "\\" {
		# skip next character since it's quoted
		set m4 [string range $m4 1 end]
		incr length 1
	    }
	    "\[" {
		# Keep stuff before subexpression
		append pline [string range $line $last [expr {$length - 1}]]
		# parse subexpression
		set temp [td_parseExpression $m4 $name $lnum $length]
		if {[string compare "" $temp]} {
		    # add call to td_eval
		    append pline "td_eval $name $lnum.$length \
				$lnum.[expr {$length + [lindex $temp 0] -2}] \
			    \{[lindex $temp 1]\}\]"
		    set m4 [string range $m4 [lindex $temp 0] end]
		    incr length [lindex $temp 0]
		    set last $length
		} else {
		    # multiline [...]
		    append pline "td_eval $name $lnum.$length $lnum.end \{\} ;"
		    set last $length
	    }   }
	    "\]" {
		# multiline [...] expression, just return the line
		append pline [string range $line $last end]
		return $pline
    }   }   }   
    # No further subexpression. Append the rest and return.
    return [append pline [string range $line $last end]]
}

# }}}
# {{{ td_parseExpression

# Search for bracketed subexpressions in a tcl expression.
# Insert a call to td_eval for each of those.
# This procedure is called recusirvely to handle nested expressions

# Args:
# line		The complete line to be parsed
# name		Name of the procedure this line belongs to
# lnum		Current line number
# start		Start of current expression in line
#
# Result:	A list, first element is length of parsed subexpression,
#		second element is the modified expression.

proc td_parseExpression {line name lnum start} {
    global td_priv

    # regular expression to search for brackets and backslashes
    set r {(([^][\\]*)(\[|\]|\\))(.*)}
    # start of current expression
    set last 0
    # length of current expression
    set length 0
    # rest of expression to be parsed
    set m4 $line
    # The modified expression
    set pline ""		
    
    while {[regexp $r $m4 m m1 m2 m3 m4]} {
	incr length [string length $m1]
	switch -exact $m3 {
	    "\\" {
		# skip next character since it's quoted
		set m4 [string range $m4 1 end]
		incr length 1
	    }
	    "\[" {
		# Keep stuff before subexpression
		append pline [string range $line $last [expr {$length - 1}]]
		# parse subexpression
		set temp [td_parseExpression $m4 $name $lnum \
			[expr {$length + $start}]]
		if {[string compare "" $temp]} {
		    # add call to td_eval
		    append pline "td_eval $name $lnum.[expr {$length + $start}] \
			    $lnum.[expr {$length + $start + \
			    [lindex $temp 0] -2}] \{[lindex $temp 1]\}\]"
		    set m4 [string range $m4 [lindex $temp 0] end]
		    incr length [lindex $temp 0]
		    set last $length
		} else {
		    # multiline [...]
		    append pline "td_eval $name $lnum.[expr {$length + $start}] \
			    $lnum.end \{\} ;"
		    set last $length
	    }   }
	    "\]" {
		    append pline [string range $line $last [expr {$length - 2}]]
		    return [list $length $pline]
    }   }   }
    # No further subexpression and no closing ],
    # so we a are inside a multiline [...] expression
    return {}
}

# }}}
# {{{ td_eval

# This is the procedure that will be called when a procedure that
# has been prepared for debugging is being executed.
# The body of the procedure is displayed along with all
# available variables and their values.
# The current expression is highlighted and its result displayed.
#
# Args:
# name		The name of the procedure that's being debugged
# l1		Start index of current expession in text-widget format
# l2		End index of expression
# script	The expression that's evaluated
#
# Result: 	The result of the evaluation of script

proc td_eval {name l1 l2 script} {
    global td_priv td_Top td_ListName td_Listing td_Result td_Vars

    if {$td_priv(state) == "break"} {
	# Finish current procedure. uplevel {return} won't work, so use error.
	set td_priv(state) stop
	# Avoid standard tkerror procedure
	if {[info procs tkerror] == ""} {
	    set td_priv(error) ""
	} else {
	    set td_priv(error) "\{[info args tkerror]\} \{[info body tkerror]\}"
	}
	# Define new tk error handler that restores the old one when its called
	td_origProc tkerror err {
	    global td_priv
	    if { $td_priv(error) == "" } {
		fe_rename tkerror ""
	    } else {
		eval td_origProc tkerror $td_priv(error)
	}   }
	$td_Listing tag remove active 1.0 end
	error "break"
    }
    scan $l1 %d lnum

    if {$script != ""} {
	# Evaluate script. Catch errors and notify the user.
	if {[catch {uplevel $script} td_priv(result.$name)]} {
	    set td_priv(result.$name) "error: $td_priv(result.$name)"
	    set td_priv(state) stop
    }   } else {
	set td_priv(result.$name) ""
    }
	
    # pop up debugger window
    if {[wm state $td_Top] != "normal"} {
	wm deiconify $td_Top
	raise $td_Top
    }
    td_displayProc $name
    $td_Listing tag remove active 1.0 end
    if {$l1 == "end"} {
	if {$td_priv(state) == "end"} {
	    set td_priv(state) stop
	}
	$td_Listing tag remove active 1.0 end
	td_updateVars $name
	return
    }
    # Check for breakpoints
    if {$td_priv(state) != "nonstop" && \
	    [lsearch -exact $td_priv(break.$name) $l1] != -1} {
	set td_priv(state) stop
    }
    # Highlight current expression and try to display it in the center
    if {$td_priv(state) != "fast" && $td_priv(state) != "nonstop"} {
	td_realIndex $name l1 
	td_realIndex $name l2
	# try to display active line centered in Listing
	scan [wm geometry $td_Top] "%dx%d+" dummy lheight
	#if {$td_priv(constrainscroll)} {
	#    td_constrainScroll [expr {$lnum - $lheight/2 - 1}]
	#} else {
	#    $td_Listing yview [expr {$lnum - $lheight/2 - 1}]
	#}
	$td_Listing see "$l2 + 3 lines"
	$td_Listing tag add active $l1 $l2+1c
	if {$td_priv(update) == "slow" || $td_priv(state) == "stop"} {
	    td_updateVars $name
	}
	update
    }
    if {$td_priv(state) == "stop"} {set td_priv(state) waiting}
    while {$td_priv(state) == "waiting"} {
	set td_priv(waitinproc) $name
	tkwait variable td_priv(state)
	switch -exact $td_priv(state) {
	    "eval" {
		$td_Result configure -textvariable td_priv(result.$name)
		if {[info complete $td_priv(evalsave)]} {
		    if {[catch {uplevel $td_priv(evalsave)} \
			    td_priv(result.$name)]} {
			set td_priv(result.$name) "error: $td_priv(result.$name)"
		    }
		    td_updateVars $name
		}
		set td_priv(state) waiting
	    }
	    "stop" {set td_priv(state) waiting}
    }   }
    if {$td_priv(state) == "next"} {
	set td_priv(state) stop
    }
    if {$td_priv(state) == "slow"} {
	after $td_priv(delay)
    }
    return $td_priv(result.$name)
}

# }}}
# {{{ td_addRegion

# Add a region to td_priv(regions.$proc), merging regions if
# necessary.
#
# Args:
# proc		Name of proc
# start		First line of region
# end		End of region
#
# Make sure that end >= start !

proc td_addRegion {proc start end} {
    global td_priv

    set remove ""
    if {[catch {set regions $td_priv(regions.$proc)}]} {
	set regions ""
    }
    set len [llength $regions]
    for {set i 0} {$i < $len} {incr i} {
	if {[lindex [lindex $regions $i] 0] > $start} break
    }
    if {$i > 0} {
	set sprev [lindex [lindex $regions [expr {$i - 1}]] 0]
	set eprev [lindex [lindex $regions [expr {$i - 1}]] 1]
	if {$eprev >= $start - 1} {
	    set start $sprev
	    set regions [lreplace $regions [expr {$i - 1}] [expr {$i -1}]]
	    incr i -1
	    incr len -1
    }   }
    while {$i < $len} {
	set snext [lindex [lindex $regions $i] 0]
	set enext [lindex [lindex $regions $i] 1]
	if {$snext > $end + 1} {
	    set regions [linsert $regions $i "$start $end"]
	    break
	} elseif {$enext >= $end} {
	    set regions [lreplace $regions $i $i "$start $enext"]
	    break
	} else {
	    set regions [lreplace $regions $i $i]
	}
	incr len -1
    }
    if {$i == $len} {
	lappend regions "$start $end"
    }
    set td_priv(regions.$proc) $regions
}    

# }}}
# {{{ td_removeRegion

# Remove a region from td_priv(regions.$proc), splitting regions if
# necessary.
#
# Args:
# proc		Name of proc
# start		First line of region
# end		End of region
#
# Make sure that end >= start !

proc td_removeRegion {proc start end} {
    global td_priv

    if {[catch {set regions $td_priv(regions.$proc)}]} {
	set regions ""
    }
    set len [llength $regions]
    for {set i 0} {$i < $len} {incr i} {
	if {[lindex [lindex $regions $i] 0] >= $start} break
    }
    if {$i > 0} {
	set sprev [lindex [lindex $regions [expr {$i - 1}]] 0]
	set eprev [lindex [lindex $regions [expr {$i - 1}]] 1]
	if {$eprev >= $start} {
	    set regions [lreplace $regions [expr {$i - 1}] [expr {$i -1}] \
			"$sprev [expr {$start - 1}]"]
	}
	if {$eprev > $end} {
	    lappend regions "[expr {$end + 1}] $eprev"
    }   }
    while {$i < $len} {
	set snext [lindex [lindex $regions $i] 0]
	set enext [lindex [lindex $regions $i] 1]
	if {$snext > $end} {
	    break
	} elseif {$enext > $end} {
	    set regions [lreplace $regions $i $i "[expr {$end + 1}] $enext"]
	    break
	} else {
	    set regions [lreplace $regions $i $i]
	}
	incr len -1
    }
    set td_priv(regions.$proc) $regions
}    

# }}}
# {{{ td_removeBreaks

# Remove breakpoints for proc inside some region.
#
# Args:
# proc		Name of proc
# start		First line of region
# end		End of region
#
# Make sure that end >= start !

proc td_removeBreaks {proc start end} {
    global td_priv

    set breaks $td_priv(break.$proc)
    set len [llength $breaks]
    for {set i 0} {$i < $len} {} {
	scan [lindex $breaks $i] "%d" b
	if {$b >= $start && $b <= $end} {
	    set breaks [lreplace $breaks $i $i]
	    incr len -1
	} else {
	    incr i
    }   }
    set td_priv(break.$proc) $breaks
}    

# }}}
# {{{ td_proc

# A replacement for proc.
# Catch calls to proc from user to be able to restore
# some values if proc has been prepared, as well as
# to update the chooser display.

proc td_proc {name arg body} {
    global td_priv

    if {[info exists td_priv(body.$name)]} {
	td_restoreProc $name
	if {[info exists td_priv(chooseinterp)]} {
	    send $td_priv(chooseinterp) td_smartRescan
	} else {
	    td_smartRescan
    }   }
    td_origProc $name $arg $body
}

# }}}
# {{{ td_makeArgs

# Construct the argument list for a proc including correct dafault
# values. The proc must allready exist.
#
# Args:
# proc:		Name of the proc

proc td_makeArgs proc {

    set args [info args $proc]

    set ret ""

    foreach i $args {
	if {[info default $proc $i def]} {
	    lappend ret "$i $def"
	} else {
	    lappend ret $i
    }   }
    return $ret
}

# }}}

# }}}
# {{{ interface procs

# {{{ td_configure

# Configure various Debugger options (right now only wrapping)
#
# Args:		As specified for `trace'

proc td_configure {name1 name2 op} {
    global td_priv td_Listing td_BTText td_WHText

    if {$name1 == "td_priv" && $op == "w"} {
	if {$name2 == "wrap"} {
	    $td_Listing configure -wrap $td_priv(wrap)
	} elseif {$name2 == "wrapback"} {
	    $td_BTText configure -wrap $td_priv(wrapback)
	} elseif {$name2 == "fullnames"} {
	    $td_WHText configure -state normal
	    $td_WHText delete 1.0 end
	    td_hierarchy $td_WHText
	    $td_WHText delete end-1c end
	    $td_WHText configure -state disabled
    }   }
}

# }}}
# {{{ td_setBreakpoint

# Set a breakpoint for the procedure currently being debugged.
# Use the innermost possible expression.
#
# Args:
# x,y		Coordinates of mouse click

proc td_setBreakpoint {x y} {
    global td_priv td_ListProc td_Listing

    set index [$td_Listing index @$x,$y]
    set proc $td_priv(current)
    set break1 ""
    if {[info procs $proc] == ""} {return}
    set body [info body $proc]
    if {! [string match #tdebug* $body]} {return}
    scan $index %d line
    set break ""
    set next [string first "td_eval $proc $line." $body]
    while {$next != -1} {
	set body [string range $body [expr {$next + 1}] end]
	set l1 [lindex $body 2]
	set l2 [lindex $body 3]
	set temp $l1
	td_realIndex $proc l1 1
	td_realIndex $proc l2
	if {[$td_Listing compare $l1 <= $index] && \
		[$td_Listing compare $l2 >= $index]} {
	    set break1 $temp
	    set break2 $l1
	}
	set next [string first "td_eval $proc $line." $body]
    }
    if {$break1 != ""} {
	set index [lsearch -exact $td_priv(break.$proc) $break1]
	if {$index == -1} {
	    lappend td_priv(break.$proc) $break1
	    $td_Listing configure -state normal
	    $td_Listing insert $break2 "B "
	    $td_Listing tag add break $break2 $break2+1c
	    $td_Listing configure -state disabled
	} else {
	    set td_priv(break.$proc) [lreplace $td_priv(break.$proc) $index $index]
	    $td_Listing configure -state normal
	    $td_Listing tag remove break $break2 $break2+1c
	    $td_Listing delete $break2 $break2+2c
	    $td_Listing configure -state disabled
    }   }
}

# }}}
# {{{ td_realIndex

# Given an index into the body of the precedure being debugged,
# compute that index's position on the screen modified for
# display of breakpoints
#
# Args:
# proc		The name of the procedure
# ind		The name of the variable holding the index
# skipequal	Skip breakpoints at index

# Result:	None. The variable named by ind is modified directly.

proc td_realIndex {proc ind {skipequal 0}} {
    global td_priv td_Listing

    upvar $ind l1

    if {[string match *.end $l1]} {return}
    
    set add 0
    scan $l1 %d line
    foreach i $td_priv(break.$proc) {
	if {[string match $line.* $i] && [$td_Listing compare $i <= $l1] \
	    && ! ($skipequal && [$td_Listing compare $i == $l1])} {
	    incr add 2
    }	}
    if {$add != 0} {
	append l1 +${add}c
}   }

# }}}
# {{{ td_updateVars

# Get the names of all variables accessible by the procedure being debugged
# and display them with the respective values.
#
# Args:
# proc		The name of the procedure.

proc td_updateVars proc {
    global td_Vars td_priv

    if {$td_priv(globalvars)} {
	if {[catch {set vars [lsort -ascii [uplevel 2 "info vars"]]}]} {return}
    } else {
	if {[catch {set vars [lsort -ascii [uplevel 2 "info locals"]]}]} {return}
    }
    set view [$td_Vars nearest 0]
    $td_Vars delete 0 end
    foreach i $vars {
	upvar 2 $i temp
	if {[catch { $td_Vars insert end "$i: $temp" }]} {
	    if {$td_priv(arrayvars) && ![catch {lsort [array names temp]} names]} {
		foreach j $names {
		    catch {$td_Vars insert end "${i}($j): $temp($j)"}
    }   }   }   }
    $td_Vars yview $view
}

# }}}
# {{{ td_updateBacktrace

proc td_updateBacktrace {} {
    global td_BTText
    
    $td_BTText configure -state normal
    $td_BTText delete 1.0 end
    set level [info level]
    # 3 inner levels belong to Tdebug 
    for {set i 1} {$i <= $level-3} {incr i} {
	$td_BTText insert end "[info level $i]\n\n"
    }
    if {$level >= 4} {
	$td_BTText delete end-2c end
    }
    $td_BTText configure -state disabled
}

# }}}
# {{{ td_prepareFromSelection

# Get the current selection and pass it as a procedure name to
# td_prepareProc.
# If the selection is more than one word, see if it's in the
# listing and do partial preparing instead.

proc td_prepareFromSelection {} {
    global td_priv td_Listing

    if {[catch {selection get} sel]} {return}
    if {$sel == ""} {return}
    set sel [string trim $sel]
    if {[regexp "\[ \t\n\]" $sel]} {
	catch {
	    set start [$td_Listing index sel.first]
	    set end [$td_Listing index sel.last-1c]
	    scan $start %d start
	    scan $end %d end
	    td_prepareProc $td_priv(current) [expr {$start - 1}] [expr {$end - 1}]
	}
    } else {
	td_prepareProc $sel
    }
}

# }}}
# {{{ td_restoreFromSelection

# Get the current selection and pass it as a procedure name to
# td_restoreProc.
# If the selection is more than one word, see if it's in the
# listing and do partial restoring instead.

proc td_restoreFromSelection {} {
    global td_priv td_Listing

    if {[catch {selection get} sel]} {return}
    if {$sel == ""} {return}
    set sel [string trim $sel]
    if {[regexp "\[ \t\n\]" $sel]} {
	catch {
	    set start [$td_Listing index sel.first]
	    set end [$td_Listing index sel.last-1c]
	    scan $start %d start
	    scan $end %d end
	    td_restoreProc $td_priv(current) [expr {$start - 1}] [expr {$end - 1}]
	}
    } else {
	td_restoreProc $sel 
}   }

# }}}
# {{{ td_evalFromSelection

# Get the current selection and evaluate it in the context of the procedure
# being debugged

proc td_evalFromSelection {} {
    global td_priv td_Result

    if {[catch {selection get} sel]} {return}
    if {$sel == ""} {return}
    if {$td_priv(current) == "" || $td_priv(current) != $td_priv(waitinproc) \
	    || $td_priv(state) != "waiting"} {
	if {[catch {uplevel #0 $sel} td_priv(result)]} {
			set td_priv(result) "error: $td_priv(result)"
	}   
	$td_Result configure -textvariable td_priv(result)
	return
    }
    set td_priv(evalsave) $sel
    set td_priv(state) eval
}

# }}}
# {{{ td_evalLine

# Evaluate the line in the eval widget in the context of the procedure
# being debugged, or at global level.

proc td_evalLine {} {
    global td_priv td_Result

    if {$td_priv(eval) == ""} {return}
    if {$td_priv(current) == "" || $td_priv(current) != $td_priv(waitinproc) \
	    || $td_priv(state) != "waiting"} {
	if {[catch {uplevel #0 $td_priv(eval)} td_priv(result)]} {
			set td_priv(result) "error: $td_priv(result)"
	}   
	$td_Result configure -textvariable td_priv(result)
	return
    }
    set td_priv(evalsave) $td_priv(eval)
    set td_priv(state) eval
}

# }}}
# {{{ td_preparedProcs

proc td_preparedProcs {} {
    set names [info procs *]
    set normal ""
    set prepared ""
    foreach i $names {
	if {[string match #tdebug* [info body $i]]} {
	    lappend prepared $i
	} else {
	    lappend normal $i
	}
    }
    return [list [lsort $normal] [lsort $prepared]]
}

# }}}
# {{{ td_hierarchy

# Display a widget hierarchy in a text widget
# Args
# w		text widget to use
# start 	start of hierarchy (default .)
# level 	level of indentation (default 0)

proc td_hierarchy {w {start .} {level 0}} {
    global td_priv td_Top td_WH td_BT td_ET td_Choose

    set skip "$td_Top $td_WH $td_BT $td_ET"
    if {[info exists td_Choose]} {
	set skip "$skip $td_Choose"
    }
    set list  [winfo children $start]
    foreach i $list {
	# remove debugger toplevels
	if {$start != "." || [lsearch -exact $skip $i] == -1} {
	    $w insert end "[string range [format "%15s" \
		    [winfo class $i]] 0 14] "
	    for {set j 0} {$j < $level} {incr j} {
		$w insert end " "
	    }
	    if {! $td_priv(fullnames)} {
		set names [split $i .]
		$w insert end "[lindex $names [expr {[llength $names] - 1}]]\n"
	    } else {
		$w insert end "$i\n"
	    }
	    td_hierarchy $w $i [expr {$level + 3}]
	    if {!$level} {
		$w insert end \n
	    }
    }   }
    if {!$level} {
	$w delete end-1c end
    }
}

# }}}
# {{{ td_updateHierarchy

# Update Widget Hierarchy and make sure the toplevel is displayed

proc td_updateHierarchy {} {
    global td_WH td_WHText
    
    $td_WHText configure -state normal
    $td_WHText delete 1.0 end
    td_hierarchy $td_WHText
    $td_WHText delete end-1c end
    $td_WHText configure -state disabled
    wm deiconify $td_WH
}

# }}}
# {{{ td_updateErrorTrace

proc td_updateErrorTrace {} {
    global td_ET td_ETText errorInfo

    $td_ETText configure -state normal
    $td_ETText delete 1.0 end
    $td_ETText insert end $errorInfo
    $td_ETText configure -state disabled
    wm deiconify $td_ET
}

# }}}
# {{{ td_catchScroll

# Catch the yscrollcommand of td_Listing to fing out it's current
# height in characters Store the value in td_priv(listheight) and set
# the scrollbar.
# Subtract 1 from total number of lines to hide newline appended by
# td_displayProc.
# Args:
# a b c d:		standard scrollbar settings

proc td_catchScroll {total current start end} {
    global td_priv td_ListScroll

    incr total -1
    set td_priv(listheight) [list $total $current $start $end]
    $td_ListScroll set $total $current $start $end
}

# }}}
# {{{ td_constrainScroll

# Constrain Scrolling of proc listing so that scrolling below last line
# won't happen. This works only with the scrollbar, dragging the text
# widget with Button-2 is not affected
# Args:
# start:		yview position given by the scrollbar

proc td_constrainScroll {start} {
    global td_priv td_Listing

    set total [lindex $td_priv(listheight) 0]
    set current [lindex $td_priv(listheight) 1]
    if {$total < $current} {
	$td_Listing yview 0
    } elseif {$total - $start < $current} {
	$td_Listing yview [expr {$total - $current}]
    } else {
	$td_Listing yview $start
}   }

# }}}
# {{{ td_catchVarScroll

# Catch scrolling of the variable listbox and use it to suppress scrolling
# below the last line. This will work with the scrollbar as well as with
# dragging via button 2
# Args:
# a b c d:		standard scrollbar settings

proc td_catchVarScroll {a b c d} {
    global td_Vars td_VarScrollY
    
    if {$a < $b && $c > 0} {
	$td_Vars yview 0
		$td_VarScrollY set $a $b 0 [expr {$b - 1}]
    } elseif {$a -$c < $b} {
	$td_Vars yview [expr {$a - $b}]
		$td_VarScrollY set $a $b [expr {$a - $b}] [expr {$a - 1}]
    } else {
	$td_VarScrollY set $a $b $c $d
    }
}

# }}}
# {{{ td_appBusy

# Search for all toplevels of the application and `make them busy'
# or remove the busy state.
# This requires the BLT extensions, but it won't fail without them.
# Args:
# on			Turn busy on if set, off otherwise

proc td_appBusy {on} {
    global td_priv
    
    if {!$td_priv(useblt)} return

    foreach i [concat [winfo children .] .] {
	if {[winfo toplevel $i] == $i} {
	    if {$on} {
		blt_busy hold $i
	    } else {
		blt_busy release $i
    }   }   }
    update
}

# }}}
# {{{ td_displayProc

# Display name, args and body of procedure.
#
# Args:
#	proc		name of procedure to display

proc td_displayProc {name} {
    global td_priv td_Listing td_Result
    
    if {$td_priv(current) != $name} {
	set td_priv(current) $name
	set td_priv(proc) "$name \{[info args $name]\}"
	$td_Listing configure -state normal
	$td_Listing delete 1.0 end
	set body [info body $name]
	if {[string match #tdebug* $body]} {
	    $td_Listing insert 1.0 $td_priv(body.$name)\n
	    foreach i $td_priv(regions.$name) {
		$td_Listing tag add prepared [lindex $i 0].0 [lindex $i 1].end+1c
	}   } else {
	    $td_Listing insert 1.0 $body\n
	}
	if {[info exists td_priv(break.$name)]} {
	    foreach i $td_priv(break.$name) {
		$td_Listing insert $i "B "
		$td_Listing tag add break $i $i+1c
	}   }
	$td_Listing configure -state disabled
	$td_Result configure -textvariable td_priv(result.$name)
	td_updateBacktrace
}   }

# }}}
# {{{ td_detachDebugger

# Remove all traces of TDebug from the current application

proc td_detachDebugger {} {
    global td_Top td_BT td_WH td_ET td_Choose

    foreach i [lindex [td_preparedProcs] 1] {
	td_restoreProc $i
    }
    fe_rename proc ""
    fe_rename td_origProc proc
    foreach i "$td_Top $td_BT $td_WH $td_ET" {
	catch {destroy $i}
    }
    if {[info exists td_Choose]} {destroy $td_Choose}
    foreach i [info globals td_*] {
	##nagelfar ignore
	global $i
	##nagelfar ignore
	unset $i
    }
    foreach i [info procs td_*] {
	fe_rename $i ""
}   }

# }}}
# {{{ dummies

# those two are just there to easily filter all procs belonging to tdebug
proc td_AAA {} {}
proc td_zzz {} {}

# }}}
# {{{ commandline 

# {{{ td_cline_prepare

# Prepare an entry widget for command line operation.
# Binds keys for cursor motion, deletion and history.
# Use emacs-like keys as well as X11-keysyms.
# Handle Entry and Exit events.
# Implement some history mechanism.
# Args:
#	w		name of entry widget
#	size		number of lines to keep for history (default 20)

proc td_cline_prepare {w {size 20}} {
    global td_cline_priv tk_version

    set td_cline_priv(Total$w) $size
    set td_cline_priv(Next$w) 0
    set td_cline_priv(Wrap$w) 0
    set td_cline_priv(Current$w) 0
    set td_cline_priv(Kill$w) {}
    
    bind $w <Return> {+ td_cline_return %W}
    bind $w <Control-p> {td_cline_previous %W}
    bind $w <Up> {td_cline_previous %W}
    bind $w <Control-n> {td_cline_next %W}
    bind $w <Down> {td_cline_next %W}
    if {$tk_version < 4.0} {
	bind $w <Enter> {focus %W}
	bind $w <Leave> {focus [focus default]}
	bind $w <Control-b> {
	    %W icursor [expr [%W index insert] - 1]
	    tk_entrySeeCaret %W
	}
	bind $w <Left> {
	    %W icursor [expr [%W index insert] - 1]
	    tk_entrySeeCaret %W
	}
	bind $w <Control-f> {
	    %W icursor [expr [%W index insert] + 1] ;
	    tk_entrySeeCaret %W
	}
	bind $w <Right> {
	    %W icursor [expr [%W index insert] + 1]
	    tk_entrySeeCaret %W
	}
	bind $w <Control-a> {%W icursor 0 ; tk_entrySeeCaret %W}
	bind $w <Home> {%W icursor 0 ; tk_entrySeeCaret %W}
	bind $w <Control-e> {%W icursor end ; tk_entrySeeCaret %W}
	bind $w <End> {%W icursor end ; tk_entrySeeCaret %W}
	bind $w <Control-k> {td_cline_kill %W}
	bind $w <Control-y> {
	    %W insert insert $td_cline_priv(Kill%W)
	    tk_entrySeeCaret %W
	}
	bind $w <Control-d> {%W delete [%W index insert] [%W index insert]}
	bind $w <Delete> {%W delete [%W index insert] [%W index insert]}
    } else {
	bind $w <Control-k> {td_cline_kill %W}
	bind $w <Control-y> {
	    %W insert insert $td_cline_priv(Kill%W)
	    tk::EntrySeeInsert %W
	}
	bindtags $w "$w Entry all"
    }
}

# }}}
# {{{ td_cline_return

# Add contents of entry widget to history and clear.
# Args:
#	w		name of entry widget

proc td_cline_return {w} {
    global td_cline_priv

    if {[string compare [$w get] ""]} {
	set td_cline_priv($td_cline_priv(Next$w)$w) [$w get]
	incr td_cline_priv(Next$w)
	if {$td_cline_priv(Next$w) == $td_cline_priv(Total$w)} {
	    set td_cline_priv(Next$w) 0
	    set td_cline_priv(Wrap$w) 1
	}
	$w delete 0 end
    }
    set td_cline_priv(Current$w) $td_cline_priv(Next$w)
}

# }}}
# {{{ cline-previous

# Move back one line in history.
# Args:
#	w		name of entry widget

proc td_cline_previous {w} {
    global td_cline_priv tk_version

    if {$td_cline_priv(Current$w) == $td_cline_priv(Next$w)} {
	set td_cline_priv($td_cline_priv(Next$w)$w) [$w get]
    }
    if {$td_cline_priv(Current$w) == $td_cline_priv(Next$w) + 1} {return}
    incr td_cline_priv(Current$w) -1
    if {$td_cline_priv(Current$w) < 0} {
	if {! $td_cline_priv(Wrap$w)} {
	    set td_cline_priv(Current$w) 0
	    return
	}
	incr td_cline_priv(Current$w) $td_cline_priv(Total$w)
    } 
    $w delete 0 end
    $w insert 0 $td_cline_priv($td_cline_priv(Current$w)$w)
    if {$tk_version >= 4.0} {
	tk::EntrySeeInsert $w
    } else {
	tk_entrySeeCaret $w
    }
}

# }}}
# {{{ td_cline_next

# Move down one line in history.
# Args
#	w		name of entry widget

proc td_cline_next {w} {
    global td_cline_priv tk_version

    if {$td_cline_priv(Current$w) == $td_cline_priv(Next$w)} {return}
    incr td_cline_priv(Current$w) 
    if {$td_cline_priv(Current$w) == $td_cline_priv(Total$w)} {
	set td_cline_priv(Current$w) 0
    } 
    $w delete 0 end
    $w insert 0 $td_cline_priv($td_cline_priv(Current$w)$w)
    if {$tk_version >= 4.0} {
	tk::EntrySeeInsert $w
    } else {
	tk_entrySeeCaret $w
}   }

# }}}
# {{{ td_cline_kill

# Kill to end of line.
# Args:
#	w		name of entry widget

proc td_cline_kill {w} {
    global td_cline_priv

    set td_cline_priv(Kill$w) [string range [$w get] [$w index insert] \
	    [$w index end]]
    $w delete [$w index insert] end
}

# }}}

# }}}

# }}}
# {{{ interface

# {{{ setup symbolic widget names

set td_Top 		.tdTop

#set td_TopFrame		$td_Top.topFrame

set td_Menubar 		$td_Top.menubar
set td_MBDebug		$td_Menubar.mBDebug
set td_MenuDebug	$td_MBDebug.menuDebug
set td_MBOptions	$td_Menubar.mBOptions
set td_MenuOptions	$td_MBOptions.menuOptions
set td_MBSelection	$td_Menubar.mBSelection
set td_MenuSelection	$td_MBSelection.menuSelection
set td_MBVars		$td_Menubar.mBVars
set td_MenuVars		$td_MBVars.menuVars
set td_MBHelp		$td_Menubar.mBHelp
set td_MenuHelp		$td_MBHelp.menuHelp

set td_MainRegion	$td_Top.mainRegion
set td_MainFrame	$td_MainRegion.mainFrame
set td_ListFrame	$td_MainFrame.listFrame
set td_ListNameFrame	$td_ListFrame.listNameFrame
set td_ListName		$td_ListNameFrame.listName
set td_ListProc		$td_ListNameFrame.listProc
set td_TextFrame	$td_ListFrame.textFrame
set td_Listing		$td_TextFrame.listing
set td_ListScroll	$td_TextFrame.listScroll
set td_ListHSFrame	$td_ListFrame.hscrollFrame
set td_ListHScroll	$td_ListHSFrame.scroll
set td_ListHFill	$td_ListHSFrame.fill

set td_VarFrame		$td_MainRegion.varFrame
set td_VarFrame1	$td_VarFrame.varFrame1
set td_VarName		$td_VarFrame1.varName
set td_VarFrame2	$td_VarFrame1.varFrame2
set td_VarFrame3	$td_VarFrame2.varFrame3
set td_Vars		$td_VarFrame3.vars
set td_VarScrollY	$td_VarFrame3.varScrollY
set td_VarFrame4 	$td_VarFrame2.varFrame4
set td_VarScrollX 	$td_VarFrame4.varScrollX
set td_VarFrame5	$td_VarFrame4.varFrame5

set td_ResultFrame	$td_ListFrame.resultFrame
set td_ResultName	$td_ResultFrame.resultName
set td_Result		$td_ResultFrame.result

set td_EvalFrame	$td_MainFrame.evalFrame
set td_EvalName		$td_EvalFrame.evalName
set td_Eval		$td_EvalFrame.eval

set td_Buttons		$td_Top.buttons
set td_BStop		$td_Buttons.bStop
set td_BNext		$td_Buttons.bNext
set td_BSlow		$td_Buttons.bSlow
set td_BFast		$td_Buttons.bFast
set td_BNonstop		$td_Buttons.bNonstop
set td_BBreak		$td_Buttons.bBreak

set td_DelayFrame	$td_VarFrame.delayFrame
set td_DelayLess	$td_DelayFrame.delayLess
set td_DelayFrame1	$td_DelayFrame.delayFrame1
set td_Delay		$td_DelayFrame1.delay
set td_DelayMore	$td_DelayFrame.delayMore

set td_BT		.td_BT
set td_BTMain		$td_BT.main
set td_BTTop		$td_BTMain.top
set td_BTText		$td_BTTop.text
set td_BTScroll		$td_BTTop.scroll
set td_BTSHFrame	$td_BTMain.hScroll
set td_BTScrollH	$td_BTSHFrame.scroll
set td_BTFillH		$td_BTSHFrame.fill
set td_BTClose		$td_BT.close

set td_WH		.td_WH
set td_WHMain		$td_WH.main
set td_WHTop		$td_WHMain.top
set td_WHText		$td_WHTop.text
set td_WHScroll		$td_WHTop.scroll
set td_WHSHFrame	$td_WHMain.hScroll
set td_WHScrollH	$td_WHSHFrame.scroll
set td_WHFillH		$td_WHSHFrame.fill
set td_WHClose		$td_WH.close

set td_ET		.td_ET
set td_ETMain		$td_ET.main
set td_ETTop		$td_ETMain.top
set td_ETText		$td_ETTop.text
set td_ETScroll		$td_ETTop.scroll
set td_ETSHFrame	$td_ETMain.hScroll
set td_ETScrollH	$td_ETSHFrame.scroll
set td_ETFillH		$td_ETSHFrame.fill
set td_ETClose		$td_ET.close

# }}}
# {{{ the toplevel

if {[winfo exists $td_Top]} {destroy $td_Top}

toplevel $td_Top -class TDebug -borderwidth 0
wm title $td_Top "TDebug for [winfo name .]"
wm withdraw $td_Top

#frame $td_TopFrame
#pack $td_TopFrame -expand 1 -fill both ;# -ipadx 4 -ipady 8

# }}}
# {{{ the menubar

frame $td_Menubar -relief raised -borderwidth 2
pack $td_Menubar -side top -fill x -padx 2 -pady 2

menubutton $td_MBDebug -text "Debugger " -underline 0 -menu $td_MenuDebug -width 9
pack $td_MBDebug -side left
menu $td_MenuDebug
$td_MenuDebug add command -label "Backtrace  " -accelerator ^B \
	-underline 0 -command "wm deiconify $td_BT"
$td_MenuDebug add command -label "Widget Hierarchy  " -accelerator ^W \
	-underline 0 -command td_updateHierarchy
$td_MenuDebug add command -label "Error Trace  " -accelerator ^T \
	-underline 6 -command td_updateErrorTrace
$td_MenuDebug add separator
$td_MenuDebug add command -label "Close  " -accelerator ^C \
	-command "wm positionfrom $td_Top user ;\
	wm withdraw $td_Top" -underline 0

menubutton $td_MBOptions -text "Options " -underline 0 -menu $td_MenuOptions -width 8
pack $td_MBOptions -side left
menu $td_MenuOptions
$td_MenuOptions add checkbutton -label "Wrap Listing  " -accelerator ^L \
	-onvalue word -offvalue none -variable td_priv(wrap) \
	-underline 5
$td_MenuOptions add checkbutton -label "Wrap Backtrace  " \
	-onvalue word -offvalue none -variable td_priv(wrapback) \
	-underline 5
$td_MenuOptions add checkbutton -label "Full Widget Names  " -accelerator ^F \
	-onvalue 1 -offvalue 0 -variable td_priv(fullnames) \
	-underline 0
$td_MenuOptions add checkbutton -label "Slow Var Update  " -accelerator ^V \
	-onvalue slow -offvalue fast -variable td_priv(update) \
	-underline 5
$td_MenuOptions add checkbutton -label "High Detail  " -accelerator ^D \
	-onvalue high -offvalue low -variable td_priv(detail) \
	-underline 5

menubutton $td_MBSelection -text Selection -underline 0 -menu $td_MenuSelection \
	-width 10
pack $td_MBSelection -side left
menu $td_MenuSelection
$td_MenuSelection add command -label "Prepare Proc  " -accelerator ^P \
	-underline 0 -command td_prepareFromSelection
$td_MenuSelection add command -label "Restore Proc  " -accelerator ^R\
	-underline 0 -command td_restoreFromSelection 
$td_MenuSelection add command -label "Eval  " -accelerator ^E \
	-underline 0 -command td_evalFromSelection

menubutton $td_MBVars -text Variables -underline 0 -menu $td_MenuVars -width 10
pack $td_MBVars -side left
menu $td_MenuVars
$td_MenuVars add checkbutton -label "Display Globals  " -accelerator ^G \
	-onvalue 1 -offvalue 0 -variable td_priv(globalvars) \
	-underline 8
$td_MenuVars add checkbutton -label "Display Arrays  " -accelerator ^A \
	-onvalue 1 -offvalue 0 -variable td_priv(arrayvars) \
	-underline 8

menubutton $td_MBHelp -text Help -underline 0 -menu $td_MenuHelp
pack $td_MBHelp -side right
menu $td_MenuHelp
$td_MenuHelp add separator

tk_menuBar $td_Menubar $td_MBDebug $td_MBOptions $td_MBSelection \
	$td_MBVars $td_MBHelp 
tk_bindForTraversal $td_Top

#We need the input focus when the cursor is inside!
if {$tk_version < 4.0} {
    ##nagelfar ignore E 
    if {"[focus default]" == "none"} {focus default .}
    bind $td_Top <FocusIn> {
	if {"%d" == "NotifyVirtual"} {
	    set td_priv(focus) [focus default]
	    focus default %W
	    focus %W
    }   }
    bind $td_Top <FocusOut> {
	if {"%d" == "NotifyVirtual"} {
	    focus default $td_priv(focus)
	    focus [focus default]
}   }   }

# bind Accelerators
bind $td_Top <Control-b> {wm deiconify $td_BT}
bind $td_Top <Control-w> {td_updateHierarchy}
bind $td_Top <Control-t> {td_updateErrorTrace}
bind $td_Top <Control-c> {wm positionfrom $td_Top user ; wm withdraw $td_Top}
bind $td_Top <Control-l> {$td_MenuOptions invoke 0}
bind $td_Top <Control-f> {$td_MenuOptions invoke 2}
bind $td_Top <Control-v> {$td_MenuOptions invoke 3}
bind $td_Top <Control-d> {$td_MenuOptions invoke 4}
bind $td_Top <Control-p> {td_prepareFromSelection}
bind $td_Top <Control-r> {td_restoreFromSelection}
bind $td_Top <Control-e> {td_evalFromSelection}
bind $td_Top <Control-g> {$td_MenuVars invoke 0}
bind $td_Top <Control-a> {$td_MenuVars invoke 1}


# }}}
# {{{ the main region

frame $td_MainRegion
pack $td_MainRegion -side top -expand 1 -fill both

# {{{ the listing

frame $td_MainFrame
pack $td_MainFrame -side left -expand 1 -fill both

frame $td_ListFrame -borderwidth 2 -relief raised
pack $td_ListFrame -side top -expand 1 -fill both -padx 2 -pady 2

frame $td_ListNameFrame -relief raised -borderwidth 0
pack $td_ListNameFrame -side top -fill x
label $td_ListName -text "Proc  :" -borderwidth 0 -width 8
pack $td_ListName -side left
if {$tk_version >= 4.0} {
    entry $td_ListProc -textvariable td_priv(proc) -relief groove \
	    -state disabled -highlightthickness 0
} else {
    entry $td_ListProc -textvariable td_priv(proc) -relief groove -state disabled
}
pack $td_ListProc -side left -expand 1 -fill x

frame $td_TextFrame -relief raised -borderwidth 0
pack $td_TextFrame -side top -expand 1 -fill both

if {$tk_version < 4.0 && $td_priv(constrainscroll)} {
    scrollbar $td_ListScroll -command "td_constrainScroll" -relief sunken
} else {
    scrollbar $td_ListScroll -command "$td_Listing yview" -relief sunken
}
pack $td_ListScroll -side $td_priv(scrollbarside) -fill y

if {$tk_version >= 4.0} {
    text $td_Listing -width 27 -height 2 \
	    -relief sunken -setgrid 1 -wrap none -state disabled \
	    -borderwidth 2  -yscrollcommand "$td_ListScroll set"
} else {
    text $td_Listing -width 27 -height 2 \
	    -relief sunken -setgrid 1 -wrap none -state disabled \
	    -borderwidth 2  -yscrollcommand td_catchScroll
}
pack $td_Listing -side $td_priv(scrollbarside) -expand 1 -fill both

if {$tk_version >= 4.0} {
    frame $td_ListHSFrame -borderwidth 0
    pack $td_ListHSFrame -side top -fill x

    scrollbar $td_ListHScroll -orient horizontal -relief sunken \
	    -command "$td_Listing xview"
    $td_Listing configure -xscrollcommand "$td_ListHScroll set"

    frame $td_ListHFill \
	    -width [expr {[$td_ListScroll cget -width] + 4 + \
		2 * [$td_ListScroll cget -highlightthickness]}] \
	    -height [expr {[$td_ListHScroll cget -width] + 4 + \
		2 * [$td_ListHScroll cget -highlightthickness]}]
    pack $td_ListHFill -side $td_priv(scrollbarside)
    pack $td_ListHScroll -side $td_priv(scrollbarside) -expand 1 -fill x
}    

eval $td_Listing tag configure prepared $td_priv(preparedtag)
eval $td_Listing tag configure active $td_priv(activetag)
eval $td_Listing tag configure break $td_priv(breaktag)
foreach i $td_priv(tagpriority) {
    $td_Listing tag raise $i
}
bind $td_Listing <Double-Button-1> "td_setBreakpoint %x %y"

# }}}
# {{{ the variables

frame $td_VarFrame
pack $td_VarFrame -side left -fill both 

frame $td_VarFrame1 -borderwidth 2 -relief raised
pack $td_VarFrame1 -side top -fill both -expand 1 -padx 2 -pady 2

label $td_VarName -text "Variables: " -borderwidth 2
pack $td_VarName -side top -fill x

frame $td_VarFrame2 
pack $td_VarFrame2 -side top -expand 1 -fill both

frame $td_VarFrame3
pack $td_VarFrame3 -side top -expand 1 -fill both

scrollbar $td_VarScrollY -command "$td_Vars yview" -relief sunken
pack $td_VarScrollY -side $td_priv(scrollbarside) -fill y

if {$tk_version >= 4.0} {
    listbox $td_Vars -xscrollcommand "$td_VarScrollX set" \
	    -relief sunken -width $td_priv(varwidth) -height 2
} else {
    ##nagelfar ignore "Bad option -geometry"
    listbox $td_Vars -xscrollcommand "$td_VarScrollX set" -relief sunken -geometry $td_priv(varwidth)x2
}
if {$tk_version < 4 && $td_priv(constrainscroll)} {
    $td_Vars configure -yscrollcommand td_catchVarScroll
} else {
    $td_Vars configure -yscrollcommand "$td_VarScrollY set" 
}
pack $td_Vars -side $td_priv(scrollbarside) -expand 1 -fill both

frame $td_VarFrame4
pack $td_VarFrame4 -side top -fill x

scrollbar $td_VarScrollX -command "$td_Vars xview" -orient horiz -relief sunken

if {$tk_version >= 4.0} {
    frame $td_VarFrame5 \
	    -width [expr {[$td_VarScrollY cget -width] + 4 + \
		2 * [$td_VarScrollY cget -highlightthickness]}] \
	    -height [expr {[$td_VarScrollX cget -width] + 4 + \
		2 * [$td_VarScrollX cget -highlightthickness]}]
} else {
    frame $td_VarFrame5 \
			-width [expr {[lindex [$td_VarScrollY configure -width] 4] + 4}] \
			-height [expr {[lindex [$td_VarScrollX configure -width] 4] + 4}]
}

pack $td_VarFrame5 -side $td_priv(scrollbarside)
pack $td_VarScrollX -side $td_priv(scrollbarside) -expand 1 -fill x

# }}}

# }}}
# {{{ the result

frame $td_ResultFrame -relief raised -borderwidth 0
pack $td_ResultFrame -side top -fill x 

label $td_ResultName -relief flat -text Result: -borderwidth 0 -width 8
pack $td_ResultName -side left

if {$tk_version >= 4.0} {
    entry $td_Result -relief groove -state disabled -highlightthickness 0
} else {
    entry $td_Result -relief groove -state disabled
}
pack $td_Result -side left -expand 1 -fill x

# }}}
# {{{ the eval line

frame $td_EvalFrame -relief raised -borderwidth 2
pack $td_EvalFrame -side top -fill x -padx 2 -pady 2

label $td_EvalName -relief flat -text "Eval  :" -borderwidth 0 -width 8
pack $td_EvalName -side left

entry $td_Eval -relief groove -textvariable td_priv(eval)
pack $td_Eval -side left -expand 1 -fill x 

bind $td_Eval <Return> td_evalLine
td_cline_prepare $td_Eval
bind $td_Eval <Control-c> {wm positionfrom $td_Top user ; wm withdraw $td_Top}

# }}}
# {{{ the buttons

frame $td_Buttons
radiobutton $td_BStop -text Stop -width 4 -variable td_priv(state) -value stop \
	-relief raised

radiobutton $td_BNext -text Next -width 4 -variable td_priv(state) -value next \
	-relief raised
radiobutton $td_BSlow -text Slow -width 4 -variable td_priv(state) -value slow \
	-relief raised
radiobutton $td_BFast -text Fast -width 4 -variable td_priv(state) -value fast \
	-relief raised
radiobutton $td_BNonstop -text Nonstop -width 4 -variable td_priv(state) \
	-value nonstop -relief raised
radiobutton $td_BBreak -text Break -width 4 -variable td_priv(state) -value break \
	-relief raised

if {$tk_version >= 4.0} {
    pack $td_Buttons -side top -fill x
    pack $td_BStop -side left -expand 1 -fill x
    pack $td_BNext -side left -expand 1 -fill x
    pack $td_BSlow -side left -expand 1 -fill x
    pack $td_BFast -side left -expand 1 -fill x
    pack $td_BNonstop -side left -expand 1 -fill x
    pack $td_BBreak -side left -expand 1 -fill x
} else {
    pack $td_Buttons -side top -fill x -pady 2
    pack $td_BStop -side left -expand 1 -fill x -padx 2
    pack $td_BNext -side left -expand 1 -fill x -padx 2
    pack $td_BSlow -side left -expand 1 -fill x -padx 2
    pack $td_BFast -side left -expand 1 -fill x -padx 2
    pack $td_BNonstop -side left -expand 1 -fill x -padx 2
    pack $td_BBreak -side left -expand 1 -fill x -padx 2
}

# }}}
# {{{ the delay

# the following layout is different depending on the button's highlightframes
if {$tk_version >= 4.0} {
    frame $td_DelayFrame
    pack $td_DelayFrame -side top -fill x -padx 0 -pady 0

    frame $td_DelayFrame1 -borderwidth 2 -relief raised
    pack $td_DelayFrame1 -side left -expand 1 -fill x -padx 2 -pady 2

    label $td_Delay -text "Delay:  $td_priv(delay)" -width 11 -borderwidth 4
    pack $td_Delay -side left -expand 1 -fill both
} else {
    frame $td_DelayFrame
    pack $td_DelayFrame -side top -fill x -pady 2

    frame $td_DelayFrame1 -borderwidth 2 -relief raised
    pack $td_DelayFrame1 -side left -expand 1 -fill x -padx 2

    label $td_Delay -text "Delay:  $td_priv(delay)" -width 11 -borderwidth 1
    pack $td_Delay -side left -expand 1 -fill both
}

button $td_DelayLess -text "-" -width 2 -relief raised -command {
    global td_priv
    if {$td_priv(delay) >= 100} {
	incr td_priv(delay) -100
	$td_Delay configure -text "Delay: [format %4d $td_priv(delay)]"
    }
}

button $td_DelayMore -text "+" -width 2 -relief raised -command {
    global td_priv
    if {$td_priv(delay) < 1500} {
	incr td_priv(delay) 100
	$td_Delay configure -text "Delay: [format %4d $td_priv(delay)]"
    }
}
if {$tk_version >= 4.0} {
    pack $td_DelayLess -side left -fill both
    pack $td_DelayMore -side left -fill both
} else {
    pack $td_DelayLess -side left -fill both -padx 2
    pack $td_DelayMore -side left -fill both -padx 2
}

# }}}

wm geometry $td_Top $td_priv(listwidth)x$td_priv(height)
if {[info exists td_priv(geometry)]} {
    wm geometry $td_Top $td_priv(geometry)
    wm positionfrom $td_Top user
}
wm minsize $td_Top 27 2

# {{{ The Backtrace toplevel

toplevel $td_BT
wm withdraw $td_BT
wm title $td_BT TDebug-Backtrace

frame $td_BTMain -relief raised -borderwidth 2
pack $td_BTMain -expand 1 -fill both -padx 2 -pady 2

frame $td_BTTop
pack $td_BTTop -side top -expand 1 -fill both

scrollbar $td_BTScroll -command "$td_BTText yview" -relief sunken
pack $td_BTScroll -side $td_priv(scrollbarside) -fill y

text $td_BTText -relief sunken -borderwidth 2 -width 30 -height 3 -setgrid 1 \
	-wrap none -state disabled
pack $td_BTText -side $td_priv(scrollbarside) -expand 1 -fill both
$td_BTText configure -yscrollcommand "$td_BTScroll set"

if {$tk_version >= 4.0} {
    frame $td_BTSHFrame -borderwidth 0
    pack $td_BTSHFrame -side top -fill x

    scrollbar $td_BTScrollH -orient horizontal -relief sunken \
	    -command "$td_BTText xview"
    $td_BTText configure -xscrollcommand "$td_BTScrollH set"

    frame $td_BTFillH \
	    -width [expr {[$td_BTScroll cget -width] + 4 + \
		2 * [$td_BTScroll cget -highlightthickness]}] \
	    -height [expr {[$td_BTScrollH cget -width] + 4 + \
		2 * [$td_BTScrollH cget -highlightthickness]}]
    pack $td_BTFillH -side $td_priv(scrollbarside)
    pack $td_BTScrollH -side $td_priv(scrollbarside) -expand 1 -fill x
}

button $td_BTClose -text Close -relief raised \
	-command "wm positionfrom $td_BT user ;	wm withdraw $td_BT"
if {$tk_version >= 4.0} {
    pack $td_BTClose -side top -fill x
} else {
    pack $td_BTClose -side top -fill x -padx 2 -pady 2
}

wm geometry $td_BT $td_priv(backtracewidth)x$td_priv(backtraceheight)
if {[info exists td_priv(backtracegeometry)]} {
    wm geometry $td_BT $td_priv(backtracegeometry)
    wm positionfrom $td_BT user
}

bind $td_BT <Control-c> {wm positionfrom $td_BT user ; wm withdraw $td_BT}
bind $td_BT <Control-w> {$td_MenuOptions invoke 3}

#We need the input focus when the cursor is inside!
if {$tk_version < 4.0} {
    ##nagelfar ignore "Wrong number of arguments"
    if {"[focus default]" == "none"} {focus default .}
    bind $td_BT <FocusIn> {
	if {"%d" == "NotifyVirtual"} {focus %W}
    }
    bind $td_BT <FocusOut> {
	if {"%d" == "NotifyVirtual"} {focus [focus default]}
    }
}

# }}}
# {{{ The Widget Hierarchy toplevel

toplevel $td_WH
wm withdraw $td_WH
wm title $td_WH TDebug-Widget-Hierarchy

frame $td_WHMain -relief raised -borderwidth 2
pack $td_WHMain -expand 1 -fill both -padx 2 -pady 2

frame $td_WHTop
pack $td_WHTop -side top -expand 1 -fill both

scrollbar $td_WHScroll -command "$td_WHText yview" -relief sunken
pack $td_WHScroll -side $td_priv(scrollbarside) -fill y

text $td_WHText -relief sunken -borderwidth 2 -width 30 -height 3 -setgrid 1 \
	-wrap none -state disabled 
pack $td_WHText -side $td_priv(scrollbarside) -expand 1 -fill both
$td_WHText configure -yscrollcommand "$td_WHScroll set"

if {$tk_version >= 4.0} {
    frame $td_WHSHFrame -borderwidth 0
    pack $td_WHSHFrame -side top -fill x

    scrollbar $td_WHScrollH -orient horizontal -relief sunken \
	    -command "$td_WHText xview"
    $td_WHText configure -xscrollcommand "$td_WHScrollH set"

    frame $td_WHFillH \
	    -width [expr {[$td_WHScroll cget -width] + 4 + \
		2 * [$td_WHScroll cget -highlightthickness]}] \
	    -height [expr {[$td_WHScrollH cget -width] + 4 + \
		2 * [$td_WHScrollH cget -highlightthickness]}]
    pack $td_WHFillH -side $td_priv(scrollbarside)
    pack $td_WHScrollH -side $td_priv(scrollbarside) -expand 1 -fill x
}

button $td_WHClose -text Close -relief raised \
	-command "wm positionfrom $td_WH user ;	wm withdraw $td_WH"
if {$tk_version >= 4.0} {
    pack $td_WHClose -side top -fill x
} else {
    pack $td_WHClose -side top -fill x -padx 2 -pady 2
}
wm geometry $td_WH $td_priv(widgetswidth)x$td_priv(widgetsheight)
if {[info exists td_priv(widgetsgeometry)]} {
    wm geometry $td_WH $td_priv(widgetsgeometry)
    wm positionfrom $td_WH user
}

bind $td_WH <Control-c> {wm positionfrom $td_WH user ; wm withdraw $td_WH}
bind $td_WH <Control-f> {$td_MenuOptions invoke 4}
#We need the input focus when the cursor is inside!
if {$tk_version < 4.0} {
    ##nagelfar ignore "Wrong number of arguments"
    if {"[focus default]" == "none"} {focus default .}
    bind $td_WH <FocusIn> {
	if {"%d" == "NotifyVirtual"} {focus %W}
    }
    bind $td_WH <FocusOut> {
	if {"%d" == "NotifyVirtual"} {focus [focus default]}
    }
}

# }}}
# {{{ The Error Trace toplevel

toplevel $td_ET
wm withdraw $td_ET
wm title $td_ET TDebug-ErrorTrace

frame $td_ETMain -relief raised -borderwidth 2
pack $td_ETMain -expand 1 -fill both -padx 2 -pady 2

frame $td_ETTop
pack $td_ETTop -side top -expand 1 -fill both

scrollbar $td_ETScroll -command "$td_ETText yview" -relief sunken
pack $td_ETScroll -side $td_priv(scrollbarside) -fill y

text $td_ETText -relief sunken -borderwidth 2 -width 30 -height 3 -setgrid 1 \
	-wrap none -state disabled
pack $td_ETText -side $td_priv(scrollbarside) -expand 1 -fill both
$td_ETText configure -yscrollcommand "$td_ETScroll set"

if {$tk_version >= 4.0} {
    frame $td_ETSHFrame -borderwidth 0
    pack $td_ETSHFrame -side top -fill x

    scrollbar $td_ETScrollH -orient horizontal -relief sunken \
	    -command "$td_ETText xview"
    $td_ETText configure -xscrollcommand "$td_ETScrollH set"

    frame $td_ETFillH \
	    -width [expr {[$td_ETScroll cget -width] + 4 + \
		2 * [$td_ETScroll cget -highlightthickness]}] \
	    -height [expr {[$td_ETScrollH cget -width] + 4 + \
		2 * [$td_ETScrollH cget -highlightthickness]}]
    pack $td_ETFillH -side $td_priv(scrollbarside)
    pack $td_ETScrollH -side $td_priv(scrollbarside) -expand 1 -fill x
}

button $td_ETClose -text Close -relief raised \
	-command "wm positionfrom $td_ET user ;	wm withdraw $td_ET"
if {$tk_version >= 4.0} {
    pack $td_ETClose -side top -fill x
} else {
    pack $td_ETClose -side top -fill x -padx 2 -pady 2
}

wm geometry $td_ET $td_priv(errorwidth)x$td_priv(errorheight)
if {[info exists td_priv(errorgeometry)]} {
    wm geometry $td_ET $td_priv(errorgeometry)
    wm positionfrom $td_ET user
}

bind $td_ET <Control-c> {wm positionfrom $td_ET user ; wm withdraw $td_ET}
#We need the input focus when the cursor is inside!
if {$tk_version < 4.0} {
    ##nagelfar ignore "Wrong number of arguments"
    if {"[focus default]" == "none"} {focus default .}
    bind $td_ET <FocusIn> {
	if {"%d" == "NotifyVirtual"} {focus %W}
    }
    bind $td_ET <FocusOut> {
	if {"%d" == "NotifyVirtual"} {focus [focus default]}
}   }

# }}}

# }}}

# install new `proc'
fe_rename proc td_origProc
fe_rename td_proc proc

# {{{ Emacs Local Variables


# Local Variables:
# folded-file: t
# End:

# }}}
