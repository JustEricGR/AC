# ------------------------------------------------------------------
#                            BatchModeWindowMgr
# ------------------------------------------------------------------
#
# WindowMgr manages frame creation and window creation protocol
#
# ----------------------------------------------------------------------
#            Copyright 2007 Mentor Graphics Corporation
#
# ======================================================================
 
package provide Bmwm 0.1

# Establish namespace for batch-mode version of windowmgr, etc.
namespace eval ::mtiwidgets {
    namespace export *
	set version 0.1
}

#
# Provide a lowercased access method for the windowmgr class.
# 
proc mtiwidgets::batchmodewindowmgr {pathName args} {
    uplevel ::mtiwidgets::BatchModeWindowMgr $pathName $args
}


itcl::class mtiwidgets::BatchModeWindowMgr {

    constructor {args} {}
    destructor {} 
	public method TriggerRegisterWindow { registerwindowcache }  {}
	public method WindowExists			{ window_type {window_data ""}}  {}
	public method GetWindow				{ window_type {window_data ""}} {}
	public method FindWindowObjFromWidget { widget } {}
	public method SetDefaultWindow      { windowobj }
	public method GetDefaultWindow		{ window_type }
	public method GetWindowsByType		{ window_type } {}
	public method GetWindowObjsByType	{ window_type {inuse_only 1}} {}
	public method GetUniqueLabel		{ base_name } {}
	public method GetWindowTypes		{} {}
	public method GetAllVisibleWindows  {} {}
	public method GetAllUndockedWindows {} {}

	public method CreateWindow			{ window_type args } {}
	public method CreateNewWindow		{ window_type } {}

	public method ShowWindow			{ windowobj {force 0}} {}
	public method ShowWindowType		{ window_type }  {}
	public method HideWindow			{ windowobj reason}  {}
	public method WindowVisible			{ window_type {window_data ""}} {return 0}
	public method WindowObjVisible		{ windowobj } {}
	public method AnyWindowVisible		{ window_type } {return 0}
	public method WindowUndocked		{ windowobj } {return 0}
	public method RenameWindow			{ windowobj new_window_data }  {}
		
	public method RegisterWindow		{ windowobj child }  {}
	public method RegisterView          { windowobj child }  {}
	public method GetRegisteredWindows	{ }  {}
	public method GetRegisteredChild	{ window_type {window_data ""}}  {}
	public method GetRegisteredView     { window_type {window_data ""}}  {}
	public method WindowName			{ window_type {window_data ""}}  {}
	public method DumpWindows			{ where type }  {puts $where [array get window_list]}

	private method FindFirstOfType		{ windowobj} {}

	public method UnSerializedNewFrame	{ windowobj } 	 {}
	private method FindOldestWindow		{ windowlist }   {}

	public method ToggleDock			{ windowobj { geometry "" }} {}
	public method ToggleMax				{ windowobj } {}

	public method TogglePaneHeaders		{} {}
	public method PaneHeadersVisible	{} {}
	private method TestForLast			{} {}
	private method NewFrameIndex			{ window_type } {}
	private method NewFrameIndexExists	{ idx} {}

	private method FindUnusedWindow		{ window_type }  {}
	private method FindReusableWindow	{ window_type window_data args}  {}

	private variable window_types   [list] ;# list of valid window types
	private variable window_list           ;# Array of all existing windows, indexed by type
	private variable default_window
	private variable root_window
	private variable all_by_type
	private variable pane_headers_visible 1
	private variable autohide_window_types [list]
	private variable manager_busy 0

}



# ------------------------------------------------------------------
#                        CONSTRUCTOR
# ------------------------------------------------------------------ 
itcl::body mtiwidgets::BatchModeWindowMgr::constructor {args} {
	set root_window .main_pane
}

itcl::body mtiwidgets::BatchModeWindowMgr::destructor {} {
}

itcl::body mtiwidgets::BatchModeWindowMgr::WindowName { window_type {window_data ""}} {
	if { $window_data eq ""} {
		return $window_type
	} 
# 	set windows [GetWindowObjsByType $window_type 0]
# 	foreach windowobj $windows { 
# 		if { [$windowobj cget -window_data] eq $window_data } {
# 			return [$windowobj cget -windowname]
# 		}
# 	}
	return ""
}

itcl::body mtiwidgets::BatchModeWindowMgr::GetWindow { window_type {window_data ""}} {
	set window_name [WindowName $window_type $window_data]
	if { [info exists window_list($window_name)] } {
		return $window_list($window_name) 
	}
	return ""
}

itcl::body mtiwidgets::BatchModeWindowMgr::GetWindowTypes {} {
	return $window_types
}

itcl::body mtiwidgets::BatchModeWindowMgr::CreateWindow { window_type args } {
	lappend window_types $window_type
	set window_types [lsort -dictionary -unique $window_types]
	set winname [NewFrameIndex $window_type]
	set windowobj [mtiwidgets::batchwindowobj $winname]
	set windowobj [namespace which -command $windowobj]
	eval [linsert $args 0 $windowobj configure -windowtype $window_type -windowname $winname]
	lappend window_list($window_type) $windowobj
	SetDefaultWindow $windowobj
	return [namespace which -command $windowobj]
}

itcl::body mtiwidgets::BatchModeWindowMgr::FindReusableWindow  { window_type window_data args}  {
	
}

itcl::body mtiwidgets::BatchModeWindowMgr::NewFrameIndex { window_type } {
	set wname ".$window_type"
	set idx 0
	while {[info commands $wname] ne ""} {
		incr idx
		set wname ".${window_type}${idx}"
	}
	return $wname
}

