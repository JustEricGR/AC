#HTEParser#systemverilog#LexSystemVerilog#SystemVerilog files#SystemVerilog Plugin#v|vlog#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2004,2005 All Rights Reserved
#
#
# @comment SystemVerilog plug-in for HTE lexical parser
#
# =============================================================================

# ======================================================================
# LexSystemVerilog namespace - SystemVerilog related lexical parser part
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
   # Schedule initialization
   #

 #
   # Schedule initialization
   #
   #HTE::registerInitScript [namespace current]::init
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
   # Tags definition used by plugin
   # Each element of PluginTags array should contain list of following items:
   #
   #     Tag description string used in configuration dialogs
   #     tag configuration string suitable for "$w taf configure string"
   #     tag option string that can contain:
   #        - "r" - tag should be removed by visual area parser
   #        - "s" - tag can have secondary tags
   #
   # Template for element of PluginTags array is defined by PluginTagsTEMPLATE
   #
#   set PluginTagsTEMPLATE  {"TEMPLATE"                ""                         "r"}
#   set PluginTagsList {
#      keyWord              {"Keyword"                       "-foreground #c00000"  "s"}
#      sysTask              {"System task"                   "-foreground #759cff"  ""}
#      compilerDirective    {"Compiler Directive"            "-foreground #008080"  ""}
#      macroName            {"Macro substitution"            "-foreground #000080"  ""}
#      net                  {"Net declaration"               "-foreground #800080"  ""}
#      reg                  {"Register declaration"          "-foreground #800080"  ""}
#      parameter            {"Parameter declaration"         "-foreground #800080"  ""}
#      port                 {"Port declaration"              "-foreground #800080"  ""}
#      gate                 {"Gate instance name"            "-foreground #ff0000"  ""}
#      moduleName           {"Module name"                   "-foreground #0080c0"  ""}
#      moduleInstanceName   {"Module instance name"          "-foreground #000080"  ""}
#      functionName         {"Function name"                 "-foreground #0080c0"  ""}
#      taskName             {"Task name"                     "-foreground #0080c0"  ""}
#      string               {"String"                        "-foreground #0080c0"  ""}
#      quote                {"Quote"                         "-font {-weight bold}" ""}
#      concatenation        {"Concatenation"                 "-background #ffff91"  ""}
#      brace                {"Brace"                         "-font {-weight bold}" ""}
#      range                {"Range"                         "-background #ffff91"  ""}
#      squareBracket        {"Square bracket"                "-font {-weight bold}" ""}
#      parentheses          {"Parentheses"                   "-background #ffff91"  ""}
#      roundBracket         {"Round bracket"                 "-font {-weight bold}" ""}
#      statement            {"Statement"                     "-background #ffff91"  ""}
#      comment              {"Comment"                       "-foreground #008000"  "r"}
#   }
#   array set PluginTags $PluginTagsList

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
      always_comb                {"Always_Comb"                VerilogAlwaysC}
      always_ff                  {"Always_FF"                  VerilogAlwaysFF}
      always_latch               {"Always_Latch"               VerilogAlwaysL}
      final                      {"Final"                      VerilogAlways}
      specify                    {"Specify"                    VerilogAlways}
      clocking                   {"Clocking"                   VerilogClockingBlock}
      comment                    {"Comment"                    {}}
      function                   {"Function"                   VerilogFunction}
      gateInstance               {"Gate Instance"              ExtPackageBodyView}
      generate                   {"Generate Statement"         VhdlGenerate}
      genvar                     {"Generate Variable"          VerilogGenvar}
      group                      {"Group"                      openfold}
      initial                    {"Initial"                    VerilogInitial}
      instance                   {"Instance"                   Instance}
      instanceExternal           {"External Instance"          VerilogForeignView}
      interface                  {"Interface"                  VerilogInterface}
      localparam                 {"Local Parameter"            VerilogLocalParameterDecl}
      specparam                  {"Spec Parameter"             VerilogLocalParameterDecl}
      exportImport               {"ExportImport"               VerilogModule}
      pkgimport                  {"PackageImport"              VerilogModule}
      include                    {"Include"                    VerilogModule}
      module                     {"Module"                     VerilogModule}
      program                    {"Program"                    VerilogModule}
      package                    {"Package"                    VhdlPkgBody}
      ogroup                     {"Group"                      openfold}
      parameter                  {"Parameter"                  VerilogParameterDecl}
      parameterMap               {"Parameter Map"              VerilogParameterMapping}
      portInOut                  {"InOut Port"                 PortIO}
      portIn                     {"Input Port"                 PortIn}
      portMap                    {"Port Map"                   PortMapping}
      portOut                    {"Output Port"                PortOut}
	  interfacePort              {"Interface Port"             PortInterface}
      modport                    {"ModPort"                    PortMapping}
      signal                     {"Wire"                       signal}
      struct                     {"Struct"                     VerilogStruct}
      rand                       {"Rand"                       signal}
      property                   {"Property"                   Sva_Property}
      assert                     {"Assert"                     SvaAssertion}
      cross                      {"Cross"                      SvaAssertion}
      coveragecross              {"CoverageCross"              SvaCoverDirective}
      coveragepoint              {"CoveragePoint"              SvaCoverDirective}
      coveragebin                {"CoverageBin"                SvaCoverDirective}
      sequence                   {"Sequence"                   SvaSequence}
      covergroup                 {"Covergroup"                 SvaCoverGroup}
      assertprop                 {"AssertProperty"             SvaAssertion}
      coverprop                  {"CoverProperty"              SvaCoverDirective}
      expectprop                 {"ExpectProperty"             SvaAssertion}
      assumeprop                 {"AssumeProperty"             SvaAssertion}
      covergroupobject           {"CoverGroupObject"           SvaCoverGroup}
      class                      {"Class"                      VerilogClass}
      classobject                {"ClassObject"                signal}
      task                       {"Task"                       VerilogTask}
      union                      {"Union"                      VerilogUnion}
      type                       {"Type"                       VhdlType}
      const                      {"Const"                      VerilogLocalParameterDecl}
   }

   # By default, set all block types to be visible
   if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
   } else {
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
         {always function gateInstance generate genvar initial instance interface instanceExternal \
          localparam module package parameter parameterMap portInOut portIn portMap portOut signal \
          interfacePort modport struct task union type specify specparam program clocking \
          const property assert cross covergroup class rand classobject always_comb always_ff \
		  always_latch final seqblk parblk covergroupobject sequence assertprop \
		  exportImport pkgimport include coverprop expectprop assumeprop coveragecross \
		  coveragepoint coveragebin}
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
   }


   array set matchingObject {
      end                        { {\m(end|begin)\M}              {backward} }
      join                       { {\m(join|fork)\M}              {backward} }
      join_any                   { {\m(join_any|fork)\M}          {backward} }
      join_none                  { {\m(join_none|fork)\M}         {backward} }
      endcase                    { {\m(endcase|case)\M}           {backward} }
      endfunction                { {\m(endfunction|function)\M}   {backward} }
      endmodule                  { {\m(endmodule|module)\M}       {backward} }
      endpackage                 { {\m(endpackage|package)\M}     {backward} }
      endprimitive               { {\m(endprimitive|primitive)\M} {backward} }
      endtable                   { {\m(endtable|table)\M}         {backward} }
      endtask                    { {\m(endtask|task)\M}           {backward} }
      endconfig                  { {\m(endconfig|config)\M}       {backward} }
      endgenerate                { {\m(endgenerate|generate)\M}   {backward} }
      endclocking                { {\m(endclocking|clocking)\M}   {backward} }
      endspecify                 { {\m(endspecify|specify)\M}     {backward} }
      endinterface               { {\m(endinterface|interface)\M} {backward} }
      endprogram                 { {\m(endprogram|program)\M}     {backward} }
      endclass                   { {\m(endclass|class)\M}         {backward} }
      endgroup                   { {\m(endgroup|covergroup)\M}    {backward} }
      endproperty                { {\m(endproperty |property)\M}  {backward} }
      endsequence                { {\m(endsequence |sequence)\M}  {backward} }
      begin                      { {\m(begin|end)\M}              {forward}  }
      fork                       { {\m(fork|join)\M}              {forward}  }
      fork                       { {\m(fork|join_any)\M}          {forward}  }
      fork                       { {\m(fork|join_none)\M}         {forward}  }
      case                       { {\m(case|endcase)\M}           {forward}  }
      function                   { {\m(function|endfunction)\M}   {forward}  }
      package                    { {\m(package|endpackage)\M}     {forward}  }
      module                     { {\m(module|endmodule)\M}       {forward}  }
      primitive                  { {\m(primitive|endprimitive)\M} {forward}  }
      table                      { {\m(table|endtable)\M}         {forward}  }
      task                       { {\m(task|endtask)\M}           {forward}  }
      config                     { {\m(config|endconfig)\M}       {forward}  }
      generate                   { {\m(generate|endgenerate)\M}   {forward}  }
      clocking                   { {\m(clocking|endclocking)\M}   {forward}  }
      specify                    { {\m(specify|endspecify)\M}     {forward}  }
      class                      { {\m(endclass |class)\M}        {forward}  }
      covergroup                 { {\m(endgroup |covergroup)\M}   {forward}  }
      property                   { {\m(endproperty |property)\M}  {forward}  }
      interface                  { {\m(interface|endinterface)\M} {forward}  }
      program                    { {\m(program|endprogram)\M}     {forward}  }
      sequence                   { {\m(sequence|endsequence)\M}   {forward}  }
   }
          
   #
   # SystemVerilog parser subsection of configuration values
   # Set - only when they are not already loaded
   #
      #
      # SystemVerilog parser subsection
      #
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Structural)              Yes
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)              Yes
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)                  Yes

      set sizeForFullParsingDefault 40
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFullParsing)  $sizeForFullParsingDefault
      set sizeForFastParsingDefault 200
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],sizeForFastParsing)  $sizeForFastParsingDefault

