#============================================================#
#============================================================#
#============================================================#
#                                                            #
# ManView proper                                             #
#                                                            #
#                                                            #
# Copyright 1991-2009 Mentor Graphics Corporation               #
#                                                            #
# All Rights Reserved                                        #
#                                                            #
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY            #
# INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS       #
# CORPORATION OR ITS LICENSORS AND IS SUBJECT TO             #
# LICENSE TERMS                                              #
#                                                            #
#============================================================#
#============================================================#
#============================================================#

package require Tcl
package require uri

namespace eval Manview {
	variable Manview

	# set initial values
	set Manview(Home) [MtiFS::NormalizeFileName [file join $env(MODEL_TECH) .. docs tcl_help_html contents.htm]]		;# home document
	set Manview(lastFile) ""            ;# filename of last file loaded
}

proc manview {{object {}}} {
	tcl_manview $object
}

proc WhatViewerDialog {which msg} {
	global tmpBrowser PrefMain
	destroy .whatbrowser
	set tmpBrowser $PrefMain($which)
	set top [toplevel .whatbrowser]
	wm withdraw $top
	wm transient $top .
	wm title $top "$msg Viewer"
	set ti [label $top.ti -text "No default $msg viewer has been specified nor could one be found.\nPlease enter the path to your prefered $msg viewer or browser."]
	set fe [MtiFormUtil::makeFileEntryBox2 $top.fe -label "$msg Viewer" \
				-textvar tmpBrowser \
				-mode open \
				-entrywidth 18]
	set bb [MtiFormUtil::makeStdButtonBox $top.bb $top "destroy $top" no OK Cancel "" 0 "destroy $top; set tmpBrowser none"]

	set entry $fe.e

	bind $entry <Return> "destroy $top"

	pack $ti -side top -fill both -expand 1 -padx 5 -pady 5
	pack $fe -side top -fill both -expand 1
	pack $bb -side top -fill none -expand 0 -anchor e
	
	Geometry::center_dialog $top
    wm resizable $top 0 0
	ModalDialogActivate $top $entry
	set tmp $tmpBrowser
	if {$tmp == ""} {
		set tmp none
	}
	unset tmpBrowser
	set tmp
}

proc WhichBrowser {flist} {
	global tmpBrowser
	destroy .whichbrowser
	set top [toplevel .whichbrowser]
	wm withdraw $top
	wm transient $top .
	set ti [label $top.ti -text "The following netscapes have been found.\nPlease select one or enter the path to a prefered HTML viewer."]
	set li [iwidgets::scrolledlistbox $top.li \
				-selectmode single \
				-vscrollmode dynamic -hscrollmode dynamic \
				-labeltext "Please pick one:" \
				-borderwidth 2]
	foreach n $flist {
		$li insert end $n
	}
	$li configure -selectioncommand "set tmpBrowser \[$li getcurselection\]"

	set fe [MtiFormUtil::makeFileEntryBox2 $top.fe -label "HTML Viewer" \
				-textvar tmpBrowser \
				-mode open \
				-entrywidth 18]
	set bb [MtiFormUtil::makeStdButtonBox $top.bb $top "destroy $top" no OK Cancel "" 0 "destroy $top; set tmpBrowser none"]

	pack $ti -side top -fill both -expand 1 -padx 5 -pady 5
	pack $li -side top -fill both -expand 1
	pack $fe -side top -fill both -expand 1
	pack $bb -side top -fill none -expand 0 -anchor e
	
	Geometry::center_dialog $top
    wm resizable $top 0 0
	ModalDialogActivate $top
	set tmp $tmpBrowser
	if {$tmp == ""} {
		set tmp none
	}
	unset tmpBrowser
	set tmp
}

proc EditViewer {which} {
	if {$which == "HTML"} {
		set pref htmlBrowser
	} else {
		set pref pdfViewer
	}
	set viewer [WhatViewerDialog $pref $which]
	if {$viewer != "none" && $viewer != ""} {
		SaveViewer $pref $viewer
	}
}

proc SaveViewer {which viewer} {
	global env PrefMain
	# Make this selection permanent
	set PrefMain($which) $viewer
	mtiPropertyCmd set $which PrefMain($which)
}

