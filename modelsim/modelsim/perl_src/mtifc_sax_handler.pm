#!/usr/local/bin/perl
#
# (c) 2005 Mentor Graphics Corporation.                            
#     All rights reserved.                                                       
#                                                                       
# THIS SOFTWARE AND (ON-LINE) DOCUMENTATION CONTAIN CONFIDENTIAL        
# INFORMATION AND TRADE SECRETS OF Mentor Graphics Corporation.  USE,   
# DISCLOSURE, OR REPRODUCTION IS PROHIBITED WITHOUT THE PRIOR EXPRESS   
# WRITTEN PERMISSION OF Mentor Graphics Corporation.                    
#
# Purpose: Build database by parsing the db file
#
# $Revision: #1 $

############################################################
=head1 NAME

mtifc_sax_handler - Package that parses db builds a database. 
=cut

############################################################

package mtifc_sax_handler;

use strict;
use warnings;
use Env;
use base qw(XML::SAX::Base);

##==========================================================
##
## Define package globals
##
##==========================================================

*VERSION_NUMBER = \5.0;
*OLDEST_COMPATIBLE_VERSION_NUMBER = \4.0;

my $database_ref = 0;
my $report_filename_ref = 0;
my @parse_state;
my $parse_leaf = "";
my $cvgreport;
my $fcover;
my $designunit;
my $design;
my $bin;
my @coveritem;
my @coveritem_kind;
my $optionitem;
my $covergroupitem;
my $covergroupitem_kind = 0;
my $in_debug_mode = 0;
my $coverpoint_index = 0;

unshift(@coveritem_kind, 0);
unshift(@coveritem, 0);

##==========================================================
##
## Define package methods
##
##==========================================================

##==========================================================
##    Functions: debug routines/ error checking methods
##==========================================================

sub mtifc_debug_is_on {
    return $in_debug_mode;
}

sub mtifc_debug_turn_on {
    $in_debug_mode = 1;
}

sub mtifc_debug_turn_off {
    $in_debug_mode = 0;
}

sub mtifc_debug_print {
    my ($str) = @_;
    if (mtifc_debug_is_on() == 1) {
	print "DBG --- $str\n";
    }
}

##==========================================================
##
## INIT methods
##
##==========================================================

##----------------------------------------------------------
## Package inits
##----------------------------------------------------------

sub new {
	my ($class, $db_ref, $report_file_rf) = @_;

	my $class_ref = {};

	$database_ref = $db_ref;
	$report_filename_ref = $report_file_rf;

	unshift(@parse_state, "STATE_TOP");

	# initialize global database record

	##----------------------------------------------------------
	## Directive
	##----------------------------------------------------------
    undef $$database_ref->{DESIGNS};            ## All inclusive list of all designs in all databases
    undef $$database_ref->{DESIGNUNITS};        ## All inclusive list of all design units in all databases
    undef $$database_ref->{FCOVERS};            ## All inclusive list of all directive covers in all databases
	##----------------------------------------------------------
	## Covergroup
	##----------------------------------------------------------
    undef $$database_ref->{COVERGROUPREPORTS};  ## All inclusive list of all covergroup reports in all databases
    undef $$database_ref->{COVERTYPES};         ## All inclusive list of all covertypes in all databases
    undef $$database_ref->{COVERGROUPS};        ## All inclusive list of all covergroups in all databases -- deprecated!
    undef $$database_ref->{COVERINSTANCES};     ## All inclusive list of all coverinstances in all databases
    undef $$database_ref->{COVERPOINTS};        ## All inclusive list of all coverpoints in all databases
    undef $$database_ref->{CROSSS};             ## All inclusive list of all crosses in all databases

	return bless($class_ref, $class);
}

##----------------------------------------------------------
## Directive inits
##----------------------------------------------------------

