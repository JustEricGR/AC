# ------------------------------------------------------------------
#                            Filelist
# ------------------------------------------------------------------
#
package provide Filelist 1.0
package require Itcl
package require Itk
package require Vsimwidgets 1.0

#
# Provide a lowercased access method for the Filelist class.
# 
proc filelist {pathName args} {
    uplevel Filelist $pathName $args
}


class Filelist {
	inherit ::vsimwidgets::Hierarchy
    constructor {prefixName args} {
		if {[catch {::vsimwidgets::Hierarchy::constructor \
						-kind tcl \
						-propertyprefix $prefixName \
						-propertycommand Filelist::FilelistPropertyCmd \
						-selectcommand UpdateToolbars \
					} msg]} {
			puts stderr "Filelist constructor error: $msg\n$::errorInfo"
		}
		set msg
	} {}
    destructor {} 

	protected method _button1 {w x y}
	protected method _buttonRelease1 {w x y}

	public	method initialize_menus { } 
	public	method UpdateFileViewContents { } 
	public	method UpdateFileView { args }
	public	method UpdateFromSelection { }

	public	method type_names {} 
	public	method GenerateFileList { node } 
	public	method PopupMenuAvailability { } 
	public  method EditSelectedFiles { } 
	public  method EditSelectedFile { } 
	public  method ExternalEditSelectedFiles { } 
	public  method OpenFile { filename } 
	public  method SaveList { } 
	public  method ClearCoverage { } 
	public  method ExcludeSelectedFile { } 
	public  method FilePropertiesDialog { } 
	public  method CoverageFileHasStmtData { path }
	public  method CoverageFileHasBranchData { path } 
	public  method CoverageFileHasConditionData { path } 
	public  method CoverageFileHasExpressionData { path } 
	public  method Action { operation args } 
	public  method Reset {}

	#
	# Interface to window mgr
	#
	public  proc CreateFilesWindow {windowobj}
	public  proc CreateFilesMenus {windowobj menu_bar}
	public  proc CloseWindow {windowobj reason} 
	public  proc ReOpenWindow { windowobj }	

	private method _addColumn {name title args}
	private method _fileInfo {path}

	private variable reselect_on_release

	private variable frame_w
	private variable frame_h
	private variable expanding
	public variable coverage_fields 
	private variable file_data
	private variable file_info
	private variable raw_wr
	private variable initializing

	common coverage_enabled 0
	public proc FilelistPropertyCmd {cmd args} {}
}


# ------------------------------------------------------------------
#                        CONSTRUCTOR
# ------------------------------------------------------------------
body Filelist::constructor {prefixName args} {
	global vsimPriv
    set initializing 1
    eval itk_initialize $args
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]
	set coverage_fields [expr {$vsimPriv(code_coverage) || $isViewcovMode}]
	set reselect_on_release -1
	set frame_w 0
	set frame_h 0
	set bttree $itk_component(tree)
	set coverage_enabled [expr {$vsimPriv(code_coverage) || $isViewcovMode}]

	set fn [cget -textfont]

	header configure 0 -text "Name" -command [code $this sort 0]

	_addColumn pathspec    "Specified path"
	_addColumn fullpath    "Full path"
	_addColumn type        "Type"
	_addColumn stmtcnt     "Stmt Count"           -justify right
	_addColumn stmthits    "Stmt Hits"            -justify right
	_addColumn stmtperc    "Stmt %"               -justify right
	_addColumn stmtgrph    "Stmt Graph"           -drawmode 2
	_addColumn brchcnt     "Branch Count"         -justify right
	_addColumn brchhits    "Branch Hits"          -justify right
	_addColumn brchperc    "Branch %"             -justify right
	_addColumn brchgrph    "Branch Graph"         -drawmode 2
	_addColumn condcnt     "Condition Count"      -justify right
	_addColumn condhits    "Condition Hits"       -justify right
	_addColumn condperc    "Condition %"          -justify right
	_addColumn condgrph    "Condition Graph"      -drawmode 2
	_addColumn exprcnt     "Expression Count"     -justify right
	_addColumn exprhits    "Expression Hits"      -justify right
	_addColumn exprperc    "Expression %"         -justify right
	_addColumn exprgrph    "Expression Graph"     -drawmode 2
	_addColumn fsmscnt     "States Count"         -justify right
	_addColumn fsmshits    "States Hits"          -justify right
	_addColumn fsmsperc    "States %"             -justify right
	_addColumn fsmsgrph    "States Graph"         -drawmode 2
	_addColumn fsmtcnt     "Transitions Count"    -justify right
	_addColumn fsmthits    "Transitions Hits"     -justify right
	_addColumn fsmtperc    "Transitions %"        -justify right
	_addColumn fsmtgrph    "Transitions Graph"    -drawmode 2
	_addColumn feccondcnt  "FEC Condition Count"  -justify right
	_addColumn feccondhits "FEC Condition Hits"   -justify right
	_addColumn feccondperc "FEC Condition %"      -justify right
	_addColumn feccondgrph "FEC Condition Graph"  -drawmode 2
	_addColumn fecexprcnt  "FEC Expression Count" -justify right
	_addColumn fecexprhits "FEC Expression Hits"  -justify right
	_addColumn fecexprperc "FEC Expression %"     -justify right
	_addColumn fecexprgrph "FEC Expression Graph" -drawmode 2

	initialize_menus
	set file_data(init) ""
	set file_info(init) ""
    set initializing 0
	UpdateFileViewContents
}

