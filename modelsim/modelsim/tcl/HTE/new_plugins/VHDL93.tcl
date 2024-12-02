#HTEParser#vhdl'93#LexVHDL#VHDL Files#VHDL '93 Plugin#vhdl|vhd#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2001-2004 All Rights Reserved
#
#
# @comment VHDL plug-in for HTE lexical parser
#
# =============================================================================

# ======================================================================
# LexVHDL namespace - VHDL related lexical parser part
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

#  putLog "::HTE::LexParser::[namespace tail [namespace current]]::setParameters: sizeForFullParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)"
#  putLog "::HTE::LexParser::[namespace tail [namespace current]]::setParameters: sizeForFastParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)"

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

#  putLog "::HTE::LexParser::[namespace tail [namespace current]]::setParameters: sizeForFullParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)"
#  putLog "::HTE::LexParser::[namespace tail [namespace current]]::setParameters: sizeForFastParsing: $HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)"

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
      architecture               {"Architecture Body"          VhdlArch}
      attribute                  {"Attribute"                  VhdlAttribute}
      block                      {"Block"                      VhdlBlock}
      blockConfiguration         {"Configuration Block"        VhdlConfigSpec}
      comment                    {"Comment"                    {}}
      component                  {"Component Declaration"      VhdlCompDecl}
      configuration              {"Configuration Declaration"  VhdlConfigDecl}
      constant                   {"Constant"                   VhdlConstant}
      entity                     {"Entity Declaration"         VhdlEntity}
      functionBody               {"Function Body"              VhdlFunctionBody}
      function                   {"Function Declaration"       VhdlFunctionHdr}
      generate                   {"Generate"                   VhdlGenerate}
      generic                    {"Generic"                    VhdlGenericDecl}
      genericMap                 {"Generic Map"                VhdlGenericMapping}
      group                      {"Group"                      openfold}
      instance                   {"Instance"                   Instance}
      packageBody                {"Package Body"               VhdlPkgBody}
      packageHeader              {"Package Header"             VhdlPkgHdr}
      portBuffer                 {"Buffer Port"                PortBuf}
      portInOut                  {"Inout Port"                 PortIO}
      portIn                     {"Input Port"                 PortIn}
      portMap                    {"Port Map"                   PortMapping}
      portOut                    {"Output Port"                PortOut}
      procedureBody              {"Procedure Body"             VhdlProcBody}
      procedure                  {"Procedure Declaration"      VhdlProcDecl}
      process                    {"Process"                    VhdlProcess}
      signal                     {"Signal"                     signal}
      subtype                    {"Subtype"                    VhdlSubtype}
      type                       {"Type"                       VhdlType}
   }

   # By default, set all block types to be visible
   if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
   } else {
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
        {architecture attribute block blockConfiguration component configuration constant entity functionBody \
	 function generate generic genericMap instance packageBody packageHeader portBuffer portInOut portIn portMap \
	 portOut procedureBody procedure process signal subtype type}
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
   }


   set statementBeginningRE {\m(alias|assert|attribute|constant|disconnect|exit|file|generic|group|library|next|signal|shared|subtype|type|use|variable|wait|with)\M}
    variable matchingObject {

       {\mend\s+entity\s+(\w+)\M}               {}                   {backward}
       {\mend\s+(entity)}                       {\mentity\M}         {backward}
       {\mend\s+architecture\s+(\w+)\M}         {}                   {backward}
       {\mend\s+(architecture)}                 {\marchitecture\M}   {backward}
       {\mend\s+configuration\s+(\w+)\M}        {}                   {backward}
       {\mend\s+(configuration)}                {\mconfiguration\M}  {backward}
       {\mend\s+(for)}                          {\mfor\M}            {backward}
       {\mend\s+package\s+(\w+)\M}              {}                   {backward}
       {\mend\s+(package)}                      {\mpackage\M}        {backward}
       {\mend\s+package\s+body\s+(\w+)\M}       {}                   {backward}
       {\mend\s+(package)\s+body}               {\mpackage\s+body\M} {backward}
       {\mend\s+procedure\s+(\w+)\M}            {}                   {backward}
       {\mend\s+(procedure)}                    {\mprocedure\M}      {backward}
       {\mend\s+function\s+(\w+)\M}             {}                   {backward}
       {\mend\s+(function)}                     {\mfunction\M}       {backward}
       {\mend\s+component\s+(\w+)\M}            {}                   {backward}
       {\mend\s+(component)}                    {\mcomponent\M}      {backward}
       {\mend\s+units\s+(\w+)\M}                {}                   {backward}
       {\mend\s+(units)}                        {\munits\M}          {backward}
       {\mend\s+record\s+(\w+)\M}               {}                   {backward}
       {\mend\s+(record)}                       {\mrecord\M}         {backward}
       {\mend\s+block\s+(\w+)\M}                {}                   {backward}
       {\mend\s+(block)}                        {\mblock\M}          {backward}
       {\mend\s+process\s+(\w+)\M}              {}                   {backward}
       {\mend\s+(process)}                      {\mprocess\M}        {backward}
       {\mend\s+postponed\s+process\s+(\w+)\M}  {}                   {backward}
       {\mend\s+postponed\s+(process)}          {\mprocess\M}        {backward}
       {\mend\s+generate\s+(\w+)\M}             {}                   {backward}
       {\mend\s+(generate)}                     {\mgenerate\M}       {backward}
       {\mend\s+if\s+(\w+)\M}                   {}                   {backward}
       {\mend\s+(if)}                           {\mif\M}             {backward}
       {\mend\s+case\s+(\w+)\M}                 {}                   {backward}
       {\mend\s+(case)}                         {\mcase\M}           {backward}
       {\mend\s+loop\s+(\w+)\M}                 {}                   {backward}
       {\mend\s+(loop)}                         {\mloop\M}           {backward}
       {\mend\s+(\w+)\M}                        {}                   {backward}
       {\mend\M\s+|\mend\s+(entity|architecture|configuration|for|package|procedure|function|component|units|record|block|process|postponed\s+process|generate|if|case|loop)\M}                              {\m(entity|architecture|configuration|package|procedure|function|component|units|record|block|process|generate|if|case|loop)\M}              {backward}

   }

   #
   # VHDL parser subsection of configuration values
   # Set - only when they are not already loaded
   #
#   if { [expr [llength [array names HTE::Configuration LexParser.[namespace tail [namespace current]],*]] == 0] } {

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
#   }

      set HighlightRE(parentheses_fore) {\(|\)}
      set HighlightRE(integer) {(?:\W|\A)(\d+)(\W|$)}
      set HighlightRE(label) {(\w+)\s*:\s*(assert|case|block|for|if|postponed|process|wait|while)}

#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural) No
#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea) No
#   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)     No

   #
   #
   #
   set structuralBuiltinParser   ::HteBuiltinParser::parseVhdlFile
   set syntaxChecker             ::HteBuiltinParser::parseVhdlFile

   namespace import -force ::HTE::Console::putLog

   setParameters

proc parseComment { id w wDirect op start } {
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

   set lexeme2 [$wDirect get $start "$start + 2 chars"]
   if { $lexeme2 == "--" } {

      # Comment region reaches one symbol after end of line
      set endComment [$wDirect index "$start lineend + 1 char"]

      # LexParser hangs while search next lexeme command if it
      # starts from "end" index. So ...
      if { [$wDirect compare $endComment >= end] } {
         set endComment [$wDirect index "$start lineend"]
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
      default  {
         error "[namespace tail [namespace current]]::parseComment: invalid operation \"$op\""
      }
   }

   return $endComment
}

proc tagKeyword { caller w keyword keywordStart keywordEnd } {
#
# @comment   Sets keyword tags (standard keyword's tag and tag for specific
# @comment keyword) in the widget $w between $keywordStart and $keywordEnd
#
# @argument       caller         caller identifier (V - for VA parser and L - for linear)
# @argument       w              text widget window name
# @argument       keyword        keyword requested
# @argument       keywordStart   start keyword index
# @argument       keywordEnd     end keyword index
#

   if { $caller != {highlight} } {
      return
   }

#   set keyword [string tolower $keyword]

#   variable keyWords
   variable HighlightRE
   variable IgnoreCase

   if { [string match -nocase {yes} $IgnoreCase] } {
      set caseSwitch {-nocase}
   } else {
      set caseSwitch {}
   }

   set word [$w get $keywordStart $keywordEnd]
   if { [eval regexp $caseSwitch -- \$HighlightRE(keyWord) \$word] } {

      # Tag keyword
      $w tag add keyWord $keywordStart $keywordEnd

      # And get in tagName name of tag that should be used for
      # specific keyword $keyword
      set tagName [[namespace parent]::parserKeywordTag [namespace tail [namespace current]] keyWord $keyword]
      if { $tagName != "" } {
         $w tag add $tagName $keywordStart $keywordEnd
      }

   }

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

proc getIdentifierOrOperatorSymbol { id w wDirect op scanIndexVar foundIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest identifier or
# @comment operatorSymbol.&p
#
# @comment   If nearest lexeme found is identifier or operatorSymbol then it
# @comment will be simply returned, scanIndexVar variable will contain
# @comment index of text to continue scan and foundIndexVar variable - index
# @comment of identifier or operatorSymbol found.&p
#
# @comment   If it is not so returns empty string.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                operation requested for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found identifier position if scan was successful
#
# @comment   Results:&p
#
# @comment   - If word found:&p
# @comment     scanIndexVar - next symbol after word or operatorSymbol found&p
# @comment     foundIndexVar - word or operatorSymbol start index&p
# @comment   - If word does not found:&p
# @comment     scanIndexVar and foundIndexVar - next non-blank symbol&p
# @comment     starting from position scanIndexVar&p
#

#
#  operator_symbol :
#     '"' graphic_character '"'
#
#  graphic_character :
#
#     /[ A-Za-z0-9\-~`!@#$%^&*()_+={};:',.<>|]/
#
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex
   #
   # found lexeme index should be returned
   #
   upvar $foundIndexVar foundIndex

   set nonBlanksRE {\S}

   set identifierRE {^[A-Za-z][A-Za-z_0-9]*}
   set operatorSymbolRE {^"[ A-Za-z0-9\-~`!@#$%^&*()_+={};:',.<>|/]+"}
   set commentRE    {^\-\-}

   while 1 {

      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex]

      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanIndex $nonBlankIndex

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

      # Get identifier into $word if it is possible
      if { [regexp $identifierRE $line word] } {
         break
      }

      # Get operator symbol
      if { [regexp $operatorSymbolRE $line word] } {
         break
      }

      # Skip comment and try again
      if { [regexp $commentRE $line word] } {
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $op $scanIndex]
         continue
      }

      #
      # Fail to get identifier or operator symbol
      #
      set foundIndex $scanIndex
      return ""
   }

   set foundIndex $scanIndex
   set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
   return $word

}

