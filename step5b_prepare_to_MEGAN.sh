#!/bin/bash

database="database"

cd taxid_process
cut -f1 -d" " ${database}_BOLD_NCBI_sl_reformatted.fasta > ${database}_BAR_BOLD_NCBI_sl_reformatted_blast.fasta
awk 'NR % 2 == 1' ${database}_BOLD_NCBI_sl_reformatted.fasta | sed 's|[>,]||g' - > ${database}_informative_name_table.tsv
awk 'NR % 2 == 1' ${database}_BOLD_NCBI_sl_reformatted.fasta  | awk -F" " '{print $(NF-1)}' > m${database}_taxids.txt
awk 'NR % 2 == 1' ${database}_BOLD_NCBI_sl_reformatted_blast.fasta | sed 's|[>,]||g' - > ${database}_seqnames.txt
paste ${database}_seqnames.txt ${database}_taxids.txt > cust_taxid_map

makeblastdb -in ${database}_BOLD_NCBI_sl_reformatted_blast.fasta -dbtype nucl -taxid_map cust_taxid_map -parse_seqids -out ${database}.db
mkdir ../MEGAN_db
mv ${database}.db* ../MEGAN_db
