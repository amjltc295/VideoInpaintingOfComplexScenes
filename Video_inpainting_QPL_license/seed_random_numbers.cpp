//this is the mex function for testing the seed

#include <string.h> 
#include <mex.h>
#include <matrix.h>
#include <math.h>
#include <time.h>


/*******************************************************************************/
/* mexFUNCTION                                                                 */
/* Gateway routine for use with MATLAB.                                        */
/*******************************************************************************/


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs>0) //seed with given number
        srand( (unsigned int) (*mxGetPr(prhs[0])));
    else
        srand ( time(NULL) );   //create random number seed
    
// //     for (int i=0; i<20; i++)
// //     {
// //         mexPrintf("%d\n",rand());
// //     }
}