proc getIdentifierOrCharacterLiteral { id w wDirect op scanIndexVar foundIndexVar } {
#
# @comment   Scans text in the window $w starting at index in the variable
# @comment scanIndexVar and tries to find nearest identifier or
# @comment character literal.&p
#
# @comment   If nearest lexeme found is identifier or character literal then it
# @comment will be simply returned, scanIndexVar variable will contain
# @comment index of text to continue scan and foundIndexVar variable - index
# @comment of identifier or character literal found.&p
#
# @comment   If it is not so returns empty string.&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                operation requested for comment
# @argument    scanIndexVar      reference to variable that contains scan start position. If scan is successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contains found identifier position if scan was successful
#
# @comment   Results:&p
#
# @comment   - If word found:&p
# @comment     scanIndexVar - next symbol after word or character literal found&p
# @comment     foundIndexVar - word or character literal start index&p
# @comment   - If word does not found:&p
# @comment     scanIndexVar and foundIndexVar - next non-blank symbol&p
# @comment     starting from position scanIndexVar&p
#

#
#  identifier_or_character_literal :
#  	      identifier | character_literal
#
#  identifier : /[A-Za-z][A-Za-z_0-9]*/
#
#  character_literal :
#  	      "'" graphic_character "'"
#
#

   #
   # scanIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $scanIndexVar scanIndex
   #
   # found lexeme index should be returned
   #
   upvar $foundIndexVar foundIndex

   set nonBlanksRE {\S}

   set identifierRE {^[A-Za-z][A-Za-z_0-9]*}
   set characterLiteralRE {^'[ A-Za-z0-9\-~`!@#$%^&*()_+={};:',.<>|/\\]'}
   set commentRE    {^--}

   while 1 {

      # Get in scanIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanIndex]

      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanIndex $nonBlankIndex

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]

      # Get identifier into $word if it is possible
      if { [regexp $identifierRE $line word] } {
         break
      }

      # Get character Literal
      if { [regexp $characterLiteralRE $line word] } {
         break
      }

      # Skip comment and try again
      if { [regexp $commentRE $line word] } {
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $op $scanIndex]
         continue
      }

      # Fail to get identifier or character literal
      set foundIndex $scanIndex
      return ""
   }

   set foundIndex $scanIndex
   set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]
   return $word

}


proc skipParentheses { w wDirect parseIndexVar } {
#
# @comment   Scans (skipping comments) some language construction in parentheses.
# @comment It is obsolete and can be called only by linear parser. It is better
# @comment to use universal skipSomethingInParentheses.&p
#
# @argument    w                    window name
# @argument    wDirect              direct window name
# @argument    parseIndexVar        scan position
#
# @comment   Results:&p
#
# @comment   - As a side effect parseIndexVar is changed so it points just after
# @comment balanced right bracket. All comments between old and new positions
# @comment are skipped.&p
#

   #
   # parseIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $parseIndexVar parseIndex

   set scanIndex $parseIndex

   set bracketRE    {\(|\)|--}

   set brackets         0
   set lineCountLimit   10
   set lineCount        0

   while 1 {

      # Get rest of line
      set line [$wDirect get $scanIndex [$wDirect index "$scanIndex lineend"]]
      set start 0

      while 1 {

         if { [regexp -indices -start $start $bracketRE $line found] } {

            set foundStart [lindex $found 0]
            set foundEnd   [lindex $found 1]
            set foundStr [string range $line $foundStart $foundEnd]

            set skipRangeLength [expr $foundEnd - $foundStart + 1]
            set start [expr $foundEnd + 1]

            if       { $foundStr == "("  } {

               incr brackets 1

            } elseif { $foundStr == ")"  } {

               incr brackets -1
               if { [expr $brackets == 0] } {
                  set parseIndex [$wDirect index "$scanIndex + $start chars"]
               }
               if { [expr $brackets <= 0] } { return }

            } elseif { $foundStr == "--" } {

               set scanIndex [$wDirect index "$scanIndex + 1 line linestart"]
               break

            } else {
               return
            }

         } else {

            if { [expr $brackets <= 0] } {
               set parseIndex [$wDirect index "$scanIndex + $start chars"]
               return
            }
            set scanIndex [$wDirect index "$scanIndex + 1 line linestart"]
            break

         }

      }

      incr lineCount
      if { [expr $lineCount > $lineCountLimit] } {
         # Fail lineCount"
         return
      }

   }
}

proc skipSomethingInParentheses { id caller w wDirect op parseIndexVar } {
#
# @comment   Scans (skipping comments) some language construction in parentheses.
# @comment For all keyword found while scanning sets appropriate tags.&p
#
# @argument    id             window identifier
# @argument    caller         caller identifier (V - for VA parser and L - for linear)
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    parseIndexVar  scan position
#
# @comment   Results:&p
#
# @comment   - As a side effect parseIndexVar is changed so it points just after
# @comment balanced right bracket. All comments between old and new positions
# @comment are skipped.&p
#

   #
   # parseIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $parseIndexVar parseIndex

   set brackets 0

   while 1 {

      set lexeme [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\w+|\(|\)}]
      if { $lexeme == "" } {
         break
      }

      switch -- $lexeme {
         "("   {
            incr brackets 1
         }
         ")"   {
            incr brackets -1
            if { [expr $brackets <= 0] } {
               break
            }
         }
         default  {
            [namespace current]::tagKeyword $caller $w $lexeme [$wDirect index "$parseIndex -[string length $lexeme] chars"] $parseIndex
         }
      }

   }

}

proc skipSimpleExpression { id w wDirect op parseIndexVar } {
#
# @comment   Scans (skipping comments) simple expression.
# @comment For all keyword found while scanning sets appropriate tags.&p
#
# @argument    id             window identifier
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    parseIndexVar  scan position
#
# @comment   Results:&p
#
# @comment   - As a side effect parseIndexVar is changed so it points just after
# @comment balanced right bracket. All comments between old and new positions
# @comment are skipped.&p
#

   #
   # parseIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $parseIndexVar parseIndex

   set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\w+}]

}

proc skipSomethingThatIncludeParentheses { id caller w wDirect op parseIndexVar delimiterRE } {
#
# @comment   Scans (skipping comments) some language construction that can
# @comment contain parentheses and should be limited by simple regular expression
# @comment or right bracket. Returns found delimiter.&p
#
# @comment   For all keyword found while scanning sets appropriate tags.&p
#
# @argument    id             window identifier
# @argument    caller         caller identifier (V - for VA parser and L - for linear)
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    parseIndexVar  scan position
# @argument    delimiterRE    regular expression that match end of construction
#
# @comment   Results:&p
#
# @comment   - As a side effect parseIndexVar is changed so it points just after
# @comment language costruction with balanced parentheses. All comments between
# @comment old and new positions are skipped.&p
#

   #
   # parseIndex is start scan position at the beginning and
   # contains index for next search after completion
   #
   upvar $parseIndexVar parseIndex

   set scanIndex $parseIndex

   set brackets 0
   set totalDelimiterRE "$delimiterRE|\\w+|\\(|\\)"

   while 1 {

      set lexeme [getLexeme $id $w $wDirect $op parseIndex $totalDelimiterRE]
      if { $lexeme == "" } {
         break
      }

      switch -- $lexeme {
         "("   {
            incr brackets 1
         }
         ")"   {
            incr brackets -1
            if { [expr $brackets >= 0] } {
               continue
            }
            return ")"
         }
         default  {
            if { [regexp $delimiterRE $lexeme] } {
               return $lexeme
            }
            [namespace current]::tagKeyword $caller $w $lexeme [$wDirect index "$parseIndex -[string length $lexeme] chars"] $parseIndex
         }
      }

   }

   return ""

}


