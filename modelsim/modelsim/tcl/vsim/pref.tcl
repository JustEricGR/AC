#
#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
#   
#
# 

#
# Define some commands so this file can be sourced by other programs
#
if {[info commands vsim_kernel] == ""} {
  proc vsim_kernel {args} {return ""}
}
if {[info commands ExpandEnvVariables] == ""} {
  proc ExpandEnvVariables {s} {return $s}
}
if {[info commands batch_mode] == ""} {
  proc batch_mode {} {return 0}
}
if {[info commands winfo] == ""} {
  proc winfo {cmd win args} {return 8}
}



#
# set initial defaults
#
set PathSeparator    [GetPrivateProfileString vsim PathSeparator / ""]
set DatasetSeparator [GetPrivateProfileString vsim DatasetSeparator : ""]

set PrefVsim(addOns) ""

#
# WildcardFilter selects the object types to be excluded when performing
# wildcard matches for user commands.
# Legal values are:
#    Signal, Variable, Constant, Generic, Alias, Compare,
#    Net, Parameter, Reg, Integer, Time, Real, Memory,
#    NamedEvent, SpecParam, CellInternal, ImmediateAssert,
#    Assertion, Cover, Endpoint, ScVariable, and None.
# Use "None" to turn off all filtering.
# Value set here is the default value.
#
if {[info commands vsimcmd::AccNameCompositsList] eq "vsimcmd::AccNameCompositsList"} {
	set WildcardFilter [vsimcmd::AccNameCompositsList Default]
} else {
	set WildcardFilter [list Variable Constant Generic Parameter SpecParam Memory Assertion Cover Endpoint CellInternal ImmediateAssert]
}

set SourceMap(NoFile) "File Not Found"
set SourceDir ""

#
# User hooks for adding to windows
#   add your procedure name to the list for the window and it will
#   be called after the window is created with a single argument: the name
#   of the window that was just creaated.
#
#   add proc names like so:
#
#           lappend PrefSource(user_hook) myMainHook
#
set PrefBatch(user_hook)      ""
set PrefDataflow(user_hook)   ""
set PrefList(user_hook)       ""
set PrefMain(user_hook)       ""
set PrefProcess(user_hook)    ""
set PrefSignals(user_hook)    ""
set PrefSource(user_hook)     ""
set PrefStructure(user_hook)  ""
set PrefVariables(user_hook)  ""
set PrefWave(user_hook)       ""
set PrefCoverage(user_hook)   ""

#---------------------------------------------

# The following control the popup info box.
# By setting the popup off delay to 0, the popup will remain indefinitely
# or until there is mouse motion.
# The value is time in milliseconds.  The time for the popup to appear is
# controlled by the popup delay.
# The popup can be disabled altogether using the popup enabled flag.

set PrefDefault(PopupDelay)   1000
set PrefDefault(PopupOff)     0
set PrefDefault(PopupEnabled) 1
set wavePriv(ActiveWidget) "name"

set PrefMain(file) [ExpandEnvVariables [GetPrivateProfileString vsim TranscriptFile "" ""]]
set PrefMain(filemode) "write"
set PrefMain(saveFile) ""
set PrefMain(updateRate) 797 ;# rate in ms to update transcript (stdout) from kernel
set PrefMain(stallKernel) 0 ;# If 1, stalls kernel during CPU intensive GUI updates.
set PrefMain(cmdHistory) [ExpandEnvVariables [GetPrivateProfileString vsim CommandHistory "" ""]]
set PrefMain(prefFile) modelsim.tcl

set PrefMain(prompt1) {VSIM [history nextid]> }
if {[IsQuesta]} {
    set PrefMain(prompt2) {QuestaSim> }
} else {
    set PrefMain(prompt2) {ModelSim> }
}
set PrefMain(prompt3) "VSIM(paused)> "

set PrefMain(saveLines) 5000
set PrefMain(LinePrefix) "# "
set PrefMain(DisplayDatasetPrefix) 1
set PrefMain(DefaultSimDatasetName) "sim"
set PrefMain(DefaultVirtualDatasetName) "virtuals"
set PrefMain(DefaultVirtualFileName) "virtuals.do"
set PrefMain(wmBug) 0
set PrefMain(forceQuit) 0
set PrefMain(noRunMsg) 0
set PrefMain(colorizeTranscript) 0
if {$tcl_platform(platform) == "windows"} {
	set PrefMain(pdfViewer) {}   ;# vish will use the default PDF viewer
	set PrefMain(linkWindows) 1
	set PrefMain(shortcuts) windows
} else {
	set PrefMain(file) [ExpandEnvVariables [GetPrivateProfileString vsim TranscriptFile "" ""]]
	set PrefMain(htmlBrowser) ""
	set PrefMain(pdfViewer) acroread
	set PrefMain(linkWindows) 0
	set PrefMain(shortcuts) unix
   set PrefMain(PCEditBindingsOnUnix) 1
}

set PrefMain(EnableCommandHelp) 1
set PrefMain(EnableFileHelp) 1
set PrefMain(RaisedCommandPromptEnabled) 1
set PrefMain(RaisedCommandPromptBinding) [list <Alt-Key-slash> <Alt-Key-space>]
set PrefMain(ViewUndocked) ""
set PrefMain(EchoBatchCommands) 0

# InlineTextSearch: control if a dialog is opened to perform a search
#                   in text-based windows, or an inline "search bar"
#
set PrefMain(InlineTextSearch) 1

# Layout options:  affects the default layout of windows when
#  there are not saved user preferences set.
#  Valid values:
#    default :: Use latest default layout rules (may change from rls to rls)
#    classic :: Use default layout of 5.4 and earlier (pre project)
#    cascade :: Use Cascade style layout
#    horizontal :: Use Horizontal tiling
#    vertical :: Use Vertical tiling
#
set PrefMain(layoutStyle) default

# HideImplicitWires:
#	0 :: Show implicit wires in structure and process windows, debugger can break on them
#	1 :: Hide implicit wires in structure and process windows, debugger will ignore them
set PrefMain(HideImplicitWires) 1

# Pattern matching mode of the contains box.
# Values are one of:
#  "glob"   - common ls style matching.  Accepts * ? [class] wildcards
#  "regexp" - full regular expressions
#  "exact"  - no wildcards
set PrefMain(ContainsMode) glob

set PrefList(nameLimit) 5
set PrefList(shortNames) 0
set PrefList(MarkerSelectWidth) 100
set PrefList(fastload) 1
set PrefList(isTrigger) 1


