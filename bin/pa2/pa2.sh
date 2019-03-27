#!/bin/bash
# pa2.sh - grades pa2 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="Guess.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa2
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
    echo "|| Grade Book for pa2 ||" >> $REPORT
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
            echo "Your program does not exit after 3 guesses or win (-5 pts)" >> ${currDIR}/$REPORT
            ((GRADE = GRADE - 5))
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

        # (3) correct output (15 pts) ================================
        while read line; do
          name="${line}"
        done < java.files
        grep "Math.random()" $name | grep "9[.]0" | grep "1" > range.valid
        if [ ! -s range.valid ]; then
          echo "Does not generate numbers in range [1,10] (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm range.valid

        if [ -s run.messages ]; then
          grep -o "[.][0-9]" run.messages > nonint.numbers
          if [ -s nonint.numbers ]; then
            echo "Does not generate integers (-5 pts)" >> $REPORT
            ((GRADE = GRADE - 5))
          fi
          rm nonint.numbers

          grep -i "high" run.messages > reply.info
          grep -i "low" run.messages >> reply.info
          grep -i "win" run.messages >> reply.info
          grep -i "correct" run.messages >> reply.info
          grep -i "good" run.messages >> reply.info
          grep -i "got" run.messages >> reply.info
          grep -i "right" run.messages >> reply.info
          if [ ! -s reply.info ]; then
            echo "No indication if guess is too high, too low, or win (-5 pts)" >> $REPORT
            ((GRADE = GRADE - 5))
          fi
          rm reply.info
          
        else
          echo "No output to see if you used Math.random() to generate integers (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
          echo "No output to see if you inform user if guess is too high, too low, or win (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        
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
     # (3) i/o specs (8 pts)
     if [ -e run.messages -a -s run.messages ]; then
       COUNT=0
       head -n 1 run.messages | grep -c '^$' | grep "[1-9]" > headd.message
       tail -n 1 run.messages | grep -c '^$' | grep "[1-9]" > taill.message 
       if [ ! -s headd.message ]; then
         echo "No blank line at start of program run (-1 pt)" >> $REPORT
         ((GRADE--))
       else
         ((COUNT++))
       fi
       if [ ! -s taill.message ]; then
         echo "No blank line at end of program run (-1 pt)" >> $REPORT
         ((GRADE--))
       else
         ((COUNT++))
       fi
       rm headd.message taill.message

       grep -c '^$' run.messages > empty.messages
       while read line; do
         num=$line
         ((num = num - COUNT))
         if ((0 == $num)); then
           echo "No blank lines separating guesses (-1 pt)" >> $REPORT
           ((GRADE--))
         fi
       done < empty.messages
       rm empty.messages
     else
       echo "No output to evaluate for correct line printing (-3 pts)" >> $REPORT
       ((GRADE = GRADE - 3))
       echo "No output to evaluate for correct program execution (-5 pts)" >> $REPORT
       ((GRADE = GRADE - 5))
     fi

     echo "" >> $REPORT
     # (4) Program structure (12 pts)
     while read line; do
      name="$line"

      grep "Math.random()" $name > prog.math
      if [ ! -s prog.math ]; then
        echo "Did not use [Math.random()] in code (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
      fi
      rm prog.math

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

      grep "if" $name > prog.ifs
      grep "else" $name > prog.elses
      if [ ! -s prog.ifs -a ! -s prog.elses ]; then
        echo "Did not use [if-else] structure in code (-2 pts)" >> $REPORT 
        ((GRADE = GRADE - 2))
      fi
      rm prog.ifs prog.elses
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

