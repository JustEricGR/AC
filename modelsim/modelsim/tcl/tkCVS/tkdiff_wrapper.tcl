set cmd [lindex $argv 1]
set argv [lrange $argv 2 end]
set argc [llength $argv]
source $cmd

