#!/bin/bash

# Make all .sh files in a directory tree executable.
# Usage: mkexec.sh <directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory"
    exit 1
fi

find "$1" -type f -name "*.sh" | while read -r file; do
    chmod +x "$file"
    echo "  $file"
done
