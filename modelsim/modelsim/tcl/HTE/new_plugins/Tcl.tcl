#HTEParser#tcl#LexTcl#Tcl scripts#TCL Plugin#tcl|tk|itcl|itk#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2003 All Rights Reserved
#
# =============================================================================

## Complementary script defining callbacks
## for Tcl plugin
array set codeTreeBlockDefinition {
   comment                    {"Comment"               {}}
   proc                       {"Procedure"             TclProc}
   namespace                  {"Namespace"             TclNamespace}
}

# By default, set all block types to be visible
if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
} else {
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) {namespace proc}
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
}

variable vaDebug 0
set linearDebug 0
array set linearParserState {}
set nonBlanksRE          {\S}

catch {
   set HighlightRE(keyWord) "(?:\\A|\[^$\])$HighlightRE(keyWord)"
}
set HighlightRE(operator) {[-+:%~\[\]*&<>=!|^]}
set HighlightRE(variable) {\$}

proc parseComment { id w wDirect start op } {
#
# @comment   Parses comment and returns index of character after the comment to
# @comment continue scanning. As a side effect adds tags or marks for comment
# @comment block according to request $op.
#
# @argument       id          window identifier
# @argument       w           window name
# @argument       wDirect     direct window name
# @argument       start       start comment index
# @argument       op          operation requested. Should be "tag" or "mark"
#

   set end {}
   set nonBlankIndex [$wDirect search -elide -backwards -regexp {\S} $start "$start linestart"]
   if { $nonBlankIndex != {} } {
      set nonBlank [$wDirect get $nonBlankIndex]
      if { $nonBlank == "\{" } {
         set end [$wDirect search -elide -regexp {\}} $start "$start lineend"]
      }
   }

   if { $end == {} } {
      # Comment region reaches one symbol after end of line
      set end [$wDirect index "$start lineend + 1 char"]
   }

   # LexParser hangs while search next lexeme command if it
   # starts from "end" index. So ...
   if { [$wDirect compare $end >= end] } {
      set end [$wDirect index "$start lineend"]
   }

   # Make requested operation
   switch -exact -- $op {
      tag {
         $w tag add comment $start $end
      }
      mark {
         [namespace parent]::BrowserComment $id $w $start $end
      }
   }
   return $end

}

proc linearInit { id fileName startLine endLine } {
#
# @comment   Performs linear parser initialization. Initializes internal parser's
# @comment data structures. Creates code browser tree.
#
# @argument       id          window identifier
# @argument       fileName    name of file loaded into editor's window
# @argument       startLine   start line of the region to be parsed
# @argument       endLine     end line of the region to be parsed
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::lexParser>&p
#

   variable linearParserState

   set linearParserState($id,quote)          {}
   set linearParserState($id,squareBrace)    {}
   set linearParserState($id,curlyBrace)     0
   set linearParserState($id,firstWord)      0
   set linearParserState($id,lastScanIndex)  1.0

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

proc getName { w wDirect scanIndexVar foundIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest lexeme.&p
#
# @comment   If lexeme found is identifier then it will be returned,
# @comment scanIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of identifier found.&p
#
# @comment   If it is not so returns empty string. scanIndexVar and
# @comment foundIndexVar are indices of lexeme found.&p
#
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found identifier position if scan was successful
#
# @comment   Results:&p
#
# @comment   - Procedure return found identifier or empty string. Variables
# @comment scanIndexVar and foundIndexVar may be changed at success&p
#

   upvar $scanIndexVar scanIndex
   upvar $foundIndexVar foundIndex

   variable nonBlanksRE

#20.06.2002   set identifierRE {^[A-Za-z:][A-Za-z_0-9:]*}
   set identifierRE {^\S+}

   while 1 {
      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex "$scanIndex lineend"]

      if { $nonBlankIndex == {} } {
         return {}
      }
      set scanIndex $nonBlankIndex
      set nonBlank [$wDirect get $scanIndex]

      # Check if it is symbol of line continuation
      if { $nonBlank == "\\" && [$wDirect get "$scanIndex +1 char"] == "\n" } {
#        putLog "Found line continuation at $scanIndex. Continue at next line"
         set scanIndex [$wDirect index "$scanIndex +1 line linestart"]
         continue
      }

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

      # Get name into $word if it is possible
      if { [regexp $identifierRE $line word] } {
         break
      }

      # Fail to get identifier
      set foundIndex $scanIndex
      return {}
   }

   set foundIndex $scanIndex
   set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]

   return $word

}

proc getVariableName { w wDirect scanIndexVar foundIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest lexeme.&p
#
# @comment   If lexeme found is identifier then it will be returned,
# @comment scanIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of identifier found.&p
#
# @comment   If it is not so returns empty string. scanIndexVar and
# @comment foundIndexVar are indices of lexeme found.&p
#
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found identifier position if scan was successful
#
# @comment   Results:&p
#
# @comment   - Procedure return found identifier or empty string. Variables
# @comment scanIndexVar and foundIndexVar may be changed at success&p
#

   upvar $scanIndexVar scanIndex
   upvar $foundIndexVar foundIndex

   variable nonBlanksRE

   set identifierRE {^\w+}

   while 1 {
      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex "$scanIndex lineend"]

      if { $nonBlankIndex == {} } {
         return {}
      }
      set scanIndex $nonBlankIndex
      set nonBlank [$wDirect get $scanIndex]

      # Check if it is symbol of line continuation
      if { $nonBlank == "\\" && [$wDirect get "$scanIndex +1 char"] == "\n" } {
#        putLog "Found line continuation at $scanIndex. Continue at next line"
         set scanIndex [$wDirect index "$scanIndex +1 line linestart"]
         continue
      }

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

      # Get name into $word if it is possible
      if { [regexp $identifierRE $line word] } {
         break
      }

      # Fail to get identifier
      set foundIndex $scanIndex
      return {}
   }

   set foundIndex $scanIndex
   set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]

   return $word

}


