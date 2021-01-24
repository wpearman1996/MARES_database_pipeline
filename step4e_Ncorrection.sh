#!/bin/bash
seqkit -is replace -p "n+$" -r "" MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > term_Ngone_seqkit.fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < term_Ngone_seqkit.fasta > term_Ngone_seqkit_sl.fasta
seqkit -is replace -p "^n+|n+$" -r "" term_Ngone_seqkit_sl.fasta > trail_Ngone_seqkit.fasta
rm MARES_BAR_BOLD_NCBI_sl_reformatted.fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < trail_Ngone_seqkit.fasta > MARES_BAR_BOLD_NCBI_sl_reformatted.fasta
sed '1d' MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > tmpfile; mv tmpfile MARES_BAR_BOLD_NCBI_sl_reformatted.fasta
while read line; do echo $line | grep -v '>' | grep -o "[NACGT]" | sort | uniq -c \
| paste - - - - - ; echo $line | grep '>' | tr "\n" "\t" ; done < MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > basecounts.txt
Rscript NPerc.R -p 30 #change to percent N you want to remove greater than
grep -A1 -Ff NPercs.txt MARES_BAR_BOLD_NCBI_sl_reformatted.fasta > tmpfile.txt
mv tmpfile.txt MARES_BAR_BOLD_NCBI_sl_reformatted.fasta