#
      # Print settings
      #
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.header) "%(p)|%(month_long) %(dd), %(year)|Page %(page)"
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.header_separator) "|"
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.linenum) 0
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.nupnum) 1
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.footer) "Page %(page)"
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.color) 0
#      if {$tcl_platform(platform) == "windows"} {
#         set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.header) "%(p)"
#         set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.footer) "Page %(page)|User %(user)|%(month_long) %(dd), %(year)"
#         set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.header_font) "{Arial} 8"
#         set HTE::Configuration(LexParser.[namespace tail [namespace current]],print.footer_font) "{Arial} 8"
#      }
#      #
#      # Tab Stops
#      #
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],tabWidth) 3
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],tabsToSpaces) 1
#      #
#      # Indentation options
#      #
#      #     Pattern indentation
#      #
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],patternIndent)    Yes
#      set patternIndentREList { { {(Never matched)} {\1  } } }
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],patternIndentREList) $patternIndentREList
#      #
#      #     Smart indentation
#      #
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndent)           Yes
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndentValue)      3
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],smartIndentBackspace)  Yes
#
#      #
#      # Syntax phrase detection
#      #
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],inMotionPhraseDetectionHighlightKeyword)    Yes
#      set HTE::Configuration(LexParser.[namespace tail [namespace current]],inMotionPhraseDetectionHighlightMatched)    Yes


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

  # store defaults before loading user settings #DR 332477
   array set HTE::defConfig [array get HTE::Configuration LexParser.LexSystemVerilog,*]

   #
   # Load user defined values
   #
   #HTE::loadConfigSection LexParser.LexSystemVerilog


   variable identifierRE       {[[:alpha:]][\w\.]*}
   variable moduleInstanceRE   "($identifierRE)\\s*\[#\\s*\(.*\)\]?\\s+$identifierRE"
   set HighlightRE(operator) {[-+:%~\[\]*&<>=!|^/]}
   set HighlightRE(digit) {(?:\W|\A)(\d+)(\W|$)}
   set HighlightRE(moduleName) $moduleInstanceRE
   set hlCallbacks(moduleName) [namespace current]::instanceCmd
   
   variable dataTypes
   set dataTypes(old,integral) { integer time reg }
   set dataTypes(new,integral) { int shortint longint bit byte logic }
   set dataTypes(old,real)     { real realtime }
   set dataTypes(new,real)     { shortreal longreal }
   set dataTypes(old,other)    { wire wand wor trireg tri0 tri1 tri triand trior sypply0 supply1 }
   set dataTypes(new,other)    { chandle string void struct union enum udt char }
   set dataTypes(old,all)      "$dataTypes(old,integral) $dataTypes(old,real)"
   set dataTypes(new,all)      "$dataTypes(new,integral) $dataTypes(new,real)"
   set dataTypes(all,integral) "$dataTypes(old,integral) $dataTypes(new,integral)"
   set dataTypes(all,real)     "$dataTypes(old,real)     $dataTypes(new,real)"
   set dataTypes(all,other)    "$dataTypes(old,other)    $dataTypes(new,other)"
   set dataTypes(all,all)      "$dataTypes(old,all)      $dataTypes(new,all)"
   set dataTypes(all,signing)  "$dataTypes(all,all) signed unsigned" 
   set dataTypes(all,wires)    "$dataTypes(old,all) $dataTypes(old,other) $dataTypes(new,all)"
   set dataTypes(all,entire)   "$dataTypes(all,all) $dataTypes(all,other) signed unsigned"
   
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

proc addChildNode { id w type name start end addFolder} {
#
# @comment Adds a child node to the code browser, a child node may 
# @comment not have children.
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    type        type of the child node
# @argument    name        name of the child node
# @argument    start       start position of the construct
# @argument    end         end position of the construct
# @argument    addFolder   Flag to identify whether a folder should
# @argument                to group the nodes of type "type"
# 
# @result Returns the Id of the created node
#
   variable parent   

   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
   
   set node [::HTE::Browser::nameOfNode $id getName $parentId]
   
   if {($addFolder == 1) && ($parentId != "root")} {  
      if [info exists parent($id,$parentId,${type}Folder)] {
         set parentId $parent($id,$parentId,${type}Folder)
      } else {
         set groupName ${type}s
         set blockId [[namespace parent]::parserContext $id register $type $groupName PSL]
         [namespace parent]::BrowserNode              \
                                 $id                  \
                                 $operation           \
                                 $w                   \
                                 $blockId             \
                                 $start-1chars        \
                                 ""                   \
                                 $parentId            \
                                 $beforeNode          \
                                 openfold
         set parent($id,$parentId,${type}Folder) $blockId
         set parentId $blockId
      }
      [namespace parent]::BrowserCompleteNode   \
                              $id               \
                              $w                \
                              $parentId         \
                              $end

   }
   
   set parentIdList $parentId
      
   foreach parentId $parentIdList {
      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $name PSL]

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

     [namespace parent]::BrowserCompleteNode       \
                             $id                   \
                             $w                    \
                             $blockId              \
                             $end
   }
   
   return $blockId
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
   if {[lsearch [::HTE::LexParser::getKeywords [namespace tail [namespace current]]] $lexeme] == -1} {
      highlightMoreKeyword $w $lexeme $lexemeStart $lexemeEnd
      return
   }
   
   # Tag keyword
   $w tag add keyWord $lexemeStart $lexemeEnd

   # And get in tagName name of tag that should be used for $lexeme
   set tagName [[namespace parent]::parserKeywordTag [namespace tail [namespace current]] keyWord $lexeme]
   if { $tagName != "" } {
      $w tag add $tagName $lexemeStart $lexemeEnd
   }

}

