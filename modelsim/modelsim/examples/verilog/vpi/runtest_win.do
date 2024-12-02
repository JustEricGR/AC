#Copyright 1991-2009 Mentor Graphics Corporation
#
#All Rights Reserved.
#
#THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
#MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

# VPI Test Compilation and Execution Script for Microsoft Windows Platforms

# NOTE: The environment variable MTI_HOME must be set to point to your
#       modeltech installation directory before invoking ModelSim.

# NOTE: This script is intended to be run from a ModelSim command line.
#       Example: ModelSim> do runtest_win.do

# Visual C/C++ compilation
catch {exec cl -c -I$env(MTI_HOME)/include vpi_test.c} msg
echo $msg
exec link -dll -export:vlog_startup_routines vpi_test.obj $env(MTI_HOME)/win32/mtipli.lib

exec rm -rf work
vlib work
vlog prim.v dff.v top.v

vsim -do "run -all" top -pli vpi_test.dll
