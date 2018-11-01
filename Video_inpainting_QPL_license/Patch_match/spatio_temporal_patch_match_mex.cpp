//this is the mex function for a spatio-temporal patchMatch


#include <string.h> 
#include <mex.h>
#include <matrix.h>
#include <math.h>


#include "../Image_structures/image_structures.cpp"
#include "patch_match.h"
//#include "patch_match_cuda.cu"
#include "patch_match_measure.cpp"
#include "patch_match_tools.cpp"
#include "patch_match.cpp"

/*******************************************************************************/
/* mexFUNCTION                                                                 */
/* Gateway routine for use with MATLAB.                                        */
/*******************************************************************************/

//dispField = spatio_temporal_patch_match_mex( single(A), single(B),size(A)', size(B)', parameters);
//inputs 
//  0/imgA
//  1/imgB
//  2/patchMatch parameters
//  3/ first guess for the ANN shift map
//  4/occlusion volume
//  5/ volume of pixels for who we wish to calculate the shift map

#define IMG_VOL_A_INPUT 0
#define IMG_VOL_B_INPUT 1
#define PATCH_MATCH_PARAMS_INPUT 2
#define FIRST_GUESS_INPUT 3
#define OCC_VOL_INPUT 4
#define MODIFICATION_VOL_INPUT 5

