#!/bin/bash

database="database"

cd ./taxid_process
#grep -P -o " [0-9]+ " newnames3.txt > kraken_taxids.txt
sed -r 's/.* ([0-9]+\.*[0-9]*).*?/\1/' newnames3.txt > kraken_taxids.txt
sed -i 's/ //g' kraken_taxids.txt
sed -i -e 's/^/>kraken:taxid|/' kraken_taxids.txt
awk 'NR%2==0' ${database}_BOLD_NCBI_sl_reformatted.fasta | paste -d'\n' kraken_taxids.txt - > ${database}_BOLD_NCBI_sl_kraken.fasta
cd ..
kraken2-build --download-taxonomy --db mares 
cp ./cust_accession2taxid ./mares/taxonomy/cust.accession2taxid
kraken2-build --add-to-library ./taxid_process/${database}_BOLD_NCBI_sl_kraken.fasta --db mares
kraken2-build --build --db mares
