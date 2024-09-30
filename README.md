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
       - Run [feature_counts_visualization.R](https://github.com/delaney-beals/LW-lowFe/blob/main/feature_counts_visualization.R)

### Individual bins
1. Download all **bin.###.fastanoDAS_assembly.RAST** genbank files from [KBASE](https://narrative.kbase.us/narrative/156152) analysis
2. extract and organize all .gbff files using [unzip_KBase_files.R](https://github.com/delaney-beals/LW-lowFe/blob/main/unzip_KBase_files.R)
3. process

### antiSMASH output of individual metaSPAdes assemblies + co-assembly 
1. run concatenate_gbk.sh
   - output file is a single .fa file which serves as our reference genome for aligning reads
2. build a bowtie index of the single .fa file
3. run bowtie 2 using all metatranscriptome replicates
4. run readcount3.sh, which does the following:
   - Extract the number of reads for each node/contig from the BAM file.

### map_meta: all replicates and co-assembly
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://narrative.kbase.us/narrative/156152): trim, check quality, and assemble (merging biological replicates for the co-assembly)
         - Download each metaSPAdes-assembled **21142X#.Assembly.fa** file (4 total)
      - Starting with raw RNA reads
         - Run the bash scripts in [Metatranscriptome_processing](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing) to trim adapters, check quality, map reads to the metagenome
         - Repeat this for all four metagenomes: rep 1, rep 2, rep 3, and the co-assembly. Each of these four metagenomes will have all three metatranscriptome replicates mapped onto them. 
         - Output files: **X.bam** and its accompanying indexed bam, **X.bam.bai**
  2. Run antiSMASH on the metagenome
       - Run [Local_antiSMASH](https://github.com/delaney-beals/LW-lowFe/blob/main/Local_antiSMASH) on all four **21142X#.Assembly.fa** files, including the coassembly
       - Output files: **21142X#/NODE_#_length_#_cov.gbk**
  4. Prep antiSMASH data by converting .gbk --> .gff [ ]( _) and then .gff --> .gtf [ ]( )
  5. Get read counts for all BGCs
       - Run [Feature_counts](https://github.com/delaney-beals/LW-lowFe/blob/main/Feature_counts) in bash
       - Output file: **feature_counts.txt**, **feature_counts.txt.summary**, and **feature_counts_individual.txt**
  6. Data visualization of distribution of BGCs
       - Run [feature_counts_visualization.R](https://github.com/delaney-beals/LW-lowFe/blob/main/feature_counts_visualization.R)
   - Parse the .gbk files to extract biosynthetic gene cluster (BGC) categories such as "terpene."
   - Combine the data from the BAM file (read counts) and .gbk files (BGC categories) into a table, indicating from which metatranscriptome replicate the read count information was pulled from
5. visualize comparison between metatranscriptome replicates using metaspades_antismash_viz.Rmd
6. merge metatranscriptome reads? 
