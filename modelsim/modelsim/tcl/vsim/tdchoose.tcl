#!vish
#
# $Id: //dvt/mti/rel/6.5b/src/tkgui/tdchoose.tcl#1 $
#
# TdChoose.tcl - A simple debugger for tcl scripts
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

# {{{ procs

# {{{ td_rescanProcs

# Rescan the procs for the currently selected interpreter
# `td_priv(interp)'.

proc td_rescanProcs {} {
    global td_priv td_ChooseBoxL td_ChooseBoxR

    if {$td_priv(send) && ! [td_loadDebugger $td_priv(interp)]} {
		return
    }
    set names [td_sendOrEval td_preparedProcs]
    set normal [lindex $names 0]
    set prepared [lindex $names 1]
    if {$td_priv(hideownprocs)} {
		# remove all procs belonging to tddebug.tcl from the list
		set i1 [lsearch -exact $normal td_AAA]
		set i2 [lsearch -exact $normal td_zzz]
		if {$i1 != -1 && $i2 != -1} {
			set normal [lreplace $normal $i1 $i2]
		}
		set i1 [lsearch -exact $normal proc]
		if {$i1 != -1} {
			set normal [lreplace $normal $i1 $i1]
		}   
	}
    if {$td_priv(hidetkprocs)} {
		# This is more difficult. Remove any proc that matches
		# tk* to keep up with future extensions
		set i1 [lsearch -glob $normal tk*]
		if {$i1 != -1} {
			set i2 $i1
			foreach proc [lrange $normal $i1 end] {
				if {! [string match tk* $proc]} {
					break;
				}
				incr i2
			}
		}
		if {$i1 != -1 && $i2 != -1} {
			set normal [lreplace $normal $i1 $i2]
		}
		set i1 [lsearch -exact $normal auto_execok]
		set i2 [lsearch -exact $normal auto_reset]
		if {$i1 != -1 && $i2 != -1} {
			set normal [lreplace $normal $i1 $i2]
		}
		set i1 [lsearch -exact $normal unknown]
		if {$i1 != -1} {
			set normal [lreplace $normal $i1 $i1]
		}   
	}
	if {$td_priv(hidemtiprocs)} {
		# This is more difficult. Remove any proc that matches
		# mti* to keep up with future extensions
		set i1 [lsearch -glob $normal mti*]
		if {$i1 != -1} {
			set i2 $i1
			foreach proc [lrange $normal $i1 end] {
				if {! [string match mti* $proc]} {
					break;
				}
				incr i2
			}
		}
		if {$i1 != -1 && $i2 != -1} {
			set normal [lreplace $normal $i1 $i2]
		}
	}
    $td_ChooseBoxL delete 0 end
    $td_ChooseBoxR delete 0 end
    if {[string compare "" $normal]} {
		eval "$td_ChooseBoxL insert 0 $normal"
    }
    if {[string compare "" $prepared]} {
		eval "$td_ChooseBoxR insert 0 $prepared"
    }
}

# }}}
# {{{ td_smartRescan

# Do td_rescanProcs but keep current yview if possible.

proc td_smartRescan {} {
    global td_ChooseBoxL td_ChooseBoxR td_ChooseScrollL td_ChooseScrollR tk_version

    
    if {$tk_version >= 4.0} {
	set left [lindex [$td_ChooseBoxL yview] 0]
	set right [lindex [$td_ChooseBoxR yview] 0]
	td_rescanProcs
	$td_ChooseBoxL yview moveto $left
	$td_ChooseBoxR yview moveto $right
    } else {
	set left [lindex [$td_ChooseScrollL get] 2]
	set right [lindex [$td_ChooseScrollR get] 2]
	td_rescanProcs
	$td_ChooseBoxL yview $left
	$td_ChooseBoxR yview $right
    }
}

# }}}
# {{{ td_chooseOK

# Prepare or restore the proc that has been selected 
# Args:
# w		widget
# y		y-position of mouse cursor

