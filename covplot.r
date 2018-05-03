#!/usr/bin/Rscript

library(ggplot2)

#This is an R script to go through the samtools depth output files and make plots of depth across chromosomes
#Also plot some histograms to characterise the depth stats

#Use the same binsize as indexcov
binsize <- 16384
scaffoldcount = 25 #ideally modify to work this count out from the reference file
depthfile = "/home/AD/tbleazar/162/processed/162_HCT-15_62-64_pool1_S1/30.bwa.hg38.dup.samtools.depth"
referencefile = "/home/AD/tbleazar/162/reference/hg38.fa"

print("Calculating reference scaffold lengths from file")
print(referencefile)
#First compute the length of each of the reference chromosomes
#Use the reference fasta to do this
filepath <- referencefile
chromosome <- ">start"
basecount <- 0
chrocount <- 0
#Store the chromosome name starting with > and the count of bases in chrotable
chrotable <- data.frame(integer(scaffoldcount))
con <- file(filepath, "r")
#Here is standard R code to line-by-line loop through a file
while ( TRUE ) {
  line <- readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }
  #do things with the line here
  if (substr(line, start=1, stop=1) == ">") {
    chrocount <- chrocount + 1
    rownames(chrotable)[chrocount] <- substr(line,start=2,stop=nchar(line))
    if (chromosome != ">start") {
      chrotable[chrocount-1,1] <- basecount
    }
    chromosome <- substr(line,start=2,stop=nchar(line))
    basecount <- 0
  } else {
    basecount <- basecount + nchar(line)
  }
}
chrotable[chrocount,1] <- basecount
close(con)

#The chrotable has the names and lengths
print("Names and lengths of reference scaffolds:")
print(chrotable)

#Will make a data.frame with a column for the bins for each chromosome
#The number of rows must be the max of the number of bins among chromosomes, and then when plotting we can just ignore the excess at the end
#The value to store in the bin is the summed coverage inside that bin. This can then be normalised by dividing all bins by binsize
bintable <- data.frame(matrix(0, ncol=nrow(chrotable), nrow=(max(chrotable) %/% binsize)+1))
colnames(bintable) <- rownames(chrotable)

#Will now go through the input samtools depth file
print("Now reading the samtools depth file")
print(depthfile)

#counter <- 0
filepath <- depthfile
con <- file(filepath, "r")
while ( TRUE ) {
  line <- readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }
  #do things with the line here
  #counter <- counter + 1
  #if (counter > 2500000) {
    #break
  #}
  threebits <- unlist(strsplit(line, "\t", fixed=TRUE)) #this is (chromosome, position, depth)
  chromosome <- threebits[1]
  binspot <- (strtoi(threebits[2]) %/% binsize)+1 #We start counting at bin 1 - so eg. position 100 binsize 16384 goes in bin 1
  depth <- strtoi(threebits[3])
  bintable[binspot,chromosome] <- bintable[binspot,chromosome] + depth
}

print("Collected the bintable, and dividing values by binsize now")
bintable <- bintable / binsize

#To finish, try to use ggplot2
for (chromosome in colnames(bintable)) {
  thisbinnumber <- (chrotable[chromosome,1] %/% binsize) + 1
  toplot <- bintable[c(1:thisbinnumber),chromosome] #weirdly, this returns a vector not a dataframe
  pdf(paste0(chromosome,".depthplot.pdf"))
  df <- as.data.frame(toplot)
  colnames(df) <- c("Depth")
  print("Writing chromosome")
  print(chromosome)
  print(summary(df))
  ggplot(data = df, aes(x = as.numeric(rownames(df)), y = Depth)) +
  geom_line(colour = "#0066CC", size = 0.1) +
  theme_bw() +
  xlab("Reference Position") +
  scale_x_continuous(expand = c(0,0)) +
  #scale_y_continuous(trans = 'log10', breaks = c(1,10,100,1000)) +
  ylim(c(0,50)) +
  ylab("Coverage") +
  ggtitle(paste0("Coverage Across Reference ",chromosome))
  dev.off()
}

