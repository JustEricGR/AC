
# ------------------------------------------------------------------
#                            WindowObj
# ------------------------------------------------------------------
#
# Provides an instance of a window object.
#
# Author: Ron Wold
# ----------------------------------------------------------------------
#            Copyright 2007 Mentor Graphics Corporation
###############################################################################



#
# Note on window behavior when the layout changes.
# There are two flavors of windows, single instanced and multi instanced.
# By default a single instanced window's visibility will be based upon what 
# is found in the layout.  If the window is visible, it is opened, if it is not 
# visible, it is left hidden.  
# Multi instance windows are slightly different.  By default, their visibility flag
# is ignored when a new layout is opened. 
# If a window needs to remain opened on a layout swap, this should be handled in 
# close window callback for that window.  The "reason" argument will be "layout" -
# meaning the request to close is coming from the layout swap. see the -layoutrestore
# option.


# ------------------------------------------------------------------
#                            WindowObj
# ------------------------------------------------------------------
#
# This is a template for creating a window.
#
 
package require Mtiwidgets 

#
# Provide a lowercased access method for the windowmgr class.
# 
proc mtiwidgets::windowobj {pathName args} {
    uplevel ::mtiwidgets::WindowObj $pathName $args
}

class mtiwidgets::WindowObj {
	inherit ::mtiwidgets::Paneframe
 
    constructor {args} {}
    destructor {} 

	# These call are for storing data on the windowobj
	public method GetData { name } 
	public method SetData { name value } 
	public method DataRef { varName } 
	public method DataExist { varName } 
	public method RemoveData { name } 

	# If a window state changes such that the title has changed
	# this routine will update it.  
	public method UpdateText {}

	# returns either the footer within the client window (when undocked)
	# or the console active window footer (when docked)
	# Creates the appropriate footer if it does not previously exist
	public method GetClientFooter {}

	# retrieves the client body
	public method GetBody {} 

	# tests the windows state 
	public method IsViable {}

	public method GetRegisteredChild { } { return $itk_option(-window) }
	public method GetRegisteredView  { } {
		if {$itk_option(-viewwidget) ne ""} {
			return $itk_option(-viewwidget)
		} else {
			return $itk_option(-window)
		}
	}
	public method WindowClosing		 {} { return $itk_option(-window_closing) }
	public method WindowOpening		 {} { return $itk_option(-window_showing) }
	public method WindowInTransition {} 

# -createcommand
#	Callback in the form of FUNCTION { windowobj }
#
#   The create command provides the window an opportunity to construct
#   it contents.  The windowobj passed in may or may not have data stored in the -window_data
#   field.  If it does, the window should use this information as basis for constructing a window
#
#   The return value can be one of the following:
#		return -code error "message"
#			This will return an error up the call stack.
#		return 0
#			This informs the windowmgr that the window was not constructed
#			but that the situation is not an error
#		return anything else or nothing implies the window has been constructed
	itk_option define -createcommand command Command {}

# -reopencommand
#	Callback in the form of FUNCTION { windowobj }
#	An existing window is being reopened and there is work to do
#	to put this window into the proper state.
#   This call is used to update a visible but unused window,
#	as well as a closed window that chooses not destroy its registered child.
#	this callback is not needed by most windows

	itk_option define -reopencommand reopencommand ReOpenCommand ""

# -closecommand
#	Callback in the form of FUNCTION { windowobj {reason user} }
#	An existing window is being closed and this callback was installed because
#   they may be work to do.  
#
#   The close command can originate several ways.  The window may or
#   may not comply with the close, depending on the desired behavior
#   Valid reason are:
#   Valid reasons are:
#			loadsim - a simulation has been loaded causing a layout change.
#			quitsim - a simulation has been unloaded causing a layout change
#			layout  - the user has issued an explicit layout change
#			user	- the user has explicity closed the window
#			exit    - the tool is shutting down
#			error   - the create call returned an error 
#			clear   - the users has requested all layouts be deleted/cleared
#	Return value of 0 implies that the window could not be closed
#   any other return value implies that the close was successful.
	itk_option define -closecommand closecommand CloseCommand ""

# -dock/undockcommand
#	Callback in the form of FUNCTION { windowobj }
#	Callback notification that the windows dock state is changing
#	arguments are windowobj

	itk_option define -dockcommand dockcommand DockCommand ""
	itk_option define -undockcommand undockcommand UnDockCommand ""

# -tab/titlecommand 
#	Callback in the form of FUNCTION { windowobj }
#	Callback that returns a custom title/tab text 
#	arguments are windowobj

	itk_option define -tab_labelcommand tab_labelcommand Tab_LabelCommand ""
	itk_option define -titlecommand titlecommand TitleCommand ""

# -activatecommand
#	Callback in the form of FUNCTION { windowobj }
#	Call that is made when this window is activated
#	arguments are windowobj

