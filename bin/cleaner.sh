#!/bin/bash
#This script cleans submission directories.

for file in ./*
   do
      cp ${file} ${file##*_}
      #rm ${file} 
done