proc getWord { w wDirect scanIndexVar foundIndexVar {compareWith ""} } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest word.&p
#
# @comment   If lexeme found is valid word and $compareWith is an empty string
# @comment then it will be returned, if lexeme found is valid word and is equal
# @comment to non-empty $compareWith then it will be returned too,
# @comment scanIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of identifier found.&p
#
# @comment   If it is not so returns empty string. scanIndexVar and
# @comment foundIndexVar are indices of lexeme found.&p
#
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found identifier position if scan was successful
# @argument    compareWith       when non-empty, should be used to compare with found word
#
# @comment   Results:&p
#
# @comment   - Procedure return found identifier or empty string. Variables
# @comment scanIndexVar and foundIndexVar may be changed at success&p
#

   upvar $scanIndexVar scanIndex
   upvar $foundIndexVar foundIndex

   variable nonBlanksRE

   set wordRE {^[A-Za-z][A-Za-z_0-9]*}

   set delimiterDefinition {[][\\"#\s]}; #"

   while 1 {
      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex]

      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanIndex $nonBlankIndex
      set nonBlank [$wDirect get $scanIndex]

      # Check if it is symbol of line continuation
      if { $nonBlank == "\\" && [$wDirect get "$scanIndex +1 char"] == "\n" } {
#        putLog "Found line continuation at $scanIndex. Continue at next line"
         set scanIndex [$wDirect index "$scanIndex +1 line linestart"]
         continue
      }
###      set lineContinuationIndex [$wDirect search -regexp $lineContinuationRE $scanIndex]
###      if { $lineContinuationIndex != "" } {
###         set scanIndex [$wDirect index "$scanIndex + 1 line linestart"]
###         continue
###      }

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

      # Get name into $word if it is possible
      if { [regexp $wordRE $line word] } {
         break
      }

      # Fail to get identifier
      set foundIndex $scanIndex
      return ""
   }

   set foundIndex $scanIndex
   if { $compareWith == "" } {
      set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
      return $word
   } else {
      if { [string equal $word $compareWith] } {
         set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
         return $word
      }
   }
   return ""

}

proc validScript { id wDirect start } {
#
# @comment   Return 1 if valid script is followed by $start and 0 otherwise
#
# @argument    id       window identifier
# @argument    wDirect  window name
# @argument    start    text position before script
#

   variable nonBlanksRE

   set scanIndex $start
   while 1 {

      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex]
      if { $nonBlankIndex == {} } {
         break
      }

      set scanIndex $nonBlankIndex
      set nonBlank [$wDirect get $scanIndex]
#     putLog "LexTcl::validScript: $scanIndex: $nonBlank Lineend: [$wDirect index "$scanIndex lineend"]"

      # Check if it is symbol of line continuation
      if { $nonBlank == "\\" && [$wDirect get "$scanIndex +1 char"] == "\n" } {
#        putLog "LexTcl::validScript: Found line continuation at $scanIndex. Continue at next line"
         set scanIndex [$wDirect index "$scanIndex +1 line linestart"]
         continue
      }

      switch -exact -- $nonBlank {
         \{   {
            return 1
         }
      }

      break
   }

   return 0
}


proc namespaceCmd { id w wDirect start end } {
#
# @comment   Namespace command parser extension. For "namespace eval" subcommand
# @comment creates list of nested namespaces. Adds namespace eval block
# @comment definition into blockList and namespaceList stacks and call code
# @comment browser to update the code tree.&p
#
# @argument    id       window identifier
# @argument    w        window name
# @argument    wDirect  direct window name
# @argument    start    start position of parsed keyword
# @argument    end      end position of parsed keyword
#
# @comment   Results:&p
#
# @comment     - namespace definition is pushed into stack of opened lexical blocks&p
# @comment     - nodes that represent nested namespaces are created in the code browser tree&p
#

#
#  namespace children ?namespace? ?pattern?
#  namespace code script
#  namespace current
#  namespace delete ?namespace namespace ...?
#  namespace eval namespace arg ?arg ...?
#  namespace export ?-clear? ?pattern pattern ...?
#  namespace forget ?pattern pattern ...?
#  namespace import ?-force? ?pattern pattern ...?
#  namespace inscope namespace arg ?arg ...?
#  namespace origin command
#  namespace parent ?namespace?
#  namespace qualifiers string
#  namespace tail string
#  namespace which ?-command? ?-variable? name
#

   set scanIndex $end

   if { [[namespace current]::getWord $w $wDirect scanIndex foundWordIndex "eval"] == "" } {
      return $end
   }

   set namespaceName [[namespace current]::getName $w $wDirect scanIndex namespaceNameIndex]
   if { $namespaceName == "" } {
      return $end
   }
   set name $namespaceName

   set type namespace

#  putLog "LexTcl::namespaceCmd 1: Namespace eval: \"$namespaceName\" starting at $namespaceNameIndex"

   #
   # Currently parser can process namespace eval code blocks that have
   # only so named "valid" script as arguments. So - bypass
   # code block creation for "invalid" script
   #
   if { [validScript $id $wDirect $scanIndex] } {

      # Create list of name qualifiers (as node names) and
      # name qualifiers tails (as node labels) starting from top
      set qualifiersList [[namespace current]::parseFullyQualifiedName $id $start $type $name]

      # Get list of nodes definitions created by parseFullyQualifiedName
      # and build set of code tree nodes
      [namespace current]::makeFullyQualifiedTree $id $w $qualifiersList

   }

   return $scanIndex
}

