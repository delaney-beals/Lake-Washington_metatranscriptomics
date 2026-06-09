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
