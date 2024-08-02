#! /bin/sh

#SBATCH --cpus-per-task 2
#SBATCH --nodes 1
#SBATCH --account=puri
#SBATCH --partition=lonepeak

antismash /scratch/genera/vast/u6015879/antismash/input/*.fasta --output-dir /scratch/genera/vast/u6015879/antismash/output --genefinding-tool prodigal-m
