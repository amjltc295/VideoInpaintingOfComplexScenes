//this function calculates the approximate nearest neighbour field for patch match
//in a volume, with multivalued pixels

#include "patch_match.h"

template <class T>
nTupleVolume<T> * wrapper_patch_Match_ANN(T *videoA, T *videoB, T *videoFirstGuess, T *videoOcc, T *videoMod,
                                    int xSizeA, int ySizeA, int tSizeA, 
									int xSizeB, int ySizeB, int tSizeB, int nTupleSize,
                                    int patchSizeX, int patchSizeY, int patchSizeT,
                                    const parameterStruct *params)
{
	//declarations
	nTupleVolume<T> *imgVolA, *imgVolB, *dispField, *firstGuessVol,*imgVolOcc, *imgVolMod;

	imgVolA = new nTupleVolume<T>(nTupleSize, xSizeA, ySizeA, tSizeA, patchSizeX, patchSizeY, patchSizeT,1,videoA);
	imgVolB = new nTupleVolume<T>(nTupleSize, xSizeB, ySizeB, tSizeB, patchSizeX, patchSizeY, patchSizeT,1,videoB);

    if (videoFirstGuess == NULL)
	{
		firstGuessVol = new nTupleVolume<T>();
	}
	else
	{
		firstGuessVol = new nTupleVolume<T>(NDIMS+1, xSizeA, ySizeA, tSizeA, patchSizeX, patchSizeY, patchSizeT,1,videoFirstGuess);
	}
	for (int k=0; k<tSizeA; k++)
		for (int j=0; j<ySizeA; j++)
			for (int i=0; i<xSizeA; i++)
				for (int p=0; p<4; p++)
				{
					float floatTemp = firstGuessVol->get_value(i,j,k,p);
				}

	//put value in imgVolOcc
	if (videoOcc == NULL)
	{
		imgVolOcc = new nTupleVolume<T>();
	}
	else
	{
		imgVolOcc = new nTupleVolume<T>(1, xSizeB, ySizeB, tSizeB, patchSizeX, patchSizeY, patchSizeT, 1, videoOcc);
	}
    
    	//put value in imgVolMod
	if (videoMod == NULL)
	{
		imgVolMod = new nTupleVolume<T>();
	}
	else
	{
		imgVolMod = new nTupleVolume<T>(1, xSizeA, ySizeA, tSizeA, patchSizeX, patchSizeY, patchSizeT,1 ,videoMod);
	}

    mexPrintf("Before patch_match_ANN\n");
	dispField = patch_match_ANN(imgVolA, imgVolB, firstGuessVol, imgVolOcc,imgVolMod, params);
    mexPrintf("After patch_match_ANN\n");
    if (dispField == NULL)
    {
        delete imgVolA;
        delete imgVolB;
        delete firstGuessVol;
        delete imgVolOcc;
        delete imgVolMod;

        return NULL;
    }
    //mexPrintf("After patch_match_ANN\n");
    //show_nTuple_volume(dispField);
	//put the displacement values in the output array

	//free memory
    //mexPrintf("Before destruction imgVolA\n");
	delete imgVolA;
    //mexPrintf("Before destruction imgVolB\n");
	delete imgVolB;
    //mexPrintf("Before destruction firstGuessVol\n");
    delete firstGuessVol;
    //mexPrintf("Before destruction imgVolOcc\n");
	delete imgVolOcc;
    //mexPrintf("Before destruction imgVolMod\n");
    delete imgVolMod;
    //mexPrintf("Before destruction dispField\n");
	return(dispField);
}

