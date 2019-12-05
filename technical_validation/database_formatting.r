# Database comparisons

library(stringr)
library(taxize)
library(stringi)
library(qdapDictionaries)
library(splitstackshape)

# Get species names and find the unique spp for each of the dataset to compare 

## 1. db_COI_MBPK_March (Wangensteen, Owen S., et al.  2018)

mbpkdb2 <-read.delim("./owen_seqnamest.txt",head=F)
mbpkdb2<-sub(".*species_name=", "", mbpkdb$V1)
mbpkdb2<-sub(';.*', '', mbpkdb2)
mbpkdb2<-unique(mbpkdb2)
mbpkdb2<-gsub("_"," ",mbpkdb2)
mbpkdb2<-gsub("'","",mbpkdb2)

mbpkdb2<-mbpkdb2[!grepl("\\.",mbpkdb2)]
mbpk_acc<-mbpkdb2[grepl(">",mbpkdb2)]
library(taxize)
ENTREZ_KEY<-"QWERTY" # INSERT YOUR ENTREZ KEY HERE
acc_det<-genbank2uid(mbpk_acc,key = ENTREZ_KEY)
acc_det_tax<-do.call("rbind",acc_det)
acc_det_tax<-acc_det_tax[!is.na(acc_det_tax)]
taxnames_mbpkacc<-id2name(acc_det_tax,db="ncbi")
taxnames<-do.call("rbind",taxnames_mbpkacc)
mbpkdb2_acc<-taxnames$name[!grepl("\\.",taxnames$name)]
mbpkdb2_acc<-unique(mbpkdb2_acc)
mbpkdb2_acc<-gsub("_"," ",mbpkdb2_acc)
mbpkdb2<-c(mbpkdb2,mbpkdb2_acc)
mbpkdb2<-mbpkdb2[!grepl(">",mbpkdb2)]
mbpk_acc<-gsub(">","",mbpk_acc)
mbpk_acc<-gsub("_"," ",mbpk_acc)
mbpkdb2<-sub("^(\\S*\\s+\\S+).*", "\\1", mbpkdb2)
mbpkdb2<-(mbpkdb2[!grepl("\\d",mbpkdb2)])
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }
t<-countSpaces(mbpkdb2)
mbpkdb2<-(mbpkdb2[t !=0])

## 2. Genbank Eukaryota COI without the Keyword = Barcode (Benson et al. 2015)

genbank<-read.delim("./genbank_seqnames.txt",head=F,sep="|")
genbank<-unique(genbank$V2)
genbank<-as.character(genbank)
genbank<-(genbank[!grepl("\\d",genbank)])
genbank<-gsub("_"," ",genbank)
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }
genbank<-str_trim(genbank,side="both")
t<-countSpaces(genbank)
genbank<-(genbank[t !=0])
genbank<-genbank[!grepl("\\.",genbank)]
genbank<-sub("^(\\S*\\s+\\S+).*", "\\1", genbank)
genbank<-gsub("'","",genbank)
genbank<-gsub("\\[","",genbank)
genbank<-gsub("\\]","",genbank)
genbank<-gsub("\\(","",genbank)
genbank<-unique(genbank)


## 3. BOLD all taxon list (Ratnasingham and Hebert 2007)

bold<-read.delim("./bold_seqnames.txt",head=F,sep="|")
bold<-bold$V2
bold<-as.character(unique(bold))
bold<-(bold[!grepl("\\d",bold)])
bold<-gsub("_"," ",bold)
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }
bold<-str_trim(bold,side="both")
t<-countSpaces(bold)
bold<-(bold[t !=0])
bold<-bold[!grepl("\\.",bold)]
bold<-sub("^(\\S*\\s+\\S+).*", "\\1", bold)
bold<-unique(bold)

## 4. Anacapa COI BOLD all taxon list (Curd et al. 2019)

anacapa<-read.delim("C:/Users/wpear/Downloads/CO1_filtered_01102018.tar/CO1_filtered_01102018/CO1_db_filtered_to_remove_ambigous_taxonomy/CO1_fasta_and_taxonomy/CO1_taxonomy.txt",head=F)
anacapa_spec<-sub('.*\\;', '', anacapa$V2)
anacapa_spec<-stringr::word(anacapa_spec,1,2)

anacapa_spec<-gsub("(?! )[[:punct:]]", "", anacapa_spec, perl=TRUE)
anacapa_spec<-anacapa_spec[word(anacapa_spec, 2) != "cf"]
anacapa_spec<-anacapa_spec[word(anacapa_spec, 2) != "sp"]
anacapa_spec<-anacapa_spec[word(anacapa_spec, 2) != "pr"]
anacapa_spec<-anacapa_spec[word(anacapa_spec, 2) != "nr"]
anacapa_spec<-unique(anacapa_spec)

## 5. MIDORI COI_LONGEST (Machida et al. 2017)

midori<-read.delim("./MIDORI_LONGEST_20180221_COI.taxon",
                   head=F,sep=";")