	itk_option define -activatecommand activatecommand ActivateCommand ""

# -deactivatecommand
#	Callback in the form of FUNCTION { windowobj }
#	Call that is made when this window is activated
#	arguments are windowobj

	itk_option define -deactivatecommand deactivatecommand DeactivateCommand ""

# -actioncommand
#	Callback in the form of FUNCTION { windowobj operation args  }
#	Call that is made when this window is activated
#	arguments are windowobj operation args

	itk_option define -actioncommand actioncommand ActionCommand ""

#-undockmbcommand
#	Callback in the form of FUNCTION { windowobj menubar }
#	Callback for adding menus to the menubar for this window and
#   occurs when undocking the window
	itk_option define -undockmbcommand undockmbcommand UndockmbCommand ""
 
#-undocktbcommand
#	Callback in the form of FUNCTION { windowobj toolbar }
#	Callback for adding toolbars to the toolbar and
#   occurs when undocking the window
	itk_option define -undocktbcommand undocktbcommand UndocktbCommand ""

#-createfootercommand
#	Callback in the form of FUNCTION { windowobj clientfooter }
#	Callback for adding window specific footers and
#   occurs when undocking the window
	itk_option define -createfootercommand createfootercommand CreateFooterCommand ""

#-createconsolefooter
# Flag to indicate if window footer should be displayed in the console footer when
# window is docked. The footer will be created via calling the window's createfootercommand
# defined above.
	itk_option define -createconsolefooter createconsolefooter CreateConsoleFooter 0

	itk_option define -windowname windowname WindowName ""
	itk_option define -windowtype windowtype WindowType ""
	itk_option define -tab_label tab_label Tab_Label ""
	itk_option define -window_data window_data Window_Data ""
	itk_option define -iconimage iconimage IconImage ""
	itk_option define -multipleinstances multipleinstances MultipleInstances 0
	itk_option define -createoptions createoptions CreateOptions ""
	# determines whether the windows icons should be displayed in the header
	itk_option define -showheadericon showheadericon ShowHeaderIcon 1

	# determines whether this window should remain visible in the new layout.
	# a value of 0 implies the window should remain open after a loadlayout
	itk_option define -layoutvisibility layoutvisibility LayoutVisibility 1


	# determines if a window should be opened on a layout change, given that it is designated
	# visible in the new layout.  By default single instance windows will be opened and
	# multiple instance windows will not be opened.  Setting the value to 0 states that this
	# window should not be opened on a layout change and setting it to 1 says that it 
	# should be opened on a layout change.
	itk_option define -layoutrestore layoutrestore LayoutRestore -1

	# references the window type to place this window with upon creation
	# if the window is found in the layout, the layout's location will be used
	# if it is not found, then this options gives some control over where it should 
	# be placed.
	# this option is used by externally registered windows 
	itk_option define -layoutlocation layoutlocation LayoutLocation ""


	# the calls below are not intended for public consumption


	itk_option define -title title Title ""
	# indicates a user request for a specific title (ie view -title foo wave)
	itk_option define -usertitle usertitle UserTitle ""
	itk_option define -type_index type_index Type_Index ""
	itk_option define -window_closing window_closing Window_Closing 0
	itk_option define -window_showing window_showing Window_Showing 0
	itk_option define -defaultwindow defaultwindow DefaultWindow 0
	itk_option define -default_focus_window default_focus_window Default_Focus_Window ""

	itk_option define -actionmanager actionmanager ActionManager "mtiwidgets::mgr_undefinedAction"
	itk_option define -windowmanager windowmanager WindowManager "mtiwidgets::mgr_undefinedWindow"
	itk_option define -serializing serializing Serializing 0
	itk_option define -defaultlabel defaultlabel Defaultlabel ""
	itk_option define -tab_labelinit tab_labelinit Tab_LabelInit 0

	# Holds widget pathname returned by [view] command
	itk_option define -viewwidget viewWidget ViewWidget {}

	# Preference variable: the variable name of the preference array for this window kind
	itk_option define -preferencevar preferenceVar PreferenceVar {}

	public method Dock {} 
	public method UnDock {} 
	public method WindowUnDocked {} 
	public method SetMaxButtonIcon {} 
	
	public method _Dock { } 
	public method _UnDock { } 
	public method Activate { args } 
	public method Deactivate { args } 
	public method TabLabel {}
	public method Title {}
	public method GetToolbar {} 
	public method GetMenuBar {} 
	public method PageSelected {} 
	public method TestForCallBack {callback} 
	public method TestCallBacks {}

