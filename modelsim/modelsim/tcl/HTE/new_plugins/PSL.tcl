#HTEParser#psl#LexPSL#PSL sources#PSL Plugin#psl#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2001-2004 All Rights Reserved
#
#
# @comment PSL plug-in for HTE lexical parser
#
# =============================================================================

## Complementary script defining callbacks
## for PSL plugin

array set codeTreeBlockDefinition {
      property                   {"Property"                      "PslProperty"}
      sequence                   {"Sequence"                      "PslSequence"}
      endpoint                   {"End Point"                     "PslEndPoint"}
      vDirective                 {"Verification Directive"        "PslAssertion"}
      vunit                      {"Verification Unit"             "PslVunit"}
      vmode                      {"Verification Mode"             "PslVmode"}
      vprop                      {"Verification Property"         "PslVprop"}
      defClock                   {"Default Clock"                 "PslClock"}
      comment                    {"Comment"                       ""}
}

# By default, set all block types to be visible
if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
} else {
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
      {property sequence endpoint vDirective vunit vmode vprop defClock}
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
      [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
}

variable extendedIdentifiers 1
 
set HighlightRE(operator) {[@+:%~*&<>=|^,;]}
set HighlightRE(parentheses) {[\[\]\(\)\{\}]}
set HighlightRE(integer) {(?:\W|\A)(\d+)(\W|$)}
set HighlightRE(otherComment) {(//)}
set HighlightRE(strong) {(!)}
set hlCallbacks(otherComment) [namespace current]::tagSingleLineComment
set hlCallbacks(strong) [namespace current]::strongOperator
set slComment2 "//"
set prsCallbacks(\{) [namespace current]::parenthesisCmd
set prsCallbacks(\}) [namespace current]::parenthesisCmd
set prsCallbacks(//) [namespace current]::tagSingleLineComment
set addKeywordsToParse {// \{ \}}
   
proc tagSingleLineComment { id language job textw kw start index } {
#
# @comment This function is added because PSL has two different single line 
# @comment commenting styles: VHDL style and Verilog style, so the VHDL style
# @comment -- is registered as the default commenting style for the plugin 
# @comment and whenever // is encountered this function is called to comment
# @comment the two / characters before calling tagSingleLineComment in the.&p
# @comment SyntaxHighlight namespace which comments the rest of the line.
#
# @argument    id          window identifier
# @argument    language    PSL
# @argument    textw       window name
# @argument    job         parsing job
# @argument    kw          keyword recognized in this case '//'
# @argument    start       start position of keyword
# @argument    index       end position of keyword
#
   $textw tag add comment $start $index
   ::SyntaxHighlight::tagSingleLineComment $id $language $job $textw $kw $start $index
}

proc strongOperator { id language job textw kw start index } {
#
# @comment Handles strong operators having "!" at the end of the keyword: 
# @comment The impelementation is quite smart because it will highlight
# @comment the "!" as it is typed like normal operators (Keywords), but 
# @comment it does not descriminate between operators that may be strong
# @comment and others that may not.&p
#
# @argument    id          window identifier
# @argument    language    PSL
# @argument    textw       window name
# @argument    job         parsing job
# @argument    kw          keyword recognized in this case '//'
# @argument    start       start position of keyword
# @argument    index       end position of keyword
#
   set prevWord [string tolower [$textw get "$start-1chars wordstart" $index]]
   
   if {($prevWord == "next_event_a!") || ($prevWord == "next_event_e!") || ($prevWord == "eventually!")} {
      $textw tag add keyWord "$start-1chars wordstart" $index
      return
   }
   if {[$textw tag prevrange keyWord $index "$start-1chars wordstart"] != ""} {
      $textw tag add keyWord $start $index
   }
}

proc addParentNode { id w type name start } {
#
# @comment Adds a node to the code browser but leaves the node open so that
# @comment more nodes can be inserted as children to this parent node
#
# @argument    id          window identifier
# @argument    w           window name
# @argument    type        type of the parent node
# @argument    name        name of the parent node
# @argument    start       start position of the construct
# 
# @result Returns the Id of the created node
#
   variable parent
   
   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}

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
   [namespace parent]::parserContext $id push $blockId
   
   foreach folder [array names parent $id,$blockId,*] {
      unset parent($folder)
   }
   
   return $blockId
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
   variable braces
   
   set iconName $HTE::Configuration(LexParser.[namespace tail [namespace current]],icon.$type)

   foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id get] {}
   
   set node [::HTE::Browser::nameOfNode $id getName $parentId]
   
   if {($addFolder == 1) && ($parentId != "root")} {  
      if [info exists parent($id,$parentId,${type}Folder)] {
         set parentId $parent($id,$parentId,${type}Folder)
      } else {
         if {$type == "property"} {
	    set groupName "properties"
	 } elseif {$type == "vDirective"} {
	    set groupName "directives"
	 } else {
	    set groupName ${type}s
	 }
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
   #if {[info exists braces(ids)] && ($braces(ids) != {})} {
   #   foreach famId $braces(ids) {
   #      foreach {structStart structEnd} $braces($famId,limits) {}
   #      if {[$w compare $start > $structStart] && [$w compare $end < $structEnd]} {
   #         set parentIdList $braces($famId,familyNodes)
   #         break	    
   #      }
   #   }
   #}
      
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

proc parenthesisCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles braces, when a right brace is entered in the text  
# @comment means that a parent construct is closed, and this should be 
# @comment known by the code browser so that new child nodes do not be 
# @comment added to it. Some right braces are just the closing delimiter 
# @comment for a sequence or a property so this should also be known so
# @comment the function initially assumes so, except for the case when
# @comment flag braces(flag) is set to 1
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
# 
   variable braces
   variable parent

   if {$keyword == "\}"} {
      if {[info exists braces(count)] && ($braces(count) != 0)} {
	 incr braces(count) -1
      } else {
         set blockId [[namespace parent]::parserContext $id pop]

         set blockEnd $end
         [namespace parent]::BrowserCompleteNode   \
                                 $id               \
                                 $w                \
                                 $blockId          \
                                 $blockEnd
      }
   } elseif {$keyword == "\{"} {
      if {[info exists braces(flag)] && ($braces(flag) == 1)} {
	 set braces(count) 0
	 set braces(flag) 0
      } else {
         if [info exists braces(count)] {
	    incr braces(count)
         } else {
            set braces(count) 1
         }
      }
   }

   return $end
}

proc inheritCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax Highlighting of base verification units  
# @comment defined by the inherit keyword: 
# @comment Syntax:
# @comment    Inherit_Spec ::=
# @comment       inherit vunit_Name { , vunit_Name } ;
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

   while 1 {
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      # Highlight declared variable
      if { $caller == "highlight" } {
         $w tag add baseVUnit $identifierIndex $parseIndex
      } 
      
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|;}]
      switch -- $delimiter {
         ;  {
            break
         }
	 ,  {
	    continue
	 }
         default  {
	    return $end
         }
      }
   }
   
   return $parseIndex
}

proc vunitCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax Highlighting and code extraction of verification 
# @comment units defined by vunit,vmode or vprop keywords: 
# @comment syntax: 
# @comment    Verification_Unit ::=
# @comment       VUnitType Name [ ( Hierarchical_HDL_Name ) ] {
# @comment          { Inherit_Spec }
# @comment          { VUnit_Item }
# @comment       }
# @comment    
# @comment    VUnitType ::=
# @comment       vunit | vprop | vmode
# @comment    
# @comment    Name ::=
# @comment       HDL_ID
# @comment    
# @comment    Hierarchical_HDL_Name ::=
# @comment       module_Name { PATH_SYM instance_Name }
# @comment    
# @comment    Inherit_Spec ::=
# @comment       inherit vunit_Name { , vunit_Name } ;
# @comment    
# @comment    VUnit_Item ::=
# @comment       HDL_Decl_or_Stmt
# @comment          | PSL_Declaration
# @comment          | Verification_Directive
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
# 
   variable braces
   variable parent
   
   set wDirect $w
   set parseIndex $end

   while 1 {
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      # Highlight declared variable
      if { $caller == "highlight" } {
	 $w tag add vunittype $identifierIndex $parseIndex
      } 
      
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(|\{}]
      switch -- $delimiter {
         (  {
            break
         }
	 \{  {
	    if {$caller == "extract"} {
               set braces(flag) 1
	       [namespace current]::addParentNode $id $w [string tolower $keyword] $identifier $start 
               set parseIndex [$w index $parseIndex-1chars]
	    }
	    return $parseIndex
	 }
         default  {
	    if {$caller == "extract"} {
	       [namespace current]::addChildNode $id $w [string tolower $keyword] $identifier $start ${parseIndex}-1chars 0
            }

            return $parseIndex
         }
      }
   }

   set exitLoop 0
   set leftParenFlag 0
   while (1) {
      set design_module [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex moduleIndex]
      if { $design_module != "" } {
         if { $caller == "highlight" } {
            $w tag add designmodule $moduleIndex $parseIndex
         }
      }
      set endIndex $parseIndex
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {.|\(|\)}]
      switch -- $delimiter {
         [ - 
         ] - 
         . {
	    if { $caller == "highlight" } {
	       $w tag add designmodule $endIndex $parseIndex
	    }
	    continue
	 }
	 ( {
	    if { $caller == "highlight" } {
	       $w tag add designmodule $endIndex $parseIndex
	    }
	    incr leftParenFlag
	    continue 
	 }
	 ) {
	    if {$leftParenFlag == 0} {
	       break
	    } else {
	       incr leftParenFlag -1
	       if { $caller == "highlight" } {
	          $w tag add designmodule $endIndex $parseIndex
	       }
	       continue
	    }
	 }
	 default {
	    break
         }
      } 
   }
   
   if {$caller == "extract"} {
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\{}]
      if {$delimiter == "\{"} {
         set braces(flag) 1
	 set parseIndex [$w index $parseIndex-1chars]
	 [namespace current]::addParentNode $id $w [string tolower $keyword] $identifier $start 
      } else {
         [namespace current]::addChildNode $id $w [string tolower $keyword] $identifier $start ${parseIndex}-1chars 0
      }
   }
   return $parseIndex
}

proc vDirectivesCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of Verification  
# @comment directives such as assert, assume, restrict, ... etc. 
# @comment Syntax:
# @comment    PSL_Directive ::=
# @comment        Verification_Directive
# @comment    
# @comment    Verification_Directive ::=
# @comment       Assert_Statement
# @comment       | Assume_Statement
# @comment       | Assume_Guarantee_Statement
# @comment       | Restrict_Statement
# @comment       | Restrict_Guarantee_Statement
# @comment       | Cover_Statement
# @comment       | Fairness_Statement
# 
   variable parent
   set wDirect $w
   set parseIndex $end

   # Looking for a label:
   set labEndIndex [$w index "$start-4chars wordstart"]
   set label [[namespace current]::getAlphaNumericWord $id $w $wDirect $op labEndIndex labStartIndex]
   if {$label != ""} {
      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op labEndIndex {:}]
      if {$delimiter == ":"} {
         set labelName $label
	 if { $caller == "highlight" } {
	    $w tag add label $labStartIndex $labEndIndex
	 }  
      }
   }

   set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
   
   if { $identifier == "" } {
      return $end
   } 
   
   set declarationEnd [[namespace current]::findSemiColon $w $parseIndex]
   if {$declarationEnd == "-1"} {
      return $end
   }
   
   if { $caller == "extract" } {
      set name [string tolower $keyword]
      if [info exists labelName] {
        set name $labelName
      } elseif [isDefined $id $w $identifier] {
         lappend name $identifier
      } else {
	 set restOfLine [$w get $identifierIndex "$identifierIndex lineend"]
	 append name " [string range $restOfLine 0 5]"
	 append name "..."
      }
      [namespace current]::addChildNode $id $w vDirective $name $start $declarationEnd 1

      return $parseIndex
   }
   
   if {[info exists parent($id,properties)] && ([lsearch $parent($id,properties) [string trim $identifier]] >= 0)} { 
      if { $caller == "highlight" } {
	 if [isDefined $id $w $identifier] {
	    $w tag add property $identifierIndex $parseIndex
	 } else {
	    $w tag add property $identifierIndex $parseIndex
	 }
      }           
   } else {
      $w tag remove property $identifierIndex $parseIndex
      return $end
   }
}

