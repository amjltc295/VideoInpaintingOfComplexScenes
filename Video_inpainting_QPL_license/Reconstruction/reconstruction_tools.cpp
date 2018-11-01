/*this function defines the functions which are tools used for the
reconstruction*/


#include "reconstruction_tools.h"

/*check if the pixel is occluded*/
template <class T>
int check_is_occluded( nTupleVolume<T> *imgVolOcc, int x, int y, int t)
{
	int zero;
	zero = 0;
	if (imgVolOcc->xSize == 0)
		return 0;
	if ( imgVolOcc->get_value(x,y,t,0) == 1)
		return 1;
	else
		return 0;
}

template <class T>
int check_disp_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume, nTupleVolume<T> *occVol)
{
	int dispValX,dispValY,dispValT,hPatchSizeX,hPatchSizeY,hPatchSizeT;
	int xB,yB,tB;
	int i,j,k,returnVal;

	hPatchSizeX = (int)floor((float)((departVolume->patchSizeX)/2));	/*half the patch size*/
	hPatchSizeY = (int)floor((float)((departVolume->patchSizeY)/2));	/*half the patch size*/
	hPatchSizeT = (int)floor((float)((departVolume->patchSizeT)/2));	/*half the patch size*/

	returnVal = 0;
	for (k=hPatchSizeT; k< ((dispField->tSize) -hPatchSizeT); k++)
		for (j=hPatchSizeY; j< ((dispField->ySize) -hPatchSizeY); j++)
			for (i=hPatchSizeX; i< ((dispField->xSize) -hPatchSizeX); i++)
			{
				dispValX = (int)dispField->get_value(i,j,k,0);
				dispValY = (int)dispField->get_value(i,j,k,1);
				dispValT = (int)dispField->get_value(i,j,k,2);

				/*if ( (fabs(dispValX) > w) || (fabs(dispValY) > w) || (fabs(dispValT) > w))
				{
					MY_PRINTF("Error, the displacement is greater than the minimum value w : %d.\n",w);
					MY_PRINTF(" dispValX : %d\n dispValY : %d\n dispValT : %d\n",dispValX,dispValY,dispValT);
					returnVal= -1;
				}*/

				xB = dispValX + i;
				yB = dispValY + j;
				tB = dispValT + k;

				if ( (xB <hPatchSizeX) || (yB <hPatchSizeY) || (tB <hPatchSizeT) || 
					(xB >= (arrivalVolume->xSize - hPatchSizeX)) || (yB >= (arrivalVolume->ySize - hPatchSizeY)) || (tB >= (arrivalVolume->tSize - hPatchSizeT)))
				{
					MY_PRINTF("Error, the displacement is incorrect.\n");
					MY_PRINTF("xA : %d\n yA : %d\n tA : %d\n",i,j,k);
					MY_PRINTF(" dispValX : %d\n dispValY : %d\n dispValT : %d\n",dispValX,dispValY,dispValT);
					MY_PRINTF(" xB : %d\n yB : %d\n tB : %d\n",xB,yB,tB);
					returnVal= -1;
				}
				/*else if (check_is_occluded(occVol,xB,yB,tB) == 1)
				{
					MY_PRINTF("Error, the displacement leads to an occluded pixel.\n");
					MY_PRINTF(" xB : %d\n yB : %d\n tB : %d\n",xB,yB,tB);
					returnVal= -1;
				}*/
			}
	return(returnVal);
}


/*this function gets the nth percentile of the current weights (set to 75th automatically)*/
float get_adaptive_sigma(float *weights, int weightsLength, float percentileSigma)
{
    int i, weightsInd, percentileInd;
    float *weightsTemp, adaptiveSigmaOut;
    float percentile = (float)percentileSigma/100;
    
    weightsTemp = (float*)malloc((size_t)weightsLength*sizeof(float));
    weightsInd = 0;
    for (i=0; i<weightsLength;i++)
    {
        if (weights[i] != -1)   /*we want to use this patch */
        {
            weightsTemp[weightsInd] = weights[i];
            weightsInd = weightsInd+1;
        }
    }
    weightsInd = weightsInd-1;
    std::sort(weightsTemp,weightsTemp+(weightsInd));
    
    percentileInd = (int)floor((float)percentile*weightsInd);
    
    adaptiveSigmaOut = sqrt(weightsTemp[percentileInd]);
    free(weightsTemp);
    return(adaptiveSigmaOut);
}

/*this function retieves the highest mode in the colour space of the
 different colours available for reconstructing a pixel*/
template <class T>
int estimate_best_colour(nTupleVolume<T> *imgVol, nTupleVolume<T> *imgVolModified,float *weights, int weightsLength,
                                float *colours, float sigmaColour,int i, int j, int k)
{
    int ii;
    int minWeightInd;
    float minWeight;
    
    
    minWeight = 100000.0;
    minWeightInd = 0;
    for (ii=0; ii<weightsLength; ii++)
    {
        if (weights[ii] != -1)
        {
			if (weights[ii] < minWeight)
            {
                minWeight = weights[ii];
                minWeightInd = ii;
            }
        }
    }

    imgVolModified->set_value(i,j,k,0,(T)(colours[minWeightInd]));
    imgVolModified->set_value(i,j,k,1,(T)(colours[minWeightInd+weightsLength]));
    imgVolModified->set_value(i,j,k,2,(T)(colours[minWeightInd+2*weightsLength]));
    
    return(1);
}
