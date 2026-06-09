# Methane community metagenomics and metatranscriptomics exploration

This repository contains exploratory metagenomic and metatranscriptomic analyses performed on a methane-oxidizing bacterial community enriched in low iron nitrate mineral salts medium under methane gas from a Lake Washington sediment inoculum.

The analyses in this repository were conducted during the early stages of a project that ultimately resulted in the publication:

> Robes JMD, Liebergesell TCE, Beals DG, Yu X, Brazelton WJ, Puri AW. 2025. *Inverse stable isotope probing–metabolomics (InverSIP) identifies an iron acquisition system in a methane-oxidizing bacterial community*. PNAS.

Unlike the code associated with the final publication, **this repository primarily contains exploratory workflows** used to evaluate metagenomic assemblies, metatranscriptomic mapping strategies, metagenome-assembled genomes (MAGs), biosynthetic gene clusters (BGCs), and antiSMASH-derived secondary metabolite predictions.

## Repository contents

* **Metatranscriptome_processing/**

  * Bash scripts for adapter trimming, quality control, read mapping, and transcriptome processing.

* Additional scripts and notebooks

  * Exploratory analyses investigating MAGs, BGC expression, antiSMASH predictions, and BiG-MAP outputs.

## Relationship to published work

This repository documents exploratory analyses that informed later project development but does not represent the final computational workflow used for the published study. The final publication focused on identifying and characterizing methylocystabactin through integration of metagenomics, metatranscriptomics, metabolomics, and InverSIP experiments.

## Data availability

Raw sequencing data are not included in this repository. File paths and software environments reflect the original analysis environment and may require modification before reuse.

----
# Main workflow
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



