library(rvest)
library(stringr)
library(Rsubread)
library(DESeq2)
library(ggplot2)
library(pheatmap)
library(reshape2)
library(Rsamtools)
library(GenomicRanges)
library(GenomicAlignments)
library(rtracklayer)
library(ape)
library(dplyr)
library(tidyr)
library(purrr)

# Function to parse GenBank files
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

# Function to extract start and end positions from the location string
extract_positions <- function(location) {
  if (grepl("complement", location)) {
    location <- gsub("complement\\((.*)\\)", "\\1", location)
  }
  start <- as.numeric(gsub("([0-9]+)\\.\\..*", "\\1", location))
  end <- as.numeric(gsub(".*\\.\\.([0-9]+)", "\\1", location))
  return(c(start, end))
}

# Directory containing the .gbk files
gbk_dir <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.062.fastanoDAS_assembly.RAST.gbff/"

# Read the index.html file and extract sequence names
index_file <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.062.fastanoDAS_assembly.RAST.gbff/index.html"
html_content <- read_html(index_file)

# Extract relevant information
seq_info <- html_content %>%
  html_nodes(xpath = "//body") %>%
  html_text() %>%
  str_split("\n") %>%
  unlist()

# Extract sequence names from the HTML
seq_info <- str_extract_all(seq_info, "c\\d+_NODE_\\d+\\.\\. .*\\(original name was: NODE_\\d+_length_\\d+_cov_\\d+\\.\\d+\\) .*") %>%
  unlist()

# Get the number of .gbk files in the directory
gbk_files <- list.files(gbk_dir, pattern = "\\.gbk$", full.names = TRUE)
num_gbk_files <- length(gbk_files)

# Extract the same number of sequence names as there are .gbk files
seq_info <- seq_info[1:num_gbk_files]

# Parse the extracted information into a named list
seqnames <- sapply(seq_info, function(info) {
  parts <- str_match(info, "(c\\d+_NODE_\\d+\\.\\..*) \\(original name was: (NODE_\\d+_length_\\d+_cov_\\d+\\.\\d+)\\)")
  c(parts[2], parts[3])
}, simplify = FALSE)

# Create a named list where the key is the file pattern and the value is the sequence name
seqnames <- setNames(sapply(seqnames, "[", 2), sapply(seqnames, "[", 1))

# Function to extract sequence names from BAM header
get_bam_seqnames <- function(bamfile) {
  bam_header <- scanBamHeader(bamfile)
  seqnames <- names(bam_header[[1]]$targets)
  return(seqnames)
}

