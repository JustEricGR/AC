# ------------------------------------------------------------------
#                            WindowMgr
# ------------------------------------------------------------------
#
# WindowMgr manages frame creation and window creation protocol
#
# Author: Ron Wold
# ----------------------------------------------------------------------
#            Copyright 2007 Mentor Graphics Corporation
#
# ======================================================================

# mtiimages is required since most windows display an icon in their tabset.




package require mtiimages
#
# Provide a lowercased access method for the windowmgr class.
# 
proc mtiwidgets::windowmgr {pathName args} {
    uplevel ::mtiwidgets::WindowMgr $pathName $args
}

itcl::class mtiwidgets::WindowMgr {

    constructor {args} {}
    destructor {} 

	public method CreateWindow			{ window_type args }
	public method WindowExists			{ window_type {window_data ""}} 
	public method FindWindowObj			{child_widget}
	public method GetWindow				{ window_type {window_data ""}}

	public method GetDefaultWindow		{ window_type } 
	public method SetDefaultWindow		{ windowobj }

	public method GetWindowsByType		{ window_type }
	public method GetWindowObjsByType	{ window_type {inuse_only 1}}
	public method GetUniqueLabel		{ windowobj base_name }
	public method GetWindowTypes		{}
	public method ValidType				{ window_type }

	public method GetWindowByIndex		{ window_type sequential_index }


	public method ShowWindow			{ windowobj {force 0}}
	public method ShowWindowType		{ window_type } 
	public method HideWindow			{ windowobj {reason user}} 
#   Valid reasons are:
#			loadsim - a simulation has been loaded causing a layout change.
#			quitsim - a simulation has been unloaded causing a layout change
#			layout  - the user has issued an explicit layout change
#			user	- the user has explicity closed the window
#			exit    - the tool is shutting down
#			error   - the create called returned an error 
#			clear   - the users has requested all layouts be deleted/cleared

	public method WindowVisible			{ window_type {window_data ""}}
	public method WindowObjVisible		{ windowobj }
	public method AnyWindowVisible		{ window_type }
	public method WindowUndocked		{ windowobj }		

	public method GetAllVisibleWindows  {}
	public method GetAllUndockedWindows {}
	public method DockAllUndockedWindows {}
	public method GetAllIconifiedWindows {}
	public method GetOrderedWindowList	{{all 0}}
	public method RegisterWindow		{ windowobj child } 
	public method RegisterView          { windowobj viewwidget } 
	public method RegisterData          { windowobj window_data }
	public method GetRegisteredWindows	{ } 
	public method GetRegisteredChild	{ window_type {window_data ""}} 
	public method GetRegisteredView     { window_type {window_data ""}} 
	public method WindowName			{ window_type {window_data ""}} 
	public method ActivatePreviousPane	{ } 
	public method ActivateNextPane	{ }

	# These are used by client code to add menu data into the
	# application's "View" menu. The additions will be located
	# at the end of the app's set of windows listed in the menu.
	#
	public method ClientAddViewMenuItem {str cmd {test ""} {m ""}}
	public method ClientAddViewSubMenu  {str {test ""}}

	#	Calls below are not for public consumption
	public method RenameWindow			{ windowobj new_window_data new_label } 
	public method UnSerializedNewFrame	{ windowobj } 	
	public method ToggleDock			{ windowobj { geometry "" } {suppress_error 0 }}
	public method Dock					{ windowobj { geometry "" } {suppress_error 0 }}
	public method UnDock				{ windowobj { geometry "" } {suppress_error 0 }}
	public method ToggleMax				{ windowobj }
	public method MaximizeWindow		{ windowobj } 
	public method MinimizeWindow		{ windowobj } 
	public method NormalizeWindows		{} 
	public method UpdateMaxButton		{} 
	public method ShowWindowNoDisplay	{ windowobj }
	public method GetDefaultWindowObj	{ windowobj }

	public method TogglePaneHeaders		{}
	public method PaneHeadersVisible	{}
	public method TriggerRegisterWindow { registerwindowcache } 
	public method CreateNewWindow		{ window_type }
	public method LayoutChangePending	{ reason layout }
	public method LayoutChangeComplete	{ reason }
	public method LayoutChanging		{} { return $LayoutInTransition }
	public method LayoutClosing			{} { return $LayoutTransitionClosing }

	public method LayoutRestore			{ windowobj } 
	public method CloseAllWindows		{ } 
	public method CloseWindowsByType { window_type {reason user} } 

	public method DumpWindows			{ where type } 

	public method FindFirstOfType		{ windowobj}
	public method WindowInLayout		{ windowobj}
	public method WindowTypeInLayout	{ window_type } 
	public method GetWindowsInLayout	{ }
	public method GetWindowsNotInLayout	{ }
	public method MaximizedMode			{ } { return $maximized_mode }  
	private method FindOldestWindow		{ windowlist }  
	private method TestForLast			{ windowobj {suppress_error 0}}
	private method NewFrameIndex		{ window_type }
	private method NewFrameIndexExists	{ idx}
	private method FindReusableWindow	{ window_type window_data args} 
	private method FindUnusedWindow		{ window_type } 
	
	# Public properties.  These properties are configurable via 
	# builtin "configure" method
	public variable actionmanager "mtiwidgets::mgr_undefinedAction"
	public variable panemanager   "mtiwidgets::mgr_undefinedPane"

	private variable window_list         ;# Lookup table Name -> Obj
	private variable default_window
	private variable windowObjCache      ;# Lookup table Obj -> Name
	private variable windowTypesCache    ;# Lookup table known Type names
	private variable windowDataCache     ;# Lookup table window Data -> Obj
	private variable windowReverseCache  ;# Lookup table window Obj -> Data
	private variable root_window
	private variable all_by_type
	private variable pane_headers_visible 1
	private variable autohide_window_types [list]
	private variable manager_busy 0
	private variable restore_list [list]

	private variable in_layout_list [list]
	private variable LayoutInTransition 0
	private variable LayoutTransitionClosing 0
	private variable maximized_mode 0
	private variable new_visibility_windows [list]
	private variable layout_change 1
}


# ------------------------------------------------------------------
#                        CONSTRUCTOR
# ------------------------------------------------------------------ 
body mtiwidgets::WindowMgr::constructor {args} {
	set root_window .main_pane
}

body mtiwidgets::WindowMgr::destructor {} {
}

body mtiwidgets::WindowMgr::TriggerRegisterWindow { registerwindowcache } {

	if {[llength $registerwindowcache] == 0} { 
		return
	}

	foreach entry $registerwindowcache {
		set window_type [lindex $entry 0]
		set args [lindex $entry 1]
		eval [ linsert $args 0 $this CreateWindow $window_type]
	}

	#special case - $transcript is used throughout the initialization process
	#this transcript must be created, even if it is not being displayed.
	if { [GetRegisteredChild transcript] eq "" } {
		Transcript::CreateTranscriptWindow [GetDefaultWindow transcript]
	}
	mtiimages::load_images
}

