# custom_metabarcoding_databases

## step 1: NCBI COI Retrieval

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

## step 2: BOLD Retrieval
For this part you will want to run the R script `retrieve_bold.r`. You may need to make modifications to this file. Specifically this script takes a list of taxa and retrieves the BOLD data, and formats this data into a fasta file. This can take a while and may be problematic if you do not have large amounts of RAM. 

Specifically if you are trying to obtain sequences for a large taxonomic group, then this file may be very large or even timeout when connecting to BOLD. In this case it may be wise to replace your taxlist without this group, and instead list each subtaxa so that each subtaxa is retrieved separately to avoid timing out. 

## step 3: merger

This part is largely taken and modified from `Macher J, Macher T, Leese F (2017) Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger. Metabarcoding and Metagenomics 1: e22262. https://doi.org/10.3897/mbmg.1.22262`

This process takens the BOLD file and ensures it is for the COI-5P region. Then it processes the names to enable dereplication sequences and merges them into a single file. At this point the files are dereplicated to remove duplicated sequences. Now the headers are changed to an appropriate format, and then we convert them to single line fastas.

## step 4: process for taxids
The first step is to export a list of sequence names from the merged database

Because many tools using lowest common ancestor approaches for taxonomic classifications, these tools often rely on the NCBI taxonomy. However, many species don't have taxids, or have been uploaded with synonyms as names - this makes it problematic to get reliable taxonomic classifications.

This step identifies any synonyms and updates them so that all species within the database have the same name, and identifies the approach taxids. If a taxa does not have a taxid, we them take the first word, generally the genus, and checks this for taxids - and then updates the classification to be at the genus level rather than species. Finally if the taxa still has no taxid, it is completely dropped from the database.  

Then we generate two lists of sequence names - the first is the original sequence names, for sequences that have taxids. The second is the new set of names for the sequences, that now are in a standardized format, with taxid included in the seq name.
We use these lists to rename and generate a new fasta called `Marine_Euk_BOLD_NCBI_sl_reformatted.fasta` which is now our completed database.

To do this step use the `taxid_addition.r` script. You will need to edit this script to modify directories etc, as well as to ensure the appropriate packages are installed. 

## Step 5
At this point we want to format it for a kraken database. For this to work the header for each fasta needs to be `kraken:taxid|{taxid}`. Here we format the fasta to have this structure and then provide instructions on how to build the database.

# Database Comparison

# Dependency List
## R packages
`stringr`
`rvest`
`httr`
`taxize`
`dplyr`
`bold`

## Other dependencies
`vsearch`
`cpanminus`
`biopython`
`Bio::Lite::Taxonomy::NCBI`
`Bio::DB::EUtilities`
`parallel`
`perl`
`r`
`python2`

`seqtk`
