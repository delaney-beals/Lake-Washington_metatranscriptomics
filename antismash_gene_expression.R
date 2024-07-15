


if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("pheatmap")


library(Rsubread)
library(DESeq2)
library(ggplot2)
library(pheatmap)
library(reshape2)
library(Rsamtools)
library(GenomicRanges)
library(GenomicAlignments)
library(rtracklayer)
library(Rsubread)
library(ape)


# 1. Extract antiSMASH hits ####--------------------------------------------------------------
parseGenbank <- function(file) {
  con <- file(file, "r")
  genes <- list()
  
  while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
    if (grepl("^\\s+CDS\\s+", line)) {
      location <- gsub("^\\s+CDS\\s+", "", line)
      gene <- list(location = location)
      
      while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0 && !grepl("^\\s+/\\w+", line)) {
        if (grepl("^\\s+/gene=", line)) {
          gene$name <- gsub('^\\s+/gene="(.+)"$', '\\1', line)
        }
      }
      
      genes[[length(genes) + 1]] <- gene
    }
  }
  
  close(con)
  return(genes)
}

# Use the parser on your GenBank file
genes <- parseGenbank( "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.050.fastanoDAS_assembly.RAST.gbff/c00003_NODE_10...region001.gbk")

# Convert to data frame
genes_df <- do.call(rbind, lapply(genes, as.data.frame))
genes_df$seqname <- "NODE_10019_length_6474_cov_194.853248" 

# Extract start and end positions from the location string
extract_positions <- function(location) {
  if (grepl("complement", location)) {
    location <- gsub("complement\\((.*)\\)", "\\1", location)
  }
  start <- as.numeric(gsub("([0-9]+)\\.\\..*", "\\1", location))
  end <- as.numeric(gsub(".*\\.\\.([0-9]+)", "\\1", location))
  return(c(start, end))
}

positions <- t(apply(genes_df, 1, function(row) extract_positions(row['location'])))
genes_df$start <- positions[, 1]
genes_df$end <- positions[, 2]

# Remove rows with NA positions
genes_df <- genes_df[!is.na(genes_df$start) & !is.na(genes_df$end), ]

# Create a GRanges object
gr <- GRanges(seqnames = Rle(genes_df$seqname),
              ranges = IRanges(start = genes_df$start, end = genes_df$end),
              gene = genes_df$name)

# 2. Subset BAM file ####--------------------------------------------------------------
# Define the input and output BAM file paths
input_bam <- "LWdata/21113X1_accepted_hits_bin050.bam"
output_bam <- "LWdata/21113X1_accepted_hits_bin050_BGC.bam"

#index the BAM file
indexBam(input_bam)

# Define a parameter to read the BAM file
param <- ScanBamParam(which = gr)

# Open the BAM file and ensure it has an index
bamfile <- BamFile(input_bam, index = paste0(input_bam, ".bai"))

# Read the alignments using the ScanBamParam
bam <- readGAlignments(bamfile, param = param)

# Write the subsetted BAM file
export(bam, output_bam, format = "BAM")

# 3. Perform gene counting ####--------------------------------------------------------------

# step 3.1: read the .gbk file and extract the gene annotations
# Function to read GenBank file and extract gene annotations
readGenBankFile <- function(file_path) {
  lines <- readLines(file_path)
  
  # Initialize lists to store gene information
  genes <- list()
  current_gene <- NULL
  in_gene <- FALSE
  
  for (line in lines) {
    if (grepl("^ +gene +", line)) {
      in_gene <- TRUE
      if (!is.null(current_gene)) {
        genes <- append(genes, list(current_gene))
      }
      current_gene <- list(start = NULL, end = NULL, strand = NULL, gene_id = NULL)
      coords <- strsplit(gsub("^ +gene +", "", line), "\\.\\.")[[1]]
      current_gene$start <- as.numeric(gsub("[^0-9]", "", coords[1]))
      current_gene$end <- as.numeric(gsub("[^0-9]", "", coords[2]))
      current_gene$strand <- ifelse(grepl("complement", line), "-", "+")
    } else if (in_gene && grepl("/gene=", line)) {
      current_gene$gene_id <- gsub('/gene="|"$', "", line)
      in_gene <- FALSE
    }
  }
  if (!is.null(current_gene)) {
    genes <- append(genes, list(current_gene))
  }
  
  return(genes)
}

# Define file paths
gbk_file_path <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.050.fastanoDAS_assembly.RAST.gbff/c00003_NODE_10...region001.gbk"  # Update this with the path to your GBK file
gtf_file_path <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.050.fastanoDAS_assembly.RAST.gbff/c00003_NODE_10...region001.gtf"  # Path to save the GTF file

# Extract gene annotations
genes <- readGenBankFile(gbk_file_path)

# Check for any gene information extracted
if (length(genes) == 0) {
  stop("No genes were extracted from the GenBank file.")
}

# Create a GTF-like dataframe
gtf_data <- data.frame(
  seqname = "NODE_10019_length_6474_cov_194.853248",  # Replace this with the actual sequence name if known
  source = "GenBank",
  feature = "gene",
  start = sapply(genes, function(g) g$start),
  end = sapply(genes, function(g) g$end),
  score = ".",
  strand = sapply(genes, function(g) g$strand),
  frame = ".",
  attribute = sapply(genes, function(g) paste0('gene_id "', g$gene_id, '";'))
)


# Write the GTF-like data to a file
write.table(gtf_data, file = gtf_file_path, sep = "\t", quote = FALSE, col.names = FALSE, row.names = FALSE)

# step 3.2: perform gene counting using "featureCounts"
# Define file paths
bam_file_path <- "LWdata/21113X1_accepted_hits_bin050_BGC.bam"  # Update this with the correct path to your BAM file
output_counts_path <- "LWdata/21113X1_bin050_gene_counts.txt"  # Update this with the correct path to your output counts file

# Perform gene counting
fc <- featureCounts(files = bam_file_path,
                    annot.ext = gtf_file_path,
                    isGTFAnnotationFile = TRUE,
                    GTF.featureType = "gene",
                    GTF.attrType = "gene_id",
                    isPairedEnd = FALSE,  # Set to TRUE if your reads are paired-end
                    nthreads = 4)  # Set the number of threads according to your system

# Save the gene counts to a file
count_table_050_1 <- as.data.frame(fc$counts, file = output_counts_path, sep = "\t", quote = FALSE, col.names = NA)


