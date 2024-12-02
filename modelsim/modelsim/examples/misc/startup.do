#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

# open all the windows
view *

if {$entity == "counter"} {

    # set up a clock on the CLK input
	force clk 1 50, 0 100 -r 100

    # list all the signals 
	add list *

} elseif {$entity == "test_adder_structural"} {

    # list all the top-level signals in hex
	add list -hex /*

}
