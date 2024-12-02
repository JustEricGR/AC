#HTEParser#XML#LexXML#XML files#XML Plugin#xml|htt|htl#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2001,2002 All Rights Reserved
#
# @comment XML plug-in for HTE lexical parser
#
# =============================================================================


# ======================================================================
# LexXML namespace - XML related lexical parser part
# ======================================================================
   global tcl_platform

   #
   array set xmlParser {}

   set updateLevelDefault 10
   set updateLevel $updateLevelDefault

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
   # Set initial configuration
   #

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
   set PluginTagsTEMPLATE        {"TEMPLATE"                ""                         "r"}
   set PluginTagsList {
      comment              {"Comment"                       "-foreground #008000"  ""}
      keyWord              {"Keyword"                       "-foreground #c00000"  "s"}
      markup               {"Markup"                        "-foreground #000080"  ""}
   }
   array set PluginTags $PluginTagsList

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
   # XML plug-in maintain dynamically created and modified array ('codeTreeBlock" wrapper)
   #
   array set codeTreeBlockDefinition {}

   #
   # XML parser subsection of configuration values
   # Set - only when they are not already loaded
   #
#   if { [expr [llength [array names HTE::Configuration LexParser.[namespace tail [namespace current]],*]] == 0] } {

      set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)              Yes
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)                  Yes

#   }

   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea) No
   HTE::Config::checkBooleanConfiguration HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)     No


   namespace import -force ::HTE::Console::putLog

   if { [[namespace parent]::parserUnavailable] } {
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],VisualArea)  No
      set HTE::Configuration(LexParser.[namespace tail [namespace current]],Linear)      No
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
#  set endOfLine [expr [$w index "$index lineend"] == [$w index $index]]
   set endOfLine [$w compare "$index lineend" == $index]

#  putLog "$endOfLine $special $index $line"
   if { $special } {
      # Shift-Enter is pressed - return line starting blanks
      if { [expr [regexp {^(\s*)} $line match initialSpaces] != 0] } {
         return $initialSpaces
      }
   } else {

      # If line is finished by end tag - preserve indentation
      if { [regexp {</.*>$} $line] } {
         # Get indentation blanks
         set initialSpaces {}
         regexp {^(\s*)} $line match initialSpaces
         # And return it
         return $initialSpaces
      }

      # Sequentially check whether line is matched against regular
      # expressions from $indentationREList
      set indentationREList {
                              {^(\s*)<}
                            }

      foreach indentationRE $indentationREList {

         # Increment indentation if we are at the end of line
         # or preserve it otherwise
         if { [regexp $indentationRE $line match initialSpaces] != "0" } {
            if { $endOfLine } {
               return $initialSpaces[string repeat " " $smartIndentValue]
            } else {
               return $initialSpaces
            }
         }
      }
   }

   return {}

}

proc getCodeTreeBlockTypes { } {
#
# @comment   Returns list of known code blocks names
#
# @note   Obsolete procedure. Calls should be changed to <proc ::HTE::LexParser::codeTreeBlock>&p
#
# @note Used by:&p
# @note - <proc ::HTE::LexParser::getCodeTreeBlockTypes>&p
#

   variable codeTreeBlockDefinition
   return [array names codeTreeBlockDefinition *]
}