proc highlightMoreKeyword { w lexeme lexemeStart lexemeEnd } {
#
# @comment   Highlights lexeme found as moreKeyword.&p
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

   # Tag moreKeyword
   $w tag add moreKeyword $lexemeStart $lexemeEnd
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

   while 1 {

      set lexemeIndex [$wDirect search -elide -regexp {\S} $scanStartIndex end]
      if { $lexemeIndex == "" } {
         return ""
      }
      set scanStartIndex $lexemeIndex

      # Get rest of line
      set line [$wDirect get $scanStartIndex "$scanStartIndex lineend"]

      # Get in lexeme first looked for lexeme or comment beginning
      set lexeme [lindex [regexp -inline $searchOrCommentRE $line] 0]
      if { $lexeme == "" } {
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
      set scanStartIndex [$wDirect index "$scanStartIndex + [string length $lexeme] chars"]
      break
   }

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

   while 1 {

      # Search requested lexeme or comment
      set lexemeIndex [$wDirect search -elide -regexp -count [namespace current]::lexemeCount $searchOrCommentRE $scanIndex end]
      if { $lexemeIndex == "" } {
         return ""
      }

      # Get what was found
      set lexeme [$wDirect get $lexemeIndex "$lexemeIndex + $lexemeCount chars"]
      set scanIndex $lexemeIndex

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
      set scanIndex [$wDirect index "$scanIndex + $lexemeCount chars"]
      break
   }

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
#     The SystemVerilog language supports the concept of hierarchical names,
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
      set foundIndex $scanIndex
      set scanIndex [$wDirect index "$scanIndex + [string length $word] chars"]

      return $word
   }

   # Get escaped identifier into $word if it is possible
   if { $extendedIdentifiers } {
      if { [regexp $escapedIdentifierRE $line word] } {
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
      set scanIndex $parseIndex
      return 1
   }

   incr brackets

   while 1 {

      # Find bracket or possible keyword
      set wordOrBracket [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\(|\)|\w+}]
      if { $wordOrBracket == "" } {
         # No brackets and no words. scanIndexVar will not be modified
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

      if { $op == "tag" } {
         if { [info exists keyWords($wordOrBracket)] } {
            # Highlight word if it seems keyword
            set lexemeStart [$w index "$parseIndex -[string length $wordOrBracket] chars"]
            highlightKeyword $w $wordOrBracket $lexemeStart $parseIndex
         }
      }
   }

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

proc skipPossibleMultiDimension { id w wDirect op scanIndexVar } {
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex
   set tempScanIndex $scanIndex
   set found 0
   
   while {1} {
      # Find left square bracket
      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\[}]
      if { $leftBracket == "" } {
         # No left square bracket. scanIndexVar will not be modified
         break;
      }
   
      # Find right bracket
      set rightBracket [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\]}]
      if { $rightBracket == "" } {
         # No brackets. scanIndexVar will not be modified
         break;
      } else {
         set found 1
      }
   }

   if {$found} {
      set scanIndex $parseIndex
      return 1
   } else {
      set scanIndex $tempScanIndex
   }
}

proc skipPossibleBraces { id w wDirect op scanIndexVar } {
   upvar $scanIndexVar scanIndex

   set parseIndex $scanIndex
   set tempScanIndex $scanIndex
   set found 0
   
   while {1} {
      # Find left square bracket
      set leftBracket [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\{}]
      if { $leftBracket == "" } {
         # No left square bracket. scanIndexVar will not be modified
         break;
      }
   
      # Find right bracket
      set rightBracket [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {\}}]
      if { $rightBracket == "" } {
         # No brackets. scanIndexVar will not be modified
         break;
      } else {
         set found 1
      }
   }

   if {$found} {
      set scanIndex $parseIndex
      return 1
   } else {
      set scanIndex $tempScanIndex
   }
}

