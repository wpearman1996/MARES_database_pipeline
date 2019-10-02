# custom_metabarcoding_databases

# step 1: NCBI COI Retrieval

First it is necessary to make a taxa.list file - this file contains a list of taxa that you're interested in. You can use different lists
for BOLD or NCBI, or the same for both. You will need to modify a few scripts to make this work for you. 
Specifically `ebot_taxonomy3.plx` needs to be modified on line 86 to include your email
Additionally you will need to modify the `taxonomy_crawl_for_genus_species_list.plx` to point to the correct location of the nodes.dmp and names.dmp files from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
You may wish to modify `grab_many_gb_catch_errors_auto_CO1_year.plx` to change the search terms to include additional genes, or keywords (line 29).
Finally you will want to modify  `NCBI_COI_Retrieval.sh` on line 29 to change -j to the number of threads you wish to run, if you are not using an NCBI API key then you can probably only run 1 or 2 threads, as you exceed the maximum requests per second without this API key. 
Then we want to run the `NCBI_COI_Retrieval.sh` script. 
This does the following:
1) Converts your list of taxa, into a list of taxids for every species within your taxa list. I.e "Chordata" will be turned into a list of taxids for every species in Chordata.
2) Converts to binomial names.
3) Prepares names into search terms for NCBI.
4) Searchs genbank and downloads ALL relevant genbank files.
