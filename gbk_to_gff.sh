#!/bin/bash

# Path to your Python conversion script
PYTHON_SCRIPT="/scratch/general/vast/u1260626/map_meta/21142X2/gbk_to_gff.py"

# Loop through all .gbk files in the directory
for gbk_file in /scratch/general/vast/u1260626/antismash_indv_metaSPAdes/21142X2/*.gbk; do

    # Define the output GFF file name by replacing .gbk with .gff
    gff_file="${gbk_file%.gbk}.gff"

    # Run the Python conversion script with the input and output files as arguments
    python "$PYTHON_SCRIPT" "$gbk_file" "$gff_file"

    # Notify about the conversion
    echo "Converted $gbk_file to $gff_file"

done
