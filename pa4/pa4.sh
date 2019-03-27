#!/bin/bash
# pa4.sh - grades pa4 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="Roots.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa4
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
    echo "|| Grade Book for pa4 ||" >> $REPORT
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
        if [[ ${DIR}/${i}/$FILE == PAIR ]]; then
          echo "$i" >> pairs
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
        echo "$FILE absent (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      ls ${DIR}/${i}/* | grep ".[.]java" > java.files # find ".java filenames
      ls ${DIR}/${i}/* | grep -i "Makefile" > Makefile.file # same for Makefile
      cat java.files
      cat Makefile.file
      if [ -s java.files ]; then
        ((COUNT--))
      fi
      if [ -s Makefile.file ]; then
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
    # (I) Performance check (50pts)
    #-------------------------------------------------------
    
    # (1) compilation (15pts) ==============================
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
      if [ -s Makefile.file ]; then
        make &> ${currDIR}/compilation.messages
        javac $basename # just to make sure there are [.class] files
      else
        javac $basename &> ${currDIR}/compilation.messages
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
      if [ -s Makefile.file ]; then
        echo "make" >> $REPORT
      else
        echo "javac $basename" >> $REPORT
      fi
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

      break # may need to fix later
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
          if [ -x Roots ]; then
            ./Roots < ${currDIR}/input.data1 2> ${currDIR}/run.errs1 > ${currDIR}/run.messages1 & # run in background
            ./Roots < ${currDIR}/input.data2 2> ${currDIR}/run.errs2 > ${currDIR}/run.messages2 & # run in background
            ./Roots < ${currDIR}/input.data3 2> ${currDIR}/run.errs3 > ${currDIR}/run.messages3 & #
            sleep 10
            ps aux | grep "Roots" | grep "amunishk" | grep "^grep" > prog.id
          else
            java $prog < ${currDIR}/input.data1 2> ${currDIR}/run.errs1 > ${currDIR}/run.messages1 & # run in background
            java $prog < ${currDIR}/input.data2 2> ${currDIR}/run.errs2 > ${currDIR}/run.messages2 & # run in background
            java $prog < ${currDIR}/input.data3 2> ${currDIR}/run.errs3 > ${currDIR}/run.messages3 & #
            sleep 10
            ps aux | grep "$prog" | grep "amunishk" | grep "^grep" > prog.id
          fi
          if [ -s prog.id ]; then
            echo "Your program has an infinite loop (-3 pts)" >> ${currDIR}/$REPORT
            ((GRADE = GRADE - 3))
            cat prog.id >> ${currDIR}/prog.id
          fi
          rm prog.id
          # <<interaction>>
          #   ...........
          # <<interaction>>
          #
          # backup tests?
          #
          cd $currDIR
          #############################
        done < name.prog
        rm name.prog
        #trap '-' # reset interrupt handlers
        
        # print java run
        echo "----------- java run ----------" >> $REPORT
        echo ">> input.data1 <<" >> $REPORT
        if [ -x "$DIR/$i/Roots" ]; then
          echo "./Roots" >> $REPORT
        else
          echo "java $prog " >> $REPORT
        fi
        grep -n "" run.messages1 >> $REPORT
        
        echo "" >> $REPORT
        echo ">> input.data2 <<" >> $REPORT
        if [ -x "$DIR/$i/Roots" ]; then
          echo "./Roots" >> $REPORT
        else
          echo "java $prog " >> $REPORT
        fi
        grep -n "" run.messages2 >> $REPORT

        echo "" >> $REPORT
        echo ">> input.data3 <<" >> $REPORT
        if [ -x "$DIR/$i/Roots" ]; then
          echo "./Roots" >> $REPORT
        else
          echo "java $prog " >> $REPORT
        fi
        grep -n "" run.messages3 >> $REPORT
        echo "-------------------------------" >> $REPORT
        #

        if [ ! -s run.messages1 ]; then
          echo "No print to screen (-1 pts)" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        grep "[Ee]xception" run.errs3 > err.messages # run.errs1
        grep "[Ee]xception" run.errs2 >> err.messages
        if [ -s err.messages ]; then
          echo "Exceptions found (-5 pts)" >> $REPORT
          grep -n "" err.messages >> $REPORT
          echo "" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm err.messages run.errs1 run.errs2 run.errs3

        echo "" >> $REPORT
        # (3) correct output (15 pts) ================================
        ## input.data1
        grep -o "[0-9][.][0-9]" run.messages3 | wc -l > correct.out
        while read line; do
          if (( 0 == $line )); then
            echo "Does not print any roots using [input.data3] (-10 pts)" >> $REPORT
            ((GRADE = GRADE - 10))
          elif (( 3 < $line )); then
            echo "Prints extra roots using [input.data3] (-5 pts)" >> $REPORT
            ((GRADE = GRADE - 5))
          fi
        done < correct.out
        rm correct.out

        ## input.data2
        grep -i "No Root" run.messages2 > correct.out
        if [ ! -s correct.out ]; then
          echo "Does not print if no root is found using [input.data2] (-5 pts)" >> $REPORT
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
    # (4) Makefile (10 pts) =========================================
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
      if [ ! -x Roots ]; then
        echo "[make] does not produce an executable [Roots] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi

      make clean
      ls | grep -o "[.]class" > mk.clean.check
      if [ -s mk.clean.check ]; then
        echo "[make clean] does not remove [.class] files (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 3))
      fi
      rm mk.clean.check

      mk=""
      if [ -e Makefile ]; then
        mk="Makefile"
      else
        mk="makefile"
      fi
      grep "submit" $mk > mk.submit.check
      if [ ! -s mk.submit.check ]; then
        echo "No [make submit] (-3 pts)" >> $REPORT
        ((GRADE = GRADE - 5))
      fi
      rm mk.submit.check
      cd ${currDIR}
      ############################
    else
      echo "No Makefile (-10 pts)" >> $REPORT
      ((GRADE = GRADE - 10))
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
     # (3) i/o specs (10 pts) =======================================
     if [ -s run.messages1 ]; then
       grep -o "[0-9][.][0-9][0-9][0-9][0-9][0-9]" run.messages3 > io.check
       if [ ! -s io.check ]; then
         echo "Roots are not printed upto 5 decimal places (-5 pts)" >> $REPORT
         ((GRADE = GRADE - 5))
       fi
       rm io.check

       grep -o "[-]0.9351" run.messages1 > io.check # check upto 4 decimal
       if [ ! -s io.check ]; then
         echo "First root is not [-0.93511]" >> grade.check1
       fi
       rm io.check
       grep -o "0.1004" run.messages1 > io.check
       if [ ! -s io.check ]; then
         echo "Second root is not [0.10049]" >> grade.check1
       fi
       rm io.check
       grep -o "0.9607" run.messages1 > io.check
       if [ ! -s io.check ]; then
         echo "Thrid root is not [0.96070]" >> grade.check1
       fi
       rm io.check

       grep -o "0.1188" run.messages3 > io.check
       if [ ! -s io.check ]; then
         echo "First root is not [0.11880]" >> grade.check3
       fi
       rm io.check
       #
       if [ -s grade.check3 ]; then # checks ints
         echo "Roots are not accurate enough upto 5 decimal places or incorrect [input.data3] (-5 pts)" >> $REPORT 
         cat grade.check3 >> $REPORT
         rm grade.check3 grade.check1
         ((GRADE = GRADE - 5))
       elif [ -s grade.check1 ]; then # check doubles if ints passed
         echo "Roots are not accurate enough upto 5 decimal places or incorrect [input.data1] (-5 pts)" >> $REPORT
         cat grade.check1 >> $REPORT
         rm grade.check1
       fi
     else
       echo "Cannot check i/o specification requirements since there is no output from [input.data1] (-10 pts)" >> $REPORT
       ((GRADE = GRADE - 10))
     fi

     echo "" >> $REPORT
     # (4) Program structure (20 pts) ===============================
     while read line; do
      name="$line"

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
          echo "Code does not contain comments (-1 pt)" >> $REPORT
          echo "i.e. this does not include the comment header at the top" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        rm prog.c.check
      done < prog.comments2
      rm prog.comments prog.comments2

      grep "static double poly" $name > prog.funcs
      if [ ! -s prog.funcs ]; then
        echo "No function [static double poly(double[] C, double x)] (-4 pts)" >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      rm prog.funcs
      grep "static double[[]] diff" $name > prog.funcs
      if [ ! -s prog.funcs ]; then
        echo "No function [static double[] diff(double[] C)] (-4 pts)" >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      rm prog.funcs
      grep "static double findRoot" $name > prog.funcs
      if [ ! -s prog.funcs ]; then
        echo "No function [static double findRoot(double[] C, double a, double b, double tolerance)] (-4 pts)" >> $REPORT
        ((GRADE = GRADE - 4))
      fi
      rm prog.funcs
     done < java.files

    else
      echo "" >> $REPORT
      echo "Cannot evaluate your program completely since there is no [.java] file that compiles (-60 pts)" >> $REPORT
      ((GRADE = GRADE - 60))
    fi
    if [ -s class.files ]; then
      rm run.messages1 run.messages2 run.messages3
    fi
    rm Makefile.file java.files class.files
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
# send notice to my email
#
cat note | mailx -s "CMPS-11 pa4 [script DONE]" amunishk@ucsc.edu
