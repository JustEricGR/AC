# mgc_style.tcl --
#
#	This file implements package MGC::style, which defines a set of
#	colors, fonts, and icons
#

package require Img

# The Mtiwidgets package is required for its 3DborderColor function
package require Mtiwidgets

namespace eval MGC::style {
#    variable PrefDefault
    variable IconPath
    set IconPath [list]

}; # end of namespace as::style

proc MGC::style::init {args} {
    MGC::style::init_fonts
    MGC::style::init_defaults
    MGC::style::init_icons
}

proc MGC::style::ColorDist {c1 c2} {
	# This is a mathmatical distance and does not
	# represent the visual intensity difference between
	# the two colors.  But this is close enough as an
	# approximation.
	scan [winfo rgb . $c1] "%d %d %d" r1 g1 b1
	scan [winfo rgb . $c2] "%d %d %d" r2 g2 b2

	set r [expr {double($r1 - $r2)}]
	set g [expr {double($g1 - $g2)}]
	set b [expr {double($b1 - $b2)}]
	set rsq [expr {$r * $r}]
	set gsq [expr {$g * $g}]
	set bsq [expr {$b * $b}]

	set dist [expr {sqrt($rsq + $gsq + $bsq)}]
}

proc MGC::style::add_to_icon_path {args} {
    variable IconPath
    set IconPath [concat $IconPath $args]
}

proc MGC::style::get_icon {icon {prefix -image}} {
    variable IconPath

    if { $icon == "_undobm" || \
	 $icon == "_redobm" } {
        lappend prefix $icon
        return $prefix
    }

    set icon_name _${icon}_icon
    if {[lsearch -exact [image names] _${icon_name}] != -1} {
        lappend prefix _${icon_name}
        return $prefix
    }
    foreach dir $IconPath {
        foreach ext {png gif bmp ico dib xpm xbm} {
            set f [file join $dir ${icon}.${ext}]
            if {[file exists $f]} {
                set img [image create photo _${icon_name} -format $ext -file $f]
                lappend prefix $img
                return $prefix
            }
        }
    }
    return ""
}

proc MGC::style::init_icons {args} {
    set expel [get_icon expel ""]
    option add *iconExpelBtnExpel $expel
    option add *expelImage        $expel
    option add *iconCloseBtn      [get_icon closex ""]
    option add *iconExpelBtnJoin  [get_icon join ""]
    option add *iconMaxBtnPlus    [get_icon plus ""]
    option add *iconMaxBtnMin     [get_icon minus ""]
    option add *plusimage	  [get_icon plus3dsmall ""]
    option add *minusimage	  [get_icon minus3dsmall ""]
}