proc codeTreeBlock { id op args } {
#
# @comment   Plug-in code tree blocks definitions wrapper.&p
#
# @comment   Valid call strings:&p
#
# @comment     codeTreeBlock $id reset&p
# @comment        - reset code tree blocks definitions&p
#
# @comment     codeTreeBlock $id add $type&p
# @comment        - add new code block type&p
#
# @argument    id             window identifier
# @argument    op             operation requested
# @argument    args           additional sub-operation arguments
#

   variable codeTreeBlockDefinition

   switch -exact -- $op {

      reset  {

         array unset codeTreeBlockDefinition $id,*
         set codeTreeBlockDefinition($id,comment) [list comment {}]
      }

      add   {
         # Get type name
         set type [lindex $args 0]

         set codeTreeBlockDefinition($id,$type) [list $type {}]
      }

      dump  {

         return [array names codeTreeBlockDefinition $id,*]
      }

      default  {
         error "LexXML::codeTreeBlock: invalid operation \"$op\" is requested"
      }

   }
   # End of switch

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
# @note In contrast to highlighting parsers other plug-ins do not really
# @note parse text - only highlight code ranges found by internal (linear) parser
#

   variable vaDebug

   variable PluginTags

#  putLog "LexXML::parserVA $id $start $end"

   # Provide first search mark start position in the numeric form
   set scanStart [$w index $start]

   # Prepare list of already selected nodes to prevent double tag setting
   set nodeSelected {}

   while 1 {

      if { [$w compare $scanStart >= $end] } {
         return $scanStart
      }

      # Get next mark
      set tagMark [$w mark next $scanStart]
      if { $tagMark == {} } {
         # No marks. It is rare but possible
         return $end
      }

      if { [$w compare $tagMark >= $end] } {
         # All is done
         return $end
      }

#     putLog "LexXML::parserVA: === [$w index $tagMark] $tagMark"

      # Check whether this mark denotes pseudo node
      set pseudoNode [[namespace parent]::marks $id fetchNode $tagMark]

      if { $pseudoNode != {} } {

         # Check whether this node already selected
         if { [expr [lsearch -exact $nodeSelected $pseudoNode] == -1] } {

            # Remember node
            lappend nodeSelected $pseudoNode

            # Get type of pseudo node
            set tagName [[namespace parent]::nameOfNode $id getType $pseudoNode]
#           putLog "LexXML::parserVA:     Node id: $pseudoNode Tag name: $tagName"

            if { $tagName != {} } {

               # Type of pseudo node to be selected should be registered tag name
               if { [array names PluginTags $tagName] != {} } {

                  # If so - get sibling mark name
                  set tagMarkSibling [[namespace parent]::marks $id sibling $tagMark]
#                 putLog "LexXML::parserVA:     $tagMark .. $tagMarkSibling"

                  if { $tagMarkSibling != {} } {

                     # Get pseudo node limitss
                     if { [$w compare $tagMark > $tagMarkSibling] } {
                        set tagMark1 $tagMarkSibling
                        set tagMark2 $tagMark
                     } else {
                        set tagMark1 $tagMark
                        set tagMark2 $tagMarkSibling
                     }

                     # And highlight it
                     $w tag add $tagName $tagMark1 $tagMark2
#                    putLog "LexXML::parserVA:     $tagMark1 .. $tagMark2 $tagName"

                  } else {
                     putLog "LexXML::parserVA:     ERROR: Sibling mark name was not found for: $tagMark"
                  }
               }

            }

         }
      }

      # Get next mark in the scanStart - it is name of mark
      # to get realy next mark by "widget mark next" command
      set scanStart $tagMark
   }

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

   variable xmlParser

   if { [info exists xmlParser($id)] } {
      $xmlParser($id) reset
      $xmlParser($id) free
   }

# Incremental parsing workaround
#                            -final 0                                                      \
# Incremental parsing workaround

   set xmlParser($id) [xml::parser                                                           \
                         -elementdeclcommand  "[namespace current]::elementDeclaration $id"  \
                         -elementstartcommand "[namespace current]::elementStart       $id"  \
                         -elementendcommand   "[namespace current]::elementEnd         $id"  \
                         -commentcommand      "[namespace current]::comment            $id"  \
                      ]

#                           -defaultcommand      [namespace current]::default

   # Reset all parser context

   set xmlParser($id,elementsOpened) 0
   set xmlParser($id,updateCount) 0

   # Reset code blocks definitions
   [namespace parent]::parserContext $id reset

   # Reset internal plug-in context
   codeTreeBlock $id reset

   # endLine should not be passed into createCodeTree
   [namespace parent]::BrowserCreateCodeTree $id $fileName $startLine ""

}

proc elementDeclaration { id args } {
#
# @comment  Element peclaration parser's extension (-elementdeclcommand callback)
#
# @argument id     - ndow identifier
# @argument args   - claration of element
#
   putLog "LexXML::elementDeclaration: $args"
}

