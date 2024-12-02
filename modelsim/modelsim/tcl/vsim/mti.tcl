#
# mti.tcl
# ----------------------------------------------------------------------
# Invoked automatically by [incr Tk] upon startup to initialize
# the MTI Widgets package.
# ----------------------------------------------------------------------
#
#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
# 
# ======================================================================

package require Tcl 8.0
package require Tk 8.0
package require Itcl
package require Itk

namespace eval ::mti {
    namespace export *

    variable library [file dirname [info script]]
    variable version 1.0
}

package provide Mti $mti::version

echo lappend auto_path $mti::library
