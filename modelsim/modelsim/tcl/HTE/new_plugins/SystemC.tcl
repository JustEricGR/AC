#HTEParser#cpp#LexSystemC#SystemC sources#SystemC Plugin#cpp|h#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2005 All Rights Reserved
#
#
# @comment SystemC plug-in for HTE lexical parser
#
# =============================================================================

# =============================================================================
#
# (C) Mentor Graphics Corporation 2005 All Rights Reserved
#
# =============================================================================

proc setParameters {} {
#
# @comment   Procedures to check (and restore default if it is needed) values
# @comment of parameters in the Configuration array&p
#
# @comment   Should be called:&p
#
# @comment     - at startup after loading configuration&p
# @comment     - after changing configuration&p
#

   if { [[namespace parent]::parserUnavailable] } {
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural)     No
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)     No
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)         No
   }

   variable sizeForFullParsingDefault
   set sizeForFullParsing $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)
   if { ! [regexp {^\d+$} $sizeForFullParsing] } {
      set sizeForFullParsing $sizeForFullParsingDefault
   }

   variable sizeForFastParsingDefault
   set sizeForFastParsing $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)
   if { ! [regexp {^\d+$} $sizeForFastParsing] } {
      set sizeForFastParsing $sizeForFastParsingDefault
   }

   # The size for full parsing is never greater than the size for fast parsing
   if { [expr $sizeForFullParsing > $sizeForFastParsing] } {
      set sizeForFullParsing $sizeForFastParsing
   }

   set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing) $sizeForFullParsing
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing) $sizeForFastParsing
}

   global tcl_platform

   #
   # Visual are parser debug output flag
   #
   variable vaDebug 0
   #
   # Linear parser debug output flags
   #
   variable linearDebug    0
   variable linearExtDebug 0

   #
   # External parser debug output flags
   #
   variable externalDebug  0

   # Extended identifiers support
   variable extendedIdentifiers 1

   #
   # Supported code tree blocks definition
   #
   #   Plug-in should contain in own namespace array "codeTreeBlockDefinition"
   # with definitions used code blocks.
   #
   #   Code block names definition array should contain elements indexed
   # by "internal name" of code block (statically created definition array) or
   # by "internal name" prefixed by "$id," (in the case when array is created
   # dynamically during scanning) and each element should be a list of below
   # described items:
   #
   #     - textual description of code block
   #     - icon used to represent block in the code tree
   #
   array set codeTreeBlockDefinition {
      class                      {"Class"                      VhdlConfigDecl}
      comment                    {"Comment"                    {}}
      function                   {"Function"                   VhdlFunctionBody}
      method                     {"Method"                     VhdlFunctionHdr}
      namespace                  {"Namespace"                  ModuleWareDu}
      module                     {"Module"                     ScModule}
      group                      {"Group"                      openfold}
      portInOut                  {"Inout Port"                 PortIO}
      portIn                     {"Input Port"                 PortIn}
      portOut                    {"Output Port"                PortOut}
      portBuffer                 {"Buffer Port"                PortBuf}
      instance                   {"Instance"                   Instance}
   }

   # By default, set all block types to be visible 
   set lan [namespace tail [namespace current]]
   if ![info exists HTE::Configuration(LexParser.$lan,Browser.ShowBlocks)] {
      set HTE::Configuration(LexParser.$lan,Browser.ShowBlocks) \
         [lsort {class function method namespace module portInOut portIn \
                 portOut portBuffer instance}]
   }

   #
   # SystemC parser subsection of configuration values
   # Set - only when they are not already loaded
   #

   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural)              Yes
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)              Yes
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)                  Yes

   set sizeForFullParsingDefault 40
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)  $sizeForFullParsingDefault
   set sizeForFastParsingDefault 200
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)  $sizeForFastParsingDefault

   #
   # Fast level processing by FFT parser callback
   #
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],fastFFTParserLevelProcessing)   Yes
   variable fastFFTParserLevelProcessing


   set HighlightRE(operation) {[-+:%~\[\]*&<>=!|^]}
   set HighlightRE(codeBlockBound) {\(|\)|{|}}
   set HighlightRE(lineContinuation) {(\\)$}
   set HighlightRE(integer) {(?:\W|\A)(\d+)(\W|$)}

   set prsCallbacks(preproc) [namespace current]::preprocCB
   set hlCallbacks(preproc) [namespace current]::preprocCB

   set linearDebug 0
   array set linearParserState {}
   set insideBlock 0
   set startInComment 0
   set prot -1
   set prevBlock 1.0

   #
   #
   #
   set structuralBuiltinParser   ::HteBuiltinParser::parseSystemCFile
   set syntaxChecker             ::HteBuiltinParser::parseSystemCFile

   namespace import -force ::HTE::Console::putLog

   setParameters

proc preprocCB { id language job textw kw start index } {

   # if there is no line continuation, just return $index
   if { [$textw get "$index -1c"] != "\\" } {
      return $index
   }

   # line continuation found, search for real statement end
   set endIndex [$textw search -elide -regexp {[^\\]$} $index end]
   if { $endIndex!={} } {
      set endIndex [$textw index "$endIndex lineend"]
      if { $job=={highlight} } {
         $textw tag add preproc $index $endIndex
      }
      return $endIndex
   }

   return $index
}

proc weAreIn { w index {check 0} } {
# @comment	Same as <prpc ::HTE::LexParser::LexCxx::insideComment> but doesn't
# @comment returns comment bounds
# @argument w: window name
# @argument index: text widget index
# @result a comment type

   # first check wether we are inside a single line comment
   set comment [$w search -elide -regexp {\/\/} [$w index "$index linestart"] $index]
   if { $comment != "" } {
      return "single"
   }
   
   # otherwise check for a multiline
   set start 1.0
   
   # search back for close
   set comment [$w search -elide -backwards -regexp {\*\/} $index 1.0]
   if { $comment != "" } {
      set start $comment
   }

   # then forward for open
   set comment [$w search -elide -regexp {\/\*} $start $index]
   if { $comment == "" } {
      # then return an appropriate result
      return ""
   } else {
      if {$check} {
         set closed  [$w search -elide -backwards -regexp {\*\/} $index $comment]
         if {$closed == {}} {
            return ""
         }
      }
      return "multi"
   }
}

