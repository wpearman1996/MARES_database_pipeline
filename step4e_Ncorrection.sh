#!/bin/bash
cd ./taxid_process
sed '1d' Marine_Euk_BOLD_NCBI_final_sl.fasta > tmpfile; mv tmpfile Marine_Euk_BOLD_NCBI_final_sl.fasta 
perl ../perl_NCounter.pl Marine_Euk_BOLD_NCBI_final_sl.fasta > basecounts.txt
grep ">" Marine_Euk_BOLD_NCBI_final_sl.fasta > seqnames_mares_reform.txt
Rscript ../NPerc.R -p 10 #change to percent N you want to remove greater than
seqtk subseq Marine_Euk_BOLD_NCBI_final_sl.fasta NPercs.txt > tmpfile.txt
mv tmpfile.txt MARES_BAR_BOLD_NCBI_sl_reformatted.fasta