proc getSemicolon { id w wDirect op scanStartIndexVar foundIndexVar } {
#
# @comment   Scan text in the window $w starting at index in the variable
# @comment scanStartIndexVar, skip comments and try to find nearest lexeme.&p
#
# @comment   If lexeme found is semicolon then it will be returned,
# @comment scanStartIndexVar variable will contain index of text to continue scan
# @comment and foundIndexVar variable - index of semicolon found.&p
#
# @comment   If it is not so returns empty string. scanStartIndexVar is an index
# @comment of lexeme found and foundIndexVar is unchanged&p
#
# @argument    id                window identifier
# @argument    w                 window name
# @argument    wDirect           direct window name
# @argument    op                operation requested for comment
# @argument    scanStartIndexVar reference to variable that contains scan start position. If scan was successful it will contain position to continue scanning
# @argument    foundIndexVar     reference to variable that will contain found identifier position if scan was successful
#
# @comment   Results:&p
#
# @comment   - Procedure return found semicolon or empty string. Variables
# @comment scanStartIndexVar and foundIndexVar may be changed at success&p
#

   upvar $scanStartIndexVar scanStartIndex
   upvar $foundIndexVar foundIndex

   set nonBlanksRE {\S}

   set semicolonRE {^;}
   set commentRE   {^--}

   while 1 {
      # Get in scanStartIndex first non-blank symbol index
      set nonBlankIndex [$wDirect search -elide -regexp $nonBlanksRE $scanStartIndex]

      if { $nonBlankIndex == "" } {
         return ""
      }
      set scanStartIndex $nonBlankIndex

      # Get rest of line
      set line [$wDirect get $scanStartIndex [$wDirect index "$scanStartIndex lineend"]]

      # Get semicolon
      if { [regexp $semicolonRE $line word] } {
         break
      }

      # Skip comment and try again
      if { [regexp $commentRE $line] } {
         set scanStartIndex [[namespace current]::parseComment $id $w $wDirect $op $scanStartIndex]
         continue
      }

      # Fail to get semicolon
      set foundIndex $scanStartIndex
      return ""
   }

   set foundIndex $scanStartIndex
   set scanStartIndex [$wDirect index "$scanStartIndex + 1 chars"]
   return $word

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

      if { $lexeme == "--" } {
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

   # Append to searched pattern start comment RE
   set searchOrCommentRE $searchRE|--

#  putLog "getLexeme: starting at $scanIndex for {$searchOrCommentRE}"
   while 1 {

      # Search requested lexeme or comment
      set lexemeIndex [$wDirect search -elide -regexp -nocase -count [namespace current]::lexemeCount $searchOrCommentRE $scanIndex end]
      if { $lexemeIndex == "" } {
#        putLog "getLexeme: Fail to find $searchOrCommentRE starting at $scanIndex"
         return ""
      }

      # Get what was found
      set lexeme [$wDirect get $lexemeIndex "$lexemeIndex + $lexemeCount chars"]
      set scanIndex $lexemeIndex
#     putLog "getLexeme: Found $lexeme starting at $scanIndex"

      if { $lexeme == "--" } {
         # Parse comment and move parser pointer
         set scanIndex [[namespace current]::parseComment $id $w $wDirect $op $scanIndex]
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

proc discreteRange { id caller w wDirect op parseIndexVar delimiterRE } {
#
# @comment   Squentially tries to determine and parse range_attribute_name or
# @comment simple_expression_to_downto_simple_expression or
# @comment discrete_subtype_indication.&p
#
# @argument    id             window identifier
# @argument    caller         caller identifier (V - for VA parser and L - for linear)
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    parseIndexVar  scan start position
# @argument    delimiterRE    regular expression to match end of subtype indication
#
# @comment   Results:&p
#
# @comment   - Returns empty string if scanning was failed. Returns delimiter
# @comment that corresponds to end of discrete range. As a side effect
# @comment parseIndexVar is changed so it points to the end of discrete range.
# @comment All encountered comments are skipped&p
#

#  discrete_range :
#        range_attribute_name
#        | simple_expression_to_downto_simple_expression
#        | discrete_subtype_indication
#
#  range_attribute_name : attribute_name
#
#  attribute_name :
#  	   identifier "'" identifier
#
#  simple_expression_to_downto_simple_expression :
#        simple_expression
#        reserved_word_to_or_downto
#        simple_expression
#
#  discrete_subtype_indication :
#        subtype_indication
#

   upvar $parseIndexVar parseIndex

   set attributeNameRE {[A-Za-z][A-Za-z_0-9]*'[A-Za-z][A-Za-z_0-9]*}

   # range_attribute_name

   # Keep parseIndex
   set attributeNameIndex $parseIndex

   set attributeName [[namespace current]::getExactLexeme $id $w $wDirect $op attributeNameIndex $attributeNameRE]
   if { $attributeName != "" } {

      # Restore parseIndex
      set parseIndex $attributeNameIndex

      # And return delimiter
      return [[namespace current]::getLexeme $id $w $wDirect $op parseIndex $delimiterRE]
   }

   # simple_expression_to_downto_simple_expression

   # Keep parseIndex
   set expressionIndex $parseIndex

   [namespace current]::skipSimpleExpression $id $w $wDirect $op expressionIndex
   set toDownto [[namespace current]::getExactLexeme $id $w $wDirect $op expressionIndex {downto|to}]

   switch -exact -- [string tolower $toDownto] {
      to       -
      downto   {
         # Restore parseIndex
         set parseIndex $expressionIndex

         if { $caller == "highlight" } {
            # Highlight keyword
            [namespace current]::tagKeyword $caller $w $toDownto [$wDirect index "$parseIndex -[string length $toDownto] chars"] $parseIndex
         }

         [namespace current]::skipSimpleExpression $id $w $wDirect $op parseIndex

         # And return delimiter
         return [[namespace current]::getLexeme $id $w $wDirect $op parseIndex $delimiterRE]
      }
   }

   # discrete_subtype_indication

   return [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex $delimiterRE]

}


proc skipSubtypeIndication { id caller w wDirect op parseIndexVar delimiterRE } {
#
# @comment   Searches type name and returns delimiter after subtype indication.
# @comment Search starts from $parseIndexVar and ignores comments. Search fails
# @comment if type name is not found as nearest lexeme. If type name is found
# @comment it is marked by tag typeName (for "V" caller) and all text including
# @comment comments is skipped up to lexeme matched by $delimiterRE regular
# @comment expression. parseIndexVar variable is changed to reflect scan results.&p
#
# @argument    id             window identifier
# @argument    caller         caller identifier (V - for VA parser and L - for linear)
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    parseIndexVar  scan start position
# @argument    delimiterRE    regular expression to match end of subtype indication
#
# @comment   Results:&p
#
# @comment   - Returns empty string if type name is not found. Returns delimiter
# @comment that corresponds to end of subtype indication. As a side effect
# @comment parseIndexVar is changed so it points to the end of subtype
# @comment indication. All encountered comments are skipped&p
#

#
#  subtype_indication :
#        type_mark
#        range_or_simple_or_discrete(?)
#
#  range_or_simple_or_discrete :
#        reserved_word_range_range_attribute_name_or_simple_downto_expression
#        | discrete_range_in_parens
#
#  reserved_word_range_range_attribute_name_or_simple_downto_expression :
#        reserved_word_range
#        range_attribute_name_or_simple_expression_to_downto_simple_expression
#
#  discrete_range_in_parens :
#        '(' discrete_range ')'
#
#  discrete_range - discreteRange
#
#  type_mark : type_name
#
#  type_name : identifier
#

   upvar $parseIndexVar parseIndex

   set typeName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex typeNameIndex]
   if { $typeName == "" } {
      return ""
   }

   # Highlight type name
   if { $caller == "highlight" } {
      $w tag add typeName $typeNameIndex $parseIndex
   }

   set rangeOrBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {range|\(}]
   if       { $rangeOrBracket == "(" } {
#  discrete_range_in_parens :
      set parseIndex [$wDirect index "$parseIndex -1 char"]
      [namespace current]::skipSomethingInParentheses $id $caller $w $wDirect $op parseIndex
   } elseif { [string match -nocase {range} $rangeOrBracket] } {;# DR 340411
#  reserved_word_range_range_attribute_name_or_simple_downto_expression :
      if { $caller == "highlight" } {
         set rStart [$wDirect index "$parseIndex -1c wordstart"]
         tagKeyword $caller $w $rangeOrBracket $rStart $parseIndex
      }

      set toDownto [getLexeme $id $w $wDirect $op parseIndex {to|downto}]
      if { $caller == "highlight" && $toDownto!={} } {
         set tdStart [$wDirect index "$parseIndex -1c wordstart"]
         tagKeyword $caller $w $toDownto $tdStart $parseIndex
      }
   };# else {
#      return ""
#   }
################################### DR 340411
   return [[namespace current]::getLexeme $id $w $wDirect $op parseIndex $delimiterRE]

}

proc associationList { id caller w wDirect op start parseIndexVar } {
#
# @comment   Searches identifiers and returns delimiter after association list.
# @comment Search starts from $parseIndexVar and ignores comments.
# @comment Firstly it tries to detect formal part in the list item, then
# @comment select identifier and skips up to item end.&p
#
# @argument    id             window identifier
# @argument    caller         caller identifier (V - for VA parser and L - for linear)
# @argument    w              window name
# @argument    wDirect        direct window name
# @argument    op             requested operation for comment
# @argument    start          phrase beginning index
# @argument    parseIndexVar  scan start position
#
# @comment   Results:&p
#
# @comment   - Returns empty string if scanning is failed. Otherwise it returns
# @comment delimiter that corresponds to end of association list. As a side effect
# @comment parseIndexVar is changed so it points to the end of list. All
# @comment encountered comments are skipped&p
#

#
#  association_list :
#        actual_formal_comma_actual_formal
#      | <error>
#
#  actual_formal_comma_actual_formal :
#        actual_part_with_optional_formal_part
#        comma_actual_part_with_optional_formal_part(s?)
#      | <error>
#
#  comma_actual_part_with_optional_formal_part :
#        ','
#        actual_part_with_optional_formal_part
#      | <error>
#
#  actual_part_with_optional_formal_part :
#        formal_part_and_arrow(?)
#        actual_part
#      | <error>
#
#  formal_part_and_arrow :
#        formal_part '=>'
#      | <error>
#
#  formal_part :
#        generic_name
#      | port_name
#      | parameter_name
#      | function_name generic_port_parameter_selection
#      | type_mark generic_port_parameter_selection
#      | <error>
#
#  generic_port_parameter_selection :
#        '(' generic_name_port_name_parameter_name ')'
#        | <error>
#
#  generic_name_port_name_parameter_name :
#        generic_name | port_name | parameter_name
#      | <error>
#
#  actual_part :
#        expression_rule
#      | variable_name
#      | reserved_word_open
#      | function_name_signal_name_or_variable_name_selection
#      | type_mark_signal_name_or_variable_name_selection
#      | <error>
#
#
#  function_name_signal_name_or_variable_name_selection :
#        function_name
#        signal_name_or_variable_name_in_parens
#
#  type_mark_signal_name_or_variable_name_selection :
#        type_mark
#        signal_name_or_variable_name_in_parens
#
#  signal_name_or_variable_name_in_parens :
#        '(' signal_name_or_variable_name ')'
#
#  signal_name_or_variable_name :
#        signal_name | variable_name
#

   upvar $parseIndexVar parseIndex

   while 1 {

      # Do not change parse index yet
      set delimiterIndex $parseIndex
      set delimiter [[namespace current]::getLexeme $id $w $wDirect $op delimiterIndex {=>|,|\)}]

      switch -exact -- $delimiter {

         "=>"  {

            #  formal_part_and_arrow(?)
            #  actual_part

            set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
            if { $identifier == "" } {
               return ""
            }

            # Highlight identifier
            if { $caller == "highlight" } {
               $w tag add aIdentifier $identifierIndex $parseIndex
            } else {
               # Update association list identifier definitions
#              [namespace parent]::declarationParserContext $id $w addLocal association $identifier $identifierIndex $parseIndex
               [namespace parent]::declarationParserContext $id $w addLocal association $identifier $start $parseIndex
            }

            set delimiter [[namespace current]::skipSomethingThatIncludeParentheses $id $caller $w $wDirect $op parseIndex {,}]
            switch -- $delimiter {
               ,  {
                  # Continue scan association list
                  continue
               }
               default   {
                  # Right parentheses that limits association_list is reached
                  break
               }
            }

         }

         ","   {
            #  actual_part
            set parseIndex $delimiterIndex
            continue
         }

         ")"   {
            # Right parentheses that limits association_list is reached
            set parseIndex $delimiterIndex
            break
         }

         default  {
            return ""
         }
      }

   }

   return $delimiter

}

proc architectureBodyCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Architecture body parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
#   Arguments:
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  architecture_body :
#     reserved_word_architecture
#        identifier
#     reserved_word_of
#        entity_name
#     reserved_word_is
#        block_declarative_item(s?)
#     reserved_word_begin
#        concurrent_statement(s?)
#     reserved_word_end
#     reserved_word_architecture(?)
#     identifier(?)
#     ';'
#

   set scanStartIndex $end

   set architectureName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex architectureNameIndex]
   if { $architectureName == "" } { return $end }

   set type              architecture
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "of"] == "" } {
      return $end
   }

   set entityName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex]
   if { $entityName == "" } { return $end }

   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "is"] == "" } {
      return $end
   }

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $architectureName VHDL]

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