sub design_init {
  my ($elem) = @_;

  mtifc_debug_print("design_init executing.....\n");
  unshift(@parse_state, "STATE_DESIGN");
  # Values
  undef $elem->{NAME};
  undef $elem->{COMMENT};
  undef $elem->{FCOVERAGE};
  undef $elem->{NUMFCOVERS};
  # Lists
  undef $elem->{FCOVERS_INDEX_BEGIN}; ## List of all directive covers in this design
  undef $elem->{FCOVERS_INDEX_COUNT};

  if (defined $$database_ref->{FCOVERS}) {
	$elem->{FCOVERS_INDEX_BEGIN} = @{$$database_ref->{FCOVERS}};
  } else {
	$elem->{FCOVERS_INDEX_BEGIN} = 0;
  }

  return $elem;
}

# OBSOLETE designunit OBSOLETE
sub designunit_init {
  my $elem;

  $elem = design_init();
  shift @parse_state;
  mtifc_debug_print("designunit_init executing.....\n");
  unshift(@parse_state, "STATE_DESIGNUNIT");

  return $elem;
}
# OBSOLETE designunit OBSOLETE

sub fcover_init {
  my ($elem) = @_;

  mtifc_debug_print("fcover_init executing.....\n");
  unshift(@parse_state, "STATE_FCOVER");
  # Values
  undef $elem->{NAME};
  undef $elem->{DU};
  undef $elem->{DUTYPE};
  undef $elem->{DIRTYPE};
  undef $elem->{SOURCE};
  undef $elem->{ENABLED};
  undef $elem->{COUNT};
  undef $elem->{ATLEAST};
  undef $elem->{LIMIT};
  undef $elem->{WEIGHT};
  undef $elem->{STATUS};
  undef $elem->{LOG};

  return $elem;
}

##----------------------------------------------------------
## Covergroup inits
##----------------------------------------------------------

sub cvgreport_init {
  my ($elem) = @_;

  mtifc_debug_print("cvgreport_init executing.....\n");
  unshift(@parse_state, "STATE_CVGREPORT");
  # Lists
  undef $elem->{COVERGROUPS_INDEX_BEGIN}; ## List of all covergroups in this cvgreport -- deprecated!
  undef $elem->{COVERGROUPS_INDEX_COUNT};
  undef $elem->{COVERTYPES_INDEX_BEGIN};  ## List of all covertypes in this cvgreport
  undef $elem->{COVERTYPES_INDEX_COUNT};
  undef $elem->{COVERPOINTS_INDEX_BEGIN}; ## List of all coverpoints in this cvgreport
  undef $elem->{COVERPOINTS_INDEX_COUNT};
  undef $elem->{CROSSES_INDEX_BEGIN};     ## List of all crosses in this cvgreport
  undef $elem->{CROSSES_INDEX_COUNT};

  if (defined $$database_ref->{COVERTYPES}) {
	$elem->{COVERTYPES_INDEX_BEGIN} = @{$$database_ref->{COVERTYPES}};
  } else {
	$elem->{COVERTYPES_INDEX_BEGIN} = 0;
  }
  if (defined $$database_ref->{COVERGROUPS}) {
	# deprecated!
	$elem->{COVERGROUPS_INDEX_BEGIN} = @{$$database_ref->{COVERGROUPS}};
  } else {
	# deprecated!
	$elem->{COVERGROUPS_INDEX_BEGIN} = 0;
  }
  if (defined $$database_ref->{COVERPOINTS}) {
	$elem->{COVERPOINTS_INDEX_BEGIN} = @{$$database_ref->{COVERPOINTS}};
  } else {
	$elem->{COVERPOINTS_INDEX_BEGIN} = 0;
  }
  $elem->{COVERPOINTS_INDEX_COUNT} = 0;
  if (defined $$database_ref->{CROSSS}) {
	$elem->{CROSSES_INDEX_BEGIN} = @{$$database_ref->{CROSSS}};
  } else {
	$elem->{CROSSES_INDEX_BEGIN} = 0;
  }
  $elem->{CROSSES_INDEX_COUNT} = 0;

  return $elem;
}