proc linearInit { id fileName startLine endLine } {
# @comment Performs linear parser initialization. Initializes
# @comment internal parser's data structures. &p
# @comment Creates code browser tree.
# @argument id: tab identifier
# @argument fileName: name of file loaded into editor's window
# @argument startLine: start line of the region to be parsed
# @argument endLine: end line of the region to be parsed
# @result none
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::lexParser>&p
#
   
   variable linearParserState
   variable prevBlock
   variable prot

   set prot -1
   set linearParserState($id,quote)          ""
   set linearParserState($id,curlyBrace)     0
   set linearParserState($id,firstWord)      0
   set linearParserState($id,lastScanIndex)  1.0
   set linearParserState($id,blockStart) 0
   set linearParserState($id,treeLevel) -1
   set prevBlock 1.0

   # Reset all parser context
   [namespace parent]::parserContext $id reset

   #
   # endLine should not be passed into createCodeTree
   #
   [namespace parent]::BrowserCreateCodeTree $id $fileName $startLine ""

   if { [info commands namespaceStack$id] != "" } {
      blockStack$id clear
      namespaceStack$id clear
      procStack$id clear
   } else {
      ::struct::stack blockStack$id
      ::struct::stack namespaceStack$id
      ::struct::stack procStack$id
   }

}

proc parseFullyQualifiedName { id start type name } {
# @c Parses C++ identifier and returns list of name qualifiers (can be
# @c used as node names) and name qualifiers tails (for using as node
# @c labels) starting from top.
#
#   Arguments:
#
# @a id:          window identifier
# @a start:       start block index
# @a type:        block type
# @a name:        fully qualified name
# @r list of {type name name_tail indexStart}

   if { $name == {} } {
      return {}
   }

   # Make last element of resulting list
   # Only last element is real code block (code tree node)
   # so it has non-empty start sub-element
   set qualifiersList [list $type $name [namespace tail $name] $start]
   set part $name
   while 1 {
      # Get next base part of name
      set part [namespace qualifiers $part]
      # And insert it as first element of list
      if { $part == {} } {
         # All is done
         break
      }
      set subId [[namespace parent]::parserContext $id getId class [namespace tail $part]]
      if { $subId == "" } {
         set subId [[namespace parent]::parserContext $id getId namespace [namespace tail $part]]
         if { $subId == "" } {
            set ctype class
         } else {
            set ctype namespace
         }
      } else {
        set ctype class
      }
      set qualifiersList [linsert $qualifiersList 0 $ctype $part [namespace tail $part] {}]
   }

   return $qualifiersList
}

proc makeFullyQualifiedTree { id w qualifiersList } {
# @c Gets as parameter list of nodes definitions created by
# @c parseFullyQualifiedName and builds set of code tree nodes.
#
#   Arguments:
#
# @a    id:             window identifier
# @a    w:              window name
# @a    qualifiersList: list of lists of node qualifier and label
# @r none

   set language [::HTE::Editor::getLangName $id]
   if { [[namespace parent]::parserContext $id checkEmpty] } {
      set parentId {}
   } else {
      set parentId [lindex [[namespace parent]::parserContext $id get] 1]
   }
    
   foreach {type qualifier qualifierLabel start} $qualifiersList {
      set name $qualifierLabel
      set blockId [[namespace parent]::parserContext $id getId $type $name]
      if { $start == "" } {
         set style Dummy
      } else {
         set style Cxx
      }
      set iconName $HTE::Configuration(LexParser.$language,icon.$type)
      set blockId [[namespace parent]::parserContext $id register $type $qualifierLabel $style]
      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id getTcl $parentId] {}
         [namespace parent]::BrowserNode             \
                                $id                  \
                                $operation           \
                                $w                   \
                                $blockId             \
                                $start               \
                                ""                   \
                                $parentId            \
                                $beforeNode          \
                                $iconName
         set parentId $blockId
      }
      [namespace parent]::parserContext $id push $blockId
}

proc getRule { keyWordVar } {
# @c Now quite simple function
# @a keyWordVar: name of the variable
# @r value of variable passed

   upvar $keyWordVar keyWordIndex
   return $keyWordIndex
}

