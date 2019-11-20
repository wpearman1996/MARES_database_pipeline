#!/bin/bash

#taxon= "Marine_Euk"
#query= "query"

#1. Build a database

mkdir MEGAN_db
makeblastdb -in taxid_process/Marine_Euk_BOLD_NCBI_sl_reformatted.fasta -dbtype nucl -parse_seqids

#2. Blast the fasta file containing your metabarcoding sequences against the database you just built. Adjust blast settings according to your needs

echo
echo "Query: query.fasta"
echo "Starting blast"

blastn -db taxid_process/Marine_Euk_BOLD_NCBI_sl_reformatted.fasta -query query.fasta -evalue 1e-60 -max_target_seqs 10 -outfmt 5 -out MEGAN_db/Marine_Euk_NCBI_BOLD_MEGAN.txt -num_threads 12

if [ -f "MEGAN_db/Marine_Euk_NCBI_BOLD_MEGAN.txt" ]; then
	echo
	echo "Finished blast"
	echo "Output: MEGAN_db/Marine_Euk_NCBI_BOLD_MEGAN.txt"
	echo "Output can now be imported to Megan"
	echo
	echo "Cleaning temporary files"
	#rm tmp/*.fasta
	echo
	echo "Finished"
fi
