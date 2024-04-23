#!/bin/bash

# Directory to search
dir="C:/Users/AndreMachado/code/icm-ui/packages/presenter-flexible-components/src"
#dir=C:/Users/AndreMachado/code/icm-ui/apps/icm-web/src/containers/presenterFlexibleContainer

# Minimum number of lines
min_lines=2000

# Use find to get all files in the directory and subdirectories
# Use wc -l to count the number of lines in each file
# Use awk to print the filename if the number of lines is greater than min_lines
find "$dir" -name "*.ts*" -type f -exec awk -v min_lines="$min_lines" 'NR > min_lines { print FILENAME; exit }' {} \;