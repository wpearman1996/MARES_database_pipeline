#!/bin/bash
makeblastdb -in taxid_process/MARES_BAR_BOLD_NCBI_sl_reformatted.fasta -dbtype nucl -parse_seqids -out MARES_BAR.db
mkdir ../MEGAN_db
mv MARES_BAR.db* ../BAR_MEGAN_db
