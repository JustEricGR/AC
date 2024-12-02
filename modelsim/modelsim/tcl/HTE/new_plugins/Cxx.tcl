#HTEParser#cxx#LexCxx#C/C++ sources#Cxx Plugin#c|h|cpp|hpp#
# =============================================================================
#
# (C) Mentor Graphics Corporation 2003-2004 All Rights Reserved
#
# =============================================================================

## Complementary script defining callbacks
## for Cxx plugin
array set codeTreeBlockDefinition {
   class                      {"Class"                      CppClass}
   comment                    {"Comment"                    {}}
   function                   {"Function"                   CppFunctionBody}
   method                     {"Method"                     CppFunctionHdr}
   namespace                  {"Namespace"                  CppNamespace}
}

# By default, set all block types to be visible 
if [info exists HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)] {
} else {
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) \
      {class function method namespace}
   set HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks) [lsort $HTE::Configuration(LexParser.[namespace tail [namespace current]],Browser.ShowBlocks)]
}

set HighlightRE(operation) {[-+:%~\[\]*&<>=!|^]}
set HighlightRE(codeBlockBound) {\(|\)|{|}}
set HighlightRE(lineContinuation) {(\\)$}

set prsCallbacks(preproc) [namespace current]::preprocCB
set hlCallbacks(preproc) [namespace current]::preprocCB

set linearDebug 0
array set linearParserState {}
set insideBlock 0
set startInComment 0
set prot -1
set prevBlock 1.0