# Process each .gbk file (OPEN AND CHECK THAT THE CORRECT BAM FILE IS BEING USED!!!)
for (i in seq_along(gbk_files)) {
  gbk_file <- gbk_files[i]
  filename <- basename(gbk_file)
  
  # Get the corresponding seqname from the seqnames list based on index
  seqname <- seqnames[[i]]
  
  if (is.null(seqname)) {
    warning(paste("No seqname found for file:", filename))
    next
  }
  
  # Debug: Print the current filename and corresponding seqname
  cat("Processing file:", filename, "with seqname:", seqname, "\n")
  
  # Parse the GenBank file
  genes <- parseGenbank(gbk_file)
  
  # Convert to data frame
  genes_df <- do.call(rbind, lapply(genes, as.data.frame))
  genes_df$seqname <- seqname
  
  # Extract start and end positions
  positions <- t(apply(genes_df, 1, function(row) extract_positions(row['location'])))
  genes_df$start <- positions[, 1]
  genes_df$end <- positions[, 2]
  
  # Remove rows with NA positions
  genes_df <- genes_df[!is.na(genes_df$start) & !is.na(genes_df$end), ]
  
  # Create a GRanges object
  gr <- GRanges(seqnames = Rle(genes_df$seqname),
                ranges = IRanges(start = genes_df$start, end = genes_df$end),
                gene = genes_df$name)
  
  # Define BAM file paths
  input_bam <- "LWdata/21113X2_bin062_accepted_hits.bam"
  output_bam <- paste0("LWdata/bin_062_accepted_hits/21113X1_accepted_hits_", seqname, "_BGC.bam")
  
  # Check if the BAM file is already indexed
  if (!file.exists(paste0(input_bam, ".bai"))) {
    cat("Indexing BAM file:", input_bam, "\n")
    indexBam(input_bam)
  }
  
  # Get sequence names from the BAM file header
  bam_seqnames <- get_bam_seqnames(input_bam)
  cat("Sequence names in BAM file:", bam_seqnames, "\n")
  
  # Check if the seqname exists in the BAM file header
  if (!(seqname %in% bam_seqnames)) {
    warning(paste("Seqname", seqname, "not found in BAM file header for file:", filename))
    next
  }
  
  # Define a parameter to read the BAM file
  param <- ScanBamParam(which = gr)
  
  # Open the BAM file and ensure it has an index
  bamfile <- BamFile(input_bam, index = paste0(input_bam, ".bai"))
  
  # Read the alignments using the ScanBamParam
  bam <- readGAlignments(bamfile, param = param)
  
  # Write the subsetted BAM file
  export(bam, output_bam, format = "BAM")
  
  # Define file paths
  gtf_file_path <- paste0("LWdata/", seqname, ".gtf")
  
  # Extract gene annotations
  genes <- readGenBankFile(gbk_file)
  
  # Create a GTF-like dataframe
  gtf_data <- data.frame(
    seqname = seqname,
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
  
  # Define file paths
  output_counts_path <- paste0("LWdata/", seqname, "_gene_counts.txt")
  
  # Perform gene counting
  fc <- featureCounts(files = output_bam,
                      annot.ext = gtf_file_path,
                      isGTFAnnotationFile = TRUE,
                      GTF.featureType = "gene",
                      GTF.attrType = "gene_id",
                      isPairedEnd = FALSE,
                      nthreads = 4)
  
  # Save the gene counts to a file
  count_table <- as.data.frame(fc$counts)
  write.table(count_table, file = output_counts_path, sep = "\t", quote = FALSE, col.names = NA)
  }

# COMBINE GENE COUNT TABLES
# Directory containing the gene count files
counts_dir <- "LWdata"

# List all files in the directory that end with "_gene_counts.txt"
count_files <- list.files(counts_dir, pattern = "_gene_counts.txt$", full.names = TRUE)


# Function to read a count file and add a column for the sample name
read_count_file <- function(file) {
  sample_name <- gsub("_gene_counts.txt$", "", basename(file))
  df <- read.table(file, header = FALSE, col.names = c("genes", "count"), fill = TRUE)
  df <- df[complete.cases(df), ]  # Remove rows with NA values
  df$Node <- sample_name  # Add the sample name as a new column
  return(df)
}

# Read all count files into a list of data frames
count_list <- lapply(count_files, read_count_file)

# Combine all data frames into a single long format data frame
long_format_counts <- bind_rows(count_list)

# View the long format counts data frame
print(long_format_counts)

# Sum up the counts from each shared value of "node"
summarized_counts <- long_format_counts %>%
  group_by(Node) %>%
  summarise(counts = sum(count, na.rm = TRUE))


# Function to extract secondary metabolites from an HTML file
extract_secondary_metabolites <- function(file_path) {
  # Read the HTML file
  page <- read_html(file_path)
  
  # Initialize empty lists to store the data
  region_ids <- list()
  types <- list()
  from_positions <- list()
  to_positions <- list()
  similar_clusters <- list()
  similarities <- list()
  
  # Extract data from the HTML
  regions <- page %>% html_nodes("table tr")
  
  for (region in regions) {
    # Extract columns
    cols <- region %>% html_nodes("td") %>% html_text(trim = TRUE)
    
    # Check if this row contains the necessary data (at least 4 columns)
    if (length(cols) >= 4) {
      region_ids <- c(region_ids, cols[1])
      types <- c(types, cols[2])
      from_positions <- c(from_positions, cols[3])
      to_positions <- c(to_positions, cols[4])
      
      # Handle cases with optional columns
      similar_clusters <- c(similar_clusters, ifelse(length(cols) > 4, cols[5], ""))
      similarities <- c(similarities, ifelse(length(cols) > 5, cols[6], ""))
    }
  }
  
  # Create a data frame from the extracted data
  data <- data.frame(
    Region_ID = unlist(region_ids),
    Type = unlist(types),
    From = unlist(from_positions),
    To = unlist(to_positions),
    Most_Similar_Cluster = unlist(similar_clusters),
    Similarity = unlist(similarities),
    stringsAsFactors = FALSE
  )
  
  # Add file name column
  data$file_name <- basename(file_path)
  
  # Extract bin name from file name
  data$bin <- sub(".*(bin\\.\\d+).*", "\\1", data$file_name)
  
  return(data)
}


# Function to process all HTML files in a folder and combine the results
process_folder <- function(folder_path) {
  # Get the list of HTML files in the folder
  html_files <- list.files(folder_path, pattern = "\\.html$", full.names = TRUE)
  
  # Initialize an empty data frame to store the combined data
  combined_df <- data.frame()
  
  # Loop through each HTML file and extract the data
  for (file in html_files) {
    df <- extract_secondary_metabolites(file)
    combined_df <- bind_rows(combined_df, df)
  }
  
  # Remove duplicate rows
  combined_df <- combined_df %>% distinct()
  
  return(combined_df)
}

# Specify the folder path
folder_path <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report"

# Process the folder and get the combined data frame
secondary_metabolites_all <- process_folder(folder_path)

# Display the dataframe
print(secondary_metabolites_all)

# keep only rows containing "Region" and not "BGC" (this fixes something strange happening where I am extracting mystery data from the html file)
secondary_metabolites_all <- secondary_metabolites_all[grepl("Region", secondary_metabolites_all$Region_ID), ]

# Keep only rows containing "bin.062" in the "file_name" column
secondary_metabolites_062 <- secondary_metabolites_all %>% 
  filter(grepl("bin\\.062", file_name))

# Keep only rows containing "bin.062" in the "file_name" column
secondary_metabolites_062 <- secondary_metabolites_all %>% 
  filter(grepl("bin\\.062", file_name))

# MERGING BCG NAMES WITH NODES
# first run extract_BGCs_html.R to get the BCG info from the html files; then come back and run the following code
# merge summarized count info with BGC info
# Merge the two dataframes based on the "To" column
NodesCountsRegion <- as.data.frame(inner_join(summarized_counts, nodeAndRegionData_062, by = "Node"))

NodesCountsRegionMetab <- inner_join(NodesCountsRegion, secondary_metabolites_062, by = "Region_ID")


# plot
ggplot(NodesCountsRegionMetab, aes(x = Type, y = counts, fill = Type)) +
  geom_bar(stat = "identity", color = "black") +
  theme_minimal() +
  labs(title = "Reads per BGC type in bin.050 (g_Methylosinus)",
       x = "Type of BGC",
       y = "Read Count") +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1)) 


