#! /usr/local/bin/perl
# (c) 2005 Mentor Graphics Corporation.                            
#     All rights reserved.  
#                                                                       
# THIS SOFTWARE AND (ON-LINE) DOCUMENTATION CONTAIN CONFIDENTIAL        
# INFORMATION AND TRADE SECRETS OF Mentor Graphics Corporation.  USE,   
# DISCLOSURE, OR REPRODUCTION IS PROHIBITED WITHOUT THE PRIOR EXPRESS   
# WRITTEN PERMISSION OF Mentor Graphics Corporation.                


use strict;
use warnings;
use Env;

use FindBin;
use lib $FindBin::Bin;

use mtifc_parse_db;

my $prog = $0;
$prog =~ s/\.pl$//;
$prog =~ s/.*\///;

sub print_usage {
    print "\n";
    print "$prog: \n";
    print "       Utility to parse an fcover report and provide access functions\n";
    print "       to the entries in the fcover report via perl functions\n";
    print "\n";
    print "Usage: $prog [-db dbfile] [-db_list db_file_list]\n";
    print "\n";
    print "  e.g. $prog -db mtifc_fcov.xml\n";
    print "  e.g. $prog -db_list fcover.db_list\n";
    print "\n";
    print "Note: The db files must be XML files created by the ";
    print "      'fcover -xml' command. ";
    print "      EXAMPLE:";
    print "          fcover report -r / -directive -cvg -xml -output mtifc_fcov.xml";
    print "      For additional information on using the 'fcover report' command,";
    print "      please consult the QuestaSim user's manual ";
    print "      (i.e. fcover report , CommandReference).";
    print "\n";
} # sub print_usage


############################################################
##    globals
############################################################

my $dbfile;
my $is_dbfile;
my $dblistfile;

############################################################
##    Function: mtifc_parse_command_line
##          in:  none
##         out:  nothing - parse the command line, set up variables
##
## Description: parse the command line and set up variables      
############################################################

sub mtifc_parse_command_line {
    
    my $argc = $#ARGV;
    my $option = shift @ARGV;
    while ($option) {
		if ($option eq "-db") {
			$option = shift @ARGV;
			$dbfile = $option;
			$is_dbfile = 1;
		} elsif ($option eq "-db_list") {
			$option = shift @ARGV;
			$dblistfile = $option;
		} elsif ($option eq "-debug") {
			mtifc_parse_db->mtifc_debug_turn_on();
		} else {
			print "Error: unrecognized option: $option\n";
			print_usage();
			exit;
		}
		$option = shift @ARGV;
    } # while
} # sub mtifc_parse_command_line

############################################################
##
## GENRAL PURPOSE UTILITY FUNCTIONS
##
############################################################

############################################################
##    Function: mtifc_get_lower_range_bound
##          in:  bin rhs range value
##         out:  the lower range bound
##
## Note: RHS range values have the format of 
##       a number followed by a colon followed by a number. 
##       $RANGE example values:
##          1:2
##			300:302
##
## When the "bin rhs kind" is $RANGE:
##       this routine returns the part of the 
##       $bin_rhs_range_value string that
##       lies to the LEFT of the colon.
## When the "bin rhs kind" is NOT $RANGE:
##       this routine just returns the 
##       $bin_rhs_range_value string.
##
## Description: given a bin rhs range value 
##              return the lower range bound
############################################################

sub mtifc_get_lower_range_bound {
    my ($db, $bin_rhs_range_value) = @_;
	my $return_value;

	$return_value = $bin_rhs_range_value;
	if ($db->mtifc_get_bin_rhs_kind($bin_rhs_range_value) == $mtifc_parse_db::RANGE) {
		$return_value =~ s/:.*//g;
	}
	return $return_value;    
} # mtifc_get_lower_range_bound