proc skipArgs { wDirect scanIndexVar } {
#
# @comment   Gets as arguments text widget window name and index of position
# @comment where proc arguments should be located. Tries to move scan index
# @comment to position just after arguments.&p
#
# @argument    wDirect           direct window name
# @argument    scanIndexVar      position of proc arguments index
#
# @comment   Results:&p
#
# @comment     - If valid proc arguments are found then scanIndexVar is
# @comment changed to position just after proc args. Otherwise it is at the
# @comment position where recognition is failed.&p
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   variable nonBlanksRE

   set braceRE          {\{|\}}
   set blanksRE         {\s}

   set curlyBrackets    0

   while 1 {

      # Get in cbIndex first nonblank symbol index
      set cbIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex "$scanIndex lineend"]

      if { $cbIndex != "" } {

         set cb [$wDirect get $cbIndex]

         if       { $cb == "\{" } {

            # First symbol is left curly brace
            incr curlyBrackets
            set scanIndex [$wDirect index "$cbIndex + 1 char"]
            break

         } elseif { $cb == "\}" } {

            # It should not be so
            return

         } elseif { $cb == "\\" && [$wDirect index $cbIndex] == [$wDirect index "$cbIndex - 1 char lineend"] } {

            # It is empty line with line continuation
            set scanIndex [$wDirect index "$cbIndex + 1 line + linestart"]
            continue

         } else {

            # No curly braces
            set blankIndex [$wDirect search -regexp $blanksRE $scanIndex "$scanIndex lineend"]
            if { $blankIndex != "" } {
               set scanIndex $blankIndex
            }
            return
         }

      } else {

         # Blank rest of line
         set scanIndex [$wDirect index "$scanIndex + 1 line linestart"]
         return

      }

   }

   while 1 {

      # Get in cbIndex first curly brace symbol index
      set cbIndex [$wDirect search -elide -regexp $braceRE $scanIndex "$scanIndex lineend"]

      if { $cbIndex != "" } {

         set cb [$wDirect get $cbIndex]

         if       { $cb == "\{" } {

            # Left curly brace found
            incr curlyBrackets

         } elseif { $cb == "\}" } {

            # Right curly brace found
            incr curlyBrackets -1
            if { $curlyBrackets == "0" } {
               set scanIndex [$wDirect index "$cbIndex + 1 char"]
               return
            }

         } else {

            # Something strange found
            return

         }
         set scanIndex [$wDirect index "$cbIndex + 1 char"]

      } else {

         set lastSymbol [$wDirect get [$wDirect index "$scanIndex lineend - 1 char"]]

         if { $lastSymbol == "\\" } {
            # Line continuation
            set scanIndex [$wDirect index "$scanIndex + 1 line linestart "]
            continue
         }
         # Unbalanced braces
         return

      }

   }

}

proc parseFullyQualifiedName { id start type name } {
#
# @comment   Parses Tcl identifier and returns list of name qualifiers (can be
# @comment used as node names) and name qualifiers tails (for using as node
# @comment labels) starting from top.
#
# @argument    id          window identifier
# @argument    start       start block index
# @argument    type        block type, should be "namespace" or "proc"
# @argument    name        fully qualified name
#

   variable linearParserState

   if { $name == {} } {
      return {}
   }

   if { [regexp {^::} $name] } {
      # Name started with "::" so
      # it's absolutely specified procedure block name
   } else {
      # It is relatively specified name. Try to transform it to absolutely one
      if { [expr [namespaceStack$id size] == 0] } {
         set name \:\:$name
      } else {
         # Get parent fully specified namespace name
         set parent [namespaceStack$id peek 1]
         # And make appropriate block name
         if { [string equal $parent "::"] } {
            set name \:\:$name
         } else {
            set name $parent\:\:$name
         }
      }
   }

   # Push block definition into appropriate stack
   blockStack$id push [list $type $linearParserState($id,curlyBrace)]
   ${type}Stack$id push $name
#  putLog "Push fully qualified proc name: \"$name\". Stack size: [procStack$id size]/[blockStack$id size]"

   if { $name == "::" } {
      return [list namespace "::" "::" $start]
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
         set part "::"
         set qualifiersList [linsert $qualifiersList 0 namespace $part $part {}]
         break
      }
      set qualifiersList [linsert $qualifiersList 0 namespace $part [namespace tail $part] {}]
   }

   return $qualifiersList
}

