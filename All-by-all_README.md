### Mapping all reads sets to all replicates + co-assembly and focusing on antiSMASH clusters of interest
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

