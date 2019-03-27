#!/bin/bash
# corrector - creates updates
#

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa6

FILE=pa6/Makefile

#
# creates the file to send later
#
#echo "=====================" > $FILE
#echo "==== CORRECTIONS ====" >> $FILE
#echo "=====================" >> $FILE
#echo "I am currently doing a regrade today for pa4. Don't worry, this regrade is meant to increase your grade (it won't decrease it) since there are some of you that made your program to work with integers only (this notice is for them eventhough I will retest all the programs)." >> $FILE
#echo "Best," >> $FILE
#echo "Alexey" >> $FILE

#
# iterates through directory list and checks if directory exists
#
for i in $(ls $DIR); do
  if [ -d "${DIR}/${i}" ]; then
    cp $FILE ${DIR}/${i}
  fi
done

echo "DONE"
