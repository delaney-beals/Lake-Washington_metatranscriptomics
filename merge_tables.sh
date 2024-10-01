#!/bin/bash

# Sort both files by the NODE column
sort combined_node_read_counts_21113X3.txt > sorted_combined_node_read_counts_21113X3.txt
sort protocluster_table.txt > sorted_protocluster_table.txt

# Join the files on the NODE column (column 1 in both files)
# This will combine the rows where the NODE matches and keep rows from the primary table
join -1 1 -2 1 -a 1 sorted_combined_node_read_counts_21113X3.txt sorted_protocluster_table.txt > merged_output_21113X3.txt

# Inform the user
echo "Merged table created: merged_output_21113X3.txt"
