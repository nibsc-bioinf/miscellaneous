#This is a script to read the WHO IS cancer result xlsx spreadsheets
#Collect the data suitably and write out in new tables

library(tidyverse)
library(readxl)

setwd("C:/Users/tbleazar/OneDrive - MHRA/Documents/R/cancer/labresults/collected")

#expected = read_excel('C:/Users/tbleazar/OneDrive - MHRA/Documents/R/cancer/test/expected.xlsx')
#Manually made a tidy version of this with clean sample names
#tidyexpected = read_excel("tidyexpected.xlsx")

#Will loop over the filenames of reports in the directory - this fails if they are open in Excel
folderfiles = list.files()
reportfiles = grep("SNV", folderfiles, value=TRUE)

#This will have a row for every mutation % recording
allrecords = data.frame(Lab=character(), Sample=character(), Mutation=character(), Percentage=character(), CDS=character(), Depth=character())

for (reportfile in reportfiles) {
  #Just using the filename as the lab ID, because they have inconsistent formats
  for (samplename in excel_sheets(reportfile)) {
    #I have to clean up the sample names because they have inconsistent whitespace
    cleanname = gsub(" ","", as.character(samplename), fixed=TRUE)
    mutpercs = read_excel(reportfile, sheet=samplename, range="F5:F10", trim_ws=TRUE)
    mutpercs = as.character(unlist(mutpercs))
    CDSdata = read_excel(reportfile, sheet=samplename, range="D5:D10", trim_ws=TRUE)
    CDSdata = as.character(unlist(CDSdata))
    Depthdata = read_excel(reportfile, sheet=samplename, range="I5:I10", trim_ws=TRUE)
    Depthdata = as.character(unlist(Depthdata))
    #Interpretationdata = read_excel(reportfile, sheet=samplename, range="K5:K10", trim_ws=TRUE)
    #Interpretationdata = as.character(unlist(Interpretationdata))
    thisrecord = data.frame(Lab=rep(reportfile,5), Sample=rep(cleanname,5), Mutation=c("PIK3CA","TP53","NRAS","PTEN","MAP2K1/MEK1"), Percentage=mutpercs, CDS=CDSdata, Depth=Depthdata)
    allrecords = rbind(allrecords, thisrecord)
  }
}

#print(unique(allrecords$Sample))
#print(unique(allrecords$Mutation))

#Record if a measurement is more than 5 percentage points off expectations
head(allrecords)

allrecords$Samplegroup = rep("MCWES02", nrow(allrecords))
allrecords = within(allrecords, Samplegroup[grepl("Sample1", allrecords$Sample)] <- "HCT-15")
allrecords = within(allrecords, Samplegroup[grepl("Sample4", allrecords$Sample)] <- "HCT-15")
allrecords = within(allrecords, Samplegroup[grepl("Sample7", allrecords$Sample)] <- "HCT-15")
allrecords = within(allrecords, Samplegroup[grepl("Sample2", allrecords$Sample)] <- "MOLT-4")
allrecords = within(allrecords, Samplegroup[grepl("Sample5", allrecords$Sample)] <- "MOLT-4")
allrecords = within(allrecords, Samplegroup[grepl("Sample8", allrecords$Sample)] <- "MOLT-4")

allrecords$Dilution = rep("crude", nrow(allrecords))
allrecords = within(allrecords, Dilution[grepl("dilutiona", allrecords$Sample)] <- "dilution a")
allrecords = within(allrecords, Dilution[grepl("dilutionb", allrecords$Sample)] <- "dilution b")
allrecords = within(allrecords, Dilution[grepl("dilutionc", allrecords$Sample)] <- "dilution c")



write.csv(allrecords, "actionable_records.csv", row.names=FALSE)
