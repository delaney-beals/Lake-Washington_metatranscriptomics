library(dplyr)
library(stringr)
library(GenomicRanges)
library(Rsamtools)
library(rtracklayer)
library(Rsubread)

# Define file paths
txt_file <- "C:/Users/Delaney/OneDrive/unknown/Desktop/metaspades_merged_bgc.txt"
fa_file <- "C:/Users/Delaney/OneDrive/unknown/Desktop/metaSPAdes_merged/metaSPAdes_merged.Assembly.fa"
bam_file <- "C:/Users/Delaney/OneDrive/unknown/Desktop/merged_replicates.bam"

# Define output file paths
output_bam <- "C:/Users/Delaney/OneDrive/unknown/Desktop/output_bam_file.bam"
gtf_file_path <- "C:/Users/Delaney/OneDrive/unknown/Desktop/output_annotation.gtf"
output_counts_path <- "C:/Users/Delaney/OneDrive/unknown/Desktop/gene_counts.txt"


# Read the text file
lines <- readLines(txt_file)

# Initialize variables to store extracted data
nodes <- c()
types <- c()
starts <- c()
ends <- c()

current_node <- NULL

# Iterate through lines and extract the relevant information
for (i in seq_along(lines)) {
  line <- str_trim(lines[i])
  if (grepl("^NODE_\\d+_length_\\d+_cov_\\d+\\.\\d+", line)) {
    current_node <- line
  } else if (grepl("^Region \\d+\\.\\d+", line) && !is.null(current_node)) {
    region_info <- str_split(line, "\t")[[1]]
    type <- region_info[2]
    start <- as.numeric(gsub(",", "", region_info[3]))
    end <- as.numeric(gsub(",", "", region_info[4]))
    nodes <- c(nodes, current_node)
    types <- c(types, type)
    starts <- c(starts, start)
    ends <- c(ends, end)
  }
}

# Create a data frame from the extracted information
genes_df <- data.frame(
  Node = nodes,
  Type = types,
  Start = starts,
  End = ends
)

# Create a GRanges object
gr <- GRanges(seqnames = Rle(genes_df$Node),
              ranges = IRanges(start = genes_df$Start, end = genes_df$End),
              gene = genes_df$Type)

# Get sequence information from the BAM file
bamfile <- BamFile(bam_file, index = paste0(bam_file, ".bai"))
seq_info <- seqinfo(bamfile)
cat("Sequence names in BAM file:", names(seq_info), "\n")

# Define a parameter to read the BAM file
param <- ScanBamParam(which = gr)

# Read the alignments using the ScanBamParam
bam <- readGAlignments(bamfile, param = param)

# Create a GTF-like dataframe for the genes of interest
gtf_data <- data.frame(
  seqname = genes_df$Node,
  source = "AntiSMASH",
  feature = "gene",
  start = genes_df$Start,
  end = genes_df$End,
  score = ".",
  strand = ".",
  frame = ".",
  attribute = paste0('gene_id "', genes_df$Type, '";')
)

# Write the GTF-like data to a file
write.table(gtf_data, file = gtf_file_path, sep = "\t", quote = FALSE, col.names = FALSE, row.names = FALSE)

