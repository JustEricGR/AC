if {[info exists ::tcl_platform(debug)]} { 
package ifneeded Itk 3.2 [list load [file join $dir itk32g.dll] Itk] 
} else { 
package ifneeded Itk 3.2 [list load [file join $dir itk32.dll] Itk] 
} 
