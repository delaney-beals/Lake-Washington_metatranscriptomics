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