proc vStrongDirectivesCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of Verification  
# @comment directive "strong". 
# @comment Syntax:
# @comment    Fairness_Statement ::=
# @comment       fairness Boolean ;
# @comment       | strong fairness Boolean , Boolean ;
#   
   set wDirect $w
   set parseIndex $end
   
   set vDirective [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex vDirectiveIndex]
   
   if { [string tolower [string trim $vDirective]] != "fairness" } {
      return $end
   }
   
   set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
   
   if { $identifier == "" } {
      return $parseIndex
   }

   if { $caller == "extract" } {
      set declarationEnd [[namespace current]::findSemiColon $w $parseIndex]
      if {$declarationEnd == "-1"} {
         return $end
      }
      [namespace current]::addChildNode $id $w vDirective "strong fairness $identifier" $start $declarationEnd 1

      return $parseIndex
   } 
}

proc integerCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of declaration  
# @comment of integer types defined by the integer modeling layer directive: 
# @comment Syntax:
# @comment    Finite_Integer_Type_Declaration ::=
# @comment       integer Integer_Range list_of_variable_identifiers ;
# @comment    
# @comment    Integer_Range ::=
# @comment       ( constant_expression : constant_expression )
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
      set parseIndex [[namespace current]::skipRange $w $parseIndex]
      if {$parseIndex == "-1"} {
         return $end
      }
   } else {
      return $end
   }
   
   while 1 {
      set identifierStart $parseIndex
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }
      # Highlight declared variable
      if { $caller == "highlight" } {
         $w tag add intType $identifierIndex $parseIndex
      } else {
         set declarationEnd $parseIndex-1chars
	 set type [string tolower $keyword]
         [namespace current]::addChildNode $id $w $type $identifier $identifierStart $declarationEnd 0
      }

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
   }
   
   return $parseIndex
}