# normalize in some way; try doing # of reads/# of genes
## Filter the dataframe to keep only rows where 'bin' contains 'bin.062'
filtered_data_062 <- aggregated_data %>% 
  filter(grepl("bin\\.062", bin))

# Aggregate the read data 
aggregated_reads_062 <- NodesCountsRegionMetab %>%
  group_by(Type) %>%
  summarise(total_counts = sum(counts, na.rm = TRUE))

# Join the tables on the "Type" column
joined_data <- inner_join(aggregated_reads_062, filtered_data_062, by = "Type")

# Perform the division
result_tbl <- joined_data %>%
  mutate(result = total_counts / count) %>%
  select(Type, result)

# normalized plot
ggplot(result_tbl, aes(x = Type, y = result, fill = Type)) +
  geom_bar(stat = "identity", color = "black") +
  theme_minimal() +
  labs(title = "Reads per all BGC type in bin.050 (g_Methylosinus)",
       x = "Type of BGC",
       y = "Read Count") +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1)) 

# change categories
filtered_data_050_new <- filtered_data_050 %>%
  mutate(Type = case_when(
    Type == "NRPS" ~ "NRPS",
    Type == "NRPS-like" ~ "NRPS",
    Type == "terpene" ~ "Terpene",
    Type == "T1PKS" ~ "PKS",
    Type == "T3PKS" ~ "PKS",
    Type == "T1PKS,T3PKS" ~ "PKS",
    Type == "siderophore" ~ "Siderophore",
    Type == "RiPP-like" ~ "RiPP",
    Type == "RRE-containing" ~ "RRE-containing",
    Type == "redox-cofactor" ~ "Redox Cofactor",
    Type == "hserlactone" ~ "Homoserine lactone",
    Type == "NAPAA" ~ "Non-Amino Acid Peptide",
    TRUE ~ "Other"
  ))
filtered_data_050_new <- filtered_data_050_new %>%
  group_by(Type) %>%
  summarise(count = n()) %>%
  ungroup()


# Aggregate the read data 
aggregated_reads_050_new <- aggregated_reads_050 %>%
  mutate(Type = case_when(
    Type == "NRPS" ~ "NRPS",
    Type == "NRPS-like" ~ "NRPS",
    Type == "terpene" ~ "Terpene",
    Type == "T1PKS" ~ "PKS",
    Type == "T3PKS" ~ "PKS",
    Type == "T1PKS,T3PKS" ~ "PKS",
    Type == "siderophore" ~ "Siderophore",
    Type == "RiPP-like" ~ "RiPP",
    Type == "RRE-containing" ~ "RRE-containing",
    Type == "redox-cofactor" ~ "Redox Cofactor",
    Type == "hserlactone" ~ "Homoserine lactone",
    Type == "NAPAA" ~ "Non-Amino Acid Peptide",
    TRUE ~ "Other"
  ))

aggregated_reads_050_new <- aggregated_reads_050_new %>%
  group_by(Type) %>%
  summarise(total_counts = sum(total_counts, na.rm = TRUE))


# Join the tables on the "Type" column
joined_data_new <- inner_join(aggregated_reads_050_new, filtered_data_050_new, by = "Type")

# Perform the division
result_tbl_new <- joined_data_new %>%
  mutate(result = total_counts / count) %>%
  select(Type, result)

ggplot(result_tbl_new, aes(x = Type, y = result, fill = Type)) +
  geom_bar(stat = "identity", color = "black") +
  theme_minimal() +
  labs(title = "Reads per all BGC type in bin.050 (g_Methylosinus)",
       x = "Type of BGC",
       y = "Read Count") +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1)) 
