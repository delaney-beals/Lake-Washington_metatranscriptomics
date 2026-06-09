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

---

# Scripts

## bbduk.sh

```bash
#! /bin/sh                                                                                                                                                                                                         
#SBATCH --cpus-per-task 4                                                                                                                                                                                          
#SBATCH --nodes 1                                                                                                                                                                                                  
#SBATCH --account=puri                                                                                                                                                                                             
#SBATCH --partition=lonepeak                                                                                                                                                                                       
for sample in `awk '{print $1}' samples.txt`                                                                                                                                                                       
do                                                                                                                                                                                                                
~/software/bbmap/bbduk.sh -Xmx10g ziplevel=9 threads=12 qin=33 ref=adapters.fa in1=/scratch/general/vast/u6015879/LWRNAseq21113R/${sample}_R1_001.fastq.gz in2=/scratch/general/vast/u6015879/LWRNAseq21113R/${sample}_R2_001.fastq.gz out=/scratch/general/vast/u1260626/21113R/${sample}.interleaved.atrim.fq.gz stats=/scratch/general/vast/u1260626/21113R/${sample}.adapter_stats.txt ftm=5 ktrim=r k=23 mink=9 rcomp=t hdist=2 tbo tpe minlength=0 2>/scratch/general/vast/u1260626/21113R/${sample}.adapters.log
~/software/bbmap/bbduk.sh -Xmx10g threads=12 qin=33 interleaved=t ref=phix.fa in=/scratch/general/vast/u1260626/21113R/${sample}.interleaved.atrim.fq.gz out=/scratch/general/vast/u1260626/21113R/${sample}.interleaved.atrim.decontam.fq.gz outm=/scratch/general/vast/u1260626/21113R/${sample}.phix.fq.gz k=31 hdist=1 mcf=0.9 stats=/scratch/general/vast/u1260626/21113R/${sample}.phix_stats.txt 2</scratch/general/vast/u1260626/21113R/${sample}.phix.log
done 
```

---

## fastp2.sh

```bash
#!/bin/bash
#SBATCH --account=puri        
#SBATCH --partition=lonepeak 
#SBATCH --cpus-per-task=12   

module use $HOME/MyModules       
module load miniconda3/latest
source /uufs/chpc.utah.edu/common/home/u1260626/software/pkg/miniconda3/etc/profile.d/conda.sh   

# Activate the conda environment    
conda activate /uufs/chpc.utah.edu/common/home/u1260626/my_conda_envs/fastp_env  

# Verify that fastp is available     
if ! command -v fastp &> /dev/null; then  
echo "fastp could not be found in the environment. Exiting."      
exit 1                                                                                                                                                                                                                                   
fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

# Process samples
for sample in $(awk '{print $1}' samples.txt)  
do                                            
echo "Processing sample: $sample"             
input_file="/scratch/general/vast/u1260626/21113R/${sample}.interleaved.atrim.decontam.fq.gz"             
output_file="/scratch/general/vast/u1260626/21113R/${sample}.interleaved.atrim.decontam.fastp.fq.gz"      
if [[ -f "$input_file" ]]; then                                                                             
fastp --thread 12 --cut_front --cut_window_size 8 --cut_mean_quality 28 --interleaved_in -i "$input_file" --stdout > "$output_file"    
else                                                                                                                                   
echo "Input file $input_file does not exist. Skipping." 
done 
```

---

## bowtie_index.sh

```bash
#! /bin/sh
#SBATCH --cpus-per-task 4
#SBATCH --nodes 1
#SBATCH --account=puri
#SBATCH --partition=lonepeak
module use $HOME/MyModules
module load miniconda3/latest
source /uufs/chpc.utah.edu/common/home/u1260626/software/pkg/miniconda3/etc/profile.d/conda.sh
conda activate bowtie2
bowtie2-build /scratch/general/vast/u1260626/21113R/Billy_metaSPAdes/scaffolds.fasta /scratch/general/vast/u1260626/21113R/Billy_metaSPAdes/scaffold_index 
```

---

## bowtie.sh

```bash
#!/bin/bash     
#SBATCH --account=puri    
#SBATCH --partition=lonepeak 
#SBATCH --cpus-per-task=12     

module use $HOME/MyModules        
module load miniconda3/latest   
source /uufs/chpc.utah.edu/common/home/u1260626/software/pkg/miniconda3/etc/profile.d/conda.sh          
conda activate bowtie2          

# Verify Bowtie2 index files exist   
if [[ ! -f "/scratch/general/vast/u1260626/21113R/metaSPAdes_merged.1.bt2" ]]; then       
echo "Bowtie 2 index files not found in /scratch/general/vast/u1260626/21113R/"  
exit 1                                                              
fi                                                                                                      

for sample in $(awk '{print $1}' samples.txt)
do                                            
samplePath="/scratch/general/vast/u1260626/21113R/${sample}"        
interleavedFile="${samplePath}.interleaved.atrim.decontam.fastp.fq.gz"      
samFile="${samplePath}.sam"                                                    
rawBamFile="${samplePath}_RAW.bam"                                                        
bamFile="${samplePath}.bam"
logFile="${samplePath}.mapping.log"         
bowtie2LogFile="${samplePath}.bowtie2.log"  

# Check if interleaved file exists       
if [[ ! -f "$interleavedFile" ]]; then    
echo "Interleaved file not found: $interleavedFile" | tee -a "$logFile"      
continue
fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

# Run bowtie2             
echo "Running bowtie2 for sample $sample..." | tee -a "$logFile"     
bowtie2 --threads 12 -x /scratch/general/vast/u1260626/21113R/metaSPAdes_merged --interleaved "$interleavedFile" --no-unal -S "$samFile" 2> "$bowtie2LogFile"   

# Check if SAM file was generated   
if [[ ! -f "$samFile" ]]; then
echo "SAM file not generated: $samFile" | tee -a "$logFile"  
echo "Check the Bowtie2 log for errors: $bowtie2LogFile" | tee -a "$logFile" 
continue                                                              
fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

# Convert SAM to BAM, sort, and index      
echo "Processing SAM file for sample $sample..." | tee -a "$logFile" 
samtools view -F 4 -bS "$samFile" > "$rawBamFile"                           
samtools sort "$rawBamFile" -o "$bamFile"                                   
samtools index "$bamFile"                                                  

# Remove intermediate files     
rm "$samFile" "$rawBamFile"       
done 

```

---

## merge_bam.sh

```bash
#!/bin/sh
#SBATCH --cpus-per-task 4
#SBATCH --nodes 1
#SBATCH --account=puri
#SBATCH --partition=lonepeak

# Define the output merged BAM file
output_bam="/scratch/general/vast/u1260626/21113R/merged_replicates.bam"

# Define the input BAM files
input_bams=("/scratch/general/vast/u1260626/21113R/21113X1_20230901_LH00227_0010_A227Y5JLT3_S59_L003.bam"
"/scratch/general/vast/u1260626/21113R/21113X2_20230901_LH00227_0010_A227Y5JLT3_S60_L003.bam"
"/scratch/general/vast/u1260626/21113R/21113X3_20230901_LH00227_0010_A227Y5JLT3_S61_L003.bam")

# Merge the BAM files
samtools merge -f "$output_bam" "${input_bams[@]}"

# Index the merged BAM file (optional but recommended)
samtools index "$output_bam"
```
