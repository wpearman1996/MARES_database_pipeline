#!/usr/bin/perl
#Be sure to update the hard coded path to names.dmp on line 29; path to nodes.dmp on line 30
#names.dmp and nodes.dmp comes from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz and these files should be kept current
#Script to use a list of taxonids to grab the name at each rank for lineage
#USAGE perl taxonomy_craw_for_genus_species_list.plx taxonomy.taxid

use Bio::LITE::Taxonomy::NCBI;
use strict;
use warnings;

#declare var
my $taxDB;
my $genus='';
my $i=0;
my $taxid;
my $species='';
my $words;

#declare array
my @taxids;
my @species;

$taxDB = Bio::LITE::Taxonomy::NCBI->new(		db	=>	"nt",
												names	=>	"/path/to/ncbi-blast-2.4.0+/db/names.dmp",
												nodes	=>	"/path/to/ncbi-blast-2.4.0+/db/nodes.dmp");  ### be sure to keep *.dmp files current ###

open (IN,"<",$ARGV[0]) || die "Error cannot read in taxid infile: $!|n";
@taxids = <IN>;
close IN;

open (OUT,">>","Genus_species.txt") || die "Error cannot write to taxid.parsed: $!\n";


while ($taxids[$i]) {
	$taxid = $taxids[$i];
	chomp $taxid;
	$species = $taxDB->get_term_at_level($taxid,"species");#new


	if (defined $species && length $species > 0) {
		if ($species !~ /(sp\.|nr\.|aff\.|cf\.)/) {
			@species = split(/ /, $species);
			$words = scalar(@species);
			if ($words == 2 ) {
				$genus = $species[0];
				$species = $species[1];
				print OUT "$genus\t$species\n";
			}
		}
	}

	$i++;
	$taxid=();
	$genus='';
	$species='';
	@species=();
	$words=();

}
$i=0;
