library(BiodiversityR)
library(betapart)

out_presab_db <- data.frame(read.csv("presab_allspec_alldatabases.csv"))
dat <- t(out_presab_db[,2:8])
colnames(dat) <- out_presab_db$Species

J_P <- beta.pair(dat[1:7,], index.family = "jaccard")