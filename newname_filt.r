x<-readLines("sl_s4_seqnames.txt")
y<-readLines("seqs_newnames2.txt")
t<-data.frame(y,stringr::word(y,1))
t1<-t[t$stringr..word.y..1. %in% x,]
t1$y<-paste0(">",t1$y)
writeLines(as.character(t1$y),"newnames3.txt",)