body mtiwidgets::WindowMgr::NewFrameIndexExists { idx } {
	foreach a_window $all_by_type {
		set a_window_index [$a_window cget -type_index]
		if { $idx == 0 && $a_window_index eq "" } {
			return 1
		}
		if {$a_window_index == $idx } {
			return 1
		}
	}	
	return 0
}

body mtiwidgets::WindowMgr::NewFrameIndex { window_type } {
	set all_by_type [GetWindowObjsByType $window_type 0]
	set idx 0
	while (1) {
		if { ![NewFrameIndexExists $idx] } {
			return $idx
		}
		incr idx
	}
}



# Layout Restore - if the value is -1 then the window registration 
# did not specify the restore behavior.  By default a single instance 
# window is restored and a multi instance is not.  
body mtiwidgets::WindowMgr::LayoutRestore { windowobj } {
	# if we are minimizing a window, then everything in the previous window 
	# should be visible
	if { $layout_change == 0 } {
		return 1
	}
	if { [$windowobj cget -layoutrestore] == -1 } {
		if { [$windowobj cget -multipleinstances] } {
			return 0
		}
		return 1
	}
	return [$windowobj cget -layoutrestore]
}

body mtiwidgets::WindowMgr::WindowName { window_type {window_data ""}} {
	set windowobj [GetWindow $window_type $window_data]
	if { $windowobj ne ""} {
		return [$windowobj cget -windowname]
	} 
	return ""
}

body mtiwidgets::WindowMgr::GetUniqueLabel { windowobj base_name } {
	set labels [list]
	foreach a_windowobj [array names windowObjCache] {
		if { $windowobj eq $a_windowobj } { 
			continue
		}
		if { ![ WindowInLayout $a_windowobj] } {	
			continue
		}
		set my_name [ $a_windowobj cget -tab_label ]
		if { $my_name ne "" && [$a_windowobj cget -tab_labelinit]} {
			lappend labels $my_name
		}
	}
	if {[lsearch -exact $labels $base_name] < 0} {
		return $base_name
	} 
	set suffix 1
	while { 1 } {
		set name "$base_name$suffix"
		if {[lsearch -exact $labels $name] < 0} {
			return $name 
		}
		incr suffix
	}
}

body mtiwidgets::WindowMgr::WindowExists { window_type {window_data ""}} {
	set window_name [WindowName $window_type $window_data]
	if { [info exists window_list($window_name)] } {
		return 1
	}
	return 0
}


body mtiwidgets::WindowMgr::GetWindow { window_type {window_data ""}} {
	if { $window_data eq ""} {
		if {[info exists window_list($window_type)]} {
			return $window_list($window_type)
		}
	} elseif {[info exists windowDataCache($window_data)]} {
		return $windowDataCache($window_data)
	}
	foreach windowobj [array names windowObjCache]  {
		if { ([$windowobj cget -windowtype]  eq $window_type) &&
			  [$windowobj cget -window_data] eq $window_data } {
			return $windowobj
		}
	}
	return ""
}

body mtiwidgets::WindowMgr::FindWindowObj { child_widget } {
	set wl [split $child_widget .]
	set w [join [lrange $wl 0 2] .]
	if {[info exists windowObjCache($w)]} {
		return $window_list($windowObjCache($w))
	}
	
	set w $child_widget
	while {$w ne "." && [winfo exists $w]} {
		if {[info exists windowObjCache($w)]} {
			return $window_list($windowObjCache($w))
		}
		set w [winfo parent $w]
	}
	return ""
}

body mtiwidgets::WindowMgr::GetWindowsByType { window_type } {
	set windows [list]
	foreach windowobj [array names windowObjCache]  {
		if { ([$windowobj cget -windowtype] eq $window_type) &&
		      [$panemanager visible $windowobj]} {
			if { [$windowobj cget -window] ne "" } {
				lappend windows [$windowobj cget -window]
			}
		}
	}
	return $windows
}

body mtiwidgets::WindowMgr::GetWindowObjsByType { window_type {inuse_only 1}} {
	set windows [list]
	foreach windowobj [array names windowObjCache]  {
		if { ([$windowobj cget -windowtype] eq $window_type) } {
			if {$inuse_only } {
				if { ![$panemanager visible $windowobj] || [$windowobj GetRegisteredChild] eq ""} {
					continue
				}
				if { [$windowobj cget -multipleinstances] == 1 && [$windowobj cget -window_data] eq "" } {
					continue
				} 
			}
			lappend windows $windowobj
		}
	}
	return $windows
}

# GetWindowByIndex is intended to support the view command and should not be used for 
# other puproses.
# This call, will return a windowobj given an integer index.  The index is independent of 
# the tab label or the actual windowobj name.  If the index requested is greater than the number of 
# existing windows, then windows will be created upto the provided index.
# The intent of this call is to allow a consistent retrieval function for view, one that 
# is unaffected by the creation order, windowobj name, or label text.
#
body mtiwidgets::WindowMgr::GetWindowByIndex { window_type sequential_index } {
	set windowobj [GetDefaultWindow $window_type]
	set multi [$windowobj cget -multipleinstances]
	if { $sequential_index > 0 } {
		if { !$multi } {
			error "Window type $window_type does not support multiple instances."
			return
		}
	}
	if { $sequential_index == 0 && !$multi } {
		return $windowobj
	}
	set wobjs [GetWindowObjsByType $window_type 0]
	if { $sequential_index >= [llength $wobjs] } {
		while { $sequential_index >= [llength $wobjs] } { 
			set windowobj [CreateNewWindow $window_type]
			ShowWindow $windowobj
			set wobjs [GetWindowObjsByType $window_type 0]
		}
		ShowWindow $windowobj
		return $windowobj
	}

	set ordered_list [list]
	set basename .main_pane.$window_type
	set idx [lsearch -exact $wobjs $basename]
	if { $idx >= 0 } {
		lappend ordered_list $basename
		lremove wobjs $idx
	}
	set index 1
	while { [llength $wobjs] } {
		set name $basename$index
		set idx [lsearch -exact $wobjs $name]
		if { $idx >= 0 } {
			lappend ordered_list $name
			lremove wobjs $idx
		}
		incr index
	}
	set windowobj [lindex $ordered_list $sequential_index]
	ShowWindow $windowobj
	return $windowobj
}


itcl::body mtiwidgets::WindowMgr::GetDefaultWindow { window_type } {
	if {[info exists default_window($window_type)]} {
		return $default_window($window_type)
	} elseif {[info exists window_list($window_type)]} {
		# try for a visible one first
		foreach w $window_list($window_type) {
			if {[$w cget -windowtype] eq $window_type && [WindowObjVisible $w]} {
				SetDefaultWindow $w
				return $w
			}
		}
		# try for anything
		foreach w $window_list($window_type) {
			if {[$w cget -windowtype] eq $window_type} {
				SetDefaultWindow $w
				return $w
			}
		}
	}
	return ""
}


