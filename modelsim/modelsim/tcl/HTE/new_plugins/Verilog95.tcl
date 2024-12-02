#HTEParser#verilog'95#LexVerilog#Verilog files#Verilog '95 Plugin#v|vlog#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2001-2004 All Rights Reserved
#
#
# @comment Verilog plug-in for HTE lexical parser
#
# =============================================================================

# ======================================================================
# LexVerilog namespace - Verilog related lexical parser part
# ======================================================================
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

#  putLog "::HTE::LexParser::LexVerilog::setParameters: sizeForFullParsing: $HTE::Configuration(LexParser.LexVerilog,sizeForFullParsing)"
#  putLog "::HTE::LexParser::LexVerilog::setParameters: sizeForFastParsing: $HTE::Configuration(LexParser.LexVerilog,sizeForFastParsing)"

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

#  putLog "::HTE::LexParser::LexVerilog::setParameters: sizeForFullParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)"
#  putLog "::HTE::LexParser::LexVerilog::setParameters: sizeForFastParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)"

}


   global tcl_platform
   #
   # Schedule initialization
   #
#   HTE::registerInitScript [namespace current]::init

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
      seqblk                     {"Sequential Block"           VerilogAlways}
      parblk                     {"Parallel Block"             VerilogAlways}
      always                     {"Always"                     VerilogAlways}
      comment                    {"Comment"                    {}}
      function                   {"Function"                   VerilogFunction}
      gateInstance               {"Gate Instance"              ExtPackageBodyView}
      group                      {"Group"                      openfold}
      initial                    {"Initial"                    VerilogInitial}
      instance                   {"Instance"                   Instance}
      instanceExternal           {"External Instance"          VerilogForeignView}
      module                     {"Module"                     VerilogModule}
      ogroup                     {"Group"                      openfold}
      parameter                  {"Parameter"                  VerilogParameterDecl}
      parameterMap               {"Parameter Map"              VerilogParameterMapping}
      portInOut                  {"InOut Port"                 PortIO}
      portIn                     {"Input Port"                 PortIn}
      portMap                    {"Port Map"                   PortMapping}
      portOut                    {"Output Port"                PortOut}
      signal                     {"Wire"                       signal}
      task                       {"Task"                       VerilogTask}
   }

   # By default, set all block types to be visible
   if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
   } else {
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
         {always function gateInstance initial instance instanceExternal module parameter parameterMap portInOut portIn portMap portOut signal task seqblk parblk}
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
   }


   array set matchingObject {
      end                        { {\m(end|begin)\M}              {backward} }
      endcase                    { {\m(endcase|case)\M}           {backward} }
      endfunction                { {\m(endfunction|function)\M}   {backward} }
      endmodule                  { {\m(endmodule|module)\M}       {backward} }
      endprimitive               { {\m(endprimitive|primitive)\M} {backward} }
      endtable                   { {\m(endtable|table)\M}         {backward} }
      endtask                    { {\m(endtask|task)\M}           {backward} }
      begin                      { {\m(begin|end)\M}              {forward}  }
      case                       { {\m(case|endcase)\M}           {forward}  }
      function                   { {\m(function|endfunction)\M}   {forward}  }
      module                     { {\m(module|endmodule)\M}       {forward}  }
      primitive                  { {\m(primitive|endprimitive)\M} {forward}  }
      table                      { {\m(table|endtable)\M}         {forward}  }
      task                       { {\m(task|endtask)\M}           {forward}  }
   }
          
   #
   # Verilog parser subsection of configuration values
   # Set - only when they are not already loaded
   #