proc removeComments { str } {
   # @c Removes commented parts from string to clarify parsing
   # @a str: Source text
   # @r text without comments
   # @note C/C++: removes /*...*/ and //...$ parts of a string str
   
   set oldStr $str
   
   # Remove singleline comments
   set startIdx 0
   while 1 {
      if [regexp -indices -start $startIdx {//[^\n]*\n} $str match] {
         foreach {st en} $match {}
         if {[string index $str [expr $st - 1]] != "\*"} {
            set str [string replace $str $st $en " "]
            set startIdx $en
         } else {
            set startIdx [expr $st + 1]
         }
      } else {
         break
      }
   }
   # Remove multiline comments:
   while 1 {
      set from [string first {/*} $str]
      if { $from == -1 } {
         break
      }
      incr from
      set upto [string first {*/} $str $from]
      if { $upto == -1 } {
         break
      }
      incr upto
      incr from -1
      set str [string replace $str $from $upto " "]
   }
     
   return $str
}

proc getCName { wDirect blockOpen } {
# @c returns class name which body is opened at blockOpen
# @a wDirect: unintercepted widget command
# @a blockOpen: index of block opening
# @r class name or empty

   variable prevBlock

   set str [$wDirect get $prevBlock $blockOpen]
   set str [removeComments $str]
   set name ""

   # it uses a usual regexp to find it out
   set ok [regexp {(class|namespace)[\s\n]+([\w_]+)} $str a type name] 
   if { $ok } {
      return [list $name $type]
   } else {
      return ""
   }
}

proc getFName { wDirect blockOpen } {
# @c Returns function name which body is opened at blockOpen
# @a wDirect: unintercepted widget command
# @a blockOpen: index of block opening
# @r function name or empty

   variable prevBlock

   set name ""
   set str [$wDirect get "$prevBlock +1 char" $blockOpen]
   set str [removeComments $str]
   regsub -all {[\n\s]+} $str " " nstr
   set str $nstr

   #now we have str without comments and long spaces
   set name [parseNode $str]
   if { [lsearch -regexp $name {function|fpointer} ] != -1 } {
      return [lindex $name 0]
   }
   return ""
}

proc getFStart { w index } {
# @c Finds out where the function header starts
# @a w: text widget
# @a index: index in function (body)
# @r starding index for function header (text to keep unhided on collapse block)
   
   variable prevBlock
   set from $prevBlock
   while 1 {
      set start [$w search -elide -backwards -regexp {\(} $index $from]
      if { [weAreIn $w $start 1] != "" } {
         set index $start
      } else {
         break
      }
   }

   # now we have $fstart between $start ( and $prevblock
   set ret [$w search -elide -backwards -regexp {[\{\}\;\/]} $start $prevBlock]
   if { $ret == "" } {
      set ret $prevBlock
   } elseif { [weAreIn $w $ret] == "single" } {
      set ret "$ret lineend"
   }
   set ret [$w search -elide -regexp {[\w\*]} $ret $index]
   return $ret
}

proc getCStart { w index } {
# @c Finds out where the class/namespace header starts
# @a w: text widget
# @a index: index in class/namespace (body)
# @r starding index for class/namespace header (text to keep unhided on collapse block)

   variable prevBlock
   set ret $index
   while 1 {
      set ret [$w search -elide -backwards -regexp {(class|namespace)} $ret $prevBlock]
      if { [weAreIn $w $ret] == "" } {
         break
      }
   }
   return "$ret +1 char"
}

proc parseNode { str } {
# @comment It's the central function. It parses complex declarations
# @comment accoding to C/C++ syntax
# @argument str: string to parse
# @result declaration name

   variable prot

   if { $prot == -1 } {
      if { [regexp {\)\s*\;\s*$} $str] } {
         set prot 1
      } else {
         set prot 0
      }
   }
   
   if { [regexp {[\{\}]} $str] } {
      return ""
   }
   
   set temp $str
   set st [string first "(" $temp]

   if { $st == -1 } {
      # we have no open braces
      regsub -all {\[[^\[\]]*\]} $temp " " str
      if { [regexp {\s\**([\w_:~]+(\s*,\s*[\w_:~]+)*)\s*;?$} $str match name] } {
         regsub -all {\s*([,;])\s*} $name {\1} a
         return $a
      }
      return ""
   }
   
   set fn [findMatchingBrace $temp $st]
   if { $fn == -1 } {
      # we have an error in a string
      return ""
   }

   # we have a decl between open and according close braces
   set temp "[string range $temp 0 $st]$[string range $temp $fn end]"

   # now we have first upperlevel (.) construction
  
   # changed to ($) one
   if { [regexp {\(\$\)\s*\(.*\)} $temp] }	{
      # we have a (dcl)() or (dcl)[]  construction
      incr st
      incr fn -1
      set ret [parseNode " [string range $str $st $fn]"]
      return [linsert $ret end fpointer]
   }
   if { [regexp {\(\$\)\s*\[.*\]} $temp] } {
      incr st
      incr fn -1
      set ret [parseNode " [string range $str $st $fn]"]
      return [linsert $ret end array]
   }

   # we have a ($) construction
   set ret [parseNode " [string range $str 0 [incr st -1]]"]
   if { $prot } {
      return [linsert $ret end method]
   } else {
      return [linsert $ret end function]
   }
}

proc findMatchingBrace { str index } {
# @comment An auxiliary procedure
# @comment It seeks in str for a brace that closes
# @comment the corresponding open brace
# @argument str: string to work with
# @argument index: open brace index
# @result corresponding index of close brace (or -1 if not found)
   
   set ind $index
   set braces 0
   set max [string length $str]
   while 1 {
      set ch [string index $str $ind]
      if { $ch == "(" } {
         incr braces
      } elseif { $ch == ")" } {
         if { $braces == 1 } {
            return $ind
         }
         incr braces -1
      }
      incr ind
      if { $ind == $max } {
         return -1
      }
   }
}

proc parseVarList { string } {
# @comment Extracts variable names from x1,x2,x3,etc list
# @argument string: string with list of arguments
# @result a TCL list with arguments' names
   
   set tmp " $string "
   regsub -all {([,;])} $tmp { \1 } string
   set list [regexp -all -inline {[\s,]([\w_]+)[\s,;]} $string]
   set ret [list]
   foreach { match name } $list {
     set ret [linsert $ret 0 $name]
   }
   return $ret
}

proc linearCompletion { id w } {
# @comment Completes first linear pass
# @argument id: window name
# @argument w: window identifier
# @result none

    variable linearParserState
    variable prevBlock
    set linearParserState($id,quote)          ""
    set linearParserState($id,curlyBrace)     0
    set linearParserState($id,firstWord)      0
    set linearParserState($id,lastScanIndex)  1.0
    set linearParserState($id,blockStart) 0
    set linearParserState($id,treeLevel) -1
    set prevBlock 1.0

    $w mark unset declaration
    $w mark unset prevBlock
}

proc linear { id w wDirect start end limit } {
# @comment  So called "linear" parser callback.
# @argument id: window identifier
# @argument w: text widget
# @argument wDirect: Tk procedure for text widget (unintercepted)
# @argument start: start recognition position index
# @argument end: end recognition position index
# @argument limit: number of lines to be recognized for current pass.
# @result scan end index
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::linearCB>&p
# @note - <proc ::HTE::LexParser::inMotion>&p
#

   if { $start == 1.0 } {
      [namespace parent [namespace parent]]::TCOM::trailer "[namespace current]::linearCompletion $id $w"
   }
   
   variable linearDebug
   variable linearParserState
   variable insideBlock
   variable startInComment
   variable prot
   variable prevBlock

   if { [lsearch -exact [$w mark names] prevBlock] != -1 } {
      set prevBlock [$w index prevBlock]
   }

   if { $linearDebug } {
      set st [open hte.debug a]
      puts $st "+++ Linear: \[$start - $end\]"
      close $st
   }

   if { [$wDirect compare $start == 1.0] } {
      # First parser entry
      set linearParserState($id,firstWord) 1

   } elseif { [$wDirect compare $start == $linearParserState($id,lastScanIndex)] } {
      # Consecutive parser entry - firstWord flag is valid
   } else {
      # Invalidate firstWord flag
      set linearParserState($id,firstWord) 0
   }

   set scanIndex $start
   set scanLimitIndex [$wDirect index "$start + $limit lines"]
   set scanStopIndex  $end

   set wordDefinition "\\S+"
   set delimiterDefinition {[\{\}\#\"\\\';]}

   variable matchedCount

   set lineContinuation 0

   while 1 {
      if { [$wDirect compare $scanIndex >= $scanLimitIndex] } {
         set linearParserState($id,lastScanIndex) $scanIndex
         $w mark set prevBlock $prevBlock
         set scanIndex [$w index $scanIndex]
         return $scanIndex
      }

      set lexemeIndex [$wDirect search -elide -count [namespace current]::matchedCount -regexp $wordDefinition $scanIndex $scanStopIndex ]

      if { $lexemeIndex == {} } {
         $w mark set prevBlock $prevBlock
         set end [$w index $end]
         return $end
      }

      if { $lineContinuation } {
         # Backslash-<newline> was processed
      } elseif { [$wDirect compare $lexemeIndex >= "$scanIndex +1 line linestart"] } {
         # Newline is the command delimiter
         set linearParserState($id,firstWord) 1
      }

      set lexemeStartSymbol [$wDirect get $lexemeIndex]
      set lineContinuation 0
      set ok [weAreIn $w $lexemeIndex]
      set insideBlock [[namespace parent]::parserContext $id checkEmpty]

      switch -exact -- $lexemeStartSymbol {
         "\)" {
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } elseif { $insideBlock } {
            }    
            set nextLexemeIndex "$lexemeIndex +1 char"
         }
      
         "\\" {
            set nextLexemeIndex [$wDirect index "$lexemeIndex +2 char"]
         }

         "#" {
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } else {
               while 1 {
                  $w mark unset declaration
                  set nextLexemeIndex [$wDirect index "$lexemeIndex lineend +1 char"]
                  if { [$wDirect get "$lexemeIndex lineend -1 char"] != "\\" } {
                     break
                  }
                  set lexemeIndex $nextLexemeIndex
               }
               if { $insideBlock } {
                  set prevBlock $nextLexemeIndex
               }
            }
         }

         "{"   {
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } else {
               set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
               set bid [lindex [[namespace parent]::parserContext $id get] 1]
               set type [[namespace parent]::parserContext $id getType $bid]
               if { $insideBlock || $type == "class" || $type == "namespace" } {
                  set prot -1
                  set fname [getFName $wDirect $lexemeIndex]
                  set cdef [getCName $wDirect $lexemeIndex]
                  set prot -1
                  set ctype [lindex $cdef 1]
                  set cname [lindex $cdef 0]
                  if { $cname != "" } {
                     set name $cname
                     set type $ctype
                     set blockstart [getCStart $w $lexemeIndex]
                     set prevBlock "$lexemeIndex +1 char"
                     incr linearParserState($id,curlyBrace)
                     incr linearParserState($id,treeLevel)
                  } elseif { $fname != "" } {
                     set name $fname
                     set type function
                     set blockstart [getFStart $w $lexemeIndex]
                     incr linearParserState($id,curlyBrace)
                     incr linearParserState($id,treeLevel)
                  } else {
                     # here must be UNKNOWN block initialization
                     set name ""
                     incr linearParserState($id,curlyBrace)
                  }
                  if { $name != "" } {
                     set ql [parseFullyQualifiedName $id $blockstart $type $name]
                     makeFullyQualifiedTree $id $w $ql
                  } 
               } else {
                   incr linearParserState($id,curlyBrace)
               }
            }     
         }

         "}"   {
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } else {
               if { $linearParserState($id,curlyBrace) > 0 } {
                  incr linearParserState($id,curlyBrace) -1
               }
               if { $linearParserState($id,curlyBrace) == $linearParserState($id,treeLevel) && !$insideBlock } { 
                  incr linearParserState($id,treeLevel) -1
                  ##############################
                  $w mark unset declaration
                  set blockId [[namespace parent]::parserContext $id pop]
                  if { $blockId != {} } {
                      [namespace parent]::BrowserCompleteNode $id $w $blockId "$lexemeIndex +1 char"
                  } else {
                  }
                  ##############################
                  set prevBlock "$lexemeIndex +2 char"
               } else {
                  set prevBlock "$lexemeIndex +2 char"
               }
                  set nextLexemeIndex [$wDirect index "$lexemeIndex +1 char"]
            }    
         }

         \; {
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } else {
               set prot -1
               set nextLexemeIndex [$wDirect index "$lexemeIndex +1 char"]
               set str [$w get $prevBlock "$lexemeIndex +1 char"]
               set str [removeComments $str]
               regsub -all {[\s\n]+} $str " " nstr
               set str " $nstr"
               set temp [parseNode $str]
               set bid [lindex [[namespace parent]::parserContext $id get] 1]
               set type [[namespace parent]::parserContext $id getType $bid]
               
               if { $insideBlock || $type == "class" || $type == "namespace" } {
                  if { [lindex $temp 1] == "method" } {
                     set blockstart [getFStart $w $lexemeIndex]
                     set ql [parseFullyQualifiedName $id $blockstart method [lindex $temp 0]]
                     makeFullyQualifiedTree $id $w $ql
                     set blockId [[namespace parent]::parserContext $id pop]
                     if { $blockId != {} } {
                        [namespace parent]::BrowserCompleteNode $id $w $blockId "$lexemeIndex +1 char"
                     }
                  } elseif { $linearParserState($id,curlyBrace) == $linearParserState($id,treeLevel) + 1  } {
                     set varList [parseVarList [lindex $temp 0]]
                     
                     # Now we have a vars start at $prevBlock end at $lexemeIndex and names in $varList
                     if { $insideBlock } {
                        set mode Global
                     } else {
                        set mode Local
                     }
                     foreach vName $varList {
                        [namespace parent]::declarationParserContext \
                           $id $w "add$mode" variable $vName $prevBlock $lexemeIndex
                     }
                  }
               }
               
               if { [lindex $temp 1] != "function" } {
                  set prevBlock "$lexemeIndex +1 char"
               }
            }
         }


         \"    {
            # Double-quote
            if { $ok == "multi" } {
               set startInComment 1
               set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
               set startInComment 0
            } elseif { $ok == "single" } {
               set nextLexemeIndex "$lexemeIndex lineend"
            } else {
               set nextLexemeIndex [$wDirect index "$lexemeIndex +1 char"]
               set quote $linearParserState($id,quote)
               if { $quote == "" } {
                  set quote $lexemeIndex
               } else {
                  set quote ""
               }

               if { $linearDebug } {
                  if { $quote == "" } {
                     set quoteTag "C Quote: "
                  } else {
                     set quoteTag "O Quote: "
                  }
                  set lexeme "$quoteTag[$wDirect get $lexemeIndex $nextLexemeIndex]"
               }

               set linearParserState($id,quote) $quote
               set linearParserState($id,firstWord) 0
            }
         }
 
         \' {
            if { $linearParserState($id,quote) != "" } {
               set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
               if { $nextLexemeIndex == "" } {
                  set nextLexemeIndex $end
               }
            } else {
               set sym [$wDirect get "$lexemeIndex +1 char"]
               if { $sym == "\\" } {
                  set nextLexemeIndex [$wDirect index "$lexemeIndex +4 char"]
               } else {
                  set nextLexemeIndex [$wDirect index "$lexemeIndex +3 char"]
               }
            }
         }

         default  {
            set nextLexemeIndex [$wDirect search -elide -regexp $delimiterDefinition                \
                                                                $lexemeIndex                        \
                                                                [$wDirect index "$lexemeIndex lineend"]]
            if { $nextLexemeIndex == "" } {
               set nextLexemeIndex [$wDirect index "$lexemeIndex + $matchedCount chars"]
            }
            
            set lexeme [$wDirect get $lexemeIndex $nextLexemeIndex]
                        if { [lsearch -exact [$w mark names] declaration] == -1 } {
               $w mark set declaration $lexemeIndex
            }
            
            if { [info exists [namespace current]::keyWordsC($lexeme)] } {
               set rule [[namespace current]::getRule [namespace current]::keyWordsC($lexeme)]
               if { $rule != "" } {
                  set nextLexemeIndex [eval $rule $id $w $wDirect $lexemeIndex $nextLexemeIndex]
               }
            }

            set linearParserState($id,firstWord) 0
            if { $linearDebug } {
               set lexeme "Default: $lexeme"
            }
         }
      }
      
      if { $linearDebug } {
         set st [open hte.debug a]
         set lineNo [lindex [split $lexemeIndex .] 0]
         set nextLineNo [lindex [split $nextLexemeIndex .] 0]

         if { $lineNo != $nextLineNo } {
            set line [$wDirect get [$wDirect index "$lexemeIndex linestart"] [$wDirect index "$lexemeIndex lineend"]]
            puts $st "===: \[$lineNo\] $line"
         }

         puts $st "[format "     %-8s: %8s - \[%-8s %8s\] - \[%s\]" $lexemeIndex $nextLexemeIndex $scanIndex $scanStopIndex $lexeme]"

         close $st
      }
      set scanIndex $nextLexemeIndex
   }
}

