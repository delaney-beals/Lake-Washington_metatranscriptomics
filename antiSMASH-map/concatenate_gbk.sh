#!/bin/bash

#SBATCH --account=puri
#SBATCH --partition=lonepeak
#SBATCH --cpus-per-task=4

# Define the directory containing the .gbk files
input_dir="/scratch/general/vast/u1260626/antismash_indv_metaSPAdes/21142X2/"

# Define the output file
output_file="concatenate_gbk_all.fa"

# Empty output file if it already exists
> "$output_file"

# Path to the samples.txt file
samples_file="/uufs/chpc.utah.edu/common/home/u1260626/samples.txt"

# Loop through all .gbk files in the input directory
for file in "$input_dir"/*.gbk; do
    if [ -f "$file" ]; then
        echo "Processing file: $file"
        
        # Extract the file name without the extension
        base_name="${file##*/}"
        base_name="${base_name%.gbk}"
        
        # Create the sequence identifier (header) from the file name
        header="$base_name"
        
        # Extract the sequence from the .gbk file
        # Grep for sequence lines (lowercase a-z letters), and remove numbers and spaces
        sequence=$(awk '/^ORIGIN/,/^\/\//' "$file" | tail -n +2 | tr -d ' 0-9\n')
        
        # Write the header and the sequence to the output file in FASTA format
        echo ">$header" >> "$output_file"
        echo "$sequence" >> "$output_file"
    else
        echo "Error: file $file does not exist or cannot be read."
    fi
done

echo "All sequences have been written to $output_file"