proc structCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of declaration  
# @comment of struct types defined by the struct modeling layer directive: 
# @comment Syntax:
# @comment    Structure_Type_Declaration ::=
# @comment       struct { Declaration_List } list_of_variable_identifiers ;
# @comment    
# @comment    Declaration_List ::=
# @comment       HDL_Variable_or_Net_Declaration { HDL_Variable_or_Net_Declaration }
# @comment    
# @comment    HDL_Variable_or_Net_Declaration ::=
# @comment       net_declaration
# @comment       | reg_declaration
# @comment       | integer_declaration
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
# 
   variable braces
   set wDirect $w
   set parseIndex $end

   set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\{}]

   if {$delimiter != "\{"} {
      return $end
   }
   set startOfStruct [$w index $parseIndex-1chars]
   set familyNodes {}
   set parseIndex [[namespace current]::findNextClosingBrace $w $parseIndex] 
   
   if {$parseIndex == "-1"} {
      return $end
   }
   
   set parseIndex ${parseIndex}+1chars
   while 1 {
      set identifierStart $parseIndex
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }
      # Highlight declared variable
      if { $caller == "highlight" } {
         $w tag add structType $identifierIndex $parseIndex
      } else {
         set declarationEnd $parseIndex-1chars
	 set type [string tolower $keyword]
	 lappend familyNodes [[namespace current]::addChildNode $id $w $type $identifier $identifierStart $declarationEnd 0]
      }

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
   }
   
   #if { $caller == "extract" } {
   #   if {([info exists braces(ids)]) && ($braces(ids) != {})} {
   #      set famId [expr [lindex $braces(ids) end] + 1]
   #   } else {
   #      set famId 0
   #   }
   #   lappend braces(ids) $famId
   #   set braces($famId,limits) "$startOfStruct $parseIndex"
   #   set braces($famId,familyNodes) $familyNodes
   #   return $startOfStruct
   #}
   return $parseIndex
}