if {![batch_mode]} {
	if {$tcl_platform(platform) == "windows"} {
		set PrefDefault(sb_width) 15
	} else {
		set PrefDefault(sb_width) 11
	}

# Fonts are decided on by mgc_style package.
# 	if {$tcl_platform(platform) == "windows"} {
# 		set PrefDefault(menuFont)   menuFont

# 		#
# 		# This is an attempt to make better font choices
# 		#
# 		set PrefDefault(textFont)   textFont
# 		set PrefDefault(fixedFont)  fixedFont
# 		set PrefDefault(footerFont) footerFont
# 		set PrefDefault(treeFont)   treeFont

# 	} else {
# 		set PrefDefault(menuFont)   menuFont
# 		set PrefDefault(textFont)   textFont
# 		set PrefDefault(fixedFont)  fixedFont
# 		set PrefDefault(footerFont) footerFont
# 		set PrefDefault(treeFont)   treeFont
# 	}

	set PrefDefault(MouseButtons) [GetNumMouseButtons]

#	set PrefList(font)            $PrefDefault(fixedFont)
#	set PrefMain(font)            $PrefDefault(textFont)
#	set PrefMain(footerFont)      $PrefDefault(footerFont)
# 	set PrefProcess(font)         $PrefDefault(treeFont)
# 	set PrefSignals(font)         $PrefDefault(treeFont)
# 	set PrefWatch(font)           $PrefDefault(textFont)
# 	set PrefSource(font)          $PrefDefault(fixedFont)
# 	set PrefStructure(font)       $PrefDefault(treeFont)
# 	set PrefVariables(font)       $PrefDefault(treeFont)
# 	set PrefWave(font)            $PrefDefault(treeFont)
# 	set PrefProfile(font)         $PrefDefault(treeFont)
# 	set PrefCoverage(font)        $PrefDefault(treeFont)
# 	set PrefFCovers(font)         $PrefDefault(treeFont)
# 	set PrefAssertions(font)      $PrefDefault(treeFont)
# 	set PrefMemory(font)          $PrefDefault(treeFont)
# 	set PrefMemory(contentsFont)  $PrefDefault(fixedFont)
# 	set PrefATV(font)             $PrefDefault(treeFont)
# 	set PrefUCDB(font)            $PrefDefault(textFont)

	# These are the Windows pseudonyms for the User default color scheme
	#                            Tcl 8.3:
	# System3dDarkShadow         "3dDarkShadow",             
	# System3dLight				 "3dLight",                  
	# SystemActiveBorder		 "ActiveBorder",             
	# SystemActiveCaption		 "ActiveCaption",            
	# SystemAppWorkspace		 "AppWorkspace",             
	# SystemBackground			 "Background",               
	# SystemButtonFace			 "ButtonFace",               
	# SystemButtonHighlight		 "ButtonHighlight",          
	# SystemButtonShadow		 "ButtonShadow",             
	# SystemButtonText			 "ButtonText",               
	# SystemCaptionText			 "CaptionText",              
	# SystemDisabledText		 "DisabledText",             
	# SystemGrayText			 "GrayText",                 
	# SystemHighlight			 "Highlight",                
	# SystemHighlightText		 "HighlightText",            
	# SystemInactiveBorder		 "InactiveBorder",           
	# SystemInactiveCaption		 "InactiveCaption",          
	# SystemInactiveCaptionText	 "InactiveCaptionText",      
	# SystemInfoBackground		 "InfoBackground",           
	# SystemInfoText			 "InfoText",                 
	# SystemMenu				 "Menu",                     
	# SystemMenuText			 "MenuText",                 
	# SystemScrollbar			 "Scrollbar",                
	# SystemWindow				 "Window",                   
	# SystemWindowFrame			 "WindowFrame",              
	# SystemWindowText			 "WindowText",               

	if {$tcl_platform(platform) == "windows"} {
		set PrefDefault(menuBackground) SystemMenu
		set PrefDefault(menuForeground) SystemMenuText
		set PrefDefault(background)    SystemButtonFace
		set PrefDefault(default_bg)    SystemButtonFace
		set PrefDefault(default_fg)    SystemWindowText
		set PrefDefault(foreground)    SystemWindowText
		set PrefDefault(dark1_bg)      System3dDarkShadow
		set PrefDefault(dark1_fg)      Black
		set PrefDefault(dark2_bg)      #a3a3a3
		set PrefDefault(dark2_fg)      Black
		set PrefDefault(inactive_fg)   SystemInactiveCaptionText
		set PrefDefault(inactive_bg)   SystemInactiveCaption
		set PrefDefault(light1_bg)     System3dLight
		set PrefDefault(light1_fg)     White
		set PrefDefault(light2_bg)     #fcfcfc
		set PrefDefault(light2_fg)     White
		set PrefDefault(active_bg)     SystemActiveCaption
		set PrefDefault(active_fg)     SystemCaptionText
		set PrefDefault(disabled_fg)   SystemDisabledText
		set PrefDefault(input1_bg)     SystemWindow
		set PrefDefault(input1_fg)     SystemWindowText
		set PrefDefault(select_fg)     SystemHighlightText
		set PrefDefault(select_bg)     SystemHighlight
		set PrefDefault(selector)      $PrefDefault(input1_bg)
		set PrefDefault(troughcolor)   SystemScrollbar
		set PrefDefault(balloonForeground) SystemInfoText
		set PrefDefault(balloonBackground) SystemInfoBackground
	} else {
		if {[option get . background Background] != ""} {
			set PrefDefault(default_bg) [option get . background Background]
		} else {
			set PrefDefault(default_bg) [. cget -background]
		}
		if {[option get . foreground Foreground] != ""} {
			set PrefDefault(default_fg) [option get . foreground Foreground]
		} else {
			set PrefDefault(default_fg) black
		}
		set 3d_fg [Get3DColors $PrefDefault(default_fg)]
		set 3d_bg [Get3DColors $PrefDefault(default_bg)]
		set PrefDefault(menuBackground) $PrefDefault(default_bg)
		set PrefDefault(menuForeground) $PrefDefault(default_fg)
		set PrefDefault(background)     White
		set PrefDefault(foreground)     black
		set PrefDefault(dark1_bg)       [lindex $3d_bg 1]
		set PrefDefault(dark1_fg)       [lindex $3d_fg 1]
		set PrefDefault(dark2_bg)       #a3a3a3
		set PrefDefault(dark2_fg)       Black
		set PrefDefault(inactive_fg)    Black
		set PrefDefault(inactive_bg)    #a3a3a3
		set PrefDefault(light1_bg)      [lindex $3d_bg 0]
		set PrefDefault(light1_fg)      [lindex $3d_fg 0]
		set PrefDefault(light2_bg)      #fcfcfc
		set PrefDefault(light2_fg)      White
		set PrefDefault(active_bg)      #6271b3
		set PrefDefault(active_fg)      White
		set PrefDefault(disabled_fg)    $PrefDefault(light1_fg)
		set PrefDefault(input1_bg)      White
		set PrefDefault(input1_fg)      Black
		if {[option get . selectForeground Background] != ""} {
			set PrefDefault(select_fg) [option get . selectForeground Background]
		} else {
			set PrefDefault(select_fg) Black
		}
		if {[option get . selectBackground Foreground] != ""} {
			set PrefDefault(select_bg) [option get . selectBackground Foreground]
		} else {
			set PrefDefault(select_bg) #c3c3c3
		}
		set PrefDefault(selector)       $PrefDefault(input1_bg)
		set PrefDefault(troughcolor)    [Color::AdjustLuminance $PrefDefault(default_bg) -0.15]
		set PrefDefault(balloonForeground) Black
		set PrefDefault(balloonBackground) {Light Yellow}
	}

	if {[Color::Dist $PrefDefault(default_fg) Black] > [Color::Dist $PrefDefault(default_fg) White]} {
		set PrefDefault(selectColor) Black
	} else {
		set PrefDefault(selectColor) White
	}

	set PrefDataflow(ColorMap) {White {0.0 0.0 0.0 setrgbcolor}} ;# list {color {postscript code}}
	set PrefDataflow(ColorMode) gray        ;# color|gray|mono
	set PrefDataflow(Orientation) landscape ;# landscape|portrait
	set PrefDataflow(OutputMode) normal     ;# normal|eps
	set PrefDataflow(PSFile) dataflow.ps
	set PrefDataflow(mouseMode) Select

	set PrefDataflow(hidecells)     1
	set PrefDataflow(inoutlocation) 1
	set PrefDataflow(keepdataflow)  1
	set PrefDataflow(keepdataflow)  1
	set PrefDataflow(lognets)       1
	set PrefDataflow(autowave)      1
	set PrefDataflow(nosprout)      0
	set PrefDataflow(selectenv)     1
	set PrefDataflow(selequivnets)  0
	set PrefDataflow(showvalues)    1
	set PrefDataflow(valuelength)   16
	set PrefDataflow(outputquerylimit) 100
	#set PrefDataflow(outputtrim)    0
	#set PrefDataflow(doubleclicknet) all
	set PrefDataflow(p2plimit)      400
	set PrefDataflow(showhierarchy) 0
	set PrefDataflow(autosource)    1
	set PrefDataflow(symlibs)       {}

	set PrefPostscript(-adobe-courier-medium-r-normal--12-*-*-*-*-*) {Courier 12}
	set PrefPostscript(-adobe-helvetica-medium-r-normal--12-*-*-*-*-*-*-*) {Helvetica 12}
	set PrefPostscript(-adobe-times-medium-r-normal--12-*-*-*-*-*-*-*) {Times 12}
	set PrefPostscript(filename) wave.ps
	set PrefPostscript(height) 11
	set PrefPostscript(margin) 0.5
	set PrefPostscript(orientation) landscape
	set PrefPostscript(paper_size) USLetter
	set PrefPostscript(perpage) {400 ns}
	set PrefPostscript(units) inch
	set PrefPostscript(width) 8.5
	set PrefPostscript(selection) visible
	set PlotFilterResolution 0.2

	set PrinterSetup(papersize) {Letter}
	set PrinterSetup(scaling) fit 
	set PrinterSetup(perpage) 500 
	set PrinterSetup(fitto) 1 
	set PrinterSetup(top) 0.5 
	set PrinterSetup(bottom) 0.5 
	set PrinterSetup(left) 0.5 
	set PrinterSetup(right) 0.5 
	set PrinterSetup(custom_width) 8.5 
	set PrinterSetup(custom_height) 11.0 
	set PrinterSetup(printer) {}
	set PrinterSetup(orientation) landscape 
	set PrinterSetup(toFile) 0
	set PrinterSetup(labelmethod) auto
	set PrinterSetup(labelwidth) 1.5
	set PrinterSetup(pscmd) "lp -d lp1"
	set PrinterSetup(pscmd_history) [list $PrinterSetup(pscmd)]
	set PrinterSetup(cursors) off
	set PrinterSetup(sigrange) current
	set PrinterSetup(timerange) current
	set PrinterSetup(psmethod) pscmd
	set PrinterSetup(color) bw
	set PrinterSetup(grid) on
	set PrinterSetup(outFile) wave.ps 

	set PrinterSetup(dfView) view
	set PrinterSetup(dfcolor) mono
	set PrinterSetup(dfhighlight) off
#	set PrinterSetup(dffont) Helvetica
	set PrinterSetup(dfborderwidth) 0.4
	set PrinterSetup(dfpapersize) Letter

	# printer preferences common to dataflow and schematic windows
	set PrinterSetup(nlvView) view
	set PrinterSetup(nlvcolor) mono
	set PrinterSetup(nlvhighlight) off
	set PrinterSetup(nlvfont) Helvetica
	set PrinterSetup(nlvborderwidth) 0.4
	set PrinterSetup(nlvpapersize) Letter

	set PrefSource(highlightExecutableLines) 1
   set PrefSource(HighlightErrorColor) orange
	set PrefSource(WarnSourceChanged) 1
	set PrefSource(SourcePopupEnabled) 1
	set PrefSource(mouseMode) debug
	set PrefSource(HighlightDriver,foreground) black
	set PrefSource(HighlightDriver,background) cyan
	set PrefSource(tabs) 8
	if {$tcl_platform(platform) == "windows"} {
		set PrefSource(MiddleMouseButtonPaste) 0
	} else {
		set PrefSource(MiddleMouseButtonPaste) 1
	}
	if {[info exists env(EDITOR)]} {
		set PrefMain(Editor)  $env(EDITOR)
	} else {
		set PrefMain(Editor) ""
	}
	set PrefSource(ReadOnly) 1

	set PrefWave(scroll_time) 60
	set PrefWave(snap_time) 200
	set PrefWave(signalNameWidth) [GetPrivateProfileString vsim WaveSignalNameWidth 0 ""]

	set PrefWave(nameColWidth) 150
	set PrefWave(valueColWidth) 100
	set PrefWave(valueJustify) left
	set PrefWave(rowMargin) 4
	set PrefWave(childRowMargin) 2 
	set PrefWave(WaveformPopupEnabled) 1
	set PrefWave(ShowDriversEnabled) 1
	set PrefWave(ScrollOnRunComplete) 1
	set PrefWave(SaveEditableCmdsOnClose) 1
	set PrefWave(SaveFormatOnClose) 0
	set PrefWave(mouseMode) Select
	set PrefWave(waveSelectEnabled) 0
	set PrefWave(waveSelectColor) grey30
	set PrefWave(gridOffset) 0
	set PrefWave(gridPeriod) 1
	set PrefWave(gridDelta) 40
	set PrefWave(gridAuto) off
	set PrefWave(timeline)   0
	set PrefWave(GroupName) "Group#"
	set PrefWave(OpenLogAutoAddWave) 1

	set PrefSignals(nameColWidth) 150
	set PrefSignals(valueJustify) left

	set PrefStructure(autoExpand) 1
	set PrefStructure(accFilter) {AllScopes AllProcesses}

	set PrefVariables(nameColWidth) 150
	set PrefVariables(valueJustify) left

	set PrefMain(LoadLogFileName) "myVsim.wav"
	set PrefMain(LoadLogLogicalName) "myDesign"

	set PrefStartup(geometry)    +150+100
	set PrefCoverage(geometry)       550x400

	set PrefWelcome(QuickStartQA) { .. tcl QAfiles QS_QA.txt }

	set PrefWatch(radix) default
	set PrefWatch(minwidth) 70
	set PrefWatch(minheight) 50
	set PrefWatch(maxwidth) 200
	set PrefWatch(maxheight) 300

	# all other window geometries are calculated later (based on screen size).

	if {[winfo depth .] > 1} {
		# Color defaults
		set PrefMain(background) White
		set PrefMain(foreground) Black
		set PrefMain(selectBackground) $PrefDefault(select_bg)
		set PrefMain(selectForeground) $PrefDefault(select_fg)
		set PrefMain(insertBackground) Black
		set PrefMain(promptColor) Navy
		set PrefMain(errorColor) red
		set PrefMain(assertColor) blue
		set PrefMain(noteColor) "forest green"
		set PrefMain(warningColor) gold4
		set PrefMain(failureColor) orange
		set PrefMain(goodProjectCompile) "forest green"
		set PrefMain(errorProjectCompile) red
		set PrefStructure(background) $PrefMain(background) ;# $PrefDefault(background)
		set PrefStructure(foreground) $PrefMain(foreground) ;# $PrefDefault(foreground)
		set PrefStructure(selectBackground) $PrefDefault(select_bg)
		set PrefStructure(selectForeground) $PrefDefault(select_fg)
		set PrefSignals(background) #505b8c
		set PrefSignals(foreground) White
		set PrefSignals(selectBackground) White
		set PrefSignals(selectForeground) Black
		set PrefWatch(foreground) $PrefMain(foreground)
		set PrefWatch(background) $PrefMain(background)
		set PrefWatch(selectBackground) $PrefDefault(active_bg)
		set PrefWatch(selectForeground) "White"
		set PrefWatch(headerBackground) $PrefDefault(active_bg)
		set PrefWatch(headerForeground) "White"
		set PrefWatch(inactiveBackground) "Light Grey"
		set PrefWatch(inactiveForeground) "Black"
		set PrefWatch(valueBackground) White
		set PrefWatch(valueForeground) Black

		set SignalColor(-in) {} ;# {light blue}
		set SignalColor(-out) {} ;# pink
		set SignalColor(-inout) {} ;# {light yellow}
		set SignalColor(-internal) {}

		set PrefVariables(background) #6271b3
		set PrefVariables(foreground) White
		set PrefVariables(selectBackground) White
		set PrefVariables(selectForeground) Black
		set PrefProcess(background) #8aa3ff
		set PrefProcess(foreground) White
		set PrefProcess(selectBackground) White
		set PrefProcess(selectForeground) Black

		set PrefWave(background) grey50
		set PrefWave(foreground) White
		set PrefWave(selectBackground) White
		set PrefWave(selectForeground) Black
		set PrefWave(waveBackground) Black
		set PrefWave(waveBackground3) MidnightBlue
		set PrefWave(waveBackground4) DarkGreen
		set PrefWave(waveForeground) White
		set PrefWave(activeRowBackground) White
		set PrefWave(vectorColor) #b3ffb3
		set PrefWave(diffColor) Red
		set PrefWave(noDiffColor) Yellow
		set PrefWave(ignoreDiffColor) grey70
		set PrefWave(annoDiffColor) purple
		set PrefWave(useStipple) 1
		set PrefWave(cursorColor) gold
		set PrefWave(cursorDeltaColor) white
		set PrefWave(cursorLockColor) red 
		set PrefWave(rubberbandColor) cyan

        set PrefWave(selectEditColor) Red
		set PrefWave(gridColor) grey50
		set PrefWave(textColor) White
		set PrefWave(timeColor) Green
		set PrefList(background) #d9dfff
		set PrefList(foreground) Black
		set PrefList(selectBackground) "Forest Green"
		set PrefList(selectForeground) White
		set PrefList(highlightcolor) maroon
		set PrefDataflow(background) #3f4973
		set PrefDataflow(textColor) White
		set PrefDataflow(fillColor) grey60
		set PrefDataflow(outlineColor) {Sky Blue}
		set PrefDataflow(valueColor) Yellow
		set PrefDataflow(highlightColor) green
		set PrefDataflow(selectColor) salmon
		set PrefLibrary(entity_color) purple
		set PrefLibrary(arch_color)   violet
		set PrefLibrary(config_color) Red
		set PrefLibrary(module_color) maroon
		set PrefLibrary(udp_color) brown
		set PrefLibrary(package_color) "Forest Green"
		set PrefLibrary(library_color) "Forest Green"
		set PrefLibrary(library_map_color) Navy
		set PrefProfile(background) White
		set PrefProfile(foreground) Blue
		set PrefProfile(hotForeground) Red
		set PrefProfile(selectBackground) Grey70
		set PrefCoverage(background) White
		set PrefCoverage(foreground) Black
		set PrefCoverage(selectBackground) Grey70
		set PrefCoverage(barColor) green
		set PrefCoverage(barHighlightColor) red
		set PrefCoverage(zeroHitsColor) red
		set PrefCoverage(excludedHitsColor) green3
		set PrefCoverage(coverHighlight) pink
		set PrefCoverage(missedHighlight) yellow
		set PrefCoverage(hoverHighlight) {light blue}
		set PrefFCovers(textBackground) White
		set PrefFCovers(textForeground) Black
		set PrefFCovers(selectBackground) $PrefDefault(select_bg)
		set PrefFCovers(selectForeground) $PrefDefault(select_fg)
		set PrefFCovers(barColor) green
		set PrefFCovers(barHighlightColor) red
		set PrefAssertions(textBackground) White
		set PrefAssertions(textForeground) Black
		set PrefAssertions(selectBackground) $PrefDefault(select_bg)
		set PrefAssertions(selectForeground) $PrefDefault(select_fg)
		set PrefMemory(textBackground) White
		set PrefMemory(textForeground) Black
		set PrefMemory(selectBackground) $PrefDefault(select_bg)
		set PrefMemory(selectForeground) $PrefDefault(select_fg)
		set PrefFSMList(textBackground) White
		set PrefFSMList(textForeground) Black
		set PrefFSMList(selectBackground) $PrefDefault(select_bg)
		set PrefFSMList(selectForeground) $PrefDefault(select_fg)
		set PrefMsgViewer(textBackground) White
		set PrefMsgViewer(textForeground) Black
		set PrefMsgViewer(selectBackground) $PrefDefault(select_bg)
		set PrefMsgViewer(selectForeground) $PrefDefault(select_fg)
		set PrefTriageViewer(textBackground) White
		set PrefTriageViewer(textForeground) Black
		set PrefTriageViewer(selectBackground) $PrefDefault(select_bg)
		set PrefTriageViewer(selectForeground) $PrefDefault(select_fg)
		set PrefATV(hierbackground) #505b8c
		set PrefATV(foreground) yellow
		set PrefATV(threadbackground) Black
		set PrefATV(textColor) white
		set PrefATV(highlightColor) magenta
		set PrefATV(selectTextColor) green
		set PrefATV(selectBackground) White
		set PrefATV(selectForeground) Black
		set PrefATV(zoomColor) orange
		set PrefATV(timeZoneColor) "#303030"
		set PrefATV(boolPassColor) green
		set PrefATV(boolFailColor) red
		set PrefATV(forkColor) yellow
		set PrefATV(beginEndColor) blueviolet
		set PrefATV(varAssignColor) deepskyblue
		set PrefUCDB(background) White
		set PrefUCDB(foreground) Black
	} else {
		# Monochrome defaults
		set PrefDefault(menuBackground) Black
		set PrefDefault(menuForeground) White
		set PrefDefault(background) White
		set PrefMain(background) White
		set PrefMain(foreground) Black
		set PrefMain(insertBackground) Black
		set PrefMain(promptColor) Black
		set PrefMain(errorColor) Black
		set PrefMain(failureColor) Black
		set PrefMain(assertColor) Black
		set PrefMain(goodProjectCompile) Black
		set PrefMain(errorProjectCompile) Black
		set PrefStructure(background) White
		set PrefStructure(foreground) Black
		set PrefStructure(selectBackground) Black
		set PrefStructure(selectForeground) White
		set PrefSignals(background) White
		set PrefSignals(foreground) Black
		set PrefSignals(selectBackground) Black
		set PrefSignals(selectForeground) White
		set PrefWatch(background) White
		set PrefWatch(selectBackground) Black
		set PrefWatch(selectForeground) White
		set PrefWatch(headerBackground) Black
		set PrefWatch(headerForeground) White
		set PrefWatch(inactiveBackground) grey50
		set PrefWatch(inactiveForeground) grey75
		set PrefWatch(valueBackground) White
		set PrefWatch(valueForeground) Black
		set PrefVariables(background) White
		set PrefVariables(foreground) Black
		set PrefVariables(selectBackground) Black
		set PrefVariables(selectForeground) White
		set PrefProcess(background) White
		set PrefProcess(foreground) Black
		set PrefProcess(selectBackground) Black
		set PrefProcess(selectForeground) White
		set PrefWave(background) Black
		set PrefWave(foreground) White
		set PrefWave(selectBackground) White
		set PrefWave(selectForeground) Black
		set PrefWave(waveBackground) Black
		set PrefWave(waveBackground3) Black
		set PrefWave(waveBackground4) Black
		set PrefWave(waveForeground) White
		set PrefList(background) White
		set PrefList(foreground) Black
		set PrefList(selectBackground) Black
		set PrefList(selectForeground) White
		set PrefDataflow(background) Black
		set PrefDataflow(textColor) White
		set PrefDataflow(fillColor) Black
		set PrefDataflow(outlineColor) White
		set PrefDataflow(valueColor) White
		set PrefLibrary(entity_color) Black
		set PrefLibrary(arch_color)   Black
		set PrefLibrary(config_color) Black
		set PrefLibrary(module_color) Black
		set PrefLibrary(udp_color) Black
		set PrefLibrary(package_color) Black
		set PrefLibrary(library_color) Black
		set PrefLibrary(library_map_color) Black
		set PrefProfile(background) White
		set PrefProfile(foreground) Black
		set PrefProfile(hotForeground) Black
		set PrefProfile(selectBackground) White
		set PrefCoverage(background) White
		set PrefCoverage(foreground) Black
		set PrefCoverage(selectBackground) White
		set PrefCoverage(barColor) Black
		set PrefCoverage(barHighlightColor) Black
		set PrefCoverage(zeroHitsColor) Black
		set PrefCoverage(excludedHitsColor) Black
		set PrefCoverage(coverHighlight) Black
		set PrefCoverage(missedHighlight) Black
		set PrefCoverage(hoverHighlight) White
		set PrefFCovers(textBackground) White
		set PrefFCovers(textForeground) Black
		set PrefFCovers(selectBackground) White
		set PrefFCovers(selectForeground) Black
		set PrefFCovers(barColor) Black
		set PrefFCovers(barHighlightColor) Black
		set PrefAssertions(textBackground) White
		set PrefAssertions(textForeground) Black
		set PrefAssertions(selectBackground) White
		set PrefAssertions(selectForeground) Black
		set PrefMemory(textBackground) White
		set PrefMemory(textForeground) Black
		set PrefMemory(selectBackground) White
		set PrefMemory(selectForeground) Black
		set PrefFSMList(textBackground) White
		set PrefFSMList(textForeground) Black
		set PrefFSMList(selectBackground) White
		set PrefFSMList(selectForeground) Black
		set PrefMsgViewer(textBackground) White
		set PrefMsgViewer(textForeground) Black
		set PrefMsgViewer(selectBackground) White
		set PrefMsgViewer(selectForeground) Black
		set PrefTriageViewer(textBackground) White
		set PrefTriageViewer(textForeground) Black
		set PrefTriageViewer(selectBackground) White
		set PrefTriageViewer(selectForeground) Black
		set PrefATV(hierbackground) Black
		set PrefATV(foreground) White
		set PrefATV(threadbackground) Black
		set PrefATV(textColor) white
		set PrefATV(highlightColor) white
		set PrefATV(selectBackground) White
		set PrefATV(selectForeground) Black
		set PrefATV(zoomColor) white
		set PrefATV(timeZoneColor) white
		set PrefATV(boolPassColor) white
		set PrefATV(boolFailColor) white
		set PrefATV(forkColor) white
		set PrefATV(beginEndColor) white
		set PrefATV(varAssignColor) white
		set PrefUCDB(background) White
		set PrefUCDB(foreground) Black
	}

	set PrefDefault(background2)   [Color::AdjustLuminance $PrefDefault(background)   -0.05]
	set PrefMain(background2)      [Color::AdjustLuminance $PrefMain(background)      -0.05]
	set PrefStructure(background2) [Color::AdjustLuminance $PrefStructure(background) -0.05]
	set PrefSignals(background2)   [Color::AdjustLuminance $PrefSignals(background)   -0.05]
	set PrefWatch(background2)     [Color::AdjustLuminance $PrefWatch(background)     -0.05]
	set PrefVariables(background2) [Color::AdjustLuminance $PrefVariables(background) -0.05]
	set PrefProcess(background2)   [Color::AdjustLuminance $PrefProcess(background)   -0.05]
	set PrefWave(waveBackground2)  [Color::AdjustLuminance $PrefWave(waveBackground)  -0.05]
	set PrefWave(background2)      [Color::AdjustLuminance $PrefWave(background)      -0.05]
	set PrefList(background2)      [Color::AdjustLuminance $PrefList(background)      -0.05]
	set PrefProfile(background2)   [Color::AdjustLuminance $PrefProfile(background)   -0.05]
	set PrefCoverage(background2)  [Color::AdjustLuminance $PrefCoverage(background)  -0.05]
	set PrefUCDB(background2)      [Color::AdjustLuminance $PrefUCDB(background)      -0.05]

    set LogicStyleTable(LOGIC_U)  {Solid      red    1}
    set LogicStyleTable(LOGIC_X)  {Solid      red    1}
    set LogicStyleTable(LOGIC_0)  {Solid      green  0}
    set LogicStyleTable(LOGIC_1)  {Solid      green  2}
    set LogicStyleTable(LOGIC_Z)  {Solid      blue   1}
    set LogicStyleTable(LOGIC_W)  {DoubleDash red    1}
    set LogicStyleTable(LOGIC_L)  {DoubleDash grey90 0}
    set LogicStyleTable(LOGIC_H)  {DoubleDash grey90 2}
    set LogicStyleTable(LOGIC_DC) {DoubleDash blue   1}

	# profile window options
	set PrefProfile(hierCutoff) 1
	set PrefProfile(hierCutoffHighlight) 5
	set PrefProfile(structCutoff) 1
	set PrefProfile(structCutoffHighlight) 5
	set PrefProfile(duCutoff) 1
	set PrefProfile(duCutoffHighlight) 5
	set PrefProfile(rankCutoff) 1
	set PrefProfile(rankCutoffHighlight) 5
	set PrefProfile(detailCutoff) 1
    set PrefProfile(updateOnStructureSelect) 1
    set PrefProfile(inclusiveDuMatch) 1

    # Compile dialog options
    set PrefCompileDialog(multiFileCompile) 0

	# coverage window options
	set PrefCoverage(cutoff) 90

	# Bitmap Images

	##nagelfar ignore
	image create bitmap _undobm -foreground black -background white \
		-data {
			#define undobm_width 16
			#define undobm_height 16
			static unsigned char undobm_bits[] = {
				0x00, 0x00, 0x00, 0x0f, 0xc0, 0x30, 0x24, 0x40, 0x1c, 0x80, 0x1c, 0x80,
				0x1c, 0x80, 0x3c, 0x80, 0x00, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10,
				0x00, 0x00, 0xfe, 0xab, 0xfe, 0xab, 0x00, 0x00};
		} \
		-maskdata {
			#define undomask_width 16
			#define undomask_height 16
			static unsigned char undomask_bits[] = {
				0x00, 0x00, 0x00, 0x0f, 0xc0, 0x30, 0x24, 0x40, 0x1c, 0x80, 0x1c, 0x80,
				0x1c, 0x80, 0x3c, 0x80, 0x00, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10,
				0x00, 0x00, 0xfe, 0xab, 0xfe, 0xab, 0x00, 0x00};
		}
		
	image create bitmap _redobm -foreground black -background white \
		-data {
			#define redobm_width 16
			#define redobm_height 16
			static unsigned char redobm_bits[] = {
				0x00, 0x00, 0xf0, 0x00, 0x0c, 0x03, 0x02, 0x24, 0x01, 0x38, 0x01, 0x38,
				0x01, 0x38, 0x01, 0x3c, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00,
				0x00, 0x00, 0xd5, 0x7f, 0xd5, 0x7f, 0x00, 0x00};
		} \
		-maskdata {
			#define redomask_width 16
			#define redomask_height 16
			static unsigned char redomask_bits[] = {
				0x00, 0x00, 0xf0, 0x00, 0x0c, 0x03, 0x02, 0x24, 0x01, 0x38, 0x01, 0x38,
				0x01, 0x38, 0x01, 0x3c, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00,
				0x00, 0x00, 0xd5, 0x7f, 0xd5, 0x7f, 0x00, 0x00};
		}

	image create bitmap _zoombm -foreground black -background white \
		-data {
			#define zoom_width 16
			#define zoom_height 16
			static unsigned char zoom_bits[] = {
				0x00, 0x00, 0xfe, 0x00, 0x02, 0x00, 0x02, 0x00, 0xf2, 0x0f, 0xf2, 0x0f,
				0x32, 0x0c, 0x32, 0x0c, 0x30, 0x4c, 0x30, 0x4c, 0xf0, 0x4f, 0xf0, 0x5f,
				0x00, 0x78, 0x00, 0x70, 0x00, 0x7f, 0x00, 0x00};
		} \
		-maskdata {
			#define zoommask_width 16
			#define zoommask_height 16
			static unsigned char zoommask_bits[] = {
				0xff, 0x00, 0xff, 0x00, 0x03, 0x00, 0xfb, 0x0f, 0xfb, 0x0f, 0xfb, 0x0f,
				0x3b, 0x0e, 0x3b, 0x4e, 0x38, 0x6e, 0xf8, 0x6f, 0xf8, 0x6f, 0xf8, 0x7f,
				0x00, 0x78, 0x00, 0x7f, 0x80, 0x7f, 0x00, 0x00};
		} 

	image create bitmap _editbm -foreground black -background white \
		-data {
			#define edit_width 16
			#define edit_height 16
			static unsigned char edit_bits[] = {
				0x00, 0x00, 0x00, 0x00, 0x7e, 0x05, 0x40, 0x20, 0x40, 0xf4, 0x44, 0x20,
				0x4f, 0x04, 0x44, 0x00, 0x40, 0x24, 0x40, 0xf0, 0x44, 0x24, 0x4f, 0x00,
				0x44, 0x04, 0xc0, 0x7f, 0x00, 0x00, 0x00, 0x00};
		} \
		-maskdata {
			#define editmask_width 16
			#define editmask_height 16
			static unsigned char editmask_bits[] = {
				0x00, 0x00, 0x00, 0x00, 0x7e, 0x05, 0x40, 0x20, 0x40, 0xf4, 0x44, 0x20,
				0x4f, 0x04, 0x44, 0x00, 0x40, 0x24, 0x40, 0xf0, 0x44, 0x24, 0x4f, 0x00,
				0x44, 0x04, 0xc0, 0x7f, 0x00, 0x00, 0x00, 0x00};
		}

	image create bitmap _selectbm -foreground black -background white \
		-data {
			#define selectbm_width 16
			#define selectbm_height 16
			static unsigned char selectbm_bits[] = {
				0x00, 0x00, 0x30, 0x00, 0x70, 0x00, 0xf0, 0x00, 0xf0, 0x01, 0xf0, 0x03,
				0xf0, 0x07, 0xf0, 0x01, 0xb0, 0x01, 0x00, 0x03, 0x00, 0x03, 0x00, 0x06,
				0x00, 0x06, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00};
		} \
		-maskdata {
			#define selectmask_width 16
			#define selectmask_height 16
			static unsigned char selectmask_bits[] = {
				0x38, 0x00, 0x78, 0x00, 0xf8, 0x00, 0xf8, 0x01, 0xf8, 0x03, 0xf8, 0x07,
				0xf8, 0x0f, 0xf8, 0x0f, 0xf8, 0x03, 0xb0, 0x07, 0x80, 0x07, 0x00, 0x0f,
				0x00, 0x0f, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00};
		}

	image create bitmap _panbm -foreground black -background white \
		-data {
			#define panbm_width 16
			#define panbm_height 16
			static unsigned char panbm_bits[] = {
				0x80, 0x01, 0xc0, 0x03, 0xe0, 0x07, 0xf0, 0x0f, 0x80, 0x01, 0x84, 0x21,
				0x86, 0x61, 0xff, 0xff, 0xff, 0xff, 0x86, 0x61, 0x84, 0x21, 0x80, 0x01,
				0xf0, 0x0f, 0xe0, 0x07, 0xc0, 0x03, 0x80, 0x01};
		} \
		-maskdata {
			#define panmask_width 16
			#define panmask_height 16
			static unsigned char panmask_bits[] = {
				0xc0, 0x03, 0xe0, 0x07, 0xf0, 0x0f, 0xf8, 0x1f, 0xfc, 0x3f, 0xce, 0x73,
				0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xce, 0x73, 0xfc, 0x3f,
				0xf8, 0x1f, 0xf0, 0x0f, 0xe0, 0x07, 0xc0, 0x03};
		}

	set _arrow_left_bitmap {
		#define _arrow_left_width 7
		#define _arrow_left_height 12
		static unsigned char _arrow_left_bits[] = {
			0x00, 0x00, 0x10, 0x18, 0x1c, 0x1e, 0x1e, 0x1c, 0x18, 0x10, 0x00, 0x00 };
	}

	image create bitmap _arrow_left_image -data $_arrow_left_bitmap -maskdata $_arrow_left_bitmap -foreground $PrefDefault(default_fg)

	set _arrow_right_bitmap {
		#define _arrow_right_width 7
		#define _arrow_right_height 12
		static unsigned char _arrow_right_bits[] = {
			0x00, 0x00, 0x04, 0x0c, 0x1c, 0x3c, 0x3c, 0x1c, 0x0c, 0x04, 0x00, 0x00 };
	}
	image create bitmap _arrow_right_image -data $_arrow_right_bitmap -maskdata $_arrow_right_bitmap -foreground $PrefDefault(default_fg)
    
	# Set the defaults for drag and drop preferences
	# also sets the supported locations   
	set types [::MtiFS::FileTypes]
	set PrefDragDrop(LOCATIONS) [list Project Transcript Wave]

	foreach loc  $PrefDragDrop(LOCATIONS)  {
	    set locli [list]
	    foreach atype $types {
			if { [llength $atype] > 2} {
				if {$loc  eq "Project"} {
					lappend locli [list [lindex $atype 2] "Add to Project" "" ]
				} else {
					lappend locli [list [lindex $atype 2] Open "" ]
				}
			}
	    }
	    set PrefDragDrop($loc) $locli
	}
}