#  putLog "Architecture: \"$architectureName\" of \"$entityName\" starting at $architectureNameIndex"
   [namespace parent]::parserContext $id push $blockId

   ####################################### declarations scope
   set declId [[namespace parent]::parserContext $id register group declarations VHDL]
   set declEnd $scanStartIndex
   if { [[namespace current]::getLexeme $id $w $wDirect $op declEnd "begin"] == "" } {
      return $end
   }

   [namespace parent]::BrowserNode                   \
                           $id                       \
                           $operation                \
                           $w                        \
                           $declId                   \
                           $foundWordIndex           \
                           $declEnd                  \
                           $blockId                  \
                           {}                        \
                           openfold

   [namespace parent]::parserContext $id push $declId
   ##########################################################

   return $scanStartIndex
}

proc componentDeclarationCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Component declaration parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  component_declaration :
#     reserved_word_component
#        component_name
#     reserved_word_is(?)
#        generic_declaration_section(?)
#        port_declaration_section(?)
#     reserved_word_end
#        reserved_word_component
#        component_name(?)
#     ';'
#  | <error>
#

   set scanStartIndex $end

   set componentName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex componentNameIndex]
   if { $componentName == "" } { return $end }

   set type           component
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $componentName VHDL]

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


   return $scanStartIndex
}

proc configurationDeclarationCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Configuration declaration parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  configuration_declaration :
#     reserved_word_configuration
#        identifier
#     reserved_word_of
#        entity_name
#     reserved_word_is
#        use_clause_or_attribute_specification_or_group_declaration(s?)
#        block_configuration
#     reserved_word_end
#        reserved_word_configuration(?)
#        identifier(?)
#     ';'
#

   set scanStartIndex $end

   set configurationName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex configurationNameIndex]
   if { $configurationName == "" } { return $end }

   set type               configuration
#   set configurationStart [lindex [split $configurationNameIndex .] 0]
#   set configurationEnd   ""
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)


   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "of"] == "" } {
      return $end
   }

   set entityName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex]
   if { $entityName == "" } { return $end }

   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "is"] == "" } {
      return $end
   }

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $configurationName VHDL]

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


#  putLog "Configuration: \"$configurationName\" of \"$entityName\" starting at $configurationNameIndex"
   [namespace parent]::parserContext $id push $blockId


   return $scanStartIndex

}

proc constantCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Constant declaration parser extension
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  constant_declaration :
#  	   reserved_word_constant
#  		   identifier_comma_identifier
#  	   ':'
#  		   subtype_indication
#  		   default_value(?)
#  	   ';'
#
#  constant_interface :
#  	   reserved_word_constant(?)
#  		   identifier_comma_identifier
#  	   ':'
#  	   reserved_word_in(?)
#  		   subtype_indication
#  		   default_value(?)
#  	   | <error>
#

   set parseIndex $end

   #  identifier_comma_identifier ':'
#   if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::constantCmd: identifier_comma_identifier ':' $parseIndex" }

   while 1 {

      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      # Highlight declared constant
      if { $caller == "highlight" } {
         $w tag add constant $identifierIndex $parseIndex
      } else {
         # Update symbols definitions
#        [namespace parent]::declarationParserContext $id $w addLocal constant $identifier $identifierIndex $parseIndex
         [namespace parent]::declarationParserContext $id $w addLocal constant $identifier $start $parseIndex
      }

      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
      switch -- $delimiter {
         ,  {
            continue
         }
         :  {
            break
         }
         default  {
            return $end
         }
      }
   }

   # reserved_word_in(?)
   set in [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {in\W}]
   if { $in != "" } {
      # Strip keyword delimiter
      set in [string range $in 0 1]
      # Highlight keyword
      [namespace current]::tagKeyword $caller $w $in [$wDirect index "$parseIndex -3 char"] [$wDirect index "$parseIndex -1 char"]
   }

   # subtype_indication
   # default_value(?)

   set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]
   if { $delimiter != ";" } {
      return $end
   }

   return $parseIndex

}

proc beginCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    wDirect     direct window name
# @argument    w           window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of parsed keyword
# @argument    end         end position of parsed keyword

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
   
   set parentType [[namespace parent]::parserContext $id getType $parentId]
   
   if { $parentType == {archDecl} } {
      [namespace parent]::parserContext $id pop
   }
   
   return $end
}

proc endCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   End of block keyword parser extension. Get last opened block
# @comment definition from blocks stack and complete code tree node.&p
# @comment   Calls code browser to update code tree.&p
# @comment   Currently not implemented structural blocks: case, if, process, for, loop&p
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
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

#   variable linearExtDebug

   set scanStartIndex $end

   set word [[namespace current]::getSemicolon $id $w $wDirect $op scanStartIndex foundWordIndex]
   if       { $word == ";" } {

   } else {

      set word [[namespace current]::getIdentifierOrOperatorSymbol $id $w $wDirect $op scanStartIndex foundWordIndex]
      set word [string tolower $word]

      switch -exact -- $word {

         ""          {
            return $end
         }

         case        -
         if          -
         process     -
         for         -
         loop        {
            return $scanStartIndex
         }

      }
      set word [[namespace current]::getSemicolon $id $w $wDirect $op scanStartIndex foundWordIndex]

   }

   if { [[namespace parent]::parserContext $id checkEmpty] } {

#      if { $linearExtDebug } {
#         putLog "$scanStartIndex: [namespace tail [namespace current]]::endCmd: Block List empty at $foundWordIndex ..."
#      }

   } else {

      set blockId [[namespace parent]::parserContext $id pop]

      set blockEnd $scanStartIndex
#     set blockEnd "$scanStartIndex -1 char"

#      if { $linearExtDebug } {
#         set blockType  [[namespace parent]::parserContext $id getType $blockId]
#         set blockName  [[namespace parent]::parserContext $id getName $blockId]
#         putLog "endCmd: $scanStartIndex End of $blockType \"$blockName\""
#      }
      [namespace parent]::BrowserCompleteNode   \
                              $id               \
                              $w                \
                              $blockId          \
                              $blockEnd

   }

   return $scanStartIndex

}

proc genericCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Generic declarations parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  generic_declaration_section :
#        reserved_word_generic generic_interface_list(?) ';'
#
#  generic_interface_list :
#        '('
#           generic_interface_list_entry_semicolon_generic_interface_list_entry
#        ')'
#
#  generic_interface_list_entry_semicolon_generic_interface_list_entry :
#        generic_interface_list_entry
#        semicolon_generic_interface_list_entry(s?)
#
#  semicolon_generic_interface_list_entry :
#        ';'
#        generic_interface_list_entry
#
#  generic_interface_list_entry :
#        identifier_comma_identifier ':'
#        subtype_indication
#        default_value(?)
#
#  identifier_comma_identifier :
#        identifier
#        comma_identifier(s?)
#
#  comma_identifier :
#        ','
#        identifier
#
#  subtype_indication - skipSubtypeIndication
#
#  default_value :
#        ':=' static_expression
#
#   ...
#
#  generic_map_section :
#        reserved_word_generic
#        reserved_word_map
#        optional_generic_association_list(?)
#
#  optional_generic_association_list :
#        '('
#           generic_association_list
#        ')'
#
#  generic_association_list :
#        association_list
#        | <error>
#
#

   set parseIndex $end

#   if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: $parseIndex" }

   #  generic_map_section :
   #     or
   #  generic_declaration_section :

   set mapKeyword [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex mapIndex]
   if { $mapKeyword != "" } {

      # Highlight keyword
      [namespace current]::tagKeyword $caller $w $mapKeyword [$wDirect index "$parseIndex -[string length $mapKeyword] chars"] $parseIndex

#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: generic_map_section: $parseIndex" }

      # optional_generic_association_list :

      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
      if { $leftBracket == "" } {
         # No bracket. Return $parseIndex to skip "map" keyword
         return $parseIndex
      }
#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: (: $parseIndex" }

      # generic_association_list
      set delimiter [[namespace current]::associationList $id $caller $w $wDirect $op $start parseIndex]

      # If ")" is returned - end of association_list is reached
#      switch -- $delimiter {
#         ")"  {
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: ) $parseIndex" }
#         }
#         default  {
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: \"$delimiter\" $parseIndex" }
#         }
#      }

   } else {

#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: generic_declaration_section: $parseIndex" }

#     generic_interface_list

      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
      if { $leftBracket == "" } {
         # No bracket
         return $end
      }
#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: (: $parseIndex" }

      while 1 {
         #  generic_interface_list_entry_semicolon_generic_interface_list_entry :

         #  identifier_comma_identifier ':'
#         if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: identifier_comma_identifier ':' $parseIndex" }

         while 1 {
            set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
            if { $identifier == "" } {
               return $end
            }
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: identifier: $identifier $parseIndex" }

            # Highlight declared constant parameter
            if { $caller == "highlight" } {
               $w tag add generic $identifierIndex $parseIndex
            } else {
               # Update constant parameter definitions
               [namespace parent]::declarationParserContext $id $w addLocal generic $identifier $start $parseIndex
            }

            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
            switch -- $delimiter {
               ,  {
#                  if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: , $parseIndex" }
                  continue
               }
               :  {
#                  if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: : $parseIndex" }
                  break
               }
               default  {
                  return $end
               }
            }
         }

         # subtype_indication
         # Skip ...
         set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {:=|;|\)}]

         switch -- $delimiter {
            ":="  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: := $parseIndex" }
            }
            ;  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: ; $parseIndex" }
               continue
            }
            ")"  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: ) $parseIndex" }
               break
            }
            default  {
               return $end
            }
         }


