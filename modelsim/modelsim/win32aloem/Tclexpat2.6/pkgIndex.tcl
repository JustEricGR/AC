if {[info exists ::tcl_platform(debug)]} { 
package ifneeded xml::expat 2.6 [list load [file join $dir Tclexpat26g.dll]] 
} else { 
package ifneeded xml::expat 2.6 [list load [file join $dir Tclexpat26.dll]] 
} 