# ------------------------------------------------------------------
#                           DESTRUCTOR
# ------------------------------------------------------------------
body Filelist::destructor {} {
}



body Filelist::FilelistPropertyCmd {cmd args} {
	if {!$coverage_enabled} {
		set prop [lindex $args 0]
		switch $prop {
			FilePane_stmtcnt_vis -
			FilePane_stmthits_vis -
			FilePane_stmtperc_vis -
			FilePane_stmtgrph_vis -
			FilePane_brchcnt_vis -
			FilePane_brchhits_vis -
			FilePane_brchperc_vis -
			FilePane_brchgrph_vis -
			FilePane_condcnt_vis -
			FilePane_condhits_vis -
			FilePane_condperc_vis -
			FilePane_condgrph_vis -
			FilePane_exprcnt_vis -
			FilePane_exprhits_vis -
			FilePane_exprperc_vis -
			FilePane_exprgrph_vis -
			FilePane_fsmscnt_vis -
			FilePane_fsmshits_vis -
			FilePane_fsmsperc_vis -
			FilePane_fsmsgrph_vis -
			FilePane_fsmtcnt_vis -
			FilePane_fsmthits_vis -
			FilePane_fsmtperc_vis -
			FilePane_fsmtgrph_vis -
			FilePane_feccondcnt_vis -
			FilePane_feccondhits_vis -
			FilePane_feccondperc_vis -
			FilePane_feccondgrph_vis -
			FilePane_fecexprcnt_vis -
			FilePane_fecexprhits_vis -
			FilePane_fecexprperc_vis -
			FilePane_fecexprgrph_vis {
				if {$cmd == "get"} {
					upvar [lindex $args 1] data
					set data 0
				}
				return
			}
		}
	}
	uplevel 1 eval mtiPropertyCmd $cmd $args
}

#
# Convience routine to add and configure columns
#
body Filelist::_addColumn {name title args} {
	set fw [expr {[font measure $itk_option(-textfont) $title] + 18}]
	set cmd [list column add $name -width $fw]
	set cmd [concat $cmd $args]
	eval $cmd
	set ci [column index $name]
	header configure $name \
		-command [code $this sort $ci prev] \
		-text $title
}

# ------------------------------------------------------------------
#                         PUBLIC METHODS
# ------------------------------------------------------------------


body Filelist::initialize_menus { } {
	global vsimPriv PrefDefault

#################################
#  BINDINGS
#################################

	$this configure -command [code $this EditSelectedFile]

	## Bindings for the name widget.
	## No other widgets have special bindings in the structure window.


#################################
#  MENUS
#################################

	## Item Menu
	set popup [AddPopupMenu FileListPopup ""]
	AddMenuItem "View Source"				$popup	[code $this EditSelectedFiles]		   can_viewsource 
	AddMenuItem "Open in external editor"   $popup  [code $this ExternalEditSelectedFiles] can_externaledit
	AddSubMenu	"Code Coverage"				$popup	""									   can_coverage
	AddMenuItem "Code Coverage Reports..."	""		"Coverage::ReportDialog"			   can_copy 
	AddMenuItem "Exclude Selected File"		""		[code $this ExcludeSelectedFile]	   can_copy 
	AddSeparator
	AddMenuItem "Clear Code Coverage Data"	""		[code $this ClearCoverage]			   ""

	AddSeparator							$popup
	AddMenuItem "Properties..."		        $popup	"$vsimPriv(Vcop) Action properties"    can_properties
	$this configure -popupmenu $popup
}