############################################################
##    Function: mtifc_get_upper_range_bound
##          in:  bin rhs range value
##         out:  the upper range bound
##
## Note: RHS range values have the format of 
##       a number followed by a colon followed by a number. 
##       $RANGE example values:
##          1:2
##			300:302
##
## When the "bin rhs kind" is $RANGE:
##       this routine returns the part of the 
##       $bin_rhs_range_value string that
##       lies to the LEFT of the colon.
## When the "bin rhs kind" is NOT $RANGE:
##       this routine just returns the 
##       $bin_rhs_range_value string.
##
## Description: given a bin rhs range value 
##              return the upper range bound
############################################################

sub mtifc_get_upper_range_bound {
    my ($db, $bin_rhs_range_value) = @_;
	my $return_value;

	$return_value = $bin_rhs_range_value;
	if ($db->mtifc_get_bin_rhs_kind($bin_rhs_range_value) == $mtifc_parse_db::RANGE) {
		$return_value =~ s/.*://g;
	}
	return $return_value;    
} # mtifc_get_upper_range_bound

############################################################
##    Function: print_cross_or_coverpoint
##          in:  parsed data base
##         out:  none
##
## Description: Print common information for a coverpoint or cross.
############################################################

sub print_cross_or_coverpoint {
    my ($db, $kind, $option_kind) = @_;
	my $handle;
	my $value;

	$handle = $db->mtifc_get_covergroupitem_aggregate_bin_handle();
	print sprintf "    %s %-28s %5s%% %10s %-10s\n",
		$kind,
		$db->mtifc_get_handle_name($handle),
		$db->mtifc_get_handle_metric($handle),
		$db->mtifc_get_handle_goal($handle),
		$db->mtifc_get_handle_status($handle);
	$value = $db->mtifc_get_covergroupitem_coveredbins();
	if (defined $value) {
		print sprintf "%s=%d\n",
			"        coveredbins",
			$value;
	}
	$value = $db->mtifc_get_covergroupitem_totalbins();
	if (defined $value) {
		print sprintf "%s=%d\n",
			"        totalbins",
			$value;
	}
    if ($option_kind == 0) {
		$handle = $db->mtifc_get_covergroupitem_option_handle();
		print_option_lines($db, "option", $handle, 2);
	} else {
	    $handle = $db->mtifc_get_covergroupitem_type_option_handle();
	    print_option_lines($db, "type_option", $handle, 2);
	}
} # print_cross_or_coverpoint

############################################################
##    Function: print_cross_coverpoints 
##          in:  parsed data base
##               The string "Cross" or "Coverpoint"
##               The nonzero integer if "type_option" otherwise zero for "option"
##         out:  none
##
## Description: given the focus of a cross item, print a line 
##              listing the names of all the coverpoints used
##              to construct this cross.
############################################################

sub print_cross_coverpoints {
    my ($db) = @_;
	my $numCoverpoints;
	my $coverpoint_handle;
	my $coverpoint_name;

	$numCoverpoints = $db->mtifc_get_cross_num_coverpoints();
	if ($numCoverpoints > 0) {
		print "        Cross coverpoints:";
		for my $index (0..$numCoverpoints-1) {
			## Get the coverpoint handle first and then get the name from it. 
			$coverpoint_handle = $db->mtifc_get_ith_cross_coverpoint_handle($index);
            $coverpoint_name = $db->mtifc_get_handle_name($coverpoint_handle);
			print sprintf " %s", $coverpoint_name;
			## Test the direct way of getting the coverpoint name from the cross.
			if ($coverpoint_name ne $db->mtifc_get_ith_cross_coverpoint_name($index)) {
			    print "Error: Coverpoint name check failed\n";
			    exit;
			}
		}
		print "\n";
	}
} # print_cross_coverpoints

############################################################
##    Function: print_bin_rhs 
##          in:  parsed data base
##         out:  none
##
## Description: given the focus of a bin item, print a line 
##              listing the names of all the rhs values
##              used to construct this bin.
############################################################

