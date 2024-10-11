#!/bin/bash

# Path to the folder containing the .gbk files
gbk_folder="/scratch/general/vast/u1260626/antismash_indv_metaSPAdes/21142X1"

# Output file for matching NODEs
output_file="nodes_in_antismash.txt"

# Ensure the output file is empty
> $output_file

# Loop through each NODE in the scaffolds_node_names.txt
while read -r node; do
    # Check if the corresponding .gbk file exists
    if [ -f "$gbk_folder/$node.region001.gbk" ]; then
        echo "$node" >> $output_file
    elif [ -f "$gbk_folder/$node.region002.gbk" ]; then
        echo "$node" >> $output_file
    fi
done < scaffolds_node_names.txt

# Inform the user
echo "Filtered NODE names saved to $output_file"