body Filelist::EditSelectedFile { } { 
	set sel_items	[selection get]
	set first_item	[lindex $sel_items 0]
	if {[llength $first_item] != 2} {
		return
    }
	set filename [lindex $first_item 1]
	OpenFile $filename
}


body Filelist::EditSelectedFiles { } { 
	set sel_items	[selection get]
	foreach item $sel_items {
		if {[llength $item] != 2} {
			continue
		}
		set filename [lindex $item 1]
		OpenFile $filename
	}
}

body Filelist::ExternalEditSelectedFiles { } { 
	set sel_items	[selection get]
	foreach item $sel_items {
		if {[llength $item] != 2} {
			continue
		}
		set filename [lindex $item 1]
		::edit $filename
	}
}

body Filelist::OpenFile { filename } {
	global vsimPriv
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]
	if {$vsimPriv(code_coverage) || $isViewcovMode} {
		Coverage::ViewSourceFile $filename
	} else {
		do_edit $filename
	}
}


body Filelist::ExcludeSelectedFile { } { 
	global vsimPriv
	set sel_items [selection get]
	if { [llength $sel_items] <= 0} {
		return
	}
	if {![$vsimPriv(windowmgr) WindowVisible exclusions]} {
		$vsimPriv(windowmgr) ShowWindowType exclusions
#		vwait vsimPriv(ExclusionList)
	}
	set el [$vsimPriv(windowmgr) GetRegisteredChild exclusions]

	foreach item $sel_items { 
		if {[llength $item] != 2} {
			continue
		}
		set filename [lindex $item 1]
		$el ExcludeFile $filename
	}
	Coverage::Update
}

body Filelist::_button1 {w x y} {
	set retval [chain $w $x $y]
	return retval
}

body Filelist::_buttonRelease1 {w x y} {
	chain $w $x $y
   UpdateFromSelection
}

#public
body Filelist::UpdateFromSelection { } {
	global vsimPriv

	set file_list [list]
	foreach fe [selection get] {
		set ns [lindex $fe 0]
		lappend file_list [lindex $fe 1]
	}
	
	if {![info exists file_list] }	{
		return
	}
	if {[llength $file_list] != 1 || [lindex $file_list 0] eq ""} {
		return
	}

	if {[getCurrentNamespace] ne $ns} {
		::append ns $::DatasetSeparator
		env $ns
	}
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]
	if { $vsimPriv(code_coverage) || $isViewcovMode } {
		if {[::find class ::CovMiss] != ""} {
			foreach cmw [::find object -class ::CovMiss] {
				$cmw UpdateMissContents file
			}
			Coveragemiss::UpdateToggleMisses --file
		}
		Coveragemiss::UpdateCoverContents file
	}
}

# The trigger version of update, which must accept the trigger arguement 
body Filelist::UpdateFileView { args } { 
	global vsimPriv
	UpdateFileViewContents
}



body Filelist::UpdateFileViewContents { } {
	set offset		[$itk_component(tree) index @0,0]
	set sel_items	[selection get]
	set exlist [expandSerialize]
	if {[info exists file_data]} {
		unset file_data
	}
	configure -querycommand [code $this GenerateFileList %n] 
	expandUnserialize $exlist
	reapply_sort
	$itk_component(col0) selection clear 0 end
	foreach filename $sel_items {
		vsimwidgets::Hierarchy::selection add $filename
	}
	$itk_component(tree) see2 $offset
}

body Filelist::_fileInfo {path} {
	set tail [file tail $path]
	set type [::MtiFS::FileType $path]
	set icon [icon_image $path $type 1]
	if {$type eq "none"} {
		set suffix [string tolower  [file extension $path]]
		if { $suffix eq "" } {
			set type "file"
		} else {
			set type "$suffix file"
		}
	}
	return [list $tail $type $icon]
}