sub print_bin_rhs {
    my ($db, $bin_handle) = @_;
	my $numRHS;
	my $rhs_value;
	my $rhs_kind;

	$numRHS = $db->mtifc_get_bin_num_rhs($bin_handle);
	if ($numRHS > 0) {
		print sprintf "            Bin RHS(%d item{s}):", $numRHS;
		for my $index (0..$numRHS-1) {
			$rhs_value = $db->mtifc_get_ith_bin_rhs_value($bin_handle, $index);
			$rhs_kind = $db->mtifc_get_bin_rhs_kind($rhs_value);
			if ($rhs_kind == $mtifc_parse_db::SINGLE) {
				print sprintf " %s", $rhs_value;
			} elsif ($rhs_kind == $mtifc_parse_db::RANGE) {
				print sprintf " [%s:%s]", 
					mtifc_get_lower_range_bound($db, $rhs_value),
					mtifc_get_upper_range_bound($db, $rhs_value);
				##### Note: The following line would yield the SAME results as the line above. The 
				##          rhs_value of a range is a number followed by a colon followed by
				##          a number.
				## print sprintf " [%s]", $rhs_value;
			} elsif ($rhs_kind == $mtifc_parse_db::TRANSITION) {
				print sprintf " (%s)", $rhs_value;
			} else {
				print sprintf " %s", $rhs_value;
			}
		}
		print "\n";
	}
} # print_bin_rhs

############################################################
##    Function: print_bin_lines 
##          in:  parsed data base
##          in:  default kind of bin (ex. "bin" or "crossbin")
##          in:  set of bin kinds to print 
##               (ex. $BIN_NORMAL | $BIN_IGNORE | $BIN_ILLEGAL)
##         out:  none
##
## Description: given the focus of a covergroup item 
##              (i.e. a coverpoint or a cross) print a line 
##              of information about each of its bins having
##              the appropriate mode.
############################################################

sub print_bin_lines {
    my ($db, $default_bin_kind, $bin_kind_set) = @_;
	my $numBins;
	my $bin_handle;
	my $bin_kind;
	my $bin_name;

	$numBins = $db->mtifc_get_covergroupitem_numbins($bin_kind_set);
	for my $index (0..$numBins-1) {
		$bin_handle  = $db->mtifc_get_ith_bin_handle($index, $bin_kind_set);
		$bin_kind = $db->mtifc_get_handle_kind($bin_handle);
		if ($bin_kind == $mtifc_parse_db::BIN_IGNORE) {
			$bin_name = sprintf "ignore_bin %s", $db->mtifc_get_handle_name($bin_handle);
		} elsif ($bin_kind == $mtifc_parse_db::BIN_ILLEGAL) {
			$bin_name = sprintf "illegal_bin %s", $db->mtifc_get_handle_name($bin_handle);
		} elsif ($bin_kind == $mtifc_parse_db::BIN_NORMAL) {
			$bin_name = sprintf "%s %s", $default_bin_kind, $db->mtifc_get_handle_name($bin_handle);
		} else {
			$bin_name = sprintf "%s %s", $default_bin_kind, $db->mtifc_get_handle_name($bin_handle);
		}
		print sprintf "        %-31s %5s %10s %-10s\n",
			$bin_name,
			$db->mtifc_get_handle_metric($bin_handle),
			$db->mtifc_get_handle_goal($bin_handle),
			$db->mtifc_get_handle_status($bin_handle);
		print_bin_rhs($db, $bin_handle);
	}
} # print_bin_lines

############################################################
##    Function: print_option_lines 
##          in:  parsed data base
##          in:  prefix (i.e. "type_option" or "option")
##          in:  "type_option" or "option" handle
##          in:  indentation level for the line written
##         out:  none
##
## Description: given a type_option or option handle 
##              print the lines of information given
##              for that option.
############################################################

