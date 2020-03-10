# This step can only be done if you have a local copy of the WoRMS database
# In addition, this will not identify algal species particularly well, as most algae species are derived from AlgaeBase
# AlgaeBase is not included in the standard worms download, thus this should be used as a tool to filter by, rather
# should be used as a tool to aid in data exploration. 
worms <- read.delim("./worms_taxonlist.txt") 
contam <- readLines("./custom_metabarcoding_databases_contam/taxa.list") 

kraken <- read.delim

megan <- read.csv("./rep-seqs-nofilt-assigned.csv")
library(stringr); library(plyr)
megan_taxonpath <- str_split(megan$TaxonPath,pattern=";")
megan$Genus <- (str_match(megan$TaxonPath, "g__(.*?);"))[,2]
megan$Species <- (str_match(megan$TaxonPath, "s__(.*?);"))[,2]

megan$Genus_Marine <- ifelse(megan$Genus %in% worms$genus, TRUE,FALSE)
megan$Species_Marine <- ifelse(megan$Species %in% worms$acceptedNameUsage, TRUE,FALSE)
megan$Genus_Contam <- ifelse(megan$Genus %in% word(contam,1), TRUE,FALSE)
megan$Species_Contam <- ifelse(megan$Species %in% contam, TRUE,FALSE)
write.csv(megan,"megan_contam_marine_list.csv")
