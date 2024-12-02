#
# Copyright 1991-2009 Mentor Graphics Corporation
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE
# PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO
# LICENSE TERMS.
#
# Simple Verilog PLI Example - Setup & simulation Tcl script
#
onbreak {resume}
onerror {quit -f}
run -all
simstats
quit -f
