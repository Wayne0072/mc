#!/bin/bash

# MASL difftool:
# This utility compares textual MASL by performing operations that do not
# affect meaning of the original MASL, then diffing the results.
# Removing comments, whitespace, and line breaking only after semicolons
# provides us with files we can diff meaningfully. Note that the results
# are not usable MASL files. Removing all whitespace will cause them to
# be unable to parse, however, no information required for a diff is lost.

# difftool (replace with your favorite diff utility)
#DIFFTOOL=vimdiff
DIFFTOOL=diff

# check arguments
if [[ $# != 2 && $# != 3 ]]; then
    echo "Usage:    ./masldiff.sh <file1> <file2> [-n]"
    echo "          <file1>     path to left MASL file"
    echo "          <file2>     path to right MASL file"
    echo "          -n          do not open diff tool"
    exit 1
fi

# remove comments
perl -pe 's/\/\/.*$//g' $1 > left1
perl -pe 's/\/\*.*\*\///g' left1 > left2
perl -pe 's/\/\/.*$//g' $2 > right1
perl -pe 's/\/\*.*\*\///g' right1 > right2

# remove whitespace
tr -d " \t\r\n" < left2 > left3
tr -d " \t\r\n" < right2 > right3

# break after semicolon
perl -pe 's/;/;\n/g' left3 > $1.masldiff
perl -pe 's/;/;\n/g' right3 > $2.masldiff

# remove temp files
rm -f left* right*

# open diff tool
if [[ $# != 3 || $3 != "-n" ]]; then
    $DIFFTOOL $1.masldiff $2.masldiff
fi

# remove the files after diff
#rm -f *.masldiff