sub print_option_lines {
    my ($db, $prefix, $handle, $indentation) = @_;
	my $value;
	my $indent;

	if ($handle != $mtifc_parse_db::NA) {
		if ($indentation == 1) {
			$indent = "    ";
		} elsif ($indentation == 2) {
			$indent = "        ";
		} else {
			$indent = "";
		}
		## NAME
		$value = $db->mtifc_get_instance_name($handle);
		if ($value ne $mtifc_parse_db::NONE) {
			print sprintf "%s%s.%s=%s\n",
				$indent,
				$prefix,
				"name",
				$value;
		}
		## WEIGHT
		$value = $db->mtifc_get_weight($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"weight",
				$value;
		}
		## GOAL
		$value = $db->mtifc_get_goal($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"goal",
				$value;
		}
		## COMMENT
		$value = $db->mtifc_get_comment($handle);
		if ($value ne $mtifc_parse_db::NONE) {
			print sprintf "%s%s.%s=%s\n",
				$indent,
				$prefix,
				"comment",
				$value;
		}
		## STROBE
		$value = $db->mtifc_get_strobe($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"strobe",
				$value;
		}
		## AT_LEAST
		$value = $db->mtifc_get_at_least($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"at_least",
				$value;
		}
		## AUTO_BIN_MAX
		$value = $db->mtifc_get_auto_bin_max($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"auto_bin_max",
				$value;
		}
		## CROSS_NUM_PRINT_MISSING
		$value = $db->mtifc_get_cross_num_print_missing($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"cross_num_print_missing",
				$value;
		}
		## DETECT_OVERLAP
		$value = $db->mtifc_get_detect_overlap($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"detect_overlap",
				$value;
		}
		## PER_INSTANCE
		$value = $db->mtifc_get_per_instance($handle);
		if ($value != $mtifc_parse_db::NA) {
			print sprintf "%s%s.%s=%d\n",
				$indent,
				$prefix,
				"per_instance",
				$value;
		}
	}
} # print_option_lines

############################################################
##
## DUMP DATABASE TREE -- Test
##
############################################################

############################################################
##    Function: mtifc_dump_data
##          in:  none
##         out:  none
##
## Description: Test access functions
##              
############################################################

