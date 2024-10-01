From 3 biological replicates of low-iron, methane-fed Lake Washington sediment enrichments, we have:
   - metaSPAdes-assembled metagenome assemblies (21142X1, 21142X2, 21142X3, coassembly)
   - metatranscriptomes (21113X1, 21113X2, 21113X3)

1. Make bowtie2 indices of each metagenome assembly
2. Map each metatranscriptome replicate onto each metagenome assembly
     - This should result in 12 total .bam files


## For each metagenome...

1. Convert .gbk files to .gff
   - Add [gbk_to_gff.py](https://github.com/delaney-beals/LW-lowFe/blob/main/gbk_to_gff.py) to your working directory
   - Ensure paths are correct in [gbk_to_gff.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/gbk_to_gff.sh) and run
2. Process antiSMASH Output # do this once per metagenome

   From the .gff or .gtf files, you want to extract the unique NODE_names. For example, you can use grep to extract the node information:
   > grep "NODE" scaffolds.gff | cut -f1 | sort | uniq > scaffolds_node_names.txt

4. Keep only NODES that are antiSMASH hits
   - Run the [relevant_nodes.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/relevant_nodes.sh) script to filter out only the NODE names from scaffolds.gff that have a corresponding .gbk file in the antiSMASH output folder.

5. Generate table of biosynthetic gene cluster names
   - Navigate to where the .gbk files are stored and run [protocluster_table.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/protocluster_table.sh).
   - Copy the protocluster_table.txt to map_meta/21142X# 


## For each metatranscriptome...
4. Extract coverage information
   - This will create a file node_read_counts.txt where each row contains:
   
     NODE_name | NODE_length | number_of_mapped_reads | number_of_unmapped_reads
   > samtools idxstats your_alignment.bam > node_read_counts.txt

5. Combine the read counts with the NODE_name information from antiSMASH
   > join -1 1 -2 1 <(sort node_read_counts.txt) <(sort nodes_in_antismash.txt) > combined_node_read_counts.txt

6. Add biosynthetic cluster names to read count table using [merge_tables.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/merge_tables.sh) 

7. Convert merged_output.txt to a .csv
   > tr -s ' ' ',' < merged_output_21113X2.txt > merged_output_21113X2.csv
   

Now go to metaSPAdes_antismash_viz.Rmd to visualize these. 


