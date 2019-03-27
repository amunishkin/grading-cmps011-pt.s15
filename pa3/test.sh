#!bin/bash

grep -i -c "count" test1.txt > out
while read line; do
  echo $line
  if (( 0 <= $line )); then
    echo "0 <="
  fi
done < out
cat out
rm out