#         if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: := $parseIndex" }

         # default_value(?)

         set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {;|\)}]
         switch -- $delimiter {
            ;  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: ; $parseIndex" }
               continue
            }
            ")"  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::genericCmd: ) $parseIndex" }
               break
            }
            default  {
               return $end
            }
         }
      }

   }

   return $parseIndex
}

proc entityDeclarationCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Entity declaration parser extension. Entity declaration header is
# @comment parsed and code browser is called to update the code tree&p
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#
# @comment   Results:&p
#
# @comment     - node that represents entity declaration is created in the
# @comment code browser tree&p
#

#
#  entity_declaration :
#     reserved_word_entity
#        entity_name
#     reserved_word_is
#        generic_declaration_section(?)
#        port_declaration_section(?)
#        entity_declaritive_item(?)
#        begin_entity_section(?)
#     reserved_word_end
#        reserved_word_entity(?)
#        identifier(?)
#     ';'
#

   set scanIndex $end

   set entityName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanIndex entityNameIndex]
   if { $entityName == "" } { return $end }

   set type        entity
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanIndex foundWordIndex "is"] == "" } {
      return $end
   }

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $entityName VHDL]

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


#  putLog "Entity: \"$entityName\" starting at $entityNameIndex"
   [namespace parent]::parserContext $id push $blockId


   return $scanIndex
}

proc functionCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Function keyword parser extension. Parses function declaration or
# @comment body and calls code browser to update code tree
# @comment the code tree&p
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of parsed keyword
# @argument    end         end position of parsed keyword
#
# @comment   Results:&p
#
# @comment     - funcrion body definition is pushed into stack of opened lexical blocks&p
# @comment     - set appropriate element of array symbols as "function"&p
# @comment     - adds function definition to array "function"&p
# @comment     - node that represents function declaration or body is created in the code browser tree&p
#

#
#  subprogram_body :
#     subprogram_specification
#     reserved_word_is
#        subprogram_declarative_part(?)
#     reserved_word_begin
#        sequential_statement(s?)
#     reserved_word_end
#     reserved_word_function_or_procedure(?)
#     identifier_or_operator_symbol(?)
#     ';'
#  | <error>
#
#
#  subprogram_declaration :
#     subprogram_specification
#     ';'
#
#
#  subprogram_specification :
#     procedure_specification | function_specification
#
#  identifier_or_operator_symbol :
#     identifier | operator_symbol
#
#  function_specification :
#     pure_or_impure(?)
#     reserved_word_function
#        identifier_or_operator_symbol
#     parameter_interface_list(?)
#     reserved_word_return
#        type_mark
#  | <error>
#
#
#  parameter_interface_list :
#     '(' interface_list ')'
#
   set scanStartIndex $end

   #
   # Get function name
   #
   set functionName [[namespace current]::getIdentifierOrOperatorSymbol $id $w $wDirect $op scanStartIndex functionNameIndex]
   if { $functionName == "" } {
      return $end
   }
#   set functionStart [lindex [split $functionNameIndex .] 0]

   #
   # Skip parameter interface list in case of extracting
   # In case of highlighting we need to tag the typeName
   #
   if { $caller == "highlight" } {
      set tempIndex $scanStartIndex
      set parenIndex $tempIndex
      set functionCheck [[namespace current]::getLexeme $id $w $wDirect $op parenIndex "\\(|return|;"]
      if {$functionCheck == ";"} {
         return $end
      }
      if {$functionCheck == "("} {
          while 1 { 
             set delimiterStr [[namespace current]::getLexeme $id $w $wDirect $op tempIndex {:|\)|;}]
             if {$delimiterStr == ";"} {
                continue
             } elseif {$delimiterStr == "\)"} {
                set scanStartIndex $tempIndex
                break
             } elseif {$delimiterStr == ":"} {
                set argType [[namespace current]::getAlphaNumericWord $id $w $wDirect $op tempIndex foundWordIndex]
                if {$argType != ""} {
                   set modeList {IN OUT INOUT in out inout}
                   if {[lsearch $modeList $argType] < 0} {
                      $w tag add typeName $foundWordIndex $tempIndex
                   }
                   set delimiterStr [[namespace current]::getLexeme $id $w $wDirect $op tempIndex {;|\)}]
                   if {$delimiterStr == {)}} {
                      set scanStartIndex $tempIndex
                      break
                   } elseif {$delimiterStr == ";"} {
                      continue
                   }		        
                }
             }  
          }
      }
   } else {
      [namespace current]::skipParentheses $w $wDirect scanStartIndex
   }
 
   #
   # Get return keyword
   #
   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "return"] == "" } {
      return $end
   }

   #
   # Get type_mark
   #
   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex] == "" } {
      return $end
   } else {
      if {$caller == "highlight"} {
         $w tag add typeName $foundWordIndex $scanStartIndex
         return $scanStartIndex
      }
   }
   set type [[namespace current]::getSemicolon $id $w $wDirect $op scanStartIndex foundWordIndex]
   if       { $type == ";" } {

      set type        function
#     set functionEnd $functionStart
#     set functionEnd $scanStartIndex
      set functionEnd "$scanStartIndex -1 char"

   } else {

      set type [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex]
      if { [string equal -nocase $type "is"] } {
         set type functionBody
      } else {
         return $end
      }
      set functionEnd ""

   }
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

#  putLog "$scanStartIndex $type: \"$functionName\" started at $functionNameIndex"

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $functionName VHDL]

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

   if { $type == "functionBody" } {
      [namespace parent]::parserContext $id push $blockId
   } else {
      [namespace parent]::BrowserCompleteNode   \
                              $id               \
                              $w                \
                              $blockId          \
                              $functionEnd
   }

   return $scanStartIndex
}

proc packageDeclarationBodyCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Package declarations parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  package_declaration :
#     reserved_word_package
#        identifier
#     reserved_word_is
#        package_declarative_item(s?)
#     reserved_word_end
#        reserved_word_package(?)
#        identifier(?)
#     ';'
#  | <error>
#
#  package_body :
#     reserved_word_package
#        reserved_word_body
#        identifier
#     reserved_word_is
#        package_body_declarative_item(s?)
#     reserved_word_end
#        reserved_word_package_and_body(?)
#        identifier(?)
#     ';'
#  | <error>
#

   set scanStartIndex $end

   set packageName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex packageNameIndex]
   if { $packageName == "" } { return $end }
#   set packageStart [lindex [split $packageNameIndex .] 0]
#   set packageEnd ""

   set type packageHeader
#27.05.2002   set type "package header"

   if { [string equal -nocase $packageName "body"] } {
      set packageName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex packageNameIndex]
      if { $packageName == "" } {
         return $end
      }
      set type packageBody
   }

   if { [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex "is"] == "" } {
      return $end
   }
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

#  putLog "Package $type: \"$packageName\" starting at $packageNameIndex"

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $packageName VHDL]

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

   return $scanStartIndex
}

proc portCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Generic declarations parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  port_declaration_section :
#        reserved_word_port
#        port_interface_list(?) ';'
#      | <error>
#
#  port_interface_list :
#        '('
#           port_interface_list_entry_semicolon_port_interface_list_entry
#        ')'
#      | <error>
#
#  port_interface_list_entry_semicolon_port_interface_list_entry :
#        port_interface_list_entry
#        semicolon_port_interface_list_entry(s?)
#      | <error>
#
#  semicolon_port_interface_list_entry :
#        ';'
#        port_interface_list_entry
#      | <error>
#
#  port_interface_list_entry :
#        port_name_comma_port_name
#        ':'
#        mode
#        subtype_indication
#        default_value(?)
#      | <error>
#
#  port_name_comma_port_name :
#        port_name
#        comma_port_name(s?)
#      | <error>
#
#  comma_port_name :
#        ','
#        port_name
#
#  mode :
#        reserved_word_inout
#      | reserved_word_out
#      | reserved_word_in
#      | reserved_word_buffer
#      | reserved_word_linkage
#
# ...
#
#  port_map_section :
#        reserved_word_port
#        reserved_word_map
#        optional_port_association_list(?)
#      | <error>
#
#  optional_port_association_list :
#        '(' port_association_list ')'
#      | <error>
#
#  port_association_list :
#        association_list
#      | <error>
#


   set parseIndex $end