body Filelist::GenerateFileList { node } {
	global vsimPriv
	if { $initializing } {
		return ""
	}
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]
	set coverage_fields [expr {$vsimPriv(code_coverage) || $isViewcovMode}]
	set src_list [list]
	if {$node eq ""} {
		if {[info exists raw_wr]} {
			unset raw_wr
		}
		array unset file_info
		foreach nsinfo [dataset list -long] {
			set nsl [split $nsinfo =]
			set ns [lindex $nsl 0]
			if {$ns eq $dataset::deleting} {
				continue
			}
			set kids branch
			set nsfile [lindex $nsl 1]
			set one_entry [list]
			lappend one_entry $ns $ns [list $kids] [GetButtonIcon simulate ""]
			#path spec column
			lappend one_entry $nsfile "" ""
			#full path column
			lappend one_entry [MtiFS::NormalizeFileName $nsfile] "" ""
			#type column
			lappend one_entry "" "" ""
			##stmt
			lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			##branch
			lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			##condition
			lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			##expression
			lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			lappend src_list 	 $one_entry	
		}
		return $src_list
	}
	if {[dataset exists $node]} {
		if {[NamespaceIsSim $node]} {
			if {![info exists raw_wr] && [DesignIsLoaded]} {
				set raw_wr [::write report -tcl]
			}
			foreach r $raw_wr {
				foreach filename [lindex $r 5] {
					if {$filename eq "" || $filename eq "nofile"} { continue }
					if {[info exists file_info($filename)]} { continue }
					set file_info($filename) [_fileInfo $filename]
				}
			}
		} else {
			array unset file_info
         # We must use a "catch" because it's possible this dataset won't have
         # any files associated with it. An example (only one?) would be when
         # wave comparisons are done - a file-less dataset is created.
         #
         if { [catch {dataset filelist $node} filenames] } {
            set filenames [list]
         }
			foreach filename $filenames {
				set file [ExpandEnvVariables $filename]
				if {$file eq "" || $file eq "nofile"} { continue }
				if {[info exists file_info($file)]} { continue }
				set file_info($file) [_fileInfo $file]
			}
		}


		foreach entry [array names file_info] { 
			set file_data($entry) [list "" "" ""]
		}

		if { $coverage_fields } {
			if {![catch {Coverage::data -ds $node} data_list]} {
				foreach entry $data_list { 
					set filename [lindex $entry 0]
					set file_data($filename) [lrange $entry 1 end]
					# Update info only if not seen before
					if {[info exists file_info($filename)]} { continue }
					if {$filename eq "nofile"} { continue }
					set file_info($filename) [_fileInfo $filename]
				}
			}
		}

		set lst [array names file_info]
		foreach filename $lst {
			set one_entry ""
			lappend one_entry [list $node $filename]
			set fie $file_info($filename)
			lappend one_entry [lindex $fie 0] ;# tail
			lappend one_entry ""
			lappend one_entry [lindex $fie 2] ;# icon
			
			#path spec column
			lappend one_entry $filename "" ""
			
			#full path column
			lappend one_entry [MtiFS::NormalizeFileName $filename] "" ""

			#type column
			lappend one_entry [lindex $fie 1] ;# type

			lappend one_entry "" "" 
			set entry $file_data($filename)

			##stmt
			if { [lindex $entry 0] == 0 } {
				# zero stmts should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 0]  "" "" 
				##stmt hits
				lappend one_entry [lindex $entry 1]  "" "" 
				##stmt percent hits
				lappend one_entry [lindex $entry 2]  "" "" 
				##stmt percent graph
				lappend one_entry [lindex $entry 2]  "" "" 
			}
			##branch
			if { [lindex $entry 3] == 0 } {
				# zero branch should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 3]  "" "" 
				##branch hits
				lappend one_entry [lindex $entry 4]  "" "" 
				##branch percent hits
				lappend one_entry [lindex $entry 5]  "" "" 
				##branch percent graph
				lappend one_entry [lindex $entry 5]  "" "" 
			}
			##condition
			if { [lindex $entry 6] == 0 } {
				# zero condition should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 6]  "" "" 
				##condition hits
				lappend one_entry [lindex $entry 7]  "" "" 
				##condition percent hits
				lappend one_entry [lindex $entry 8]  "" "" 
				##condition percent graph
				lappend one_entry [lindex $entry 8]  "" "" 
			}
			##expression
			if { [lindex $entry 9] == 0 } {
				# zero condition should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 9]  "" "" 
				##condition hits
				lappend one_entry [lindex $entry 10]  "" "" 
				##condition percent hits
				lappend one_entry [lindex $entry 11]  "" "" 
				##condition percent graph
				lappend one_entry [lindex $entry 11]  "" "" 
			}
			##states
			if { [lindex $entry 12] == 0 } {
				# zero states should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 12]  "" "" 
				##state hits
				lappend one_entry [lindex $entry 13]  "" "" 
				##state percent hits
				lappend one_entry [lindex $entry 14]  "" "" 
				##state percent graph
				lappend one_entry [lindex $entry 14]  "" "" 
			}
			##transitions
			if { [lindex $entry 15] == 0 } {
				# zero transitions should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 15]  "" "" 
				##transitions hits
				lappend one_entry [lindex $entry 16]  "" "" 
				##transitions percent hits
				lappend one_entry [lindex $entry 17]  "" "" 
				##transitions percent graph
				lappend one_entry [lindex $entry 17]  "" "" 
			}
			## fec condition
			if { [lindex $entry 18] == 0 } {
				# zero condition should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 18]  "" "" 
				##condition hits
				lappend one_entry [lindex $entry 19]  "" "" 
				##condition percent hits
				lappend one_entry [lindex $entry 20]  "" "" 
				##condition percent graph
				lappend one_entry [lindex $entry 20]  "" "" 
			}
			## fec expression
			if { [lindex $entry 21] == 0 } {
				# zero condition should be blank
				lappend one_entry  "" "" "" "" "" "" "" "" "" "" "" ""
			} else {
				lappend one_entry [lindex $entry 21]  "" "" 
				##condition hits
				lappend one_entry [lindex $entry 22]  "" "" 
				##condition percent hits
				lappend one_entry [lindex $entry 23]  "" "" 
				##condition percent graph
				lappend one_entry [lindex $entry 23]  "" "" 
			}
			lappend src_list 	 $one_entry	
		}
	}
	return $src_list
}