proc smartIndent { w special index line } {
#
# @comment   "smart indent script" - script that will be used to implement
# @comment language specific "smart indent" operation.&p
#
# @comment   Is called from parser as most high-priority code to detect
# @comment necessity to increase indent level after pressing Enter. Should
# @comment analyse current line supplied as argument and make decision
# @comment whether indent level should be increased. In this case it should
# @comment return "indentation string" that will be inserted in the text at
# @comment the beginnning of inserted new line. Otherwise should return empty
# @comment string to permit parser try other possibilities to detect indent
# @comment level for new line.&p
#
# @comment   Normally plug-in smartIndent behaviour should be changed according
# @comment to that fact that $index denotes end of line position and value of
# @comment $special flag (Shift-Enter is pressed). In the second case it is
# @comment suitable to detect that Enter is pressed inside single line comment
# @comment and return as indentation string single line comment string beginning
# @comment similar to current line.&p
#
# @comment Should be registered through call <proc ::HTE::LexParser::registerSmartIndentScript>&p
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::getIndentation>&p
#
# @argument    w        window name
# @argument    special  "smart indent" operation modificator. Currently - it is boolean flag, if "true" - make "smart indent" in the special mode inside comment
# @argument    index    current text widget index
# @argument    line     part of line before index
#
# @comment   Results:&p
#
# @comment   - Returns empty string or string that will be used as indentation string&p
#

   set smartIndentValue $HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndentValue)
   set tabsToSpaces $HTE::Configuration(LexParser.[namespace tail [namespace current]],tabsToSpaces)
   set endOfLine [expr [$w index "$index lineend"] == [$w index $index]]

   if { $special } {
      if { [regexp {^(\s*//\s*)} $line match initialSpaces] != "0" } {
         return $initialSpaces
      }
   } else {

      set indentationREList {
                              {^(\s*)public:$}
                              {^(\s*)private:$}
                              {^(\s*)protected:$}
                              {^(\s*).*(\{|\()(\s*)$}
                            }

      if { $tabsToSpaces } {
         set new [string repeat " " $smartIndentValue]
      } else {
         set new "\t"
      }

      foreach indentationRE $indentationREList {
         if { [regexp $indentationRE $line match initialSpaces] } {
            if { $endOfLine } {
               return $initialSpaces$new
            } else {
               return $initialSpaces
            }
         }
      }
   }

   regexp {^\s*} $line initialSpaces
   return $initialSpaces

}

proc isItUndoIndent { word } {
#
# @comment   Is called from parser after any text insertion to detect that
# @comment inserted text should cause indentation level decrease.
# @comment   It should analyze $word supplied as argument and return 1 if it is
# @comment "undo indent" word or 0 otherwise.
#
# @argument    word           some word (it is supposed that it is word near insert mark position)
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::undoIndentation>&p
#

   switch -glob -- $word {

      )*          -
      \}*         -
      public:     -
      private:    -
      protected:  {
         return 1
      }
   }

   return 0
}

proc structuralParserCB { id wDirect name type start end level } {
#
# @comment   FFT external parser callback. Process requests of parser and builds code tree
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    name        code block name
# @argument    type        code block type
# @argument    start       start position of code block
# @argument    end         end position of code block
# @argument    level       code block level
#

   variable externalDebug
   variable fastFFTParserLevelProcessing

   if { $externalDebug } {
      set genuineType $type
   }

   if { $start == 0x7FFFFFFF && $end == 0x80000000 } {
      putLog "[namespace tail [namespace current]]::structuralParserCB: ERROR: abstract min and max limits for \"$name\" of \"$type\" at level $level"
      set end $start
   } elseif { $end < $start } {
      putLog "[namespace tail [namespace current]]::structuralParserCB: ERROR: end value \"$end\" is less then start value ($start) for \"$name\" of \"$type\" at level $level"
      set end $start
   }

   if { $name == {} } {
      putLog "[namespace tail [namespace current]]::structuralParserCB: ERROR: empty name of \"$type\" at \"$start .. $end\""
      set name NOTSET
   }

   set parentId {}

   if { $fastFFTParserLevelProcessing } {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id level get $level] {}
   } else {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id levelRange get $level $start $end] {}
   }

   if { $parentId == {} } {
      putLog "[namespace tail [namespace current]]::structuralParserCB: ERROR: no parent found for \"$name\" at $start .. $end at previous level"
      return
   }

   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::structuralParserCB: $level \[$start .. $end\] \"$name\" of \"$type\" (as incarnation of \"$genuineType\" [string equal $genuineType $type])"
      set parentType [[namespace parent]::parserContext $id getType $parentId]
      set parentName [[namespace parent]::parserContext $id getName $parentId]
      putLog "[namespace tail [namespace current]]::structuralParserCB: parent found: $parentId: \[$parentName of $parentType\]"
   }

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $name SystemC]

   # Register range of lines occupied by node to permit some subsequent "parserContext $id levelRange get"
   if { $fastFFTParserLevelProcessing } {
      [namespace parent]::parserContext $id level set $level $blockId
   } else {
      [namespace parent]::parserContext $id levelRange set $level $start $end $blockId
   }

   set startIndex $start.0
   # Changed because of bug concerned with code block is started just
   # on the next line of the previous one. BTW external parser hangs when
   # code block is started on the same line as previous one is finished
   set endIndex   $end.end
   set iconName file
   catch {set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)}

   set exceptList {}
   if { [lsearch -exact $exceptList $type] < 0 } {
      set sIndex [$wDirect search -elide  "$name" $startIndex $endIndex]
      if { $sIndex!={} } {
         set eIndex $sIndex
         [namespace parent]::declarationParserContext $id $wDirect \
            addGlobal $type $name $sIndex $eIndex
      }
   }

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

