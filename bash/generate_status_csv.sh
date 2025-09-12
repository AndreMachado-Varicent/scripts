#!/bin/bash

# Script to generate a CSV file with STATUS_x,Status_x format
# where x is a number from 1 to 1000

# Output file name
output_file="status_data.csv"

# Create or overwrite the CSV file
echo "Creating CSV file: $output_file"

# Write header (optional)
echo "Column1,Column2" > "$output_file"

# Generate entries from 1 to 1000
for i in {1001..20000}; do
    echo "STATUS_$i,Status_$i" >> "$output_file"
done

echo "CSV file '$output_file' has been created successfully!"
echo "Total entries: 1000"
