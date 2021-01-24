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
x<-read.delim("./basecounts.txt",sep="\t",head=F,na.strings=c(" ",""))


x$A<-ifelse(grepl("A",x$V2), parse_number(x$V2),
            ifelse(grepl("A",x$V3), parse_number(x$V3),
                   ifelse(grepl("A",x$V4), parse_number(x$V4),
                          ifelse(grepl("A",x$V5), parse_number(x$V5),parse_number(x$V6)))))
            
x$T<-ifelse(grepl("T",x$V2), parse_number(x$V2),
            ifelse(grepl("T",x$V3), parse_number(x$V3),
                   ifelse(grepl("T",x$V4), parse_number(x$V4),
                          ifelse(grepl("T",x$V5), parse_number(x$V5),parse_number(x$V6)))))

x$G<-ifelse(grepl("G",x$V2), parse_number(x$V2),
            ifelse(grepl("G",x$V3), parse_number(x$V3),
                   ifelse(grepl("G",x$V4), parse_number(x$V4),
                          ifelse(grepl("G",x$V5), parse_number(x$V5),parse_number(x$V6)))))

x$C<-ifelse(grepl("C",x$V2), parse_number(x$V2),
            ifelse(grepl("C",x$V3), parse_number(x$V3),
                   ifelse(grepl("C",x$V4), parse_number(x$V4),
                          ifelse(grepl("C",x$V5), parse_number(x$V5),parse_number(x$V6)))))

x$N<-ifelse(grepl("N",x$V2), parse_number(x$V2),
            ifelse(grepl("N",x$V3), parse_number(x$V3),
                   ifelse(grepl("N",x$V4), parse_number(x$V4),
                          ifelse(grepl("N",x$V5), parse_number(x$V5),parse_number(x$V6)))))
x$NPerc<-100*(x$N/(x$A+x$T + x$G + x$C + x$N))
x$NPerc<-ifelse(is.na(x$NPerc),0,x$NPerc)
x<-x[x$NPerc <= opt$percent,]
write.table(x[,c(1,12)],"./NPercs.txt")
