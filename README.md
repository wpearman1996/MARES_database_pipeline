# custom_metabarcoding_databases

These scripts are designed to be run using a linux OS, and were developed on Ubuntu 16.04. If you use windows, you may be able to use the windows linux subsystem (https://docs.microsoft.com/en-us/windows/wsl/install-win10) but you may have additional dependencies to install that aren't covered by this list below.
![Flowchart](https://github.com/wpearman1996/custom_metabarcoding_databases/blob/master/Flowchart_metabarcodingdb.svg)
*Bioinformatic pipeline for generating a custom reference database combining sequences retrieved from BOLD and GenBank for a taxonomic group of interest. Shaded boxes detail the workflow for each numbered step described in the methods and the name of the script required for each step. Smaller open boxes describe the subroutines including the functions, packages, and software required (in italics). Boxes with solid outlines indicate input files and boxes with dotted-lined boxes indicate the output files. Asterisks indicate original contributions to the MARES pipeline*
## step 1: NCBI COI Retrieval

First, it is necessary to make a taxa.list file - this file contains the list of taxa that you're interested in. You can use different lists for BOLD or NCBI, or the same for both. You will need to modify a few scripts to make this work for you.
Specifically, ebot_taxonomy3.plx needs to be modified on line 86 to include your email.
Additionally, you will need to modify the taxonomy_crawl_for_genus_species_list.plx to index the correct location of the nodes.dmp and names.dmp files from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
You may wish to modify grab_many_gb_catch_errors_auto_CO1_year.plx to change the search terms to include additional genes, or keywords (line 29).
Finally, you will want to modify NCBI_COI_Retrieval.sh on line 29 to change -j to the number of threads you wish to run, if you are not using an NCBI API key then you can probably only run 1 or 2 threads, as you will likely exceed the maximum requests per second without this API key.
Then, we want to run the NCBI_COI_Retrieval.sh script which does the following:
1.	Convert your list of taxa, into a list of taxids for every species within your taxa.list. I.e "Chordata" will be turned into a list of taxids for every species in Chordata.
2.	Convert taxids to binomial names to search for in NCBI.
3.	Searches genbank and downloads all relevant genbank files.


## step 2: BOLD Retrieval

For BOLD retrieval you will want to run the R script retrieve_bold.r. You may need to make modifications to this file. Specifically, this script takes a list of taxa and retrieves the BOLD data, and formats this data as a fasta file. This can take a while for large taxonomic groups, and may timeout when connecting to BOLD if you do not have large amounts of RAM.

If this does become problematic, it may be wise to remove this group from your taxlist, replacing it with the subtaxa for that group to avoid timing out. It is for this reason we have two taxlist_bold files in our example.

## step 3: The BOLD_NCBI merger

The BOLD_NCBI merger step is based largely on Macher J, Macher T, Leese F (2017) Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger. Metabarcoding and Metagenomics 1: e22262. https://doi.org/10.3897/mbmg.1.22262

This process takes the BOLD file, ensures it is for the COI-5P region, and processes the names to enable dereplication of sequences and merges sequences into a single file. At this point the files are dereplicated to remove duplicated sequences. Last, the headers are reformatted, and the sequences converted to single line fastas.
You may need to modify Step3_merge_bold_ncbi.sh on line 6 to specify the taxon name for your reference database


## step 4: Normalise taxonomy IDs

To normalise the taxonomic IDs we first need to export a list of sequence names from the merged database.
Because many pipelines and software use lowest common ancestor approaches for taxonomic classifications, these tools often utilize on the NCBI taxonomy. However, many species don't have taxids, or have been uploaded with synonyms as names - making the retrieval of reliable taxonomic classifications difficult.

Next, we identifies any synonyms and updates them so that all species within the database have the same name, and identifies the appropriate taxids. If a taxa does not have a taxid, we then take the first word, generally the genus, and checks this for taxids - and then update the classification to be at the genus level if a match is found. Last,  if the taxa still has no taxid, it is removed from the database.


We then update the sequence names with the new taxids and rename the fasta file Marine_Euk_BOLD_NCBI_sl_reformatted.fasta which is now our completed database. 

To do this step, use the taxid_addition.r script. You will need to edit this script to modify directories etc, as well as to ensure the appropriate packages are installed.
 

## Step 5: Format for taxonomy classifiers

### 5a : Prepare to KRAKEN 
At this point, we want to format our database for taxonomic classification using kraken. For this to work the header for each fasta needs to be reformatteded to kraken:taxid|{taxid} and we then provide scripts to generate the database.

Note: At the time of writing, the conda installation of kraken2 is not compatible due to changes with the ncbi taxonomy files. The recent version on github has been updated - so please use this installation.

### 5b : Prepare to MEGAN 

In this step, we built a local database from our custom reference database and blast it against your metabarcoding sample file.

The fasta file containing your sample file (query.fasta) should be added to the custom_metabarcoding_database folder. And modify the Blast parameters as you prefer in line 17. 

The output is a .txt file in the MEGAN_db folder that can be imported into MEGAN (Husson et al. 2007) for taxonomic assignment.  

## Technical Validation

## Accessibility
Copies of each database and the list of taxa in each database (used in the techical validation) are available on the Open Science Framework with the following link: https://osf.io/8rdqk/

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
`BLAST+`
`cpanminus`
`biopython`
`Bio::Lite::Taxonomy::NCBI`
`Bio::DB::EUtilities`
`HTTP::Date`
`LWP::Simple`
`LWP::UserAgent`
`parallel`
`perl`
`r`
`python2`
`seqtk`
`Kraken`
