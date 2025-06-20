#!/bin/sh
# assignment 1
# Author: cskang510


if [ $# -lt 2 ]
then
	if [ $# -eq 1 ]
	then
		echo "Error: search string not specified"
	else
		echo "Error: search directory and search string not specified"
	fi
		
	exit 1	
else
	SEARCH_DIR=$1
	SEARCH_STR=$2
fi

if [ ! -d $SEARCH_DIR ]
then
	echo "$SEARCH_DIR is not a folder"
	exit 1
fi

echo "finder.sh: searching $SEARCH_STR in $SEARCH_DIR ..."

FILES_FOUND=0
MATCH_FOUND=0
for EACHFILE in $(find $SEARCH_DIR -type f); do
	FILES_FOUND=$(expr $FILES_FOUND + 1)
	NUM_MATCH=$(grep -c SEARCH_STR $EACHFILE)
	MATCH_FOUND=$((MATCH_FOUND + NUM_MATCH))
done

echo "The number of files are $FILES_FOUND and number of matching lines are $MATCH_FOUND"
exit 0
