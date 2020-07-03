#This program will sort the species according to their number of reads in descending order

# Get report.txt file
args <- commandArgs(trailingOnly = TRUE)
report_file <- args[1]

report_txt_file <- read.table(report_file, 
                              header = FALSE, 
                              sep = "\t")

# Change in dataframe
report_dataframe = data.frame(report_txt_file)

# Add 6 names columns in dataframme. 
colnames(report_dataframe) <- c("Pourcentage", 
                                "Reads_total", 
                                "Reads_rank", 
                                "Rank", 
                                "Taxonomy", 
                                "Name")

# Recover lines with a specie rank (S)
line_with_specie <- with(report_dataframe, which(Rank=="S", arr.ind = TRUE))

# Recover species only and add in new dataframe.
specie_dataframe <- data.frame(report_dataframe$Reads_total[line_with_specie],
                               report_dataframe$Name[line_with_specie])

# Sort in decrease of Reads_total.
result <- specie_dataframe[order(specie_dataframe$report_dataframe.Reads_total.line_with_specie. ,
                                 decreasing=TRUE),]

# Get the output name with .tsv extension.
name_output <- sub("\\.txt", "", basename(report_file))
name_output <- paste(name_output,".tsv", sep = "")

# Make a tsv output.
write.table(result, file=name_output, sep='\t', col.names = c("Max Reads", "Name"), row.names = FALSE)