#   if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: $parseIndex" }

   #  port_map_section :
   #     or
   #  port_declaration_section :

   set mapKeyword [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex mapIndex]

   if { $mapKeyword != "" } {

#     putLog "[namespace tail [namespace current]]::portCmd: port_map_section: $parseIndex"

      # Highlight keyword
      [namespace current]::tagKeyword $caller $w $mapKeyword [$wDirect index "$parseIndex -[string length $mapKeyword] chars"] $parseIndex

#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: port_map_section: $parseIndex" }

      # optional_port_association_list :

      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
      if { $leftBracket == "" } {
         # No bracket. Return $parseIndex to skip "map" keyword
         return $parseIndex
      }
#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: (: $parseIndex" }

      # port_association_list
      set delimiter [[namespace current]::associationList $id $caller $w $wDirect $op $start parseIndex]

      # If ")" is returned - end of association_list is reached
#      switch -- $delimiter {
#         ")"  {
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ) $parseIndex" }
#         }
#         default  {
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: \"$delimiter\" $parseIndex" }
#         }
#      }

   } else {

#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: port_declaration_section: $parseIndex" }

#     port_interface_list
      
      # create ports folder in code browser
      if { $caller == {extract} } {
         foreach { operation compId beforeNode } [[namespace parent]::parserContext $id get] {}
         set portsFolderId [[namespace parent]::parserContext $id register group ports VHDL]

         [namespace parent]::BrowserNode  $id  $operation  $w              \
                              $portsFolderId  $parseIndex  {}              \
                              $compId  $beforeNode  openfold
      }


      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
      if { $leftBracket == "" } {
         # No bracket
         return $end
      }
#      if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ( $parseIndex" }

      while 1 {
#        port_interface_list_entry_semicolon_port_interface_list_entry :

#        port_name_comma_port_name ':'
#         if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: identifier_comma_identifier ':' $parseIndex" }

         while 1 {
            set portName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex portNameIndex]
            if { $portName == "" } {
               return $end
            }
#            if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: portName: $portName $parseIndex" }

            # Highlight declared constant parameter
            if { $caller == "highlight" } {
               $w tag add port $portNameIndex $parseIndex
            } else {
               # Update constant parameter definitions
               [namespace parent]::declarationParserContext $id $w addLocal port $portName $start $parseIndex
               set localPortList($portName) "$portNameIndex $parseIndex"
            }

            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
            switch -- $delimiter {
               ,  {
#                  if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: , $parseIndex" }
                  continue
               }
               :  {
#                  if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: : $parseIndex" }
                  break
               }
               default  {
                  return $end
               }
            }
         }

         set mode [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {inout|out|in|buffer|linkage}]
         if { $mode == "" } {
            # mode not found
            return $end
         }
#         if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: mode: $mode $parseIndex" }
         # Highlight interface mode
         if { $caller == "highlight" } {
            $w tag add mode [$w index "$parseIndex - [string length $mode] chars"] $parseIndex
         } else {
            switch -- [string tolower $mode] {
               in      {  set type portIn      }
               out     {  set type portOut     }
               inout   {  set type portInOut   }
               buffer  {  set type portBuffer  }
               default {  set type portIn      }
            }
            set iconName $HTE::Configuration(LexParser.$lang,icon.$type)
            
            foreach portName [array names localPortList] {
               set portId [[namespace parent]::parserContext $id register $type $portName VHDL]
               
               foreach { startI endI } $localPortList($portName) {}
               
               [namespace parent]::BrowserNode  $id  $operation  $w   \
                              $portId  $startI  $endI                 \
                              $portsFolderId  {}  $iconName
            }
            
            catch { unset localPortList }
         }

         # subtype_indication
         # Skip ...
         set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {:=|;|\)}]

         switch -- $delimiter {
            ":="  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: := $parseIndex" }
            }
            ;  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ; $parseIndex" }
               continue
            }
            ")"  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ) $parseIndex" }
               break
            }
            default  {
               return $end
            }
         }


#         if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: := $parseIndex" }

         # default_value(?)

         set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {;|\)}]
         switch -- $delimiter {
            ;  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ; $parseIndex" }
               continue
            }
            ")"  {
#               if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::portCmd: ) $parseIndex" }
               break
            }
            default  {
               return $end
            }
         }
      }

      if { $caller=="extract" } {
         [namespace parent]::BrowserCompleteNode $id $w $portsFolderId $parseIndex
      }
   }
   
   

   return $parseIndex

}

proc procedureCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Function keyword parser extension. Parses procedure declaration or
# @comment body and calls code browser to update code tree&p
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of parsed keyword
# @argument    end         end position of parsed keyword
#
# @comment   Results:&p
#
# @comment     - funcrion body definition is pushed into stack of opened lexical blocks&p
# @comment     - set appropriate element of array symbols as "procedure"&p
# @comment     - adds procedure definition to array "procedure"&p
# @comment     - node that represents procedure declaration or body is created in the code browser tree&p
#

#
#  subprogram_body :
#     subprogram_specification
#     reserved_word_is
#        subprogram_declarative_part(?)
#     reserved_word_begin
#        sequential_statement(s?)
#     reserved_word_end
#     reserved_word_function_or_procedure(?)
#     identifier_or_operator_symbol(?)
#     ';'
#  | <error>
#
#
#  subprogram_declaration :
#     subprogram_specification
#     ';'
#
#
#  subprogram_specification :
#     procedure_specification | function_specification
#
#  procedure_specification :
#     reserved_word_procedure
#        identifier_or_operator_symbol
#     parameter_interface_list(?)
#
#  identifier_or_operator_symbol :
#     identifier | operator_symbol
#
#
#  parameter_interface_list :
#     '(' interface_list ')'
#

   set scanStartIndex $end

   #
   # Get procedure name
   #
   set procedureName [[namespace current]::getIdentifierOrOperatorSymbol $id $w $wDirect $op scanStartIndex procedureNameIndex]
   if { $procedureName == "" } {
      return $end
   }
#   set procedureStart [lindex [split $procedureNameIndex .] 0]

   #
   # Skip parameter interface list
   #
   [namespace current]::skipParentheses $w $wDirect scanStartIndex

   set type [[namespace current]::getSemicolon $id $w $wDirect $op scanStartIndex foundWordIndex]
   if       { $type == ";" } {

      set type        procedure
#      set procedureEnd $procedureStart
#      set procedureEnd $procedureNameIndex
      set procedureEnd $scanStartIndex

   } else {

      set type [[namespace current]::getAlphaNumericWord $id $w $wDirect $op scanStartIndex foundWordIndex]
      if { [string equal -nocase $type "is"] } {
         set type procedureBody
      } else {
         return $end
      }
      set procedureEnd {}

   }
   set iconName $HTE::Configuration(LexParser.$lang,icon.$type)

#  putLog "$scanStartIndex $type: \"$procedureName\" started at $procedureNameIndex"

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $procedureName VHDL]

   [namespace parent]::BrowserNode              \
                           $id                  \
                           $operation           \
                           $w                   \
                           $blockId             \
                           $start               \
                           $procedureEnd        \
                           $parentId            \
                           $beforeNode          \
                           $iconName


   if { $type == "procedureBody" } {
      [namespace parent]::parserContext $id push $blockId
   }

   return $scanStartIndex
}

proc processStatementCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Process statements parser extension. It is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#
#  process_statement :
#     label_followed_by_colon(?)
#     reserved_word_postponed(?)
#     reserved_word_process
#        sensitivity_list(?)
#     reserved_word_is(?)
#        process_declarative_item(s?)
#     reserved_word_begin
#        sequential_statement(s?)
#     reserved_word_end
#        reserved_word_postponed(?)
#        reserved_word_process
#        process_label(?)
#     ';'
#  | <error>
#

   set scanStartIndex $end

   set processIndex $scanStartIndex
   #
   # Skip sensitivity list
   #
   [namespace current]::skipParentheses $w $wDirect scanStartIndex

#  set type process
#  set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

   return $scanStartIndex

}

proc signalCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Signal declaration parser extension
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  signal_declaration :
#  	   reserved_word_signal
#  		   identifier_comma_identifier
#  	   ':'
#  		   subtype_indication
#  		reserved_word_register_or_bus(?)
#  		default_value(?)
#  	   ';'
#
#  reserved_word_register_or_bus :
#  	   reserved_word_register | reserved_word_bus
#
#  signal_interface :
#  	   reserved_word_signal(?)
#  		   identifier_comma_identifier
#  	   ':'
#  		   mode(?)
#  		subtype_indication
#  	   reserved_word_bus(?)
#  		default_value(?)
#  	   | <error>
#
#

   set parseIndex $end
   
   # get declarations scope
   if { $caller == "extract" } {
      foreach { operation declId beforeNode } [[namespace parent]::parserContext $id get] {}
   
      # get browser icon
      set type signal
      set iconName $HTE::Configuration(LexParser.$lang,icon.$type)
   }

   #  identifier_comma_identifier ':'
#   if { $linearExtDebug } {
#      putLog "[namespace tail [namespace current]]::signalCmd: identifier_comma_identifier ':' $parseIndex"
#   }

   # Workaround for huge signals
   set loop 1
   set signal_end [$wDirect search -elide -regexp {:|;} $start]
   if { $signal_end == "" } { set signal_end end }
   if { [$wDirect index "$start linestart + 50 lines"] < [$wDirect index "$signal_end linestart"]} {
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      set parseIndex [$wDirect search -elide -regexp -backward {\M} $signal_end]
      if { $caller == "highlight" } {
         $w tag add signal $identifierIndex $parseIndex
      }
      set loop 0
   }

   while $loop {

      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      # Highlight declared variable
      if { $caller == "highlight" } {
         $w tag add signal $identifierIndex $parseIndex
      } else {
         # Update symbols definitions
         [namespace parent]::declarationParserContext $id $w addLocal signal $identifier $identifierIndex $parseIndex
         
         # add node to cobe browser
         set signalId [[namespace parent]::parserContext $id register $type $identifier VHDL]

         [namespace parent]::BrowserNode  $id  $operation  $w          \
                              $signalId  $identifierIndex  $parseIndex \
                              $declId  {}  $iconName ;#signal
      }

      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
      switch -- $delimiter {
         ,  {
            continue
         }
         :  {
            break
         }
         default  {
            return $end
         }
      }
   }

   # mode(?)
   set mode [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {inout\W|out\W|in\W|buffer\W|linkage\W}]
   if { $mode != "" } {
      # Strip keyword delimiter
      set mode [string range $mode 0 end-1]
      set keywordEnd   [$wDirect index "$parseIndex -1 char"]
      set keywordStart [$wDirect index "$keywordEnd -[string length $mode] char"]
      # Highlight keyword
      [namespace current]::tagKeyword $caller $w $mode $keywordStart $keywordEnd
   }

   # subtype_indication
   # reserved_word_register_or_bus(?)
   # default_value(?)

   set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {register|bus|;}]
   switch -exact -- [string tolower $delimiter] {
      register -
      bus      {
         # Highlight keyword
         [namespace current]::tagKeyword $caller $w $delimiter [$wDirect index "$parseIndex -[string length $delimiter] chars"] $parseIndex

         set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {;}]
         if { $delimiter == "" } {
            return $end
         }
      }
      ;  {
      }
      default  {
         return $end
      }
   }

   return $parseIndex

}

proc subtypeCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Subtype declaration parser extension
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  subtype_declaration :
#  	reserved_word_subtype
#  		identifier
#  	reserved_word_is
#  		subtype_indication
#  	';'
#

   set parseIndex $end

   set typeName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex typeNameIndex]
   if { $typeName == "" } {
      return $end
   }

   # Highlight type name
   if { $caller == "highlight" } {
      $w tag add typeName $typeNameIndex $parseIndex
   } else {
      # Update type name definitions
#     [namespace parent]::declarationParserContext $id $w addLocal subtype $typeName $typeNameIndex $parseIndex
      [namespace parent]::declarationParserContext $id $w addLocal subtype $typeName $start $parseIndex
   }

   # reserved_word_is
   set is [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {is}]
   if { $is == "" } {
      return $end
   }

   # Highlight keyword
   [namespace current]::tagKeyword $caller $w $is [$wDirect index "$parseIndex -2 char"] $parseIndex

   # subtype_indication

   set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]
   if { $delimiter != ";" } {
      return $end
   }

   return $parseIndex

}