sub mtifc_dump_data {

    my ($db) = @_;

    ########################################################
	## Fcover Covergroup report
    ########################################################
    my $numReports = $db->mtifc_get_num_cvgreports();
	my $handle;
    
    foreach my $i (0..$numReports-1) {
		$db->mtifc_set_cvgreport_focus_to_ith_report($i);

		########################################################
		## Print the covergroup TYPE portion of the report
		########################################################
		print "\n$i\n";
		print "--------------------------------------------------------------------\n";
		print "Covergroup                             Metric      Goal/ Status\n";
		print "                                                At Least\n";
		print "--------------------------------------------------------------------\n";
	    
		my $numCoverTypes = $db->mtifc_get_ith_cvgreport_numcovertypes($i);
		for my $j (0..$numCoverTypes-1) {
			$db->mtifc_set_coveritem_focus_to_ith_covertype($j);

			$handle = $db->mtifc_get_coveritem_aggregate_bin_handle();
			print sprintf " TYPE %-32s %5s%% %10s %-10s {%s}\n",
				$db->mtifc_get_handle_name($handle),
				$db->mtifc_get_handle_metric($handle),
				$db->mtifc_get_handle_goal($handle),
				$db->mtifc_get_handle_status($handle),
				$db->mtifc_get_coveritem_path();
			$handle = $db->mtifc_get_coveritem_type_option_handle();
			print_option_lines($db, "type_option", $handle, 1);
			my $numCoverpoints = $db->mtifc_get_coveritem_numcoverpoints();
			for my $k (0..$numCoverpoints-1) {
				$db->mtifc_set_covergroupitem_focus_to_ith_coverpoint($k);

                print_cross_or_coverpoint($db, "Coverpoint", 1);
				print_bin_lines($db, "bin", $mtifc_parse_db::BIN_ILLEGAL);
				print_bin_lines($db, "bin", $mtifc_parse_db::BIN_IGNORE);
				print_bin_lines($db, "bin", $mtifc_parse_db::BIN_NORMAL);
			}
			my $numCrosses = $db->mtifc_get_coveritem_numcrosses();
			for my $k (0..$numCrosses-1) {
				$db->mtifc_set_covergroupitem_focus_to_ith_cross($k);

                print_cross_or_coverpoint($db, "Cross", 1);
				print_bin_lines($db, "crossbin", $mtifc_parse_db::BIN_ALL);
				print_cross_coverpoints($db);
			}
			########################################################
			## Print the COVERINSTANCE portion of the report
			########################################################
			my $numCoverInstances = $db->mtifc_get_ith_covertype_numcoverinstances();
			for my $jj (0..$numCoverInstances-1) {
				$db->mtifc_set_coveritem_focus_to_ith_coverinstance($jj);

				$handle = $db->mtifc_get_coveritem_aggregate_bin_handle();
				print sprintf " Covergroup instance %-17s %5s%% %10s %-10s {%s}\n",
					$db->mtifc_get_handle_name($handle),
					$db->mtifc_get_handle_metric($handle),
					$db->mtifc_get_handle_goal($handle),
					$db->mtifc_get_handle_status($handle),
					$db->mtifc_get_coveritem_path();
				my $index = $db->mtifc_get_coverinstance_covertype_index();
				if ($index == $j) {
				    print sprintf "    Associated COVERTYPE index: %d.\n", $index;
				} else {
				    print sprintf "    ERROR: Associated COVERTYPE index is %d (NOT the expected value of %d)!\n", $index, $j;
				}
				$handle = $db->mtifc_get_coveritem_option_handle();
				print_option_lines($db, "option", $handle, 1);
				my $numCoverpoints = $db->mtifc_get_coveritem_numcoverpoints();
				for my $k (0..$numCoverpoints-1) {
					$db->mtifc_set_covergroupitem_focus_to_ith_coverpoint($k);

                    print_cross_or_coverpoint($db, "Coverpoint", 0);
					print_bin_lines($db, "bin", 
						$mtifc_parse_db::BIN_NORMAL |			## Note: The order here has NO significance
						$mtifc_parse_db::BIN_IGNORE);
					print_bin_lines($db, "bin", $mtifc_parse_db::BIN_ILLEGAL);
				}
				my $numCrosses = $db->mtifc_get_coveritem_numcrosses();
				for my $k (0..$numCrosses-1) {
					$db->mtifc_set_covergroupitem_focus_to_ith_cross($k);

                    print_cross_or_coverpoint($db, "Cross", 0);
					print_bin_lines($db, "crossbin", 
						$mtifc_parse_db::BIN_ILLEGAL |			## Note: The order here has NO significance
						$mtifc_parse_db::BIN_NORMAL);
					print_bin_lines($db, "crossbin", $mtifc_parse_db::BIN_IGNORE);
					print_cross_coverpoints($db);
				}
			}
		}

        ########################################################
		### WARNING! THIS SECTION IS DEPRECATED WARNING!
		########################################################
		## Print the COVERGROUP portion of the report (DEPRECATED)
		########################################################
		my $numCoverGroups = $db->mtifc_get_ith_cvgreport_numcovergroups($i); # DEPRECATED
		for my $j (0..$numCoverGroups-1) {
			$db->mtifc_set_coveritem_focus_to_ith_covergroup($j);             # DEPRECATED

			$handle  = $db->mtifc_get_coveritem_aggregate_bin_handle();
			print sprintf " Covergroup instance %-17s %5s%% %10s %-10s {%s}\n",
				$db->mtifc_get_handle_name($handle),
				$db->mtifc_get_handle_metric($handle),
				$db->mtifc_get_handle_goal($handle),
				$db->mtifc_get_handle_status($handle),
				$db->mtifc_get_coveritem_path();
			$handle  = $db->mtifc_get_coveritem_option_handle();
			print_option_lines($db, "option", $handle, 1);
			my $numCoverpoints = $db->mtifc_get_coveritem_numcoverpoints();
			for my $k (0..$numCoverpoints-1) {
				$db->mtifc_set_covergroupitem_focus_to_ith_coverpoint($k);

                print_cross_or_coverpoint($db, "Coverpoint", 0);
				print_bin_lines($db, "bin", 
					$mtifc_parse_db::BIN_NORMAL |			## Note: The order here has NO significance
					$mtifc_parse_db::BIN_IGNORE);
				print_bin_lines($db, "bin", $mtifc_parse_db::BIN_ILLEGAL);
			}
			my $numCrosses = $db->mtifc_get_coveritem_numcrosses();
			for my $k (0..$numCrosses-1) {
				$db->mtifc_set_covergroupitem_focus_to_ith_cross($k);

                print_cross_or_coverpoint($db, "Cross", 0);
				print_bin_lines($db, "crossbin", 
					$mtifc_parse_db::BIN_ILLEGAL |			## Note: The order here has NO significance
					$mtifc_parse_db::BIN_NORMAL);
				print_bin_lines($db, "crossbin", $mtifc_parse_db::BIN_IGNORE);
				print_cross_coverpoints($db);
			}
		}
        ########################################################
		### WARNING! THIS SECTION IS DEPRECATED WARNING!
		########################################################
	 
		print "\n";

    } # foreach

    ########################################################
	## Fcover Directive report
    ########################################################
    my $numDesigns = $db->mtifc_get_num_designs();
    
    foreach my $i (0..$numDesigns-1) {
		my $numfcovers = $db->mtifc_get_ith_design_numfcovers($i);

		print "\n$i\n";
		print "----------------------------------------------------------------------------------------\n";
		print "Name                       Design Design   Lang File(Line)                    Count Status\n";    
		print "                           Unit   UnitType   \n";                                             
		print "----------------------------------------------------------------------------------------\n";

		$db->mtifc_set_design_focus_to_ith_design($i);
		for my $j (0..$numfcovers-1) {
			print sprintf "%-27s %5s %8s %4s %-29s %5d %-s \n\t[PATH=%s, LINE=%s, FIRED=%s, COVERED=%s]\n",
				$db->mtifc_get_ith_fcover_name($j),
				$db->mtifc_get_ith_fcover_du($j),
				$db->mtifc_get_ith_fcover_dutype($j),
				$db->mtifc_get_ith_fcover_dirtype($j),
				$db->mtifc_get_ith_fcover_source($j),
                $db->mtifc_get_ith_fcover_count($j),
                $db->mtifc_get_ith_fcover_status($j),
				$db->mtifc_get_ith_fcover_file_path($j),
				$db->mtifc_get_ith_fcover_linenum($j),
				$db->mtifc_get_ith_fcover_is_fired($j),
				$db->mtifc_get_ith_fcover_is_covered($j);
		}
	 
		print sprintf "\nTOTAL COVERAGE: %5s%%  COVERS: %d [NAME: %s, COMMENT: %s]\n\n",
			$db->mtifc_get_ith_design_fcoverage($i),
			$numfcovers,
			$db->mtifc_get_ith_design_name($i),
			$db->mtifc_get_ith_design_comment($i);

    } # foreach

    return (1);
    
} # sub mtifc_dump_data

############################################################
##
## Main routine
##
############################################################

if ($#ARGV < 0) {
    print_usage();
    exit;
}

my $db = mtifc_parse_db->new();
my $filelist;
mtifc_parse_command_line();
if ($is_dbfile) {
	$filelist = $dbfile;
	print "BEGIN fcov data dump for \"$filelist\".\n";
    $db->mtifc_parse_db_file($dbfile);
} else {
	$filelist = $dblistfile;
	print "BEGIN fcov data dump for \"$filelist\".\n";
    $db->mtifc_parse_db_filelist($dblistfile);
}
mtifc_dump_data($db);
print "END   fcov data dump for \"$filelist\".\n";
