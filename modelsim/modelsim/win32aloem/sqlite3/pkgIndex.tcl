if {[info exists ::tcl_platform(debug)]} {
package ifneeded sqlite3 3.2 [list load [file join $dir libtclsqlite3g.dll]]
} else {
package ifneeded sqlite3 3.2 [list load [file join $dir libtclsqlite3.dll]]
}