	public method _trigger_show_cmd {}
	protected method MakeResizeCorner {}
	protected method CreateToolbar {}
	protected method CreateFooter {} 
	public method AddHeaderIcon {} 
	public method RemoveHeaderIcon {} 
	public method Reset {} 
	public	method _hidecommand_ {}
	public method DumpAll { where }
	public method DumpData { where } 
	public method FrameName { } { return $frame_name }
	public method SetUndockGeom { geom } 
	public method GetUndockGeom {}  { return $undocked_geom }
	public method SetUndockGeomHistory { geom }  
	public method GetUndockGeomHistory {}  { return $undocked_geom_history }
	public method _dump_queue { } 

	private method GetFooter {}  
	private method GetConsoleFooter {}  

	private variable frame_name ""
	private variable headericon ""
	private variable toolbar ""
	private variable footer ""
	private variable body ""
	private variable clientfooter ""
	private variable consolefooter ""	;# footer in console window when docked
	private variable data_array
	private variable labelsuffix ""
	private variable callbackstested 0
	private variable undocked_geom ""
	private variable undocked_geom_history ""
	private variable update_id 0
	common busy 0
	common activate_in_progress 0
	common show_queue [list]
	private variable callbacks [list	-createcommand \
										-reopencommand \
										-closecommand  \
										-dockcommand \
										-undockcommand \
										-tab_labelcommand \
										-titlecommand \
										-activatecommand \
										-deactivatecommand \
										-actioncommand \
										-undockmbcommand \
										-undocktbcommand \
										-createfootercommand ]
}

#bind WindowObj <FocusIn> {%W Activate}
trace variable mtiwidgets::WindowObj::busy w WobjUpdate

proc WobjUpdate {args } {
	if { $mtiwidgets::WindowObj::busy == 0 } {
		if { [llength $mtiwidgets::WindowObj::show_queue] > 0 } {
			[lindex $mtiwidgets::WindowObj::show_queue 0] _trigger_show_cmd
		}
	}	
}

proc WobjActivateInProgress {} {
	return $mtiwidgets::WindowObj::activate_in_progress
}

configbody mtiwidgets::WindowObj::window_data {
	# Add to window mgr's tables for faster lookups
	$itk_option(-windowmanager) RegisterData $itk_component(hull) $itk_option(-window_data)
}

configbody mtiwidgets::WindowObj::window_closing {
	set ix [lsearch -exact $show_queue $frame_name] 
	if { $ix > 0 } {
		lremove show_queue $ix
	}
}

body mtiwidgets::WindowObj::constructor {args} {
	set frame_name [string trimleft $this :]
	if {[catch {eval itk_initialize $args} err]} {
		puts stderr ">>$::errorInfo"
		error $err
	}
	if { $itk_option(-windowname) eq "" } {
		configure -windowname $itk_option(-windowtype)
	}
	set cs [childsite]
	set body [frame $cs.body -class Treetop]
	grid $body -row 1 -sticky nsew
	grid columnconfigure $cs 0 -weight 1
	grid rowconfigure $cs 1 -weight 1
	configure -defaultlabel $itk_option(-tab_label)
	if { $itk_option(-tab_labelcommand) eq "" } {
		if {$itk_option(-tab_label) eq "" } { 
			CallTrace echo
			echo Internal Error : window type $itk_option(-windowtype) must define either a -tab_labelcommand callback or provide the -tab_label value
		}
	} else { 
		TabLabel
	}
	bind $frame_name			<<PageSelected>> [code $this PageSelected]
	return $frame_name
}

body mtiwidgets::WindowObj::destructor {} {
}


body mtiwidgets::WindowObj::GetData { name } {
	if { [info exists data_array($name)] } {
		return $data_array($name)
	} 
	return ""
}
 
body mtiwidgets::WindowObj::SetData { name value } {
	set data_array($name) $value
}

body mtiwidgets::WindowObj::DataRef { varName } {
	if { ![info exists data_array($varName)] } {
		set data_array($varName) ""
	}
	return [itcl::scope data_array($varName)]
}

body mtiwidgets::WindowObj::DataExist { varName } {
	if { [info exists data_array($varName)] } {
		return 1
	}
	return 0
}

body mtiwidgets::WindowObj::Reset { } {
	configure -window ""	
	configure -window_data ""
   array unset data_array
}


body mtiwidgets::WindowObj::DumpData { where  } {
	set datanames [array names data_array]
	foreach name $datanames {
		if { $where } {
			puts stderr "Name  : $name"
			puts stderr "Value : $data_array($name)"
		} else {
			echo Name  : $name 
			echo Value : $data_array($name)
		}
    }
}

