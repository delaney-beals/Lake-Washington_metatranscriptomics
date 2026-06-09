### Mapping merged reads to the co-assembly
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://kbase.us/n/156152/78/) : trim, check quality, and assemble (merging biological replicates)
         - Download the **metaSPAdes_merged.Assembly.fa** file
      - Starting with raw RNA reads
         - Run the bash scripts in [Metatranscriptome_processing.md](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing.md) to trim adapters, check quality, map reads to the metagenome, and merge biological replicates
         - Output files: **merged_replicates.bam** and its accompanying indexed bam, **merged_replicates.bam.bai**
  2. Run antiSMASH on the metagenome
       - Run [Local_antiSMASH](https://github.com/delaney-beals/LW-lowFe/blob/main/scripts/Local_antiSMASH.sh) on **metaSPAdes_merged.Assembly.fa**
       - Output files: **metaSPAdes_merged_Assembly.gbk** and **index.html**
          - *Optional: check reads in Integrated Genome Viewer software where metaSPAdes_merged.Assembly.fa is the genome and the reads are loaded in using merged_replicates.bam. Can also try loading in the metaSPAdes_merged_Assembly.gbk as the genome and the merged_replicates.bam as the reads; doing this is how I found that the .gbk did not separate the metagenome into different nodes, even though the index.html includes different nodes that align with what's in the .bam file. The following steps are based on this discrepancy.*
       - Copy all node + BGC hits from index.html and paste into a new text file called **metaspades_merged_bgc.txt**
  3. Scan antiSMASH output hmtl to collate gene ID and BGC type
       - Run [co-assembly_antismash.R](https://github.com/delaney-beals/LW-lowFe/blob/main/Co-assembly/co-assembly_antismash.R)
       - Output files: **output_annotation.gtf**
  4. Get read counts for all BGCs
       - Run [Feature_counts](https://github.com/delaney-beals/LW-lowFe/blob/main/Co-assembly/Feature_counts.sh) in bash
       - Output file: **feature_counts.txt**, **feature_counts.txt.summary**, and **feature_counts_individual.txt**
  5. Data visualization of distribution of BGCs
       - Run [feature_counts_visualization.R](https://github.com/delaney-beals/LW-lowFe/blob/main/Co-assembly/feature_counts_visualization.R)
