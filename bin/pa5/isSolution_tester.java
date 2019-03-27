//
// Driver program for testing [static boolean isSolution(int[] A)]
//

import java.*;

class isSolution_tester {
  public static void main( String[] args )
  {
    int[] A = new int[5];
    int[] B = new int[5];
    for( int i=0; i<A.length; ++i ) { A[i]=i; B[i]=i; }

    // check wrong solution
    A[0]=1;
    A[1]=2;
    A[2]=3;
    A[3]=4;
    A[4]=1;
    if( isSolution(A) ) { System.out.println("*** FAILURE 1 ***"); }
    else { System.out.println("*** SUCCESS 1 ***"); }

    // check one correct solution
    A[0]=3;
    A[1]=1;
    A[2]=4;
    A[3]=2; 
    //A[4]; // Not used
    //
    //B[0]; // Not used
    B[1]=3;
    B[2]=1;
    B[3]=4;
    B[4]=2;
    if( isSolution(A) || isSolution(B) ) { System.out.println("*** SUCCESS 1 ***"); }
    else { System.out.println("*** FAILURE 1 ***"); }
  }

  // Student's code goes below ======================================
  static boolean isSolution( int[] A ) {

