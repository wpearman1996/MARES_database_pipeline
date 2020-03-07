setwd("./taxid_process")
library(stringr)
convert2name<-function(seqnames){
  seqnames<-paste(seqnames$V2,seqnames$V3)
  seqnames<-trimws(gsub("\\w*[0-9]+\\w*\\s*", "", seqnames))
  seqnames<-trimws(gsub("\\w*\\.+\\w*\\s*", "", seqnames))
  seqnames
}
generate_newnames<-function(taxidtable,seqnames){
  taxidtable$`preferred name`<-ifelse(taxidtable$`preferred name`==" ",
                                      taxidtable$name,taxidtable$`preferred name`)
 # seqnames<-strsplit(seqnames," ")
  #seqnames<-lapply(seqnames,head,3)
  #seqnames<-as.data.frame(do.call("rbind",seqnames))
  me_wo_uni<-unique(convert2name((seqnames)))
  me_wo_uni<-data.frame(me_wo_uni)
  me_wo_uni$newname<-taxidtable$`preferred name`[match(me_wo_uni$me_wo_uni,taxids$name)]
  me_wo_uni$taxid<-taxidtable$taxid[match(me_wo_uni$me_wo_uni,taxidtable$name)]
  seqnames$spec<-paste(seqnames$V2,seqnames$V3)
  seqnames$spec<-trimws(gsub("\\w*[0-9]+\\w*\\s*", "", seqnames$spec))
  seqnames$spec<-trimws(gsub("\\w*\\.+\\w*\\s*", "", seqnames$spec))
  seqnames$newspec<-me_wo_uni$newname[match(seqnames$spec,me_wo_uni$newname)]
  seqnames$taxid<-me_wo_uni$taxid[match(seqnames$spec,me_wo_uni$newname)]
  newseqnames<-data.frame(seqnames$V1,seqnames$newspec,seqnames$taxid,"COIN5P")
  newseqnames<-newseqnames[complete.cases(newseqnames),]
  newseqnames
}
library(stringr)
newtaxids <- readLines("../newtaxids.txt")
newtaxids <- word(newtaxids,5)
newtaxids <- gsub('.{1}$', '', newtaxids)

newtaxids<-data.frame("1",parentdetails$oldname," ",newtaxids)
colnames(newtaxids) <- colnames(taxids)
taxids<-rbind(taxids,newtaxids)


temp<-generate_newnames(taxids,me_wo_names)
accessions<-temp$seqnames.V1
me_wo_names<-readLines(file)
accesion_old<-gsub(">", "",word(me_wo_names,1))
accesion_old<-gsub(">","",accesion_old)
accessions<-gsub(">","",accessions)
#View(intersect(accessions,accesion_old))
x<-(me_wo_names[accesion_old %in% accessions])
temp$oldname<-x[match(temp$seqnames.V1,word(x,1))]
temp$newname<-with(temp, paste(seqnames.V1, seqnames.newspec, seqnames.taxid, X.COIN5P.,sep=" "))
writeLines(temp$oldname,"seqs_oldnames.txt")
writeLines(temp$newname,"seqs_newnames.txt")
