## Processing metagenomes and their metatranscriptomes

### Co-assembly
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://narrative.kbase.us/narrative/156152): trim, check quality, and assemble (merging biological replicates)
         - Download the **metaSPAdes_merged.Assembly.fa** file
      - Starting with raw RNA reads
         - Using the bash scripts in "Lake Washington low iron metatranscriptome scripts. txt" file available in this repository: trim adapters, check quality, map reads to the metagenome, and merge biological replicates
         - Output files: **merged_replicates.bam** and its accompanying indexed bam, **merged_replicates.bam.bai**
  2. Run antiSMASH on the metagenome
       - Use standalone/local [antiSMASH](https://docs.antismash.secondarymetabolites.org/install/) on metaSPAdes_merged.Assembly.fa
       - Output files: **metaSPAdes_merged_Assembly.gbk** and **index.html**
       - Copy all node + BGC hits from index.html and paste into a text file called **metaspades_merged_bgc.txt**
  3. Get read counts for all BGCs
       - Run **co-assembly_antismash.R**, available in this repository
       - Output files: gene_counts.txt
  4. Data visualization of distribution of BGCs


### Individual bins
1. Download all bin.###.fastanoDAS_assembly.RAST genbank files from [KBASE](https://narrative.kbase.us/narrative/156152) analysis
2. extract and organize all .gbff files using the "unzip_KBase_files" script in R
