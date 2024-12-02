#
#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
# 
#   

package require Mtiwidgets

namespace eval notepad {
	variable Notepad
	variable notefiles
	variable notepads
	variable search_pat
	variable search_dir
	variable search_regexp
	variable replace_pat
	variable search_case

}

proc notepad {args} {
	uplevel notepad::notepad $args
}



proc notepad::notepad {{file {}} {readonly ""} {append 0}} {
	variable Notepad
	variable notefiles
	variable notepads

	set winname .np
	set _ff fixedFont

   set SEARCH_CMD "Transcript::SourceSearchDialog $winname 0"

	if {![winfo exists $winname]} {

		toplevel $winname
		set menu_bar [CreateMenuBar $winname]

		AddMenu file $menu_bar  ""     f
		AddMenuItem "New"				"" "notepad::new_file $winname" "" N
		AddMenuItem "Open..."			"" "notepad::open_file $winname" "" O
		AddMenuItem "Insert..."			"" "notepad::insert_file $winname" can_insert I
		AddSeparator
		AddMenuItem "Save"				"" "notepad::save_file $winname" can_save S
		AddMenuItem "Save as..."		"" "notepad::save_as_file $winname" can_saveas A
		AddSeparator 
		AddMenuItem "Close file"		"" "notepad::close_file $winname" can_closefile C
		AddSeparator
		AddMenuItem "Close window"		"" "notepad::close_notepad $winname" "" W
 
		AddMenu edit $menu_bar  ""    e
		AddMenuItem  "Cut"				"" "notepad::cutcopy $winname 1"	can_cut C
		AddMenuItem  "Copy"				"" "notepad::cutcopy $winname 0"	can_copy O
		AddMenuItem  "Paste"			"" "notepad::paste $winname"		can_paste P
		AddSeparator
		AddMenuItem  "Select All"		"" "notepad::select_all $winname"	can_selectall S
		AddMenuItem  "Unselect All"		"" "notepad::unselect_all $winname"	can_unselectall U
		AddSeparator	
		AddMenuItem  "Find..."			"" $SEARCH_CMD	can_findaction F
		AddMenuItem  "Replace..."		"" "Transcript::SourceSearchDialog $winname 1"	can_replace R
		AddSeparator		
		AddMenuCB    "Read Only"		"" "notepad::update_readonly_state $winname" notepad::Notepad(Readonly:$winname) can_readonly Y -onvalue -r -offvalue "-edit"
		AddWindowMenu $menu_bar notepad
		AddSystemMenu $menu_bar

		bind $winname <Destroy>		"notepad::update_for_destroy"
		bind $winname <FocusIn>		"notepad::focusin %W"
		bind $winname <FocusOut>	"notepad::focusout %W"

	#	$::vsimPriv(Vcop) RegisterWindow $winname notepad::Action
		wm protocol $winname WM_DELETE_WINDOW "notepad::close_notepad $winname"

		set mdi [::mtiwidgets::mdiframe $winname.mdi -borderwidth 2 -relief sunken -mode $::vsimPriv(MDIMode)]

		pack $mdi -side top -expand 1 -fill both

		set fh [font metrics $_ff -linespace]
		set fw [font measure $_ff "0"]
		wm geometry $winname [format "%dx%d" [expr {$fw * 80}] [expr {$fh * 25}]]
		wm title $winname "Notepad"
	} else {
		set mdi .np.mdi
	}

	if {[info exists notefiles($file)] } {
		set client $notefiles($file)
		$mdi setcurrent $client
		if {$append == 0} {
			return
		}
		notepad::close_file $winname
	}
	set t 0
	while {[info exists notepads($t)]} {incr t}

	set client [$mdi client $t -title $file]
	set pad [$winname.mdi lastcurrent]
	set top [$mdi childsite $pad]
	$mdi component $t configure -command "notepad::clientcmd $winname [$mdi component $t] %a"
	set notefiles($file) $t
	set notepads($t) $file

	set st [iwidgets::scrolledtext $top.st -hscrollmode dynamic -vscrollmode dynamic]
	pack $st -side top -expand 1 -fill both
	set Notepad(File:$top) $file
	
	$st config -wrap none -textfont $_ff
	set text [$st component text]
	tabset $text 8
	foreach {opt name class default val} [join [$text tag configure sel]] {
		$text tag configure altSel $opt $val
	}
	bind $text <<Selection>> "$text tag remove altSel 1.0 end"

   # Get the inlined search bar set up
   #
   SearchBar::register \
       -mode $SearchBar::modes(FIND) \
       -parent $top \
       -src $text \
       -show [list pack %W -side bottom -before $top.st -fill x] \
       -close {pack forget %W} \
       -search "Transcript::doSearchBarSearch"

   if {$::tcl_platform(platform) == "windows"} {
      bind $winname <Control-Key-f> $SEARCH_CMD
   } else {
      bind $winname <Control-Key-s> $SEARCH_CMD
   }

	set Notepad(Readonly:$top) -edit
	if {$file == "" || ![file exists $file]} {
		notepad::set_signature $winname
		return
	}
	if {[catch {open $file r} f]} {
		$st insert end $f
		notepad::set_signature $winname
		return
	}
	$st insert end [read $f]
	close $f
	if {$readonly == "-r"} {
		$st config -state disabled
	}
	set Notepad(Readonly:$top) $readonly
	notepad::set_signature $winname

	$mdi maxclient $t
	return ""
}




