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
onbreak {resume}
set PathSeparator .

# log signals in database
add wave -divider "Signals from MUX41 instance I0"
add wave .mux_tb.DUT.I0.*
add wave -divider "Register from MUX41 instance I1"
add wave .mux_tb.DUT.I1.y_l
add wave -divider "Nets from MUX21 instance I2"
add wave .mux_tb.DUT.I2.im1
add wave .mux_tb.DUT.I2.Sb
add wave -divider "Signals from MUX81 instance DUT"
add wave .mux_tb.DUT.*

# configure wave window
wave zoomfull