proc td_chooseOK {w y} {
    global td_priv tk_version td_ChooseBoxL

    set sel [$w nearest $y]
    
    if {$sel != ""} {
	set name [$w get $sel]
    }
    if {$name != ""} {
	if {$td_priv(send)} {
	    if {! [td_loadDebugger $td_priv(interp)]} {return}
	}
	if {$w == $td_ChooseBoxL} {

	    # give some visible response
	    if {$tk_version >= 4.0} {
		$w selection clear 0 end
	    } else {
		$w select clear
	    }
	    update idletasks
	    
	    # can't use td_sendOrEval because of `after 1...'
	    if {$td_priv(send)} {
		if {[catch {send $td_priv(interp) \
			"after 1 \{td_prepareProc $name\}"} err]} {
		    td_panic $err
	    }   } else {
		td_prepareProc $name
	    }
	} else {
	    td_sendOrEval {td_restoreProc $name}
	}
	td_smartRescan
}   }

# }}}
# {{{ td_chooseList

# Display the selected proc.
# Args:
# w		widget
# y		y-position of mouse cursor

proc td_chooseList {w y} {
    global td_priv

    set sel [$w nearest $y]
    
    if {$sel != ""} {
	set name [$w get $sel]
    }
    if {$name != ""} {
	if {$td_priv(send)} {
	    if {! [td_loadDebugger $td_priv(interp)]} {return}
	}
	td_sendOrEval "td_displayProc $name"
}   }   

# }}}
# {{{ td_makeInterpMenu

# Setup the menu to change the selected interpreter. Don't diplay the
# interpreter of the Chooser

proc td_makeInterpMenu {} {
    global td_ChooseMenu td_ChooseMB

    $td_ChooseMenu delete 0 last
	##nagelfar ignore "Wrong number of arguments"
    set interps [winfo interps]
    set myind [lsearch -exact $interps [winfo name .]]
    set interps [lreplace $interps $myind $myind]
    if {$interps != ""} {
	foreach i $interps {
	    $td_ChooseMenu add command -label $i -command "td_doChange $i"
    }   } else {
	$td_ChooseMenu add command -label " <none> " 
	$td_ChooseMenu disable 0
    }
}

# }}}
# {{{ td_doChange

# Change `td_priv(interp)' to the interpreter chosen and
# call `td_rescan' to update the display.

proc td_doChange {args} {
    global td_priv
    set td_priv(interp) $args
    td_rescanProcs
}
    

# }}}
# {{{ td_popDebugger

# Make sure selected interpreter has sourced tddebug.tcl  and popup
# Debugger window

proc td_popDebugger {} {
    global td_priv
    if {$td_priv(send)} {
	if {! [td_loadDebugger $td_priv(interp)]} {return}
	if {[catch {
	    send $td_priv(interp) {
		wm deiconify $td_Top
		raise $td_Top
	}   } err]} {
	    td_panic $err
    }   } else {
	global td_Top
	wm deiconify $td_Top
}   }

# }}}
# {{{ td_loadDebugger

# Check if tddebug has been sourced. If not, try to do it.
# Catch fails of send to avoid exiting when hitting an inactive
# interpreter.
# Args:
# interp	Interpreter to check
# Return value:
#		1	successfull
#		0	not successfull

proc td_loadDebugger interp {
    global td_priv

    if {[catch {send $interp "info procs td_eval"} procs]} {
	if {[string match "X server insecure*" $procs]} {
	    bgerror "$procs\nSee Installation section of README !"
	} else {
	    bgerror $procs
	}
	return 0
    }
    if {$procs == ""} {
	if {[catch {send $interp \
		"source $td_priv(debugdir)/tddebug.tcl"} err]} {
	    bgerror $err
	    return 0
	}
	lappend td_priv(connected) $interp
	send $interp "set td_priv(chooseinterp) \{[winfo name .]\}"
    }   
    return 1
}

# }}}
# {{{ td_catchChooseScroll

proc td_catchChooseScroll {box scroll a b c d} {
    if {$a < $b && $c > 0} {
	$box yview 0
	$scroll set $a $b 0 [expr {$b - 1}]
    } elseif {$a -$c < $b} {
	$box yview [expr {$a - $b}]
	$scroll set $a $b [expr {$a - $b}] [expr {$a - 1}]
    } else {
	$scroll set $a $b $c $d
    }
}

# }}}
# {{{ td_panic

# This is called if send seems to work, but an error is caught anyway.
# As the text says, it shouldn't happen, but it will, if the application
# is busy, or maybe because of some real bug in tddebug.tcl
# Arg:
# err:			The error that was caught.

proc td_panic {err} {
    error "$err\nThis should never have happened !\
	    Please report this error and include the backtrace info."
}

