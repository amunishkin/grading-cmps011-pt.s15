#!/bin/bash
# pa6.sh - grades pa6 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="Complex.java
ComplexTest.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa6
#DIR=~/private/_grading/tests

CVS=report.csv
echo "" > report.csv # rewrite each run of program

#
# iterates through directory list
#
for i in $(ls ${DIR}); do
  
  if [ -d "${DIR}/${i}" ]; then
    GRADE=100
    REPORT=grade
    echo "========================" >> $REPORT
    echo "|| Grade Book for pa6 ||" >> $REPORT
    echo "========================" >> $REPORT
    echo "${i}" >> $REPORT 
    echo ""
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
        if [ ! -e donePAIR ]; then
        if [[ "${DIR}/${i}/$FILE" == "${DIR}/${i}/PAIR" ]]; then # check if pair submit
          echo "$i" >> pairs
          touch donePAIR
        fi
        fi
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
        echo "$FILE absent (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi
    done
    #
    ls ${DIR}/${i}/* | grep ".[.]java" > java.files # find ".java filenames
    ls ${DIR}/${i}/* | grep -i "Makefile" > Makefile.file # same for Makefile
    cat java.files
    cat Makefile.file
    if [ -s java.files ]; then
      ((COUNT = COUNT - 2)) # should be two ".java files
    fi
    if [ -s Makefile.file ]; then
      ((COUNT--))
    else
      echo "Makefile absent (-3 pts)" >> $REPORT
      ((GRADE = GRADE - 3))
    fi
    if [ -e donePAIR ]; then
      ((COUNT--))
      rm donePAIR
    fi
    #
    if (( $COUNT != 0 )); then
      echo "Extra files present (-1 pts)" >> $REPORT
      ((GRADE = GRADE - 1))
    fi

    echo "" >> $REPORT
    echo "============================================" >> $REPORT
    echo "           Performance Evaluation " >> $REPORT
    echo "============================================" >> $REPORT
    #
    echo "========== Performance Evaluation =========="
    #-------------------------------------------------------
    # (I) Performance check (50pts)
    #-------------------------------------------------------
    
    # (1) compilation (15pts) ==============================
    if [ -s java.files ]; then
      #trap '' INT
      pwd > curr.dir
      currDIR=""
      while read line; do
        currDIR="$line"
      done < curr.dir
      rm curr.dir
      ###################################
      cd ${DIR}/${i} 
      if [ -s Makefile.file ]; then
        make &> ${currDIR}/compilation.messages
      else
        cp ${currDIR}/Makefile .
        make &> ${currDIR}/compilation.messages
        #rm Makefile
      fi
      #
      # backup?
      #
      cd $currDIR
      ###################################
      #trap '-'
      grep -o "error" compilation.messages > err.messages
      grep -o "warning" compilation.messages > warn.messages
      
      # print code compilation
      echo "---------- compilation ----------" >> $REPORT
      echo "make" >> $REPORT
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

        for j in {1..5}; do # to determine range of errors
          ((COUNT--))
          if (( COUNT == 0 )); then
            touch err.finished
          fi
        done
        if [ ! -e err.finished ]; then
          echo "More than 5 errors (-5 pts)" >> $REPORT
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
    fi

    if [ -x "${DIR}/${i}/ComplexTest" ]; then
     echo "" >> $REPORT
     # (2) runs (10 pts) ===================================
     #trap '' INT # ignore interrupts (^C)
     pwd > curr.dir
     currDIR=""
     while read line; do
       currDIR="$line"
     done < curr.dir
     rm curr.dir
     #############################
     cd ${DIR}/${i}/
     cp ${currDIR}/file1 .
     ./ComplexTest file1 f2 2> ${currDIR}/run.errs # possible err only in first
     ./ComplexTest f2 f3 &> /dev/null
     ./ComplexTest f3 f4 &> /dev/null
     ./ComplexTest f4 f5 &> /dev/null
     #
     mv f2 ${currDIR}/.
     mv f3 ${currDIR}/.
     mv f4 ${currDIR}/.
     mv f5 ${currDIR}/.
     # <<interaction>>
     #   ...........
     # <<interaction>>
     #
     # backup tests?
     #
     cd $currDIR
     #############################
     #trap '-' # reset interrupt handlers
        
     # print java run
     echo "----------- java run ----------" >> $REPORT
     echo "./ComplexTest file1 f2" >> $REPORT
     echo "f2:" >> $REPORT
     grep -n "" f2 >> $REPORT
        
     echo "" >> $REPORT
     echo "./ComplexTest f2 f3" >> $REPORT
     echo "f3:" >> $REPORT
     grep -n "" f3 >> $REPORT

     echo "" >> $REPORT
     echo "./ComplexTest f3 f4" >> $REPORT
     echo "f4:" >> $REPORT
     grep -n "" f4 >> $REPORT

     echo "" >> $REPORT
     echo "./ComplexTest f4 f5" >> $REPORT
     echo "f5:" >> $REPORT
     grep -n "" f5 >> $REPORT
     echo "-------------------------------" >> $REPORT
     #

     if [ ! -s f2 ]; then
       echo "No print to file (-1 pt)" >> $REPORT
       ((GRADE = GRADE - 1))
     fi
     if [ ! -e f3 ]; then
       echo "No file IO (-3 pts)" >> $REPORT
       ((GRADE = GRADE - 3))
     fi
     grep "[Ee]xception" run.errs >> err.messages
     if [ -s err.messages ]; then
       echo "Exceptions found (-5 pts)" >> $REPORT
       grep -n "" err.messages >> $REPORT
       echo "" >> $REPORT
       ((GRADE = GRADE - 5))
     fi
     rm err.messages run.errs

     echo "" >> $REPORT
     # (3) correct output (20 pts) ================================
      ## diff file2 f2
     grep -o "[-]2[.]0+8[.]0i" f2 > correct.out1
     grep -o "[-]4[.]0+5[.]0i" f2 > correct.out2
     if [ ! -s correct.out1 -o ! -s correct.out2 ]; then
        echo "[f2] does not give correct result (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
     fi
     rm correct.out* f2

      ## diff file3 f3
     grep -o "[-]6[.]0+13[.]0i" f3 > correct.out1
     grep -o "[-]4[.]0+5[.]0i" f3 > correct.out2
     if [ ! -s correct.out1 -o ! -s correct.out2 ]; then
        echo "[f3] does not give correct result (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
     fi
     rm correct.out* f3

      ## diff file4 f4
     grep -o "[-]10[.]0+18[.]0i" f4 > correct.out1
     grep -o "[-]4[.]0+5[.]0i" f4 > correct.out2
     if [ ! -s correct.out1 -o ! -s correct.out2 ]; then
        echo "[f4] does not give correct result (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
     fi
     rm correct.out* f4

      ## diff file5 f5
     grep -o "[-]14[.]0+23[.]0i" f5 > correct.out1
     grep -o "[-]4[.]0+5[.]0i" f5 > correct.out2
     if [ ! -s correct.out1 -o ! -s correct.out2 ]; then
        echo "[f5] does not give correct result (-5 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
     fi
     rm correct.out* f5

    else
      echo "No [ComplexTest] to test" >> $REPORT
      echo "Thus cannot test the program ... (-30 pts)" >> $REPORT
      ((GRADE = GRADE - 30))
    fi

    echo "" >> $REPORT
    # (4) Makefile (5 pts) =========================================
    if [ -s Makefile.file ]; then
      pwd > curr.dir
      currDIR=""
      while read line; do
        currDIR="$line"
      done < curr.dir
      rm curr.dir

      #############################
      cd ${DIR}/${i}
      make
      if [ ! -x ComplexTest ]; then
        echo "[make] does not produce an executable [ComplexTest] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi

      make clean
      ls *.class > mk.clean.check
      if [ -s mk.clean.check ]; then
        echo "[make clean] does not remove [.class] files (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      rm mk.clean.check

      make # keep exe ComplexTest
      cd ${currDIR}
      ############################
    else
      echo "No Makefile (-5 pts)" >> $REPORT
      ((GRADE = GRADE - 5))
    fi

    echo "" >> $REPORT
    echo "==============================================" >> $REPORT
    echo "           Specification Evaluation " >> $REPORT
    echo "==============================================" >> $REPORT
    #
    echo "========== Specification Evaluation =========="
    #--------------------------------------------------------------
    # Specification check (50 pts)
    #--------------------------------------------------------------
    
    if [ -s java.files ]; then
     echo "" >> $REPORT
     # (1) clarity (15 pts) =========================================
     while read line; do
      name="$line"
      echo "${line##*/}" > base.name
      basename=""
      while read line; do
        basename="$line"
      done < base.name
      rm base.name
      ################################################
      if [[ "$basename" == "ComplexTest.java" ]]; then
         continue # don't read ComplexTest.java
      fi
      ################################################
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

      break # need to fix???
     done < java.files
     #

     echo "" >> $REPORT
     # (3) Function specs (15 pts) =======================================
          
     echo "" >> $REPORT
     # (4) Program structure (10 pts) ===============================
     while read line; do
      name="$line"
      echo "${line##*/}" > base.name
      basename=""
      while read line; do
        basename="$line"
      done < base.name
      rm base.name
      ################################################
      if [[ "$basename" == "ComplexTest.java" ]]; then
         continue # don't read ComplexTest.java
      fi
      ################################################
      grep "import java[.]" $name > prog.imp
      grep "*" prog.imp > prog.imp2
      if [ -s prog.imp2 ]; then
        echo "Use of generic library import (-4 pts)" >> $REPORT
        grep -n "" prog.imp2 >> $REPORT
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
          echo "Code does not contain in-line comments (-1 pt)" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        rm prog.c.check
      done < prog.comments2
      rm prog.comments prog.comments2

      #diff ${DIR}/${i}/ComplexTest.java ComplexTest.java > diff.CT
      #if [ -s diff.CT ]; then
      #   echo "Modified [ComplexTest.java] (-5 pts)" >> $REPORT
      #   ((GRADE = GRADE - 5))
      #fi

      break # need to fix???
     done < java.files

    else
      echo "" >> $REPORT
      echo "Cannot evaluate your program completely since there is no [.java] file (-65 pts)" >> $REPORT
      ((GRADE = GRADE - 65))
    fi
    rm Makefile.file java.files
    #
    echo "$i, $GRADE" >> $CVS

    #
    echo "" >> $REPORT
    echo "###################" >> $REPORT
    echo "# GRADE = $GRADE/100 #" >> $REPORT
    echo " GRADE = $GRADE/100 "
    echo "###################" >> $REPORT
    echo "" >> $REPORT
    #
    mv $REPORT ${DIR}/${i}
  fi
  sleep 3 # just to avoid the OS to make weird errors due to running at 100%
done

echo ""
echo "DONE" | tee note
echo ""

#
# send notice to my email once script done
#
cat note | mailx -s "CMPS-11 pa6 [script DONE]" amunishk@ucsc.edu