body mtiwidgets::WindowObj::DumpAll { where } {
	if { !$where  } {
		echo frame name $frame_name
		echo windowtype [cget -windowtype]
		echo windowname [cget -windowname]
		echo windowdata  [cget -window_data]
		echo index [cget -type_index]
		echo title [ cget -title]
		echo usertitle [ cget -usertitle]
		echo titlecommand [ cget -titlecommand]
		echo tablabel [ cget -tab_label]
		echo tab_labelcommand [ cget -tab_labelcommand]
		echo createcommand  [ cget -createcommand]
		echo reopencommand [ cget -reopencommand]
		echo dockcommand [ cget -dockcommand]
		echo undockcommand [ cget -undockcommand]
		echo activatecommand [cget -activatecommand]
		echo deactivatecommand [cget -deactivatecommand]
		echo closecommand  [ cget -closecommand]
		echo actioncmd [ cget -actioncommand]
		echo undockmbcommand [ cget -undockmbcommand]
		echo undocktbcommand [ cget -undocktbcommand]
		echo createfootercommand [ cget -createfootercommand]
		echo createconsolefooter [ cget -createconsolefooter]
		echo iconimage [ cget -iconimage]
		echo multipleinstances [ cget -multipleinstances]
		echo default_focus_window [ cget -default_focus_window]
		echo layoutlocation [ cget -layoutlocation]
		echo layoutrestore [ cget -layoutrestore]
		echo registered child [cget -window]
		DumpData $where
	} else { 
		puts stderr "frame name $frame_name"
		puts stderr "windowtype [cget -windowtype]"
		puts stderr "windowname [cget -windowname]"
		puts stderr "windowdata [cget -window_data]"
		puts stderr "index [cget -type_index]"
		puts stderr "title [cget -title]"
		puts stderr "usertitle [cget -usertitle]"
		puts stderr "titlecommand [cget -titlecommand]"
		puts stderr "tablabel [cget -tab_label]"
		puts stderr "tab_labelcommand [cget -tab_labelcommand]"
		puts stderr "createcommand  [cget -createcommand]"
		puts stderr "reopencommand [cget -reopencommand]"
		puts stderr "dockcommand [cget -dockcommand]"
		puts stderr "undockcommand [cget -undockcommand]"
		puts stderr "activatecommand [cget -activatecommand]"
		puts stderr "deactivatecommand [cget -deactivatecommand]"
		puts stderr "closecommand  [cget -closecommand]"
		puts stderr "actioncmd [cget -actioncommand]"
		puts stderr "undockmbcommand [cget -undockmbcommand]"
		puts stderr "undocktbcommand [cget -undocktbcommand]"
		puts stderr "createfootercommand [cget -createfootercommand]"
		puts stderr "createconsolefooter [cget -createconsolefooter]"
		puts stderr "iconimage [cget -iconimage]"
		puts stderr "multipleinstances [cget -multipleinstances]"
		puts stderr "default_focus_window [cget -default_focus_window]"
		puts stderr "layoutlocation [cget -layoutlocation]"
		puts stderr "layoutrestore [cget -layoutrestore]"
		puts stderr "registered child [cget -window]"
		DumpData $where
	}
}

body mtiwidgets::WindowObj::RemoveData { name } {
	unset data_array($name) 
}

body mtiwidgets::WindowObj::GetMenuBar { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if {[winfo exists $frame_name.mBar]} {
		return $frame_name.mBar
	} 
	set mbar [menu $frame_name.mBar]
	$frame_name configure -menu $mbar
	return $mbar
}


body mtiwidgets::WindowObj::Dock { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { [$itk_option(-windowmanager) WindowUndocked $frame_name] } { 
		$itk_option(-windowmanager) ToggleDock $frame_name
	}
}

body mtiwidgets::WindowObj::UnDock { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { ![$itk_option(-windowmanager) WindowUndocked $frame_name] } { 
		$itk_option(-windowmanager) ToggleDock $frame_name
	}
}

body mtiwidgets::WindowObj::SetUndockGeom { geom } {
	set undocked_geom $geom
	set undocked_geom_history $geom
}


body mtiwidgets::WindowObj::SetUndockGeomHistory { geom } {
	set undocked_geom_history $geom
}


body mtiwidgets::WindowObj::WindowUnDocked { } {
	return [$itk_option(-windowmanager) WindowUndocked $frame_name] 
}

