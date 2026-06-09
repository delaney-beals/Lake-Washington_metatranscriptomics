### Exploring the biosynthetic potential of a methane-oxidizing bacterial community through metagenomics and metatranscriptomics
Starting with 3 biological replicates and raw DNA and RNA sequencing data: 
1. Process the DNA to generate metagenomes
2. Process the RNA to generate metatranscriptomes
   - Run the bash scripts in [Metatranscriptome_processing](https://github.com/delaney-beals/LW-lowFe/blob/main/Metatranscriptome_processing) to trim adapters, check quality, map reads to the   metagenome, and *optionally* merge biological replicates 


Once you have processed all 3 samples, each with a corresponding metagenome (21142X#) and metatranscriptome (21113X#), here are the avenues for analysis: 
1. [Mapping merged reads to the co-assembly](https://github.com/delaney-beals/LW-lowFe/blob/main/Co-assembly/Co-assembly_README.md)
2. [Mapping reads to individual MAGs of interest](https://github.com/delaney-beals/LW-lowFe/blob/main/Individual-MAGs/Individual-MAGs_README.md)
3. [Mapping reads to antiSMASH clusters of interest](https://github.com/delaney-beals/LW-lowFe/blob/main/antiSMASH-map/antiSMASH-map_README.md)
4. [Mapping all reads sets to all replicates + co-assembly and focusing on antiSMASH clusters of interest](https://github.com/delaney-beals/LW-lowFe/blob/main/All-by-all/All-by-all_README.md)
5. [BiG-MAP analysis to get RPKM values](https://github.com/delaney-beals/LW-lowFe/blob/main/BiG-MAP/bigmap_RPKM_cleaning.R)



