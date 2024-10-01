# For each metagenome...
1. Process antiSMASH Output # do this once per metagenome
   - From the .gff or .gtf files, you want to extract the unique NODE_names. For example, you can use grep to extract the node information:
> grep "NODE" scaffolds.gff | cut -f1 | sort | uniq > scaffolds_node_names.txt

2. Keep only NODES that are antiSMASH hits, do this once per metagenome
   - Run the following script to filter out only the NODE names from scaffolds.gff that have a corresponding .gbk file in the folder /scratch/general/vast/u1260626/antismash_indv_metaSPAdes/21142X1 (using relavent_nodes.sh):
>#!/bin/bash
>#Path to the folder containing the .gbk files
>gbk_folder="/scratch/general/vast/u1260626/antismash_indv_metaSPAdes/21142X1"
>#Output file for matching NODEs
>output_file="nodes_in_antismash.txt"
>#Ensure the output file is empty
> #>$output_file
>#Loop through each NODE in the scaffolds_node_names.txt
>while read -r node; do
>#Check if the corresponding .gbk file exists
>if [ -f "$gbk_folder/$node.region001.gbk" ]; then
>echo "$node" >> $output_file
>elif [ -f "$gbk_folder/$node.region002.gbk" ]; then
>echo "$node" >> $output_file
>fi
>done < scaffolds_node_names.txt
>echo "Filtered NODE names saved to $output_file"

3. Generate table of biosynthetic gene cluster names # do this once per metagenome
   - Navigate to where the .gbk files are stored and run the following (protocluster_table.sh): 
>#!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     # Output file                                                                                                                                                                                                                                   output_file="protocluster_table.txt"                                                                                                                                                                                                                                                                                                                                                                                                                                                            # Write header to output file                                                                                                                                                                                                                   echo "NODE | Product" > $output_file                                                                                                                                                                                                                                                                                                                                                                                                                                                            # Loop through each .gbk file in the directory                                                                                                                                                                                                  for gbk_file in NODE_*.gbk; do                                                                                                                                                                                                                      # Extract the NODE information from the file                                                                                                                                                                                                    NODE=$(grep -m 1 "LOCUS" "$gbk_file" | awk '{print $2}')                                                                                                                                                                                        if [ -z "$NODE" ]; then                                                                                                                                                                                                                           NODE="unknown"                                                                                                                                                                                                                                fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              # Extract the product information (whatever follows /product=)                                                                                                                                                                                  PRODUCT=$(grep '/product="' "$gbk_file" | sed -n 's/.*\/product="\([^"]*\)".*/\1/p' | sort -u | paste -sd ',')
>                                                                                                                                                                                                                                                                                                                                                                                  # If a product is found, append NODE and product to the output file                                                                                                                                                                             if [ ! -z "$PRODUCT" ]; then                                                                                                                                                                                                                        echo "$NODE | $PRODUCT" >> $output_file                                                                                                                                                                                                     fi
>done
>echo "Table created: $output_file"

5. copy protocluster_table.txt to map_meta/21142X1

# For each metatranscriptome...
5. Extract Coverage Information #do this for all bam files
>samtools idxstats your_alignment.bam > node_read_counts.txt
This will create a file node_read_counts.txt where each line contains:
NODE_name   NODE_length   number_of_mapped_reads   number_of_unmapped_reads

6. Combine the Information into a Table # do this for each metatranscriptome
Next, you can use join or awk to combine the read counts from node_read_counts.txt with the NODE_name information from antiSMASH.
join -1 1 -2 1 <(sort node_read_counts.txt) <(sort nodes_in_antismash.txt) > combined_node_read_counts.txt

7. add biosynthetic cluster names to read count table using merge_tables.sh # do this for each metatranscriptome
#!/bin/bash
#Sort both files by the NODE column
sort combined_node_read_counts.txt > sorted_combined_node_read_counts.txt
sort protocluster_table.txt > sorted_protocluster_table.txt
#Join the files on the NODE column (column 1 in both files)
#This will combine the rows where the NODE matches and keep rows from the primary table
join -1 1 -2 1 -a 1 sorted_combined_node_read_counts.txt sorted_protocluster_table.txt > merged_output.txt
echo "Merged table created: merged_output.txt"


9. convert merged_output.txt to a csv
tr -s ' ' ',' < merged_output_21113X2.txt > merged_output_21113X2.csv


