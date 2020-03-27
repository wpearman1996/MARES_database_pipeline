# Building custom reference databases for metabarcoding
This pipeline can be used to develop a de-contamination database (i.e used to create a database of potential contaminants), or as a database for general purpose metabarcoding. We have provided three databases - a very small database composed of common contaminants (i.e human, sheep, goat, flies etc), as well as two metabarcoding databases for marine eukaryotes. 

These scripts support the MARES (MARine Eukaryote Species) pipeline used to create the MARES database of COI sequences for metabarcoding studies (presented in Arranz, Pearman, Aguirre, Liggins, in prep.). The scripts are designed to be run using a Linux OS, and were developed on Ubuntu 16.04. If you use windows, you may be able to use the Windows Linux subsystem (https://docs.microsoft.com/en-us/windows/wsl/install-win10) but you may have additional dependencies to install that aren't covered by the list below. 

![Flowchart](https://github.com/wpearman1996/custom_metabarcoding_databases/blob/master/Flowchart_metabarcodingdb.svg)
*The MARES bioinformatic pipeline for generating a custom reference database combining sequences retrieved from the Barcode of Life Database (BOLD) and NCBI for a taxonomic group of interest. Shaded boxes detail the workflow within each step and the names of the scripts required. Smaller open boxes describe the subroutines including the functions, packages, and software required (in italics). Boxes with solid outlines indicate input files and boxes with dotted-lined boxes indicate the output files. Many of the scripts and functions used in the MARES pipeline were developed by others; asterisks denote the original contributions of the MARES pipeline.*
## Data Processing and Database Construction
We suggest that users ensure their database is representative of not only the taxa they expect to encounter, but also of possible contaminants. One way to do this is to include potential contaminants in your taxa list. The other way is to create a separate contaminant database. In our MARES database, we have opted for the latter. This enables you to screen your sequence reads for contaminants, and remove them, before processing and further analysing your data. Alternatively, you could merge these two databases (i.e. fasta files) together. In our workflow, we provide scripts that help trawl through your sequence reads, and taxa list, and provide a list of reads or taxa that are potentially contaminants.
#### Please note that if you intend to use kraken2 to classify your samples, you should run:
        kraken2-build --download-taxonomy --db mares
#### Because MARES relies on a local copy of the NCBI taxonomy, the locations of these files must be specified prior to running the pipeline. Where indicate below, you should adjust the scripts to point to the location of the nodes.dmp and names.dmp files from the NCBI taxdump file.
## List of Files that need modification prior to running the script
* ./coi_ret/ebot_taxonomy3.plx - line 86 requires email
* ./coi_ret/grab_many_gb_catch_errors_auto_CO1_year.plx - line 32 requires email, you may also wish to modify the search terms here on line 29
* ./coi_ret/taxonomy_crawl_for_genus_species_list.plx lines 29 and 30 require location of names and nodes dmp files (see note above about kraken usage)
* step4a_taxid_addition.r - line 75, may need to change location of nodes and names dmp (see note above about kraken usage)
* ./coi_ret/grab_many_gb_catch_errors_auto_CO1_year.plx - change the search terms to include additional genes, or keywords (line 29).
* blacklisted_accessions.txt - this file contains a list of accessions that you do not want included in your database. This should include BOTH NCBI and BOLD accessions. For BOLD the accession should be formatted as ABCI122225-19 (example case), while NCBI accessions should be WITHOUT the version i.e AC1234 rather than AC1234.1.    
## Step 1: NCBI COI Retrieval
Make sure you have completed the changes to the files outlined above. 

First, it is necessary to make a taxa.list file - this file contains the list of taxa that you're interested in. You can use different lists for BOLD or NCBI, or the same for both. For the MARES databases, our list of taxa included all families known to have marine species (based on the World Registry of Marine Species, WoRMS, http://www.marinespecies.org/), and we additionally built a database that included common laboratory contaminants.

Then, we want to run the NCBI_COI_Retrieval.sh script which does the following:
1.	Converts your list of taxa (i.e. taxa.list) into a list of taxids for every species. For example, "Chordata" will be turned into a list of taxids for every species found in Chordata.
2.	Converts taxids to binomial names that can be searched for in NCBI.
3.	Searches NCBI and downloads all relevant genbank files (.gb format) .

The last step removes a list of accessions that can be provided by a user - in case there are certain accessions (i.e ones that you know have the wrong species associated with the sequence) that you wish to remove from the database. Note that this is the accession number WITHOUT the version i.e AC1234 rather than AC1234.1. To implement this step, add a list of accessions (both NCBI and BOLD) to the blacklisted_accessions.txt file.
## Step 2: BOLD Retrieval

For BOLD retrieval you will want to run the R script retrieve_bold.r. You may need to make modifications to this file. Specifically, this script takes a list of taxa and retrieves the BOLD data, and formats this data as a fasta file. This can take a while for large taxonomic groups, and may timeout when connecting to BOLD if you do not have large amounts of RAM.

If this does become problematic, it may be wise to remove this group from your taxlist, replacing it with the subtaxa for that group to avoid timing out. It is for this reason we have two taxlist_bold files in our example. You will want to specify the taxalist files you wish to use in this file on line 27 and 30 (or remove line 30)

## Step 3: The BOLD_NCBI merger
*The step also removes a list of accessions that can be provided by a user - in case there are certain accessions (i.e ones that you know have the wrong species associated with the sequence) that you wish to remove from the database. Note that this is the accession number WITHOUT the version i.e AC1234 rather than AC1234.1. This is the blacklisted_accessions.txt file that removes accesions from the GenBank fasta, therefore it should also contain the BOLD accessions as well.* 

The BOLD_NCBI merger step is based largely on Macher J, Macher T, Leese F (2017) Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger. Metabarcoding and Metagenomics 1: e22262. https://doi.org/10.3897/mbmg.1.22262

This process takes the BOLD file, ensures it is for the COI-5P region, and processes the names to enable dereplication of sequences and the merging of sequences into a single file. Last, the headers are reformatted, and the sequences converted to single line fasta format.
You may need to modify Step3_merge_bold_ncbi.sh on line 6 to specify the taxon name for your reference database.

## Step 4: Normalise taxonomy IDs
To normalise the taxonomic IDs we first need to export a list of sequence names from the merged database.

Many pipelines and software use lowest common ancestor approaches for taxonomic classification, and rely on the NCBI taxonomy to do this.  However, many species don't have taxids in NCBI or have been uploaded with synonyms as names, making the retrieval of reliable taxonomic classifications difficult.

In our pipeline, we identify any synonyms and consolidate them so that each taxon has only one name, and is provided with the appropriate taxid. If a taxon does not have a taxid assigned, we assign one based on the genus name and incorporate this into the nodes and names dmp files. This only occurs if the genus name is unique taxonomically (i.e "Acanthocephala" is both a genus of fly, and phylum of worms, as a result of ambiguous naming, we do not assign a taxid). If a taxid cannot be assigned because the genus was not able to be identified, then the sequence is removed from the database.

We then generate two lists of sequence names - the first is the original sequence names, for sequences that have taxids. The second is the new set of names for the sequences, that now are in a standardized format, with taxid included in the seq name. We use these lists to rename and generate a new fasta called Marine_Euk_BOLD_NCBI_sl_reformatted.fasta which is now our completed database.
To do this step, use the taxid_addition.r script. You will need to edit this script to modify directories, as well as to ensure the appropriate packages are installed.



## Step 5: Format for taxonomy classifiers

### 5a : Prepare for KRAKEN 
At this point, we want to format our database for taxonomic classification using kraken. For this to work the header for each fasta needs to be reformatted to kraken:taxid|{taxid}. Scripts are then provided that generate the Kraken database using the MARES sequences.

You will need to adjust the code on line 8 of step5_make_krakendb to reflect the location of the mares database.

Note: To avoid compatibility issues, please ensure you use the most recent version of Kraken2 on github.

### 5b : Prepare for MEGAN 

In this step, we build a local database from our custom reference database and blast it against your metabarcoding sample file.

The fasta file containing your sample file (query.fasta) should be added to the custom_metabarcoding_database folder. Modify the blast parameters according to your preference in line 17.

The output is a .txt file in the MEGAN_db folder that can be imported into MEGAN (Husson et al. 2007) for taxonomic assignment. 


## Technical Validation

To highlight the value and potential utility of our curated reference databases (MARES_COI_BAR and MARES_COI_NOBAR) we compare them with previously published reference databases for the metabarcoding locus COI. 

To compare the MARES databases with databases in terms of taxonomic composition, we used pairwise beta (β)‐diversity measures based on the presence and absence of taxa within each database. Additionally, we calculated the proportion of marine species out of the total of unique species names for each database.

The scripts to reproduce our comparisons are in in the technical_validation folder. 

The script *database_formatting.R* first re-formats the species names of each database to find the unique species names after a quality control procedure for retaining fully identified taxa with binomial species names. For this step the sequence names of each reference database are needed, these can be found in the technical validation folder. Next, all the species names across all databases were merged and a presence/absence species matrix was generated to use as input for the script *bdiv_database_comparison.R*. Lastly, the species list from all the databases was checked against WORMS database to identify which were the marine species and to calculate the proportion present in each database.  

The script *bdiv_database_comparison.R* includes the calculations for the pairwise beta (β)‐diversity measures between databases. 

Databases included in this comparison: 
-	BOLD 
-	Genbank
-	MiDori-LONGEST
-	db_COI_MBPK
-	Anacapa CO1


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
`betapart`
`stingi`
`qdapDictionaries`
`splitstackshape`
`taxizedb`

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

Please also cite: https://doi.org/10.5281/zenodo.3701276 if you're usage involved the addition of custom TaxIDs (this is included by default within the pipeline)

The genbank_to_fasta.py script was developed by the Rocap Lab https://rocaplab.ocean.washington.edu/

## Questions
If there are any questions or issues - please email William Pearman (wpearman1996@gmail.com) or Vanessa Arranz (vanearranz@hotmail.com), or alternatively leave comment on this repository.


# Suggested Citation

Please refer to the publication: Arranz, Vanessa, Pearman, William S., Aguirre, J. David and Liggins, Libby. (2020). "MARES: a replicable pipeline and curated reference database for marine (COI) metabarcoding". Manuscript submitted for publication.


In addition, if you make use of this pipeline, please also cite the following publications:
Macher, Jan-Niklas, Till-Hendrik Macher, and Florian Leese. "Combining NCBI and BOLD databases for OTU assignment in metabarcoding and metagenomic datasets: The BOLD_NCBI _Merger." Metabarcoding and Metagenomics 1 (2017): e22262.

Porter, Teresita M., and Mehrdad Hajibabaei. "Over 2.5 million COI sequences in GenBank and growing." PloS one 13.9 (2018): e0200177.
