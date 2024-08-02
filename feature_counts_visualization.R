library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(cowplot)

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
    Geneid = first(Geneid),
    Count = n(),
    Length = first(Length),
    Total_Reads = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam),
    Start = sum(Start),
    End = sum(End),
    Reads_Per_Gene = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam) / n(),
    Reads_Per_Length = first(X.scratch.general.vast.u1260626.21113R.filtered_reads3.bam) / first(Length),
    .groups = 'drop'
  )

# filter out rows with NA for total_reads
counts_summary_filt <- counts_summary %>%
  filter(!is.na(Total_Reads))

# Create the bar plot
length_plot <- ggplot(counts_summary_filt, aes(x = Geneid, y = Reads_Per_Length, fill = Geneid)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per BGC length") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

gene_plot <- ggplot(counts_summary_filt, aes(x = Geneid, y = Reads_Per_Gene, fill = Geneid)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "BGCs found in co-assembly metatranscriptome",
       x = "Type of BGC",
       y = "Total reads per BGC count") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 45, hjust = 1, vjust = 1.1), legend.position = "none")

plot_grid(length_plot, gene_plot, ncol = 2)