## Fonts
##
proc MGC::style::init_fonts {args} {
    global PrefDefault

    if {[lsearch -exact [font names] menuFont] < 0} {
	set cmd create
    } else {
	set cmd configure
    }

    set defaultVFont [DefaultVariableFont]
    set defaultFFont [DefaultFixedFont]

    # Initialize variable width fonts.  Use preferences settings if present.
    set fontlist {menuFont footerFont treeFont}
    foreach vfont $fontlist {
	if {[info exists PrefDefault($vfont)] &&
	    [lsearch $fontlist $PrefDefault($vfont)] < 0} {
	    set font $PrefDefault($vfont)
	} else {
	    set font $defaultVFont
	}
	array set data [font actual $font]
	set sz  $data(-size)
	set fam $data(-family)
	set wgt $data(-weight)
	set sl  $data(-slant)
	set ul  $data(-underline)
	set os  $data(-overstrike)
	font $cmd ${vfont}     -size $sz -family $fam -weight $wgt -underline $ul -overstrike $os
	font $cmd ${vfont}Bold -size $sz -family $fam -weight bold -underline $ul -overstrike $os
	font $cmd ${vfont}Underline -size $sz -family $fam -weight $wgt -underline 1 -overstrike $os
    }
	
    # Initialize fixed width fonts.  Use preferences settings if present.
    foreach ffont {fixedFont textFont} {
	if {[info exists PrefDefault($ffont)] &&
	    [lsearch $fontlist $PrefDefault($ffont)] < 0} {
	    set font $PrefDefault($ffont)
	} else {
	    set font $defaultFFont
	}
	array set data [font actual $font]
	set sz  $data(-size)
	set fam $data(-family)
	set wgt $data(-weight)
	set sl  $data(-slant)
	set ul  $data(-underline)
	set os  $data(-overstrike)
	font $cmd ${ffont}     -size $sz -family $fam -weight $wgt -underline $ul -overstrike $os
	font $cmd ${ffont}Bold -size $sz -family $fam -weight bold -underline $ul -overstrike $os
	font $cmd ${ffont}Underline -size $sz -family $fam -weight $wgt -underline 1 -overstrike $os
    }

    if {$cmd eq "create"} {
	set PrefDefault(menuFont)   [FontSpec menuFont]
	set PrefDefault(textFont)   [FontSpec textFont]
	set PrefDefault(fixedFont)  [FontSpec fixedFont]
	set PrefDefault(footerFont) [FontSpec footerFont]
	set PrefDefault(treeFont)   [FontSpec treeFont]

	option add *Text.Font              fixedFont ;#widgetDefault
	option add *Button.Font            menuFont  ;#widgetDefault
	option add *Canvas.Font            textFont  ;#widgetDefault
	option add *Checkbox.labelFont     menuFont  ;#21 ;#;#widgetDefault+1
	option add *Checkbutton.Font       menuFont  ;#widgetDefault
	option add *Colbutton.Font         menuFont  ;#widgetDefault
	option add *Combobox.labelFont     menuFont  ;#widgetDefault
	option add *Combobox.textFont      fixedFont ;#widgetDefault
	option add *Dataflow.Font          menuFont  ;#widgetDefault
	option add *Dockbar.BalloonFont    menuFont  ;#widgetDefault
	option add *Entry.Font             fixedFont ;#widgetDefault
	option add *Entryfield.labelFont   menuFont  ;#widgetDefault
	option add *Entryfield.textFont    fixedFont ;#widgetDefault
	option add *Hierarchy.labelFont    menuFont  ;#widgetDefault
	option add *Label.Font             menuFont  ;#widgetDefault
	option add *Labelframe.Font        menuFont  ;#widgetDefault
	option add *Labeledframe.labelFont menuFont  ;#21 ;#;#widgetDefault+1
	option add *Labeledwidget.labelFont menuFont ;#21 ;#;#widgetDefault+1
	option add *Listbox.Font           textFont  ;#widgetDefault
	option add *Mdiclient.Font         menuFont  ;#widgetDefault
	option add *Menu.Font              menuFont  ;#widgetDefault
	option add *Menubutton.Font        menuFont  ;#widgetDefault
	option add *Message.Font           textFont  ;#widgetDefault
	option add *MonitorNode.Font       menuFont  ;#widgetDefault
	option add *Optionmenu.Font        menuFont  ;#widgetDefault
	option add *Nlview.Font            menuFont  ;#widgetDefault
	option add *Paneframe.Font         menuFont  ;#widgetDefault
	option add *Radiobutton.Font       menuFont  ;#widgetDefault
	option add *Scrolledhtml.FixedFont courier   ;#widgetDefault
	option add *Scrolledhtml.FontName  times     ;#widgetDefault
	option add *Scrolledtext.labelFont menuFont  ;#widgetDefault
	option add *Scrolledtext.textFont  fixedFont ;#widgetDefault
	option add *Scrolledlistbox.Font   textFont  ;#widgetDefault
	option add *Spinbox.Font           menuFont  ;#widgetDefault
	option add *Spinner.labelFont      menuFont  ;#widgetDefault
	option add *Spinner.textFont       fixedFont ;#widgetDefault
	option add *Spinint.labelFont      menuFont  ;#widgetDefault
	option add *Spinint.textFont       fixedFont ;#widgetDefault

	option add *Table.Font             textFont  ;#widgetDefault
	option add *Tabnotebook.Font       menuFont  ;#widgetDefault
	option add *Toolbar.BalloonFont    menuFont  ;#widgetDefault
	option add *Toolbar.Font           menuFont  ;#widgetDefault
	option add *TreeCtrl*Font          textFont  ;#widgetDefault
	option add *WelcomeScreen.FixedFont courier  ;#widgetDefault
	option add *WelcomeScreen.FontName times     ;#widgetDefault
	option add *WelcomeScreen.Font     menuFont  ;#widgetDefault
	option add *ViewMaster.Font        menuFont
	option add *Monitor.labelFont      menuFont
	option add *Flatlist.labelFont     menuFont
	option add *Tabset.Font            menuFont
	option add *Tabbedpane.Font        menuFont
	option add *Tabbedwindow.Font      menuFont
	option add *Mdiclient.balloonFont  menuFont
	option add *Projectlist.labelFont  menuFont
	option add *Structurelist.labelFont menuFont
	option add *FlagMemlist.labelFont  menuFont
	option add *CovMiss.labelFont      menuFont
	option add *RankedProfileHierarchy.labelFont menuFont
	option add *CallTreeProfileHierarchy.labelFont menuFont
	option add *CallTreeDUProfileHierarchy.labelFont menuFont
	option add *StructuralProfileHierarchy.labelFont menuFont
	option add *RankedDetailProfileHierarchy.labelFont menuFont
	option add *Filelist.labelFont     menuFont
	option add *FlatMemlist.labelFont  menuFont
	option add *FlatFSMlist.labelFont  menuFont
	option add *CompileOrderList.labelFont menuFont

	# All Hierarchy and derived classes
	option add *Name.TextFont                         treeFont  ;#widgetDefault
	option add *CallTreeProfileHierarchy.TextFont     treeFont  ;#widgetDefault
	option add *CallTreeDUProfileHierarchy.TextFont   treeFont  ;#widgetDefault
	option add *CodeBrowserList.TextFont              treeFont  ;#widgetDefault
	option add *CompileOrderList.TextFont             treeFont  ;#widgetDefault
	option add *CovMiss.TextFont                      treeFont  ;#widgetDefault
	option add *Filelist.TextFont                     treeFont  ;#widgetDefault
	option add *FlatMemlist.TextFont                  treeFont  ;#widgetDefault
	option add *FlatFSMlist.TextFont                  treeFont  ;#widgetDefault
	option add *Flatlist.TextFont                     treeFont  ;#widgetDefault
	option add *Hierarchy.TextFont                    treeFont  ;#widgetDefault
	option add *Name.Font                             treeFont  ;#widgetDefault
	option add *ProfileHierarchy.TextFont             treeFont  ;#widgetDefault
	option add *Projectlist.TextFont                  treeFont  ;#widgetDefault
	option add *RankedDetailProfileHierarchy.TextFont treeFont  ;#widgetDefault
	option add *RankedProfileHierarchy.TextFont       treeFont  ;#widgetDefault
	option add *StructuralProfileHierarchy.TextFont   treeFont  ;#widgetDefault
	option add *Structurelist.TextFont                treeFont  ;#widgetDefault
	option add *Value.Font                            treeFont  ;#widgetDefault
	option add *Wave.Font                             treeFont  ;#widgetDefault
	option add *WaveTree.Font                         treeFont  ;#widgetDefault
	option add *WaveCursor.Font                       treeFont  ;#widgetDefault
	option add *WaveMessage.Font                      treeFont  ;#widgetDefault
	option add *VTree.Font                            treeFont
	option add *TValue.Font                           treeFont
	option add *CapacityBrowserList.TextFont          treeFont  ;#widgetDefault

    }

}

