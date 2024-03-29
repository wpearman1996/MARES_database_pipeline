#!/bin/bash
### A large part of this script has copied and modified from https://doi.org/10.3897/mbmg.1.22262
### Modifications include removal of non-ascii characters to allow error free dereplication, and modification of sed scripts on line 14 and 16
## First specify the taxa of interest here - your bold and ncbi files must be names like ${database}_BOLD.fasta or  ${database}_NCBI.fasta

database="database"
###################################################################################################################################################################
######################################################     BOLD_NCBI_MERGER 0.1     #####################################################################
###################################################################################################################################################################

WORKING_DIR='tmp'
if [ -d "$WORKING_DIR" ]; then rm -rf $WORKING_DIR; fi
mkdir $WORKING_DIR

	# Write COI-5P (standard barcoding region) sequences into a new file: 
cat ./taxaBOLD/*bold.fasta > tmp/${database}_BOLD_tmp.fasta
	# Remove blacklisted accessions
sed 's#\(.*\)#/\1/,+1d#' blacklisted_accessions.txt > commands.sed
sed -f commands.sed tmp/${database}_BOLD_tmp.fasta > tmp/${database}_BOLD.fasta

LC_ALL=C awk '/^>/ { ok=index($0,"COI-5P")!=0;} {if(ok) print;}'  tmp/${database}_BOLD.fasta > tmp/${database}_BOLD_COI.fasta

	# Change BOLD & NCBI files so that usearch can dereplicate them without cutting the header:

LC_CTYPE=C && LANG=C cat tmp/${database}_BOLD_COI.fasta | sed 's/ /|/g' | sed 's/\t/|/g' > tmp/${database}_BOLD_COI_usearch.fasta

	# Remove blacklisted accessions
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < genbank_coi.fasta > genbank_coi_sl_temp.fasta
sed -f commands.sed genbank_coi_sl_temp.fasta > genbank_coi_sl.fasta

mv genbank_coi_sl.fasta ./tmp/${database}_NCBI.fasta
LC_CTYPE=C && LANG=C cat tmp/${database}_NCBI.fasta | sed 's/ /|/g' | sed 's/\t/|/g' > tmp/${database}_NCBI_usearch.fasta

	# concatenate BOLD and NCBI files

cat tmp/${database}_BOLD_COI_usearch.fasta tmp/${database}_NCBI_usearch.fasta > tmp/${database}_BOLD_NCBI_usearch.fasta


	#5 Use vsearch to dereplicate the sequences

#LC_CTYPE=C && LANG=C tr '-' 'N' < tmp/${database}_BOLD_NCBI_usearch.fasta > tmp/${database}_BOLD_NCBI_COI_N_replaced.fasta
sed -i "/^>/! {s/-/n/g; s/\(.*\)/\U\1/g}" tmp/${database}_BOLD_NCBI_usearch.fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < tmp/${database}_BOLD_NCBI_usearch.fasta > tmp.fasta
mv tmp.fasta tmp/${database}_BOLD_NCBI_usearch.fasta
seqkit -is replace -p "n+$" -r "" tmp/${database}_BOLD_NCBI_usearch.fasta > tmp/term_Ngone_seqkit.fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < tmp/term_Ngone_seqkit.fasta > tmp/term_Ngone_seqkit_sl.fasta
seqkit -is replace -p "^n+|n+$" -r "" tmp/term_Ngone_seqkit_sl.fasta > tmp/trail_Ngone_seqkit.fasta

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < tmp/trail_Ngone_seqkit.fasta > tmp.fasta
mv tmp.fasta tmp/${database}_BOLD_NCBI_COI_N_replaced.fasta

### Fix till here
# 5.1 Remove all the non-ascii characters
tr -cd "[:print:]\n" < ./tmp/${database}_BOLD_NCBI_COI_N_replaced.fasta > ./tmp/${database}_BOLD_NCBI_COI_N_replaced_nonascci.fasta
sed '1d' ./tmp/${database}_BOLD_NCBI_COI_N_replaced_nonascci.fasta > tmpfile; mv tmpfile ./tmp/${database}_BOLD_NCBI_COI_N_replaced_nonascci.fasta
vsearch -derep_fulllength tmp/${database}_BOLD_NCBI_COI_N_replaced_nonascci.fasta --output tmp/${database}_BOLD_NCBI_derep.fasta


	# Now change the headers so that Megan can read them later
mkdir database_${database}
cd ./database_${database}
LC_CTYPE=C && LANG=C tr '|' ' ' < ../tmp/${database}_BOLD_NCBI_derep.fasta > ./${database}_BOLD_NCBI_final.fasta
cd ..

WORKING_DIR='taxid_process'
if [ -d "$WORKING_DIR" ]; then rm -rf $WORKING_DIR; fi
mkdir $WORKING_DIR

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < ./database_${database}/${database}_BOLD_NCBI_final.fasta > ./taxid_process/${database}_BOLD_NCBI_final_sl.fasta
cd ./taxid_process
grep -e ">" ${database}_BOLD_NCBI_final_sl.fasta > seqnames_${database}_nobarcode.txt
