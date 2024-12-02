#
# Load up the options database from the .kderc file
# 
proc _kdeSetup {} {
	global env
	if {[info exists env(HOME)] && [info exists env(KDEDIR)]} {
		set kderc [file join $env(HOME) .kderc] 
		if {[file exists $kderc]} {
			set sections [list General WM]
			set props [list background foreground \
						   selectBackground selectForeground \
						   windowBackground windowForeground \
						   activeBackground activeForeground \
						   inactiveBackground inactiveForeground \
						   fixed StandardFont menuFont font]
			foreach section $sections {
				foreach prop $props {
					set value [GetPrivateProfileString $section $prop "" $kderc]
					if {$value != ""} {
						set vlist [split $value ,]
						switch -glob -- $prop {
							background {
								set color [_kdeDecodeColor $value]
								if {$color ne ""} {
									option add *$prop $color widgetDefault
									option add *Background $color widgetDefault
								}
							}
							foreground {
								set color [_kdeDecodeColor $value]
								if {$color ne ""} {
									option add *$prop $color widgetDefault
									option add *Foreground $color widgetDefault
								}
							}
							selectBackground {
								set color [_kdeDecodeColor $value]
								if {$color ne ""} {
									option add *$prop $color widgetDefault
									option add *ActiveBackground $color widgetDefault
								}
							}
							selectForeground {
								set color [_kdeDecodeColor $value]
								if {$color ne ""} {
									option add *$prop $color widgetDefault
									option add *ActiveForeground $color widgetDefault
								}
							}
							font {
								set font [_kdeDecodeFont $vlist]
								option add *font $font widgetDefault
								option add *Font $font widgetDefault
							}
							menuFont {
								set font [_kdeDecodeFont $vlist]
								set PrefDefault(menuFont) $font
								option add *menuFont $font widgetDefault
								option add *MenuFont $font widgetDefault
							}
							fixed {
								set font [_kdeDecodeFont $vlist]
								set PrefDefault(fixedFont) $font
								option add *fixedFont $font widgetDefault
								option add *FixedFont $font widgetDefault
							}
							StandardFont {
								set font [_kdeDecodeFont $vlist]
								set PrefDefault(textFont) $font
								set PrefDefault(footerFont) $font
								option add *$prop $font widgetDefault
							}
							windowBackground {
								set PrefDefault(input1_bg) $color
								option add *textBackground $color widgetDefault
							}
							windowForeground {
								set PrefDefault(input1_fg) $color
								option add *textForeground $color widgetDefault
							}
							*ground {
								set color [_kdeDecodeColor $value]
								if {$color ne ""} {
									option add *$prop $color widgetDefault
								}
							}
							default {
							}
						}
					}
				}
			}
		}
	}
}

proc _kdeDecodeColor {val} {
	if {[regexp {(\d+),(\d+),(\d+)} $val dummy r g b]} {
		set color [eval format "#%02x%02x%02x" $r $g $b]
	} else {
		set color ""
	}
	return $color
}

proc _kdeDecodeFont {fl} {
	set fname [lindex $fl 0]
	set size  [lindex $fl 1]
	set unk1  [lindex $fl 2]
	set unk2  [lindex $fl 3]
	set wght  [lindex $fl 4]
	set slnt  [lindex $fl 5]
	if {$wght > 50} {
		set wght bold
	} else {
		set wght normal
	}
	if {$slnt} {
		set slnt italic
	} else {
		set slnt roman
	}
	return [list $fname $size $wght $slnt]
}
