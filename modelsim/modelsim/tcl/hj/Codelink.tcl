# The following supports functionality added by the Codelink product

if {[info exists ::env(CODELINK_HOME)]} {
   set fileName [file join $::env(CODELINK_HOME) modelsim.tcl]
   if {[file exists $fileName]} {
      if {[catch {source $fileName} errorMessage]} {
         puts "#"
         puts "# ERROR:"
         puts "#    A problem occurred loading the Codelink customization file at $fileName"
         puts "#    The error was: $errorMessage"
         puts "#"
         puts "#    If the problem persists please contact Mentor Graphics support."
         puts "#"
      }
   }
}
