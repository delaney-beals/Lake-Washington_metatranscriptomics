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
