### Mapping all reads sets to all replicates + co-assembly and focusing on antiSMASH clusters of interest
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://narrative.kbase.us/narrative/156152): trim, check quality, and assemble (merging biological replicates for the co-assembly)
         - Download each metaSPAdes-assembled **21142X#.Assembly.fa** file (4 total)
      - Starting with raw RNA reads
         - Run the bash scripts in [Metatranscriptome_processing](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing) to trim adapters, check quality, map reads to the metagenome
         - Make bowtie2 indices of each metagenome assembly
         - Repeat this for all four metagenomes: rep 1, rep 2, rep 3, and the co-assembly. Each of these four metagenomes will have all three metatranscriptome replicates mapped onto them (resulting in 12 total .bam files). 
         - Output files: **X.bam** and its accompanying indexed bam, **X.bam.bai**
  2. Run antiSMASH on the metagenome
       - Run [Local_antiSMASH](https://github.com/delaney-beals/LW-lowFe/blob/main/Local_antiSMASH) on all four **21142X#.Assembly.fa** files, including the coassembly
       - Output files: **21142X#/NODE_#_length_#_cov.gbk**

#### For each metagenome...
1. Convert .gbk files to .gff
   - Add [gbk_to_gff.py](https://github.com/delaney-beals/LW-lowFe/blob/main/gbk_to_gff.py) to your working directory
   - Ensure paths are correct in [gbk_to_gff.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/gbk_to_gff.sh) and run
2. Process antiSMASH Output # do this once per metagenome
      ```
      grep "NODE" scaffolds.gff | cut -f1 | sort | uniq > scaffolds_node_names.txt
      ```
4. Keep only NODES that are antiSMASH hits
   - Run the [relevant_nodes.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/relevant_nodes.sh) script to filter out only the NODE names from scaffolds.gff that have a corresponding .gbk file in the antiSMASH output folder.

5. Generate table of biosynthetic gene cluster names
   - Navigate to where the .gbk files are stored and run [protocluster_table.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/protocluster_table.sh).
   - Copy the protocluster_table.txt to map_meta/21142X# 



#### For each metatranscriptome...
Unless there's a link to a slurm script, run the indented code below directly in the CHPC command line.
1. Extract coverage information
   - This will create a file node_read_counts.txt where each row contains:
   
     NODE_name | NODE_length | number_of_mapped_reads | number_of_unmapped_reads
     ```
     samtools idxstats output/your_alignment.bam > node_read_counts.txt 
     ```
   
2. Combine the read counts with the NODE_name information from antiSMASH
     ```
     for file in node_read_counts*.txt
       do join -1 1 -2 1 <(sort "$file") <(sort nodes_in_antismash.txt) > "combined_${file%.txt}.txt"
       done
     ```
3. Add biosynthetic cluster names to read count table using [merge_tables.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/merge_tables.sh) 

4. Convert merged_output.txt to a .csv
    ```
    for file in merged_output_21113X*.txt
     do tr -s ' ' ',' < "$file" > "${file%.txt}.csv"
     done
    ```

   

Now go to [metaSPAdes_antismash_viz.Rmd](https://github.com/delaney-beals/LW-lowFe/blob/main/metaSPAdes_antismash_viz.Rmd) to visualize these. 



