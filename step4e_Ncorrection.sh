#!/bin/bash
cd ./taxid_process
#sed '1d' MARES_BAR_BOLD_NCBI_sl_reformatted.fas.fasta > tmpfile; mv tmpfile Marine_Euk_BOLD_NCBI_final_sl.fasta 
perl ../perl_NCounter.pl MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > basecounts.txt
grep ">" MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > seqnames_mares_reform.txt
Rscript ../NPerc.R -p 10 #change to percent N you want to remove greater than
seqtk subseq MARES_BAR_BOLD_NCBI_sl_reformatted.fasta NPercs.txt > tmpfile.txt
mv tmpfile.txt MARES_BAR_BOLD_NCBI_sl_reformatted.fasta