proc tcl_manview {{file {}}} {
	global PrefDefault
	set t 0
	while {[winfo exists .mv$t]} {incr t}
	set top [toplevel .mv$t]
	wm protocol $top WM_DELETE_WINDOW "destroy $top"
	set menu_bar [CreateMenuBar $top]

	AddMenu		"File"			$menu_bar	"" F
	AddMenuItem "Contents"		""			[list Manview::importHome $top] "" C
	AddMenuItem "Top"			""			[list Manview::pop_and_import $top] "" T
	AddSeparator 

	AddMenuItem "Close"         ""			 "destroy $top" "" L
	

	AddMenu		"Edit"			$menu_bar	"" E
	AddMenuItem "Copy"			""          "Manview::cutcopy $top 0" "" C
	AddSeparator	
	AddMenuItem "Select All"	""			"Manview::select_all $top" "" S
	AddMenuItem "Unselect All"	""			"Manview::unselect_all $top" "" U
	AddSeparator
    AddMenuItem "Find..."		""			"Transcript::SourceSearchDialog $top" "" F
	AddWindowMenu $menu_bar
	AddSystemMenu $menu_bar

	bind $top <<Find>> "Transcript::SourceSearchDialog $top; break"

	set tbar [frame $top.tbar]
	set fentry [MtiFormUtil::makeFileEntryBox $tbar.file -label {File:} \
					-textvar Manview::Manview(File:$top) -entrywidth 58]
	set fe [$fentry.fe component entry]
	set st [iwidgets::scrolledhtml $top.st  -update 0 -borderwidth 1 -sbwidth $PrefDefault(sb_width)]
	foreach {opt name class default val} [join [$st tag configure sel]] {
		$st tag configure altSel $opt $val
	}
	wm title $top [file rootname [file tail $file]]

	set home [button $tbar.top -text Top -command [list Manview::pop_and_import $top]]
	set back [button $tbar.back -text Back -command [list Manview::back $top]]

	set icon [GetButtonIcon back]
	if {$icon != ""} {
		eval $back config $icon
	}
	set icon [GetButtonIcon open]
	if {$icon != ""} {
		eval $fentry.browse config $icon
	}

   # Get the inlined search bar set up
   #
   SearchBar::register \
       -mode $SearchBar::modes(FIND) \
       -parent $top \
       -src [$st component text] \
       -show [list pack %W -side bottom -before $top.st -fill x] \
       -close {pack forget %W} \
       -search "Transcript::doSearchBarSearch"

	# Bindings
	bind $fe <Return> [list Manview::importFile $top]

	# Generate layout
	pack $back -side left
	pack $fentry -side left -fill x -expand 1
	pack $tbar -side top -fill x -expand 0
	pack $st -side bottom -expand 1 -fill both

	set Manview::Manview(File:$top) $file
	set Manview::Manview(History:$top) ""

	if {$file == "" || ![file exists $file]} {return}

	tkwait visibility $st
	$st clear
	Manview::importFile $top
	$st tag raise sel

	return ""
}

proc Manview::open_file {top {file ""}} {
	variable Manview
	if {[string length $file] == 0} {
		set file [tk_getOpenFile -initialdir [file dirname $file] -initialfile $file]
	}
	if {$file == ""} {return}
	set Manview(File:$top) $file

	catch {import $top $Manview(File:$top)}
}

proc Manview::save_file winname {
	variable Manview
	if {$Manview(Readonly:$winname) == "-r"} return
	set file $Manview(File:$winname)
	if {$file == ""} return
	set st $winname.st
	if {[catch {open $file w} fd]} {
		tk_messageBox -parent $winname -icon error -title "Save Error" -message $fd -type ok -default ok
		return
	}
    puts $fd [$st get 1.0 end]
    close $fd
}

proc Manview::save_as_file winname {
	variable Manview
	if {$Manview(Readonly:$winname) == "-r"} return
	set file [tk_getSaveFile -initialfile $Manview(File:$winname) -parent $winname]
	set Manview(File:$winname) $file
	wm title $winname $Manview(File:$winname)
	if {$file == ""} return
	save_file $winname
}

proc Manview::cutcopy {w delete_sel} {
	set st $w.st
	set sel_range [$st tag ranges sel]
	if {"$sel_range" != ""} {
		clipboard clear
		set i 0
		set len [llength $sel_range]
		while {$i < $len} {
			set mark1 [lindex $sel_range $i]
			set mark2 [lindex $sel_range [expr {$i + 1}]]
			set text [$st get $mark1 $mark2]
			clipboard append $text
			if {$delete_sel} {
				$st delete $mark1 $mark2
			}
			incr i 2
		}
	}
}

proc Manview::select_all {w} {
	set st $w.st
	$st tag add sel 1.0 end
}
proc Manview::unselect_all {w} {
	set st $w.st
	catch {$st tag remove sel sel.first sel.last}
}

proc Manview::import {top link} {
	variable Manview
	$top.st component text configure -cursor watch
	update idletasks
	set pwd [$top.st pwd]
	set file [file join $pwd $link]
	push_history $top $file
	set Manview(File:$top) $file
	$top.st import -link $link
	$top.st component text configure -cursor {}
	update idletasks
}

proc Manview::push_history {top file} {
	variable Manview
	if {[lindex $Manview(History:$top) 0] != $file} {
		set Manview(History:$top) [linsert $Manview(History:$top) 0 $file]
	}
}

proc Manview::pop_history {top} {
	variable Manview
	if {[llength $Manview(History:$top)] > 1} {
		set Manview(History:$top) [lrange $Manview(History:$top) 1 end]
	}
	return [lindex $Manview(History:$top) 0]
}

proc Manview::pop_home {top} {
	variable Manview
	set Manview(History:$top) [lrange $Manview(History:$top) end end]
	return [lindex $Manview(History:$top) 0]
}	

proc Manview::pop_and_import {top} {
	import $top [pop_home $top]
}

proc Manview::back {top} {
	variable Manview
	set Manview(File:$top) [pop_history $top]
	catch {import $top $Manview(File:$top)}
}

proc Manview::importFile {top} {
	variable Manview
	catch {import $top $Manview(File:$top)}
}

proc Manview::importHome {top} {
	variable Manview
	import $top $Manview(Home)
}
