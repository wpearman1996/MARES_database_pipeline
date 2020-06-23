If you're here and wanting to use MARES, i've compiled a brief tutorial here on how to get started. I've written this with the assumption that all the dependencies are installed, if there's interest - i'll try to try a tutorial on how to install the dependencies.
***Set up and running*** 
1) First run the following command to download MARES

`git clone wpearman1996/MARES_database_pipeline` 

2) Modify the following files

`taxa.list` - include the list of taxa you want here. 

`./coi_ret_ebot_taxonomy3.plx` - line 86 will require your email added to it.

`./coi_ret/grab_many_gb_catch_errors_auto_CO1_year.plx` - line 32 requires your email too, you may also wish to modify the search terms on line 29.

`./coi_ret/taxonomy_crawl_for_genus_species_list.plx` - lines 29 and 30 require location of names and nodes dmp files ( ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz. )

`step4a_taxid_addition.r` - line 75 requires nodes and names dmp file locations

`blacklist_accessions.txt` - if there are certain NCBI or bold accessions you wish to exclude then you can list them here. Theoretically this may work on excluding certain taxa, however this has not been tested. If you're interested in us adding that as a function of MARES - either email us, or log an issue.

`step6_marine_contaminants_checker.R` -  lines 5 & 6 to point to WoRMS taxon list & contaminant list, lines 10 or 34 to point to Kraken or Megan output, and line 24 to point to the names.dmp file.

*** Running the pipeline *** 

1) Execute `step1_NCBI_COI_Retrieval.sh` - you may need to modify the permissions to make it executable using `chmod +x step1_NCBI_COI_Retrieval.sh` 

2) Execute `step2_retrieve_bold.r` through `Rscript step2_retrieve_bold.r`. I personally prefer to run this through RStudio myself and execute it line by line, but that's a personal preference. If you're having issues with this, try running it line-by-line to work out where the issue is or file an issue and we'll try to resolve it.

3) Execute `step3_merge_bold_ncbi.sh` similar to above, you may need to modify the permissions using `chmod +x step3_merge_bold_ncbi.sh`

4) Execute `step4a_taxid_addition.r` through `Rscript step4a_taxid_addition.r`. As with all R Scripts in this pipeline, I prefer to run these scripts line-by-line in RStudio. 

5) Execute `step4b_taxid_generation.sh` similar to above, you may need to modify the permissions using `chmod +x step4b_taxid_generation.sh`

6) Execute `step4c_taxid_processing.r` 

7) Execute `step4d_taxid_processing.sh` - and then you'll have a fasta file you can format for kraken or megan using the 
`step5_make_krakendb.sh`  or `step5b_prepare_to_MEGAN.sh	` scripts. 
