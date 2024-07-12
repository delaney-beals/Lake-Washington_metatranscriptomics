install.packages("rvest")
library(rvest)

#### EXTRACT BIOSYNTHETIC GENE CLUSTER INFO FROM AN HTML FILE MADE DURING ANTISMASH ANALYSIS ####
# Define a function to extract secondary metabolite regions from the HTML file
extract_secondary_metabolites <- function(html_file) {
  # Read the HTML file
  page <- read_html(html_file)
  
  # Print the structure of the HTML file for debugging
  # print(page)
  
  # Initialize empty lists to store the data
  region_ids <- list()
  types <- list()
  from_positions <- list()
  to_positions <- list()
  similar_clusters <- list()
  similarities <- list()
  
  # Extract data from the HTML
  regions <- page %>% html_nodes("table tr")
  
  # Debugging: print the number of rows found
  cat("Number of rows found:", length(regions), "\n")
  
  for (region in regions) {
    # Extract columns
    cols <- region %>% html_nodes("td") %>% html_text(trim = TRUE)
    
    # Debugging: print the content of cols
    if (length(cols) > 0) {
      print(cols)
    }
    
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
  
  return(data)
}

# Path to your HTML file
html_file <- "C:/Users/Delaney/Downloads/54_ Antismash on collection 53_ HTML report/Antismash on collection 53_ HTML report/bin.050.fastanoDAS_assembly.fa.html"

# Extract the data
secondary_metabolites <- extract_secondary_metabolites(html_file)

# Display the data
print(secondary_metabolites)


#### CREATE A DATAFRAME LISTING ALL IDENTIFIED BGCs FROM MULTIPLE METAGENOMES ####
library(xml2)
library(rvest)
library(dplyr)

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
  data$bin <- sub("^(bin\\.\\d+).*", "\\1", data$file_name)
  
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
  
  return(combined_df)
}


# Specify the folder path
folder_path <- "C:/Users/Delaney/Downloads/54_ Antismash on collection 53_ HTML report/Antismash on collection 53_ HTML report"

# Process the folder and get the combined data frame
secondary_metabolites_all <- process_folder(folder_path)

# Display the combined data frame
print(secondary_metabolites_all)


#### MAKE A PLOT #### 
library(ggplot2)

# Aggregate data for the plot
aggregated_data <- secondary_metabolites_all %>%
  group_by(bin, Type) %>%
  summarise(count = n()) %>%
  ungroup()

# Create the stacked bar plot
ggplot(aggregated_data, aes(x = bin, y = count, fill = Type)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Secondary Metabolite Types per Bin",
       x = "Bin",
       y = "Count",
       fill = "Type") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