proc declarationCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of declarations  
# @comment of named sequences, properties and endpoints: 
# @comment Syntax:
# @comment    PSL_Declaration ::=
# @comment       Sequence_Declaration
# @comment    
# @comment    Sequence_Declaration ::=
# @comment       sequence Name [ ( Formal_Parameter_List ) ] DEF_SYM Sequence ;
# @comment    
# @comment    Formal_Parameter_List ::=
# @comment       Formal_Parameter { ; Formal_Parameter }
# @comment    
# @comment    Formal_Parameter ::=
# @comment       sequence_ParamKind Name { , Name }
# @comment    
# @comment    sequence_ParamKind ::=
# @comment       const | boolean | sequence
# @comment    -----------------------------------------------------------------
# @comment    PSL_Declaration ::=
# @comment       Endpoint_Declaration
# @comment    
# @comment    Endpoint_Declaration ::=
# @comment       endpoint Name [ ( Formal_Parameter_List ) ] DEF_SYM Sequence ;
# @comment    
# @comment    Formal_Parameter_List ::=
# @comment       Formal_Parameter { ; Formal_Parameter }
# @comment    
# @comment    Formal_Parameter ::=
# @comment       sequence_ParamKind Name { , Name }
# @comment    
# @comment    sequence_ParamKind ::=
# @comment       const | boolean | sequence
# @comment    -----------------------------------------------------------------
# @comment    PSL_Declaration ::=
# @comment       Property_Declaration
# @comment    
# @comment    Property_Declaration ::=
# @comment       property Name [ ( Formal_Parameter_List ) ] DEF_SYM Property ;
# @comment    
# @comment    Formal_Parameter_List ::=
# @comment       Formal_Parameter { ; Formal_Parameter }
# @comment    
# @comment    Formal_Parameter ::=
# @comment       ParamKind Name { , Name }
# @comment    
# @comment    ParamKind ::=
# @comment       const | boolean | property | sequence
# @comment    -----------------------------------------------------------------
#
# @argument    id          window identifier
# @argument    lang        PSL
# @argument    w           window name
# @argument    caller      parsing job
# @argument    keyword     keyword recognized
# @argument    start       start position of keyword
# @argument    end         end position of keyword
# 
   variable parent
   set wDirect $w
   set parseIndex $end

   while 1 {
      set identifier [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex identifierIndex]
      if { $identifier == "" } {
         return $end
      }

      if {[string tolower $keyword] == "property"} {
	 # Add the new property to the group of properties under that parent
	 if {[info exists parent($id,properties)] && ([lsearch $parent($id,properties) [string trim $identifier]] != "-1")} {
	    set idx [lsearch $parent($id,properties) [string trim $identifier]]
	    set parent($id,properties) [lreplace $parent($id,properties) $idx [expr $idx + 1]]
	 }
	 lappend parent($id,properties) [string trim $identifier] $identifierIndex
      } 
      
      if { $caller == "highlight" } {
         $w tag add [string tolower $keyword] $identifierIndex $parseIndex
      } else {
         # Update symbols definitions
	 #[namespace parent]::declarationParserContext $id $w addLocal [string tolower $keyword] $identifier $start $parseIndex
         set declarationEnd [[namespace current]::findSemiColon $w $parseIndex]
	 if {$declarationEnd == "-1"} {
	    set declarationEnd $end
	 }
	 set type [string tolower $keyword]
         [namespace current]::addChildNode $id $w $type $identifier $start $declarationEnd 1 

	 return $declarationEnd
      }

      set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {\(}]
      switch -- $delimiter {
         (  {
            break
         }
         default  {
            return $parseIndex
         }
      }
   }

   set exitLoop 0

   while {!$exitLoop} {
      set param_type [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {boolean\W|const\W|sequence\W}]
      if { $param_type != "" } {
	 while (1) {
	    set param_name [[namespace current]::getAlphaNumericWord $id $w $wDirect $op parseIndex parameterIndex]
	    if { $param_name == "" } {
               return $end
            }
	    if { $caller == "highlight" } {
               $w tag add [string trim $param_type] $parameterIndex $parseIndex
            }
	    
	    set delimiter [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {,|\)|;}]
	    switch -- $delimiter {
               ,  {
                  continue
               }
	       ;  {
                  break
               }
	       )  {
	          set exitLoop 1
                  break
               }
               default  {
                  return $parseIndex 
               }
            }
	 }
      } else {
         break
      }
   }
   return $parseIndex
}

