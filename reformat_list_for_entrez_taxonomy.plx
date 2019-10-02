#!/usr/bin/perl
#May 14, 2012 by Teresita Porter
#Script to reformat Genus_species.txt into a form that can be used with grab_many_gb_catch_errors_auto_CO1_year.plx
#USAGE perl reformat_list_for_entrez_taxonomy.plx 'x files'

use strict;
use warnings;

#declare var
my $i=0;
my $line;
my $genus;
my $species;
my $max; #total number of species
my $target; #index number of last species in array
my $filename; #generate custom filename

#declare array
my @in;
my @line;

open (IN, "<", $ARGV[0]) || die "Error cannot open infile: $!\n";
@in = <IN>;
close IN;

$filename = $ARGV[0].".txt";

open (OUT, ">>", $filename) || die "Error cannot open outfile: $!\n";

$max = scalar(@in);
$target = $max-1;

while ($in[$i]) {
	$line = $in[$i];
	chomp $line;

	@line = split(/\t/,$line);
	$genus = $line[0];
	$species = $line[1];

	if ($i < $target) {
		print OUT "\"$genus $species\"[Organism] OR ";
	}
	elsif ($i == $target) {
		print OUT "\"$genus $species\"[Organism]";
	}

	$i++;
	$line=();
	@line=();
	$genus=();
	$species=();
}
$i=0;

close OUT;