proc makeFullyQualifiedTree { id w qualifiersList } {
#
# @comment   Gets as parameter list of nodes definitions created by
# @comment parseFullyQualifiedName and builds set of code tree nodes.
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    qualifiersList list of lists of node qualifier and label
#

   # Initial parentId value. For "parserContext $id getTcl" subfunction
   # it means get context for building node under root
   set parentId {}

   foreach {type qualifier qualifierLabel start} $qualifiersList {

#     putLog "LexTcl::makeFullyQualifiedTree: Part: \"$type\" \"$qualifier\" Label: \"$qualifierLabel\" Start: $start"

      # Segregate dummy nodes
      if { $start == {} } {
         set style Dummy
      } else {
         set style Tcl
      }

      # Get appropriate icon name
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

      # Register new block and get unique identifier
      set name [namespace tail $qualifier]

      if { $name == {} } {
         set name "::"
      }

      set blockId [[namespace parent]::parserContext $id register $type $name $style]
#     putLog "LexTcl::makeFullyQualifiedTree: blockId: $blockId"

      # Create parser context needed
      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id getTcl $parentId] {}
#     putLog "LexTcl::makeFullyQualifiedTree: Operation: $operation ParentId: $parentId Before: $beforeNode"

      # Create new or update existing code tree node
      [namespace parent]::BrowserNode              \
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
   # Push last (real) block definition into parser's context
#  putLog "LexTcl::makeFullyQualifiedTree: PUSH $blockId $type $name $style"
   [namespace parent]::parserContext $id push $blockId
}

proc procCmd { id w wDirect start end } {
#
# @comment   Proc command parser extension. For "proc" keyword:&p
#
# @comment     - get procedure name in procName&p
# @comment     - proc definition is pushed into stack of opened lexical blocks&p
# @comment     - nodes that represent parts of proc name are created in the code browser tree&p
#
# @argument    id       window identifier
# @argument    w        window name
# @argument    wDirect  direct window name
# @argument    start    start position of parsed keyword
# @argument    end      end position of parsed keyword
#

#
#  proc name args body
#

   set scanIndex $end

   # Get proc name or exit
   set procName [[namespace current]::getName $w $wDirect scanIndex procNameIndex]
   if { $procName == "" } {
      return $end
   }
   set name $procName
   set type proc

#  putLog "LexTcl::procCmd: Proc: \"$procName\" at $procNameIndex"

   # Skip arguments
   skipArgs $wDirect scanIndex

   #
   # Currently parser can process proc code blocks that have
   # only so named "valid" script as arguments. So - bypass
   # code block creation for "invalid" script
   #
   if { [validScript $id $wDirect $scanIndex] } {

      # Create list of name qualifiers (as node names) and
      # name qualifiers tails (as node labels) starting from top
      set qualifiersList [[namespace current]::parseFullyQualifiedName $id $start $type $name]

      # Get list of nodes definitions created by parseFullyQualifiedName
      # and build set of code tree nodes
      [namespace current]::makeFullyQualifiedTree $id $w $qualifiersList
   }

   return $scanIndex
}

proc variableName { id w wDirect start end } {
#
# @comment   Variable name parser extension. Gets variable name and adds it into
# @comment parser's declaration context.
#
# @argument    id       window identifier
# @argument    w        window name
# @argument    wDirect  direct window name
# @argument    start    start position of parsed keyword
# @argument    end      end position of parsed keyword
#

#
#  set varName ?value?
#  variable ?name value...? name ?value?
#
   set scanIndex $end

   # Get variable name or exit
   set varName [[namespace current]::getVariableName $w $wDirect scanIndex varNameIndex]
   if { $varName == "" } {
      return $end
   }

   [namespace parent]::declarationParserContext $id $w addLocal variable $varName $start $varNameIndex

#  putLog "LexTcl::varCmd: Variable: \"$varName\" at $varNameIndex"
   return $scanIndex
}

proc blockCompletion { id w start } {
#
# @comment   Completes opened code block
#
# @argument    id       window identifier
# @argument    w        window name
# @argument    start    start position of parsed keyword
#

   # Check whether block stack is not empty
   if { [expr [blockStack$id size] > 0] } {

      # Get reference to block definition
      set type [lindex [blockStack$id pop] 0]

      # If referenced block stack is not empty
      if { [expr [${type}Stack$id size] > 0] } {

         # Pop top definition
         set qualifier [${type}Stack$id pop]
         set name [namespace tail $qualifier]
#        putLog "Pop: $blockRef/$name Block stack size [${type}Stack$id size]/[blockStack$id size]"

         # Pop block definition from parser's context
#        putLog "LexTcl::blockCompletion: POP"
         set blockId [[namespace parent]::parserContext $id pop]

         # Internal plug-in block stack is used, so previos $blockId is thrown away
         set blockId [[namespace parent]::parserContext $id getId $type $name]
         if { $blockId != {} } {
            [namespace parent]::BrowserCompleteNode  \
                                    $id               \
                                    $w                \
                                    $blockId          \
                                    $start
         } else {
            ::HTE::Console::putLog "LexTcl::blockCompletion: block \"$name\" of type \"$type\" is not registered at $start"
         }

      } else {

         # Report that specific block stack is empty
         ::HTE::Console::putLog "Pop: $type - invalid. Block stack size [${type}Stack$id size]/[blockStack$id size]"

      }

   } else {
      # Report that stack of block definitions is empty
      ::HTE::Console::putLog "Block stack empty at $start"
   }

}


proc getRule { keyWordVar } {
#
# @comment Returns rule for processing $keyWordVar referenced keyword
#
# @argument keyWordVar reference to variable with ketword
#

   upvar $keyWordVar keyWordIndex
   return $keyWordIndex
}

