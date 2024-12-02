#
set hte_file [file join $dir hte.tbc]
if { ![file exists $hte_file] } {
   set hte_file [file join $dir hte.tcl]
}
package ifneeded DesignPad 2.75 "[list source $hte_file];\
                                 set code \[catch ::HTE::initWidget msg\]
                                 if { \$code } {
                                    error \$msg
                                 }"
