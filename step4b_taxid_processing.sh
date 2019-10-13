#!/bin/bash
#After executing the R script - we then process the sequences
sed 's/^.\{1\}//' seqs_oldnames.txt > seqs_oldnames2.txt
sed 's/^.\{1\}//' seqs_newnames.txt > seqs_newnames2.txt
sed -i -e 's/^/>/' seqs_newnames2.txt
seqtk subseq Marine_Euk_BOLD_NCBI_final_sl.fasta seqs_oldnames2.txt > Marine_Euk_BOLD_NCBI_sl_s4.fasta 
awk 'NR%2==0' Marine_Euk_BOLD_NCBI_sl_s4.fasta | paste -d'\n' seqs_newnames2.txt - > Marine_Euk_BOLD_NCBI_sl_reformatted.fasta
