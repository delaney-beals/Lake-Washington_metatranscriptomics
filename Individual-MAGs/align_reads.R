# download QuasR which provides the framework for the quantification and analysis of Short Reads. 
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("Gviz")

#load the packages
suppressPackageStartupMessages({
  library(QuasR)
  library(BSgenome)
  library(Rsamtools)
  library(rtracklayer)
  library(GenomicFeatures)
  library(txdbmaker)
  library(Gviz)
})


# load in RNA sequences and the metagenome reference file
sampleFile <- "LWdata/samples_rna_paired.txt"
genomeFile <- "LWdata/bin050_BGC.fasta"

# align reads to reference file using bowtie
proj <- qAlign(sampleFile, genomeFile)

# generate a quality report
qQCReport(proj, "LWdata/qc_report.pdf")

annotFile <- "extdata/hg19sub_annotation.gtf"
txStart <- import.gff(annotFile, format = "gtf", feature.type = "start_codon")
promReg <- promoters(txStart, upstream = 500, downstream = 500)
names(promReg) <- mcols(promReg)$transcript_name

promCounts <- qCount(proj, query = promReg)

qExportWig(proj)
