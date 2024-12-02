#!/bin/sh
#
# Copyright 1991-2009 Mentor Graphics Corporation
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE
# PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO
# LICENSE TERMS.
#
# Simple Verilog PLI Example - Simulation shell script
#
# Usage:     Help/usage ..................... doit.sh
#            Run Fibonacci example .......... doit.sh demo
#            Clean directory ................ doit.sh clean
#
if [ "$1" = "clean" ] ; then
    rm -f transcript *.wlf core* *.log workingExclude.cov
    rm -f *.dll *.exp *.lib *.obj *.sl *.o *.so
    rm -f vsim_stacktrace.vstf *.h
    rm -rf work
    exit 0
fi

if [ "$1" = "demo" ] ; then
    rm -rf work
    vlib work
    if [ -z "$MTI_HOME" ] ; then
        echo "ERROR: Environment variable MTI_HOME is not set"
        exit 0
    fi
    platform=`$MTI_HOME/vco`
    rm -f *.o *.dll *.so
    if [ "$platform" = "linux" ] ; then
        CC="gcc -g -c -I$MTI_HOME/include"
        LD="/usr/bin/ld -shared -E -o"
    elif [ "$platform" = "sunos5" ] ; then
        CC="gcc -g -c -I$MTI_HOME/include"
        LD="/usr/ccs/bin/ld -G -B symbolic -o"
    elif [ "$platform" = "win32" ] ; then
        CC="$MTI_HOME/gcc-3.2.3-mingw32/bin/gcc -g -c -I$MTI_HOME/include"
        LD="$MTI_HOME/gcc-3.2.3-mingw32/bin/gcc -shared -L$MTI_HOME/win32 -lmtipli -o"
    else
        echo "Script not configured for $platform, see User's manual."
        exit 0
    fi
    echo ""
    echo "### NOTE: Running Fibonacci Sequence Example ..."
    echo ""
    $CC fibonacci_pli.c
    $LD fibonacci.dll fibonacci_pli.o
    vlog -sv fibonacci.v
    vsim -c -vopt TEST -pli ./fibonacci.dll -do sim.do
    exit 0
fi

echo ""
echo "### Help/Usage ..................... doit.sh"
echo "### Run Fibonacci example .......... doit.sh demo"
echo "### Clean directory ................ doit.sh clean"
echo ""