proc skipPossibleInitialization { id w wDirect op scanIndexVar } {
   upvar $scanIndexVar scanIndex
   
   set parseIndex $scanIndex
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(|\{|\"|,|;}]
   switch -- $delimiter {
      \( -
      \{ -
      \" {
         switch -- $delimiter {
            \( {
               set sym \)
            }
            \{ {
               set sym \}
            }
            \" {
               set sym \"
            }
         }      
         set parseIndex [findClosingSymbol $delimiter $sym $w $parseIndex]
         if {($parseIndex == -1) || ($parseIndex <= $scanIndex)} {
            return 0
         } else {
            set scanIndex [$w index $parseIndex+1c]
            return 1
         }
      }
      , - \; {
         return 0;
      }
      default {
         while 1 {
            set value [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\w+|.}]
            switch -- $value {
               , - ; {
                  set parseIndex [$w index $parseIndex-1c]
                  break
               }
               "" {
                  return 0
               }
               default {
                  continue
               }
            }
         }
         set scanIndex $parseIndex
         return 1
      }
   }
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

   set scanIndex [$w index $scanIndex]
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
         set blockId [[namespace parent]::parserContext $id register $type $gateInstance SystemVerilog]

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
   variable dataTypes

# SystemVerilog Syntax:
#    function_data_type ::= data_type | void
#    function_data_type_or_implicit ::=
#        function_data_type
#           | [ signing ] { packed_dimension }
#    function_declaration ::= function [ lifetime ] function_body_declaration
#    function_body_declaration ::=
#        function_data_type_or_implicit
#              [ interface_identifier . | class_scope ] function_identifier ;
#           { tf_item_declaration }
#           { function_statement_or_null }
#        endfunction [ : function_identifier ]
#      | function_data_type_or_implicit
#              [ interface_identifier . | class_scope ] function_identifier ( [ tf_port_list ] ) ;
#           { block_item_declaration }
#           { function_statement_or_null }
#        endfunction [ : function_identifier ]
#    lifetime ::= static | automatic
#    signing ::= signed | unsigned

   set scanStartIndex $end

   # automatic or static
   set lifetimeStart $scanStartIndex
   set lifetime [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {automatic|static}]
   if { ($lifetime!={}) && ($caller=={highlight}) } {
      highlightKeyword $w $lifetime $lifetimeStart $scanStartIndex 
   }
   # signed or unsigned:
   set signingStart $scanStartIndex
   set signing [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {signed|unsigned}]
   if { ($signing!={}) && ($caller=={highlight}) } {
      highlightKeyword $w $signing $signingStart $scanStartIndex 
   }

   # Skip possible range
   [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex

   # Get function_identifier or type
   set functionName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex functionNameIndex mark]
   if { $functionName == "" } { 
      return $end 
   } 
   if {[lsearch $dataTypes(all,all) $functionName] != -1} {
      # Highlight Verilog2001 keyword
      if { $caller == "highlight" } {
         highlightKeyword $w $functionName $functionNameIndex $scanStartIndex
      }
      
      # Array?
      [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex 

      # Get function name
      set functionName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex functionNameIndex mark]
      if { $functionName == "" } { return $end }

   }

   # Highlight function name
   if { $caller == "highlight" } {
      $w tag add functionName $functionNameIndex $scanStartIndex
   }     
   # function port list
   set openParen [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {\(}]
   if { $openParen=={(} } {
      while 1 {
         set dirStart $scanStartIndex
         set portDir [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {input|output|inout|ref}]
         if { $portDir!={} && $caller=={highlight} } {
            highlightKeyword $w $portDir $dirStart $scanStartIndex
         }

         set typeStart $scanStartIndex
         set portType [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex [join $dataTypes(all,entire) |]]
         if { $portType!={} } {
            if { $caller=={highlight} } { highlightKeyword $w $portType $typeStart $scanStartIndex }
            if { $portType=={unsigned} || $portType=={signed} } {
               set typeStart $scanStartIndex
               set anotherType [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex [join $dataTypes(all,entire) |]]
               if { $anotherType!={} && $caller=={highlight} } {
                  highlightKeyword $w $anotherType $typeStart $scanStartIndex
               }
            }
            # Skip an enum, struct or union body:
            [namespace current]::skipPossibleBraces $id $w $wDirect $op scanStartIndex
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         # get port identifiers
         set portName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex portNameIndex $op]
         if { $portName!={} && $caller=={highlight} } { $w tag add port $portNameIndex $scanStartIndex }
         # Array?
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         while 1 {
            set comma [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {,}]
            if { $comma!={,} } break
            set tempStartIndex $scanStartIndex
            set portName [[namespace current]::getIdentifier $id $w $wDirect tempStartIndex portNameIndex $op]
            if { [lsearch {input output inout ref} $portName] != -1 } {
               break
            }
            set scanStartIndex $tempStartIndex
            if { $portName!={} && $caller=={highlight} } { $w tag add port $portNameIndex $scanStartIndex }
            # Array?
            [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         }
         
         # initializing variables before entering the while loop
         set tempIndex $scanStartIndex
         set breakFlag false
       
          while 1 {
             set closeParen [[namespace current]::getLexeme $id $w $wDirect $op scanStartIndex {[\);]}]
             if { $closeParen == {)} } {
                set breakFlag true
                break
             } elseif { $closeParen == {;} } {
                set scanStartIndex $tempIndex
                set breakFlag true
                break
             } elseif {$closeParen == ""} {
                set dummyIndex $scanStartIndex
                set scanStartIndex [$w index "$scanStartIndex + 1 lines linestart"] 
                if [$w compare $scanStartIndex <= $dummyIndex] {
                   set breakFlag true
                   break
                }
             }
          }
          if {$breakFlag} break     
      }
   }

   # Get semicolon
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {;}]

   if { $delimiter == "" } {
      # No valid delimiter
      return $end
   }

   if { $caller == "extract" } {

      set type "function"
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $functionName SystemVerilog]

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
      [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex

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
         set blockId [[namespace parent]::parserContext $id register $type $instanceName SystemVerilog]

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
   variable dataTypes

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
   set scanStartIndex $end
   set wDirect        $w
   
   set moduleName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex moduleNameIndex $op]
   if { $moduleName == "" } { return $end }

   # Highlight module name
   if { $caller == "highlight" } {
      $w tag add moduleName $moduleNameIndex $scanStartIndex
   }

   set type "module"
   set moduleStart $moduleNameIndex
   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)


   # find parameter list
   set hash [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {#\s*\(}]
   if { $hash!={} } {
      set closeIndex "$scanStartIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex
      while { [$w compare $scanStartIndex < $closeIndex] } {
         # get parameter keyword
         set keyStart $scanStartIndex
         set paramKeyword [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {parameter}]
         if { $paramKeyword!={} && $caller=={highlight} } {
            highlightKeyword $w $paramKeyword $keyStart $scanStartIndex
         }

         # Get type
         set typeStart $scanStartIndex
         set paramType [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex \
               [join $dataTypes(all,all)]]
         if { $paramType!={} && $caller=={highlight} } {
            highlightKeyword $w $paramType $typeStart $scanStartIndex
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex

         #  parameter_assignment_comma_parameter_assignment

         while 1 {
            set tempIndex $scanStartIndex
            set parameterIdentifier [[namespace current]::getIdentifier \
                  $id $w $wDirect tempIndex parameterIdentifierIndex $op]
            if { $parameterIdentifier=={parameter} } break
            set scanStartIndex $tempIndex
            # Highlight declared identifier
            if { $parameterIdentifier!={} && $caller=={highlight} } {
               $w tag add variable $parameterIdentifierIndex $scanStartIndex
            }

            set delimiter [[namespace current]::getLexeme $id $w $wDirect $op scanStartIndex {,|\)}]
            switch -exact -- [string index $delimiter 0] {
               ,  {
                  continue
               }
               )  {
                  # End of parameter declaration
                  break
               }
               default {
                  # No valid delimiter
                  return $end
               }
            }
         }
      }
   }

   # module port list
   set openParen [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {\(}]
   if { $openParen=={(} } {
      set closeIndex "$scanStartIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex

      set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {/}]
      if { $openComment=={/} } {
         [namespace current]::parseComment $id $w $wDirect "$scanStartIndex-1c" scanStartIndex {}
      }

      while { [$w compare $scanStartIndex < $closeIndex] } {
         set dirStart $scanStartIndex
         set portDir [[namespace current]::getExactLexeme \
               $id $w $wDirect $op scanStartIndex {input|output|inout}]
         if { $portDir!={} && $caller=={highlight} } {
            highlightKeyword $w $portDir $dirStart $scanStartIndex
         }

         set typeStart $scanStartIndex
         set portType [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex \
               [join $dataTypes(all,wires) |]]
         if { $portType!={} && $caller=={highlight} } {
            highlightKeyword $w $portType $typeStart $scanStartIndex
         }

         set signingStart $scanStartIndex
         set signing [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {signed|unsigned}]
         if { $signing!={} && $caller=={highlight} } {
            highlightKeyword $w $signing $signingStart $scanStartIndex
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         
         set firstPort 1
         while 1 {
            update
            if {$firstPort} {
               # get port identifiers
               set portName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex portNameIndex $op]
               if { $portName!={} && $caller=={highlight} } {
                  $w tag add port $portNameIndex $scanStartIndex
               }
               set firstPort 0
            }
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {,|=|\)}]
            switch -exact -- $delimiter {
               , {
                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$scanStartIndex-1c" scanStartIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {`}]
                  if { $openDirective=={`} } {
                     set scanStartIndex [$w index "$scanStartIndex lineend +1c"]
                  }

                  set tempStartIndex $scanStartIndex
                  set portName [[namespace current]::getIdentifier \
                        $id $w $wDirect tempStartIndex portNameIndex $op]
                  if { [lsearch -exact {input output inout} $portName]>-1 } break
                  set scanStartIndex $tempStartIndex
                  if { $portName!={} && $caller=={highlight} } {
                     $w tag add port $portNameIndex $scanStartIndex
                  }

                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$scanStartIndex-1c" scanStartIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {`}]
                  if { $openDirective=={`} } {
                     set scanStartIndex [$w index "$scanStartIndex lineend +1c"]
                  }
               }
               = {
                  [namespace current]::getLexeme $id $w $wDirect $op scanStartIndex {,|\)}
                  set scanStartIndex "$scanStartIndex-1c"
                  continue
               }
               ) break
               default {
                  return $end
               }
            }
         }
      }
   }

   if { $caller == "extract" } {

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $moduleName SystemVerilog]

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
      set portsFolderId [[namespace parent]::parserContext $id register ogroup ports SystemVerilog]
      [namespace parent]::BrowserNode  $id  $operation  $w     \
                              $portsFolderId  {}  {}           \
                              $blockId  {}  openfold
      set declFolderID($id,$blockId,ports) $portsFolderId

      set wiresFolderId [[namespace parent]::parserContext $id register ogroup wires SystemVerilog]
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
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.signal)

      # get parent module
      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
      set wiresFolderId $declFolderID($id,$parentId,wires)
   }

#  net_type_vectored_scalared_range_delay3_list_of_net_identifiers :
#  net_type_drive_strength_vectored_scalared_signed_range_delay3_list_of_net_decl :
   while 1 {
      # Find and skip drive_strength
      if { [[namespace current]::skipPossibleStrength $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find vectored_or_scalared
      set startIndex $parseIndex
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {vectored|scalared}]
      if { $lexeme!={} } {
         # Found - parseIndex contains next scan position
         if { $caller=={highlight} } { highlightKeyword $w $lexeme $startIndex $parseIndex }
         continue
      }

      # Find signed
      set startIndex $parseIndex
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed}]
      if { $lexeme!={} } {
         # Found - parseIndex contains next scan position
         if { $caller=={highlight} } { highlightKeyword $w $lexeme $startIndex $parseIndex }
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
            set wireId [[namespace parent]::parserContext $id register signal $netIdentifier SystemVerilog]
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

   # Get caller name
   ##set caller [namespace tail [lindex [info level -1] 0]]

#  trireg_charge_strength_vectored_scalared_signed_range_delay3_list_of_net :
   while 1 {
      # Find and skip drive_strength
      if { [[namespace current]::skipPossibleStrength $id $w $wDirect $op parseIndex] } {
         # Found - parseIndex contains next scan position
         continue
      }

      # Find charge_strength
      set startIndex $parseIndex
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
            {\(\s*(small|medium|large)\s*\)}]
      if { $lexeme!={} } {
         set startIndex [$w search -elide -exact {(} $startIndex $parseIndex]
         # Found - parseIndex contains next scan position
         if { $caller=={highlight} } { highlightKeyword $w $lexeme "$startIndex+1c" "$parseIndex-1c" }
         continue
      }

      # Find vectored_or_scalared
      set startIndex $parseIndex
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {vectored|scalared}]
      if { $lexeme!={} } {
         # Found - parseIndex contains next scan position
         if { $caller=={highlight} } { highlightKeyword $w $lexeme $startIndex $parseIndex }
         continue
      }

      # Find signed
      set startIndex $parseIndex
      set lexeme [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed}]
      if { $lexeme!={} } {
         # Found - parseIndex contains next scan position
         if { $caller=={highlight} } { highlightKeyword $w $lexeme $startIndex $parseIndex }
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
   while 1 {
      set netIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex netIdentifierIndex $op]
      if { $netIdentifier == "" } {
         return $end
      }

      # Highlight declared net
      if { $caller == "highlight" } {
         $w tag add net $netIdentifierIndex $parseIndex
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

   # Get type
   set typeStart $parseIndex
   set paramType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|integer|realtime|real|time}]
   if { $paramType!={} && $caller=={highlight} } {
      $w tag add keyWord $typeStart $parseIndex
   }

   # skip possible range
   [namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex

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
#        net_type(?)
#        'signed'(?)
#        range(?)
#        direction_port_identifier_list[$item[1],@{$item{range}->[0]}]
#        ';'
#
#  output_declaration :
#        'output'
#        net_type|'reg'(?)
#        'signed'(?)
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

   # find net_type and/or signed
   set typeStart $parseIndex
   set netType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
         {reg|supply0|supply1|tri|triand|trior|tri0|tri1|wire|wand|wor}]
   if { $netType!={} && $caller=={highlight} } { highlightKeyword $w $netType $typeStart $parseIndex }

   set outputVarTypeStart $parseIndex
   set outputVarType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {integer|time|real|realtime}]
   if { $outputVarType!={} && $caller=={highlight} } { highlightKeyword $w $outputVarType $outputVarTypeStart $parseIndex }

   set signedStart $parseIndex
   set signed [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed}]
   if { $signed!={} && $caller=={highlight} } { highlightKeyword $w $signed $signedStart $parseIndex }

   # Find and skip range
   if { [[namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex] } {
      # Found - parseIndex contains next scan position
   }

   while 1 {
      set portIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex portIdentifierIndex $op]
      if { $portIdentifier == "" } {
         return $end
      } elseif { [lsearch -exact {input output inout} $portIdentifier]>-1 } {
         # DR 212271:
         return $end
         
         highlightKeyword $w $portIdentifier $portIdentifierIndex $parseIndex

         # find net_type and/or signed
         set typeStart $parseIndex
         set netType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
               {reg|supply0|supply1|tri|triand|trior|tri0|tri1|wire|wand|wor}]
         if { $netType!={} && $caller=={highlight} } { highlightKeyword $w $netType $typeStart $parseIndex }

         set signedStart $parseIndex
         set signed [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|unsigned}]
         if { $signed!={} && $caller=={highlight} } { highlightKeyword $w $signed $signedStart $parseIndex }

         # Find and skip range
         [namespace current]::skipPossibleRange $id $w $wDirect $op parseIndex

         continue
      }

      # Highlight declared port
      if { $caller == "highlight" } {
         $w tag add port $portIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],portSymbolsEnable) } {
         # Add port declaration into parser context
         [namespace parent]::declarationParserContext $id $w addLocal port $portIdentifier $start $parseIndex

         # Add port node to code browser
         if { $parentType=={module} } {
            set portId [[namespace parent]::parserContext $id register $portType $portIdentifier SystemVerilog]
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

proc interfaceCmd { id lang caller w keyword start end {op mark} } {
 
   variable dataTypes
   
   set wDirect    $w  
   set parseIndex $end

   set interfaceName [[namespace current]::getIdentifier $id $w $wDirect parseIndex interfaceNameIndex $op]
   if { $interfaceName == "" } { return $end }

   # Highlight interface name
   if { $caller == "highlight" } {
      $w tag add interfaceName $interfaceNameIndex $parseIndex
   }

   set type "interface"
   set interfaceStart $interfaceNameIndex
   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

   # find parameter list
   set hash [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {#\s*\(}]
   if { $hash!={} } {
      set closeIndex "$parseIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex
      while { [$w compare $parseIndex < $closeIndex] } {
         #get parameter keyword
         set keyStart $parseIndex
         set paramKeyword [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {parameter}]

         # Get type
         set typeStart $parseIndex
         set paramType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
               [join dataTypes(all,signing)]]

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex

         #  parameter_assignment_comma_parameter_assignment
         while 1 {
            set tempIndex $parseIndex
            set parameterIdentifier [[namespace current]::getIdentifier \
                  $id $w $wDirect tempIndex parameterIdentifierIndex $op]
            if { $parameterIdentifier=={parameter} } break
            set parseIndex $tempIndex
            # Highlight declared identifier
            if { $parameterIdentifier!={} && $caller=={highlight} } {
               $w tag add variable $parameterIdentifierIndex $parseIndex
            }

            set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|\)}]
            switch -exact -- [string index $delimiter 0] {
               ,  {
                  continue
               }
               \)  {
                  # End of parameter declaration
                  break
               }
               default {
                  # No valid delimiter
                  return $end
               }
            }
         }
      }
   }

   # module port list
   set openParen [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
   if { $openParen == {(} } {
      set closeIndex "$parseIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex

      set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
      if { $openComment=={/} } {
         [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex {}
      }

      while { [$w compare $parseIndex < $closeIndex] } {
         set dirStart $parseIndex
         set portDir [[namespace current]::getExactLexeme \
               $id $w $wDirect $op parseIndex {input|output|inout}]

         set typeStart $parseIndex
         set portType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
               {reg|wire|wand|wor|tri|triand|trior|int|shortint|longint|bit|byte|integer|time}]

         set signedStart $parseIndex
         set signed [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|unsigned}]
         if { $signed=={} && $caller=={highlight} } {
            highlightKeyword $w $signed $signedStart $parseIndex
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex
         
         # get port identifiers
         set portName [[namespace current]::getIdentifier $id $w $wDirect parseIndex portNameIndex $op]
         if { $portName!={} && $caller=={highlight} } {
            $w tag add port $portNameIndex $parseIndex
         }
         while 1 {
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|=|\)}]
            switch -exact -- $delimiter {
               , {
                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {`}]
                  if { $openDirective=={`} } {
                     set parseIndex [$w index "$parseIndex lineend +1c"]
                  }

                  set tempStartIndex $parseIndex
                  set portName [[namespace current]::getIdentifier \
                        $id $w $wDirect tempStartIndex portNameIndex $op]
                  if { [lsearch -exact {input output inout} $portName] > -1 } break
                  set parseIndex $tempStartIndex
                  if { $portName!={} && $caller=={highlight} } {
                     $w tag add port $portNameIndex $parseIndex
                  }

                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {`}]
                  if { $openDirective=={`} } {
                     set parseIndex [$w index "$parseIndex lineend +1c"]
                  }
               }
               = {
                  [namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|\)}
                  set parseIndex "$parseIndex-1c"
                  continue
               }
               ) break
               default {
                  return $end
               }
            }
         }
      }
   }

   if { $caller == "extract" } {

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $interfaceName SystemVerilog]

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

      set symbols($id,$interfaceName) "interface"
      
      # create ports and wires folders
      set portsFolderId [[namespace parent]::parserContext $id register ogroup ports SystemVerilog]
      [namespace parent]::BrowserNode  $id  $operation  $w     \
                              $portsFolderId  {}  {}           \
                              $blockId  {}  openfold
      set declFolderID($id,$blockId,ports) $portsFolderId

      set wiresFolderId [[namespace parent]::parserContext $id register ogroup wires SystemVerilog]
      [namespace parent]::BrowserNode  $id  $operation  $w     \
                              $wiresFolderId  {}  {}           \
                              $blockId  {}  openfold
      set declFolderID($id,$blockId,wires) $wiresFolderId

   }

   return $parseIndex
}

proc structUnionCmd { id lang caller w keyword start end {op mark} } {
#
# @comment   Applies syntax highlighting and extraction for structs and union types
# @comment parser extension.
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   # Get start parse index
   set parseIndex $end
   set startIndex $parseIndex
   set wDirect    $w
   
   if {$keyword == "union"} {
      # Look for 'tagged'
      set tagged [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {tagged}]
   }
   
   # Look for 'packed'
   set packed [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {packed}]

   # Look for 'signed' or 'unsigned'
   set signKW [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|unsigned}]
   
   # Skip declarations (if available)
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\{}]
   if { $delimiter != {} } {
      # Search for closing brace:
      set decEndIndex [findClosingSymbol $delimiter \} $w $parseIndex]
      if {$decEndIndex == -1} {
         return $end
      }
      set parseIndex [$w index $decEndIndex+1c]
   }
   
   while 1 {
      # Highlight struct name
      set structIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex structIdentifierIndex $op]
      if { $structIdentifier == "" } {
         return $end
      }
      if { $caller == "highlight" } {
         $w tag add structUnion $structIdentifierIndex $parseIndex
      } else {
         addChildNode $id $w $keyword $structIdentifier $start [$w index "$parseIndex lineend"] 0
      }
       
       # Get colon, or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;|=}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of reg declaration
            break
         }
         = {
            # Initialization
            [namespace current]::skipPossibleInitialization $id $w $wDirect $op parseIndex
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
            switch $delimiter {
               , {
                  # Another one:
                  continue
               }
               ; {
                  break
               }
               default {
                  return $end
               }
            }
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }
   return $parseIndex
}
  
proc enumCmd { id lang caller w keyword start end {op mark} } {
  #
  # @comment   Applies syntax highlighting and extraction for enumerated types
  # @comment parser extension.
  #
  # @argument    id          window identifier
  # @argument    w           window name
  # @argument    wDirect     direct window name
  # @argument    op          requested operation for comment
  # @argument    keyword     keyword recognized
  # @argument    start       start position of keyword
  # @argument    end         end position of keyword
  #
     
     variable dataTypes
     
     # Get start parse Index
     set parseIndex $end
     set startIndex $parseIndex
     set wDirect    $w
     
     # Look for type (integer, int, shortint, longint, bit, byte, reg or logic)
     set type [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex [join $dataTypes(all,integral) |]]
     if { $type!={} } {
        # skip packed multidimension:
        [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex
     }
     
   # Skip enumeration:
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\{}]
   if { $delimiter != {} } {
      # Search for closing brace:
      set decEndIndex [findClosingSymbol $delimiter \} $w $parseIndex]
      if {$decEndIndex == -1} {
         return $end
      }
      set parseIndex [$w index $decEndIndex+1c]
   }
   
   while 1 {
      # Highlight enum name:
      set enumIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex enumIdentifierIndex $op]
      if { $enumIdentifier == "" } {
         return $end
      }
      if { $caller == "highlight" } {
         $w tag add enum $enumIdentifierIndex $parseIndex
      }
      
      # Get colon, or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;|=}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of reg declaration
            break
         }
         = {
            # Initialization
            [namespace current]::skipPossibleInitialization $id $w $wDirect $op parseIndex
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
            switch $delimiter {
               , {
                  # Another one:
                  continue
               }
               ; {
                  break
               }
               default {
                  return $end
               }
            }
         }
         default {
            # No valid delimiter
            return $end
         }
      }
   }

   return $parseIndex
}

proc variableDeclaration { id lang caller w keyword start end {op mark} } {
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

   # Get start parse index
   set parseIndex $end
   set wDirect $w

   # Look for signed/unsigned keyword
   set startIndex $parseIndex
   
   if {[lsearch {string chandle event} $keyword] == "-1"} {
      set sign [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|unsigned}]
      if { $sign!={} && $caller=={highlight} } {
         highlightKeyword $w $sign $startIndex $parseIndex
      }
   }

   if {[lsearch {bit logic reg wire} $keyword] != "-1"} {
      # Skip packed array definition
      [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex
   }

   while 1 {
      set regIdentifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex regIdentifierIndex $op]
      if { $regIdentifier == "" } {
         return $end
      }

      # Highlight declared reg
      if { $caller == "highlight" } {
         $w tag add variable $regIdentifierIndex $parseIndex
      } elseif { $caller == "extract" && $HTE::Configuration(LexParser.[namespace tail [namespace current]],registerDataTypeSymbolsEnable) } {
         # Add reg declaration into parser context
         [namespace parent]::declarationParserContext $id $w addLocal register $regIdentifier $start $parseIndex
      }

      # Skip unpacked dimensions:
      [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex

      # Get colon, or semicolon
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;|=}]
      switch -exact -- $delimiter {
         ,  {
            continue
         }
         ;  {
            # End of reg declaration
            break
         }
         = {
            # Initialization
            [namespace current]::skipPossibleInitialization $id $w $wDirect $op parseIndex
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
            switch $delimiter {
               , {
                  # Another one:
                  continue
               }
               ; {
                  break
               }
               default {
                  return $end
               }
            }
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
   variable dataTypes

#  Syntax:
#    task_declaration ::= task [ lifetime ] task_body_declaration
#    task_body_declaration ::=
#           [ interface_identifier . | class_scope ] task_identifier ;
#        { tf_item_declaration }
#        { statement_or_null }
#        endtask [ : task_identifier ]
#        | [ interface_identifier . | class_scope ] task_identifier ( [ tf_port_list ] ) ;
#        { block_item_declaration }
#        { statement_or_null }
#        endtask [ : task_identifier ]
#    tf_item_declaration ::=
#        block_item_declaration
#        | tf_port_declaration
#    tf_port_list ::=
#        tf_port_item { , tf_port_item }
#    tf_port_item ::=
#        { attribute_instance }
#        [ tf_port_direction ] data_type_or_implicit
#        port_identifier variable_dimension [ = expression ]
#    tf_port_direction ::= port_direction | const ref
#    tf_port_declaration ::=
#        { attribute_instance } tf_port_direction data_type_or_implicit list_of_tf_variable_identifiers ;
#    lifetime ::= static | automatic
#    signing ::= signed | unsigned
#    data_type_or_implicit ::=
#        data_type
#        | [ signing ] { packed_dimension }

   set scanStartIndex $end
   set wDirect $w

   # automatic/static ?
   set liftimeStart $scanStartIndex
   set lifetime [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {automatic|static}]
   if { $lifetime!={} && $caller=={highlight} } {
      [namespace current]::highlightKeyword $w $lifetime $lifetimeStart $scanStartIndex
   }

   # Get task_identifier
   set taskName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex taskNameIndex $op]
   if { $taskName == "" } { return $end }
   # Highlight task name
   if { $caller == "highlight" } {
      $w tag add taskName $taskNameIndex $scanStartIndex
   }

   # task port list
   set openParen [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {\(}]
   if { $openParen=={(} } {
      while 1 {
         set dirStart $scanStartIndex
         set portDir [[namespace current]::getExactLexeme \
               $id $w $wDirect $op scanStartIndex {input|output|inout|const}]
         if { ($portDir != {}) && ($caller=={highlight}) } { highlightKeyword $w $portType $dirStart $scanStartIndex }
         if { $portDir == "const" } {
            set portDir [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {ref}]
         }

         set typeStart $scanStartIndex
         set portType [[namespace current]::getExactLexeme \
               $id $w $wDirect $op scanStartIndex [join $dataTypes(all,entire) |]]

         if { $portType!={} } {
            if { $caller=={highlight} } { highlightKeyword $w $portType $typeStart $scanStartIndex }
            if { $portType=={unsigned} || $portType=={signed} } {
               set typeStart $scanStartIndex
               set anotherType [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex [join $dataTypes(all,entire) |]]
               if { $anotherType!={} && $caller=={highlight} } {
                  highlightKeyword $w $anotherType $typeStart $scanStartIndex
               }
            }
            # Skip an enum, struct or union body:
            [namespace current]::skipPossibleBraces $id $w $wDirect $op scanStartIndex   
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         
         # get port identifiers
         set portName [[namespace current]::getIdentifier $id $w $wDirect scanStartIndex portNameIndex $op]
         if { $portName!={} && $caller =={highlight} } { $w tag add port $portNameIndex $scanStartIndex }
         # Array?
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         
         while 1 {
            set comma [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {,}]
            if { $comma!={,} } break
            set tempStartIndex $scanStartIndex
            set portName [[namespace current]::getIdentifier $id $w $wDirect tempStartIndex portNameIndex $op]
            if { [lsearch -exact {input output inout} $portName]>-1 } break
            set scanStartIndex $tempStartIndex
            if { $portName!={} && $caller=={highlight} } { $w tag add port $portNameIndex $scanStartIndex }
            # Array?
            [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op scanStartIndex
         }
         while 1 {
             set closeParen [[namespace current]::getLexeme $id $w $wDirect $op scanStartIndex {[\);]}]
             if { $closeParen == {)} } {
                set breakFlag true
                break
             } elseif { $closeParen == {;} } {
                set scanStartIndex $tempIndex
                set breakFlag true
                break
             } elseif {$closeParen == ""} {
                set dummyIndex $scanStartIndex
                set scanStartIndex [$w index "$scanStartIndex + 1 lines linestart"] 
                if [$w compare $scanStartIndex <= $dummyIndex] {
                   set breakFlag true
                   break
                }
             }
          }
          if {$breakFlag} break  
      }
   }

   #
   # Get semicolon
   #
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op scanStartIndex {;}]

   if { $delimiter == "" } {
      # No valid delimiter
      return $end
   }

   if { $caller == "extract" } {

      set type "task"
      set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

      foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

      # Register new block and get unique identifier
      set blockId [[namespace parent]::parserContext $id register $type $taskName SystemVerilog]

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

proc propSeqCmd { id lang caller w keyword start end {op mark} } {
#
# @comment   Sequence keyword parser extension. 
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
   set wDirect $w
   
   # Get sequence_identifier
   set seqName [[namespace current]::getIdentifier $id $w $wDirect parseIndex seqNameIndex $op]
   if { $seqName == "" } { return $end }
   # Highlight sequence name
   if { $caller == "highlight" } {
      $w tag add ${keyword}Name $seqNameIndex $parseIndex
   }

   # task port list
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(|;}]
      switch -- $delimiter {
      \( {
         while 1 {
            set argument [[namespace current]::getIdentifier $id $w $wDirect parseIndex argIndex $op]
            if {$argument == {}} {
               return $end
            } else {
               if { $caller == "highlight" } {
                  $w tag add argument $argIndex $parseIndex
               }
               set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\)|,}]
               switch -- $delimiter {
                  , {
                     # Another argument
                     continue
                  }
                  \) {
                     # End of argument list
                     break
                  }
                  default {
                     return $end
                  }
               }
            }
         }
      }
      ; {
         return $parseIndex
      }
      default {
         return $end
      }
   }

   return $parseIndex
}

proc clockingCmd { id lang caller w keyword start end {op mark} } {
#
# @comment   Clocking keyword parser extension. 
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
   set wDirect $w

   # Get clocking identifier:
   set clockName [[namespace current]::getIdentifier $id $w $wDirect parseIndex clockNameIndex $op]
   # Highlight clocking identifier
   if { $caller == "highlight" } {
      $w tag add ${keyword}Name $clockNameIndex $parseIndex
   }
   
   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {@}]
   switch -- $delimiter {
      @ {
         set parenStart [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
         if {$parenStart == ""} {
            set identifier [[namespace current]::getIdentifier $id $w $wDirect parseIndex identifierIndex $op]
            if {$identifier == ""} {
               return $end
            }
         } else {
            set endIndex [[namespace current]::findClosingSymbol \( \) $w $parseIndex]
            if {$endIndex == -1} {
               return $end
            }
         }         
      }
      default {
         return $end;
      }
   }
   
   return $parseIndex
}  

proc packageCmd { id lang caller w keyword start end {op mark} } {
#
# @comment   Clocking keyword parser extension. 
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
   set wDirect $w

   # Get package identifier:
   set packageName [[namespace current]::getIdentifier $id $w $wDirect parseIndex packageNameIndex $op]
   # Highlight clocking identifier
   if { $caller == "highlight" } {
      $w tag add ${keyword}Name $packageNameIndex $parseIndex
   }

   return parseIndex
}

proc programCmd { id lang caller w keyword start end {op mark} } {
#
# @comment   Program keyword parser extension. 
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    wDirect     direct window name
# @argument    op          requested operation for comment
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
#

   variable dataTypes
   
   set parseIndex $end
   set wDirect $w

   # automatic/static ?
   set liftimeStart $parseIndex
   set lifetime [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {automatic|static}]
   if { $lifetime!={} && $caller=={highlight} } {
      [namespace current]::highlightKeyword $w $lifetime $lifetimeStart $parseIndex
   }

   # Get program_identifier
   set programName [[namespace current]::getIdentifier $id $w $wDirect parseIndex programNameIndex $op]
   if { $programName == "" } { return $end }
   # Highlight task name
   if { $caller == "highlight" } {
      $w tag add programName $programNameIndex $parseIndex
   }
   # find parameter list
   set hash [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {#\s*\(}]
   if { $hash!={} } {
      set closeIndex "$parseIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex
      while { [$w compare $parseIndex < $closeIndex] } {
         #get parameter keyword
         set keyStart $parseIndex
         set paramKeyword [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {parameter}]

         # Get type
         set typeStart $parseIndex
         set paramType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
               [join dataTypes(all,signing)]]

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex

         #  parameter_assignment_comma_parameter_assignment
         while 1 {
            set tempIndex $parseIndex
            set parameterIdentifier [[namespace current]::getIdentifier \
                  $id $w $wDirect tempIndex parameterIdentifierIndex $op]
            if { $parameterIdentifier=={parameter} } break
            set parseIndex $tempIndex
            # Highlight declared identifier
            if { $parameterIdentifier!={} && $caller=={highlight} } {
               $w tag add variable $parameterIdentifierIndex $parseIndex
            }

            set delimiter [[namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|\)}]
            switch -exact -- [string index $delimiter 0] {
               ,  {
                  continue
               }
               \)  {
                  # End of parameter declaration
                  break
               }
               default {
                  # No valid delimiter
                  return $end
               }
            }
         }
      }
   }

   # program port list
   set openParen [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
   if { $openParen == {(} } {
      set closeIndex "$parseIndex-1c"
      [namespace current]::skipPossibleParentheses $id $w $wDirect $op closeIndex

      set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
      if { $openComment=={/} } {
         [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex {}
      }

      while { [$w compare $parseIndex < $closeIndex] } {
         set dirStart $parseIndex
         set portDir [[namespace current]::getExactLexeme \
               $id $w $wDirect $op parseIndex {input|output|inout}]

         set typeStart $parseIndex
         set portType [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex \
               {reg|wire|wand|wor|tri|triand|trior|int|shortint|longint|bit|byte|integer|time}]

         set signedStart $parseIndex
         set signed [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {signed|unsigned}]
         if { $signed=={} && $caller=={highlight} } {
            highlightKeyword $w $signed $signedStart $parseIndex
         }

         # skip possible range
         [namespace current]::skipPossibleMultiDimension $id $w $wDirect $op parseIndex
         
         # get port identifiers
         set portName [[namespace current]::getIdentifier $id $w $wDirect parseIndex portNameIndex $op]
         if { $portName!={} && $caller=={highlight} } {
            $w tag add port $portNameIndex $parseIndex
         }
         while 1 {
            set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|=|\)}]
            switch -exact -- $delimiter {
               , {
                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {`}]
                  if { $openDirective=={`} } {
                     set parseIndex [$w index "$parseIndex lineend +1c"]
                  }

                  set tempStartIndex $parseIndex
                  set portName [[namespace current]::getIdentifier \
                        $id $w $wDirect tempStartIndex portNameIndex $op]
                  if { [lsearch -exact {input output inout} $portName] > -1 } break
                  set parseIndex $tempStartIndex
                  if { $portName!={} && $caller=={highlight} } {
                     $w tag add port $portNameIndex $parseIndex
                  }

                  # skip possible comments
                  set openComment [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {/}]
                  if { $openComment=={/} } {
                     [namespace current]::parseComment $id $w $wDirect "$parseIndex-1c" parseIndex $op
                  }

                  # skip possible directives
                  set openDirective [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {`}]
                  if { $openDirective=={`} } {
                     set parseIndex [$w index "$parseIndex lineend +1c"]
                  }
               }
               = {
                  [namespace current]::getLexeme $id $w $wDirect $op parseIndex {,|\)}
                  set parseIndex "$parseIndex-1c"
                  continue
               }
               ) break
               default {
                  return $end
               }
            }
         }
      }
   }
  
   return $parseIndex
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

   variable codeTreeBlockDefinitionHDS
   set failed [catch {set type $codeTreeBlockDefinitionHDS($type)}]

   # Workaroud for error in the external parser
   if { $start == 0x7FFFFFFF && $end == 0x80000000 } {
      putLog "LexSystemVerilog::structuralParserCB: ERROR: abstract min and max limits for \"$name\" of \"$type\""
      set end $start
   } elseif { $end < $start } {
      putLog "LexSystemVerilog::structuralParserCB: ERROR: end value \"$end\" is less then start value ($start) for \"$name\" of \"$type\""
      set end $start
   }

   if { $name == {} } {
      putLog "LexSystemVerilog::structuralParserCB: ERROR: empty name of \"$type\" at \"$start .. $end\""
      set name NOTSET
   }

   set parentId {}
   if { $fastFFTParserLevelProcessing } {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id level get $level] {}
   } else {
      foreach {operation parentId beforeNode} [[namespace parent]::parserContext $id levelRange get $level $start $end] {}
   }

   if { $parentId == {} } {
      putLog "LexSystemVerilog::structuralParserCB: ERROR: no parent found for \"$name\" at $start .. $end at previous level"
      return
   }

   if { $externalDebug } {
      putLog "LexSystemVerilog::structuralParserCB: $level \[$start .. $end\] \"$name\" of \"$type\" (as incarnation of \"$genuineType\" [string equal $genuineType $type])"
      set parentType [[namespace parent]::parserContext $id getType $parentId]
      set parentName [[namespace parent]::parserContext $id getName $parentId]
      putLog "LexSystemVerilog::structuralParserCB: parent found: $parentId: \[$parentName of $parentType\]"
   }


   # Register new block and get unique identifier
   set blockId [[namespace parent]::parserContext $id register $type $name SystemVerilog]

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

   set exceptList {group ogroup portMapGroup parameterMapGroup portMap parameterMap}
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
      putLog "LexSystemVerilog::structuralParser: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "LexSystemVerilog::structuralParser: $msg"
      return $msg
   }

   set fileSizeInLines [lindex [split [$wDirect index end] .] 0]

   set fastFFTParserLevelProcessing [HTE::Config::isConfiguration $HTE::Configuration(LexParser.[namespace tail [namespace current]],fastFFTParserLevelProcessing)]
   if { $externalDebug } {
      putLog "LexSystemVerilog::structuralParser: fastFFTParserLevelProcessing: $fastFFTParserLevelProcessing"
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
      putLog "LexSystemVerilog::structuralParser: analysis level: \"$level\""
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
         putLog "LexSystemVerilog::structuralParser: invalid level \"$level\" returned"
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
      putLog "LexSystemVerilog::structuralParser: FFT return: \"$errorDef\""
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
      putLog "LexSystemVerilog::checkSyntax: $msg"
      return $msg
   }

   if { [info exists env(HDS_HOME)] == "" } {
      set msg "No parser - \[HDS_HOME\] environment variable is not defined"
      putLog "LexSystemVerilog::checkSyntax: $msg"
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
      putLog "LexSystemVerilog::checkSyntax: FFT analysis level: \"$level\""
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
      putLog "LexSystemVerilog::checkSyntax: FFT return: \"$errorDef\""
   }

   return $errorDef
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
  
   set ignoreIdx [$w search $ignoreSym $index end]
   set idx       [$w search $sym $index end]
   
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
                              {^(\s*).*begin}
                              {^(\s*)case}
                              {^(\s*)clocking}
                              {^(\s*)config}
                              {^(\s*)else}
                              {^(\s*)function}
                              {^(\s*)generate}
                              {^(\s*)if.*(.*)}
                              {^{\s*}interface}
                              {^(\s*)module}
                              {^(\s*)package}
                              {^(\s*)program}
                              {^(\s*)property}
                              {^(\s*)sequence}
                              {^(\s*)task}
                              {\{[^\}]*$}
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
      endclocking    -
      endconfig      -
      endfunction    -
      endgenerate    -
      endinterface   -
      endmodule      -
      endpackage     -
      endprimitive   -
      endprogram     -
      endproperty    -
      endsequence    -
      endtable       -
      endtask        -
      \} {
         return 1
      }
   }

   return 0
}

proc getAdditionalTags {} {
   return "integer moreKeyword structUnion enum compilerDirectives timeUnit"
}