body mtiwidgets::WindowObj::_Dock { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	grid forget [GetToolbar]
	grid forget [GetFooter]
	if {$itk_option(-dockcommand) != ""} {
 		eval $itk_option(-dockcommand) $frame_name
    } 

	# Create the Console Footer and activate it
	set consolefooter [GetConsoleFooter]
	if {$consolefooter eq ""} {
		if {($itk_option(-createfootercommand) != "") && ($itk_option(-createconsolefooter) != 0)} {
			set consolefooter [Console::CreateWindowFooter [$frame_name cget -windowname]]
			eval $itk_option(-createfootercommand) $frame_name $consolefooter
		}
	}
	if {$consolefooter ne ""} {
		Console::activateWindowFooter [$frame_name cget -windowname]
	} else {
		Console::displayDefaultWindowFooter
	}

	$itk_option(-actionmanager) Activate $frame_name
	UpdateText
}




body mtiwidgets::WindowObj::_UnDock { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	# First Create the MenuBar 
	if {![winfo exists $frame_name.mBar]} {
		set menu_bar [GetMenuBar]
		if {$itk_option(-undockmbcommand) == ""} {
			set file_menu [AddMenu file $menu_bar ""  F]
			AddMenuItem "Close Window"		$file_menu  "$itk_option(-actionmanager) Action close_window"  can_close_window  C
			AddWindowMenu $menu_bar
		} else { 
			eval $itk_option(-undockmbcommand) $frame_name $menu_bar
		}
	}

	# Next Create the Toolbar
	set toolbar [GetToolbar]
	if {$toolbar eq ""} {
		set toolbar [CreateToolbar]
		if {$itk_option(-undocktbcommand) == ""} {
			Tbar::StandardToolbarInit	$toolbar
		} else { 
			eval $itk_option(-undocktbcommand) $frame_name $toolbar
		}
	} 

	# Next Create the Footer
	set footer [GetFooter]
	if {$footer eq ""} {
		set footer [CreateFooter]
		if {$itk_option(-createfootercommand) != ""} {
			eval $itk_option(-createfootercommand) $frame_name $clientfooter
		}
	}


	# information on the icon setting.  iconphoto is a tcl 8.5 feature that supports colorized
	# icons.  Some older windowing systems do not provide support for it.
	# On all systems but windows, using iconbitmap and then followed with iconphoto has no negative
	# effects, if it supports iconphoto its used, if it isn't supported the iconbitmap does the work
	# However, on windows, apply both commands will cause the icon to display improperly.
	if {$::tcl_platform(platform) ne "windows" } {
		wm iconbitmap $frame_name [wm iconbitmap .] ;#$::vsimPriv(defaultIconbitmap)
	}

	if { $itk_option(-iconimage) ne "" } {
		wm iconphoto $frame_name $itk_option(-iconimage)
	}

	if { [winfo manager $toolbar] eq "" } { 
		grid $toolbar -row 0 -sticky nwe 
	}
	if { [winfo manager $footer] eq "" } {
		grid $footer  -row 2 -stick swe
	}

	if {$itk_option(-undockcommand) != ""} {
		eval $itk_option(-undockcommand) $frame_name
    }
	
	# deactivate window specific footer mechanism in console window
	set consolefooter [GetConsoleFooter]
	if {$consolefooter ne ""} {
		Console::deactivateWindowFooter [$frame_name cget -windowname]
	}

	$itk_option(-actionmanager) Activate $frame_name
	UpdateToolbars 
 	UpdateText


	set width [winfo width $frame_name]
	set height [winfo height $frame_name]
	set adjust 0
	if { $width < 250 } {
		set width 250
		set adjust 1
	}
	if { $height < 250 } { 
		set height 250
		set adjust 1
	}
	if { $adjust } {
		set geometry [format %dx%d $width $height]
		after idle "$itk_option(-panemanager)  _adjustGeometry $frame_name $geometry"
	}


	##
	## Look for user hook callbacks and execute them
	##
	# Do NOT put anything after this line.  The code below to evaluate user_hooks
	# could directly or indirectly depend on any and all actions taken in this proc.
	# Placing any definitions after this code could result in bad behavior or failure.
	if {$itk_option(-preferencevar) eq ""} {
		set pvar "::Pref[string totitle $itk_option(-windowtype)]"
	} else {
		set pvar "::$itk_option(-preferencevar)"
	}
	if {[info exists ${pvar}(user_hook)]} {
		set user_hook [set ${pvar}(user_hook)]
		if {[llength $user_hook] > 0} {
			set winname [GetRegisteredView]
			foreach p $user_hook {
				if {[catch {eval [concat $p $winname]} errmsg]} {
					mti_error_message "Errors generated by [string totitle $itk_option(-windowtype)] window user hook $p: $errmsg\n"
				}
			}
		}
	}

}


body mtiwidgets::WindowObj::PageSelected {} { 
	if { $itk_option(-window) eq "" } {
		return
	}
	if { ![winfo ismapped $itk_option(-window)] } {
		grid [GetBody] -row 1 -sticky nsew
	}
	focus $itk_option(-window)
	UpdateToolbars
}


