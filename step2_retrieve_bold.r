library(bold)

#Functions to retrieve the subtaxa of each family (get)subtaxa) and search in Bold and download the available sequences of each subtaxa (get_fasta)
get_fasta<-function(taxon,filename){
  x<-bold_seqspec(taxon=taxon)
  x<-x[x$markercode=="COI-5P" | x$markercode=="COI-3P",]
  x[x==""]  <- NA 
  b_acc<-x$processid
  b_tax<-ifelse(!is.na(x$species_name),x$species_name,ifelse(!is.na(x$genus_name),x$genus_name,ifelse(
    !is.na(x$family_name),x$family_name,ifelse(
      !is.na(x$order_name),x$order_name,ifelse(
        !is.na(x$class_name),x$class_name,x$phylum_name)))))
  b_mark<-x$markercode
  n_acc<-ifelse(!is.na(x$genbank_accession),ifelse(!is.na(x$genbank_accession),paste0("|",x$genbank_accession),""),"")
  
  seq<-x$nucleotides
  seqname<-paste(b_acc,b_tax,b_mark,sep="|")
  seqname<-paste0(seqname,n_acc)
  Y<-cbind(seqname,seq)
  colnames(Y)<-c("name","seq")
  fastaLines = c()
  for (rowNum in 1:nrow(Y)){
    fastaLines = c(fastaLines, as.character(paste(">", Y[rowNum,"name"], sep = "")))
    fastaLines = c(fastaLines,as.character(Y[rowNum,"seq"]))
  }
  writeLines(fastaLines,filename)
}

get_subtaxa<-function(taxid){
  require(dplyr)
  require(rvest)
tax_page<-paste0("http://www.boldsystems.org/index.php/Taxbrowser_Taxonpage?taxid=",taxid)
info <- read_html(tax_page) %>% html_nodes(xpath = '//*[@class="ibox float-e-margins"]') 
x<-paste(info)
x<-x[grepl("<lh>",x)]
x<-strsplit(x,"\"")
x<-as.vector(do.call("rbind",x))
x<-x[grepl(">",x)]
x<-gsub("].*","",x)
x<-gsub(">","",x,fixed = T)
x<-gsub("[","",x,fixed= T)
subtax<-(do.call("rbind",strsplit(x," "))[,1:2])
subtax<-as.data.frame(subtax[2:nrow(subtax),])
colnames(subtax)<-c("Taxa","Number of Records")
subtax
}

taxlist<-readLines(file("taxa.list"))

dir.create("./taxaBOLD")
setwd("./taxaBOLD")
library(bold)
for (i in 1:length(taxlist)) {
   cat("Processing ", taxlist[i], "\n")
   tryCatch({
    get_fasta(taxlist[i],paste0(taxlist[i],"bold",".fasta"))
   }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}