proc typeCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Type declaration parser extension. Declaration is parsed and internal
# @comment parser and/or browser data structures are updated.
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  type_declaration :
#        reserved_word_type
#           identifier
#           is_type_definition(?)
#           ';'
#
#  is_type_definition :
#           reserved_word_is
#           type_definition
#
#  type_definition :
#           enumeration_type_definition
#         | integer_type_definition
#         | floating_type_definition
#         | physical_type_definition
#         | array_type_definition
#         | record_type_definition
#         | access_type_definition
#         | file_type_definition
#
#
#  enumeration_type_definition :
#           '(' id_or_char_comma_id_or_char ')'
#
#     id_or_char_comma_id_or_char :
#              identifier_or_character_literal
#              comma_id_or_char(s?)
#
#     comma_id_or_char :
#              ','
#              identifier_or_character_literal
#
#     identifier_or_character_literal - getIdentifierOrCharacterLiteral
#
#  integer_type_definition :
#           reserved_word_range
#           range_attribute_name_or_simple_expression_to_downto_simple_expression
#
#  floating_type_definition :
#           reserved_word_range
#           range_attribute_name_or_simple_expression_to_downto_simple_expression
#
#  physical_type_definition :
#           reserved_word_range
#           range_attribute_name_or_simple_expression_to_downto_simple_expression
#           reserved_word_units
#           identifier
#           ';'
#           identifier_is_physical_literal(?)
#           reserved_word_end
#           reserved_word_units
#           identifier(?)
#
#
#  array_type_definition :
#           reserved_word_array
#           '(' array_type_mark_definition_or_array_discrete_range_definition ')'
#           reserved_word_of
#           element_subtype_indication
#
#  array_type_mark_definition_or_array_discrete_range_definition :
#  	      type_mark_range_box_comma_type_mark_range_box
#  	    | array_discrete_range_definition
#
#  type_mark_range_box_comma_type_mark_range_box :
#  	      type_mark_range_box
#  	      comma_type_mark_range_box(s?)
#
#  comma_type_mark_range_box :
#  	      ','
#  	      type_mark_range_box
#
#  type_mark_range_box :
#  	      type_mark reserved_word_range box_operator
#
#  box_operator : '<>'
#
#  array_discrete_range_definition :
#  	      discrete_range_comma_discrete_range
#
#  discrete_range_comma_discrete_range :
#  	      discrete_range
#  	      comma_discrete_range(s?)
#
#  comma_discrete_range :
#  	      ','
#  	      discrete_range
#
#
#  element_subtype_indication : subtype_indication
#
#
#  record_type_definition :
#           reserved_word_record
#           record_element_definition(s)
#           reserved_word_end reserved_word_record identifier(?)
#
#  record_element_definition :
#  	      identifier_comma_identifier
#  	         ':'
#  	      subtype_indication - skipSubtypeIndication
#  	      ';'
#
#
#  access_type_definition :
#           reserved_word_access
#           subtype_indication
#
#
#  file_type_definition :
#           reserved_word_file
#           reserved_word_of
#           type_mark
#

   set parseIndex $end

   set typeName [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex typeNameIndex]
   if { $typeName == "" } {
      return $end
   }

   # Highlight type name
   if { $caller == "highlight" } {
      $w tag add typeName $typeNameIndex $parseIndex
   } else {
      # Update type name definitions
#     [namespace parent]::declarationParserContext $id $w addLocal type $typeName $typeNameIndex $parseIndex
      [namespace parent]::declarationParserContext $id $w addLocal type $typeName $start $parseIndex
   }

   # is_type_definition(?)
   set isOrSemicolon [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {is|;}]
   if { $isOrSemicolon == ";" } {
      # No is_type_definition
      return $parseIndex
   }

   # Highlight keyword
   [namespace current]::tagKeyword $caller $w $isOrSemicolon [$wDirect index "$parseIndex -2 chars"] $parseIndex


   # type_definition
   set typeSelector [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(|range|array|record|file|access|;}]

#   if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::typeCmd: typeSelector: $typeSelector" }

   switch -exact -- [string tolower $typeSelector] {

      "("   {

         #  enumeration_type_definition :

         while 1 {

            set literal [[namespace current]::getIdentifierOrCharacterLiteral $id $w $wDirect $op parseIndex literalIndex]
            if { $literal == "" } {
#               if { $linearExtDebug } { putLog "Fail to find identifier or literal: $parseIndex" }
            } elseif { [regexp {^'} $literal] } {
               # Highlight character literal
               if { $caller == "highlight" } {
                  $w tag add eLiteral $literalIndex $parseIndex
               }
            } else {
               # Highlight declared enumeration literal
               if { $caller == "highlight" } {
                  $w tag add eLiteral $literalIndex $parseIndex
               } else {
                  # Update symbols definitions
#                 [namespace parent]::declarationParserContext $id $w addLocal literal $literal $literalIndex $parseIndex
                  [namespace parent]::declarationParserContext $id $w addLocal literal $literal $start $parseIndex
               }

            }

            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|\)}]
            switch -- $delimiter {
               ,  {
                  continue
               }
               ")"  {
                  break
               }
               default  {
                  return $end
               }
            }

         }
      }

      range {
         # NIY
      }

      array {

         # Highlight keyword
         [namespace current]::tagKeyword $caller $w $typeSelector [$wDirect index "$parseIndex -5 chars"] $parseIndex

         set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
         if { $leftBracket == "" } {
            # No bracket
            return $end
         }

         #  array_type_mark_definition_or_array_discrete_range_definition :
         while 1 {

            # Keep parseIndex
            set typeMarkParseIndex $parseIndex

            set typeMark [[namespace current]::getAlphaNumericWord $id $w $wDirect $op typeMarkParseIndex typeMarkIndex]
            set rangeKeyword [[namespace current]::getExactLexeme $id $w $wDirect $op typeMarkParseIndex {range}]

            if { $rangeKeyword != "" } {

               #  type_mark_range_box :

               # Restore parseIndex
               set parseIndex $typeMarkParseIndex

               if { $caller == "highlight" } {
                  # Highlight type name
                  $w tag add typeName $typeMarkIndex [$wDirect index "$typeMarkIndex +[string length $typeMark] chars"]
                  # Highlight keyword
                  [namespace current]::tagKeyword $caller $w $rangeKeyword [$wDirect index "$parseIndex -5 chars"] $parseIndex
               }

               set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|\)}]
               switch -- $delimiter {
                  ,  {
                     continue
                  }
                  ")"  {
                     break
                  }
                  default  {
                     return $end
                  }
               }

            } else {

               # discrete_range

               set delimiter [[namespace current]::discreteRange $id $caller $w $wDirect $op parseIndex {,|\)}]
               switch -- $delimiter {
                  ,  {
                     continue
                  }
                  ")"  {
                     break
                  }
                  default  {
                     return $end
                  }
               }
            }
         }

         # reserved_word_of
         set of [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {of}]
         if { $of != "" } {
            # Highlight keyword
            [namespace current]::tagKeyword $caller $w $of [$wDirect index "$parseIndex -2 char"] $parseIndex

            # element_subtype_indication
            set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]
         }

      }

      record   {

         # Highlight keyword
         [namespace current]::tagKeyword $caller $w $typeSelector [$wDirect index "$parseIndex -6 chars"] $parseIndex

         # record_type_definition :

         while 1 {

            # record_element_definition(s)

               # identifier_comma_identifier ':'

            while 1 {
               set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
               if { $identifier == "" } {
                  return $end
               }

               # Highlight declared record field name
               if { $caller == "highlight" } {
                  $w tag add rfIdentifier $identifierIndex $parseIndex
               } else {
                  # Update symbols definitions
                  [namespace parent]::declarationParserContext $id $w addLocal recordField $identifier $start $parseIndex
               }

               set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
               switch -- $delimiter {
                  ,  {
                     continue
                  }
                  :  {
                     break
                  }
                  default  {
                     return $end
                  }
               }
            }

               # subtype_indication
            set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]

            if { $delimiter != ";" } {
               return $end
            }

            # Keep parseIndex
            set endIndex $parseIndex

            # DR 340411: change end to endKeyword
            set endKeyword [[namespace current]::getExactLexeme $id $w $wDirect $op endIndex {end}]
            if { $endKeyword == "" } {
               continue
            }

            # Highlight keyword
            [namespace current]::tagKeyword $caller $w $endKeyword [$wDirect index "$endIndex -3 char"] $endIndex

            # Restore parse index and finalize record type definition scanning
            set parseIndex $endIndex
            break

         }

         # reserved_word_end reserved_word_record identifier(?)

         # reserved word "end" is already found

            # reserved_word_record
         set record [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {record}]
         if { [expr [string compare -nocase $record "record"] != 0] } {
            return $end
         }

         # Highlight keyword
         [namespace current]::tagKeyword $caller $w $record [$wDirect index "$parseIndex -6 char"] $parseIndex


            # identifier(?)
         set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {;}]
         if { $delimiter == "" } {
            return $end
         }

      }

      file  {
         # NIY
      }

      access   {
         # reserved_word_access

         # Highlight keyword
         [namespace current]::tagKeyword $caller $w $typeSelector [$wDirect index "$parseIndex -6 chars"] $parseIndex

         # subtype_indication
         # Skip ...
         set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]
         if { $delimiter != ";" } {
            return $end
         }
      }

      ";"   {
      }

      default  {
      }
   }

   return $parseIndex

}

