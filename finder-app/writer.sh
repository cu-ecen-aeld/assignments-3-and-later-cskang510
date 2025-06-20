#!/bin/bash

# the first argument is a path to a file name
writefile="$1"

# the second argument is a text string which will be written to the file
writestr="$2"

if [ $# -lt 2 ]; then
    echo "runtime argument not specified"
    exit 1
fi

# find the path of the file
dir=$(dirname "$writefile")

# create the path if it does not exist
if ! mkdir -p $dir; then
    echo "Failed to create directory."
    exit 1
fi

# create a file using the file name with the string
if ! echo $writestr > $writefile; then
    echo "Failed to write to the file, $writefile"
    exit 1
fi

