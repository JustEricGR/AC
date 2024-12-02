#
#
#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
# 
#   
# Mti packages
#
package ifneeded Filelist 1.0 [list source [file join $dir filepane.tcl]]
package ifneeded mtiimages 1.0 [list source [file join $dir mtiimages.tc_]]
package ifneeded SplitView 1.0 [list source [file join $dir splitview.itk]] 
package ifneeded JobSpy 1.0 [list source [file join $dir jobspy.tc_]] 
package ifneeded JobSpyUtil 1.0 [list source [file join $dir jobspy_util.tc_]] 
package ifneeded Vsimwidgets 1.0 [list source [file join $dir mtihierarchy.itk]]
package ifneeded vsimwidgets::Panedwin 1.0 [list source [file join $dir mtipane.itk]]
if {[file exists [file join $dir tree.tc_]]} {
	package ifneeded vsimwidgets::VTree 1.0 [list source [file join $dir tree.tc_]]
} elseif {[file exists [file join $dir tree.tcl]]} {
	package ifneeded vsimwidgets::VTree 1.0 [list source [file join $dir tree.tcl]]
}
