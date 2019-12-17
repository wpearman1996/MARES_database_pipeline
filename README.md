# custom_metabarcoding_databases

These scripts support the MARES (MARine Eukaryote Species) pipeline used to create the MARES database of COI sequences for metabarcoding studies (presented in Arranz, Pearman, Aguirre, Liggins, in prep.). The scripts are designed to be run using a Linux OS, and were developed on Ubuntu 16.04. If you use windows, you may be able to use the Windows Linux subsystem (https://docs.microsoft.com/en-us/windows/wsl/install-win10) but you may have additional dependencies to install that aren't covered by the list below. 

![Flowchart](https://github.com/wpearman1996/custom_metabarcoding_databases/blob/master/Flowchart_metabarcodingdb.svg)
*The MARES bioinformatic pipeline for generating a custom reference database combining sequences retrieved from the Barcode of Life Database (BOLD) and NCBI for a taxonomic group of interest. Shaded boxes detail the workflow within each step and the names of the scripts required. Smaller open boxes describe the subroutines including the functions, packages, and software required (in italics). Boxes with solid outlines indicate input files and boxes with dotted-lined boxes indicate the output files. Many of the scripts and functions used in the MARES pipeline were developed by others; asterisks denote the original contributions of the MARES pipeline.*

## Step 1: NCBI COI Retrieval
First, it is necessary to make a taxa.list file - this file contains the list of taxa that you're interested in. You can use different lists for BOLD or NCBI, or the same for both. You will need to modify a few scripts to make this work for you.
Specifically, ebot_taxonomy3.plx needs to be modified on line 86 to include your email address.

Additionally, you will need to modify the taxonomy_crawl_for_genus_species_list.plx to index the correct location of the nodes.dmp and names.dmp files from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

You may wish to modify grab_many_gb_catch_errors_auto_CO1_year.plx to change the search terms to include additional genes, or keywords (line 29).

Finally, you will want to modify NCBI_COI_Retrieval.sh on line 29 to change -j to the number of threads you wish to run. If you are not using an NCBI API key then you can probably only run 1 or 2 threads, as you will likely exceed the maximum requests per second without this API key.

Then, we want to run the NCBI_COI_Retrieval.sh script which does the following:
1.	Converts your list of taxa (i.e. taxa.list) into a list of taxids for every species. For example, "Chordata" will be turned into a list of taxids for every species found in Chordata.
2.	Converts taxids to binomial names that can be searched for in NCBI.
3.	Searches NCBI and downloads all relevant genbank files (.gb format) .


## Step 2: BOLD Retrieval

For BOLD retrieval you will want to run the R script retrieve_bold.r. You may need to make modifications to this file. Specifically, this script takes a list of taxa and retrieves the BOLD data, and formats this data as a fasta file. This can take a while for large taxonomic groups, and may timeout when connecting to BOLD if you do not have large amounts of RAM.

If this does become problematic, it may be wise to remove this group from your taxlist, replacing it with the subtaxa for that group to avoid timing out. It is for this reason we have two taxlist_bold files in our example.

## Step 3: The BOLD_NCBI merger

The BOLD_NCBI merger step is based largely on Macher J, Macher T, Leese F (2017) Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger. Metabarcoding and Metagenomics 1: e22262. https://doi.org/10.3897/mbmg.1.22262

This process takes the BOLD file, ensures it is for the COI-5P region, and processes the names to enable dereplication of sequences and the merging of sequences into a single file. Last, the headers are reformatted, and the sequences converted to single line fasta format.
You may need to modify Step3_merge_bold_ncbi.sh on line 6 to specify the taxon name for your reference database.

## Step 4: Normalise taxonomy IDs

To normalise the taxonomic IDs we first need to export a list of sequence names from the merged database.

Many pipelines and software use lowest common ancestor approaches for taxonomic classification, and rely on the NCBI taxonomy to do this.  However, many species don't have taxids in NCBI or have been uploaded with synonyms as names, making the retrieval of reliable taxonomic classifications difficult.

In our pipeline, we identify any synonyms and consolidate them so that each taxon has only one name, and is provided with the appropriate taxid. If a taxon does not have a taxid assigned, we then take the first word, generally the genus, and check it for a matching taxid, updating the classification to the genus level if a match is found. Last,  if the taxon still has no taxid, it is removed from the database.

We then generate two lists of sequence names - the first is the original sequence names, for sequences that have taxids. The second is the new set of names for the sequences, that now are in a standardized format, with taxid included in the seq name. We use these lists to rename and generate a new fasta called Marine_Euk_BOLD_NCBI_sl_reformatted.fasta which is now our completed database.
To do this step, use the taxid_addition.r script. You will need to edit this script to modify directories, as well as to ensure the appropriate packages are installed.

 

## Step 5: Format for taxonomy classifiers

### 5a : Prepare to KRAKEN 
At this point, we want to format our database for taxonomic classification using kraken. For this to work the header for each fasta needs to be reformatted to kraken:taxid|{taxid} and then provide instructions on how to build the database.  

Note: At the time of writing, the conda installation of kraken2 was not compatible with this pipeline, due to changes in the NCBI taxonomy files . The recent version of Kraken2 on github has been updated  - so please use this installation.

### 5b : Prepare to MEGAN 

In this step, we built a local database from our custom reference database and blast it against your metabarcoding sample file.

The fasta file containing your sample file (query.fasta) should be added to the custom_metabarcoding_database folder. Modify the blast parameters according to your preference in line 17.

The output is a .txt file in the MEGAN_db folder that can be imported into MEGAN (Husson et al. 2007) for taxonomic assignment. 


## Technical Validation

## Accessibility
Copies of the MARES databases (as fasta files) and the list of taxa in each database (used in the technical validation) are available on the Open Science Framework with the following link: https://osf.io/8rdqk/

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

## Citations and Acknowledgements

Macher, Jan-Niklas, Till-Hendrik Macher, and Florian Leese. "Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger." Metabarcoding and Metagenomics 1 (2017): e22262.

Porter, Teresita M., and Mehrdad Hajibabaei. "Over 2.5 million COI sequences in GenBank and growing." PloS one 13.9 (2018): e0200177.

The genbank_to_fasta.py script was developed by the Rocap Lab https://rocaplab.ocean.washington.edu/

## Questions
If there are any questions or issues - please email William Pearman (wpearman1996@gmail.com) or Vanessa Arranz (vanearranz@hotmail.com), or alternatively leave comment on this repository.

Please refer to the publication: Arranz, Pearman, Aguirre, Liggins. MARES: [insert title from updated draft!]. In preparation
