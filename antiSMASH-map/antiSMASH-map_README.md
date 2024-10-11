### Mapping reads to antiSMASH clusters of interest
1. run [concatenate_gbk.sh](https://github.com/delaney-beals/LW-lowFe/blob/main/antiSMASH-map/concatenate_gbk.sh)
   - output file is a single .fa file which serves as our reference genome for aligning reads
2. build a bowtie index of the single .fa file
3. run bowtie 2 using all metatranscriptome replicates
4. run readcount3.sh, which does the following:
   - Extract the number of reads for each node/contig from the BAM file.
