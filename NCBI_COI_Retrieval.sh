## it might be wise to make a new conda environment for this to install all the dependenies into to avoid any issues - especially if you're
## a bioinformatics guru

##### Much of this process is based on https://github.com/terrimporter/COI_NCBI_2018 to download COI sequences from NCBI
##### additionally many of the scripts have been modified or copied from the above repository.
##### First step is we decide on what taxonomy we wish to work with
##### once we have this list, we have to retrieve the taxonomy information for this. 
##### This is done by using the following scripts (modified from terrimporter/COI_NCBI_2018)
sed 's/$/[ORGN]+AND+species[RANK]/' taxa.list > taxa.list_ebot 
#change directory into a new folder - since we're about to fill it up with as many files as there are taxa
#!/bin/bash
while IFS= read -r line; do
  perl ../COI_NCBI_2018/Scripts/ebot_taxonomy3.plx "$line" "$line"
done < ../taxa.list_ebot

cat * > ../taxonomy.taxid

### Now we convert these to genus_species, this requires the modification of the script to include the location of the 
### nodes.dmp and names.dmp from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

perl taxonomy_crawl_for_genus_species_list.plx taxonomy.taxid

mkdir taxids
cd taxids
split -l 100 ../Genus_species.txt

### Now what we're doing is reformatting the list so that it works for NCBI Entrez and then doing
### some directory admin
ls | grep '^x' | parallel -j 23 "perl ../COI_NCBI_2018/Scripts/reformat_list_for_entrez_taxonomy.plx {}"
mkdir reformatted_taxids
mv *.txt reformatted_taxids/.
mv reformatted_taxids/Genus_species.txt .
mkdir original_split_taxids
mv x* original_split_taxids/.
cd reformatted_taxids

#### Here we download all relevant genbank files

ls | grep .txt | parallel -j 1 "perl /home/william/vanessawork/database_paper_work_30Sept/COI_NCBI_2018/Scripts/grab_many_gb_catch_errors_auto_CO1_year.plx {}"

#### Now we'll cat them together and convert to fasta using the script from: https://rocaplab.ocean.washington.edu/tools/genbank_to_fasta/

for FILE in *gb
do
echo $FILE 
python2 genbank_to_fasta.py -i $FILE -o ${FILE/gb/fasta} -s whole -d 'pipe' -a 'accessions,organism'
gzip $FILE
done

cat *.fasta > ../genbank_coi.fasta
cd ..
cp ./genbank_coi.fasta ../
cd ..
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < genbank_coi.fasta > genbank_coi_sl.fasta