proc notepad::Action { operation args } {
	global vsimPriv 
	set winname .np ;# This shouldn't be hard coded
	switch $operation {


		SetMenuState	{
			SetActiveWindowMenu "Notepad" N
			set menus [lindex $args 0]
			foreach submenu $menus {
				set cmd [lindex $submenu 1]
				set action [lindex $submenu 0]
				switch $action {
					can_save {
						set cmd [Vsimmenu::SetMenuText $action "Save" $cmd]
						lappend cmd normal
					}

					can_saveas { 
						set cmd [Vsimmenu::SetMenuText $action "Save As..." $cmd]
						lappend cmd normal
					}

					can_insert -
					can_closefile { 
						set pad [$winname.mdi lastcurrent]	
						if {$pad != "" && [winfo exists [set top [$winname.mdi childsite $pad]]]} {
							lappend cmd normal
						} else {	
							lappend cmd disabled
						}
					}
					
					can_cut -
					can_copy -
					can_paste -
					can_selectall -
					can_unselectall -
					can_findaction -
					can_replace -
					can_readonly {
						set pad [$winname.mdi lastcurrent]
						if {$pad != "" && [winfo exists [set top [$winname.mdi childsite $pad]]]} {
							set txt $top.st
							switch [$txt cget -state] {
								normal {
									set Notepad(Readonly:$winname) "-edit"
								}
								disabled {
									set Notepad(Readonly:$winname) "-r"
								}
							}
							lappend cmd normal
						} else {
							lappend cmd disable
						}
					}

					default		{
						if {[regexp {value_(.*)} $action dummy subaction]} {
							continue
						}
						lappend cmd disabled
					}

				}
				eval $cmd
			}
		}

		default			{
			return 0
		}
	}

}


proc notepad::focusin {w} {
}

proc notepad::focusout {w} {
}

proc notepad::update_for_destroy {} {
}



proc notepad::update_readonly_state winname {
	variable Notepad
	set pad [$winname.mdi lastcurrent]
	if {$pad != ""} {
		set top [$winname.mdi childsite $pad]
		if {![winfo exists $top]} {
			return
		}
		set txt $top.st
		if {$Notepad(Readonly:$winname) == "-r"} {
			$txt config -state disabled
		} elseif {$Notepad(Readonly:$winname) == "-edit"} {
			$txt config -state normal
		} else {
			return -code error "notepad:: Bad mode switch specified"
		}
	}
}

proc notepad::set_signature winname {
	variable Notepad
	set pad [$winname.mdi lastcurrent]
	if {$pad != ""} {
		set top [$winname.mdi childsite $pad]
		if {![winfo exists $top]} {
			return
		}
		set txt $top.st
		set Notepad(Signature:$top) [CRCString [$txt get 1.0 end]]
	}
}

proc notepad::clientcmd {winname top action} {
	if {$action == "close"} {
		return [notepad::close_pad $winname $top]
	}
	return 1
}

proc notepad::close_pad {winname {top ""}} {
	variable Notepad
	variable notefiles
	variable notepads

	if {$top != ""} {
		set pad [winfo name $top]
		set top [$top childsite]
	} else {
		set pad [$winname.mdi lastcurrent]
		set top [$winname.mdi childsite $pad]
	}
	if {$pad == ""} {
		return 1
	}
	if {![winfo exists $top]} {
		return 1
	}
	set txt $top.st
	set new_signature [CRCString [$txt get 1.0 end]]
	if {[info exists Notepad(Signature:$top)] && "$new_signature" != "$Notepad(Signature:$top)"} {
		set ans [tk_messageBox -parent $winname -icon question -title "Notepad" -message "Save changes to file?" -type yesnocancel -default yes]
		switch $ans {
			no  { }
			yes { 
				set file $Notepad(File:$top)
				if {$file == "" || ![file exists $file] || ![file writable $file]} {
					notepad::save_as_file $winname
				} else {
					notepad::save_file $winname
				}
			}
			cancel { return 1 }
		}
	}

	catch {set file $notepads($pad)}
	catch {unset notefiles($file)}
	catch {unset notepads($pad)}
	catch {unset Notepad(File:$top)}
	catch {unset Notepad(Readonly:$top)}
	catch {unset Notepad(Signature:$top)}
	return 0
}