body Filelist::CoverageFileHasStmtData { path } { 
	if { ![info exists file_data($path)] || ([llength $file_data($path)] < 6) || \
		 ([lindex $file_data($path) 0] == 0)} {
		return 0
	}
	set stmt_perc [lindex $file_data($path) 2] 
	if { $stmt_perc >= 100 } {
		return -1
	} 
	return 1
}

body Filelist::CoverageFileHasBranchData { path } { 
	if { ![info exists file_data($path)] || ([llength $file_data($path)] < 6) || \
		 ([lindex $file_data($path) 3] == 0)} {
		return 0
	}
	set branch_perc [lindex $file_data($path) 5] 
	if { $branch_perc >= 100 } {
		return -1
	} 
	return 1

}

body Filelist::CoverageFileHasConditionData { path } { 
# TODO: this function needs to be implemented
return 1
	if { ![info exists file_data($path)] || ([llength $file_data($path)] < 9) || \
		 ([lindex $file_data($path) 6] == 0)} {
		return 0
	}
	set branch_perc [lindex $file_data($path) 8] 
	if { $branch_perc >= 100 } {
		return -1
	} 
	return 1

}

body Filelist::CoverageFileHasExpressionData { path } { 
# TODO: this function needs to be implemented
return 1
	if { ![info exists file_data($path)] || ([llength $file_data($path)] < 9) || \
		 ([lindex $file_data($path) 6] == 0)} {
		return 0
	}
	set branch_perc [lindex $file_data($path) 8] 
	if { $branch_perc >= 100 } {
		return -1
	} 
	return 1

}