sub coveritem_init {
  my ($elem) = @_;

  mtifc_debug_print("coveritem_init executing.....\n");
  unshift(@parse_state, "STATE_COVERITEM");
  # Values
  undef $elem->{PATH};
  undef $elem->{AGGREGATION};
  undef $elem->{TYPE_OPTION};
  undef $elem->{OPTION};
  undef $elem->{COVERTYPE_INDEX};             ## When this coveritem is a COVERINSTANCE, then 
                                              ##     this holds the index value for its associated covertype.
  # Lists
  undef $elem->{COVERPOINTS_INDEX_BEGIN};     ## List of all coverpoints in this coveritem
  undef $elem->{COVERPOINTS_INDEX_COUNT};
  undef $elem->{CROSSES_INDEX_BEGIN};         ## List of all crosses in this coveritem
  undef $elem->{CROSSES_INDEX_COUNT};
  undef $elem->{COVERPOINT_LOOKUP_BY_NAME};   ## Find the index associated with a coverpoint name
  undef $elem->{COVERINSTANCES_INDEX_BEGIN};  ## List of all coverinstances in this covertype
  undef $elem->{COVERINSTANCES_INDEX_COUNT};

  if (defined $$database_ref->{COVERPOINTS}) {
	$elem->{COVERPOINTS_INDEX_BEGIN} = @{$$database_ref->{COVERPOINTS}};
  } else {
	$elem->{COVERPOINTS_INDEX_BEGIN} = 0;
  }
  $elem->{COVERPOINTS_INDEX_COUNT} = 0;
  if (defined $$database_ref->{CROSSS}) {
	$elem->{CROSSES_INDEX_BEGIN} = @{$$database_ref->{CROSSS}};
  } else {
	$elem->{CROSSES_INDEX_BEGIN} = 0;
  }
  $elem->{CROSSES_INDEX_COUNT} = 0;
  if (defined $$database_ref->{COVERINSTANCES}) {
	$elem->{COVERINSTANCES_INDEX_BEGIN} = @{$$database_ref->{COVERINSTANCES}};
  } else {
	$elem->{COVERINSTANCES_INDEX_BEGIN} = 0;
  }
  $elem->{COVERINSTANCES_INDEX_COUNT} = 0;
  $elem->{COVERPOINT_LOOKUP_BY_NAME} = {};
  $coverpoint_index = 0;

  return $elem;
}

sub optionitem_init {
  my ($elem) = @_;

  mtifc_debug_print("optionitem_init executing.....\n");
  unshift(@parse_state, "STATE_OPTIONITEM");
  # Values
  undef $elem->{NAME};
  undef $elem->{WEIGHT};
  undef $elem->{GOAL};
  undef $elem->{COMMENT};
  undef $elem->{STROBE};
  undef $elem->{AT_LEAST};
  undef $elem->{AUTO_BIN_MAX};
  undef $elem->{CROSS_NUM_PRINT_MISSING};
  undef $elem->{DETECT_OVERLAP};
  undef $elem->{PER_INSTANCE};
  return $elem;
}

sub covergroupitem_init {
  my ($elem) = @_;

  mtifc_debug_print("covergroupitem_init executing.....\n");
  unshift(@parse_state, "STATE_COVERGROUPITEM");
  # Values
  undef $elem->{AGGREGATION};
  undef $elem->{TYPE_OPTION};
  undef $elem->{OPTION};
  undef $elem->{COVEREDBINS};
  undef $elem->{TOTALBINS};
  # Lists
  undef $elem->{BINS_NORMAL};  ## List of all normal  bins in this covergroup item
  undef $elem->{BINS_IGNORE};  ## List of all ignore  bins in this covergroup item
  undef $elem->{BINS_ILLEGAL}; ## List of all illegal bins in this covergroup item
  undef $elem->{CROSS_COVERPOINTS};

  return $elem;
}