proc notepad::close_notepad winname {
	variable Notepad
	variable notefiles
	variable notepads
	foreach pad [array names notepads] {
		$winname.mdi setcurrent $pad
		update
		if {[notepad::close_pad $winname]} {
			return
		}
	}
	catch {unset notefiles}
	catch {unset notepads}
	catch {unset Notepad}
	destroy $winname
}

proc notepad::new_file winname {
	notepad ""
	return
}

proc notepad::open_file winname {
	variable Notepad
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {[info exists Notepad(File:$top)]} {
		set initfile $Notepad(File:$top)
	} else {
		set initfile ""
	}
	set file [tk_getOpenFile -initialfile $initfile -parent $winname]
	if {$file == ""} {return}
	notepad $file
}

proc notepad::insert_file winname {
	variable Notepad
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	set file [tk_getOpenFile -initialfile $Notepad(File:$top) -parent $winname]
	if {$file == ""} {return}
	set f [open $file r]
	$txt config -wrap none
	$txt insert insert [read $f]
	close $f
}

proc notepad::save_file winname {
	variable Notepad
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	if {[info exists Notepad(File:$top)]} {
		set file $Notepad(File:$top)
	} else {
		set file ""
	}
	if {$file == ""} return
	if {[catch {open $file w} fd]} {
		tk_messageBox -parent $winname -icon error -title "Save Error" -message $fd -type ok -default ok
		return
	}
	puts -nonewline $fd [$txt get 1.0 end]
	close $fd
	notepad::set_signature $winname
}

proc notepad::save_as_file winname {
	variable Notepad

	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	if {[info exists Notepad(File:$top)]} {
		set initFile $Notepad(File:$top)
	} else {
		set initFile ""
	}
	set file [tk_getSaveFile -initialfile $initFile -parent $winname]
	set Notepad(File:$top) $file
	$winname.mdi component $pad configure -title $file
	if {$file == ""} return
	notepad::save_file $winname
	notepad::set_signature $winname
}

proc notepad::cutcopy {winname delete_sel} {
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	set sel_range [$txt tag ranges sel]
	if {"$sel_range" != ""} {
		clipboard clear
		set i 0
		set len [llength $sel_range]
		while {$i < $len} {
			set mark1 [lindex $sel_range $i]
			set mark2 [lindex $sel_range [expr {$i + 1}]]
			set text [$txt get $mark1 $mark2]
			clipboard append $text
			if {$delete_sel} {
				$txt delete $mark1 $mark2
			}
			incr i 2
		}
	}
}

proc notepad::paste {winname} {
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	set text [selection get -selection CLIPBOARD]
	$txt insert insert $text
}

proc notepad::select_all {winname} {
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	$txt tag add sel 1.0 end
}
proc notepad::unselect_all {winname} {
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	set txt $top.st
	catch {$txt tag remove sel sel.first sel.last}
}

proc notepad::close_file {winname} {
	set pad [$winname.mdi lastcurrent]
	set top [$winname.mdi childsite $pad]
	if {![winfo exists $top]} {
		return
	}
	$winname.mdi closeclient $pad
}

