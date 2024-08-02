## Processing metagenomes and their metatranscriptomes

### Co-assembly
  1. Process DNA and RNA
       - Starting with raw DNA sequences
         - In [KBASE](https://narrative.kbase.us/narrative/156152): trim, check quality, and assemble (merging biological replicates)
         - Download the **metaSPAdes_merged.Assembly.fa** file
      - Starting with raw RNA reads
         - Using the bash scripts in "[Metatranscriptome_processing](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing)" file available in this repository: trim adapters, check quality, map reads to the metagenome, and merge biological replicates
         - Output files: **merged_replicates.bam** and its accompanying indexed bam, **merged_replicates.bam.bai**
  2. Run antiSMASH on the metagenome
       - Use standalone/local antiSMASH on **metaSPAdes_merged.Assembly.fa**; script available in this repository as "Local antiSMASH"
       - Output files: **metaSPAdes_merged_Assembly.gbk** and **index.html**
       - Copy all node + BGC hits from index.html and paste into a new text file called **metaspades_merged_bgc.txt**
  3. Scan antiSMASH output to collate gene ID and BGC type
       - Run **co-assembly_antismash.R**, available in this repository
       - Output files: **output_annotation.gtf**
  4. Get read counts for all BGCs
       - Run featurecounts2.sh in bash on CHPC; script available in this repository
       - Output file: **feature_counts.txt** and **feature_counts.txt.summary**
  5. Clean up feature_counts ouput file
       - Run 
  7. Data visualization of distribution of BGCs


### Individual bins
1. Download all bin.###.fastanoDAS_assembly.RAST genbank files from [KBASE](https://narrative.kbase.us/narrative/156152) analysis
2. extract and organize all .gbff files using the "unzip_KBase_files" script in R
