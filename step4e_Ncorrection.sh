#!/bin/bash

database="database"

cd ./taxid_process
#sed '1d' ${database}_BOLD_NCBI_sl_reformatted.fas.fasta > tmpfile; mv tmpfile ${database}_BOLD_NCBI_final_sl.fasta
perl ../perl_NCounter.pl ${database}_BOLD_NCBI_sl_reformatted.fasta > basecounts.txt
grep ">" ${database}_BOLD_NCBI_sl_reformatted.fasta > ${database}_reform.txt
Rscript ../NPerc.R -p 10 #change to percent N you want to remove greater than
seqtk subseq ${database}_BOLD_NCBI_sl_reformatted.fasta NPercs.txt > tmpfile.txt
mv tmpfile.txt ${database}_BOLD_NCBI_sl_reformatted.fasta

mkdir ../${database}
cp Lunella_BOLD_NCBI_sl_reformatted.fasta ../${database}/${database}_db.fasta