# Place after here if it needs to work in batch mode

set PrefSource(OpenOnBreak) 1
set PrefSource(verilogFiles) {{Verilog Files}  {.v *.vl *.vo *.vp *.vt *.vqm}                            }
set PrefSource(systemVerilogFiles) {{SystemVerilog Files}  {*.sv *.svh *.svp}                            }
set PrefSource(VHDLFiles)    {{VHDL Files}     {.vhd *.vhdl *.vho *.vht}                                 }
set PrefSource(PSLFiles)     {{PSL Files}      {.psl}                                                    }
set PrefSource(HDLFiles)     {{HDL Files}      {.v *.vl *.vhd *.vhdl *.vho *.hdl *.vo *.vp *.sv *.svh *.svp *.psl *.vt *.vht *.vqm}   }
set PrefSource(CFiles)       {{C/C++ Files}    {.c *.h *.cpp *.hpp *.cxx *.hxx *.cc *.c++ *.cp *.i *.ii} }
set PrefSource(GZFiles)      {{GZ Files}       {.gz}                                                     }
set PrefSource(LogFiles)     {{Log Files}      {.wlf}                                                    }
set PrefSource(TDBFiles)     {{TDB Files}      {.tdb}                                                    }
set PrefSource(MacroFiles)   {{Macro Files}    {.do *.tcl}                                               }
set PrefSource(VCDFiles)     {{VCD Files}      {.vcd}                                                    }
set PrefSource(SDFFiles)     {{SDF Files}      {.sdf *.sdo}                                              }
set PrefSource(XMLFiles)     {{XML Files}      {.xml *.htt *.htl}                                        }
set PrefSource(TCLFiles)     {{TCL Files}      {.tcl}                                                    }
set PrefSource(DoFiles)      {{Do Files}       {.do}                                                     }
set PrefSource(TextFiles)    {{TXT Files}      {.txt}                                                    }
set PrefSource(TextLogFiles) {{Log Files}      {.log}                                                    }
set PrefSource(ProjectFiles) {{Project Files}  {.mpf}                                                    }
set PrefSource(IniFiles)     {{Ini Files}      {.ini}                                                    }
set PrefSource(AllFiles)     {{All Files}      *                                                         }
set PrefSource(UCDBFiles)    {{UCDB Files}     {.ucdb}                                                   }
set PrefSource(RankFiles)    {{Rank Files}     {.rank}                                                   }
set PrefSource(DatasetFiles) {{Dataset Files}  {.wlf *.ucdb}                                             }
set PrefSource(RMDBFiles)    {{RunMgr Db Files} {.rmdb}                                                  }
set PrefSource(spiceFiles)   {{SPICE Files}    {*.cir}                                                   }        
set PrefSource(COMMANDFiles) {{COMMAND Files}  {*.cmd}                                                   }
set PrefSource(vhdlamsFiles) {{VHDL Files}     {*.vhd *.vhdl}                                            }
set PrefSource(verilogamsFiles) {{Verilog Files} {*.v *.va *.vams}                                       } 
set PrefSource(ResultsFiles) {{Results Files}  {*.chi}                                                   } 
set PrefSource(ConverterFiles) {{Converters} {*.conv}                                                    }