proc structuralParserAvailable { } {
#
# @comment   Should return flag that means availability of external parser
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::structuralParserAvailable>&p
# @note - <proc ::HTE::LexParser::lexParser>&p
#

   variable structuralBuiltinParser
   if { [info commands $structuralBuiltinParser] == "" } {
      return 0
   }
   return 1

}

proc structuralParser { id wDirect fileName } {
#
# @comment  FFT parser front-end. Initiates code tree and calls external parser
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    fileName    file to be parsed
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::lexStructural>&p
#

   variable externalDebug
   variable structuralBuiltinParser
   variable fastFFTParserLevelProcessing

   if { [info commands $structuralBuiltinParser] == "" } {
      set msg "No parser - \[$structuralBuiltinParser\] is not defined"
      putLog "[namespace tail [namespace current]]::structuralParser: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "[namespace tail [namespace current]]::structuralParser: $msg"
      return $msg
   }

   set fileSizeInLines [lindex [split [$wDirect index end] .] 0]

   set fastFFTParserLevelProcessing [HTE::Config::isConfiguration $HTE::Configuration(LexParser.[namespace tail [namespace current]],fastFFTParserLevelProcessing)]
   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::structuralParser: fastFFTParserLevelProcessing: $fastFFTParserLevelProcessing"
   }

   # Register first range of lines to permit all subsequent "parserContext $id levelRange get"
   set rootId [[namespace parent]::parserContext $id getId root root]

   if { $fastFFTParserLevelProcessing } {
      [namespace parent]::parserContext $id level set -1 $rootId
   } else {
      [namespace parent]::parserContext $id levelRange set -1 1 $fileSizeInLines $rootId
   }

   [namespace parent]::BrowserCreateCodeTree $id $fileName 1 $fileSizeInLines

   set level [[namespace parent]::analysisLevel [namespace tail [namespace current]] get $fileName]
   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::structuralParser: analysis level: \"$level\""
   }

   if { $level == {} } {
      [namespace parent]::keepParserActivity $id status "error while getting analysis level for \"$fileName\"" 5
      return {}
   }

   switch -exact -- $level {
      NONE {
         set ::HTE::Browser::parserLevel($id) None;# DR 337579
         [namespace parent]::keepParserActivity $id status "File \"$fileName\" is greater then fast parsing limit. It should not be parsed"
         return {}
      }
      FFT_SYNTAX_S {
         set ::HTE::Browser::parserLevel($id) Fast;# DR 337579
         [namespace parent]::keepParserActivity $id status "Analysis level: \"$level\". File \"$fileName\" is greater then full parsing limit"
      }
      SYNTAX {
         set ::HTE::Browser::parserLevel($id) Full;# DR 337579
         [namespace parent]::keepParserActivity $id status "Analysis level: \"$level\". File \"$fileName\" is less then full parsing limit"
      }
      default {
         set ::HTE::Browser::parserLevel($id) None;# DR 337579
         putLog "[namespace tail [namespace current]]::structuralParser: invalid level \"$level\" returned"
         return {}
      }
   }
   update idletasks

   ##### DR 194611
   set createTextObject 0
   set createIgnoreFile 0
   set originalFile $::HTE::Editor::winData($id,fileName)
   if {$fileName != $originalFile} {
      if [::HteProxy::isTextObject $originalFile] {
         variable ::HteProxy::textObjects
         set textObjects($fileName) [lindex [file split $fileName] end]
         set createTextObject 1
      }
      if [::HteProxy::areErrorsIgnored $originalFile] {
         ::HteProxy::ignoreErrors $fileName
         set createIgnoreFile 1
      }
   }
   ##### DR 194611
   
   set errorDef [$structuralBuiltinParser $fileName "[namespace current]::structuralParserCB $id $wDirect %n %t %s %e %l" $level]

   ##### DR 194611
   if {$createTextObject} {
      catch {unset textObjects($fileName)}
   }
   if {$createIgnoreFile} {
      catch {unset ::HteProxy::ignoreErrors([file normalize $fileName])}
   }
   ##### DR 194611
 
   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::structuralParser: FFT return: \"$errorDef\""
   }
