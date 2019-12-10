#!/bin/bash
mkdir MEGAN_db
makeblastdb -in taxid_process/Marine_Euk_BOLD_NCBI_sl_reformatted.fasta -dbtype nucl -parse_seqids
