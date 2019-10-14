#!/bin/bash
cd ./taxid_process
#After executing the R script - we then process the sequences
sed 's/^.\{1\}//' seqs_oldnames.txt > seqs_oldnames2.txt
sed 's/^.\{1\}//' seqs_newnames.txt > seqs_newnames2.txt
#sed -i -e 's/^/>/' seqs_newnames2.txt
#sed -i -e 's/^/>/' seqs_oldnames2.txt
seqtk subseq Marine_Euk_BOLD_NCBI_final_sl.fasta seqs_oldnames2.txt > Marine_Euk_BOLD_NCBI_sl_s4.fasta
grep ">" Marine_Euk_BOLD_NCBI_sl_s4.fasta > sl_s4_seqnames.txt
sed -i -e 's/>//' sl_s4_seqnames.txt
Rscript ../newname_filt.r
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < ./Marine_Euk_BOLD_NCBI_sl_s4.fasta > ./Marine_Euk_BOLD_NCBI_final_sl_s5.fasta
tail -n +2 Marine_Euk_BOLD_NCBI_final_sl_s5.fasta > Marine_Euk_BOLD_NCBI_final_sl_s6.fasta
#awk 'BEGIN {RS = ">" ; FS = "\n" ; ORS = ""} {if ($2) print ">"$0}' Marine_Euk_BOLD_NCBI_final_sl_s6.fasta > Marine_Euk_BOLD_NCBI_final_sl_s7.fasta
awk 'NR%2==0' Marine_Euk_BOLD_NCBI_final_sl_s6.fasta | paste -d'\n' newnames3.txt - > Marine_Euk_BOLD_NCBI_sl_reformatted.fasta