proc getVariableSubstitution { wDirect scanStartIndex } {
#
# @comment   Should be called to recognize variable substitution. Gets as
# @comment arguments text widget window name and index of position
# @comment just after $ symbol in the word. Returns index of position just after
# @comment variable substitution or unchanged scanStartIndex if recognition
# @comment failed.&p
#
# @argument    wDirect        window name
# @argument    scanStartIndex index of position just after $ symbol in the word
#
# @comment   Results:&p
#
# @comment     - Returns next scanning position&p
#


#
#   $name
#      Name is the name of a scalar variable; the name is terminated
#      by any character that isn't a letter, digit, or underscore.
#
#   $name(index)
#      Name gives the name of an array variable and index gives the
#      name of an element within that array. Name must contain only
#      letters, digits, and underscores. Command substitutions, variable
#      substitutions, and backslash substitutions are performed on the
#      characters of index.
#
#   ${name}
#      Name is the name of a scalar variable. It may contain any
#      characters whatsoever except for close braces.
#

   variable nameCount

   set nameSymbolRE     {[a-zA-Z0-9_]}
   set nameRE           {[a-zA-Z0-9_]+}
   set leftBraceRE      {\{}
   set anyNameSymbolRE  {[^\}]*}


   set scanIndex $scanStartIndex

   set nameIndex [$wDirect search -elide -regexp $nameSymbolRE $scanIndex "$scanIndex + 1 char"]
   if { $nameIndex != "" } {
      set nameIndex [$wDirect search -elide -count [namespace current]::nameCount -regexp $nameRE $scanIndex "$scanIndex lineend"]
      return [$wDirect index "$scanStartIndex + $nameCount chars"]
   }

   set braceIndex [$wDirect search -elide -regexp $leftBraceRE $scanIndex "$scanIndex + 1 char"]
   if { $braceIndex != "" } {
      set nameCount 0
      set nameIndex [$wDirect search -elide -count [namespace current]::nameCount -regexp $anyNameSymbolRE "$scanIndex + 1 char"]
      return [$wDirect index "$scanStartIndex + $nameCount chars + 2 chars"]
   }

   return $scanStartIndex
}

proc backslashSubstitutionLength { w index } {
#
# @comment   Return length of backslash substitution started at $index for
# @comment widget $w
#
# @argument    w        window name
# @argument    index    text widget index that points to backslash substitution beginning
#

#
#    If a backslash (``\'') appears within a word then backslash substitution occurs.
#  In all cases but those described below the backslash is dropped and the
#  following character is treated as an ordinary character and included in the
#  word. This allows characters such as double quotes, close brackets, and dollar
#  signs to be included in words without triggering special processing.
#  The following table lists the backslash sequences that are handled specially,
#  along with the value that replaces each sequence.
#
#     \a                      Audible alert (bell) (0x7).
#     \b                      Backspace (0x8).
#     \f                      Form feed (0xc).
#     \n                      Newline (0xa).
#     \r                      Carriage-return (0xd).
#     \t                      Tab (0x9).
#     \v                      Vertical tab (0xb).
#     \<newline>whiteSpace    A single space character replaces the backslash, newline,
#                             and all spaces and tabs after the newline. This backslash
#                             sequence is unique in that it is replaced in a separate
#                             pre-pass before the command is actually parsed. This means
#                             that it will be replaced even when it occurs between
#                             braces, and the resulting space will be treated as a word
#                             separator if it isn't in braces or quotes.
#     \\                      Backslash (``\'').
#     \ooo                    The digits ooo (one, two, or three of them) give an eight-bit
#                             octal value for the Unicode character that will be inserted.
#                             The upper bits of the Unicode character will be 0.
#     \xhh                    The hexadecimal digits hh give an eight-bit hexadecimal value
#                             for the Unicode character that will be inserted. Any number
#                             of hexadecimal digits may be present; however, all but the
#                             last two are ignored (the result is always a one-byte quantity).
#                             The upper bits of the Unicode character will be 0.
#     \uhhhh                  The hexadecimal digits hhhh (one, two, three, or four of them)
#                             give a sixteen-bit hexadecimal value for the Unicode character
#                             that will be inserted.
#
#    Backslash substitution is not performed on words enclosed in braces, except for
#  backslash-newline as described above.
#

   set backslashSubstitution [$w get "$index +1 char" "$index +6 char"]
   switch -regexp -- $backslashSubstitution {
      [0-7][0-7][0-7] {
         set length 4
      }
      [0-7][0-7]   {
         set length 3
      }
      x[[:xdigit:]][[:xdigit:]]  {
         set length 4
      }
      u[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]  {
         set length 6
      }
      default  {
         set length 2
      }
   }

   return $length
}

proc firstCharacterOfFirstWord { id } {
#
# @comment   Returns first symbol of first word of command
#
# @argument    id       window name
#

#
#  If a hash character (``#'') appears at a point where Tcl is expecting
#  the first character of the first word of a command, then the hash
#  character and the characters that follow it, up through the next
#  newline, are treated as a comment and ignored. The comment
#  character only has significance when it appears at the beginning
#  of a command.
#

   variable linearParserState

   return $linearParserState($id,firstWord)
}

