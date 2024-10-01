#!/usr/bin/env python

import sys
from BCBio import GFF
from Bio import SeqIO

# Check if the correct number of arguments are provided
if len(sys.argv) != 3:
    print("Usage: convert_gbk_to_gff.py <input.gbk> <output.gff>")
    sys.exit(1)

# Specify the input GenBank and output GFF files from command-line arguments
gbk_file = sys.argv[1]
gff_file = sys.argv[2]

# Open the output GFF file for writing
with open(gff_file, "w") as gff_handle:
    # Parse the GenBank file and convert to GFF format
    for seq_record in SeqIO.parse(gbk_file, "genbank"):
        GFF.write([seq_record], gff_handle)