# }}}
# {{{ td_sendOrEval

proc td_sendOrEval {cmd} {
    global td_priv
    if {! $td_priv(send)} {
	return [uplevel 1 $cmd]
    }
    if { [catch {uplevel 1 send \{$td_priv(interp)\} $cmd} err]} {
	td_panic $err
    } else {
	return $err
}   }

# }}}
# {{{ td_chooseExit

# Detach from all interpreters and exit

proc td_chooseExit {} {
    global td_priv
    
    if {!$td_priv(send)} {
	td_detachDebugger
    } else {
	foreach i $td_priv(connected) {
	    catch {send $i td_detachDebugger}
	}
	destroy .
}   }

# }}}
# {{{ td_getDebugdir

proc td_getDebugdir {} {
    set cwd [pwd]
    _cd [file dirname [info script]]
    set debugdir [pwd]
    _cd $cwd
    return $debugdir
}

# }}}

# }}}
# {{{ global variables

if {[file exists "~/.tdebugrc"]} {
    source "~/.tdebugrc"
    set td_priv(.tdebugrc) 1
}

# Setup default values for variables not set from .tdebugrc
# Most variables have only 2 legal alternatives, so we can
# also check for correctness.

foreach i [list \
    "send		           1	0" \
    "scrollbarside	   right	left" \
    "constrainscroll 	1	0" \
    "chooseheight	   10	NOCHECK" \
    "choosewidth	    20	NOCHECK" \
    "hideownprocs	    1	0" \
    "hidetkprocs	     0	1" \
	"hidemtiprocs     1 0" \
    [list debugdir		  [td_getDebugdir] NOCHECK] \
] {
    if {[lindex $i 2] != "NOCHECK"} {
		if {![info exists td_priv([lindex $i 0])] || \
				$td_priv([lindex $i 0]) != [lindex $i 2]} {
			set td_priv([lindex $i 0]) [lindex $i 1]
		}   
	} else {
		if {![info exists td_priv([lindex $i 0])]} {
			set td_priv([lindex $i 0]) [lindex $i 1]
		}
	}   
}

set td_priv(send) 0

if {$td_priv(send)} {
	##nagelfar ignore "Wrong number of arguments"
    set td_ips [winfo interps]
    if {[llength $td_ips] > 1} {
	foreach i $td_ips {
	    if {$i != [winfo name .]} {
		set td_priv(interp) $i
		break
    }   }   } else {
	set td_priv(interp) <none>
	unset td_ips
}   } else {
    set td_priv(interp) [winfo name .]
}

# }}}
# {{{ interface

# {{{ setup symbolic widget names for Chooser

if {$td_priv(send)} {
    set td_Choose 	""
} else {
    set td_Choose	.td_Choose
}
set td_ChooseNameFrame	$td_Choose.chooseNameFrame
set td_ChooseLabel	$td_ChooseNameFrame.chooseLabel
set td_ChooseButton	$td_ChooseNameFrame.chooseButton
set td_ChooseMenu	$td_ChooseButton.menu
set td_ChooseName	$td_ChooseNameFrame.chooseName

set td_ChooseFrame	$td_Choose.chooseFrame
set td_ChooseFrameL	$td_ChooseFrame.left
set td_ChooseTopL	$td_ChooseFrameL.top
set td_ChooseNameL	$td_ChooseTopL.chooseName
set td_ChooseBottomL	$td_ChooseFrameL.bottom
set td_ChooseBoxL	$td_ChooseBottomL.chooseBox
set td_ChooseScrollL	$td_ChooseBottomL.chooseScroll
set td_ChooseFrameR	$td_ChooseFrame.right
set td_ChooseTopR	$td_ChooseFrameR.top
set td_ChooseNameR	$td_ChooseTopR.chooseName
set td_ChooseBottomR	$td_ChooseFrameR.bottom
set td_ChooseBoxR	$td_ChooseBottomR.chooseBox
set td_ChooseScrollR	$td_ChooseBottomR.chooseScroll

set td_ChooseBFrame	$td_Choose.chooseBFrame
set td_ChooseBPop	$td_ChooseBFrame.pop
set td_ChooseBRescan 	$td_ChooseBFrame.rescan
set td_ChooseBExit	$td_ChooseBFrame.exit

# }}}
# {{{ Chooser Toplevel