body mtiwidgets::WindowObj::Activate { args } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { $itk_option(-window_closing) } {
		return
	}

	incr activate_in_progress
	$itk_option(-windowmanager) SetDefaultWindow $frame_name
	chain
	if {[winfo exists $headericon]} {
		$headericon configure -background $itk_option(-activebackground)
	}
	if {$itk_option(-activatecommand) != ""} {
		eval $itk_option(-activatecommand) $frame_name
	} 
	# if window is activated and docked, activate the footer in the console
	if {![$itk_option(-windowmanager) WindowUndocked $frame_name] } {
		set consolefooter [GetConsoleFooter]
		if {$consolefooter eq ""} {
			if {($itk_option(-createfootercommand) != "") && ($itk_option(-createconsolefooter) != 0)} {
				set consolefooter [Console::CreateWindowFooter [$frame_name cget -windowname]]
				eval $itk_option(-createfootercommand) $frame_name $consolefooter
			}
		}
		if {$consolefooter ne ""} {
			Console::activateWindowFooter [$frame_name cget -windowname]
		} else {
			Console::displayDefaultWindowFooter
		}
	}
	SetMaxButtonIcon
	incr activate_in_progress -1
}

body mtiwidgets::WindowObj::Deactivate { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { [WindowInTransition]} {
		return 
	}
	chain
	if {[winfo exists $headericon]} {
		$headericon configure -background $itk_option(-background)
	}
	if {$itk_option(-deactivatecommand) != ""} {
		eval $itk_option(-deactivatecommand) $frame_name
	}
	set consolefooter [GetConsoleFooter]
	if {$consolefooter ne ""} {
		Console::deactivateWindowFooter [$frame_name cget -windowname]
	}
}


#	The window obj class over loads the trigger_show_cmd which is also found
#   on a PaneFrame.
#	Trigger show occurs when the Pane Frame (the windowobj) is Mapped
#   The mapping will occur when the pane frame is added, an operation that 
#   happens when a new layout is loaded.
#	So, if this call occurs, the Pane Frame is already visible.
#	If it fails, it must be removed.
#	Be careful with this call... it the trigger is tied to the <MAP> event,
#   which can get called in various ways, such as the first view or when dragging.
itcl::body mtiwidgets::WindowObj::_dump_queue {} {
	puts stderr "$frame_name queue is $show_queue"
	echo busy is $busy
}

itcl::body mtiwidgets::WindowObj::_trigger_show_cmd {} {
	if { [$itk_option(-windowmanager) LayoutClosing] } {
		return
	}
	if { [WindowInTransition] } {
		return
	}

	if {[lsearch -exact $show_queue $frame_name]  < 0 } {
		lappend show_queue $frame_name
	}

	if { $busy } { 
		return
	}
	set busy 1
	while {[llength $show_queue] > 0} {
		set wobj [lindex $show_queue 0]
		lremove show_queue 0
		catch {$itk_option(-windowmanager) ShowWindow $wobj} results
		set geom [$wobj GetUndockGeom]
		if { $geom != "" } {
			$wobj SetUndockGeom ""
			$itk_option(-windowmanager) UnDock $wobj $geom 1
			set undocked_geom ""
		} 			
	}
	set busy 0
}


body mtiwidgets::WindowObj::TabLabel {  } { 
	# note tab labels must be unique across the world
	# thus, a window implementation cannot set the value itself
	# when its initialized the windowobj returns what it would like the label
	# to be.  It must then ask the windowmgr to guarantee uniqueness.  
	# once the value is set, it shouldn't be changed anywhere except by the
	# windowmgrs renamewindow operation.  The renamewindow will set the string
	# to empty, and then call for a new label which will be verified for uniqueness.
	configure -tab_labelinit 1
	if {$itk_option(-tab_labelcommand) ne ""} {
		if { [GetRegisteredChild] eq "" } {
			set tab_label $itk_option(-windowtype)
		} else { 
			set tab_label [eval $itk_option(-tab_labelcommand) $frame_name]
			if {$itk_option(-tab_label) eq "" && $itk_option(-tab_labelcommand) eq "" } {
				echo Internal Error : procedure $itk_option(-tab_labelcommand) failed to return a valid tab label string
				set tab_label  $itk_option(-windowtype)
			}
		}
	} else {
		set tab_label $itk_option(-defaultlabel)
		if { $itk_option(-usertitle) != "" } {
			set tab_label $itk_option(-usertitle)
		}
		if { $tab_label == "" } {
			echo Internal Error : unable to determine tab label string
			set tab_label $itk_option(-windowtype)
		}
	}
	set unique_label [$itk_option(-windowmanager) GetUniqueLabel $frame_name $tab_label]

	if { $unique_label eq $itk_option(-tab_label) } { 
		return $itk_option(-tab_label)
	}

	configure -tab_label $unique_label
	return $unique_label
}