proc elementStart { id args } {
#
# @comment  Element start parser's extension (-elementstartcommand callback)
#
# @argument id     - ndow identifier
# @argument args   - st of element name, field name and value
#

   variable xmlParser
   variable updateLevel

   variable matchedCount

   if { $args == {} } {
      putLog "LexXML::elementStart: Internal error - empty arguments"
   }

   set w       $xmlParser($id,w)
   set wDirect $xmlParser($id,wDirect)
   set start   $xmlParser($id,start)

   set elementName [lindex $args 0]

   set elementNameStart [$wDirect search -elide -exact -count [namespace current]::matchedCount -- $elementName $start end]
   if { $elementNameStart == {} } {
      putLog "LexXML::elementStart: Internal error: element name \"$elementName\" is not found from $start"
      return
   }
   set elementNameEnd [$wDirect index "$elementNameStart +$matchedCount chars"]

#  putLog "LexXML::elementStart: $args"
#  putLog "                      $start Name: \"$elementName\" $elementNameStart $elementNameEnd"

   # Create pseudo node for keyword
   [namespace parent]::addPseudo $id $w keyWord $elementNameStart $elementNameEnd

   # I do not know - does any blanks are possible around name?
   # Head markup bounds
   set start1 [$wDirect index "$elementNameStart -1 char"]
   set start2 $elementNameStart
   # Create pseudo node for markup delimiter
   [namespace parent]::addPseudo $id $w markup $start1 $start2

   # Shift global scan index
   set xmlParser($id,start) $elementNameEnd

###   set fields [eval concat [lrange $args 1 end]]
###   if { [expr [llength $fields] == 0] }

#  array set fields [eval concat [lrange $args 1 end]]
   array set fields {}
   foreach {field value} [eval concat [lrange $args 1 end]] {
      set fields([string tolower $field]) $value
   }

   if { [expr [llength [array names fields *]] == 0] } {
      set end1   $elementNameEnd
      set end2   [$wDirect index "$elementNameEnd +1 char"]

      # Create pseudo node for markup delimiter
      [namespace parent]::addPseudo $id $w markup $end1 $end2

      # Shift global scan index
      set xmlParser($id,start) $end2

   }

   incr xmlParser($id,elementsOpened)

   incr xmlParser($id,updateCount)
   if { [expr $xmlParser($id,updateCount) >= $updateLevel] } {
      update
      set xmlParser($id,updateCount) 0
   }

   # Create browser node
   set type $elementName
   codeTreeBlock $id add $type

#  set iconName $HTE::Configuration(LexParser.LexVerilog,icon.$type)

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

   # Register new block and get unique identifier
   set name {}
   catch {set name $fields(name)}
   set blockId [[namespace parent]::parserContext $id register $type $name XML]

   [namespace parent]::BrowserNode              \
                           $id                  \
                           $operation           \
                           $w                   \
                           $blockId             \
                           $start1              \
                           {}                   \
                           $parentId            \
                           $beforeNode
#                          $iconName

   [namespace parent]::parserContext $id push $blockId

}

proc elementEnd { id args } {
#
# @comment  Element end parser's extension (-elementendcommand callback)
#
# @argument id     - ndow identifier
# @argument args   - st that contains element name
#

   variable linearExtDebug

   variable xmlParser
#  variable updateLevel

   variable matchedCount

   # Check arguments
   if { $args == {} } {
      putLog "LexXML::elementEnd: Internal error - empty arguments"
   }

   # Get widget names and scan start position
   set w       $xmlParser($id,w)
   set wDirect $xmlParser($id,wDirect)
   set start   $xmlParser($id,start)

   # Check internal consistency
   if { [expr $xmlParser($id,elementsOpened) <= 0] } {
      putLog "LexXML::elementEnd: internal error: structure discrepancy: \"$xmlParser($id,elementsOpened)\""
   } else {
      incr xmlParser($id,elementsOpened) -1
   }

   # First element of argument list is name of element
   set elementName [lindex $args 0]
   # I do not know - does any blanks are possible around name?
   set elementNameRE "/>|</$elementName>"

#  set elementNameStart [$wDirect search -elide -exact -count [namespace current]::matchedCount -- $elementName $start end]
   set elementNameStart [$wDirect search -elide -regexp -count [namespace current]::matchedCount -- $elementNameRE $start end]
   if { $elementNameStart == {} } {
      putLog "LexXML::elementEnd: Internal error: element name \"$elementName\" is not found from $start"
      return
   }

   set elementNameEnd [$wDirect index "$elementNameStart +$matchedCount chars"]
   set elementEnd [$wDirect get $elementNameStart $elementNameEnd]

   if { $elementEnd == {/>} } {

      # Tail markup bounds
      set end1 $elementNameStart
      set end2 [$wDirect index "$elementNameStart +2 chars"]

      # Create pseudo node for markup
      [namespace parent]::addPseudo $id $w markup $end1   $end2

   } else {

      set start [$wDirect index "$elementNameStart +2 chars"]
      set end   [$wDirect index "$elementNameEnd -1 char"]

      # Create pseudo node for element name
      [namespace parent]::addPseudo $id $w keyWord $start $end

      # Tail markup bounds
      set start1 $elementNameStart
      set start2 [$wDirect index "$elementNameStart +2 chars"]
      set end1   [$wDirect index "$elementNameEnd -1 char"]
      set end2   $elementNameEnd

      # Create pseudo nodes for markup delimiters
      [namespace parent]::addPseudo $id $w markup $start1 $start2
      [namespace parent]::addPseudo $id $w markup $end1   $end2

   }

   # Shift global scan index
   set xmlParser($id,start) $elementNameEnd


#  putLog "LexXML::elementEnd: $args"
#  putLog "                    $start Name: \"$elementName/$elementEnd\" $elementNameStart .. $elementNameEnd"

   set blockId [[namespace parent]::parserContext $id pop]

   set blockEnd $end2

   if { $linearExtDebug } {
      set blockType  [[namespace parent]::parserContext $id getType $blockId]
      set blockName  [[namespace parent]::parserContext $id getName $blockId]
      putLog "LexXML::elementEnd: $blockEnd End of $blockType \"$blockName\""
   }

   [namespace parent]::BrowserCompleteNode   \
                           $id               \
                           $w                \
                           $blockId          \
                           $blockEnd

}

