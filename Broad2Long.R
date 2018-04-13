# Title: Transpose Broad2Long
# Author: Martin Fritzsche
# Date: 28/03/2018

# This script converts a list of sample names (input via clipboard) from "filled-by-row" (broad) format to "filled-by-column" (long).
# It writes the output back into the clipboard.


# Read-in single excel column from clipboard, convert from dataframe to vector
input <- unlist(read.table("clipboard", stringsAsFactors = FALSE, header = FALSE, colClasses = "character", sep = "\n")) 

# Pad vector with "NA" to a total length of 96 (otherwise conversion to array would be not possible)
length(input) <- 96 

# Convert to matrix, fill by column
input_matrix <- matrix(input, nrow = 8, ncol = 12, byrow = FALSE, dimnames = list(LETTERS[1:8], c(1:12))) 
print(input_matrix)

output_matrix <- t(input_matrix) # transpose input matrix
print(output_matrix)

# Convert to vector by column (default behavior)
output <- as.vector(output_matrix) 

# Remove "NA"
output <- output[!is.na(output)] 

# Write to clipboard
writeClipboard(output)