proc defaultCmd { id lang caller w keyword start end {op mark} } {
#
# @comment Handles syntax highlighting and code extraction of declaration  
# @comment of the default clock for a certain module using the default clock
# @comment keyword: 
# @comment Syntax:
# @comment    PSL_Declaration ::=
# @comment       Clock_Declaration
# @comment    
# @comment    Clock_Declaration ::=
# @comment       default clock DEF_SYM Boolean ;
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

   set clock [string trim [[namespace current]::getExactLexeme $id $w $wDirect $op parseIndex {clock\W}]]
   if { $clock != "clock" } {
      return $end
   }

   if { $caller == "extract" } {
      set declarationEnd [[namespace current]::findSemiColon $w $parseIndex]
      
      if {$declarationEnd == "-1"} {
         return $end
      }
      
      [namespace current]::addChildNode $id $w defClock "Clock" $start $declarationEnd 0

      return $parseIndex
   }   
}

proc findNextClosingBrace { w index } {
#
# @comment Searches and returns the next right brace that does not have a   
# @comment matching left brace.
#
# @argument    w           window name
# @argument    index       starting index to start the search from
#   
   set leftBrace 0
   while 1 {
      if [$w compare $index >= [$w index end]] { return -1 }
      set char [$w get $index]
      switch -- $char {
         "{" {
	    incr leftBrace
	 }
	 "}" {
	    if {$leftBrace == 0} {
	       return $index
	    } else {
	       incr leftBrace -1
	    }
	 }
      }
      set index [$w index ${index}+1chars]
   }
}