proc comment  { id data } {
#
# @comment  Comment parser's extension (-commentcommand callback)
#
# @argument id     window identifier
# @argument data   comment body
#

#
#  2.5 Comments
#
#  [Definition:] Comments may appear anywhere in a document outside other markup;
#  in addition, they may appear within the document type declaration at places
#  allowed by the grammar. They are not part of the document's character data;
#  an XML processor may, but need not, make it possible for an application to
#  retrieve the text of comments. For compatibility, the string "--"
#  (double-hyphen) must not occur within comments.
#
#  Comments
#
#  [15]  Comment ::=  '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
#
#
#  An example of a comment:
#
#  <!-- declarations for <head> & <body> -->
#

   variable xmlParser
   variable matchedCount

   set w       $xmlParser($id,w)
   set wDirect $xmlParser($id,wDirect)
   set start   $xmlParser($id,start)

#  putLog "LexXML::comment:   $data"

   set commentStart {}

   # For each line in the multiline comment
   foreach line [split $data "\n"]  {

      # Skip empty line
      if { $line == {} } {
         continue
      }
#     putLog "LexXML::comment:   $line"

      # Find next chunk of data in the text
      set commentLineStart [$wDirect search -elide -exact -count [namespace current]::matchedCount -- $line $start end]

      if { $commentLineStart == {} } {
         putLog "LexXML::comment: Internal error: chunk of comment \"$line\" is not found from $start "
         return
      }

      # Remember start of first line
      if { $commentStart == {} } {
         set commentStart $commentLineStart
#        putLog "first: $commentStart \"$line\""
      }

      # Remember end of possibly last line
      set commentEnd [$wDirect index "$commentLineStart +$matchedCount chars"]

      # Shift scan index
      set start $commentEnd
   }

   # Register comment and create pseudo node
#  putLog "LexXML::comment: $commentStart .. $commentEnd"
   [namespace parent]::BrowserComment $id $w $commentStart $commentEnd

   # Shift global scan index
   set xmlParser($id,start) $commentEnd

   # Get position of comment head markup
   set markupStart [$wDirect search -elide -backwards -exact -count [namespace current]::matchedCount -- {<!--} $commentStart 1.0]
   if { $markupStart != {} } {

      # Head markup limits
      set start1 $markupStart
      set start2 [$wDirect index "$markupStart +$matchedCount chars"]

      # Get position of comment tail markup
      set markupEnd [$wDirect search -elide -exact -count [namespace current]::matchedCount -- {-->} $commentEnd end]
      if { $markupEnd != {} } {

         # Tail markup bounds
         set end1 $markupEnd
         set end2 [$wDirect index "$markupEnd +$matchedCount chars"]

         # Create pseudo nodes for markup delimiters
         [namespace parent]::addPseudo $id $w markup $start1 $start2
         [namespace parent]::addPseudo $id $w markup $end1   $end2

#        putLog "LexXML::comment: markup $start1 .. $start2"
#        putLog "LexXML::comment: markup $end1   .. $end2"

         # Shift global scan index and set it just after tail comment markup
         set xmlParser($id,start) $end2
      }
   }

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
#

   variable xmlParser

   set xmlParser($id,w)       $w
   set xmlParser($id,wDirect) $wDirect
   set xmlParser($id,start)   $start

   variable linearDebug

   variable matchedCount

   set scanStart $start
# Incremental parsing workaround
#  set scanLimit [$wDirect index "$start + $limit lines linestart"]
   set scanLimit [$wDirect index end]
# Incremental parsing workaround
   set scanStop  $end

   variable lexemeStart {\S}

   variable stringRE

# Incremental parsing workaround
#   if { [$wDirect compare $scanLimit >= $end] } {
#      $xmlParser($id) configure -final 1
#      set scanLimit $end
#      putLog "Final new"
#   }
# Incremental parsing workaround

#  putLog "LexXML::linear: $start .. $scanLimit .. $end"

   set buffer [$wDirect get $scanStart $scanLimit]

   set parserFailed [catch {$xmlParser($id) parse $buffer} parserError]
   if { $parserFailed } {
      putLog "LexXML::linear: $parserError"
      return $end
   }

   [namespace parent]::generateTextScrolled $id $w
   return $end
}