if {$td_priv(send)} {
    wm title . TDebug-Choose
} else {
	catch {destroy $td_Choose}
    toplevel $td_Choose -class TDebug-Choose
    wm title $td_Choose TDebug-Choose
}

# }}}
# {{{ the name

frame $td_ChooseNameFrame -borderwidth 2 -relief raised 
pack $td_ChooseNameFrame -side top -fill x -padx 2 -pady 2
label $td_ChooseLabel -text Interp: -width 8
pack $td_ChooseLabel -side left
if {$td_priv(send)} {
    menubutton $td_ChooseButton -relief raised -text "+" -width 1 \
	    -menu $td_ChooseMenu
    pack $td_ChooseButton -side left 
    menu $td_ChooseMenu -postcommand td_makeInterpMenu
}
entry $td_ChooseName -relief groove -textvariable td_priv(interp) -state disabled \
	-width 8
if {$tk_version >= 4.0} {
    $td_ChooseName configure -highlightthickness 0
}

pack $td_ChooseName -side left -expand 1 -fill both

# }}}
# {{{ the listboxes

frame $td_ChooseFrame -borderwidth 0 -relief flat
pack $td_ChooseFrame -side top -expand 1 -fill both -padx 2 -pady 2

frame $td_ChooseFrameL -borderwidth 2 -relief raised
pack $td_ChooseFrameL -side left -expand 1 -fill both -padx 0

frame $td_ChooseTopL -borderwidth 0 -relief flat
pack $td_ChooseTopL -side top -fill x

label $td_ChooseNameL -text Normal
pack $td_ChooseNameL -side top -fill x

frame $td_ChooseBottomL -borderwidth 0 -relief flat
pack $td_ChooseBottomL -side top -expand 1 -fill both

scrollbar $td_ChooseScrollL -command "$td_ChooseBoxL yview" -relief sunken
pack $td_ChooseScrollL -side $td_priv(scrollbarside) -fill y

if {$tk_version >= 4.0} {
    listbox $td_ChooseBoxL -relief sunken -setgrid 1 -width 10 -height 3
} else {
	##nagelfar ignore Error: Bad option -geometry to listbox
    listbox $td_ChooseBoxL -relief sunken -setgrid 1 -geometry 10x3
}

if {$tk_version < 4.0 && $td_priv(constrainscroll)} {
    $td_ChooseBoxL configure -yscrollcommand \
	    "td_catchChooseScroll $td_ChooseBoxL $td_ChooseScrollL"
} else {
    $td_ChooseBoxL configure -yscrollcommand "$td_ChooseScrollL set"
}
pack $td_ChooseBoxL -side $td_priv(scrollbarside) -expand 1 -fill both

frame $td_ChooseFrameR -borderwidth 2 -relief raised
pack $td_ChooseFrameR -side left -expand 1 -fill both -padx 0

frame $td_ChooseTopR -borderwidth 0 -relief flat
pack $td_ChooseTopR -side top -fill x

label $td_ChooseNameR -text Prepared
pack $td_ChooseNameR -side top -fill x

frame $td_ChooseBottomR -borderwidth 0 -relief flat
pack $td_ChooseBottomR -side top -expand 1 -fill both

scrollbar $td_ChooseScrollR -command "$td_ChooseBoxR yview" -relief sunken
pack $td_ChooseScrollR -side $td_priv(scrollbarside) -fill y

if {$tk_version >= 4.0} {
    listbox $td_ChooseBoxR -relief sunken -setgrid 1 -width 10 -height 3
} else {
	##nagelfar ignore Error: Bad option -geometry to listbox
    listbox $td_ChooseBoxR -relief sunken -setgrid 1 -geometry 10x3
}

if {$tk_version < 4.0 && $td_priv(constrainscroll)} {
    $td_ChooseBoxR configure -yscrollcommand \
	    "td_catchChooseScroll $td_ChooseBoxR $td_ChooseScrollR"
} else {
    $td_ChooseBoxR configure -yscrollcommand "$td_ChooseScrollR set"
}
pack $td_ChooseBoxR -side $td_priv(scrollbarside) -expand 1 -fill both

# }}}
# {{{ the buttons

frame $td_ChooseBFrame
pack $td_ChooseBFrame -side top -fill x; # -padx 2 -pady 2

