#This is a script to go through my accession to taxid files and add taxid information to my RVDB fasta file

#Need to add to the fasta file and write out a new one with entries like:
#>sequence16|kraken:taxid|32630  Adapter sequence
#In the accession2taxid files, column 2 is the accession with version (should match what is in the fasta), and column 3 is the taxid

accessiontotaxid = "nucl_gb.accession2taxid"
rvdb = "C-RVDBv15.1.clean.fasta"
outfile = "C-RVDBv15.1.taxid.fasta"

#taxidlookup = {} #big dictionary matching from accession IDs to taxid
noversionlookup = {} #lookup in case a match for the given version cannot be found


filein = open(accessiontotaxid)
header = filein.readline()
for line in filein:
    collect = line.rstrip().split()
    nover = collect[0]
    accid = collect[1]
    taxid = collect[2]
    noversionlookup[nover] = taxid
filein.close()

print("Finished reading taxid lookup, got size:")
print(len(noversionlookup))

print(noversionlookup["NC_000005"])
#This should be 9606 homo sapiens

print("Now writing out the fasta with adjusted entries")

#The fasta has sequence lines which should not be changed, and header lines starting with > such as
#>acc|REFSEQ|NC_001798.2|Human herpesvirus 2 strain HG52, complete genome

filein = open(rvdb)
fileout = open(outfile, "w")

for line in filein:
    if line[0] != ">":
        fileout.write(line)
    else:
        pipesplit = line.rstrip().split("|")
        accid = pipesplit[2]
        nover = accid.split(".")[0]
        if nover not in noversionlookup:
            fileout.write(line)
            print("Failed to get a match for fasta entry")
            print(line.rstrip())
        else:
            fileout.write(pipesplit[0]+"|kraken:taxid|"+noversionlookup[nover])
            for pipething in pipesplit[1:]:
                fileout.write("|"+pipething)
            fileout.write("\n")
filein.close()
fileout.close()


