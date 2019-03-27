#!/bin/bash

if [ -s permute.specs ]; then
  cp nextPermutation_test.java nextPermutation.java
  cat permute.specs >> nextPermutation.java

  javac nextPermutation.java
  java nextPermutation_tester > permute_test

  rm nextPermutation.java
fi
rm permute.specs

if [ -s solution.specs ]; then
  cp isSolution_test.java isSolution.java
  cat solution.specs >> isSolution.java

  javac isSolution.java
  java isSolution_tester > solution_test

  rm isSolution.java
fi
rm solution.specs

