#! /bin/bash
# corrector_files - cleans files in student's directory
#                   if error occured in grading
#

EXITCODE=0

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa6
#DIR=~/private/_grading/tests

#
# iterates through directory list and checks if directory exist
#
for i in $(ls $DIR); do
  if [ -d "${DIR}/$i" ]; then
    pwd > current.dir
    currDIR=""
    while read line; do
      currDIR="$line"
    done < current.dir
    rm current.dir

    cd ${DIR}/${i}
    rm *.class ComplexTest file1 grade
    cd ${currDIR}
  fi
done

echo "DONE"