sub bin_init {
  my ($elem) = @_;

  mtifc_debug_print("bin_init executing.....\n");
  unshift(@parse_state, "STATE_BIN");
  # Values
  undef $elem->{NAME};
  undef $elem->{METRIC};
  undef $elem->{GOAL};
  undef $elem->{STATUS};
  undef $elem->{BIN_RHS};
  undef $elem->{BIN_RHS_STR};
	    $elem->{BIN_KIND} = $mtifc_parse_db::BIN_NORMAL;

  return $elem;
}

##==========================================================
##
## Parse handler methods
##
##==========================================================

##----------------------------------------------------------
## Directive parse handler methods
##----------------------------------------------------------

sub start_element_fcover {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_fcover {

		m/^(name|dutype|dirtype|du|source|enabled|count|atleast|limit|weight|status|log)$/ && do {
			$parse_leaf = $_;
			return;
		};

		m/^fcover$/ && ($token_ref->[0] eq "E") && do {
			# We are done with this design
            push @{ $$database_ref->{FCOVERS}} , $fcover;
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_designunit {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_designunit {

		m/^(fcoverage|numfcovers|name)$/ && do {
			$parse_leaf = $_;
			return;
		};

		m/^fcover$/ && do {
			$fcover = fcover_init();
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_design {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_design {

		m/^(fcoverage|numfcovers|comment|name)$/ && do {
			$parse_leaf = $_;
			return;
		};

		# OBSOLETE designunit OBSOLETE
		m/^designunit$/ && do {
			# OBSOLETE designunit OBSOLETE
			$designunit = designunit_init();
			return;
		};
		# OBSOLETE designunit OBSOLETE

		m/^fcover$/ && do {
			$fcover = fcover_init();
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

##----------------------------------------------------------
## Covergroup parse handler methods
##----------------------------------------------------------
sub start_element_bin {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_bin {

		m/^(name|metric|goal|status|bin_rhs)$/ && do {
			$parse_leaf = $_;
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_bins {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_bins {

		m/^bin$/ && do {
			$bin = bin_init();
            push @{$covergroupitem->{BINS_NORMAL}} , $bin;
			return;
		};

		m/^ignore_bins$/ && do {
			$bin = bin_init();
			$bin->{BIN_KIND} = $mtifc_parse_db::BIN_IGNORE;
            push @{$covergroupitem->{BINS_IGNORE}} , $bin;
			return;
		};

		m/^illegal_bins$/ && do {
			$bin = bin_init();
			$bin->{BIN_KIND} = $mtifc_parse_db::BIN_ILLEGAL;
            push @{$covergroupitem->{BINS_ILLEGAL}} , $bin;
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_cross_coverpoints {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_cross_coverpoints {

		m/^cross_coverpoint$/ && do {
			$parse_leaf = "CROSS_COVERPOINTS";
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_covergroupitem {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_covergroupitem {

		m/^bins$/ && do {
			unshift(@parse_state, "STATE_BINS");
			return;
		};

		m/^cross_coverpoints$/ && do {
			unshift(@parse_state, "STATE_CROSS_COVERPOINTS");
			return;
		};

		m/^bin$/ && do {
			$bin = bin_init();
			$covergroupitem->{AGGREGATION} = $bin;
			return;
		};

		m/^(type_option)$/ && do {
			$optionitem = optionitem_init();
			$covergroupitem->{TYPE_OPTION} = $optionitem;
			return;
		};

		m/^(option)$/ && do {
			$optionitem = optionitem_init();
			$covergroupitem->{OPTION} = $optionitem;
			return;
		};

		m/^(coveredbins|totalbins)$/ && do {
			$parse_leaf = $_;
			return;
		};

	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_coveritem {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_coveritem {

		m/^path$/ && do {
			$parse_leaf = $_;
			return;
		};

		m/^bin$/ && do {
			$bin = bin_init();
			$coveritem[0]->{AGGREGATION} = $bin;
			return;
		};

		m/^(type_option)$/ && do {
			$optionitem = optionitem_init();
			$coveritem[0]->{TYPE_OPTION} = $optionitem;
			return;
		};

		m/^(option)$/ && do {
			$optionitem = optionitem_init();
			$coveritem[0]->{OPTION} = $optionitem;
			return;
		};

		m/^(coverpoint|cross)$/ && do {
			$covergroupitem_kind = $_;
			$covergroupitem = covergroupitem_init();
			return;
		};

		m/^(coverinstance)$/ && do {
			my $instance;

            $instance = coveritem_init();
            $instance->{COVERTYPE_INDEX} = $#{$$database_ref->{COVERTYPES}} + 1;
			unshift(@coveritem_kind, $_);
			unshift(@coveritem, $instance);
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_optionitem {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_optionitem {

		m/^(name|weight|goal|comment|strobe|at_least|auto_bin_max|cross_num_print_missing|detect_overlap|per_instance)$/ && do {
			$parse_leaf = $_;
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_cvgreport {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_cvgreport {

		m/^(covertype|covergroup)$/ && do {
			# NOTE: "covergroup" is deprecated!
			unshift(@coveritem_kind, $_);
			unshift(@coveritem, coveritem_init());
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_top {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_top {

		m/^coverage_report$/ && do {
            unshift(@parse_state, "STATE_COVERAGE");
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_coverage {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_top {

		m/^code_coverage_report$/ && do {
            unshift(@parse_state, "STATE_CODE_COVERAGE");
			return;
		};

		m/^functional_coverage_report$/ && do {
            unshift(@parse_state, "STATE_FUNCTIONAL_COVERAGE");
			return;
		};

		m/^assert_coverage_report$/ && do {
            unshift(@parse_state, "STATE_ASSERT_COVERAGE");
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub start_element_code_coverage {
	my ($token_ref) = @_;
	# Process document start event

	return;
}

sub start_element_functional_coverage {
	my ($token_ref) = @_;
	# Process document start event

	$_ = $token_ref->{"LocalName"};
	SWITCH_start_element_top {

		m/^design$/ && do {
			$design = design_init();
			return;
		};

		m/^cvgreport$/ && do {
			$cvgreport = cvgreport_init();
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}
sub start_element_assert_coverage {
	my ($token_ref) = @_;
	# Process document start event

    return;
}

##----------------------------------------------------------
## Package parse handler methods
##----------------------------------------------------------

sub start_element {
	my ($self, $token_ref) = @_;
	# Process tag start event

	$_ = $token_ref->{"LocalName"};
	mtifc_debug_print("parse_report_files: TOKEN = \"" . $_ . "\"\n");
	if ($parse_leaf ne "") {
		printf("ERROR: unexpected XML parse state at token \"%s\": file = %s, text = %s\n",
					   $_, $$report_filename_ref, $token_ref->{"LocalName"});
		return;
	}
	SWITCH_start_element: {

		m/^\s+$/ && do {
			# Skip white space
			return;
		};

		DEFAULT: {
			$_ = $parse_state[0];
			SWITCH_start_element_state: {
				m/^STATE_FCOVER$/ && do {
					start_element_fcover($token_ref);
					return;
				};
				m/^STATE_DESIGNUNIT$/ && do {
					start_element_designunit($token_ref);
					return;
				};
				m/^STATE_DESIGN$/ && do {
					start_element_design($token_ref);
					return;
				};
				m/^STATE_BINS$/ && do {
					start_element_bins($token_ref);
					return;
				};
				m/^STATE_BIN$/ && do {
					start_element_bin($token_ref);
					return;
				};
				m/^STATE_CROSS_COVERPOINTS$/ && do {
					start_element_cross_coverpoints($token_ref);
					return;
				};
				m/^STATE_COVERGROUPITEM$/ && do {
					start_element_covergroupitem($token_ref);
					return;
				};
				m/^STATE_COVERITEM$/ && do {
					start_element_coveritem($token_ref);
					return;
				};
				m/^STATE_CVGREPORT$/ && do {
					start_element_cvgreport($token_ref);
					return;
				};
				m/^STATE_OPTIONITEM$/ && do {
					start_element_optionitem($token_ref);
					return;
				};
				m/^STATE_ASSERT_COVERAGE$/ && do {
					start_element_assert_coverage($token_ref);
					return;
				};
				m/^STATE_FUNCTIONAL_COVERAGE$/ && do {
					start_element_functional_coverage($token_ref);
					return;
				};
				m/^STATE_CODE_COVERAGE$/ && do {
					start_element_code_coverage($token_ref);
					return;
				};
				m/^STATE_COVERAGE$/ && do {
					start_element_coverage($token_ref);
					return;
				};
				m/^STATE_TOP$/ && do {
					start_element_top($token_ref);
					return;
				};
			}
		}
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		$_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub end_element {
	my ($self, $token_ref) = @_;
	# Process tag start event

	$_ = $token_ref->{"LocalName"};
	mtifc_debug_print("parse_report_files: END TOKEN = \"" . $_ . "\"\n");
	SWITCH_end_element: {

		m/^\s+$/ && do {
			# Skip white space
			return;
		};

		m/^$parse_leaf$/ && do {
			# Skip white space
			$parse_leaf = "";
			return;
		};

		m/^coverage_report$/ && ($parse_state[0] eq "STATE_COVERAGE") && do {
			shift @parse_state;
			return;
		};

		m/^code_coverage_report$/ && ($parse_state[0] eq "STATE_CODE_COVERAGE") && do {
			shift @parse_state;
			return;
		};

		m/^functional_coverage_report$/ && ($parse_state[0] eq "STATE_FUNCTIONAL_COVERAGE") && do {
			shift @parse_state;
			return;
		};

		m/^assert_coverage_report$/ && ($parse_state[0] eq "STATE_ASSERT_COVERAGE") && do {
			shift @parse_state;
			return;
		};

		m/^fcover$/ && ($parse_state[0] eq "STATE_FCOVER") && do {
            push @{ $$database_ref->{FCOVERS}} , $fcover;
			shift @parse_state;
			return;
		};

		m/^designunit$/ && ($parse_state[0] eq "STATE_DESIGNUNIT") && do {
			if (defined $$database_ref->{FCOVERS}) {
				$designunit->{FCOVERS_INDEX_COUNT} =  
					@{ $$database_ref->{FCOVERS}} - $designunit->{FCOVERS_INDEX_BEGIN};
			} else {
				$designunit->{FCOVERS_INDEX_COUNT} =  0;
			}
            push @{$$database_ref->{DESIGNUNITS}} , $designunit;
			shift @parse_state;
			return;
		};

		m/^design$/ && ($parse_state[0] eq "STATE_DESIGN") && do {
			if (defined $$database_ref->{FCOVERS}) {
				$design->{FCOVERS_INDEX_COUNT} =  
					@{ $$database_ref->{FCOVERS}} - $design->{FCOVERS_INDEX_BEGIN};
			} else {
				$design->{FCOVERS_INDEX_COUNT} =  0;
			}
            push @{$$database_ref->{DESIGNS}} , $design;
			shift @parse_state;
			return;
		};

		m/^bins$/ && ($parse_state[0] eq "STATE_BINS") && do {
			shift @parse_state;
			return;
		};

		m/^(bin|ignore_bins|illegal_bins)$/ && ($parse_state[0] eq "STATE_BIN") && do {
			shift @parse_state;
			return;
		};

		m/^cross_coverpoints$/ && ($parse_state[0] eq "STATE_CROSS_COVERPOINTS") && do {
			shift @parse_state;
			return;
		};

		m/^cross_coverpoint$/ && ($parse_state[0] eq "STATE_CROSS_COVERPOINTS") && ($parse_leaf eq "CROSS_COVERPOINTS") && do {
			# Skip white space
			$parse_leaf = "";
			return;
		};

		m/^$covergroupitem_kind$/ && ($parse_state[0] eq "STATE_COVERGROUPITEM") && do {
	        # NOTE: $covergroupitem_kind is either "coverpoint" or "cross".
			# NOTE: uc($covergroupitem_kind . 'S') is either "COVERPOINTS" or "CROSSS".
            push @{$$database_ref->{uc($covergroupitem_kind . 'S')}} , $covergroupitem;
			shift @parse_state;
			$covergroupitem_kind = 0;
			# Update the COVERPOINT/CROSS count of the enclosing $coveritem (i.e. either "covertype" or "coverinstance" (deprecated:"covergroup").
			if (defined $$database_ref->{COVERPOINTS}) {
				$coveritem[0]->{COVERPOINTS_INDEX_COUNT} =  
					@{ $$database_ref->{COVERPOINTS}} - $coveritem[0]->{COVERPOINTS_INDEX_BEGIN};
			} else {
				$coveritem[0]->{COVERPOINTS_INDEX_COUNT} =  0;
			}
			if (defined $$database_ref->{CROSSS}) {
				$coveritem[0]->{CROSSES_INDEX_COUNT} =  
					@{ $$database_ref->{CROSSS}} - $coveritem[0]->{CROSSES_INDEX_BEGIN};
			} else {
				$coveritem[0]->{CROSSES_INDEX_COUNT} =  0;
			}
			return;
		};

		m/^$coveritem_kind[0]$/ && ($parse_state[0] eq "STATE_COVERITEM") && do {
			# NOTE: $coveritem_kind[0] is either "covertype", "covergroup" or "coverinstance".
			# NOTE: "covergroup" is deprecated!
			if (defined $$database_ref->{COVERINSTANCES}) {
				$coveritem[0]->{COVERINSTANCES_INDEX_COUNT} =  
					@{ $$database_ref->{COVERINSTANCES}} - $coveritem[0]->{COVERINSTANCES_INDEX_BEGIN};
			} else {
				$coveritem[0]->{COVERINSTANCES_INDEX_COUNT} =  0;
			}

			# NOTE: uc($coveritem_kind[0] . 'S') is either "COVERTYPES", "COVERGROUPS" or "COVERINSTANCES".
			# NOTE: "COVERGROUPS" is deprecated!
            push @{$$database_ref->{uc($coveritem_kind[0] . 'S')}} , $coveritem[0];
			shift @parse_state;
			shift @coveritem;
			shift @coveritem_kind;
			return;
		};

		m/^(type_option|option)$/ && ($parse_state[0] eq "STATE_OPTIONITEM") && do {
			shift @parse_state;
			return;
		};

		m/^cvgreport$/ && ($parse_state[0] eq "STATE_CVGREPORT") && do {
			if (defined $$database_ref->{COVERTYPES}) {
				$cvgreport->{COVERTYPES_INDEX_COUNT} =  
					@{ $$database_ref->{COVERTYPES}} - $cvgreport->{COVERTYPES_INDEX_BEGIN};
			} else {
				$cvgreport->{COVERTYPES_INDEX_COUNT} =  0;
			}
			if (defined $$database_ref->{COVERGROUPS}) {
				# deprecated!
				$cvgreport->{COVERGROUPS_INDEX_COUNT} =  
					@{ $$database_ref->{COVERGROUPS}} - $cvgreport->{COVERGROUPS_INDEX_BEGIN};
			} else {
				# deprecated!
				$cvgreport->{COVERGROUPS_INDEX_COUNT} =  0;
			}
			if (defined $$database_ref->{COVERPOINTS}) {
				$cvgreport->{COVERPOINTS_INDEX_COUNT} =  
					@{ $$database_ref->{COVERPOINTS}} - $cvgreport->{COVERPOINTS_INDEX_BEGIN};
			} else {
				$cvgreport->{COVERPOINTS_INDEX_COUNT} =  0;
			}
			if (defined $$database_ref->{CROSSS}) {
				$cvgreport->{CROSSES_INDEX_COUNT} =  
					@{ $$database_ref->{CROSSS}} - $cvgreport->{CROSSES_INDEX_BEGIN};
			} else {
				$cvgreport->{CROSSES_INDEX_COUNT} =  0;
			}

            push @{$$database_ref->{COVERGROUPREPORTS}} , $cvgreport;
			shift @parse_state;
			return;
		};
	}
	printf("ERROR: unexpected XML token \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $token_ref->{"LocalName"});
}

sub characters {
	my ($self, $data) = @_;
	my $text;

	$text = $data->{"Data"};

	# Process data event

	if ($text =~  m/^\s+$/) {
		# Skip white space
		return;
	}

	if ($parse_leaf ne "") {
		$_ = $parse_state[0];
		SWITCH_characters: {
			m/^STATE_FCOVER$/ && do {
				$fcover->{uc($parse_leaf)} .= $text;
				return;
			};
			m/^STATE_DESIGNUNIT$/ && do {
				$designunit->{uc($parse_leaf)} .= $text;
				return;
			};
			m/^STATE_DESIGN$/ && do {
				$design->{uc($parse_leaf)} .= $text;
				return;
			};
			m/^STATE_BIN$/ && do {
				if ($parse_leaf eq "bin_rhs") {
					$bin->{BIN_RHS_STR} = $text;
				    @{$bin->{BIN_RHS}} = split(/;/,$text);
				} elsif ($parse_leaf eq "name") {
					$bin->{uc($parse_leaf)} .= $text;
					if (($parse_state[1] eq "STATE_COVERGROUPITEM") && ($covergroupitem_kind eq "coverpoint" )) {
                        # For each <coverpoint> create the "index" by which it can be referenced (i.e. $coverpoint_index).
						# This index value can be retrieved by hashing on the name of the <coverpoint>.
                        $coveritem[0]->{COVERPOINT_LOOKUP_BY_NAME}->{$text} = $coverpoint_index;
                        $coverpoint_index++;
					}
				} else {
					$bin->{uc($parse_leaf)} .= $text;
				}
				return;
			};
			m/^STATE_COVERITEM$/ && do {
				$coveritem[0]->{uc($parse_leaf)} .= $text;
				return;
			};
			m/^STATE_COVERGROUPITEM$/ && do {
			    $covergroupitem->{uc($parse_leaf)} = $text;
				return;
			};
			m/^STATE_OPTIONITEM$/ && do {
				$optionitem->{uc($parse_leaf)} .= $text;
				return;
			};
			m/^STATE_CROSS_COVERPOINTS$/ && do {
				push @{$covergroupitem->{CROSS_COVERPOINTS}} , $text;
				return;
			};
		}
	}

	printf("ERROR: unexpected XML text \"%s\": file = %s, text = %s\n",
		   $_, $$report_filename_ref, $text);
}

sub processing_instruction {
	my ($self, $data) = @_;
	my $target;
	my $data_;

	$target = $data->{"Target"};
	$data_  = $data->{"Data"};

	$_ = $target;
	SWITCH_processing_instruction: {
		m/^mtifc_parse_db$/ && do {
			# This line contains the version number.
			if ($data_ =~ /version="([\d\.]+)"/i) {
				if ($1 < $mtifc_sax_handler::OLDEST_COMPATIBLE_VERSION_NUMBER) {
					printf("ERROR: XML file is NOT compatible with mtifc_parse_db (version %.1f)!\n", $mtifc_sax_handler::VERSION_NUMBER);
					printf("       The XML file needs to be no less than version %.1f (unfortunatly it is version %.1f).\n", $mtifc_sax_handler::OLDEST_COMPATIBLE_VERSION_NUMBER, $1);
				}
		    } else {
				printf("ERROR: XML file does NOT have a valid version number!\n");
			}
			return;
		};
	}
	printf("ERROR: unexpected XML processing_instruction \"%s\": file = %s, data = %s\n",
		   $target, $$report_filename_ref, $data_);
}

##########
## DONE ##
##########

1;
