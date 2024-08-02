## Processing metagenomes and their metatranscriptomes

### Co-assembly
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://narrative.kbase.us/narrative/156152): trim, check quality, and assemble (merging biological replicates)
         - Download the **metaSPAdes_merged.Assembly.fa** file
      - Starting with raw RNA reads
         - Run the bash scripts in [Metatranscriptome_processing](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing) to trim adapters, check quality, map reads to the metagenome, and merge biological replicates
         - Output files: **merged_replicates.bam** and its accompanying indexed bam, **merged_replicates.bam.bai**
  2. Run antiSMASH on the metagenome
       - Run [Local_antiSMASH](https://github.com/delaney-beals/LW-lowFe/blob/main/Local_antiSMASH) on **metaSPAdes_merged.Assembly.fa**
       - Output files: **metaSPAdes_merged_Assembly.gbk** and **index.html**
          - *Optional: check reads in Integrated Genome Viewer software where metaSPAdes_merged.Assembly.fa is the genome and the reads are loaded in using merged_replicates.bam. Can also try loading in the metaSPAdes_merged_Assembly.gbk as the genome and the merged_replicates.bam as the reads; doing this is how I found that the .gbk did not separate the metagenome into different nodes, even though the index.html includes different nodes that align with what's in the .bam file. The following steps are based on this discrepancy.*
       - Copy all node + BGC hits from index.html and paste into a new text file called **metaspades_merged_bgc.txt**
  3. Scan antiSMASH output hmtl to collate gene ID and BGC type
       - Run [co-assembly_antismash.R](https://github.com/delaney-beals/LW-lowFe/blob/main/co-assembly_antismash.R)
       - Output files: **output_annotation.gtf**
  4. Get read counts for all BGCs
       - Run [Feature_counts](https://github.com/delaney-beals/LW-lowFe/blob/main/Feature_counts) in bash
       - Output file: **feature_counts.txt**, **feature_counts.txt.summary**, and **feature_counts_individual.txt**
  5. Data visualization of distribution of BGCs
       - Run [feature_counts_visualization.R]()


### Individual bins
1. Download all **bin.###.fastanoDAS_assembly.RAST** genbank files from [KBASE](https://narrative.kbase.us/narrative/156152) analysis
2. extract and organize all .gbff files using [unzip_KBase_files.R](https://github.com/delaney-beals/LW-lowFe/blob/main/unzip_KBase_files.R)
3. process 
