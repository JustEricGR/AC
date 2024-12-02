proc mtiwidgets::3DborderColor {window {which both} {option -background}} {
	# which is one of flat, light, dark, both, all
	# stressed = TkpCmapStressed(tkwin, borderPtr->colormap);
	set stressed [winfo colormapfull $window]
	#define MAX_INTENSITY 65535
	set MAX_INTENSITY 65535
	#
	# /*
	#  * First, handle the case of a color display with lots of colors.
	#  * The shadow colors get computed using whichever formula results
	#  * in the greatest change in color:
	#  * 1. Lighter shadow is half-way to white, darker shadow is half
	#  *    way to dark.
	#  * 2. Lighter shadow is 40% brighter than background, darker shadow
	#  *    is 40% darker than background.
	#  */
	#
	# if (!stressed && (Tk_Depth(tkwin) >= 6)) 
	if {!$stressed && [winfo depth $window] >= 6} {
		#/*
		# * This is a color display with lots of colors.  For the dark
		# * shadow, cut 40% from each of the background color components.
		# * But if the background is already very dark, make the
		# * dark color a little lighter than the background by increasing
		# * each color component 1/4th of the way to MAX_INTENSITY.
		# *
		# * For the light shadow, boost each component by 40% or half-way
		# * to white, whichever is greater (the first approach works
		# * better for unsaturated colors, the second for saturated ones).
		# * But if the background is already very bright, instead choose a
		# * slightly darker color for the light shadow by reducing each
		# * color component by 10%.
		# *
		# * Compute the colors using integers, not using lightColor.red
		# * etc.: these are shorts and may have problems with integer
		# * overflow.
		# */
		#
		#/*
		# * Compute the dark shadow color
		# */
		#
		# r = (int) borderPtr->bgColorPtr->red;
		# g = (int) borderPtr->bgColorPtr->green;
		# b = (int) borderPtr->bgColorPtr->blue;
		scan [winfo rgb $window [$window cget $option]] "%d %d %d" r g b
		set flat [format "#%04x%04x%04x" $r $g $b]
		#
		# if (r*0.5*r + g*1.0*g + b*0.28*b < MAX_INTENSITY*0.05*MAX_INTENSITY) 
		if {($r * 0.5 * $r + $g * 1.0 * $g + $b * 0.28 * $b) < ($MAX_INTENSITY * 0.05 * $MAX_INTENSITY)} {
			# darkColor.red = (MAX_INTENSITY + 3*r)/4;
			set darkRed [expr {($MAX_INTENSITY + 3 * $r)/4}]
			# darkColor.green = (MAX_INTENSITY + 3*g)/4;
			set darkGreen [expr {($MAX_INTENSITY + 3 * $g)/4}]
			# darkColor.blue = (MAX_INTENSITY + 3*b)/4;
			set darkBlue [expr {($MAX_INTENSITY + 3 * $b)/4}]
		} else {
			# darkColor.red = (60 * r)/100;
			set darkRed [expr {(60 * $r)/100}]
			# darkColor.green = (60 * g)/100;
			set darkGreen [expr {(60 * $g)/100}]
			# darkColor.blue = (60 * b)/100;
			set darkBlue [expr {(60 * $b)/100}]
		}
		#
		#/*
		# * Allocate the dark shadow color and its GC
		# */
		#
		# borderPtr->darkColorPtr = Tk_GetColorByValue(tkwin, &darkColor);
		# gcValues.foreground = borderPtr->darkColorPtr->pixel;
		# borderPtr->darkGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
		set dark [format "#%04x%04x%04x" $darkRed $darkGreen $darkBlue]
		#
		#/*
		# * Compute the light shadow color
		# */
		#
		# if (g > MAX_INTENSITY*0.95) 
		if {$g > ($MAX_INTENSITY * 0.95)} {
			#	    lightColor.red = (90 * r)/100;
			set lightRed [expr {(90 * $r)/100}]
			#	    lightColor.green = (90 * g)/100;
			set lightGreen [expr {(90 * $g)/100}]
			#	    lightColor.blue = (90 * b)/100;
			set lightBlue [expr {(90 * $b)/100}]
		} else {
			# tmp1 = (14 * r)/10;
			set tmp1 [expr {(14 * $r)/10}]
			# if (tmp1 > MAX_INTENSITY)
			if {$tmp1 > $MAX_INTENSITY} {
				# tmp1 = MAX_INTENSITY;
				set tmp1 $MAX_INTENSITY
			}
			# tmp2 = (MAX_INTENSITY + r)/2;
			set tmp2 [expr {($MAX_INTENSITY + $r)/2}]
			# lightColor.red = (tmp1 > tmp2) ? tmp1 : tmp2;
			set lightRed [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
			# tmp1 = (14 * g)/10;
			set tmp1 [expr {(14 * $g)/10}]
			# if (tmp1 > MAX_INTENSITY) 
			if {$tmp1 > $MAX_INTENSITY} {
				# tmp1 = MAX_INTENSITY;
				set tmp1 $MAX_INTENSITY
			}
			# tmp2 = (MAX_INTENSITY + g)/2;
			set tmp2 [expr {($MAX_INTENSITY + $g)/2}]
			# lightColor.green = (tmp1 > tmp2) ? tmp1 : tmp2;
			set lightGreen [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
			# tmp1 = (14 * b)/10;
			set tmp1 [expr {(14 * $b)/10}]
			# if (tmp1 > MAX_INTENSITY)
			if {$tmp1 > $MAX_INTENSITY} {
				# tmp1 = MAX_INTENSITY;
				set tmp1 $MAX_INTENSITY
			}
			# tmp2 = (MAX_INTENSITY + b)/2;
			set tmp2 [expr {($MAX_INTENSITY + $b)/2}]
			# lightColor.blue = (tmp1 > tmp2) ? tmp1 : tmp2;
			set lightBlue [expr {($tmp1 > $tmp2) ? $tmp1 : $tmp2}]
		}
		#	
		#/*
		# * Allocate the light shadow color and its GC
		# */
		#
		# borderPtr->lightColorPtr = Tk_GetColorByValue(tkwin, &lightColor);
		# gcValues.foreground = borderPtr->lightColorPtr->pixel;
		# borderPtr->lightGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
		set light [format "#%04x%04x%04x" $lightRed $lightGreen $lightBlue]
		# return;
	} elseif {[winfo depth $window] > 2} {
		set flat [$window cget $option]
		set dark gray50
		set light gray90
	} else {
		set flat [$window cget $option]
		set dark black
		set light white
	}
	switch $which {
		flat  { return $flat }
		light { return $light }
		dark  { return $dark }
		both  { return [list $light $dark] }
		all   { return [list $light $dark $flat] }
	}
	return -code error "Unrecognized option: $which"
	#
	# if (borderPtr->shadow == None) {
	#	borderPtr->shadow = Tk_GetBitmap((Tcl_Interp *) NULL, tkwin, Tk_GetUid("gray50"));
	#	if (borderPtr->shadow == None) {
	#	    panic("TkpGetShadows couldn't allocate bitmap for border");
	#	}
	# }
	# if (borderPtr->visual->map_entries > 2) {
	#	/*
	#	 * This isn't a monochrome display, but the colormap either
	#	 * ran out of entries or didn't have very many to begin with.
	#	 * Generate the light shadows with a white stipple and the
	#	 * dark shadows with a black stipple.
	#	 */
	#
	#   gcValues.foreground = borderPtr->bgColorPtr->pixel;
	#   gcValues.background = BlackPixelOfScreen(borderPtr->screen);
	#   gcValues.stipple = borderPtr->shadow;
	#   gcValues.fill_style = FillOpaqueStippled;
	#   borderPtr->darkGC = Tk_GetGC(tkwin,	GCForeground|GCBackground|GCStipple|GCFillStyle, &gcValues);
	#   gcValues.background = WhitePixelOfScreen(borderPtr->screen);
	#   borderPtr->lightGC = Tk_GetGC(tkwin, GCForeground|GCBackground|GCStipple|GCFillStyle, &gcValues);
	#   return;
	# }
	#
	# /*
	#  * This is just a measly monochrome display, hardly even worth its
	#  * existence on this earth.  Make one shadow a 50% stipple and the
	#  * other the opposite of the background.
	#  */
	#
	# gcValues.foreground = WhitePixelOfScreen(borderPtr->screen);
	# gcValues.background = BlackPixelOfScreen(borderPtr->screen);
	# gcValues.stipple = borderPtr->shadow;
	# gcValues.fill_style = FillOpaqueStippled;
	# borderPtr->lightGC = Tk_GetGC(tkwin, GCForeground|GCBackground|GCStipple|GCFillStyle, &gcValues);
	# if (borderPtr->bgColorPtr->pixel == WhitePixelOfScreen(borderPtr->screen)) {
	#   gcValues.foreground = BlackPixelOfScreen(borderPtr->screen);
	#   borderPtr->darkGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
	# } else {
	#   borderPtr->darkGC = borderPtr->lightGC;
	#   borderPtr->lightGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
	# }
}
