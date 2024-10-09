#!/bin/bash

# Sort the protocluster table once, as it's common to all operations
sort protocluster_table.txt > sorted_protocluster_table.txt

# List of the files you want to process
files=("21113X1" "21113X2" "21113X3")

# Loop over each file and perform the sort and join operations
for file in "${files[@]}"; do
    # Sort the combined node read counts file
    sort combined_node_read_counts_"$file".txt > sorted_combined_node_read_counts_"$file".txt

    # Join the sorted node read counts with the sorted protocluster table
    join -1 1 -2 1 -a 1 sorted_combined_node_read_counts_"$file".txt sorted_protocluster_table.txt > merged_output_"$file".txt

    # Notify that the merged table has been created
    echo "Merged table created: merged_output_$file.txt"
done
