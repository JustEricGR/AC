
Perl and the fcover Perl scripts

Directory Contents:
	A) README.txt (This file)
	B) mtifc_parse_db.pm (the fcover Perl script package)
		The access methods are in this file. The headers of each 
		access method documents:
			1) What the method does.
			2) How the method is called.
	C) mtifc_sax_handler.pm
		XML parsing support file for "mtifc_parse_db.pm".
	D) mtifc_parse_db_test.pl
		This is a Perl test driver script. It is designed to illustrate
		how one might call the fcover Perl access methods.

		This Perl script creates a textual report from one or more 
		functional coverage XML database files that were produced by 
		the "fcover report" command at simulation time. The syntax for the 
		test script is as follows:
			mtifc_parse_db_test.pl [-db dbfile] [-db_list db_file_list]
		There are two options: 
		    -db to specify one XML database file or 
		    -db_list to specify multiple XML database files.

                PLEASE NOTE: The functional coverage XML database files must be
		created by the "fcover -xml" command. 
                    EXAMPLE:
                        fcover report -r / -directive -cvg -xml -output report.xml
                    For additional information on using the "fcover report" command,
                    please consult the QuestaSim user's manual 
                    (i.e. fcover report , CommandReference).
	E) XML (directory)
		Perl publicly distributed modules to support parsing of an XML file.
		Everything in this directory, and and its subdirectories are governed 
		by the Perl Artistic copyright (See XML/Perl_artistic_copyright.htm).

In order to use the fcover Perl script package you will need:
	A) Perl version 5.005 or better. 
	B) The XML::SAX and XML::NamespaceSupport modules must be available.
		It is likely that these modules will already be installed in your version of Perl.
		If not, you may either:
			1) install the modules directly into your version of Perl.

			   The tar files for these modules can be downloaded from:
				http://cpan.uwinnipeg.ca/cpan/authors/id/M/MS/MSERGEANT/XML-SAX-0.12.tar.gz
					and
				http://cpan.uwinnipeg.ca/cpan/authors/id/R/RB/RBERJON/XML-NamespaceSupport-1.08.tar.gz

			   After unTARing the files, install the modules. On Unix and Unix-like platforms: 

				$ perl Makefile.PL
				$ make
				$ make test
				$ make install 

			   On ActivePerl, or Perl's built with MSVC: 

				$ perl Makefile.PL
				$ nmake
				$ nmake test
				$ nmake install 

			2) use the modules that we have provide in the XML directory.

			   Just include the line 'use lib "<full pathname to this directory>";'
			   at the top of Perl script files which reference methods found in
			   mtifc_parse_db.pm. The Perl script file mtifc_parse_db_test.pl has an
			   example of this.

			   See file XML/README.txt for additional information.

NOTE:
	Better performance can be had by installing the XML::Parser and XML::SAX::Expat Perl modules
	directly into your version of Perl (if they are not already installed).

	The tar files for these modules can be downloaded from:
		http://cpan.uwinnipeg.ca/cpan/authors/id/M/MS/MSERGEANT/XML-Parser-2.34.tar.gz
			and
		http://cpan.uwinnipeg.ca/cpan/authors/id/R/RB/RBERJON/XML-SAX-Expat-0.37.tar.gz

	After unTARing the files, install the modules. On Unix and Unix-like platforms: 

		$ perl Makefile.PL
		$ make
		$ make test
		$ make install 

	On ActivePerl, or Perl's built with MSVC: 

		$ perl Makefile.PL
		$ nmake
		$ nmake test
		$ nmake install 
