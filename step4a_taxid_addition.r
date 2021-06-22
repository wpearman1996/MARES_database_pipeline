setwd("./taxid_process") #This will need to updated so that Marine_Euk represents your taxon from
## line 5 step3_merge_bold_ncbi.sh
file<-"./seqnames_Marine_Euk_nobarcode.txt" ## File containing sequence names
me_wo_names<-readLines(file)#,sep=" ",stringsAsFactors=FALSE,head=F)
me_wo_names<-gsub("^ *|(?<= ) | *$", "", me_wo_names, perl = TRUE)
me_wo_names<-strsplit(me_wo_names," ")
me_wo_names<-lapply(me_wo_names,head,3)
me_wo_names<-as.data.frame(do.call("rbind",me_wo_names))
library(stringr)
convert2name<-function(seqnames){
  seqnames<-paste(seqnames$V2,seqnames$V3)
  seqnames<-trimws(gsub("\\w*[0-9]+\\w*\\s*", "", seqnames))
  seqnames<-trimws(gsub("\\w*\\.+\\w*\\s*", "", seqnames))
  seqnames
}
me_wo<-convert2name(me_wo_names)
me_wo_uni<-unique(me_wo)


get_taxinfo<-function(taxnames){
  names<-paste(taxnames,"\n")
  names<-split(names, ceiling(seq_along(names)/10000))
  names<-lapply(names,paste,collapse=" ")
  #  paste(names,collapse=" ")
  library(rvest)
  library(httr)
  col<-list()
  for( i in 1:length(names)){
    col[[i]] = POST(url="https://www.ncbi.nlm.nih.gov/Taxonomy/TaxIdentifier/tax_identifier.cgi",
                    encode="form",
                    body=list(tax=names[i],
                              match=1,
                              button="Save in file"))
    col[[i]]<-as.character(paste(col[[i]]))
  }
  for( i in 1:length(col)){
    col[[i]]<-strsplit(col[[i]], "\n")
  }
  col2<-list()
  for( i in 1:length(col)){
    col[[i]]<-lapply(col[[i]][[1]],strsplit, "\\t|\t")
  }
  coldat <-list()
  for(i in 1:length(col)){
    coldat[[i]]<-(do.call("rbind",(do.call("rbind",col[[i]][2:length(col[[i]])]))))
  }
  col2<-do.call("rbind",coldat)
  col2<-as.data.frame(col2)
  col2$V2<-NULL;col2$V4<-NULL;col2$V6<-NULL
  colnames(col2)<-c("code","name", "preferred name","taxid")
  col2
}
x<-get_taxinfo(me_wo_uni)



notaxids<-as.character(x$name[x$code==3])
notaxids_genus<-word(notaxids,1)

notaxids_info<-get_taxinfo(notaxids_genus)
notaxids_spec <- get_taxinfo(notaxids)
notaxids_info <- notaxids_info[2:nrow(notaxids_info),]
notaxids_info$taxid <-   gsub("^$", NA, trimws(notaxids_info$taxid))
notaxids_info <- notaxids_info[notaxids_info$code==1,]
taxids<-rbind(x[x$code != 3,],notaxids_info[notaxids_info$code == 1,])

library(dplyr)
taxids<-taxids %>%
  mutate_all(as.character)

genus_taxids <- notaxids_info[notaxids_info$code == 1,]
genus_taxids <- unique(genus_taxids)

                        
#Data frame with genus, old name, taxid
parentdetails<-data.frame(notaxids)
colnames(parentdetails)<-c("oldname")
parentdetails$Genus <- word(parentdetails$oldname,1)
parentdetails$GenusTaxid <- genus_taxids$taxid[match(parentdetails$Genus,genus_taxids$name)]
parentdetails<-parentdetails[complete.cases(parentdetails),]
write.table(parentdetails,"./notaxid_forgeneration.csv",row.names = F, col.names = F,quote = F,sep=",")
write.table(parentdetails,"./notaxid_forgeneration.csv",row.names = F, col.names = F,quote = F,sep=",")
parentdetails$command<-paste("perl ./taxdump_edit/taxdump_edit.pl -names ./taxdump/names.dmp -nodes ./taxdump/nodes.dmp -taxa ", paste0("\'",parentdetails$oldname,"\'"),
                             "-parent", parentdetails$GenusTaxid, "-rank species -division 1")
writeLines(as.character(parentdetails$command),"../taxid_commands_addition.txt")
write.table(taxids,"./old_taxids_step4a.csv",row.names = F, col.names = F,quote = F,sep=",")
save.image("./step4a.RData")
# Post revisions the following has been superceded by a new method

#generate_newnames<-function(taxidtable,seqnames){
#  taxidtable$`preferred name`<-ifelse(taxidtable$`preferred name`==" ",
#                                      taxidtable$name,taxidtable$`preferred name`)
#  me_wo_uni<-unique(convert2name((seqnames)))
#  me_wo_uni<-data.frame(me_wo_uni)
#  me_wo_uni$newname<-taxidtable$`preferred name`[match(me_wo_uni$me_wo_uni,taxids$name)]
#  me_wo_uni$taxid<-taxidtable$taxid[match(me_wo_uni$me_wo_uni,taxidtable$name)]
 # seqnames$spec<-paste(seqnames$V2,seqnames$V3)
  #seqnames$spec<-trimws(gsub("\\w*[0-9]+\\w*\\s*", "", seqnames$spec))
  #seqnames$spec<-trimws(gsub("\\w*\\.+\\w*\\s*", "", seqnames$spec))
  #seqnames$newspec<-me_wo_uni$newname[match(seqnames$spec,me_wo_uni$newname)]
  #seqnames$taxid<-me_wo_uni$taxid[match(seqnames$spec,me_wo_uni$newname)]
  #newseqnames<-data.frame(seqnames$V1,seqnames$newspec,seqnames$taxid,"COIN5P")
  #newseqnames<-newseqnames[complete.cases(newseqnames),]
  #newseqnames
#}
#library(stringr)
#temp<-generate_newnames(taxids,me_wo_names)
#accessions<-temp$seqnames.V1
#me_wo_names<-readLines(file)
#accesion_old<-gsub(">", "",word(me_wo_names,1))
#accesion_old<-gsub(">","",accesion_old)
#accessions<-gsub(">","",accessions)
#View(intersect(accessions,accesion_old))
#x<-(me_wo_names[accesion_old %in% accessions])
#temp$oldname<-x[match(temp$seqnames.V1,word(x,1))]
#temp$newname<-with(temp, paste(seqnames.V1, seqnames.newspec, seqnames.taxid, X.COIN5P.,sep=" "))
#writeLines(temp$oldname,"seqs_oldnames.txt")
#writeLines(temp$newname,"seqs_newnames.txt")