proc preprocCB { id language job textw kw start index } {

   # if ther is no line continuation, just return $index
   if { [$textw get "$index -1c"]!="\\" } {
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

proc parseComment { id w wDirect start stopIndex op } {
	# @comment	Parses comment and returns index of character after
	# @comment	the comment to continue scanning. As a side effect 
	# @comment	adds tags or marks for comment block according to 
	# @comment	request $op.
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
   if       { $lexeme2 == "//" } {

#    puts stdout "  in parse"
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

#         if { $caller == "parserVA" } {
            # For VA parser it is sufficient that it is started
            set endComment $stopIndex
#         } else {
            # For other cases - ignore start of comment
#            set endComment [$wDirect index "$start + 2 chars"]
#            return $endComment
#         }
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
#	then return an appropriate result
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
   
#    puts stdout "LINEAR INIT"
   variable linearParserState
   variable prevBlock
#   variable startInComment


    variable prot
    set prot -1
   set linearParserState($id,quote)          ""
#   set linearParserState($id,squareBrace)    {}
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
   # @c   Parses C++ identifier and returns list of name qualifiers (can be
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


#    puts stdout "PFQN> ($start ($type ($name"
#   variable linearParserState

   if { $name == {} } {
      return {}
   }

   # Push block definition into appropriate stack
#   blockStack$id push [list $type $linearParserState($id,curlyBrace)]
#   ${type}Stack$id push $name
#  putLog "Push fully qualified proc name: \"$name\". Stack size: [procStack$id size]/[blockStack$id size]"

   # Make last element of resulting list
   # Only last element is real code block (code tree node)
   # so it has non-empty start sub-element
   set qualifiersList [list $type $name [namespace tail $name] $start]
   set part $name
   while 1 {
      # Get next base part of name
#      puts stdout "BEFORE ADDING> $part"
      set part [namespace qualifiers $part]
#      puts stdout "BEFORE ADDING> $part"
      # And insert it as first element of list
      if { $part == {} } {
         # All is done
#         set part "::"
#         set qualifiersList [linsert $qualifiersList 0 namespace $part $part {}]
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
#      puts stdout "ADD IN LIST> [namespace tail $part] $ctype"
      set qualifiersList [linsert $qualifiersList 0 $ctype $part [namespace tail $part] {}]
   }

   return $qualifiersList
}

proc makeFullyQualifiedTree { id w qualifiersList } {
   # @c   Gets as parameter list of nodes definitions created by
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
	
#    puts "$type $qualifier $qualifierLabel $start"
	set name $qualifierLabel
        set blockId [[namespace parent]::parserContext $id getId $type $name]
	#puts stdout "INFO> Id:$blockId Start:$start Type:$type"
    	if { $start == "" } {
	    set style Dummy
	} else {
	    set style Cxx
	}
	set iconName $HTE::Configuration(LexParser.$language,icon.$type)
	set blockId [[namespace parent]::parserContext $id register $type $qualifierLabel $style]
        foreach { operation parentId beforeNode } [[namespace parent]::parserContext $id getTcl $parentId] {}
#	puts stdout "ADD IN BROWSER> $name $type"
        [namespace parent]::BrowserNode              \
    	    $id                  \
            $operation           \
            $w                   \
            $blockId             \
            $start		 \
            ""                   \
            $parentId            \
            $beforeNode          \
            $iconName
        set parentId $blockId
    }
#    puts stdout "PUSH $name $start"
#    puts stdout "----"
    [namespace parent]::parserContext $id push $blockId
}

proc getRule { keyWordVar } {
   # @c Now quite simple function
   # @a keyWordVar: name of the variable
   # @r value of variable passed

#	puts stdout "getRule"
	
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
#	puts stdout "	LATEST getFName> $prevBlock $blockOpen"
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
#    puts stdout "fixme $start $prevBlock"
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
#	puts stdout "GETC $prevBlock $ret"
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
#    puts stdout "parseNode $str $prot"
    if { $prot == -1 } {
        if { [regexp {\)\s*\;\s*$} $str] } {
		set prot 1
        } else {
		set prot 0
        }
    }
#   puts stdout "LATEST AAAAAA> $str"
    if { [regexp {[\{\}]} $str] } {
	return ""
    }
    set temp $str
   set st [string first "(" $temp]
#   puts stdout "start $st"
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
#   	puts stdout "finish $fn"
   	if { $fn == -1 } {
# we have an error in a string
			return ""
	 }
# we have a decl between open and according close braces
	set temp "[string range $temp 0 $st]$[string range $temp $fn end]"
#	puts stdout "SUb> $temp"
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
  	
#    puts stdout "COMPLETE :)"
#    puts stdout "[[namespace parent]::parserContext $id getBlockList]"
#    while ![[namespace parent]::parserContext $id checkEmpty] {
#	set blockId [[namespace parent]::parserContext $id pop]
#        [namespace parent]::BrowserCompleteNode $id $w $blockId 10.10
#    }
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
   	# @comment So called "linear" parser callback.
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

#   puts stdout "linear $start $end $limit"
    if { $start == 1.0 } {
       [namespace parent [namespace parent]]::TCOM::trailer "[namespace current]::linearCompletion $id $w"
    }
 variable linearDebug

   variable linearParserState
   variable insideBlock
   variable startInComment
   variable prot
#   variable fName
    variable prevBlock
    if { [lsearch -exact [$w mark names] prevBlock] != -1 } {
    	set prevBlock [$w index prevBlock]
#	puts stdout "	LATEST NPB begin  $prevBlock"
    }

#    set comm [insideComment $w $start]
#    set prevBlock [lindex $comm 2]
#    if { $prevBlock == "" } {
#	set prevBlock $start
#    }
       
   
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
#   set insideBlock 0
#   set fName 0

   set wordDefinition "\\S+"
   #set wordDefinition ".*\{.*\}.*"
   # set delimiterDefinition {[][\\"#\s\$\{\}\;]}
   set delimiterDefinition {[\{\}\#\"\\\';]}

   variable matchedCount

   set lineContinuation 0

   while 1 {

#	puts stdout "INDICES <$start><$scanIndex><$scanLimitIndex>"

      if { [$wDirect compare $scanIndex >= $scanLimitIndex] } {
         set linearParserState($id,lastScanIndex) $scanIndex
	 $w mark set prevBlock $prevBlock

	 set scanIndex [$w index $scanIndex]
#	  puts stdout "return $scanIndex"
        return $scanIndex
      }

      set lexemeIndex [$wDirect search -elide -count [namespace current]::matchedCount -regexp $wordDefinition $scanIndex $scanStopIndex ]

#    puts stdout "$lexemeIndex"
    
      if { $lexemeIndex == {} } {
        $w mark set prevBlock $prevBlock
	
	set end [$w index $end]
#	puts stdout "return $end"
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
        
    #  puts stdout "--- $lexemeStartSymbol at $lexemeIndex"

    set ok [weAreIn $w $lexemeIndex]
    
    
    set insideBlock [[namespace parent]::parserContext $id checkEmpty]


      switch -exact -- $lexemeStartSymbol {
      
      
        \) {
	
	     if { $ok == "multi" } {
		set startInComment 1
		set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
		set startInComment 0
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
	    } elseif { $ok == "single" } {
		set nextLexemeIndex "$lexemeIndex lineend"
	    } elseif { $linearParserState($id,quote) != "" && $lexemeStartSymbol != "\"" } {
    	    	set nextLexemeIndex [$w search -elide -regexp {[\"\\]} "$lexemeIndex +1 char" $end]
		if { $nextLexemeIndex == "" } {
		    set nextLexemeIndex $end
		}
	    } elseif { $insideBlock } {
	#	puts stdout "GOOD $lexemeIndex"
	#	set linearParserState($id,blockStart) 1
	    }    
	    set nextLexemeIndex "$lexemeIndex +1 char"
	}
      
        \\ {
		set nextLexemeIndex [$wDirect index "$lexemeIndex +2 char"]
	}

         #     {
	     if { $ok == "multi" } {
		set startInComment 1
		set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
		set startInComment 0
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
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
#	        puts stdout "	LATEST preproc-> prevBlock=$prevBlock"
	    }}
         }

         "{"   {
#	    puts stdout "LATEST \{$lexemeIndex $linearParserState($id,curlyBrace), $linearParserState($id,quote), $ok"
	     if { $ok == "multi" } {
		set startInComment 1
		set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
		set startInComment 0
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
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
#			puts stdout "LEVELS start at $lexemeIndex with $insideBlock and $type ($bid)"
#			puts stdout "LEVELS \{ $linearParserState($id,curlyBrace) $linearParserState($id,treeLevel)"
			if { $insideBlock || $type == "class" || $type == "namespace" } {
		    	    # set linearParserState($id,firstWord) 1
			    set prot -1
			    set fname [getFName $wDirect $lexemeIndex]
			    set cdef [getCName $wDirect $lexemeIndex]
			    set prot -1
			    set ctype [lindex $cdef 1]
			    set cname [lindex $cdef 0]
			#    puts stdout "LATEST MyLex >>>($cname)($fname) at $lexemeIndex pb $prevBlock"
			    if { $cname != "" } {
				set name $cname
				set type $ctype
				set blockstart [getCStart $w $lexemeIndex]
				set prevBlock "$lexemeIndex +1 char"
#				puts stdout "	LATEST classopen = $prevBlock"
				incr linearParserState($id,curlyBrace)
				incr linearParserState($id,treeLevel)
			#	puts stdout "classopen-> prevBlock=$prevBlock"
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
				# set fstart [getFStart $wDirect $lexemeIndex]
				#puts "MA $name $type"
				set ql [parseFullyQualifiedName $id $blockstart $type $name]
				#foreach { a b c d } $ql {
				#    puts stdout "Q> $a, $b, $c, $d"
				#}
			#	puts stdout ">>$linearParserState($id,curlyBrace)"
				makeFullyQualifiedTree $id $w $ql
		    	    } 
			} else {
			    incr linearParserState($id,curlyBrace)
			}
			}
			  
         }

         "}"   {
#	    puts stdout "LATEST \}$lexemeIndex $linearParserState($id,curlyBrace), $linearParserState($id,quote), $ok"
	     if { $ok == "multi" } {
		set startInComment 1
		set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
		set startInComment 0
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
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
#		puts stdout "LEVELS \} $linearParserState($id,curlyBrace) $linearParserState($id,treeLevel)"
		if { $linearParserState($id,curlyBrace) == $linearParserState($id,treeLevel) && !$insideBlock } { 
		incr linearParserState($id,treeLevel) -1
	#	puts stdout "closeblock at $lexemeIndex"
		##############################
		$w mark unset declaration
		set blockId [[namespace parent]::parserContext $id pop]
		if { $blockId != {} } {
		    [namespace parent]::BrowserCompleteNode $id $w $blockId "$lexemeIndex +1 char"
		} else {
#		    puts stdout "ERROR"
		}
		##############################
		set prevBlock "$lexemeIndex +2 char"
#		puts stdout "	LATEST FINISH pb = $prevBlock"
	#	puts stdout "---"
	    } else {
		set prevBlock "$lexemeIndex +2 char"
#		puts stdout "	LATEST OTHER FINISH pb = $prevBlock"
	    }
	    set nextLexemeIndex [$wDirect index "$lexemeIndex +1 char"]
	}    
         }
	 
	         \; {
		# puts stdout "\; at $lexemeIndex, $ok"
	if { $ok == "multi" } {
		set startInComment 1
		set nextLexemeIndex [parseComment $id $w $w $lexemeIndex $end mark]
	#	puts stdout ">>> $nextLexemeIndex"
		set startInComment 0
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
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
	#	puts stdout "$insideBlock $type at $lexemeIndex"
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
			# puts stdout "Found vars \"[lindex $temp 0]\""
			set varList [parseVarList [lindex $temp 0]]
			# Now we have a vars start at $prevBlock end at $lexemeIndex and names in $varList
			#puts stdout ">>> <$varList> at $prevBlock - $lexemeIndex"
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
	#	    puts stdout "$linearParserState($id,curlyBrace) $linearParserState($id,treeLevel) at $lexemeIndex"
		}
		# puts stdout "($temp)($str) State: Stack_$insideBlock Braces_$linearParserState($id,curlyBrace)"
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
		#set prevBlock $nextLexemeIndex
	#	puts stdout "comment-> $lexemeIndex - $nextLexemeIndex"
	    } elseif { $ok == "single" } {
    		set nextLexemeIndex "$lexemeIndex lineend"
	    } else {

                  set nextLexemeIndex [$wDirect index "$lexemeIndex +1 char"]

                  set quote $linearParserState($id,quote)
                  if { $quote == "" } {
                     set quote $lexemeIndex
		    # puts stdout "OPEN QUOTE $lexemeIndex"
                  } else {
                     set quote ""
		    # puts stdout "CLOSE QUOTE $lexemeIndex"
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
		     # puts stdout "KWFOUND> <$lexemeIndex> <$nextLexemeIndex>"
		     # puts stdout "KWFOUND> $lexeme"

		    #if { [regexp {typedef} $lexeme]} {
	#		$w mark set "typedef" $lexemeIndex
	#		# parseTypedef $w $lexemeIndex
	#	    }
		    
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
      
#      puts stdout "$lexeme"

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

#	puts stdout "INDEX <$nextLexemeIndex>"
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