itcl::body mtiwidgets::WindowMgr::SetDefaultWindow { windowobj } {
	if {$windowobj ne ""} {
		set type [$windowobj cget -windowtype]
		if {[info exists default_window($type)]} {
			set prior $default_window($type)
		} else {
			set prior ""
		}
		set default_window($type) $windowobj
		return $prior
	} else {
		error "$windowobj not found!"
	}
}

body mtiwidgets::WindowMgr::GetWindowTypes {  } {
	set rv [list]
	foreach windowobj [array names windowObjCache]  {
		lappend rv [$windowobj cget -windowtype]
	}
	return [lsort -dictionary -unique $rv]
}


body mtiwidgets::WindowMgr::ValidType { window_type } {
	foreach windowobj [array names windowObjCache]  {
		if { $window_type eq [$windowobj cget -windowtype] } {
			return 1
		}
	}
	return 0
}


body mtiwidgets::WindowMgr::GetAllVisibleWindows {  } {
	set retval [list]
	foreach windowobj [array names windowObjCache]  {
		if { [WindowObjVisible $windowobj] } {
			lappend retval $windowobj
		}
	}
	return $retval
}

body mtiwidgets::WindowMgr::GetAllUndockedWindows {  } {
	set retval [list]
	foreach {this_name windowobj} [array get window_list]  {
		if { [WindowObjVisible $windowobj] && [WindowUndocked $windowobj] } {
			lappend retval $windowobj
		}
	}
	return $retval
}

body mtiwidgets::WindowMgr::DockAllUndockedWindows {  } {
	foreach {this_name windowobj} [array get window_list]  {
		if { [WindowObjVisible $windowobj] && [WindowUndocked $windowobj] } {
			ToggleDock $windowobj
		}
	}
}



body mtiwidgets::WindowMgr::TestForLast { windowobj {suppress_error 0}} {
	set cnt 0
	set visible_windows [GetAllVisibleWindows]
	foreach a_windowobj $visible_windows {
		if { ![WindowUndocked $a_windowobj] } {
			if { $a_windowobj ne $windowobj } { 
				# if there is one visible, and its not the one closing then
				# then there will be at least one remaining.
				return 0
			}
			incr cnt
			if { $cnt > 1 } {
				return 0
			}
		}
	}
	if { $cnt == 1 } {
		if { !$suppress_error } {
			tk_messageBox  -title "Warning - Unable to Remove Window" -title Warning -message "Unable to remove window.  One window must remain docked within the main window." -type ok -parent . -icon info
		}
		return 1
	}
	return 0
}

# Previous versions of Modelsim bound the toggle dock event to the windowobj (paneframe)
# and the frame called the panemanager directly.  All windows are now undockable, and at least 
# one must remain in the main frame so the window manager now handles the start of the undock process.
body mtiwidgets::WindowMgr::ToggleDock { windowobj {geometry ""} {suppress_error 0}} {
	if { ![WindowObjVisible $windowobj] } { 
		if { [catch {ShowWindow $windowobj} results] } { 
			return -code error $results
		}
		if { [$windowobj GetRegisteredChild] eq "" } {
			# the Show Failed
			return $results
		}
	}

	set docking_it [WindowUndocked $windowobj]
	if { $docking_it } {
		Dock $windowobj $geometry $suppress_error
	} else { 
		UnDock $windowobj $geometry $suppress_error
	}
}


body mtiwidgets::WindowMgr::UnDock { windowobj {geometry ""} {suppress_error 0}} {
	if { ![WindowObjVisible $windowobj] } { 
		if { [catch {ShowWindow $windowobj} results] } { 
			return -code error $results
		}
		if { [$windowobj GetRegisteredChild] eq "" } {
			# the Show Failed
			return $results
		}
	}

	set undocked [WindowUndocked $windowobj]
	if { $undocked } {
		$windowobj _UnDock 
		return
	}
	if { $geometry eq "" } {
		# test for last window
		if { [TestForLast $windowobj $suppress_error] } {
			return
		}
		set geometry [$windowobj GetUndockGeomHistory]
	} 

	set sibling [$panemanager windowprevious $windowobj]
	$panemanager togglerip $windowobj $geometry
	$windowobj _UnDock
	if { $sibling ne"" } {
		# This Show Raises the correct window in the remaing tabset.
		ShowWindow $sibling
	} 
	$actionmanager Activate $windowobj
}


body mtiwidgets::WindowMgr::Dock { windowobj {geometry ""} {suppress_error 0}} {
	if { ![WindowObjVisible $windowobj] } { 
		if { [catch {ShowWindow $windowobj} results] } { 
			return -code error $results
		}
		if { [$windowobj GetRegisteredChild] eq "" } {
			# the Show Failed
			return $results
		}
	}

	set undocked [WindowUndocked $windowobj]
	if { !$undocked } {
		return
	}
	$windowobj SetUndockGeomHistory [wm geometry $windowobj]
	$panemanager togglerip $windowobj $geometry
	$windowobj _Dock
	if { ![$windowobj IsViable] } {
		global vsimPriv
		$vsimPriv(PaneMgr) triggermap $windowobj
	}
}



proc dw {{d 0 } {type all} } {
	$::vsimPriv(windowmgr) DumpWindows $d $type
}
 
body mtiwidgets::WindowMgr::DumpWindows { where type} {
	if { !$where  } {
		foreach {this_name windowobj} [array get window_list]  {
			if { $type ne "all" && $type ne [$windowobj cget -windowtype] } { 
				continue
			}
			$windowobj DumpAll $where
		}
	}
}

body mtiwidgets::WindowMgr::FindFirstOfType {  windowobj } {
	set window_type [$windowobj cget -windowtype]
	foreach {this_name tmp_windowobj} [array get window_list]  {
		if { $tmp_windowobj eq $windowobj } {
			continue
		}
		if { [$tmp_windowobj cget -windowtype] == $window_type && [$panemanager exists $tmp_windowobj]} {
			return $tmp_windowobj
		}
	}
	set layout_location [$windowobj cget -layoutlocation]
	if { $layout_location != ""  } {
		set tmp_windowobj [GetWindow $layout_location]
		if { $tmp_windowobj != "" } {
			return $tmp_windowobj
		}
	}
	return [GetWindow library]
}

# Be carefull with this call.  It cannot be used for checking visiblity.  The window may
# have a tab, but it may not have been mapped, so there is not child or child contents.
body mtiwidgets::WindowMgr::WindowInLayout {  windowobj } {
	if { $LayoutInTransition } {
		if { [lsearch -exact $new_visibility_windows $windowobj] < 0 } {
			return 0
		}
		return 1
	}

	if { [WindowObjVisible $windowobj] || [$panemanager windowhastab $windowobj]} {
		return 1
	}
	return 0
}



