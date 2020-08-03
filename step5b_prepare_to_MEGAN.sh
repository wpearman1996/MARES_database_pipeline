#!/bin/bash
cut -f1 -d" " MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > MARES_BAR_BOLD_NCBI_sl_reformatted_blast.fasta
awk 'NR % 2 == 1' MARES_NOBAR_BOLD_NCBI_sl_reformatted.fasta | sed 's|[>,]||g' - > MARES_informative_name_table.tsv
awk 'NR % 2 == 1' MARES_BAR_BOLD_NCBI_sl_reformatted.fasta  | awk -F" " '{print $(NF-1)}' > mares_taxids.txt
awk 'NR % 2 == 1' MARES_BAR_BOLD_NCBI_sl_reformatted_blast.fasta | sed 's|[>,]||g' - > seqnames_mares.txt
paste seqnames_mares.txt mares_taxids.txt | column -s $' ' -t > cust_taxid_map
makeblastdb -in MARES_BAR_BOLD_NCBI_sl_reformatted_blast.fasta -dbtype nucl -taxid_map cust_taxid_map -parse_seqids -out MARES_BAR.db
mkdir ../MEGAN_db
mv MARES_BAR.db* ../BAR_MEGAN_db
