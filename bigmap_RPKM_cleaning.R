# CLEANING BIGMAP CSV-RESULTS

library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)

#### Data prep: only run once ####
# load in data
BiGMAP.results.RPKM <- read.csv("BiG-MAP.map.results.RPKM.csv")
NODE_dictionary <- read.csv("node_dictionary.csv", row.names = 1 )

# separate the information in the first column and rename each column
RPKM_table <- BiGMAP.results.RPKM %>%
  separate(gene_clusters, into = c("gb", "NODE_name", "GC_DNA", "Entryname", "BGC", "OS", "node", "NR1", "smashregion", "region", "dereplication_factor", "BG", "BG_factor"), sep = "\\|+|=|--", extra = "merge", fill = "right")

# delete meaningless columns
RPKM_table <- RPKM_table %>%
  select(-gb, -GC_DNA, -Entryname, -OS, -NR1, -BG)

# Remove ".region001" from every value in the NODE_name column
RPKM_table$NODE_name <- gsub("\\.region00[1234567]$", "", RPKM_table$NODE_name)

# merge the node dictionary to the main table to associate the assemblies to each node
RPKM_table_merge <- RPKM_table %>%
  left_join(NODE_dictionary, by = "NODE_name")

# average the RPKM between reads replicates 21113X1 and 21113X3
RPKM_table_merge <- RPKM_table_merge %>%
  mutate(AVG_X1_X3 = rowMeans(select(., X21113X1, X21113X3), na.rm = TRUE),
         SD_X1_X3 = apply(select(., X21113X1, X21113X3), 1, sd, na.rm = TRUE)
         )

# save the table
write.csv(RPKM_table_merge, "RPKM_table.csv")

# some values are NA for the assembly column, I am going to make a df with just these and then search the scaffold.gbk of each assembly in bash on the CHPC
missing_assembly <- RPKM_table_merge %>%
  filter(is.na(assembly)) %>%
  select(NODE_name) 

write.csv(missing_assembly, "missing_assembly.csv")

#### START HERE FOR RE-ANALYSIS USING CLEANED DATA ####
RPKM_table_merge <- read.csv("RPKM_table.csv", row.names = 1 )

# clarify assignments
RPKM_table_merge <- RPKM_table_merge %>%
  mutate(BGC = ifelse(NODE_name == "NODE_474_length_39305_cov_79.198038", "NRPS:NRP-metallophore", BGC)) %>%
  separate(BGC, into = c("BGC", "secondary_BGC"), sep = ":", fill = "right", extra = "merge")

# pivot the table so that the RPKM are in long format
RPKM_table_long <- RPKM_table_merge %>%
  pivot_longer(cols = starts_with("X21113X"), 
               names_to = "MTX_replicate", 
               values_to = "RPKM") 