proc variableCmd { id lang caller w keyword start end {op mark} } {
set wDirect $w
#
# @comment   Variable declaration parser extension
#
# @argument    id          window identifier
# @argument    caller      caller identifier (V - for VA parser and L - for linear)
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

#   variable linearExtDebug

#
#  variable_declaration :
#  	   reserved_word_variable
#  		   identifier_comma_identifier
#  	   ':'
#  		   subtype_indication
#  		   default_value(?)
#  	   ';'
#
#  variable_interface :
#     	reserved_word_variable(?)
#  		   identifier_comma_identifier
#  	   ':'
#  		   mode(?)
#  		   subtype_indication
#  		   default_value(?)
#  	| <error>
#

   set parseIndex $end

   #  identifier_comma_identifier ':'
#   if { $linearExtDebug } { putLog "[namespace tail [namespace current]]::variableCmd: identifier_comma_identifier ':' $parseIndex" }

   while 1 {

      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      # Highlight declared variable
      if { $caller == "highlight" } {
         $w tag add variable $identifierIndex $parseIndex
      } else {
         # Update symbols definitions
#        [namespace parent]::declarationParserContext $id $w addLocal variable $identifier $identifierIndex $parseIndex
         [namespace parent]::declarationParserContext $id $w addLocal variable $identifier $start $parseIndex
      }

      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|:}]
      switch -- $delimiter {
         ,  {
            continue
         }
         :  {
            break
         }
         default  {
            return $end
         }
      }
   }

   # mode(?)
   set mode [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {inout\W|out\W|in\W|buffer\W|linkage\W}]
   if { $mode != "" } {
      # Strip keyword delimiter
      set mode [string range $mode 0 end-1]
      set keywordEnd   [$wDirect index "$parseIndex -1 char"]
      set keywordStart [$wDirect index "$keywordEnd -[string length $mode] char"]
      # Highlight keyword
      [namespace current]::tagKeyword $caller $w $mode $keywordStart $keywordEnd
   }

   # subtype_indication
   # default_value(?)

   set delimiter [[namespace current]::skipSubtypeIndication $id $caller $w $wDirect $op parseIndex {;}]
   if { $delimiter != ";" } {
      return $end
   }

   return $parseIndex

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

#  [namespace parent]::profile startRange FFT

   if { $externalDebug } {
      set genuineType $type
   }

   if       { $start == 0x7FFFFFFF && $end == 0x80000000 } {
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
   set blockId [[namespace parent]::parserContext $id register $type $name VHDL]

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
#  set endIndex   [$wDirect index "$end.0 + 1 line linestart"]
   set endIndex   $end.end
   set iconName file
   catch {set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)}

#   set decList {constant generic portIn portOut signal type subtype}
   set exceptList {group ogroup portMapGroup genericMapGroup portMap genericMap}
   if { [lsearch -exact $exceptList $type] < 0 } {
################ DR 339054 + CQ 121926
#CB_PER      set sIndex [$wDirect search -elide -regexp "\\m[string map {\\ \\\\} $name]\\M" $startIndex $endIndex]
      set sIndex [$wDirect search -elide  "$name" $startIndex $endIndex]
      if { $sIndex!={} } {
#CB_PER         set eIndex [$wDirect index "$sIndex wordend"]
         set eIndex $sIndex
         [namespace parent]::declarationParserContext $id $wDirect \
            addGlobal $type $name $sIndex $eIndex
      }
################ DR 339054 + CQ 121926
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

#  [namespace parent]::profile stopRange FFT

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

#  [namespace parent]::profile init FFT
   
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

#  putLog "[namespace tail [namespace current]]::checkSyntaxCB: $level \[$start .. $end\]: \"$name\" of \"$type\""

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

   # Check whether symbol at or before $index is simple matching object
   foreach char [list [$w get $index] [$w get "$index -1 char"]] {
      switch -exact -- $char {
         \[ -
         \] -
         \( -
         \) -
         \" -
         \; {
#           putLog "Matching charcter: $char"
            return 1
         }
      }
   }

   set ok 0

   variable matchingObject

   # Try sequentially to match some regular expressions on the current line
   foreach {matchingRE targetRE direction} $matchingObject {
      set matchingIndex [$w search -elide -nocase -regexp $matchingRE "$index linestart" "$index lineend"]
      if { $matchingIndex != {} } {
         set ok 1
#        putLog "Matching re: $matchingIndex: \"$matchingRE\" Target: \"$targetRE\""
         break
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

   set matchingRE {}

   # Set default search type
   set searchType [list backwardChar]

   # Firstly try to find character as "matching object"

   # For characters under $index or before it
   foreach charIndex [list $index "$index -1 char"] {

      set char [$w get $charIndex]
      set beforeIndex [$w index "$charIndex -1 char"]

      switch -exact -- $char {

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
      # End of switch on $char

   }
   # End of foreach

   set afterCharIndex [$w index "$charIndex +1 char"]

   variable matchingObject

   if { $matchingRE == {} } {

      # No chracter as "matching object" is found

      # Try to find some phrase as "matching object"
      foreach {currentRE targetRE direction} $matchingObject {

         # Fetch current line
         set line [$w get "$index linestart" "$index lineend"]
         # Get index of current position
         set indexPosition [lindex [split [$w index $index] .] 1]
         # Sequentially from the line beginning fine nearest matching substring
         set nextPosition 0

         while 1 {

            set targetWordIndices {}
            if { [regexp -nocase -indices -start $nextPosition $currentRE $line matchedIndices targetWordIndices] } {

               set matchedStart [lindex $matchedIndices 0]
#              putLog "LexVHDL::locateMatching: $nextPosition: For $currentRE - $matchedIndices"

               # Starting position of the matched string is higher then
               # $indexPosition and previous match have precedence
               if { [expr $matchedStart >= $indexPosition] && $matchingRE != {} } {
#                 putLog "LexVHDL::locateMatching: break because of previous match have precedence"
                  break
               }

               # Found phrase starting position
               set labelIndex [lindex $targetWordIndices 0]

               if { $targetRE == {} } {
                  # If matching regular expression is not specified we should
                  # find name or label of the phrase
                  set word [string range $line $labelIndex [lindex $targetWordIndices 1]]
                  set wordIndex [$w index "$index linestart +$labelIndex chars"]

                  # Full search regular expression
                  set matchingRE $word
#                  set direction  [lindex $matchingObject($word) 1]
                  set searchType [list ${direction}Word]

               } else {
                  # Otherwise - string that will match regular expression for matching phrase
                  set phraseIndex [$w index "$index linestart +$matchedStart chars"]
                  set sourceRE    $currentRE
                  set matchingRE  $targetRE
                  set searchType  [list ${direction}Phrase]
               }

               # Starting position of the matched string is higher then
               # $indexPosition - finish search
               if { [expr $matchedStart >= $indexPosition] } {
#                 putLog "LexVHDL::locateMatching: break: $matchedStart"
                  break
               }

            } else {

               # $currentRE is not found starting from $nextPosition
               break

            }

            # Search was successful, try further
            set nextPosition [lindex $matchedIndices 1]
         }

         # Check whether there some matches
         if { $matchingRE != {} } {
            # If so - break because of upper expressions should have precedence
            break
         }
      }
   }

   # No phrase that can have matching object was found
   if { $matchingRE == {} } {
      return {}
   }

   set language [namespace tail [namespace current]]

   foreach type $searchType {

      switch -exact -- $type {

         forwardChar {
#           putLog "LexVHDL::locateMatching: Search type $type Char: $char RE: $matchingRE Starting: $afterCharIndex"

            # Find matching chracter forwards starting from the next position after the $char
            set matchingIndex [[namespace parent]::findMatchingCharacter -forward $w $language $afterCharIndex $char $matchingRE]
#           set description "forwards for \"$char\""
         }

         backwardChar {
#           putLog "LexVHDL::locateMatching: Search type $type Char: $char RE: $matchingRE Starting: $charIndex"

            # Find matching chracter backwards starting from the position before the $char
            set matchingIndex [[namespace parent]::findMatchingCharacter -backward $w $language $charIndex $char $matchingRE]
#           set description "backwards for \"$char\""
         }

         statementBeginning   {
#           putLog "LexVHDL::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $charIndex"

            # Find statement beginning backwards starting from the position $charIndex
            set matchingIndex [[namespace parent]::findWord -backward $w $language $charIndex $matchingRE ";" {}]
#           set description "backwards for \";\""
         }

         forwardWord {
            set wordIndex [$w index "$wordIndex +[string length $word] chars"]
#           putLog "LexVHDL::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $wordIndex"

            set matchingIndex [[namespace parent]::findWord -backward $w $language $wordIndex $matchingRE {} {}]
#           set description "forwards for \"$matchingRE\""
         }

         backwardWord {
#           putLog "LexVHDL::locateMatching: Search type $type Word: $word RE: $matchingRE Starting: $wordIndex"

            set matchingIndex [[namespace parent]::findWord -backward $w $language $wordIndex $matchingRE {} {}]
#           set description "backwards for \"$matchingRE\""
         }

         backwardPhrase {
#           putLog "LexVHDL::locateMatching: Search type $type RE: $matchingRE Source: $sourceRE Starting: $phraseIndex"

            set matchingIndex [[namespace parent]::findMatchingPhrase -backward $w $language $phraseIndex $matchingRE $sourceRE]
#           set description "backwards for \"$matchingRE\""
         }

         default  {
            error "LexVHDL::locateMatching: invalid search type \"$type\""
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

   set smartIndentValue $HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndentValue)
   set tabsToSpaces $HTE::Configuration(LexParser.[namespace tail [namespace current]],tabsToSpaces)
   set endOfLine [expr [$w index "$index lineend"] == [$w index $index]]

   if { $special } {
      if { [regexp {^(\s*--\s*)} $line match initialSpaces] != "0" } {
         return $initialSpaces
      }
   } else {

      set indentationREList {
                              {^(\s*)begin}
                              {^(\s*)case.*is$}
                              {^(\s*)component}
                              {^(\s*)configuration}
                              {^(\s*)elsif.*then}
                              {^(\s*)else}
                              {^(\s*)entity.*is$}
                              {^(\s*)(\w+\s*:\s*)?for}
                              {^(\s*)generic.*\($}
                              {^(\s*)if.*then}
                              {^(\s*)package}
                              {^(\s*)port.*\($}
                              {^(\s*)process}
                              {^(\s*)type.*record\s*}
                              {^(\s*)when}
                              {^(\s*)while.*loop}
                            }
#                              {^(\s*)architecture.*is$}
#                              {^(\s*)library}

      foreach indentationRE $indentationREList {
         if { [regexp -nocase $indentationRE $line match initialSpaces] != "0" } {
            if { $tabsToSpaces } {
               set new [string repeat " " $smartIndentValue]
            } else {
               set new "\t"
            }
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

   switch -exact -- [string tolower $word] {

      else  -
      elsif -
      end   -
      when {
         return 1
      }
   }

   return 0
}