//this function calculates a nearest neighbour field, from imgVolA to imgVolB
template <class T>
nTupleVolume<T> * patch_match_ANN(nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB, 
        nTupleVolume<T> *firstGuessVol, nTupleVolume<T> *imgVolOcc,nTupleVolume<T> *imgVolMod,
        const parameterStruct *params)
{
	//decalarations
	int xSizeA, ySizeA, tSizeA, xSizeB, ySizeB, tSizeB, nTupleSize;
	int i, nbModified;
    clock_t startTime;
    double propagationTime,randomSearchTime;
	nTupleVolume<T> *dispField;

	//get image volume sizes
	xSizeA = imgVolA->xSize;
	ySizeA = imgVolA->ySize;
	tSizeA = imgVolA->tSize;
	nTupleSize = imgVolA->nTupleSize;
	xSizeB = imgVolB->xSize;
	ySizeB = imgVolB->ySize;
	tSizeB = imgVolB->tSize;

	//check certain parameters
	if(nTupleSize != (imgVolB->nTupleSize) )
	{
		MY_PRINTF("Error in patch_match_ANN, the size of the vector associated to each pixel is different for the two image volumes.");
		return NULL;
	}
	if( (imgVolA->patchSizeX != (imgVolB->patchSizeX)) || (imgVolA->patchSizeY != (imgVolB->patchSizeY)) ||
		(imgVolA->patchSizeT != (imgVolB->patchSizeT))  )	//check that the patch sizes are equal
	{
		MY_PRINTF("Error in patch_match_ANN, the size of the patches are not equal in the two image volumes.");
		return NULL;
	}
	if ( ( imgVolA->patchSizeX > imgVolA->xSize) || ( imgVolA->patchSizeY > imgVolA->ySize) || ( imgVolA->patchSizeT > imgVolA->tSize) ||
		( imgVolA->patchSizeX > imgVolB->xSize) || ( imgVolA->patchSizeY > imgVolB->ySize) || ( imgVolA->patchSizeT > imgVolB->tSize)
		)	//check that the patch size is less or equal to each dimension in the images
	{
		MY_PRINTF("Error in patch_match_ANN, the patch size is to large for one or more of the dimensions of the image volumes.");
		return NULL;
	}

	//create the displacement field
    //mexPrintf("Before dispField creation\n");
	dispField = new nTupleVolume<T>(NDIMS+1, xSizeA, ySizeA, tSizeA, imgVolA->patchSizeX, imgVolA->patchSizeY, imgVolA->patchSizeT,1);
    //mexPrintf("After dispField creation\n");
	//show_nTuple_volume(dispField);
	//randomly initialise the displacement field
    
    //#pragma omp parallel
    //mexPrintf("Hello\n");
    
    //cuda_full_search(dispField,imgVolA,imgVolB,imgVolOcc,imgVolMod);
    //mexPrintf("dispField[1] : %f\n",dispField->values[1]);
    //return(dispField);
    propagationTime = 0.0;
    randomSearchTime = 0.0;
    ssdTime = 0.0;
    randomGenerationTime = 0.0;
    if (params->fullSearch == 1)
    {
        //memset(dispField->values,0,(size_t)(dispField->xSize)*(dispField->ySize)*(dispField->tSize)*(dispField->nTupleSize)*sizeof(float));
        initialise_displacement_field(dispField, imgVolA,imgVolB, firstGuessVol, imgVolOcc,params);
        //memset(dispField->values,0,(size_t)(dispField->xSize)*(dispField->ySize)*(dispField->tSize)*(dispField->nTupleSize)*sizeof(float));
        startTime = clock();
        patch_match_full_search(dispField, imgVolA,imgVolB, imgVolOcc,imgVolMod,params);
        propagationTime = propagationTime + double(clock() - startTime);
    }
    else    //normal patchMatch
    {
        mexPrintf("Initialisation\n");
        initialise_displacement_field(dispField, imgVolA, imgVolB, firstGuessVol, imgVolOcc,params);
        //show_nTuple_volume(dispField);
        if (check_disp_field(dispField, imgVolA, imgVolB,imgVolOcc,params) == -1)
            return(dispField);
        for (i=0; i<(params->nIters); i++)
        {
            startTime = clock();
            
            nbModified = patch_match_propagation(dispField, imgVolA, imgVolB,imgVolOcc,imgVolMod,params,i);
            propagationTime = propagationTime + double(clock() - startTime);
            
            startTime = clock();
            
            nbModified = patch_match_random_search(dispField, imgVolA,imgVolB, imgVolOcc,imgVolMod,params);
            randomSearchTime = randomSearchTime + double(clock() - startTime);
        }
    }
    MY_PRINTF("Propagation time : %f s\n",propagationTime/CLOCKS_PER_SEC);
    MY_PRINTF("Random search time : %f s\n",randomSearchTime/CLOCKS_PER_SEC);

	return(dispField);
}