body Filelist::FilePropertiesDialog { } {
	global CompileDlg PrefDefault tcl_platform Project Projectdlg
	global vsimPriv
	set sel_items	[selection get]	
	set first_item	[lindex $sel_items 0]
	if {[llength $first_item] != 2} {
		foreach nsinfo [dataset list -long] {
			set nsl [split $nsinfo =]
			set ns [lindex $nsl 0]
			if {$ns eq $dataset::deleting} {
				continue
			}
			set pathname [lindex $nsl 1]
		}	
    } else { 
		set pathname [lindex $first_item 1]
	}

	if { $pathname == "" } {
		return
	}


	set f .file_cust
	if {[winfo exists $f]} {
		wm deiconify $f
		raise $f
		return
	}
	set f [toplevel $f]
	wm title $f "File Properties"

	iwidgets::labeledframe $f.fprop -labeltext "File Properties" -labelpos nw 
	set t [$f.fprop childsite]

	set file_type [::MtiFS::FileType $pathname]

	array set property_attr {-permissions 0000 -owner - -group - -shortname "" -readonly 0 -hidden 0 -archive 0 -system 0}
	set fixed_name [MtiFS::NormalizeFileName $pathname]
	set native_name "File not found"

	if {[file exists $fixed_name]} {
		set native_name [file nativename $fixed_name]
		array set property_attr [file attributes $fixed_name]
		set amtime [file mtime $fixed_name]
		set size [file size $fixed_name]
		if {($size / 1073741824) > 0} {
			set size_str [format "(%dGB)" [expr {$size / 1073741824}]]
		} elseif {($size / 1048576) > 0} {
			set size_str [format "(%dMB)" [expr {$size / 1048576}]]
		} elseif {($size / 1024) > 0} {
			set size_str [format "(%dKB)" [expr {$size / 1024}]]
		} else {
			set size_str [format "(%d bytes)" $size]
		}
		set fname [file tail $fixed_name]
		set loc  $pathname
	} else {
		set amtime 0
		set size ""
		set size_str ""
		set mod ""
		set fname "File not found"
		set loc ""
	}
	if {$tcl_platform(platform) != "windows"} {
		set mod [get_attr $property_attr(-permissions)]
	}
		
	button $t.change_type 
	set nf [$t.change_type cget -font]

	set Projectdlg($t:file_type) $file_type
	label $t.filel -text "File:"  -font $nf
	label $t.file -text $fname  -font $nf
	grid $t.filel $t.file - -sticky w -padx 5
	label $t.locl -text "Location:" -font $nf
	label $t.loc -text $loc  -font $nf
	grid $t.locl $t.loc - -sticky w -padx 5
	if {$tcl_platform(platform) == "windows"} {
		label $t.lMS -text "MS-DOS name:" -font $nf
		label $t.llMS -text $native_name -font $nf
		grid $t.lMS $t.llMS - -sticky w -padx 5
	} 
	frame $t.f1 -height 2 -relief sunken -bd 1
	grid $t.f1 -     - -sticky ew -padx 5 -pady 10
	label $t.typel -text "Type:" -font $nf
	label $t.type -textvariable Projectdlg($t:file_type)  -font $nf

	label $t.sizel -text "Size:" -font $nf
	label $t.size -text "$size $size_str" -font $nf
	grid $t.sizel $t.size - -sticky w -padx 5
	label $t.modl -text "Modification Time:" -font $nf
	if {$amtime > 0} {
		set mtime [clock format $amtime]
	} else {
		set mtime unknown
	}
	label $t.mod -text $mtime -font $nf
	grid $t.modl $t.mod - -sticky w -padx 5

	if {$tcl_platform(platform) == "windows"} {
		label $t.fa_label -text "File Attributes:" -font $nf
		set str ""
		if { $property_attr(-readonly) } {
			set str "Read Only"
		}
		if { $property_attr(-hidden) } {
			if { [string length $str] } {
				::append str ", "
			}
			::append str "Hidden"
		}
		if { $property_attr(-archive) } {
			if { [string length $str] } {
				::append str ", "
			}
			::append str "Archive"
		}
		if { [string length $str] == 0 } {
			set str "No special attributes set"
		}
		label $t.fa -text $str -font $nf
		grid $t.fa_label $t.fa -sticky w -padx 5
	} else {
		label $t.lF -text "Permissions:" -font $nf
		label $t.lG -text $mod  -font $nf
		label $t.lH -text "Owner:" -font $nf
		label $t.lI -text $property_attr(-owner)  -font $nf
		label $t.lJ -text "Group:" -font $nf
		label $t.lK -text $property_attr(-group)     -font $nf
		grid $t.lF $t.lG - -sticky w -padx 5
		grid $t.lH $t.lI - -sticky w -padx 5
		grid $t.lJ $t.lK - -sticky w -padx 5
	}	
	
	grid  $f.fprop  -row 1 -column 1 -sticky ew -pady 5

	set bok  [MtiFormUtil::makeButtonBox $f.bb 0 [list \
			[list "Close"     "destroy $f"] \
			]]

	grid $bok  -row 2 -column 1 -padx 2 -pady 2 -sticky e
}


body Filelist::SaveList { } {
	global transcript

	# Produces sorted, duplicate-vetted list of files used in a design. This
	# procedure is not intended to produce an exact copy of what's contained
	# in the tree widget (that's "Save List..." under the "File" menu).

	set filename [tk_getSaveFile -title "Save Files" -filetypes [AllFileTypes] \
					-parent $transcript -initialfile summary.txt ]

	if { $filename != "" } {
		set flist [list]

		# First, build a list of unique files...

		foreach r [::write report -tcl] {
			foreach f [lindex $r 5] {
				if {[lsearch -exact $flist $f] < 0} {
					lappend flist $f
				}
			}
		}

		# ...and *then* send the sorted list to the output file

		if {![catch {open $filename w} handle]} {
			foreach f [lsort $flist] {
				catch {puts $handle $f} err
			}
			close $handle
		}
	}

}


body Filelist::ClearCoverage { } {
	global vsimPriv
	coverage clear
	UpdateFileView
	foreach w [$vsimPriv(windowmgr) GetWindowsByType structure] {
		$w update
	}
}

