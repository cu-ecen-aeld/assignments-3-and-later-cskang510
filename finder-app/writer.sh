#!/bin/sh
# assignment 1
# Author: cskang510


if [ $# -lt 2 ]
then
	if [ $# -eq 1 ]
	then
		echo "Error: write string not specified"
	else
		echo "Error: write file and write string not specified"
	fi
		
	exit 1	
else
	WRITE_FILE=$1
	WRITE_STR=$2
fi

if [ -e $WRITE_FILE ]
then
	if [ ! -f $WRITE_FILE ]
	then
		echo "Error: $WRITE_FILE is not a file"
		exit 1
	else
		if [ ! -w $WRITE_FILE ]
		then
			echo "Error: $WRITE_FILE is not writable"
			exit 1
		fi
	fi
fi

echo $WRITE_STR > $WRITE_FILE
exit 0

