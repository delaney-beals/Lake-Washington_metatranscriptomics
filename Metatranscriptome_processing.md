# Lake Washington Low-Iron Metatranscriptomics Processing and Analysis

## Tasks and Outputs

### 1. Remove adapters and PhiX with bbduk

- [x] Run `bbduk.sh` (`slurm-6823318.out`)
- [x] Confirm output files (`${sample}.interleaved.atrim.decontam.fq.gz`) can be read and have a reasonable size

#### Check file size

```bash
ls -lh /path/sample.interleaved.atrim.fq.gz
```

Expected output:

```text
12G
13G
```

#### Check file contents

```bash
zcat /path/sample.interleaved.atrim.fq.gz | head -n 20
```

#### Optional: Check line count

```bash
zcat /path/sample.interleaved.atrim.fq.gz | wc -l
```

---

### 2. Trim and filter based on quality with fastp

- [x] Run `fastp.sh` (`slurm-6824734.out`)
- [x] Confirm output files (`${sample}.interleaved.atrim.decontam.fastp.fq.gz`) can be read and have a reasonable size

---

### 3. Build the Bowtie2 index

- [x] Run `bowtie_index.sh`
- [x] Verify the presence of index files

Expected files:

```text
scaffold_index.1.bt2
scaffold_index.2.bt2
scaffold_index.3.bt2
scaffold_index.4.bt2
scaffold_index.rev.1.bt2
scaffold_index.rev.2.bt2
```

---

### 4. Read mapping with Bowtie2

- [x] Ensure the Bowtie2 environment contains samtools

```bash
conda activate bowtie2
conda install bioconda::samtools
```

- [x] Run `bowtie.sh` (`slurm-6825492.out`)
- [x] Confirm output files can be read and have a reasonable size

#### Check alignment rates

Inspect the Bowtie2 log files.

Observed alignment rates:

```text
87.01%
86.27%
80.94%
```

#### Verify BAM files exist

```bash
ls *.bam
```

#### Check BAM file size

```bash
ls -lh /path/sample.bam
```

Expected output:

```text
6.5G
7.0G
6.1G
```

#### Check BAM header

```bash
samtools view -H \
/scratch/general/vast/u1260626/21113R/Billy_metaSPAdes/21113X1_20230901_LH00227_0010_A227Y5JLT3_S59_L003.bam
```

Expected output:

```text
@SQ SN:NODE_35212_length_2000_cov_70.075578 LN:2000
...
```

---

### 5. Merge biological replicate BAM files with samtools

- [x] Run `merge_bam.sh` (`slurm-6825748.out`)
- [x] Confirm output files can be read and have a reasonable size

#### Check merged BAM size

```bash
ls -lh /scratch/general/vast/u1260626/21113R/merged_replicates.bam
```

Expected output:

```text
18G
```

#### Check BAM index size

```bash
ls -lh /scratch/general/vast/u1260626/21113R/merged_replicates.bam.bai
```

Expected output:

```text
3.1M
```