body mtiwidgets::WindowMgr::WindowTypeInLayout { window_type } {
	foreach {name windowobj} [array get window_list]  {
		if {[$windowobj cget -windowtype] eq $window_type && [WindowInLayout $windowobj]} {
			return 1
		}
	}
	return 0
}


# This call is used by the Next/Prev Activate Window (F4 button)
# Jumping from a top level to another top level does not work on *NIX
# (its always behaved this way).  It does on windows, so we support it.
body mtiwidgets::WindowMgr::GetOrderedWindowList {{all 0}} {
	global tcl_platform
	set results [$panemanager GetOrderedWindowList]
	if {$all || $tcl_platform(platform) == "windows"} {
		foreach windowobj [GetAllUndockedWindows]  {
			lappend results $windowobj
		}
	}
	return $results
}


body mtiwidgets::WindowMgr::GetWindowsInLayout { } {
	set retval [list]
	foreach {name windowobj} [array get window_list]  {
		if {[WindowInLayout $windowobj]} {
			lappend retval $windowobj
		}
	}
	return $retval
}


body mtiwidgets::WindowMgr::GetWindowsNotInLayout { } {
	set retval [list]
	foreach {name windowobj} [array get window_list]  {
		if {![WindowInLayout $windowobj]} {
			lappend retval $windowobj
		}
	}
	return $retval
}


body mtiwidgets::WindowMgr::CreateWindow { window_type args } {
	set window_data ""
	# find the unique handle switch if it was provided
	if {[set ix [lsearch -exact $args -window_data]] >= 0} {
		set window_data [lindex $args [expr {$ix + 1}]]
	}
	set force 0
	# find the force create switch if it was provided
	if {[set ix [lsearch $args -force]] >= 0} {
		set force [lindex $args [expr {$ix + 1}]]
		set args [lreplace $args $ix [expr {$ix+1}]]
	}

	# if the creation is forced, then look for either an unused window or create one

	# if the creation is not force, then look for one that matches the request, an unused one or create one
	# the difference is based on creation behavior.  If the user issues a view transcript, the existing transcript
	# should be displayed.  if they issue a view -new wave they are expecting a new wave window, the force
	# switch indicates this behavioral difference.
	if { $force } {
		set windowobj [FindUnusedWindow $window_type]
	} else {
		#  if the window we want already exists return it
		set windowobj [GetWindow $window_type $window_data]
		if { $windowobj ne "" } {
			return $windowobj
		}

		# Look for a window that we can reuse.  This can be a hidden frame
		# or it can be an empty window that is visible but has the unused flag set
		# or it can be an inuse window where the unique id matches
		set windowobj [eval [ linsert $args 0  FindReusableWindow $window_type $window_data]]
		if { $windowobj == 0 } { 
			return 0
		}
	}
	if { $windowobj eq "" } {
		# Last, we create a frame and insert it.  Note that the window must be created and added
		# to the window list BEFORE the insert_special is called.  insert_special will result in the 
		# show call.
		set frame_index [NewFrameIndex $window_type]
		if { $frame_index == 0 } {
			set frame_index ""
		}
		set window_index ""
		while {[info exists windowObjCache(.main_pane.$window_type$window_index)]} {
			set window_index [expr {($window_index eq "") ? 1 : $window_index+1}]
		}
		set window_name $window_type$window_index
		set windowobj [eval [linsert $args 0 ::mtiwidgets::windowobj .main_pane.$window_name \
								 -actionmanager		$actionmanager \
								 -panemanager		$panemanager \
								 -windowmanager		$this \
								 -windowtype		$window_type \
								 -expelcommand		[code $this ToggleDock .main_pane.$window_name] \
								 -maximizecommand	[code $this ToggleMax  .main_pane.$window_name] \
								 -type_index		$frame_index \
								 -windowname		$window_name]]
		if { ![$windowobj TestCallBacks] } {
			set window_list($window_name) $windowobj	
			set windowObjCache($windowobj) $window_name
			set windowTypesCache($window_type) ""
		} 	
		set first_of_type [FindFirstOfType $windowobj]
		$panemanager insert_special $windowobj $first_of_type
	} 
	set hidecommand [$windowobj cget -hidecommand]
	if { $hidecommand eq "" } {
		$windowobj configure -hidecommand [code $this HideWindow $windowobj]
	}
	return $windowobj
}

body mtiwidgets::WindowMgr::CreateNewWindow { window_type } {
	set default_win [GetDefaultWindow $window_type]

	set windowobj [CreateWindow $window_type \
						-createcommand		[$default_win cget -createcommand] \
						-closecommand		[$default_win cget -closecommand] \
						-dockcommand		[$default_win cget -dockcommand] \
						-undockcommand		[$default_win cget -undockcommand] \
						-titlecommand		[$default_win cget -titlecommand] \
						-tab_labelcommand	[$default_win cget -tab_labelcommand] \
						-multipleinstances	[$default_win cget -multipleinstances] \
						-reopencommand		[$default_win cget -reopencommand] \
						-activatecommand	[$default_win cget -activatecommand] \
						-deactivatecommand	[$default_win cget -deactivatecommand] \
						-actioncommand		[$default_win cget -actioncommand] \
						-iconimage			[$default_win cget -iconimage] \
						-layoutrestore		[$default_win cget -layoutrestore] \
						-layoutvisibility	[$default_win cget -layoutvisibility] \
						-undockmbcommand	[$default_win cget -undockmbcommand] \
						-undocktbcommand	[$default_win cget -undocktbcommand] \
						-createfootercommand [$default_win cget -createfootercommand] \
						-createconsolefooter [$default_win cget -createconsolefooter] \
						-tab_label			[$default_win cget -defaultlabel] \
						-force				1 
			]
	return $windowobj
}

body mtiwidgets::WindowMgr::FindOldestWindow  { windowlist }  {
	# return the oldest one ie. it has the lowest type index
	set idx 1000
	foreach windowobj $windowlist {
		set this_index [$windowobj cget -type_index]
		# if it has no index then it is the oldest
		if { $this_index eq "" } {
			return $windowobj
		}
		if  { $this_index < $idx } {
			set idx $this_index
		}
	}
	foreach windowobj $windowlist {
		if {[$windowobj cget -type_index] == $idx } {
			return $windowobj
		}
	}
	return ""
}


body mtiwidgets::WindowMgr::FindUnusedWindow  { window_type }  {
	set windowlist [list]
	foreach {this_name windowobj} [array get window_list]  {
		if { [$windowobj cget -windowtype] == $window_type } {
			if { ![$panemanager visible $windowobj]} {
				lappend windowlist $windowobj			
			}
		}
	}
	return [FindOldestWindow $windowlist]
}