#  [namespace parent]::profile dump -range FFT

   # Destroy data structures to maintain ranges of occupied lines
   [namespace parent]::parserContext $id destroyRanges

   return $errorDef
}

proc syntaxCheckerAvailable { } {
#
# @comment   Should return flag that means availability of external parser
# @comment for Check Syntax command implementation
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::syntaxCheckerAvailable>&p
# @note - <proc ::HTE::LexParser::lexParser>&p
#

   variable syntaxChecker
   if { [info commands $syntaxChecker] == "" } {
      return 0
   }
   return 1

}

proc checkSyntaxCB { id wDirect name type start end level } {
#
# @comment   FFT external parser callback
# @comment for Check Syntax command implementation
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    name        code block name
# @argument    type        code block type
# @argument    start       start position of code block
# @argument    end         end position of code block
# @argument    level       code block level
#

}

proc checkSyntax { id wDirect fileName } {
#
# @comment  FFT parser front-end. Calls external parser
# @comment for Check Syntax command implementation
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    fileName    file to be parsed
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::lexCheckSyntax>&p
#

   variable externalDebug
   variable syntaxChecker

   if { [info commands $syntaxChecker] == "" } {
      set msg "No parser - \[$syntaxChecker\] is not defined"
      putLog "[namespace tail [namespace current]]::checkSyntax: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "[namespace tail [namespace current]]::checkSyntax: $msg"
      return $msg
   }

   set level [[namespace parent]::analysisLevel [namespace tail [namespace current]] getSyntaxCheck]
   if { $level == {} } {
      putLog "Error while getting analysis level for \"$fileName\""
      return {}
   }

   [namespace parent]::keepParserActivity $id status "Syntax checking started for \"$fileName\" at level \"$level\""
   update idletasks


   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::checkSyntax: FFT analysis level: \"$level\""
   }

   set createTextObject 0
   set createIgnoreFile 0
   set originalFile $::HTE::Editor::winData($id,fileName)
   if {$fileName != $originalFile} {
      if [::HteProxy::isTextObject $originalFile] {
         variable ::HteProxy::textObjects
         set textObjects($fileName) [lindex [file split $fileName] end]
         set createTextObject 1
      }
      if [::HteProxy::areErrorsIgnored $originalFile] {
         ::HteProxy::ignoreErrors $fileName
         set createIgnoreFile 1
      }
   }
   ##### DR 194611
   
   set errorDef [$syntaxChecker $fileName "[namespace current]::checkSyntaxCB $id $wDirect %n %t %s %e %l" $level]
   
   ##### DR 194611
   if {$createTextObject} {
      catch {unset textObjects($fileName)}
   }
   if {$createIgnoreFile} {
      catch {unset ::HteProxy::ignoreErrors([file normalize $fileName])}
   }
   ##### DR 194611

   if { $externalDebug } {
      putLog "[namespace tail [namespace current]]::checkSyntax: FFT return: \"$errorDef\""
   }

   return $errorDef
}

