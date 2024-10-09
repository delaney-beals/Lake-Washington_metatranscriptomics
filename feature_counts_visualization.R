library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(cowplot)
library(plotly)

#### feature_counts_individual
feature_counts_file_indiv <- "C:/Users/Delaney/OneDrive/unknown/Desktop/metaSPAdes_merged/feature_counts_individual.txt"
feature_counts_indiv <- read.delim(feature_counts_file_indiv, comment.char="#")

counts <- feature_counts_indiv %>%
  separate_rows(Start, End, Strand, sep = ";") %>%
  mutate(
    Start = as.numeric(Start),
    End = as.numeric(End)
  )


# Summarize the table by unique 'Chr'
counts_summary <- counts %>%
  group_by(Chr) %>%
  summarise(
    BGC = first(Geneid),
    Node_Variants = n(),
    Node_Length = first(Length),
    Total_Node_Reads = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam),
    Start = sum(Start),
    End = sum(End),
    Reads_Per_Variant = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam) / n(),
    Reads_Per_Node_Length = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam) / first(Length),
    .groups = 'drop'
  )

# filter out rows with NA for total_reads
counts_summary_filt <- counts_summary %>%
  filter(!is.na(Total_Node_Reads))

# Create the bar plot
length_plot <- ggplot(counts_summary_filt, aes(x = BGC, y = Reads_Per_Node_Length, fill = BGC)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per node length") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

gene_plot <- ggplot(counts_summary_filt, aes(x = BGC, y = Reads_Per_Variant, fill = BGC)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per node variant") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

plot_grid(length_plot, gene_plot, ncol = 2)

# Aggregate the read data 
counts_summary_filt_agg <- counts_summary_filt %>%
  mutate(BGC_category = case_when(
    BGC == "NRPS" ~ "NRPS",
    BGC == "NRPS-like" ~ "NRPS",
    BGC == "terpene" ~ "Terpene",
    BGC == "T1PKS" ~ "PKS",
    BGC == "T3PKS" ~ "PKS",
    BGC == "T1PKS,T3PKS" ~ "PKS",
    BGC == "siderophore" ~ "Siderophore",
    BGC == "RiPP-like" ~ "RiPP",
    BGC == "RRE-containing" ~ "RRE-containing",
    BGC == "redox-cofactor" ~ "Redox cofactor",
    BGC == "hserlactone" ~ "Homoserine lactone",
    BGC == "NAPAA" ~ "Non-amino acid peptide",
    BGC == "acyl_amino_acids" ~ "Acyl amino acids",
    BGC == "acyl_amino_acids,hserlactone" ~ "Acyl amino acids",
    BGC == "arylpolyene,ectoine" ~ "Aryl polyene",
    BGC == "arylpolyene,resorcinol" ~ "Aryl polyene",
    BGC == "betalactone" ~ "Betalactone",
    BGC == "blactam" ~ "β-lactam",
    BGC == "butyrolactone" ~ "Butyrolactone",
    BGC == "hglE-KS" ~ "Heterocyst glycolipid synthase-like PKS",
    BGC == "hglE-KS,T3PKS" ~ "Heterocyst glycolipid synthase-like PKS",
    BGC == "hydrogen-cyanide" ~ "Hydrogen cyanide",
    BGC == "lanthipeptide-class-i" ~ "Lanthipeptide",
    BGC == "LAP" ~ "Linear azol(in)e-containing peptides",
    BGC == "lassopeptide" ~ "Lasso peptide",
    BGC == "lassopeptide,RRE-containing" ~ "Lasso peptide",
    BGC == "methanobactin" ~ "Copper-chelating",
    BGC == "NAGGN" ~ "N-acetylglutaminylglutamine amide",
    BGC == "NI-siderophore" ~ "Siderophore",
    BGC == "NRPS-like,NRPS" ~ "NRPS",
    BGC == "NRPS-like,T1PKS" ~ "NRPS",
    BGC == "NRPS,T1PKS" ~ "NRPS",
    BGC == "NRPS,T1PKS,NRPS-like" ~ "NRPS",
    BGC == "phosphonate" ~ "Phosphonate",
    BGC == "ranthipeptide" ~ "Ranthipeptide",
    BGC == "resorcinol" ~ "Resorcinol",
    BGC == "resorcinol,arylpolyene" ~ "Resorcinol",
    BGC == "resorcinol,T3PKS" ~ "Resorcinol",
    BGC == "RRE-containing,lassopeptide" ~ "RRE-containing",
    BGC == "T1PKS,NRPS" ~ "PKS",
    BGC == "T1PKS,NRPS-like,NRPS" ~ "PKS",
    BGC == "T3PKS,hglE-KS" ~ "PKS",
    BGC == "thioamitides" ~ "Thioamitide RiPPs",
    BGC == "transAT-PKS,T3PKS" ~ "PKS",
    BGC == "NRPS,NRPS-like" ~ "NRPS"
          ))

# Define the mapping of old BGC names to new BGC category names
bgc_mapping <- tibble::tibble(
  old_bgc = c("NRPS", "NRPS-like", "terpene", "T1PKS", "T3PKS", "T1PKS,T3PKS", 
              "siderophore", "RiPP-like", "RRE-containing", "redox-cofactor", 
              "hserlactone", "NAPAA", "acyl_amino_acids", "acyl_amino_acids,hserlactone", 
              "arylpolyene,ectoine", "arylpolyene,resorcinol", "betalactone", "blactam", 
              "butyrolactone", "hglE-KS", "hglE-KS,T3PKS", "hydrogen-cyanide", 
              "lanthipeptide-class-i", "LAP", "lassopeptide", "lassopeptide,RRE-containing", 
              "methanobactin", "NAGGN", "NI-siderophore", "NRPS-like,NRPS", "NRPS-like,T1PKS", 
              "NRPS,T1PKS", "NRPS,T1PKS,NRPS-like", "phosphonate", "ranthipeptide", 
              "resorcinol", "resorcinol,arylpolyene", "resorcinol,T3PKS", 
              "RRE-containing,lassopeptide", "T1PKS,NRPS", "T1PKS,NRPS-like,NRPS", 
              "T3PKS,hglE-KS", "thioamitides", "transAT-PKS,T3PKS", "NRPS,NRPS-like"),
  new_bgc = c("NRPS", "NRPS", "Terpene", "PKS", "PKS", "PKS", 
              "Siderophore", "RiPP", "RRE-containing", "Redox cofactor", 
              "Homoserine lactone", "Non-amino acid peptide", "Acyl amino acids", "Acyl amino acids", 
              "Aryl polyene", "Aryl polyene", "Betalactone", "β-lactam", 
              "Butyrolactone", "Heterocyst glycolipid synthase-like PKS", "Heterocyst glycolipid synthase-like PKS", 
              "Hydrogen cyanide", "Lanthipeptide", "Linear azol(in)e-containing peptides", "Lasso peptide", 
              "Lasso peptide", "Copper-chelating", "N-acetylglutaminylglutamine amide", "Siderophore", 
              "NRPS", "NRPS", "NRPS", "NRPS", "Phosphonate", "Ranthipeptide", 
              "Resorcinol", "Resorcinol", "Resorcinol", "RRE-containing", 
              "PKS", "PKS", "PKS", "Thioamitide RiPPs", "PKS", "NRPS")
)

# Create a unique color palette for the new BGC category names
unique_new_bgcs <- unique(bgc_mapping$new_bgc)
colors <- rainbow(length(unique_new_bgcs))
color_palette <- setNames(colors, unique_new_bgcs)

# Map the old BGC names to colors based on their corresponding new BGC category names
bgc_mapping <- bgc_mapping %>%
  mutate(color = color_palette[new_bgc])

# Create a named vector for the color palette
named_color_palette <- setNames(bgc_mapping$color, bgc_mapping$old_bgc)

# Create the ggplot object
summary <- ggplot(counts_summary_filt_agg, aes(x = BGC_category, y = Reads_Per_Variant, fill = BGC, 
                                               text = paste("BGC:", BGC, 
                                                            "<br>Total node reads:", Total_Node_Reads,
                                                            "<br>Node variants:", Node_Variants))) +
  geom_bar(stat = "identity", color = "black") +
  scale_fill_manual(values = named_color_palette) +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per node variant") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

# generate interactive plot
ggplotly(summary, tooltip = c("x", "y", "text"))


# Create the ggplot object
summary2 <- ggplot(counts_summary_filt_agg, aes(x = BGC_category, y = Total_Node_Reads, fill = BGC, 
                                               text = paste("BGC:", BGC, 
                                                            "<br>Total contig reads:", Total_Node_Reads,
                                                            "<br>Contig variants:", Node_Variants))) +
  geom_bar(stat = "identity", color = "black") +
  scale_fill_manual(values = named_color_palette) +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per contig") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

# generate interactive plot
ggplotly(summary2, tooltip = c("x", "y", "text"))

# Summary of # of nodes with each BGC type
counts_summary_filt_agg_summary <- counts_summary_filt_agg %>%
  group_by(BGC) %>%
  summarise(count = n()) %>%
  ungroup()

ggplot(counts_summary_filt_agg_summary, aes(x = BGC, y = count, fill = BGC)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "# of nodes of each BGC type in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "# of contigs") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

