#!/bin/sh
# assignment 1
# Author: cskang510

# the first argument is a path to a directory on the filesystem, i.e. filesdir
filesdir="$1"

# the second argument is a text string which will be searched, i.e. searchstr
searchstr="$2"

if [ $# -lt 2 ]; then
    echo "runtime argument not specified"
    exit 1
fi

if [ ! -d "$filesdir" ]; then
    echo "$filesdir is not an actual directory"
    exit 1
fi

# find the number of files in the path and subdirectory of path
num_files=`find $filesdir -type f | wc -l`

# find the number of matching lines of string in the path and subdirectory of path
num_matches=`grep -r -l $searchstr $filesdir | wc -l`
echo "The number of files are $num_files and the number of matching lines are $num_matches"