midori_spec<-(midori$V7)
midori<-(midori[!grepl("\\d",midori)])
midori<-gsub("_"," ",midori)
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }
library(stringr)
midori<-str_trim(midori)
t<-countSpaces(midori)
midori<-(midori[t !=0])
midori_spec<-gsub("s__","",midori_spec)
midori_spec<-gsub("_","",midori_spec)
midori_spec<-sub("^(\\S*\\s+\\S+).*", "\\1", midori_spec)
midori_spec<-midori_spec[!grepl("\\.",midori_spec)]
midori_spec<-unique(midori_spec)
midori_spec[8]<-NA;midori_spec<-midori_spec[!is.na(midori_spec)]

## 6. MARES_wo_barcode

mares_wo<-read.delim("../ME_wo_barcodes_seqnames.txt",sep=" ",stringsAsFactors=FALSE,head=F)
mares_wo<-paste(mares_wo$V2,mares_wo$V3)
mares_wo<-unique(mares_wo)
mares_wo<-(mares_wo[!grepl("\\d",mares_wo)])
mares_wo<-gsub("_"," ",mares_wo)
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }

mares_wo<-str_trim(mares_wo)
t<-countSpaces(mares_wo)
mares_wo<-(mares_wo[t !=0])
mares_wo<-mares_wo[!grepl("\\.",mares_wo)]
mares_wo<-sub("^(\\S*\\s+\\S+).*", "\\1", mares_wo)
mares_wo<-unique(mares_wo)
mares_wo<-stringr::str_replace_all(mares_wo, "(\\w)N(\\w)", "\\1-\\2")
mares_wo<-(mares_wo[!grepl(" CMF",mares_wo)]);mares_wo<-(mares_wo[!grepl(" JLE",mares_wo)]);mares_wo<-(mares_wo[!grepl(" RW",mares_wo)])
mares_wo<-mares_wo[!ifelse(word(mares_wo,2)=="sp",TRUE,FALSE)]

## 6. MARES_w_barcode

mares_bar<-read.delim("../mares_barcode_seqnames.txt",sep=" ",stringsAsFactors=FALSE,head=F)
mares_bar<-paste(mares_bar$V2,mares_bar$V3)
mares_bar<-unique(mares_bar)
mares_bar<-(mares_bar[!grepl("\\d",mares_bar)])
mares_bar<-gsub("_"," ",mares_bar)
countSpaces <- function(s) { sapply(gregexpr(" ", s), function(p) { sum(p>=0) } ) }
mares_bar<-str_trim(mares_bar)
t<-countSpaces(mares_bar)
mares_bar<-(mares_bar[t !=0])
mares_bar<-mares_bar[!grepl("\\.",mares_bar)]
mares_bar<-sub("^(\\S*\\s+\\S+).*", "\\1", mares_bar)
mares_bar<-unique(mares_bar)

mares_bar<-stringr::str_replace_all(mares_bar, "(\\w)N(\\w)", "\\1-\\2")
mares_bar<-(mares_bar[!grepl(" CMF",mares_bar)]);mares_bar<-(mares_bar[!grepl(" JLE",mares_bar)]); mares_bar<-(mares_bar[!grepl(" RW",mares_bar)])
mares_bar<-mares_bar[!ifelse(word(mares_bar,2)=="sp",TRUE,FALSE)]

## Merge all the species list from all the databases, create a presence/asence matrix of species in each database

all_spec<-c(midori_spec,bold,genbank,mbpkdb2,mares_wo,mares_bar,anacapa_spec)
all_spec<-unique(all_spec)

all_spec<-as.data.frame(all_spec)
all_spec$length_word1<-nchar(word(all_spec$all_spec,1))
all_spec$length_word2<-nchar(word(all_spec$all_spec,2))
all_spec<-all_spec[all_spec$length_word1 > 1,]
all_spec<-all_spec[all_spec$length_word2 > 1,]
all_spec<-all_spec[word(all_spec$all_spec,1) != "nr",]
all_spec<-all_spec[word(all_spec$all_spec,1) != "cf",]
all_spec<-all_spec[word(all_spec$all_spec,2) != "pr",]
all_spec<-all_spec[word(all_spec$all_spec,2) != "cf",]
all_spec$word1_dict<-word(all_spec$all_spec,1) %in% GradyAugmented
all_spec$word2_dict<-word(all_spec$all_spec,2) %in% GradyAugmented
all_spec<-as.character(all_spec$all_spec[all_spec$word1_dic==FALSE])


midori_spec<-midori_spec[midori_spec %in% all_spec]
bold<-bold[bold %in% all_spec]
genbank<-genbank[genbank %in% all_spec]
mares_bar<-mares_bar[mares_bar %in% all_spec]
mares_wo<-mares_wo[me_wo %in% all_spec]
mbpkdb2<-mbpkdb2[mbpkdb2 %in% all_spec]
anacapa_spec<-anacapa_spec[anacapa_spec %in% all_spec]


out <- t(splitstackshape:::charMat(listOfValues = mget(c("midori_spec","bold","genbank",
                "mbpkdb2","mares_wo","mares_bar","anacapa_spec")), fill = 0L))
fac<-c("midori","bold","genbank",
                "mbpkdb","mares_wo","mares_bar","anacapa")
colnames(out)<-fac

outsub<-out[sample(nrow(out), 1000), ]
write.csv(out,"./presab_allspec_alldatabases.csv")






