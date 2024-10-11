# extract Lake Washington assemblies downloaded from KBASE

# download packages
install.packages("zip")
install.packages("fs")

# Load necessary packages
library(zip)
library(fs)

# Define the path to the directory containing the zip files
zip_dir <- "D:/Lake Washington low iron MTG"

# Define the path to the directory where the .gbff files will be moved
output_dir <- "D:/Lake Washington low iron MTG/gbff_files"
dir_create(output_dir)

# List all zip files in the directory
zip_files <- dir_ls(zip_dir, regexp = "\\.zip$")

# Function to extract and process each zip file
process_zip_file <- function(zip_file, output_dir) {
  # Create a temporary directory to extract files
  temp_dir <- tempfile()
  dir_create(temp_dir)
  
  # Extract the zip file
  unzip(zip_file, exdir = temp_dir)
  
  # Find and remove the read me files
  read_me_files <- dir_ls(temp_dir, regexp = "README", recurse = TRUE)
  file_delete(read_me_files)
  
  # Find the .gbff files and move them to the output directory
  gbff_files <- dir_ls(temp_dir, regexp = "\\.gbff$", recurse = TRUE)
  file_move(gbff_files, output_dir)
  
  # Clean up the temporary directory
  dir_delete(temp_dir)
}

# Apply the function to each zip file
lapply(zip_files, process_zip_file, output_dir = output_dir)

cat("All .gbff files have been extracted and moved to the output directory.\n")

#check that we got all 106 files
# List all files in the directory
file_list <- dir_ls(output_dir)

# Extract the base names of the files (without extensions)
file_base_names <- path_file(file_list)

# Get the unique file base names
unique_file_names <- unique(file_base_names)

# Count the number of unique file names
num_unique_files <- length(unique_file_names)

# Print the result
cat("Number of unique file names:", num_unique_files, "\n")