set PrefSource(spiceFileTypes) \
	{\
		 $PrefSource(spiceFiles) \
		 $PrefSource(COMMANDFiles) \
		 $PrefSource(vhdlamsFiles) \
	 }
set PrefSource(amsFileTypes) \
	{\
		 $PrefSource(vhdlamsFiles) \
		 $PrefSource(verilogamsFiles) \
		 $PrefSource(spiceFiles) \
		 $PrefSource(COMMANDFiles) \
		 $PrefSource(ResultsFiles) \
		 $PrefSource(ConverterFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(UCDBFileTypes) \
	{\
		 $PrefSource(UCDBFiles) \
		 $PrefSource(RankFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(MergeFileTypes) \
	{\
		 $PrefSource(UCDBFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(RankFileTypes) \
	{\
		 $PrefSource(RankFiles) \
		 $PrefSource(UCDBFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(RMDBFileTypes) \
	{\
		 $PrefSource(RMDBFiles) \
		 $PrefSource(AllFiles) \
	}
set PrefSource(XmlFileTypes) \
	{\
		 $PrefSource(XMLFiles) \
		 $PrefSource(AllFiles) \
	}
set PrefSource(DoFileTypes) \
	{\
		 $PrefSource(DoFiles) \
		 $PrefSource(AllFiles) \
	}
set PrefSource(TextLogFileTypes) \
	{\
		 $PrefSource(TextLogFiles) \
		 $PrefSource(AllFiles) \
	}
set PrefSource(verilogFileTypes) \
	{\
		 $PrefSource(verilogFiles) \
		 $PrefSource(systemVerilogFiles) \
		 $PrefSource(VHDLFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(HDLFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(systemVerilogFileTypes) \
	{\
		 $PrefSource(systemVerilogFiles) \
		 $PrefSource(verilogFiles) \
		 $PrefSource(VHDLFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(HDLFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(vhdlFileTypes) \
	{\
		 $PrefSource(VHDLFiles) \
		 $PrefSource(verilogFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(HDLFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(systemcFileTypes) \
	{\
		 $PrefSource(CFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(pslFileTypes) \
	{\
		 $PrefSource(PSLFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(HDLFileTypes) \
	{\
		 $PrefSource(HDLFiles) \
		 $PrefSource(VHDLFiles) \
		 $PrefSource(verilogFiles) \
		 $PrefSource(systemVerilogFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(HDLCFileTypes) \
	{\
		 $PrefSource(HDLFiles) \
		 $PrefSource(VHDLFiles) \
		 $PrefSource(verilogFiles) \
		 $PrefSource(systemVerilogFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(CFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefSource(AllFileTypes) \
	{\
		 $PrefSource(AllFiles) \
	}

set PrefMain(PostscriptFileTypes) {{{Postscript Files} {.ps}} {{All Files} *}}
set PrefMain(TextFileTypes) {{{Text Files} {.txt}} {{All Files} *}}
set PrefMain(TclFileTypes) {{{Tcl Files} {.tcl}} {{All Files} *}}
set PrefMain(MacroFileTypes) {$PrefSource(MacroFiles) {{All Files} *}}
set PrefMain(SDFFileTypes) {{{SDF Files} {.sdf .sdo}} {{All Files} *}}
set PrefMain(ListFileTypes) {{{List Files} {.lst}} {{All Files} *}}
set PrefMain(ProjectFiles) {{Project Files} {.ini *.mpf}}
set PrefMain(ProjectFileTypes) \
	{\
		 $PrefMain(ProjectFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefMain(LogFileTypes) \
	{\
		 $PrefSource(LogFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefMain(DatasetFileTypes) \
	{\
		 $PrefSource(DatasetFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefMain(TDBFileTypes) \
	{\
		 $PrefSource(TDBFiles) \
		 $PrefSource(AllFiles) \
	 }
set PrefMain(AllFileTypes) [list $PrefSource(AllFiles)]
set PrefMain(GeneralFileTypes) \
	{\
		 $PrefSource(HDLFiles) \
		 $PrefSource(CFiles) \
		 $PrefSource(LogFiles) \
		 $PrefMain(ProjectFiles) \
		 $PrefSource(GZFiles) \
		 $PrefSource(MacroFiles) \
		 $PrefSource(verilogFiles) \
		 $PrefSource(systemVerilogFiles) \
		 $PrefSource(VHDLFiles) \
		 $PrefSource(PSLFiles) \
		 $PrefSource(SDFFiles) \
		 $PrefSource(TextFiles) \
		 $PrefSource(DoFiles) \
		 $PrefSource(TCLFiles) \
		 $PrefSource(UCDBFiles) \
		 $PrefSource(AllFiles) \
	 }

set PrefCoverage(pref_InitFilterFrom) ""

set PrefCoverage(DefaultCoverageMode) byfile

set PrefProject(file) History

set ListTranslateTable(LOGIC_U)  {'U'}      
set ListTranslateTable(LOGIC_X)  {'X' 'x'}    
set ListTranslateTable(LOGIC_0)  {'0' FALSE}
set ListTranslateTable(LOGIC_1)  {'1' TRUE}      
set ListTranslateTable(LOGIC_Z)  {'Z' 'z'}    
set ListTranslateTable(LOGIC_W)  {'W'}      
set ListTranslateTable(LOGIC_L)  {'L'}      
set ListTranslateTable(LOGIC_H)  {'H'}      
set ListTranslateTable(LOGIC_DC) {'-'}      

set ForceTranslateTable(LOGIC_X)  {'X' 'x'}  
set ForceTranslateTable(LOGIC_0)  {'0' FALSE}
set ForceTranslateTable(LOGIC_1)  {'1' TRUE}      
set ForceTranslateTable(LOGIC_Z)  {'Z' 'z'}  

set STDLOGIC_X_MatchesAnything 0
set VLOG_X_MatchesAnything 0

set PrefCompare(defaultGoldDatasetName)			gold
set PrefCompare(defaultTestDatasetName)			sim
set PrefCompare(defaultMaxTotalErrors)	 		1000
set PrefCompare(defaultMaxSignalErrors)  		100
set PrefCompare(defaultHideIfNoDiffs)  		    0
set PrefCompare(defaultIgnoreVerilogStrengths) 	1
set PrefCompare(defaultAddToWave) 				1

# case does matter in the following variables:
# 'D' is used in place of the don't care '-'
set PrefCompare(defaultVHDLMatches) {U=UWXD:X=UWXD:0=0LD:1=1HD:Z=ZD:W=UWXD:L=0LD:H=1HD:D=UX01ZWLHD}
set PrefCompare(defaultVLOGMatches)	{0=0:1=1:Z=Z:X=X}

set PrefCompare(defaultLeadTolerance) 			0
set PrefCompare(defaultLeadUnits) 				ns
set PrefCompare(defaultTrailTolerance) 			0
set PrefCompare(defaultTrailUnits) 				ns
#
# default signal mode may be any of the following:
# "-all"
# "-port"
# "-in"
# "-out"
# "-inout"
# "-internals"
# or some limited combinations like "-in -out"...
#
set PrefCompare(defaultSignalMode) 				"-all"
set PrefCompare(defaultWaveWindow) 				".wave"
set PrefCompare(defaultListWindow) 				none
set PrefCompare(defaultWavePane) 				0
set PrefCompare(defaultClockName) 				default_clock
set PrefCompare(defaultTrackLiveSim) 			yes
set PrefCompare(defaultFast) 			        0
set PrefCompare(defaultRebuildSeparator) 		"_"
#
# if PrefCompare(defaultStrobe) == 1, 
# signals are compared using clocked comparison by default
# if 0, uses continuous comparison:
set PrefCompare(defaultStrobe) 					0
set PrefCompare(defaultWhen) 					""

set PrefCompare(defaultDiffsFile) 				compare.dif
set PrefCompare(defaultRulesFile) 				compare.rul
set PrefCompare(defaultDiffsReportFile)			compare.txt
set PrefCompare(DiffFileTypes) {{{Diff Files} {.dif}} {{All Files} *}}
set PrefCompare(RuleFileTypes) {{{Rule Files} {.rul}} {{All Files} *}}
#
# This variable gives the maximum undo operations possible
set PrefCompare(maxUndoOperation)               20

# Memory preferences
set PrefMemory(ExpandPackedMem) 0
set PrefMemory(IdentifyMemWithinCells) 0

# UCDB preferences
set PrefUCDB(defaultPrecision) 2

# TriageViewer preferences
set PrefTriageViewer(wlfTablename)  "wlfTriageTable"
set PrefTriageViewer(ucdbTablename) "ucdbTriageTable"
set PrefTriageViewer(sqlfilename)   "questasim.tdb"
set PrefTriageViewer(logTablename)  "logTriageTable"


