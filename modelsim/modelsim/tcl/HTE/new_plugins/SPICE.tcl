#HTEParser#spi#LexSPICE#SPICE sources#SPICE Plugin#cir|ckt|cmd|lib|model|sp|spi#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2003 All Rights Reserved
#
# =============================================================================

## SPICE plugin for DesignPad

## imports
namespace import -force ::HTE::Console::putLog

## Regular expressions for syntax highlighting

set commands {^\s*(\.(?:}
set cmdGroups {
   A2D|AC|ADDLIB|ALTER
   |CHECKBUS|CHECKSOA|CHRENT|CHRSIM|COMCHAR|CONNECT|CONSO|CORREL
   {|D2A|DATA|DC|DEFMAC|DEFMOD|DEFWAVE|DEL LIB|DISCARD|DISTRIB|DSP|DSPMOD|DSPF_INCLUDE}
   |END|ENDL|ENDS|EXTRACT
   |FFILE|FOUR
   |GLOBAL|GUESS
   |HIER
   |IC|INCLUDE|INIT
   |LIB|LOAD|LOOP|LOTGROUP
   |MC|MCMOD|MEAS|MODDUP|MODEL|MODLOGIC|MPRUN
   |NET|NEWPAGE|NOCOM|NODESET|NOISE|NOISETRAN|NOTRC|NWBLOCK
   |OP|OPTFOUR|OPTION|OPTNOISE|OPTPWL|OPTWIND
   |PARAM|PLOT|PLOTBUS|PRINT|PROBE|PROTECT|PZ
   |RAMP|RESTART
   |SAVE|SENS|SETBUS|SETSOA|SIGBUS|SINUS|SNF|SOLVE|STEP|SUBCKT|SUBDUP
   |TABLE|TEMP|TITLE|TF|TOPCELL|TRAN|TVINCLUDE
   |UNPROTECT|USE
   |WCASE|WIDTH))\\M
}
foreach group $cmdGroups {
   append commands $group
}

set HighlightRE(comment)         {\*|\s!|#com}
set HighlightRE(number)          {(?:[^[:alnum:]=_]|\A)((\.?\d+|\d+\.\d*)([ed][\-+]?\d+|meg|mil|[fgkmnpu])?)}
set HighlightRE(param_eqs)       {\m(\w+)\s*=}
set HighlightRE(commands)        $commands
set HighlightRE(preproc)         {^(?:\s*)#(?!com|endcom).*$}
set HighlightRE(component)       {^(?:\s*)[C-MP-Y]\w*}
set HighlightRE(output_variable) {(?:v|vdb|vp|i|w)\s*\([^)]*\)}

## Special handelling for multiple single-line comment marks
lappend prsTargetKeywords {\*|\s!}
foreach commentStart {* " !" "\t!"} {
   set hlCallbacks($commentStart) ::SyntaxHighlight::tagSingleLineComment
   set prsCallbacks($commentStart) ::SyntaxHighlight::tagSingleLineComment
}

## Code block definition array
array set codeTreeBlockDefinition {
   2           {"Sub-Circuit"                    BtnComponentBrowser}
   3           {"Sub-Circuit Node"               Port}
   4           {"Sub-Circuit Parameter"          property}
}

# By default, set all block types to be visible
if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
} else {
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) {2 3 4}
}

## Builtin Parser

set structuralBuiltinParser   ::CirParser::parseFileTclCallback

set HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural) Yes
set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing) NA
set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing) NA

proc structuralParserAvailable { } {
   variable structuralBuiltinParser

   if { [info commands $structuralBuiltinParser] == {} } {
      return 0
   }
   return 1
}


proc structuralParser { id wDirect fileName } {
   variable structuralBuiltinParser

   if { [info commands $structuralBuiltinParser] == {} } {
      set msg "No parser - \[$structuralBuiltinParser\] is not defined"
      putLog "SPICE::structuralParser: $msg"
      return $msg
   }

   if { ![info exists ::env(HDS_HOME)] } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "SPICE::structuralParser: $msg"
      return $msg
   }

   set fileSizeInLines [lindex [split [$wDirect index end] .] 0]

   # Register first range of lines to permit all subsequent "parserContext $id levelRange get"
   set rootId [[namespace parent]::parserContext $id getId root root]

   [namespace parent]::parserContext $id level set -1 $rootId

   [namespace parent]::BrowserCreateCodeTree $id $fileName 1 $fileSizeInLines

   set errorDef {}
   set callback "[namespace current]::structuralParserCB $id $wDirect %n %t %s %e %l"
   if { [catch {set errorDef [$structuralBuiltinParser $fileName $callback]}] } {
      putLog "Error in SPICE::structuralParser\n$errorInfo"
   }

   # Destroy data structures to maintain ranges of occupied lines
   [namespace parent]::parserContext $id destroyRanges

   return $errorDef
}

proc structuralParserCB { id wDirect name type start end level } {

   if { $name == {} } {
      putLog "SPICE::structuralParserCB: ERROR: empty name of \"$type\" at \"$start .. $end\""
      set name NOTSET
   }

   set parentId {}

   foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id level get $level] {}

   if { $parentId == {} } {
      putLog "SPICE::structuralParserCB: ERROR: no parent found for \"$name\" at $start .. $end at previous level"
      return
   }

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $name SPICE]

   # Register range of lines occupied by node to permit some subsequent "parserContext $id levelRange get"
   [namespace parent]::parserContext $id level set $level $blockId

   set startIndex $start.0
   set endIndex   $end.end
   set iconName file
   catch {set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)}

   # Create node
   [namespace parent]::BrowserNode  \
                           $id       \
                           $operation \
                           $wDirect    \
                           $blockId     \
                           $startIndex   \
                           $endIndex      \
                           $parentId       \
                           $beforeNode      \
                           $iconName

   return {}
}