proc notepad::SearchDialog {w {replace 0}} {
	variable search_pat
	variable search_dir
	variable search_regexp
	variable replace_pat

	set top [winfo toplevel $w]

	# If this window is a child in a Mdi frame
	# then use the Mdi frame window for searching
	set z $w
	while {$z != $top} {
		set z [winfo parent $z]
		if {[winfo class $z] == "Mdiframe"} {
			echo "Switching $w to $z"
			set w [winfo parent $z]
			break
		}
	}
	set parent_title [wm title [winfo toplevel $top]]
	set parent $top
	set title "Find in $parent_title"

	if {![info exists search_pat]} {
		set search_pat ""
	}
	if {![info exists search_dir]} {
		set search_dir 1
	}
	if {![info exists search_regexp]} {
		set search_regexp 0
	}
	if {[winfo exists $top.search]} {
		set rf $top.search.rpl
		set rb $top.search.rb
		set bc $top.search.bc
		if {$replace && ![winfo exists $rf]} {
			destroy $top.search
		} elseif {$replace && [winfo exists $rf]} {
			grid $rf  -row 1 -column 0 -columnspan 2 -sticky ew  -padx 10
			grid $rb  -row 1 -column 2               -sticky sew -pady 2 -ipadx 8
			wm deiconify $top.search
			#raise $top.search
			wm title $top.search $title
			focus $top.search.ent.box
			return ""
		} elseif {!$replace && [winfo exists $rf]} {
			set rb $top.search.rb
			set bc $top.search.bc
			grid forget $rf
			grid forget $rb
			wm deiconify $top.search
			#raise $top.search
			wm title $top.search $title
			focus $top.search.ent.box
			return ""
		} else {
			wm deiconify $top.search
			#raise $top.search
			wm title $top.search $title
			focus $top.search.ent.box
			set txt [SubWidget $w Text]
			set r [$txt tag ranges sel]
			if {[llength $r] != 0} {
				scan [$txt index sel.first] "%d.%d" first_line char
				scan [$txt index sel.last ] "%d.%d" last_line char
				if {$first_line == $last_line} {
					set search_pat [$txt get sel.first sel.last]
					# Just changed the search pattern, the first "find" will
					# stop at the current selection.  
					# We want to move to the next one
					Transcript::SourceSearchNext $w
				}
			}
			Transcript::SourceSearchNext $w
			return ""
		}
	}

    set f [toplevel $top.search -borderwidth 10]
	wm withdraw $f
	wm title $f $title
    set p2 [frame $f.p2 -relief flat]
	set txt [SubWidget $w Text]
    set r [$txt tag ranges sel]
    if {[llength $r] != 0} {
        scan [$txt index sel.first] "%d.%d" first_line char
        scan [$txt index sel.last ] "%d.%d" last_line char
        if {$first_line == $last_line} {
            set search_pat [$txt get sel.first sel.last]
        }
    }   
    set ef [MtiFormUtil::makeEntryBox $f.ent -label {Find:} -variable notepad::search_pat]
	$f.ent.box configure -exportselection 0

	if {$replace} {
		set rf [MtiFormUtil::makeEntryBox $f.rpl -label {Replace:} -variable notepad::replace_pat]
	}

	if {![info exists search_case]} {
		set search_case 0
	}

    set cs [checkbutton $f.cs \
		-variable notepad::search_case \
		-onvalue 1 -offvalue 0 \
		-text "Case sensitive"]

    set dir [checkbutton $f.dir \
		-variable notepad::search_dir \
		-onvalue 0 -offvalue 1 \
		-text "Search backwards"]

    set re [checkbutton $f.re \
		-variable notepad::search_regexp \
		-onvalue 1 -offvalue 0 \
		-text "Regular expression"]

	set bf [button $top.search.bf \
		-text "Find Next" \
		-command "Transcript::sourceSearch \[SubWidget $w Text\] \$notepad::search_pat \$notepad::search_dir \$notepad::search_case \$notepad::search_regexp"]

	if {$replace} {
		set rb [button $top.search.rb \
					-text "Replace" \
					-command "Transcript::sourceReplace \[SubWidget $w Text\] \$notepad::replace_pat $bf \$notepad::search_regexp \$notepad::search_pat"]
	}

	set bc [button $top.search.bc \
		-text "Close" \
		-command "destroy $top.search"]

	focus $f.ent.box
	bind $f <Key-Return> "$top.search.bf invoke; EntryHighlightTo $top.search.ent.box $top.search"
	if {$::tcl_platform(platform) == "windows"} {
		bind $f <Key-Escape> "destroy $top.search"
	}
	grid     $ef  -row 0 -column 0 -columnspan 2 -sticky ew -padx 10
	if {$replace} {
		grid $rf  -row 1 -column 0 -columnspan 2 -sticky ew -padx 10
	}
	grid     $cs  -row 2 -column 0               -sticky w
	grid     $dir -row 2 -column 1               -sticky w
	grid     $re  -row 3 -column 0               -sticky w
	grid     $bf  -row 0 -column 2               -sticky sew -pady 2 -ipadx 8
	if {$replace} {
		grid $rb  -row 1 -column 2               -sticky sew -pady 2 -ipadx 8
	}
	grid $bc  -row 2 -column 2               -sticky new -pady 2 -ipadx 8
	grid columnconfigure $f 1 -pad 10
	grid columnconfigure $f 2 -pad 10
	wm resizable $f 0 0
	wm transient $f $parent
	Geometry::center_dialog $f $parent
}

proc notepad::SearchNext {w} {
	variable search_pat
	variable search_dir
	variable search_case
	variable search_regexp

	set top [winfo toplevel $w]
	if {$top == "."} {
		set top ""
	}
	if {![info exists search_pat] || $search_pat == ""} return
	set txt [SubWidget $w Text]
	Transcript::sourceSearch $txt $search_pat $search_dir $search_case $search_regexp
}

proc notepad::dumpall {} {
	variable notepads

	set winname .np
	set mdi $winname.mdi

	set result ""

	foreach pad [array names notepads] {
		set top [$mdi childsite $pad]
		set st $top.st
		append result [$st get 1.0 end]
	}
	return $result
}