proc findSemiColon { w index {inComments 0} {comm {}} } {
#
# @comment Searches and returns index of the next semicolon   
#
# @argument    w           window name
# @argument    index       starting index to start the search from
#   
   set leftBrace 0
   set leftParen 0

   while 1 {
      if [$w compare $index >= [$w index end]] { return -1 }
      if {$inComments} {
         if {![regexp -nocase -- "${comm}( )+" [$w get "$index linestart" "$index lineend"] match]} {
	    set index [$w index [$w index "$index lineend"]+1chars]
	    return "-1"
	 } else {
	    set comment [$w get $index "$index lineend"]
	 }
      }
      set char [$w get $index]
       switch -- $char {
         "(" {
	    incr leftParen
	 }
	 ")" {
            incr leftParen -1
	 }
	 "{" {
	    incr leftBrace
	 }
	 "}" {
            incr leftBrace -1
	 }
	 ";" {
	    if {($leftBrace == 0) && ($leftParen == 0)} {
	       return $index
	    }
         }
      }
      set index [$w index ${index}+1chars]
   }
}

proc skipRange { w index } {
#
# @comment Skips a range enclosed between parenthesis and returns    
# @comment the index of the character following the range.
#
# @argument    w           window name
# @argument    index       starting index to start the search from
#   
   while 1 {
      if [$w compare $index >= [$w index end]] { return -1 }
      set char [$w get $index]
      switch -- $char {
         ")" {
	    return [$w index $index+1chars]
	 }
	 default {
            set index [$w index ${index}+1chars]
	    continue
	 }
      }     
   }
}

proc isDefined { id w property } {
#
# @comment Checks if the given property's identifier was previously defined    
# @comment in the file.
#
# @argument    id          window identifier
# @argument    w           window's name
# @argument    property    name of a defined property
#
# @result  Returns 0 if the property was nor previously defined
# @result  Returns 1 if the property was previously defined
#
   variable parent
   
   if {![info exists parent($id,properties)]} {
      return 0
   } 
   set idx [lsearch $parent($id,properties) [string trim $property]]
   if {$idx == "-1"} {
      return 0
   }
   
   if {[$w get [lindex $parent($id,properties) [expr $idx + 1]] "[lindex $parent($id,properties) [expr $idx + 1]] wordend"] == [string trim $property]} {
      return 1
   } else {
      return 0
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
   if { ($lexeme2 == "--") || ($lexeme2 == "//") } {

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
