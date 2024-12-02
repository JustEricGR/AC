rem Copyright 1991-2009 Mentor Graphics Corporation

rem All Rights Reserved.

rem THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
rem MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

rem PLI Test Compilation and Execution Script for Microsoft Windows Platforms

rem NOTE: This script is intended to be run in a DOS shell.

rem NOTE: The environment variable MTI_HOME must be set to point to your
rem       modeltech installation directory before invoking this script.
rem       Example: set MTI_HOME=\users\me\modeltech

set PLATFORM=win32

rem Visual C/C++ compilation
cl -c -I%MTI_HOME%\include pli_test.c
link -dll -export:veriusertfs pli_test.obj %MTI_HOME%\win32\mtipli.lib

rm -rf work
%MTI_HOME%\%PLATFORM%\vlib work
%MTI_HOME%\%PLATFORM%\vlog prim.v dff.v top.v

%MTI_HOME%\%PLATFORM%\vsim -c -do vsim.do top -pli pli_test.dll
