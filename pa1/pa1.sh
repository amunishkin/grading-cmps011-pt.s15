#!/bin/bash
# pa1.sh - grades pa1 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="Lawn.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/spa1
#DIR=~/private/_grading/tests

CVS=report.csv
echo "" > report.csv # rewrite each run of program

#
# iterates through directory list
#
for i in $(ls ${DIR}); do
  
  if [ -d "${DIR}/${i}" ]; then
    GRADE=80
    REPORT=grade
    echo "========================" > $REPORT
    echo "|| Grade Book for pa1 ||" >> $REPORT
    echo "========================" >> $REPORT
    echo "${i}" >> $REPORT 
    echo "${i}"
    echo "" >> $REPORT

    #
    # counts num of files submitted
    #
    COUNT=0
    for FILE in $(ls ${DIR}/${i}); do
      if [ -f "${DIR}/${i}/$FILE" ]; then
        ((COUNT++))
        echo "$FILE" >> files.submitted
      fi
    done

    echo "Total number of files submitted: $COUNT" >> $REPORT
    grep -n "" files.submitted >> $REPORT
    echo "" >> $REPORT
    rm files.submitted
    #
    # checks files
    #
    for FILE in $SOURCES; do
      if [ ! -e "${DIR}/${i}/${FILE}" ]; then
        echo "$FILE absent (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      ls ${DIR}/${i}/* | grep ".[.]java" > java.files # find ".java filenames
      cat java.files
      if [ -s java.files ]; then
        ((COUNT--))
      fi
    done
    if (( $COUNT != 0 )); then
      echo "Extra files present (-3 pts)" >> $REPORT
      ((GRADE = GRADE - 3))
    fi

    echo "" >> $REPORT
    echo "============================================" >> $REPORT
    echo "           Performance Evaluation " >> $REPORT
    echo "============================================" >> $REPORT
    #
    echo "========== Performance Evaluation =========="
    #-------------------------------------------------------
    # (I) Performance check (40pts)
    #-------------------------------------------------------
    
    echo "" >> $REPORT
    # (1) compilation (15pts) ==============================
    #grep -l "" ${DIR}/${i}/* | grep ".[.]java" > java.files # find ".java" filenames
    if [ -s java.files ]; then
     while read line; do
      name="$line"
      echo "${line##*/}" > base.name
      basename=""
      while read line; do
        basename="$line"
      done < base.name
      rm base.name
     
      #trap '' INT
      pwd > curr.dir
      currDIR=""
      while read line; do
        currDIR="$line"
      done < curr.dir
      rm curr.dir
      ###################################
      cd ${DIR}/${i} 
      javac $name &> ${currDIR}/compilation.messages
      #
      cp ${currDIR}/compilation.messages .
      cd $currDIR
      ###################################
      #trap '-'
      grep -l "error" compilation.messages > err.messages
      grep -l "warning" compilation.messages > warn.messages
      
      # print code compilation
      echo "---------- compilation ----------" >> $REPORT
      echo "javac $basename" >> $REPORT
      #echo "" >> $REPORT
      grep -n "" compilation.messages >> $REPORT
      echo "---------------------------------" >> $REPORT
      #
      rm compilation.messages

      #
      # error messages ------------------------
      #
      COUNT=0
      while read line; do
        ((COUNT++))
      done < err.messages
      if [ -s err.messages ]; then
        ((COUNT--)) # error print at end
      fi
      echo "You have $COUNT error(s)" >> $REPORT

      if (( $COUNT != 0 )); then
        echo "At least 1 error (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))

        for j in {1..3}; do # to determine range of errors
          ((COUNT--))
          if (( COUNT == 0 )); then
            touch err.finished
          fi
        done
        if [ ! -e err.finished ]; then
          echo "More than 3 errors (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        else
          rm err.finished
        fi
      fi
      rm err.messages

      #
      # warning messages ----------------------
      #
      COUNT=0
      WARNCOUNT=0
      while read line; do
        ((WARNCOUNT++))
        if (( $COUNT != 5 )); then # limit to 5
          ((COUNT++))
        fi
      done < warn.messages
      if [ -s warn.messages ]; then
        ((WARNCOUNT--))
        if (( $WARNCOUNT == $COUNT )); then # warning print at end
          ((COUNT--))
        fi
      fi
      echo "You have $WARNCOUNT warning(s)" >> $REPORT
      
      PREVGRADE=GRADE
      ((GRADE = GRADE - COUNT))
      if (( $GRADE != $PREVGRADE )); then
        echo "Warnings upto 5 (-$COUNT pt(s))" >> $REPORT
        ((GRADE = GRADE - COUNT))
      fi
      rm warn.messages
     done < java.files
    fi

    echo "" >> $REPORT
    # (2) runs (10 pts) ===================================
    ls ${DIR}/${i}/* | grep ".[.]class" > class.files # find ".class" filenames
    if [ -s class.files ]; then
      while read line; do
        strlength=${#line}
        ((strlength = strlength - 6)) # remove [.class]
        echo ${line:0:strlength} >> class.files.sv
      done < class.files
      mv class.files.sv class.files

      while read line; do
        name="$line"
        prog=""

        #trap '' INT # ignore interrupts (^C)
        echo ${name##*/} > name.prog
        while read line; do
          prog="$line"
          pwd > curr.dir
          currDIR=""
          while read line; do
            currDIR="$line"
          done < curr.dir
          rm curr.dir
          #############################
          cd ${DIR}/${i}/
          java $prog < ${currDIR}/input.data 2> ${currDIR}/run.errs > ${currDIR}/run.messages
          # <<interaction>>
          #   ...........
          # <<interaction>>
          cat ${currDIR}/run.messages > output.data
          cat ${currDIR}/run.errs >> output.data    # backup tests in each
          cp ${currDIR}/input.data .                # student's directory
          #
          cd $currDIR
          #############################
        done < name.prog
        rm name.prog
        #trap '-' # reset interrupt handlers
        
        # print java run
        echo "----------- java run ----------" >> $REPORT
        echo "java $prog " >> $REPORT
        #echo "" >> $REPORT
        grep -n "" run.messages >> $REPORT
        echo "-------------------------------" >> $REPORT
        #

        if [ ! -s run.messages ]; then
          echo "No print to screen (-2 pts)" >> $REPORT
          ((GRADE = GRADE - 2))
        fi
        grep "[Ee]xception" run.errs > err.messages
        if [ -s err.messages ]; then
          echo "Exceptions found (-5 pts)" >> $REPORT
          grep -n "" err.messages >> $REPORT
          echo "" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm err.messages run.errs

        # (3) correct output (15 pts)
        spell run.messages > grammar.check
        if [ -s grammar.check ]; then
          echo "Wrong grammar usage, see below (-5 pts)" >> $REPORT
          grep -n "" grammar.check >> $REPORT
          echo "" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm grammar.check
        
        grep -o "[-+ ]3" run.messages > timee.check.hr # extract digits
        grep -o "[-+ ]12" run.messages > timee.check.min
        grep -o "[-+ ]10" run.messages > timee.check.sec
        #
        grep -o "hours" run.messages > plural.check.hr # extract words
        grep -o "minutes" run.messages > plural.check.min
        grep -o "seconds" run.messages > plural.check.sec
        #
        if [ ! -s plural.check.hr -o ! -s plural.check.min -o ! -s plural.check.sec ]; then
          echo "Plural usage wrong (-5 pts)" >> $REPORT
         ((GRADE = GRADE - 5))
        fi
        rm plural.check.hr plural.check.min plural.check.sec
        #
        if [ ! -s timee.check.hr -o ! -s timee.check.min -o ! -s timee.check.sec ]; then
          echo "Time output wrong (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm timee.check.hr timee.check.min timee.check.sec
        
      done < class.files
    else
      echo "No class file(s) to test" >> $REPORT
      echo "Thus cannot test the program ... (-25 pts)" >> $REPORT
      ((GRADE = GRADE - 25))
    fi

    echo "" >> $REPORT
    echo "==============================================" >> $REPORT
    echo "           Specification Evaluation " >> $REPORT
    echo "==============================================" >> $REPORT
    #
    echo "========== Specification Evaluation =========="
    #--------------------------------------------------------------
    # Specification check (40 pts)
    #--------------------------------------------------------------
    
    if [ -s java.files ]; then
     echo "" >> $REPORT
     # (1) clarity (15 pts)
     while read line; do
      name="$line"
      echo "${line##*/}" > base.name
      basename=""
      while read line; do
        basename="$line"
      done < base.name
      rm base.name
      grep -i "$basename" $name > clarity.check
      if [ ! -s clarity.check ]; then
        echo "Standard comment block in $basename does not contain [$basename] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi
      grep -i "${i}" $name > clarity.check
      grep "[0-9][0-9][0-9][0-9][0-9][0-9][0-9]" $name >> clarity.check
      if [ ! -s clarity.check ]; then
        echo "Standard comment block in $basename does not contain [CruzID] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi
      grep -i "pa" $name > clarity.check
      grep -i "assignment" $name >> clarity.check
      grep -i "prog" $name >> clarity.check
      if [ ! -s clarity.check ]; then
        echo "Standard comment block in $basename does not contain [assignment#] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi
      rm clarity.check
     done < java.files

     echo "" >> $REPORT
     # (3) i/o specs (10 pts)
     if [ -e run.messages -a -s run.messages ]; then
       grep -o "[-+ ][0-9]*[.]" run.messages > round.miss
       grep -o "[-+ ][0-9]*[.]" run.messages >> round.miss
       grep -o "[-+ ][0-9]*[.]" run.messages >> round.miss
       if [ -s round.miss ]; then
        echo "You did not round your time to the nearest whole number (-1 pt)" >> $REPORT
        grep -n "" round.miss >> $REPORT
        echo "" >> $REPORT
        ((GRADE--))
       fi
       rm round.miss

       grep -i "hour" run.messages | grep -i "minute" | grep -i "second" > format.miss
       if [ ! -s format.miss ]; then
        echo "You did not print in the format of [hour(s) minute(s) second(s)] (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
       fi
       rm format.miss run.messages
     else
       echo "No output to evaluate for correct rounding (-1 pt)" >> $REPORT
       ((GRADE--))
       echo "No output to evaluate for correct format (-2 pts)" >> $REPORT
       ((GRADE = GRADE - 2))
     fi

     echo "" >> $REPORT
     # (4) Program structure (10 pts)
     while read line; do
      name="$line"

      grep "print" $name > prog.p
      if [ ! -s prog.p ]; then
        echo "Did not use print statements in code (-2 pt)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      rm prog.p

      grep "Scanner" $name > prog.s
      if [ ! -s prog.s ]; then
        echo "Did not use Scanner class in code (-2 pt)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      rm prog.s

      grep "import java[.]" $name > prog.imp
      if [ ! -s prog.imp ]; then
        echo "Did not use [java.util.Scanner] (-4 pts)" >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      grep -o "java[.]util[.]Scanner" prog.imp > prog.imp2
      if [ ! -s prog.imp2 ]; then
        echo "Did not just use [java.util.Scanner] (-4 pts)" >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      rm prog.imp prog.imp2

      grep "double" $name > prog.double
      if [ ! -s prog.double ]; then
        echo "Did not use [double] for variables (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      rm prog.double
     done < java.files

    else
      echo "" >> $REPORT
      echo "Cannot evaluate your program completely since there is no [.java] file that compiles (-50 pts)" >> $REPORT
      ((GRADE = GRADE - 50))
    fi
    if [ ! -s java.files -a -s class.files ]; then
      rm run.messages
    fi
    rm java.files class.files
    #
    echo "$i, $GRADE" >> $CVS

    #
    echo "" >> $REPORT
    echo "#################" >> $REPORT
    echo "# GRADE = $GRADE/80 #" >> $REPORT
    echo " GRADE = $GRADE/80 "
    echo "#################" >> $REPORT
    echo "" >> $REPORT
    #
    mv $REPORT ${DIR}/${i}
  fi
done

echo ""
echo "DONE"
echo ""

