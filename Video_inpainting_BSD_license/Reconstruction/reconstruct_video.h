/*this is the include function for the colour estimation*/

#ifndef COLOUR_ESTIMATION_H
#define COLOUR_ESTIMATION_H


	#include "common_reconstruction.h"
    #include "../Image_structures/image_structures.h"
    #include "reconstruction_tools.h"

    template <class T>
    int check_is_occluded( nTupleVolume<T> *imgVolOcc, int x, int y, int t);

    template <class T>
    int check_disp_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume,
            nTupleVolume<T> *arrivalVolume, nTupleVolume<T> *occVol);
	
    template <class T>
    void reconstruct_video(nTupleVolume<T>* imgVol, nTupleVolume<T>* occVol,
            nTupleVolume<T>* dispField, float sigmaColour,
            int useAllPatches,int reconstructionType);

#endif