body mtiwidgets::WindowMgr::FindReusableWindow  { window_type window_data args}  {
	set windowobj ""
	set new_label ""
	if {[set ix [lsearch $args -tab_label]] >= 0} {
		set new_label [lindex $args [expr {$ix + 1}]]
	}

	# Looking for a window that we can use.  First look for one is already visible
	# Only windows of multiple_instance = 1 can be in this state
	if { $window_data ne "" } {
		set window_obj_list  [GetWindowObjsByType $window_type] 
		# case where the window is visible and sitting there doing nothing
		foreach a_windowobj $window_obj_list {
			if { [$a_windowobj cget -window_data] eq "" } {
				if { [$panemanager visible $a_windowobj] && [$a_windowobj GetRegisteredChild] ne ""} {
					set windowobj $a_windowobj
					eval [linsert $args 0 $windowobj configure]
					if { [$windowobj cget -reopencommand] ne "" } {	
						if {[catch {eval [$windowobj cget -reopencommand] $windowobj } results]} {
							puts stderr "Reopencommand error: $results\n$::errorInfo"
						}
						if { $results == 0 }  {
							return 0
						} 
					}
					if { $new_label eq "" } { 
						set new_label [$windowobj cget -tab_label]
					}
					RenameWindow $windowobj $window_data $new_label
					return $windowobj
				}
			}
		}

		# case where the window was closed earlier but still has its registered child
		set window_obj_list  [GetWindowObjsByType $window_type 0] 
		foreach a_windowobj $window_obj_list {
			if { [$a_windowobj cget -window_data] eq "" } {
				if { [$a_windowobj GetRegisteredChild] ne ""} {
					set windowobj $a_windowobj
					eval [linsert $args 0 $windowobj configure]
					if { [$windowobj cget -reopencommand] ne "" } {	 
						if {[catch {eval [$windowobj cget -reopencommand] $windowobj } results]} {
							puts stderr "Reopencommand error: $results\n$::errorInfo"
						}
						if { $results == 0 }  {
							return 0
						} 
					}
					if { $new_label eq "" } { 
						set new_label [$windowobj cget -tab_label]
					}
					RenameWindow $windowobj $window_data $new_label
					return $windowobj
				}
			}
		}

		set windowlist [list]
		if { $windowobj eq "" } {
			foreach a_windowobj [GetWindowObjsByType $window_type 0] { 
				if { [$a_windowobj GetRegisteredChild] eq ""} {
					lappend windowlist $a_windowobj
				}
			}
			set windowobj [FindOldestWindow $windowlist]
			if { $windowobj ne "" } {
				eval [linsert $args 0 $windowobj configure -window_data $window_data]
				if { ![$panemanager exists $windowobj] } {
					$panemanager insert_special $windowobj [FindFirstOfType $windowobj]
				} 
				if { $new_label eq "" } { 
					set new_label [$windowobj cget -tab_label]
				}
				RenameWindow $windowobj $window_data $new_label
				return $windowobj
			}
		}
	}
	return ""
}

body mtiwidgets::WindowMgr::ShowWindowType { window_type } {
	set windowobj [GetWindow $window_type]
	if { [catch {ShowWindow $windowobj} results] } { 
		return -code error $results
	}
	return $windowobj 
}

body mtiwidgets::WindowMgr::ShowWindow { windowobj {force 0}} {
	if { ![winfo exists $windowobj] } { 
		error "error WindowMgr::ShowWindow - windowobj $windowobj does not exists"
		return 0
	}

	if { [$windowobj WindowInTransition] } {
		return 0
	}
	if { [$windowobj cget -serializing] } {
		$windowobj configure -serializing 0
	} else {
		if { [WindowObjVisible $windowobj] } { 
			$actionmanager Activate $windowobj
			return 1
		}
	}

	set mtiwidgets::WindowObj::busy 1

	set postundock_necessary 0
	$windowobj configure -window_showing 1
	set child [$windowobj GetRegisteredChild]
	set child_exists 1
	if { $child eq "" || ![winfo exists $child] } {
		set child_exists 0
		if { [$windowobj cget -createcommand] ne "" } {	

			set createcommand [$windowobj cget -createcommand]
			# The following test checks to see if a createcommand exists and handles
			# it gracefully if it doesnt
			# The createcommand can be missing because the layout change specified a
			# window type that doesnt exist or becasue a window type was registered
			# but the actual window code hasn't been sourced.
			if { [info commands $createcommand] eq "" } {
				global auto_index
				if { ![info exists auto_index($createcommand)] &&
					 ![info exists auto_index(::$createcommand)]
				} {
					$windowobj configure -window_showing 0
					set mtiwidgets::WindowObj::busy 0
					return -code error "Unable to open window, the -createcommand $createcommand does not exist"
				}
			}
			if { [catch { eval [$windowobj cget -createcommand] $windowobj } results ] } {
				HideWindow $windowobj error
				$windowobj configure -window_showing 0
				set mtiwidgets::WindowObj::busy 0
				return -code error $results
			}
			if { [$windowobj GetRegisteredChild] eq "" } {
				# no error, but the window chose to not be visible
				HideWindow $windowobj error
				$windowobj configure -window_showing 0
				set mtiwidgets::WindowObj::busy 0
				return 0 ;# - window $windowobj hidden
			}
		}
		if { [$windowobj cget -multipleinstances] } {
			if { [$windowobj cget -window_data] eq "" } { 
				$windowobj configure -window_data [$windowobj cget -windowname]
			}
		}
	}
				
	if { ![$panemanager exists $windowobj] } {
		set first_of_type [FindFirstOfType $windowobj]
		$panemanager insert_special $windowobj $first_of_type
	}

	$panemanager show $windowobj

	if { $child_exists } {
		if { [$windowobj cget -reopencommand] ne "" } {	
			if {[catch {eval [$windowobj cget -reopencommand] $windowobj } results]} {
				puts stderr "Reopencommand error: $results\n$errorInfo"
			}
			if { $results == 0 }  {
				$windowobj configure -window_showing 0
				set mtiwidgets::WindowObj::busy 0
				return 0 ;# window $windowobj hidden
			} 
		} else {
			# error "Window $windowobj does not define a reopencommand call back but did not unregister its child window on close"
		}
	}

	$windowobj configure -window_showing 0

	if { [WindowUndocked $windowobj] } {
		# if a window is undocked within the layout and sets layoutrestore to false,
		# the undock geometry/position is generated but the showwindow has not yet been called.
		# Later (when this code is reached), if the window is shown, the necessary undock work 
		# needs to occur.  If the windowobjs toolbar is an empty string, then the _UnDock hasn't been
		# called and is needed.
		if { [$windowobj GetToolbar] == "" } {
			$windowobj _UnDock
		}
	} 

	if { ![$windowobj IsViable] } {
		if { ![WindowUndocked $windowobj] } {
			global vsimPriv
			catch { $vsimPriv(PaneMgr) triggermap $windowobj } err
		}
	}
	if {![winfo ismapped .]} {
		set mtiwidgets::WindowObj::busy 0
		return 0
	}
	eval $actionmanager Activate $windowobj
	$windowobj UpdateText
	SetDefaultWindow $windowobj
	set body [$windowobj GetBody]
	while {!([winfo exists $body] && [winfo ismapped $body]) || ![$windowobj IsViable]} {
		if {![winfo ismapped $body]} {
			tkwait visibility $body
		} elseif {![$windowobj IsViable]} {
			set child [$windowobj GetRegisteredChild]
			tkwait visibility $child
		}
	}
	set mtiwidgets::WindowObj::busy 0
	FlushEvents
	return 1
}


