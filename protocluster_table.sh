#!/bin/bash

# Output file
output_file="protocluster_table.txt"

# Write header to output file
echo "NODE | Product" > $output_file

# Loop through each .gbk file in the directory
for gbk_file in NODE_*.gbk; do

    # Extract the NODE information from the file
    NODE=$(grep -m 1 "LOCUS" "$gbk_file" | awk '{print $2}')
    if [ -z "$NODE" ]; then
        NODE="unknown"
    fi

    # Extract the product information (whatever follows /product=)
    PRODUCT=$(grep '/product="' "$gbk_file" | sed -n 's/.*\/product="\([^"]*\)".*/\1/p' | sort -u | paste -sd ',')

    # If a product is found, append NODE and product to the output file
    if [ ! -z "$PRODUCT" ]; then
        echo "$NODE | $PRODUCT" >> $output_file
    fi
done

# Inform the user
echo "Table created: $output_file"
