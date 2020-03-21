rm(list=ls())
library("getopt")
spec <- matrix(
  c("input",  "i", 2, "character", "sequence alignment",
    "output", "o", 2, "character",  "output file prefix",
    "help",   "h", 0, "logical",  "This script is used to cluster sequence and divide them into groups"),
  byrow=TRUE, ncol=5)
opt<-getopt(spec=spec)

if( !is.null(opt$help) || is.null(opt$input) || is.null(opt$output)){
      cat(paste(getopt(spec=spec, usage = T),"\n"))
      quit()
}

library("ape")

myseq<-read.FASTA(opt$input)
myclust<-hclust(dist.dna(myseq))

myh1<-max(myclust$height)*0.2
groups1<-cutree(myclust,h=myh1)
myh2<-max(myclust$height)*0.1
groups2<-cutree(myclust,h=myh2)

count<-matrix(nrow=length(groups1),ncol=2,dimnames=list(row.names=NULL,colnames=c("count1","count2")))

for (i in 1:length(groups1)){
   count[i,1]=sum(groups1==groups1[i])
   count[i,2]=sum(groups2==groups2[i])
}

write.table(cbind(names(groups1),groups1,groups2,count),file=paste(opt$output,"groups.txt",sep="."),sep="\t",row.names=F,quote=F)