body Filelist::Action { windowobj operation args } {
	global transcript vsimPriv
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]
	switch $operation {
		SetMenuState {
			SetActiveWindowMenu "Files" I
			set menus [lindex $args 0]
			set selected [llength [selection get]]
			foreach submenu $menus {
				set cmd [lindex $submenu 1]
				set action [lindex $submenu 0]
				switch $action {

				    can_findaction {
						lappend cmd normal
					}

					
					can_save {
						set cmd [Vsimmenu::SetMenuText $action "Save List..." $cmd]
						lappend cmd normal
					}

					can_expndsel	- 
					can_cllpssel	- 
					can_copy	{ 
									if {$selected > 0} {
										lappend cmd normal
									} else {
										lappend cmd disabled
									}
								}

					can_properties { 
									if {$selected == 1} {
										lappend cmd normal
									} else {
										lappend cmd disabled
									}								
								}
					can_viewsource {
									set results disabled
									set sel_items	[selection get]
									foreach item $sel_items {
										if {[llength $item] != 2} {
											continue
										}
										set results normal
										break
									}
									lappend cmd $results
								}

					can_externaledit {
									set results disabled
									if {$::PrefMain(Editor) ne "" && 
										$::PrefMain(Editor) ne "default"} {
										set sel_items	[selection get]
										foreach item $sel_items {
											if {[llength $item] != 2} {
												continue
											}
											set results normal
											break
										}
									}
									lappend cmd $results
								}	

					can_coverage { 
									if { $vsimPriv(code_coverage) || $isViewcovMode } {
										lappend cmd normal
									} else {
										lappend cmd disabled
									}
								}

					can_properties { 
									if {$selected == 1} {
										lappend cmd normal
									} else {
										lappend cmd disabled
									}								
								}

					can_close_window -								
					can_open -
					can_expndall -
					can_cllpsall {
									lappend cmd normal
								}

					can_add		{ 
									if { [AllowAdd ] || [IsStructSelectedSystemC] } {
										lappend cmd normal
									} else {
										lappend cmd disabled
									}
								}

					default		{
									lappend cmd disabled
								}

				}
				eval $cmd
			}
		}

		active_window_menu {     
			ClearActiveWindowMenu
			AddMenuItem "View Source"				$vsimPriv(AWMenu) [code $this EditSelectedFiles]         can_viewsource   V
			AddMenuItem "Open in external editor"   $vsimPriv(AWMenu) [code $this ExternalEditSelectedFiles] can_externaledit X
			AddMenuItem "Save Files..."				$vsimPriv(AWMenu) [code $this SaveList]                  ""               S
			return 1
		}

		save { 
			SaveTree [winfo parent $itk_component(tree)]
		}

		copy		{
						clipboard clear
						set sel_items	[selection get]
						set str ""
						foreach item $sel_items {
                            set filename [lindex $item 1]
							::append str $filename " "
						}
						clipboard append [string trim $str]
						return 1
					}

       findaction {
         if { [SearchBar::enabled] } {
            SearchBar::show [$windowobj GetRegisteredChild]
			}
         return 1
		}

		open {
			return [$::vsimPriv(Vcop) Action Create OpenFile]
		}

		properties {
						FilePropertiesDialog
						return 1
				   }
		
		expndsel	{
			expandselected
		}
		expndall	{
			expandall -1
		}
		cllpssel	{
			collapseselected
		}
		cllpsall	{
			collapseall -1
		}

		close_window {
						$vsimPriv(windowmgr) HideWindow $windowobj user
						return 1
					}

		expndsel		{
			expandselected
			return 1
		}

		expndall		{
			expandall -1
			return 1
		}

		cllpssel		{
			collapseselected
			return 1
		}

		cllpsall		{
			collapseall -1
			return 1
		}

		}
		return 0
}