# create a stacked bar plot for all nodes
ggplot(RPKM_table_long, aes(x = MTX_replicate, y = RPKM, fill = BGC)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(x = "", y = "RPKM", fill = "BGC") +
  ggtitle("RPKM by Assembly, MTX Replicate, and BGC") +
  theme_classic() +
  facet_grid(. ~ assembly, scales = "free_x", space = "free_x", switch = "x") +
  theme(strip.background = element_blank(),
        strip.placement = "outside",
        axis.text.x = element_text(angle = 45, hjust = 1))

# make this interactive with plotly
p <- ggplot(RPKM_table_long, aes(x = MTX_replicate, y = RPKM, fill = BGC, text = BGC)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(x = "", y = "RPKM", fill = "BGC") +
  ggtitle("RPKM by Assembly, MTX Replicate, and BGC") +
  theme_classic() +
  facet_grid(. ~ assembly, scales = "free_x", space = "free_x", switch = "x") +
  theme(strip.background = element_blank(),
        strip.placement = "outside",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggplotly(p, tooltip = "text")

# create a stacked bar plot for NODE_474 (siderophore of interest)
# first subset the table to only include our node of interest
NODE_474 <- RPKM_table_long %>%
  filter(NODE_name == "NODE_474_length_39305_cov_79.198038")

ggplot(NODE_474, aes(x = MTX_replicate, y = RPKM, fill = BGC)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(x = "", y = "RPKM of siderophore (NODE_474_length_39305_cov_79.198038)", fill = "BGC") +
  ggtitle("RPKM by Assembly, MTX Replicate, and BGC") +
  theme_classic() +
  facet_grid(. ~ assembly, scales = "free_x", space = "free_x", switch = "x") +
  theme(strip.background = element_blank(),
        strip.placement = "outside",
        axis.text.x = element_text(angle = 45, hjust = 1))

#### RELABELLING OR CATEGORIZING BGCs (optional) ####

# Reduce the number of individual BGC categories
# First, create a new column to categorize BGCs 
RPKM_table_summary <- RPKM_table_long %>%
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
    BGC == "lanthipeptide-class-v" ~ "Lanthipeptide",
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
    BGC == "arylpolyene" ~ "Aryl polyene",
    BGC == "indole" ~ "Indole",
    BGC == "resorcinol,arylpolyene" ~ "Resorcinol",
    BGC == "resorcinol,T3PKS" ~ "Resorcinol",
    BGC == "RRE-containing,lassopeptide" ~ "RRE-containing",
    BGC == "T1PKS,NRPS" ~ "PKS",
    BGC == "T1PKS,NRPS-like,NRPS" ~ "PKS",
    BGC == "thiopeptide" ~ "Thiopeptide",
    BGC == "T3PKS,hglE-KS" ~ "PKS",
    BGC == "thioamitides" ~ "Thioamitide RiPPs",
    BGC == "proteusin" ~ "Proteusin",
    BGC == "transAT-PKS,T3PKS" ~ "PKS",
    BGC == "transAT-PKS" ~ "PKS",
    BGC == "transAT-PKS-like" ~ "PKS",
    BGC == "CDPS" ~ "tRNA-dependent cyclodipeptide synthases",
    BGC == "NRP-metallophore" ~ "NRP-metallophore",
    BGC == "NRPS,NRPS-like" ~ "NRPS",
    BGC == "Acyl amino acids" ~ "N-acyl amino acid",      
    BGC == "Aryl polyene" ~ "Aryl polyene",           
    BGC == "T1PKS:NRPS-like" ~ "T1PKS",            
    BGC == "Butyrolactone" ~ "Butyrolactone",          
    BGC == "Copper-chelating" ~ "Copper-chelating",      
    BGC == "Heterocyst glycolipid synthase-like PKS" ~ "PKS", 
  )) %>%
  group_by(MTX_replicate, BGC_category, assembly) %>%
  summarise(total_RPKM = sum(RPKM, na.rm = TRUE))


# Create the updated stacked bar plot using the new summarized data
ggplot(RPKM_table_summary, aes(x = MTX_replicate, y = total_RPKM, fill = BGC_category)) +
  geom_bar(stat = "identity", color="black") +
  theme_minimal() +
  labs(x = "", y = "RPKM", fill = "BGC") +
  theme_classic() +
  facet_grid(. ~ assembly, scales = "free_x", space = "free_x", switch = "x") +
  theme(strip.background = element_blank(),
        strip.placement = "outside",
        axis.text.x = element_text(angle = 45, hjust = 1))

# Define the list of protocluster values from your conversion list
conversion_list <- c(
  "NRPS", "NRPS-like", "terpene", "T1PKS", "T3PKS", "T1PKS,T3PKS", "siderophore", "RiPP-like", "RRE-containing", "redox-cofactor", 
  "hserlactone", "NAPAA", "acyl_amino_acids", "acyl_amino_acids,hserlactone", "arylpolyene,ectoine", "arylpolyene,resorcinol", 
  "betalactone", "blactam", "butyrolactone", "hglE-KS", "hglE-KS,T3PKS", "hydrogen-cyanide", "lanthipeptide-class-i", 
  "lanthipeptide-class-v", "LAP", "lassopeptide", "lassopeptide,RRE-containing", "methanobactin", "NAGGN", "NI-siderophore", 
  "NRPS-like,NRPS", "NRPS-like,T1PKS", "NRPS,T1PKS", "NRPS,T1PKS,NRPS-like", "phosphonate", "ranthipeptide", "resorcinol", 
  "arylpolyene", "indole", "resorcinol,arylpolyene", "resorcinol,T3PKS", "RRE-containing,lassopeptide", "T1PKS,NRPS", 
  "T1PKS,NRPS-like,NRPS", "thiopeptide", "T3PKS,hglE-KS", "thioamitides", "proteusin", "transAT-PKS,T3PKS", "transAT-PKS", 
  "CDPS", "NRP-metallophore", "NRPS,NRPS-like"
)

# Get unique values in the protocluster column of combined_long_facet
unique_protoclusters <- unique(RPKM_table_long$BGC)

# Find values in the protocluster column that are not in the conversion list
unmatched_protoclusters <- setdiff(unique_protoclusters, conversion_list)

# Print the unmatched values
print(unmatched_protoclusters)


#### PLOT THE TOP NRPS NODES ####
RPKM_table_NRPS <- RPKM_table_merge %>%
  filter(BGC == "NRPS")

RPKM_table_NRPS_length <- RPKM_table_NRPS %>%
  filter(as.numeric(str_extract(NODE_name, "(?<=length_)[0-9]+")) > 2999)

RPKM_table_NRPS_top <- RPKM_table_NRPS_length %>%
  arrange(desc(AVG_X1_X3)) %>%
  slice(1:20)

ggplot(RPKM_table_NRPS_top, aes(x= reorder(NODE_name, AVG_X1_X3), AVG_X1_X3))+
  geom_bar(stat ="identity", fill = "goldenrod")+
  geom_errorbar(aes(ymin = AVG_X1_X3 - SD_X1_X3, ymax = AVG_X1_X3 + SD_X1_X3), width = 0.3, linewidth = 0.7) +
  coord_flip()+
  xlab("NODE")+
  ylab("Average RPKM (Rep 1 and 3, ± 1 SD)")+
  ggtitle("NRPS expression") +
  theme_classic()

  
# mirrored plot
RPKM_table_longer <- RPKM_table_NRPS_top %>%
    select(NODE_name, X21113X1, X21113X3) %>%
    pivot_longer(cols = c(X21113X1, X21113X3), names_to = "Metatranscriptome", values_to = "RPKM_value")
  
# Modify the X21113X1 values to be negative for mirrored effect
  RPKM_table_longer_flip <- RPKM_table_longer %>%
    mutate(RPKM_value = ifelse(Metatranscriptome == "X21113X1", -RPKM_value, RPKM_value))
  
# Plot with bars going outward from the center
  ggplot(RPKM_table_longer_flip, aes(x = reorder(NODE_name,RPKM_value ), y = RPKM_value, fill = Metatranscriptome)) +
    geom_bar(stat = "identity", position = "identity") +
    coord_flip() +
    xlab("NODE") +
    ylab("RPKM") +
    scale_fill_manual(values = c("#2a9d8f", "#e76f51")) +
    scale_y_continuous(labels = abs) + 
    theme_classic() +
    ggtitle("Two-sided plot with RPKM values from Rep 1 and Rep 3")

  