proc MGC::style::reset_fonts {args} {
    font delete menuFont menuFontBold textFont textFontBold fixedFont footerFont  
    init_fonts
}

proc MGC::style::init_defaults {args} {
#    variable PrefDefault
    global PrefDefault

    if {[lsearch -exact [font names] MGCfont] != -1} return

    switch -exact [tk windowingsystem] {
	"x11" {

	    configure -sb_width 11

	    listbox .xlb
	    if {[option get .xlb background Background] != ""} {
		configure -default_bg [option get .xlb background Background]
	    } else {
		configure -default_bg [.xlb cget -background]
	    }
	    if {[option get .xlb foreground Foreground] != ""} {
		configure -default_fg [option get .xlb foreground Foreground]
	    } else {
		configure -default_fg black
	    }

	    frame .fg -background $PrefDefault(default_fg)
	    frame .bg -background $PrefDefault(default_bg)
	    set 3d_fg [mtiwidgets::3DborderColor .fg both]
	    set 3d_bg [mtiwidgets::3DborderColor .bg both]
	    destroy .fg .bg

	    configure -menuBackground $PrefDefault(default_bg)
	    configure -menuForeground $PrefDefault(default_fg)
	    configure -background     White  
	    configure -foreground     black  
	    configure -dark1_bg       [lindex $3d_bg 1]
	    configure -dark1_fg       [lindex $3d_fg 1]
	    configure -dark2_bg       #a3a3a3
	    configure -dark2_fg       Black
	    configure -inactive_fg    Black  
	    configure -inactive_bg    #e0e0e0
	    configure -light1_bg      [lindex $3d_bg 0]
	    configure -light1_fg      [lindex $3d_fg 0]
	    configure -light2_bg      #fcfcfc
	    configure -light2_fg      White  
	    configure -active_bg      #6271b3
	    configure -active_fg      White  
	    configure -disabled_fg    $PrefDefault(light1_fg)
	    configure -input1_bg      White  
	    configure -input1_fg      Black  
	    if {[option get .xlb selectforeground selectForeground] != ""} {
		configure -select_fg [option get .xlb selectforeground selectForeground]
	    } else {
		configure -select_fg White ;#Black
	    }
	    if {[option get .xlb selectbackground selectBackground] != ""} {
		configure -select_bg [option get .xlb selectbackground selectBackground]
	    } else {
		configure -select_bg #678db2 ;##c3c3c3
	    }
	    configure -deemphasis_bg $PrefDefault(light1_bg)
	    configure -deemphasis_fg $PrefDefault(light1_fg)
	    destroy .xlb
	    #TODO: is PrefDefault(selector) useful ?
	    #configure -selector       $PrefDefault(input1_bg)
	    configure -troughcolor    [Color::AdjustLuminance $PrefDefault(default_bg) -0.25]
	    configure -balloonForeground Black
	    configure -balloonBackground {Light Yellow}

	}
	"win32" {
	    configure -menuBackground SystemMenu
	    configure -menuForeground SystemMenuText
	    configure -background    SystemButtonFace
	    configure -default_bg    SystemButtonFace
	    configure -default_fg    SystemWindowText
	    configure -foreground    SystemWindowText
	    configure -dark1_bg      System3dDarkShadow
	    configure -dark1_fg      Black  
	    configure -dark2_bg      #a3a3a3
	    configure -dark2_fg      Black  
	    configure -inactive_fg   SystemInactiveCaptionText
	    configure -inactive_bg   SystemInactiveCaption
	    configure -light1_bg     System3dLight
	    configure -light1_fg     White  
	    configure -light2_bg     #fcfcfc
	    configure -light2_fg     White  
	    configure -active_bg     SystemActiveCaption
	    configure -active_fg     SystemCaptionText
	    configure -disabled_fg   SystemDisabledText
	    configure -input1_bg     SystemWindow
	    configure -input1_fg     SystemWindowText
	    configure -select_fg     SystemHighlightText
	    configure -select_bg     SystemHighlight
#	    configure -selector      $PrefDefault(input1_bg)
	    configure -troughcolor   SystemScrollbar
	    configure -balloonForeground SystemInfoText
	    configure -balloonBackground SystemInfoBackground

	}
    }

    option add *PlusColor "#888888"
    option add *signals*interior*cs*tree*PlusColor "#e0e0e0"
    option add *variables*interior*cs*tree*PlusColor "#e0e0e0"
    option add *data*PlusColor "#e0e0e0"

    option add *selectBorderWidth 0
    option add *highlightThickness 0
    option add *HighlightThickness 0

    option add *Labelframe.padX 5
    option add *Labelframe.padY 5

    option add *Button.borderWidth 1
    option add *CallTreeProfileHierarchy.borderWidth 1
    option add *CallTreeDUProfileHierarchy.borderWidth 1
    option add *Combobox.borderWidth 1
	option add *CompileOrderList.borderWidth 1
    option add *Entry.borderWidth 1
    option add *FlatMemlist.borderWidth 1
    option add *FlatFSMlist.borderWidth 1
    option add *Label.borderWidth 1
    option add *Listbox.borderWidth 1
    option add *Mapscrollbar.borderWidth 1
	option add *Menu.tearOff 0
    option add *Menu.borderWidth 1
    option add *Menu.activeBorderWidth 1
    if {[tk windowingsystem] eq "win32"} {
	set ebd 2
	set style default
    } else {
	set ebd 1
	set style classic
    }
    option add *Mapscrollbar.elementBorderWidth $ebd
    option add *Mapscrollbar.style $style
    option add *Monitor.borderWidth 1
    option add *Projectlist.borderWidth 1
    option add *RankedProfileHierarchy.borderWidth 1
    option add *Scrollbar.borderWidth 1
    option add *Scrolledframe.borderWidth 1
    option add *Scrolledlistbox.borderWidth 1
    option add *Scrolledtext.borderWidth 1
    option add *StructuralProfileHierarchy.borderWidth 1
    option add *Label.anchor w
    if {[info exists ::env(MTI_TREE_STRIPS)]} {
	option add *striping 1
    }

    if {[ColorDist $PrefDefault(default_fg) Black] > [ColorDist $PrefDefault(default_fg) White]} {
	set PrefDefault(selectColor) Black
    } else {
	set PrefDefault(selectColor) White
    }

}

