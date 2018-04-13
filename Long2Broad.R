# Title: Transpose Long2Broad
# Author: Martin Fritzsche
# Date: 28/03/2018

# This script converts a list of sample names (input via clipboard), which had been converted from broad to long format, back to broad format.
# It is the converse of the Broad2Long script and writes the output back into the clipboard.

input <- unlist(read.table("clipboard", stringsAsFactors = FALSE, header = FALSE, colClasses = "character", sep = "\n")) # Read-in single excel column from clipboard, convert from dataframe to vector

l <- length(input) # Determine length of input string

c <- ceiling(l / 8) # Determine number of columns used (in 96 well plate)

r <- 8-(c*8-l) # Determine number of rows for first subset

sub1 <- matrix(input, nrow = r, ncol = c, byrow = TRUE) # Convert to sub-matrix 1 (complete rows), fill by row

remaining_n = c*r + 1 # Determine index of remaining cells

sub2 <- matrix(input[remaining_n:l], nrow = 8-r, ncol = (l-(remaining_n-1))/(8-r) , byrow = TRUE) # Convert to sub-matrix 2, fill by row

sub2 <- cbind(sub2, rep(NA, 8-r)) # Add one column of NA (in order to achieve same length as sub-matrix 1) to sub-matrix 2

output <- rbind(sub1, sub2) # Combine sub-matrix 1 and 2

output <- as.vector(output) # Convert to vector by column (default behavior)

output <- output[!is.na(output)] # Remove "NA"

writeClipboard(output) # Write to clipboard
