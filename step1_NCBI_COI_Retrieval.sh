#!/bin/bash
## it might be wise to make a new conda environment for this to install all the dependenies into to avoid any issues - especially if you're
## a bioinformatics guru
##### Much of this process is based on https://github.com/terrimporter/COI_NCBI_2018 to download COI sequences from NCBI
##### additionally many of the scripts have been modified or copied from the above repository.
##### First step is we decide on what taxonomy we wish to work with
##### once we have this list, we have to retrieve the taxonomy information for this. 
##### This is done by using the following scripts (modified from terrimporter/COI_NCBI_2018)
sed 's/$/[ORGN]+AND+species[RANK]/' taxa.list > taxa.list_ebot 
#change directory into a new folder - since we're about to fill it up with as many files as there are taxa

WORKING_DIR='taxaNCBI'
if [ -d "$WORKING_DIR" ]; then rm -rf $WORKING_DIR; fi
mkdir $WORKING_DIR
mv taxa.list_ebot $WORKING_DIR
cd $WORKING_DIR

while IFS= read -r line; do
  perl ../coi_ret/ebot_taxonomy3.plx "$line" "$line"
done < ./taxa.list_ebot

cat taxonomy.taxid* > ./taxonomy.taxid

### Now we convert these to genus_species, this requires the modification of the script to include the location of the 
### nodes.dmp and names.dmp from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

perl ../coi_ret/taxonomy_crawl_for_genus_species_list.plx taxonomy.taxid > Genus_species.txt

WORKING_DIR='../taxids'
if [ -d "$WORKING_DIR" ]; then rm -rf $WORKING_DIR; fi
mkdir $WORKING_DIR
mv Genus_species.txt $WORKING_DIR
cd $WORKING_DIR

split -l 100 Genus_species.txt

### Now what we're doing is reformatting the list so that it works for NCBI Entrez and then doing
### some directory admin
ls | grep '^x' | parallel -j 2 "perl ../coi_ret/reformat_list_for_entrez_taxonomy.plx {}"
mkdir reformatted_taxids
mv *.txt reformatted_taxids/.
mv reformatted_taxids/Genus_species.txt .
mkdir original_split_taxids
mv x* ./original_split_taxids/.
cd reformatted_taxids

#### Here we download all relevant genbank files

ls | grep .txt | parallel -j 1 "perl ../../coi_ret/grab_many_gb_catch_errors_auto_CO1_year.plx {}"
gunzip *_seqs.gb.gz 
#### Now we'll cat them together and convert to fasta using the script from: https://rocaplab.ocean.washington.edu/tools/genbank_to_fasta/

for FILE in *.gb
do
echo $FILE
outputFile=`echo "$FILE" | cut -d'.' -f1`
outputFile="${outputFile}.fasta"
python3 ../../genbank_to_fasta.py -i $FILE -o $outputFile -s 'whole' -d 'pipe' -a 'accessions,organism'
gzip $FILE
done

WORKING_FILE='../../genbank_coi.fasta'
if [ "$WORKING_FILE" ]; then rm $WORKING_FILE; fi
cat *.fasta > $WORKING_FILE

cd ../../
#awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < genbank_coi.fasta > genbank_coi_sl_temp.fasta
#sed 's#\(.*\)#/\1/,+1d#' blacklisted_accessions.txt > commands.sed
#sed -f commands.sed genbank_coi_sl_temp.fasta > genbank_coi_sl.fasta