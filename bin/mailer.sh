#!/bin/bash
# send - sends files to email ($i)
#

EXITCODE=0

SUBJECT="CMPS-11 pa6 Grade"
DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa6

FILE=grade
#FILE=corrections

#
# iterates through directory list and checks if directory exist
#
for i in $(ls $DIR)
do
	if [ -d "${DIR}/$i" ]
	then
#
# sends files
#
		if [ -e "${DIR}/${i}/$FILE" ]
		then
			echo "sending mail to ${i}@ucsc.edu"
			cat ${DIR}/${i}/$FILE | mailx -s "$SUBJECT" ${i}@ucsc.edu >& tmp
			sleep 3
			if [ -e tmp -a $(wc -l < tmp) -eq 0 ]
			then
				echo "mail to ${i} is sent"
			else
				echo "mail to ${i} is not sent"
				cat tmp
			fi
		else 
			echo "could not sent email to ${i}@ucsc.edu"
			echo "$FILE does not exist"
		fi	
     	else
#
# prints error message if directory does not exist
#
		echo "$i: directory does not exist" >&2
		echo
		EXITCODE=2
	fi
done
echo "all mails are sent" | tee note

#
# send notice to my email
#
cat note | mailx -s "$SUBJECT [mailx DONE]" amunishk@ucsc.edu
exit $EXITCODE