proc MGC::style::configure_PopupDelay {val} {
#    variable PrefDefault
    global PrefDefault
    set PrefDefault(PopupDelay) $val
}

proc MGC::style::configure_PopupEnabled {val} {
#    variable PrefDefault
    global PrefDefault
    set PrefDefault(PopupEnabled) $val
}

proc MGC::style::configure_PopupOff {val} {
#    variable PrefDefault
    global PrefDefault
    set PrefDefault(PopupOff) $val
}

proc MGC::style::configure {args} {
#    variable PrefDefault
    global PrefDefault
    set argc [llength $args]
    if {$argc == 0} {
	# return the current configuration
	set options {}
	foreach var [lsort [array names PrefDefault]] {
	    lappend options [list -$var $PrefDefault($var)]
	}
	return $options
    } elseif {$argc == 1} {
	# return one given configuration item
	set arg [lindex $args 0]
	set option [string range $arg 1 end]
	if {[string range $arg 0 0] == "-" && [info exists PrefDefault($option)]}  {
	    return [list $arg $PrefDefault($option)]
	} else {
	    return -code error "unknown option \"$arg\""
	}
    }
    # At this point we have to set the value for each given option
    while {$argc > 0} {
	set arg [lindex $args 0]
	set option [string range $arg 1 end]
	if {[string range $arg 0 0] != "-" } {
	    return -code error "unknown option \"$arg\""
	} elseif {$argc == 1} {
	    return -code error "value for \"$arg\" missing"
	}
	set val [lindex $args 1]
	switch -exact $option {
	    active_bg {
		set PrefDefault(active_bg) $val
		option add *ActiveBackground $PrefDefault(active_bg)
		option add *Paneframe.activeBackground $PrefDefault(active_bg)
		option add *WindowObj.activeBackground $PrefDefault(active_bg)
		option add *Menu.activeBackground $PrefDefault(active_bg)
		option add *Menubutton.activeBackground $PrefDefault(active_bg)
	    }
	    active_fg {
		set PrefDefault(active_fg) $val
		option add *ActiveForeground $PrefDefault(active_fg)
		option add *Paneframe.activeForeground $PrefDefault(active_fg)
		option add *WindowObj.activeForeground $PrefDefault(active_fg)
		option add *Menu.activeForeground $PrefDefault(active_fg)
	    }
	    background {
		set PrefDefault(background) $val
		
	    }
	    balloonBackground {
		set PrefDefault(balloonBackground) $val
	    }
	    balloonForeground {
		set PrefDefault(balloonForeground) $val
	    }
	    borderWidth {
		set PrefDefault(borderWidth) $val
		option add *Button.borderWidth $val
		option add *CallTreeProfileHierarchy.borderWidth $val
		option add *CallTreeDUProfileHierarchy.borderWidth $val
		option add *Combobox.borderWidth $val
		option add *CompileOrderList.borderWidth 1
		option add *Entry.borderWidth $val
		option add *FlatMemlist.borderWidth $val
		option add *FlatFSMlist.borderWidth $val
		option add *Label.borderWidth $val
		option add *Listbox.borderWidth $val
		option add *Mapscrollbar.borderWidth $val
		option add *Mapscrollbar.elementBorderWidth $val
		option add *Menu.borderWidth $val
		option add *Menu.activeBorderWidth $val
		option add *Monitor.borderWidth $val
		option add *Projectlist.borderWidth $val
		option add *RankedProfileHierarchy.borderWidth $val
		option add *Scrollbar.borderWidth $val
		option add *Scrolledframe.borderWidth $val
		option add *Scrolledlistbox.borderWidth $val
		option add *Scrolledtext.borderWidth $val
		option add *StructuralProfileHierarchy.borderWidth $val
	    }
	    dark1_bg {
		set PrefDefault(dark1_bg) $val
		option add *DraggableTabset.background $PrefDefault(dark1_bg)
		option add *Tabbedpane.background $PrefDefault(dark1_bg)
		option add *Tabbedwindow.background $PrefDefault(dark1_bg)
	    }
	    dark1_fg {
		set PrefDefault(dark1_fg) $val
		option add *DraggableTabset.foreground $PrefDefault(dark1_fg)
		option add *Tabbedpane.foreground $PrefDefault(dark1_fg)
		option add *Tabbedwindow.foreground $PrefDefault(dark1_fg)
	    }
	    dark2_bg {
		set PrefDefault(dark2_bg) $val
	    }
	    dark2_fg {
		set PrefDefault(dark2_fg) $val
	    }
	    default_bg {
		set PrefDefault(default_bg) $val
		tk_setPalette $PrefDefault(default_bg)
		option add *background $PrefDefault(default_bg)
		option add *Background $PrefDefault(default_bg)
		option add *Hierarchy.background $PrefDefault(default_bg)
		option add *tabBackground $PrefDefault(default_bg)
		option add *backdrop $PrefDefault(default_bg)
		option add *labelBackground $PrefDefault(default_bg)
		option add *Tabnotebook.tabBackground $PrefDefault(default_bg)
		option add *Tabnotebook.tabSelectBackground $PrefDefault(default_bg)
		option add *DraggableTabset.tabSelectBackground $PrefDefault(default_bg)
		option add *Tabbedpane.tabSelectBackground $PrefDefault(default_bg)
		option add *Tabbedwindow.tabSelectBackground $PrefDefault(default_bg)
	    }
	    default_fg {
		set PrefDefault(default_fg) $val
		option add *foreground $PrefDefault(default_fg)
		option add *Foreground $PrefDefault(default_fg)
		option add *Hierarchy.foreground $PrefDefault(default_fg)
		option add *labelForeground $PrefDefault(default_fg)
		option add *Tabset.selectforeground $PrefDefault(default_fg)
		option add *Tabnotebook.tabSelectForeground $PrefDefault(default_fg)
		option add *DraggableTabset.tabSelectForeground $PrefDefault(default_fg)
		option add *Tabbedpane.tabSelectForeground $PrefDefault(default_fg)
		option add *Tabbedwindow.tabSelectForeground $PrefDefault(default_fg)
		if {[Color::Dist $PrefDefault(default_fg) Black] > [Color::Dist $PrefDefault(default_fg) White]} {
		    set PrefDefault(selectColor) Black
		} else {
		    set PrefDefault(selectColor) White
		}
		option add *selectColor $PrefDefault(selectColor)
	    }
	    disabled_fg {
		set PrefDefault(disabled_fg) $val
		option add *disabledForeground $PrefDefault(disabled_fg)
	    }
	    fixedFont {
		set PrefDefault(fixedFont) $val
		set fa [font actual $val]
		eval [linsert $fa 0 font configure fixedFont]
		eval [linsert $fa 0 font configure fixedFontBold]
		font configure fixedFontBold -weight bold
	    }
	    footerFont {
		set PrefDefault(footerFont) $val
		set fa [font actual $val]
		eval [linsert $fa 0 font configure footerFont]
		eval [linsert $fa 0 font configure footerFontBold]
		font configure footerFontBold -weight bold
	    }
	    foreground {
		set PrefDefault(foreground) $val
	    }
	    inactive_bg {
		set PrefDefault(inactive_bg) $val
		option add *deemphasizebg $PrefDefault(inactive_bg) ;#DeemphasizeBG
	    }
	    inactive_fg {
		set PrefDefault(inactive_fg) $val
		option add *deemphasizefg $PrefDefault(inactive_fg) ;#DeemphasizeFG
	    }
	    input1_bg {
		set PrefDefault(input1_bg) $val

		option add *Entry.background $PrefDefault(input1_bg)
		option add *Entryfield.textBackground $PrefDefault(input1_bg)
		option add *Listbox.background $PrefDefault(input1_bg)
		option add *Mclistbox.background $PrefDefault(input1_bg)
		option add *Scrolledlistbox.textBackground $PrefDefault(input1_bg)
		option add *Scrolledtext.textBackground $PrefDefault(input1_bg)
		option add *Spinner.textBackground $PrefDefault(input1_bg)
		option add *Text.background $PrefDefault(input1_bg)
#		option add *selectColor $PrefDefault(input1_bg)
		option add *textBackground $PrefDefault(input1_bg)
	    }
	    input1_fg {
		set PrefDefault(input1_fg) $val
		option add *Entry.foreground $PrefDefault(input1_fg)
		option add *Entryfield.textForeground $PrefDefault(input1_fg)
		option add *Listbox.foreground $PrefDefault(input1_fg)
		option add *Mclistbox.foreground $PrefDefault(input1_fg)
		option add *Menu.selectColor $PrefDefault(input1_fg)
		option add *Scrolledlistbox.textForeground $PrefDefault(input1_fg)
		option add *Scrolledtext.textForeground $PrefDefault(input1_fg)
		option add *Spinner.textForeground $PrefDefault(input1_fg)
		option add *Text.foreground $PrefDefault(input1_fg)
		option add *insertBackground $PrefDefault(input1_fg)
		option add *textForeground $PrefDefault(input1_fg)
		option add *textForeground $PrefDefault(input1_fg)
	    }
	    light1_bg {
		set PrefDefault(light1_bg) $val
	    }
	    light1_fg {
		set PrefDefault(light1_fg) $val
	    }
	    light2_bg {
		set PrefDefault(light2_bg) $val
		option add *Tabset.selectBackground $PrefDefault(light2_bg)
	    }
	    light2_fg {
		set PrefDefault(light2_fg) $val
	    }
	    menuBackground {
		set PrefDefault(menuBackground) $val
		option add *Button.activeBackground $PrefDefault(menuBackground)
		option add *Checkbutton.activeBackground $PrefDefault(menuBackground)
		option add *Toolbar.activeBackground $PrefDefault(menuBackground)
		option add *Menu.background $PrefDefault(menuBackground)
		option add *Menubutton.background $PrefDefault(menuBackground)
	    }
	    menuFont {
		set PrefDefault(menuFont) $val
		set fa [font actual $val]
		eval [linsert $fa 0 font configure menuFont]
		eval [linsert $fa 0 font configure menuFontBold]
		font configure menuFontBold -weight bold
	    }
	    menuForeground {
		set PrefDefault(menuForeground) $val
		option add *Button.activeForeground $PrefDefault(menuForeground)
		option add *Checkbutton.activeForeground $PrefDefault(menuForeground)
		option add *Toolbar.activeForeground $PrefDefault(menuForeground)
		option add *Menu.foreground $PrefDefault(menuForeground)
		option add *Menubutton.foreground $PrefDefault(menuForeground)
	    }
	    sb_width {
		set PrefDefault(sb_width) $val
		option add *Scrollbar.width $PrefDefault(sb_width)
		option add *Monitor.sbWidth $PrefDefault(sb_width)
		option add *Hierarchy.sbWidth $PrefDefault(sb_width)
		option add *Projectlist.sbWidth $PrefDefault(sb_width)
		option add *Structurelist.sbWidth $PrefDefault(sb_width)
		option add *Flatlist.sbWidth $PrefDefault(sb_width)
		option add *Filelist.sbWidth $PrefDefault(sb_width)
		option add *FlatMemlist.sbWidth $PrefDefault(sb_width)
		option add *FlatFSMlist.sbWidth $PrefDefault(sb_width)
		option add *CompileOrderList.sbWidth $PrefDefault(sb_width)
		option add *CovMiss.sbWidth $PrefDefault(sb_width)
		option add *Watch.sbWidth $PrefDefault(sb_width)
		option add *Scrolledframe.sbWidth $PrefDefault(sb_width)
		option add *Scrolledtext.sbWidth $PrefDefault(sb_width)
		option add *Scrolledlistbox.sbWidth $PrefDefault(sb_width)
		option add *Mapscrollbar.width $PrefDefault(sb_width)
		option add *RankedProfileHierarchy.sbWidth $PrefDefault(sb_width)
		option add *CallTreeProfileHierarchy.sbWidth $PrefDefault(sb_width)
		option add *CallTreeDUProfileHierarchy.sbWidth $PrefDefault(sb_width)
		option add *StructuralProfileHierarchy.sbWidth $PrefDefault(sb_width)
	    }
	    selectColor {
		set PrefDefault(selectColor) $val
		option add *Checkbutton.selectColor $PrefDefault(selectColor)
		option add *selectColor $PrefDefault(selectColor)
		option add *Radiobutton.selectColor $PrefDefault(selectColor)
	    }
	    select_bg {
		set PrefDefault(select_bg) $val
		option add *selectBackground $PrefDefault(select_bg)
	    }
	    select_fg {
		set PrefDefault(select_fg) $val
		option add *selectForeground $PrefDefault(select_fg)
	    }
	    deemphasis_bg {
		option add *deemphasizebg $PrefDefault(inactive_bg) ;#DeemphasizeBG
		option add *deemphasisBackground $PrefDefault(inactive_bg) ;#DeemphasizeBG
	    }
	    deemphasis_fg {
		option add *deemphasizefg $PrefDefault(inactive_fg) ;#DeemphasizeFG
		option add *deemphasisForeground $PrefDefault(inactive_fg) ;#DeemphasizeFG
	    }
	    textFont {
		set PrefDefault(textFont) $val
		set fa [font actual $val]
		eval [linsert $fa 0 font configure textFont]
		eval [linsert $fa 0 font configure textFontBold]
		eval [linsert $fa 0 font configure textFontUnderline]
		eval [linsert $fa 0 font configure textFontSmallBold]
		font configure textFontBold -weight bold
		font configure textFontUnderline -underline 1
	    }
	    treeFont {
		set PrefDefault(treeFont) $val
		set fa [font actual $val]
		eval [linsert $fa 0 font configure treeFont]
		eval [linsert $fa 0 font configure treeFontBold]
		font configure treeFontBold -weight bold
	    }
	    troughcolor {
		set PrefDefault(troughcolor) $val
		option add *troughColor $PrefDefault(troughcolor)
	    }
	    default {
		return -code error "unknown option \"$arg\""
	    }
	}
	incr argc -2
	set args [lreplace $args 0 1]
    }
}

