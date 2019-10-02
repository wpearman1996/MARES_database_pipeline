#!/usr/bin/perl
#Teresita M. Porter 2018
#Script to grab COI records from NCBI nucleotide database using 4 COI search terms, for all Eukaryota, for one year at a time, with and without the BARCODE keyword
#edit the search term below for one year or many years ex. 2017 or 2003:2017[PDAT]
#edit whether you want to match the BARCODE in the keyword field ex. BARCODE[KYWD]
#Be sure to add your email address to line 31
#USAGE perl grab_many_gb_catch_errors_auto_COI1_year.plx 'x something.txt'

use strict;
use warnings;
use Bio::DB::EUtilities;

my $factory;
my $count;
my $hist;
my $retry;
my $out;
my $taxonlist;
my $filename;
my $term;
my @in;

open (IN, "<", $ARGV[0]) || die "Error cannot open infile: $!\n";
@in = <IN>;
$taxonlist = $in[0];
chomp $taxonlist;

$term = "(\"CO1\"[GENE] OR \"COI\"[GENE] OR \"COX1\"[GENE] OR \"COXI\"[GENE]) AND \"Eukaryota\"[ORGN] AND 2017[PDAT] AND \"BARCODE\"[KYWD]) AND (".$taxonlist.")";

$factory = Bio::DB::EUtilities -> new (-eutil => 'esearch',
										-email => '', ### Add your email here
										-db => 'nucleotide',
										-term => $term,
										-usehistory => 'y');

$count = $factory -> get_count;

#get history from queue
$hist = $factory -> next_History || die 'No history data returned';
print "History returned\n";

#db carries over from above
$factory -> set_parameters (-eutil => 'efetch',
							-rettype => 'gb',
							-history => $hist);

$retry = 0;
my ($retmax, $retstart) = (500,0);

$filename = $ARGV[0];
$filename =~ s/\.txt//;
$filename = $filename."_seqs.gb";

open ($out, ">", $filename) || die "Can't open file: $!\n";

RETRIEVE_SEQS:
while ($retstart < $count) {
	$factory -> set_parameters (-retmax => $retmax,
								-retstart => $retstart);
	
	eval {
		$factory -> get_Response (-cb => sub {
											my ($data) = @_;
											print $out $data
										 }
								 );
	};

	if ($@) {
		die "Server error : $@.  Try again later" if $retry == 5;
		print STDERR "Server error, redo #$retry\n";
		$retry++ && redo RETRIEVE_SEQS;
	}

	print "Retrieved $retstart\n";
	$retstart += $retmax;

}

close $out;

