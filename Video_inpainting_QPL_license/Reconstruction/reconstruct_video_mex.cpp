/*this is the mex function for the colour estimation of the pixels in an
image volume, given the correspondances (displacement) field*/

#include <string.h>
#include <mex.h>
#include <matrix.h>
#include <math.h>

#include "../Image_structures/image_structures.cpp"
#include "reconstruction_tools.cpp"
#include "reconstruct_video.cpp"

#define IMG_VOL_INPUT 0
#define OCC_VOL_INPUT 1
#define DISP_FIELD_INPUT 2
#define PATCH_MATCH_PARAMS_INPUT 3
#define SIGMA_COLOUR_INPUT 4
#define USE_ALL_PATCHES_INPUT 5
#define RECONSTRUCTION_TYPE_INPUT 6

/*******************************************************************************/
/* mexFUNCTION                                                                 */
/* Gateway routine for use with MATLAB.                                        */
/*******************************************************************************/

/*inputs 
  0/imgVol
  1/occlusion volume
  2/dispField
  3/patchMatchParams
  4/sigmaColour
  5/useAllPatches
  6/reconstructionType
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        nTupleVolume<float> *imgVol, *occVol, *dispField;
        const mwSize * imgVolSizes, *dispFieldSizes;
        float sigmaColour;
        float *dispFieldTemp;
        int nY, nX, nT;
        int numDimsImgVol, numDimsDispField;
        int i,j,k,p;
        int useAllPatches, reconstructionType;
        parameterStruct *patchMatchParams;
        mwSize resultSize[4];

        if (nrhs < (RECONSTRUCTION_TYPE_INPUT+1))
        {
            mexErrMsgTxt("Error. A minimum of 8 parameters are needed in the reconstruction mexfunction.\n");
            return;
        }

        if ( (mxGetClassID(prhs[IMG_VOL_INPUT]) != mxSINGLE_CLASS) || (mxGetClassID(prhs[OCC_VOL_INPUT]) != mxSINGLE_CLASS) ||
               (mxGetClassID(prhs[DISP_FIELD_INPUT]) != mxSINGLE_CLASS))
        {
            mexErrMsgTxt("Error, the input images, displacement field, and occlusion volumes must be of mxSINGLE_CLASS.");
			plhs[0] = mxCreateNumericMatrix((mwSize)1,(mwSize)1, mxINT32_CLASS, (mxComplexity)0);
            dispFieldTemp = (float*)mxGetPr(plhs[0]);
            *dispFieldTemp = -1;
            return;
        }

        /* Get sizes of variables*/
        imgVolSizes = mxGetDimensions(prhs[IMG_VOL_INPUT]);  /* sizes of imgVol*/
        numDimsImgVol = (int)mxGetNumberOfDimensions(prhs[IMG_VOL_INPUT]);  /*length of sizes of imgVolA*/
        dispFieldSizes = mxGetDimensions(prhs[DISP_FIELD_INPUT]);  /*sizes of imgVolB*/
        numDimsDispField = (int)mxGetNumberOfDimensions(prhs[DISP_FIELD_INPUT]);  /* length of sizes of dispField*/
        
        if ((numDimsImgVol != 4) || (numDimsDispField != 4))
        {
            mexPrintf("Number of dimensions :\n imgVol : %d\nimgVolFine : %d\nDispField : %d\n",numDimsImgVol,numDimsDispField);
            mexErrMsgTxt("Error, the number of array dimensions must be 4 (x,y,t,multivalue).");
			plhs[0] = mxCreateNumericMatrix((mwSize)1,(mwSize)1, mxINT32_CLASS, (mxComplexity)0);
            dispFieldTemp = (float*)mxGetPr(plhs[0]);
            *dispFieldTemp = -1;
            return;
        }
		
        /*occlusion hole*/
        //get the patchMatch parameters
        ASSERT(mxIsStruct(prhs[PATCH_MATCH_PARAMS_INPUT]) );
        patchMatchParams = (parameterStruct*)new parameterStruct;
        parse_patch_match_parameters(prhs[PATCH_MATCH_PARAMS_INPUT],patchMatchParams);
        sigmaColour = (float)(*mxGetPr(prhs[SIGMA_COLOUR_INPUT]));  /* sigma colour*/
		
		if ( (imgVolSizes[2] < patchMatchParams->patchSizeX) || (imgVolSizes[1] < patchMatchParams->patchSizeY) || (imgVolSizes[3] < patchMatchParams->patchSizeT) )
        {
            MY_PRINTF("Image sizes :\n x : %d, y : %d, t : %d\n",(int)imgVolSizes[2],(int)imgVolSizes[1],(int)imgVolSizes[3]);
            MY_PRINTF("Patch sizes :\n x : %d, y : %d, t : %d\n",(int)patchMatchParams->patchSizeX,(int)patchMatchParams->patchSizeY,(int)patchMatchParams->patchSizeT);
            mexErrMsgTxt("Error, the patch sizes are too large for the image.");
			plhs[0] = mxCreateNumericMatrix((mwSize)1,(mwSize)1, mxINT32_CLASS, (mxComplexity)0);
            dispFieldTemp = (float*)mxGetPr(plhs[0]);
            *dispFieldTemp = -1;
            return;
        }
        
        if (nrhs >= (USE_ALL_PATCHES_INPUT+1))
            useAllPatches = (int)(*mxGetPr(prhs[USE_ALL_PATCHES_INPUT]));  /* if we want to use all surrounding patches or not*/
        else
            useAllPatches = 1;
        
        if (nrhs >= (RECONSTRUCTION_TYPE_INPUT+1))
            reconstructionType = (int)(*mxGetPr(prhs[RECONSTRUCTION_TYPE_INPUT]));  /* the manner in which we want to reconstruct the image*/
        else
            reconstructionType = 0;
    
        int imageIndexing = 1;
        
                //input image volumes
        imgVol = new nTupleVolume<float>(NCHANNELS, (int)imgVolSizes[2], (int)imgVolSizes[1], (int)imgVolSizes[3],
                patchMatchParams->patchSizeX, patchMatchParams->patchSizeY, patchMatchParams->patchSizeT,imageIndexing,
            (float*)mxGetPr(prhs[IMG_VOL_INPUT]));
        occVol = new nTupleVolume<float>(1, (int)imgVolSizes[2], (int)imgVolSizes[1], (int)imgVolSizes[3],
                patchMatchParams->patchSizeX, patchMatchParams->patchSizeY, patchMatchParams->patchSizeT,imageIndexing,
                (float*)mxGetPr(prhs[OCC_VOL_INPUT]));
        
        //shift volume
        dispField = new nTupleVolume<float>(4, (int)imgVolSizes[2], (int)imgVolSizes[1], (int)imgVolSizes[3],
                patchMatchParams->patchSizeX, patchMatchParams->patchSizeY, patchMatchParams->patchSizeT,imageIndexing,
            (float*)mxGetPr(prhs[DISP_FIELD_INPUT]));
        
        /*reconstruction algorithm*/
        reconstruct_video(imgVol, occVol,
            dispField, sigmaColour, useAllPatches, reconstructionType);
        
        /*OUTPUT*/
        /* Create output matrix*/
        resultSize[0] = (int)(imgVolSizes[0]);
        resultSize[1] = (int)(imgVolSizes[1]);
        resultSize[2] = (int)(imgVolSizes[2]);
        resultSize[3] = (int)(imgVolSizes[3]);
        plhs[0] = mxCreateNumericArray((mwSize)4,(mwSize*)resultSize, mxSINGLE_CLASS, (mxComplexity)0);
        float *imgVolOutTemp = (float*)mxGetPr(plhs[0]);
        memcpy(imgVolOutTemp,imgVol->get_value_ptr( 0,0,0,0), resultSize[0]*resultSize[1]*resultSize[2]*resultSize[3]*sizeof(float));
        
        delete imgVol;
        delete patchMatchParams;
        return;
}