proc linear { id w wDirect start end limit } {
#
# @comment   Internal (linear) plug-in exported parser. Parses requested range $start .. $end
# @comment and builds code tree.
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    start       start position to parse
# @argument    end         end position to parse
# @argument    limit       maximum number of lines to be parsed
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::linearCB>&p
# @note - <proc ::HTE::LexParser::inMotion>&p
#
#
#stackTrace
   variable linearDebug

   variable linearParserState

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
   set delimiterDefinition {[][\"#\s\$\{\}]}

   variable matchedCount

   set lineContinuation 0

   while 1 {

      if { [$wDirect compare $scanIndex >= $scanLimitIndex] } {
         set linearParserState($id,lastScanIndex) $scanIndex
         return $scanIndex
      }

      set lexemeIndex [$wDirect search -elide -count [namespace current]::matchedCount -regexp $wordDefinition $scanIndex $scanStopIndex ]

      if { $lexemeIndex == {} } {
         return $end
      }

      if       { $lineContinuation } {
         # Backslash-<newline> was processed
      } elseif { [$wDirect compare $lexemeIndex >= "$scanIndex +1 line linestart"] } {
         # Newline is the command delimiter
         set linearParserState($id,firstWord) 1
      }

#      if { $linearDebug } {
#         set st [open hte.debug a]
#         puts $st "First character of first word: $linearParserState($id,firstWord)"
#         close $st
#      }

      set lexemeStartSymbol [$wDirect get $lexemeIndex]
      set lineContinuation 0

      switch -exact -- $lexemeStartSymbol {

         \\    {
                  # Backslash substitution

                  set length [backslashSubstitutionLength $wDirect $lexemeIndex]
                  set nextLexemeIndex [$wDirect index "$lexemeIndex +$length char"]

                  set bsChar [$w get "$lexemeIndex +1 char"]
                  if { $bsChar == "\n" } {
                     set lineContinuation 1
                  } else {
                     set linearParserState($id,firstWord) 0
                  }

                  if { $linearDebug } {
                     set lexeme "Escape:  [$wDirect get $lexemeIndex $nextLexemeIndex]"
                  }
         }

         #     {
                  if { [firstCharacterOfFirstWord $id] } {

                     set nextLexemeIndex [[namespace current]::parseComment $id $w $wDirect $lexemeIndex mark]
                     set linearParserState($id,firstWord) 1

                     if { $linearDebug } {
                        set lexeme "Comment: [$wDirect get $lexemeIndex $nextLexemeIndex]"
                     }

                  } else {

                     set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
                     set linearParserState($id,firstWord) 0

                     if { $linearDebug } {
                        set lexeme "Non Comment: [$wDirect get $lexemeIndex $nextLexemeIndex]"
                     }

                  }

         }

         "{"   {
                  set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
                  incr linearParserState($id,curlyBrace)
                  # Next character will be first one of the first word of a command
                  set linearParserState($id,firstWord) 1

                  if { $linearDebug } {
                     set lexeme "L-Brace: $linearParserState($id,curlyBrace) [$wDirect get $lexemeIndex $nextLexemeIndex]"
                  }

         }

         "}"   {
                  set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
                  if { [expr $linearParserState($id,curlyBrace) > 0] } {
                     incr linearParserState($id,curlyBrace) -1
                  }

                  #
                  # Get block (that should be closed) level and check whether it
                  # corresponds to last code block. If so - complete it
                  #

                  # Check whether block stack is not empty
                  if { [expr [blockStack$id size] > 0] } {
                     # Get level of top block and compare it with current one
                     set blockCurlyCount [lindex [blockStack$id peek 1] 1]
                     if { [expr $linearParserState($id,curlyBrace) == $blockCurlyCount] } {
                        # Complete block
                        [namespace current]::blockCompletion $id $w $nextLexemeIndex
                     }
                  }

                  set linearParserState($id,quote) {}
                  set linearParserState($id,firstWord) 0

                  if { $linearDebug } {
                     set lexeme "R-Brace: $linearParserState($id,curlyBrace) [$wDirect get $lexemeIndex $nextLexemeIndex]"
                  }
         }

         \"    {
                  # Double-quote

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

         \[   {
                  lappend linearParserState($id,squareBrace) [list $lexemeIndex $linearParserState($id,quote)]

                  set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
                  set linearParserState($id,quote) ""
                  # Next character will be first one of the first word of a command
                  set linearParserState($id,firstWord) 1

                  if { $linearDebug } {
                     set lexeme "Sq O Br: [$wDirect get $lexemeIndex $nextLexemeIndex]"
                  }
         }

         \]   {
                  set squareBrace $linearParserState($id,squareBrace)
                  if { [llength $squareBrace] > 0 } {

                     set startOfCodeBlock             [lindex [lindex $squareBrace end] 0]
                     set linearParserState($id,quote) [lindex [lindex $squareBrace end] 1]

#                    $w tag add codeBlock $startOfCodeBlock [$wDirect index "$lexemeIndex + 1 char"]
                     set squareBrace [lreplace $squareBrace end end]
                     set linearParserState($id,squareBrace) $squareBrace

                  }

                  set nextLexemeIndex [$wDirect index "$lexemeIndex + 1 char"]
                  set linearParserState($id,firstWord) 0

                  if { $linearDebug } {
                     set lexeme "Sq C Br: [$wDirect get $lexemeIndex $nextLexemeIndex]"
                  }
         }

         $     {
                  set nextLexemeIndex [getVariableSubstitution $wDirect [$wDirect index "$lexemeIndex + 1 char"]]
                  set linearParserState($id,firstWord) 0

                  if { $linearDebug } {
                     set lexeme "V Subst: [$wDirect get $lexemeIndex $nextLexemeIndex]"
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

                     if { [info exists [namespace current]::prsCallbacks($lexeme)] } {

                        set rule [[namespace current]::getRule [namespace current]::prsCallbacks($lexeme)]
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

proc parserVA {id w start end} {
#
# @comment   Language specific highlighting parser.
# @comment   Sets tags for syntax highlighting for requested area $start .. $end
#
# @argument       id       window identifier
# @argument       w        text widget window name
# @argument       start    text start index
# @argument       end      text stop index
#

   set scanStartIndex $start
   set scanStopIndex  $end

   set wordDefinition {\S+}
   set delimiterDefinition {[][\\"#\s\$\{\}]} ;#"

   set quote {}
   # Local lists
   set squareBrace {}
   set curlyBrace {}

   variable matchedCount

   while 1 {

      if { [$w compare $scanStartIndex >= $scanStopIndex] } {

         if { [catch {::SyntaxHighlight::doParsing $id highlight LexTcl $w $start $end 0} errCode] } {
            puts "SyntaxHighlight::doParsing: $errCode"
         }

         return $scanStartIndex
      }

      set lexemeIndex [$w search -elide -count [namespace current]::matchedCount \
         -regexp $wordDefinition $scanStartIndex $scanStopIndex ]

      if { $lexemeIndex == "" } {

         if { [catch {::SyntaxHighlight::doParsing $id highlight LexTcl $w $start $end 0} errCode] } {
            puts "SyntaxHighlight::doParsing: $errCode"
         }

         return $end
      }

      set lexemeStartSymbol [$w get $lexemeIndex]

      switch -exact -- $lexemeStartSymbol {
      
         #     {
                  set nextLexemeIndex [$w index "$lexemeIndex lineend +1c"]
               }

         \\    {
                  # Backslash substitution

                  set length [backslashSubstitutionLength $w $lexemeIndex]
                  set nextLexemeIndex [$w index "$lexemeIndex +$length char"]

                  set bsChar [$w get "$lexemeIndex +1 char"]
                  if { $bsChar == "\n" } {
                     $w tag add lineContinuation $lexemeIndex
                  }
               }

         \"    {
                  # Double-quote
                  # Local quote variable is used

                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  if { $quote == {} } {
                     set quote $lexemeIndex
                  } else {
                     $w tag add string $quote $nextLexemeIndex
                     set quote {}
                  }
               }

         "{"   {
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  lappend curlyBrace $quote
                  set quote {}
               }

         "}"   {
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  set quote {}
                  if { [expr [llength $curlyBrace] > 0] } {
                     set quote [lindex $curlyBrace end]
                     set curlyBrace [lreplace $curlyBrace end end]
                  }
               }


         "["   {
                  lappend squareBrace [list $lexemeIndex $quote]
                  set quote ""
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex
               }

         "]"   {
                  if { [llength $squareBrace] > 0 } {
                     set startOfCodeBlock [lindex [lindex $squareBrace end] 0]
                     set quote            [lindex [lindex $squareBrace end] 1]

                     set squareBrace [lreplace $squareBrace end end]
                     $w tag add codeBlock $startOfCodeBlock [$w index "$lexemeIndex + 1 char"]
                  }
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex
               }

         $     {
                  set nextLexemeIndex [getVariableSubstitution $w [$w index "$lexemeIndex + 1 char"]]
                  $w tag add variable $lexemeIndex $nextLexemeIndex
               }

         default  {
                     #set nextLexemeIndex [$w search -elide -regexp $delimiterDefinition                    \
                                                                 $lexemeIndex                       \
                                                                 [$w index "$lexemeIndex lineend"]]
                     set nextLexemeIndex [$w search -elide -regexp $delimiterDefinition \
                        [$w index "$lexemeIndex + 1 char"] [$w index "$lexemeIndex lineend"]]
                     if { $nextLexemeIndex == "" } {
                        set nextLexemeIndex [$w index "$lexemeIndex + $matchedCount chars"]
                     }
                  }
      }

      set scanStartIndex $nextLexemeIndex

   }

}

proc parserVA_original {id w start end} {
#
# @comment   Language specific highlighting parser.
# @comment   Sets tags for syntax highlighting for requested area $start .. $end
#
# @argument       id       window identifier
# @argument       w        text widget window name
# @argument       start    text start index
# @argument       end      text stop index
#

   variable vaDebug

   if { $vaDebug } {
      set st [open hte.vaDebug a]
      puts $st "+++ VA parser: $w \[$start - $end\]"
      close $st
   }

   set scanStartIndex $start
   set scanStopIndex  $end

   set wordDefinition {\S+}
   set delimiterDefinition {[][\\"#\s\$\{\}]} ;#"

   set quote {}
   # Local lists
   set squareBrace {}
   set curlyBrace {}

   variable matchedCount

   while 1 {

      if { [$w compare $scanStartIndex >= $scanStopIndex] } {
         return $scanStartIndex
      }

      set lexemeIndex [$w search -elide -count [namespace current]::matchedCount -regexp $wordDefinition $scanStartIndex $scanStopIndex ]

      if { $lexemeIndex == "" } {
         return $end
      }

      set lexemeStartSymbol [$w get $lexemeIndex]

      switch -exact -- $lexemeStartSymbol {

         \\    {
                  # Backslash substitution

                  set length [backslashSubstitutionLength $w $lexemeIndex]
                  set nextLexemeIndex [$w index "$lexemeIndex +$length char"]

                  set bsChar [$w get "$lexemeIndex +1 char"]
                  if { $bsChar == "\n" } {
                     $w tag add lineContinuation $lexemeIndex
                  }

                  if { $vaDebug } {
                     set lexeme "Escape:  [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         #     {
                  set comment 0
                  set nonBlankIndex [$w search -elide -backwards -regexp {\S} $lexemeIndex "$lexemeIndex linestart"]
                  if { $nonBlankIndex != {} } {
                     set nonBlank [$w get $nonBlankIndex]
                     if { $nonBlank == "\{" } {
                        set comment 1
                     }
                  } else {
                     set comment 1
                  }

                  if { $comment } {

                     set nextLexemeIndex [[namespace current]::parseComment $id $w $w $lexemeIndex tag]
                     if { $vaDebug } {
                        set lexeme "Comment: [$w get $lexemeIndex $nextLexemeIndex]"
                     }

                  } else {
                     set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  }
               }

         "{"   {
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  lappend curlyBrace $quote
                  set quote {}

                  if { $vaDebug } {
                     set lexeme "L-Brace:   [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         "}"   {
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  set quote {}
                  if { [expr [llength $curlyBrace] > 0] } {
                     set quote [lindex $curlyBrace end]
                     set curlyBrace [lreplace $curlyBrace end end]
                  }

                  if { $vaDebug } {
                     set lexeme "R-Brace:   [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }


         \"    {
                  # Double-quote
                  # Local quote variable is used

                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  if { $quote == {} } {
                     set quote $lexemeIndex
                  } else {
                     $w tag add literal $quote $nextLexemeIndex
                     set quote {}
                  }

                  if { $vaDebug } {
                     if { $quote == {} } {
                        set quoteTag "C Quote: "
                     } else {
                        set quoteTag "O Quote: "
                     }
                     set lexeme "$quoteTag[$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         "["   {
                  lappend squareBrace [list $lexemeIndex $quote]
                  set quote ""
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  if { $vaDebug } {
                     set lexeme "Sq O Br: [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         "]"   {
                  if { [llength $squareBrace] > 0 } {
                     set startOfCodeBlock [lindex [lindex $squareBrace end] 0]
                     set quote            [lindex [lindex $squareBrace end] 1]

                     set squareBrace [lreplace $squareBrace end end]
                     $w tag add codeBlock $startOfCodeBlock [$w index "$lexemeIndex + 1 char"]
                  }
                  set nextLexemeIndex [$w index "$lexemeIndex + 1 char"]
                  $w tag add codeBlockBound $lexemeIndex $nextLexemeIndex

                  if { $vaDebug } {
                     set lexeme "Sq C Br: [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         $     {
                  set nextLexemeIndex [getVariableSubstitution $w [$w index "$lexemeIndex + 1 char"]]

                  if { $vaDebug } {
                     set lexeme "V Subst: [$w get $lexemeIndex $nextLexemeIndex]"
                  }
               }

         default  {
                     set nextLexemeIndex [$w search -elide -regexp $delimiterDefinition                    \
                                                                 $lexemeIndex                       \
                                                                 [$w index "$lexemeIndex lineend"]]
                     if { $nextLexemeIndex == "" } {
                        set nextLexemeIndex [$w index "$lexemeIndex + $matchedCount chars"]
                     }
                     set lexeme [$w get $lexemeIndex $nextLexemeIndex]

                     if {    [info exists [namespace current]::keyWordsTcl($lexeme)]   \
                          || [info exists [namespace current]::keyWordsTk($lexeme)]  } {
                        # Tag keyword
                        $w tag add keyWord $lexemeIndex $nextLexemeIndex
                        # And get in tagName name of tag that should be used for $lexeme
                        set tagName [[namespace parent]::parserKeywordTag [namespace tail [namespace current]] keyWord $lexeme]
                        if { $tagName != "" } {
                           $w tag add $tagName $lexemeIndex $nextLexemeIndex
                        }
                     }

                     if { $vaDebug } {
                        set lexeme "Default: $lexeme"
                     }
                  }
      }


      if { $vaDebug } {

         set st [open hte.vaDebug a]

         set lineNo [lindex [split $lexemeIndex .] 0]
         set nextLineNo [lindex [split $nextLexemeIndex .] 0]

         if { $lineNo != $nextLineNo } {
            set line [$w get [$w index "$lexemeIndex linestart"] [$w index "$lexemeIndex lineend"]]
            puts $st "===: \[$lineNo\] $line"
         }

         puts $st "[format "     %-8s: %8s - \[%-8s %8s\] - \[%s\]" $lexemeIndex $nextLexemeIndex $scanStartIndex $scanStopIndex $lexeme]"

         close $st

      }

      set scanStartIndex $nextLexemeIndex

   }

}

proc keywordDetection { word } {
   if { ! [ HTE::Config::isConfiguration \
   $HTE::Configuration(LexParser.[namespace tail [namespace current]],inMotionPhraseDetectionHighlightKeyword) ] } {
      return {}
   }
   variable HighlightRE
   variable IgnoreCase

   if { [string match -nocase {yes} $IgnoreCase] } {
      set caseSwitch {-nocase}
   } else {
      set caseSwitch {}
   }
   
   foreach tag [array names HighlightRE] {
      if { [eval regexp $caseSwitch -- \$HighlightRE($tag) \$word] } {
         if {$tag == "keyWord"} {
            if {([string index $word 0] == ".") || ([string index $word 0] == "-")} {
               return {}
            }
         }
         return $tag
      }
   }
   return {}
}

proc getAdditionalTags {} {
   return "operator variable"
}

proc testExtended { tag match } {
   switch -- $tag {
      "operator" {
         if {$match == "-"} {
            return 1
         }
      }
      "variable" {
         if {$match == "\$"} {
            return 1
         }
      }
   }
   return 0
}

proc prevCharacterTester { char } {
   switch -- $char {
      "." -
      "-" -
      "\$" {
         return 1
      }
   }
   return 0
}
