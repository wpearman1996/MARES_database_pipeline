library(bold)
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


taxlist<-c("Acanthocephala","Annelida","Brachiopoda","Bryozoa","Cephalorhyncha","Chaetognatha",
           "Cnidaria","Cycliophora","Ctenophora","Dicyemida","Echinodermata","Entoprocta","Gastrotricha",
           "Gnathostomulida","Hemichordata","Mollusca","Nematoda","Nemertea","Onychophora","Orthonectida",
           "Phoronida","Placozoa","Platyhelminthes","Porifera","Rotifera","Sipuncula","Tardigrada",
           "Xenacoelomorpha","Chlorophyta","Rhodophyta","Chlorarachniophyta","Ciliophora","Heterokontophyta",
           "Pyrrophycophyta","Branchiopoda","Cephalocarida","Diplura","Hexanauplia","Malacostraca","Maxillopoda",
           "Merostomata","Ostracoda","Protura","Pycnogonida","Remipedia",
           "Pentastomida","Actinopterygii","Amphibia","Appendicularia","Ascidiacea","Aves","Cephalaspidomorphi",
           "Elasmobranchii","Holocephali","Leptocardii","Mammalia","Myxini","Reptilia","Sarcopterygii","Thaliacea")


taxlist2<-c("Cephalorhyncha","Rhombozoa","Orthonectida","Chlorarachniophyta","Copepoda","Thecostraca","Branchiura","Mystacocarida",
           "Tantulocarida","Pentastomida","Acanthuriformes","Acipenseriformes","Albuliformes","Alepocephaliformes",
           "Amiiformes","Anabantiformes","Anguilliformes","Argentiniformes","Ateleopodiformes","Atheriniformes",
           "Aulopiformes","Batrachoidiformes","Beloniformes","Beryciformes","Blenniiformes","Callionymiformes",
           "Caproiformes","Carangiformes","Cetomimiformes","Characiformes","Cichliformes","Clupeiformes",
           "Cypriniformes","Cyprinodontiformes","Echinorhiniformes","Elopiformes","Esociformes","Gadiformes",
           "Galaxiiformes","Gobiesociformes","Gobiiformes","Gonorynchiformes","Gymnotiformes","Hiodontiformes",
           "Holocentriformes","Icosteiformes","Istiophoriformes","Kurtiformes","Labriformes","Lampriformes",
           "Lepidogalaxiiformes","Lepisosteiformes","Lophiiformes","Moroniformes","Mugiliformes","Myctophiformes",
           "Notacanthiformes","Ophidiiformes","Osmeriformes","Osteoglossiformes","Ovalentaria","Perciformes",
           "Percopsiformes","Pleuronectiformes","Polymixiiformes","Polypteriformes","Salmoniformes",
           "Scombriformes","Scombrolabraciformes","Scorpaeniformes","Siluriformes","Spariformes","Stomiiformes",
           "Stylephoriformes","Synbranchiformes","Syngnathiformes","Tetraodontiformes","Trachichthyiformes")
		   
taxlist3 <- c("Akysidae","Amblycipitidae","Amphiliidae","Ariidae","Aspredinidae", "Astroblepidae",
            "Auchenipteridae","Austroglanididae","Bagridae","Callichthyidae","Cetopsidae","Chacidae","Clariidae",
            "Claroteidae","Cranoglanididae","Diplomystidae","Doradidae","Erethistidae","Heptapteridae",
            "Heteropneustidae","Horabagridae","Ictaluridae","Kryptoglanidae","Loricariidae","Malapteruridae",
            "Mochokidae","Nematogenyidae","Pangasiidae","Pimelodidae", "Plotosidae","Pseudopimelodidae","Ritidae",
            "Schilbeidae", "Scoloplacidae","Siluridae","Sisoridae","Trichomycteridae")

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


dir.create("./taxaBOLD")
setwd("./taxaBOLD")
library(bold)
for (i in 1:length(taxlist2)) {
  tryCatch({
    get_fasta(taxlist2[i],paste0(taxlist2[i],"bold",".fasta"))
   }, error=function(e){cat("ERROR :",conditionMessage(e), "\n",taxlist2[i])})
}
