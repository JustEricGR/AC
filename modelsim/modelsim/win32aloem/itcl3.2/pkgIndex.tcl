if {[info exists ::tcl_platform(debug)]} { 
package ifneeded Itcl 3.2 [list load [file join $dir itcl32g.dll] Itcl] 
} else { 
package ifneeded Itcl 3.2 [list load [file join $dir itcl32.dll] Itcl] 
} 
