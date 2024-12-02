# Tcl package index file, version 1.0

if {[package vcompare [info tclversion] 8.0] < 0} return

proc imgifneeded dir {
    rename imgifneeded {}
    if {[package vcompare [info tclversion] 8.5] < 0} {
	regsub {\.} [info tclversion] {} version
    } else {
	set version {}
    }
	if {[info exists ::tcl_platform(debug)]} {
		set dbg g
	} else {
		set dbg ""
	}
	set ext [info sharedlibextension]
	set libname img13${version}${dbg}${ext}
    package ifneeded Img 1.3 "package require Tk\nload [list [file join $dir $libname]] Img"
}
imgifneeded $dir
