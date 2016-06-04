# include "mex.h"
  int i;
  double x;
  double y;
  double *y_pointer;
  
  void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] );
  double doFactorial( double x);

double doFactorial(double x)
{ 
  y = 1.0;
  for ( i = 1; i <= ( int ) x; i++ )
  {
    y = y * ( double ) i;
  }
  return y;
}

/**********************************************************************/

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )

/**********************************************************************/
/*
  Purpose:

    MEXFUNCTION is a MATLAB/C interface for the factorial function.

  Discussion:

    This file should be called "fact.c".  It should be placed in the
    MATLAB user's path.  It can either be compiled externally, with
    a command like

      mex fact.c

    creating a compiled MEX file, or, inside of MATLAB, the command

      mex fact.c

    accomplishes the same task.  Once the file has been compiled,
    The MATLAB user can invoke the function by typing:

      y = fact ( x )

    The routine carries out the computation of the factorial of X,
    whose value is returned in Y.

  Modified:

    17 July 2006

  Author:

    Duane Hanselman and Bruce Littlefield

  Reference:

    Duane Hanselman, Bruce Littlefield,
    Mastering MATLAB 7,
    Pearson Prentice Hall, 2005,
    ISBN: 0-13-143018-1.

    The Mathworks,
    MATLAB External Interfaces,
    The Mathworks, 2000.

  Parameters:

    Input, int NLHS, the number of output arguments.

    Input, mxArray *PLHS[NLHS], pointers to the output arguments.

    Input, int NRHS, the number of input arguments.

    Input, const mxArray *PRHS[NRHS], pointers to the input arguments.
*/
{  
  
/*
  INPUT:
    Retrieve the (first) (scalar) input argument from the line

    y = fact ( x )
*/
  x = mxGetScalar ( prhs[0] );
/*
  COMPUTATION:
    Here is where the computation is done.
    In many cases, it would make sense to have this computation be in
    separate C function, so that the mexFunction is really just an
    interface.
*/
y = doFactorial(x);

/*
  OUTPUT:
    Make space for the output argument,
    retrieve the value of the pointer to that space,
    and copy the value of Y into the address for the output.
*/
  plhs[0] = mxCreateDoubleMatrix ( 1, 1, mxREAL );

  y_pointer = mxGetPr ( plhs[0] );

  *y_pointer = y;

  return;
}