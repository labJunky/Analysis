/* 
    C function to make a random double
*/

#include "mex.h"
#include <math.h>
#include <stdio.h>

//Random number Generator

//void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] );
//double doRandom();

typedef unsigned long long int Ullong;
struct Ran
{
   Ullong u,v,w;
   float x1, x2, q;
   Ran(Ullong j) : v(4101842887655102017LL), w(1)
   {
       u=j^v; int64();
       v=u; int64();
       w=v; int64();
   }
   inline Ullong int64() {
       u = u * 2862933555777941757LL + 7046029254386353087LL;
       v^= v >> 17; v^= v << 31; v^= v >> 8;
       w = 4294957665U*(w & 0xffffffff) + (w >> 32);
       w = 4294957665U*w + (w >> 32);
       Ullong x = u ^ (u<<21); x ^= x >> 35; x ^= x <<4;
       return (x+v)^w;
   }
   inline double doub()
   {
       return 5.42101086242752217E-20 * int64();
   }
    
};
Ran rf((int)123456);

double doRandom()
{
    double value;
    value =  rf.doub();
    return value;
}

// Handle the matlab interfacing; This is also the main() function of C.
void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] );
{

  double y;
  double *y_pointer;
/*
  INPUT:
    Retrieve the (first) (scalar) input argument from the line

    y = fact ( x )
*/
 
/*
  COMPUTATION:
    Here is where the computation is done.
    In many cases, it would make sense to have this computation be in
    separate C function, so that the mexFunction is really just an
    interface.
*/
  y = doRandom();
/*
  OUTPUT:
    Make space for the output argument,
    retrieve the value of the pointer to that space,
    and copy the value of Y into the address for the output.
*/
  plhs[0] = mxCreateDoubleMatrix ( 1, 1, mxREAL );

  y_pointer = mxGetPr ( plhs[0] );

  *y_pointer = randomNumber;

  return;
};