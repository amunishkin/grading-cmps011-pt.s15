#!/bin/bash
# pa3.sh - grades pa3 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="GCD.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/spa3
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
    echo "|| Grade Book for pa3 ||" >> $REPORT
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
      grep -o "error" compilation.messages > err.messages
      grep -o "warning" compilation.messages > warn.messages
      
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
          nohup java $prog < ${currDIR}/input.data 2> ${currDIR}/run.errs > ${currDIR}/run.messages
          sleep 10
          ps aux | grep "$prog" | grep "amunishk" | grep "^grep" > prog.id
          if [ -s prog.id ]; then
            echo "Your program has an infinite loop (-3 pts)" >> ${currDIR}/$REPORT
            ((GRADE = GRADE - 3))
            cat prog.id
          fi
          rm prog.id
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
          echo "No print to screen (-1 pts)" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        grep "[Ee]xception" run.errs > err.messages
        if [ -s err.messages ]; then
          echo "Exceptions found (-5 pts)" >> $REPORT
          grep -n "" err.messages >> $REPORT
          echo "" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm err.messages run.errs

        # (3) correct output (15 pts) ================================
        grep -i "positive" run.messages > correct.out
        if [ ! -s correct.out ]; then
          echo "No prompt for 'positive' integer (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi

        grep -o "[Pp]ositive" run.messages | wc -l > correct.out
        while read line; do
          if (( 2 > $line )); then
            echo "No another prompt for 'positive' integer (-5 pts)" >> $REPORT
            ((GRADE = GRADE - 5))
          fi
        done < correct.out

        grep "38" run.messages > correct.out
        if [ ! -s correct.out ]; then
          echo "Incorrect GCD calculation (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm correct.out

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
      grep -o "[0-9][0-9][0-9][0-9][0-9][0-9][0-9]" $name >> clarity.check
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
       grep -o "[Ee]nter" run.messages | wc -l > check.user.input
       while read line; do
         if (( 2 >= $line )); then
           echo "Does not continue to prompt user for input if wrong input is given (-5 pts)" >> $REPORT
           ((GRADE = GRADE - 5))
         fi
       done < check.user.input
       rm check.user.input
     else
       echo "Cannot check i/o specification requirements since there is no output (-10 pts)" >> $REPORT
       ((GRADE = GRADE - 10))
     fi

     echo "" >> $REPORT
     # (4) Program structure (10 pts)
     while read line; do
      name="$line"

      grep "while" $name > prog.loops
      grep "for" $name >> prog.loops
      if [ ! -s prog.loops ]; then
        echo "Did not use loops, i.e. 'while', 'do while', or 'for', in code (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
      fi
      rm prog.loops

      grep "import java[.]" $name > prog.imp
      grep "*" prog.imp > prog.imp2
      if [ -s prog.imp2 ]; then
        echo "Use of generic library import (-4 pts)" >> $REPORT
        grep -n prog.imp2 >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      rm prog.imp prog.imp2

      grep -n -i "class" $name > prog.comments
      grep -o "[0-9]*" prog.comments > prog.comments2
      while read line; do
        startc="$line"
        sed -n "${line},$ p" $name | grep -o "//" > prog.c.check
        sed -n "${line},$ p" $name | grep -o "/[*]" >> prog.c.check
        if [ ! -s prog.c.check ]; then
          echo "Code does not contain comments (-1 pt)" >> $REPORT
          echo "i.e. this does not include the comment header at the top" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        rm prog.c.check
      done < prog.comments2
      rm prog.comments prog.comments2
     done < java.files

    else
      echo "" >> $REPORT
      echo "Cannot evaluate your program completely since there is no [.java] file that compiles (-50 pts)" >> $REPORT
      ((GRADE = GRADE - 50))
    fi
    if [ -s class.files ]; then
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