proc moduleCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting of ports declarations
# @comment Syntax:
# @comment    SC_MODULE(modName) { module declaration };
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
   set wDirect $w
   set parseIndex $end

   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]

   if {$delimiter == "\("} {
      set endIndex [[namespace current]::findClosingSymbol "\(" "\)" $w [$w index $parseIndex+1c]]
      if {$endIndex == "-1"} {
         return $end
      }
   } else {
      return $end
   }
   
   set identifierStart $parseIndex
   set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
   if { $identifier == "" } {
      return $end
   }
   # Highlight declared module
   if { $caller == "highlight" } {
      $w tag add moduleName $identifierIndex $parseIndex
   }
}

proc portCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting of ports declarations
# @comment Syntax:
# @comment    port_type<IF,N> portName1,portName2,...;
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   return [highlightDeclaration "port" $id $lang $caller $w $keyword $start $end $op]
} 

proc channelCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting of channel declarations  
# @comment Syntax:
# @comment    channel_type<IF,N> chanName1,chanName2,...;
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   return [highlightDeclaration "channel" $id $lang $caller $w $keyword $start $end $op]
}

proc highlightDeclaration { type id lang caller w keyword start end {op mark}} {
#
# @comment Highlights declarations of type defined by $type,
# @comment this function is called for ports and channels.
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
   set wDirect $w
   set parseIndex $end

   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {<}]

   if {$delimiter == "<"} {
      set parseIndex [[namespace current]::findClosingSymbol "<" ">" $w [$w index $parseIndex+1c]]
      if {$parseIndex == "-1"} {
         return $end
      } else {
         set parseIndex [$w index $parseIndex+1c]
      }
   }
   
   while 1 {
      set identifierStart $parseIndex
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }
      # Highlight declared port
      if { $caller == "highlight" } {
         $w tag add ${type}Declaration $identifierIndex $parseIndex
      }

      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;|\(}]
      switch -- $delimiter {
         \( {
            # Found a paren, skip the paren pair and test again:
            set parseIndex [[namespace current]::findClosingSymbol "\(" "\)" $w [$w index $parseIndex+1c]]
            if {$parseIndex == "-1"} {
               # Could not find closing paren:
               return $end
            } else {
               # Test again:
               set parseIndex [$w index $parseIndex+1c]
               set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
               switch -- $delimiter {
                  ,  {
                     continue
                  }
                  ; {
                      break
                  }
                  default  {
                     return $end
                  }
               }
               continue
            }
         }
         ,  {
            continue
         }
         ; {
            break
         }
         default  {
            return $end
         }
      }
   }
   
   return $parseIndex
}

####################################################################################
#                    Syntax Highlighting helper functions:                         #
####################################################################################

proc parseComment { id w wDirect start stopIndex op } {
# @comment  Parses comment and returns index of character after
# @comment  the comment to continue scanning. As a side effect 
# @comment  adds tags or marks for comment block according to 
# @comment  request $op.
# @argument id: tab identifier
# @argument w: window name
# @argument wDirect: direct window name
# @argument start: start comment index
# @argument stopIndex: stop parsing index
# @argument op: operation requested. Should be "tag" or "mark"
# @result the comment stop index

   variable startInComment
   
   set lexeme2 [$wDirect get $start "$start + 2 chars"]
   set endComment [$wDirect search -elide -regexp {\*/} $start $stopIndex]
   if { $lexeme2 == "//" } {
      # Comment region reaches one symbol after end of line
      set endComment [$wDirect index "$start lineend + 1 char"]

      # LexParser hangs while search next lexeme command if it
      # starts from "end" index. So ...
      if { [$wDirect compare $endComment >= end] } {
         set endComment [$wDirect index "$start lineend"]
      }
   } elseif { $lexeme2 == "/*" || $endComment == ""  || $startInComment } {
      if { $endComment == "" } {
         # Comment is not finished till $stopIndex

         # Get caller name
         set caller [namespace tail [lindex [info level -1] 0]]
         set endComment $stopIndex
      } else {
         set endComment [$wDirect index "$endComment + 2 chars"]
      }

   } else {
      set endComment [$wDirect index "$start + 1 char"]
      return $endComment
   }

   # Make requested operation
   switch -exact -- $op {
      tag {
         $w tag add comment $start $endComment
      }
      mark {
         [namespace parent]::BrowserComment $id $w $start $endComment
      }
   }

   # Parser's trace
   variable linearDebug
   if { $linearDebug } {
      parserTrace $wDirect $start $endComment $start $stopIndex "Comment: [$w get $start $endComment]"
   }

   return $endComment
}

