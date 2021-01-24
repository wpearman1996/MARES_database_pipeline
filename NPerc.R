library(readr)
library(stringr)
library("optparse")
option_list = list(
  make_option(c("-p","--percent"), type="numeric", default=NULL, 
              help="Percent N to remove", metavar="numeric"))
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
if (is.null(opt$percent)){
  print_help(opt_parser)
  stop("Percent N is required", call.=FALSE)
}
x<-read.delim("./basecounts.txt",sep="\t",head=T,na.strings=c(" ",""))

x$NPerc<-100*x$N_perc
names<-readLines("./seqnames_mares_reform.txt")
names<-gsub(">","",names)
names<-data.frame(names,word(names,1,sep=" "))
colnames(names)<-c("Name","Accession")
names$NPerc<-x$NPerc[match(names$Accession,x$Seq_ID)]
x<-names[names$NPerc <= opt$percent,]
write.table(x[,1],"./NPercs.txt",quote = F,row.names = F,col.names = F)
