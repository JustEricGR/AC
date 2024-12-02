#
# mtiwidgets.tcl
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
#  AUTHOR: Brian S. Griffin              EMAIL: bgriffin@model.com    
#
#  @(#) $Id: //dvt/mti/rel/6.5b/src/tkgui/mtiwidgets.tcl#1 $
# ----------------------------------------------------------------------
#           Copyright 1991-2009 Mentor Graphics Corporation
# 
# ======================================================================
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package require Iwidgets

namespace eval ::mtiwidgets {
    namespace export *

    variable library [file dirname [info script]]
    variable version 0.5
}

lappend auto_path [file join $mtiwidgets::library scripts]
package provide Mtiwidgets $mtiwidgets::version

