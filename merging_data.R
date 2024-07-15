library(rvest)
library(dplyr)
library(stringr)


# Function to extract NODE_ names and Region IDs from an HTML file
extractNodeAndRegionIDsFromHTML <- function(htmlFile) {
  # Read the HTML content from the file
  page <- read_html(htmlFile)
  
  # Extract all text from the HTML file
  textContent <- html_text(page)
  textLines <- strsplit(textContent, "\n")[[1]]
  
  # Initialize empty vectors to store the nodes and region IDs
  nodes <- c()
  region_ids <- c()
  
  # Extract NODE_ names and Region IDs from the text content
  for (line in textLines) {
    if (grepl("original name was: NODE_", line)) {
      nodeName <- sub(".*original name was: (NODE_\\S+).*", "\\1", line)
      nodeName <- gsub("\\).*", "", nodeName)  # Remove everything after the closing parenthesis
      nodes <- c(nodes, nodeName)
    }
    if (grepl("Region&nbsp", line)) {
      regionID <- sub(".*Region&nbsp([0-9.]+).*", "Region\\1", line)
      region_ids <- c(region_ids, regionID)
    }
  }
  
  # Create a data frame from the extracted data
  data <- data.frame(
    Node = nodes,
    Region_ID = region_ids[1:length(nodes)],  # Ensure the lengths match
    stringsAsFactors = FALSE
  )
  
  return(data)
}

# Path to your HTML file
htmlFile <- "C:/Users/Delaney/OneDrive/unknown/Documents/antismash_download/Antismash_107_bins_HTML_report/Antismash on collection 107_ HTML report/KBase_derived_bin.062.fastanoDAS_assembly.RAST.gbff.html"

# Extract NODE_ names and Region IDs from the HTML file
nodeAndRegionData <- extractNodeAndRegionIDsFromHTML(htmlFile)

# subset dataframe
nodeAndRegionData_050 <- nodeAndRegionData[1:26, ]

# i know that NODE_4682 and NODE_516 didn't make it through the pipeline because I suspect there were no reads assigned to those contigs. I know this because of the warning out put after I ran the "process .gbk files" in the antismash_gene_expression_highthruput script
# for now I want to remove those nodes

nodeAndRegionData_050 <- subset(nodeAndRegionData_050, Node != "NODE_4682_length_12699_cov_32.3638")
nodeAndRegionData_050 <- subset(nodeAndRegionData_050, Node != "NODE_516_length_75863_cov_38.79451")

# Modify the "Region_ID" column
nodeAndRegionData_050$Region_ID <- sub("Region", "Region&nbsp", nodeAndRegionData_050$Region_ID)



