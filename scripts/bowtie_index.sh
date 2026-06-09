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
