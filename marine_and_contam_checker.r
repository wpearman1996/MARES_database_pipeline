# This step can only be done if you have a local copy of the WoRMS database
# In addition, this will not identify algal species particularly well, as most algae species are derived from AlgaeBase
# AlgaeBase is not included in the standard worms download, thus this should be used as a tool to filter by, rather
# should be used as a tool to aid in data exploration. 
worms <- read.delim("./worms_taxonlist.txt") 
contam <- readLines("../custom_metabarcoding_databases_contam//taxa.list") 



megan <- read.csv("../rep-seqs-nofilt-assigned.csv")
library(stringr); library(plyr)
megan_taxonpath <- str_split(megan$TaxonPath,pattern=";")
megan$Genus <- (str_match(megan$TaxonPath, "g__(.*?);"))[,2]
megan$Species <- (str_match(megan$TaxonPath, "s__(.*?);"))[,2]

megan$Genus_Marine <- ifelse(megan$Genus %in% worms$genus, TRUE,FALSE)
megan$Species_Marine <- ifelse(megan$Species %in% worms$acceptedNameUsage, TRUE,FALSE)
megan$Genus_Contam <- ifelse(megan$Genus %in% word(contam,1), TRUE,FALSE)
megan$Species_Contam <- ifelse(megan$Species %in% contam, TRUE,FALSE)
write.csv(megan,"megan_contam_marine_list.csv")


#The following code to import the names.dmp file was retrieved from taxizedb
ncbi_names_file <- #location of names.dmp file.
ncbi_names <- readr::read_tsv(
  ncbi_names_file,
  col_names = c("tax_id", "name_txt", "unique_name", "name_class"),
  col_type = "i_c_c_c_",
  quote = ""
)

ncbi_names<-ncbi_names[ncbi_names$name_class=="scientific name",]

kraken <- read.delim("../kraken_test.txt",head=F)
colnames(kraken)<- c("ClassifiedStatus","ReadID","TaxID","SequenceLength","LCA_History")
kraken$TaxonClass <- ncbi_names$name_txt[match(kraken$V3,ncbi_names$tax_id)]
kraken$Genus <- word(kraken$TaxonClass,1)
kraken$Genus_Marine <- ifelse(kraken$Genus %in% worms$genus, TRUE,FALSE)
kraken$Species_Marine <- ifelse(kraken$TaxonClass %in% worms$acceptedNameUsage, TRUE,FALSE)
kraken$Genus_Contam <- ifelse(kraken$Genus %in% word(contam,1), TRUE,FALSE)
kraken$Species_Contam <- ifelse(kraken$Species %in% contam, TRUE,FALSE)
write.csv(kraken,"kraken_contam_marine_list.csv")