body mtiwidgets::WindowMgr::ShowWindowNoDisplay { windowobj } {
	if { ![winfo exists $windowobj] } { 
		error "error WindowMgr::ShowWindow - windowobj $windowobj does not exists"
		return 0
	}
	if { [$windowobj WindowInTransition] } {
		return 0
	}
	if { [$windowobj cget -serializing] } {
		$windowobj configure -serializing 0
	} else {
		if { [WindowObjVisible $windowobj] } { 
			$actionmanager Activate $windowobj
			return 1
		}
	}
	set child [$windowobj GetRegisteredChild]
	set child_exists 1
	if { $child eq "" || ![winfo exists $child] } {
		set child_exists 0
		if { [$windowobj cget -createcommand] ne "" } {	
			set createcommand [$windowobj cget -createcommand]
			if { [info commands $createcommand] eq "" } {
				global auto_index
				if { ![info exists auto_index($createcommand)] &&
					 ![info exists auto_index(::$createcommand)]
				} {
					$windowobj configure -window_showing 0
					return -code error "Unable to open window, the -createcommand $createcommand does not exist"
				}
			}
			if { [catch { eval [$windowobj cget -createcommand] $windowobj } results ] } {
				HideWindow $windowobj error
				$windowobj configure -window_showing 0
				return -code error $results
			}
			if { [$windowobj GetRegisteredChild] eq "" } {
				# no error, but the window chose to not be visible
				HideWindow $windowobj error
				$windowobj configure -window_showing 0
				return 0 ;# - window $windowobj hidden
			}
		}
		if { [$windowobj cget -multipleinstances] } {
			if { [$windowobj cget -window_data] eq "" } { 
				$windowobj configure -window_data [$windowobj cget -windowname]
			}
		}
	}
				
	$windowobj configure -window_showing 0
	return 1
}

body mtiwidgets::WindowMgr::GetDefaultWindowObj { windowobj } {
	if {[winfo exists $windowobj] } {
		return $windowobj
	}
	set leaf [string range $windowobj [string length ".main_pane."] end]
	set leaf_len [string length $leaf]
	foreach type [GetWindowTypes] {
		set type_len [string length $type]
		if { $type_len > $leaf_len } {
			continue
		}
		incr type_len -1
		set test_leaf [string range $leaf 0 $type_len]
		if { $test_leaf eq $type } {
			set wobj [GetWindow $test_leaf]
			if { [winfo exists $wobj] } {
				return $wobj
			}
		}
	}
	return ""
}

body mtiwidgets::WindowMgr::HideWindow { windowobj {reason user}} {
	if {![winfo exists $windowobj] || ![$panemanager visible $windowobj]} {
		return
	}

	if { $reason eq "user" && ![WindowUndocked $windowobj] && [TestForLast $windowobj] } {
		return
	}
	$windowobj configure -window_closing 1
	set child [$windowobj GetRegisteredChild]

	set sibling ""
	if { $reason eq "user" && ![WindowUndocked $windowobj]} {
		set sibling [$panemanager windowprevious $windowobj]
	}
	if { [$windowobj cget -closecommand] ne "" && $child ne "" } {
		if { [catch { eval [list [$windowobj cget -closecommand] $windowobj $reason]} results ] } {
			$windowobj configure -window_closing 0
			catch { $panemanager hide $windowobj }
			puts stderr "error on $windowobj -closecommand : $results"
			return $results
		}

		if { $results == 0 } {
			# the window did not want to close
			# check to see if the windows close is actually messed up
			if { [$windowobj GetRegisteredChild] ne "" && [winfo exists $child] } {
				$windowobj configure -window_closing 0
				return 0
			}
		}
		if { $results != 1 } {
			puts stderr "Attempting to hide window $windowobj - it failed to return a 1, 0 or an error"
		}
	}
	$panemanager hide $windowobj
	if { $reason eq "exit" } {
		return 
	}
	set child [$windowobj GetRegisteredChild]
	if { $child eq "" || ![winfo exists $child] } { 
		$windowobj Reset
	}

	$windowobj configure -window_closing 0
	global vsimPriv
	#Note - we do not want to reset the active window while in the middle of a layout change
	# so the hide reason is important
	if { $reason eq "user" } {	
		if { $sibling ne"" } {
			ShowWindow $sibling
		} else { 
			$vsimPriv(Vcop) ActivateDefault
		}
	}
}

body mtiwidgets::WindowMgr::RegisterWindow { windowobj child } { 
	$windowobj configure -window $child 
}

body mtiwidgets::WindowMgr::RegisterView { windowobj viewwidget } { 
	$windowobj configure -viewwidget $viewwidget
}

##
## Register window data for faster lookups
##
body mtiwidgets::WindowMgr::RegisterData { windowobj window_data } {

   # There is an issue that needs special handling related to using
   # the "window_data" value as a key name for the windowDataCache array.
   # Because the value of window_data can be arbitrary, it's possible for
   # it to contain characters that make it difficult to correctly perform
   # the "array unset" calls below. I believe this is due to the pattern
   # matching that the Tcl "array" code is doing. An example of this is when
   # window_data contains "\" characters, which is the case when dealing with
   # VHDL extended identifiers. To provide reliable behavior(ie the "unset"
   # actually works), we make sure we use a key name which has had the
   # problematic characters mapped to something safe.
   #
   if {$window_data ne ""} {
      # TODO:  should we check for overwrite?
      if {[info exists windowDataCache($window_data)] &&
         $windowDataCache($window_data) ne $windowobj} {
         error "Duplicate cross-reference for $window_data"
      }
      if {[info exists windowReverseCache($windowobj)]} {
         set old_value $windowReverseCache($windowobj)
         set clean_key [string map {\\ \\\\} $old_value]

         array unset windowDataCache $clean_key
         array unset windowReverseCache $windowobj
      }
      set windowDataCache($window_data) $windowobj
      set windowReverseCache($windowobj) $window_data

   } elseif {[info exists windowReverseCache($windowobj)]} {
      set old_value $windowReverseCache($windowobj)
      set clean_key [string map {\\ \\\\} $old_value]

      array unset windowDataCache $clean_key
      array unset windowReverseCache $windowobj
   }
}

body mtiwidgets::WindowMgr::GetRegisteredWindows { } { 
	set ret_val [list]
	foreach {this_name windowobj} [array get window_list]  {
		lappend ret_val $windowobj
	}
	return $ret_val	
}