configbody mtiwidgets::WindowObj::tab_label {
	if { $itk_option(-tab_label) eq "" } {
		return
	}
	$itk_option(-panemanager) rename $frame_name
}

body mtiwidgets::WindowObj::Title {  } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { $itk_option(-usertitle) != "" } {
		configure -title $itk_option(-usertitle)
	} else {
		if {$itk_option(-titlecommand) ne ""} {
			configure -title [eval $itk_option(-titlecommand) $frame_name]
		} else { 
			if { [cget -title] eq "" } {
				configure -title $itk_option(-tab_label)
			}
		}
	}
	if { [wm toplevel $frame_name] } {
		wm title $frame_name $itk_option(-title)
	} 
	configure -text $itk_option(-title)
}

configbody mtiwidgets::WindowObj::usertitle {
	# if the usertitle is changed, we need to go through the process of recalculating the tab/title
	$itk_option(-windowmanager)	RenameWindow $frame_name $itk_option(-window_data) $itk_option(-usertitle)
}


body mtiwidgets::WindowObj::UpdateText {} {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	if { [WindowClosing] } {
		return
	}
	TabLabel
	Title
}


body mtiwidgets::WindowObj::GetBody { } {
	return $body
}

body mtiwidgets::WindowObj::IsViable { } {
	if { [winfo exists $frame_name] && [winfo ismapped $frame_name] } {
		set child [GetRegisteredChild] 
		if { $child ne "" && [winfo exists $child] && [winfo ismapped $child]} {
			return 1
		}
	}
	return 0
}


body mtiwidgets::WindowObj::CreateToolbar { } {
	if { [GetRegisteredChild] eq "" } {
		return
	}
	set toolbar [mtiwidgets::Dockbar [$frame_name childsite].controls -relief sunken -borderwidth 1]
	set prop $itk_option(-windowtype) 
	append prop _db_
	$toolbar configure -propertycommand mtiPropertyCmd -propertyprefix $prop
	$toolbar configure -updatecommand UpdateToolbars
	return $toolbar	

}

body mtiwidgets::WindowObj::GetToolbar { } {
	return $toolbar
}

body mtiwidgets::WindowObj::CreateFooter { } {
	if { [GetRegisteredChild] eq "" } {
		return ""
	}
	set footer [frame [$frame_name childsite].footer]
	set clientfooter [frame [$frame_name childsite].footer.clientfooter]
	MakeResizeCorner
	pack [$frame_name childsite].footer.clientfooter -side left -anchor s -fill x -expand true
	pack [$frame_name childsite].footer.corner -side right -anchor s -fill none -expand false
	return $footer
}

body mtiwidgets::WindowObj::GetFooter { } {
	if { ![winfo exists $footer] } { 
		set footer ""
	}
	return $footer
}

body mtiwidgets::WindowObj::GetConsoleFooter { } {
	if { ![winfo exists $consolefooter] } { 
		set consolefooter ""
	}
	return $consolefooter
}

# return either the footer within the client window (when undocked)
# or the console active window footer (when docked)
# Creates the appropriate footer if it does not previously exist
body mtiwidgets::WindowObj::GetClientFooter { } {
	if { [$itk_option(-windowmanager) WindowUndocked $frame_name] } { 
		if { ![winfo exists $clientfooter] } {
			set clientfooter ""
		}
		set footer [GetFooter]
		if {$footer eq ""} {
			set footer [CreateFooter]
			if {$footer eq ""} {
				return ""
			}
			if {$itk_option(-createfootercommand) != ""} {
				eval $itk_option(-createfootercommand) $frame_name $clientfooter
			}
		}
		return $clientfooter
	} else {
		if { ![winfo exists $consolefooter] } { 
			set consolefooter ""
		}
		if {$consolefooter eq ""} {
			if {($itk_option(-createfootercommand) != "") && ($itk_option(-createconsolefooter) != 0)} {
				set consolefooter [Console::CreateWindowFooter [$frame_name cget -windowname]]
				eval $itk_option(-createfootercommand) $frame_name $consolefooter
			}
		}
		return $consolefooter
	}
}


