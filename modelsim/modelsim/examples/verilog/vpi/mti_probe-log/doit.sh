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
# VPI routine for logging of signals from within the HDL code
#
# Usage:     Help/usage ..................... doit.sh
#            Run VPI example ................ doit.sh demo
#            Clean directory ................ doit.sh clean
#
if [ "$1" = "clean" ] ; then
    rm -f transcript vsim.wlf core *.log workingExclude.cov
    rm -f *.dll *.exp *.lib *.obj *.o *.sl
    rm -f vsim_stacktrace.vstf
    rm -rf work
    exit 0
fi

if [ "$1" = "demo" ] ; then
    echo ""
    echo "### NOTE: Determining OS and compiling C code ..."
    echo ""
    if [ -z "$MTI_HOME" ] ; then
        echo "ERROR: environment variable MTI_HOME is not set"
        exit 0
    fi
    platform=`$MTI_HOME/vco`
    rm -f *.o *.dll
    if [ "$platform" = "linux" ] ; then
        CC="gcc -g -c -I$MTI_HOME/include"
        LD="/usr/bin/ld -shared -E -o"
    elif [ "$platform" = "linux_x86_64" ] ; then
        CC="$MTI_HOME/gcc-3.2.3-rhe21/bin/gcc -g -m32 -fPIC -I$MTI_HOME/include"
        LD="$MTI_HOME/gcc-3.2.3-rhe21/bin/gcc -m32 -shared -fPIC -o"
    elif [ "$platform" = "sunos5" ] ; then
        CC="gcc -g -c -I$MTI_HOME/include"
        LD="/usr/ccs/bin/ld -G -B symbolic -o"
    elif [ "$platform" = "hp700" ] ; then
        CC="/opt/ansic/bin/cc -g -c +DAportable -Ae -z +z -I$MTI_HOME/include"
        LD="/usr/ccs/bin/ld -b -o"
    elif [ "$platform" = "win32" ] ; then
        CC="cl -c -I$MTI_HOME/include"
        LD="link -dll $MTI_HOME/win32/mtipli.lib"
    else
        echo "Script not configured for $platform, see User's manual."
        exit 0
    fi
    $CC mti_probe.c
    $CC vpi_user.c
    if [ "$platform" = "win32" ] ; then
        $LD -export:vlog_startup_routines vpi_user.obj mti_probe.obj
    else
        $LD vpi_user.dll vpi_user.o mti_probe.o
    fi
    echo ""
    echo "### NOTE: Creating library and compiling HDL code ..."
    echo ""
    rm -rf work
    vlib work
    vlog mux21.v mux41.v mux81.v mux_tb.v
    echo ""
    echo "### NOTE: Starting simulator and running DEMO ..."
    echo ""
    vsim -c -pli ./vpi_user.dll mux_tb \
        -do "set PathSeparator .; run -all; quit -f"
    vsim -view vsim.wlf -do sim.do
    exit 0
fi

echo ""
echo "### Help/Usage ..................... doit.sh"
echo "### Run VPI example ................ doit.sh demo"
echo "### Clean directory ................ doit.sh clean"
echo ""