body mtiwidgets::WindowMgr::GetRegisteredChild { window_type {window_data ""}} { 
	if { ![WindowExists $window_type $window_data] } {
		return ""
	}
	set windowobj [GetWindow $window_type $window_data ]
	return [$windowobj cget -window]
}

body mtiwidgets::WindowMgr::GetRegisteredView { window_type {window_data ""}} { 
	if { ![WindowExists $window_type $window_data] } {
		return ""
	}
	set windowobj [GetWindow $window_type $window_data ]
	set vw [$windowobj cget -viewwidget]
	if {$vw eq ""} {
		set vw [$windowobj cget -window]
	}
	return $vw
}

body mtiwidgets::WindowMgr::WindowVisible { window_type {window_data ""} } {
	if { ![WindowExists $window_type $window_data] } {
      if { ![ValidType $window_type] } {
         CallTrace echo
         return -code error "Invalid window type specified: $window_type"
      }
		return 0
	}
	set windowobj [GetWindow $window_type $window_data ]

	if {[winfo exists $windowobj] } {
		if { [WindowObjVisible $windowobj] } { 
			return 1
		}
	}
	return 0 
}

body mtiwidgets::WindowMgr::WindowObjVisible { windowobj } {
	if {[winfo exists $windowobj] && [$panemanager visible $windowobj]} {
		set child [$windowobj GetRegisteredChild] 
		if { $child ne ""} {
			return 1
		}
	}
	return 0 
}
body mtiwidgets::WindowMgr::AnyWindowVisible { window_type } {
	foreach windowobj [GetWindowObjsByType $window_type] {
		if {[WindowObjVisible $windowobj]} {
			return 1
		}
	}
	return 0

}

body mtiwidgets::WindowMgr::WindowUndocked { windowobj } {
	if {[winfo exists $windowobj] && [winfo toplevel $windowobj] eq $windowobj} {
		return 1
	}
	return 0 
}

body mtiwidgets::WindowMgr::GetAllIconifiedWindows { } {
	set retval [list]
	foreach {this_name windowobj} [array get window_list]  {
		if { ([winfo toplevel $windowobj] eq $windowobj) && ([$windowobj GetRegisteredChild] != "")} {
			lappend retval $windowobj
		}
	}
	return $retval
}

body mtiwidgets::WindowMgr::RenameWindow  { windowobj new_window_data new_label}  {
	$windowobj configure -window_data $new_window_data
	if { $new_label ne "" && [$windowobj cget -tab_labelcommand] eq ""} { 
		$windowobj configure -defaultlabel $new_label
	}		
	$windowobj UpdateText
#	if { ![WindowUndocked $windowobj] } { 
#		$panemanager rename $windowobj
#	}
}
# During the course of unserializing a layout string (window names and locations) 
# We can come across a second instance of a window, like a wave window or source window
# By keeping the frame in the serialized string, we essentially are keeping track of where
# the second instance of, say, the wave window should be created.

body mtiwidgets::WindowMgr::UnSerializedNewFrame { windowobj } {
	set name_parse [lindex [split $windowobj .] end]
	set window_type [string trim $name_parse 0123456789]

	if {![ValidType $window_type] } {
		return 0
	}
	set frame_index [NewFrameIndex $window_type]
	if { $frame_index == 0 } {
		set frame_index ""
	}

	set default_win [GetDefaultWindow $window_type]
	if { $default_win eq "" } {
		error "No default window found for window_type $window_type.  Unable to create window"
		return
	}

	# Note - we do not call CreateWindow because we need a windowobj named exactly as it is found in the 
	# unserialized string. 
	set window_name $window_type$frame_index
	::mtiwidgets::windowobj $windowobj \
			-windowtype			$window_type \
			-actionmanager		$actionmanager \
			-windowmanager		$this \
			-panemanager		$panemanager \
			-expelcommand		[code $this ToggleDock $windowobj] \
			-maximizecommand	[code $this ToggleMax $windowobj] \
			-type_index			$frame_index \
			-windowname			$window_name \
			-layoutrestore		[$default_win cget -layoutrestore] \
			-layoutvisibility	[$default_win cget -layoutvisibility] \
			-createcommand		[$default_win cget -createcommand] \
			-closecommand		[$default_win cget -closecommand] \
			-dockcommand		[$default_win cget -dockcommand] \
			-undockcommand		[$default_win cget -undockcommand] \
			-titlecommand		[$default_win cget -titlecommand] \
			-tab_labelcommand	[$default_win cget -tab_labelcommand] \
			-multipleinstances	[$default_win cget -multipleinstances] \
			-reopencommand		[$default_win cget -reopencommand] \
			-activatecommand	[$default_win cget -activatecommand] \
			-deactivatecommand	[$default_win cget -deactivatecommand] \
			-actioncommand		[$default_win cget -actioncommand] \
			-undockmbcommand	[$default_win cget -undockmbcommand] \
			-undocktbcommand	[$default_win cget -undocktbcommand] \
			-createfootercommand [$default_win cget -createfootercommand] \
			-createconsolefooter [$default_win cget -createconsolefooter] \
			-iconimage			[$default_win cget -iconimage] \
			-tab_label			[$default_win cget -defaultlabel] \
			-title				[$default_win cget -title]  

	set window_list($window_name) $windowobj
	set windowObjCache($windowobj) $window_name
	set windowTypesCache($window_type) ""

	# A hide command must be defined for the close window icon
	# We set it to the default only if a window specific callback is not defined.
	set hidecommand [$windowobj cget -hidecommand]
	if { $hidecommand eq "" } {
		$windowobj configure -hidecommand [code $this HideWindow $windowobj user]
	}
	return 1
}

body mtiwidgets::WindowMgr::TogglePaneHeaders {  } {
	set new_value [expr {! $pane_headers_visible}]
	foreach {this_name windowobj} [array get window_list]  {
		$windowobj configure -headervisible $new_value
	}
	set pane_headers_visible $new_value
}
 
body mtiwidgets::WindowMgr::PaneHeadersVisible { } {
	return $pane_headers_visible
}
proc mtiwidgets::mgr_undefined {which args} {
	error "The $which manager command is undefined: $args"
}
proc mtiwidgets::mgr_undefinedAction {args} {
	eval [linsert $args 0 mgr_undefined Action]
}
proc mtiwidgets::mgr_undefinedWindow {args} {
	eval [linsert $args 0 mgr_undefined Window]
}
proc mtiwidgets::mgr_undefinedPane {args} {
	eval [linsert $args 0 mgr_undefined Pane]
}