itcl::body Filelist::CreateFilesWindow {windowobj} {
	global vsimPriv PrefStructure PrefMain PrefCoverage
	set body [$windowobj GetBody]
	set filespane $body.filepane
	::filelist $filespane FilePane_ \
			-hscrollmode dynamic -vscrollmode dynamic \
			-textbackground $PrefStructure(background) \
			-textbackground2 $PrefStructure(background2) \
			-textforeground $PrefStructure(foreground) \
			-selectbackground $PrefStructure(selectBackground) \
			-selectforeground $PrefStructure(selectForeground) \
			-belowcutoff $PrefCoverage(barHighlightColor) \
			-abovecutoff $PrefCoverage(barColor) \
			-highlightthickness 0 \
			-expanded false \
			-selectmode multiple \
			-borderwidth 1 \
			-relief sunken \
			-header 1 \
			-exportselection 1 

	pack $filespane -fill both -expand true
	
	$windowobj configure -actioncommand [code $filespane Action]

	$vsimPriv(windowmgr)	RegisterWindow $windowobj $filespane
	$vsimPriv(windowmgr)	RegisterView $windowobj $body
	set isViewcovMode [NamespaceIsViewcov [getCurrentNamespace]]

	$filespane updateColumnVisibility
	Coverage::Update
	ReOpenWindow $windowobj

	  # Get our Search Bar set up
      #
      proc ::Filelist::doSearchBarSearch {target_w paramsArray} {
         global vsimPriv
         upvar $paramsArray params

         set wname $target_w
         set vsimPriv($wname:exact)      $params(-exact)
         set vsimPriv($wname:find_class) VTree
         set vsimPriv($wname:search_pat) $params(-pattern)
         set vsimPriv($wname:search_fld) 1 ;# file name
         set vsimPriv($wname:search_dir)    [expr {$params(-back) ? "-backward" : "-forward"}]
         set vsimPriv($wname:wrap)          [expr {$params(-wrap) ? "-wrap"     : "-nowrap"}]

         return [FindDoIt $wname "Filelist" 1 $params(-find_all) 0 1]
      }
      SearchBar::register \
          -prefix [$filespane cget -propertyprefix] \
          -mode $SearchBar::modes(BOTH) \
          -defaultmode $SearchBar::modes(FILTER) \
          -parent $body \
          -src $filespane \
          -show [list pack %W -side bottom -before $filespane -fill x] \
          -close {pack forget %W} \
          -search "Filelist::doSearchBarSearch"
      #--- End of Seach Bar set up


}


itcl::body Filelist::CreateFilesMenus {windowobj menu_bar} {
	global vsimPriv tcl_platform

	set file_menu [AddMenu			"File"			$menu_bar  ""   F]
	AddMenuItem  "Close Window"			$file_menu		{$vsimPriv(Vcop) Action close_window}		can_close_window	W

	# Edit menu
	set edit_menu [AddMenu		"Edit"					$menu_bar "" E]
	AddMenuItem "Cut"					""			{$vsimPriv(Vcop) Action cut}					can_cut				T
	AddMenuItem "Copy"					""			{$vsimPriv(Vcop) Action copy}					can_copy			C
	AddMenuItem "Paste"					""			{$vsimPriv(Vcop) Action paste}					can_paste			P
	AddSeparator						
	AddMenuItem "Select All"			"" 			{$vsimPriv(Vcop) Action selectall}				can_selectall		A
	AddMenuItem "Unselect All"			"" 			{$vsimPriv(Vcop) Action unselectall}			can_unselectall		N
	AddSeparator						"" 
	AddSubMenu  "Expand"				$edit_menu 		""  ""                                                       	E
	AddMenuItem "Expand Selected"		""			{$vsimPriv(Vcop) Action expndsel}				can_expndsel		E.E
	AddMenuItem "Collapse Selected"		""			{$vsimPriv(Vcop) Action cllpssel}				can_cllpssel		E.C
	AddMenuItem "Expand All"			"" 			{$vsimPriv(Vcop) Action expndall}				can_expndall		E.x
	AddMenuItem "Collapse All"			""			{$vsimPriv(Vcop) Action cllpsall}				can_cllpsall		E.o
	AddSeparator						$edit_menu
	AddMenuItem  "Find In Files..."		$edit_menu	MtiFileUtil::FindInFiles						""                  I
	AddWindowMenu						$menu_bar
}

itcl::body Filelist::Reset {} {
	if {[info exists raw_wr]} {
		unset raw_wr
	}
	array unset file_info
	reset
}

itcl::body Filelist::CloseWindow {windowobj reason} {
	set filespane [$windowobj cget -window]
	$filespane Reset
	RemoveCmdFromQueue QuitSimQ      "$filespane UpdateFileView"
	RemoveCmdFromQueue StrucChangedQ "$filespane UpdateFileView"
	RemoveCmdFromQueue LoadCompleteQ "$filespane UpdateFileView"
	RemoveCmdFromQueue RestartQ      "$filespane UpdateFileView"
	return 1
}

itcl::body Filelist::ReOpenWindow { windowobj } {
	set filespane [$windowobj cget -window]
	$filespane UpdateFileViewContents
	AddCmdToQueue QuitSimQ		 "$filespane UpdateFileView"
	AddCmdToQueue StrucChangedQ	 "$filespane UpdateFileView"
	AddCmdToQueue LoadCompleteQ  "$filespane UpdateFileView"
	AddCmdToQueue RestartQ		 "$filespane UpdateFileView"
	return
}