#   if { [expr [llength [array names HTE::Configuration LexParser.[namespace tail [namespace current]],*]] == 0] } {

      #
      # Verilog parser subsection
      #
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural)              Yes
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)              Yes
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)                  Yes

      set sizeForFullParsingDefault 40
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)  $sizeForFullParsingDefault
      set sizeForFastParsingDefault 200
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)  $sizeForFastParsingDefault

      #
      # Declaration enable flags - make possible to add appropriate
      # declared symbols to symbol table
      #
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],netSymbolsEnable)                 1
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],netTriregSymbolsEnable)           1
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],parameterSymbolsEnable)           1
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],portSymbolsEnable)                1
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],registerDataTypeSymbolsEnable)    1
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],`defineSymbolsEnable)             1

      #
      # Fast level processing by FFT parser callback
      #
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],fastFFTParserLevelProcessing)   Yes
      variable fastFFTParserLevelProcessing
#   }
   
#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural) No
#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea) No
#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)     No
   variable identifierRE       {[[:alpha:]][\w\.]*}
   variable moduleInstanceRE   "($identifierRE)\\s*\[#\\s*\(.*\)\]?\\s+$identifierRE"
   set HighlightRE(moduleName) $moduleInstanceRE
   set hlCallbacks(moduleName) [namespace current]::instanceCmd

   #
   #
   #
   set structuralBuiltinParser   ::HteBuiltinParser::parseVerilogFile
   set syntaxChecker             ::HteBuiltinParser::parseVerilogFile

   #
   # Linear parser state
   #

   #
   #   Elements of array symbols indexed by window identifier appended
   # by symbol name are references to appropriate definitions
   #   Valid values:
   #
   #   symbols($id,<symbolName>)    - function
   #   symbols($id,<symbolName>)    - module
   #   symbols($id,<symbolName>)    - task
   #
   variable symbols

   #
   #   Elements of array declFolderID indexed by window identifier appended
   # by module name are references to code browser grouping folders
   #
   #   declFolderID($id,$moduleId,ports)    - ports folder & parentId
   #   declFolderID($id,$moduleId,wires)    - wires folder & parentId
   #
   variable declFolderID

   namespace import -force ::HTE::Console::putLog

   setParameters



proc parseComment { id w wDirect start stopIndex op } {
#
# @comment   Parses comment and returns index of character after the comment to
# @comment continue scanning. As a side effect adds tags or marks for comment
# @comment block according to request $op.
#
# @argument       id          window identifier
# @argument       w           window name
# @argument       wDirect     direct window name
# @argument       start       start comment index
# @argument       stopIndex   stop scan index
# @argument       op          operation requested. Should be "tag" or "mark"
#

   set lexeme2 [$wDirect get $start "$start + 2 chars"]

   if       { $lexeme2 == "//" } {

      # Comment region reaches one symbol after end of line
      set endComment [$wDirect index "$start lineend + 1 char"]

      # LexParser hangs while search next lexeme command if it
      # starts from "end" index. So ...
      if { [$wDirect compare $endComment >= end] } {
         set endComment [$wDirect index "$start lineend"]
      }

   } elseif { $lexeme2 == "/*" } {

      set endComment [$wDirect search -elide -regexp {\*/} "$start + 2 chars" $stopIndex]
      if { $endComment == "" } {
         # Comment is not finished till $stopIndex

         # Get caller name
         ##set caller [namespace tail [lindex [info level -1] 0]]

         if { $caller == "highlight" } {
            # For VA parser it is sufficient that it is started
            set endComment $stopIndex
         } else {
            # For other cases - ignore start of comment
            set endComment [$wDirect index "$start + 2 chars"]
            return $endComment
         }
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
   variable vaDebug
   if { $vaDebug } {
      parserTrace $wDirect $start $endComment $start $stopIndex "Comment: [$w get $start $endComment]"
   }

   return $endComment
}

proc highlightKeyword { w lexeme lexemeStart lexemeEnd } {
#
# @comment   Highlights lexeme found as keyword.&p
#
# @argument       w           text widget window name
# @argument       lexeme      lexeme found
# @argument       lexemeStart lexeme start index
# @argument       lexemeEnd   lexeme end index
#
# @comment   Results:&p
#
# @comment   - Tags are set for syntax highlighting keyword&p
#

   # Tag keyword
   $w tag add keyWord $lexemeStart $lexemeEnd

   # And get in tagName name of tag that should be used for $lexeme
   set tagName [[namespace parent]::parserKeywordTag [namespace tail [namespace current]] keyWord $lexeme]
   if { $tagName != "" } {
      $w tag add $tagName $lexemeStart $lexemeEnd
   }

}

proc findLexeme { id w wDirect scanIndex stopIndex op } {
#
# @comment   Searches (starting from $scanIndex stopping at $stopIndex and
# @comment ignoring comments) and returns index of first lexeme found or empty
# @comment string&p
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    scanIndex      scan start position
# @argument    stopIndex      scan stop position
# @argument    op             request operation for comment
#
# @comment   Results:&p
#
# @comment   - Return index of first lexeme or empty string if it is impossible&p
#

   while 1 {

      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp {\S} $scanIndex $stopIndex]
      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanIndex $nonBlankIndex

      set commentIndex [$wDirect search -elide -exact {/} $scanIndex "$scanIndex + 1 chars"]
      if { $commentIndex != "" } {
         # Parse possible comment and move parser pointer
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $scanIndex end $op]
         continue
      }

      # First non-comment lexeme found
      break
   }

   return $scanIndex
}

proc getExactLexeme { id w wDirect op scanStartIndexVar searchRE } {
#
# @comment   Searches and returns string that match $searchRE simple regular
# @comment expression starting from position $scanStartIndexVar and ignoring
# @comment comments. If first encountered non-comment lexeme does not match
# @comment $searchRE search fails. scanStartIndexVar variable is changed to
# @comment reflect scan results.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanStartIndexVar scan start position
# @argument    searchRE          simple search regular expression
#
# @comment   Results:&p
#
# @comment   - Returns empty string if lexeme requested is not found at
# @comment $scanStartIndexVar (skipping comments). As a side effect
# @comment scanStartIndexVar is changed so it points to next lexeme and
# @comment all comments between old and new position are skipped.&p
#
# @comment   - Returns string that matches $searchRE if lexeme requested is
# @comment found after $scanStartIndexVar (skipping comments). As a side effect
# @comment scanStartIndexVar is changed so it points to the end of lexeme found.&p
#

   upvar $scanStartIndexVar scanStartIndex

   #
   # Append to searched pattern start comment RE. Make RE matching only from the
   # search start point
   #
   set searchOrCommentRE ^($searchRE|//|/\\*)

#  putLog "getExactLexeme: starting at $scanStartIndex for \[$searchOrCommentRE\]"

   while 1 {

      set lexemeIndex [$wDirect search -elide -regexp {\S} $scanStartIndex end]
      if { $lexemeIndex == "" } {
#        putLog "getExactLexeme: Fail to find non blank symbol starting at $scanStartIndex"
         return ""
      }
      set scanStartIndex $lexemeIndex
#     putLog "getExactLexeme: Found non blank symbol starting at $scanStartIndex"

      # Get rest of line
      set line [$wDirect get $scanStartIndex "$scanStartIndex lineend"]

      # Get in lexeme first looked for lexeme or comment beginning
      set lexeme [lindex [regexp -inline $searchOrCommentRE $line] 0]
      if { $lexeme == "" } {
#        putLog "getExactLexeme: Fail to find $searchCommentRE starting at $scanStartIndex"
         return ""
      }

      if { $lexeme == "//" } {
         # Parse comment and move parser pointer
         set scanStartIndex [[namespace current]::parseComment $id $w $wDirect $scanStartIndex "$scanStartIndex lineend" $op]
         continue
      }

      if { $lexeme == "/*" } {
         # Parse comment and move parser pointer
         set scanStartIndex [[namespace current]::parseComment $id $w $wDirect $scanStartIndex end $op]
         continue
      }

      # We have succeeded
#     putLog "getExactLexeme: $searchRE Found at $scanStartIndex: $lexeme"
      set scanStartIndex [$wDirect index "$scanStartIndex + [string length $lexeme] chars"]
      break
   }

#  putLog "getExactLexeme: new search position $scanStartIndex"
   return $lexeme
}

proc getLexeme { id w wDirect op scanIndexVar searchRE } {
#
# @comment   Searches and returns string that match $searchRE simple regular
# @comment expression starting from position $scanIndexVar and ignoring
# @comment comments. Search fails if $searchRE does not match in all text
# @comment up to end. scanIndexVar variable is changed to reflect scan
# @comment results.&p
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    scanIndexVar   scan start position
# @argument    searchRE       simple search regular expression
#
# @comment   Results:&p
#
# @comment   - Returns empty string if lexeme requested is not found. As a side
# @comment effect scanIndexVar is changed so it points to next lexeme and
# @comment all comments between old and new position are skipped.&p
#
# @comment   - Returns string that matches $searchRE if lexeme requested is
# @comment found. As a side effect scanIndexVar is changed so it points to
# @comment the end of lexeme found. All encountered comments and lexemes that do
# @comment not match $searchRE are skipped&p
#

   variable lexemeCount
   upvar $scanIndexVar scanIndex

   #
   # Append to searched pattern start comment RE
   #
   set searchOrCommentRE $searchRE|//|/\\*

#  putLog "getLexeme: starting at $scanIndex for {$searchOrCommentRE}"
   while 1 {

      # Search requested lexeme or comment
      set lexemeIndex [$wDirect search -elide -regexp -count [namespace current]::lexemeCount $searchOrCommentRE $scanIndex end]
      if { $lexemeIndex == "" } {
#        putLog "getLexeme: Fail to find $searchOrCommentRE starting at $scanIndex"
         return ""
      }

      # Get what was found
      set lexeme [$wDirect get $lexemeIndex "$lexemeIndex + $lexemeCount chars"]
      set scanIndex $lexemeIndex
#     putLog "getLexeme: Found $lexeme starting at $scanIndex"

      if { $lexeme == "//" } {
         # Parse comment and move parser pointer
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $scanIndex "$scanIndex lineend" $op]
         continue
      }

      if { $lexeme == "/*" } {
         # Parse comment and move parser pointer
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $scanIndex end $op]
         continue
      }

      # We have succeeded
#     putLog "getLexeme: $searchRE Found $lexeme at $scanIndex count $lexemeCount"
      set scanIndex [$wDirect index "$scanIndex + $lexemeCount chars"]
      break
   }

#  putLog "getLexeme: new search position $scanIndex"
   return $lexeme
}

proc getIdentifier { id w wDirect scanIndexVar foundIndexVar op } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest lexeme.&p
#
# @comment   If lexeme found is identifier then it will be returned,
# @comment scanIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of identifier found.&p
#
# @comment   If it is not so returns empty string. scanIndexVar is an index
# @comment of lexeme found and foundIndexVar is unchanged&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contain found identifier position if scan was successful
# @argument    op                requested operation for comment
#
# @comment   Results:&p
#
# @comment   - Procedure return found identifier or empty string. Variables
# @comment scanIndexVar and foundIndexVar may be changed at success&p
#

   variable extendedIdentifiers

#
#  Identifiers
#
#    Identifiers are user-defined words for variables, function names,
#  module names, and instance names. Identifiers can be composed of
#  letters, digits, and the underscore character ( _ ). The first character
#  of an identifier cannot be a number. Identifiers can be any length.
#  Identifiers are case-sensitive, and all characters are significant.
#    Identifiers that contain special characters, begin with numbers, or
#  have the same name as a keyword can be specified as an escaped
#  identifier. An escaped identifier starts with the backslash character
#  (\), followed by a sequence of characters, followed by white space.
#
#     The Verilog language supports the concept of hierarchical names,
#  which can be used to access variables of submodules directly from
#  a higher-level module.
#


#
#  Period is added to allow hierarchical names
#
#  identifier :
#         /[a-zA-Z_][a-zA-Z_0-9\.]*/
#

   upvar $scanIndexVar scanIndex
   upvar $foundIndexVar foundIndex

   set identifierRE {^[A-Za-z_][A-Za-z_0-9\.]*}
   set escapedIdentifierRE {^\\\S*}

   # Get in scanIndex first non-blank symbol index by skipping possible comments
   set nonBlankIndex [[namespace current]::findLexeme $id $w $wDirect $scanIndex end $op]
   if { $nonBlankIndex == "" } {
      return ""
   }
   set scanIndex $nonBlankIndex

   # Get rest of line
   set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

   # Get name into $word if it is possible
   if { [regexp $identifierRE $line word] } {
#     putLog "LexVerilog::getIdentifier: Identifier: $scanIndex: $word"
      set foundIndex $scanIndex
      set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]

      return $word
   }

   # Get escaped identifier into $word if it is possible
   if { $extendedIdentifiers } {
      if { [regexp $escapedIdentifierRE $line word] } {
#        putLog "LexVerilog::getIdentifier: Escaped identifier: $scanIndex: $word"
         set foundIndex $scanIndex
         set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]

         return $word
      }
   }

   # Fail to get identifier
   return ""

}

proc skipPossibleParentheses { id w wDirect op scanIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest matched parentheses.
# @comment Nested parentheses are allowed, comments are skipped.&p
#
# @comment   If nearest lexeme is not opening round bracket then returns 0
# @comment and scanIndexVar will not be changed. Otherwise it tries to
# @comment skip balanced round brackets scanIndexVar variable will contain
# @comment index of text to continue scan after. If unbalanced bracket is
# @comment encountered when returns 0, otherwise - 1.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
#
# @comment   Results:&p
#
# @comment   - Procedure changes variables scanIndexVar at success and
# @comment returns 1 if balanced round brackets are found, 0 - otherwise&p
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   set brackets 0

   # Find left bracket
   set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op scanIndex {\(}]
   if { $leftBracket == "" } {
      # No brackets. scanIndexVar will not be modified
      return 0
   }
   incr brackets

   while 1 {

      # Find bracket
      set roundBracket [[namespace current]::getLexeme $id $w $wDirect $op scanIndex {\(|\)}]
      if { $roundBracket == "" } {
         # No brackets. scanIndexVar will not be modified
         return 0
      }

      if { $roundBracket == "(" } {
         # Left bracket
         incr brackets
         continue

      }

      if { $roundBracket == ")" } {
         # Right bracket
         incr brackets -1
         if { [expr $brackets <= 0] } {
            return 1
         }

         continue

      }

      # We should not fall here
      return 0

   }
}

proc skipValueOrIdentifierOrParentheses { id w wDirect op scanIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest delay value or identifier
# @comment or something in parentheses. Comments are skipped.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
#
# @comment   Results:&p
#
# @comment   - Procedure changes variables scanIndexVar at success and returns 1.
# @comment Otherwise - returns 0&p
#

   variable keyWords

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex

   set brackets 0

   # Find left bracket
   set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
   if { $leftBracket == "" } {
      # No brackets. Skip delay value or identifier
      set lexeme [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\S+}]
#     putLog "skipValueOrIdentifierOrParentheses: no parentheses: $lexeme"
      set scanIndex $parseIndex
      return 1
   }

   incr brackets

   while 1 {

      # Find bracket or possible keyword
      set wordOrBracket [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\(|\)|\w+}]
      if { $wordOrBracket == "" } {
         # No brackets and no words. scanIndexVar will not be modified
#        putLog "skipValueOrIdentifierOrParentheses: No brackets at $parseIndex. scanIndexVar will not be modified"
         return 0
      }

      if { $wordOrBracket == "(" } {
         # Left bracket
         incr brackets
         continue

      }

      if { $wordOrBracket == ")" } {
         # Right bracket
         incr brackets -1
         if { [expr $brackets <= 0] } {
            break
         }
         continue
      }

      # Some lexeme will be skipped but keyword should be highlighted for
      # visual area parser

#     putLog "skipValueOrIdentifierOrParentheses: $wordOrBracket"
      if { $op == "tag" } {
         if { [info exists keyWords($wordOrBracket)] } {
            # Highlight word if it seems keyword
            set lexemeStart [$w index "$parseIndex -[string length $wordOrBracket] chars"]
            highlightKeyword $w $wordOrBracket $lexemeStart $parseIndex
         }
      }
   }

#  putLog "skipValueOrIdentifierOrParentheses: 1 $scanIndex .. $parseIndex"
   set scanIndex $parseIndex
   return 1
}

proc skipPossibleDelay2orDelay3 { id w wDirect op scanIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest delay3 construction.
# @comment Comments are skipped.&p
#
# @comment   If nearest lexeme is not '#' symbol then nothing happens
# @comment and scanIndexVar will not be changed, otherwise scanIndexVar
# @comment variable will contain index of text to continue scan after braces.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
#
# @comment   Results:&p
#
# @comment   - Procedure changes variables scanIndexVar at success and returns 1.
# @comment Otherwise - returns 0&p
#

#
#  delay2 :
#        '#'
#        (
#           paren_up_to_2_delay_values
#           | delay_value
#        )
#
#  delay3 :
#        '#'
#        (
#           paren_up_to_3_delay_values
#           | delay_value
#        )
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex

   # Find '#'
   set hash [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {#}]
   if { $hash == "" } {
      # No hash symbol. scanIndexVar will not be modified
      return 0
   }

   # Find delay3/delay2 expression
   if { ! [[namespace current]::skipPossibleParentheses $id $w $wDirect $op parseIndex] } {
      # No delay3. scanIndexVar will not be modified
      return 0
   }

   set scanIndex $parseIndex
   return 1
}

proc skipPossibleRange { id w wDirect op scanIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest range in the square braces.
# @comment Comments are skipped.&p
#
# @comment   If nearest lexeme is not opening square bracket then nothing happens
# @comment and scanIndexVar will not be changed, otherwise scanIndexVar
# @comment variable will contain index of text to continue scan after braces.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
#
# @comment   Results:&p
#
# @comment   - Procedure changes variables scanIndexVar at success and returns 1.
# @comment Otherwise - returns 0&p
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex

   # Find left square bracket
   set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\[}]
   if { $leftBracket == "" } {
      # No left square bracket. scanIndexVar will not be modified
      return 0
   }

   # Find right bracket
   set rightBracket [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\]}]
   if { $rightBracket == "" } {
      # No brackets. scanIndexVar will not be modified
      return 0
   }

   set scanIndex $parseIndex
   return 1
}

proc skipPossibleStrength { id w wDirect op scanIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest drive/pullup/pulldown strength
# @comment in the round braces. Comments are skipped.&p
#
# @comment   If nearest lexeme is not opening round bracket then nothing happens
# @comment and scanIndexVar will not be changed, otherwise scanIndexVar
# @comment variable will contain index of text to continue scan after braces.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                requested operation for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
#
# @comment   Results:&p
#
# @comment   - Procedure changes variables scanIndexVar at success and returns 1.
# @comment Otherwise - returns 0&p
#

#
#  drive_strength :
#        '('
#          (
#            strength0_comma_strength1
#          | strength1_comma_strength0
#          | strength0_comma_highz1
#          | strength1_comma_highz0
#          | highz1_comma_strength0
#          | highz0_comma_strength1
#          )
#        ')'
#
#  strength0_comma_strength1 : strength0 ',' strength1
#  strength1_comma_strength0 : strength1 ',' strength0
#  strength0_comma_highz1 :    strength0 ',' 'highz1'
#  strength1_comma_highz0 :    strength1 ',' 'highz0'
#  highz1_comma_strength0 :    'highz1' ',' strength0
#  highz0_comma_strength1 :    'highz0' ',' strength1
#
#  strength0 : 'supply0' | 'strong0' | 'pull0' | 'weak0'
#  strength1 : 'supply1' | 'strong1' | 'pull1' | 'weak1'
#
#  pullup_strength :
#        '('
#          (
#             strength0_comma_strength1
#           | strength1_comma_strength0
#           | strength1
#          )
#        ')'
#
#  pulldown_strength :
#        '('
#          (
#            strength0_comma_strength1
#          | strength1_comma_strength0
#          | strength0
#          )
#        ')'
#


   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex

   # Find left bracket
   set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
   if { $leftBracket == "" } {
      # No brackets. scanIndexVar will not be modified
      return 0
   }

   set strengthRE {\)|,|supply0|strong0|pull0|weak0|supply1|strong1|pull1|weak1|highz0|highz1}

   while 1 {

      # Find "strength" or comma or right bracket
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex $strengthRE]

      switch -exact -- $lexeme {
         ""    {
            # Parse failed
            return 0
         }

         ")"   {
            # Parse success
            break
         }

         default  {
            # Found comma or valid word
            continue
         }

      }

      # We should not fall here
      return 0
   }


   set scanIndex $parseIndex
   return 1
}

proc skipLine { id w wDirect scanIndex op } {
#
# @comment   Skips all lexemes found (starting from $scanIndex up to end
# @comment of line and ignoring comments) and returns index for parse
# @comment continuation
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    scanIndex      scan start position
# @argument    op             operation requested for comment
#

   set endOfLine "$scanIndex lineend"

   while 1 {

      # Get in scanIndex first non-blank sympol position (skipping possible comments)
      set nonBlankIndex [[namespace current]::findLexeme $id $w $wDirect $scanIndex end $op]
      if { $nonBlankIndex == "" } {
         # No lexeme found at all - only comments up to end of file
         set scanIndex end
         break
      }
      if { [$wDirect compare $nonBlankIndex >= $endOfLine] } {
         # First found lexeme on the below line
         set scanIndex $nonBlankIndex
         break
      }

      # Skip lexeme
      set scanIndex $nonBlankIndex
      set lexeme [[namespace current]::getLexeme $id $w $wDirect $op scanIndex {\S+}]

   }

   return $scanIndex
}

proc endBlockCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   End of block keyword parser extension. Get last opened block
# @comment definition from blocks stack and complete code tree node.&p
#
# @comment   Calls code browser to update code tree.&p
#
# @comment   Currently implemented structural blocks:&p
#
# @comment     - module declaration&p
# @comment     - function declaration&p
# @comment     - task declaration&p
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    w           window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of parsed keyword
# @argument    end         end position of parsed keyword
#
# @comment   Results:&p
#
# @comment     - block definition is removed from stack of opened lexical blocks&p
# @comment     - node that represents block is completed in the code browser tree&p
#

   variable function
   variable module
   variable task

   set scanStartIndex $end

   variable linearExtDebug

   if { $linearExtDebug } {
      putLog "endBlockCmd: $scanStartIndex"
   }

   if { [[namespace parent]::parserContext $id checkEmpty] } {

      if { $linearExtDebug } {
         putLog "endBlockCmd: Block List empty at $scanStartIndex"
      }

   } else {

      set blockId [[namespace parent]::parserContext $id pop]

      set blockEnd $scanStartIndex
#     set blockEnd "$scanStartIndex -1 char"

      if { $linearExtDebug } {
         set blockType  [[namespace parent]::parserContext $id getType $blockId]
         set blockName  [[namespace parent]::parserContext $id getName $blockId]
         putLog "endBlockCmd: $scanStartIndex End of $blockType \"$blockName\""
      }
      [namespace parent]::BrowserCompleteNode   \
                              $id               \
                              $w                \
                              $blockId          \
                              $blockEnd
   }

   return $scanStartIndex

}

proc gateInstantiation { id lang caller w functionName start end {op mark} } {
set wDirect $w
#
# @comment   Name reference parser extension
#
# @argument    id          window identifier
# @argument    wDirect     direct window name
# @argument    w           window name
# @argument    op          requested operation for comment
# @argument    functionName function name
# @argument    start       start position of parsed function name reference
# @argument    end         end position of parsed function name reference
#
#

#
#  module_item :
#     ...
#        | gate_instantiation
#     ...
#
#  gate_instantiation :
#          n_input_gatetype_drive_strength_delay2_n_input_gate_instance
#        | n_output_gatetype_drive_strength_delay2_n_output_gate_instance
#        | enable_gatetype_drive_strength_delay3_enable_gate_instance
#        | mos_switchtype_delay3_mos_switch_instance
#        | pass_switchtype_pass_switch_instance
#        | pass_en_switchtype_delay3_pass_enable_switch_instance
#        | cmos_switchtype_delay3_cmos_switch_instance
#        | pullup_pullup_strength_pull_gate_instance
#        | pulldown_pulldown_strength_pull_gate_instance
#
#  n_input_gatetype_drive_strength_delay2_n_input_gate_instance :
#        n_input_gatetype
#        drive_strength(?)
#        delay2(?)
#        n_input_gate_instance_comma_n_input_gate_instance
#        ';'
#
#  n_output_gatetype_drive_strength_delay2_n_output_gate_instance :
#        n_output_gatetype
#        drive_strength(?)
#        delay2(?)
#        n_output_gate_instance_comma_n_output_gate_instance
#        ';'
#
#
#  enable_gatetype_drive_strength_delay3_enable_gate_instance :
#        enable_gatetype
#        drive_strength(?)
#        delay3(?)
#        enable_gate_instance_comma_enable_gate_instance
#        ';'
#
#  mos_switchtype_delay3_mos_switch_instance :
#        mos_switchtype
#        delay3(?)
#        mos_switch_instance_comma_mos_switch_instance
#        ';'
#
#  pass_switchtype_pass_switch_instance :
#        pass_switchtype
#        pass_switch_instance_comma_pass_switch_instance
#        ';'
#
#  pass_en_switchtype_delay3_pass_enable_switch_instance :
#        pass_en_switchtype
#        delay3(?)
#        pass_enable_switch_instance_comma_pass_enable_switch_instance
#        ';'
#
#  cmos_switchtype_delay3_cmos_switch_instance :
#        cmos_switchtype
#        delay3(?)
#        cmos_switch_instance_comma_cmos_switch_instance
#        ';'
#
#  pullup_pullup_strength_pull_gate_instance :
#        'pullup'
#        pullup_strength(?)
#        pull_gate_instance_comma_pull_gate_instance
#        ';'
#
#  pulldown_pulldown_strength_pull_gate_instance :
#        'pulldown'
#        pulldown_strength(?)
#        pull_gate_instance_comma_pull_gate_instance
#        ';'
#
#  n_input_gatetype :
#        'and' | 'nand' | 'or' | 'nor' | 'xor' | 'xnor'
#
#  n_output_gatetype :
#        'buf' | 'not'
#
#  enable_gatetype :
#        'bufifo' | 'bufdl'  | 'notifo' | 'notifl'     - What does it mean ?
#        'bufif0' | 'bufif1' | 'notif0' | 'notif1'
#
#  mos_switchtype :
#        'nmos' | 'pmos' | 'rnmos' | 'rpmos'
#
#  pass_switchtype :
#        'tran' | 'rtran'
#
#  pass_en_switchtype :
#        'tranif0' | 'tranif1' | 'rtranif1' | 'rtranif0'
#
#  cmos_switchtype :
#        'cmos' | 'rcmos'
#
#  n_input_gate_instance_comma_n_input_gate_instance :
#        n_input_gate_instance comma_n_input_gate_instance(s?)
#
#  comma_n_input_gate_instance :
#        ',' n_input_gate_instance
#
#  n_output_gate_instance_comma_n_output_gate_instance :
#        n_output_gate_instance comma_n_output_gate_instance(s?)
#
#  comma_n_output_gate_instance :
#        ',' n_output_gate_instance
#
#  enable_gate_instance_comma_enable_gate_instance :
#        enable_gate_instance comma_enable_gate_instance(s?)
#
#  comma_enable_gate_instance :
#        ',' enable_gate_instance
#
#  mos_switch_instance_comma_mos_switch_instance :
#        mos_switch_instance comma_mos_switch_instance(s?)
#
#  comma_mos_switch_instance :
#        ',' mos_switch_instance
#
#  pass_switch_instance_comma_pass_switch_instance :
#        pass_switch_instance
#        comma_pass_switch_instance(s?)
#
#  comma_pass_switch_instance :
#        ',' pass_switch_instance
#
#  pass_enable_switch_instance_comma_pass_enable_switch_instance :
#        pass_enable_switch_instance
#        comma_pass_enable_switch_instance(s?)
#
#  comma_pass_enable_switch_instance :
#        ','
#        pass_enable_switch_instance
#
#  cmos_switch_instance_comma_cmos_switch_instance :
#        cmos_switch_instance
#        comma_cmos_switch_instance(s?)
#
#  comma_cmos_switch_instance :
#        ','
#        cmos_switch_instance
#
#  pullup_strength : - skipPossibleStrength
#
#  pull_gate_instance_comma_pull_gate_instance :
#        pull_gate_instance
#        comma_pull_gate_instance(s?)
#
#  comma_pull_gate_instance :
#        ','
#        pull_gate_instance
#
#  pullup_strength(?) - skipPossibleStrength
#
#  pull_gate_instance_comma_pull_gate_instance :
#        pull_gate_instance
#        comma_pull_gate_instance(s?)
#
#  comma_pull_gate_instance :
#        ','
#        pull_gate_instance
#
#  n_input_gate_instance :
#        name_of_gate_instance(?)
#        '(' output_terminal ',' input_terminal_comma_input_terminal ')'
#
#  n_output_gate_instance :
#        name_of_gate_instance(?)
#        '(' output_terminal_comma_output_terminal ')'
#
#  enable_gate_instance :
#        name_of_gate_instance(?)
#        '(' output_terminal ',' input_terminal ',' enable_terminal ')'
#
#  mos_switch_instance :
#        name_of_gate_instance(?)
#        '(' output_terminal ',' input_terminal ',' enable_terminal ')'
#
#  pass_switch_instance :
#       name_of_gate_instance(?)
#       '(' inout_terminal ',' inout_terminal ')'
#
#  pass_enable_switch_instance :
#       name_of_gate_instance(?)
#       '(' inout_terminal ',' inout_terminal ',' enable_terminal ')'
#
#  cmos_switch_instance :
#       name_of_gate_instance(?)
#       '(' output_terminal ',' input_terminal ',' ncontrol_terminal ',' pcontrol_terminal ')'
#
#  pull_gate_instance :
#       name_of_gate_instance(?)
#       '(' output_terminal ')'
#
#  name_of_gate_instance :
#        gate_instance_identifier
#        range(?)
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # Get start parse index
   set parseIndex $end

   while 1 {

      # Find and skip drive/pullup/pulldown strength
      if { [[namespace current]::skipPossibleStrength $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip delay2 or delay3
      if { [[namespace current]::skipPossibleDelay2orDelay3 $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Always break cicle
      break
   }

#  n_input_gate_instance_comma_n_input_gate_instance :
   while 1 {

      set gateInstance [[namespace current]::getIdentifier $id $w $wDirect parseIndex gateInstanceIndex $op]
      set gateEndIndex $parseIndex

      # Find and skip range
      if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
      }

      # Skip rest of 'n_input_gate_instance'
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op parseIndex

      # Get colon, or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
      if { $delimiter == {,} || $delimiter == {;} } {
         if { $gateInstance == "" } {

            # No named gate instance
            set gateInstance "nonamed"
            set gateInstanceIndex $gateEndIndex

         } else {

            # Highlight declared port
            if { $caller == "highlight" } {
               $w tag add gate $gateInstanceIndex $gateEndIndex
            }

         }
      }
      switch -exact -- $delimiter {
         ,  {
            set ok "continue"
         }
         ;  {
            # End of parameter declaration
            set ok "break"
         }
         default {
            # No valid delimiter
            return $end
         }
      }

      if { $caller == "extract" } {

         # Create browser node
         set type "gateInstance"
         set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

         foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

         # Register new block and get unique identifier
         set blockId [[namespace parent]::parserContext $id register $type $gateInstance Verilog]

         [namespace parent]::BrowserNode              \
                                 $id                  \
                                 $operation           \
                                 $w                   \
                                 $blockId             \
                                 $gateInstanceIndex   \
                                 $parseIndex          \
                                 $parentId            \
                                 $beforeNode          \
                                 $iconName

      }

      # Continue or break cycle
      eval $ok
   }

   return $parseIndex

}

proc function { id w wDirect op functionName start end } {
#
# @comment   Function call parser extension&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    functionName function name
# @argument    start       start position of parsed function name reference
# @argument    end         end position of parsed function name reference
#
# @comment   Results:&p
#
# @comment   - Currently nothing happens&p
#

   return $end

}

proc functionCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Function keyword parser extension. Function declaration is parsed
# @comment and code browser is called to update the code tree&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
# @comment   Results:&p
#
# @comment     - node that represents function declaration is created in the
# @comment code browser tree&p
#

   variable function
   variable symbols

#
#  function_declaration :
#        'function'
#           range_or_type(?)
#           function_identifier
#        ';'
#           function_item_declaration(s)
#           statement
#        'endfunction'
#
#  range_or_type :
#        range | 'integer' | 'real' | 'realtime' | 'time'
#
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   set scanStartIndex $end
#  putLog "function: start parsing at $start"

   # Skip possible range
   [namespace current]::skipPossibleRange $id $w $wDirect $op scanStartIndex
#  putLog "function: $scanStartIndex after skipping range"

   # Get function_identifier or type
   set functionName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex functionNameIndex mark]
   if { $functionName == "" } { return $end }
   switch -exact -- $functionName {

      integer     -
      real        -
      realtime    -
      time        {
         # Highlight keyword
         if { $caller == "highlight" } {
            highlightKeyword $w $functionName $functionNameIndex $scanStartIndex
         }

         # Get function name
         set functionName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex functionNameIndex mark]
         if { $functionName == "" } { return $end }

         # Highlight function name
         if { $caller == "highlight" } {
            $w tag add functionName $functionNameIndex $scanStartIndex
         }
      }

      default     {

         # Highlight function name
         if { $caller == "highlight" } {
            $w tag add functionName $functionNameIndex $scanStartIndex
         }
      }

   }
#  putLog "function: $scanStartIndex $functionName at $functionNameIndex"

   # Get semicolon
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {;}]

   if { $delimiter == "" } {
      # No valid delimiter
      return $end
   }
#  putLog "function: $scanStartIndex ;"

   if { $caller == "extract" } {

      set type "function"
#     set functionStart [lindex [split $functionNameIndex .] 0]
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $functionName Verilog]

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

      [namespace parent]::parserContext $id push $blockId

      set symbols($id,$functionName) "function"

   }

   return $scanStartIndex
}

proc instanceCmd { id lang caller w keyword start end {op mark} } {
   return [module $id $w $caller $op $keyword $start $end External]
}

proc module { id w caller op moduleName start end {external {}} } {
set wDirect $w
#
# @comment   Module instance parser extension. Module instantiation starts from
# @comment module name and includes list of instances. For each instance its
# @comment name fetched.&p
# @comment   Calls code browser to update the code tree&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    moduleName  module name
# @argument    start       start position of parsed module name
# @argument    end         end position of parsed module name
# @argument    external    if not empty - instance of external module is encountered
#
# @comment   Results:&p
#
# @comment     - node that represents module instance is created in the
# @comment code browser tree&p
#

#   variable linearExtDebug

#
#  Notes: implemented list of module_instance separated with comma
#
#  module_instantiation :
#        module_identifier
#        parameter_value_assignment(?)
#        module_instance(s)
#        ';'
#
#  parameter_value_assignment :
#        '#'
#        '('
#           expression_comma_expression
#        ')'
#
#  module_instance :
#        name_of_instance
#        '('
#           list_of_module_connections(?)
#        ')'
#
#  name_of_instance :
#        module_instance_identifier
#        range(?)
#
#
#  range :
#        '['
#           msb_constant_expression
#           ':'
#           lsb_constant_expression
#        ']'
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]
   set moduleInstanceIndices {}

   # Remember possible module name coordinates
   set moduleNameStart $start
   set moduleNameEnd   $end

   set scanStartIndex $end

   while 1 {

      # Skip parameter_value_assignment
      set hashChar [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {#}]
      if { $hashChar != "" } {
         [namespace current]::skipPossibleParentheses $id $w $wDirect $op scanStartIndex
      }

      # Get module_instance_identifier
      set instanceName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex instanceNameIndex $op]
      if { $instanceName == "" } {
         $w tag remove moduleName $start $end
         return $end
      }
      if { $caller == "highlight" } {
         lappend moduleInstanceIndices $instanceNameIndex $scanStartIndex
      }

      # Skip range
      [namespace current]::skipPossibleRange $id $w $wDirect $op scanStartIndex

      #
      # Skip list_of_module_connections
      #
      # Note: parentheses here are mandatory not possible
      #
      set p [[namespace current]::skipPossibleParentheses $id $w $wDirect $op scanStartIndex]

      if { $p == 0 } {
         $w tag remove moduleName $start $end
         return $end
      }

      # Get comma or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {,|;}]

      if { $delimiter == "" } {
         # No valid delimiter
         $w tag remove moduleName $start $end
         break
      }
      set endIndex $scanStartIndex

      if { $caller == "extract" } {

         set type "instance"
         if { $external != "" } {
            set type "instance$external"
         }
         set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

         foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

         # Register new block and get unique identifier
         set blockId [[namespace parent]::parserContext $id register $type $instanceName Verilog]

         [namespace parent]::BrowserNode              \
                                 $id                  \
                                 $operation           \
                                 $w                   \
                                 $blockId             \
                                 $start               \
                                 $endIndex            \
                                 $parentId            \
                                 $beforeNode          \
                                 $iconName

      }


      if { $delimiter == ";" } {
         # Highlight module name
         if { $caller == "highlight" } {
#            $w tag add moduleName $moduleNameStart $moduleNameEnd

            # Highlight module instances names
            foreach {startIndex endIndex} $moduleInstanceIndices {
               $w tag add moduleInstanceName $startIndex $endIndex
            }

         }
         break
      }

   }


   return $scanStartIndex
}

proc moduleCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Module keyword parser extension. Calls code browser to update
# @comment code tree&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of parsed keyword
# @argument    end         end position of parsed keyword
#
# @comment   Results:&p
#
# @comment     - module definition is pushed into stack of opened lexical blocks&p
# @comment     - set appropriate element of array symbols as "module"&p
# @comment     - adds module declaration definition to array "module"&p
# @comment     - node that represents module is created in the code browser tree&p
#

   variable module
   variable symbols
   variable declFolderID

#
#  module_declaration :
#        ( 'module'  |  'macromodule' )
#        module_declaration_identifier
#        list_of_ports(?)
#        ';'
#        module_item(s?)
#        'endmodule'
#
#
#  module_declaration_identifier :
#        identifier
#
#
#  list_of_ports :
#        '('
#           port
#           comma_port(s?)
#        ')'
#
#  comma_port :
#        ','
#        port
#
#  port :
#       port_expression(?) |
#       dot_port_identifier_and_port_expression
#
#  dot_port_identifier_and_port_expression :
#        '.'
#        port_identifier
#        '('
#        port_expression(?)
#        ')'
#
#  port_expression :
#        port_reference
#        comma_port_reference(s?)
#
#  comma_port_reference :
#        ','
#        port_reference
#
#  port_reference :
#        port_identifier
#        port_bit_selection_or_bit_slice(?)
#        {
#           $verilog_port{$item{port_identifier}} = 1;
#        }
#
#  port_bit_selection_or_bit_slice :
#        bit_selection_or_bit_slice(?)
#
#
#  bit_selection_or_bit_slice :
#        '['
#           expression
#           colon_expression(?)
#        ']'
#
#  colon_expression :
#        ':'
#           expression
#
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   variable linearExtDebug

   if { $linearExtDebug } {
      putLog "LexVerilog::moduleCmd $id $start $end"
   }

   set scanStartIndex $end

   set moduleName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex moduleNameIndex $op]
   if { $moduleName == "" } { return $end }

   if { $linearExtDebug } {
      putLog "moduleCmd 1: Module: \"$moduleName\" at $moduleNameIndex .. $scanStartIndex"
   }

   # Highlight module name
   if { $caller == "highlight" } {
      $w tag add moduleName $moduleNameIndex $scanStartIndex
   }

   set type "module"
#  set moduleStart [lindex [split $moduleNameIndex .] 0]
   set moduleStart $moduleNameIndex
   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)


   # Skip possible list_of_ports
   [namespace current]::skipPossibleParentheses $id $w $wDirect $op scanStartIndex
   if { $linearExtDebug } {
      putLog "moduleCmd 2: $scanStartIndex"
   }

   [namespace current]::getLexeme $id $w $wDirect $op scanStartIndex {;}
   if { $linearExtDebug } {
      putLog "moduleCmd 3: $scanStartIndex"
   }

   if { $caller == "extract" } {

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $moduleName Verilog]

      if { $linearExtDebug } {
         putLog "Module Declaration($blockId): \"$moduleName\" starting at $moduleNameIndex"
      }

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


      [namespace parent]::parserContext $id push $blockId

      set symbols($id,$moduleName) "module"
      
      # create ports and wires folders
      set portsFolderId [[namespace parent]::parserContext $id register ogroup ports Verilog]
      [namespace parent]::BrowserNode  $id  $operation  $w     \
                              $portsFolderId  {}  {}           \
                              $blockId  {}  openfold
      set declFolderID($id,$blockId,ports) $portsFolderId

      set wiresFolderId [[namespace parent]::parserContext $id register ogroup wires Verilog]
      [namespace parent]::BrowserNode  $id  $operation  $w     \
                              $wiresFolderId  {}  {}           \
                              $blockId  {}  openfold
      set declFolderID($id,$blockId,wires) $wiresFolderId

   }

   return $scanStartIndex

}


#
#  net_declaration :
#          net_type_vectored_scalared_range_delay3_list_of_net_identifiers
#        | net_type_vectored_scalared_drive_strength_range_delay3_list_of_net_decl
#        | trireg_vectored_scalared_charge_strength_range_delay3_list_of_net
#
#  net_type_vectored_scalared_range_delay3_list_of_net_identifiers :
#        net_type
#        vectored_or_scalared(?)
#        range(?)
#        delay3(?)
#        declaring_net_identifier_comma_declaring_net_identifier
#        ';'
#
#  net_type_vectored_scalared_drive_strength_range_delay3_list_of_net_decl :
#        net_type
#        vectored_or_scalared(?)
#        drive_strength(?)
#        range(?)
#        delay3(?)
#        net_decl_assignment_comma_net_decl_assignment
#        ';'
#
#  trireg_vectored_scalared_charge_strength_range_delay3_list_of_net :
#        'trireg'
#        vectored_or_scalared(?)
#        charge_strength(?)
#        range(?)
#        delay3(?)
#        declaring_net_identifier_comma_declaring_net_identifier
#        ';'
#
#  net_type :
#        'wire' | 'supply0' | 'supply1' | 'triand' | 'trior' | 'tril' | 'tri0' | 'tri' | 'wand' | 'wor'
#
#  vectored_or_scalared :
#        'vectored' | 'scalared'
#
#  drive_strength - skipPossibleStrength
#
#  charge_strength : 'small' | 'medium'| 'large'
#
#  range :
#        '['
#          msb_constant_expression
#          ':'
#          lsb_constant_expression
#        ']'
#
#  delay3 : - skipPossibleDelay2orDelay3
#
#  declaring_net_identifier_comma_declaring_net_identifier :
#      declaring_net_identifier
#      comma_declaring_net_identifier(s?)
#
#  declaring_net_identifier :
#      net_identifier
#
#  comma_declaring_net_identifier :
#      ','
#      declaring_net_identifier
#
#  net_decl_assignment_comma_net_decl_assignment :
#      net_decl_assignment
#      comma_net_decl_assignment(s?)
#
#  net_decl_assignment :
#        net_identifier '=' expression
#
#  comma_net_decl_assignment :
#      ','
#      net_decl_assignment
#
#  constant_mintypmax_expression :
#          constant_expression
#          colon_constant_expression_colon_constant_expression(?)
#
#  colon_constant_expression_colon_constant_expression :
#          ':'
#          constant_expression
#          ':'
#          constant_expression
#
#  constant_expression :
#     constant_trinary_expression
#     | constant_expression_in_parens
#
#  constant_trinary_expression :
#     constant_binary_series
#     question_constant_expr_colon_constant_expr(?)
#
#  constant_expression_in_parens :
#     '(' constant_expression ')'
#

proc netDeclaration { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Net declarations parser extension. Net declaration is parsed and
# @comment internal parser data structure are updated
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   set parseIndex $end

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   if { $caller=={extract} && $keyword=={wire} } {
      variable declFolderID

      # get port icon
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.wire)

      # get parent module
      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
      set wiresFolderId $parentId
      if [info exists declFolderID($id,$parentId,wires)] {
         set wiresFolderId $declFolderID($id,$parentId,wires)
      }
   }

#  net_type_vectored_scalared_range_delay3_list_of_net_identifiers :
#  net_type_vectored_scalared_drive_strength_range_delay3_list_of_net_decl :
   while 1 {
      # Find and skip vectored_or_scalared
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {vectored|scalared}]
      if { $lexeme != "" } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip drive_strength
      if { [[namespace current]::skipPossibleStrength $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip range
      if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip delay3
      if { [[namespace current]::skipPossibleDelay2orDelay3 $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Always break cicle
      break
   }

   # declaring_net_identifier_comma_declaring_net_identifier
   # net_decl_assignment_comma_net_decl_assignment
   while 1 {
      set netIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex netIdentifierIndex $op]
      if { $netIdentifier == "" } {
         return $end
      }

      # Highlight declared net
      if { $caller == "highlight" } {
         $w tag add net $netIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],netSymbolsEnable) } {
         # Update net definitions
         [namespace parent]::declarationParserContext $id $w addLocal net $netIdentifier $start $parseIndex

         # Add wire node to code browser
         if { $keyword=={wire} } {
            set wireId [[namespace parent]::parserContext $id register signal $netIdentifier Verilog]
            [namespace parent]::BrowserNode  $id  $operation  $w        \
                              $wireId  $netIdentifierIndex  $parseIndex  \
                              $wiresFolderId  $beforeNode  $iconName
         }
      }


      # Get colon, equal sign or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|=|;}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         =  {
            # Skip something and get colon or semicolon
            set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|;}]
            if { $delimiter == "" } {
               # No valid delimiter
               break
            }
            if { $delimiter == ";" } {
               # End of net declaration
               break
            }
            # Get next identifier
            continue
         }
         ;  {
            # End of net declaration
            break
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc netTriregDeclaration { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Net declarations parser extension. Net declaration is parsed and
# @comment internal parser data structure are updated
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   set parseIndex $end

#  trireg_vectored_scalared_charge_strength_range_delay3_list_of_net :
   while 1 {
      # Find and skip vectored_or_scalared
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {vectored|scalared}]
      if { $lexeme != "" } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip charge_strength
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {small|medium|large}]
      if { $lexeme != "" } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip range
      if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find and skip delay3
      if { [[namespace current]::skipPossibleDelay2orDelay3 $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Always break cicle
      break
   }

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # declaring_net_identifier_comma_declaring_net_identifier
   while 1 {
      set netIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex netIdentifierIndex $op]
      if { $netIdentifier == "" } {
         return $end
      }

      # Highlight declared net
      if { $caller == "highlight" } {
         $w tag add parameter $netIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],netTriregSymbolsEnable) } {
         # Update net definitions
         [namespace parent]::declarationParserContext $id $w addLocal net $netIdentifier $start $parseIndex
      }


      # Get colon, equal sign or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|=|;}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         =  {
            # Skip something and get colon or semicolon
            set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|;}]
            if { $delimiter == "" } {
               # No valid delimiter
               break
            }
            if { $delimiter == ";" } {
               # End of net declaration
               break
            }
            # Get next identifier
            continue
         }
         ;  {
            # End of net declaration
            break
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc parameterDeclaration { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Parameters declarations and defparam parser extension. Declaration
# @comment is parsed and internal parser data structure are updated
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  module_item :
#     ...
#        | module_item_declaration
#     ...

#  module_item_declaration :
#     ...
#        | 'defparam' parameter_override
#     ...
#
#  parameter_override :
#        parameter_assignment_comma_parameter_assignment
#        ';'
#
#  parameter_assignment_comma_parameter_assignment :
#        parameter_assignment
#        comma_parameter_assignment(s?)
#
#  comma_parameter_assignment :
#        ','
#        parameter_assignment
#
#  parameter_declaration :
#        'parameter'
#        parameter_assignment_comma_parameter_assignment
#        ';'
#
#  parameter_assignment :
#        parameter_identifier
#        '='
#        constant_expression  # is not parsed
#
# Note:
#  parameter[0:0] mb_low = 0; - is not supported
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # Get start parse index
   set parseIndex $end

#  parameter_assignment_comma_parameter_assignment

   while 1 {
      set parameterIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex parameterIdentifierIndex $op]
      if { $parameterIdentifier == "" } {
         return $end
      }

      # Highlight declared reg
      if { $caller == "highlight" } {
         $w tag add reg $parameterIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],parameterSymbolsEnable) } {
         # Add parameter declaration into parser context
         [namespace parent]::declarationParserContext $id $w addLocal parameter $parameterIdentifier $start $parseIndex
      }

#  '='
#  constant_expression  # is not parsed

      # Get colon, or semicolon
      set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|;}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of parameter declaration
            break
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc portDeclaration { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Port declarations parser extension. Declaration  is parsed and
# @comment internal parser data structure are updated
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  module_item_declaration :
#     ...
#        | input_declaration
#        | output_declaration
#        | inout_declaration
#     ...
#
#  input_declaration :
#        'input'
#        range(?)
#        direction_port_identifier_list[$item[1],@{$item{range}->[0]}]
#        ';'
#
#  output_declaration :
#        'output'
#        range(?)
#        direction_port_identifier_list[$item[1],@{$item{range}->[0]}]
#        ';'
#
#  inout_declaration :
#        'inout'
#        range(?)
#        direction_port_identifier_list[$item[1],@{$item{range}->[0]}]
#        ';'
#
#  direction_port_identifier_list :
#        direction_port_identifier
#        comma_direction_port_identifier(s?)
#
#  comma_direction_port_identifier :
#        ','
#        direction_port_identifier
#
#  direction_port_identifier :
#        port_identifier
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # Get start parse index
   set parseIndex $end
   
   if { $caller == {extract} } {
      variable declFolderID

      # get port icon
      switch -- [string tolower $keyword] {
         input   {  set portType portIn  }
         output  {  set portType portOut }
         inout   {  set portType portInOut  }
         default {  set portType portIn  }
      }
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$portType)

      # get parent module
      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
      set parentType [[namespace parent]::parserContext $id getType $parentId]
      if { $parentType=={module} } {
         set portsFolderId $declFolderID($id,$parentId,ports)
      }
   }

   # Find and skip range
   if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
      # Found - parseIndex contains next scan position
   }

   while 1 {
      set portIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex portIdentifierIndex $op]
      if { $portIdentifier == "" } {
         return $end
      }

      # DR 212271:
      switch -- $portIdentifier {
         input -
     output -
     inout {
        return $end
     }
      }

      # Highlight declared port
      if { $caller == "highlight" } {
         $w tag add port $portIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],portSymbolsEnable) } {
         # Add port declaration into parser context
         [namespace parent]::declarationParserContext $id $w addLocal port $portIdentifier $start $parseIndex

         # Add port node to code browser
         if { $parentType=={module} } {
            set portId [[namespace parent]::parserContext $id register $portType $portIdentifier Verilog]
            [namespace parent]::BrowserNode  $id  $operation  $w            \
                                 $portId  $portIdentifierIndex  $parseIndex  \
                                 $portsFolderId  $beforeNode  $iconName
         }
      }

      # Get colon, or semicolon
      set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|;}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of parameter declaration
            break
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc registerDataTypeDeclaration { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Register data type declarations parser extension. Declaration is
# @comment parsed and internal parser data structure are updated
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  reg_declaration :
#        'reg'
#        range(?)
#        declare_register_name_comma_declare_register_name
#        ';'
#
#  time_declaration :
#        'time'
#        declare_register_name_comma_declare_register_name
#        ';'
#
#  integer_declaration :
#        'integer'
#        declare_register_name_comma_declare_register_name
#        ';'
#
#  declare_register_name_comma_declare_register_name :
#        declare_register_name
#        comma_declare_register_name(s?)
#
#  comma_declare_register_name :
#        ','
#        declare_register_name
#
#  declare_register_name :
#        register_name
#        range(?)
#
#  real_declaration :
#         'real'
#         real_identifier_comma_real_identifier
#         ';'
#
#  real_identifier_comma_real_identifier :
#         real_identifier
#        comma_real_identifier(s?)
#
#  comma_real_identifier :
#        ','
#        real_identifier
#
#  realtime_declaration :
#          'realtime'
#          real_identifier_comma_real_identifier
#          ';'
#
#  event_declaration :
#         'event'
#         event_identifier_comma_event_identifier
#          ';'
#
#  event_identifier_comma_event_identifier :
#        event_identifier
#        comma_event_identifier(s?)
#
#  comma_event_identifier :
#        ','
#        event_identifier
#
#  register_name :
#          register_identifier |
#          memory_identifier     range(?)
#
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # Get start parse index
   set parseIndex $end

#  reg_declaration :

   # Find and skip range
   if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
      # Found - parseIndex contains next scan position
   }

#  declare_register_name_comma_declare_register_name
   while 1 {
      set regIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex regIdentifierIndex $op]
      if { $regIdentifier == "" } {
         return $end
      }

      # Highlight declared reg
      if { $caller == "highlight" } {
         $w tag add reg $regIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],registerDataTypeSymbolsEnable) } {
         # Add reg declaration into parser context
         [namespace parent]::declarationParserContext $id $w addLocal register $regIdentifier $start $parseIndex
      }

      while 1 {
         # Find and skip range
         if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
            # Found - parseIndex contains next scan position
            continue
         }
         break
      }

      # Get colon, or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of reg declaration
            break
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc proceduralTimingControlStatement { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Procedural timing control statement parser extension.
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     "#" for delay or "@" for event controls
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
# @note   repeat_expression_event_control is processed after "repeat"
# @note keyword detection (repeatWhile).
#

#
#  statement :
#        ...
#        |  procedural_timing_control_statement
#        ...
#        | system_task_enable
#        ...
#
#  procedural_timing_control_statement :
#        delay_or_event_control
#        statement_or_null
#
#  delay_or_event_control :
#          delay_control
#        | event_control
#        | repeat_expression_event_control
#
#  delay_control :
#        '#'
#           delay_value_or_mintypmax_expression_in_paren
#        | <error?> <reject>
#
#  delay_value_or_mintypmax_expression_in_paren :
#          delay_value
#        | mintypmax_expression_in_paren
#
#  delay_value :
#        constant_mintypmax_expression
#  ...
#
#  mintypmax_expression_in_paren :
#        '(' mintypmax_expression ')'
#
#  ...
#
#  event_control :
#        '@'
#        <commit>
#           event_identifier_or_event_expression_list_in_paren
#        | <error?> <reject>
#
#  event_identifier_or_event_expression_list_in_paren :
#          event_expression_list_in_paren
#        | event_identifier
#
#  event_expression_list_in_paren :
#        '('
#           event_expression
#           or_event_expression(s?)
#        ')'
#
#  or_event_expression :
#        'or'
#        <commit>
#           event_expression
#        | <error?> <reject>
#
#  event_expression :
#          posedge_expression
#        | negedge_expression
#        | expression
#        | event_identifier
#
#  posedge_expression :
#          'posedge'
#        <commit>
#        expression
#        | <error?> <reject>
#
#  negedge_expression :
#          'negedge'
#        <commit>
#        expression
#        | <error?> <reject>
#
#  event_identifier :
#        identifier
#
#
#  repeat_expression_event_control :
#        'repeat'
#        <commit>
#        '('expression')'
#        event_control
#        | <error?> <reject>

#  system_task_enable :
#        system_task_name
#        expression_list_in_paren(?)
#        ';'
#
#  system_task_name :
#        '$'
#        identifier
#
#  expression_list_in_paren :
#        '('
#           expression_comma_expression
#        ')'
#
   set scanIndex $end

   skipValueOrIdentifierOrParentheses $id $w $wDirect $op scanIndex

   return $scanIndex
}

proc repeatWhile { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   repeat/while keywords parser extension
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  repeat_expression_statement :
#        'repeat'
#        <commit>
#        '(' expression ')'
#        statement
#        | <error?> <reject>
#
#  while_expression_statement :
#        'while'
#        <commit>
#        '(' expression ')'
#        statement
#        | <error?> <reject>
#

   set scanIndex $end

   # '(' expression ')'
   set p [[namespace current]::skipPossibleParentheses $id $w $wDirect $op scanIndex]
   if { $p == 0 } {
      return $end
   }

   return $scanIndex
}

proc specparamCmd { id w wDirect op moduleName start end } {
#
# @comment   Specparam keyword parser extension. Skips
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    moduleName  keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  specparam_declaration :
#        'specparam'
#         <commit>
#        specparam_assignment_comma_specparam_assignment
#        ';'
#      | <error?> <reject>
#
#  specparam_assignment_comma_specparam_assignment :
#         specparam_assignment
#         comma_specparam_assignment(s?)
#
#  comma_specparam_assignment :
#         ','
#         <commit>
#         specparam_assignment
#      | <error?> <reject>
#
#  specparam_assignment :
#          specparam_identifier_equal_constant_expression
#       | pulse_control_specparam
#
#  specparam_identifier_equal_constant_expression :
#        specparam_identifier
#        '='
#        constant_expression
#

   set scanStartIndex $end

   # Get semicolon
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {;}]

   if { $delimiter == {} } {
      # No valid delimiter
      return $end
   }

   return $scanStartIndex
}

proc task { id w wDirect op moduleName start end } {
#
# @comment   Task name reference parser extension.&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    moduleName  keyword recognized
# @argument    start       start position of parsed task name reference
# @argument    end         end position of parsed task name reference
#
# @comment   Results:&p
#
# @comment   - Currently nothing happens&p
#

   return $end

}

proc taskCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Task keyword parser extension. Task declaration is parsed and code
# @comment browser is called to update the code tree&p
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
# @comment   Results:&p
#
# @comment     - node that represents task declaration is created in the code browser tree&p
#

   variable task
   variable symbols

#
#  task_declaration :
#        'task'
#           task_identifier
#        ';'
#           task_item_declaration(s?)
#           statement_or_null
#        'endtask'
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   set scanStartIndex $end
#  putLog "task: start parsing at $start"

   # Get task_identifier
   set taskName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex taskNameIndex $op]

   if { $taskName == "" } { return $end }
#  putLog "task: $scanStartIndex $taskName at $taskNameIndex"

   # Highlight task name
   if { $caller == "highlight" } {
      $w tag add taskName $taskNameIndex $scanStartIndex
   }

   #
   # Get semicolon
   #
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {;}]

   if { $delimiter == "" } {
      # No valid delimiter
      return $end
   }
#  putLog "task: $scanStartIndex ;"

   if { $caller == "extract" } {

      set type "task"
   #  set taskStart [lindex [split $taskNameIndex .] 0]
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $taskName Verilog]

      # Create node
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

      [namespace parent]::parserContext $id push $blockId

      set symbols($id,$taskName) "task"

   }

   return $scanStartIndex
}

proc `defineDirective { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   `define directive parser extension. Directive
# @comment is parsed and internal parser data structure are updated. It is
# @comment proposed that `define takes one line but can be finished by comment
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

   # Get start parse index
   set parseIndex $end

   set macroIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex macroIdentifierIndex $op]
   if { $macroIdentifier == "" } {
      return $end
   }

   set parseIndex [[namespace current]::skipLine $id $w $wDirect $parseIndex $op]

   # Add declaration into parser context
   if { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],`defineSymbolsEnable) } {
      [namespace parent]::declarationParserContext $id $w addGlobal macro $macroIdentifier $start $parseIndex
   }

   return $parseIndex
}

proc parserTrace { wDirect lexemeIndex nextLexemeIndex scanStartIndex scanStopIndex lexeme } {
#
# @comment   Auxiliary procedure to trace parser state
#
# @argument    wDirect           direct window name
# @argument    lexemeIndex       lexeme found index
# @argument    nextLexemeIndex   next lexeme index
# @argument    scanStartIndex    scan start index
# @argument    scanStopIndex     scan stop index
# @argument    lexeme            lexeme found
#


   set st [open hte.debug a]

   set lineNo [lindex [split $lexemeIndex .] 0]
   set nextLineNo [lindex [split $nextLexemeIndex .] 0]

   if { $lineNo != $nextLineNo } {
      set line [$wDirect get [$wDirect index "$lexemeIndex linestart"] [$wDirect index "$lexemeIndex lineend"]]
      puts $st "===: \[$lineNo\] $line"
   }

   puts $st "[format "     %-8s: %8s - \[%-8s %8s\] - \[%s\]" $lexemeIndex $nextLexemeIndex $scanStartIndex $scanStopIndex $lexeme]"
   close $st

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

#CB_PER   if { $failed } {
#CB_PER      putLog "LexVerilog::structuralParserCB: ERROR: unknown block type \"$type\" was encountered at line $start"
#CB_PER   }

   # Workaroud for error in the external parser
   if       { $start == 0x7FFFFFFF && $end == 0x80000000 } {
      putLog "LexVerilog::structuralParserCB: ERROR: abstract min and max limits for \"$name\" of \"$type\""
      set end $start
   } elseif { $end < $start } {
      putLog "LexVerilog::structuralParserCB: ERROR: end value \"$end\" is less then start value ($start) for \"$name\" of \"$type\""
      set end $start
   }

   if { $name == {} } {
      putLog "LexVerilog::structuralParserCB: ERROR: empty name of \"$type\" at \"$start .. $end\""
      set name NOTSET
   }

   set parentId {}
   if { $fastFFTParserLevelProcessing } {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id level get $level] {}
   } else {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id levelRange get $level $start $end] {}
   }
#  foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id levelRange get $level $start $end] {}

   if { $parentId == {} } {
      putLog "LexVerilog::structuralParserCB: ERROR: no parent found for \"$name\" at $start .. $end at previous level"
      return
   }

   if { $externalDebug } {
      putLog "LexVerilog::structuralParserCB: $level \[$start .. $end\] \"$name\" of \"$type\" (as incarnation of \"$genuineType\" [string equal $genuineType $type])"
      set parentType [[namespace parent]::parserContext $id getType $parentId]
      set parentName [[namespace parent]::parserContext $id getName $parentId]
      putLog "LexVerilog::structuralParserCB: parent found: $parentId: \[$parentName of $parentType\]"
   }


   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $name Verilog]

   # Register range of lines occupied by node to permit some subsequent "parserContext $id levelRange get"
   if { $fastFFTParserLevelProcessing } {
      [namespace parent]::parserContext $id level set $level $blockId
   } else {
      [namespace parent]::parserContext $id levelRange set $level $start $end $blockId
   }
#  [namespace parent]::parserContext $id levelRange set $level $start $end $blockId

   set startIndex $start.0
   # Changed because of bug concerned with code block is started just
   # on the next line of the previous one. BTW external parser hangs when
   # code block is started on the same line as previous one is finished
#  set endIndex   [$wDirect index "$end.0 + 1 line linestart"]
   set endIndex   $end.end
   set iconName file
   catch {set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)}

   ##set decList {portIn portInOut portOut signal parameter wire reg}
   set exceptList {group ogroup portMapGroup parameterMapGroup portMap parameterMap}
   if { [lsearch -exact $exceptList $type] < 0 } {
#CB_PER      set sIndex [$wDirect search -elide -regexp "\\m$name\\M" $startIndex $endIndex]
      set sIndex [$wDirect search -elide  "$name" $startIndex $endIndex]
################ DR 336789
      if { $sIndex!={} } {
#CB_PER         set eIndex [$wDirect index "$sIndex wordend"]
         set eIndex $sIndex
         [namespace parent]::declarationParserContext $id $wDirect \
            addGlobal $type $name $sIndex $eIndex
      }
################ DR 336789
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
      putLog "LexVerilog::structuralParser: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "LexVerilog::structuralParser: $msg"
      return $msg
   }

   set fileSizeInLines [lindex [split [$wDirect index end] .] 0]

   set fastFFTParserLevelProcessing [HTE::Config::isConfiguration $HTE::Configuration(LexParser.[namespace tail [namespace current]],fastFFTParserLevelProcessing)]
   if { $externalDebug } {
      putLog "LexVerilog::structuralParser: fastFFTParserLevelProcessing: $fastFFTParserLevelProcessing"
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
      putLog "LexVerilog::structuralParser: analysis level: \"$level\""
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
         putLog "LexVerilog::structuralParser: invalid level \"$level\" returned"
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
      unset textObjects($fileName)
   }
   if {$createIgnoreFile} {
      catch {unset ::HteProxy::ignoreErrors([file normalize $fileName])}
   }
   ##### DR 194611 

   if { $externalDebug } {
      putLog "LexVerilog::structuralParser: FFT return: \"$errorDef\""
   }


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

#  putLog "LexVerilog::checkSyntaxCB: $level \[$start .. $end\]: \"$name\" of \"$type\""

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
      putLog "LexVerilog::checkSyntax: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "LexVerilog::checkSyntax: $msg"
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
      putLog "LexVerilog::checkSyntax: FFT analysis level: \"$level\""
   }

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
   
   set errorDef [$syntaxChecker $fileName "[namespace current]::checkSyntaxCB $id $wDirect %n %t %s %e %l" $level]
   
   ##### DR 194611
   if {$createTextObject} {
      unset textObjects($fileName)
   }
   if {$createIgnoreFile} {
      catch {unset ::HteProxy::ignoreErrors([file normalize $fileName])}
   }
   ##### DR 194611 

   if { $externalDebug } {
      putLog "LexVerilog::checkSyntax: FFT return: \"$errorDef\""
   }

   return $errorDef
}

proc locateMatchingStatus { id w index {word {}} } {
#
# @comment   Returns 0 or 1 as enable/disable status of "locate matching object"
# @comment command according to $index
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    index          text index
# @argument    word           word under or before $index
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::locateMatchingStatus>&p
#

   variable matchingObject

   set ok 0
   if { [array names matchingObject $word] != "" } {
      set ok 1
   } else {
      foreach char [list [$w get $index] [$w get "$index -1 char"]] {
         switch -exact -- $char {
            \{ -
            \} -
            \[ -
            \] -
            \( -
            \) -
            \" -
            \; {
               set ok 1
               break
            }
         }
      }
   }

   return $ok
}

proc locateMatching { id w index {word {}} } {
#
# @comment   Returns index of matching object or empty string
#
#   Arguments:
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    index          text index
# @argument    word           word under or before $index
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::locateMatching>&p
#

   variable matchingObject

#  set searchType [list backwardChar]

   # Try to find keyword as "matching object"
   if [catch {set matchingRE [lindex $matchingObject($word) 0]}] {

      # No keyword found as "matching object"

      set matchingRE {}
      # Set default search type
      set searchType [list backwardChar]

      # For characters under $index or before it
      foreach charIndex [list $index "$index -1 char"] {

         set char [$w get $charIndex]
         set beforeIndex [$w index "$charIndex -1 char"]

         switch -exact -- $char {

            \{ {
               set searchType [list forwardChar]
               set matchingRE {[{}]}
               break
            }

            \} {
               set matchingRE {[{}]}
               break
            }

            \[ {
               set searchType [list forwardChar]
               set matchingRE {[][]}
               break
            }

            \] {
               set matchingRE {[][]}
               break
            }

            \( {
               set searchType [list forwardChar]
               set matchingRE {[()]}
               break
            }

            \) {
               set matchingRE {[()]}
               break
            }

            \" {
               lappend searchType forwardChar
               set matchingRE {"} ;#"
               break
            }

            \; {
               variable statementBeginningRE
               set matchingRE $statementBeginningRE
               set searchType [list statementBeginning]
               break
            }
         }
         # End of switch switch

      }
      # End of foreach

      if { $matchingRE == {} } {
         return {}
      }
      set afterCharIndex [$w index "$charIndex +1 char"]

   } else {

      set wordIndex [$w search -elide -exact $word $index "$index +[string length $word] chars"]
      if { $wordIndex == {} } {
         set wordIndex [$w search -elide -backwards -exact $word $index "$index linestart"]
         if { $wordIndex == {} } {
            return {}
         }
      }

      set direction  [lindex $matchingObject($word) 1]
      set searchType [list ${direction}Word]

   }

   set language [namespace tail [namespace current]]

   foreach type $searchType {

      switch -exact -- $type {

         forwardChar {
#           putLog "LexVerilog::locateMatching: Search type $type Char: $char RE: $matchingRE Starting: $afterCharIndex"

            # Find matching chracter forwards starting from the next position after the $char
            set matchingIndex [[namespace parent]::findMatchingCharacter -forward $w $language $afterCharIndex $char $matchingRE]
         }

         backwardChar {
#           putLog "LexVerilog::locateMatching: Search type $type Char: $char RE: $matchingRE Starting: $charIndex"

            # Find matching chracter backwards starting from the position before the $char
            set matchingIndex [[namespace parent]::findMatchingCharacter -backward $w $language $charIndex $char $matchingRE]
         }

         statementBeginning   {
#           putLog "LexVerilog::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $charIndex"

            # Find statement beginning backwards starting from the position $charIndex
            set matchingIndex [[namespace parent]::findWord -backward $w $language $charIndex $matchingRE ";" {}]
         }

         forwardWord {
            set wordIndex [$w index "$wordIndex +[string length $word] chars"]
#           putLog "LexVerilog::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $wordIndex"

            set matchingIndex [[namespace parent]::findMatchingWord -forward $w $language $wordIndex $word $matchingRE]
         }

         backwardWord {
#           putLog "LexVerilog::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $wordIndex"

            set matchingIndex [[namespace parent]::findMatchingWord -backward $w $language $wordIndex $word $matchingRE]
         }

         default  {
            error "LexVerilog::locateMatching: invalid search type \"$type\""
         }
      }
      # End of switch

      if { $matchingIndex != {} } {
         return $matchingIndex
      }

   }
   # End of foreach

   return {}
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

   # Check that we are not inside a comment
   if {[::SyntaxHighlight::insideComment $w $index] != {}} { 
      regexp {^\s*} $line initialSpaces
      return $initialSpaces
   }
   
   set smartIndentValue $HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndentValue)
   set tabsToSpaces $HTE::Configuration(LexParser.[namespace tail [namespace current]],tabsToSpaces)
   set endOfLine [expr [$w index "$index lineend"] == [$w index $index]]

   if { $special } {
      if { [regexp {^(\s*//\s*)} $line match initialSpaces] != "0" } {
         return $initialSpaces
      }
   } else {

      set indentationREList {
                              {^(\s*).*begin}
                              {^(\s*)case}
                              {^(\s*)else}
                              {^(\s*)function}
                              {^(\s*)if.*(.*)}
                              {^(\s*)module}
                              {^(\s*)task}
                            }
      if { $tabsToSpaces } {
         set new [string repeat " " $smartIndentValue]
      } else {
         set new "\t"
      }

      foreach indentationRE $indentationREList {
         if { [regexp $indentationRE $line match initialSpaces] != "0" } {
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

   switch -exact -- $word {

      else           -
      end            -
      endcase        -
      endfunction    -
      endmodule      -
      endprimitive   -
      endtable       -
      endtask        {
         return 1
      }
   }

   return 0
}