body mtiwidgets::WindowMgr::CloseAllWindows { } {
	if { $maximized_mode } {
		global vsimPriv
		set active_window [$vsimPriv(Vcop) ActiveWindow]
		NormalizeWindows
		FlushEvents
	    Layout::SaveLayout $Layout::currentLayout
		Layout::StoreLayoutAsMaximized 	$active_window 
	}

	set LayoutInTransition 1
	foreach {this_name windowobj} [array get window_list]  {
		$windowobj configure -window_closing 1
	}
	foreach windowobj [GetAllVisibleWindows] {
		set results [HideWindow $windowobj exit]
	}
}

body mtiwidgets::WindowMgr::CloseWindowsByType { window_type {reason user} } {
	foreach windowobj [GetWindowObjsByType $window_type] {
		set results [HideWindow $windowobj $reason]
	}
}

#
# ToggleMax will maximize a window.  Essentially, the window gets upacked from its tabbed window
# and gets repacked into the panemanager's child site (cs).
# There are a few special considerations.  First, if a layout is saved that has a maximized window,
# the maximazation must happen last.  The panemanager will call ToggleMax, and if LayoutInTransition is 
# true, it means we are in the middle of unserializing.  In this situation, we capture the window to maixmize, 
# and later in LayoutChangeComplete, after everything is done (including opening of source windows)
# we maximize.
# The other tricky situation is when we normalize (maximize to normals mode).  Many of the windows 
# in the layout will not display by default, as they may be a multi-instance window.  The purpose of the 
# LayoutChangePending and LayoutChangeComplete is to capture and restore windows that should be open.
#
#
body mtiwidgets::WindowMgr::ToggleMax { windowobj } {
	global vsimPriv
	if { !$maximized_mode } {
		MaximizeWindow $windowobj
		Layout::StoreLayoutAsMaximized 	$windowobj
	} else { 
		NormalizeWindows
		Layout::DontStoreLayoutAsMaximized
	}
}

body mtiwidgets::WindowMgr::MaximizeWindow { windowobj } {
	global vsimPriv
	if { $windowobj eq "" } {
		return
	}
    Layout::SaveLayout $Layout::currentLayout
	set maximized_mode 1
	Layout::LayoutMaximize 
	FlushEvents
	$vsimPriv(Vcop) Activate $windowobj
}


body mtiwidgets::WindowMgr::MinimizeWindow { windowobj } {
	NormalizeWindows
}

body mtiwidgets::WindowMgr::NormalizeWindows { } {
	if { $maximized_mode } {
		global vsimPriv
		set active_window [$vsimPriv(Vcop) ActiveWindow]
		Layout::Minimize
		set maximized_mode 0
		FlushEvents
		$vsimPriv(Vcop) Activate $active_window
		after idle [code $this UpdateMaxButton]
	}
}

body mtiwidgets::WindowMgr::UpdateMaxButton { } {
	foreach windowobj [GetWindowsInLayout] { 
		$windowobj SetMaxButtonIcon
	}
}

# Layout Change Pending/Restore
# When a layout changes, all windows are hidden.  Some windows may be defined to not hide for the given
# reason.  IE.  the structure window should not close due to a layout change.

body mtiwidgets::WindowMgr::LayoutChangePending { reason layout } {
	set in_layout_list  [GetWindowsInLayout]
	set visible_windows [GetAllVisibleWindows]

	set restore_list [list]
	set new_visibility [$panemanager parsevisibility $layout]
	set new_visibility_windows [lindex $new_visibility 1]


	set layout_change 1
	# Note LayoutInTransition is used throughout the windowmgr and can effect the behavior of certain calls.

	set LayoutInTransition 1
	set LayoutTransitionClosing 1

	if { $reason == "Minimize" || $reason == "Maximize"} {
		set layout_change 0
	}	

	foreach windowobj $visible_windows {
		set geom "" 
		set results 0
		set dock_state 0
		set dock_state [WindowUndocked $windowobj]
		if { $dock_state } {
			set geom [wm geometry $windowobj]
			Dock $windowobj
		}
		if { $layout_change && [lsearch -exact $new_visibility_windows $windowobj] < 0 } {
			# the window is not visibile in the next layout
			# When swapping to a new layout, the pane manager will not call the closecallback
			# if the window is to be closed, we must do it here
			set results [HideWindow $windowobj $reason]
			if { $results eq 0 } { 
				lappend restore_list [list $windowobj $dock_state $geom]
			}
		}
	}
	set LayoutTransitionClosing 0
}

body mtiwidgets::WindowMgr::LayoutChangeComplete { reason } {
	set LayoutInTransition 0
	foreach entry $restore_list {
		set windowobj [lindex $entry 0]
		set dock_state [lindex $entry 1]
		set geom [lindex $entry 2]
		ShowWindow $windowobj
		if { $dock_state } {
			UnDock $windowobj $geom 1
			catch {wm geometry $windowobj $geom} 				
		}			
	}

	if { $reason eq "Minimize" } {
		foreach entry $Layout::add_list {
			set windowobj [lindex $entry 0]
			set geom [lindex $entry 1]
			ShowWindow $windowobj
			if { $geom ne "na" } {
				UnDock $windowobj $geom
			}
		}
	}
	set layout_change 1 
}

body mtiwidgets::WindowMgr::ActivatePreviousPane {  } {
	global vsimPriv
	set active_window [$vsimPriv(Vcop) ActiveWindow]
	set visible_windows [GetOrderedWindowList]
	set idx [lsearch -exact $visible_windows $active_window] 
	if { $idx < 0 } {
		return
	}
	if {$idx == 0} {
		set idx end
	} else {
		incr idx -1
	}
	ShowWindow [lindex $visible_windows $idx]
}

body mtiwidgets::WindowMgr::ActivateNextPane {  } {
	global vsimPriv
	set active_window [$vsimPriv(Vcop) ActiveWindow]
	set visible_windows [GetOrderedWindowList]
	set len [llength $visible_windows] 
	set idx [lsearch -exact $visible_windows $active_window] 
	if { $idx < 0 } {
		return
	}
	if { $idx == [expr { $len - 1} ] } {
		set idx 0
	} else {
		incr idx
	}
	ShowWindow [lindex $visible_windows $idx]
}

# str : label text for the menu item
# cmd : command to be executed by the item
# test: optional "can_XXXX" handler
# m   : optional menu handle (use when adding items into a submenu
#
body mtiwidgets::WindowMgr::ClientAddViewMenuItem {str cmd {test ""} {m ""}} {
   global vsimPriv

   if { $m == "" } {
      set m $vsimPriv(viewMenuWidget)
      incr vsimPriv(viewMenuInsertIndex)
   }
   AddMenuItem $str $m $cmd $test "quiet" "none" $vsimPriv(viewMenuInsertIndex)
}

# str : label text for the menu item
# test: optional "can_XXXX" handler
#
body mtiwidgets::WindowMgr::ClientAddViewSubMenu {str {test ""}} {
   global vsimPriv

   set insert_at [incr vsimPriv(viewMenuInsertIndex)]

   set m $vsimPriv(viewMenuWidget)

   return [AddSubMenu $str $m "" $test "quiet" "" $insert_at]
}