body mtiwidgets::WindowObj::MakeResizeCorner { } {
	global tcl_platform
	canvas $footer.corner -width 14 -height 14
	if {$tcl_platform(platform) == "windows"} {
		set cursor size_nw_se
		set colorD System3dDarkShadow
		set colorL System3dLight
	} else {
		set shadows [Get3DColors [$footer.corner cget -background]]
		set cursor bottom_right_corner
		set colorD [lindex $shadows 0]
		set colorL [lindex $shadows 1]
	}
	$footer.corner  configure -cursor $cursor -takefocus 0 \
		-highlightthickness 1 \
		-highlightcolor [$footer.corner cget -background] \
		-highlightbackground [$footer.corner cget -background]
	$footer.corner  create line 15 4 4 15 -fill $colorL -width 1
	$footer.corner  create line 15 5 5 15 -fill $colorD -width 1
	$footer.corner  create line 15 8 8 15 -fill $colorL -width 1
	$footer.corner  create line 15 9 9 15 -fill $colorD -width 1
	$footer.corner  create line 15 12 12 15 -fill $colorL -width 1
	$footer.corner  create line 15 13 13 15 -fill $colorD -width 1
	$footer.corner  addtag resize all
	$footer.corner  create polygon 0 0 0 15 15 0 -fill [$footer.corner  cget -bg]
	$footer.corner  addtag move closest 0 0
	$footer.corner  bind resize <1> { mti_WindowResizeStart %W %X %Y }
	$footer.corner  bind resize <B1-Motion> { mti_WindowResizeDrag %W %X %Y }
	$footer.corner  bind move <1> { mti_WindowMoveStart %W %X %Y 1 }
	$footer.corner  bind move <Enter> "%W configure -cursor fleur"
	$footer.corner  bind move <Leave> "%W configure -cursor $cursor"
	$footer.corner  bind move <B1-Motion> { mti_WindowMoveDrag %W %X %Y 1 }
	bind $footer.corner  <1> { # Disable general move binding }
	return $footer.corner 
}

# these two routines test the validity of registered callbacks.
# this will help prevent a windowmgr crash due to an incorrectly
# registered window.

body mtiwidgets::WindowObj::TestForCallBack {callback} {
	set failure 0
	set call $itk_option($callback)
	if { $call ne "" } {
		if { [info commands $call] eq "" } {
			global auto_index
			if { ![info exists auto_index($call)] &&
				 ![info exists auto_index(::$call)] } {
				# might be an itk class function
				if { [llength $call] > 3 } {
					if { [lindex $call 0] eq "namespace" } {
						set func_list [lindex $call 3]
						set the_instance [lindex $func_list 0]
						set the_func [lindex $func_list 1]
						if {![catch {eval $the_instance info function $the_func} err]} {
							return 0
						}

					}
				}
				append msg Internal Error : WindowObj
				append msg "Error with window registration.  Window $frame_name. \n"
				append msg "The callback \"$callback\" references function \"$call\" \n"
				append msg "which does not exist.\n"
				mti_error_message $msg
				return 1
			}
		}
	}
	return 0
}

body mtiwidgets::WindowObj::TestCallBacks {} {
	if { $callbackstested } {
		return
	}
	set failure 0
	set callbackstested 1
	foreach callback $callbacks {
		if { [TestForCallBack $callback] } {
			set failure 1
		}
	}
	return $failure
}


body mtiwidgets::WindowObj::AddHeaderIcon {} {
	if { $itk_option(-iconimage) eq "" } {
		return
	}
	if { ![winfo exists $headericon] } {

      # tell base class to add the icon
      set headericon [_set_icon $itk_option(-iconimage)]
	}
}


body mtiwidgets::WindowObj::RemoveHeaderIcon {} {
	if { ![winfo exists $headericon] } {
		return
	}
	destroy $headericon
}

configbody mtiwidgets::WindowObj::showheadericon {
	if { $itk_option(-showheadericon) } {
		AddHeaderIcon
	} else {
		RemoveHeaderIcon
	}
}

configbody mtiwidgets::WindowObj::iconimage {
	if { $itk_option(-showheadericon) } {
		RemoveHeaderIcon
		AddHeaderIcon
	} 
	$itk_option(-panemanager) updatetabs $frame_name
}


body mtiwidgets::WindowObj::_hidecommand_ {} {
#	if {$itk_option(-hidecommand) ne ""} {
#		$itk_option(-panemanager) normal
#		after 20 $itk_option(-hidecommand)
#	}
#	catch {[$itk_option(panemanager) FocusPrev $itk_component(hull)] Activate}
	$itk_option(-windowmanager) HideWindow $frame_name user

}

body mtiwidgets::WindowObj::WindowInTransition {} {
	if { $itk_option(-window_closing) || $itk_option(-window_showing) } {
		return 1
	} 
	return 0
}

body mtiwidgets::WindowObj::SetMaxButtonIcon {} {
	if { [$itk_option(-windowmanager) MaximizedMode] } { 
		eval [linsert [GetButtonIcon minus] 0 component maxbutton configure]
	} else {
		eval [linsert [GetButtonIcon plus] 0 component maxbutton configure]
	}
}

	 
