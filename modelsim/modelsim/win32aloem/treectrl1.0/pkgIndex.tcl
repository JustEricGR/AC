proc ::TreeCtrlLoad {dir} {
	uplevel #0 [list source [file join $dir treectrl.tcl]]
	uplevel #0 [list source [file join $dir filelist-bindings.tcl]]
	tclPkgSetup $dir treectrl 1.0 {
		{libtreectrl10.dll load {treectrl imagetint textlayout}}
	}
}
package ifneeded treectrl 1.0 [list ::TreeCtrlLoad $dir]

