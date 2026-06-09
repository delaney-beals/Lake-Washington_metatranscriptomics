#!/bin/bash
#SBATCH --account=puri
#SBATCH --partition=lonepeak 
#SBATCH --cpus-per-task=12    
module use $HOME/MyModules    
module load miniconda3/latest 
source /uufs/chpc.utah.edu/common/home/u1260626/software/pkg/miniconda3/etc/profile.d/conda.sh   
conda activate subread    

# Define file paths       
BAM_FILE="/scratch/general/vast/u1260626/21113R/merged_replicates.bam"   
GTF_FILE="/scratch/general/vast/u1260626/21113R/output_annotation.gtf"    
FILTERED_BAM_FILE="/scratch/general/vast/u1260626/21113R/filtered_reads5.bam"   
RELEVANT_NODES_FILE="/scratch/general/vast/u1260626/21113R/relevant_nodes5.txt"  
COMMON_NODES_FILE="/scratch/general/vast/u1260626/21113R/common_nodes5.txt"      
OUTPUT_DIR="/scratch/general/vast/u1260626/21113R/"                              
OUTPUT_FILE="${OUTPUT_DIR}/feature_counts5.txt"                                  

# Step 1: Extract relevant nodes and their regions from the GTF file             
echo "Extracting relevant nodes and regions from the GTF file..."                
awk '{if ($3 == "gene") print $1":"$4"-"$5}' $GTF_FILE | sort | uniq > $RELEVANT_NODES_FILE   
echo "Relevant nodes and regions extracted:"                                                   
head $RELEVANT_NODES_FILE                                                                      

# Step 2: Extract node names from BAM file                                                                  
echo "Extracting node names from BAM file..."                                                               
samtools view -H $BAM_FILE | grep '@SQ' | awk '{print $2}' | sed 's/SN://' > ${OUTPUT_DIR}/bam_nodes.txt    

# Step 3: Find common nodes between GTF and BAM files                                                       
echo "Finding common nodes between GTF and BAM files..."                                                   
comm -12 <(sort $RELEVANT_NODES_FILE) <(sort ${OUTPUT_DIR}/bam_nodes.txt) > $COMMON_NODES_FILE             
echo "Common nodes:"                                                                                      
cat $COMMON_NODES_FILE                                                                                  

# Step 4: Filter BAM file based on common nodes and regions        
echo "Filtering BAM file based on common nodes and regions..."                 
samtools view -H $BAM_FILE > ${OUTPUT_DIR}/header.sam                          
: > ${OUTPUT_DIR}/body.sam # Initialize an empty body.sam  
while read -r REGION; do                                            
samtools view $BAM_FILE $REGION >> ${OUTPUT_DIR}/body.sam           
done < $RELEVANT_NODES_FILE                                      
cat ${OUTPUT_DIR}/header.sam ${OUTPUT_DIR}/body.sam | samtools view -b > $FILTERED_BAM_FILE

# Step 5: Index the filtered BAM file           
echo "Indexing the filtered BAM file..."       
samtools index $FILTERED_BAM_FILE              

# Clean up intermediate files                  
rm ${OUTPUT_DIR}/header.sam ${OUTPUT_DIR}/body.sam       

# Step 6: Run featureCounts on the filtered BAM file          
echo "Running featureCounts..."                                                 
featureCounts -T 8 -p -t gene -g gene_id -a $GTF_FILE -o $OUTPUT_FILE $FILTERED_BAM_FILE    
echo "Pipeline completed. The feature counts are stored in ${OUTPUT_DIR}feature_counts5.txt."  