proc getAlphaNumericWord { id w wDirect op scanIndexVar foundIndexVar {requestedWord ""} } {
#
# @comment   Scans text in the window $w/$wDirect starting at index in the
# @comment variable scanIndexVar and tries to find nearest alphanumeric lexeme
# @comment starting from letter and skipping comments.&p
#
# @comment   If nearest lexeme found is alphanumeric then it will be simply
# @comment returned if requestedWord is not specified at call or compared with
# @comment $requestedWord and will be returned if comparison was successfull.&p
#
# @comment   scanIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of lexeme found.&p
#
# @comment   If it is not so returns empty string. scanIndexVar and
# @comment foundIndexVar are indices of lexeme found.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                operation requested for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found lexeme position if scan was successful
# @argument    requestedWord     expected nearest lexeme
#
#   Results:
#
# @result   Procedure returns found alphanumeric lexeme or empty string.
# @result Variables scanIndexVar and foundIndexVar may be changed at success
#

   variable extendedIdentifiers

   upvar $scanIndexVar scanIndex
   upvar $foundIndexVar foundIndex

   set nonBlanksRE {\S}

   set identifierRE        {^[A-Za-z][A-Za-z_0-9]*}
   set escapedIdentifierRE {^\\[^\\]*\\}
   set removeBackslachRE   {^\\(.*)\\$}
   set commentRE           {^--}

   while 1 {

      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex]

      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanIndex $nonBlankIndex

      # Get rest of line. It is faster to match regular expressions
      # starting with ^ in the string then in the widget data
      set line [$wDirect get $scanIndex "$scanIndex lineend"]

      # Get alphanumeric lexeme into $word if it is possible
      if { [regexp $identifierRE $line word] } {
         break
      }
      # Get escaped lexeme into $word if it is possible
      #
      # Problem with file top_level_epf10k50sqc208.vhd
      #
      if { $extendedIdentifiers } {
         if { [regexp $escapedIdentifierRE $line word] } {
            break
         }
      }

      # Skip comment and try again
      if { [regexp $commentRE $line word] } {
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $op $scanIndex]
         continue
      }

      #
      # Fail to get word
      # TODO: next string seems to be needless
      #
      set foundIndex $scanIndex
      return ""
   }

   # Return lexeme found index
   set foundIndex $scanIndex

   if { $requestedWord == "" } {

      # Return position to continue scanning
      set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
      if { $extendedIdentifiers } {
         if { [regexp $removeBackslachRE $word matched wordWithoutBackslash] } {
            set word $wordWithoutBackslash
         }
      }
      return $word

   } else {

      if { [string equal -nocase $word $requestedWord] } {
         # Return position to continue scanning
         set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
         return $word
      }

   }
   return ""

}

proc getExactLexeme { id w wDirect op scanIndexVar searchRE } {
#
# @comment   Searches and returns string that match $searchRE simple regular
# @comment expression starting from position $scanIndexVar and ignoring
# @comment comments. If first encountered non-comment lexeme does not match
# @comment $searchRE search fails. scanIndexVar variable is changed to
# @comment reflect scan results.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      scan start position
# @argument    searchRE          simple search regular expression
#
# @comment   Results:&p
#
# @comment   Returns empty string if lexeme requested is not found at
# @comment $scanIndexVar (skipping comments). As a side effect
# @comment scanIndexVar is changed so it points to next lexeme and
# @comment all comments between old and new position are skipped.&p
#
# @comment   Returns string that matches $searchRE if lexeme requested is
# @comment found after $scanIndexVar (skipping comments). As a side effect
# @comment scanIndexVar is changed so it points to the end of lexeme found.&p
#

   upvar $scanIndexVar scanIndex

   #
   # Append to searched pattern start comment RE. Make RE matching only from the
   # search start point
   #
   set searchOrCommentRE ^($searchRE|--)

   while 1 {

      set lexemeIndex [$wDirect search -elide -nocase -regexp {\S} $scanIndex end]
      if { $lexemeIndex == "" } {
         # Fail to find non blank symbol starting at $scanIndex
         return ""
      }
      set scanIndex $lexemeIndex
      # Found non blank symbol starting at $scanIndex

      # Get rest of line
      set line [$wDirect get $scanIndex "$scanIndex lineend"]

      # Get in lexeme first looked for lexeme or comment beginning
      set lexeme [lindex [regexp -inline -nocase $searchOrCommentRE $line] 0]
      if { $lexeme == "" } {
         # Fail to find $searchCommentRE starting at $scanIndex
         return ""
      }

      if { ($lexeme == "--") || ($lexeme == "//") } {
         # Parse comment and move parser pointer
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $op $scanIndex]
         continue
      }

      # We have succeeded
      # $searchRE Found at $scanIndex: $lexeme
      set scanIndex [$wDirect index "$scanIndex + [string length $lexeme] chars"]
      break
   }

   # new search position $scanIndex
   return $lexeme
}

proc findClosingSymbol {ignoreSym sym w index} {
# @comment  This proc searches for a closing symbol, i.e. it can 
# @comment  look for a closing brace, paren, triangular paren, or any
# @comment  other of the client's choice, the sym is the symbol to look 
# @comment  for and ignoreSym is the opening symbol that should be 
# @comment  ignored, the function should take the index of the character
# @comment  immidietly succeeding the opening character.
# @argument sym - symbol to look for.
# @argument ignoreSym - opening symbol (should cause the folloyin sym
# @argument             to be ignored).
# @argument w - Text widget name.
# @argument index - start index for search.
# @result   -1 if not found, and the closing character index.
  
   set ignoreIdx [$w search $ignoreSym $index "$index lineend"]
   set idx       [$w search $sym $index "$index lineend"]
   
   switch -- $idx {
      "" {
         return -1;
      }
      default {
         if {($ignoreIdx == "") || ([$w compare $ignoreIdx >= $idx] == 1)} {
            return $idx
         } else {
            set newIdx [findClosingSymbol $ignoreSym $sym $w [$w index $ignoreIdx+1c]]
            return [findClosingSymbol $ignoreSym $sym $w [$w index $newIdx+1c]]            
         }
      }
   }
}

####################################################################################

proc getKeyword { {pattern *} } {
#
# @comment   Returns list of language keywords that match $pattern (using the
# @comment matching rules of "string match"). If $pattern is omitted - all
# @comment keywords will be returned.&p
# @comment   If language is not case sensitive - keywords should be returned
# @comment in the low case.&p
#
# @argument       pattern     something like argument of "string match"
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::getKeywords>&p
# @note - <proc ::HTE::LexParser::keywordCompletion>&p
#
   variable allKeywords
   variable HighlightRE
   
   set keywords $allKeywords
   foreach hlg {builtinFunction builtinMacros dataType \
                interfaceTypes chanTypes portTypes     \
                builtinConstant} {
      set specKeywords [string range $HighlightRE($hlg) 4 end-3]
      set specKeywords [split $specKeywords |]
      set keywords "$keywords $specKeywords"
   }
   set pattern [string tolower $pattern]
   set matchedKw ""
   foreach kw $keywords {
      set kw [string tolower $kw]
      if {[string match $pattern $kw]} {
         lappend matchedKw $kw
      }
   }
   return $matchedKw
}
