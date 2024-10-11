#! /bin/sh
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1                 
#SBATCH --account=puri            
#SBATCH --partition=lonepeak        
module use $HOME/MyModules         
module load miniconda3/latest      
source /uufs/chpc.utah.edu/common/home/u1260626/software/pkg/miniconda3/etc/profile.d/conda.sh              
conda activate bowtie2                                                                                     
# change to where the reference genome is and where you want the output files to go                                              
bowtie2-build /scratch/general/vast/u1260626/map_meta/21142X2/scaffolds_21142X2.fasta /scratch/general/vast/u1260626/map_meta/21142X2/scaffold_index_21142X2  
conda deactivate