proc MGC::style::FontSpec {font} {
	set fa [font actual $font]
	array set fs $fa
	set spec [list $fs(-family) $fs(-size)]
	if {$fs(-weight) ne "normal"} {
		lappend spec $fs(-weight)
	}
	if {$fs(-slant) ne "roman"} {
		lappend spec $fs(-slant)
	}
	if {$fs(-underline)} {
		lappend spec underline
	}
	if {$fs(-overstrike)} {
		lappend spec overstrike
	}
	return $spec
}

proc MGC::style::DefaultFixedFont {} {
    # Determine default font specs
    switch -exact [tk windowingsystem] {
	"x11" -
	default {
	    set font            Courier
	    lappend font        12
	    lappend font        normal
	    lappend font        roman
	}
	"win32" {
	    set font            Courier
	    lappend font        9
	    lappend font        normal
	    lappend font        roman
	}
	"aqua" - "macintosh" {
	    set font            Courier
	    lappend font        11
	    lappend font        normal
	    lappend font        roman
	}
    }
    return $font
}

proc MGC::style::DefaultVariableFont {} {
    # Determine default font specs
    switch -exact [tk windowingsystem] {
	"x11" -
	default {
	    set font            Helvetica
	    lappend font        12
	    lappend font        normal
	    lappend font        roman
	}
	"win32" {
	    set font            Tahoma
	    lappend font        8
	    lappend font        normal
	    lappend font        roman
	}
	"aqua" - "macintosh" {
	    set font            "Lucida Grande"
	    lappend font        11
	    lappend font        normal
	    lappend font        roman
	}
    }
    return $font
}

package provide MGC::style 0.1