void parse_patch_match_parameters(const mxArray* prhs,parameterStruct* params);
void failure_return(mxArray** plhs);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        float *imgVolATemp, *imgVolBTemp,
                *imgVolOccTemp, *firstGuessVolTemp, *imgVolModTemp;
        int * imgSizesA, * imgSizesB;
        float *dispFieldTemp;
        nTupleVolume<float> *dispField;
        int nXdisp,nYdisp,nTdisp;
        int numDimsA, numDimsB;
        int i,j,k,p,q;
        int occTemp;
        parameterStruct *patchMatchParams;
        mwSize resultSize[4];

        if (nrhs < (PATCH_MATCH_PARAMS_INPUT+1))
        {
            mexErrMsgTxt("Error. A minimum of 3 parameters are needed in the spatio-temporal patch match mexfunction.\n");
            return;
        }
            
        if ( (mxGetClassID(prhs[IMG_VOL_A_INPUT]) != mxSINGLE_CLASS) || (mxGetClassID(prhs[IMG_VOL_B_INPUT]) != mxSINGLE_CLASS) )
        {
            mexErrMsgTxt("Error, the input matrices must be of mxSINGLE_CLASS type");
			failure_return(plhs);
            return;
        }
        patchMatchParams = (parameterStruct*)new parameterStruct;
        
        //get the parameters
        if (!mxIsStruct(prhs[PATCH_MATCH_PARAMS_INPUT]) )
        {
            mexErrMsgTxt("Error, the patchMatch parameter input must be a structure");
			failure_return(plhs);
            return;
        }
        parse_patch_match_parameters(prhs[PATCH_MATCH_PARAMS_INPUT],patchMatchParams);

        imgVolATemp = (float*)mxGetPr(prhs[IMG_VOL_A_INPUT]); // Width target
        imgVolBTemp = (float*)mxGetPr(prhs[IMG_VOL_B_INPUT]); // Height target
        

        // Get sizes of variables
        imgSizesA = (int*)mxGetDimensions (prhs[IMG_VOL_A_INPUT]);  // sizes of imgVolA
        numDimsA = (int)mxGetNumberOfDimensions(prhs[IMG_VOL_A_INPUT]);  // number of dimensions of imgVolA
        imgSizesB = (int*)mxGetDimensions (prhs[IMG_VOL_B_INPUT]);  // sizes of imgVolB
        numDimsB = (int)mxGetNumberOfDimensions(prhs[IMG_VOL_B_INPUT]);  // number of dimensions of imgVolA
        
        if ((numDimsA != 4) || (numDimsB != 4))
        {
            mexPrintf("image sizes length :\n A : %d\nB : %d",numDimsA,numDimsB);
            mexErrMsgTxt("Error, the array sizes must be of length 4 (x,y,t,multivalue).");
			failure_return(plhs);
            return;
        }
		
        if (imgSizesA[3] != imgSizesB[3])
        {
            mexErrMsgTxt("Error, the arrays must have the same multivalued pixels sizes");
			failure_return(plhs);
            return;
        }
        
		if ( (imgSizesA[2] < patchMatchParams->patchSizeX) || (imgSizesA[1] < patchMatchParams->patchSizeY) || (imgSizesA[3] < patchMatchParams->patchSizeT) ||
			(imgSizesB[2] < patchMatchParams->patchSizeX) || (imgSizesB[1] < patchMatchParams->patchSizeY) || (imgSizesB[3] < patchMatchParams->patchSizeT)  )
        {
            mexErrMsgTxt("Error, the patch sizes are too large for at least one of the images.");
			failure_return(plhs);
            return;
        }

        //case where we want an occlusion volume
        if ( (nrhs >= (FIRST_GUESS_INPUT+1)) && (!mxIsEmpty(prhs[FIRST_GUESS_INPUT]) ) ) //first guess
        {
            firstGuessVolTemp = (float*)mxGetPr(prhs[FIRST_GUESS_INPUT]); //first guess volume
        }
        else
            firstGuessVolTemp = NULL;
        
        occTemp = 0;
        if ( (nrhs >= (OCC_VOL_INPUT+1)) && (!mxIsEmpty(prhs[OCC_VOL_INPUT]) ) )  //occlusion volume
        {
            imgVolOccTemp = (float*)mxGetPr(prhs[OCC_VOL_INPUT]); //occlusion volume
        }
        else
            imgVolOccTemp = NULL;

        if ( (nrhs >= (MODIFICATION_VOL_INPUT+1) ) && (!mxIsEmpty(prhs[MODIFICATION_VOL_INPUT]) ) ) //modification volume
        {
            imgVolModTemp = (float*)mxGetPr(prhs[MODIFICATION_VOL_INPUT]); //modification volume
        }
        else
            imgVolModTemp = NULL;
        
        mexPrintf("Number of iterations : %d\n",patchMatchParams->nIters);
        mexPrintf("Patch sizes : %d %d %d\n",patchMatchParams->patchSizeX,patchMatchParams->patchSizeY,patchMatchParams->patchSizeT);
        mexPrintf("x : %d\ny : %d\nt : %d\n",(int)imgSizesA[2],(int)imgSizesA[1],(int)imgSizesA[3]);
        
        //patch match execution
        dispField = wrapper_patch_Match_ANN<float>(imgVolATemp, imgVolBTemp, firstGuessVolTemp, imgVolOccTemp,imgVolModTemp,(int)(imgSizesA[2]), (int)(imgSizesA[1]), (int)(imgSizesA[3]), 
									(int)(imgSizesB[2]), (int)(imgSizesB[1]), (int)(imgSizesB[3]), (int)(imgSizesA[0]), 
                patchMatchParams->patchSizeX, patchMatchParams->patchSizeY, patchMatchParams->patchSizeT, patchMatchParams);
        if (dispField == NULL)
        {
            free(patchMatchParams);
            resultSize[0] = 1;
            plhs[0] = (mxArray*)mxCreateNumericArray((mwSize)1,(mwSize*)resultSize, mxSINGLE_CLASS, (mxComplexity)false);
            dispFieldTemp = (float*)mxGetPr(plhs[0]);
            *dispFieldTemp = -1;
            return;
        }
        
        //OUTPUT
        // Create output matrix
        resultSize[0] = (int)(imgSizesA[0])+1;
        resultSize[1] = (int)(imgSizesA[1]);
        resultSize[2] = (int)(imgSizesA[2]);
        resultSize[3] = (int)(imgSizesA[3]);
        
        plhs[0] = (mxArray*)mxCreateNumericArray((mwSize)4,(mwSize*)resultSize, mxSINGLE_CLASS, (mxComplexity)0);

        dispFieldTemp = (float*)mxGetPr(plhs[0]);

        //sizes of c arrays
        nTdisp = (int)((int)(imgSizesA[0]+1))*((int)imgSizesA[1])*((int)imgSizesA[2]); //p*x*y
        nXdisp = (int)((imgSizesA[0]+1)*imgSizesA[1]); //p*y
        nYdisp = (int)(imgSizesA[0]+1);   //p

        //copy info
        for (k=0; k<(int)(imgSizesA[3]); k++)
            for (i=0; i<(int)(imgSizesA[2]); i++)
                for (j=0; j<(int)(imgSizesA[1]); j++)
                    for (p=0; p<(int)(imgSizesA[0]+1); p++)
                    {
                        dispFieldTemp[ k*nTdisp + j*nYdisp + i*nXdisp+ p] = 
                                dispField->get_value(i,j,k,p);
                    }
        
        delete dispField;
        free(patchMatchParams);
}

void failure_return(mxArray** plhs)
{
    int *dispFieldTemp;
    plhs[0] = mxCreateNumericMatrix((mwSize)1,(mwSize)1, mxINT32_CLASS, (mxComplexity)0);
    dispFieldTemp = (int*)mxGetPr(plhs[0]);
    *dispFieldTemp = -1;
}