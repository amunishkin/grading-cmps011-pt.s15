#!/bin/bash
# pa5.sh - grades pa5 performance and specification
#
# cmps11 (Intermediate Programming) - Spring 2015
#

SOURCES="Queens.java"

DIR=/afs/cats.ucsc.edu/class/cmps011-pt.s15/pa5
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
    echo "|| Grade Book for pa5 ||" >> $REPORT
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
        if [[ "${DIR}/${i}/$FILE" == "${DIR}/${i}/PAIR" ]]; then # check if pair submit
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
      if [ -e "${DIR}\${i}\PAIR" ]; then
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

      break # may need to fix later <---------------------------?????
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
          if [ -x Queens ]; then
            ./Queens -v 6 < ${currDIR}/empty_file 2> ${currDIR}/run.errs1 > ${currDIR}/run.messages1 & # run in background
            ./Queens -v < ${currDIR}/empty_file 2> ${currDIR}/run.errs2 > ${currDIR}/run.messages2 & # run in background
            ./Queens 8 < ${currDIR}/empty/file 2> ${currDIR}/run.errs3 > ${currDIR}/run.messages3 & # run in background
            ./Queens 10 < ${currDIR}/empty_file 2> ${currDIR}/run.errs4 > ${currDIR}/run.messages4 & #
            sleep 60 # wait for a minute
            ps aux | grep "Queens" | grep "amunishk" > prog.id
            grep -c "" > prog.id.count
          else
            java $prog -v 6 < ${currDIR}/empty_file 2> ${currDIR}/run.errs1 > ${currDIR}/run.messages1 & # run in background
            java $prog -v < ${currDIR}/empty_file 2> ${currDIR}/run.errs2 > ${currDIR}/run.messages2 & # run in background
            java $prog 8 < ${currDIR}/empty_file 2> ${currDIR}/run.errs3 > ${currDIR}/run.messages3 & # run in background
            java $prog 10 < ${currDIR}/empty_file 2> ${currDIR}/run.errs4 > ${currDIR}/run.messages4 & #
            sleep 60 # wait for a minute
            ps aux | grep "$prog" | grep "amunishk" > prog.id
            grep -c "" > prog.id.count
          fi
          while read line; do
            if (( $line >= 2 )); then
              echo "Your program has an infinite loop (-3 pts)" >> ${currDIR}/$REPORT
              ((GRADE = GRADE - 3))
              cat prog.id >> ${currDIR}/prog.id
            fi
          done < prog.id.count
          rm prog.id prog.id.count
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
        if [ -x "$DIR/$i/Queens" ]; then
          echo "./Queens -v 6" >> $REPORT
        else
          echo "java $prog -v 6" >> $REPORT
        fi
        grep -n "" run.messages1 >> $REPORT
        
        echo "" >> $REPORT
        if [ -x "$DIR/$i/Queens" ]; then
          echo "./Queens -v" >> $REPORT
        else
          echo "java $prog -v" >> $REPORT
        fi
        grep -n "" run.messages2 >> $REPORT

        echo "" >> $REPORT
        if [ -x "$DIR/$i/Queens" ]; then
          echo "./Queens 8" >> $REPORT
        else
          echo "java $prog 8" >> $REPORT
        fi
        grep -n "" run.messages3 >> $REPORT

        echo "" >> $REPORT
        if [ -x "${DIR}/$i/Queens" ]; then
          echo "./Queens 10" >> $REPORT
        else
          echo "java $prog 10" >> $REPORT
        fi
        grep -n "" run.messages4 >> $REPORT
        echo "-------------------------------" >> $REPORT
        #

        if [ ! -s run.messages1 ]; then
          echo "No print to screen (-1 pts)" >> $REPORT
          ((GRADE = GRADE - 1))
        fi
        grep "[Ee]xception" run.errs1 > err.messages
        grep "[Ee]xception" run.errs2 >> err.messages
        grep "[Ee]xception" run.errs3 >> err.messages
        grep "[Ee]xception" run.errs4 >> err.messages
        if [ -s err.messages ]; then
          echo "Exceptions found (-5 pts)" >> $REPORT
          grep -n "" err.messages >> $REPORT
          echo "" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm err.messages run.errs1 run.errs2 run.errs3 run.errs4

        echo "" >> $REPORT
        # (3) correct output (20 pts) ================================
        ## Queens -v 6
        grep "2" run.messages1 | grep "4" | grep "6" | grep "1" | grep "3" | grep "5" | wc -l > correct.out
        while read line; do
          if (( 4 != $line )); then
            echo "[Queens -v 6] does not give correct result (-5 pts)" >> $REPORT
            ((GRADE = GRADE - 5))
          fi
        done < correct.out
        rm correct.out

        ## Queens -v
        grep "Usage: Queens [[]-v[]] number" run.messages2 > correct.out
        if [ ! -s correct.out ]; then
          echo "[Queens -v] does not print usage message (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm correct.out

        ## Queens 8
        grep "92" run.messages3 > correct.out
        if [ ! -s correct.out ]; then
          echo "[Queens 8] does not print '92 solutions' (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm correct.out

        ## Queens 10
        grep "724" run.messages4 > correct.out
        if [ ! -s correct.out ]; then
          echo "[Queens 10] does not print '724 solutions' (-5 pts)" >> $REPORT
          ((GRADE = GRADE - 5))
        fi
        rm correct.out

        break # need to fix ???
      done < class.files
    else
      echo "No class file(s) to test" >> $REPORT
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
      if [ ! -x Queens ]; then
        echo "[make] does not produce an executable [Queens] (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi

      make clean
      ls | grep -o "[.]class" > mk.clean.check
      if [ -s mk.clean.check ]; then
        echo "[make clean] does not remove [.class] files (-2 pts)" >> $REPORT
        ((GRADE = GRADE - 2))
      fi
      rm mk.clean.check

      make # keep exe Queens
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
     #

      echo "" >> $REPORT
     # (3) Function specs (20 pts) =======================================
      grep "static void nextPermutation" $name > permute.specs
      if [ -s permute.specs ]; then
        cat $name | sed -e '1,/static void nextPermutation/d' > permute.specs
      fi
      grep "static boolean isSolution" $name > solution.specs
      if [ -s solution.specs ]; then
        cat $name | sed -e '1,/static boolean isSolution/d' > solution.specs
      fi

      break # need to fix later
     done < java.files
     #
     #./mk.sh ## 1. creates 'permutation_test'
             ## 2. creates 'solution_test'

     if [ -s permute.specs ]; then
       cp nextPermutation_tester.java nP.java
       cat permute.specs >> nP.java

       javac nP.java
       java nextPermutation_tester > permutation_test
       rm nextPermutation_tester.class nP.java
     fi
     rm permute.specs

     if [ -s solution.specs ]; then
       cp isSolution_tester.java is.java
       cat solution.specs >> is.java

       javac is.java
       java isSolution_tester > solution_test
       rm isSolution_tester.class is.java
     fi
     rm solution.specs

     if [ -e permutation_test ]; then
       echo "----------> [nextPermutation] TEST <----------" >> $REPORT
       grep -n "" permutation_test >> $REPORT
       grep "FAILURE 1" permutation_test > func.specs
       if [ -s func.specs ]; then
         echo "[static void nextPermutation(int[] A)] does not give n! permutations (-5 pts)" >> $REPORT
         ((GRADE = GRADE - 5))
       fi
       rm func.specs
       #
       ## lexicographic ordering???
       rm permutation_test
     else
       echo "No [static void nextPermutation(int[] A)] (-10 pts)" >> $REPORT
       ((GRADE = GRADE - 10))
     fi
     
     if [ -e solution_test ]; then
       echo "----------> [isSolution] TEST <----------" >> $REPORT
       grep -n "" solution_test >> $REPORT
       grep "FAILURE 1" solution_test > func.specs
       if [ -s func.specs ]; then
         echo "[static boolean isSolution(int[] A)] gives incorrect evaluation" >> $REPORT
         ((GRADE = GRADE - 5))
       fi
       rm func.specs
       #
       ## only one compare per Queens???
       rm solution_test
     else
       echo "No [static boolean isSolution(int[] A)] (-10 pts)" >> $REPORT
       ((GRADE = GRADE - 10))
     fi
     
     echo "" >> $REPORT
     # (4) Program structure (10 pts) ===============================
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

      grep "Scanner" $name > prog.funcs
      grep "File" $name >> prog.funcs
      if [ -s prog.funcs ]; then
        echo "Found user interaction other than command-line arguments (-5 pts)" >> $REPORT
        grep -n "" prog.funcs >> $REPORT
        ((GRADE = GRADE - 5))
      fi
      rm prog.funcs

      break # need to fix ???
     done < java.files

    else
      echo "" >> $REPORT
      echo "Cannot evaluate your program completely since there is no [.java] file (-60 pts)" >> $REPORT
      ((GRADE = GRADE - 60))
    fi
    if [ -s class.files ]; then
      rm run.messages1 run.messages2 run.messages3 run.messages4
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
# send notice to my email once script done
#
cat note | mailx -s "CMPS-11 pa5 [script DONE]" amunishk@ucsc.edu