button $td_ChooseBRescan -text "Rescan" -command td_smartRescan -width 6
button $td_ChooseBPop -text "Popup" -command td_popDebugger -width 6
button $td_ChooseBExit -relief raised -text "Exit" -width 6 \
	-command td_chooseExit

if {$tk_version >= 4.0} {
    pack $td_ChooseBRescan -side left -expand 1 -fill x
    pack $td_ChooseBPop -side left -expand 1 -fill x
    pack $td_ChooseBExit -side left -fill x -expand 1
} else {
    pack $td_ChooseBRescan -side left -expand 1 -fill x -padx 2 -pady 2
    pack $td_ChooseBPop -side left -expand 1 -fill x -padx 2 -pady 2
    pack $td_ChooseBExit -side left -fill x -expand 1 -padx 2 -pady 2
}

# }}}

# {{{ configure toplevel

if {$td_priv(send)} {
    wm geometry . $td_priv(choosewidth)x$td_priv(chooseheight)
    if {[info exists td_priv(choosegeometry)]} {
	wm geometry . $td_priv(choosegeometry)
	wm positionfrom . user
    }
    wm minsize . 17 3
} else {
    wm geometry $td_Choose $td_priv(choosewidth)x$td_priv(chooseheight)
    if {[info exists td_priv(choosegeometry)]} {
	wm geometry $td_Choose $td_priv(choosegeometry)
	wm positionfrom $td_Choose user
    }
    wm minsize $td_Choose 17 3
}

# }}}
# {{{ configure listboxes

# {{{ left box

$td_ChooseBoxL configure -exportselection no  -selectbackground \
        [lindex [$td_ChooseBPop configure -activebackground] 4]
if {$tk_version >= 4.0} {
    bind $td_ChooseBoxL <Enter> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxL <Leave> {%W selection clear 0 end}
    bind $td_ChooseBoxL <Any-Motion> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxL <Any-Motion> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxL <Button-2> {+ %W selection clear 0 end}
    bind $td_ChooseBoxL <B2-Motion> {%W scan dragto %x %y}
    bind $td_ChooseBoxL <ButtonRelease-2> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
} else {
    bind $td_ChooseBoxL <Enter> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxL <Leave> {%W select clear}
    bind $td_ChooseBoxL <Any-Motion> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxL <Any-Motion> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxL <Button-2> {+ %W select clear}
    bind $td_ChooseBoxL <B2-Motion> {%W scan dragto %x %y}
    bind $td_ChooseBoxL <ButtonRelease-2> {%W select from [%W nearest %y]}
}
bind $td_ChooseBoxL <1> "td_chooseOK %W %y"
bind $td_ChooseBoxL <3> "td_chooseList %W %y"

# }}}
# {{{ right box

$td_ChooseBoxR configure -exportselection no  -selectbackground \
        [lindex [$td_ChooseBPop configure -activebackground] 4]
if {$tk_version >= 4.0} {
    bind $td_ChooseBoxR <Enter> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxR <Leave> {%W selection clear 0 end}
    bind $td_ChooseBoxR <Any-Motion> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxR <Any-Motion> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
    bind $td_ChooseBoxR <Button-2> {+ %W selection clear 0 end}
    bind $td_ChooseBoxR <B2-Motion> {%W scan dragto %x %y}
    bind $td_ChooseBoxR <ButtonRelease-2> {
	%W selection clear 0 end
	%W selection set [%W nearest %y] [%W nearest %y]
    }
} else {
    bind $td_ChooseBoxR <Enter> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxR <Leave> {%W select clear}
    bind $td_ChooseBoxR <Any-Motion> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxR <Any-Motion> {%W select from [%W nearest %y]}
    bind $td_ChooseBoxR <Button-2> {+ %W select clear}
    bind $td_ChooseBoxR <B2-Motion> {%W scan dragto %x %y}
    bind $td_ChooseBoxR <ButtonRelease-2> {%W select from [%W nearest %y]}
}
bind $td_ChooseBoxR <1> "td_chooseOK %W %y"
bind $td_ChooseBoxR <3> "td_chooseList %W %y"

# }}}

# }}}

# }}}

if {! $td_priv(send)} {
    source $td_priv(debugdir)/tddebug.tcl
    td_rescanProcs
} elseif {$td_priv(interp) != "<none>"} {
    td_rescanProcs
}   

# {{{ Emacs Local Variables


# Local Variables:
# folded-file: t
# End:

# }}}
