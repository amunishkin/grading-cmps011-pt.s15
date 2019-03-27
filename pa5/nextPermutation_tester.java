//
// Driver program for [static void nextPermutation(int[] A)]
//

import java.*;

class nextPermutation_tester {
  public static void main( String[] args )
  {
    int[] A = new int[5]; // some use [0,n-1] others [1,n] => A.length=(n-2)
    for( int i=0; i<A.length; ++i ) { A[i]=i; }

    boolean failure = false;

    // do n! runs of printing
    int fac = 6; // 3!
    for( int i=0; i<fac; ++i ) {
      nextPermutation(A);
      if( (A[1]==1 && A[2]==2 && A[3]==3 && A[4]==4) && (i!=(fac-1)) ) {
        System.out.println("*** FAILURE 1 ***");
        failure = true;
      }
    }
    if( !failure ) { System.out.println("*** SUCCESS 1 ***"); }
  }

  // Below is student's code ========================================
  static void nextPermutation( int[] A ) {