itcl::body mtiwidgets::BatchModeWindowMgr::SetDefaultWindow { windowobj } {
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

itcl::body mtiwidgets::BatchModeWindowMgr::GetDefaultWindow { window_type } {
	if {[info exists default_window($window_type)]} {
		return $default_window($window_type)
	} elseif {[info exists window_list($window_type)]} {
		foreach w $window_list($window_type) {
			if {[$w cget -windowtype] eq $window_type} {
				SetDefaultWindow $w
				return $w
			}
		}
	}
	return ""
}


# ------------------------------------------------------------------
#                            WindowObj
# ------------------------------------------------------------------
#
# This is a template for creating a window.
#
 

#
# Provide a lowercased access method for the windowmgr class.
# 
proc mtiwidgets::batchwindowobj {pathName args} {
    uplevel ::mtiwidgets::BatchWindowObj $pathName $args
}

itcl::class mtiwidgets::BatchWindowObj {
 
    constructor {args} {}
    destructor {} 
	public method Dock { } 
	public method UnDock { } 
	public method Activate { args } 
	public method Deactivate { args } 
	public method TabLabel {} {return $tab_label}
	public method Title {} {return $title}
	public method UpdateText {}
	public method CreateDockbar {}
	public method GetDockbar {} 
	public method GetMenuBar {} 

	public method GetRegisteredChild { } {return $window }

# -createcommand
#	Create the window contents callback routine - windowobj argument
#	-create command is defined in the baseclass, PaneFrame
#	arguments are windowobj

#	itk_option define -createcommand command Command {}

# -reopencommand
#	An existing window is being reopened and there is work to do
#	to put this window into the proper state.
#   This call is used to update a visible but unused window,
#	as well as a closed window that chooses not destroy its registered child.
#	this callback is not needed by most windows
#	arguments are windowobj, window_data

#	itk_option define -reopencommand reopencommand ReOpenCommand ""

# -closecommand
#	An existing window is being closed and there is work to do
#	this callback is not needed by most windows
#	arguments are windowobj

#	itk_option define -closecommand closecommand CloseCommand ""

#-undockmbcommand
#	Callback for creating the menubar for this window.  This
#	callback is delayed until the window is actually undocked and 
#	it becomes necessary to create the window
#	itk_option define -undockmbcommand undockmbcommand undockmbcommand ""

# -dock/undockcommand
#	Callback notification that the windows dock state is changing
#	arguments are windowobj

#	itk_option define -dockcommand dockcommand DockCommand ""
#	itk_option define -undockcommand undockcommand UnDockCommand ""

# -tab/titlecommand 
#	Callback that returns a custom title/tab text 
#	arguments are windowobj

#	itk_option define -tab_labelcommand tab_labelcommand Tab_LabelCommand ""
#	itk_option define -titlecommand titlecommand TitleCommand ""

# -activatecommand
#	Call that is made when this window is activated
#	arguments are windowobj

#	itk_option define -activatecommand activatecommand ActivateCommand ""

# -deactivatecommand
#	Call that is made when this window is activated
#	arguments are windowobj

#	itk_option define -deactivatecommand deactivatecommand DeactivateCommand ""

# -actioncommand
#	Call that is made when this window is activated
#	arguments are windowobj operation args

#	itk_option define -actioncommand actioncommand ActionCommand ""



#	itk_option define -windowname windowname WindowName ""
#	itk_option define -windowtype windowtype WindowType ""
#	itk_option define -tab_label tab_label Tab_Label ""
#	itk_option define -title title Title ""
#	itk_option define -window_data window_data Window_Data ""
#	itk_option define -type_index type_index Type_Index ""
#	itk_option define -iconimage tabimage TabImage ""
#	itk_option define -window_closing window_closing Window_Closing 0
#	itk_option define -multipleinstances multipleinstances MultipleInstances 0
#	itk_option define -default_focus_window default_focus_window Default_Focus_Window ""

	# Keep these in alphabetical order for convience
	# The order here is the order [$<obj>] configure will display them.
	public variable actioncommand
	public variable activatecommand
	public variable closecommand
	public variable createcommand
	public variable undockmbcommand
	public variable deactivatecommand
	public variable default_focus_window
	public variable defaultwindow
	public variable dockcommand
	public variable iconimage
	public variable multipleinstances
	public variable reopencommand
	public variable tab_label
	public variable tab_labelcommand
	public variable title
	public variable titlecommand
	public variable type_index
	public variable undockcommand
	public variable window
	public variable window_closing
	public variable window_data
	public variable windowname
	public variable windowtype

	public variable actionmanager ""
	public variable windowmanager ""
	public variable panemanager   ""

	public method _trigger_show_cmd {}
	private variable frame_name ""
	private variable dockbar ""
}

itcl::body mtiwidgets::BatchWindowObj::TabLabel {  } {
	if { $tab_label ne "" } {
		return $tab_label
	}
	set tab_label $windowtype
	if {$tab_labelcommand ne ""} {
		if { [info commands [lindex $tab_labelcommand 0]] eq "" } {
			echo Internal Error : WindowObj setting -tab_labelcommand of [lindex $tab_labelcommand 0].  Procedure does not exist.
			return ""
		}
		set tab_label [eval [concat $tab_labelcommand $frame_name]]
	}
	set label [lindex [$::mtiwidgets::BatchModeWindowMgr::windowmgr GetUniqueLabel $tab_label] 0]
	set tab_label $label
	return $tab_label
}

